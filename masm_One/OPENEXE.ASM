.386p
stack segment stack
db 400h dup (0)
stack ends


DATA SEGMENT para use16
MESSAGE DB 'ESC to quit,otherwise  EXE filename to run:',0AH,0DH,24h
ERROR DB 'not found,press any key to begin....',0AH,0DH,24H
EXENAME DB 20h DUP (0)
handle dw 0
lowpage dw 0
highpage dw 0
LOCATEITEM DW 0
LOCATEVOLUME DW 0
LOCATESS DW 0
LOCATESP DW 0
LOCATEIP DW 0
LOCATECS DW 0
LOCATEADDR DW 0
REALIP DW 0
REALCS DW 0
REALDS DW 0
loadbseg dw 8000h
cursorlow dw 0400fh
cursorhigh dw 010eh
DATA ENDS



CODE SEGMENT para use16
ASSUME CS:CODE,ES:DATA,DS:DATA
START:
call inputname
call getfileinfo
call getrelocationparam
call jumptoexe


inputname proc near
mov ax,3
int 10h
MOV AX,DATA
MOV ES,AX
MOV DS,AX
MOV AH,9
MOV DX,OFFSET MESSAGE
INT 21H
mov word ptr es:[cursorlow],0400fh
mov word ptr es:[cursorhigh],0010eh


MOV AX,0B800H
MOV DS,AX
MOV SI,320
MOV DI,OFFSET EXENAME
cld
getname:
mov dx,3d4h
mov ax,es:[cursorlow]
out dx,ax
mov dx,3d4h
mov ax,es:[cursorhigh]
out dx,ax
MOV AH,0
INT 16H
CMP AL,8
JNZ CHECKCR

DEC DI
cmp di,offset exename
jge next0
mov di,offset exename
next0:
SUB SI,2
cmp si,320
jge next1
mov si,320
next1:
MOV AX,020H
MOV DS:[SI],AX
sub word ptr es:[cursorlow],100h
cmp es:[cursorlow],0400fh
jge next3
mov word ptr es:[cursorlow],0400fh
next3:
JMP getname

CHECKCR:
CMP AL,0DH
JZ toret
cmp al,1bh
jz toquit
STOSB
mov ah,0ah
mov ds:[si],ax
add si,2
add word ptr es:[cursorlow],100h
JMP getname
toret:
mov al,0
stosb
ret
toquit:
call quit
inputname endp







getfileinfo proc near
clc
MOV AX,DATA
MOV DS,AX
MOV AX,3D00H
MOV DX,OFFSET EXENAME
INT 21H

Jnc gethandle

notfoundfile:
MOV AX,ES
MOV DS,AX
MOV AH,9
MOV DX,OFFSET ERROR
INT 21H
mov ah,0
int 16h
call quit

gethandle:
MOV BX,AX
mov es:[handle],ax
MOV AX,4202H
MOV CX,0
MOV DX,0
INT 21H
mov es:[lowpage],ax
mov es:[highpage],dx
MOV AX,4200H
mov bx,es:[handle]
MOV CX,0 
MOV DX,0
INT 21H
MOV AX,es:[loadbseg]
MOV DS,AX
MOV AX,3F00H
mov cx,es:[lowpage]
MOV DX,0
INT 21H

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
ret
getfileinfo endp





getrelocationparam proc near
MOV AX,es:[loadbseg]    
ADD AX,ES:[LOCATEVOLUME]
ADD AX,ES:[LOCATECS]
MOV ES:[REALCS],AX

mov  AX,ES:[LOCATEIP]
MOV ES:[REALIP],AX

MOV AX,es:[loadbseg]
ADD AX,ES:[LOCATEVOLUME]
ADD AX,ES:[LOCATESS]
MOV es:[locatess],AX
;MOV SP,ES:[LOCATESP]

MOV AX,es:[loadbseg]
ADD AX,ES:[LOCATEVOLUME]
SUB AX,10H
MOV ES:[REALDS],AX

MOV SI,ES:[LOCATEADDR]
MOV CX, ES:[LOCATEITEM]
CMP CX,0
JZ toreturn
;dec cx
relocation:
mov bx,WORD PTR DS:[SI]
ADD SI,2
mov AX,DS:[SI]
add AX,es:[loadbseg]
ADD AX,ES:[LOCATEVOLUME]
MOV gs,AX    
sub si,2
mov bx,ds:[si]                  ;
mov ax,gs:[bx]
ADD ax,es:[loadbseg]
ADD ax,ES:[LOCATEVOLUME]
MOV gs:[bx],ax
ADD SI,4
LOOP relocation
toreturn:
ret
getrelocationparam endp



jumpTOEXE proc near
mov ax,3
int 10h
MOV AX,ES:[REALIP]
MOV CS:[IPIP],AX
MOV AX,ES:[REALCS]
MOV CS:[CSCS],AX
mov ax,es:[locatess]
mov ss,ax
mov sp,es:[locatesp]
MOV AX,ES:[REALDS]
MOV DS,AX
MOV ES,AX
MOV AX,0
MOV BX,0
MOV CX,0
MOV DX,0
MOV SI,0
MOV DI,0
MOV BP,0

DB 0eAH
IPIP DW 0
CSCS DW 0
jumptoexe endp



quit proc near
mov ax,3e00h
mov bx,es:[handle]
int 21h
mov ah,4ch
int 21h
quit endp
CODE ENDS
END START