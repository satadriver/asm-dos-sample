.386p



PmRltIntProc segment page use32
assume cs:PmRltIntProc
push ax
push ds
mov ax,KbdBufSeg
mov ds,ax
inc dword ptr ds:[6ch]
cmp dword ptr ds:[6ch],1800b0h
jbe PmRltIntReturn
mov dword ptr ds:[6ch],0

PmRltIntReturn:
mov al,20h
out 20h,al
pop ds
pop ax
Iretd
PmRltIntProcLenth	dd $-1
PmRltIntProc ends




PmKbdIntProc  segment para use32
assume cs:PmKbdIntProc
pushad
push ds
push es
mov ax,KbdBufSeg
mov es,ax
mov ax,ParamSeg
mov ds,ax
in al,60h
mov bl,al
movzx ebx,bl
mov al,ds:[ebx]
mov ah,bl
cmp ah,3bh
jb  FuncScanCode
mov al,0
FuncScanCode:
mov di,word ptr es:[1ch]
add di,2		
cmp di,3eh
jnz NotKbdBufEnd
mov di,1eh
NotKbdBufEnd:
mov word ptr es:[1ch],di	
mov word ptr es:[di],ax
mov al,20h
out 20h,al
pop es
pop ds
popad
iretd



pushad
push ds
push es
mov ax,ParamSeg
mov ds,ax   
mov ax,KbdBufSeg
mov es,ax
in al,60h
mov byte ptr ds:[ScanCode],al

db 09ah                             ;call Analysis    
dw offset Analysis
dw 0
dw PmKbdIntSeg

mov al,20h
out 20h,al
out 0a0h,al
pop es
pop ds
popad
iretd


Analysis proc near
;CheckMakeCtrl:
cmp byte ptr ds:[ScanCode],1dh		;1dh=Ctrl
jnz CheckMakeShiftLeft
or byte ptr es:[17h],4
ret
CheckMakeShiftLeft:
cmp byte ptr ds:[ScanCode],2ah		;2ah=Shift Left
jnz CheckMakeShiftRight
or byte ptr es:[17h],2
ret
CheckMakeShiftRight:
cmp byte ptr ds:[ScanCode],36h		;36h=Shift Right
jnz CheckMakeAlt
or byte ptr es:[17h],1
ret
CheckMakeAlt:
cmp byte ptr ds:[ScanCode],38h		;38h=Alt
jnz CheckMakeCapsLock
or byte ptr es:[17h],8
ret
CheckMakeCapsLock:
cmp byte ptr ds:[ScanCode],3ah		;3ah=CapsLock
jnz CheckMakeScrollLock
db 09ah
dw offset MakeCapsLock			;call MakeCapsLock    
dw 0
dw PmKbdIntSeg                       
ret
align 10h
CheckMakeScrollLock:
cmp byte ptr ds:[ScanCode],46h		;46h=ScrollLock
jnz CheckMakeNumsLock
db 09ah
dw offset MakeScrollLock		;call MakeScrollLock                            
dw 0
dw PmKbdIntSeg
ret
align 10h
CheckMakeNumsLock:
cmp byte ptr ds:[ScanCode],45h		;45h=NumsLock
jnz CheckBreakShiftRight
db 09ah
dw offset MakeNumsLock			;call MakeNumsLock 
dw 0
dw PmKbdIntSeg
ret
align 10h
CheckBreakShiftRight:
cmp byte ptr ds:[ScanCode],0b6h		;0b6h=Shift Left
jnz CheckBreakShiftLeft
and byte ptr es:[17h],0feh
ret
CheckBreakShiftLeft:
cmp byte ptr ds:[ScanCode],0aah		;0aah=Shift Right
jnz CheckBreakCtrl
and byte ptr es:[17h],0fdh
ret
CheckBreakCtrl:
cmp byte ptr ds:[ScanCode],9dh		;9dh=Ctrl
jnz CheckBreakAlt
and byte ptr es:[17h],0fbH
ret
CheckBreakAlt:
cmp byte ptr ds:[ScanCode],0b8h		;0b8h=Alt
jnz CheckMakeInsert
and byte ptr es:[17h],0f7h
ret
CheckMakeInsert:
cmp byte ptr ds:[ScanCode],52h		;52h=Insert
jnz CheckMakeDelete
xor byte ptr es:[17h],80h

db 0eah                                ;jmp MakeNormal	
dw offset ToMakeNormal
dw 0
dw PmKbdIntSeg

align 10h
CheckMakeDelete:
cmp byte ptr ds:[ScanCode],53h		;53h=Delete
jnz CheckBreakOthers
test byte ptr es:[17h],4
jz ToMakeNormal
test byte ptr es:[17h],8
jz ToMakeNormal

db 0eah                                   ;call Reset		
dw offset Reset
dw 0
dw PmKbdIntSeg

CheckBreakOthers:
cmp byte ptr ds:[ScanCode],80h
jae AnalysisReturn

ToMakeNormal:
db 09ah                                      ;call MakeNormal
dw offset MakeNormal
dw 0
dw PmKbdIntSeg

AnalysisReturn:
ret
Analysis endp



MakeNormal proc near
cmp byte ptr ds:[ScanCode],2eh
jz Ctrl_C
cmp byte ptr ds:[ScanCode],0c5h
jnz CheckNumLock
CtrlBreak:
Ctrl_C:
test byte ptr es:[17h],4
jz CheckNumLock
ret

CheckNumLock:
cmp byte ptr ds:[ScanCode],47h
jb CheckCapsLock
test byte ptr es:[17h],20h
jz NormalKey

db 0eah                                         ;jmp ShiftKey
dw offset ShiftKey
dw 0
dw PmKbdIntSeg

CheckCapslock:
test byte ptr es:[17h],40h
jnz CapsLockKey
test byte ptr es:[17h],3
jnz ShiftKey

NormalKey:
mov ebx,offset ScanCodeNormal
db 0eah                                                         ;jmp ScanCodeToAsc
dw offset ScanCodeToAsc
dw 0
dw PmKbdIntSeg

ShiftKey:
mov ebx,offset ScanCodeShift
db 0eah                                                         ;jmp ScanCodeToAsc
dw offset ScanCodeToAsc
dw 0
dw PmKbdIntSeg

CapsLockKey:
Test byte ptr es:[17h],3
jnz NormalKey
cmp BYTE PTR ds:[scancode],10h
jb  NormalKey
cmp BYTE PTR ds:[scancode],19h
jbe ShiftKey
cmp BYTE PTR ds:[scancode],1eh
jb  NormalKey
cmp BYTE PTR ds:[scancode],26h
jbe ShiftKey
CMP byte ptr ds:[scancode],2ch
jb  NormalKey
cmp byte ptr ds:[scancode],32h
jbe shiftkey

db 0eah                                                         ;jmp NormalKey
dw offset NormalKey
dw 0
dw PmKbdIntSeg

ScanCodeToAsc:
mov al,byte ptr ds:[ScanCode]
xlat
mov ah,byte ptr ds:[ScanCode]
cmp ah,3bh
jb  EffectiveScanCode
mov al,0
EffectiveScanCode:
mov di,word ptr es:[1ch]
add di,2		;Next Buf Head
cmp di,3eh
jnz KbdBufNotEnd
mov di,1eh
KbdBufNotEnd:
mov word ptr es:[1ch],di	;Kbd buf head
mov word ptr es:[di],ax
ret
MakeNormal endp



SetKbdLed proc near
call waitin
mov al,0edh
out 60h,al
call waitout
in al,60h
cmp al,0fah
jnz SetKbdLed
call waitin
mov al,ds:[LedFlag]
out 60h,al
call waitout        ;here u get return byte 0fah,but why can't read it out ?
in al,60h
ret
SetKbdLed endp



MakeScrollLock proc near
xor byte ptr es:[17h],10h
xor byte ptr es:[LedFlag],1
db 09ah
dw offset SetKbdLed
dw 0
dw PmKbdIntSeg

;call SetKbdLed
ret
MakeScrollLock endp



MakeNumsLock proc near
xor byte ptr es:[17h],20h
xor byte ptr es:[LedFlag],2
db 09ah
dw offset SetKbdLed
dw 0
dw PmKbdIntSeg
;call SetKbdLed
ret
MakeNumsLock endp



MakeCapsLock proc near
Xor byte ptr es:[17h],40h
xor byte ptr es:[LedFlag],4
db 09ah
dw offset SetKbdLed
dw 0
dw PmKbdIntSeg
;call SetKbdLed
ret
MakeCapsLock endp


WaitOut proc near
in al,64h
test al,1
jz waitout
ret
WaitOut endp



WaitIn proc near
in al,64h
test al,2
jnz WaitIn
ret
WaitIn endp



Reset proc near
mov dx,0cf8h
mov eax,8000f840h ;LPC bus NO.0,DEV NO.31,FUNC NO.0,BASE ADDRESS 40H
out dx,eax
mov dx,0cfch
in eax,dx
and al,0feh      ;BIT=1 rePRESENT THE ADDRESS IS REGISTER,OTHERWISE IS MEMORY
mov dx,ax
push dx
add dx,30h ;base reg +30h
in ax,dx
and ax,0ffefh
out dx,ax
pop dx
add dx,5  ;base reg+5
in al,dx
or al,3ch
out dx,al
Reset endp

PmKbdIntProcLenth		dd $-1
PmKbdIntProc ends





PmMouseIntProc segment para use32
assume cs:PmMouseIntProc
pushad
push ds
push es
push fs
push gs
mov ax,ParamSeg
mov ds,ax
mov esi,offset MouseStatus
mov ebx,ds:[MousePacketNum]
in al,60h
movsx eax,al
mov ds:[esi+ebx],eax
add dword ptr ds:[MousePacketNum],4
cmp dword ptr ds:[MousePacketNum],12
jz  MouseIntMain
PmMouseIntIretd:
mov al,20h
out 20h,al
out 0a0h,al
pop gs
pop fs
pop es
pop ds
popad
iretd
MouseIntMain:
mov dword ptr ds:[MousePacketNum],0
mov ax,VesaSeg
mov es,ax
cmp dword ptr ds:[MouseInitFlag],0
jz GetMousePos

mov esi,offset MouseBkgrd
mov edi,ds:[MousePos]
mov ecx,16
cld
RestoreMouseBkgrd:
push ecx
mov ecx,16
rep movsd
add edi,2496
pop ecx
loop RestoreMouseBkgrd

GetMousePos:
mov dword ptr ds:[MouseInitFlag],1
mov eax,ds:[MouseDeltaX]
add ds:[MouseX],eax
mov eax,ds:[MouseDeltaY]
sub ds:[MouseY],eax
mov eax,ds:[MouseY]
mov ebx,2560
mul ebx
mov ebx,ds:[MouseX]
shl ebx,2
add eax,ebx
mov ds:[MousePos],eax

SaveMouseBkgrd:
mov dword ptr ds:[MouseInitFlag],1
mov edi,ds:[MousePos]
mov esi,offset MouseBkgrd
mov ecx,16
SaveBkgrd:
push ecx
mov ecx,16
SaveMouseLine:
mov eax,es:[edi]
mov ds:[esi],eax
add edi,4
add esi,4
loop SaveMouseLine
add edi,2496
pop ecx
loop SaveBkgrd

mov edi,ds:[MousePos]
mov eax,0ffffffffh
mov ecx,16
cld
ShowMouseGraph:
push ecx
mov ecx,16
rep stosd
pop ecx
add edi,2496
loop ShowMouseGraph

db 0eah
dw offset PmMouseIntIretd
dw 0
dw PmMouseIntSeg

PmMouseIntProcLenth             dd $-1
PmMouseIntProc ends




PmCode16Proc segment para use16
assume cs:PmCode16Proc
db 0eah
dw 0
dw PmCode32Seg

ToDosMode:
cli
mov ax,NormalSeg
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,cr0
and al,0feh
mov cr0,eax
jmp far ptr DosMode

PmCode16ProcLenth              dw $-1
PmCode16Proc ends





PmCode32Proc segment para use32
assume cs:PmCode32Proc
mov ax,ParamSeg
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ax,Stack0Seg
mov ss,ax
mov esp,8000h
mov al,0f8h
out 21h,al
mov al,0efh
out 0a1h,al
sti
mov edi,0
InOutChar:
call PmGetKey
cmp al,1bh
jz ToRealMode
call PmShowKey
db 0eah
dw offset InOutChar
dw 0
dw PmCode32Seg

ToRealMode:
db 0eah
dw offset ToDosMode
dw 0
dw PmCode16Seg


;return in eax
PmGetKey Proc near                ;INT xx instruction will clear int flag and trap flag in RealMode but not Protect Mode
push si
push ds
mov ax,KbdBufSeg
mov ds,ax
sti
WaitKeyBufFull:
mov si,word ptr ds:[1ah]
cmp si,word ptr ds:[1ch]
jz WaitKeyBufFull
add si,2
cmp si,3eh
jnz NotKbdBufEnd
mov si,1eh
NotKbdBufEnd:
mov ax,word ptr ds:[si]
movzx eax,ax
mov ds:[1ah],si
pop ds
pop si
ret
PmGetKey endp




PmShowKey proc near             ;eax=ascii char                 ;edi=position
push ebx
push ecx
push edx
push esi
push ds
push es

push edi
mov bx,VesaSeg
mov es,bx
mov bx,GraphCharSeg
mov ds,bx
movzx eax,al
shl eax,3
mov esi,eax
cld
mov ecx,8
ShowCharGraphNextLine:
xor eax,eax
lodsb
;call  ShowCharGraphLine
db 09ah
dw offset ShowCharGraphLine
dw 0
dw PmCode32Seg
add edi,2528
loop ShowCharGraphNextLine

pop edi
add edi,32
mov eax,edi
mov ebx,2560
mov edx,0
div ebx
cmp edx,0
jnz  NotNextLine
add edi,17920
NotNextLine:
pop es
pop ds
pop esi
pop edx
pop ecx
pop ebx
ret

ShowCharGraphLine:
mov bl,al
and eax,1
stosd
mov al,bl
and eax,2
shr eax,1
stosd
mov al,bl
and eax,4
shr eax,2
stosd
mov al,bl
and eax,8
shr eax,3
stosd
mov al,bl
and eax,16
shr eax,4
stosd
mov al,bl
and eax,32
shr eax,5
stosd
mov al,bl
and eax,64
shr eax,6
stosd
mov al,bl
and eax,128
shr eax,7
stosd
ret
PmShowKey endp


PmCode32ProcLenth               dd $-1
PmCode32Proc ends






ProcIretd segment para use32
assume cs:Prociretd
;push eax
;mov al,20h
;out 20h,al
;out 0a0h,al
;pop eax
iretd
ProcIretd ends


MainProc Segment para use16
assume cs:MainProc

start:
;call InitRlt
call SetVesaMode
call Init8259
call InitMouse
call SetDescriptor

mov ax,Param
mov es,ax
mov ax,ss
shl eax,16
mov ax,sp
mov es:[DosStackPtr],eax

cli
mov al,2
out 92h,al
lgdt fword ptr ds:[GdtLimit]
lidt fword ptr ds:[IdtLimit]
mov eax,cr0
or al,1
mov cr0,eax
                db 0eah
                dw 0
                dw PmCode16Seg

align 10h
DosMode:
cli
mov ax,Param
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[DosStackPtr]
call Restore8259
mov ax,4f02h
mov bx,3
int 10h
mov ah,4ch
int 21h


SetDescriptor proc near
xor eax,eax
mov ax,Rom
mov ds,ax
shl eax,4
mov ds:[GdtBase],eax
mov word ptr ds:[RomSelector+2],ax
shr eax,16
mov byte ptr ds:[RomSelector+4],al
mov ax,es:[RomLenth]
mov word ptr ds:[RomSelector],ax

xor eax,eax
mov ax,ProcIretd
shl eax,4
mov word ptr ds:[IretdSelector+2],ax
shr eax,16
mov byte ptr ds:[IretdSelector+4],al

mov ax,Param
mov es,ax
mov ax,4f01h
mov di,offset VideoBuffer
mov cx,112h
int 10h
mov eax,es:[di+28h]
mov word ptr ds:[VesaSelector+2],ax
shr eax,16
mov byte ptr ds:[VesaSelector+4],al
mov byte ptr ds:[VesaSelector+7],ah

mov ax,es:[ParamLenth]
mov word ptr ds:[ParamSelector],ax
xor eax,eax
mov ax,es
shl eax,4
mov word ptr ds:[ParamSelector+2],ax
shr eax,16
mov byte ptr ds:[ParamSelector+4],al
mov byte ptr ds:[ParamSelector+7],ah

mov ax,PmCode16Proc
mov es,ax
mov ax,es:[PmCode16ProcLenth]
mov word ptr ds:[PmCode16Selector],ax
xor eax,eax
mov ax,es
shl eax,4
mov word ptr ds:[PmCode16Selector+2],ax
shr eax,16
mov byte ptr ds:[PmCode16Selector+4],al

mov ax,PmCode32Proc
mov es,ax
mov eax,es:[PmCode32ProcLenth]
mov word ptr ds:[PmCode32Selector],ax
xor eax,eax
mov ax,es
shl eax,4
mov word ptr ds:[PmCode32Selector+2],ax
shr eax,16
mov byte ptr ds:[PmCode32Selector+4],al

mov ax,PmRltIntProc
mov es,ax
mov eax,es:[PmRltIntProcLenth]
mov word ptr ds:[PmRltIntSelector],ax
xor eax,eax
mov ax,es
shl eax,4
mov word ptr ds:[PmRltIntSelector+2],ax
shr eax,16
mov byte ptr ds:[PmRltIntSelector+4],al

mov ax,PmKbdIntProc
mov es,ax
mov eax,es:[PmKbdIntProcLenth]
mov word ptr ds:[PmKbdIntSelector],ax
xor eax,eax
mov ax,es
shl eax,4
mov word ptr ds:[PmKbdIntSelector+2],ax
shr eax,16
mov byte ptr ds:[PmKbdIntSelector+4],al
mov byte ptr ds:[PmKbdIntSelector+7],ah

mov ax,PmMouseIntProc
mov es,ax
mov eax,es:[PmMouseIntProcLenth]
mov word ptr ds:[PmMouseIntSelector],ax
xor eax,eax
mov ax,es
shl eax,4
mov word ptr ds:[PmMouseIntSelector+2],ax
shr eax,16
mov byte ptr ds:[PmMouseIntSelector+4],al

xor eax,eax
mov ax,IdtSeg
mov es,ax
shl eax,4
mov dword ptr ds:[IdtBase],eax

align 10h
mov ax,PmRltIntSeg
mov word ptr es:[RltIntDesc+2],ax
mov ax,PmKbdIntSeg
mov word ptr es:[KbdIntDesc+2],ax
mov ax,PmMouseIntSeg
mov word ptr es:[MouseIntDesc+2],ax
ret
align 10h
SetDescriptor endp



InitMouse proc near
cli
mov al,0f8h
out 21h,al
mov al,0efh
out 0a1h,al

call WaitIBE
mov al,0adh
out 64h,al
call WaitIBE
mov al,0a8h
out 64h,al
ResendMouseCom:
call WaitIBE
mov al,0d4h
out 64h,al
call WaitIBE
mov al,0f4h
out 60h,al
call WaitOBF
in al,60h
cmp al,0fah
jnz ResendMouseCom
call WaitIBE
mov al,60h
out 64h,al
call WaitIBE
mov al,47h
out 60h,al
call WaitIBE
mov al,0aeh
out 64h,al
ret

WaitOBF:
in al,64h
test al,1
jz WaitOBF
ret
WaitIBE:
in al,64h
test al,2
jnz WaitIBE
ret
InitMouse endp





Init8259 proc near
cli
mov al,11h
out 20h,al
out 0a0h,al
mov al,20h
out 21h,al
mov al,28h
out 0a1h,al
mov al,4
out 21h,al
mov al,2
out 0a1h,al
mov al,11h
out 21h,al
out 0a1h,al
ret
Init8259 endp


Restore8259 proc near
cli
mov al,11h
out 20h,al
out 0a0h,al
mov al,8
out 21h,al
mov al,70h
out 0a1h,al
mov al,4
out 21h,al
mov al,2
out 0a1h,al
mov al,11h
out 21h,al
out 0a1h,al
ret
Restore8259 endp

SetVesaMode proc near
mov ax,4f02h
mov bx,112h
int 10h
mov ax,4f06h
mov bx,0
mov cx,640
int 10h
ret
SetVesaMode endp

InitRlt proc near
cli
mov al,36h
out 43h,al
mov al,0
out 40h,al
out 40h,al
mov al,76h
out 43h,al
mov al,0
out 41h,al
out 41h,al
mov al,0b6h
out 43h,al
mov al,0
out 42h,al
out 42h,al
in al,61h
or al,3
out 61h,al
ret
InitRlt endp

MainProc ends






Param Segment para use16
ScanCodeNormal  db 0,1bh,31h,32h,33h,34h,35h,36h,37h,38h,39h,30h,'-','=',8,9,'q'
                db 'w','e','r','t','y','u','i','o','p','[',']',0dh,0,'a','s','d'
                db 'f','g','h','j','k','l',';',"'",'`',0,'\','z','x','c','v','b'
                db 'n','m', ',' , '.', '/', 0, 0, 0,' ',0,0,0,0,0,0,0
                db 0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0
                db 0,0,0


ScanCodeShift   db 0,1bh,'!@#$%^&*()_+',8,9,'Q'
                db 'WERTYUIOP{}',0dh,0,'ASD'
                db 'FGHJKL:"~',0,'|ZXCVB'
                db 'NM<>?',0,0,0,' ',0,0,0,0,0,0,0
                db 0,0,0,0,0,0,'789-456+1230.'

ScanCode    	db 0
LEDflag     	db 0


MouseStatus	dd 0
MouseDeltaX	dd 0
MouseDeltaY	dd 0
MouseInitFlag 	dd 0
MouseX		dd 0
MouseY		dd 0
MousePos	dd 0
MousePacketNum  dd 0
MouseBkGrd	db 1024 dup (0)


VideoBuffer 	db 400h dup (0)
DosStackPtr     dd 0
ParamLenth	dw $-1
Param ends

Rom segment para use16
NullSelector		dq 0
NormalSeg		= $-NullSelector
NormalSelector		dq 000092000000ffffh
KbdBufSeg		= $-NullSelector
KbdBufSelector		dq 00009200040000ffh
ParamSeg		= $-NullSelector
ParamSelector		dq 0000920000000000h
RomSeg			= $-NullSelector
RomSelector		dq 0000900000000000h
VgaSeg			= $-NullSelector
VgaSelector		dq 0000920a0000ffffh
TxtSeg			= $-NullSelector
TxtSelector		dq 0000920b80007fffh
VesaSeg			= $-NullSelector
VesaSelector		dq 00cf92000000ffffh
GraphCharSeg		= $-NullSelector
GraphCharSelector	 dq 0000900ffa6e07ffh

Stack0Seg               = $-NullSelector
Stack0Selector   	dq 104f92000000ffffh
Stack1Seg               = $-NullSelector
Stack1Selector        	dq 104fb2100000ffffh
Stack2Seg               = $-NullSelector
Stack2Selector        	dq 104fd2200000ffffh
Stack3Seg               = $-NullSelector
Stack3Selector		dq 104ff2300000ffffh

PmCode16Seg		= $-NullSelector
PmCode16Selector	dq 0000980000000000h
PmCode32Seg		= $-NullSelector
PmCode32Selector	dq 0040980000000000h
PmKbdIntSeg		= $-NullSelector
PmKbdIntSelector	dq 0040980000000000h
PmMouseIntSeg		= $-NullSelector
PmMouseIntSelector	dq 0040980000000000h		
IretdSeg		=$-NullSelector
IretdSelector		dq 004098000000ffffh
PmRltIntSeg		=$-NullSelector
PmRltIntSelector	dq 0040980000000000h			
			
GdtLimit		dw $-1
GdtBase			dd 0
			
IdtLimit		dw 7ffh
IdtBase			dd 0
RomLenth		dw $-1
Rom  Ends




IdtSeg segment para use16
			dq 20h dup (00008f0000880000h)
RltIntDesc		dq 00008e0000000000h
KbdIntDesc      	dq 00008e0000000000h
			dq 6 dup (00008e0000880000h)
			dq 4 dup (00008e0000880000h)
MouseIntDesc   		dq 00008e0000000000h 
			dq 3 dup (00008e0000880000h)
			dq 208 dup (00008f0000880000h)
IdtSeg ends
end start
