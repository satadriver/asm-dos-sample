.386p

stack segment stack para use16
db 100h dup (0)
stack ends


clock segment page use16
assume cs:clock

JMP MAIN
align 16
gdt0 dq 0
gdt1 dq 000098000000ffffh ;code1
gdt2 dq 004098000000ffffh ;code2
gdt3 dq 004092000000ffffh ;fs,gs
gdt4 dq 004092000000ffffh ;ds
gdt5 dq 00cf92000000ffffh ;es
gdt6 dq 004092400000ffffh ;ss
gdt7 dq 000092000000ffffh ;normal
gdt8 dq 000092000000ffffh ;code1
gdtend=$-gdt0
gdtlimit 	dw gdtend-1
gdtbase 	dd 0
bitmap 		db 'demo.bmp',00
handle 		dw 0
bmphead 	db 36h dup (0)
colortable 	db 400h dup (0)
kbdbuf 		db 20h dup (0)
vesabuf 	db 100h dup (0)
counter 	dd 0
bmpseg 		dw 5000h
procseg 	dw 2000h
stackptr 	dd 0
xpos 		dd 200
ypos 		dd 200
variablex 	dd 1
variabley 	dd 1
prevpos 	dd 0
oldseg 		dw 0
oldip 		dw 0
cover 		db 0
lastkey 	db 0
portB 		db 0
retaddr 	dd 0  ;used for jmp dword ptr ds:[retaddr]
msg0 		db 'U will get somewhat interesting...',0ah,0dh,24h
msg1 		db 'Not found file,press any key to quit...',0ah,0dh,24h


MAIN PROC NEAR
pushad
push ds
push es
push ss
push fs
push gs
mov ax,40h
mov ds,ax
mov ax,cs
mov es,ax
mov si,1eh
mov di,offset kbdbuf
mov cx,20h
repz cmpsb
cmp cx,0
jnz toiret
inc dword ptr es:[counter]
cmp dword ptr es:[counter],10
jle toback
jmp showbitmap
toiret:
mov si,1eh
mov di,offset kbdbuf
mov cx,20h
rep movsb
toback:
mov al,0ch
out 70h,al
in al,71h
mov al,20h
out 20h,al
out 0a0h,al
pop gs
pop fs
pop ss
pop es
pop ds
popad
iret

showbitmap:
call init
call setcolor
mov al,2
out 92h,al
mov ax,ss
shl eax,16
mov ax,sp
mov ds:[stackptr],eax
cli
lgdt Qword ptr ds:[gdtlimit]
mov eax,cr0
or al,1
mov cr0,eax
db 0eah
dw 0
dw 8
dosmode:
mov ax,cs:[procseg] ;why can't be cs???????????
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[stackptr]
mov ax,4f02h
mov bx,3
int 10h
mov dword ptr ds:[counter],0
mov ax,40h
mov ds,ax
mov si,1eh
mov cx,20h
mov di,offset kbdbuf
rep movsb

mov ax,es
mov ds,ax
cmp byte ptr ds:[lastkey],1
jnz constantly
mov al,ds:[cover]
out 0a1h,al
mov ax,0
mov es,ax
mov di,70h
shl di,2
mov ax,ds:[oldip]
stosw
mov ax,ds:[oldseg]
stosw
mov al,0bh
out 70h,al
mov al,ds:[portB]
out 71h,al
constantly:
jmp toback
MAIN ENDP


init proc near
mov ax,cs
MOV DS,AX
MOV ES,AX
mov ax,4f02h
mov bx,105h
int 10h
mov ax,4f06h
mov bx,0
mov cx,1024
int 10h
mov di,offset vesabuf
mov ax,4f01h
mov cx,105h
int 10h
mov si,offset vesabuf
add si,40
lodsd
mov word ptr ds:[gdt5+2],ax
shr eax,16
mov byte ptr ds:[gdt5+4],al
mov byte ptr ds:[gdt5+7],ah
xor eax,eax
mov ebx,eax
mov ax,cs
shl eax,4
mov bx,offset gdt0
add eax,ebx
mov ds:[gdtbase],eax

xor eax,eax
mov ax,code1
shl eax,4
mov word ptr ds:[gdt1+2],ax
mov word ptr ds:[gdt8+2],ax
shr eax,16
mov byte ptr ds:[gdt1+4],al
mov byte ptr ds:[gdt8+4],al

xor eax,eax
mov ax,code2
shl eax,4
mov word ptr ds:[gdt2+2],ax
shr eax,16
mov byte ptr ds:[gdt2+4],al

xor eax,eax
mov ax,ds:[procseg]
shl eax,4
mov word ptr ds:[gdt3+2],ax
shr eax,16
mov byte ptr ds:[gdt3+4],al

xor eax,eax
mov ax,ds:[bmpseg]
shl eax,4
mov word ptr ds:[gdt4+2],ax
shr eax,16
mov byte ptr ds:[gdt4+4],al

mov ax,ds:[procseg]
shl eax,16
mov ax,offset dosmode
mov ds:[retaddr],eax
retn
init endp


setcolor proc near
mov al,0
mov dx,3c8h
out dx,al
mov dx,3c9h
lea si,ds:[colortable]
mov cx,100h
setpalette:
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
loop setpalette
retn
setcolor endp




code1 segment para use16
assume cs:code1
db 0eah
dw 0
dw 10h
todosmode:
mov ax,38h
mov ds,ax
mov es,ax
mov ss,ax
mov fs,ax
mov gs,ax
mov eax,cr0
and al,0feh
mov cr0,eax
;jmp far ptr dosmode
;push cs
;pop ds
;jmp dword ptr ds:[retaddr]
db 0eah
dw offset dosmode
seg2000h dw 0
code1 ends



code2 segment para use32
assume cs:code2
mov ax,18h
mov fs,ax
mov gs,ax
mov ax,20h
mov ds,ax
mov ax,28h
mov es,ax
mov ax,30h
mov ss,ax
mov esp,1000h

mov al,36h
out 43h,al
mov ax,0
out 40h,al
xchg ah,al
out 40h,al

circle:
in al,64h
test al,1
jz nokey
in al,60h
mov fs:[lastkey],al
jmp toquit

nokey:
mov eax,fs:[ypos]
mov ebx,1024
mul ebx
add eax,fs:[xpos]
mov edi,eax
mov fs:[prevpos],eax
mov esi,0
mov ecx,200
copyline:
push ecx
push edi
mov ecx,80
rep movsd
pop edi
add edi,1024
pop ecx
loop copyline

cmp dword ptr fs:[xpos],703
jnz next1
mov dword ptr fs:[variablex],-1
next1:
cmp dword ptr fs:[xpos],0
jnz next2
mov dword ptr fs:[variablex],1
next2:
cmp dword ptr fs:[ypos],567
jnz next3
mov dword ptr fs:[variabley],-1
next3:
cmp dword ptr fs:[ypos],0
jnz next4
mov dword ptr fs:[variabley],1
next4:
mov eax,fs:[xpos]
add eax,fs:[variablex]
mov fs:[xpos],eax
mov eax,fs:[ypos]
add eax,fs:[variabley]
mov fs:[ypos],eax

mov ecx,0
waittime:
mov al,0
out 43h,al
in al,40h
cmp al,0
jnz waittime
inc ecx
cmp ecx,40h
jnz waittime

mov edi,fs:[prevpos]
mov ecx,200
clear:
push ecx
push edi
mov eax,0
mov ecx,80
rep stosd
pop edi
add edi,1024
pop ecx
loop clear

;jmp circle     ;IF THIS INSTRUCTION,WILL CAUSE EXCEPTION,WHY???
db 0eah
dw offset circle
dw 0
dw 10h

toquit:
push word ptr fs:[procseg]
mov ax,40h
mov gs,ax
pop word ptr gs:[seg2000h]
db 0eah
dw offset todosmode
dw 0
dw 8
code2 ends


clocklen dw $
clock ends



code segment para use16
assume cs:code
start:
cli
cld
in al,0a1h
push ax
or al,1
out 0a1h,al
mov ax,clock
mov ds,ax
mov ax,3
int 10h
mov ah,9
mov dx,offset msg0
int 21h

mov ax,0
mov es,ax
mov di,70h  ;real timer
shl di,2
mov bx,es:[di]
push bx
stosw
mov bx,es:[di]
push bx
mov ax,ds:[procseg]
stosw

mov ax,clock
mov es,ax
mov di,offset oldseg
pop ax
stosw
pop ax
stosw
pop ax
stosb

mov ax,3d00h
mov dx,offset bitmap
int 21h
jnc found
mov ah,9
mov dx,offset msg1
int 21h
mov ah,0
int 16h
jmp exit
found:
mov bx,ax
mov ds:[handle],ax
mov ax,3f00h
mov cx,0436h
mov dx,offset bmphead
int 21h
mov ax,ds:[bmpseg]
mov ds,ax
mov ax,3f00h
mov bx,es:[handle]
mov cx,0fa00h
mov dx,0
int 21h
mov ax,3e00h
int 21h

mov cx,100
mov si,0
mov di,0fa00h
sub di,320
exchg1:
push cx
push si
push di
mov cx,320
exchg0:
mov al,ds:[si]
mov ah,ds:[di]
xchg ah,al
mov ds:[si],al
mov ds:[di],ah
inc si
inc di
loop exchg0
pop di
sub di,320
pop si
add si,320
pop cx
loop exchg1

mov ax,clock
mov ds,ax
mov ax,ds:[procseg]
mov es,ax
mov di,0
mov si,0
mov cx,ds:[clocklen]  ;a segment can be included in another segment
rep movsb

mov al,0bh
out 70h,al
in al,71h
mov ds:[portB],al
or al,10h  ;circle int != refresh int!!!!!!!!!!!!!!
out 71h,al
mov al,0ch
out 0a1h,al
exit:
mov ah,4ch
int 21h
code ends


end start