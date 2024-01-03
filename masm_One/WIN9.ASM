.386p






Param Segment para use16

KbdBuf          db 100h dup (0)
KbdBufHead      dw offset KbdBuf
                dw 0
KbdBufDetail    dw offset KbdBuf
                dw 0
ScanCode    	db 0
KbdLedStatus   	db 0

KbdStatus       db 0
SysTimerCount   dd 0




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



MouseStatus	dd 0
MouseDeltaX	dd 0
MouseDeltaY	dd 0
MouseX		dd 0
MouseY		dd 0
MousePos	dd 0
MousePacketNum  dd 0
MouseInitFlag 	dd 0
MouseBkGrd	db 1024 dup (0)
MouseColor	dd 0

RltVideoBuf	db 2048 dup (0)
RltMapColor	dd 00ff0000h


HdPortBase	dw 0
BmIdePort	dw 0
HdSlaveFlag	db 0
SataFlag	db 0
HdInfo		db 200h dup (0)
HdPciPort	dw 20 dup (0)
HdIntLinePin    dw 0

DosIntMask	dw 0
DosStackPtr     dd 0
OldIdtPtr	dq 0
ParamLenth	dw $-1
Param ends






Rom segment para use16
NullSelector		dq 0
NormalSeg		= $-NullSelector
NormalSelector		dq 000092000000ffffh
ParamSeg		= $-NullSelector
ParamSelector		dq 0040920000000000h
RomSeg			= $-NullSelector
RomSelector		dq 0040900000000000h
VgaSeg			= $-NullSelector
VgaSelector		dq 0040920a0000ffffh
TxtSeg			= $-NullSelector
TxtSelector		dq 0040920b80007fffh
VesaSeg			= $-NullSelector
VesaSelector		dq 00cf92000000ffffh
GraphCharSeg		= $-NullSelector
GraphCharSelector	dq 0040900ffa6e07ffh

Stack0Seg               = $-NullSelector
Stack0Selector   	dq 104f92000000ffffh
Stack1Seg               = $-NullSelector
Stack1Selector        	dq 104fb2100000ffffh
Stack2Seg               = $-NullSelector
Stack2Selector        	dq 104fd2200000ffffh
Stack3Seg               = $-NullSelector
Stack3Selector		dq 104ff2300000ffffh

PmCode16Seg		= $-NullSelector
PmCode16Selector	dq 00009a000000ffffh
PmCode32Seg		= $-NullSelector
PmCode32Selector	dq 0040980000000000h
PmIntSeg		= $-NullSelector
PmIntSelector	  	dq 0040980000000000h	



			
	
GdtLimit		dw $-1
GdtBase			dd 0
	
	
IdtLimit		dw 7ffh
IdtBase			dd 0


Div0ExceptionDesc	dq 20h dup (00008f0000880000h)
SysTimerIntDesc		dq 00008e0000000000h
KbdIntDesc      	dq 00008e0000000000h
			dq 6 dup (00008e0000880000h)
RltIntDesc		dq 00008e0000000000h
			dq 3 dup (00008e0000880000h)
MouseIntDesc   		dq 00008e0000000000h 
			dq 3 dup (00008e0000880000h)

SysTimerIntCallDesc     dq 00008f0000000000h
GetKeyIntDesc      	dq 00008f0000000000h
ShowCharIntDesc        	dq 00008f0000000000h
                        dq 13 dup (00008e0000000000h)
			dq 192 dup (00008f0000880000h)


RomLenth		dw $-1
Rom  Ends






MainProc Segment para use16
assume cs:MainProc

start:
call SetDescriptor
call SetVesaMode

mov ax,Param
mov es,ax
mov ax,ss
shl eax,16
mov ax,sp
mov es:[DosStackPtr],eax
in al,21h
mov ah,al
in al,0a1h
xchg ah,al
mov es:[DosIntMask],ax
cli
mov al,2
out 92h,al
sidt qword ptr es:[OldIdtPtr]
lgdt qword ptr ds:[GdtLimit]
lidt qword ptr ds:[IdtLimit]
mov eax,cr0
or al,1
mov cr0,eax
                db 0eah
                dw 0
                dw PmCode16Seg
DosMode:
align 10h
cli
call Restore8259
mov ax,Param
mov ds,ax
mov es,ax
lidt qword ptr ds:[OldIdtPtr]
lss sp,dword ptr ds:[DosStackPtr]
mov ax,ds:[DosIntMask]
out 21h,al
mov al,ah
or al,11h
out 0a1h,al
sti
mov ax,4f02h
mov bx,3
int 10h
mov ah,4ch
int 21h


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

SetDescriptor proc near
xor eax,eax
mov ax,Rom
mov ds,ax
shl eax,4
push eax
push eax
mov word ptr ds:[RomSelector+2],ax
shr eax,16
mov byte ptr ds:[RomSelector+4],al
mov byte ptr ds:[RomSelector+7],ah
mov ax,ds:[RomLenth]
mov word ptr ds:[RomSelector],ax
pop eax
xor ebx,ebx
mov bx,offset NullSelector
add eax,ebx
mov ds:[GdtBase],eax
pop eax
xor ebx,ebx
mov bx,offset Div0ExceptionDesc
add eax,ebx
mov dword ptr ds:[IdtBase],eax

mov ax,PmIntSeg
mov word ptr ds:[SysTimerIntDesc+2],ax
mov word ptr ds:[KbdIntDesc+2],ax
mov word ptr ds:[RltIntDesc+2],ax
mov word ptr ds:[MouseIntDesc+2],ax
mov word ptr ds:[ShowCharIntDesc+2],ax

mov ax,offset PmSysTimerIntProc
mov word ptr ds:[SysTimerIntDesc],ax
mov ax,offset PmKbdIntProc
mov word ptr ds:[KbdIntDesc],ax
mov ax,offset PmRltIntProc
mov word ptr ds:[RltIntDesc],ax
mov ax,offset PmMouseIntProc
mov word ptr ds:[MouseIntDesc],ax
mov ax,offset PmShowCharIntProc
mov word ptr ds:[ShowCharIntDesc],ax

mov ax,Param
mov es,ax
mov ax,4f01h
mov di,offset MouseBkgrd
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
;mov word ptr ds:[PmCode16Selector],ax	;Waht's normal format of Code??? 
xor eax,eax
mov ax,es
shl eax,4
mov word ptr ds:[PmCode16Selector+2],ax
shr eax,16
mov byte ptr ds:[PmCode16Selector+4],al
mov byte ptr ds:[PmCode16Selector+7],ah

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
mov byte ptr ds:[PmCode32Selector+7],ah

mov ax,PmIntProc
mov es,ax
mov eax,es:[PmIntProcLenth]
mov word ptr ds:[PmIntSelector],ax
xor eax,eax
mov ax,es
shl eax,4
mov word ptr ds:[PmIntSelector+2],ax
shr eax,16
mov byte ptr ds:[PmIntSelector+4],al

ret
align 10h
SetDescriptor endp

align 10h
Restore8259  proc near
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
MainProc ends






PmIntProc segment para use32
assume cs:PmIntProc


PmSysTimerIntProc:
push eax
push ds
mov ax,ParamSeg
mov ds,ax
inc dword ptr ds:[SysTimerCount]
cmp dword ptr ds:[SysTimerCount],1800b0h
jbe PmRltIntReturn
mov dword ptr ds:[SysTimerCount],0
PmRltIntReturn:
mov al,20h
out 20h,al
pop ds
pop eax
PmIntRet:
Iretd





PmKbdIntProc:
pushad
push ds
push es
mov ax,ParamSeg
mov ds,ax
mov es,ax
xor eax,eax
in al,60h
cmp al,80h
jae IllegalBreakCode
xor ebx,ebx
mov ebx,offset ScanCodeNormal
add ebx,eax
mov ah,al
mov al,ds:[ebx]
mov edi,dword ptr ds:[KbdBufDetail]
add edi,2		
cmp edi,offset KbdBufHead
jnz KbdBufDetailNotEnd
mov edi,offset KbdBuf
KbdBufDetailNotEnd:
mov dword ptr es:[KbdBufDetail],edi	
mov word ptr es:[edi],ax
IllegalBreakCode:
mov al,20h
out 20h,al
pop es
pop ds
popad
iretd






PmRltIntProc:
pushad
push ds
push es

mov ax,ParamSeg
mov ds,ax
mov ax,VesaSeg
mov es,ax

mov al,0ch
out 70h,al
in al,71h
cmp al,0c0h
jz RltPeriodInt
cmp al,90h
jz RltTimingInt

RltPeriodInt:
cmp dword ptr ds:[MouseInitFlag],0
jz PmRltIntRet
mov eax,ds:[MouseColor]
mov edi,ds:[MousePos]
mov ecx,16
ColorMouse:
push ecx
push edi
mov ecx,16
ColorMouseLine:
stosd
add eax,10h
loop ColorMouseLine
pop edi
add edi,2560
pop ecx
loop ColorMouse
mov ds:[MouseColor],eax
db 0eah
dw offset PmRltIntRet
dw 0
dw PmIntSeg

RltTimingInt:
mov esi,offset RltVideoBuf
mov edi,2560*464
sub edi,256
mov ecx,8
cld
RestoreRtlVideo:
push ecx
push edi
mov ecx,64
rep movsd
pop edi
add edi,2560
pop ecx
loop RestoreRtlVideo

mov edi,2560*464
sub edi,256
mov al,4
out 70h,al
in al,71h
call DigitalTOAsc
int 32h
xchg ah,al
int 32h

mov eax,3ah
int 32h

mov al,2
out 70h,al
in al,71h
call DigitalToAsc
int 32h
xchg ah,al
int 32h

mov al,3ah
int 32h

mov al,0
out 70h,al
in al,71h
call DigitalToAsc
int 32h
xchg ah,al
int 32h

PmRltIntRet:
mov al,20h
out 20h,al
out 0a0h,al
pop es
pop ds
popad
iretd

DigitalToAsc:                   ;input al,output ax
push ebx
mov bh,al
shr al,4
cmp al,9
jbe NotHexLow
add al,7
NotHexLow:
add al,30h
mov bl,al
mov al,bh
and al,0fh
cmp al,9
jbe NotHexHigh
add al,7
NotHexHigh:
add al,30h
mov bh,al
mov ax,bx
pop ebx
ret








PmMouseIntProc:
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

PmMouseIntReturn:
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

RestoreMouseBkgrd:
mov esi,offset MouseBkgrd
mov edi,ds:[MousePos]
mov ecx,16
cld
RestoreMouseBkgrdLine:
push ecx
mov ecx,16
rep movsd
add edi,2496
pop ecx
loop RestoreMouseBkgrdLine

GetMousePos:
mov dword ptr ds:[MouseInitFlag],1
mov eax,ds:[MouseDeltaX]
add ds:[MouseX],eax
mov eax,ds:[MouseY]
sub eax,ds:[MouseDeltaY]
mov ds:[MouseY],eax
mov edx,0
mov ebx,2560
mul ebx
mov ebx,ds:[MouseX]
shl ebx,2
add eax,ebx
mov ds:[MousePos],eax

SaveMouseBkgrd:
mov edi,ds:[MousePos]
mov esi,offset MouseBkgrd
mov ecx,16
SaveBkgrd:
push ecx
mov ecx,16
SaveMouseBkgrdLine:
mov eax,es:[edi]
mov ds:[esi],eax
add edi,4
add esi,4
loop SaveMouseBkgrdLine
add edi,2496
pop ecx
loop SaveBkgrd

ShowMouseGraph:
mov edi,ds:[MousePos]
mov eax,ds:[MouseColor]
mov ecx,16
cld
ShowMouseGraphLine:
push ecx
mov ecx,16
rep stosd
pop ecx
add edi,2496
loop ShowMouseGraphLine

;jmp near ptr PmMouseIntReturn		;jmp is illegal,why?????
db 0eah
dw offset PmMouseIntReturn
dw 0
dw PmIntSeg






PmShowCharIntproc:            ;input:eax=ascii char ,edi=position
push eax
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
ShowCharGraph:
push ecx
push esi
push edi
xor eax,eax
mov al,ds:[esi]
call  ShowCharGraphLine
pop edi
add edi,2560
pop esi
inc esi
pop ecx
loop ShowCharGraph

pop edi
add edi,32
mov eax,edi
mov edx,0
mov ebx,2560
div ebx
cmp edx,0
jnz  GraphCharLine
add edi,17920
GraphCharLine:
pop es
pop ds
pop esi
pop edx
pop ecx
pop ebx
pop eax
iretd

ShowCharGraphLine:
mov bl,al
mov bh,128
mov ecx,8
DrawCharPixLine:
push ecx
mov al,bl
and al,bh
cmp al,0
jnz DrawCharPix
add edi,4
db 0eah
dw offset InspectNextPix
dw 0
dw PmIntSeg
DrawCharPix:
mov eax,0ff00h
stosd
InspectNextPix:
shr bh,1
pop ecx
loop DrawCharPixLine
ret

PmIntProcLenth                   dd $-1
PmIntProc ends














PmCode16Proc segment para use16
assume cs:PmCode16Proc
db 0eah
dw 0
dw PmCode32Seg

ToDosMode:
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
mov ax,VesaSeg
mov es,ax
mov ax,ParamSeg
mov ds,ax
mov fs,ax
mov gs,ax
mov ax,Stack0Seg
mov ss,ax
mov esp,8000h
cld
mov ecx,640*480
mov eax,0ffffffffh
mov edi,0
rep stosd

mov ecx,8
mov esi,offset RltVideoBuf
mov edi,2560*464
sub edi,256
SaveRltVideo:
push ecx
mov ecx,64
SaveRltVideoLine:
mov eax,es:[edi]
mov ds:[esi],eax
add esi,4
add edi,4
loop SaveRltVideoLine
pop ecx
add edi,2304
loop SaveRltVideo

call GetHdPortBase
call Init8259
call InitSysTimer
call InitRlt
call InitMouse
sti


mov edi,0
mov esi,offset HdPortBase
lodsw
cmp ax,0c080h
jz HdOk
add edi,5120
HdOk:
add edi,0

InOutChar:
call PmGetkey
;db 09ah
;dw offset PmGetKey
;dw 0
;dw PmCode32Seg

cmp al,1bh
jz ToRealMode
int 32h
jmp InOutChar

ToRealMode:
cli
db 0eah
dw offset ToDosMode
dw 0
dw PmCode16Seg


PmGetKey Proc near 
push esi
push ds
mov ax,ParamSeg
mov ds,ax
sti
WaitKeyPress:
mov esi,dword ptr ds:[KbdBufHead]
cmp esi,dword ptr ds:[KbdBufDetail]
jz WaitKeyPress
add esi,2
cmp esi,offset KbdBufHead
jnz KbdBufHeadNotEnd
mov esi,offset KbdBuf
KbdBufHeadNotEnd:
mov dword ptr ds:[KbdBufHead],esi
mov ax,word ptr ds:[esi]
movzx eax,al
pop ds
pop esi
ret
PmGetKey endp







InitMouse proc near
cli
call WaitIBE
mov al,0adh
out 64h,al
call WaitIBE
mov al,0a8h
out 64h,al

call WaitIBE
mov al,0d4h
out 64h,al
ResendMouseCom:
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


InitRlt proc near
cli
mov al,0bh
out 70h,al
mov al,52h
out 71h,al
ret
InitRlt endp



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

mov al,0f8h
out 21h,al
mov al,0eeh
out 0a1h,al
ret
Init8259 endp






InitSysTimer proc near
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
InitSysTimer endp





ReadSector proc near
push ecx
push eax
mov dx,ds:[HdPortBase]
add dx,5
mov al,0
out dx,al
dec dx
out dx,al
dec dx
pop eax
rol eax,8
out dx,al
mov dx,ds:[HdPortBase]
add dx,5
rol eax,8
out dx,al
dec dx
rol eax,8
out dx,al
dec dx
rol eax,8
out dx,al
mov dx,fs:[HdPortBase]
add dx,2
mov ax,cx
rol ax,8
out dx,al
rol ax,8
out dx,al
mov dx,fs:[HdPortBase]
add dx,6
mov al,0e0h
out dx,al
mov dx,fs:[HdPortBase]
add dx,7
mov al,29h
out dx,al
pop ecx
shl ecx,8
wait_read:
in al,dx
cmp al,58h
jnz wait_read
mov dx,fs:[HdPortBase]
rep insw
ret
ReadSector endp


GetHdPortBase proc near
pushad
push ds
push es
cli
mov ax,ParamSeg
mov ds,ax
mov es,ax

mov dx,1f6h
mov al,0e0h
call CheckHdPort
cmp word ptr ds:[HdPortBase],0
jnz GetHdPortOk
mov dx,1f6h
mov al,0f0h
call CheckHdPort
cmp word ptr ds:[HdPortBase],0
jnz GetHdPortOk
mov dx,176h
mov al,0e0h
call CheckHdPort
cmp word ptr ds:[HdPortBase],0
jnz GetHdPortOk
mov dx,176h
mov al,0f0h
call CheckHdPort
cmp word ptr ds:[HdPortBase],0
jnz GetHdPortOk

call GetHdPciPort
mov byte ptr ds:[HdSlaveFlag],0e0h
call GetHdPciPortBase
cmp word ptr ds:[HdPortBase],0
jnz GetHdPortOk
mov byte ptr ds:[HdSlaveFlag],0f0h
call GetHdPciPortBase
GetHdPortOk:
pop es
pop ds
popad
ret



GetHdPciPortBase:
pushad
mov esi,offset HdPciPort
mov ecx,2
CheckPciPort:
push ecx
push esi
lodsw
mov dx,ax
add dx,6
mov al,ds:[HdSlaveFlag]
call CheckHdPort
cmp word ptr ds:[HdPortBase],0
jnz FindHdPciPort
pop esi
add esi,10
pop ecx
loop CheckPciPort
popad
ret

FindHdPciPort:
pop esi
pop ecx
add esi,8
lodsw
cmp byte ptr ds:[HdSlaveFlag],0e0h
jz BusMasterPrimary
add ax,8
BusMasterPrimary:
add ax,2
mov ds:[BmIdePort],ax
mov byte ptr ds:[SataFlag],1
popad
ret




CheckHdPort:
push ax
push dx
out dx,al
inc dx
mov al,0ech
out dx,al
call WaitHdResponse
in al,dx
cmp al,58h
jnz CheckHdPortRet
pop dx
sub dx,6
mov ds:[HdPortBase],dx
pop ax
mov ds:[HdSlaveFlag],al
push ecx
push edi
mov ecx,100h
mov edi,offset HdInfo
cld
rep insw
pop edi
pop ecx
ret
CheckHdPortRet:
pop dx
pop ax
ret

WaitHdResponse:
push ax
mov ax,0
WaitTickCount:
in al,40h
cmp al,0
jnz WaitTickCount
inc ah
cmp ah,40h
jnz WaitTickCount
pop ax
ret



GetHdPciPort:
pushad
mov edi,offset HdPciPort
mov eax,80000008h
SearchPciDev:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in  eax,dx
shr eax,16
cmp eax,0101h
jnz ReadNextPciDev 

pop eax
push eax
add eax,8
mov ecx,5
Read5Port:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and ax,0fffeh
stosw
pop eax
add eax,4
loop Read5Port
add eax,14h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in ax,dx
cmp ax,0
jz ReadNextPciDev
mov word ptr ds:[HdIntLinePin],ax

ReadNextPciDev:
pop eax
add eax,100h
cmp eax,80010008h
jbe SearchPciDev
popad
ret

GetHdPortBase endp













PmCode32ProcLenth               dd $-1
PmCode32Proc ends
end start
