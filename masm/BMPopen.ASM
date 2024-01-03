.model small
.386p
.stack
.data
bmpname db 20h dup (0)
handle dw 0
lowpagenum dw 0
highpagenum dw 0
bmphead db 36h dup (0)
bmppalette db 400h dup (0)

hcursor dw 0
lcursor dw 0
palettenum db 0

pagenum dw 0
videomode dw 0
scanline dw 0

msg0 db 'press ESC to quit......',0ah,0dh
db 'please input BITMAP name:',0ah,0dh,24h
msg1 db 'file not found,press any key to continue......',0ah,0dh,24h
msg2 db 'not supproted resolution,press any key to continue......',24h
.code
start:

main proc near
call getfileinfo
;call setcolor   ;colortable cant be set for more than 1 timer,or color clapse
call setvideomode
jmp main
main endp

getfileinfo proc near
mov ax,4f02h
mov bx,3
int 10h
mov ax,@data
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ah,9
mov dx,offset msg0
int 21h

mov ax,0b800h
mov ds,ax
mov di,offset bmpname
push di
mov cx,offset handle
sub cx,di
mov al,0
rep stosb
pop di
mov si,790h
mov ax,0c80fh
mov es:[lcursor],ax
mov ax,0030eh
mov es:[hcursor],ax

mov ax,40ah
mov dx,3d4h
out dx,ax
mov ax,40bh
mov dx,3d4h
out dx,ax
inputname:
mov ax,es:[lcursor]
mov dx,3d4h
out dx,ax
mov dx,3d4h
mov ax,es:[hcursor]
out dx,ax
mov ah,0
int 16h
cmp al,1bh
jz toquit
cmp al,0dh
jz openfile
cmp al,8
jnz getchar

dec di
cmp di,offset bmpname
jge next0
mov di,offset bmpname
next0:
sub si,2
cmp si,790h
jge next1
mov si,790h
next1:
mov ax,720h   ;here if the BKground color is 0,the cursor will be recovered
mov ds:[si],ax
sub word ptr es:[lcursor],100h
cmp word ptr es:[lcursor],0c80fh
jge next2
mov word ptr es:[lcursor],0c80fh
next2:
jmp inputname

getchar:
stosb
mov ah,9
mov ds:[si],ax
add si,2
add word ptr es:[lcursor],100h
jmp inputname
toquit:
call quit

openfile:
mov ax,es
mov ds,ax
mov ax,3d00h
mov dx,offset bmpname
int 21h
jnc gethandle

mov ax,4f02h
mov bx,3
int 10h
mov ah,9
mov dx,offset msg1
int 21h
mov ah,0
int 16h
jmp getfileinfo

gethandle:
mov es:[handle],ax
mov bx,ax

mov ax,3f00h
mov cx,36h
mov dx,offset bmphead
int 21h
mov ax,word ptr es:[bmphead+2h] ; why not use offset 22h or 24h? offset 2-5 file bytes num,22-25 data bytes num
mov es:[lowpagenum],ax
mov ax,word ptr es:[bmphead+4h]
mov es:[highpagenum],ax
ret
getfileinfo endp



setvideomode proc near
mov eax,dword ptr es:[bmphead+12h]
cmp ax,1600
jz to1600
cmp ax,1280
jz to1280
cmp eax,1024
jz to1024
cmp eax,800
jz to800
cmp ax,640
jz to640
cmp ax,320
jz to320
call informat
to1600:
mov ax,word ptr es:[bmphead+1ch]
cmp ax,8
jz  mode1600x8
call informat
to1280:
mov ax,word ptr es:[bmphead+1ch]
cmp ax,8
jz  mode1280x8
cmp ax,24
jz mode1280x24
cmp ax,32
jz mode1280x32
call informat
to1024:
mov ax,word ptr es:[bmphead+1ch]
cmp ax,8
jz  mode1024x8
cmp ax,24
jz mode1024x24
cmp ax,32
jz mode1024x32
call informat
to800:
mov ax,word ptr es:[bmphead+1ch]
cmp ax,8
jz mode800x8
cmp ax,24
jz mode800x24
cmp ax,32
jz mode800x32
call informat
to640:
mov ax,word ptr es:[bmphead+1ch]
cmp ax,8
jz mode640x8
cmp ax,24
jz mode640x24
cmp ax,32
jz mode640x32
call informat
to320:
mov ax,word ptr es:[bmphead+1ch]
cmp ax,8
jz mode320x8
cmp ax,24
jz mode320x24
cmp ax,32
jz mode320x32
call informat

mode1600x8:
mov es:[videomode],11ch
mov es:[scanline],1600
call show_800x8
mode1280x8:
mov es:[videomode],107h
mov es:[scanline],1280
call show_800x8

mode1280x24:
mov word ptr es:[videomode],11bh
mov word ptr es:[scanline],1280
call show_1024x24
mode1280x32:
mov word ptr es:[videomode],11bh
mov word ptr es:[scanline],1280
call show_1024x32

mode1024x8:
call  show_1024x8
mode1024x24:
mov word ptr es:[videomode],118h
mov word ptr es:[scanline],1024
call show_1024x24
mode1024x32:
mov word ptr es:[videomode],118h
mov word ptr es:[scanline],1024
call show_1024x32
mode800x8:
mov word ptr es:[videomode],103h
mov word ptr es:[scanline],800
call show_800x8
mode800x24:
mov word ptr es:[videomode],115h
mov word ptr es:[scanline],800
call show_1024x24
mode800x32:
mov word ptr es:[videomode],115h
mov word ptr es:[scanline],800
call show_1024x32
mode640x8:
mov word ptr es:[videomode],101h
mov word ptr es:[scanline],640
call show_800x8
mode640x24:
mov word ptr es:[videomode],112h
mov word ptr es:[scanline],640
call show_1024x24
mode640x32:
mov word ptr es:[videomode],112h
mov word ptr es:[scanline],640
call show_1024x32
mode320x8:
call show_320x8
mode320x24:
mov word ptr es:[videomode],10fh
mov word ptr es:[scanline],320
call show_1024x24
mode320x32:
mov word ptr es:[videomode],10fh
mov word ptr es:[scanline],320
call show_1024x32
ret
setvideomode endp




show_1024x8 proc near
mov ax,4f02h
mov bx,105h
int 10h
mov ax,4f06h
mov bx,0
mov cx,1024
int 10h
call setcolor
mov ax,8000h
mov ds,ax
mov ax,0a000h
mov gs,ax
mov  word ptr es:[pagenum],0

shownextpage0:
mov ax,4f05h
mov bx,0
mov dx,es:[pagenum]
int 10h
dec word ptr es:[highpagenum]
mov ax,4200h
mov bx,es:[handle]
mov cx,es:[highpagenum]
mov dx,es:[lowpagenum]
int 21h
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
mov si,0ffffh
mov di,1023
mov cx,64
copydata0:
push cx
push di
push si
mov cx,1024
copyscanline:
mov al,ds:[si]
mov gs:[di],al
dec si
dec di
loop copyscanline
pop si
pop di
pop cx
add di,1024
sub si,1024
loop copydata0
inc word ptr es:[pagenum]
cmp word ptr es:[highpagenum],0
jnz shownextpage0
call closehandle
mov ah,0
int 16h
jmp main
show_1024x8 endp




show_1024x32 proc near
mov ax,4f02h
mov bx,3
int 10h
mov ax,4f02h
mov bx,fs:[videomode]
int 10h
mov ax,4f06h
mov bx,0
mov cx,fs:[scanline]
int 10h
mov ax,8000h
mov ds,ax
mov ax,0a000h
mov gs,ax
mov word ptr fs:[pagenum],0

shownextpage1:
mov ax,4f05h
mov bx,0
mov dx,fs:[pagenum]
int 10h
dec word ptr fs:[highpagenum]
mov ax,4200h
mov bx,fs:[handle]
mov cx,fs:[highpagenum]
mov dx,fs:[lowpagenum]
int 21h
mov ax,3f00h
mov bx,fs:[handle]
mov cx,0ffffh
mov dx,0
int 21h
mov ax,3f00h
mov bx,fs:[handle]
mov cx,1
mov dx,0ffffh
int 21h

mov si,0f000h
mov di,0
mov cx,16
copydata1:
push cx
push di
push si
mov cx,4096
copyscanline1:
;dw 0c80fh==bswap eax
mov al,ds:[si]
mov gs:[di],al
inc si
inc di
loop copyscanline1
pop si
pop di
add di,4096
sub si,4096
pop cx
loop copydata1
inc word ptr fs:[pagenum]
cmp word ptr fs:[highpagenum],0
jnz shownextpage1
call closehandle
mov ah,0
int 16h
jmp main
show_1024x32 endp




show_320x8 proc near
mov ax,4f02h
mov bx,13h
int 10h
call setcolor
mov ax,8000h
mov ds,ax
mov ax,0a000h
mov gs,ax
mov ax,3f00h
mov bx,es:[handle]
mov cx,0fa00h
mov dx,0
int 21h
mov si,319
mov di,0f9ffh
mov cx,200
copydata5:
push cx
push si
push di
mov cx,320
copyscanline4:
mov al,ds:[si]
mov gs:[di],al
dec si
dec di
loop copyscanline4
pop di
pop si
add si,320
sub di,320
pop cx
loop copydata5
call closehandle
mov ah,0
int 16h
jmp main
show_320x8 endp



show_1024x24 proc near
mov ax,4f02h
mov bx,es:[videomode]
int 10h
mov ax,4f06h
mov bx,0
mov cx,es:[scanline]
int 10h
mov  word ptr es:[pagenum],0
mov ax,8000h
mov ds,ax
mov ax,0a000h
mov gs,ax
shownextpage2:
mov ax,4f05h
mov bx,0
mov dx,es:[pagenum]
int 10h
mov ax,3f00h
mov bx,es:[handle]
mov cx,49152
mov dx,0
int 21h
sub word ptr es:[lowpagenum],49152
sbb word ptr es:[highpagenum],0
mov cx,16384
mov si,0
mov di,0
copydata2:
mov al,ds:[si]
mov gs:[di],al
inc si
inc di
mov al,ds:[si]
mov gs:[di],ax
inc si
inc di
mov al,ds:[si]
mov gs:[di],ax
add di,2
inc si
loop copydata2
inc word ptr es:[pagenum]
cmp word ptr es:[highpagenum],0
jnz shownextpage2
call showlowpage
call closehandle
mov ah,0
int 16h
jmp main
show_1024x24 endp


show_800x8 proc near
mov ax,4f02h
mov bx,es:[videomode]
int 10h
mov ax,4f06h
mov bx,0
mov cx,es:[scanline]
int 10h
call setcolor
mov  word ptr es:[pagenum],0
mov ax,8000h
mov ds,ax
mov ax,0a000h
mov gs,ax
shownextpage3:
mov ax,4f05h
mov bx,0
mov dx,es:[pagenum]
int 10h
dec word ptr es:[highpagenum]
mov ax,4200h
mov bx,es:[handle]
mov cx,es:[highpagenum]
mov dx,es:[lowpagenum]
int 21h
mov ax,3f00h
mov cx,0ffffh
mov dx,0
int 21h
mov ax,3f00h
mov cx,1
mov dx,0ffffh
int 21h
mov di,0
mov si,0ffffh
mov cx,0ffffh
copydata3:
mov al,ds:[si]
mov gs:[di],al
dec si
inc di
loop copydata3
inc word ptr es:[pagenum]
cmp word ptr es:[highpagenum],0
jnz shownextpage3
call showlowpage
call closehandle
mov ah,0
int 16h
jmp main
show_800x8 endp



showlowpage  proc near
cmp word ptr es:[lowpagenum],0
jz goback0
cmp word ptr es:[bmphead+1ch],8
jz showlowpage_800x8
mov ax,4f05h
mov bx,0
mov dx,es:[pagenum]
int 10h
mov ax,3f00h
mov bx,es:[handle]
mov cx,es:[lowpagenum]
mov dx,0
int 21h
push word ptr es:[lowpagenum]
pop ax
mov bx,3
div bx
mov cx,ax
mov si,0
mov di,0
copylowpage0:
mov al,ds:[si]
mov gs:[di],al
inc si
inc di
mov al,ds:[si]
mov gs:[di],al
inc si
inc di
mov al,ds:[si]
mov gs:[di],al
add di,2
inc si
loop copylowpage0
jmp goback0

showlowpage_800x8:
mov ax,4f05h
mov bx,0
mov dx,es:[pagenum]
int 10h
mov ax,4200h
mov bx,es:[handle]
mov cx,0
mov dx,0436h ;why here is not 436h??
int 21h
mov ax,3f00h
mov cx,es:[lowpagenum]
sub cx,436h
mov dx,0
int 21h
push word ptr es:[lowpagenum]
pop cx
sub cx,436h
mov si,cx
dec si
mov di,0
copylowpage1:
mov al,ds:[si]
mov gs:[di],al
inc di
dec si
loop copylowpage1
goback0:
ret
showlowpage  endp





setcolor proc near
mov ax,word ptr es:[bmphead+1ch]
cmp ax,8
jz setpalette
ret
setpalette:
mov ax,3f00h
mov bx,es:[handle]
mov cx,400h
mov dx,offset bmppalette
int 21h
mov cx,100h
mov si,offset bmppalette
mov word ptr es:[palettenum],0
cld
colorsample:
mov al,es:[palettenum]
mov dx,3c8h
out dx,al
add si,2
lodsb
shr al,2
mov dx,3c9h
out dx,al
sub si,2
lodsb
shr al,2
mov dx,3c9h
out dx,al
sub si,2
lodsb
shr al,2
mov dx,3c9h
out dx,al
add si,3
inc byte ptr es:[palettenum]
loop colorsample
RET
setcolor endp


informat proc near
mov ax,es
mov ds,ax
mov ah,9
mov dx,offset msg2
int 21h
call closehandle
mov ah,0
int 16h
jmp getfileinfo
ret
informat endp



quit proc near
mov ax,4f02h
mov bx,3
int 10h
mov ah,4ch
int 21h
quit endp

closehandle proc near
mov ax,3e00h
mov bx,es:[handle]
int 21h
ret
closehandle endp

end start