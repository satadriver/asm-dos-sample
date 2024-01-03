.model small
.386
.data
message   db 'input file name to show',0ah,0dh,24h
bmp256     db 'f:\asm\bmp\'
bmpnum    dw 0
db              '.bmp',00
ERROR DB 'NOT FOUND FILE,QUIT$'
colortable db 400h dup (0)
.code
start:
mov ax,@data
mov ds,ax
mov es,ax
mov ah,9
mov dx,offset message
int 21h

mov di,offset bmpnum
input:
mov ah,0
int 16h
cmp al,0dh
jz next
stosb
mov ah,2
mov dl,al
int 21h
jmp input



SHOW_320X200BMP PROC NEAR
next:
mov ax,@data
mov ds,ax
mov es,ax
mov ax,3d00h
mov dx,offset bmp256
int 21h
jc quit

mov bx,ax
mov ax,4200h
mov cx,0
mov dx,36h
int 21h

mov ax,3f00h
mov cx,400h
mov dx,offset colortable
int 21h
push bx

mov ax,4f02h
mov bx,13h
int 10h

cld
mov cx,100h
mov si,offset colortable
mov ax,0
l0:
push ax
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
loop l0

mov ax,0a000h
mov es,ax
mov ax,2000h
mov ds,ax

std
pop bx
mov ax,3f00h
mov cx,64000
mov dx,0
int 21h
mov si,319
mov di,64000
mov cx,200
l1:
push cx
push si
push di
mov cx,320
std
rep movsb
pop di
pop si
pop cx
add si,320
sub di,320
loop l1
SHOW_320X200BMP ENDP

QUIT PROC NEAR
mov ah,0
int 16h


mov ax,3
int 10h
mov ax,4c00h
int 21h
QUIT ENDP

end start
SHIFT PROC NEAR
MOV CX,0CH
MOV DI,0DH

MOV AX,40H
MOV DS,AX
MOV SI,6CH
MOVIMAGE:
LODSW
ADD AX,5
MOV BX,AX
L3:
SUB SI,2
LODSW
CMP AX,BX
JBE L3
ADD CX,1000
MOV DX,3D4H
MOV AX,CX
OUT DX,AX
MOV DX,3D4H
MOV AX,DI
OUT DX,AX
CMP CX,10000
JBE MOVIMAGE
MOV AX,@DATA
MOV DS,AX
MOV ES,AX
MOV DI,OFFSET BMPNUM
MOV SI,DI
LODSW
CMP AX,3630H
JZ QUIT
INC AX
STOSW
CALL SHOW_320X200BMP
SHIFT ENDP 


JNC NEXT0
MOV AX,3
INT 10H
MOV AH,9
MOV DX,OFFSET ERROR
INT 21H
CALL QUIT