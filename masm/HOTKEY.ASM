.386p
stack segment stack
db 400h dup (0)
stack ends

code segment para use16
assume cs:code
start:
cli
cld
mov al,2
out 92h,al
xor ax,ax
mov es,ax
mov ax,hotkey
mov ds,ax
mov ds:[hotkeyseg],ax

mov di,9
shl di,2
push word ptr es:[di]
pop  word ptr ds:[hotkey_ip]
mov ax,ds:[hotkeyoffset]
stosw
push word ptr es:[di]
pop  word ptr ds:[hotkey_cs]
mov ax,ds:[hotkeyseg]
stosw

;mov es,ax
;mov di,ds:[hotkeyoffset]
;mov si,0
;mov cx,ds:[hotkeylenth]
;rep movsb

sti
mov ah,4ch
int 21h
code ends


hotkey segment para use16
assume cs:hotkey
mainproc proc near
pushad
push ds
push es
push fs
push gs
push ss

pushf
call dword ptr cs:[hotkey_ip]

sti
mov ax,40h
mov ds,ax
mov si,word ptr ds:[1ah]
cmp si,word ptr ds:[1ch]
jnz keybuf_full
jmp hotkey_iret
keybuf_full:
cmp word ptr ds:[si],3b00h
jz key_f1_press
jmp hotkey_iret
key_f1_press:
add si,2
cmp si,3eh
jl not_reachend
mov si,1eh
not_reachend:
mov ds:[1ah],si
mov ds:[1ch],si
call key_f1_proc
hotkey_iret:
pop ss
pop gs
pop fs
pop es
pop ds
popad
iret
mainproc endp

key_f1_proc proc near
mov ax,3
int 10h
mov ax,cs
mov ds,ax

MOV Al,4
out 70h,al
in al,71h

push ax
pop bx
shr al,4
add al,30h
and bl,0fh
add bl,30h
mov ah,bl
mov ds:[hour],ax

mov al,2
out 70h,al
in al,71h
push ax
pop bx
shr al,4
add al,30h
and bl,0fh
add bl,30h
mov ah,bl
mov ds:[minute],ax

mov al,0
out 70h,al
in al,71h
push ax
pop bx
shr al,4
add al,30h
and bl,0fh
add bl,30h
mov ah,bl
mov ds:[second],ax
call showmsg

retn
key_f1_proc endp

showmsg proc near
mov ax,0b800h
mov es,ax
mov di,0
mov ah,ds:[color]
mov si,offset msg_f1
toshowmsg:
lodsb
cmp al,0ffh
jz showmsg_ret
stosw
jmp toshowmsg
showmsg_ret:
ret
showmsg endp

msg_f1 		db 'CURRENT TIME:'
hour	  	DW 0
		db 2fh
minute		dw 0
		db 2fh
second		dw 0
		db 0ffh      		
color		db 7h
hotkey_ip 	dw 0
hotkey_cs 	dw 0
hotkeyoffset	dw 000h
hotkeyseg 	dw 000h
hotkeylenth 	dw $
hotkey ends

end start