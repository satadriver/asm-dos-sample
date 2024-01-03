.model small
.code
start:
mov ax,8000h
add ax,8000h
into
mov ah,0
int 16h
mov bx,0
div bx
mov ah,4ch
int 21h
end start