.model small
.386
.STACK
.data
handle 		dw 0
sizelow 		dw 0
sizehigh 		dw 0
rate 		dw 0
block 		dw 0
channel 		dw 0
wavlimitlen 		db 40h
wavfactlen  		db 0
wavname 		db 40h dup(0)
wavheader 		db 46 dup (0)
msgInput 		db 'Please Input the Name of Wave File:',24h
msgNotFound 		db 'Not Found File!Please Input File Again!',20h dup (20h),0ah,0dh,24h
.code
start:



MOV AX,40H
MOV FS,AX
mov ax,@data
mov ds,ax
mov es,ax

mov ah,9
mov dx,offset msgInput
int 21h
mov ah,0ah
mov dx,offset wavlimitlen
int 21h
xor bx,bx
mov bl,ds:[wavfactlen]
mov byte ptr ds:[wavname+bx],0


mov ax,3d00h
mov dx,offset wavname
int 21h
jnc found
mov ah,9
mov dx,offset msgNotFound
int 21h
jmp start
found:
mov bx,ax
mov ds:[handle],ax
mov ah,3fh
mov cx,02Eh
mov dx,offset wavheader
int 21h
mov ax,word ptr ds:[wavheader+4]
sub ax,46
mov word ptr ds:[sizelow],ax
mov ax,word ptr ds:[wavheader+6]
mov word ptr ds:[sizehigh],ax
mov ax,word ptr  ds:[wavheader+18h]
mov word ptr ds:[rate],ax                                 ;2B11H=11025D,8BIT WAVE FILE RATE=11025Bps=88200bps
mov ax,word ptr ds:[wavheader+1ch]
mov word ptr ds:[block],ax
mov ax,word ptr ds:[wavheader+16h]
mov word ptr ds:[channel],ax
cmp al,2
jz singlechannel
mov ax,es:[block]
mov cx,2
mul cx
mov es:[block],ax
mov es:[rate],ax
singlechannel:
mov ax,es:[block]
cmp ax,11025
ja lowrate
shl ax,0
mov es:[block],ax
mov es:[rate],ax
lowrate:

mov ax,2000h
mov ds,ax
mov ax,4200h
mov cx,0
mov dx,2Eh
int 21h

mov ax,es:[sizelow]
mov dx,es:[sizehigh]
mov si,es:[block]
div si
MOV CX,ax

main proc near
PUSH CX                 ;blockÊýÁ¿

mov al,5
out 0dh,al                      ;initiate the DMA
out 0ah,al
mov al,059h
out 0bh,al
out 0ch,al

mov ax,ds
mov cx,10h
mul cx
out 2,al
xchg ah,al
out 2,al

mov al,dl
out 83h,al

mov ax,es:[block]
out 3,al
xchg ah,al
out 3,al

mov al,1                 ;INITIATE DSP
mov dx,226h
out dx,al
mov cx,0
loop $
mov al,0
out dx,al





mov ah,3fh
mov cx,es:[block]
mov dx,0
int 21h

mov al,1
out 0ah,al

mov al,14h
call dspout

mov al,40h
call dspout
mov ax,es:[rate]   ;attention here
xchg ah,al
call dspout 
xchg ah,al
call dspout 


mov al,48h           ;this program can only review 8bit single channel,so not be neccesary
call dspout
mov ax,es:[block]
xchg ah,al
call dspout 
xchg ah,al
call dspout 

waitDma:
in al,3
cmp al,0
jnz WaitDma
POP CX
dec cx
cmp cx,0
jnz next
call quit
next:
jmp main
main endp



quit proc near
mov ah,4ch
int 21h
quit endp



dspout proc near
push ax
mov dx,22ch
waitOutFree:
in al,dx
test al,80h
jnz waitOutFree
pop ax
out dx,al
retn
dspout endp



dspin proc near
mov dx,22eh
waitInFree:
in al,dx
test al,80h
jz waitInFree
mov dx,22ah
in al,dx
retn
dspin endp
end start