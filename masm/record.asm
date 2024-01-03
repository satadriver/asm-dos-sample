.model small
.386
.stack
.data
wavname db 'd:\kk.wav',00
wavheader db 'RIFF'
size dw 0
dw 0
dd 0
db 'fmt '
dd 10h
dw 1
dw 1
dd 8000
dd 8000
dw 1
dw 8
db 'data'
dw 0ffc0h


handle dw 0
.code
toquit:
mov ax,4202h
mov bx,es:[handle]
mov cx,0
mov dx,0
int 21h
mov ax,0000h
mov es:[size],ax
mov dx,1
mov word ptr es:[size+2],dx
mov ax,4200h
mov cx,0
mov dx,0
int 21h
mov ax,4000h
mov cx,2ch
mov dx,offset wavheader
int 21h

mov ax,3e00h
mov bx,es:[handle]
int 21h
call quit


start:
mov ax,@data
mov ds,ax
mov es,ax
mov ax,40h
mov fs,ax



mov dx,offset wavname
mov ax,3c00h
mov cx,0
int 21h
mov bx,ax
mov es:[handle],ax

mov ax,4200h
mov cx,0
mov dx,2ch
int 21h

mov ax,2000h
mov ds,ax

l0:
in al,60h
cmp al,1
jz toquit
mov dx,226h
mov al,1
out dx,al
mov cx,1
loop $
mov al,0
out dx,al

mov al,7
out 0ah,al
out 0dh,al
mov al,57h
out 0bh,al
out 0ch,al
mov ax,ds
mov bx,10h
mul bx
out 2,al
xchg ah,al
out 2,al
mov al,dl
out 83h,al
mov ax,word ptr es:[wavheader+18h]
dec ax
out 3,al
xchg ah,al
out 3,al


mov al,0d0h
call dspout
mov al,20h
call dspout 
mov al,3
out 0ah,al


mov al,40h
call dspout
mov ax,1f40h;word ptr es:[wavheader+18h]
xchg ah,al
call dspout 
xchg ah,al
call dspout 

mov al,48h
call dspout
mov ax,1f40h;word ptr es:[wavheader+1ch]
xchg ah,al
call dspout 
xchg ah,al
call dspout 





mov si,6ch
mov ax,fs:[si]
add ax,18
mov bx,ax
ll:
mov ax,fs:[si]
cmp ax,bx
jb ll
mov ah,40h
mov bx,es:[handle]
mov cx,1f40h;word ptr es:[wavheader+1ch]
mov dx,0
int 21h
jmp l0


quit proc near
mov ah,4ch
int 21h
ret
quit endp




dspout proc near
push ax
mov dx,22ch
l8:in al,dx
test al,80h
jnz l8
pop ax
out dx,al
retn
dspout endp

dspin proc near
mov dx,22eh
l9:in al,dx
test al,80h
jz l9
mov dx,22ah
in al,dx
retn
dspin endp

end start