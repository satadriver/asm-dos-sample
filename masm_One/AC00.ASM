.386p
stack segment stack
db 400h dup (0)
stack ends

data segment page use16
org 0
gdtlimit dw 47h
gdtbase dd 0
align 16
gdt0 dq 0
gdt1 dq 000098000000ffffh
gdt2 dq 004098000000ffffh
gdt3 dq 00cf92050000ffffh
gdt4 dq 10cf92000000ffffh
gdt5 dq 20cf92000000ffffh
gdt6 dq 004092200000ffffh
gdt7 dq 004092000000ffffh
gdt8 dq 000092000000ffffh

prd dq 32 dup (0)
prdaddr dd 0
;gdtlimit dw 47h
;gdtbase dd 0
wavname db 'f:\asm\wavefile\shut.wav',0
handle dw 0
wavhead db 2ch dup (0)
lowpage dw 0
highpage dw 0
pagenum dw 0
fileptrlow dw 2ch
fileptrhigh dw 0
volume dw 480h
dataseg dw 5000h
edipos dd 0
esipos dd 0
slot01 dw 0fff8h
slot4321 dt 0800004c000h      
slot8765 dt 1f4001f4001f4001f400h
slotcba9 dt 1f400h
leftchannel dw 0
rightchannel dw 0
stackptr dd 0
msg0 db 'play now !!$'
data ends

code0 segment para use16
assume cs:code0

start:
initdesc proc near
cld
xor eax,eax
mov ax,data
mov ds,ax
mov es,ax
shl eax,4
push eax
push eax
mov word ptr es:[gdt7+2],ax
shr eax,16
mov byte ptr es:[gdt7+4],al
pop eax
xor ebx,ebx
mov bx,offset gdt0
add eax,ebx
mov es:[gdtbase],eax

pop eax
xor ebx,ebx
mov bx,offset prd
add eax,ebx
mov ds:[prdaddr],eax

mov ecx,32
mov di,offset prd
mov eax,20000000h
setprd:
stosd
add eax,0fa00h
push eax
cmp ecx,0
jz endprd
mov eax,0fa00h
jmp store
endprd:
mov eax,8000fa00h
store:
stosd
pop eax
loop setprd


xor eax,eax
mov ax,code1
shl eax,4
mov word ptr es:[gdt1+2],ax
shr eax,16
mov byte ptr es:[gdt1+4],al
xor eax,eax
mov ax,code2
shl eax,4
mov word ptr es:[gdt2+2],ax
shr eax,16
mov byte ptr es:[gdt2+4],al
mov byte ptr es:[gdt2+7],ah
initdesc endp




getdata proc near
mov ax,3d00h
mov dx,offset wavname
int 21h
mov bx,ax
mov ax,3f00h
mov cx,2ch
mov dx,offset wavhead
int 21h
mov eax,dword ptr ds:[wavhead+4]
sub eax,2ch
mov dword ptr ds:[lowpage],eax
mov ax,3e00h
int 21h

cli
mov al,2
out 92h,al

readfile:
mov ah,9
mov dx,offset msg0
int 21h
mov ah,0
int 16h
mov ax,3d00h
mov dx,offset wavname
int 21h
mov bx,ax
mov es:[handle],ax
mov ax,4200h
mov bx,es:[handle]
mov cx,es:[fileptrhigh]
mov dx,es:[fileptrlow]
int 21h
mov ax,es:[dataseg]
mov ds,ax
read:
cmp word ptr es:[highpage],0
jnz nextpage
cmp word ptr es:[lowpage],0
jnz detail
nextpage:
mov ax,3f00h
mov cx,0ffffh
mov dx,0
int 21h
mov ax,3f00h
mov cx,1
mov dx,0ffffh
int 21h
dec word ptr es:[highpage]
inc word ptr es:[fileptrhigh]
inc word ptr es:[pagenum]
mov ax,ds
cmp ax,8000h
jz getinPMmode
add ax,1000h
mov ds,ax
jmp read
detail:
mov ax,3f00h
mov bx,es:[handle]
mov cx,es:[lowpage]
mov dx,0
int 21h
mov word ptr es:[lowpage],0
mov word ptr es:[fileptrlow],ax
mov ax,3e00h
mov bx,es:[handle]
int 21h

getinPMmode:
mov ax,ss
shl eax,16
mov ax,sp
mov es:[stackptr],eax
lgdt qword ptr es:[gdtlimit]
mov eax,cr0
or al,1
mov cr0,eax
db 0eah
dw 0
dw 8

dosmode:
mov ax,data
mov es,ax
mov ds,ax
lss sp,dword ptr es:[stackptr]
cmp word ptr ds:[pagenum],0ffffh
jz quit
jmp near ptr readfile

quit:
mov ax,4ch
int 21h
getdata endp
code0 ends




code1 segment para use16
assume cs:code1
mov ax,18h
mov ds,ax
mov ax,20h
mov es,ax
mov ax,38h
mov fs,ax
mov ax,30h
mov ss,ax
mov ax,40h
mov gs,ax
mov edi,0b8000h
mov eax,41424344h
mov dword ptr gs:[edi],eax
l0:
in al,60h
cmp al,1
jnz l0
mov esp,2000h

cld
cmp word ptr fs:[highpage],0
jnz trans4page
mov cx,fs:[pagenum]
movzx ecx,cx
mov eax,ecx
mov ebx,10000h
mul ebx
mov ecx,eax
mov ax,fs:[fileptrlow]
movzx eax,ax
add ecx,eax
mov esi,0
mov edi,fs:[edipos]
rep movsb
jmp to32bit
trans4page:
mov ecx,40000h
mov esi,0
mov edi,fs:[edipos]
rep movsb
mov fs:[edipos],edi

todosmode:
mov word ptr fs:[pagenum],0
mov ax,40h
mov ds,ax
mov es,ax
mov ss,ax
mov fs,ax
mov gs,ax
mov eax,cr0
and al,0feh
mov cr0,eax
jmp far ptr dosmode

to32bit:
db 0eah
dw 0
dw 10h
code1 ends




code2 segment para use32
assume cs:code2
mov ax,20h
mov ds,ax
mov ax,28h
mov es,ax
mov ax,38h
mov fs,ax
mov ax,30h
mov ss,ax
mov esp,2000h
mov esi,0
mov edi,0

loop0:
cmp esi,dword ptr fs:[fileptrlow]
jae toquit
mov dword ptr fs:[edipos],0
mov ecx,64000

transfer:
push ecx
mov esi,fs:[esipos]
lodsw
mov word ptr fs:[slot4321+8],ax
lodsw
mov fs:[esipos],esi
xor ebx,ebx
push ax
mov eax,dword ptr fs:[slot4321+4]
pop bx
movzx ebx,bx
shl ebx,12
or eax,ebx
mov dword ptr fs:[slot4321+4],eax
mov edi,fs:[edipos]
mov cx,8
mov esi,offset slot01
rep movsd
mov fs:[esipos],edi
pop ecx
loop transfer


mov dx,0fa2ch
mov eax,2
out dx,eax
mov dx,0fa1bh
mov al,2
out dx,al
mov dx,0f016h
mov ax,31
out dx,ax
mov dx,0fa10h
mov eax,fs:[prdaddr]
out dx,eax
mov dx,0f000h
mov al,0
out dx,al
mov dx,0f002h
mov ax,es:[volume]
out dx,ax
mov dx,0f018h
out dx,ax
mov dx,0fa1bh
mov al,1
out dx,al
waitfree:
mov dx,0fa1bh
in al,dx
cmp al,31h
jnz waitfree
mov dx,0fa16h
mov ax,4
out dx,ax
jmp loop0

toquit:
mov word ptr fs:[pagenum],0ffffh
db 0eah
dw offset todosmode
dw 0
dw 8
code2 ends
end start
