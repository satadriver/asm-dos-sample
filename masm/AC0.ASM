.386
stack segment stack
db 400h dup (0)
stack ends

data segment para use16
gdt0                    dq 0
gdt1                    dq 000098000000ffffh
gdt2                    dq 000092000000ffffh
gdt3                    dq 00cf92050000ffffh
gdt4                    dq 10cf92000000ffffh
gdt5                    dq 000092800000ffffh
gdt6                    dq 000092000000ffffh
gdtend=$-gdt0
gdtlimit                dw gdtend-1
gdtbase                 dd 0

align 16
prdtable                dq 8000fa0000000000h
prdbase                 dd 0

wavfile_lenthlimit      db 20h 
wavfile_factlenth       db 0
wavfile_name            db 20h dup (0)
wavhead                 db 100h dup (0)

datasize                dd 0
datastart               dd 0
bufferbase              dd 5000h
buffer                  dd 6000h
sipos                   dw 0
dipos                   dw 0

slot0                   dw 9800h
slot4321                dt 0
slot8765                dt 0
slotcba9                dt 0

ac97_mixer_basereg      dw 0
ac97_busmaster_basereg  dw 0
ac97_int_pin_line       dd 0
ac97_int_line           db 5


msginput                db 'Please input the music name(such as "f:\wavefile\start.wav") to play:',0ah,0dh,24h
msg_notfindDEVICE       db 'Not find ac97 audio device,press any key to quit...',0ah,0dh,24h
msg_openfailure         db 'Can not open file,please check file name...',0ah,0dh,24h
data ends





code segment para use16
assume cs:code
start:
main proc near
call init
call get_ac97_basereg
call set_intrrupt
toreadfile:
call readfile
mov ax,ss
shl eax,16
mov ax,sp
mov ds:[stackptr],eax
lgdt qword ptr fs:[gdtlimit]
cli
mov al,2
out 92h,al
mov eax,cr0
or al,1
mov cr0,eax
db 0eah
dw 0
dw 8
rmmode:
mov ax,data
mov ds,ax
mov es,ax
mov ss,ax
mov fs,ax
mov gs,ax
lss sp,dword ptr ds:[stackptr]
cmp word ptr ds:[endflag],0ffh
jnz toreadfile


main endp


quit proc near
mov ah,0
int 16h
mov ah,4ch
int 21h
quit endp


init proc near
xor eax,eax
mov ax,data
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
shl eax,4
push eax
mov word ptr ds:[gdt2+2],ax
shr eax,16
mov byte ptr ds:[gdt2+4],al
pop eax
xor ebx,ebx
mov bx,offset prdtable
add eax,ebx
mov ds:[prdbase],eax
mov ah,9
mov dx,offset msginput
int 21h
mov ah,0ah
mov dx,offset wavfile_lenthlimit
int 21h
cld
mov di,ds:[wavfile_factlenth]
add di,offset wavfile_name
mov al,0
stosb
mov ax,3d00h
mov dx,offset wavfile_name
int 21h
jnc openfileOK
jmp far ptr openfile_failure
OPENFILEok:
mov ds:[handle],bx
mov ax,3f00h
mov cx,100h
mov dx,offset wavhead
int 21h
mov esi,dword ptr ds:[wavhead+10h]
sub si,10h
add si,24h
add si,offset wavhead
lodsd
cmp eax,74636166h
jnz nofactblock
add si,12
nofactblock:
lodsd
sub eax,8
mov ds:[datasize],eax
sub si,offset wavhead
mov ds:[datastart],esi
mov ax,3e00h
mov bx,ds:[handle]
int 21h
xor eax,eax
mov ax,pm16seg
shl eax,4
mov word ptr ds:[gdt1+2],ax
shr eax,16
mov byte ptr ds:[gdt1+4],al
ret
init endp


set_intrrupt proc near
mov eax,ds:[bus_dev_func]
add eax,3ch
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
or al,ds:[ac97_int_line]
mov ds:[ac97_int_pin_line],eax
out dx,eax
mov eax,8000f860h
add al,byte ptr ds:[ac97_int_pin_line+1]
dec al
mov dx,0cf8h
out dx,eax
mov al,ds:[ac97_int_line]
mov dx,0cfch
out dx,al
mov eax,8000f8d0h
mov edx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
or eax,100h
out dx,eax
ret
set_intrrupt endp




get_ac97_basereg proc near
mov eax,80000008h
getAC97_basereg:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and eax,0ffffff00h
cmp eax,04000000h
jz find_ac97_basereg
pop eax
add eax,100h
cmp eax,80ffff08h
jbe getAC97_basereg

notfindDEVICE:
mov ah,9
mov dx,offset msg_notfinddevice
int 21h
call quit
find_ac97_basereg:
pop eax
and eax,0ffffff00h
mov ds:[bus_dev_func],eax

add eax,10h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
test ax,1
jz notfindDEVICE
and ax,0fffeh
mov ds:[ac97_mixer_basereg],ax
mov eax,ds:[bus_dev_func]
add eax,14h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and ax,0fffeh
mov ds:[ac97_busmaster_basereg],ax
ret
get_ac97_basereg endp

;;;;;;;;;;;;;;;;;;;;;;fs



readfile proc near
mov ax,3d00h
mov dx,offset wavfile_name
int 21h
jnc openfile_success
jmp openfile_failure
openfile_success:
mov ds:[handle],bx
mov ax,4200h
mov cx,word ptr ds:[datastart+2]
mov dx,word ptr ds:[datastart]
int 21h
mov ax,ds:[bufferbase]
mov ds,ax
mov ax,word ptr fs:[datastart+2]
cmp ax,word ptr fs:[datasize+2]
jz readdetail
mov ax,3f00h
mov bx,fs:[handle]
mov cx,0ffffh
mov dx,0
int 21h
mov ax,3f00h
mov cx,1
mov dx,0ffffh
int 21h
inc word ptr fs:[datastart+2]
jmp readfile_ret
readdetail:
mov ax,3f00h
mov bx,fs:[handle]
mov cx,word ptr fs:[datasize]
int 21h
mov word ptr fs:[endflag],0ffh
readfile_ret:
mov ax,3e00h
mov bx,fs:[handle]
int 21h
ret
openfile_failure:
mov ah,9
mov dx,offset msg_openfailure
int 21h
call quit
readfile endp


ac97_prepare proc near
mov ax,fs:[buffer]
mov es,ax
mov cx,2000
transfer:
mov si,fs:[sipos]
xor eax,eax
lodsb
mov fs:[sipos],si
mov fs:[slot4321+9],al
shl eax,20
mov fs:[slot4321+4],eax
mov di,fs:[dipos]
mov cx,8
mov si,offset slot0
movdata:
mov eax,dword ptr fs:[si]
mov es:[di],eax
add si,4
add di,4
loop movdata
mov fs:[dipos],di
pop cx
loop transfer
ret
ac97_prepare endp







playwav proc near
mov dx,fs:[ac97_busmaster_basereg]
add dx,2ch
mov eax,2
out dx,eax
mov dx,fs:[ac97_busmaster_basereg]
add dx,1bh
mov al,6
out dx,al
mov dx,fs:[ac97_busmaster_basereg]
add dx,10h
mov eax,fs:[prdbase]
out dx,eax
mov dx,fs:[ac97_mixer_basereg]
add dx,2
mov ax,fs:[volume]
out dx,ax
mov dx,fs:[ac97_mixer_basereg]
add dx,18h
out dx,ax
mov ax,480h
mov dx,fs:[ac97_mixer_basereg]
add dx,36h
out dx,ax
mov dx,fs:[ac97_mixer_basereg]
add dx,38h
out dx,ax
mov dx,fs:[ac97_busmaster_basereg]
add dx,15h
mov al,0
out dx,al
mov dx,fs:[ac97_busmaster_basereg]
add dx,1bh
mov al,5
out dx,al
intstatus:
mov dx,fs:[ac97_busmaster_basereg]
add dx,16h
in ax,dx
test al,4
jz intstatus
mov dx,fs:[ac97_busmaster_basereg]
add dx,16h
mov ax,4
out dx,ax
cmp dword ptr fs:[lastprdflag],0ffh
jnz playwavret

playwavret:
ret
playwav endp






pm16seg segment para use16
assume cs:pm16seg
mov ax,10h
mov fs,ax
mov gs,ax
mov ax,18h
mov ds,ax
mov ax,20h
mov es,ax
mov ax,28h
mov ss,ax
mov esp,400h
mov esi,0
mov edi,fs:[edipos]
cmp word ptr fs:[endflag],0ffh
jz endfilepart
mov ecx,4000h
copybuffer:
mov eax,ds:[esi]
mov es:[edi],eax
add esi,4
add edi,4
loop copybuffer

back_RMmode:
mov fs:[edipos],edi
mov eax,cr0
and al,0feh
mov cr0,eax
mov ax,30h
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
jmp far ptr rmmode
endfilepart:
mov ecx,fs:[datastart]
mov al,ds:[esi]
mov es:[edi],al
inc esi
inc edi
loop copybuffer_detail
jmp back_rmmode
pm16seg ends

