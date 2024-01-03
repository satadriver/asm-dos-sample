.386p

code segment para use16
assume cs:code
start:
cld
mov ax,strap
mov ds,ax
mov ax,0
mov es,ax

mov word ptr es:[4],0
mov word ptr es:[6],8000h

mov ax,8000h
mov es,ax
mov si,0
mov di,0
mov cx,ds:[straplen]
rep movsb

pushfd
bts [esp],8
popfd
;mov ah,0
;int 16h
pushfd
btr [esp],8
popfd
MOV AH,0
INT 16H

xor eax,eax
mov ebx,eax
mov ax,cs
shl eax,4
mov bx,offset ptr0
add eax,ebx
mov dr3,eax

mov eax,0000ffh
mov dr7,eax


ptr0:
mov ax,100h
mov bx,ax

mov ah,4ch
int 21h
code ends

strap segment para use16
assume cs:strap

pop word ptr cs:[ip]
pop word ptr cs:[codeseg]
pop word ptr cs:[flag]
bts dword ptr cs:[flag],16 ;base on the flag d16 RF IN STACK,not flag RF
push dword ptr cs:[flag]
push dword ptr cs:[codeseg]
push dword ptr cs:[ip]
pushad
push ds
push es
mov ax,13h
int 10h
mov ax,0a000h
mov es,ax
mov di,0
mov cx,0fffh
mov al,2
rep stosb
mov ah,0
int 16h
mov ax,3
int 10h
pop es
pop ds
popad

pushfd
bts [esp],16
popfd
iretd

flag dw 0
dw 0
codeseg dw 0
dw 0
ip dw 0
dw 0
straplen dw $
strap ends

end start