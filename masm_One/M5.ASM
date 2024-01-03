.model small
.data
.stack 1000h
.code
start:
cld
mov ax,0a000h
mov Es,ax
mov ax,13h
int 10h
mov Di,0
mov al,1
mov cx,0ffffh
REP STOSB

mov ax,@CODE
mov es,ax
mov dx,offset process
mov ax,0ch
mov cx,1
int 33h

main:
in al,64h
test al,1
jz main
in al,60h
cmp al,1h
JNZ MAIN

quit:
mov ax,3
int 10h
mov ah,4ch
int 21h

process proc far
push ax
push dx
push cx
push bx
push si
push di
push ds
push es
mov ax,dx
mov bx,320
mul bx
add ax,cx
MOV SI,AX
ADD AX,321
MOV DI,AX
PUSH DI
MOV BL,4
MOV DS:[DI],BL
INC DI
MOV DS:[DI],BL
ADD DI,319
MOV DS:[DI],BL
INC DI
MOV DS:[DI],BL

mov ax,3
int 33h
cmp bx,1
jnz l2
mov CL,2
mov ds:[si],Cl

l2:POP DI

MOV BL,1
MOV DS:[DI],BL
INC DI
MOV DS:[DI],BL
ADD DI,319
MOV DS:[DI],BL
INC DI
MOV DS:[DI],BL
pop es
pop ds
pop di
pop si
pop bx
pop dx
pop cx
pop ax
ret
process endp

end start 

