.model small
.data
bmpname db 'f:\asm\bmp\ww0.bmp',00
.code
start:
mov ax,4f02h
mov bx,115h
int 10h
mov ax,4f06h
mov bx,0
mov cx,800
int 10h
mov ax,4f07h
mov bx,0
mov cx,0
mov dx,0
int 10h

mov ax,@data
mov ds,ax
mov ax,3d02h
mov dx,offset bmpname
int 21h
mov bx,ax

mov ax,2000h
mov ds,ax
mov ax,0a000h
mov es,ax
mov bp,1


mov di,-49098
mov si,0

l0:
add di,49152
adc si,0
cmp si,50h
jz toquit
push si
push di
push bx

mov ax,4200h
mov cx,si
mov dx,di
int 21h

mov ax,3f00h
mov cx,49152
mov dx,0
int 21h


mov cx,16384
mov di,0fffeh
mov si,49151
l3:
dec si
mov al,ds:[si]
mov es:[di],al
dec si
dec di
mov al,ds:[si]
mov es:[di],al
add si,2
dec di
mov al,ds:[si]
mov es:[di],al
sub si,3
sub di,2
loop l3



mov ax,4f05h
mov bx,0
mov dx,bp
int 10h
inc bp
pop bx
pop di
pop si
jmp l0

toquit:
mov cx,0
mov dx,0
mov ax,40h
mov es,ax
mov di,6ch
PUSH CX

l2:
in al,60h
cmp al,1
jz quit
mov bx,es:[di]
add bx,5
l1:
mov ax,es:[di]
cmp ax,bx
jbe l1
POP CX
add Cx,10
PUSH CX
mov ax,4f07h
mov bx,0
MOV DX,0
int 10h
JMP L2



quit:
mov ah,0
int 16h
mov ax,4f02h
mov bx,3
int 10h
mov ah,4ch
int 21h
end start