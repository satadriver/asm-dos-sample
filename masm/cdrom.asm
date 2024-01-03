.model small
.386
.stack
.data
CDCTRL dw 1ah,0ch,5 dup (0),0,3000h,1,3 dup (0)
SHOWCDMESSAGE db 'your CD driver is:'
cddriverdisk DB 0,0AH,0DH
DB 'your CD number is:'
cddrivernum db 0,0AH,0DH
DB 'press ESC to quit,press any key to open CDROM$'
nocdDRIVER db 'NO CD DRIVER,press any key to QUIT!',24H
DRIVERNUM Dw 0
DRIVERDISK DW 0

.code
start:
push ds
xor ax,ax
push ax

mov ax,@data
mov es,ax
MOV DS,AX
mov ax,1500h
mov bx,0
int 2fh
mov es:[driverdisk],cx
MOV ES:[drivernum],bx
cmp bx,0
jnz showcd

mov ah,9
mov dx,offset NOCDDRIVER
INT 21H
MOV AH,0
INT 16H
RETF

showcd:
mov ax,es:[drivernum]
add ax,30h
mov es:[cddrivernum],al
mov ax,es:[driverdisk]
add ax,41h
mov es:[cddriverdisk],al
MOV AH,9
MOV DX,OFFSET SHOWCDMESSAGE
INT 21H

mov ah,0
int 16h
cmp al,1bh
jz quit

mov bx,offset CDCTRL
mov ax,es:[bx+10H]
mov fs,ax
mov bp,es:[bx+0EH]
mov al,0
mov fs:[bp],al



mov ax,1510h 
MOV BX,OFFSET CDCTRL
mov cx,es:[driverdisk]
int 2fh
mov ah,0
int 16h


mov al,5
mov fs:[bp],al
mov ax,1510h 
MOV BX,OFFSET CDCTRL
mov cx,es:[driverdisk]
int 2fh

mov ah,0
int 16h
quit:
mov ah,4ch
int 21h
end start

