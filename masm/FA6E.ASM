.model samll
.386p
code segment para use16
assume cs:code
start:
push ds
push word ptr 0

mov ax,4f02h
mov bx,13h
int 10h
mov ax,4f06h
mov bx,0
mov cx,320
int 10h

mov eax,0
mov ax,code
shl eax,4
mov ebx,0
mov bx,offset gdt0
add eax,ebx
mov dword ptr cs:[gdtbase],eax


;lgdt qword ptr cs:[gdtlen]
cli
in al,0eeh
mov eax,cr0
or al,1
;mov cr0,eax

mov bx,8
mov es,bx

and al,0feh
;mov cr0,eax

sti
mov ax,0a000h
mov es,ax
mov ax,0f000h
mov ds,ax
mov si,0fa6eh
mov di,300H

L2:push di

push si
mov ah,0
int 16h
cmp al,1bh
jz quit
mov cl,8
mul cl
add si,ax

mov cx,8
l1:
push cx
mov cl,0
lodsb

l0:
push ax
shl al,cl
shr al,7
CMP AL,0
JZ NEXT
SHL AL,2
ADD AL,1

NEXT:
stosb
pop ax
inc cl
cmp cl,8
jnz l0

add di,632;CHARWIDTH
pop cx
loop l1
pop si
pop di
add di,10
jmp L2

quit:
mov ax,3
int 10h
mov ah,4ch
int 21h

;CHARWIDTH DW 632
gdtlen dw 01fh
gdtbase dd 0
gdt0 dq 0
gdt1 dq 0c08f92000000ffffh  ;greater than 1M you must make D=1,top point=4G
gdt2 dq 0000920fa6effffh
code ends
end start
