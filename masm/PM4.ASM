.386p
stack0 segment para use16
db 1000h dup (0)
stack0 ends
stack1 segment para use16
db 1000h dup (0)
stack1 ends
stack2 segment para use16
db 1000h dup (0)
stack2 ends
stack3 segment para use16
db 1000h dup (0)
stack3 ends

V86DATA SEGMENT Para USE16
DB 0001000H DUP (0)
V86DATA ENDS

TSSSEG0 SEGMENT PARA USE16
DD 25 DUP (0)
DW 0 
DW $+2
DB 100H DUP (0)
DB 0FFH
TSSSEG0 ENDS 

TSSSEG1 SEGMENT PARA  USE16
DD 0 ;CHAIN
DD 78h ;ESP0
DD 400h ;SS0
DD 0 ;ESP1
DD 0 ;SS1
DD 0 ;ESP2
DD 0 ;SS2
DD 0 ;CR3
DD 0 ;EIP
DD 2 ;EFLAGES
DD 0 ;EAX
DD 0 ;ECX
DD 0 ;EDX
DD 0 ;EBX
DD 800H     ;ESP
DD 0 ;EBP
DD 0 ;ESI
DD 0 ;EDI
DD 48h ;ES
DD 28H      ;CS
DD 78H      ;SS
DD 48H ;DS
DD 48H ;FS
DD 48H ;GS
DD 0 ;LDT
DW 0
DW $+2
DB 100H DUP (0)
DB 0FFH
TSSSEG1 ENDS

gdtpointer segment para use16
gdtlimit dw gdtlen-1
gdtbase  dd 0
gdtpointer ends

gdtseg segment para  use16
GDT0 DQ 0
gdt1 dq 000098000000FFFFH
GDT2 DQ 004098000000FFFFH
GDT3 DQ 0040f8000000FFFFH

GDT4 DQ 0040b8000000FFFFH
GDT5 DQ 004098000000FFFFH
GDT6 DQ 004098000000FFFFH
GDT7 DQ 0
GDT8 DQ 0
GDT9 DQ 0000920A0000FFFFH
GDT10 DQ 0000920B8000FFFFH

GDT11 DQ 0040920000000FFFH
GDT12 DQ 0040920000000FFFH
GDT13 DQ 0040920000000FFFH
GDT14 DQ 0040f20000000FFFH
GDT15 DQ 0040920000000fffh

GDT16 DQ 0040890000000168H
GDT17 DQ 0040e90000000168H   ;40E9

GDT18 DQ 0000920000000FFFH
gdt19 dq 0000ec0000280000h
gdtlen=$-gdt0
gdtseg ends

idtpointer segment para use16
idtlimit dw 7ffh
idtbase  dd 0
DOSIDTLIMIT DW 3FFH
DOSIDTBASE DD  0
idtpointer ends

idtseg segment para use16
REPT 256 
DQ 0000EF0000980000H    ;WHY USE EF NOT 8F??
ENDM
idtseg ends

CODE1 SEGMENT PARA USE16
ASSUME CS:CODE1
cli
mov ax,48h
mov es,ax
mov edi,0
mov ecx,0ffffh
mov al,1
rep stosb
ll:in al,60h
cmp al,39h
jnz ll
MOV AX,80H
LTR AX
db 09ah
dw 0
dw 10h

toreal:
;CLTS
mov ax,50h
mov SS,AX
MOV DS,AX
MOV ES,AX
MOV FS,AX
MOV GS,AX
MOV EAX,CR0
AND AL,0FEH
MOV CR0,EAX
JMP FAR PTR REAL
CODE1 ENDS

CODE2 SEGMENT PARA USE32
ASSUME CS:CODE2
mov AX,58H
MOV SS,AX
mov esp,800h

;CLTS   ;HERE THOSE 6 INSTRUCTIONS IS VERY IMPORTANT,WHTHOUT THE WILL COLLAPSE!!!
PUSHFD ;;;;;;;
POP EAX   ;;;;
AND EAX,0FFFFBFFFH ;;;;
PUSH EAX         ;;;;;;
POPFD            ;;;;;;

MOV EAX,0
PUSH EAX ;GS
PUSH EAX ;FS
PUSH EAX ;DS
PUSH EAX ;ES

MOV AX,90H
MOV DS,AX
MOV ESI,0
LODSD ;SS
MOV EDX,EAX
AND EAX,0FFFFH
PUSH EAX

MOV EAX,800H ;ESP
PUSH EAX

MOV EAX,23002H ;EFLAGES
PUSH EAX  

MOV EAX,EDX       ;CS
SHR EAX,16
PUSH EAX

MOV EAX,0      ;EIP
PUSH EAX
IRETD
CODE2 ENDS

CODE3 SEGMENT PARA USE16
assume cs:code3
mov ax,0a000h
mov es,ax
mov di,0
mov cx,0ffffh
mov al,2
rep stosb

l2:in al,60h
cmp al,1
jnz l2

;MOV AX,78H ;THESE 2 INSTRUCTION HERE IS NOT CORRECT!!!!16BITS SEGMENT HERE!!
;MOV SS,AX  ;16BITS SEGMENT  CAN'T USE 32 BITS STACK SEGMENT

INT 20H
;CLTS
DB 0eAH
DW 0
;DW 0      ;HERE IS 16BITS SEGMENT,CAN'T RECOGNISE 32 SEGMENT
DW 98H
CODE3 ENDS

CODE4 SEGMENT PARA USE32
ASSUME CS:CODE4
DB 0eAH
DW 0
DW 0
DW 28H
CODE4 ENDS

CODE5 SEGMENT PARA USE32
ASSUME CS:CODE5
MOV AX,48H
MOV ES,AX
MOV EDI,0
MOV AL,4
MOV ECX,0FFFFH
REP STOSB
L3:IN AL,60H
CMP AL,1CH
JNZ L3

DB 09AH             ;WHY CAN'T USE 09AH(INSTRUCTION CALL) TO CODE5??
DW OFFSET TOREAL
DW 0
DW 8
CODE5 ENDS


CODE0 SEGMENT PARA USE16
ASSUME CS:CODE0,DS:GDTSEG,ES:GDTPOINTER,FS:IDTSEG,GS:IDTPOINTER
START:
MOV AX,GDTSEG
MOV DS,AX
MOV AX,GDTPOINTER
MOV ES,AX

XOR EAX,EAX
MOV AX,GDTSEG
SHL EAX,4
MOV DWORD PTR ES:[GDTBASE],EAX

xor eax,eax
mov ax,code1
shl eax,4
mov word ptr ds:[gdt1+2],ax
shr eax,16
mov byte ptr ds:[gdt1+4],al

xor eax,eax
mov ax,code2
shl eax,4
mov word ptr ds:[gdt2+2],ax
shr eax,16
mov byte ptr ds:[gdt2+4],al

xor eax,eax
mov ax,code3
shl eax,4
mov word ptr ds:[gdt3+2],ax
shr eax,16
mov byte ptr ds:[gdt3+4],al

xor eax,eax
mov ax,code4
shl eax,4
mov word ptr ds:[gdt4+2],ax
shr eax,16
mov byte ptr ds:[gdt4+4],al

xor eax,eax
mov ax,code5
shl eax,4
mov word ptr ds:[gdt5+2],ax
shr eax,16
mov byte ptr ds:[gdt5+4],al

xor eax,eax
mov ax,stack0
shl eax,4
mov word ptr ds:[gdt11+2],ax
shr eax,16
mov byte ptr ds:[gdt11+4],al

xor eax,eax
mov ax,stack1
shl eax,4
mov word ptr ds:[gdt12+2],ax
shr eax,16
mov byte ptr ds:[gdt12+4],al

xor eax,eax
mov ax,stack2
shl eax,4
mov word ptr ds:[gdt13+2],ax
shr eax,16
mov byte ptr ds:[gdt13+4],al

xor eax,eax
mov ax,stack3
shl eax,4
mov word ptr ds:[gdt14+2],ax
shr eax,16
mov byte ptr ds:[gdt14+4],al

xor eax,eax
mov ax,tssseg0
shl eax,4
mov word ptr ds:[gdt16+2],ax
shr eax,16
mov byte ptr ds:[gdt16+4],al
mov byte ptr ds:[gdt16+7],ah


xor eax,eax
mov ax,tssseg1
shl eax,4
mov word ptr ds:[gdt17+2],ax
shr eax,16
mov byte ptr ds:[gdt17+4],al
mov byte ptr ds:[gdt17+7],ah

MOV AX,IDTSEG
MOV FS,AX
MOV AX,IDTPOINTER
MOV GS,AX

XOR EAX,EAX
MOV AX,IDTSEG
SHL EAX,4
MOV DWORD PTR GS:[IDTBASE],EAX

xor eax,eax
MOV AX,V86DATA
SHL EAX,4
MOV WORD PTR DS:[GDT18+2],AX
SHR EAX,16
MOV BYTE PTR DS:[GDT18+4],AL

assume es:nothing
ASSUME ES:V86DATA
MOV AX,V86DATA
MOV ES,AX
MOV DI,0
MOV AX,STACK3
STOSW
MOV AX,CODE3
STOSW

ASSUME ES:GDTPOINTER
MOV AX,GDTPOINTER
MOV ES,AX

mov ax,13h
int 10h
CLI
MOV AL,2
OUT 92H,AL
LGDT QWORD PTR ES:[GDTLIMIT]
LIDT   QWORD PTR GS:[IDTLIMIT]

mov eax,cr0
or al,1
mov cr0,eax
db 09ah
dw 0
dw 8

real:
ASSUME GS:IDTPOINTER
MOV AX,STACK0
MOV SS,AX
MOV AX,IDTPOINTER
MOV GS,AX
LIDT QWORD PTR GS:[DOSIDTLIMIT]
mov ax,3
int 10h
mov ah,4ch
int 21h
code0 ends
end start
