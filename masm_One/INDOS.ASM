.386
code segment para use16
org 100h
assume cs:code

int28h_new:
pushad
push ds
push es
push fs
push gs

mov ax,cs
mov ds,ax
mov ax,0b800h
mov es,ax
mov di,400h
mov si,offset msg_note
show_msg:
lodsb
cmp al,0
jz next
mov ah,cs:[color]
stosw
jmp show_msg
next:
inc byte ptr cs:[color]
mov ax,cs
mov es,ax
cmp byte ptr cs:[over_flag],0ffh
jz to_exit

mov ax,ss
shl eax,16
mov ax,sp
mov dword ptr cs:[stack_ptr],eax

call check_indos

mov ax,cs:[psp_seg]
mov es,ax
mov ax,4a00h
mov bx,offset start
add bx,0fh
shr bx,4
add bx,10h
int 21h

;call check_indos
;mov ah,55h
;int 21h
;call check_indos

mov ax,4b00h
mov bx,offset parameters
mov dx,offset exename
int 21h
lss sp,dword ptr cs:[stack_ptr]
mov byte ptr cs:[over_flag],0ffh

check_indos_exit:
pushf
call dword ptr cs:[int28h_old_ip]
pop gs
pop fs
pop es
pop ds
popad
iret

check_indos proc near
push es
mov ax,cs:[indos_cs]
mov es,ax
mov di,cs:[indos_ip]
cmp byte ptr es:[di],1
ja to_exit
dec di
cmp byte ptr es:[di],0
jnz to_exit
pop es
ret
to_exit:
add bp,4
jmp check_indos_exit
check_indos endp

int28h_old_ip   dw 0
int28h_old_cs   dw 0
psp_seg         dw 0
indos_ip        dw 0
indos_cs        dw 0
stack_ptr       dd 0
parameters      dw 0
cmdline         dd 0
fcb1            dd 0
fcb2            dd 0
procstackptr    dd 0
ip_cs           dd 0               
exename         db 'clock6.exe',0
msg_note 	db 'int 28h occurred!',0
over_flag       db 0
color		db 1




start:
push ds
pop word ptr cs:[psp_seg]

mov ax,cs
mov ds,ax

mov ax,0
mov es,ax
mov di,28h
shl di,2
push word ptr es:[di]
pop word ptr cs:[int28h_old_ip]
mov ax,offset int28h_new
stosw
push word ptr es:[di]
pop word ptr cs:[int28h_old_cs]
mov ax,seg int28h_new
stosw

mov ax,3400h
int 21h
mov cs:[indos_cs],es
mov cs:[indos_ip],bx

mov ax,3100h           ;stay in memory 31h\21h do not need to use 4ch\21h!!!
mov dx,offset start    ;also like 27h 
add dx,0fh
shr dx,4
add dx,100h
int 21h
code ends
end start