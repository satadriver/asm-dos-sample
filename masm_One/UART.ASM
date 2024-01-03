.386
CODE segment para use16
assume cs:code

uart_int:
pushad
push ds
push es
push fs
push gs
mov ax,cs
mov ds,ax
mov dx,cs:[uart_base_port]
add dx,2
in al,dx
test al,1
jz check_int_reason
jmp uart_int_iret
check_int_reason:
cmp al,6
jz torecieve_error
cmp al,4
jz torecieve_ready
cmp al,2
jz totransfer_empty
cmp al,0
jz tomodem_status_change

torecieve_error:
call recieve_error
jmp uart_int_iret
torecieve_ready:
call recieve_ready
jmp uart_int_iret
totransfer_empty:
call transfer_empty
jmp uart_int_iret
tomodem_status_change:
call modem_status_change
jmp uart_int_iret

recieve_error proc near
mov ax,0b800h
mov es,ax
mov di,cs:[show_position]
mov si,offset msg_recieve_error
show_recieve_error:
lodsb
cmp al,0
jz recieve_error_ret
mov ah,cs:[color]
stosw
jmp show_recieve_error
recieve_error_ret:
ret
recieve_error endp


recieve_ready proc near
mov ax,0b800h
mov es,ax
cld
mov di,cs:[show_position]
mov dx,cs:[uart_base_port]
in al,dx
mov ah,cs:[color]
stosw
mov cs:[show_position],di
inc byte ptr cs:[color]
ret
recieve_ready endp



transfer_empty proc near
MOV AX,0b800h
mov es,ax
mov di,cs:[show_position]
add di,100h
mov si,offset msg_transfer_empty
cld
show_transfer_empty:
lodsb
cmp al,0
jz transfer_empty_ret
mov ah,cs:[color]
stosw
jmp show_transfer_empty
transfer_empty_ret:
inc byte ptr cs:[color]
ret
transfer_empty endp



modem_status_change proc near
mov ax,0b800h
mov es,ax
mov di,cs:[show_position]
mov si,offset msg_modem_change
show_modem_change:
lodsb
cmp al,0
jz modem_change_ret
mov ah,cs:[color]
stosw
jmp show_modem_change
modem_change_ret:
inc byte ptr cs:[color]
ret
modem_status_change endp


uart_int_iret:
mov al,20h
out 20h,al
pop gs
pop fs
pop es
pop ds
popad
iret

show_position 		dw 400h
uart_old_ip 		dw 0
uart_old_cs 		dw 0
uart_base_port 		dw 0
color			db 42H
msg_nodevice 		db 'Not found COM device,press any key to quit...',0ah,0dh,24h
msg_recieve_error 	db 'Recieve error!',0
msg_modem_change   	db 'Modem status had changed!',0
msg_transfer_empty 	db 'Transfer empty!',0

start:
mov ax,cs
mov ds,ax
mov es,ax
call lpc_uart_port
call set_uart_int
call init_uart
call stay


lpc_uart_port proc near
mov eax,8000f8e6h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in  ax,dx
test al,1           ;comA=bit0,comB=bit1
jnz lpc_com_enable
mov word ptr cs:[uart_base_port],3f8h
ret
lpc_com_enable:
mov eax,8000f8e0h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in al,dx
test al,7
jz _3f8h
test al,1
jnz _2f8h
test al,2
jnz _220h
test al,3
jnz _228h
test al,4
jnz _238h
test al,5
jnz _2e8h
test al,6
jnz _338h
test al,7
jnz _3e8h
mov ah,9
mov dx,offset msg_nodevice
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h
_3f8h:
mov word ptr cs:[uart_base_port],3f8h
ret
_2f8h:
mov word ptr cs:[uart_base_port],2f8h
ret
_220h:
mov word ptr cs:[uart_base_port],220h
ret
_228h:
mov word ptr cs:[uart_base_port],228h
ret
_238h:
mov word ptr cs:[uart_base_port],238h
ret
_2e8h:
mov word ptr cs:[uart_base_port],2e8h
ret
_338h:
mov word ptr cs:[uart_base_port],338h
ret
_3e8h:
mov word ptr cs:[uart_base_port],3e8h
ret
lpc_uart_port endp


set_uart_int proc near
cli
mov ax,350ch
int 21h
mov cs:[uart_old_ip],bx
mov bx,es
mov cs:[uart_old_cs],bx
mov ax,250ch
mov dx,offset UART_int
int 21h

in al,21h
and al,0efh
out 21h,al
ret
set_uart_int endp



init_uart proc near
mov dx,cs:[uart_base_port]  	;3f8h
add dx,3  			;3fbh
mov al,80h
out dx,al

mov al,0ch
sub dx,3			;3f8h
out dx,al
inc dx				;3f9h
mov al,0
out dx,al

add dx,2			;3fbh
mov al,0fh
out dx,al

sub dx,2			;3f9h
mov al,0fh
out dx,al

add dx,3			;3fch
mov al,0fh
out dx,al

ret
init_uart endp



stay proc near
sti
add sp,2
mov ax,3100h
mov bx,offset start
add bx,0fh
shr bx,4
add bx,10h
int 21h
ret
stay endp

code ends
end start