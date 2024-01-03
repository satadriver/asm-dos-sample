.386p
pmstack segment para use16
db 1000h dup (0)
pmstack ends

stack segment stack
db 400h dup (0)
stack ends

data segment page use16
prdtable dq 128h dup (0)
gdt0 dq 0
gdt1 dq 000098000000ffffh
gdt2 dq 004098000000ffffh
gdt3 dq 004092000000ffffh  ;data selector
gdt4 dq 004f92040000ffffh
gdt5 dq 004092050000ffffh
gdt6 dq 004092060000ffffh
gdt7 dq 004092070000ffffh
gdt8 dq 004092000000ffffh  ;pmstack
gdt9 dq 004092000000ffffh
gdt10 dq 004f92800000ffffh ;wavdata in pm mode
gdtlen=$-gdt0
gdtlimit dw gdtlen-1
gdtbase dd 0
lowpage dw 0
highpage dw 0
filehandle dw 0
wavbaseseg dw 4000h
slot0 dw 9800h
slot4321 dt 0
slot8765 dt 0
slotcba9 dt 0
stackpointer dd 0
wavblocknum dd 0
esipos dd 0
edipos dd 0
prdaddr dd 0
leftchannel dw 0
rightchannel dw 0
wavheader db 100h dup (0)
headersize dw 3ah
wavname db 'f:\asm\wavefile\shut.wav',0
volume dw 480
data ends

code1 segment para use16
assume cs:code1
db 0eah
dw 0
dw 10h
returndos:
mov ax,48h
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,cr0
and al,0
mov cr0,eax
jmp far ptr dosmode
code1 ends

code2 segment para use32
assume cs:code2 
mov ax,18h
mov es,ax
mov ax,50h
mov gs,ax
mov fs,ax
mov ax,40h
mov ss,ax
mov esp,800h
mov ax,20h
mov ds,ax
mov ecx,10

nextblock:
push ecx
call near ptr ac97
waitindex:
mov dx,0fa16h
in ax,dx
test al,4
jz waitindex
pop ecx
loop nextblock
db 0eah
dw offset returndos
dw 0
dw 8

ac97:
mov ecx,6000
mov eax,0
mov dword ptr es:[edipos],eax
copytoslot:
push ecx
mov esi,es:[esipos]
mov ax,ds:[esi]
mov word ptr es:[leftchannel],ax
add esi,2
mov ax,ds:[esi]
mov word ptr es:[rightchannel],ax
add esi,2
mov es:[esipos],esi
mov edi,offset slot4321
add edi,4
xor eax,eax
mov ax,word ptr es:[leftchannel]
shl eax,12
mov dword ptr es:[edi],eax
mov edi,offset slot4321
add edi,8
mov ax,word ptr es:[rightchannel]
mov word ptr es:[edi],ax
mov esi,offset slot0
mov edi,es:[edipos]
mov ecx,8
copy:
mov eax,es:[esi]
mov gs:[edi],eax
add esi,4
add edi,4
loop copy
mov ax,0
mov word ptr es:[slot0],ax
mov esi,offset slot0
mov ecx,8
lll:
mov eax,es:[esi]
mov gs:[edi],eax
add esi,4
add edi,4
loop lll
mov ax,9800h
mov word ptr es:[slot0],ax
mov es:[edipos],edi
pop ecx
dec ecx
cmp ecx,0
jz toplay
jmp  copytoslot
toplay:
in al,60h
cmp al,39h
jnz toplay
call codecplay
retn


codecplay:
;mov dx,0fa2ch
;mov eax,2
;out dx,eax
mov dx,0fa1bh
mov al,2
out dx,al
mov dx,0fa15h
mov al,5
out dx,al
mov dx,0fa10h
mov eax,es:[prdaddr]
out dx,eax
mov dx,0f002h
mov ax,es:[volume]
out dx,ax
;mov dx,0f006h
;out dx,ax
;mov dx,0f008h
;out dx,ax
mov dx,0f018h
out dx,ax
;mov dx,0f02ch
;out dx,ax
;mov dx,0f02eh
;out dx,ax
;mov dx,0f030h
;out dx,ax
;mov dx,0f032h
;out dx,ax
;mov dx,0f036h
;out dx,ax
;mov dx,0f038h
;out dx,ax
;mov dx,0fa16h
;mov ax,0
;out dx,ax
mov dx,0fa1bh
mov al,1
out dx,al
retn
code2 ends




code0 segment para use16
assume cs:code0
start:
main proc near
call initpmmode
call getwavinfo
call readfile
mov ax,ss
shl eax,16
mov ax,sp
mov di,offset stackpointer
stosd
cli
mov al,2
out 92h,al
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
lss sp,dword ptr es:[stackpointer]
mov ah,4ch
int 21h
main endp





initpmmode proc near
mov ax,stack
mov ss,ax
xor eax,eax
mov ax,data
mov ds,ax
mov es,ax
shl eax,4
push eax
push eax
mov word ptr es:[gdt3+2],ax
shr eax,16
mov byte ptr es:[gdt3+4],al
pop eax
xor ebx,ebx
mov bx,offset gdt0
add eax,ebx
mov es:[gdtbase],eax
pop eax
xor ebx,ebx
mov bx,offset prdtable
add eax,ebx
mov es:[prdaddr],eax

xor eax,eax
mov ax,pmstack
shl eax,4
mov word ptr es:[gdt8+2],ax
shr eax,16
mov byte ptr es:[gdt8+4],al
xor eax,eax
mov ax,code1
shl eax,4
mov word ptr es:[gdt1+2],ax
shr eax,16
mov byte ptr es:[gdt1+4],al
mov byte ptr es:[gdt1+7],ah
xor eax,eax
mov ax,code2
shl eax,4
mov word ptr es:[gdt2+2],ax
shr eax,16
mov byte ptr es:[gdt2+4],al
mov byte ptr es:[gdt2+7],ah
cld
mov di,offset prdtable
mov ecx,6
mov eax,800000h
fillprd:
push eax
stosd
cmp ecx,0
jz fillnextprd
mov eax,0ffffh
jmp next
fillnextprd:
mov eax,8000ffffh
next:
stosd
pop eax
add eax,10000h
loop fillprd
retn
initpmmode endp





getwavinfo proc near
mov ax,3d00h
mov dx,offset wavname
int 21h
jc callquit
mov es:[filehandle],ax
mov bx,ax
mov ax,4202h
mov cx,0
mov dx,0
int 21h
mov es:[highpage],dx
mov es:[lowpage],ax
mov ax,4200h
mov cx,0
mov dx,0
int 21h
mov ax,3f00h
mov cx,es:[headersize]             ;wav file header size
mov dx,offset wavheader
int 21h
mov cx,es:[lowpage]
sbb cx,ax             ;wav file header size
mov es:[lowpage],cx
mov cx,es:[highpage]
sbb cx,0
mov es:[highpage],cx
ret
callquit:
call quit
getwavinfo endp


quit proc near
mov ah,4ch
int 21h
quit endp


readfile proc near
mov ax,es:[wavbaseseg]
mov ds,ax
xor eax,eax
mov dword ptr es:[wavblocknum],eax
readblock:
mov ax,es:[highpage]
cmp ax,0
jz readdetail
mov ax,3f00h
mov bx,es:[filehandle]
mov cx,0ffffh
mov dx,0
int 21h
mov ax,3f00h
mov cx,1
mov dx,0ffffh
int 21h
mov ax,es:[highpage]
dec ax
mov es:[highpage],ax
mov eax,es:[wavblocknum]
inc eax
mov es:[wavblocknum],eax
cmp eax,4
jz toreturn
mov ax,ds
add ax,1000h
mov ds,ax
jmp readblock

readdetail:
mov ax,3f00h
mov bx,es:[filehandle]
mov cx,es:[lowpage]
mov dx,0
int 21h
mov word ptr es:[lowpage],0
toreturn:
mov ax,3e00h
mov bx,es:[filehandle]
int 21h
retn
readfile endp
code0 ends
end start
