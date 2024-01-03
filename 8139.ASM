.386p

DataSeg	segment para use16
NullDesc	dq 0
NormalSeg	dq 0000092000000ffffh
NetRecvSeg	dq 04000920000003fffh
NetSendSeg	dq 0f000920040000fffh
PmCode16Seg	dq 0000098000000ffffh
PmCode32Seg	dq 000cf98000000ffffh
PmStack32Seg	dq 000cf92400000ffffh
PmVideoSeg	dq 00000920b8000ffffh

szInitOk	db 'Init Ok!',0dh,0ah,24h
StackPtr	dd 0

GdtLen 		dw 7fh
GdtBase		dd 0
DataSeg ends





PmCode16 segment para use16
assume cs:PmCode16
ToPm16:
db 0eah
dw offset ToPm32
dw 28h 

ToRm16:
mov ax,8
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov eax,cr0
and al,0feh
mov cr0,eax
db 0eah
dw offset DosMode
dw seg DosMode
PmCode16 ends






PmCode32 segment para use32
assume cs:PmCode32
ToPm32:
mov ax,10h
mov ds,ax
mov ax,38h
mov es,ax
mov ax,30h
mov ss,ax
mov esp,1000h

mov ecx,2000
mov edi,0
mov ax,4200h
rep stosw

ToShow:
mov dx,0e037h
mov al,10h
out dx,al
WaitInit:
in al,dx
test al,10h
jnz WaitInit

in al,60h
cmp al,1
jz ToQuit

mov dx,0e040h
mov eax,08fh
out dx,eax

mov dx,0e044h
mov eax,08fh
out dx,eax

mov dx,0e030h
mov eax,000000004h
out dx,eax

mov dx,0e037h
mov al,0ch
out dx,al

cld
mov ecx,1000
mov esi,0
mov edi,0
mov ah,42h
CopyData:
lodsb
mov bl,al
shr al,4
cmp al,9
jbe SmallHigh
add al,7
SmallHigh:
add al,30h
mov ah,42h
stosw
mov al,bl
and al,0fh
cmp al,9
jbe SmallLow
add al,7
SmallLow:
add al,30h
mov ah,42h
stosw
LOOP CopyData

mov eax,0ffffffffh
WaitMoment:
cmp eax,0
jz Next
dec eax
jmp WaitMoment

Next:
jmp ToShow

ToQuit:
db 0eah
dw offset ToRm16
dw 0
dw 20h
PmCode32 ends






CodeSeg segment para use16
assume cs:CodeSeg
start:

xor eax,eax
mov ax,DataSeg
mov ds,ax
mov es,ax
shl eax,4
xor ebx,ebx
mov bx,offset NullDesc
add eax,ebx
mov dword ptr ds:[GdtBase],eax

xor eax,eax
mov ax,PmCode16
shl eax,4
mov word ptr ds:[PmCode16Seg+2],ax
shr eax,16
mov byte ptr ds:[PmCode16Seg+4],al


xor eax,eax
mov ax,PmCode32
shl eax,4
mov word ptr ds:[PmCode32Seg+2],ax
shr eax,16
mov byte ptr ds:[PmCode32Seg+4],al

mov ax,ss
shl eax,16
mov ax,sp
mov ds:[StackPtr],eax
cli
lgdt qword ptr ds:[GdtLen]
mov al,2
out 92h,al
mov eax,cr0
or al,1
mov cr0,eax

db 0eah
dw offset ToPm16
dw 20h

DosMode:
mov ax,DataSeg
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[StackPtr]
mov ah,9
mov dx,offset szInitOk
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h
CodeSeg ends
end start