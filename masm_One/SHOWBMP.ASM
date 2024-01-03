.386p
data segment para use16
gdt0 dq 0
gdt1 dq 000098000000ffffh
gdt2 dq 004098000000ffffh
gdt3 dq 00cf92000000ffffh ;ds
gdt4 dq 00cf92000000ffffh ;data 
gdt5 dq 00cf92400000ffffh ;buffer
gdt6 dq 00cf92000000ffffh ;vesa base
gdt7 dq 004092100000ffffh ;stack
gdt8 dq 000092000000ffffh ;normal
gdtlen=$-gdt0
gdtlimit dw gdtlen-1
gdtbase dd 0

bmpnamelen db 20h
bmpnamefactlen db 0
bmpname db 20h dup (0)
bmpname1len db 20h
bmpname1factlen db 0
bmpname1 db 20h dup (0)

handle dw 0
bmpflag dw 0
filesize dd 0
reserved dd 0
dataalloc dd 0
headsize dd 0
widthpixels dd 0
height dd 0
planenum dw 0
colornum dw 0
stamptype dd 0
datasize dd 0
dibx dd 0
diby dd 0
color0 dd 0
color1 dd 0

colortable db 400h dup (0)
vesainfo db 100h dup (0)
widthbytes dd 0
SCANLINE DD 0
edipos dd 0
dataseg dw 7000h
flag dd 0
line24flag dw 0
namepos dw 0
stackptr dd 0
vesastock db 4000h dup (0)
pspSeg	dw 0
msg0 	     db   'Please input BitMap name which U want to view:',0ah,0dh,24h
msg1	    db	  'Please input BitMap name which U want to view:',0ah,0dh,24h
MSGformat   db   'Not BitMap format file,press ESC to quit,any Other key to continue...',0ah,0dh,24h
MSGnotfound db 	'Not found file,press ESC to quit,any Other key to continue...',0ah,0dh,24h
msgquit     db 	'Press ESC to quit,any other key to continue...',0ah,0dh,24h
msgnotsurport db 'Not surported color format,press ESC to quit,other keys to continue...',24h
data ends



code segment para use16
assume cs:code
start:
;call init
;call getfilename

main proc near
call init
call getfilename
toread:
call readfile
mov ax,ss
shl eax,16
mov ax,sp
push eax
pop es:[stackptr]
mov al,2
out 92h,al
cli
lgdt qword ptr es:[gdtlimit]
mov eax,cr0
or al,1
mov cr0,eax
db 0eah
dw 0
dw 8
dosmode:
mov ax,data
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[stackptr]
cmp dword ptr ds:[flag],0ffh
jnz toread
jmp quit
main endp



readfile proc near
mov ax,3d00h
mov dx,offset bmpname
int 21h
jc notfound
mov es:[handle],ax
cmp dword ptr es:[flag],0
jnz readbmpfile
mov ax,3f00h
mov bx,es:[handle]
mov cx,36h
mov dx,offset bmpflag
int 21h
cmp word ptr ds:[bmpflag],4d42h
jz isbmpfile
cmp word ptr ds:[bmpflag],6d62h
jnz notrightformat
isbmpfile:
cmp word ptr ds:[colornum],1
jz notsurport
mov eax,ds:[filesize]
cmp word ptr ds:[colornum],8
jnz modifydatasize
sub eax,400h
modifydatasize:
sub eax,36h
mov ds:[datasize],eax
call setVESAmode
mov dword ptr es:[flag],1
readbmpfile:
mov ax,es:[dataseg]
mov ds,ax
mov ax,4200h
mov bx,es:[handle]
mov cx,word ptr es:[dataalloc+2]
mov dx,word ptr es:[dataalloc]
int 21h
cmp word ptr es:[datasize+2],0
jnz readblock
cmp word ptr es:[datasize],0
jz endfile
mov ax,3f00h
mov bx,es:[handle]
mov cx,word ptr es:[datasize]
mov dx,0
int 21h
endfile:
mov dword ptr es:[flag],0ffh
jmp toret
readblock:
mov ax,3f00h
mov bx,es:[handle]
mov cx,0ffffh
mov dx,0
int 21h
mov ax,3f00h
mov cx,1
mov dx,0ffffh
int 21h
inc word ptr es:[dataalloc+2]
dec word ptr es:[datasize+2]
toret:
mov ax,3e00h
mov bx,es:[handle]
int 21h
ret
notfound:
mov ax,4f02h
mov bx,3
int 10h
mov ah,9
mov dx,offset msgnotfound
int 21h
information:
mov ah,0
int 16h
cmp al,1bh
jz toquit
jmp main
toquit:
mov ah,4ch
int 21h
notrightformat:
mov ah,9
mov dx,offset msgformat
int 21h
jmp information
notsurport:
mov ah,9
mov dx,offset msgnotsurport
int 21h
jmp information
readfile endp




init proc near
cld
push ds
xor eax,eax
xor ebx,ebx
mov ax,data
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
shl eax,4
push eax
mov bx,offset gdt0
add eax,ebx
mov ds:[gdtbase],eax
pop eax
mov word ptr ds:[gdt3+2],ax
shr eax,16
mov byte ptr ds:[gdt3+4],al
xor eax,eax
mov ax,ds:[dataseg]
shl eax,4
mov word ptr ds:[gdt4+2],ax
shr eax,16
mov byte ptr ds:[gdt4+4],al
xor eax,eax
mov ax,code1
shl eax,4
mov word ptr ds:[gdt1+2],ax
shr eax,16
mov byte ptr ds:[gdt1+4],al
xor eax,eax
mov ax,code2
shl eax,4
mov word ptr ds:[gdt2+2],ax
shr eax,16
mov byte ptr ds:[gdt2+4],al
mov ax,4f01h
mov cx,101h
mov di,offset vesainfo
int 10h
mov si,offset vesainfo
add si,40
lodsd
mov word ptr ds:[gdt6+2],ax
shr eax,16
mov byte ptr ds:[gdt6+4],al
mov byte ptr ds:[gdt6+7],ah
;mov dword ptr ds:[flag],0
pop word ptr ds:[pspSeg]
ret
init endp



getfilename proc near
mov ax,4f02h
mov bx,3
int 10h
mov ah,9
mov dx,offset msg0
int 21h
cmp word ptr ds:[namepos],0
jz togetfullname
togetname:
mov ah,0ah
mov dx,offset bmpname1len
int 21h
mov di,offset bmpname1
mov dl,ds:[bmpname1factlen]
movzx dx,dl
add di,dx
mov al,0
stosb
mov si,offset bmpname1
mov di,ds:[namepos]
mov cl,ds:[bmpname1factlen]
movzx cx,cl
inc cx
rep movsb
jmp togetnameret
togetfullname:
mov ah,0ah
mov dx,offset bmpnamelen
int 21h
std
mov si,offset bmpname
add si,20h
getnamepos:
lodsb
cmp si,offset bmpnamelen
jz togetnameret
cmp al,'\'
jnz getnamepos
add si,2
mov ds:[namepos],si
cld
mov di,offset bmpname
xor dx,dx
mov dl,ds:[bmpnamefactlen]
add di,dx
mov al,0
stosb
togetnameret:
ret
getfilename endp


setVESAmode proc near
mov ax,ds:[colornum]
cmp ax,4
jz tocolor4
cmp ax,8
jz tocolor8
cmp ax,24
jz tocolor24
cmp ax,32
jz tocolor24
tocolor4:
call color4
jmp setvesaret
tocolor8:
call color8
jmp setvesaret
tocolor24:
call color24
setvesaret:
ret
setVESAmode endp


color4 proc near
mov ax,4200h
mov bx,ds:[handle]
mov cx,0
mov dx,36h
int 21h
mov ax,3f00h
mov bx,ds:[handle]
mov cx,40h
mov dx,offset colortable
int 21h
mov ax,word ptr ds:[widthpixels]
push ax
shr ax,1
mov word ptr ds:[widthbytes],ax
pop ax
mov bx,2
mov dx,0
div bx
cmp dx,0
jz isevenline
add word ptr ds:[widthbytes],1
isevenline:
mov ax,word ptr ds:[widthbytes]
mov bx,4
mov dx,0
div bx
cmp dx,0
jz horizon4end
CMP DX,1
JZ horizon4add3
cmp dx,2
jz horizon4add2
horizon4add1:
mov ax,1
jmp horizon4OK
horizon4add2:
mov ax,2
jmp horizon4OK
horizon4add3:
mov ax,3
horizon4OK:
add ax,word ptr ds:[widthbytes]
mov word ptr ds:[widthbytes],ax
horizon4end:
cmp dword ptr ds:[widthpixels],320
jbe mode320x4
cmp dword ptr ds:[widthpixels],640
jbe mode640x4
cmp dword ptr ds:[widthpixels],800
jbe mode800x4
cmp dword ptr ds:[widthpixels],1024
jbe mode1024x4
cmp dword ptr ds:[widthpixels],1280
jbe mode1280x4below
mov ax,4f02h
mov bx,106h
int 10h
mov ax,4f06h
mov bx,0
mov cx,word ptr ds:[widthbytes]
shl cx,1
int 10h
push dword ptr ds:[widthbytes]
pop dword ptr ds:[scanline]
jmp tosetcolor16
mode1280x4below:
mov ax,4f02h
mov bx,106h
int 10h
mov ax,4f06h
mov bx,0
mov cx,1280
int 10h
mov dword ptr ds:[scanline],640
jmp tosetcolor16
mode1024x4:
mov ax,4f02h
mov bx,104h
int 10h
mov ax,4f06h
mov bx,0
mov cx,1024
int 10h
mov dword ptr ds:[scanline],512
jmp tosetcolor16
mode800x4:
mov ax,4f02h
mov bx,102h
int 10h
mov ax,4f06h
mov bx,0
mov cx,800
int 10h
mov dword ptr ds:[scanline],400
jmp tosetcolor16
mode320x4:
mode640x4:
mov ax,12h
int 10h
mov ax,4f06h
mov bx,0
mov cx,640
int 10h
mov dword ptr ds:[scanline],320
call setcolor
call showbmp320x8
jmp quit
tosetcolor16:
call setcolor
ret
color4 endp


color8 proc near
mov ax,4200h
mov bx,es:[handle]
mov cx,word ptr es:[dataalloc+2]
mov dx,word ptr es:[dataalloc]
sub dx,400h
int 21h
mov ax,3f00h
mov bx,ds:[handle]
mov cx,400h
mov dx,offset colortable
int 21h
mov ax,word ptr ds:[widthpixels]
mov word ptr ds:[widthbytes],ax
mov bx,4
mov dx,0
div bx
cmp dx,0
jz horizon8OK
CMP DX,1
JZ horizon8add3
cmp dx,2
jz horizon8add2
horizon8add1:
add word ptr ds:[widthbytes],1
jmp horizon8OK
horizon8add2:
add word ptr ds:[widthbytes],2
jmp horizon8OK
horizon8add3:
add word ptr ds:[widthbytes],3
horizon8OK:
cmp dword ptr ds:[widthpixels],320
jbe mode320x8
cmp dword ptr ds:[widthpixels],640
jbe mode640x8
cmp dword ptr ds:[widthpixels],800
jbe mode800x8
cmp dword ptr ds:[widthpixels],1024
jbe mode1024x8
cmp dword ptr ds:[widthpixels],1280
jbe mode1280x8below
mov ax,4f02h
mov bx,105h
int 10h
mov ax,4f06h
mov bx,0
mov cx,word ptr ds:[widthbytes]
int 10h
push dword ptr ds:[widthbytes]
pop dword ptr ds:[scanline]
jmp tosetcolor
mode1280x8below:
mov ax,4f02h
mov bx,107h
int 10h
mov ax,4f06h
mov bx,0
mov cx,1280
int 10h
mov dword ptr ds:[scanline],1280
jmp tosetcolor
mode1024x8:
mov ax,4f02h
mov bx,105h
int 10h
mov ax,4f06h
mov bx,0
mov cx,1024
int 10h
mov dword ptr ds:[scanline],1024
jmp tosetcolor
mode800x8:
mov ax,4f02h
mov bx,103h
int 10h
mov ax,4f06h
mov bx,0
mov cx,800
int 10h
mov dword ptr ds:[scanline],800
jmp tosetcolor
mode640x8:
mov ax,4f02h
mov bx,101h
int 10h
mov ax,4f06h
mov bx,0
mov cx,640
int 10h
mov dword ptr ds:[scanline],640
jmp tosetcolor
mode320x8:
mov ax,4f02h
mov bx,13h
int 10h
mov ax,4f06h
mov bx,0
mov cx,320       ;word ptr ds:[weight0]
int 10h
mov dword ptr ds:[scanline],320
call setcolor
call showbmp320x8
jmp quit
tosetcolor:
call setcolor
ret
color8 endp



color24 proc near
cmp word ptr ds:[colornum],24
jz setvideomode24b
mov ax,word ptr ds:[widthpixels]
shl ax,2
mov word ptr ds:[widthbytes],ax
jmp horizon24ok
setvideomode24b:
mov ax,word ptr ds:[widthpixels]
mov bx,3
mul bx
mov word ptr ds:[widthbytes],ax
mov bx,4
mov dx,0
div bx
cmp dx,0
jz horizon24ok
CMP DX,1
JZ horizon24add3
cmp dx,2
jz horizon24add2
horizon24add1:
add dword ptr ds:[widthbytes],1
mov word ptr ds:[line24flag],1
jmp horizon24OK
horizon24add2:
add dword ptr ds:[widthbytes],2
mov word ptr ds:[line24flag],2
jmp horizon24OK
horizon24add3:
add dword ptr ds:[widthbytes],3
mov word ptr ds:[line24flag],3
horizon24OK:
cmp dword ptr ds:[widthpixels],320
jbe mode320x24
cmp dword ptr ds:[widthpixels],640
jbe mode640x24
cmp dword ptr ds:[widthpixels],800
jbe mode800x24
cmp dword ptr ds:[widthpixels],1024
jbe mode1024x24
cmp dword ptr ds:[widthpixels],1280
jbe mode1280x24below
mov ax,word ptr ds:[widthpixels]
mov ax,4f02h
mov bx,118h
int 10h
mov ax,4f06h
mov bx,0
mov cx,2048;word ptr ds:[widthpixels]
int 10h
;mov eax,ds:[widthpixels]
;shl eax,2
mov dword ptr ds:[scanline],8192;eax
jmp color24ret
mode1280x24below:
mov ax,4f02h
mov bx,11bh
int 10h
mov ax,4f06h
mov bl,0
mov cx,1280
int 10h
mov dword ptr ds:[scanline],5120
jmp color24ret
mode1024x24:
mov ax,4f02h
mov bx,118h
int 10h
mov ax,4f06h
mov bl,0
mov cx,1024
int 10h
mov dword ptr ds:[scanline],4096
jmp color24ret
mode800x24:
mov ax,4f02h
mov bx,115h
int 10h
mov ax,4f06h
mov bl,0
mov cx,800
int 10h
mov dword ptr ds:[scanline],3200
jmp color24ret
mode640x24:
mov ax,4f02h
mov bx,112h
int 10h
mov ax,4f06h
mov bl,0
mov cx,640
int 10h
mov dword ptr ds:[scanline],2560
jmp color24ret
mode320x24:
mov ax,4f02h
mov bx,112h
int 10h
mov ax,4f06h
mov bx,0
mov cx,640
int 10h
mov dword ptr ds:[scanline],2560
color24ret:
ret
color24 endp


setcolor proc near
mov al,0
mov dx,3c8h
out dx,al
mov dx,3c9h
mov si,offset colortable
cmp word ptr ds:[colornum],8
jz set256color
mov cx,10h
jmp setpalette
set256color:
mov cx,100h
setpalette:
add si,2
lodsb
shr al,2
out dx,al
sub si,2
lodsb
shr al,2
out dx,al
sub si,2
lodsb
shr al,2
out dx,al
add si,3
loop setpalette
ret
setcolor endp

showbmp320x8 proc near
mov ax,ds
mov fs,ax
mov ax,ds:[dataseg]
mov ds,ax
mov ax,0a000h
mov es,ax
mov ax,3f00h
mov bx,fs:[handle]
mov cx,word ptr fs:[datasize]
mov dx,0
int 21h
mov si,WORD PTR fs:[datasize]
sub si,word ptr fs:[widthbytes]
mov di,0
mov cx,word ptr fs:[height]
copybmp320x8:
push cx
push si
push di
mov cx,word ptr fs:[widthbytes]
rep movsb
pop di
pop si
sub si,word ptr fs:[widthbytes]
add di,word ptr fs:[scanline]
pop cx
loop copybmp320x8
ret
showbmp320x8 endp


move proc near
mov al,36h
out 43h,al
mov ax,11931 ;11931816
out 40h,al
xchg ah,al
out 40h,al
mov si,0
mov di,0
l00:
mov cx,0
waittime:
mov al,0
out 43h,al
in al,40h
cmp al,0
jnz waittime
inc cx
cmp cx,50
jnz waittime
mov ax,4f07h
mov bx,0
mov cx,si
mov dx,di
int 10h
inc si
;inc di
cmp si,1000
jz toret0
jmp l00

toret0:
ret
move endp


quit proc near
;mov ah,0
;int 16h
;call move
;mov ax,4f04h
;mov bx,offset vesastock
;mov dx,1
;mov cx,0fh
;int 10h

mov ah,0
int 16h
mov ax,4f02h
mov bx,3
int 10h
;mov ax,4f04h
;mov bx,offset vesastock
;mov cx,0fh
;mov dx,2
;int 10h
;mov ah,0
;int 16h
;mov ax,4f02h
;mov bx,3
;int 10h
mov ax,data
mov ds,ax
mov es,ax
mov ah,9
mov dx,offset msgquit
int 21h
mov dword ptr ds:[edipos],0
mov dword ptr ds:[flag],0
mov ah,0
int 16h
cmp al,1bh
jz over
jmp main
over:
mov ah,4ch
int 21h
quit endp
code ends


code1 segment para use16
assume cs:code1
mov ax,18h
mov fs,ax
mov gs,ax
mov ax,20h
mov ds,ax
mov ax,28h
mov es,ax
mov ax,38h
mov ss,ax
mov esp,1000h
cmp dword ptr fs:[flag],0ffh
jnz tocopyblock
cmp word ptr fs:[datasize],0
jz  to32bitPM
mov edi,fs:[edipos]
mov esi,0
mov cx,word ptr fs:[datasize]
movzx ecx,cx
copydetail:
mov al,ds:[esi]         ;why could't use rep movsb in PM16?????
mov es:[edi],al
inc edi
inc esi
loop copydetail
mov fs:[edipos],edi
to32bitPM:
db 0eah
dw 0
dw 10h
tocopyblock:
cld
mov edi,fs:[edipos]
mov esi,0
mov ecx,10000h
copyblock:               ;why could't use rep movsb in PM16?????
mov al,ds:[esi]
mov es:[edi],al
inc esi
inc edi
loop copyblock
mov fs:[edipos],edi
todosmode:
mov ax,40h
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,cr0
and al,0feh
mov cr0,eax
jmp far ptr dosmode
code1 ends


code2 segment para use32
assume cs:code2
cld
mov ax,28h
mov ds,ax
mov ax,30h
mov es,ax
mov ax,38h

cmp word ptr fs:[colornum],4
jz tobmpcolor16
cmp word ptr fs:[colornum],8
jz tobmpcolor256
cmp word ptr fs:[colornum],24
jz tobmpcolor24b
cmp word ptr fs:[colornum],32
jz tobmpcolor256
jmp backPM16
tobmpcolor16:
call bmpcolor16
jmp backPM16
tobmpcolor256:
call bmpcolor256
jmp backPM16
tobmpcolor24b:
call bmpcolor24b

backPM16:
db 0eah
dw offset todosmode
dw 0
dw 8


bmpcolor16 proc near
mov ecx,fs:[height]
mov esi,fs:[edipos]
sub esi,fs:[widthbytes]
mov edi,0
copydata16:
push ecx
push esi
push edi
mov ecx,fs:[widthbytes]
rep movsb
pop edi
pop esi
sub esi,fs:[widthbytes]
add edi,fs:[scanline]
pop ecx
loop copydata16
ret
bmpcolor16 endp


bmpcolor256 proc near
mov ecx,fs:[height]
mov esi,fs:[edipos]
sub esi,fs:[widthbytes]
mov edi,0
copydata:
push ecx
push esi
push edi
mov ecx,fs:[widthbytes]
rep movsb
pop edi
pop esi
sub esi,fs:[widthbytes]
add edi,fs:[scanline]
pop ecx
loop copydata
ret
bmpcolor256 endp

bmpcolor24b proc near
mov ecx,fs:[height]
mov esi,fs:[edipos]
sub esi,fs:[widthbytes]
mov edi,0
copydata24b:
push ecx
push esi
push edi
mov ecx,fs:[widthpixels]
copyline:
movsb
movsb
movsb
inc edi
loop copyline
pop edi
pop esi
sub esi,fs:[widthbytes]
add edi,fs:[scanline]
pop ecx
loop copydata24b
ret
bmpcolor24b endp
code2 ends
end start











