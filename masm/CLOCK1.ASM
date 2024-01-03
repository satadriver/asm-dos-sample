.386
code segment para use16
assume cs:code
start:
mov al,0ffh
out 0a1h,al
cli
cld
mov ax,0
mov es,ax
mov di,1c0h
stosw
mov ax,5000h
stosw
mov es,ax
mov ax,clock
mov ds,ax
mov si,0
mov di,0
mov cx,ds:[clocklen]
rep movsb

mov al,0
out 0a1h,al
in al,21h
and al,0fbh
out 21h,al
mov al,0bh
out 70h,al
mov al,20h
out 71h,al

mov al,0
out 70h,al
in al,71h
mov bl,al
mov al,1
out 70h,al
mov al,bl
out 71h,al

mov al,2
out 70h,al
in al,71h
mov bl,al
mov al,3
out 70h,al
mov al,bl
cmp al,58h
jae small58
mov bx,ax
and al,0fh
cmp al,8
jbe l01
add bx,6
l01:
mov ax,bx
inc al
out 71h,al
mov al,4
out 70h,al
in al,71h
mov bl,al
mov al,5
out 70h,al
mov al,bl
out 71h,al
jmp next01
small58:
mov al,0
out 71h,al
mov al,4
out 70h,al
in al,71h
mov bl,al
mov al,5
out 70h,al
mov al,bl
inc al
out 71h,al
next01: 
sti
mov ah,4ch
int 21h
code ends

clock segment para use16
assume cs:clock
pushad
push ds
push es
push ss
push fs
push gs
mov ax,3
int 10h
mov ax,0b800h
mov es,ax
mov ax,cs
mov ds,ax
mov si,offset rect
mov di,780h
mov cx,6
copy:
push cx
mov cx,62
rep movsw
add di,36
pop cx
loop copy

circle:
mov al,0
out 70h,al
in al,71h
push ax
shr al,4
add al,30h
mov byte ptr ds:[sec],al
pop ax
and al,0fh
add al,30h
mov byte ptr ds:[sec+1],al
mov al,2
out 70h,al
in al,71h
push ax
shr al,4
add al,30h
mov byte ptr ds:[min],al
pop ax
and al,0fh
add al,30h
mov byte ptr ds:[min+1],al
mov al,4
out 70h,al
in al,71h
push ax
shr al,4
add al,30h
mov byte ptr ds:[hour],al
pop ax
and al,0fh
add al,30h
mov byte ptr ds:[hour+1],al


mov al,1
out 70h,al
in al,71h
push ax
shr al,4
add al,30h
mov byte ptr ds:[alarmsec],al
pop ax
and al,0fh
add al,30h
mov byte ptr ds:[alarmsec+1],al
mov al,3
out 70h,al
in al,71h
push ax
shr al,4
add al,30h
mov byte ptr ds:[alarmmin],al
pop ax
and al,0fh
add al,30h
mov byte ptr ds:[alarmmin+1],al
mov al,5
out 70h,al
in al,71h
push ax
shr al,4
add al,30h
mov byte ptr ds:[alarmhour],al
pop ax
and al,0fh
add al,30h
mov byte ptr ds:[alarmhour+1],al

mov al,32h
out 70h,al
in al,71h
push ax
shr al,4
add al,30h
mov byte ptr ds:[century],al
pop ax
and al,0fh
add al,30h
mov byte ptr ds:[century+1],al
mov al,9
out 70h,al
in al,71h
push ax
shr al,4
add al,30h
mov byte ptr ds:[year],al
pop ax
and al,0fh
add al,30h
mov byte ptr ds:[year+1],al
mov al,8
out 70h,al
in al,71h
push ax
shr al,4
add al,30h
mov byte ptr ds:[mon],al
pop ax
and al,0fh
add al,30h
mov byte ptr ds:[mon+1],al
mov al,7
out 70h,al
in al,71h
push ax
shr al,4
add al,30h
mov byte ptr ds:[day],al
pop ax
and al,0fh
add al,30h
mov byte ptr ds:[day+1],al

push es
mov ax,ds
mov es,ax
mov al,6
out 70h,al
in al,71h
cmp al,1
jz weekone
cmp al,2
jz weektwo
cmp al,3
jz weekthree
cmp al,4
jz weekfour
cmp al,5
jz weekfive
cmp al,6
jz weeksix
jmp weekseven
weekone:
mov si,offset week1
mov di,offset weekday
l1:
lodsb
cmp al,24h
jz next
stosb
jmp l1
weektwo:
mov si,offset week2
mov di,offset weekday
l2:
lodsb
cmp al,24h
jz next
stosb
jmp l2
weekthree:
mov si,offset week3
mov di,offset weekday
l3:
lodsb
cmp al,24h
jz next
stosb
jmp l3
weekfour:
mov si,offset week4
mov di,offset weekday
l4:
lodsb
cmp al,24h
jz next
stosb
jmp l4
weekfive:
mov si,offset week5
mov di,offset weekday
l5:
lodsb
cmp al,24h
jz next
stosb
jmp l5
weeksix:
mov si,offset week6
mov di,offset weekday
l6:
lodsb
cmp al,24h
jz next
stosb
jmp l6
weekseven:
mov si,offset week7
mov di,offset weekday
l7:
lodsb
cmp al,24h
jz next
stosb
jmp l7



next:
pop es
mov si,offset str0
mov di,822h
next1:
lodsb
cmp al,24h
jz quit
cmp al,13
jnz next2

push di
mov dx,0
mov ax,di
mov bx,0a0h
div bx
mov bp,160
sub bp,dx
pop di
add di,bp
add di,2
jmp next1
next2:
mov ah,0ah
stosw
jmp next1

quit:
in al,60h
cmp al,1
jz tocontinue
jmp circle
tocontinue:
push word ptr es:[sec]
mov ax,es:[sec]
xchg ah,al
push ax
and ax,0ff00h
sub ah,30h
shr ax,4
pop bx
sub bl,30h
or bl,al
pop word ptr es:[sec]

mov al,0
out 70h,al
in al,71h
cmp al,bl
jz quit
jmp circle


next10:
mov al,0
out 70h,al
in al,71h
mov bl,al
mov al,1
out 70h,al
mov al,bl
out 71h,al

mov al,2
out 70h,al
in al,71h
mov bl,al
mov al,3
out 70h,al
mov al,bl
cmp al,58h
jae small59
mov bx,ax
and al,0fh
cmp al,8
jbe l010
add bx,6
l010:
mov ax,bx
inc al
out 71h,al
mov al,4
out 70h,al
in al,71h
mov bl,al
mov al,5
out 70h,al
mov al,bl
out 71h,al
jmp next00
small59:
mov al,0
out 71h,al
mov al,4
out 70h,al
in al,71h
mov bl,al
mov al,5
out 70h,al
mov al,bl
inc al
out 71h,al


next00:
mov al,20h
out 20h,al
out 0a0h,al
mov al,0ch
out 70h,al
in al,71h
mov ax,3
int 10h
pop gs
pop fs
pop ss
pop es
pop ds
popad
iret
mov ah,4ch
int 21h

toquit:
mov al,20h
out 20h,al
out 0a0h,al
mov al,0ch
out 70h,al
in al,71h
mov ax,3
int 10h
pop gs
pop fs
pop es
pop ds
popad
iret
rect dw 0adah
dw 60 dup (0ac4h)
dw 0abfh

dw 0ab3h
dw 60 dup (720h)
dw 0ab3h

dw 0ab3h
dw 60 dup (720h)
dw 0ab3h

dw 0ab3h
dw 60 dup (720h)
dw 0ab3h

dw 0ab3h
dw 60 dup (720h)
dw 0ab3h

dw 0ac0h
dw 60 dup (0ac4h)
dw 0ad9h

blank dw 372 dup (720h)


str0 db 'current time is:'
hour dw 0
db 3ah
min dw 0
db 3ah
sec dw 0
db 0dh
str1 db 'alarm time is:'
alarmhour dw 0
db 3ah
alarmmin dw 0
db 3ah
alarmsec dw 0
db 0dh
str2 db 'current date is:'
century dw 0
year dw 0
db 2fh
mon dw 0
db 2fh
day dw 0
dw 2020h
weekday db 10 dup (0)
db 24h

week1 db ' monday$'
week2 db ' tuesday$'
week3 db ' wednesday$'
week4 db ' thursday$'
week5 db ' friday$'
week6 db ' saturday$'
week7 db ' sunday$'
videobuf db 200h dup (0)
clocklen dw $
clock ends
end start