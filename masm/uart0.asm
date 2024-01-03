title uart0
NAME UART0
extrn showchar:far, quit:far
.model small
.386
.code
start:
cli
mov al,80h
mov dx,3fbh
out dx,al
mov dx,3f8h
mov al,0ch
out dx,al
inc dx
mov al,0
out dx,al
mov al,3
mov dx,3fbh
out dx,al
mov al,0
mov dx,3f9h
out dx,al
mov al,10h
mov dx,3fch
out dx,al
mov ax,0b800h
mov fs,ax
mov di,0

l1:
mov ah,0
int 16h


cmp al,1bh
jnz next
call far ptr quit
next:
mov dx,3f8h
out dx,al
call far ptr showchar
in al,dx
mov ah,7
mov fs:[di],ax
add di,2
jmp l1

end start
