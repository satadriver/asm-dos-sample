.386p
mouse segment para use16
assume cs:mouse
jmp main

align 16
gdt0 dq 0
gdt1 dq 000098000000ffffh
gdt2 dq 004098000000ffffh
gdt3 dq 004092050000ffffh ;data seg
gdt4 dq 0d0cf92000000ffffh
gdt5 dq 104092000000ffffh
gdt6 dq 000092000000ffffh
gdtlimit dw 3fh
gdtbase dd 0
counter db 0
mousestatus db 0
deltaX db 0
deltaY db 0
mousex dw 0
dw 0
mousey dw 0
dw 0
scanline dw 0
dw 0
currentPOS dw 0
mouseflag dw 0ffdbh
coveredCHAR dw 0
mousecolor db 0cch
mouseseg dw 5000h
mousebmp db 'finger.bmp',0 ;random 32x32x8 bitmap
bmphead db 36h dup (0)
colortable db 400h dup (0)
bmpdata db 1024 dup (0)
buffer db 1024 dup (0)
mousebmpvesa db 'mouse7.bmp',0 ;random 64x64x8 bitmap
bmpheadVESA db 36h dup (0)
colortableVESA db 400h dup (0)
bmpdataVESA db 4096 dup (0)
bufferVESA db 4096 dup (0)
currentposVESA DD 0
videomode dw 0
stackptr dd 0


main:
pushad
push ds
push es
push fs
push gs
cld
mov ax,cs
mov ds,ax
xor ax,ax
mov si,offset counter
mov al,cs:[si]
inc al
mov cs:[si],al
push ax
add si,ax
in al,60h
mov cs:[si],al
pop ax
cmp al,3
jz showmouse
jmp return

showmouse:
mov byte ptr cs:[counter],0
mov ax,4f03h
int 10h
mov cs:[videomode],bx
cmp bx,3
jz mode3
cmp bx,13h
jz mode13h
jmp modeVESA

mode3:
jmp mousemode3
mode13h:
jmp mousemode13h
modevesa:
jmp mousemodeVESA

mousemode3 proc near
mov ax,0b800h
mov es,ax
cmp word ptr cs:[currentpos],0
jz next1
mov ax,cs:[coveredchar] 
mov Es:[currentpos],ax
jmp next2
next1:
mov word ptr cs:[scanline],160
next2:
test byte ptr ds:[mousestatus],10h
jnz left
test byte ptr ds:[mousestatus],20h
jnz rightdown

rightup:
shr byte ptr ds:[deltaX],4
shr byte ptr ds:[deltay],4
mov al,ds:[deltax]
movzx ax,al
add ds:[mousex],ax
mov al,ds:[deltay]
movzx ax,al
sub ds:[mousey],ax
jmp next
rightdown:
neg byte ptr ds:[deltay]
shr byte ptr ds:[deltax],4
shr byte ptr ds:[deltay],4
mov al,ds:[deltax]
movzx ax,al
add ds:[mousex],ax
mov al,ds:[deltay]
movzx ax,al
add ds:[mousey],ax

left:
test byte ptr ds:[mousestatus],20h
jnz leftdown
leftup:
neg byte ptr ds:[deltax]
shr byte ptr ds:[deltax],4
shr byte ptr ds:[deltay],4
mov al,ds:[deltax]
movzx ax,al
sub ds:[mousex],ax
mov al,ds:[deltay]
movzx ax,al
sub ds:[mousey],ax

leftdown:
neg byte ptr ds:[deltax]
neg byte ptr ds:[deltay]
shr byte ptr ds:[deltax],4
shr byte ptr ds:[deltay],4
mov al,cs:[deltaX]
movzx ax,al
sub cs:[mousex],ax
mov al,cs:[deltaY]
movzx ax,al
add cs:[mousey],ax
next:
mov ax,cs:[mousey]
mov bx,cs:[scanline]
mul bx
add ax,cs:[mousex]
mov cs:[currentpos],ax
push word ptr es:[currentpos]
pop word ptr cs:[coveredCHAR]
mov ax,cs:[mouseflag]
mov es:[currentpos],ax
jmp return
mousemode3 endp



mousemode13h proc near
mov ax,0a000h
mov es,ax
cmp word ptr cs:[currentpos],0
jz next3

mov si,offset buffer
mov di,cs:[currentpos]
call restore
jmp next4

next3:
mov cs:[scanline],320
;call setcolor ;why not set colortable???
next4:
mov al,cs:[DELTAX]
movsx ax,al
add cs:[mousex],ax
mov al,cs:[deltaY]
movsx ax,al
sub cs:[mousey],ax
mov ax,cs:[mousey]
mov bx,cs:[scanline]
mul bx
add ax,cs:[mousex]
mov cs:[currentpos],ax

mov di,cs:[currentpos]
mov si,offset buffer
call save

mov di,cs:[currentpos]
mov si,offset bmpdata
call showmousebmp
test byte ptr ds:[mousestatus],1
jz toreturn0
mov di,ds:[currentpos]
sub di,320
mov al,ds:[mousecolor]
stosb
toreturn0:
jmp return
mousemode13h endp

showmousebmp proc near
mov cx,32
copy5:
push cx
push di
mov cx,32
copy6:
lodsb
cmp al,0FFH
jz andpix
not byte ptr es:[di]
inc di
jmp nextpix
andpix:
and AL,BYTE PTR ES:[DI]
stosb
nextpix:
loop copy6
pop di
add di,320
pop cx
loop copy5
ret
showmousebmp endp

save proc near
mov cx,32
copy2:
push cx
push di
mov cx,32
copy3:
mov al,es:[di]
mov ds:[si],al
inc si
inc di
loop copy3
pop di
add di,320
pop cx
loop copy2
ret
save endp

restore proc near
mov cx,32
copy4:
push cx
push di
mov cx,32
rep movsb
pop di
add di,320
pop cx
loop copy4
ret
restore endp

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


mousemodeVESA proc near
mov ax,4f06h
mov bx,1
int 10h
mov ds:[scanline],cx
xor eax,eax
mov ax,ds
shl eax,4
xor ebx,ebx
mov bx,offset gdt0
add eax,ebx
mov ds:[gdtbase],eax

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

mov ax,ss
shl eax,16
mov ax,sp
mov ds:[stackptr],eax
lgdt qword ptr ds:[gdtlimit]
mov al,2
out 92h,al
mov eax,cr0
or al,1
mov cr0,eax
db 0eah
dw 0
dw 8
dosmode:
mov ax,5000h
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[stackptr]
jmp return
mousemodeVESA endp



return:
mov al,20h
out 0a0h,al
out 20h,al
pop gs
pop fs
pop es
pop ds
popad 
sti
iret


code1 segment para use16
assume cs:code1
db 0eah
dw 0
dw 10h
todos:
mov ax,30h
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


code2 segment para  use32
assume cs:code2
mov ax,18h
mov ds,ax
mov ax,20h
mov es,ax
mov ax,28h
mov fs,ax
mov gs,ax
mov ss,ax
mov esp,1000h
cmp Dword ptr ds:[currentposVESA],0
jz next6

xor esi,esi
mov si,offset bufferVESA
mov Edi,ds:[currentposVESA]
call restoreVESA

next6:
mov al,ds:[DELTAX]
movsx ax,al
add ds:[mousex],ax
mov al,ds:[deltaY]
movsx ax,al
sub ds:[mousey],ax
mov eax,dword ptr ds:[mousey]
mov ebx,dword ptr ds:[scanline]
mul ebx
add eax,dword ptr ds:[mousex]
mov ds:[currentposVESA],Eax

mov Edi,ds:[currentposVESA]
xor esi,esi
mov si,offset buffervesa
call saveVESA

mov Edi,ds:[currentposVESA]
xor esi,esi
mov si,offset bmpdataVESA
call showmouseVESA

test byte ptr ds:[mousestatus],1
jz toreturn1
mov Edi,ds:[currentposVESA]
sub edi,dword ptr DS:[SCANLINE]
mov al,ds:[mousecolor]
MOV ES:[EDI],AL

toreturn1:
db 0eah
dw offset todos
dw 0
dw 8

showmouseVESA proc near
mov Ecx,64
copy10:
push Ecx
push Edi
mov Ecx,64
copy11:
lodsb
cmp al,0FFH
jnz notANDvesa
and AL,BYTE PTR ES:[eDI]
notANDvesa:
stosb
loop copy11
pop Edi
add edi,dword ptr ds:[scanline]
pop Ecx
loop copy10
ret
showmouseVESA endp

saveVESA proc near
mov Ecx,64
copy12:
push Ecx
push Edi
mov Ecx,64
copy13:
mov al,es:[Edi]
mov ds:[Esi],al
inc Esi
inc Edi
loop copy13
pop Edi
add edi,dword ptr ds:[scanline]
pop Ecx
loop copy12
ret
saveVESA endp

restoreVESA proc near
mov Ecx,64
copy14:
push Ecx
push Edi
mov Ecx,64
rep movsb
pop Edi
add edi,dword ptr ds:[scanline]
pop Ecx
loop copy14
ret
restoreVESA endp
code2 ends
mouselenth dw $
mouse ends




code segment para use16
assume cs:code
start:
mov ax,mouse
mov ds,ax
mov ax,3d00h
mov dx,offset mousebmp
int 21h
mov bx,ax
mov ax,3f00h
mov cx,436h
mov dx,offset bmphead
int 21h
mov ax,3f00h
mov cx,1024
mov dx,OFFSET bmpdata
int 21h

mov si,offset bmpdata
mov di,si
add di,1023
sub di,32
mov cx,16
copy0:
push cx
push si
push di
mov cx,32
copy1:
mov al,ds:[si]
mov ah,ds:[di]
xchg ah,al
mov ds:[si],al
mov ds:[di],ah
inc si
inc di
loop copy1
pop di
pop si
add si,32
sub di,32
pop cx
loop copy0
MOV AX,3E00H
INT 21H


mov ax,3d00h
mov dx,offset mouseBMPVESA
int 21h
mov bx,ax
mov ax,3f00h
mov cx,436h
mov dx,offset bmpheadVESA
int 21h
mov ax,3f00h
mov cx,4096
mov dx,OFFSET bmpdataVESA
int 21h

mov si,offset bmpdataVESA
mov di,si
add di,4095
sub di,64
mov cx,32
copyVESA0:
push cx
push si
push di
mov cx,64
copyVESA1:
mov al,ds:[si]
mov ah,ds:[di]
xchg ah,al
mov ds:[si],al
mov ds:[di],ah
inc si
inc di
loop copyVESA1
pop di
pop si
add si,64
sub di,64
pop cx
loop copyVESA0
MOV AX,3E00H
INT 21H

mov al,0ffh
out 21h,al
out 0a1h,al
cli
cld
mov ax,0
mov es,ax
mov di,1d0h
stosw
mov ax,ds:[mouseseg]
stosw

mov si,0
mov ax,ds:[mouseseg]
mov es,ax
mov di,0
mov cx,ds:[mouselenth]
rep movsb
call initmouse
mov al,0
out 21h,al
out 0a1h,al
sti
mov ah,4ch
int 21h


initmouse proc near
l1:
in al,64h
test al,2
jnz l1
mov al,0adh
out 64h,al
l2:
in al,64h
test al,2
jnz l2
mov al,0a8h
out 64h,al
l3:
in al,64h
test al,2
jnz l3
mov al,0d4h
out 64h,al
l4:in al,64
test al,2
jnz l4
l6:
mov al,0f4h
out 60h,al
l5:
in al,64h
test al,1
jz l5
in al,60h
cmp al,0fah
jnz l6
l7:
in al,64h
test al,2
jnz l7
mov al,60h
out 64h,al
l8:
in al,64h
test al,2
jnz l8
mov al,47h
out 60h,al
l9:
in al,64h
test al,2
jnz l9
mov al,0aeh
out 64h,al
ret
initmouse endp
code ends
end start



















