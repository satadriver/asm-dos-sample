.386p
Code segment para use16
assume cs:Code
start:

xor eax,eax
mov ax,GdtSeg
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
shl eax,4
mov dword ptr ds:[GdtBase],eax
mov word ptr ds:[CodeSelector+2],ax
shr eax,16
mov byte ptr ds:[CodeSelector+4],al

Xor eax,eax
mov ax,Pm16
shl eax,4
mov word ptr ds:[Pm16Selector+2],ax
shr eax,16
mov byte ptr ds:[Pm16Selector+4],al

Xor eax,eax
mov ax,Pm32
shl eax,4
mov word ptr ds:[Pm32Selector+2],ax
shr eax,16
mov Byte ptr ds:[Pm32Selector+4],al

mov ax,4f01h
mov cx,101h
mov di,offset VesaInfo
int 10h
mov eax,dword ptr ds:[VesaInfo+40]
mov word ptr ds:[VesaBaseSelector+2],ax
shr eax,16
mov byte ptr ds:[VesaBaseSelector+4],al
mov byte ptr ds:[VesaBaseSelector+7],ah

mov ax,4f02h
mov bx,118h
int 10h
mov ax,4f06h
mov bx,0
mov cx,1024
int 10h

mov ax,ss
shl eax,16
mov ax,sp
mov ds:[StackPtr],eax
cli
lgdt qword ptr ds:[GdtLenth]
;in al,0eeh
mov al,2
out 92h,al
mov eax,cr0
or al,1
mov cr0,eax
db 0eah
dw 0
dw 8

align 10h
DosMode:
mov ax,GdtSeg
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[StackPtr]
WaitKey:
in al,64h
test al,1
jz Waitkey
mov ah,0
int 16h
mov ax,4f02h
mov bx,3
int 10h
mov ah,4ch
int 21h
Code ends



GdtSeg segment para use16
NullSelector 		dq 0
Pm16Selector		dq 000098000000ffffh
Pm32Selector		dq 004098000000ffffh
CodeSelector		dq 004092000000ffffh
HdAudioSelector 	dq 0fecf92af4000ffffh
VesaBaseSelector	dq 00cf92000000ffffh
NormalSelector		dq 000092000000ffffh
GdtLenth		=$-NullSelector
GdtLimit		dw GdtLenth-1
GdtBase			dd 0
VesaInfo		db 100h dup (0)
StackPtr		dd 0
GdtSeg ends



Pm16 segment para use16
assume cs:Pm16
db 0eah
dw 0
dw 10h
ToDosMode:
mov ax,30h
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,cr0
and al,0feh
mov cr0,eax
jmp far ptr DosMode
Pm16 ends



Pm32 segment para use32
assume cs:Pm32
mov ax,28h
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov edi,0
mov eax,0ff000000h
mov ecx,1024*768
Fill:
stosd
add eax,1
loop Fill

mov ax,20h
mov es,ax

mov ecx,2000h
mov eax,0480h
mov edi,60h
rep stosd

db 0eah
dw offset ToDosMode
dw 0
dw 8
Pm32 ends

end start
