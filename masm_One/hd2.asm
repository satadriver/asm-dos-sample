.386
data segment para use16
filename_limit_lenth db 40h
filename_fact_lenth db 0
filename db 40h dup (0)
hd_base_port dw 0



msg_input db 'input the file name to process!',0ah,0dh,24h
msg_nodevice db 'Not found Hard Disk driver!',0ah,0dh,24h
data ends




hd_buffer segment para use16
db 0ffffh dup (0)
db 0
hd_buffer ends


code segment para use16
assume cs:code
start:






get_file_name proc near
mov ax,data
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ah,9
mov dx,offset msg_input
int 21h
mov ah,0ah
mov dx,offset filename_limit_lenth
int 21h
xor bx,bx
mov di,offset filename
mov bl,fs:[filename_fact_lenth
add di,bx
mov al,0
stosb
ret
get_file_name endp








get_hd_partition proc near
push ds
push es
mov ax,hd_buffer
mov es,ax
mov ds,ax
mov edi,0
mov ecx,1
mov eax,0
call read_hd

mov esi,0
add esi,1beh
add esi,8
lodsd
mov ecx,1
mov edi,200h
call read_hd
mov esi,200h
add esi,3
lodsd
cmp eax,5346544eh
jz NTFS_partition
mov esi,200h
add esi,1beh
add esi,8
lodsd






ret
get_hd_partition endp








get_hd_port proc near
mov eax,80000008h
toget_device:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
shr eax,16
cmp eax,0101h
jz find_device
pop eax
add eax,100h
cmp eax,80ffff08h
jbe toget_device
no_device:
mov ah,9
mov dx,offset msg_nodevice
int 21h
jmp quit
find_device:
pop eax
and eax,0ffffff00h
push eax
add eax,40h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and eax,80008000h
sub eax,80008000h
jz legacy_port
pop eax
add eax,10h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and eax,0fffeh
mov ds:[hd_base_port],ax
legacy_port:
pop eax
mov dx,177h
mov al,20h
out dx,al
mov cx,0ffffh
waitbuf_full:
dec cx
cmp cx,0
jnz waitfuf_full
in al,dx
cmp al,58h
jnz port_1f0h
mov dx,376h
mov al,0ch
out dx,al
mov al,2
out dx,al
mov word ptr ds:[hd_base_port],170h
ret
port_1f0h:
mov dx,3f6h
mov al,0ch
out dx,al
mov al,2
out dx,al
mov word ptr ds:[hd_base_port],1f0h
ret
get_hd_port endp




read_hd proc near
;eax=sector begin number to read out
;ecx=sector number
;edi=load offset 
;es=load segment
;fs=parameter segment
push ecx
push eax
mov al,0
mov dx,fs:[hd_port_base]
add dx,5
out dx,al
dec dx
out dx,al
dec dx
pop eax
rol eax,8
out dx,al
mov dx,fs:[hd_port_base]
add dx,5
rol eax,8
out dx,al
dec dx
rol eax,8
out dx,al
dec dx
rol eax,8
out dx,al
mov dx,fs:[hd_port_base]
add dx,2
mov ax,cx
rol ax,8
out dx,al
rol ax,8
out dx,al
mov dx,fs:[hd_port_base]
add dx,6
mov al,0e0h
out dx,al
mov dx,fs:[hd_port_base]
add dx,7
mov al,29h
out dx,al
pop ecx
shl ecx,8
wait_read:
in al,dx
cmp al,58h
jnz wait_read
mov dx,fs:[hd_port_base]
rep insw
ret
read_hd endp



write_hd proc near
;eax=sector begin number to write in
;ecx=sector number
;esi=unload offset 
;ds=unload segment
;fs=parameter segment
push ecx
push eax
mov al,0
mov dx,fs:[hd_port_base]
add dx,5
out dx,al
dec dx
out dx,al
dec dx
pop eax
rol eax,8
out dx,al
mov dx,fs:[hd_port_base]
add dx,5
rol eax,8
out dx,al
dec dx
rol eax,8
out dx,al
dec dx
rol eax,8
out dx,al
mov dx,fs:[hd_port_base]
add dx,2
mov ax,cx
rol ax,8
out dx,al
rol ax,8
out dx,al
mov dx,fs:[hd_port_base]
add dx,6
mov al,0e0h
out dx,al
mov dx,fs:[hd_port_base]
add dx,7
mov al,39h
out dx,al
pop ecx
shl ecx,8
wait_write:
in al,dx
cmp al,58h
jnz wait_write
mov dx,fs:[hd_port_base]
rep outsw
ret
write_hd endp




quit proc near
mov ah,0
int 16h
mov ah,4ch
int 21h
quit endp


code ends

end start
