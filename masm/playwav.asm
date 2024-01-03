.model small
.386p
.stack
.data
handle dw 0
highpage dw 0
lowpage dw 0
headersize db 2ch
wavheader db 100h dup (0)
datapos dw 0
wavlist db      '01	a.wav',0ah,0dh
db '02	b.wav',0ah,0dh
db '03	c.wav',0ah,0dh
db '04	d.wav',0ah,0dh
db '05	e.wav',0ah,0dh
db '06	f.wav',0ah,0dh
db '07	g.wav',0ah,0dh
db '08	h.wav',0ah,0dh
db '09	i.wav',0ah,0dh
db '10	j.wav',0ah,0dh
db '11	k.wav',0ah,0dh
db '12	l.wav',0ah,0dh
db '13	m.wav',0ah,0dh
db '14	n.wav',0ah,0dh
db '15	o.wav',0ah,0dh
db '16	p.wav',0ah,0dh
db '17	q.wav',0ah,0dh
db '18	r.wav',0ah,0dh
db '19	s.wav',0ah,0dh
db '20	t.wav',0ah,0dh
message0 db 'Input prefix number of the music name you want to play:$',0ah,0dh
message1 db 'press any key to continue,press ESC to quit.....',0ah,0dh,24h
message2 db 'Can not initiate DSP normally,press any key to quit....',0ah,0dh,24h
message3 db 'Not found file,press any key to quit....',0ah,0dh,24h

buffer db 5         ;ah=0ah/int21 buffer not include the second return byte,and will put the enter into the buffer
db 0
prefixnum dw 0
db 0
dw 0

routine db 'g:\asm\wavefile\'
filename db 0
db '.wav',0

.code
start:
mov ax,40h
mov fs,ax
playwav proc 
call getfilename
call initfile


play:
call initdsp 
call initdma
mov ax,es:[highpage]
cmp ax,0
jnz readblock
mov ax,es:[lowpage]
cmp ax,0
jz gostart
readblock:
call readfile

mov al,0d0h
call dspout
mov al,14h
call dspout
mov al,0dh
out 0fh,al

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
xchg ah,al                                               ;word ptr es:[wavheader+1ch]
call dspout
xchg ah,al
call dspout


mov si,6ch
l1:
mov ax,fs:[si]
add ax,18
mov bx,ax
mov ax,fs:[si]
cmp ax,bx
jb l1

jmp play
gostart:

mov si,0
mov eax,0
mov cx,03fffh
l0:
mov ds:[si],eax
add si,4
loop l0
mov ax,es
mov ds,ax
mov ax,3e00h
mov bx,es:[handle]
mov ax,3
int 10h
mov ah,9
mov dx,offset message1
int 21h
mov ah,0
int 16h
cmp al,1bh
jz quit
call start
playwav endp



getfilename proc near
mov ax,@data
mov ds,ax
mov es,ax
mov ah,9
mov dx,offset wavlist
int 21h
mov ah,0ah
mov dx,offset buffer
int 21h

mov ax,es:[prefixnum]
sub ax,3030h
test ah,0ffh
jz onebyte
test ah,2
jz below20
sub ax,1e0h
sub ax,12
jmp next0
below20:
sub ax,0f0h
sub ax,6
jmp next0
onebyte:
sub ax,30h
next0:
add ax,40h
mov es:[filename],al
ret
getfilename endp




initfile proc near
mov ax,@data
mov ds,ax
mov ax,3d00h
mov dx,offset routine
int 21h
jc notfound
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
notfound:
mov ah,9
mov dx,offset message3
int 21h
mov ah,0
int 16h
call quit
initfile endp

readfile proc near
mov ax,6000h
mov ds,ax
mov ax,es:[highpage]
cmp ax,0
jnz next1
mov ax,es:[lowpage]
cmp ax,word ptr es:[wavheader+1ch]                                                ;word ptr es:[wavheader+2ch]
jnz next1
mov ax,3f00h
mov bx,es:[handle]
mov cx,es:[lowpage]
mov dx,0
int 21h
mov word ptr es:[lowpage],0
jmp toret
next1:
mov ax,3f00h
mov bx,es:[handle]
mov cx, word ptr es:[wavheader+1ch]                                   ;word ptr es:[wavheader+2ch]
mov dx,0
int 21h
mov cx,es:[lowpage]
sub cx,ax
mov es:[lowpage],cx
mov cx,es:[highpage]
sbb cx,0
mov es:[highpage],cx
toret:
ret
readfile endp

initdma proc near
mov al,0fh
out 0dh,al
mov al,59h
out 0bh,al
xor eax,eax
mov ax,ds
shl eax,4
mov eax,60000h
out 2,al
mov al,ah
out 2,al
shr eax,16
out 83h,al
mov ax,word ptr es:[wavheader+1ch]                 ;word ptr es:[wavheader+2ch]???
dec ax                                          ;dec ax???                            ;why dec ax??
out 3,al
mov al,ah
out 3,al
ret
initdma endp

initdsp proc near
mov dx,226h
mov al,1
out dx,al
mov cx,0
loop $
mov al,0
mov dx,226h
out dx,al
call dspin
cmp al,0aah
jnz initfailure
ret
initfailure:
mov ax,es
mov ds,ax
mov ah,9
mov dx,offset message2
int 21h
mov ah,0
int 16h
call quit
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
mov ah,4ch
int 21h
quit endp
end start