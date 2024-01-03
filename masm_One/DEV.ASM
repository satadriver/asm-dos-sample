.model small
.386
.data
PCIDEV DB 'e:\ASM\PCIDEV.TXT',00
.code
start:
MOV AX,@DATA
MOV DS,AX
MOV AX,3C00H
MOV CX,0
MOV DX,OFFSET PCIDEV
INT 21H
MOV SI,AX

mov ax,3
int 10h
mov ax,0b800h
mov es,ax
mov di,0

mov ebx,80000000h
l1:
cmp di,0ff0h
jb l8

PUSH EAX
PUSH EBX
PUSH ECX
PUSH EDX
PUSH DS
mov bp,0
mov cx,07ffh
MOV AX,0B800H
MOV DS,AX

l9:
push cx
MOV AX,4000H
MOV BX,SI
MOV CX,1
MOV DX,bp
INT 21H
add bp,2
pop cx
loop l9


MOV AH,0
INT 16H
MOV AX,3
INT 10H
MOV DI,0
POP DS
POP EDX
POP ECX
POP EBX
POP EAX



l8:
push ebx
mov eax,ebx
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
cmp ax,0ffffh
jz l0

PUSH EbX
add ebx,8
mov eax,ebx
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx

mov edx,eax
mov ecx,28
l4:
mov eax,edx
shr eax,cl
and al,0fh
cmp al,9
jbe l3
add al,7
l3:
add al,30h
mov ah,7
stosw
sub cl,4
cmp cl,-4
jnz l4
mov eax,07200720h
stosd

POP EdX
MOV ECX,28
L5:
MOV EAX,EDX
SHR EAX,CL
AND AL,0FH
CMP AL,9
JBE L7
ADD AL,7
L7:
ADD AL,30H
MOV AH,7
STOSW
SUB CL,4
CMP cL,-4
JNZ L5

MOV AX,DI
MOV Bl,160
DIV Bl
mov bl,160
SUB bl,ah
xor bh,bh
add di,bx

l0:
pop ebx
add ebx,100h
cmp ebx,81000000h
jae quit
jmp l1

quit:
mov ah,0
int 16h

MOV AX,0B800H
MOV DS,AX

mov cx,0a0h

mov bp,0
l10:
push cx
MOV AX,4000H
MOV BX,SI
MOV CX,1
MOV DX,bp
INT 21H
add bp,2
pop cx
loop l10

MOV Ah,3EH
INT 21H

mov AH,4CH
INT 21H
END START


