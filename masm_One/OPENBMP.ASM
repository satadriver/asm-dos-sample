.model small
.data
bmpname db 'f:\asm\bmp\2.bmp',00
.code
start:
mov ax,@data
mov ds,ax
mov ax,3d02h
mov dx,offset bmpname
int 21h
jnc nextproc
jmp quit

nextproc:
mov bx,ax
push bx

mov ax,4f02h
mov bx,101h
int 10h
mov ax,4f06h
mov bx,0
mov cx,480
int 10h

pop bx
mov ax,4202h
mov cx,0
mov dx,0
int 21h
mov si,dx
mov di,ax


mov ax,4200h
mov cx,0
mov dx,0
int 21h

l1:
dec si
cmp si,0ffffh
jz quit
push si
push di
push bx
mov ax,4f05h
mov bx,0
mov dx,si
int 10h
pop bx

mov ax,2000h
mov ds,ax

mov dx,1
mov ax,0
mov cx,1920
div cx
mov cx,ax
mov bp,dx

mov dx,0ffffh
l0:
push cx
sub dx,1920
mov ax,3f00h
mov cx,1920
int 21h
pop cx
loop l0

mov cx,bp
mov ax,3f00h
mov dx,65280
int 21h

mov ax,0a000h
mov es,ax
mov si,0
mov di,0
mov cx,0ffffh
rep movsb

pop di
pop si
cmp si,0
jmp l1

quit:
mov ah,0
int 16h
mov ax,3
int 10h
mov ah,4ch
int 21h
end start











