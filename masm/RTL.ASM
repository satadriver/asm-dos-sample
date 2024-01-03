.386
Transmit segment para use16
		;db 0aah,0aah,0aah,0aah,0aah,0aah,0aah,0abh
DesMac		db 255,255,255,255,255,255
SrcMac		db 6 dup (0)
		dw 800
Info		db 'Hello,Ethernet!',0ah,0dh,24h
CRC		dd 100h dup ('1234')
		db 100h dup (0)
Transmit ends


Code segment para use16
assume cs:Code
start:


mov ax,Transmit
mov es,ax
mov di,offset SrcMac
mov dx,cs:[EthernetBase]
mov cx,6
cld
GetSrcMAC:
in al,dx
stosb
inc dx
loop GetSrcMAC



mov dx,cs:[EthernetBase]
add dx,37h
mov al,0ch
out dx,al

mov dx,cs:[EthernetBase]
add dx,44h
mov eax,0fh			;receive DMA burst 1024b,16k+16b buffer,Rx FIFO 64b
out dx,eax

mov dx,cs:[EthernetBase]
add dx,40h
mov eax,03000000h		;transmit DMA burst 1024b,time gap
out dx,eax

mov dx,cs:[EthernetBase]		;Receive base 60000h
add dx,30h
mov eax,80000h
out dx,eax

mov dx,cs:[EthernetBase]
add dx,3ch
mov ax,0ffh
out dx,ax


xor eax,eax
mov ax,Transmit
shl eax,4				;Transmit base TransmitSeg
mov dx,cs:[EthernetBase]
add dx,20h
out dx,eax

mov dx,cs:[EthernetBase]
add dx,10h
mov eax,00000100h		;Transmit FIFO size 64b,Data Size 256
out dx,eax

mov ah,0
int 16h

mov ah,4ch
int 21h

EthernetBase	dw 0d800h
Code ends
end start