.model small
.stack 100h
.code
start:
mov ax,13h
int 10h
mov bx,519

mov ax,0f000h
mov ds,ax
mov ax,0a000h
mov es,ax
mov di,0
mov si,0fa6eh

l11:mov dh,8
mov dl,80h
mov cx,7


l0:mov al,ds:[si+bx]
and al,dl
shr al,cl
mov byte ptr es:[di],al
shr dl,1
add di,1
dec cl
dec dh
cmp dh,0
jnz l0


add di,312
inc bx
cmp bx,700
jnz l11




mov ah,0
int 16h
mov ax,3
int 10h
mov ah,4ch
int 21h

end start

