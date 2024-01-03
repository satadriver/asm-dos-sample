.386
code segment para use16
assume cs:code
start:
push ds       ;trap did not need to CLI and OUT 21H,FF;U CALL IT!
mov  ax,0
push ax

mov es,ax
mov di,1
shl di,2
mov ax,offset Int1Proc
stosw
mov ax,Seg Int1Proc
stosw

mov ax,3100h
mov dx,Int1Len
add dx,0fh
shr dx,4
add dx,10h
int 21h
retf

int1proc:
cli
PUSH DS
PUSH SS
PUSH ES
PUSH DI
PUSH SI

PUSH BP
push sp
PUSH DX
PUSH CX
PUSH BX
PUSH AX

MOV AX,0b800h
MOV ES,AX
MOV DI,3C0H  
MOV AX,Code
MOV DS,AX
MOV SI,OFFSET REG1
mov ax,offset int1proc
sub si,ax
CLD
MOV bp,13
jmp sHOWNEXT

REG1 DB 'AX='
REG2 DB 'BX='
REG3 DB 'CX='
REG4 DB 'DX='
REG5 DB 'SP='
REG6 DB 'BP='
REG7 DB 'SI='
REG8 DB 'DI='
REG9 DB 'es='
REG10 DB 'SS='
REG11 DB 'DS='
REG14 DB 'ip='
REG15 DB 'cs='

SHOWNEXT:
LODSB
MOV AH,4
STOSW

LODSB
STOSW

LODSB
STOSW

POP AX
MOV bX,aX
mov cl,12
sHR AX,cl
cmp al,9
jbe l0
add al,7
l0:
ADD AL,30H
MOV AH,4H
STOSW

MOV AX,BX
mov cl,4
SHL AX,cl
mov cl,12
SHR AX,cl
cmp al,9
jbe  l1
add al,7
L1:
ADD AL,30H
MOV AH,4H
STOSW

MOV AX,BX
mov cl,8
SHL AX,cl
mov cl,12
SHR AX,cl
cmp al,9
jbe l2
add al,7
l2:
ADD AL,30H
MOV AH,4H
STOSW

mov ax,bx
mov cl,12
SHL AX,cl
SHR AX,cl
cmp al,9
jbe l3
add al,7
l3:
ADD AL,30H
MOV AH,4H
STOSW

MOV AX,0020H
STOSW
dec bp
cmp bp,0
jnz shownext

loop0:in al,64h
test al,1
jz loop0
IN AL,60H
cmp al,80h
jaE loop0

sub sp,26
POP AX
POP BX
POP CX
POP DX
POP SP
POP BP
POP SI
POP DI
POP ES
POP SS
POP DS

IRET
int1len=$-int1proc
CODE ENDS
end start
