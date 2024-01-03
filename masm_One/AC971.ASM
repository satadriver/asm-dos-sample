.386
stack segment stack
db 100h dup (0)
stack ends



data segment para use16
prdtable                dq 8000ffff00000000h
prdbase                 dd 0

wavname_limit_lenth     db 40h
wavname_fact_lenth      db 0
wavname                 db 40h dup (0)

wavhead                 db 100h dup (0)
handle                  dw 0
wav_block               db 2000h dup (0)

slot_data_seg           dw 0
wavsize                 dd 0
begin_pos               dd 0
block                   dw 0
block_num               dw 0
block_num_read          dw 0
block_detail            dw 0
detail_flag             dw 0
si_pos                  dw 0
di_pos                  dw 0

bus_dev_func            dd 0
ac97mixerbase           dw 0
ac97masterbase          dw 0

slot0                   dw 9800h
slot4321                dt 0
slot8765                dt 0
slotcba9                dt 0
volume                  dw 480h

msg_name db 'Please input the name of wav file to play:',0dh,0ah,24h
msg_nodevice db 'Not found AC97 device,press any key to quit...',0dh,0ah,24h
msg_openfailure db 'Not found file,please check file name...',0dh,0ah,24h
msg_reallocate_error db 'Can not allocate memory',0dh,0ah,24h
datalenth dw $
data ends

code segment para use16
assume cs:code
start:
call reallocate
call get_ac97port
call init

next_page:
mov word ptr ds:[detail_flag],0
mov word ptr ds:[prdtable+4],0ffffh
mov cx,ds:[block_num]
dec cx
next_block:
push cx
call readblock
call prepare_slot
call playwav
pop cx
loop next_block
cmp word ptr ds:[block_detail],0
jz next_page
todetail:
mov word ptr ds:[detail_flag],1
call readdetail
call prepare_slot
call playwav
jmp next_page 



reallocate proc near
mov ax,data
mov ds,ax
mov ax,4a00h
mov bx,cs:[codelenth]
add bx,ds:[datalenth]
add bx,0fh
shr bx,4
add bx,10h
add bx,10h
int 21h
jc reallocate_error
mov ax,4800h
mov bx,1000h
int 21h
jc reallocate_error
mov ds:[slot_data_seg],ax
mov es,ax
ret
reallocate_error:
mov ah,9
mov dx,offset msg_reallocate_error
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h
reallocate endp




init proc near
xor eax,eax
mov ax,data
mov ds,ax
mov fs,ax
mov gs,ax
shl eax,4
xor ebx,ebx
mov bx,offset prdtable
add eax,ebx
mov ds:[prdbase],eax

xor eax,eax
mov ax,ds:[slot_data_seg]
shl eax,4
mov dword ptr ds:[prdtable],eax

call near ptr get_file_name
mov ax,3d00h
mov dx,offset wavname
int 21h
jnc open_success
jmp open_failure
open_success:
mov bx,ax
mov ds:[handle],ax
mov ax,3f00h
mov cx,100h
mov dx,offset wavhead
int 21h

mov esi,dword ptr ds:[wavhead+10h]
sub si,10h
add si,offset wavhead
add si,24h
lodsd
cmp eax,74636166h
jnz no_fact_block
add si,12
no_fact_block:
lodsd
sub eax,8
mov ds:[wavsize],eax
sub si,offset wavhead
mov ds:[begin_pos],esi

mov ax,word ptr ds:[wavhead+20h]
mov bx,2048
mul bx
mov word ptr ds:[block],ax

mov ax,word ptr ds:[wavhead+1ch]
mov dx,word ptr ds:[wavhead+1eh]
mov bx,ds:[block]
div bx
mov ds:[block_num],ax
mov ds:[block_detail],dx

mov ax,4200h
mov bx,ds:[handle]
mov cx,word ptr ds:[begin_pos+2]
mov dx,word ptr ds:[begin_pos]
int 21h
ret

open_failure:
mov ah,9
mov dx,offset msg_openfailure
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h
init endp



get_file_name proc near
mov ah,9
mov dx,offset msg_name
int 21h
mov ah,0ah
mov dx,offset wavname_limit_lenth
int 21h
xor bx,bx
mov si,offset wavname
mov bl,ds:[wavname_fact_lenth]
add si,bx
mov ax,0
mov ds:[si],ax
ret
get_file_name endp






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
mov ah,9
mov dx,offset msg_nodevice
int 21h
quit:
mov ah,0
int 16h
mov ah,4ch
int 21h
get_ac97_basereg:
pop eax
and al,0
mov ds:[bus_dev_func],eax
add eax,10h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
test al,1
jz no_ac97_device
and al,0feh
mov ds:[ac97mixerbase],ax
mov eax,ds:[bus_dev_func]
add eax,14h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and al,0feh
mov ds:[ac97masterbase],ax
ret
get_ac97port endp



readblock proc near
mov ax,3f00h
mov bx,ds:[handle]
mov cx,ds:[block]
mov dx,offset wav_block
int 21h
cmp ax,0
jz block_to_quit
ret
block_to_quit:
mov ah,4ch
int 21h
readblock endp

readdetail proc near
mov ax,3f00h
mov bx,ds:[handle]
mov cx,ds:[block_detail]
mov dx,offset wav_block
int 21h
mov  di,ds:[block_detail]
mov cx,ds:[block]
sub cx,di
mov al,0
rep stosb
cmp ax,0
jz detail_to_quit
ret
detail_to_quit:
mov ah,4ch
int 21h
readdetail endp


prepare_slot proc near
cmp word ptr ds:[detail_flag],1
jnz slot_block
mov ax,ds:[block_detail]
mov bx,32
mul bx
dec ax
mov word ptr ds:[prdtable+4],ax
slot_block:
mov si,offset wav_block
mov ds:[si_pos],si
mov word ptr ds:[di_pos],0
mov ax,word ptr ds:[wavhead+16h]
cmp ax,1
jz channel_1
channel_2:
mov ax,word ptr ds:[wavhead+22h]
shr ax,3
cmp ax,1
jz channel2_sample1
jmp channel2_sample2
channel_1:
mov ax,word ptr ds:[wavhead+22h]
shr ax,3
cmp ax,1
jz channel1_sample1
jmp channel1_sample2

channel1_sample1:
call set_mode_channel1sample1
ret
channel1_sample2:
call set_mode_channel1sample2
ret
channel2_sample1:
call set_mode_channel2sample1
ret
channel2_sample2:
call set_mode_channel2sample2
ret
prepare_slot endp



set_mode_channel1sample1 proc near
mov cx,word ptr ds:[block]
channel1sample1:
push cx
mov si,ds:[si_pos]
lodsb
mov byte ptr ds:[slot4321+9],al
mov byte ptr ds:[slot4321+5],al
mov ds:[si_pos],si
call copy_wav_data
pop cx
loop channel1sample1
ret
set_mode_channel1sample1 endp

set_mode_channel1sample2 proc near
mov cx,word ptr ds:[block]
channel1sample2:
push cx
mov si,ds:[si_pos]
lodsb
mov byte ptr ds:[slot4321+9],al
lodsb
mov byte ptr ds:[slot4321+5],al
mov ds:[si_pos],si
call copy_wav_data
pop cx
loop channel1sample2
ret
set_mode_channel1sample2 endp

set_mode_channel2sample1 proc near
mov cx,word ptr ds:[block]
channel2sample1:
push cx
xor eax,eax
mov si,ds:[si_pos]
lodsw
mov word ptr ds:[slot4321+8],ax
shl eax,12
mov dword ptr ds:[slot4321+4],eax
mov ds:[si_pos],si
call copy_wav_data
pop cx
loop channel2sample1
ret
set_mode_channel2sample1 endp

set_mode_channel2sample2 proc near
mov cx,word ptr ds:[block]
channel2sample2:
push cx
xor eax,eax
mov si,ds:[si_pos]
lodsw
mov word ptr ds:[slot4321+8],ax
lodsw
shl eax,12
mov dword ptr ds:[slot4321+4],eax
mov ds:[si_pos],si
call copy_wav_data
pop cx
loop channel2sample2
ret
set_mode_channel2sample2 endp


copy_wav_data proc near
mov si,offset slot0
mov di,ds:[di_pos]
mov cx,8
rep movsd
mov ds:[di_pos],di
ret
copy_wav_data endp



playwav proc near
mov dx,ds:[ac97masterbase]
add dx,2ch
mov eax,2
out dx,eax
mov dx,ds:[ac97masterbase]
add dx,1bh
mov al,6
out dx,al
mov dx,ds:[ac97masterbase]
add dx,10h
mov eax,ds:[prdbase]
out dx,eax
mov dx,ds:[ac97mixerbase]
add dx,2
mov ax,ds:[volume]
out dx,ax
mov dx,ds:[ac97mixerbase]
add dx,18h
out dx,ax
mov ax,480h
mov dx,ds:[ac97mixerbase]
add dx,36h
out dx,ax
mov dx,ds:[ac97mixerbase]
add dx,38h
out dx,ax

mov dx,ds:[ac97mixerbase]
add dx,26
in ax,dx
or ax,3
out dx,ax
add dx,2
in ax,dx
or ax,3
out dx,ax
add dx,2
in ax,dx
or ax,3
out dx,ax

mov dx,ds:[ac97mixerbase]
add dx,2ch
mov ax,word ptr ds:[wavhead+18h]
out dx,ax
add dx,2
out dx,ax
add dx,2
out dx,ax
add dx,2
out dx,ax

mov dx,ds:[ac97masterbase]
add dx,1bh
mov al,1
out dx,al
wait_prd:
mov dx,ds:[ac97masterbase]
add dx,18h
in ax,dx
cmp ax,0
jnz wait_prd
ret
playwav endp


codelenth dw $
code ends
end start

