.386
data segment para use16
msg_input_filename db 'This program is to find a file path',0dh,0ah
                    'Please input the file name:',24h
filename_limit_lenth db 40h
filename_fact_lenth db 0
filename db 40h dup (0)
data ends

CODE segment para use16
assume cs:code

start:
mov ax,data
mov ds,ax
mov es,ax
mov ah,9
mov dx,msg_input_filename 
int 21h
mov ah,0ah
mov dx,offset filename
int 21h
xor bx,bx
mov bl,ds:[filename_fact_lenth]
mov byte ptr ds:[filename+bx],0

mov ax,4e00h
mov dx,offset filename
int 21h
int 3

mov ah,4ch
int 21h



code ends
end start