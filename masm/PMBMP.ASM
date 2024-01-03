.386p
stack segment stack  para use16
db 100h dup (0)
stack ends

data segment para use16
gdt0 dq 0
gdt1 dq 000098000000ffffh
gdt2 dq 004098000000ffffh
gdt3 dq 00cf92050000ffffh
gdt4 dq 10cf92000000ffffh
gdt5 dq 0d0cf92000000ffffh
gdt6 dq 004092800000ffffh ;stack
gdt7 dq 000092000000ffffh ;normal
gdt8 dq 004092000000ffffh ;data seg
gdtlen=$-gdt0
gdtlimit 	dw gdtlen-1
gdtbase 	dd 0
filename 	db 'f:\asm\bmp\3.bmp',0
handle 		dw 0
highpage 	dw 0
lowpage 	dw 0
fileptrlow 	dw 36h
fileptrhigh 	dw 0
bmphead 	db 36h dup (0)
colortable 	db 400h dup (0)
stackptr 	dd 0
edipos 		dd 0
msg0 		db 'not found file',24h
msg1 		db 'set videomode$'
msg2 		db 'get in pm mode$'
data ends

code segment para use16
assume cs:code

init proc near
xor eax,eax
xor ebx,ebx
mov ax,data
mov ds,ax
mov es,ax
shl eax,4
push eax
push ebx
mov word ptr ds:[gdt8+2],ax
shr eax,16
mov byte ptr ds:[gdt8+4],al
pop ebx
pop eax
mov bx,offset gdt0
add eax,ebx
mov ds:[gdtbase],eax
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
ret 
init endp




getlen proc near
mov ax,3d00h
mov dx,offset filename
int 21h
jnc next1
call notfound
next1:
mov ds:[handle],ax
mov bx,ax
mov ax,3f00h
mov cx,36h
mov dx,offset bmphead
int 21h
mov si,offset bmphead
add si,2
lodsd
sbb eax,36h
mov ds:[lowpage],ax
shr eax,16
mov ds:[highpage],ax
mov ax,3e00h
mov bx,es:[handle]
int 21h
ret
getlen endp


readfile proc near
mov ax,data
mov ds,ax
mov es,ax
mov ax,3d00h
mov dx,offset filename
int 21h
mov bx,ax
mov es:[handle],ax
mov ax,4000h
mov ds,ax
read:
cmp word ptr es:[highpage],0
jnz readblock
cmp word ptr es:[lowpage],0
jnz readdetail
call quit
readblock:
mov ax,4200h
mov bx,es:[handle]
mov cx,es:[fileptrhigh]
mov dx,es:[fileptrlow]
int 21h
mov ax,3f00h
mov bx,es:[handle]
mov cx,0ffffh
mov dx,0
int 21h
mov ax,3f00h
mov cx,1
mov dx,0ffffh
int 21h
inc word ptr es:[fileptrhigh]
dec word ptr es:[highpage]
mov ax,ds
cmp ax,8000h
jz toret
add ax,1000h
mov ds,ax
jmp read
readdetail:
mov ax,3f00h
mov cx,es:[lowpage]
mov dx,0
int 21h
mov word ptr es:[lowpage],0
mov word ptr es:[fileptrlow],ax
toret:
mov ax,3e00h
mov bx,es:[handle]
int 21h
ret
readfile endp

main proc near
call init 
call getlen
mov ax,4f02h
mov bx,101h
int 10h
mov ax,4f06h
mov bx,0
mov cx,640
int 10h
call  setcolor
loop0:
call readfile
mov ax,ss
shl eax,16
mov ax,sp
mov es:[stackptr],eax
lgdt qword ptr es:[gdtlimit]
cli
mov al,2
out 92h,al
mov eax,cr0
or eax,1
mov cr0,eax
db 09ah
dw 0
dw 8

dosmode:
mov ax,data
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[stackptr]

;lss sp,dword ptr ds:[stackptr]
jmp loop0
main endp

quit proc near
mov ah,0
int 16h
mov ax,4f02h
mov bx,3
int 10h
mov ah,4ch
int 21h
quit endp

notfound proc near
mov ax,data
mov ds,ax
mov ah,9
mov dx,offset msg0
int 21h
mov ah,0
int 16h
mov ax,3
int 10h
mov ah,4ch
int 21h
notfound endp




setcolor proc near

mov ax,data
mov ds,ax
mov es,ax
mov si,offset colortable
mov cx,100h
mov al,0
mov dx,3c8h
out dx,al

color:
mov dx,3c9h
push cx
add si,2
lodsb
shr al,2
out dx,al
sub si,2
lodsb
shr al,2
out dx,al
sub si,2
lodsb
shr al,2
out dx,al
add si,3
pop cx
loop color
ret
setcolor endp
code ends

code1 segment para use16
assume cs:code1
db 0eah
dw 0
dw 10h


todos:
mov ax,38h
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,cr0
and al,0feh
mov cr0,eax
jmp far ptr dosmode
code1 ends

code2 segment para use32
assume cs:code2
mov ax,18h
mov ds,ax
mov ax,28h
mov es,ax
mov ax,30h
mov ss,ax
mov esp,1000h
mov ax,40h
mov fs,ax

cmp word ptr fs:[highpage],0
jnz next01
cmp word ptr fs:[lowpage],0
jnz next01
cld
mov esi,0
mov edi,0
mov ecx,0ffffh
l0:
mov eax,gs:[esi]
mov es:[edi],eax
add esi,4
add edi,4
loop l0
jmp next02

next01:
mov esi,0
mov edi,fs:[edipos]
mov ecx,0ffffh
lll:
mov eax,ds:[esi]
mov gs:[edi],eax
add esi,4
add edi,4
loop lll
mov fs:[edipos],edi
next02:
db 0eah
dw offset todos
dw 0
dw 8
code2 ends



end main