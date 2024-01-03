
.386p
stack segment stack
db 01000h dup (0)
stack ends

DATA SEGMENT para use16
MESSAGE 	DB "INPUT EXE NAME TO RUN!",0AH,0DH,24H
EXENAME 	DB 20h DUP (0)
ERROR 		DB 'FILE NOT FOUND,STRIKE ANY KEY TO QUIT....',0AH,0DH,24H
quitmsg 	db 'press any key to quit....',24h

LOCATEITEM 	DW 0
LOCATEVOLUME 	DW 0
LOCATESS 	DW 0
LOCATESP 	DW 0
LOCATEIP 	DW 0
LOCATECS 	DW 0
LOCATEADDR 	DW 0
REALIP 		DW 0
REALCS 		DW 0
REALDS 		DW 0
cursorlow 	dw 0500fh
cursorhigh 	dw 000eh
handle 		dw 0
lowpage 	dw 0
highpage 	dw 0
loadseg 	dw 5000h
DATA ENDS

CODE SEGMENT para use16
ASSUME CS:CODE,ES:DATA,DS:DATA
START:
MOV AX,DATA
MOV ES,AX
MOV DS,AX
MOV AH,9
MOV DX,OFFSET MESSAGE
INT 21H



mov dx,3d4h
mov ax,080ah
out dx,ax
mov dx,3d4h
mov ax,080bh
out dx,ax
MOV DX,3D4H
MOV AX,es:[cursorlow]
OUT DX,AX
MOV DX,3D4H
MOV AX,es:[cursorhigh]
OUT DX,AX

MOV AX,0B800H
MOV DS,AX
MOV SI,160
MOV DI,OFFSET EXENAME
CLD
LL0:
MOV AH,0
INT 16H
cmp al,1bh
jnz next
mov ax,es
mov ds,ax
mov ah,9
mov dx,offset quitmsg
int 21h
mov ah,0
int 16h
call quit
next:
CMP AL,8
JNZ CHECKCR
DEC DI
SUB SI,2
cmp si,160
jge changecolor
add si,2
mov di,offset exename
changecolor:
MOV AX,720H
MOV DS:[SI],AX
JMP LL0

CHECKCR:
CMP AL,0DH
JZ NEXTPROC
STOSB
MOV AH,0AH
MOV DS:[SI],AX
ADD SI,2
JMP LL0

NEXTPROC:
MOV AL,0
STOSB
MOV AX,DATA
MOV DS,AX

MOV AX,3D00H
MOV DX,OFFSET EXENAME
INT 21H
JC TOERROR
mov bx,ax
mov es:[handle],ax
JMP NEXTSTEP

TOERROR:
MOV AH,9
MOV DX,OFFSET ERROR
MOV AX,ES
MOV DS,AX
INT 21H
MOV AH,0
INT 16H
call quit

NEXTSTEP:
MOV AX,4202H
mov bx,es:[handle]
MOV CX,0
MOV DX,0
INT 21H
mov es:[highpage],dx
mov es:[lowpage],ax
MOV AX,4200H
MOV CX,0 
MOV DX,0
INT 21H

MOV AX,es:[loadseg]
MOV DS,AX
MOV AX,3F00H
mov bx,es:[handle]
mov cx,es:[lowpage]
MOV DX,0
INT 21H

CLD
MOV DI,OFFSET LOCATEITEM
MOV SI,6
LODSW
STOSW
LODSW
STOSW
MOV SI,0EH
LODSW
STOSW
LODSW
STOSW
MOV SI,14H
LODSW
STOSW
LODSW
STOSW
LODSW
STOSW

MOV AX,es:[loadseg]     ;LOCATE DS
ADD AX,ES:[LOCATEVOLUME]
ADD AX,ES:[LOCATECS]
MOV ES:[REALCS],AX

MOV AX,0           ;LOCATE OFFSET
ADD AX,ES:[LOCATEIP]
MOV ES:[REALIP],AX

MOV AX,es:[loadseg]
ADD AX,ES:[LOCATEVOLUME]
ADD AX,ES:[LOCATESS]
MOV es:[locatess],AX

MOV AX,es:[loadseg]
ADD AX,ES:[LOCATEVOLUME]
SUB AX,10H
MOV ES:[REALDS],AX

MOV SI,ES:[LOCATEADDR]
MOV CX, ES:[LOCATEITEM]
CMP CX,0
JZ TOEXE
l0:
PUSH CX
MOV AX,es:[loadseg]
MOV DS,AX                      
mov di,WORD PTR DS:[SI]
ADD SI,2
MOV AX,es:[loadseg]
ADD AX,ES:[LOCATEVOLUME]
ADD AX,DS:[SI]
MOV DS,AX                      ;

MOV aX,DS:[DI]
ADD aX,es:[loadseg]
ADD aX,ES:[LOCATEVOLUME]
MOV DS:[DI],aX

ADD SI,2
POP CX
LOOP L0

TOEXE:
mov ax,es:[locatess]
mov ss,ax
cmp word ptr es:[locatesp],0
jz zerosp
mov sp,es:[locatesp]
jmp set_reg
zerosp:
mov sp,400h

set_reg:
MOV AX,ES:[REALIP]
MOV CS:[IPIP],AX
MOV AX,ES:[REALCS]
MOV CS:[CSCS],AX


MOV AX,0
MOV BX,es:[highpage]
MOV CX,es:[lowpage]
mov ax,es:[realds]
mov es,ax
mov ds,ax
mov ax,0
MOV DX,0
MOV SI,0
MOV DI,0
MOV BP,0
DB 0EAH
IPIP DW 0
CSCS DW 0


quit proc near
mov ah,4ch
int 21h
quit endp
CODE ENDS
END START