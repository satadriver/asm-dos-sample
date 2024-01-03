.model small
.386
.stack 1000h
.data
wavname db 'g:\asm\wavefile\'
filename db 0
db '.wav',0,0
highpage dw 0
lowpage dw 0
readblock dw 0
wavfile db '	Wave file directory is:g:\asm\wavefile:',0ah,0dh
db '	a.wav',0ah,0dh
db '	b.wav',0ah,0dh
db'	c.wav',0ah,0dh
db '	d.wav',0ah,0dh
db '	e.wav',0ah,0dh
db '	f.wav',0ah,0dh
db '	g.wav',0ah,0dh
db '	h.wav',0ah,0dh
db '	i.wav',0ah,0dh
db '	j.wav',0ah,0dh
db '	k.wav',0ah,0dh
db '	l.wav',0ah,0dh
db '	m.wav',0ah,0dh
db '	n.wav',0ah,0dh
db '	o.wav',0ah,0dh
db '	p.wav',0ah,0dh
db '	q.wav',0ah,0dh
db '	r.wav',0ah,0dh
db '	s.wav',0ah,0dh
db '	t.wav',0ah,0dh
db 'Input the wav name you want play:',0ah,0dh
db 'press ESC to quit',0ah,0dh,24h
msg0 db 'Not found file,press any key to continue....',24h
wavheader db 40h dup (0)
handle dw 0
block dw 0


.code
start:
main proc near
mov ax,3
int 10h
call initfile


circle:
call initdma
call initdsp
mov ax,es:[highpage]
cmp ax,0
jnz next1
mov ax,es:[lowpage]
cmp ax,0
jnz next1
mov ah,3eh
mov bx,es:[handle]
int 21h
mov si,0
mov cx,0fffh
mov eax,0
l0:
mov ds:[si],eax
add si,4
loop l0
mov ax,3
int 10h
call main
next1:
call readfile
call playwav
jmp circle
main endp

initfile proc near
mov ax,@data
mov ds,ax
mov es,ax
mov ax,40h
mov fs,ax
mov ah,9
mov dx,offset wavfile
int 21h
mov ah,0
int 16h
cmp al,1bh
jnz continue
call quit
continue:
mov es:[filename],al
mov ah,2
mov dl,al
int 21h
mov ax,3d00h
mov dx,offset wavname
int 21h
jc toquit
mov bx,ax
mov es:[handle],ax
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
mov ah,3fh
mov bx,es:[handle]
mov cx,02ch
mov dx,offset wavheader
int 21h
mov cx,es:[lowpage]
sub cx,ax
mov es:[lowpage],cx
mov cx,es:[highpage]
sbb cx,0
mov es:[highpage],cx
mov ax,word ptr es:[wavheader+1ch]
push ax
shl ax,4
mov bx,0
sub bx,ax
shr bx,4
pop ax
add ax,bx
mov bx,word ptr es:[wavheader+16h]
mul bx
mov es:[readblock],ax
mov ax,2000h
mov ds,ax
retn
toquit:
mov ax,3
int 10h
mov ah,9
mov dx,offset msg0
int 21h
mov ah,0
int 16h
call main
initfile endp




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
jz toret
call quit
toret:
retn
initdsp endp



initDMA proc near
mov al,0
out 0dh,al
mov al,59h
out 0bh,al
mov ax,ds
shl eax,4
out 2,al
xchg ah,al
out 2,al
shr eax,16
out 83h,al
mov ax,es:[readblock]
dec ax
out 3,al
xchg ah,al
out 3,al
retn
initDma endp



readfile proc near
mov ax,es:[highpage]
cmp ax,0
jnz next0
mov ax,es:[lowpage]
cmp ax,es:[readblock]
jge next0
mov ah,3fh
mov bx,word ptr es:[handle]
mov cx,word ptr es:[lowpage]
mov dx,0
int 21h
mov word ptr es:[lowpage],0
jmp return
next0:
mov ah,3fh
mov bx,word ptr es:[handle]
mov cx,es:[readblock]
mov dx,0
int 21h
mov cx,es:[lowpage]
sub cx,es:[readblock]
mov es:[lowpage],cx
mov cx,es:[highpage]
sbb cx,0
mov es:[highpage],cx
return:
retn
readfile endp



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
mov ax,es:[readblock]
xchg ah,al
call dspout 
xchg ah,al
call dspout 
mov si,6ch
mov ax,fs:[si]
add ax,18
mov bx,ax
ll:
mov ax,fs:[si]
cmp ax,bx
jb ll
ret
playwav endp


dspout proc near
push ax
mov dx,22ch
l8:in al,dx
test al,80h
jnz l8
pop ax
out dx,al
retn
dspout endp

dspin proc near
mov dx,22eh
l9:in al,dx
test al,80h
jz l9
mov dx,22ah
in al,dx
retn
dspin endp



quit proc near
mov ah,4ch
int 21h
quit endp
end start


