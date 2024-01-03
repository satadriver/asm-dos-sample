.386p
clock segment para use16
assume cs:clock
start:
JMP MAIN
align 16
gdt0 dq 0
gdt1 dq 000098000000ffffh ;code1
gdt2 dq 004098000000ffffh ;code2
gdt3 dq 004092000000ffffh ;fs gs
gdt4 dq 004092050000ffffh ;ds
gdt5 dq 00cf92000000ffffh ;es
gdt6 dq 004092400000ffffh ;ss
gdt7 dq 000092000000ffffh ;normal
gdtlimit dw 3fh
gdtbase dd 0
bitmap db 'demo.bmp',00
handle dw 0
bmphead db 36h dup (0)
colortable db 400h dup (0)
kbdbuf db 20h dup (0)
vesabuf db 100h dup (0)
counter dd 0
bmpseg dw 5000h
stackptr dd 0
xpos dd 200
ypos dd 200
prevpos dd 0
variablex dd 1
variabley dd 1
cover21h db 0
civer0a1h db 0



MAIN:
showbitmap:
call near ptr init
call near ptr setcolor
mov al,2
out 92h,al
mov ax,ss
shl eax,16
mov ax,sp
mov ds:[stackptr],eax
cli
lgdt qword ptr ds:[gdtlimit]
mov eax,cr0
or al,1
mov cr0,eax
db 0eah
dw 0
dw 8
dosmode:
mov ax,clock
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[stackptr]
mov ax,4f02h
mov bx,3
int 10h
mov ah,4ch
int 21h





init proc near
mov ax,clock
mov ds,ax
mov es,ax
mov ax,3d00h
mov dx,offset bitmap
int 21h
mov ds:[handle],ax
mov bx,ax
mov ax,3f00h
mov cx,0436h
mov dx,offset bmphead
int 21h

XOR EAX,EAX
mov ax,ds:[bmpseg]
mov ds,ax
shl eax,4
mov word ptr es:[gdt3+2],ax
shr eax,16
mov byte ptr es:[gdt3+4],al

;xor eax,eax
;mov ax,ds:[bmpseg]
;shl eax,4
;mov word ptr es:[gdt4+2],ax
;shr eax,16
;mov byte ptr es:[gdt4+4],al

mov ax,ds
mov es,ax
mov ax,3f00h
mov cx,0fa00h
mov dx,0
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
mov ah,es:[di]
xchg ah,al
mov ds:[si],al
mov es:[di],ah
inc si
inc di
loop exchg0
pop di
sub di,320
pop si
add si,320
pop cx
loop exchg1

mov ax,4f02h
mov bx,105h
int 10h
mov ax,4f06h
mov bx,0
mov cx,1024
int 10h
mov ax,clock
mov es,ax
mov ds,ax
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
mov ax,clock
shl eax,4
push eax
mov word ptr  ds:[gdt3+2],ax
shr eax,16
mov byte ptr ds:[gdt3+4],al
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
retn
init endp



setcolor proc near
mov al,0
mov dx,3c8h
out dx,al
mov dx,3c9h
mov si,offset colortable
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
clock ends





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
jmp far ptr dosmode
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
mov ax,0FFFFh
out 40h,al
xchg ah,al
out 40h,al

circle:
in al,64h
test al,1
jz next0
in al,60h
cmp al,1
jz toquit
next0:
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

MOV ECX,20
waittime:
mov al,0
out 43h,al
in al,40h
cmp al,1  ;WHY THERE USE 0 IS MORE SPEEDY?????
jnz waittime
LOOP WAITTIME

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
db 0eah
dw offset todosmode
dw 0
dw 8
code2 ends
end start