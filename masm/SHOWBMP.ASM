.386p
Stack segment stack
db 1000h dup (0)
stack ends

BmpDataSeg segment para 
dd 4000h dup (0)
bmpDataSeg ends


data segment para use16
NUllSelector        dq 0
Pm16Seg		=$-NullSelector
Pm16Selector        dq 000098000000ffffh
Pm32Seg		=$-NullSelector
Pm32Selector        dq 004098000000ffffh
ParaSeg		=$-NullSelector
ParaSelector        dq 00cf92000000ffffh
Pm32BmpDataSeg	=$-NullSelector
BmpDataSelector     dq 00cf92000000ffffh
BmpBufferSeg	=$-NullSelector 
BmpBufferSelector   dq 10cf92000000ffffh
VesaBaseSeg	=$-NullSelector
VesaBaseSelector    dq 00cf92000000ffffh
StackSeg	=$-NullSelector
StackSelector       dq 004092100000ffffh
Rm16Seg		=$-NullSelector
Rm16Selector        dq 000092000000ffffh
gdtlen              =$-NullSelector
gdtlimit            dw gdtlen-1
gdtbase             dd 0

bmpnamelimitlen     db 80h
bmpnamefactlen      db 0
bmpname             db 80h dup (0)
handle              dw 0
SearchHandle	    dw 0
SearchPos	    dw 0

bmpflag             dw 0            ;BMP header struct
filesize            dd 0
reserved            dd 0
dataalloc           dd 0
headsize            dd 0
widthpixels         dd 0
height              dd 0
planenum            dw 0
colornum            dw 0
stamptype           dd 0
datasize            dd 0
dibx                dd 0
diby                dd 0
colorTotal          dd 0
colorImportant      dd 0

colortable          db 400h dup (0)
vesainfo            db 100h dup (0)
widthbytes          dd 0
SCANLINE            dd 0
edipos              dd 0
dataseg             dw 0
flag                dd 0
line24flag          dw 0
stackptr            dd 0
PspSeg              dw 0

IndexNum            dw 0
CurrentIndex        dw 0
AllName             db 4000h dup (0)
NameLenth           db 200h dup (0)
ColorGreen          db 0ah
ColorRed	    db 0Ch
ColorbLUE	    db 9
ColorBack	    db 4ah
CursorPos	    dw 0



Rect                db 0dah
                    db 78 dup (0c4h)
                    db 0bfh

                    db 0b3h
msgquitline0        db 'ARE YOU SURE TO QUIT THIS PROGRAM?'
TAB0=$-msgQuitLine0
                    db 78-tab0 dup (20h)
                    db 0b3h
                    
                    db 0b3h
msgquitline1        db 'PRESS "Y" OR "y" TO CONFIRM QUIT'
tab1=$-msgquitLIne1                    
                    db 78-tab1 dup (20h)
                    db 0b3h

                    db 0b3h
                    db 25 dup (20h)
OK                  db 'YES'
                    db 23 dup (20h)
CANCEL              db 'NO'
                    db 25 dup (20h)
                    db 0b3h

                    db 0b3h
msgQuitline2        db 'HAVE A GOOD TIME! BYEBYE!'
tab2=$-msgquitLIne2
                    db 78-Tab2 dup (20h)
                    db 0b3h
                    
                    db 0c0h
                    db 78 dup (0c4h)
                    db 0d9h



msgInput 	   db 'Please Input BitMap DIRECTORY Which U Want to Browse:',0ah,0dh,24h
  	                                                        
msgNotsurport      db 'Not surported color format,press ESC to quit,other keys to continue...',0ah,0dh,24h
msgNotBmpFormat    db 'Not BitMap format file,press ESC to quit,any Other key to continue...',0ah,0dh,24h
msgNotFound        db 'Not Found File,Press ESC to Quit,Any Other Key to Continue...',0ah,0dh,24h
msgNoMem	   db 'MEMORY Reallocation Failure!',0ah,0dh,24h
msgLoadSuccess     db 'Successfully Load Program! Have a Fun!',0dh,0ah
msgTip		   db 'Press -> or <- ,LEFT or RIGHT to choose the file',0ah,0dh,24h
datalenth          dw $
data ends



code segment para use16
assume cs:code
start:
;call ReallocMemory
;call InitSelector
mov ax,data
mov ds,ax
push es
pop word ptr ds:[PspSeg]

Main proc near
call GetFileName
toShow:
call InitSelector
call ShowBmpName
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
dw Pm16Seg
dosmode:
mov ax,data
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
lss sp,dword ptr ds:[stackptr]
sti
cmp dword ptr ds:[flag],0ffh
jnz toread
mov ah,0
int 16h
jmp toShow
main endp



ReallocMemory proc near
mov ax,data
mov ds,ax
mov ax,es                    ;sub ax,10h is wrong!!!at the beginning,the psp is equal to es and ds
mov ds:[PspSeg],ax
push ax

mov ax,code
mov es,ax
mov ax,Pm16
mov fs,ax
mov ax,Pm32
mov gs,ax
mov ax,4a00h
mov bx,ds:[datalenth]
add bx,es:[codelenth]
add bx,fs:[Pm16lenth]
add bx,word ptr gs:[Pm32lenth]
add bx,40h
shr bx,4
add bx,40h
pop es
int 21h
jc no_alloc_mem
mov ax,4800h
mov bx,2000h
int 21h
jc no_alloc_mem
and ax,0f000h
add ax,1000h
mov ds:[dataseg],ax
jmp Realloc_Return
no_alloc_mem:
mov ah,9
mov dx,offset msgNoMem
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h
Realloc_Return:
mov ax,4900h
mov bx,ds:[dataseg]
mov es,bx
int 21h
mov ah,9
mov dx,offset msgLoadSuccess
int 21h
ret
ReallocMemory endp



readfile proc near
mov ax,3d00h
mov dx,offset bmpname
int 21h
jc notfound
mov ds:[handle],ax
cmp dword ptr ds:[flag],0
jnz readbmpfile
mov ax,3f00h
mov bx,ds:[handle]
mov cx,36h
mov dx,offset bmpflag
int 21h
cmp word ptr ds:[bmpflag],4d42h
jz Isbmp
cmp word ptr ds:[bmpflag],6d62h
jz IsBmp
cmp word ptr ds:[BmpFlag],4d62h
jz IsBmp
cmp word ptr ds:[BmpFlag],6d42h
jnz notBMPformat
Isbmp:
mov eax,ds:[filesize]
cmp word ptr ds:[colornum],1
jnz check4bit
sub eax,3eh
mov ds:[datasize],eax
jmp toSetBmpVesaMode
check4bit:
cmp word ptr ds:[colornum],4
jnz Check8or24bit
sub eax,76h
mov ds:[datasize],eax
jmp tosetbmpvesamode
Check8or24bit:
cmp word ptr ds:[colornum],8
jnz check24bit
sub eax,400h
check24bit:
sub eax,36h
mov ds:[datasize],eax
tosetbmpvesamode:
call setVESAmode
mov dword ptr ds:[flag],1
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
jmp ReadFileReturn
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
ReadFileReturn:
mov ax,3e00h
mov bx,es:[handle]
int 21h
ret

notfound:
mov ax,es
mov ds,ax
mov ax,3
int 10h
mov ah,9
mov dx,offset msgNotFound
int 21h
jmp toMain

notBMPformat:
mov ax,es
mov ds,ax
mov ax,3
int 10h
mov ah,9
mov dx,offset msgNOtBmpFormat
int 21h
toMain:
mov ah,0
int 16h
cmp al,1bh
jnz ToMainProc
jmp quit
ToMainProc:
add sp,2
jmp main

notsurport:
mov ax,es
mov ds,ax
mov ax,3
int 10h
mov ah,9
mov dx,offset msgNotSurport
int 21h
jmp ToMain
readfile endp




initSelector proc near
cld
xor eax,eax
mov ax,data
mov ds,ax
;push es
;pop word ptr ds:[PspSeg]
mov es,ax
mov fs,ax
mov gs,ax
shl eax,4
mov ds:[gdtbase],eax
mov word ptr ds:[ParaSelector+2],ax
shr eax,16
mov byte ptr ds:[ParaSelector+4],al
mov byte ptr ds:[ParaSelector+7],ah

xor eax,eax
mov ax,BmpDataSeg
mov ds:[dataSeg],ax
shl eax,4
mov word ptr ds:[BmpDataSelector+2],ax
shr eax,16
mov byte ptr ds:[BmpDataSelector+4],al
mov byte ptr ds:[BmpDataSelector+7],ah

xor eax,eax
mov ax,Pm16
shl eax,4
mov word ptr ds:[Pm16Selector+2],ax
shr eax,16
mov byte ptr ds:[Pm16Selector+4],al

xor eax,eax
mov ax,Pm32
shl eax,4
mov word ptr ds:[Pm32Selector+2],ax
shr eax,16
mov byte ptr ds:[Pm32Selector+4],al

mov ax,4f01h
mov cx,101h
mov di,offset vesainfo
int 10h
mov si,offset vesainfo
add si,40
lodsd
mov word ptr ds:[VesaBaseSelector+2],ax
shr eax,16
mov byte ptr ds:[VesaBaseSelector+4],al
mov byte ptr ds:[VesaBaseSelector+7],ah
mov dword ptr ds:[flag],0
ret
initSelector endp




getfilename proc near
mov ax,data
mov ds,ax
;push es
;pop word ptr ds:[PspSeg]
mov es,ax
mov fs,ax
mov gs,ax
mov ah,9
mov dx,offset msgLoadSuccess
int 21h

mov ah,9
mov dx,offset msgInput
int 21h
mov ah,0ah
mov dx,offset BmpNameLimitLen
int 21h
mov bl,ds:[bmpnamefactlen]
movzx bx,bl
cld
dec bx
cmp byte ptr ds:[bmpname+bx],5ch
jz EndDIrectory
inc bx
mov byte ptr ds:[bmpname+bx],5ch
EndDIrectory:
inc bx
add bx,offset bmpname
mov ds:[SearchPos],bx
mov di,bx
mov eax,6d622e2ah  ;mb.*
stosd
mov ax,0070h
stosw

SearchFirst:
mov ax,4e00h
mov cx,0
mov dx,offset BmpName
int 21h
jc SearchFail
mov es:[SearchHandle],bx
push ds
mov ax,es:[PspSeg]
mov ds,ax
mov di,offset AllName
mov bx,0

SearchNext:
mov si,9eh
MoveName:
lodsb
stosb
cmp al,0
jnz MOveName
sub si,9eh
mov word ptr es:[NameLenth+bx],si
add bx,2
mov ax,4f00h
int 21h
jnc SearchNext

pushad
mov ax,3e00h
mov bx,es:[SearchHandle]
int 21h
popad

sub bx,2
mov es:[IndexNum],bx
mov word ptr es:[di],2424h
mov word ptr es:[CurrentIndex],0
mov word ptr es:[CursorPos],0
pop ds
ret
SearchFail:
mov ah,9
mov dx,offset msgNotFound
int 21h
add sp,2
jmp ToMain
getfilename endp




ShowBmpName proc near
mov ax,4f02h
mov bx,3
int 10h
push es
mov ax,0b800h
mov es,ax
mov di,0
mov si,offset ALlName
ShowName:
lodsb
cmp al,24h
jz endShowName
mov ah,ds:[coloRGREEN]
stosw
jmp ShowName
endShowName:
pop es
MOV AX,0B800H
MOV FS,AX
MOV GS,AX

GetAkey:
mov bx,ds:[CursorPos]
mov al,0eh
mov ah,bh
mov dx,3d4h
out dx,ax
mov al,0fh
mov ah,bl
mov dx,3d4h
out dx,ax

shl bx,1
mov di,bx
mov al,ds:[ColorRED]
SetFocus:
inc di
MOV FS:[DI],AL
inc di
cmp byte ptr fs:[di],0
jnz setFocus

mov ah,0
int 16h
cmp al,1bh
jnz notQuit
call quit
jmp Getakey
NotQuit:
cmp al,0dh
jz ToShowBmp
cmp ah,50h
jz Down
cmp ah,48h
jz Up
cmp ah,4dh
jz Right
cmp ah,4bh
jz Left
jmp GetaKey

Up:
sub word ptr ds:[currentIndex],10h
JMP LeftProc
Down:
add word ptr ds:[CUrrentIndex],10h
jmp RightProc
Right:
add word ptr ds:[CurrentIndex],2
RightProc:
mov ax,ds:[IndexNum]
cmp ax,word ptr ds:[CurrentIndex]
ja NotEnd
push ax
pop word ptr ds:[CurrentIndex]
notEnd:
jmp GetCursorPos
Left:
sub word ptr ds:[CurrentIndex],2
LeftProc:
cmp word ptr ds:[CurrentIndex],0
jge GetCursorPos
mov word ptr ds:[CUrrentIndex],0
GetCursorPos:
mov bx,0
mov si,offset Namelenth
mov di,ds:[CurrentIndex]
cmp di,0
jz REsetCursor
add di,si
CalcPos:
lodsw
add bx,ax
cmp si,di
jnz CalcPos
REsetCursor:
push bx
;mov ds:[CursorPos],bx
mov di,ds:[CursorPos]
shl di,1
ClearFocus:
inc di
mov al,ds:[colorGreen]
mov fs:[di],al
inc di
cmp byte ptr fs:[di],0
jnz clearFocus
pop word ptr ds:[CursorPos]
jmp GetAkey

ToShowBmp:
mov bx,0
mov si,offset NameLenth
mov di,ds:[CurrentIndex]
add di,offset NameLenth
cmp word ptr ds:[CurrentIndex],0
jz FirstBmp
GetNameAddr:
lodsw
add bx,ax
cmp si,di
jnz GetNameAddr
FirstBmp:
mov cx,ds:[si]
mov si,offset AllName
add si,bx
mov di,ds:[SearchPos]
rep movsb
ret
ShowBmpName endp




setVESAmode proc near
mov ax,ds:[colornum]
cmp ax,1
jz tocolor1bit
cmp ax,4
jz tocolor4bit
cmp ax,8
jz tocolor8bit
cmp ax,24
jz tocolor24bit
cmp ax,32
jz tocolor24bit

tocolor1bit:
call color1bit
jmp setvesaret
tocolor4bit:
call color4bit
jmp setvesaret
tocolor8bit:
call color8bit
jmp setvesaret
tocolor24bit:
call color24bit
setvesaret:
ret
setVESAmode endp



;1 经过4F01/INT 10H 检验2色/1位不被VESA标准支持！VBE中无法设置此种显示方式,这里采用256色的方式模拟1位色
;2 在8位及以下的显示方式中BMP数据区的内容实际为DAC调色板寄存器的索引号，而不是24位模式中的颜色分量
;3 2色1位模式下一个字节包含8个像素的索引，第一个像素索引为第8位，即反向显示
;4 水平分辨率>640的16色模式是不分页的，一个字节的低四位为第1个像素的DAC调色板索引号，高四位为第2个像素的DAC调色板索引号
;5 640x480x16色的显示情况下需要分页面显示，为求简单没有很好的支持，有兴趣的可以自己查看资料重新编写此种模式
;6 VESA 24位及32位显示模式下没有硬件开启ALPHA值，所以不能通过ALPHA值实现淡入淡出的效果
;7 VESA的最大分辨率为105H或118H模式下的1024X768分辨率，其最大扫描线可以达到2564像素


color1bit proc near
mov ax,4200h
mov bx,ds:[handle]
mov cx,0
mov dx,36h
int 21h
mov ax,3f00h
mov bx,ds:[handle]
mov cx,8
mov dx,offset colortable
int 21h

mov ax,word ptr ds:[widthpixels]
mov bx,8
mov dx,0
div bx
cmp dx,0
jz CalcWIdth
inc ax
calcWidth:
mov word ptr ds:[widthbytes],ax
mov bx,4
mov dx,0
div bx
cmp dx,0
jz horizon1end
mov ax,4
sub ax,dx
add word ptr ds:[widthbytes],ax
horizon1end:
cmp dword ptr ds:[widthpixels],640
jbe mode640x1
cmp dword ptr ds:[widthpixels],800
jbe mode800x1
cmp dword ptr ds:[widthpixels],1024
jbe mode1024x1
cmp dword ptr ds:[widthpixels],1280
jbe mode1280x1below
jmp mode1024x1 
mode1280x1below:
mov ax,4f02h
mov bx,105h
int 10h
mov ax,4f06h
mov bx,0
mov cx,1024
int 10h
mov dword ptr ds:[scanline],1024
jmp tosetcolor2
mode1024x1:
mov ax,4f02h
mov bx,105h
int 10h
mov ax,4f06h
mov bx,0
mov cx,1024
int 10h
mov dword ptr ds:[scanline],1024
jmp tosetcolor2
mode800x1:
mov ax,4f02h
mov bx,103h
int 10h
mov ax,4f06h
mov bx,0
mov cx,800
int 10h
mov dword ptr ds:[scanline],800
jmp tosetcolor2
mode640x1:
mov ax,4f02h
mov bx,101h
int 10h
mov ax,4f06h
mov bx,0
mov cx,640
int 10h
mov dword ptr ds:[scanline],640
tosetcolor2:
call setcolor
ret
color1bit endp



;经过4F01/INT 10H 检验16色/4位不被VESA标准支持！VBE中无法设置此种显示方式！这里采用256色的方式模拟16色
;但是640X480X16色不支持此中方法

color4bit proc near
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
mov bx,2
mov dx,0
div bx
add ax,dx
mov word ptr ds:[widthbytes],ax
mov bx,4
mov dx,0
div bx
cmp dx,0
jz horizon4end
mov ax,4
sub ax,dx
add word ptr ds:[widthbytes],ax
horizon4end:

cmp dword ptr ds:[widthpixels],640
jbe mode640x4
cmp dword ptr ds:[widthpixels],800
jbe mode800x4
cmp dword ptr ds:[widthpixels],1024
jbe mode1024x4
cmp dword ptr ds:[widthpixels],1280
jbe mode1280x4below
jmp mode1024x4

mode1280x4below:
mov ax,4f02h
mov bx,107h
int 10h
mov ax,4f06h
mov bx,0
mov cx,1280
int 10h
mov dword ptr ds:[scanline],1280
jmp tosetcolor16
mode1024x4:
mov ax,4f02h
mov bx,105h
int 10h
mov ax,4f06h
mov bx,0
mov cx,1024
int 10h
mov dword ptr ds:[scanline],1024
jmp tosetcolor16
mode800x4:
mov ax,4f02h
mov bx,103h
int 10h
mov ax,4f06h
mov bx,0
mov cx,800
int 10h
mov dword ptr ds:[scanline],800
call setcolor
mode640x4:
mov ax,4f02h
mov bx,12h
int 10h
mov ax,4f06h
mov bx,0
mov cx,320			;;;
int 10h
mov dword ptr ds:[scanline],320 ;;;
tosetcolor16:
call setcolor
ret
color4bit endp



color8bit proc near
mov ax,4200h
mov bx,ds:[handle]
mov cx,word ptr ds:[dataalloc+2]
mov dx,word ptr ds:[dataalloc]
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
mov ah,0
int 16h
jmp ToShow
tosetcolor:
call setcolor
ret
color8bit endp



color24bit proc near
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
mov ax,4f02h
mov bx,118h
int 10h
xor ecx,ecx
mov ax,4f06h
mov bx,3
int 10h
mov ax,4f06h
mov bx,0
int 10h
shl ecx,2
mov dword ptr ds:[scanline],ecx
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
color24bit endp


setcolor proc near
mov al,0
mov dx,3c8h
out dx,al
mov dx,3c9h
mov si,offset colortable
cmp word ptr ds:[colornum],1
jz set2color
cmp word ptr ds:[colornum],4
jz set16color
cmp word ptr ds:[colornum],8
jz set256color

set2color:
mov cx,2
jmp setpalette
set16color:
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



quit proc near
pushad
push ds
push es
mov ax,data
mov ds,ax
mov ax,0b800h
mov es,ax
mov di,2880
push di
mov si,offset Rect
mov cx,480
push cx
mov ah,ds:[colorBack]
showQuit:
lodsb
stosw
loop showQuit

ToGetKey:
mov ah,0
int 16h
cmp al,'y'
jz overProg
cmp al,'Y'
jz overProg

pop cx
pop di
mov ax,720h
rep stosw
pop es
pop ds
popad
ret
OverProg:
mov ax,3
int 10h
add sp,36
jmp Main
mov ah,4ch
int 21h
quit endp

codelenth dw $
code ends



Pm16 segment para use16
assume cs:Pm16
mov ax,ParaSeg
mov fs,ax
mov gs,ax
mov ax,Pm32BmpDataSeg
mov ds,ax
mov ax,BmpBufferSeg
mov es,ax
mov ax,StackSeg
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
dw Pm32Seg
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
mov ax,Rm16Seg
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,cr0
and al,0feh
mov cr0,eax
jmp far ptr dosmode
Pm16lenth dw $
Pm16 ends


Pm32 segment para use32
assume cs:Pm32
cld
mov ax,BmpBufferSeg
mov ds,ax
mov ax,VesaBaseSeg
mov es,ax
cmp word ptr fs:[colornum],1
jz tobmpcolor2
cmp word ptr fs:[colornum],4
jz tobmpcolor16
cmp word ptr fs:[colornum],8
jz tobmpcolor256
cmp word ptr fs:[colornum],24
jz tobmpcolor24b
cmp word ptr fs:[colornum],32
jz tobmpcolor256
jmp backPM16
tobmpcolor2:
call bmpcolor2
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
dw Pm16Seg


bmpcolor2 proc near
mov ecx,fs:[height]
mov esi,fs:[edipos]
sub esi,fs:[widthbytes]
mov edi,0
copydata2:
push ecx
push esi
push edi
mov ecx,fs:[widthbytes]
copydata2line:
		;caution:1 byte contain 8 pixels in 1bit color BMP
		;the first Picture Element is in MSB(=D7)
		;the second pixel is in bit6(=D6)
		;the third pixel is in bit5(=D5)
		;......
		;the eightth(last pixel) is in the LSB(=D0)
push ecx
lodsb
mov ecx,7
bitTobyte:
push ax
shr al,cl
and al,1
stosb
pop ax
loop bitTobyte
and al,1
stosb
pop ecx
loop copydata2line

pop edi
pop esi
sub esi,fs:[widthbytes]
add edi,fs:[scanline]
pop ecx
loop copydata2
ret
bmpcolor2 endp


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

cmp word ptr fs:[scanline],320		;;;
jnz copydata16line
rep movsb
jmp bmpVesa16
copydata16line:
lodsb
mov bl,al
and al,0fh
stosb
mov al,bl
shr al,4
and al,0fh
stosb
loop copydata16line
BmpVesa16:
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

Pm32lenth   dd $                     
Pm32 ends
end start