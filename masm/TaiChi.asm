.386p
_GdtSeg segment para use16
_NullSelector       dq 0
_Pm16Selector       dq 000098000000ffffh
_DrawSelector       dq 004098000000ffffh
_DataSelector       dq 004092000000ffffh
_DataBufferSelector dq 10cf92000000ffffh
_VesaBaseSelector   dq 00cf92000000ffffh
_StackSelector      dq 004092800000ffffh
_Rm16Selector       dq 000092000000ffffh

_GdtLenth           =$
_GdtLimit           dw _GdtLenth-1
_GdtBase            dd 0
_dwStackPtr         dd 0
_stVesaInfo         db 100h dup (0)

_dwCenterX          dd 512
_dwCenterY          dd 384
_dwRadius           dd 300
_dwColor            dd 0ffh
_dwAngle            dd 0

_dwDeltaX           dd 0
_dwDeltaY           dd 0
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
mov eax,dword ptr es:[di+40]
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
mov eax,cr0
and al,0feh
mov cr0,eax
jmp far ptr _DosMode
_Pm16Seg ends




_DrawGraphics segment para use32
assume cs:_DrawGraphics
push dword ptr fs:[_dwAngle]
push dword ptr fs:[_dwColor]
mov eax,fs:[_dwRadius]
mul eax
push eax
push dword ptr fs:[_dwCenterY]
push dword ptr fs:[_dwCenterX]
call _Chord

l0:
in al,60h
cmp al,1
jnz l0

push dword ptr fs:[_dwAngle]
push dword ptr fs:[_dwColor]
mov eax,fs:[_dwRadius]
shr eax,1
push eax
push dword ptr fs:[_dwCenterY]
push dword ptr fs:[_dwCenterX]
call _CalcDeltaXY


push dword ptr fs:[_dwAngle]
push dword ptr fs:[_dwColor]
mov eax,fs:[_dwRadius]
shr eax,1
mul eax
push eax
mov eax,fs:[_dwCenterY]
add eax,fs:[_dwDeltaY]
push eax
mov eax,fs:[_dwCenterX]
sub eax,fs:[_dwDeltaX]
push eax
call _Chord

push dword ptr fs:[_dwAngle]
push dword ptr fs:[_dwColor]
mov eax,fs:[_dwRadius]
shr eax,1
mul eax
push eax
mov eax,fs:[_dwCenterY]
add eax,fs:[_dwDeltaY]
push eax
mov eax,fs:[_dwCenterX]
sub eax,fs:[_dwDeltaX]
push eax
call _Chord

waitkey:
in al,60h
cmp al,1
jnz waitkey
db 0eah
dw offset _TODos
dw 0
dw 8


_CalcDeltaXY proc near
push ebp
mov ebp,esp
sub esp,100h
;[ebp]=ebp
;[ebp+4]=call back
;[ebp+8]=_dwCenterX
;[ebp+12]=_dwCenterY
;[ebp+16]=_dwHalfRadius
;[ebp+20]=_dwColor
;[ebp+24]=_dwAngle

finit
fild dword ptr [ebp+24]
fldpi
fmul
fild dword ptr fs:[_dwAnglePI]
fdivp st(1),st(0)
dw 0fed9h
fild dword ptr [ebp+16]
fmul
fistp dword ptr fs:[_dwDeltaY]
finit
fild dword ptr [ebp+24]
fldpi
fmul
fild dword ptr fs:[_dwAnglePI]
fdivp st(1),st(0)
dw 0ffd9h
fild dword ptr [ebp+16]
fmul
fistp dword ptr fs:[_dwDeltaX]

mov esp,ebp
pop ebp
ret
_CalcDeltaXY endp




_Chord proc near
push ebp
mov ebp,esp
sub esp,100

;[ebp-16]=_DeltaY
;[ebp-12]=_DeltaX
;[ebp-8]=tan(_DeltaY/_DeltaX)
;[ebp-4]=tan(_dwAngle)
;[ebp]=ebp
;[ebp+4]=call back
;[ebp+8]=_dwCenterX
;[ebp+12]=_dwCenterY
;[ebp+16]=_dwSqrRadius
;[ebp+20]=_dwColor
;[ebp+24]=_dwAngle

finit
fild dword ptr [ebp+24]
fldpi
fmul
fild dword ptr fs:[_dwAnglePI]
fdivp st(1),st(0)
dw 0fbd9h
fistp dword ptr [ebp-4]

mov esi,0
_CheckNextPoint:
push esi
mov eax,esi
mov edx,0
mov ebx,fs:[_dwScanLine]
div ebx
sub edx,[ebp+8]
sub eax,[ebp+12]
mov [ebp-12],edx
mov [ebp-16],eax
mul eax
mov ebx,eax
mov ecx,edx
mov eax,[ebp-12]
mul eax
add eax,ebx
adc edx,ecx
cmp eax,[ebp+16]
jg _OutCircle

finit
fild dword ptr [ebp-12]
fild dword ptr [ebp-16]
fdiv
fistp dword ptr [ebp-8]
mov eax,[ebp-8]
cmp eax,[ebp-4]
jle _OutCircle
mov eax,[ebp+20]
stosb

_OutCircle:
pop esi
inc esi
cmp esi,_dwDisplaySize
jle _CheckNextPoint

mov esp,ebp
pop ebp
ret 
_Chord endp

_DrawGraphics ends
end start

