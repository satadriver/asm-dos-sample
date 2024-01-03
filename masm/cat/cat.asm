.386p
BmpDataSeg segment para use16
dd 4000h dup (0)
BmpDataSeg ends


Param segment page use16
NullSelector            dq 0
Pm16Selector            dq 000098000000ffffh
Pm32Selector            dq 004098000000ffffh
ParamSelector           dq 004092000000ffffh  ;Param 
BmpDataSelector         dq 00cf92000000ffffh  ;BmpDataSeg
BufSelector             dq 00cf92800000ffffh  ;Buf
VesaSelector            dq 00cf92000000ffffh  ;VesaBase
Stack32Selector         dq 004092400000ffffh  ;Stack32  A20 is Enabled??????
Rm16Selector            dq 000092000000ffffh
gdtend                  =$-NullSelector
gdtlimit                dw gdtend-1
gdtbase                 dd 0

BmpBackName             db 'Back0001.bmp',0   ;Back is 1024x768x24b Mode 

bmpFileName   	        db 'Scratc01.bmp',0   ;all BMP is 240x360x32b Mode
                        db 'Simple01.bmp',0
                        db 'Sneeze01.bmp',0
                        db 'Stomac01.bmp',0                        
bmpFileNum 	           dd 56   ;scratc
                        dd 25   ;Simple
                        dd 14   ;Sneeze
                        dd 34   ;Stomac

BmpNamePtr              dd 0
BmpNumPtr               dd 0
Count                   dd 0

handle     	            dd 0
videoscanline 	     	   dd 4096
bmpscanline   	     	   dd 960
bmphead    	             db 36h dup (0)
BmpBackHead               db 36h dup (0)
vesainfo     	     	    db 100h dup (0)
endflag    	            dd 0
stackptr   	            dd 0
edipos     	            dd 0
RMdataseg  	            dw 0
showBase1              	  dd 98576
ShowBase2                   dd 98816
ShowBase3                   dd 1573136
ShowBase4                   dd 1573376
MemoryBase                  dd 0
MemoryBase2                 dd 0
MemoryBase3                 dd 0
MemoryBase4                 dd 0
NotFound 	                  db 'Not Found File',24h
Param ends



Rm16 segment para use16
assume cs:Rm16
start:


Main proc near
call init

Rm16ReadBmpBack:
call ReadBmpBack
mov ax,ss
shl eax,16
mov ax,sp
mov dword ptr es:[stackptr],eax
cli
lgdt qword ptr es:[gdtlimit]
mov al,2
out 92h,al
mov eax,cr0
or al,1
mov cr0,eax
db 0eah
dw offset Pm16ReadBmpBack
dw 8
Rm16ReadBmpBackReturn:
mov ax,Param
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[stackptr]
inc dword ptr ds:[BmpBackHead+0ch]
cmp dword ptr ds:[BmpBackHead+0ch],36
jnz Rm16ReadBmpBack


Rm16ReadBmp:
call ReadBmp
mov ax,ss
shl eax,16
mov ax,sp
mov dword ptr es:[stackptr],eax
cli
lgdt qword ptr es:[gdtlimit]
mov al,2
out 92h,al
mov eax,cr0
or al,1
mov cr0,eax
db 0eah
dw 0
dw 8
Rm16ReadBmpReturn:
mov ax,Param
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[stackptr]
cmp dword ptr ds:[EndFlag],1
jnz Rm16ReadBmp
jmp Quit
Main endp



init proc near
xor eax,eax
mov ax,Param
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
shl eax,4
mov ds:[gdtbase],eax
mov word ptr ds:[ParamSelector+2],ax
shr eax,16
mov byte ptr ds:[ParamSelector+4],al

xor eax,eax
mov ax,BmpDataSeg
mov word ptr ds:[RMdataseg],ax
shl eax,4
mov word ptr ds:[BmpDataSelector+2],ax
shr eax,16
mov byte ptr ds:[BmpDataSelector+4],al

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
mov di,offset VesaInfo
mov cx,118h
int 10h
mov eax,dword ptr es:[vesainfo+28h]
mov word ptr ds:[VesaSelector+2],ax
shr eax,16
mov byte ptr ds:[VesaSelector+4],al
mov byte ptr ds:[VesaSelector+7],ah

push offset ds:[BmpFileName]
pop word ptr ds:[BmpNamePtr]
push offset ds:[BmpFileNum]
pop word ptr ds:[BmpNumPtr]

call readbmphead
call ReadBackHead
call SetVesaMode
ret
init endp


SetVesaMode proc near
mov ax,4f02h
mov bx,118h
int 10h
ret
setvesamode endp


ReadBackHead proc near
mov ax,3d00h
mov dx,offset bmpBackName
int 21h
jc Quit
mov bx,ax
mov ax,3f00h
mov cx,36h
mov dx,offset bmpBackhead
int 21h
mov ax,3e00h
int 21h
ret
ReadBackHead endp


readbmphead proc near
mov ax,3d00h
mov dx,offset BmpFileName
int 21h
jc Quit
mov bx,ax
mov ax,3f00h
mov cx,36h
mov dx,offset BmpHead
int 21h
mov ax,3e00h
int 21h
ret
readbmphead endp

 
ReadBmpBack proc near
mov ax,3d00h
mov dx,offset BmpBackName
int 21h
mov word ptr ds:[Handle],ax
mov bx,ax
mov ax,4200h
mov cx,word ptr ds:[BmpBackHead+0ch]
mov dx,word ptr ds:[BmpBackHead+0ah]
int 21h
mov ax,es:[RmDataSeg]
mov ds,ax
mov ax,3f00h
mov cx,0ffffh
mov dx,0
int 21h
mov ax,3f00h
mov cx,1
mov dx,0ffffh
int 21h
mov ax,3e00h
int 21h
ret
ReadBmpBack endp



ReadBmp proc near
mov ax,3d00h
mov dx,word ptr ds:[BmpNamePtr]
int 21h
jnc FoundFile
Quit:
mov ax,4f02h
mov bx,3
int 10h
mov ah,4ch
int 21h
FoundFile:
mov word ptr ds:[handle],ax
mov bx,ax
mov ax,4200h
mov cx,word ptr ds:[bmphead+0ch]
mov dx,word ptr ds:[bmphead+0ah]
int 21h
mov ax,es:[RmDataSeg]
mov ds,ax
mov ax,word ptr es:[bmphead+0ch]
cmp ax,word ptr es:[bmphead+4]
jnz readblock
readdetail:
mov ax,3f00h
mov bx,word ptr es:[handle]
mov cx,word ptr es:[bmphead+22h]
mov dx,0
int 21h
mov dword ptr es:[endflag],0ffh
jmp ReadBmpReturn
readblock:
mov ax,3f00h
mov bx,word ptr es:[handle]
mov cx,0ffffh
mov dx,0
int 21h
mov ax,3f00h
mov cx,1
mov dx,0ffffh
int 21h
inc word ptr es:[bmphead+0ch]
ReadBmpReturn:
mov ax,3e00h
mov bx,word ptr es:[handle]
int 21h
ret
ReadBmp endp
Rm16 ends



Pm16 segment para use16
assume cs:Pm16
Pm16ReadBmp:
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
mov edi,fs:[edipos]
mov esi,0
cmp dword ptr fs:[endflag],0ffh
jz copydetail

mov ecx,4000h
copyblock:
mov eax,ds:[esi]
mov es:[edi],eax
add esi,4
add edi,4
loop copyblock
mov fs:[edipos],edi

Rm16BitMode:
mov ax,40h
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,cr0
and al,0feh
mov cr0,eax
jmp far ptr Rm16ReadBmpReturn

copydetail:
mov cx,word ptr fs:[bmphead+22h]
movzx ecx,cx
copyBYTE:
mov al,ds:[esi]
mov es:[edi],al
inc esi
inc edi
loop copybyte
mov fs:[edipos],edi

setsequence:
mov edi,fs:[edipos]
mov esi,edi
sub esi,dword ptr fs:[bmpscanline]
sub edi,dword ptr fs:[bmphead+22h]
mov ecx,dword ptr fs:[bmphead+16h]
shr ecx,1
exchangecolumn:
push ecx
push esi
push edi
mov ecx,dword ptr fs:[bmphead+12h]
xchgline:
mov eax,es:[esi]
mov ebx,es:[edi]
xchg eax,ebx
mov es:[esi],eax
mov es:[edi],ebx
add esi,4
add edi,4
loop xchgline
pop edi
pop esi
pop ecx
sub esi,fs:[bmpscanline]
add edi,fs:[bmpscanline]
loop exchangecolumn

mov esi,fs:[BmpNamePtr]
add esi,6
mov ax,word ptr fs:[esi]
cmp ah,39h
jz decimal
inc ah
jmp NextBmpName
Decimal:
inc al
mov ah,30h 
NextBmpName:
mov word ptr fs:[esi],ax

mov dword ptr fs:[EndFlag],0
mov word ptr fs:[BmpHead+0ch],0
mov eax,fs:[BmpNumPtr]
cmp eax,fs:[Count]
jz  NextWindow
inc dword ptr fs:[Count]
ToRm16BitMode:
db 0eah
dw offset Rm16BitMode
dw 8
NextWindow:
mov dword ptr fs:[Count],0
mov eax,fs:[BmpNumPtr]
sub eax,fs:[BmpFileNum]
cmp eax,16
jz ToPm32BitMode
add dword ptr fs:[BmpNumPtr],4
jmp ToRm16BitMode
toPm32BitMode:
db 0eah
dw 0
dw 10h

Pm16ReadBmpBack:
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
mov ecx,4000h
mov edi,fs:[EdiPos]
mov esi,0
CopyBackBlock:
mov eax,ds:[esi]
mov es:[edi],eax
add esi,4
add edi,4
loop copyBackBlock
mov fs:[edipos],edi

mov ax,40h
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,cr0
and al,0feh
mov cr0,eax
jmp far ptr Rm16ReadBmpBackReturn
Pm16 ends




Pm32 segment para use32
assume cs:Pm32
mov ax,28h
mov ds,ax
mov ax,30h
mov es,ax
call SetTimer
call CalcMemoryPos

mov esi,0
Show4window:
push esi
mov edi,ShowBase1
call ShowWindow


mov esi,fs:[MemoRyBase2]
mov edi,fs:[ShowBase2]
call ShowWindow

mov esi,fs:[MemoryBase3]
mov edi,fs:[ShowBase3]
call ShowWindow

mov esi,fs:[MemoryBase4]
mov edi,fs:[ShowBase4]
call ShowWindow

call WaitTime
in al,60h
cmp al,1
jnz Next
mov dword ptr fs:[EndFlag],1
db 0eah
dw offset Rm16BitMode
dw 0
dw 8
Next:
pop esi
add esi,dword ptr fs:[BmpHead+22h]
cmp esi,dword ptr fs:[ediPos]
jbe NotOver
mov esi,0
NotOver:
db 0eah
dw offset Show4Window
dw 0
dw 10h

CalcMemoryPos proc near
pushad
mov ecx,3
mov ebp,0
mov edi,offset MemoryBase2
mov esi,offset BmpFileNum
CalcSize:
mov eax,fs:[esi]
mov ebx,dword ptr fs:[BmpHead+22h]
mul ebx
add ebp,eax
mov fs:[edi],ebp
add esi,4
add edi,4
loop CalcSize
popad
ret
CalcMemoryPos endp


ShowWindow proc near
pushad
mov ecx,dword ptr fs:[BmpHead+16h]
Show:
push ecx
mov ecx,dword ptr fs:[BmpHead+12h]
rep movsd
pop ecx
add edi,fs:[VideoScanLine]
loop Show
popad
ret
ShowWindow endp


WaitTIme proc near
pushad
mov ecx,0
waittimer:
mov al,0
out 43h,al
in al,40h
cmp al,0
jnz waittimer
inc ecx
cmp ecx,256
jnz waittimer
popad
ret
WaitTime endp



settimer proc near
mov al,36h
out 43h,al
mov ax,0
out 40h,al
xchg ah,al
out 40h,al
ret
settimer endp
Pm32 ends
end start