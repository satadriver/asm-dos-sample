.386
code segment para use16
assume cs:code
start:
cld
mov ax,int23h
mov ds,ax
mov ax,0
mov es,ax
mov di,28h
shl di,2
;mov ax,ds:[int23h_offset]
mov ax,es:[di]
mov ds:[int23h_offset],ax
stosw
;mov ax,ds:[int23h_seg]
mov ax,es:[di]
mov ds:[int23h_seg],ax
stosw

mov ax,ds:[int23h_seg]
mov es,ax
mov si,0
mov di,ds:[int23h_offset]
mov cx,ds:[int23h_lenth]
rep movsb

mov ah,4ch
int 21h
code ends

int23h segment para use16
assume cs:int23h
pushad
push ds
push es
push fs
push gs
;mov ax,13h
;int 10h
;mov ax,0a000h
;mov es,ax
;mov di,0
;mov cx,0ffffh
;mov al,2
;rep stosb
;mov ah,0
;int 16h
mov ax,0b800h
mov es,ax
mov di,0
mov ax,4142h
stosw
;mov ax,3
;int 10h
pop gs
pop fs
pop es
pop ds
popad
;mov ah,4ch
;int 21h
iret
int23h_offset dw 0
int23h_seg dw 5000h
int23h_lenth dw $
int23h ends
end start