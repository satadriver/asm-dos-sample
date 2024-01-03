
.model small
.code

start:mov ah,0
mov al,13h
int 10h

mov dx,3ceh
mov al,5
out dx,al
mov dx,3cfh
mov al,0
out dx,al

mov dx,3ceh
mov al,8
out dx,al
mov dx,3cfh
mov al,00ffh
out dx,al


mov bh,10h
mov bl,0

loop0:
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
mov al,bl      ;为反色显示，3即为红
out dx,al



mov si,0
mov cx,0ffffh
mov ax,0a000h
mov ds,ax
mov al,0ffh     ;AL决定8位中发光的像素是那几个
l1:mov  ds:[si],al
inc si
loop l1


mov di,0ffffh
delay1:mov si,0ffffh
delay2:dec si
jnz delay2
dec di
jnz delay1



dec bh
inc bl
jnz loop0
mov ah,0
int 16h
mov ax,3
int 10h
mov ah,4ch
int 21h
end start