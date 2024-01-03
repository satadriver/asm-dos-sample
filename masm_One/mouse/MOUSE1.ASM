.386
code segment para use16
assume cs:code
start:
cli
mov al,0ffh
out 0a1h,al

mov ax,code
mov ds,ax
mov si,offset mouse
mov ax,8000h
mov es,ax
mov di,0
mov cx,mouselenth
rep movsb

mov ax,0
mov es,ax
mov di,1d0h
stosw
mov ax,8000h
stosw

l5:in al,64h
test al,2
jnz l5
mov al,0adh
out 64h,al

l6:in al,64h
test al,2
jnz l6

mov al,0a8h
out 64h,al

l7:
in al,64h
test al,2
jnz l7

mov al,0d4h
out 64h,al

l8:in al,64h
test al,2
jnz l8

;l11:
;mov al,0ffh
;out 60h,al

;l18:
;in al,64h
;test al,1
;jz l18
;in al,60h
;cmp al,0fah
;jnz l11

;l12:in al,64h
;test al,2
;jnz l12

;mov al,0d4h
;out 64h,al

;l13:
;in al,64h
;test al,2
;jnz l13

l14:
mov al,0f4h
out 60h,al

l15:
in al,64h
test al,1
jz l15
in al,60h
cmp al,0fah
jnz l14

l16:
in al,64h
test al,2
jnz l16

mov al,60h
out 64h,al

l9:
in al,64h
test al,2
jnz l9

mov al,47h
out 60h,al

l10:in al,64h
test al,2
jnz l10

mov al,0aeh
out 64h,al

mov ax,2000h
mov es,ax
mov di,0
mov ax,0
stosb
mov di,5
mov ax,7fffh
stosw

mov ax,4f02h
mov bx,13h
int 10h

cld
mov ax,0a000h
mov es,ax
mov di,0
mov cx,0ffffh
mov al,0ffh
rep stosb

mov al,0
out 0a1h,al
sti
ll:
in al,64h
test al,1
jz ll
in al,60h
cmp al,1ch
jnz ll
mov ax,3
int 10h
mov ah,4ch
int 21h


mouse proc far
mousebegin:

pusha
push ds
push es

cld
mov ax,2000h
mov ds,ax
xor ax,ax
mov si,0
lodsb

inc al
dec si
mov ds:[si],al

mov si,ax
l0:
in al,64h
test al,1
jz l0
in al,60h
mov ds:[si],al
cmp si,3
jnz return

xor ax,ax
mov bx,ax
mov cx,ax
mov dx,ax

mov al,0
mov si,0
mov ds:[si],al

mov si,1
lodsb
mov bl,al
lodsb
mov cl,al
lodsb
mov dl,al

mov ax,0a000h
mov es,ax
mov si,5
lodsw
mov di,ax


test bl,10h
jz right

not  cl
test bl,20h
jz leftup

not dl
mov ax,dx
mov bx,320
mul bx
mov dx,ax

sub di,cx
add di,dx
mov al,4
stosb
dec di
mov si,5
mov ds:[si],di
jmp return

leftup:
mov ax,dx
mov bx,320
mul bx
mov dx,ax
sub di,cx
sub di,dx
mov al,4
stosb
dec di
mov si,5
mov ds:[si],di
jmp return

right:
test bl,20h
jz rightup

not dl
mov ax,dx
mov bx,320
mul bx
mov dx,ax

add di,cx
add di,dx
mov al,4
stosb
dec di
mov si,5
mov ds:[si],di
jmp return

rightup:
mov ax,dx
mov bx,320
mul bx
mov dx,ax
add di,cx
sub di,dx
mov al,4
stosb
dec di
mov si,5
mov ds:[si],di

return:
mov al,20h
out 0a0h,al
out 20h,al
pop es
pop ds
popa
iret
mouselenth=$-mousebegin
mouse endp
code ends
end start