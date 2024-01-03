.386p
_GdtSeg segment para use16
_NullSelector       dq 0
_Pm16Selector       dq 000098000000ffffh
_DrawSelector       dq 004098000000ffffh
_DataSelector       dq 004092000000ffffh
_DataBufferSelector dq 10cf92000000ffffh
_VesaBaseSelector   dq 004f92000000ffffh
_StackSelector      dq 004092800000ffffh
_Rm16Selector       dq 000092000000ffffh

_GdtLenth           =$
_GdtLimit           dw _GdtLenth-1
_GdtBase            dd 0
_dwStackPtr         dd 0
_stVesaInfo         db 100h dup (0)


_dwColorYin             dd 1
_dwColorYang		dd 2
_dwAngle                dd 0
_dwSlope                dq 0
_dwBuf                  dd 0

_dwDotNum               dd 0

_dwX                    dd 0
_dwY                    dd 0
_dwLineNum              dd 0
_dwColumnNum            dd 0
_dwCenterDeltaX         dd 0
_dwCenterDeltaY         dd 0

_dwCenterX              dd 512
_dwCenterY              dd 384
_dwSmallCenterLX        dd 362
_dwSmallCenterLY        dd 384
_dwSmallCenterRX        dd 662
_dwSmallCenterRY        dd 384

                        

_dwRadius           dd 300
_dwHalfRadius       dd 0
_dwSmallSqrRadius   dd 0
_dwSqrRadius        dd 0

_dwDisplaySize      dd 1024*768-1
_dwScanLine         dd 1024
_dwAnglePi          dd 180
_GdtSeg ends



_MainCode segment para use16
assume cs:_MainCode
start:

call _InitSelector
call _SetVesaMode
call _InitTimer
call _InitRadius

_Main proc near
mov ax,ss
shl eax,16
mov ax,sp
mov ds:[_dwStackPtr],eax
lgdt qword ptr ds:[_GdtLimit]
cli
mov al,2
out 92h,al
mov eax,cr0
or al,1
mov cr0,eax
db 0eah
dw 0
dw 8
_DosMode:
mov ax,_GdtSeg
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
lss sp,dword ptr ds:[_dwStackPtr]
mov ax,3
int 10h
mov ah,4ch
int 21h
_Main endp



_InitSelector proc near
xor eax,eax
mov ax,_GdtSeg
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
shl eax,4
mov ds:[_GdtBase],eax
mov word ptr ds:[_DataSelector+2],ax
shr eax,16
mov byte ptr ds:[_DataSelector+4],al

xor eax,eax
mov ax,_Pm16Seg
shl eax,4
mov word ptr ds:[_Pm16Selector+2],ax
shr eax,16
mov byte ptr ds:[_Pm16Selector+4],al

xor eax,eax
mov ax,_DrawGraphics
shl eax,4
mov word ptr ds:[_DrawSelector+2],ax
shr eax,16
mov byte ptr ds:[_DrawSelector+4],al

mov ax,4f01h
mov cx,101h
mov di,offset _stVesaInfo
int 10h
mov di,offset _stVesaInfo
add di,40
mov eax,dword ptr es:[di]
mov word ptr ds:[_VesaBaseselector+2],ax
shr eax,16
mov byte ptr ds:[_VesaBaseselector+4],al
mov byte ptr ds:[_VesaBaseselector+7],ah
ret
_InitSelector endp


_SetVesaMode proc near
mov ax,4f02h
mov bx,105h
int 10h
ret
_SetVesaMode endp


_InitTimer proc near
mov al,36h
out 43h,al
mov ax,0
out 40h,al
out 40h,al
ret
_InitTimer endp


_InitRadius proc near
mov eax,ds:[_dwRadius]
push eax
shr eax,1
mov ds:[_dwHalfRadius],eax
mul eax
mov ds:[_dwSmallSqrRadius],eax
pop eax
mul eax
mov ds:[_dwSqrRadius],eax
ret
_InitRadius endp
_MainCode ends





_Pm16Seg segment para use16
assume cs:_Pm16Seg
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
db 0eah
dw 0
dw 10h

_TODos:
mov ax,38h
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,cr0
and al,0feh
mov cr0,eax
jmp far ptr _DosMode
_Pm16Seg ends




_DrawGraphics segment para use32
assume cs:_DrawGraphics

_Rotate:
call _Chord
mov ecx,0
waittime:
in al,40h
cmp al,0
jnz waittime
inc ecx
cmp ecx,50
jnz waittime
waitkey:
in al,60h
cmp al,1
jz toback
;jmp waitkey
call _ResetRegion
add dword ptr fs:[_dwAngle],10
call _calcCenterXY
jmp _ROtate

toback:
db 0eah
dw offset _TODos
dw 0
dw 8



_CalcCenterXY proc near
finit
fild dword ptr fs:[_dwAngle]
fldpi
fmul
fild dword ptr fs:[_dwAnglePI]
fdivp st(1),st(0)
dw 0fed9h
fild dword ptr fs:[_dwHalfRadius]
fmul
fistp dword ptr fs:[_dwCenterDeltaY]
finit
fild dword ptr fs:[_dwAngle]
fldpi
fmul
fild dword ptr fs:[_dwAnglePI]
fdivp st(1),st(0)
dw 0ffd9h
fild dword ptr fs:[_dwHalfRadius]
fmul
fistp dword ptr fs:[_dwCenterDeltaX]

mov eax,fs:[_dwSmallCenterRY]
sub eax,fs:[_dwCenterDeltaY]
mov fs:[_dwSmallCenterRY],eax
mov eax,fs:[_dwSmallCenterRX]
sub eax,fs:[_dwCenterDeltaX]
mov fs:[_dwSmallCenterRX],eax

mov eax,fs:[_dwSmallCenterLY]
ADD eax,fs:[_dwCenterDeltaY]
mov fs:[_dwSmallCenterLY],eax
mov eax,fs:[_dwSmallCenterLX]
ADD eax,fs:[_dwCenterDeltaX]
mov fs:[_dwSmallCenterLX],eax

ret
_CalcCenterXY endp




_Chord proc near
finit
fild dword ptr fs:[_dwAngle]
fldpi
fmul
fild dword ptr fs:[_dwAnglePI]
fdivp st(1),st(0)
dw 0fbd9h
fstp qword ptr fs:[_dwSlope]

mov dword ptr fs:[_dwDotNum],0
_CheckNextPoint:
mov eax,fs:[_dwDotNum]
mov edx,0
mov ebx,fs:[_dwScanLine]
div ebx
mov fs:[_dwLineNum],eax
mov fs:[_dwColumnNum],edx
sub eax,fs:[_dwCenterY]
sub edx,fs:[_dwCenterX]
mov fs:[_dwX],edx
mov fs:[_dwY],eax
mul eax
mov ebx,eax
mov ecx,edx
mov eax,fs:[_dwX]
mul eax                     ;mul
add eax,ebx
adc edx,ecx                   
cmp eax,fs:[_dwSqrRadius]
jG _OutCircle


mov eax,fs:[_dwLineNum]
sub eax,fs:[_dwSmallCenterRY]
mul eax
mov ebx,eax
mov eax,fs:[_dwColumnNum]
sub eax,fs:[_dwSmallCenterRX]
mul eax
add eax,ebx
cmp eax,fs:[_dwSmallSqrRadius]
jG _NotInSmallR
;mov eax,fs:[_dwColorYIN]
;mov al,0
;mov edi,fs:[_dwDotNum]
;stosb
jmp _OutCircle


_NotInSmallR:
mov eax,fs:[_dwLineNum]
sub eax,fs:[_dwSmallCenterLY]
mul eax
mov ebx,eax
mov eax,fs:[_dwColumnNum]
sub eax,fs:[_dwSmallCenterLX]
mul eax
add eax,ebx
cmp eax,fs:[_dwSmallSqrRadius]
ja _NotInSmallL
;mov eax,fs:[_dwColorYang]
mov eax,fs:[_dwCOlorYin]
mov edi,fs:[_dwDotNum]
stosb
jmp _OutCircle


_NotInSmallL:
finit
fild dword ptr fs:[_dwX]
fld qword ptr fs:[_dwSlope]
fmul
fistp dword ptr fs:[_dwBuf]
mov eax,fs:[_dwY]
cmp eax,fs:[_dwBuf]
jL _OutCircle
mov eax,fs:[_dwColorYin]
mov edi,fs:[_dwDotNum]
stosb
jmp _OutCircle


_OutCircle:
inc dword ptr fs:[_dwDotNum]
mov eax,fs:[_dwDotNum]
cmp eax,fs:[_dwDisplaySize]
jae quit

db 0eah
dw offset  _CheckNextPoint
dw 0
dw 10h
quit:
ret 
_Chord endp

_ResetRegion proc near
mov dword ptr fs:[_dwDotNum],0
_ResetPix:
mov eax,fs:[_dwDotNum]
mov edx,0
mov ebx,fs:[_dwScanLine]
div ebx
sub eax,fs:[_dwCenterY]
sub edx,fs:[_dwCenterX]
push edx
mul eax
mov ebx,eax
pop eax
mul eax
add eax,ebx
cmp eax,fs:[_dwSqrRadius]
ja _NotInRegion
mov al,0
mov edi,fs:[_dwDotNum]
stosb
_NotInRegion:
inc dword ptr fs:[_dwDotNum]
mov eax,fs:[_dwDotNum]
cmp eax,fs:[_dwDisplaySize]
jb _ResetPix
ret
_ResetRegion endp

_DrawGraphics ends
end start

