.model small
.code
start:
mov al,0eh
mov ah,0a0h
mov dx,3d4h
out dx,ax
mov al,0fh
mov ah,0
out dx,ax
mov ah,0
int 16
mov ah,4ch
int 21h
end start