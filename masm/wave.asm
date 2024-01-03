.model small
.386
.stack
.data
handle dw 0
highpage dw 0
lowpage dw 0
headersize dw 3ah
wavheader db 3ah dup (0)
wavlist db      'd:\wavmusic\test.wav',0

message0 db 'press ESC to quit,Input wavename(*.wav) to play:$'
message1 db 'Can not open file,press any key to continue,press ESC to quit.....',24h
message2 db 'Can not initiate DSP normally,press any key to quit....',24h
message3 db 'Not found file,press any key to continue...',0ah,0dh,24h

buffer db 6         
db 0
prefixnum dw 0
dd 0

routine db 'd:\wavmusic\test.wav',0
filename db 'b'
db '.wav',0

.code
start:
main proc 
call init
play:
mov ax,es:[highpage]
cmp ax,0
jz toquit
call readfile
call initdsp
call initdma
mov al,0d1h
call dspout

mov al,14h
call dspout
mov al,1
out 0ah,al

mov al,40h
call dspout
mov ax,word ptr es:[wavheader+1ch]
call dspout
xchg ah,al
call dspout
mov al,48h
call dspout
mov ax,word ptr es:[wavheader+1ch]
call dspout
xchg ah,al
call dspout

mov dx,22ch
waitout:
in al,dx
test al,80h
jnz waitout
push ds
mov ax,40h
mov ds,ax
mov si,6ch
mov ax,ds:[si]
add ax,18
mov bx,ax
waittime:
mov ax,ds:[si]
cmp ax,bx
jb waittime
pop ds
jmp play
toquit:
call quit
main endp



init proc near
mov ax,@data
mov ds,ax
mov es,ax
mov ax,3d00h
mov dx,offset routine
int 21h
;jc notfoundfile
mov es:[handle],ax
mov bx,ax
mov ax,4202h
mov cx,0
mov dx,0
int 21h
mov es:[highpage],dx
mov es:[lowpage],ax
mov ax,4200h
mov cx,0
mov dx,0
int 21h
mov ax,3f00h
mov bx,es:[handle]
mov cx,word ptr es:[headersize]
mov dx,offset wavheader
int 21h
mov cx,es:[lowpage]
sub cx,ax
mov es:[lowpage],cx
mov cx,es:[highpage]
sbb cx,0
mov es:[highpage],cx
ret
init endp

readfile proc near
mov ax,6000h
mov ds,ax
mov ax,3f00h
mov bx,es:[handle]
mov cx,word ptr es:[wavheader+2ch]
mov dx,0
int 21h
mov cx,es:[lowpage]
sub cx,ax
mov es:[lowpage],cx
mov cx,es:[highpage]
sbb cx,0
mov es:[highpage],cx
ret
readfile endp

initdma proc near
mov al,5
out 0ch,al
out 0ah,al
mov al,59h
out 0bh,al

mov ax,ds
out 2,al
mov al,ah
out 2,al
mov al,6
out 83h,al
mov ax,word ptr es:[wavheader+2ch]
out 3,al
mov al,ah
out 3,al
ret
initdma endp

initdsp proc near
mov dx,226h
mov al,1
out dx,al
mov cx,100h
loop $
mov al,0
mov dx,226h
out dx,al
call dspin
cmp al,0aah
jnz quit
ret
initdsp endp


dspout proc near
push ax
mov dx,22ch
waitoutfree:
in al,dx
test al,80h
jnz waitoutfree
pop ax
out dx,al
ret
dspout endp

dspin proc near
mov dx,22eh
waitinfree:
in al,dx
test al,80h
jz waitinfree
mov dx,22ah
in al,dx
ret
dspin endp

quit proc near
mov ax,es
mov ds,ax
mov ah,9
mov dx,offset message2
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h
quit endp
end start