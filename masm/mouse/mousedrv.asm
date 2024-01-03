.386
.model small
.stack
.code
mouse proc far
push ax
PUSH BX
PUSH CX
PUSH DX
PUSH BP
PUSH SI
PUSH DI
PUSH DS
PUSH ES
mov bx,0
mov cx,0
mov dx,0
mov ax,0

MOV AX,0B800H
MOV DS,AX
MOV AX,2000H
MOV ES,AX
MOV DI,4
MOV BP,WORD PTR ES:[DI]

MOV DI,0
MOV AL,ES:[DI]
CMP AL,0
JZ FIRST
CMP AL,1
JZ SECOND 
CMP AL,2
JZ THIRD
jmp return

FIRST:
MOV SI,0
MOV AL,1
MOV ES:[SI],AL
MOV SI,1
in al,60h
MOV ES:[SI],AL
JMP RETURN

SECOND:
MOV SI,0
MOV AL,2
MOV ES:[SI],AL
MOV SI,2
in al,60h
MOV ES:[SI],AL
JMP RETURN

THIRD:
mov si,0
mov al,0
mov es:[si],al
MOV SI,3
IN AL,60H
MOV ES:[SI],AL

mov bx,0
mov cx,0
mov dx,0
MOV SI,1
MOV BL,ES:[SI]
INC SI
MOV CL,ES:[SI]
INC SI
MOV DL,ES:[SI]

MOV AL,160
MUL DL
MOV DX,AX


test bl,10h
jnz left       ;x<0 to left
test bl,20h            ;x>0 right
jz rightdown

rightup:
add bp,cx
sub bp,dx
mov di,bp
shr di,3
and di,0fffeh
mov AX,4142H
mov WORD PTR Ds:[di],aX
jmp return

rightdown:
add bp,cx
add bp,dx
mov di,bp
shr di,3
and di,0fffeh
mov ax,4142H
mov Ds:[di],aX
jmp return

left:
test bl,20h
jnz leftup

sub bp,cx
add bp,dx
mov di,bp
shr di,3
and di,0fffeh
mov ax,04142H
mov Ds:[di],aX
jmp return

leftup:
sub bp,cx
sub bp,dx
mov di,bp
shr di,3
and di,0fffeh
mov ax,4142H
mov Ds:[di],aX

return:
MOV SI,4
MOV ES:[SI],BP

MOV AL,20H
OUT 20H,AL
out 0a0h,al
POP ES
POP DS
POP DI
POP SI
POP BP
POP DX
POP CX
POP BX
POP AX
sti
iret
mouselenth=$-mouse
mouse endp

start:
push ds
mov ax,0
push ax
cli

mov ax,seg mouse
mov ds,ax
mov ax,8000h
mov es,ax
mov di,0
mov si,offset mouse
mov cx,mouselenth
rep movsb

mov ax,0
mov ds,ax
mov si,1d0h
mov ds:[si],ax
add si,2 
mov ax,8000h
mov ds:[si],ax

ll0:
in al,64h
test al,2
jnz ll0
;mov al,0adh
;out 64h,al

l0:
in al,64h
test al,2
jnz l0

MOV AL,0A8H
OUT 64H,AL

L1:
IN AL,64H
TEST AL,2
JNZ L1

MOV AL,0D4H
OUT 64H,AL

L2:IN AL,64H
TEST AL,2
JNZ L2

LL2:
MOV AL,0F4H
OUT 60H,AL
LL1:in al,64h
test al,1
jz LL1
in al,60h
cmp al,0fah
JNZ LL2
mov al,80h
out 60h,al
LL3:in al,64h
test al,2
jnz LL3
MOV AL,08
OUT 60H,AL

L3:
IN AL,64H
TEST AL,2
JNZ L3

MOV AL,60H
OUT 64H,AL

L4:IN AL,64H
TEST AL,2
JNZ L4

MOV AL,47H
OUT 60H,AL

LLL1:
in al,64h
test al,2
jnz LLL1
mov al,0aeh
out 64h,al

MOV AX,2000H
MOV ES,AX
MOV DI,0
MOV AL,0
MOV eS:[dI],AL
MOV DI,4
MOV AX,00H
MOV eS:[dI],AX

mov al,0
out 21h,al
out 0a1h,al
sti
RETF
END START
