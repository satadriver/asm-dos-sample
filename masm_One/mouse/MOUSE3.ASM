.386p
stack segment stack
db 400h dup (0)
stack ends

mouse segment para use16
assume cs:mouse

jmp main
align 16
gdt0 dq 0
gdt1 dq 000098000000ffffh ;code1  segment descripter
gdt2 dq 004098000000ffffh ;code2  segment descripter
gdt3 dq 00cf92000000ffffh ;data   segment  descripter
gdt4 dq 00cf92000000ffffh ;vesa   video buffer start address
gdt5 dq 10cf92000000ffffh ;buffer descripter
gdt6 dq 000092000000ffffh ;normal descripter
gdtend=$-gdt0
align 10h
gdtlimit                dw gdtend-1
gdtbase                 dd 0

counter                 db 0
mousestatus             db 0
deltaX                  db 0
deltaY                  db 0

mousex                  dw 0
                        dw 0
mousey                  dw 0
                        dw 0
scanline                dw 0
                        dw 0
currentPOS              dw 0
currentposVESA          DD 0

mouseflag               dw 1720h
coveredCHAR             dw 0
mousecolor              db 0cch
mouseseg                dw 5000h

mousebmp                db 'finger.bmp',0 ;random 32x32x8 bitmap
mousebmpvesa            db 'mouse7.bmp',0 ;random 64x64x8 bitmap
mousebmpvesa4           db '1.bmp',0

bmphead                 db 36h dup (0)
colortable              db 400h dup (0)
bmpdata                 db 1024 dup (0)
buffer                  db 1024 dup (0)

bmpheadVESA             db 36h dup (0)
colortableVESA          db 400h dup (0)
bmpdataVESA             db 4096 dup (0)

bmpheadVESA4            db 36h dup (0)
bmpdataVESA4            db 4096 dup (0)
bufferVESA              db 4096 dup (0)

videomode               dw 0
stackptr                dd 0
videomodeflag           dd 0
old_mouse_int_ip        dw 0
old_mouse_int_cs        dw 0
vesainfo                db 100h dup (0)

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
mov al,byte ptr cs:[si]
inc al
mov byte ptr cs:[si],al
push ax
add si,ax
in al,60h
mov byte ptr cs:[si],al
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
call mousemode3
jmp return
mode13h:
call mousemode13h
jmp return
modevesa:
cmp word ptr ds:[videomode],112h
jz bit32
cmp word ptr ds:[videomode],115h
jz bit32
cmp word ptr ds:[videomode],118h
jz bit32
cmp word ptr ds:[videomode],11bh
jz bit32
mov dword ptr ds:[videomodeflag],0
call mousemodeVESA
jmp return
bit32:
mov dword ptr ds:[videomodeflag],1
call mousemodeVESA
jmp return

mousemode3 proc near
mov ax,0b800h
mov es,ax
cmp word ptr cs:[currentpos],0
jz next1
mov di,cs:[currentpos]
mov ax,cs:[coveredchar] 
mov Es:[di],ax
jmp next2
next1:
mov word ptr cs:[scanline],160
next2:
mov al,ds:[deltax]
movsx ax,al
add ds:[mousex],ax
mov al,ds:[deltay]
movsx ax,al
sub ds:[mousey],ax

mov ax,ds:[mousey]
shr ax,4
mov bx,ds:[scanline]
mul bx
mov bx,ds:[mousex]
shr bx,2
add ax,bx
and ax,0fffeh
mov ds:[currentpos],ax
mov di,ax
push word ptr es:[di]
pop word ptr cs:[coveredCHAR]

push word ptr cs:[mouseflag]
pop word ptr  es:[di]
ret
mousemode3 endp



mousemode13h proc near
mov ax,cs
mov ds,ax
mov ax,0a000h
mov es,ax
cmp word ptr cs:[currentpos],0
jz first_switch_13h

mov si,offset buffer
mov di,cs:[currentpos]
call restore
jmp not_first_13h

first_switch_13h:
mov cs:[scanline],320
;call setcolor                ;why not set colortable???
not_first_13h:
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
call save_32x32x8

mov di,cs:[currentpos]
mov si,offset bmpdata
call showmousebmp
test byte ptr ds:[mousestatus],1
jz to_mode13h_ret
mov di,cs:[currentpos]
sub di,cs:[scanline]
mov al,cs:[mousecolor]
stosb
to_mode13h_ret:
ret
mousemode13h endp



showmousebmp proc near
mov cx,32
show_line_32x32x8:
push cx
push di
mov cx,32
show_32x32x8:
lodsb
cmp al,0FFH
jz andpix_white
not byte ptr es:[di]
inc di
jmp nextpix
andpix_white:
and AL,BYTE PTR ES:[DI]
stosb
nextpix:
loop show_32x32x8
pop di
add di,320
pop cx
loop show_line_32x32x8
ret
showmousebmp endp



save_32x32x8 proc near
mov cx,32
save_line_32x32x8:
push cx
push di
mov cx,32
save_byte_32x32x8:
mov al,es:[di]
mov ds:[si],al
inc si
inc di
loop save_byte_32x32x8
pop di
add di,320
pop cx
loop save_line_32x32x8
ret
save_32x32x8 endp



restore proc near
mov cx,32
res_line_32x32x8:
push cx
push di
mov cx,32
rep movsb
pop di
add di,320
pop cx
loop res_line_32x32x8
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

mov ax,ss
shl eax,16
mov ax,sp
mov ds:[stackptr],eax
lgdt qword ptr ds:[gdtlimit]
mov al,2
out 92h,al
cli
mov eax,cr0
or al,1
mov cr0,eax
db 0eah
dw 0
dw 8
dosmode:
mov ax,mouse
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
iret
mouselenth dw $
mouse ends




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
code1lenth dw $
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
mov esp,10000h
cmp Dword ptr ds:[currentposVESA],0
jz first_switch_vesa

xor esi,esi
mov si,offset bufferVESA
mov Edi,ds:[currentposVESA]
cmp dword ptr ds:[videomodeflag],1
jz bitbmp_32bit_1
call restoreVESA
jmp first_switch_vesa
bitbmp_32bit_1:
call restorevesa4

first_switch_vesa:
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
cmp dword ptr ds:[videomodeflag],1
jnz not32bit
shl eax,2                             ;why need to shl 2 bit??? 32bit 
not32bit:
mov ds:[currentposVESA],Eax

mov Edi,ds:[currentposVESA]
xor esi,esi
mov si,offset buffervesa
cmp dword ptr ds:[videomodeflag],1
jz bitbmp_32bit_2
call saveVESA
jmp arrow_1
bitbmp_32bit_2:
call saveVESA4

arrow_1:
xor esi,esi
mov Edi,ds:[currentposVESA]
cmp dword ptr ds:[videomodeflag],1
jz bitbmp_32bit_3
mov si,offset bmpdataVESA
call showmouseVESA
jmp bitbmp_32bit_4
bitbmp_32bit_3:
mov si,offset bmpdataVESA4
call showmousevesa4

bitbmp_32bit_4:
test byte ptr ds:[mousestatus],1
jz back_PM16
mov Edi,ds:[currentposVESA]
MOV EAX,dword ptr DS:[SCANLINE]
SHL EAX,2
SUB EDI,EAX
mov al,ds:[mousecolor]
cmp dword ptr ds:[videomodeflag],1
jz bitbmp_32bit_5
MOV ES:[EDI],AL
jmp back_PM16
bitbmp_32bit_5:
movzx eax,al
mov es:[edi],eax
back_PM16:
db 0eah
dw offset todos
dw 0
dw 8


showmouseVESA4 proc near
mov Ecx,32
show32bit_line_32x32x32:
push Ecx
push Edi
mov Ecx,32
show32bit_32x32x32:
lodsd
stosd
loop show32bit_32x32x32
pop Edi
mov eax,dword ptr ds:[scanline]
shl eax,2
add edi,eax
pop Ecx
loop show32bit_line_32x32x32
ret
showmouseVESA4 endp



saveVESA4 proc near
mov Ecx,32
save_line_32x32x32:
push Ecx
push Edi
mov Ecx,32
save_32x32x32:
mov eax,es:[Edi]
mov ds:[Esi],eax
add esi,4
add edi,4
loop save_32x32x32
pop Edi
mov eax,dword ptr ds:[scanline]
shl eax,2
add edi,eax
pop Ecx
loop save_line_32x32x32
ret
saveVESA4 endp



restoreVESA4 proc near
mov Ecx,32
res_line_32x32x32:
push Ecx
push Edi
mov Ecx,32
rep movsd
pop Edi
mov eax,dword ptr ds:[scanline]
shl eax,2
add edi,eax
pop Ecx
loop res_line_32x32x32
ret
restoreVESA4 endp



showmouseVESA proc near
mov Ecx,64
show_line_64x64x8:
push Ecx
push Edi
mov Ecx,64
show_64x64x8:
lodsb
cmp al,0FFH
jnz notANDvesa
and AL,BYTE PTR ES:[eDI]
notANDvesa:
stosb
loop show_64x64x8
pop Edi
add edi,dword ptr ds:[scanline]
pop Ecx
loop show_line_64x64x8
ret
showmouseVESA endp



saveVESA proc near
mov Ecx,64
save_line_64x64x8:
push Ecx
push Edi
mov Ecx,64
save_64x64x8:
mov al,es:[Edi]
mov ds:[Esi],al
inc Esi
inc Edi
loop save_64x64x8
pop Edi
add edi,dword ptr ds:[scanline]
pop Ecx
loop save_line_64x64x8
ret
saveVESA endp



restoreVESA proc near
mov Ecx,64
res_line_64x64x8:
push Ecx
push Edi
mov Ecx,64
rep movsb
pop Edi
add edi,dword ptr ds:[scanline]
pop Ecx
loop res_line_64x64x8
ret
restoreVESA endp
code2lenth  dd $
code2 ends











code segment para use16
assume cs:code
start:
init proc near
push ds
in al,0a1h                
or al,10h
out 0a1h,al           ;mouse interrupt mask bit number is 4 in register 0a1h,
                      ;IRQ is 0ch,interrupt vector is 74h
cli
mov ax,mouse
mov ds,ax
mov ds:[mouseseg],ax
mov ax,0
mov es,ax
mov di,74h
shl di,2
cld
push word ptr es:[di]
pop word ptr ds:[old_mouse_int_ip]
mov ax,0       ;offset mouse
stosw
push word ptr es:[di]
pop word ptr ds:[old_mouse_int_cs]
mov ax,mouse
stosw
call initmouse

sti
call readbmp_32x32x8
call readbmp_64x64x8
call readbmp_32x32x32
 
mov ax,mouse
mov es,ax
mov di,offset VESAinfo
mov ax,4f01h
mov cx,101h
int 10h
mov si,offset vESAinfo
add si,40
lodsd
mov word ptr ds:[gdt4+2],ax
shr eax,16
mov byte ptr ds:[gdt4+4],al
mov byte ptr ds:[gdt4+7],ah

xor eax,eax
mov ax,mouse
shl eax,4
mov word ptr ds:[gdt3+2],ax
shr eax,16
mov byte ptr ds:[gdt3+4],al

xor eax,eax
mov ax,mouse
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
mov ax,code2
shl eax,4
mov word ptr ds:[gdt2+2],ax
shr eax,16
mov byte ptr ds:[gdt2+4],al
mov byte ptr ds:[gdt2+7],ah

in al,0a1h
and al,0efh
out 0a1h,al
in al,21h
and al,0fbh
out 21h,al


pop es
mov ax,4a00h
mov bx,800h
int 21h

mov ax,4800h
mov bx,0c00h
int 21h

mov ax,3100h
mov dx,ds:[mouselenth]
mov ax,code1
mov es,ax
add dx,es:[code1lenth]
mov ax,code2
mov es,ax
add dx,word ptr es:[code2lenth]
add dx,15
shr dx,4
add dx,10h
inc dx
mov dx,0c00h
int 21h

;mov ax,5000h
;mov ds:[mouseseg],ax
;mov es,ax
;mov si,0
;mov di,0
;mov cx,ds:[mouselenth]
;push es
;mov ax,code1
;mov es,ax
;add cx,es:[code1lenth]
;mov ax,code2;
;add cx,word ptr es:[code2lenth]
;add cx,1000h
;pop es
;rep movsb


mov ah,4ch
int 21h
init endp





initmouse proc near
call wait_ibf_empty
mov al,0adh
out 64h,al
call wait_ibf_empty
mov al,0a8h
out 64h,al
call wait_ibf_empty
mov al,0d4h
out 64h,al

mouse_command:
call wait_ibf_empty
mov al,0f4h
out 60h,al
call wait_obf_full
in al,60h
cmp al,0fah
jnz mouse_command
call wait_ibf_empty
mov al,60h
out 64h,al
call wait_ibf_empty
mov al,47h
out 60h,al
call wait_ibf_empty
mov al,0aeh
out 64h,al
ret
initmouse endp



wait_obf_full proc near
in al,64h
test al,1
jz wait_obf_full
ret
wait_obf_full endp



wait_ibf_empty proc near
in al,64h
test al,2
jnz wait_ibf_empty
ret
wait_ibf_empty endp



readbmp_32x32x8 proc near
mov ax,3d00h
mov dx,offset mousebmp  ;32x32x8 bit
int 21h
mov bx,ax
mov ax,3f00h
mov cx,436h
mov dx,offset bmphead
int 21h
mov ax,3f00h
mov cx,1024             ;32x32=1024
mov dx,OFFSET bmpdata
int 21h
mov si,offset bmpdata
mov di,si
add di,1023
sub di,32
mov cx,16
copyline_8b:
push cx
push si
push di
mov cx,32
copy_byte_8b:
mov al,ds:[si]
mov ah,ds:[di]
xchg ah,al
mov ds:[si],al
mov ds:[di],ah
inc si
inc di
loop copy_byte_8b
pop di
pop si
add si,32
sub di,32
pop cx
loop copyline_8b
mov ax,3e00h
int 21h
ret
readbmp_32x32x8 endp





readbmp_64x64x8 proc near
mov ax,3d00h
mov dx,offset mouseBMPVESA  ;64x64x8 bit
int 21h
mov bx,ax
mov ax,3f00h
mov cx,436h
mov dx,offset bmpheadVESA
int 21h
mov ax,3f00h
mov cx,4096                   ;64x64=4096
mov dx,OFFSET bmpdataVESA
int 21h
mov si,offset bmpdataVESA
mov di,si
add di,4095
sub di,64
mov cx,32
copyVESA_line:
push cx
push si
push di
mov cx,64
copyVESA_byte:
mov al,ds:[si]
mov ah,ds:[di]
xchg ah,al
mov ds:[si],al
mov ds:[di],ah
inc si
inc di
loop copyVESA_byte
pop di
pop si
add si,64
sub di,64
pop cx
loop copyVESA_line
mov ax,3e00h
int 21h
ret
readbmp_64x64x8 endp




readbmp_32x32x32 proc near
mov ax,3d00h
mov dx,offset mouseBMPVESA4  ;32x32x32 bit
int 21h
mov bx,ax
mov ax,3f00h
mov cx,36h
mov dx,offset bmpheadVESA4
int 21h
mov ax,3f00h
mov cx,4096                  ;32x32x4=4096             
mov dx,OFFSET bmpdataVESA4
int 21h
mov si,offset bmpdataVESA4
mov di,si
add di,4096
sub di,128
mov cx,16
copyVESA4_line:
push cx
push si
push di
mov cx,32
copyVESA4_byte:
mov eax,ds:[si]
mov ebx,ds:[di]
xchg eax,ebx
mov ds:[si],eax
mov ds:[di],ebx
add si,4
add di,4
loop copyVESA4_byte
pop di
pop si
add si,128
sub di,128
pop cx
loop copyVESA4_line
;MOV AX,3E00H  
;INT 21H
;need not to close handle,4ch/21h instruction will 
;close all handle which it open in
mov ax,3e00h
int 21h
ret
readbmp_32x32x32 endp
code ends


end start

