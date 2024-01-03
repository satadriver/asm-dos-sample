.model small
.data
nt db 'd:\ntoskrnl.exe',0
nt1 db 'c:\windows\system32\ntoskrnl.exe',0
.code
start:
mov ax,@data
mov ds,ax

mov ah,3ch  ;create c:\windows\system32\ntoskrnl.exe
mov cx,0
mov dx,offset nt1
int 21h
mov di,ax   ;pointer 

mov ah,3dh
mov al,2
mov dx,offset nt
int 21h
mov bx,ax
mov si,ax

mov ax,4202h
mov cx,0
mov dx,0
int 21h
mov cx,dx
mov dx,ax

push dx
push cx

mov ax,4200h
mov cx,0
mov dx,0
int 21h

mov ax,2000h
mov ds,ax

pop cx         ;high
pop dx         ;low

l0:
push dx
push cx

mov bx,si
mov ah,3fh
mov cx,0ffffh
mov dx,0
int 21h

mov ah,40h
mov cx,0ffffh
mov dx,0
mov bx,di
int 21h
pop cx
pop dx
dec cx
loop l0

mov bx,si
mov ah,3fh
mov cx,dx
mov dx,0
int 21h

mov bx,di
mov ah,40h
mov dx,0
int 21h

mov ax,@data
mov ds,ax
mov ah,3eh
mov dx,offset nt
int 21h
mov ah,3eh
mov dx,offset nt1
int 21h
mov ah,4ch
int 21h
end start