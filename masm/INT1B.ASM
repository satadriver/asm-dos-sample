.386p
code segment para use16
assume cs:code
start:
push ds
push word ptr 0
in al,21h
or al,2
out 21h,al
cli
cld
mov ax,int1bproc
mov ds,ax
mov ax,0
mov es,ax
mov di,1bh
shl di,2
stosw
mov ax,ds:[int1bseg]
stosw
mov ax,ds:[int1bseg]
mov es,ax
mov si,0
mov di,0
mov cx,ds:[int1blen]
rep movsb
sti
in al,21h
and al,0fdh
out 21h,al
retf
code ends



int1bproc segment para use16
assume cs:int1bproc
pushad
push ds
push es
push fs
push gs
call waitfree
mov al,0d2h
out 64h,al
call waitfree
mov al,9dh
out 60h,al
mov al,20h
out 20h,al
mov ax,0b800h
mov ds,ax
mov ax,cs
mov es,ax
mov si,0
mov di,offset storevideo
mov cx,1000h
rep movsb
mov ax,cs
mov ds,ax
mov dx,3d4h
mov al,0fh
out dx,al
mov dx,3d5h
in al,dx
mov ds:[cursorlow],al
mov dx,3d4h
mov al,0eh
out dx,al
mov dx,3d5h
in al,dx
mov ds:[cursorhigh],al
mov ax,3
int 10h
mov ax,900h
mov dx,offset msg
int 21h
input:
in al,60h
cmp al,2
jz shut
cmp al,3
jz restart
cmp al,4
jz gowindows
cmp al,5
jz quit
jmp input

shut proc near
call shutscreen
mov dx,0cf8h
mov eax,8000f840h ;LPC bus NO.0,DEV NO.31,FUNC NO.0,BASE ADDRESS 40H
out dx,eax
mov dx,0cfch
in eax,dx
and al,0feh      ;BIT=1 rePRESENT THE ADDRESS IS REGISTER,OTHERWISE IS MEMORY
mov dx,ax
push dx
add dx,30h ;base reg +30h
in ax,dx
and ax,0ffefh
out dx,ax
pop dx
add dx,5  ;base reg+5
in al,dx
or al,3ch
out dx,al
ret
shut endp

restart proc near
call shutscreen
db 0eah
dw 0
dw 0ffffh

mov al,0feh
out 64h,al

mov al,1
out 92h,al

mov dx,0cf9h
mov al,4
out dx,al
ret
restart endp

gowindows proc near
call waitfree
mov al,0d2h
out 64h,al
call waitfree
mov al,1ch
out 60h,al
call waitfree
mov al,0d2h
out 64h,al
call waitfree
mov al,9ch
out 60h,al
int 19h
gowindows endp

quit proc near
call waitfree
;mov ax,0b800h
;mov es,ax
;mov si,offset storevideo
;mov di,0
;mov cx,1000h
;rep movsb
;mov dx,3d4h
;mov al,0fh
;mov ah,ds:[cursorlow]
;out dx,ax
;mov dx,3d4h
;mov al,0eh
;mov ah,ds:[cursorhigh]
;out dx,ax
add sp,40
mov ah,4ch
int 21h
pop gs
pop fs
pop es
pop ds
popad
iret
quit endp

waitfree proc near
in al,64h
test al,2
jnz waitfree
ret
waitfree endp

shutscreen proc near
mov ax,2001h
mov dx,3c4h
out dx,ax
ret
shutscreen endp

msg db 'Select the number U want to do:',0ah,0dh
    db '1:Shut     down computer',0ah,0dh
    db '2:Restart  computer',0ah,0dh
    db '3:Go   	   to Windows',0ah,0dh
    db '4:Go       back',0ah,0dh,24h 
    
int1bseg dw 5000h
storevideo db 0fffh dup (0)
cursorlow db 0
cursorhigh db 0
int1blen dw $
int1bproc ends
end start


