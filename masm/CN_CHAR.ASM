.model small
.386
.stack
.data
exename       db 'clock.exe',0
pspseg 	    dw 0
tel 	       db 0,  3fh,40h,5fh,52h,74h,0bh,14h
    	       db 29h,4ah,49h,44h,43h,3fh,0  ,0
    	       db 0,0f8h,4,0f4h,94h,5ch,0a0h,50h
    	       db 28h,0a4h,24h,44h,84h,0f8h,0,0
tel_char 	    db 'this is a phone', 0ceh,0cfh,24h
    

.code
start:
mov ax,4a00h
mov bx,800h
int 21h
mov ax,@data
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax

mov ax,1100h
mov bx,1000h
mov cx,2
mov dx,0ceh
mov bp,offset tel
int 10h
mov ah,9
mov dx,offset tel_char
int 21h

waitkey:
mov ah,0
int 16h

pushad
push ds
push es
mov ax,ss
shl eax,16
mov ax,sp
mov dword ptr cs:[stackptr],eax
cld
mov ax,4b00h
mov dx,offset exename
int 21h
lss sp,dword ptr cs:[stackptr]
pop es
pop ds
popad
;mov ah,0
;int 16h
mov ah,4ch
int 21h
stackptr	dd 0
end start