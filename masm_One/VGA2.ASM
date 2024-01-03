.model small
.code
start:mov ah,0
mov al,12h
int 10h

mov dx,3ceh
mov al,5
out dx,al
mov dx,3cfh
mov al,2
out dx,al

mov dx,3ceh;该段与颜色无关，由CPU决定
mov al,1
out dx,al
mov al,0fh
mov dx,3cfh
out dx,al
mov dx,3feh
mov al,0
out dx,al
mov dx,3cfh
mov al,3
out dx,al

mov dx,3ceh
mov al,8
out dx,al
mov dx,3cfh
mov al,11111111b
out dx,al


mov ax,0a000h
mov ds,ax
mov bx,00h
mov al,5
l11:
mov ds:[bx],al
inc bx
cmp bx,9500h
jnz l11

mov bx,6400
mov cx,50
mov si,20
l1:
mov al,2
mov  ds:[bx+si],al
inc si
cmp si,60
jnz l1
add bx,80
mov si,20
loop l1

mov cx,16050
mov al,6
mov bx,16000
mov si,20
mov di,100
l9:
mov ds:[bx+si],al
inc bx
cmp bx,16049
jnz l9


mov dl,1
mov ah,0ffh
l99:mov dx,3ceh
mov al,4
out dx,al
mov al,0
mov dx,3cfh
out dx,al
mov dx,3ceh
mov al,5
out dx,al
mov dx,3cfh
mov al,5
out dx,al
mov dx,3ceh
mov al,1
out dx,al
mov al,0fh
mov dx,3cfh
out dx,al
mov dx,3feh
mov al,0
out dx,al
mov dx,3cfh
mov al,3
out dx,al
mov dx,3ceh
mov al,8
out dx,al
mov dx,3cfh
mov al,ah
out dx,al
mov al,5
mov ds:[bx+si],al ;-------------
sub ah,dl
shl dl,1
cmp dl,80h
jnz  l99

mov al,6
mov bx,16000
add si,80
dec di
dec cx

cmp cx,16000
jnz l9
mov ah,0
int 16h
mov ax,3
int 10h
mov ah,4ch
int 21h
end start






