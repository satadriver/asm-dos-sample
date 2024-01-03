
.386
code segment para use16
assume cs:code
start:
jmp main

mid db 'd:\asm\masm1\a1.mid',0
handle dw 0
filesize dw 0
msgnotfound db 'not found file',24h

main:
mov ax,cs
mov ds,ax
mov es,ax
mov ax,40h
mov gs,ax
mov fs,ax
mov dx,3d00h
mov dx,offset mid
int 21h
jnc found
mov ah,9
mov dx,offset msgnotfound
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h
found:
mov ds:[handle],ax
mov bx,ax
mov ax,4202h
mov cx,0
mov dx,0
int 21h
mov ds:[filesize],ax
mov ax,4200h
mov bx,ds:[handle]
mov cx,0
mov dx,0
int 21h
mov ax,7000h
mov ds,ax
mov ax,3f00h
mov bx,es:[handle]
mov cx,es:[filesize]
sub cx,36h
mov dx,0
int 21h

cld
mov cx,es:[filesize]
sub cx,36h
mov si,0
l0:
push cx
call initdsp

mov al,38h
call waitout
lodsb
call waitout
call time
pop cx
loop l0

mov ah,4ch
int 21h


initdsp proc near
mov al,1
mov dx,226h
out dx,al
mov al,0
out dx,al
ret
initdsp endp

waitout proc near
push ax
mov dx,22ch
wait_out:
in al,dx
test al,80h
jnz wait_out
pop ax
out dx,al
ret
waitout endp

time proc near
mov di,6ch
mov eax,fs:[di]
inc eax
l2:
mov ebx,fs:[di]
cmp eax,ebx
ja l2

ret
time endp

code ends
end start