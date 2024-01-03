.model small
.code
start:

mov ax,13h
int 10h


mov ax,0a000h
mov es,ax


mov cx,0ffffh
mov al,0ffh
l0:
rep stosb

mov ah,0
int 16h

mov dx,3c4h;;;;;;关闭显示器的端口操作
mov al,01h
out dx,al
mov dx,3c5h
mov al,20h
out dx,al




mov ah,0
int 16h

mov dx,3c2h
mov al,67h
out dx,al



mov ah,0
int 16h
mov ax,3
int 10h
mov ah,4ch
int 21h
end start



mov dx,3ceh
mov al,6
out dx,al
inc dx
mov al,5
out dx,al


mov dx,3dah
mov al,09
out dx,al
mov dx,3c0h
mov al,0
out dx,al
mov dx,3c0h
mov al,10h
out dx,al
mov dx,3c0h
mov al,0ffh
out  dx,al



mov dx,3c4h;;;;;;打开显示器的端口操作
mov ax,300h
out dx,ax
mov dx,3c4h
mov ax,001h
out dx,ax