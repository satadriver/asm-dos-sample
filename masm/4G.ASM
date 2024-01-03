.386p
code segment para use16
assume cs:code
start:
mov ax,4f02h
mov bx,101h
int 10h
mov ax,4f06h
mov bx,0
mov cx,640
int 10h
mov ax,code
mov ds,ax
MOV ES,AX
mov AX,4F01H
MOV DI,1000H
MOV CX,101H
INT 10H
MOV EAX,ES:[1040]
MOV DWORD PTR CS:[BASE],EAX
MOV WORD PTR CS:[GDT1+2],AX
SHR EAX,16
MOV BYTE PTR CS:[GDT1+4],AL
MOV BYTE PTR CS:[GDT1+7],AH


mov eax,0
mov ax,code
shl eax,4
mov ebx,0
mov bx,offset gdt0
add eax,ebx
mov dword ptr cs:[gdtbase],eax
lgdt qword ptr cs:[gdtlen]
cli
in al,0eeh
mov eax,cr0
or al,1
mov cr0,eax
mov bx,8
mov es,bx
and al,0feh
mov cr0,eax


mov ax,3d00h
mov dx,offset bmpname
int 21h
mov bx,AX
MOV AX,4200H
MOV CX,0
MOV DX,36H
INT 21H

mov ax,6000h
mov ds,ax
MOV BP,1

SHOW:
PUSH BX
MOV AX,3F00H
MOV CX,0FFFFH
MOV DX,0
int 21h

mov si,0
mov di,0
mov cx,0ffffh
rep movsb

MOV AX,4F05H
MOV BX,0
MOV DX,BP
INT 10H
INC BP
CMP BP,6
JZ QUIT
POP BX
JMP SHOW

QUIT:
mov ah,0
int 16h
mov ax,3
int 10h
mov ah,4ch
int 21h

BASE DD 0
bmpname db 'f:\asm\bmp\1.bmp',00

gdtlen dw 01fh
gdtbase dd 0
gdt0 dq 0
gdt1 dq 0d0cf92000000ffffh  ;greater than 1M you must make D=1,top point=4G
gdt2 dq 00cf92000000ffffh
gdt3 dq 000098000000ffffh
code ends
end start