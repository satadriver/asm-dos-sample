;水平扫描线的长度为垂直方向上的分辨率，如24色下1024X768为768
;640X480为480，但是800X600下为800
;8位下640x480为640，800X600为800，1024X768为1024
;而32位下1024X768为1024    800X600为800    640x480为800    


.model small
.386
.data 
bmpname db "f:\asm\masm\122.bmp",00

info db 36h dup (0)
colortable db 400h dup (0)
.code 
start:
mov dx,3c4h
mov al,0eh
out dx,al
mov dx,3c5h
in al,dx
xor al,2
out dx,al
mov dx,3c4h
mov al,6
out dx,al
in al,dx
mov dx,3ceh
mov ax,506h
out dx,ax
mov ax,@data
mov ds,ax
mov ah,3dh
mov al,2
mov dx,offset bmpname
int 21h
mov bx,ax

MOV AX,4200H
MOV CX,0
MOV DX,0
INT 21H

mov ax,3f00h
mov cx,36h
mov dx,offset info
int 21h


MOV AX,3F00H
MOV CX,400H
MOV DX,OFFSET COLORTABLE
INT 21H


PUSH BX
MOV AX,4F02H
MOV BX,105H
INT 10H
MOV AX,4F06H
MOV BX,0
MOV CX,1024
INT 10H
mov ax,4f07h
mov bx,0
mov cx,0
mov dx,0
int 10h




std
mov si,offset colortable
mov bx,0
mov cx,100h
ll:
push bx
add si,2

mov dx,3c8h
mov ax,bx
out dx,al
lodsb
shr al,1
shr al,1
mov dx,3c9h
out dx,al


lodsb
shr al,1
shr al,1
mov dx,3c9h
out dx,al

lodsb
shr al,1
shr al,1
mov dx,3c9h
out dx,al

add si,5
pop bx
inc bx
loop ll

mov ax,0a000h
mov ds,ax
mov ax,0a000h ;;;
mov es,ax;;;;
mov bp,1

POP BX
l0:
push bx
mov ah,3fh
mov cx,0ffffh
mov dx,0
int 21h
mov ah,3fh
mov cx,1
mov dx,0ffffh
int 21h


cli
mov ax,4f05h       ;换页,no need to pushf
mov bx,0
mov dx,bp
db 09ah  
dw 8c89h
dw 0c000h



pop bx
inc bp
cmp bp,20
jz quit




jmp l0


quit:

MOV AH,0
INT 16H
mov ax,3
int 10h
mov ah,4ch
int 21h
end start
mov ah,0
int 16h

MOV AX,3000H
MOV ES,AX
MOV BX,0
MOV AX,4F04H
MOV DL,1
MOV CX,0FH
INT 10H
mov ax,3h
int 10h

mov ah,0
int 16h
mov ax,4202h
mov bx,101h
int 10h
MOV AX,4F04H
MOV DL,2
MOV CX,0FH
MOV BX,0
INT 10H