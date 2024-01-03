DATA SEGMENT 
SSPEED DB 'SPEED:',0DH,0AH,'$' 
SSPEEDH DB '1.HIGH',0DH,0AH,'$' 
SSPEEDN DB '2.NORMAL',0DH,0AH,'$' 
SSPEEDL DB '3.LOW',0DH,0AH,'$' 
SSPEEDH1 DB 'HIGH',0DH,0AH,'$' 
SSPEEDN1 DB 'NORMAL',0DH,0AH,'$' 
SSPEEDL1 DB 'LOW',0DH,0AH,'$' 
DIRECTIONL DB 'LEFT:A',0DH,0AH,'$' 
DIRECTIONR DB 'RIGHT:D',0DH,0AH,'$' 
DIRECTIONU DB 'UP:W',0DH,0AH,'$' 
DIRECTIOND DB 'DOWN:S',0DH,0AH,'$' 
AUTHOR1 DB 'AUTHOR:',0DH,0AH,'$' 
AUTHOR2 DB 'ZPQ',0DH,0AH,'$' 
BETA DB 'BETA2.0',0DH,0AH,'$' 
SPEED DB ? 
EMP1 DB 50 DUP(?) 
SNAKE DB 9,9,12,9,15,9,18,9,21,9 
DB 24,9,27,9,30,9,33,9,36,9 
DB 39,9,42,9,45,9,48,9,51,9 
EMP2 DB 500 DUP(?) 
DATA ENDS 

STACK SEGMENT STACK 
STACK ENDS 

CODE SEGMENT 
    ASSUME CS:CODE,DS:DATA,SS:STACK 

CLEAR PROC NEAR ;���� 
PUSH AX 
PUSH BX 
PUSH CX 
PUSH DX 

MOV AH,6 
MOV AL,7 
MOV CH,0 
MOV CL,0 
MOV DH,200 
MOV DL,200 
MOV BH,0 
INT 10H 

POP DX 
POP CX 
POP BX 
POP AX 
RET 
CLEAR ENDP 

POINT PROC NEAR ;���� 
PUSH AX 
PUSH BX 
PUSH CX 
PUSH DX 

DEC CX 
DEC DX 
MOV AL,1 
MOV AH,0CH 
INT 10H 

INC CX 
MOV AL,1 
MOV AH,0CH 
INT 10H 

INC CX 
MOV AL,1 
MOV AH,0CH 
INT 10H 

INC DX 
MOV AL,1 
MOV AH,0CH 
INT 10H 

DEC CX 
MOV AL,3 
MOV AH,0CH 
INT 10H 

DEC CX 
MOV AL,3 
MOV AH,0CH 
INT 10H 

INC DX 
MOV AL,3 
MOV AH,0CH 
INT 10H 

INC CX 
MOV AL,3 
MOV AH,0CH 
INT 10H 

INC CX 
MOV AL,3 
MOV AH,0CH 
INT 10H 

POP DX 
POP CX 
POP BX 
POP AX 
RET 
POINT ENDP 

POINT1 PROC NEAR ;����ܵ� 
PUSH AX 
PUSH BX 
PUSH CX 
PUSH DX 

DEC CX 
DEC DX 
MOV AL,2 
MOV AH,0CH 
INT 10H 

INC CX 
MOV AL,2 
MOV AH,0CH 
INT 10H 

INC CX 
MOV AL,2 
MOV AH,0CH 
INT 10H 

INC DX 
MOV AL,2 
MOV AH,0CH 
INT 10H 

DEC CX 
MOV AL,2 
MOV AH,0CH 
INT 10H 

DEC CX 
MOV AL,2 
MOV AH,0CH 
INT 10H 

INC DX 
MOV AL,2 
MOV AH,0CH 
INT 10H 

INC CX 
MOV AL,2 
MOV AH,0CH 
INT 10H 

INC CX 
MOV AL,2 
MOV AH,0CH 
INT 10H 

POP DX 
POP CX 
POP BX 
POP AX 
RET 
POINT1 ENDP 

DPOINT PROC NEAR ;��� 
PUSH AX 
PUSH BX 
PUSH CX 
PUSH DX 

DEC CX 
DEC DX 
MOV AL,0 
MOV AH,0CH 
INT 10H 

INC CX 
MOV AL,0 
MOV AH,0CH 
INT 10H 

INC CX 
MOV AL,0 
MOV AH,0CH 
INT 10H 

INC DX 
MOV AL,0 
MOV AH,0CH 
INT 10H 

DEC CX 
MOV AL,0 
MOV AH,0CH 
INT 10H 

DEC CX 
MOV AL,0 
MOV AH,0CH 
INT 10H 

INC DX 
MOV AL,0 
MOV AH,0CH 
INT 10H 

INC CX 
MOV AL,0 
MOV AH,0CH 
INT 10H 

INC CX 
MOV AL,0 
MOV AH,0CH 
INT 10H 

POP DX 
POP CX 
POP BX 
POP AX 
RET 
DPOINT ENDP 

READY PROC NEAR ;����� 
PUSH AX 
PUSH BX 
PUSH CX 
PUSH DX 

MOV BX,50 
MOV CX,6 
MOV DX,6 

READY1: 
CALL POINT1 
INC CX 
INC CX 
INC CX 
DEC BX 
JNZ READY1 

MOV BX,50 

READY2: 
CALL POINT1 
INC DX 
INC DX 
INC DX 
DEC BX 
JNZ READY2 

MOV BX,50 

READY3: 
CALL POINT1 
DEC CX 
DEC CX 
DEC CX 
DEC BX 
JNZ READY3 

MOV BX,50 

READY4: 
CALL POINT1 
DEC DX 
DEC DX 
DEC DX 
DEC BX 
JNZ READY4 

MOV BX,30 
MOV CX,180 



 

MOV DX,6 

READY5: 
CALL POINT1 
INC CX 
INC CX 
INC CX 
DEC BX 
JNZ READY5 

MOV BX,40 

READY6: 
CALL POINT1 
INC DX 
INC DX 
INC DX 
DEC BX 
JNZ READY6 

MOV BX,30 

READY7: 
CALL POINT1 
DEC CX 
DEC CX 
DEC CX 
DEC BX 
JNZ READY7 

MOV BX,40 

READY8: 
CALL POINT1 
DEC DX 
DEC DX 
DEC DX 
DEC BX 
JNZ READY8 

POP DX 
POP CX 
POP BX 
POP AX 
RET 
READY ENDP 

DRAW PROC NEAR ;���� 
PUSH BX 
PUSH CX 
PUSH DX 
PUSH SI 
PUSH DI 

DEC SI 
DEC SI 
MOV CL,[SI] 
XOR CH,CH 
INC SI 
MOV DL,[SI] 
XOR DH,DH 
DEC SI 
CALL DPOINT 
INC SI 
INC SI 

DRAW1: 
MOV CL,[SI] 
XOR CH,CH 
INC SI 
MOV DL,[SI] 
XOR DH,DH 
INC SI 
CALL POINT 
DEC BL 
JNZ DRAW1 
POP DI 
POP SI 
POP DX 
POP CX 
POP BX 
RET 
DRAW ENDP 

MOVE PROC NEAR ;�ƶ� 
INC SI 
INC SI 
CMP BH,'a' 
JZ MOVERL 
CMP BH,'d' 
JZ MOVERL 
CMP BH,'w' 
JZ MOVEUD 
CMP BH,'s' 
JZ MOVEUD 

MOVERL: 
CMP AL,'w' 
JZ MOVEU 
CMP AL,'s' 
JZ MOVED 
CMP BH,'a' 
JZ MOVEL 
CMP BH,'d' 
JZ MOVER 

MOVEUD: 
CMP AL,'a' 
JZ MOVEL 
CMP AL,'d' 
JZ MOVER 
CMP BH,'w' 
JZ MOVEU 
CMP BH,'s' 
JZ MOVED 

MOVEL: 
MOV AH,[DI] 
SUB AH,3 
INC DI 
MOV AL,[DI] 
INC DI 
MOV [DI],AH 
INC DI 
MOV [DI],AL 
DEC DI 
MOV BH,'a' 
JMP MOVEEND 

MOVER: 
MOV AH,[DI] 
ADD AH,3 
INC DI 
MOV AL,[DI] 
INC DI 
MOV [DI],AH 
INC DI 
MOV [DI],AL 
DEC DI 
MOV BH,'d' 
JMP MOVEEND 

MOVEU: 
MOV AH,[DI] 
INC DI 
MOV AL,[DI] 
SUB AL,3 
INC DI 
MOV [DI],AH 
INC DI 
MOV [DI],AL 
DEC DI 
MOV BH,'w' 
JMP MOVEEND 

MOVED: 
MOV AH,[DI] 
INC DI 
MOV AL,[DI] 
ADD AL,3 
INC DI 
MOV [DI],AH 
INC DI 
MOV [DI],AL 
DEC DI 
MOV BH,'s' 
JMP MOVEEND 

MOVEEND: 
RET 
MOVE ENDP 

RESET PROC NEAR ;��λ 
PUSH AX 
PUSH BX 
PUSH CX 
PUSH DX 
PUSH DI 

MOV DI,SI 
DEC DI 
DEC DI 
MOV DX,DI 

RESET1: 
MOV AL,[SI] 
MOV [DI],AL 
INC SI 
INC DI 
MOV AL,[SI] 
MOV [DI],AL 
INC SI 
INC DI 
DEC Bl 
JNZ RESET1 

RESET2: 
MOV SI,DX 
POP DI 
DEC DI 
DEC DI 
POP DX 
POP CX 
POP BX 
POP AX 
RET 
RESET ENDP 

DELAY PROC NEAR ;�ӳ� 
PUSH AX 
PUSH BX 
PUSH CX 
PUSH DX 
  LEA BX,SPEED 
    MOV BX,[BX] 

MOV AH,0 
INT 1AH 
ADD BX,DX 
LOOP1: 
INT 1AH 
CMP DX,BX 
JNZ LOOP1 

POP DX 
POP CX 
POP BX 
POP AX 
RET 
DELAY ENDP 

RPOINT  PROC  NEAR ;����� 
PUSH AX 
PUSH BX 

CMP CH,1 
JNZ RPOINTEND 
JMP RPOINT1 

RSET: 
POP SI 
POP BX 
PUSH BX 

RPOINT1: 
MOV AH,2CH 
INT 21H 
MOV CL,4 

MOV AL,DH 
SHL AX,CL 
AND AH,0FH 
SHR AL,CL 
AND AL,0FH 

MOV BL,DL 
SHL BX,CL 
AND BH,0FH 
SHR BL,CL 
AND BL,0FH 

ADD AL,AH 
ADD AL,AH 
MOV CH,AL 
ADD AL,CH 
ADD AL,CH 
ADD AL,CH 
ADD AL,CH 
ADD AL,CH 
MOV CL,AL 
ADD CL,21 
XOR CH,CH 

ADD BL,BH 
MOV DH,BL 
ADD BL,DH 
ADD BL,DH 
ADD BL,DH 
ADD BL,DH 
ADD BL,DH 
MOV DL,BL 
ADD DL,21 
XOR DH,DH 

POP BX 
PUSH BX 
PUSH SI 

RPOINT2: 
MOV AH,[SI] 
INC SI 
MOV AL,[SI] 
INC SI 
CLC 
CMP CL,AH 
JZ RSET 
CLC 
CMP DL,AL 
JZ RSET 
CLC 
DEC BL 
JNZ RPOINT2 





CALL POINT 
POP SI 

RPOINTEND: 
POP BX 
POP AX 
MOV CH,0 
RET 
RPOINT ENDP  

EAT PROC NEAR 
PUSH AX 
PUSH BX 
PUSH CX 
PUSH DX 
PUSH DI 
PUSH SI 

MOV AH,[DI] 
INC DI 
MOV AL,[DI] 

CMP AH,CL ;��ͷλ�ø������Ƚ� 
JNZ EAT2 
CMP AL,DL 
JNZ EAT2 

EAT1: ;�Ե� 
POP SI 
POP DI 
POP DX 
POP CX 
POP BX 

CMP BH,'a' 
JZ EATL 
CMP BH,'d' 
JZ EATR 
CMP BH,'w' 
JZ EATU 
CMP BH,'s' 
JZ EATD 

EATL: 
MOV AH,[DI] 
SUB AH,3 
INC DI 
MOV AL,[DI] 
INC DI 
MOV [DI],AH 
INC DI 
MOV [DI],AL 
DEC DI 
JMP EAT11 
EATR: 
MOV AH,[DI] 
ADD AH,3 
INC DI 
MOV AL,[DI] 
INC DI 
MOV [DI],AH 
INC DI 
MOV [DI],AL 
DEC DI 
JMP EAT11 
EATU: 
MOV AH,[DI] 
INC DI 
MOV AL,[DI] 
SUB AL,3 
INC DI 
MOV [DI],AH 
INC DI 
MOV [DI],AL 
DEC DI 
JMP EAT11 
EATD: 
MOV AH,[DI] 
INC DI 
MOV AL,[DI] 
ADD AL,3 
INC DI 
MOV [DI],AH 
INC DI 
MOV [DI],AL 
DEC DI 
JMP EAT11 

EAT11: 
POP AX 
INC BL ;�߳���+1 
MOV CH,1 
RET 

EAT2: 
POP SI 
POP DI 
POP DX 
POP CX 
POP BX 
POP AX ;û�Ե� 
RET 
EAT ENDP 

FAIL PROC NEAR ;ʧ�� 
PUSH AX 
PUSH BX 
PUSH CX 
PUSH DX 
PUSH DI 
PUSH SI 

MOV AH,[DI] 
INC DI 
MOV AL,[DI] 
INC DI 
CMP AH,6 
JZ FAIL2 
CMP AH,156 
JZ FAIL2 
CMP AL,6 
JZ FAIL2 
CMP AL,156 
JZ FAIL2 

FAIL1: 
DEC BL 
CMP BL,0 
JZ FAILNEXT 
MOV CH,[SI] 
INC SI 
MOV CL,[SI] 
INC SI 
CMP AH,CH 
JNZ FAIL1 
CMP AL,CL 
JNZ FAIL1 

FAIL2: 
POP SI 
POP DI 
POP DX 
POP AX 
POP BX 
POP AX 
    MOV AH,4CH 
    INT 21H 

FAILNEXT: 
POP SI 
POP DI 
POP DX 
POP CX 
POP BX 
POP AX 
RET 
FAIL ENDP 

START: 
    MOV AX,DATA 
    MOV DS,AX 

LEA BX,SPEED 
MOV [BX],05FFH 

LEA DX,SSPEED 
MOV AH,09 
INT 21H 

LEA DX,SSPEEDH 
MOV AH,09 
INT 21H 

LEA DX,SSPEEDN 
MOV AH,09 
INT 21H 

LEA DX,SSPEEDL 
MOV AH,09 
INT 21H 

MOV AH,1 
INT 21H 
CMP AL,'1' 
JZ SPEED1 
CMP AL,'2' 
JZ SPEED2 
CMP AL,'3' 
JZ SPEED3 

SPEED1: 
push ax
mov ax,1
MOV [BX],ax
pop ax
LEA DX,SSPEEDH1 
JMP GAMENEXT 
SPEED2: 
push ax
mov ax,2
MOV [BX],ax
pop ax
LEA DX,SSPEEDN1 
JMP GAMENEXT 
SPEED3: 
push ax
mov ax,3
MOV [BX],ax
pop ax
LEA DX,SSPEEDL1 
JMP GAMENEXT 

GAMENEXT: 
PUSH DX 

MOV AH,0 
MOV AL,4 
INT 10H 

MOV AH,0BH 
MOV BH,0 
MOV BL,1 
INT 10H 

MOV DH,3 ;���ƹ�� 
MOV DL,27 
MOV BH,0 
MOV AH,2 
INT 10H 

POP DX 
MOV AH,09 
INT 21H 

MOV DH,2 
MOV DL,24 
MOV BH,0 
MOV AH,2 
INT 10H 

LEA DX,SSPEED 
MOV AH,09 
INT 21H 

MOV DH,5 
MOV DL,24 
MOV BH,0 
MOV AH,2 
INT 10H 

LEA DX,DIRECTIONL 
MOV AH,09 
INT 21H 

MOV DH,6 
MOV DL,24 
MOV BH,0 
MOV AH,2 
INT 10H 

LEA DX,DIRECTIONR 
MOV AH,09 
INT 21H 

MOV DH,7 
MOV DL,24 
MOV BH,0 
MOV AH,2 
INT 10H 

LEA DX,DIRECTIONU 
MOV AH,09 
INT 21H 

MOV DH,8 
MOV DL,24 
MOV BH,0 
MOV AH,2 
INT 10H 

LEA DX,DIRECTIOND 
MOV AH,09 
INT 21H 

MOV DH,10 
MOV DL,24 
MOV BH,0 
MOV AH,2 
INT 10H 

LEA DX,AUTHOR1 
MOV AH,09 
INT 21H 

MOV DH,11 
MOV DL,27 
MOV BH,0 
MOV AH,2 
INT 10H 

LEA DX,AUTHOR2 
MOV AH,09 
INT 21H 

MOV DH,13 
MOV DL,24 
MOV BH,0 
MOV AH,2 
INT 10H 

LEA DX,BETA 
MOV AH,09 
INT 21H 

LEA SI,SNAKE 
MOV DI,SI 
ADD DI,28 
MOV BL,15 ;�ߵĳ�ʼ���� 
MOV BH,'d' ;��ʼ�ƶ����� 
XOR AL,AL 
MOV CH,1 ;������������ΪCH=1 
CALL READY 
CALL DRAW 

CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 
CALL DELAY 


GAME: 
MOV AH,0BH 
INT 21H 
INC AL 
JE GAME1 
JNE GAME2 

GAME1: 
MOV AH,08H 
INT 21H 
CALL MOVE 
CALL DRAW 
CALL RESET 
CALL RPOINT 
CALL EAT 
CALL FAIL 
CALL DELAY 
JMP GAME 

GAME2: 
CALL MOVE 
CALL DRAW 
CALL RESET 
CALL RPOINT 
CALL EAT 
CALL FAIL 
CALL DELAY 
JMP GAME 

LAST: 
    MOV AH,4CH 
    INT 21H 
CODE ENDS 
    END START
 