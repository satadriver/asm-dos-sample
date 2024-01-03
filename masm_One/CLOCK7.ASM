.386p
BmpData segment para use16
dd 4000h dup (0)
BMpData ends


Pm16 segment para use16
assume cs:Pm16
db 0eah
dw 0
dw 10h
ToDosMode:
mov ax,38h
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,cr0
and al,0feh
mov cr0,eax
jmp far ptr DosMode
Pm16Lenth dw $
Pm16 ends



Pm32 segment para use32
assume cs:Pm32
mov ax,18h
mov fs,ax
mov gs,ax
mov ax,20h
mov ds,ax
mov ax,28h
mov es,ax
mov ax,30h
mov ss,ax
mov esp,1000h

ShowAnimation:
mov ecx,200
mov esi,0
mov edi,fs:[Y]
shl edi,10
add edi,fs:[X]
Show:
push ecx
push edi
mov cx,80
rep movsd
pop edi
add edi,1024
pop ecx
loop Show

cmp byte ptr fs:[FlagX],1
jnz RightX
dec dword ptr fs:[X]
cmp dword ptr fs:[X],0
jge CheckY
mov byte ptr fs:[FlagX],0
jmp CheckY
RightX:
inc dword ptr fs:[X]
cmp dword ptr fs:[X],1024-320
jle CheckY
mov byte ptr fs:[FlagX],1

CheckY:
cmp byte ptr fs:[FlagY],1
jnz DownY
dec dword ptr fs:[Y]
cmp dword ptr fs:[Y],0
jge ToWait
mov byte ptr fs:[FlagY],0
jmp ToWait
DownY:
inc dword ptr fs:[Y]
cmp dword ptr fs:[Y],768-200
jle ToWait
mov byte ptr fs:[FlagY],1

ToWait:
mov ecx,0
WaitTime:
mov al,80h
out 43h,al
in al,42h
cmp al,0
jnz WaitTime
inc ecx
cmp ecx,2560
jnz WaitTime

in al,64h
test al,1
jnz Terminate
db 0eah
dw offset ShowAnimation
dw 0
dw 10h

Terminate:
in al,60h
cmp al,1
jnz ReturnPm16
mov byte ptr fs:[EndFlag],1
ReturnPm16:
in al,64h
test al,1
jz ReturnPm16
in al,60h
db 0eah
dw offset ToDosMode
dw 0
dw 8
Pm32Lenth dd $
Pm32 ends



Code segment para use16
assume cs:code
Org 0
NullSelector 		dq 0
Pm16Selector 		dq 000098000000ffffh
Pm32Selector 		dq 004098000000ffffh
CodeSelector  		dq 004092000000ffffh
BmpDataSelector 	dq 004092000000ffffh
VesaBaseSelector 	dq 00cf92000000ffffh
StackSelector 		dq 004092800000ffffh
NormalSelector 		dq 000092000000ffffh
GdtLenth		=$-NullSelector
GdtLimit 		dw GdtLenth-1
GdtBase 		dd 0

OldClock 	dd 0
StackPtr 	dd 0
X 		dd 0
Y 		dd 0
FlagX 		db 0
FlagY 		db 0
KbdBuf 		db 20h dup (0)
Counter 	db 0
VIdeoMode 	dw 0
VIdeoStore 	db 1000h dup (0)
EndFlag 	db 0
VesaInfo 	db 100h dup (0)
BmpName 	db 'Demo.bmp',0
Handle 		dw 0
Bmphead 	db 36h dup (0)
ColorTable 	db 400h dup (0)
msgNotFound 	db 'Not Found File!',0
msgEnd		db 'Have a Good Time!',24h

Clock:
pushad
push ds
push es
push fs
push gs
mov al,20h
out 20h,al
out 0a0h,al
mov al,0ch
out 70h,al
in al,71h

mov ax,code
mov es,ax
mov ax,40h
mov ds,ax
mov si,1eh
mov di,offset KbdBuf
mov cx,8
rep cmpsd
cmp cx,0
jnz RefreshBuf

inc byte ptr cs:[Counter]
cmp byte ptr cs:[counter],10
jbe StayNextSec
jmp ClockIntProc

RefreshBuf:
mov si,1eh
mov di,offset Kbdbuf
mov cx,8
rep movsd
mov byte ptr cs:[Counter],0

StayNextSec:
pop gs
pop fs
pop es
pop ds
popad
iret


CLockIntProc:
mov si,1eh
mov di,offset KbdBuf
mov cx,8
rep movsd
mov byte ptr cs:[Counter],0

mov ax,4f03h
int 10h
mov cs:[VideoMode],bx
cmp bx,13h
ja  SaveVesaMode

mov ax,4f04h
mov cx,0fff8h
mov dx,0
int 10h

mov ax,4f04h
mov bx,offset VideoStore
mov cx,7
mov dx,1
int 10h
jmp SetVideoMode
SaveVesaMode:
mov ax,4f04h
mov bx,offset VideoStore
mov cx,0ffh
mov dx,1
int 10h
SetVideoMode:
mov ax,4f02h
mov bx,8105h
int 10h
mov ax,4f06h
mov bx,0
mov cx,1024
int 10h


call SetColor
lgdt qword ptr cs:[GdtLimit]
cli
mov al,2
out 92h,al
mov ax,ss
shl eax,16
mov ax,sp
mov cs:[StackPtr],eax
mov eax,cr0
or al,1
mov cr0,eax
db 0eah
dw 0
dw 8

DosMode:
mov ax,code
mov es,ax
mov fs,ax
mov gs,ax
mov ax,40h
mov ds,ax
sti
lss sp,dword ptr es:[StackPtr]
cmp byte ptr es:[EndFlag],1
jnz KeepInt
in al,0a1h
or al,1
out 0a1h,al
push es
mov ax,0
mov es,ax
mov di,70h
shl di,2
push word ptr cs:[OldClock]
pop word ptr es:[si]
add di,2
push word ptr cs:[OldClock+2]
pop word ptr es:[di]
pop es
KeepInt:
mov byte ptr cs:[EndFlag],0

cmp word ptr cs:[VideoMode],13h
ja RestoreVesa
mov ax,4f02h
mov bx,cs:[VideoMode]
int 10h
mov ax,4f04h
mov bx,offset VideoStore
mov cx,7
mov dx,2
int 10h
jmp ToRestore
RestoreVesa:
;mov ax,4f02h
;mov bx,cs:[VIdeoMode]
;int 10h
mov ax,4f04h
mov bx,offset VideoStore
mov cx,0fff8h
mov dx,2
int 10h
ToRestore:
jmp StayNextSec




SetColor proc near
push ds
mov ax,code
mov ds,ax
mov si,offset ColorTable
mov al,0
mov dx,3c8h
out dx,al
mov dx,3c9h
mov cx,100h
SetADC:
lodsd
rol eax,16
shr al,2
out dx,al
rol eax,8
shr al,2
out dx,al
rol eax,8
shr al,2
out dx,al
loop SetADC
pop ds
ret
SetColor endp

Start:

call SetTimer2
call InitSelector
call ReadBmp
call SetInt
Call StayInDos

ReadBmp proc near
mov ax,3d00h
mov dx,offset BmpName
int 21h
jnc OPen
mov ah,9
mov dx,offset msgNotFound 
int 21h
mov ah,4ch
int 21h
Open:
mov ds:[Handle],ax
mov bx,ax
mov ax,3f00h
mov cx,436h
mov dx,offset Bmphead
int 21h
push ds
push es
mov ax,BmpData
mov ds,ax
mov es,ax
mov ax,3f00h
mov cx,0fa00h
mov dx,0
int 21h
mov si,0fa00h
sub si,320
mov di,0
mov cx,100
XchgPix:
push cx
push si
mov cx,80
XchgLine:
mov eax,ds:[si]
mov ebx,es:[di]
xchg eax,ebx
mov ds:[si],eax
mov es:[di],ebx
add si,4
add di,4
loop XchgLine
pop si
sub si,320
pop cx
loop XchgPix
call ClearFrame

mov ax,3e00h
mov bx,cs:[Handle]
int 21h
pop es
pop ds
ret
ReadBmp endp



InitSelector proc near
push es
pop word ptr cs:[PspSeg]
xor eax,eax
mov ax,code
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
shl eax,4
mov ds:[GdtBase],eax
mov word ptr ds:[Codeselector+2],ax
shr eax,16
mov byte ptr ds:[CodeSelector+4],al

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

xor eax,eax
mov ax,BmpData
shl eax,4
mov word ptr ds:[BmpDataSelector+2],ax
shr eax,16
mov byte ptr ds:[BmpDataSelector+4],al

mov ax,4f01h
mov di,offset VesaInfo
mov cx,101h
int 10h
mov eax,dword ptr es:[VesaInfo+40]
mov word ptr ds:[VesaBaseSelector+2],ax
shr eax,16
mov byte ptr ds:[VesaBaseSelector+4],al
mov byte ptr ds:[VEsaBaseSelector+7],ah
ret
InitSelector endp



ClearFrame proc near
mov di,0
mov cx,640
mov eax,0
rep stosd
mov di,320*192
mov cx,640
rep stosd
mov di,8
mov cx,200
ClearLine:
add di,304
stosd
stosd
stosd
stosd
loop ClearLine
ret
ClearFrame endp



SetInt Proc near
;call InstallKbdInt
cli
in al,21h
and al,0fbh
out 21h,al
in al,0a1h
and al,0feh
out 0a1h,al
mov al,0bh
out 70h,al
mov al,12h
out 71h,al
push es
mov ax,0
mov es,ax
mov di,70h
shl di,2
push word ptr es:[di]
pop word ptr ds:[OldClock]
mov ax,offset Clock
stosw
push word ptr es:[di]
pop word ptr ds:[OldClock+2]
mov ax,seg Clock
stosw
pop es
sti
ret
SetInt endp



StayIndos proc near
mov ah,9
mov dx,offset msgEnd
int 21h
mov ax,Pm16
mov fs,ax
mov ax,Pm32
mov gs,ax
mov ax,3100h
mov dx,offset Start
add dx,0fh
add dx,fs:[Pm16lenth]
add dx,0fh
add dx,word ptr gs:[Pm32Lenth]
add dx,0fh
shr dx,4
add dx,40h
add dx,1000h
push dx
pop word ptr ds:[AllocMem]
int 21h
ret
StayIndos endp


InstallKbdInt proc near
cli
push es
mov ax,0
mov es,ax
mov di,9
shl di,2
push word ptr es:[di]
pop word ptr cs:[OldKbdInt]
mov ax,offset KbdInt
stosw
push word ptr es:[di]
pop word ptr cs:[OldKbdInt+2]
mov ax,seg KbdInt
stosw
pop es
sti
ret
InStallKbdInt endp


KbdInt proc near
pushf
call dword ptr cs:[OldKbdInt]
pushad
push ds
push es
mov ax,40h
mov ds,ax
mov si,1ah
lodsw
cmp ax,word ptr ds:[1ch]
jz KbdIntRet

mov si,ax
lodsw
cmp ax,3b00h
jnz KbdIntRet

mov ax,cs:[PspSeg]
mov es,ax
mov ax,4900h
mov bx,cs:[AllocMem]
int 21h

add word ptr ds:[1ch],2
cmp word ptr ds:[1ch],3eh
jnz KbdBufNot
mov word ptr ds:[1ch],1eh
KbdBufNot:
push word ptr ds:[1ch]
pop word ptr ds:[1ah]

KbdIntRet:
pop es
pop ds
popad
iret
PspSeg 		dw 0
AllocMem	dw 0
OldKbdInt 	dd 0
KbdInt endp


SetTimer2 proc near
mov al,0b6h
out 43h,al
mov al,0
out 42h,al
out 42h,al
in al,61h
or al,1
out 61h,al
ret
SetTimer2 endp

code ends
end start