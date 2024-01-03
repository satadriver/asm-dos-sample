.model tiny
.386p

.CODE
START:
jmp main
bus_dev_func    	dd 0
ac97masterbase 		dw 0
ac97mixerbase   	dw 0
volume		    	dw 0
show_hide_flag 		dw 0
lastcounter 		dd 0
cur_pos_low		dw 800
cur_pos_high		dw 640h
msg_nodevice 		db 'Not found AC''97 sound card,press any key to quit...',0ah,0dh,24h

msg_show_reg		db 'AC''97 audio mixer base reg:'
mixerbase		dd 0
			db 0ah,0dh
			db 'AC''97 audio bus master base reg:'
masterbase		dd 0
			db 0ah,0dh,24h
			
color_rect 		dq 1020102010201020h
		      	dq 2020202020202020h
	 		dq 1020102010201020h
		      	dq 2020202020202020h
	 		dq 6020602060206020h
		      	dq 4020402040204020h
	 		dq 6020602060206020h
		      	dq 4020402040204020h
main:
mov ax,3
int 10h
mov ax,0b800h
mov es,ax
mov ax,40h
mov ds,ax
mov fs,ax
mov gs,ax
cld
call get_ac97port
mov ax,cs:[ac97mixerbase]
mov si,offset mixerbase
call show_base_reg
mov si,offset masterbase
mov ax,cs:[ac97masterbase]
call show_base_reg
push ds
mov ax,cs
mov ds,ax
mov ah,9
mov dx,offset msg_show_reg
int 21h
pop ds

mov si,6ch
lodsd
mov cs:[lastcounter],eax
mov dx,cs:[ac97mixerbase]
mov ax,0
out dx,ax
mov dx,cs:[ac97mixerbase]
add dx,2
mov ax,1fh
out dx,ax

mainproc:
mov si,6ch
lodsd
mov ebx,eax
sub eax,cs:[lastcounter]
cmp eax,18
jnz next
call show_hide
next:
inc ebx
waittime:
sub si,4
lodsd
cmp eax,ebx
jbe waittime

mov dx,3d4h
mov ax,cs:[cur_pos_low]
push ax
mov al,0eh
out dx,ax
pop ax
shl ax,8
mov al,0fh
out dx,ax
add word ptr cs:[cur_pos_low],2
mov ax,word ptr cs:[cur_pos_low]
cmp ax,word ptr cs:[cur_pos_high]
jb nomove_cur
mov ax,cs:[cur_pos_high]
sub ax,800
mov word ptr cs:[cur_pos_low],ax
nomove_cur:
mov ax,cs:[volume]
mov dx,cs:[ac97mixerbase]
add dx,0ah
out dx,ax
add word ptr cs:[volume],2
in al,60h
cmp al,1
jz quit
jmp mainproc



get_ac97port proc near
mov eax,80000008h
ac97port:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and al,0
cmp eax,04010000h
jz get_ac97_basereg
pop eax
add eax,100h
cmp eax,80ffff08h
jbe ac97port
no_ac97_device:
mov ax,cs
mov ds,ax
mov ah,9
mov dx,offset msg_nodevice
int 21h
quit:
mov ah,0
int 16h
mov ax,3
int 10h
mov dx,cs:[ac97mixerbase]
mov ax,0
out dx,ax
mov ah,4ch
int 21h
get_ac97_basereg:
pop eax
and al,0
mov cs:[bus_dev_func],eax
add eax,10h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
test al,1
jz no_ac97_device
and al,0feh
mov cs:[ac97mixerbase],ax
mov eax,cs:[bus_dev_func]
add eax,14h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and al,0feh
mov cs:[ac97masterbase],ax
ret
get_ac97port endp


	
	
show_hide proc near
pushad
push ds
mov ax,cs
mov ds,ax
mov cs:[lastcounter],ebx
mov di,2000
sub di,320		;line number =2
sub di,8		;lenth=16 bytes
cmp word ptr cs:[show_hide_flag],1
jnz show
hide:
mov eax,00200020h
mov cx,4
copy_hide:
push cx
mov cx,4
rep stosd
add di,144
pop cx
loop copy_hide
mov word ptr cs:[show_hide_flag],0
jmp show_hide_ret
show:
mov si,offset color_rect
mov cx,4
copy_show:
push cx
mov cx,4
rep movsd
add di,144
pop cx
loop copy_show
mov word ptr cs:[show_hide_flag],1
show_hide_ret:
pop ds
popad
ret
show_hide endp

show_base_reg proc near
push ax
push ax
push ax
shr ax,12
call hex_decimal
mov byte ptr cs:[si],al
pop ax
shr ax,8
and al,0fh
call hex_decimal
mov byte ptr cs:[si+1],al
pop ax
shr al,4
call hex_decimal
mov byte ptr cs:[si+2],al
pop ax
and al,0fh
call hex_decimal
mov byte ptr cs:[si+3],al
ret
show_base_reg endp


hex_decimal proc 
cmp al,9
jbe decimal
add al,7
decimal:
add al,30h
ret
hex_decimal endp

end start