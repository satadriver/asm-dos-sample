.386
code segment para use16
assume cs:code
start:
mov ax,int22h
mov ds,ax
mov ax,0
mov es,ax
mov di,22h
shl di,2
cld
;mov ax,ds:[int22h_offset]
mov ax,es:[di]
mov ds:[int22h_offset],ax
stosw
;mov ax,ds:[int22h_seg]
mov ax,es:[di]
mov ds:[int22h_seg],ax
stosw

mov es,ax
mov di,ds:[int22h_offset]
mov si,0
mov cx,ds:[int22h_lenth]
rep movsb


mov ah,4ch
int 21h
code ends

int22h segment para use16
assume cs:int22h
pushad
push ds
push es
push fs
push gs
mov ax,13h
int 10h
mov ax,0a000h
mov es,ax
mov di,0
mov cx,0ffffh
mov al,1
rep stosb
pop gs
pop fs
pop es
pop ds
popad
mov ah,0
int 16h
mov ax,3
int 10h
mov ah,4ch
int 21h
int22h_offset dw 0
int22h_seg dw 5000h
int22h_lenth dw $
int22h ends
end start