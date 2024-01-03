.386
code segment para use16
assume cs:code
hotkey:
jmp hotkey_proc
old_ip 		dw 0
old_cs	 	dw 0
cpu_reg 	dw 0
msg_inc 	db 'Processor has increased at 12.5 percent',0
msg_dec 	db 'Processor has decreased at 12.5 percent',0
msg_highest 	db 'Processor had reached highest speed',0
msg_lowest 	db 'Processor had reached lowest speed',0

hotkey_proc:
pushad
push ds
push es
push fs
push gs
pushf
call dword ptr cs:[old_ip]
mov ax,40h
mov ds,ax
mov ax,0b800h
mov es,ax
mov ax,cs
mov fs,ax
mov gs,ax
mov si,word ptr ds:[1ah]
cmp si,word ptr ds:[1ch]
jnz presskey_occur
jmp hotkey_iret
presskey_occur:
lodsw
cmp ax,3b00h
jz f1_pressed
cmp ax,3c00h
jz f2_pressed
cmp ax,011bh
jz esc_pressed
jmp hotkey_iret

f1_pressed:
call f1_proc
jmp hotkey_iret
f2_pressed:
call f2_proc
jmp hotkey_iret
esc_pressed:
call esc_proc

hotkey_iret:
pop gs
pop fs
pop es
pop ds
popad
iret

f1_proc proc near
mov dx,cs:[cpu_reg]
in ax,dx
test al,10h
jz show_highest
add al,2
;cmp al,20h
;jz show_highest
out dx,ax
mov si,offset msg_inc
call putout
ret
show_highest:
mov si,offset msg_highest
call putout
ret
f1_proc endp




putout proc near
mov ax,cs
mov ds,ax
mov di,0
output:
lodsb
cmp al,0
jz putout_ret
mov ah,7
stosw
jmp output
putout_ret:
ret
putout endp


f2_proc proc near
mov dx,cs:[cpu_reg]
in ax,dx
cmp al,12h
jz show_lowest
test al,10h
jz reset_cpu_reg
sub al,2
out dx,ax
show_dec:
mov si,offset msg_dec
call putout
ret
reset_cpu_reg:
mov al,1eh
out dx,ax
jmp show_dec
show_lowest:
mov si,offset msg_lowest
call putout
ret
f2_proc endp

esc_proc proc near
cli
mov ax,0
mov es,ax
mov di,9
shl di,2
mov ax,cs:[old_ip]
stosw
mov ax,cs:[old_cs]
stosw
ret
esc_proc endp

main:
cli
mov ax,code
mov ds,ax
mov eax,8000f840h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and al,0feh
add ax,10h
mov ds:[cpu_reg],ax

mov ax,0
mov es,ax
mov di,9
shl di,2
cld
push word ptr es:[di]
pop word ptr ds:[old_ip]
mov ax,offset hotkey
stosw
push word ptr es:[di]
pop word ptr ds:[old_cs]
mov ax,seg hotkey
stosw

mov ax,3100h
mov dx,offset main
add dx,0fh
shr dx,4
add dx,10h
int 21h

mov ah,4ch
int 21h
code ends
end main