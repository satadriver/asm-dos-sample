.386
data segment para use16
prd dq 0
prdbase dd 0
filename db 'c:\b.wav',0
handle dw 0

wavflag     dd 0
filesize    dd 0
filetype    dd 0
format      dd 0
appendsize  dd 0
codetype    dw 0
channels    dw 0
samplerate  dd 0
bytespersec dd 0
bytespersam dw 0
bitsperchannel  dw 0

slot0 dw 9800h
slot4321 dt 0
slot8765 dt 0
slotcba9 dt 0
sipos dw 0
dipos dw 0
volume dw 480h
dataseg dw 5000h
buffer db 2000 dup (0)
data ends


code segment para use16
assume cs:code
start:
xor eax,eax
mov ax,data
mov ds,ax
shl eax,4
xor ebx,ebx
mov bx,offset prd
add eax,ebx
mov ds:[prdbase],eax

xor eax,eax
mov ax,ds:[dataseg]
shl eax,4
mov dword ptr ds:[prd],eax
mov eax,8000bb80h
mov dword ptr ds:[prd+4],eax

mov ax,3d00h
mov dx,offset filename
int 21h
mov ds:[handle],ax
mov bx,ax
mov ax,3f00h
mov cx,2ch
mov dx,offset wavflag
int 21h

readfile:
mov ax,3f00h
mov bx,ds:[handle]
mov cx,1500
mov dx,offset buffer
int 21h
cmp ax,0
jnz notends
mov ah,4ch
int 21h
notends: 
mov ax,ds:[dataseg]
mov es,ax
cld
mov cx,1500
mov si,offset buffer
copydata:
push cx
lodsb
mov ds:[sipos],si
mov byte ptr ds:[slot4321+9],al
movzx eax,al
shl eax,20
mov dword ptr ds:[slot4321+4],eax
mov di,ds:[dipos]
mov si,offset slot0
mov cx,32
rep movsb
pop cx
loop copydata

mov dx,0fa2ch
mov eax,2
out dx,eax
mov dx,0fa1bh
mov al,2
out dx,al
mov dx,0f016h
mov ax,4
out dx,ax
mov dx,0fa10h
mov eax,ds:[prdbase]
out dx,eax
mov dx,0f002h
mov ax,ds:[volume]
out dx,ax
mov dx,0f018h
out dx,ax

mov dx,0fa1bh
mov al,1
out dx,al
waitfree:
mov dx,0fa16h
in ax,dx
test al,4
jz waitfree
mov ax,0
mov dx,0fa16h
out dx,ax
jmp readfile

init proc near
code ends
end start