.MODEL large

.CODE
org 100h
START:
mov ax,@data
mov ds,ax
mov ax,cs
mov es,ax


MOV AX,0A000H
MOV DS,AX
MOV AX,4f02H
mov bx,13h
INT 10H
MOV BP,0
MOV AL,2
L5:
MOV DS:[BP],AL
INC BP
CMP BP,0
JNZ L5

LOP:
MOV AX,0CH
MOV DX,OFFSET PROCESS
MOV CX,01H
INT 33H
NOP
in al,64h
test al,1
jz lop
IN AL,60H
CMP AL,1
JZ QUIT
JMP LOP

PROCESS PROC FAR
MOV BP,0
MOV AL,2
L0:
MOV DS:[BP],AL
INC BP
CMP BP,0
JNZ L0

MOV AX,DX
MOV BX,320
MUL BX
ADD AX,CX
MOV SI,AX
MOV BP,SI
ADD AX,8
MOV BX,AX
SUB AX,8
ADD AX,8*320
MOV DX,AX

MOV AL,4
L1:MOV DS:[BP],AL
INC BP
CMP BP,BX
JNZ L1

ADD SI,320
MOV BP,SI
ADD BX,320
CMP BP,DX
JNZ L1

RET
PROCESS ENDP
quit:MOV AX,3
INT 10H
MOV AH,4CH
INT 21H
END START


.DATA
.STACK 

mov ax,es
push ax
mov ax,40h
mov es,ax
mov bp,1ah
mov ax,es:[bp]
mov bp,ax
mov ax,es:[bp]
cmp al,1bh
jz quit
pop ax
mov es,ax

cld
push ds
push es
mov ax,40h
mov ds,ax
mov ax,8000h
mov es,ax
mov si,1eh
mov di,1eh
mov cx,30
rep movsb
pop es
pop ds

push ds
push es
mov ax,40h
mov ds,ax
mov ax,8000h
mov es,ax
mov si,1eh
mov di,1eh
mov cx,30
rep cmpsw
jnz quit

pop es
pop ds