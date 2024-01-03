.model small
.386

.STACK

.data
cursorname 		db 'cursor.bmp',00  ;ICON BMP  FILE16X16=256 BYTE
info 			db 36h dup (0)                               ;ICON BMP FILE HEADER
colortable 		db 400h dup (0)                   ;ICON BMP FILE COLORTABLE
cursor 			db 100h dup (0)                         ;ICON BMP FILE DATA
BUFFER 			DB 100H DUP (0)                   ;LASTEST CURSOR_COVERED DATA
CURSOR_XY 		DW 0                              ;LASTEST CURSOR XY ADDRESS 
color 			db 1
msg_notfound 		db 'not found file ,quit now!',24h


.code
start:
mov ax,@data
mov ds,ax
MOV ES,AX
mov fs,ax
mov gs,ax

mov ax,3d00h
mov dx,offset cursorname
int 21h
jnc find_file
mov ah,9
mov dx,offset msg_notfound
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h
find_file:
mov bx,ax
mov ax,3f00h
mov cx,36h
mov dx,offset info
int 21h
MOV AX,3F00H
MOV CX,400H
MOV DX,OFFSET COLORTABLE
INT 21H
MOV AX,3F00H
MOV CX,100h
MOV DX,offset cursor
INT 21H
MOV AX,13h
INT 10H

cld
PUSH ES
MOV AX,0A000H
MOV ES,AX
MOV DI,0
xor bx,bx
mov bl,ds:[color]
MOV CX,16
set_palette:
PUSH CX
PUSH BX
MOV CX,20
set_line:
PUSH CX
MOV CX,16
MOV AL,BL
REP STOSB
INC BX
POP CX
LOOP set_line
POP BX
POP CX
LOOP set_palette
POP ES

mov dx,3c8h
mov al,0
out dx,al
mov si,offset colortable
mov cx,100h
setcolortable:
push cx
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
pop cx
loop setcolortable

cli
MOV AX,0
INT 33H
MOV AX,2
INT 33H

MOV AX,4
MOV CX,150
MOV DX,100
INT 33H

MOV AX,3
INT 33H

MOV AX,DX
MOV BX,320
MUL BX
ADD AX,CX
MOV DI,OFFSET CURSOR_XY
STOSW

MOV AX,0A000H
MOV DS,AX
MOV SI,ES:[CURSOR_XY]
MOV DI,OFFSET BUFFER
cld
MOV CX,16
L9:
PUSH CX
PUSH SI
MOV CX,16
REP MOVSB
POP SI
ADD SI,320
POP CX
LOOP L9


mov ax,seg mouse0
mov es,ax
mov dx,offset mouse0
mov cx,0FFH
mov ax,0ch
int 33h

sti
wait_stop_key:
in al,64h
test al,1
jz wait_stop_key
in al,60h
cmp al,1
jnz wait_stop_key
mov ax,3
int 10h
mov ah,4ch
int 21h

mouse0:
pusha
push ds
push es
mov ax,@data
mov ds,ax
mov ax,0a000h
mov es,ax
mov ax,dx
mov bx,320
mul bx
add ax,cx
PUSH AX
MOV DI,DS:[CURSOR_XY]
MOV SI,OFFSET BUFFER
MOV CX,16
L5:
PUSH CX
PUSH DI
MOV CX,16
REP MOVSB
POP DI
ADD DI,320
POP CX
LOOP L5
POP AX
mov DS:[CURSOR_XY],ax
MOV DI,AX
mov si,offset BUFFER
mov cx,16
l2:
push cx
push di
mov cx,16
L3:
MOV AL,ES:[DI]
MOV DS:[SI],AL
INC SI
INC DI
LOOP L3
pop di
add di,320
pop cx
loop l2

MOV SI,OFFSET CURSOR
MOV DI,DS:[CURSOR_XY]
MOV CX,16
l4:
push cx
push di
mov cx,16

calcBackground:       ;用BMP图象的黑色背景  “与”  屏幕底色    使光标黑色背景不会影响图象底色
mov al,ds:[si]
cmp al,0
jnz shownormal
or al,es:[di]
shownormal:
mov es:[di],al
inc si
inc di
loop calcBackground

pop di
add di,320
pop cx
loop l4

MOV AX,3
INT 33H
LL0:
and bx,1
JZ ENDINT

CMP DX,18
Ja todraw
MOV AX,CX 
MOV cL,16
div cl
inc al
mov ds:[color],al
jmp endint

TODRAW:
mov al,ds:[color]
MOV DI,DS:[CURSOR_XY]
SUB DI,642
STOSB
stosb
add di,318
stosb
stosb


ENDINT:
pop  es
pop ds
popa
retf                   ;U MUST USE RETF NOT RET------->>>ES:DX IS 32BIT FAR JUMP
end start
