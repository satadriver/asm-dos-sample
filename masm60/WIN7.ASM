.386p





Param Segment para use16     
ParamBuf        db 800h dup (0)  
SysTimerCount	dd 0

KbdBuf          db 100h dup (0)
KbdBufHead      dw offset KbdBuf
                dw 0
KbdBufDetail    dw offset KbdBuf
                dw 0
KbdStatus       dd 0
ScanCode    	dd 0
KbdLedStatus   	dd 0
TransScanCodeNormal  db 0,1bh,31h,32h,33h,34h,35h,36h,37h,38h,39h,30h,'-','=',8,9,'q'
                db 'w','e','r','t','y','u','i','o','p','[',']',0dh,0,'a','s','d'
                db 'f','g','h','j','k','l',';',"'",'`',0,'\','z','x','c','v','b'
                db 'n','m', ',' , '.', '/', 0, 0, 0,' ',0,0,0,0,0,0,0
                db 0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0
                db 0,0,0
TransScanCodeShift   db 0,1bh,'!@#$%^&*()_+',8,9,'Q'
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
MouseColor	dd 0

DeskTopBkgrdAlterFlag           dd 0
FontColor	dd 0
VesaFontColor	dd 0
RltFontColor	dd 00ffffh
FontColorStore 	dd 0
RltTimingPos    dd 2560*464-256


HdPortBase	dw 0
BmIdePort	dw 0
HdSlaveFlag	db 0
SataFlag	db 0
HdPciPort	dw 20h dup (0)
HdIntLinePin    dw 0

Disk0SecPerClu 	db 0
Disk0Reserved 	dw 0
Disk0FatNum	db 0
Disk0Hidden	dd 0
Disk0SecSum  	dd 0
Disk0FatSize	dd 0
Disk0FirstClu	dd 0
Disk0FsInfo	dw 0
Disk0Stock	dw 0
Disk0FatPtr	dd 0
Disk0FdtPtr	dd 0
	
NextDiskInfo	db 736 dup (0)
ExtPartPtr	dd 0
PartInc	    	dd 0
DiskInc		dd 0
SecPtr		dd 0

EsiPtr		dd 0
FileName     	db 260 dup (0)
FileSubDirBuf   db 100h dup (0)
FileSubDirLen   dd 0		
FileSize        dd 0	
FileFirstClu    dd 0	
FileCluSize     dd 0

PspSeg          dw 0
DosIntMask	dw 0
DosStackPtr     dd 0
OldIdtPtr	dq 0

MsgBoxNotFat32  db 'Not FAT32 PARTITION,FILE SYSTEM FAILURE!',0
ParamLenth	equ $-1
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

Stack0Seg               =$-NullSelector
Stack0Selector   	dq 104f92400000ffffh
Stack1Seg               =$-NullSelector
Stack1Selector        	dq 104fb2500000ffffh
Stack2Seg               =$-NullSelector
Stack2Selector        	dq 104fd2600000ffffh
Stack3Seg               =$-NullSelector
Stack3Selector		dq 104ff2700000ffffh
BackingBufSeg		=$-NullSelector
BackingBufSelector	dq 104f92800000ffffh
DeskTopBackingSeg 	=$-NullSelector
DeskTopBackingSelector  dq 104f92900000ffffh

HdBufSeg           	=$-NullSelector
HdBufSelector      	dq 204f92000000ffffh
HdDataSeg		=$-NullSelector
HdDataSelector		dq 20cf92400000ffffh
VesaBackingSeg		=$-NullSelector
VesaBackingSelector	dq 30cf92000000ffffh	;256M

PmCode16Seg		=$-NullSelector
PmCode16Selector	dq 000098000000ffffh
PmCode32Seg		= $-NullSelector
PmCode32Selector	dq 0040980000000000h
PmIntSeg		= $-NullSelector
PmIntSelector	  	dq 0040980000000000h	
Tss0Seg                 =$-NullSelector
Tss0Selector            dq 0000890000000068h
Tss1Seg                 =$-NullSelector
Tss1Selector            dq 0000890000000068h
Tss2Seg                 =$-NullSelector
Tss2Selector            dq 0000890000000068h
Tss3Seg                 =$-NullSelector
Tss3Selector            dq 0000890000000068h

align 10h			
GdtLimit		dw $-1
GdtBase			dd 0
align 10h			
IdtLimit		dw 7ffh
IdtBase			dd 0
	
align 10h
Div0ExceptionDesc	dq 20h dup (00008f0000880000h)

SysTimerIntDesc		dq 00008e0000000000h
KbdIntDesc      	dq 00008e0000000000h
			dq 6 dup (00008e0000880000h)
			
RltIntDesc		dq 00008e0000000000h
			dq 3 dup (00008e0000880000h)
MouseIntDesc   		dq 00008e0000000000h 
			dq 3 dup (00008e0000880000h)              

			dq 50h dup (00008f0000000000h)

SysTimerIntCallDesc     dq 00008f0000000000h
KbdServiceDesc      	dq 00008f0000000000h
GraphServiceDesc        dq 00008f0000000000h
SunDryServiceDesc       dq 00008f0000000000h
			dq 00008f0000000000h			
			dq 3 dup (00008f0000000000h)

RltIntCallDesc          dq 00008f0000000000h
                        dq 3 dup (00008f0000000000h)
MouseServiceDesc    	dq 00008f0000000000h
CoprocServiceDesc    	dq 00008f0000000000h
HdServiceDesc           dq 00008f0000000000h
FileServiceDesc         dq 00008f0000000000h                             
			dq 112 dup (00008f0000000000h)

Tss0                    db 102 dup (0)
                        dw $+2
                        db 0ffh
Tss1                    db 102 dup (0)
                        dw $+2
                        db 0ffh                                   
Tss2                    db 102 dup (0)
                        dw $+2
                        db 0ffh
Tss3                    db 102 dup (0)
                        dw $+2
                        db 0ffh
RomLenth		equ $-1
Rom  Ends






MainProc Segment para use16
assume cs:MainProc
start:


call GetDeskTopBmpPath
call SetDescriptor
call SetVesaMode
call GetHdPortBase


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
mov ax,Rom
mov ds,ax
cli
sidt fword ptr es:[OldIdtPtr]
lgdt fword ptr ds:[GdtLimit]
lidt fword ptr ds:[IdtLimit]
mov al,2
out 92h,al
mov eax,cr0
or al,1
mov cr0,eax
                db 0eah
                dw 0
                dw PmCode16Seg
DosMode:
mov ax,Param
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[DosStackPtr]
mov ax,ds:[DosIntMask]
out 21h,al
mov al,ah
or al,11h
out 0a1h,al
lidt fword ptr ds:[OldIdtPtr]
mov ax,3
int 10h
mov ah,4ch
int 21h


GetDeskTopBmpPath proc near
mov ax,Param
mov ds,ax
push es
pop word ptr ds:[PspSeg]
mov es,ax
mov ah,19h
int 21h
inc al
push ax
mov dl,al
mov ah,47h
mov si,offset FileName
int 21h
mov di,offset FileName
mov cx,0ffh
CheckDeskTopBmpPathTerminal:
mov al,es:[di]
inc di
cmp al,0
jnz CheckDeskTopBmpPathTerminal
dec di
mov byte ptr es:[di],5ch

inc di
mov ax,ds:[PspSeg]
mov ds,ax
mov si,81h
mov cl,byte ptr ds:[80h]
movzx cx,cl
cld
rep movsb
sub di,3
mov eax,00504d42h
stosd

mov ax,es
mov ds,ax
mov si,offset FileName
add si,0feh
mov di,si
add di,3
mov cx,0ffh
std
rep movsb
cld
pop ax
add al,40h
mov di,offset FileName
stosb
mov ax,5c3ah
stosw
ret
GetDeskTopBmpPath endp





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
cld
xor eax,eax
mov ax,Rom
mov ds,ax
mov es,ax
shl eax,4
push eax
push eax
push eax
mov word ptr ds:[RomSelector+2],ax
shr eax,16
mov byte ptr ds:[RomSelector+4],al
mov byte ptr ds:[RomSelector+7],ah
mov word ptr ds:[RomSelector],RomLenth
pop eax
add eax,offset NullSelector
mov ds:[GdtBase],eax
pop eax
add eax,offset Div0ExceptionDesc
mov dword ptr ds:[IdtBase],eax

pop eax
add eax,offset Tss0
mov bx,offset Tss0Selector
mov cx,4
SetTssDesc:
push eax
mov word ptr ds:[bx+2],ax
shr eax,16
mov byte ptr ds:[bx+4],al
mov byte ptr ds:[bx+7],ah
pop eax
add eax,105
add bx,8
loop SetTssDesc


mov di,offset Div0ExceptionDesc
mov ax,PmIntSeg
shl eax,16
mov ax,offset PmIntRet
mov cx,100h
SetIntDescSeg:
stosd
add di,4
loop SetIntDescSeg

mov ax,offset PmSysTimerIntProc
mov word ptr ds:[SysTimerIntDesc],ax
mov ax,offset PmKbdIntProc
mov word ptr ds:[KbdIntDesc],ax
mov ax,offset PmRltIntProc
mov word ptr ds:[RltIntDesc],ax
mov ax,offset PmMouseIntProc
mov word ptr ds:[MouseIntDesc],ax
mov ax,offset PmKbdServiceProc
mov word ptr ds:[KbdServiceDesc],ax
mov ax,offset PmGraphServiceProc
mov word ptr ds:[GraphServiceDesc],ax
mov ax,offset PmSundryServiceProc
mov word ptr ds:[SundryServiceDesc],ax
mov ax,offset PmHdServiceProc
mov word ptr ds:[HdServiceDesc],ax
mov ax,offset PmFileServiceProc
mov word ptr ds:[FileServiceDesc],ax


xor eax,eax
mov ax,Param
mov es,ax
shl eax,4
push eax
mov ax,4f01h
mov di,offset ParamBuf
mov cx,112h
int 10h
mov eax,es:[di+28h]
mov word ptr ds:[VesaSelector+2],ax
shr eax,16
mov byte ptr ds:[VesaSelector+4],al
mov byte ptr ds:[VesaSelector+7],ah
pop eax
mov word ptr ds:[ParamSelector+2],ax
shr eax,16
mov byte ptr ds:[ParamSelector+4],al
mov byte ptr ds:[ParamSelector+7],ah
mov word ptr ds:[ParamSelector],ParamLenth

xor eax,eax
mov ax,PmCode16Proc
shl eax,4
mov word ptr ds:[PmCode16Selector+2],ax
shr eax,16
mov byte ptr ds:[PmCode16Selector+4],al
mov byte ptr ds:[PmCode16Selector+7],ah
mov word ptr ds:[PmCode16Selector],PmCode16ProcLenth	;What's  normal format of Rm Code segment??? 

xor eax,eax
mov ax,PmCode32Proc
shl eax,4
mov word ptr ds:[PmCode32Selector+2],ax
shr eax,16
mov byte ptr ds:[PmCode32Selector+4],al
mov byte ptr ds:[PmCode32Selector+7],ah
mov word ptr ds:[PmCode32Selector],PmCode32ProcLenth

xor eax,eax
mov ax,PmIntProc
shl eax,4
mov word ptr ds:[PmIntSelector+2],ax
shr eax,16
mov byte ptr ds:[PmIntSelector+4],al
mov byte ptr ds:[PmIntSelector+7],ah
mov word ptr ds:[PmIntSelector],PmIntProcLenth
ret
SetDescriptor endp






GetHdPortBase proc near
mov ax,Param
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
mov dx,ds:[HdPortBase]
add dx,7
in al,dx
cmp al,50h
jnz GetHdPortOk
ret

GetHdPciPortBase:
pushad
mov esi,offset HdPciPort
mov ecx,2
CheckHdPciPort:
push ecx
push esi
lodsw
mov dx,ax
add dx,6
mov al,ds:[HdSlaveFlag]
call CheckHdPort
cmp word ptr ds:[HdPortBase],0
jnz FindHdPciPortBase
pop esi
add esi,10
pop ecx
loop CheckHdPciPort
popad
ret
FindHdPciPortBase:
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
sub dx,4
mov al,1
out dx,ax
add dx,5
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
mov edi,offset ParamBuf
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
add eax,18h
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


























MainProc ends






PmIntProc segment page use32
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
push fs
push gs
cld
mov ax,ParamSeg
mov ds,ax   
in al,60h
mov byte ptr ds:[ScanCode],al
call AnalysisScanCode  
PmKbdIntRet:
mov al,20h
out 20h,al
pop gs
pop fs
pop es
pop ds
popad
iretd

AnalysisScanCode proc near
CheckMakeCtrl:
cmp byte ptr ds:[ScanCode],1dh		;1dh=Ctrl
jnz CheckMakeShiftLeft
or byte ptr ds:[KbdStatus],4
ret
CheckMakeShiftLeft:
cmp byte ptr ds:[ScanCode],2ah		;2ah=Shift Left
jnz CheckMakeShiftRight
or byte ptr ds:[KbdStatus],2
ret
CheckMakeShiftRight:
cmp byte ptr ds:[ScanCode],36h		;36h=Shift Right
jnz CheckMakeAlt
or byte ptr ds:[KbdStatus],1
ret
CheckMakeAlt:
cmp byte ptr ds:[ScanCode],38h		;38h=Alt
jnz CheckMakeCapsLock
or byte ptr ds:[KbdStatus],8
ret
CheckMakeCapsLock:
cmp byte ptr ds:[ScanCode],3ah		;3ah=CapsLock
jnz CheckMakeScrollLock
call MakeCapsLock                       
ret
CheckMakeScrollLock:
cmp byte ptr ds:[ScanCode],46h		;46h=ScrollLock
jnz CheckMakeNumsLock
call MakeScrollLock                            
ret
CheckMakeNumsLock:
cmp byte ptr ds:[ScanCode],45h		;45h=NumsLock
jnz CheckBreakShiftRight
call MakeNumsLock 
ret
CheckBreakShiftRight:
cmp byte ptr ds:[ScanCode],0b6h		;0b6h=Shift Left
jnz CheckBreakShiftLeft
and byte ptr ds:[KbdStatus],0feh
ret
CheckBreakShiftLeft:
cmp byte ptr ds:[ScanCode],0aah		;0aah=Shift Right
jnz CheckBreakCtrl
and byte ptr ds:[KbdStatus],0fdh
ret
CheckBreakCtrl:
cmp byte ptr ds:[ScanCode],9dh		;9dh=Ctrl
jnz CheckBreakAlt
and byte ptr ds:[KbdStatus],0fbH
ret
CheckBreakAlt:
cmp byte ptr ds:[ScanCode],0b8h		;0b8h=Alt
jnz CheckMakeInsert
and byte ptr ds:[KbdStatus],0f7h
ret
CheckMakeInsert:
cmp byte ptr ds:[ScanCode],52h		;52h=Insert
jnz CheckMakeDelete
xor byte ptr ds:[KbdStatus],80h
jmp ToScanCodeToAscii
CheckMakeDelete:
cmp byte ptr ds:[ScanCode],53h		;53h=Delete
jnz CheckInvalidBreakScanCode
test byte ptr ds:[KbdStatus],4
jz ToScanCodeToAscii
test byte ptr ds:[KbdStatus],8
jz ToScanCodeToAscii
call ShutSystem
CheckInvalidBreakScanCode:
cmp byte ptr ds:[ScanCode],80h
jae AnalysisScanCodeReturn
ToScanCodeToAscii:
call ScanCodeToAscii
AnalysisScanCodeReturn:
retn
AnalysisScanCode endp


ScanCodeToAscii proc near
mov al,byte ptr ds:[KbdStatus]
and al,40h
jnz ScanCodeCapsLock
test byte ptr ds:[KbdStatus],3
jnz ScanCodeShift
jmp ScanCodeNormal
ScanCodeCapsLock:
shr al,5
test al,byte ptr ds:[KbdStatus]
jz CheckShiftRightCapsLock	;ScanCodeNormal
jmp ShiftAndCapsLock
CheckShiftRightCapsLock:
shr al,1
test al,byte ptr ds:[KbdStatus]
jz OnlyCapsLock
ShiftAndCapsLock:
cmp byte ptr ds:[ScanCode],10h
jb ScanCodeShift
cmp byte ptr ds:[ScanCode],19h
jbe ScanCodeNormal
cmp byte ptr ds:[ScanCode],1eh
jb ScanCodeShift
cmp byte ptr ds:[ScanCode],26h
jbe ScanCodeNormal
cmp byte ptr ds:[ScanCode],2ch
jb ScanCodeShift
cmp byte ptr ds:[ScanCode],32h
jbe ScanCodeNormal
jmp ScanCodeShift
OnlyCapsLock:
cmp BYTE PTR ds:[scancode],10h
jb  ScanCodeNormal
cmp BYTE PTR ds:[scancode],19h
jbe ScanCodeShift
cmp BYTE PTR ds:[scancode],1eh
jb  ScanCodeNormal
cmp BYTE PTR ds:[scancode],26h
jbe ScanCodeShift
CMP byte ptr ds:[scancode],2ch
jb  ScanCodeNormal
cmp byte ptr ds:[scancode],32h
jbe ScanCodeShift
ScanCodeNormal:
mov ebx,offset TransScanCodeNormal
jmp TranslateScanCode
ScanCodeShift:
mov ebx,offset TransScanCodeShift
TranslateScanCode:
mov al,byte ptr ds:[ScanCode]
xlat 
mov ah,byte ptr ds:[ScanCode]
cmp ah,39h
jb  StoreKeyValue
mov al,0
StoreKeyValue:
mov edi,dword ptr ds:[KbdBufDetail]
add edi,2		
cmp edi,offset KbdBufHead
jnz KbdBufNotDetail
mov edi,offset KbdBuf
KbdBufNotDetail:
mov dword ptr ds:[KbdBufDetail],edi	
mov word ptr ds:[edi],ax
ret
ScanCodeToAscii endp


SetKbdLed proc near
call waitIn
mov al,0adh
out 64h,al
call WaitIn
mov al,0edh
out 60h,al
call waitOut
in al,60h
cmp al,0fah
jnz SetKbdLed
ResendKbdLedCom:
call waitIn
mov al,byte ptr ds:[KbdLedStatus]
out 60h,al
call waitOut        ;here u get return byte 0fah,but why can't read it out ?
in al,60h
cmp al,0fah
jnz ResendKbdLedCom
call WaitIn
mov al,0aeh
out 64h,al
ret
SetKbdLed endp

MakeScrollLock proc near
xor byte ptr ds:[KbdStatus],10h
xor byte ptr ds:[KbdLedStatus],1
call SetKbdLed
ret
MakeScrollLock endp

MakeNumsLock proc near
xor byte ptr ds:[KbdStatus],20h
xor byte ptr ds:[KbdLedStatus],2
call SetKbdLed
ret
MakeNumsLock endp

MakeCapsLock proc near
Xor byte ptr ds:[KbdStatus],40h
xor byte ptr ds:[KbdLedStatus],4
call SetKbdLed
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

ShutSystem proc near
mov dx,0cf8h
mov eax,8000f840h 
out dx,eax
mov dx,0cfch
in eax,dx
and al,0feh    
mov dx,ax
push dx
add dx,30h 
in ax,dx
and ax,0ffefh
out dx,ax
pop dx
add dx,5 
in al,dx
or al,3ch
out dx,al
ShutSystem endp







PmRltIntProc:
pushad
push ds
push es
push fs
push gs
mov al,0ch
out 70h,al
in al,71h
cmp al,90h
jz RltTimingInt
cmp al,0a0h
jz RltAlarmInt
cmp al,0c0h
jz RltPeriodInt

RltPeriodInt:
mov ax,ParamSeg
mov ds,ax
mov ax,VesaSeg
mov es,ax
cmp dword ptr ds:[DeskTopBkgrdAlterFlag],1
jnz NoNeedToKeepDeskTopBkgrd
mov bh,0
int 83h
NoNeedToKeepDeskTopBkgrd:
mov eax,ds:[MouseColor]
mov edi,ds:[MousePos]
mov ecx,16
cld
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
jmp PmRltIntRet



RltAlarmInt:
jmp PmRltIntRet



RltTimingInt:
mov ax,ParamSeg
mov ds,ax
cmp byte ptr ds:[DeskTopBkgrdAlterFlag],1
jnz ToRestoreRltBkgrd
mov bh,0
int 83h
ToRestoreRltBkgrd:
mov edi,ds:[RltTimingPos]
mov ax,BackingBufSeg
mov ds,ax
mov esi,1024
mov ax,VesaSeg
mov es,ax
mov ecx,8
cld
RestoreRtlBkgrd:
push ecx
push edi
mov ecx,64
rep movsd
pop edi
add edi,2560
pop ecx
loop RestoreRtlBkgrd

mov ax,ParamSeg
mov ds,ax
push dword ptr ds:[FontColor]
pop dword ptr ds:[FontColorStore]
push dword ptr ds:[RltFontColor]
pop dword ptr ds:[FontColor]
mov edi,ds:[RltTimingPos]
mov al,4
out 70h,al
in al,71h
call HexToAsc
mov bh,0
int 82h
xchg ah,al
mov bh,0
int 82h
mov eax,3ah
mov bh,0
int 82h
mov al,2
out 70h,al
in al,71h
call HexToAsc
mov bh,0
int 82h
xchg ah,al
mov bh,0
int 82h
mov al,3ah
mov bh,0
int 82h
mov al,0
out 70h,al
in al,71h
call HexToAsc
mov bh,0
int 82h
xchg ah,al
mov bh,0
int 82h
push dword ptr ds:[FontColorStore]
pop dword ptr ds:[FontColor]
add dword ptr ds:[RltFontColor],8020c0h
PmRltIntRet:
mov al,20h
out 20h,al
out 0a0h,al
pop gs
pop fs
pop es
pop ds
popad
iretd

HexToAsc:                   ;input al,output ax
push ebx
mov bh,al
shr al,4
cmp al,9
jbe TranslateDigitalHigh
add al,7
TranslateDigitalHigh:
add al,30h
mov bl,al
mov al,bh
and al,0fh
cmp al,9
jbe TranslateDigitalLow
add al,7
TranslateDigitalLow:
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
cmp byte ptr ds:[DeskTopBkgrdAlterFlag],1
jnz GetMousePacket
mov bh,0
int 83h
GetMousePacket:
mov ebx,ds:[MousePacketNum]
in al,60h
movsx eax,al
mov ds:[MouseStatus+ebx],eax
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
mov edi,ds:[MousePos]
mov ax,VesaSeg
mov es,ax
mov ax,BackingBufSeg
mov ds,ax
mov esi,0
mov ecx,16
cld
RestoreMouseBkgrd:
push ecx
push edi
mov ecx,16
rep movsd
pop edi
add edi,2560
pop ecx
loop RestoreMouseBkgrd

GetMousePos:
mov ax,ParamSeg
mov ds,ax
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

mov esi,eax
mov ax,VesaSeg
mov ds,ax
mov ax,BackingBufSeg
mov es,ax
mov edi,0
mov ecx,16
SaveMouseBkgrd:
push ecx
push esi
mov ecx,16
rep movsd
pop esi
add esi,2560
pop ecx
loop SaveMouseBkgrd

mov ax,ParamSeg
mov ds,ax
mov ax,VesaSeg
mov es,ax
mov edi,ds:[MousePos]
mov eax,ds:[MouseColor]
mov ecx,16
ShowMouseGraph:
push ecx
push edi
mov ecx,16
rep stosd
pop edi
add edi,2560
pop ecx
loop ShowMouseGraph
jmp PmMouseIntReturn	;jmp is illegal when offset above 128b in masm5.0,why?????






PmKbdServiceProc proc near
cmp bh,0
jz WaitForInputAKey
iretd

WaitForInputAKey:
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
pop ds
pop esi
iretd
PmKbdServiceProc endp








PmGraphServiceproc:            ;input:eax=ascii char ,edi=position
cmp bh,0
jz ToVesaShowGraphChar
cmp bh,1
jz ToMessageBox
iretd

ToVesaShowGraphChar:
jmp VesaShowGraphChar
ToMessageBox:
jmp MessageBox

VesaShowGraphChar:
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
call ShowCharGraphLine
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
jnz ShowGraphCharRet
add edi,2560*7
cmp edi,2560*480
jnz ShowGraphCharRet
mov edi,0
ShowGraphCharRet:
pop es
pop ds
pop esi
pop edx
pop ecx
pop ebx
pop eax
iretd

ShowCharGraphLine:
push eax
push ebx
push ecx
push ds
mov bl,al
mov bh,128
mov ax,ParamSeg
mov ds,ax
mov ecx,8
cld
DrawCharPixLine:
push ecx
mov al,bl
and al,bh
cmp al,0
jnz DrawCharPixDot
add edi,4
jmp InspectNextPix
DrawCharPixDot:
mov eax,ds:[FontColor]
stosd
InspectNextPix:
shr bh,1
pop ecx
loop DrawCharPixLine
pop ds
pop ecx
pop ebx
pop eax
ret



MessageBox:
pushad
push ds
push es
mov ax,ParamSeg
mov ds,ax
mov ax,VesaSeg
mov es,ax
mov edi,461020
mov ecx,120
ShowMsgBox:
push ecx
push edi
mov ecx,200
mov eax,7fh
rep stosd
pop edi
add edi,2560
pop ecx
loop ShowMsgBox

mov esi,offset MsgBoxNotFat32
mov edi,604380
MsgShowNextChar:
lodsb
cmp al,0
jz ShowMsgEnd
mov bh,0
int 82h
jmp MsgShowNextChar
ShowMsgEnd:
pop es
pop ds
popad
iretd







PmSundryServiceProc:
cmp bh,0
jz InitMouseRltTiming
iretd

InitMouseRltTiming proc near
pushad
push ds
push es
mov ax,ParamSeg
mov ds,ax
mov esi,ds:[MousePos]
mov ax,VesaSeg
mov ds,ax
mov ax,BackingBufSeg
mov es,ax
mov edi,0
mov ecx,16
cld
SaveMouseBkgrdFirst:
push ecx
push esi
mov ecx,16
rep movsd
pop esi
add esi,2560
pop ecx
loop SaveMouseBkgrdFirst

mov ax,ParamSeg
mov ds,ax
mov esi,ds:[RltTimingPos]
mov ax,VesaSeg
mov ds,ax
mov ax,BackingBufSeg
mov es,ax
mov edi,1024
mov ecx,8
SaveRltTimingBkgrdFirst:
push ecx
push esi
mov ecx,64
rep movsd
pop esi
add esi,2560
pop ecx
loop SaveRltTimingBkgrdFirst

mov ax,ParamSeg
mov ds,ax
mov ax,VesaSeg
mov es,ax
mov eax,ds:[MouseColor]
mov edi,ds:[MousePos]
mov ecx,16
ShowMouseFirst:
push ecx
push edi
mov ecx,16
rep stosd
pop edi
add edi,2560
pop ecx
loop ShowMouseFirst
mov byte ptr ds:[DeskTopBkgrdAlterFlag],0
pop es
pop ds
popad
iretd
InitMouseRltTiming  Endp










;how to reference the function?which reg is much better as a function index?
;eax looks no good,cx is also,dx is not appropriate,so bx is perceived to be better,but DOS used to 
;use ah as a function index,cause ebx will be assigned again as a pointer,but eax and ecx and edx will be good to be parameters,
PmHdServiceProc:
cmp bh,0
jz ToReadSector
cmp bh,1
jz ToWriteSector
cmp bh,2
jz ToGetDiskInfo
iretd

ToReadSector:
jmp ReadSector
ToWriteSector:
jmp WriteSector
ToGetDiskInfo:
jmp GetDiskInfo


ReadSector proc near            ;input ecx,eax,es:[edi]
push eax
push ecx
push edx
push ds

push ecx
push eax
mov ax,ParamSeg
mov ds,ax
mov dx,ds:[HdPortBase]
add dx,7
WaitIdeFree:
in al,dx
cmp al,50h
jnz WaitIdeFree
dec dx	
mov al,ds:[HdSlaveFlag]
out dx,al
dec dx	
mov al,0
out dx,al
dec dx 	
out dx,al
dec dx	
pop eax
rol eax,8
out dx,al
add dx,2	
rol eax,8
out dx,al
dec dx 		
rol eax,8
out dx,al
dec dx		
rol eax,8
out dx,al
dec dx
pop ecx
mov ax,cx
xchg ah,al
out dx,al
xchg ah,al
out dx,al
add dx,5
mov al,29h
out dx,al
WaitHdReady:
in al,dx
and al,0fdh
cmp al,58h
jnz WaitHdReady
sub dx,7
shl ecx,8
cld
rep insw
add dx,7
CheckIdeStatus:
in al,dx
cmp al,50h
jnz CheckIdeStatus
pop ds
pop edx
pop ecx
pop eax
iretd
ReadSector endp



WriteSector:
iretd

GetDiskInfo proc near
pushad
push ds
push es
push fs
push gs
mov ax,ParamSeg
mov ds,ax
mov ax,HdBufSeg
mov es,ax
cld
mov eax,0
mov ecx,1
mov edi,0
mov bh,0
int 8eh
mov al,byte ptr es:[1c2h]
cmp al,0bh
jz  MainPartFat32
cmp al,0ch
jz  MainPartFat32
cmp al,1bh
jz  MainPartFat32
cmp al,1ch
jnz CheckExtPartType
MainPartFat32:		 
mov eax,dword ptr es:[1c6h]
mov ecx,1
mov edi,400h
mov bh,0
int 8eh
call CopyBPB

CheckExtPartType:
mov al,byte ptr es:[1d2h]
cmp al,0fh
jz CheckExtPart
cmp al,5
jnz CheckPartEnd

CheckExtPart:
mov eax,dword ptr es:[1d6h]
mov ds:[ExtPartPtr],eax
mov ecx,1
mov edi,200h
mov bh,0
int 8eh

ExtMainPart:
cmp word ptr es:[3feh],0aa55h
jnz CheckPartEnd
mov eax,dword ptr es:[3c6h]
add eax,ds:[ExtPartPtr]
mov ds:[ExtpartPtr],eax
mov ecx,1
mov edi,400h
mov bh,0
int 8eh
cmp dword ptr es:[452h],33544146h
jnz NextLogicalPart
call CopyBPB
NextLogicalPart:
mov eax,dword ptr es:[3cah]
cmp eax,0
jz CheckPartEnd
add eax,ds:[ExtPartPtr]
mov ds:[ExtPartPtr],eax
mov ecx,1
mov edi,200h
mov bh,0
int 8eh
jmp ExtMainPart

CheckPartEnd:
cmp dword ptr ds:[DiskInc],0
jz MessageBoxNotFat32
shr dword ptr ds:[DiskInc],5
call CalcDiskParam
GetDiskInfoReturn:
pop gs
pop fs
pop es
pop ds
popad
iretd

MessageBoxNotFat32:
mov bh,1
int 82h
mov bh,0
int 81h
jmp GetDiskInfoReturn

CopyBPB:
pushad
push ds
push es
mov ax,ds
mov bx,es
mov ds,bx
mov es,ax
mov esi,40dh
mov edi,offset Disk0SecPerClu
add edi,dword ptr es:[DiskInc]
cld
movsd
mov esi,41ch
movsd
movsd                                              
movsd
mov esi,42ch		
movsd
mov esi,430h
movsd
add dword ptr es:[DiskInc],20h
pop es
pop ds
popad
ret

CalcDiskParam:
push eax
push ebx
push ecx
push edx
push ds
mov ax,ParamSeg
mov ds,ax
mov ebx,0
mov ecx,ds:[DiskInc]
CalcFAT:
mov eax,ds:[ebx+Disk0Hidden]
mov dx,ds:[ebx+Disk0Reserved]
movzx edx,dx
add eax,edx
mov ds:[ebx+Disk0FATptr],eax
add ebx,20h
loop CalcFAT
mov ebx,0
mov ecx,ds:[DiskInc]
CalcFDT:
mov eax,ds:[ebx+Disk0FATSize]
mov dl,ds:[ebx+Disk0FATnum]
movzx edx,dl
mul edx
add eax,ds:[ebx+Disk0FATptr]
mov ds:[ebx+Disk0FDTptr],eax
add ebx,20h
loop CalcFDT
pop ds
pop edx
pop ecx
pop ebx
pop eax
ret
GetDiskInfo endp

















PmFileServiceProc:
cmp bh,0
jz ToPmOpenFile
cmp bh,1
jz ToPmReadFile
iretd
ToPmOpenFile:
jmp PmOpenFile
ToPmReadFile:
jmp PmReadFile

PmOpenFile Proc near
cli
pushad
push ds
push es
push fs
push gs
mov ax,ParamSeg
mov ds,ax
mov es,ax
mov esi,offset FileName

cld        
lodsb
cmp al,43h		;'C'
jl FileNameInvalid
cmp al,5ah		;'Z'
jle FileNameCapitals
cmp al,63h		;'c'
jl FileNameInvalid
cmp al,7ah		;'z'
jg FileNameInvalid
sub al,20h
FileNameCapitals:
sub al,43h		;'C'
movzx eax,al
cmp eax,ds:[DiskInc]	
jge FileNameInvalid
shl eax,5
mov ds:[PartInc],eax
lodsw
cmp ax,5c3ah		
jnz FileNameInvalid
mov ebx,ds:[PartInc]
mov ebx,ds:[ebx+Disk0FDTptr]
mov ds:[SecPtr],ebx

HandleFileName:
mov esi,ds:[EsiPtr]

mov edi,offset FileSubDirBuf
mov dword ptr ds:[FileSubDirLen],0
CheckFileSubDir:
cmp esi,offset FileSubDirLen
jz FileNameInvalid
cld
lodsb
cmp al,5ch		
jz GetFileSubDir
cmp al,2eh		
jz GetFileSoleName
stosb
inc dword ptr ds:[FileSubDirLen]
jmp CheckFileSubDir

FileNameInvalid:
mov bh,1
int 82h
mov bh,0
int 81h
jmp OpenFileRet


GetFileSubDir:
mov ecx,11
sub ecx,dword ptr ds:[FileSubDirLen]
mov al,20h
cld
rep stosb

mov ds:[EsiPtr],esi
call near ptr LowerLetterToCapitals
call near ptr ReadFileSubDir
jmp HandleFileName

GetFileSoleName:
mov ecx,8
sub ecx,ds:[FileSubDirLen]
mov al,20h
cld
rep stosb
mov ecx,3
rep movsb
call near ptr LowerLetterToCapitals
call near ptr ReadFileSubDir
OpenFileRet:
pop gs
pop fs
pop es
pop ds
popad
iretd



LowerLetterToCapitals:
push eax
push ecx
push esi
push edi
push ds
push es
mov ax,ParamSeg
mov ds,ax
mov es,ax
mov esi,offset FileSubDirBuf
mov edi,offset FileSubDirBuf
mov ecx,10h
cld	
LowerCaseToUpperCase:
lodsb
cmp al,7ah
ja NeglectLetter
cmp al,61h
jb NeglectLetter
sub al,20h
NeglectLetter:
stosb
loop LowerCaseToUpperCase
;mov eax,20202020h
;stosd
pop es
pop ds
pop edi
pop esi
pop ecx
pop eax
ret

ReadFileSubDir:
pushad
push ds
push es
mov ax,ParamSeg
mov ds,ax
mov ax,HdBufSeg
mov es,ax
mov ebx,ds:[PartInc]
mov cl,byte ptr ds:[ebx+Disk0SecPerClu]
movzx ecx,cl
mov eax,ds:[SecPtr]
mov edi,0
mov bh,0
int 8eh

mov ebx,ds:[PartInc]
mov cl,ds:[ebx+Disk0SecPerClu]
movzx ecx,cl
shl ecx,4		
mov esi,offset FileSubDirBuf
mov edi,0
SearchFileNameInFdt:
push ecx
push esi
push edi
mov ecx,11
repz cmpsb
cmp ecx,0
jz FindShortNameInFdt
pop edi
add edi,20h
pop esi
pop ecx
loop SearchFileNameInFdt
mov bh,1
int 82h
mov bh,0
int 81h
jmp ReadFileSubDirRet
FindShortNameInFdt:
pop edi
pop esi
pop ecx
mov ax,word ptr es:[edi+14h]
shl eax,16
mov ax,word ptr es:[edi+1ah]		
mov dword ptr ds:[FileFirstClu],eax
mov eax,es:[edi+1ch]
mov ds:[FileSize],eax
mov eax,ds:[FileFirstClu]
mov ebx,ds:[PartInc]
sub eax,ds:[ebx+Disk0FirstClu]
mov dl,ds:[ebx+Disk0SecPerClu]
movzx edx,dl
mul edx
add eax,ds:[ebx+Disk0FDTptr]
mov ds:[SecPtr],eax
ReadFileSubDirRet:
pop es
pop ds
popad
ret
PmOpenFile endp








PmReadFile Proc near
cli
pushad
push ds
push es
mov ax,ParamSeg
mov ds,ax
mov ax,HdDataSeg
mov es,ax
mov ebx,ds:[PartInc]
mov cl,ds:[ebx+Disk0SecPerClu]
movzx ecx,cl
shl ecx,9
mov ds:[FileCluSize],ecx

mov eax,ds:[FileSize]
mov edx,0
div ecx
cmp edx,0
jz  FileClusterAlignment
inc eax
FileClusterAlignment:
mov ecx,eax
mov edi,0
ReadFileClu:
push ecx
push edi
mov ebx,ds:[PartInc]
mov cl,ds:[ebx+Disk0SecPerClu]
movzx ecx,cl
mov eax,ds:[SecPtr]
mov bh,0
int 8eh
call near ptr GetNextCluNum
pop edi
add edi,dword ptr ds:[FileCluSize]
pop ecx
loop ReadFileClu
pop es
pop ds
popad
iretd



GetNextCluNum:
pushad
push ds
push es
mov ax,ParamSeg
mov ds,ax
mov ax,HdBufSeg
mov es,ax
mov eax,ds:[FileFirstClu]
shl eax,2
mov edx,0
mov ecx,512
div ecx 		
push edx
mov ebx,ds:[PartInc]
add eax,ds:[ebx+Disk0FATptr]
mov ecx,1
mov edi,0
mov bh,0
int 8eh
pop edx
mov eax,dword ptr es:[edx]
;mov ds:[FileFirstClu],eax
mov ebx,ds:[PartInc]
sub eax,ds:[ebx+Disk0FirstClu]
mov cl,ds:[ebx+Disk0SecPerClu]
movzx ecx,cl
mul ecx
add eax,ds:[ebx+Disk0FDTptr]
mov ds:[SecPtr],eax
pop es
pop ds
popad
ret
PmReadFile Endp








PmIntProcLenth                  equ $-1
PmIntProc ends














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
PmCode16ProcLenth              equ $-1
PmCode16Proc ends







PmCode32Proc segment page use32
assume cs:PmCode32Proc
cli
mov bx,Tss0Seg
ltr bx
mov ax,ParamSeg
mov ds,ax
mov fs,ax
mov gs,ax
mov ax,VesaSeg
mov es,ax
mov ax,Stack0Seg
mov ss,ax
mov esp,8000h

mov dword ptr ds:[DeskTopBkGrdAlterFlag],1
call Init8259
call SetSysTimerPort
call SetRltPort
call SetMousePort

sti
mov bh,2
int 8eh
mov bh,0
int 81h
mov bh,0
int 8fh
mov bh,1
int 8fh

mov ax,VesaSeg
mov es,ax
mov ax,HdDataSeg
mov ds,ax
cld
mov esi,860214;1720374
sub esi,1920
mov edi,0
mov ecx,448
l0:
push esi
push edi
push ecx
mov ecx,640
l1:
movsb
movsb
movsb
mov al,0
stosb
loop l1
pop ecx
pop edi
add edi,2560
pop esi
sub esi,1920
loop l0

mov edi,0
push dword ptr ds:[VesaFontColor]
pop dword ptr ds:[FontColor]
InOutChar:
mov bh,0
int 81h
cmp al,1bh
jz ToRealMode
mov bh,0
int 82h
jmp InOutChar

ToRealMode:
call Restore8259
db 0eah
dw offset ToDosMode
dw 0
dw PmCode16Seg







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
mov al,0f8h     ;IRQ2 must be enabled!
out 21h,al
mov al,0eeh
out 0a1h,al
;mov al,0
;mov dx,4d1h
;out dx,al
;mov al,0
;mov dx,4d0h
;out dx,al
ret
Init8259 endp

SetSysTimerPort proc near
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
in al,61h		;port 61h is used for what?????
mov al,1
out 61h,al
ret
SetSysTimerPort endp


SetMousePort proc near
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
SetMousePort endp

SetRltPort proc near
cli
mov al,0bh
out 70h,al
mov al,72h      ;enable periodic and timing int
out 71h,al
ret
SetRltPort endp








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


























PmCode32ProcLenth               equ $-1
PmCode32Proc ends
end start
