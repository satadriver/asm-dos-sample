.386

CODE segment para use16
assume cs:code
start:
push ds
pop word ptr cs:[psp_seg]
mov ax,cs
mov ds,ax
mov es,ax

;call input
mov ax,4e00h
mov dx,offset filename0
mov cx,0
int 21h
jnc found
call notfound
found:
mov ah,9
mov dx,offset msg_found
int 21h
mov ah,9
mov dx,offset msg_next
int 21h
;call input
mov ah,4fh
int 21h
jc notfound
mov ah,9
mov dx,offset msg_found
int 21h
mov ah,0
int 16h

mov ah,4ch
int 21h



notfound proc near
mov ah,9
mov dx,offset msg_notfound
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h
ret
notfound endp

input proc near
mov ah,9
mov dx,offset msg_input_filename 
int 21h
mov ah,0ah
mov dx,offset filename_limit_lenth
int 21h
xor bx,bx
mov bl,ds:[filename_fact_lenth]
mov byte ptr ds:[filename+bx],0
ret
input endp

psp_seg                 dw 0
msg_input_filename      db 'This program is to find a file path,Please input the file name:',24h
msg_notfound            db 'Not found file',24h
msg_found                 db 'Found file',24h
msg_next		db 'Now search more...',24h
filename0  		db 'f:\asm\bmp\*.bmp',0
filename_limit_lenth    db 40h
filename_fact_lenth     db 0
filename                db 40h dup (0)

code ends
end start