.386p
code segment para use16
org 100h
assume cs:code,ds:code,es:code
start:
jmp main

align 10h
prdtable		             dq 800001ff00000000h
prdbase	 		          dd 0
hd_port 		              dw 0
bus_master_base 	           dw 0
hd_bus_dev_func		       dd 0
start_seg		             dw 5000h
start_offset		          dw 0
sector_label		          dd 0
sector_num		            dw 1
msg_init            db 'this program is used to demonstrate the IDE bus master',0ah,0dh
                           db 'DMA reading transfer,press any key to continue...',0ah,0dh,24h
msg_nodevice 		         db 'NO IDE DEVICE,PRESS ANY KEY TO QUIT!',0AH,0DH,24H
msg_end                     db 'Now go into DEBUG for check MBR in 5000:0000',0ah,0dh,24h

main:
call init
call get_IDE_bus_dev_func
call get_ide_port
call get_bus_master_base
call readsector
call hd_dma_read
in al,0a1h
and al,3fh
out 0a1h,al
mov ah,4ch
int 21h

init proc near
mov ax,3
int 10h
in al,0a1h
or al,0c0h
out 0a1h,al
xor eax,eax
mov ax,cs
mov ds,ax
mov es,ax
shl eax,4
xor ebx,ebx
mov bx,offset prdtable
add eax,ebx
mov cs:[prdbase],eax
xor eax,eax
mov ax,cs:[start_seg]
shl eax,4
xor ebx,ebx
mov bx,cs:[start_offset]
add eax,ebx
mov dword ptr cs:[prdtable],eax

mov ah,9
mov dx,offset msg_init
int 21h
mov ah,0
int 16h
ret
init endp



get_ide_bus_dev_func proc near
mov eax,80000008h
next_func:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in  eax,dx
mov al,0
cmp eax,01018000h    ;09=80 bus master capable,0b0ah=0101 mass storage device
jz find_device
pop eax
add eax,100h
cmp eax,80ffff08h
jbe next_func
nodevice:
mov ah,9
mov dx,offset msg_nodevice
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h
find_device:
pop eax
mov al,0
mov cs:[HD_bus_dev_func],eax
ret
get_ide_bus_dev_func endp



get_ide_port proc near
mov eax,cs:[hd_bus_dev_func]
mov al,40h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
test eax,80008000h
jnz legacy_port
mov eax,cs:[hd_bus_dev_func]
mov al,10h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and al,0feh
mov cs:[hd_port],ax
ret
legacy_port:
mov al,20h
mov dx,177h
out dx,al
mov cx,0ffffh
waitbuf:
dec cx
cmp cx,0
jnz waitbuf
in al,dx
cmp al,58h
jz port170h
mov word ptr cs:[hd_port],1f0h
mov dx,3f6h
jmp reset_HD
port170h:
mov word ptr cs:[hd_port],170h
mov dx,376h
RESET_HD:	
mov al,0ch
out dx,al
mov al,2
out dx,al
ret
get_ide_port endp



get_bus_master_base proc near
mov eax,cs:[HD_bus_dev_func]
mov al,20h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and al,0feh
mov cs:[bus_master_base],ax
ret
get_bus_master_base endp



readsector proc near
mov dx,cs:[hd_port]
add dx,5
mov al,0
out dx,al
dec dx
out dx,al
dec dx
mov eax,cs:[sector_label]
rol eax,8
out dx,al

mov dx,cs:[hd_port]
add dx,5
rol eax,8
out dx,al
dec dx
rol eax,8
out dx,al
dec dx
rol eax,8
out dx,al

dec dx
mov ax,cs:[sector_num]
xchg ah,al
out dx,al
xchg ah,al
out dx,al

mov dx,cs:[hd_port]
add dx,7
mov al,25h
out dx,al
wait_hd_ready:
in al,dx
cmp al,58h
jnz wait_hd_ready
ret
readsector endp


hd_dma_read proc near
mov dx,cs:[bus_master_base]
add dx,8
in al,dx
test al,4
jnz slave_base
mov dx,cs:[bus_master_base]
jmp next
slave_base:
mov dx,cs:[bus_master_base]
add dx,8
next:
add dx,4
mov eax,cs:[prdbase]
out dx,eax
sub dx,2
mov al,6
out dx,al
sub dx,2
mov al,9
out dx,al
add dx,2
wait_int:
in al,dx
test al,4
jz wait_int
mov al,4
out dx,al
;mov al,20h
;out 0a0h,al
;out 20h,al
;sub dx,2 
;mov al,1
;out dx,al
;add dx,2
;in al,dx
mov ah,9
mov dx,offset msg_end
int 21h
ret
hd_dma_read endp

code ends
end start