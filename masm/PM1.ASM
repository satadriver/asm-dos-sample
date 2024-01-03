.386p
gdtseg segment para use16
gdtlimit dw gdtlen-1
gdtbase dd 0
gdt0 dq 0
gdt1 dq  00009a000000ffffh
gdt2 dq  00409e000000ffffh
gdt3 dq  0040fa000000ffffh
gdt4 dq  004098000000ffffh  ;32b
gdt5 dq 0
gdt6 dq 0
gdt7 dq 0
gdt8 dq 0
gdt9 dq 0
gdt10 dq 0
gdt11 dq  0040f20a0000ffffh
gdt12 dq  0
gdt13 dq 0
gdt14 dq 0
gdt15 dq 000092000000ffffh

gdt16 dq  0000e90000000068h ;注意TSS段的长度为68H    特权为3

GDT17 DQ  0040920000000200H
GDT18 DQ  0040B20000000200H  ;esp1 dpl=1
GDT19 DQ  0040D20000000200H  ;esp2 dpl=2
gdt20   dq   0040f20000000200h ;esp3  dpl=3

gdt21 dq     0000ec0000200000h ;callgate dpl=3,why??? gate descriptor is 32b or 16b?
gdtlen=$-gdt0
gdtseg ends

tssseg segment para use16
dd 0
dd 200h
ss0 dd 88h
dd 200h
ss1 dd 91h
dd 200h
ss2 dd 9ah
dd 18 dup (0)
dw 0
dw $+2
db 0ffh
tssseg ends


code1 segment para use16
assume cs:code1
mov ax,80h
ltr ax ;??

db 09ah
dw 0
dw 10h

toreal:
MOV AX,78H
MOV DS,AX
MOV ES,AX
MOV FS,AX
MOV GS,AX
mov ss,ax
mov eax,cr0
and al,0feh
mov cr0,eAX
db 9ah
dw offset real
dw code0
code1 ends

code2 segment para use32  ;本段的唯一作用在于RETF指令，因为堆栈切换必须为32位，32位堆栈RETF指令弹出返回为32位，所以专门安排一个32位段
assume cs:code2
MOV AX,58H
MOV DS,AX
MOV ES,AX
MOV FS,AX
MOV GS,AX

MOV AX,88H
MOV SS,AX
MOV AX,200H
MOV SP,AX

mov eax,0a3H  ;返回的堆栈特权为3 
PUSH eAX
MOV eAX,200H
PUSH eAX
MOV eAX,1bH   ;返回的堆栈特权为3 
PUSH eAX
MOV eAX,0
PUSH eAX
retf
code2 ends


code3 segment para use32  ;PARA伪指令在于偏移地址为0，作用在于装载选择子时无须考虑偏移地址更方便
assume cs:code3
mov di,0
mov al,0
mov cx,0ffffh
l0:stosb
inc al
loop l0
mov ax,0ffffh
l1:
mov cx,0ffffh
l2:
dec cx
cmp cx,0
jnz l2
dec ax
cmp ax,0
jnz l1
db 9ah
dw 0
dw 0
dw 0a8h
code3 ends  ;本段特权为3，故不能直接直接返回，而要通过调用门先回到特权0，即代码CODE4

code4 segment para use32
assume cs:code4
db 9ah
dw offset toreal
dw 0
dw 8
code4 ends

stack0 segment para use16
db 200h dup (0)
stack0 ends
stack1 segment para use16
db 200h dup (0)
stack1 ends
stack2 segment para use16
db 200h dup (0)
stack2 ends
stack3 segment para use16
db 200h dup (0)
stack3 ends

code0 segment para use16
assume cs:code0
start:
mov ax,gdtseg
mov ds,ax

xor eax,eax
mov ax,tssseg
shl eax,4
mov word ptr ds:[gdt16+2],ax
shr eax,16
mov byte ptr ds:[gdt16+4],al
mov byte ptr ds:[gdt16+7],ah

xor eax,eax
mov ax,stack0
shl eax,4
mov word ptr ds:[gdt17+2],ax
shr eax,16
mov byte ptr ds:[gdt17+4],al

xor eax,eax
mov ax,stack1
shl eax,4
mov word ptr ds:[GDT18+2],ax
SHR EAX,16
MOV BYTE PTR DS:[GDT18+4],AL

xor eax,eax
mov ax,stack2
shl eax,4
mov word ptr ds:[GDT19+2],ax
SHR EAX,16
MOV BYTE PTR DS:[GDT19+4],AL

xor eax,eax
mov ax,stack3
shl eax,4
mov word ptr ds:[GDT20+2],ax
SHR EAX,16
MOV BYTE PTR DS:[GDT20+4],AL

xor eax,eax
mov ax,code1
shl eax,4
mov word ptr ds:[gdt1+2],ax
shr eax,16
mov byte ptr ds:[gdt1+4],al
mov byte ptr ds:[gdt1+7],ah
xor eax,eax

mov ax ,code2
shl eax,4
mov word ptr ds:[gdt2+2],ax
shr eax,16
mov byte ptr ds:[gdt2+4],al
mov byte ptr ds:[gdt2+7],ah


mov ax ,code3
shl eax,4
mov word ptr ds:[gdt3+2],ax
shr eax,16
mov byte ptr ds:[gdt3+4],al
mov byte ptr ds:[gdt3+7],ah

mov ax ,code4
shl eax,4
mov word ptr ds:[gdt4+2],ax
shr eax,16
mov byte ptr ds:[gdt4+4],al
mov byte ptr ds:[gdt4+7],ah

xor eax,eax
mov ax,offset gdt0
xor ebx,ebx
mov bx,gdtseg
shl ebx,4
add eax,ebx
mov dword ptr ds:[gdtbase],eax

cli
mov ax,13h
int 10h
lgdt qword ptr ds:[gdtlimit]
mov al,2
out 92h,al
mov eax,cr0
or al,1
mov cr0,eax
db 09ah
dw 0
dw 8

real:
mov ax,code3
mov ss,ax

mov ax,3
int 10h
mov ah,4ch
int 21h
code0 ends
end start
