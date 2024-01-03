.model small
.386p
.stack
.data
msg0 db 'press q to quit......',0ah,0dh
msg1 db 'Input ( *.wav )name to play(including the directory):',0ah,0dh,24h
msg2 db 'File not found,press any key to contine...',24h
msg3 db 'init DSP failure,press any key to quit....',24h

filename    db 20h
            db 0
            db 20h dup (0)
wavheader   db 100h dup (0)
dataseg     dw 2000h

datasize    dd 0
fileptr     dd 0
detail      dw 0
handle      dw 0
endflag     db 0

.code
start:
call init
cmp dword ptr es:[wavheader+1ch],10000h
jbe nextblock

nextblock16b:
cmp byte ptr es:[endflag],1
jnz notendfile16b
jmp start
notendfile16b:
call readfile16b
call initdsp
call initdma16b
jmp nextblock16b



nextblock:
cmp byte ptr es:[endflag],1
jnz notendfile
jmp start
notendfile:
call readfile
call initdma
call initdsp
call playwav
call waittime
jmp nextblock





init proc near
cld
mov ax,3
int 10h

mov ax,@data
mov ds,ax
mov es,ax
mov ah,9
mov dx,offset msg0
int 21h
mov ah,0ah
mov dx,offset filename
int 21h
cmp byte ptr ds:[filename+2],'q'
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
mov ax,es:[dataseg]
mov ds,ax
mov eax,dword ptr es:[datasize]
sub eax,dword ptr es:[fileptr]
cmp eax,dword ptr es:[wavheader+1ch]
jbe readdetail
mov ax,3f00h
mov bx,es:[handle]
mov cx,word ptr es:[wavheader+1ch]
mov dx,0
int 21h
movzx eax,ax
add dword ptr es:[fileptr],eax
ret
readdetail:
mov cx,ax
mov es:[detail],ax
mov ax,3f00h
mov bx,es:[handle]
mov dx,0
int 21h
mov byte ptr es:[endflag],1
ret
readfile endp



readfile16b proc near
mov ax,es:[dataseg]
mov ds,ax
mov eax,dword ptr es:[datasize]
sub eax,dword ptr es:[fileptr]
cmp eax,dword ptr es:[wavheader+1ch]
jbe readdetail16b
readblock16b:
mov ax,3f00h
mov bx,es:[handle]
mov cx,0ffffh
mov dx,0
int 21h
mov ax,3f00h
mov bx,es:[handle]
mov cx,1
mov dx,0ffffh
int 21h
mov ax,ds
add ax,1000h
mov ds,ax
mov ax,3f00h
mov bx,es:[handle]
mov cx,word ptr es:[wavheader+1ch]
mov dx,0
int 21h
mov eax,dword ptr es:[wavheader+1ch]
add dword ptr es:[fileptr],eax
ret
readdetail16b:
push eax
cmp eax,10000h
jbe readdetail16b
mov ax,3f00h
mov bx,es:[handle]
mov cx,0ffffh
mov dx,0
int 21h
mov ax,3f00h
mov bx,es:[handle]
mov cx,1
mov dx,0ffffh
int 21h
mov ax,ds
add ax,1000h
mov ds,ax
mov ax,3f00h
mov bx,es:[handle]
pop ecx
sub ecx,10000h
mov dx,0
int 21h
mov byte ptr es:[endflag],1
ret
detail16b:
pop ecx
mov ax,3f00h
mov bx,es:[handle]
mov dx,0
int 21h
mov byte ptr es:[endflag],1
ret
readfile16b endp





initdsp proc near
mov dx,226h
mov al,1
out dx,al
mov cx,0
loop $
mov al,0
out dx,al
call dspin
cmp al,0aah
jz initdsp_ret
mov ax,es
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
mov ax,es:[dataseg]
shl eax,4
out 2,al
xchg ah,al
out 2,al
shr eax,16
out 83h,al
mov ax,word ptr es:[wavheader+1ch]
dec ax
out 03,al
xchg ah,al
out 3,al
retn
initdma endp



initDMA16b proc near
mov al,0
out 0dah,al
mov al,59h
out 0d6h,al
xor eax,eax
mov ax,es:[dataseg]
shl eax,4
out 0c4h,al
xchg ah,al
out 0c4h,al
shr eax,16
out 8bh,al
mov ax,0
out 0c6h,al
out 0c6h,al
call playwav16b
call waittime16b
mov ax,es:[dataseg]
add ax,1000h
shl eax,4
out 0c4h,al
xchg ah,al
out 0c4h,al
shr eax,16
out 8bh,al
mov ax,word ptr es:[wavheader+1ch]
dec ax
out 0c6h,al
xchg ah,al
out 0c6h,al
call playwav16b
call waittime16b
ret
initDMA16b endp


playwav proc near
mov al,14h
call dspout 
mov al,1
out 0ah,al
mov al,40h
call dspout
mov ax,word ptr es:[wavheader+18h]
xchg ah,al
call dspout 
xchg ah,al
call dspout 
mov al,48h
call dspout
mov ax,word ptr es:[wavheader+1ch]
xchg ah,al
call dspout 
xchg ah,al
call dspout
retn
playwav endp



playwav16b proc near
mov al,14h
call dspout 
mov al,1
out 0d4h,al
mov al,40h
call dspout
mov ax,word ptr es:[wavheader+18h]
xchg ah,al
call dspout 
xchg ah,al
call dspout 
mov al,48h
call dspout
mov ax,word ptr es:[wavheader+1ch]
xchg ah,al
call dspout 
xchg ah,al
call dspout
retn
playwav16b endp

waittime proc near
in al,4
mov ah,al
in al,4
xchg ah,al
cmp ax,0
jnz waittime
ret
waittime endp


waittime16b proc near
in al,0c6h
mov ah,al
in al,0c6h
xchg ah,al
cmp ax,0
jnz waittime16b
ret
waittime16b endp

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
end start