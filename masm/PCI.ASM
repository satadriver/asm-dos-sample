.model small
.386
.stack
.data
str0 db "E:\ASM\MASM\PCI.TXT",00
.code
start:
mov aX,@DATA
MOV DS,AX

mov ax,0b800h
mov es,ax
mov di,0

mov eax,80001000h
read:
MOV ESI,EAX
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx

cmp ax,0ffffh
jz nextequip

call far ptr shift
mov ecx,3
l0:shr eax,8
call far ptr  shift
nop
Loop l0

MOV EAX,ESI
add eax,4h
cmp al,0h
jnz read

              JMP QUIT

and eax,0ffffff00h
MOV ESI,EAX

nextequip:
MOV EAX,ESI
add eax,100h
cmp eax,8000ff00h
jbe read

mov ah,3Dh
mov cx,0
MOV AL,2
mov dx,OFFSET str0
int 21h
mov bx,ax

mov ax,es
mov ds,ax

MOV DX,0
L1:mov ah,40h
mov cx,1
int 21h
ADD DX,2
CMP DX,DI
JNZ  L1

mov ah,3eh
int 21h
quit:
mov al,0
out 21h,al
sti

mov  ah,0
int 16h
mov ax,3
int 10h
mov ah,4ch
int 21h

shift proc far
cli
mov edx,eax
and al,0fh
cmp al,9
jbe digital0
add al,7
digital0:
add al,30h
stosb
mov al,42h
stosb

mov al,dl
shr al,4
cmp al,9
jbe digital1
add al,7
digital1:
add al,30h
stosb
mov al,42h
stosb
mov al,20h
stosb
mov al,42h
stosb
retf
nop
nop
shift endp
end start

