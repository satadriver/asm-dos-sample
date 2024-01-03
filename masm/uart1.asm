TITLE UART1
NAME UART1
public showchar,quit
.model small
.code
start:
showchar proc far
mov ax,0b800h
mov es,ax
mov di,0
mov ah,42h
mov dx,3fdh
l0:in al,dx
test al,1
jz l0
mov dx,3f8h
in al,dx
CMP AL,80H
JNB L3
CMP AL,1EH
JNZ SHOW
MOV AL,41H
SHOW:
stosw
L3:retf
showchar endp

quit proc far
mov ah,4ch
int 21h
retf
quit endp
end start

