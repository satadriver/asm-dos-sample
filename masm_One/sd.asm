
.386

buffer segment para 
dd 4000h dup (0)
buffer ends

buf segment para
dd 4000h dup (0)
buf ends

data segment para 
msg0 db 'press q to quit......',0ah,0dh
msg1 db 'Input ( *.wav )name to play(including the directory):',0ah,0dh,24h
msg2 db 'File not found,press any key to contine...',24h
msg3 db 'init DSP failure,press any key to quit....',24h

filename    db 20h
            db 0
            db 20h dup (0)
wavheader   db 100h dup (0)
dataseg     dw 0
databuffer  dw 0

datasize    dd 0
fileptr     dd 0
handle      dw 0
endflag     db 0
data ends

code segment para use16
assume cs:code
start:
call init
nextblock:
cmp byte ptr fs:[endflag],1
jnz notendfile
jmp start
notendfile:
call readfile
call adjust
call initdma
call initdsp
call playwav
call waittime
jmp nextblock


init proc near
cld
mov ax,3
int 10h
mov ax,data
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ax,buffer
mov ds:[dataseg],ax
mov ax,buf
mov ds:[databuffer],ax
mov ah,9
mov dx,offset msg0
int 21h
mov ah,0ah
mov dx,offset filename
int 21h
cmp byte ptr ds:[filename+2],'q'
jnz notquit_capslock
jmp quit
notquit_capslock:
cmp byte ptr ds:[filename+2],'Q'
jnz notquit
jmp quit
notquit:
mov bl,ds:[filename+1]
movzx bx,bl
mov si,offset filename
mov al,0
mov ds:[si+bx+2],al

mov dword ptr ds:[fileptr],0
mov byte ptr ds:[endflag],0


mov ax,3d00h
mov dx,offset filename
add dx,2
int 21h
jnc gethandle
mov ah,9
mov dx,offset msg2
int 21h
mov ah,0
int 16h
jmp start
gethandle:
mov ds:[handle],ax
mov bx,ax
mov ax,3f00h
mov cx,100h
mov dx,offset wavheader
int 21h

mov esi,dword ptr ds:[wavheader+10h]
sub si,10h
add si,24h
add si,offset wavheader
mov eax,ds:[si]
cmp eax,74636166h
jnz nofact
add si,12
nofact:
add si,4
mov eax,ds:[si]
mov ds:[datasize],eax
add si,4
sub si,offset wavheader
mov word ptr ds:[fileptr],si

mov ax,es:[dataseg]
mov ds,ax
mov ax,4200h
mov bx,es:[handle]
mov cx,word ptr es:[fileptr+2]
mov dx,word ptr es:[fileptr]
int 21h
retn
init endp



readfile proc near
mov ax,fs:[dataseg]
mov ds,ax
mov ax,fs:[databuffer]
mov es,ax
mov eax,dword ptr fs:[datasize]
sub eax,dword ptr fs:[fileptr]
cmp eax,dword ptr fs:[wavheader+1ch]
jbe readdetail
mov ax,3f00h
mov bx,fs:[handle]
mov cx,word ptr fs:[wavheader+1ch]
mov dx,0
int 21h
movzx eax,ax
add dword ptr fs:[fileptr],eax
ret
readdetail:
mov cx,ax
mov ax,3f00h
mov bx,fs:[handle]
mov dx,0
int 21h
mov byte ptr fs:[endflag],1
ret
readfile endp






adjust proc near
mov si,0
mov di,0
mov cx,word ptr fs:[wavheader+18h]
cmp word ptr fs:[wavheader+22h],4
jz channel1bytehalf

cmp word ptr fs:[wavheader+16h],2
jz channel2
cmp word ptr fs:[wavheader+22h],16
jz channel1byte2
jmp channel1byte1
channel2:
cmp word ptr fs:[wavheader+22h],16
jz channel2byte2
jmp channel2byte1

channel1bytehalf:
lodsb
push ax
and al,0fh
stosb
pop ax
and al,0f0h
stosb
loop channel1bytehalf
jmp adjust_ret

channel1byte2:
copychannel1byte2:
lodsw
shr ax,8
stosb
loop copychannel1byte2
jmp adjust_ret
ret

channel2byte2:
ret

channel1byte1:
RET

channel2byte1:
copy:
movsb
inc si
loop copy

adjust_ret:
mov ax,es
mov ds,ax
ret
adjust endp




initdsp proc near
mov dx,226h
mov al,1
out dx,al
mov cx,1
loop $
mov al,0
out dx,al
call dspin
cmp al,0aah
jz initdsp_ret
mov ax,fs
mov ds,ax
mov ah,9
mov dx,offset msg3
int 21h
mov ah,0
int 16h
call quit
initdsp_ret:
retn
initdsp endp


initdma proc near
mov al,0
out 0dh,al
mov al,59h
out 0bh,al
xor eax,eax
mov ax,ds
shl eax,4
out 2,al
xchg ah,al
out 2,al
shr eax,16
out 83h,al
mov ax,word ptr fs:[wavheader+18h]
dec ax
out 03,al
xchg ah,al
out 3,al
retn
initdma endp




playwav proc near
mov al,14h
call dspout 
mov al,1
out 0ah,al
mov al,40h
call dspout
mov ax,word ptr fs:[wavheader+18h]
xchg ah,al
call dspout 
xchg ah,al
call dspout 
mov al,48h
call dspout
mov ax,word ptr fs:[wavheader+18h]
xchg ah,al
call dspout 
xchg ah,al
call dspout
retn
playwav endp


 
waittime proc near
in al,4
mov ah,al
in al,4
xchg ah,al
cmp ax,0
jnz waittime
retn
waittime endp


dspout proc near
push ax
mov dx,22ch
getinfree:
in al,dx
test al,80h
jnz getinfree
pop ax
out dx,al
retn
dspout endp

dspin proc near
mov dx,22eh
getoutfree:
in al,dx
test al,80h
jz getoutfree
mov dx,22ah
in al,dx
retn
dspin endp



quit proc near
mov ah,4ch
int 21h
quit endp
code ends
end start