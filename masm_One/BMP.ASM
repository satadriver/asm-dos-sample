.model small
.386
.data
bmpname db 'f:\asm\bmp\3.bmp',00
.code
start:
mov ax,4f02h
mov bx,105h
int 10h
mov ax,4f06h
mov bx,0
mov cx,640
int 10h


mov ax,@data
mov ds,ax
mov ax,3d02h
mov dx,offset bmpname
int 21h
mov bx,ax


mov ax,2000h
mov ds,ax
mov ax,0a000h
mov es,ax
mov bp,1



mov ax,4200h
mov cx,0
mov dx,36h
int 21h
mov ax,3f00h
mov cx,400h
mov di,0
int 21h

cld
mov cx,100h
mov si,0
mov ax,0
ll0:push ax
mov dx,3c8h
out dx,al
mov dx,3c9h
add si,2
lodsb
shr al,2
out dx,al

sub si,2
lodsb
shr al,2
out dx,al

sub si,2
lodsb
shr al,2
out dx,al
add si,3
pop ax
inc ax
loop ll0

mov ax,4202h
mov cx,0
mov dx,0
int 21h
mov si,dx
mov di,ax

l1:
dec si
cmp si,0ffffh
jz quit
push si
push di
push bx

mov ax,4200h
mov cx,si
mov dx,di
int 21h

mov ax,3f00h
mov cx,0ffffh
mov dx,0
int 21h

mov si,0ffffh
mov di,0
mov cx,0ffffh
l0:
mov al,ds:[si]
mov es:[di],al
inc di
dec si
loop l0

mov ax,4f05h
mov bx,0
mov dx,bp
int 10h
inc bp
pop bx
pop di
pop si
jmp l1


quit:
mov ah,0
int 16h

;MOV AX,40H
;MOV DS,AX
;MOV SI,6CH

;cld
;LOOP1:
;LODSW
;ADD AX,5
;MOV BX,AX
;CMPTIME:
;SUB SI,2
;LODSW
;CMP AX,BX
;JBE CMPTIME

;MOV AX,4F07H
;MOV BX,0
;ADD CX,20
;MOV DX,0
;INT 10H

;IN AL,60H
;CMP AL,1
;JNZ LOOP1

TODOS:
mov ax,3
int 10h
mov ah,4ch
int 21h
end start
