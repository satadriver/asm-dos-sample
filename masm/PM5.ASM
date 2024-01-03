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

code1 segment para use16
assume cs:code1
mov ax,30h
ltr ax
db 09ah
dw 0
dw 20h
code1 ends

code4 segment para use32
assume cs:code4
mov ax,38h
mov ss,ax
mov eax,100h
mov esp,eax   ;push instruction generate the esp smaller not greater
mov eax,53h   ;caution here!!;;;;;;;;;;;;;;;;;;;;;;
push eax
mov eax,100h
push eax
mov eax,13h   ;caution here!!;;;;;;;;;;;;;;;;;;;;;;;
push eax
mov eax,0
push eax
retf
code4 ends

code2 segment para use32
assume cs:code2
mov ax,58h
mov ds,ax
mov es,ax
mov edi,0
mov ecx,0ffffh
mov bl,1
l0:
mov [edi],bl
inc di
add bl,4
loop l0
mov ax,0ffffh
l1:
mov cx,0ffffh
l2:dec cx
cmp cx,0
jnz l2
dec ax
cmp ax,0
jnz l1
db 09ah
dw 0
dw 0
dw 68h
code2 ends

code5 segment para use32
assume cs:code5
mov ax,58h
mov ds,ax
mov es,ax
mov esi,0
mov ecx,07fffh
mov ax,4h
l3:mov [esi],ax
add esi,2
loop l3

db 09ah
dw 0
dw 0
dw 18h
code5 ends

code3 segment para use16
assume cs:code3
mov eax,cr0
and eax,0fffffffeh
mov cr0,EAX
DB 0EAH
DW OFFSET MAIN2
DW SEG MAIN2
MAIN2:
mov AX,3
INT 10H
MOV AH,4CH
INT 21H                                            
CODE3 ENDS

gdtseg segment para use16
gdtlen dw gdtend-1
gdtbase dd 0
gdt0 dq 0
gdt1 dq 000098000000ffffh
gdt2 dq 0040f8000000ffffh;;;;;;;;;;;
gdt3 dq 000098000000ffffh;;;;;;;;;;;
gdt4 dq 004098000000ffffh
gdt5 dq 004098000000ffffh;1-5 code selector
gdt6 dq 0000890000000068h;task state segment;;;;;;;;;;          
gdt7 dq 0040920000000fffh;7-10 stack segment
gdt8 dq 0040b20000000fffh
gdt9 dq 0040d20000000fffh
gdt10 dq 0040f20000000fffh
gdt11 dq 0000f20a0000ffffh;video buffer;;;;;;;;;;;;;;;;;
gdt12 dq 0000f20b8000ffffh;text buffer
gdt13 dq 0000ec0000280000h;callgate
gdtend=$-gdt0
gdtseg ends

tssseg segment para use16
dd 0
dd 100h    
dd 38h
dd 100h
dd 41h
dd 100h
dd 4ah
dd 18 dup (0)
dw 0
dw $+2
dd 0ffh
tssseg ends

code0 segment para use16
assume cs:code0
start:
xor eax,eax
mov ax,gdtseg
mov ds,ax
shl eax,4
xor esi,esi
mov si,offset gdt0
add eax,esi
mov dword ptr ds:[gdtbase],eax

xor eax,eax
mov ax,tssseg
shl eax,4
mov word ptr ds:[gdt6+2],ax
shr eax,16
mov byte ptr ds:[gdt6+4],al

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
mov word ptr ds:[gdt7+2],ax
shr eax,16
mov byte ptr ds:[gdt7+4],al

xor eax,eax
mov ax,stack1
shl eax,4
mov word ptr ds:[gdt8+2],ax
shr eax,16
mov byte ptr ds:[gdt8+4],al

xor eax,eax
mov ax,stack2
shl eax,4
mov word ptr ds:[gdt9+2],ax
shr eax,16
mov byte ptr ds:[gdt9+4],al

xor eax,eax
mov ax,stack3
shl eax,4
mov word ptr ds:[gdt10+2],ax
shr eax,16
mov byte ptr ds:[gdt10+4],al

mov ax,13h
int 10h
lgdt qword ptr ds:[gdtlen]
cli
mov al,2
out 92h,al
mov eax,cr0
or eax,1
mov cr0,eax
db 09ah
dw 0
dw 8
code0 ends
end start
