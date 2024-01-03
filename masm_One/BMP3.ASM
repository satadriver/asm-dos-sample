;fdf00000-fdf7ffff  d0000000-dfffffff  fdf80000-fdfb0000
.386p
stack segment stack
db 2000h dup (0)
stack ends

data segment para use16
bmpname db 'f:\asm\bmp\2.bmp',00
bmphandle dw 0
bmpdetail dw 0
bmppage dw 0
bmppagenum dw 0

gdtlen dw 17h
gdtbase dd 0
gdt0 dq 0
gdt1 dq 0d0cf92000000ffffh
gdt2 dq 000092000000ffffh
data ends

code segment para use16
assume cs:code
start:
mov ax,4f02h
mov bx,4112h
int 10h
mov ax,4f06h
mov bx,0
mov cx,640
int 10h


in al,0eeh
cli
mov ax,stack
mov ss,ax
xor eax,eax
mov ebx,eax
mov ax,data
mov ds,ax
mov es,ax
shl eax,4
mov bx,offset gdt0
add eax,ebx
mov dword ptr ds:[gdtbase],eax
lgdt qword ptr ds:[gdtlen]

cld
mov di,offset bmphandle
mov ax,3d00h
mov dx,offset bmpname
int 21h
jc quit
mov bx,ax
stosw

mov ax,4202h
mov cx,0
mov dx,0
int 21h
stosw
mov ax,dx
stosw
mov ax,3eh
int 21h


show:
mov ax,4f02h
mov bx,4112h
int 10h
mov ax,4f06h
mov cx,640
mov bx,0
int 10h
mov ax,4f07h
mov bx,0
mov cx,0
mov dx,0
int 10h
mov ax,data
mov ds,ax
mov es,ax
mov ax,3d00h
mov dx,offset bmpname
int 21h
jc quit
mov bx,ax
mov ax,4200h
mov cx,es:[bmppage]
dec cx
cmp cx,0ffffh
jz quit
mov es:[bmppage],cx
mov dx,es:[bmpdetail]
int 21h

mov ax,2000h
mov ds,ax

mov ax,3f00h
mov cx,0ffffh
mov dx,0
int 21h

call getsegbase
mov ax,ds
mov ss,ax

mov cx,0ffffh
mov si,0
mov di,0
l0:
mov al,byte ptr ds:[si]
mov byte ptr es:[di],al
inc si
inc di
dec cx
cmp cx,0
jnz l0

clts
call retsegbase
mov ax,ds
mov ss,ax

mov ax,4f05h
mov bx,0
mov dx,es:[bmppagenum]
inc dx
mov es:[bmppagenum],dx
int 10h
jmp show

quit:
mov ax,3
int 10h
mov ah,4ch
int 21h


getsegbase proc near
push eax
push ebx
push ds
mov ax,data
mov ds,ax

lgdt qword ptr ds:[gdtlen]
mov eax,cr0
or al,1
mov cr0,eax
mov bx,8
mov es,bx
and eax,0fffffffeh
mov cr0,eax
pop ds
pop ebx
pop eax
retn
getsegbase endp

retsegbase proc near
push eax
push ebx
push ds
mov ax,data
mov ds,ax
lgdt qword ptr ds:[gdtlen]
mov eax,cr0
or al,1
mov cr0,eax
mov bx,10h
mov es,bx
and al,0feh
mov cr0,eax
pop ds
pop ebx
pop eax
retn
retsegbase endp

code ends
end start
