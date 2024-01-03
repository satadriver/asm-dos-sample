.386
data segment para use16
dd 4000h dup (0)
data ends


bitmap segment page use16
assume cs:bitmap
start:
jmp Main

DataSeg                 dw 0
PspSeg                  dw 0
handle 		             dw 0

bmpName 	             db 'Tender.bmp',0
bmpHead 	             db 36h dup (0)
ColorTable 	             db 400h dup (0)
ColorTableStore		     db 400h dup (0)
msgInit 		         db 'This progpram will demonstrate you of 320x200x256 BITMAP',0ah,0dh,24h
msg_notfound 	         db 'not found file,press any key to quit',0ah,0dh,24h
msgAllocError           db 'Reallocation error!',0ah,0dh,24h
msgLoadSuccess          db 'Successfully loadind Program!',0ah,0dh,24h


Main proc near
;call ReallocMemory

call SetTimer
call OpenFile

call ShowBMp

call LeftToRight

call XchgUpDown

call XchgLeftRight

call ClearCenTOside

call Quit
Main endp



OpenFile proc near
push es                    
pop word ptr cs:[PspSeg]
mov ax,cs
mov ds,ax
mov es,ax
mov ax,40h
mov fs,ax
mov gs,ax
mov ax,data
mov cs:[dataSeg],ax

mov ah,9
mov dx,offset msgInit
int 21h
mov ah,0
int 16h
cmp al,1bh
jz toquit
openhandle:
mov ax,3d00h
mov dx,offset bmpname
int 21h
jnc FindFile
mov ah,9
mov dx,offset msg_notfound
int 21h
mov ah,0
int 16h
toquit:
call quit
FindFile:
mov ds:[handle],ax
mov bx,ax
mov ax,3f00h
mov cx,436h
mov dx,offset bmphead
int 21h

mov si,offset ColorTable
mov di,offset cOlorTableStore
mov cx,100h
rep movsd

call setVideomode

mov ax,cs:[DataSeg]
mov ds,ax
mov ax,0a000h
mov es,ax
mov ax,3f00h
mov bx,cs:[handle]
mov cx,0fa00h
mov dx,0
int 21h

mov si,0fa00h
sub si,320
mov di,0
mov cx,100
reverse:
push cx
push di
push si

mov cx,80
reverseline:
mov eax,ds:[si]
mov ebx,ds:[di]
xchg eax,ebx
mov ds:[si],eax
mov ds:[di],ebx
add si,4
add di,4
loop reverseline

pop si
pop di
sub si,320
add di,320
pop cx
loop reverse

mov ax,3e00h
mov bx,cs:[handle]
int 21h
ret
OpenFile endp


  
ShowBmp proc near 
mov di,0
mov si,0
mov cx,0fa00h
rep movsb

mov ah,0
int 16h
call SetDac

push ds
mov ax,cs
mov ds,ax
mov si,offset ColorTable
call far ptr SetColor
pop ds

mov di,0
mov al,0
mov cx,0fa00h
rep stosb
ret
ShowBMp endp



LeftToRight proc near
mov cx,320
mov si,0
mov di,0
ColumnLeftToright:
push cx
push si
push di
mov cx,200
LeftColumn:
movsb
add si,319
add di,319
loop leftColumn
call waitTimeLong
pop di
pop si
inc si
inc di 
pop cx
loop ColumnLeftToright
mov ah,0
int 16h
ret
LeftToRight endp



XchgUpDown proc near
mov si,0
mov di,0fa00h
mov cx,0fa00h
shr cx,1
XchgPixel:
push cx
mov al,es:[si]
mov bl,es:[di]
xchg al,bl
mov es:[si],al
mov es:[di],bl
inc si
dec di
call waitTimeshort
pop cx
loop XchgPixel
mov ah,0
int 16h
ret
XchgUpDown endp



XchgLeftRight proc near
mov cx,160
mov si,0
mov di,319
changeAllColumn:
push cx
push si
push di
mov cx,200
xchgColumn:
mov al,es:[di]
mov ah,es:[si]
xchg al,ah
mov es:[di],al
mov es:[si],ah
add di,320
add si,320
loop xchgColumn
call waitTimeLong
pop di
pop si
inc si
dec di
pop cx
loop changeAllColumn
mov ah,0
int 16h
ret
XchgLeftRight endp



ClearCenTOSide proc near
mov cx,160
mov si,159
mov di,160
SetBlackCOlumn:
push cx
push si
push di
mov cx,200
mov al,0
setblack:
mov es:[di],al
mov es:[si],al
add di,320
add si,320
loop setblack
call waitTimeLong
pop di
inc di
pop si
dec si
pop cx
loop SetBlackCOlumn
ret
ClearCenTOSide endp


SetDac proc near
pushad
push ds
push es
mov ax,cs
mov ds,ax
mov es,ax
ResetAdc:
mov cx,100h
mov si,offset ColorTableStore
mov di,si
ChgAdc:
lodsd
add eax,01010101h
stosd
loop ChgAdc

pushad
push ds
push es
mov si,offset COlorTableStore
call far ptr SetColor
pop es
pop ds
popad

pushad
call WaitTimeLong
popad

mov ah,1
int 16h
jnz SetDacReturn
jmp ResetAdc
SetDacReturn:
pop es
pop ds
popad
ret
SetDac endp


WaitTImeshort proc near
in al,42h
cmp al,0
jnz waitTimeShort
ret
WaitTImeshort endp



WaitTImeLong proc near
mov cx,0
shortT:
in al,40h
cmp al,0
jnz shortT
inc cx
cmp cx,50
jnz shortT
ret
WaitTImeLong endp


setcolor proc far
;lea si,cs:[colortable]
mov cx,100h
mov al,0
mov dx,3c8h
out dx,al
cld
mov dx,3c9h
setpalette:
add si,2
lodsb
;shr al,2
out dx,al
sub si,2
lodsb
;shr al,2
out dx,al
sub si,2
lodsb
;shr al,2
out dx,al
add si,3
loop setpalette
retf
setcolor endp


setTimer proc near
in al,61h
or al,1
out 61h,al
cli
mov al,0b6h
out 43h,al
mov ax,8000h
out 42h,al
xchg ah,al
out 42h,al
sti
ret
SetTImer endp



ReallocMemory proc near
push es                    
pop word ptr cs:[PspSeg]
mov ax,cs
mov ds,ax
mov ax,40h
mov fs,ax
mov gs,ax

mov ax,4a00h
mov bx,cs:[BitMapLen]
add bx,0fh
shr bx,4
add bx,10h
int 21h

jc no_alloc_mem
mov ax,4800h
mov bx,1000h
int 21h
jc no_alloc_mem
mov cs:[dataseg],ax
mov ax,4900h
mov bx,cs:[dataseg]
mov es,bx
int 21h
jmp Realloc_Return
no_alloc_mem:
mov ah,9
mov dx,offset msgAllocError
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h
Realloc_Return:
mov ah,9
mov dx,offset msgLoadSuccess
int 21h
ret
ReallocMemory endp



SetVideoMode proc near
mov ax,13h
int 10h
mov si,offset ColorTable
call far ptr setcolor   ;设置颜色寄存器必须要在设置显示模式之后，因为BIOS调用回清除所有原来的显示设置
ret
SetVideoMode endp



quit proc near
mov ax,3
int 10h
mov ah,4ch
int 21h
ret
quit endp


BitMapLen   dw  $
bitmap ends
end start
