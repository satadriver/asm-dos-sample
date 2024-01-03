.model small
.386
.stack 1000h
.data
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
db 'Input the wav name you want play:',0ah,0dh,24h

msg0 db 'press ESC to quit,press other key to cintinue......',0ah,0dh,24h
msg1 db 'not found file,strike any key t ocontinue....',24h
wavheader db 40h dup (0)
handle dw 0
buffer db 'g:\asm\wavefile\'
filename db 0
db '.wav',0
readblock dw 0


.code
start:
mov ax,3
int 10h
mov ax,40h
mov fs,ax
mov ax,@data
mov ds,ax
mov es,ax
mov ah,9
mov dx,offset wavfile
int 21h
mov ah,0
int 16h
cmp al,1bh
jnz next2
call quit
next2:
mov ah,2
mov dl,al
int 21h
mov es:[filename],al
mov ah,3dh
mov dx,offset buffer
int 21h
;jc notfound

mov es:[handle],ax
mov bx,ax
mov ax,3f00h
mov cx,2ch
mov dx,offset wavheader
int 21h
mov ax,word ptr es:[wavheader+1ch]
mov bx,word ptr es:[wavheader+16h]
mul bx
mov es:[readblock],ax
mov ax,2000h
mov ds,ax
jmp l00
toquit:
mov ax,3
int 10h
mov ax,es
mov ds,ax
mov ah,9
mov dx,offset msg0
int 21h
mov ah,0
int 16h
cmp al,1bh
jnz tomain
call quit
tomain:
jmp start

l00:
in al,60h
cmp al,1
jnz next1
call quit
next1:
mov ah,3fh
mov bx,word ptr es:[handle]
mov cx,es:[readblock]
mov dx,0
int 21h
cmp ax,0
jz toquit



initdsp:
mov dx,226h
mov al,1
out dx,al
mov cx,1
loop $
mov al,0
out dx,al


initdma:
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

playwav:
mov al,0d0h
call dspout
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
jmp l00



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