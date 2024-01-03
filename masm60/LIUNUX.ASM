.386p

Kernel Segment para use16
assume cs:kernel

jmp MainProc

Disk1SecPerClu 	db 0
Disk1Reserved 	dw 0
Disk1FatNum	db 0
Disk1Hidden	dd 0
Disk1FatSize	dd 0
Disk1FirstClu	dd 0
Disk1FsInfo	dw 0
Disk1Stock	dw 0
Disk1FatPtr	dd 0
Disk1FdtPtr	dd 0
		dd 0		
NextDisk	db 288 dup (0)

MbrBase		db 200h dup (0)
EbrBase		db 200h dup (0)
DbrBase		db 200h dup (0)
ExtPartPtr	dd 0
PartInc	    	dw 0
DiskInc		dw 0

DapHead		dw 10h
DapSecNum	dw 0
DapAddr		dd 0
DapSecAlloc	dq 0

FileName	db 80h dup (0)
NameBuf		db 10h dup (0)
DirLen     	dw 0
CluTable	dd 0
CluSize		dd 0
FileSize	dd 0
DataSeg		dw 3000h
FileType	db 0
CursorPos	dw 320

PSP		dw 20cdh
SectionNum	dw 0
		db 0
ToLiunux	db 0eah
LiunuxIP	dw offset ToGetCommand		;Important!!!
LiunuxCS	dw 1000h
Int22Addr	dd 0
Int23Addr	dd 0
Int24Addr	dd 0
ParentPSP	dw 0
SoftNum		db 20 dup (0)
EnviromentSeg	dw 0
UserStackPtr	dd 0		;Important!!!
		db 30 dup (0)
MachineCode	dw 21cdh
		db 0cbh
		dw 0
FCBext		db 7 dup (0)
FCB1		db 16 dup (0)
FCB2		db 16 dup (0)
		dd 0
CommandLine	db 128 dup (0)		
ProcessFlag	db 0		

SysStackPtr	dd 0		
MsgInput    	db 'Please Input File Name(Include full Path):',0dh,0ah,24h
MsgNotFound	db 'Not Existed File or Error File Format.',0dh,0ah,24h
MsgNotFat32	db 'Only Support FAT32 Partition,Please Check Ur Disk Format.',0dh,0ah,24h
MsgNotEnoughMem db 'Not Enough Memory.',0ah,0dh,24h

MainProc:
call Init
call GetDiskInfo
ToGetCommand:
mov byte ptr cs:[ProcessFlag],0
Call GetCommand
call OpenFile
call ReadFile
cmp byte ptr cs:[FileType],1
jz ComFile
cmp byte ptr cs:[FileType],2
jz ExeFile
cmp byte ptr cs:[FileType],3
jz BmpFile
cmp Byte ptr cs:[FileType],4	
jz TxtFile		
jmp ToGetCommand
ComFile:
mov byte ptr cs:[ProcessFlag],1
call RunCom
jmp ToGetCommand
ExeFile:
mov byte ptr cs:[ProcessFlag],1
call RunExe
jmp ToGetCommand
BmpFile:
call ShowBmp
jmp ToGetCommand
TxtFile:		
call ShowTxt		
jmp ToGetCommand	








Init proc near
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

cld
mov ax,0
mov es,ax
mov di,76h
shl di,2
mov ax,2000h
shl eax,16
mov ax,offset IntIretProc
stosd
stosd

mov di,0
shl di,2
mov ax,offset Int0Proc
stosw
mov ax,2000h
stosw

;BIOS Parameter Block in 40:0--40:0ffh is NOT need to init
mov di,2
shl di,2
mov ax,offset Int2Proc
stosw
mov ax,2000h
stosw

mov di,4
shl di,2
mov ax,offset Int4Proc
stosw
mov ax,2000h
stosw

mov di,8
shl di,2
mov ax,offset SysTimerIntProc
stosw
mov ax,2000h
stosw

mov di,9
shl di,2
mov ax,offset KbdIntProc
stosw
mov ax,2000h
stosw

mov di,16h
shl di,2
mov ax,offset Int16Proc
stosw
mov ax,2000h
stosw

mov di,1bh
shl di,2
mov ax,offset Int1bProc
stosw
mov ax,2000h
stosw

mov di,1ch
shl di,2
mov ax,offset Int1cProc
stosw
mov ax,2000h
stosw

mov di,20h
shl di,2
mov ax,offset QuitProg
stosw
mov ax,cs
stosw
mov di,21h
shl di,2
mov ax,offset Int21Proc
stosw
mov ax,cs
stosw
mov di,22h
shl di,2
mov ax,offset QuitProg
stosw
mov ax,cs
stosw
mov di,23h
shl di,2
mov ax,offset Int23Proc
stosw
mov ax,2000h
stosw

mov di,70h
shl di,2
mov ax,offset RealTimerIntProc
stosw
mov ax,2000h
stosw

mov di,74h
shl di,2
mov ax,offset MouseIntProc
stosw
mov ax,2000h
stosw

mov di,75h
shl di,2
mov ax,offset CorprocessorIntProc
stosw
mov ax,2000h
stosw

;mov eax,8000f8d0h
;mov dx,0cf8h
;out dx,eax
;mov dx,0cfch
;in  eax,dx
;or  eax,2000h
;out dx,eax
;mov dx,4d0h	;4d0h(ELCR1) d6 can not be set(level Mode),why?
;mov al,0ffh	;ELCR1(4d0h)d0,d1,d2 and ELCR2(4d1h)d0,d5 can't set(Level Mode)
;out dx,al
;mov dx,4d1h
;out dx,al

mov ax,ss
shl eax,16
mov ax,sp
mov cs:[SysStackPtr],eax

push es
mov ax,2000h
mov es,ax
mov ax,ss
shl eax,16
mov ax,sp
mov dword ptr es:[DriverStackPtr],eax
pop es


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

call WaitIn8042
mov al,0adh
out 64h,al
call WaitIn8042
mov al,0a8h
out 64h,al
call WaitIn8042
mov al,0d4h
out 64h,al
ReEnableMouse:
call WaitIn8042
mov al,0f4h
out 60h,al
call WaitOut8042
in al,60h
cmp al,0fah
jnz ReEnableMouse
call WaitIn8042
mov al,60h
out 64h,al
call WaitIn8042
mov al,47h
out 60h,al
call WaitIn8042
mov al,0aeh
out 64h,al

mov al,0bh
out 70h,al
mov al,1ah
out 71h,al

mov al,0
out 21h,al
mov al,0
out 0a1h,al
sti
mov ax,3
int 10h
ret
Init endp


WaitIn8042 proc near
in al,64h
test al,2
jnz WaitIn8042
ret
WaitIn8042 endp


WaitOut8042 proc near
in al,64h
test al,1
jz WaitOut8042
ret
WaitOut8042 endp




Int21Proc Proc near
cmp ah,9
jz ShowString
cmp ah,0ah
jz GetString
cmp ah,31h
jz StayInMem
cmp ah,4ch
jz QuitProg

StayInMem:
add word ptr cs:[DataSeg],dx
add word ptr cs:[DataSeg],10h
QuitProg:
cli
lss sp,dword ptr cs:[UserStackPtr]
pop es
pop ds
popad
popf
sti
JmpToGetCommand		db 0eah
			dw offset ToGetCommand
			dw 1000h
ShowString:
pushad
push es
mov si,dx
mov ax,0b800h
mov es,ax
mov di,cs:[CursorPos]
cld
ReadCharFromSrc:
mov ah,0ah
lodsb
cmp al,24h
jz EndShowString
cmp al,0dh
jz ReturnBack
cmp al,0ah
jz NextLine
Stosw
jmp ReadCharFromSrc

ReturnBack:
mov ax,di
mov bl,160
div bl
cmp ah,0
jz EndReturnBack
xchg ah,al
movzx ax,al
sub di,ax
EndReturnBack:
jmp ReadCharFromSrc

NextLine:
add di,160
jmp ReadCharFromSrc

EndShowString:
mov cs:[CursorPos],di
call ShowCursor
pop es
popad
iret

GetString:
pushad
push es
mov ax,0b800h
mov es,ax
mov di,cs:[CursorPos]
mov si,dx
mov cl,ds:[si]
movzx cx,cl
cmp cx,0
jz GetStringReturn
inc si
mov byte ptr ds:[si],0
inc si
GetStringInt21:
push cx
GoOnGetString:
mov ah,0
int 16h
cmp al,8
jnz AsciiNormal
dec si
cmp si,dx
jae NotReachHead
mov si,dx
NotReachHead:
sub di,2
mov ax,920h
mov es:[di],ax
jmp GoOnGetString
AsciiNormal:
mov ds:[si],al
inc si
mov ah,9
stosw
cmp al,0dh
jnz GetStringNextCHar
pop cx
dec cx
mov si,dx
mov al,ds:[si]
sub al,cl
mov ds:[si+1],al
GetStringReturn:
pop es
popad
iret
GetStringNextChar:
pop cx
loop GetStringint21

Int21Proc endp



ShowCursor proc near
push ax
push dx
mov ax,cs:[CursorPos]
shr ax,1
shl ax,8
mov al,0fh
mov dx,3d4h
out dx,ax
mov ax,cs:[CursorPos]
shr ax,1
mov al,0eh
out dx,ax
pop dx
pop ax
ret
ShowCursor endp



GetCommand proc near 
mov ax,cs
mov ds,ax
mov ax,0b800h
mov es,ax
mov ah,9
mov dx,offset MsgInput
int 21h

mov si,offset FileName
mov cx,90h
mov al,0
ClearBuf:
mov ds:[si],al
inc si
loop ClearBuf

mov si,offset FileName
GetKey:
mov di,cs:[CursorPos]
cmp di,4000
jb NotRollScreen

push si
push ds
mov ax,es
mov ds,ax
sub word ptr cs:[CursorPos],3680
call ShowCursor
mov si,4000
mov di,320
mov cx,4000
rep movsb
mov di,cs:[CursorPos]
pop ds
pop si

NotRollScreen:
mov ax,si
sub ax,offset FileName
cmp ax,80h
jb NotMaxPath
mov si,offset FileName
NotMaxPath:
mov ah,0
int 16h
CheckEscape:
cmp al,1bh
jnz CheckBackSpace
call EscapeProc
jmp GetKey

CheckBackSpace:
cmp al,8
jnz CheckTab
call BackSpaceProc
jmp GetKey

CheckTab:
cmp al,9
jnz CheckEnter
call TabProc
jmp GetKey

CheckEnter:
cmp al,0dh
jnz CheckArrowUp
call EnterProc
ret

CheckArrowUp:
cmp ah,48h
jnz CheckArrowDown
call ArrowUpProc
jmp GetKey

CheckArrowDown:
cmp ah,50h
jnz CheckArrowLeft
call ArrowDownProc
jmp GetKey

CheckArrowLeft:
cmp ah,4bh
jnz CheckArrowRight
call ArrowLeftProc
jmp GetKey

CheckArrowRight:
cmp ah,4dh
jnz CheckDelete
call ArrowRightProc

CHeckDelete:
cmp ah,53h
jnz CheckInsert
call DeleteProc
jmp GetKey

CheckInsert:
cmp ah,52h
jnz CheckHome
call InsertProc
jmp GetKey

CheckHome:
cmp ah,47h
jnz CheckEnd
call HomeProc
jmp GetKey

CHeckEnd:
cmp ah,4fh
jnz CheckPageUp
call EndProc
jmp GetKey

CheckPageUp:
cmp ah,49h
jnz CheckPageDown
call PageUpProc
jmp GetKey

CheckPageDown:
cmp ah,51h
jnz CheckPrintScreen
call PageDownProc
jmp GetKey

CheckPrintScreen:
cmp ah,37h
jnz CheckPause
call printScreenProc
jmp GetKey

CheckPause:
cmp ah,0c5h
jnz CheckFuncKey
call PauseProc
jmp GetKey

CheckFuncKey:
cmp ah,3bh
jb AsciiKeyProc
cmp ah,44h
ja AsciiKeyProc
call FuncKeyProc
jmp GetKey

AsciiKeyProc:
mov ds:[si],al
inc si
mov ah,0ch
mov es:[di],ax
add di,2
mov cs:[CursorPos],di
call ShowCursor
jmp GetKey

EscapeProc:
cmp byte ptr cs:[ProcessFlag],0
jz NotInProgress
cli
lss sp,dword ptr cs:[UserStackPtr]
pop es
pop ds
popad
popf
sti
	db 0eah
	dw offset ToGetCommand
	dw 1000h
NotInProgress:
ret

FuncKeyProc:		;IRQ 8 is not under control by IMR???????????????
mov ax,cs
mov ds,ax
mov si,offset MbrBase
mov ebx,1
mov cx,1
call ReadSec
mov ax,0
mov es,ax
mov si,offset MbrBase
mov di,7c00h
mov cx,80h
cld
rep movsd
	db 0eah
	dw 7c00h
	dw 0

BackSpaceProc:
dec si
cmp si,offset FileName
jae CheckInputMsg
mov si,offset FileName
CheckInputMsg:
mov byte ptr ds:[si],0
sub di,2
cmp di,320
jge KeyBackOk
mov di,320
KeyBackOk:
mov cs:[CursorPos],di
mov ax,720h
mov es:[di],ax
call ShowCursor
ret

TabProc:
and word ptr cs:[CursorPos],0fff8h
add word ptr cs:[CursorPos],8
call ShowCursor
ret

EnterProc:
mov ax,cs:[CursorPos]
mov bl,160
div bl
sub bl,ah
movzx bx,bl
add word ptr cs:[CursorPos],bx
call ShowCursor
ret

ArrowUpProc:
sub word ptr cs:[CursorPos],160
call ShowCursor
ret

ArrowDownProc:
add word ptr cs:[CursorPos],160
call ShowCursor
ret

ArrowLeftProc:
sub word ptr cs:[CursorPos],2
call ShowCursor
ret

ArrowRightProc:
add word ptr cs:[CursorPos],2
call ShowCursor
ret

DeleteProc:
ret

InsertProc:
ret

HomeProc:
mov ax,cs:[CursorPos]
mov dx,0
mov bx,160
div bx
sub bx,dx
add word ptr cs:[CursorPos],bx
call ShowCursor
ret

EndProc:
and word ptr cs:[CursorPos],0ffa0h
call ShowCursor
ret

PageUpProc:
mov ax,cs:[CursorPos]
mov dx,0
mov bx,160
div bx
sub bx,dx
add word ptr cs:[CursorPos],bx
call ShowCursor
ret

PageDownProc:
and word ptr cs:[CursorPos],0ffa0h
call ShowCursor
ret

PauseProc:
ret

PrintScreenProc:
ret

GetCommand endp






RunCom proc near
pushf
pushad
push ds
push es
mov ax,ss
shl eax,16
mov ax,sp
mov cs:[UserStackPtr],eax
mov ax,cs
mov ds,ax
mov es,ax
mov si,offset FileName
mov di,offset CommandLine
mov cx,80h
rep movsb

mov ax,cs:[DataSeg]
sub ax,10h
mov es,ax
mov cs:[ComCS],ax
mov ax,cs
mov ds,ax
mov si,offset PSP
mov di,0
mov cx,40h
rep movsd
mov ax,es
mov ds,ax
mov ss,ax
mov bx,word ptr cs:[FileSize+2]
mov cx,word ptr cs:[FileSize]
mov ax,0
mov dx,0
mov si,0
mov di,0
mov bp,0
mov sp,0fffeh
	db 0eah
ComIP	dw 100h
ComCS	dw 0
RunCom endp



RunExe proc near
pushf
pushad
push ds
push es
mov ax,ss
shl eax,16
mov ax,sp
mov cs:[UserStackPtr],eax
mov ax,cs
mov ds,ax
mov es,ax
mov si,offset FileName
mov di,offset CommandLine
mov cx,80h
rep movsb

mov ax,cs:[DataSeg]
mov ds,ax
mov es,ax
cld
mov si,8
lodsw
add ax,cs:[DataSeg]
mov bp,ax
mov si,16h
lodsw
add ax,bp
mov cs:[ExeCs],ax
mov si,14h
lodsw
mov cs:[ExeIp],ax
mov si,6
lodsw
mov cx,ax
cmp cx,0
jz SetContext
mov si,18h
lodsw
mov si,ax
RellocSeg:
push cx
add si,2
mov ax,ds:[si]
add ax,bp
mov es,ax
sub si,2
mov di,ds:[si]
mov ax,es:[di]
add ax,bp
mov es:[di],ax
add si,4
pop cx
loop RellocSeg
SetContext:
mov sp,word ptr ds:[10h]
mov ax,word ptr ds:[0eh]
add ax,bp 
mov ss,ax

mov ax,ds
sub ax,10h
mov es,ax
mov ax,cs
mov ds,ax
mov si,offset PSP
mov di,0
mov cx,40h
rep movsd
mov ax,es
mov ds,ax

mov ax,0
mov bx,word ptr cs:[FileSize+2]
mov cx,word ptr cs:[FileSize]
mov dx,0
mov si,0
mov di,0
mov bp,0

	db 0eah
ExeIp 	dw 0
ExeCs	dw 0
ret
RunExe endp




ShowTxt Proc near
pushad
push ds
push es
mov ax,3
int 10h
mov ax,0b800h
mov es,ax
mov ax,cs:[DataSeg]
mov ds,ax
mov word ptr cs:[ShowTxtPos],0
mov si,cs:[ShowTxtPos]
call ShowTxtPage

ShowTxtCommand:
mov ah,0
int 16h
cmp al,1bh
jz ShowTxtQuit
cmp ah,48h
jz ShowTxtPrevLine
cmp ah,50h
jz ShowTxtNextLine
jmp ShowTxtCommand

ShowTxtNextLine:
add word ptr cs:[ShowTxtPos],80
mov si,cs:[ShowTxtPos]
call ShowTxtPage
jmp ShowTxtCommand

ShowTxtPrevLine:
sub word ptr cs:[ShowTxtPos],80
mov si,cs:[ShowTxtPos]
call ShowTxtPage
jmp ShowTxtCommand
ShowTxtQuit:
pop es
pop ds
popad
lss sp,dword ptr cs:[SysStackPtr]
mov ax,3
int 10h
jmp ToGetCommand			;ret is wrong ,why?????
			
ShowTxtPage:
mov di,320
mov cx,1840	;2000 chars-160
cld
mov ax,0a20h
rep stosw
mov di,320
mov cx,1840
ShowTxtChar:
push cx
lodsb
cmp al,9
jz ShowTxtTab
cmp al,0dh
jz ShowTxtEnter
cmp al,0ah
jz ShowTxtNL
mov ah,0ah
stosw
jmp ShowTxtStep
ShowTxtTab:
add di,10h
and di,0fff0h
jmp ShowTxtStep
ShowTxtEnter:
mov ax,di
mov bl,160
div bl
mov bl,ah
movzx bx,bl
sub di,bx
jmp ShowTxtStep
ShowTxtNL:
add di,160
ShowTxtStep:
pop cx
loop ShowTxtChar
ret

ShowTxtPos		dw 0
ShowTxt endp



ShowBmp proc near
mov ax,13h
int 10h
mov ax,cs:[DataSeg]
mov ds,ax
mov ax,0a000h
mov es,ax
mov dx,3c8h
mov al,0
out dx,al
mov dx,3c9h
mov si,36h
mov cx,100h
cld
SetPalette:
add si,2
lodsb
shr al,2
out dx,al
sub si,2
lodsb
shr al,2
out dx,al
sub si,2
lodsb
shr al,2
out dx,al
add si,3
loop SetPalette
mov cx,200
mov si,1078
mov di,0fa00h
sub di,320
ShowLine:
push cx
push di
mov cx,320
rep movsb
pop di
sub di,320
pop cx
loop ShowLine
mov ah,0
int 16h
mov ax,3
int 10h
ret
ShowBmp endp




GetDiskInfo proc near
mov ax,cs
mov ds,ax
mov es,ax
xor ebx,ebx
mov cx,1
mov si,offset MbrBase
call ReadSec

mov si,offset MbrBase
add si,1c2h
lodsb
cmp al,0bh
jz  MainPartFat32
cmp al,0ch
jz  MainPartFat32
cmp al,1bh
jz  MainPartFat32
cmp al,1ch
jnz CheckExtPart
MainPartFat32:
mov si,offset MbrBase
add si,1c6h		 
lodsd
mov ebx,eax
mov cx,1
mov si,offset DbrBase
call ReadSec
call CopyBPB

mov si,offset MbrBase
add si,1d2h
lodsb
cmp al,0fh
jnz NotSupportPart

CheckExtPart:
mov si,offset MbrBase
add si,1d6h
lodsd
mov cs:[ExtPartPtr],eax
mov ebx,eax
mov cx,1
mov si,offset EbrBase
call ReadSec

ExtMainPart:
mov si,offset EbrBase
add si,1c6h
lodsd
add eax,cs:[ExtPartPtr]
mov cs:[ExtpartPtr],eax
mov ebx,eax
mov cx,1
mov si,offset DbrBase
call ReadSec
call CheckFAT32 
cmp ax,1
jnz NextLogicalPart
call CopyBPB

NextLogicalPart:
mov si,offset EbrBase
add si,1cah
lodsd
cmp eax,0
jz ExtPartEnd
add eax,cs:[ExtPartPtr]
mov cs:[ExtPartPtr],eax
mov ebx,eax
mov cx,1
mov si,offset EbrBase
call ReadSec
jmp ExtMainPart
ExtPartEnd:
cmp word ptr cs:[DiskInc],0
jz NotSupportPart
shr word ptr cs:[DiskInc],5
call CalcDiskParam
ret
NotSupportPart:
mov ah,9
mov dx,offset MsgNotFAT32
int 21h
mov ah,0
int 16h
db	0eah
dw	offset ToGetCommand
dw 	1000h

CheckBoot:
add si,1feh
lodsw
cmp ax,0aa55h
jnz CheckBootRet
mov ax,1
ret
CheckBootRet:
mov ax,0
ret

CheckFat32:
mov si,offset DbrBase
add si,52h
lodsd
cmp eax,33544146h ;FAT3
jnz CheckFat32Ret
lodsb
cmp al,32h
jnz CheckFat32Ret
mov ax,1
ret
CheckFat32Ret:
mov ax,0
ret

CopyBPB:
mov si,offset DbrBase
add si,0dh
mov di,offset Disk1SecPerClu
add di,cs:[DiskInc]
movsd
mov si,offset DbrBase	
add si,1ch
movsd
mov si,offset DbrBase
add si,24h
movsd
mov si,offset DbrBase
add si,2ch			
movsd
mov si,offset DbrBase
add si,30h
movsd
add word ptr cs:[DiskInc],32
ret

CalcDiskParam:
mov bx,0
mov cx,cs:[DiskInc]
CalcFAT:
mov eax,cs:[bx+Disk1Hidden]
mov dx,cs:[bx+Disk1Reserved]
movzx edx,dx
add eax,edx
mov cs:[bx+Disk1FATptr],eax
add bx,20h
loop CalcFAT

mov bx,0
mov cx,cs:[DiskInc]
CalcFDT:
mov eax,cs:[bx+Disk1FATSize]
mov dl,cs:[bx+Disk1FATnum]
movzx edx,dl
mul edx
add eax,cs:[bx+Disk1FATptr]
mov cs:[bx+Disk1FDTptr],eax
add bx,20h
loop CalcFDT
ret
GetDiskInfo endp


OpenFile Proc near
mov ax,cs
mov ds,ax
mov es,ax
mov si,offset FileName            
lodsb
cmp al,43h		;'C'
jl ErrorPath
cmp al,5ah		;'Z'
jle PathCapsLock
cmp al,63h		;'c'
jl ErrorPath
cmp al,7ah		;'z'
jg ErrorPath
sub al,20h
PathCapsLock:
sub al,43h		;'C'
movzx ax,al
cmp ax,cs:[DiskInc]	;5
jge ErrorPath
shl ax,5
mov cs:[PartInc],ax

lodsw
cmp ax,5c3ah		;':\' Be Careful!!!!!
jnz ErrorPath

mov bx,cs:[PartInc]
mov eax,cs:[bx+Disk1FDTptr]
mov cs:[ExtPartPtr],eax

PathProcess:
mov di,offset NameBuf
mov word ptr cs:[DirLen],0
CheckDir:
mov ax,si
sub ax,offset FileName
cmp ax,80h
jge ErrorPath
lodsb
stosb
inc word ptr cs:[DirLen]
cmp al,5ch		;'\'
jz GetDir
cmp al,2eh		;'.'
jz GetPureName
jmp CheckDir

ErrorPath:
mov ax,cs
mov ds,ax
mov es,ax
lss sp,dword ptr cs:[SysStackPtr]
mov ah,9
mov dx,offset MsgNotFound
int 21h
jmp ToGetCommand

GetDir:
dec word ptr cs:[DirLen]
mov cx,11
sub cx,cs:[DirLen]
mov al,20h
dec di
rep stosb
call Translate
call ReadDir
jmp PathProcess

GetPureName:
dec word ptr cs:[DirLen]
mov cx,8
sub cx,cs:[DirLen]
mov al,20h
dec di
rep stosb
mov cx,3
rep movsb
call Translate
call ReadDir
ret

Translate:
pushad
mov si,offset NameBuf
mov di,si
mov cx,11	
AscChange:
lodsb
cmp al,7ah
ja NoChange
cmp al,61h
jb NoChange
sub al,20h
NoChange:
stosb
loop AscChange
mov si,offset NameBuf
add si,7
lodsd
mov al,20h
cmp eax,4d4f4320h
jz  FileTypeCOM
cmp eax,504d4220h
jz  FileTypeBMP
cmp eax,45584520h
jz  FileTypeEXE
CMP EAX,54585420H	
JZ FileTypeTXT		
cmp eax,4d534120h
jz FileTypeTXT
cmp eax,50504320h
jz FileTypeTXT
cmp eax,20204320h
jz FileTypeTXT
mov byte ptr cs:[FileType],0
jmp UnexpectedFileType
FileTypeCOM:
mov byte ptr cs:[FileType],1
jmp UnexpectedFileType
FileTypeBMP:
mov byte ptr cs:[FileType],3
jmp UnExpectedFileType
FileTypeEXE:
mov byte ptr cs:[FileType],2
jmp UnexpectedFileType
FileTypeTXT:
mov byte ptr cs:[FileType],4
UnexpectedFileType:
popad
ret

ReadDir:
pushad
push ds
push es
mov ax,cs:[DataSeg]
mov ds,ax
mov ax,cs
mov es,ax

mov bx,cs:[PartInc]
mov cl,cs:[bx+Disk1SecPerClu]
movzx cx,cl
mov ebx,cs:[ExtPartPtr]
mov si,0
call ReadSec

mov bx,cs:[PartInc]
mov cl,cs:[bx+Disk1SecPerClu]
movzx ecx,cl
shl ecx,4		;one sector has 16 directories
mov si,0
mov di,offset NameBuf
SearchFileName:
push ecx
push si
push di
mov cx,11
repz cmpsb
cmp cx,0
jz FindShortName
pop di
pop si
add si,20h
pop ecx
loop SearchFileName
jmp ErrorPath
FindShortName:
pop di
pop si
pop ecx
push si
add si,14h	;offset 14h(2B)is High word of First FAT number
lodsw
mov word ptr cs:[CluTable+2],ax
pop si
add si,1ah	;offset 1ah(2B)is Low word of First FAT number
lodsw		;offset 1ch(4B)is File Size of bytes
mov word ptr cs:[CluTable],ax
lodsd
mov cs:[FileSize],eax
mov eax,cs:[CluTable]
mov bx,cs:[PartInc]
sub eax,cs:[bx+Disk1FirstClu]
mov dl,cs:[bx+Disk1SecPerClu]
movzx edx,dl
mul edx
add eax,cs:[bx+Disk1FDTptr]
mov cs:[ExtPartPtr],eax
pop es
pop ds
popad
ret

OpenFile endp



ReadFile Proc near
pushad
push ds
push es
mov ax,cs:[DataSeg]
mov ds,ax
mov ax,cs
mov es,ax

mov bx,cs:[PartInc]
mov cl,cs:[bx+Disk1SecPerClu]
movzx ecx,cl
shl ecx,9
mov cs:[CluSize],ecx


mov eax,cs:[FileSize] ;;;;;;10000h  ;Cluster is at most 64kb size,dividen by 64kb with mode 0
mov edx,0
div ecx
cmp edx,0
jz  FileAlignCluster
inc eax
FileAlignCluster:
mov ecx,eax
mov si,0
Read:
push cx
mov bx,cs:[PartInc]
mov cl,cs:[bx+Disk1SecPerClu]
movzx cx,cl
mov ebx,cs:[ExtPartPtr]
call ReadSec
call GetCluNum
mov eax,cs:[CluTable]
			;FAT32 Cluster NO. use low 28 bits!!!
			;if FileSize=64kb,it present 3 clusters,WHY?????

mov bx,cs:[PartInc]
sub eax,cs:[bx+Disk1FirstClu]
mov cl,cs:[bx+Disk1SecPerClu]
movzx ecx,cl
mul ecx
add eax,cs:[bx+Disk1FDTptr]
mov cs:[ExtPartPtr],eax
add si,word ptr cs:[CluSize]



cmp si,0
jnz ReadIn64KB
mov ax,ds
add ax,1000h
cmp ax,9000h
jnz ReadNext64KB
mov ax,cs
mov ds,ax
mov es,ax
mov ah,9
mov dx,offset MsgNotEnoughMem
int 21h
lss sp,dword ptr cs:[SysStackPtr]
jmp ToGetCommand

ReadNext64KB:
mov ds,ax
ReadIn64KB:




pop cx
loop Read
EndClu:
pop es
pop ds
popad
ret

GetCluNum:
pushad
push ds
push es
mov ax,cs
mov ds,ax
mov es,ax
mov eax,cs:[CluTable]
shl eax,2
mov edx,0
mov ecx,512
div ecx 		;ax=shang dx=yushu
push edx
mov bx,cs:[PartInc]
add eax,cs:[bx+Disk1FATptr]
mov ebx,eax
mov cx,1
mov si,offset DbrBase
call ReadSec
pop esi
add si,offset DbrBase
lodsd
mov cs:[CluTable],eax
pop es
pop ds
popad
ret

ReadFile Endp



ReadSec proc near
push ax
push dx
push si
push ds
mov word ptr cs:[DapAddr],si
mov ax,ds
mov word ptr cs:[DapAddr+2],ax
mov cs:[DapSecNum],cx
mov dword ptr cs:[DapSecAlloc],ebx
mov ax,cs
mov ds,ax
mov si,offset DapHead
mov ax,4200h
mov dl,80h
int 13h
pop ds
pop si
pop dx
pop ax
ret
ReadSec endp

KernelLen		dw $
kernel ends




Driver Segment page use16
assume cs:Driver

int0Proc:
pushad
push ds
push es
mov ax,cs
mov ds,ax
mov ax,0b800h
mov es,ax
mov si,offset Int0ProcMsg
mov di,3840
cld
call ShowIntMsg
pop es
pop ds
popad
pop word ptr cs:[StackBuf]
pop word ptr cs:[StackBuf]
popf
lss sp,dword ptr cs:[DriverStackPtr]
pushf
push word ptr 1000h
mov word ptr cs:[StackBuf],offset ToGetCommand
push word ptr cs:[StackBuf]
iret
Int0ProcMsg	db 'Dividen by Zero!',0
StackBuf	dw 0
DriverStackPtr	dd 0



Int4Proc:
pushad
push ds
push es
mov ax,cs
mov ds,ax
mov ax,0b800h
mov es,ax
mov si,offset Int4ProcMsg
mov di,3840
cld
call ShowIntMsg
pop es
pop ds
popad
iret
Int4ProcMsg	db 'OverFlow Interruption Happening!',0



SysTimerIntProc:
push ax
push es
mov al,20h
out 20h,al
mov ax,40h
mov es,ax
inc dword ptr es:[6ch]
cmp dword ptr es:[6ch],1800b0h
jnz SysTimerInc
mov dword ptr es:[6ch],0
SysTImerInc:
int 1ch
pop es
pop ax
iret



KbdIntProc:
pushad
push ds
push es
push fs
push gs
mov ax,cs
mov ds,ax   
mov fs,ax
mov gs,ax
mov ax,40h
mov es,ax
mov al,20h
out 20h,al
cld
in al,60h
mov byte ptr cs:[ScanCode],al
call Analysis
KbdIntRet:
pop gs
pop fs
pop es
pop ds
popad
iret


Analysis proc near
CheckMakeCtrl:
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
jmp MakeNormal			
CheckMakeDelete:
cmp byte ptr ds:[ScanCode],53h		;53h=Delete
jnz CheckBreakOthers
test byte ptr es:[17h],4
jz ToMakeNormal
test byte ptr es:[17h],8
jz ToMakeNormal
call Reset			
CheckBreakOthers:
cmp byte ptr ds:[ScanCode],80h
jae AnalysisReturn
ToMakeNormal:
call MakeNormal
AnalysisReturn:
ret
Analysis endp



MakeNormal proc near
cmp byte ptr cs:[ScanCode],2eh
jz Ctrl_C
cmp byte ptr cs:[ScanCode],0c5h
jnz CheckNumLock
CtrlBreak:
Ctrl_C:
test byte ptr es:[17h],4
jz CheckNumLock
int 1bh
ret

CheckNumLock:
cmp byte ptr cs:[ScanCode],47h
jb CheckCapsLock
test byte ptr es:[17h],20h
jz NormalKey
jmp ShiftKey

CheckCapslock:
test byte ptr es:[17h],40h
jnz CapsLockKey
test byte ptr es:[17h],3
jnz ShiftKey

NormalKey:
mov bx,offset ScanCodeNormal
jmp ScanCodeToAsc
ShiftKey:
mov bx,offset ScanCodeShift
jmp ScanCodeToAsc

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
jmp NormalKey

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
mov es:[di],ax
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
call SetKbdLed
ret
MakeScrollLock endp



MakeNumsLock proc near
xor byte ptr es:[17h],20h
xor byte ptr es:[LedFlag],2
call SetKbdLed
ret
MakeNumsLock endp



MakeCapsLock proc near
Xor byte ptr es:[17h],40h
xor byte ptr es:[LedFlag],4
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



Reset proc near
Shut:
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

align 10h
ScanCode    	dd 0
LEDflag     	db 0

ScanCodeNormal  db 0,1bh,31h,32h,33h,34h,35h,36h,37h,38h,39h,30h,'-','=',8,9,'q'
                db 'w','e','r','t','y','u','i','o','p','[',']',0dh,0,'a','s','d'
                db 'f','g','h','j','k','l',';',"'",'`',0,'\','z','x','c','v','b'
                db 'n','m', ',' , '.', '/', 0, 0, 0,' ',0,0,0,0,0,0,0
                db 0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0
                db 0,0,0
ScanCodeShift   db 0,1bh,'!@#$%^&*()_+',8,9,'Q'
                db 'WERTYUIOP{}',0dh,0,'ASD'
                DB 'FGHJKL:"~',0,'|ZXCVB'
                DB 'NM<>?',0,0,0,' ',0,0,0,0,0,0,0
                DB 0,0,0,0,0,0,'789-456+1230.'





RealTimerIntProc:
pushad
push ds
push es
mov al,0ch
out 70h,al
in al,71h
mov al,20h
out 20h,al
out 0a0h,al
mov ax,cs
mov ds,ax
mov es,ax

mov di,offset SecCMOS
mov al,0
call GetCMOS

mov di,offset MinCMOS
mov al,2
call GetCMOS

mov di,offset HourCMOS
mov al,4
call GetCMOS

mov di,offset WeekDayCMOS
mov al,6
call GetCMOS

mov di,offset DayCMOS
mov al,7
call GetCMOS

mov di,offset MonCMOS
mov al,8
call GetCMOS

mov di,offset YearCMOS
mov al,9
call GetCMOS

mov di,offset CenturyCMOS
mov al,32h
call GetCMOS

mov ax,0b800h
mov es,ax
mov di,0
mov cx,160
mov al,20h
mov ah,1ch
rep stosw

mov si,offset MsgCredit
mov di,0
call ShowIntMsg

mov si,offset MsgDateAndTime
mov di,160
call ShowIntMsg
;add byte ptr cs:[CapColor],10h
pop es
pop ds
popad
iret
MsgCredit	db 'LIUNUX,credit by liujinguan,ljg438@tianya.cn',0

GetCMOS:
out 70h,al
in al,71h
mov ah,al
shr al,4
cmp al,9
jbe Decimal_1
add al,7
Decimal_1:
add al,30h
stosb
mov al,ah
and al,0fh
cmp al,9
jbe Decimal_2
add al,7
Decimal_2:
add al,30h
stosb
ret

MsgDateAndTime	db 'Current Time:'
HourCMOS	dw 0
		db ':'
MinCMOS 	dw 0
		db ':'
SecCMOS 	dw 0
		dw 2020h
		dw 2020h
		db 'Date:'
MonCMOS		dw 0
		db '\'
DayCMOS		dw 0
		db '\'
CenturyCMOS 	dw 0
YearCMOS	dw 0
		dw 2020h
		db 'WeekDay:'
WeekDayCMOS	dw 0
		db 0

ShowIntMsg:
lodsb
cmp al,0
jz ShowIntMsgEnd
mov ah,01ch
stosw
jmp ShowIntMsg
ShowIntMsgEnd:
ret		
		
		

;Only for PS/2 mouse,or USB mouse first supported by BIOS
MouseIntProc:
pushad
push ds
push es
mov ax,cs
mov ds,ax
mov bl,cs:[MouseCounter]
movzx bx,bl
in al,60h
mov cs:[bx+MouseStatus],al
inc byte ptr cs:[MouseCounter]
cmp byte ptr cs:[MouseCounter],3
jz MouseProc
MouseIntRet:
mov al,20h
out 20h,al
out 0a0h,al
pop es
pop ds
popad
iret
MouseProc:
mov byte ptr cs:[MouseCounter],0
mov al,cs:[MouseDeltaY]
movsx ax,al
sub word ptr cs:[MousePosY],ax
mov al,cs:[MouseDeltaX]
movsx ax,al
add word ptr cs:[MousePosX],ax
mov ax,4f03h
int 10h
mov cs:[VideoMode],bx
cmp bx,3
jz TxtVideoMode
cmp bx,13h
jz VideoMode320x200x8
cmp bx,12h
jz VideoMode640x480x4
jmp VesaVideoMode

TxtVideoMode:
mov ax,0b800h
mov es,ax
cmp byte ptr cs:[TxtInitFlag],0
jz TxtModeInit

mov di,cs:[MousePosXY]
mov ax,cs:[Covered]
mov es:[di],ax
jmp GetTxtCursorPos

TxtModeInit:
mov byte ptr cs:[TxtInitFlag],1
mov di,cs:[MousePosXY]
push es:[di]
pop cs:[Covered]
jmp TxtModeEnd

GetTxtCursorPos:
mov ax,cs:[MousePosY]
mov cx,cs:[MousePosX]
shr ax,4
mov bx,160
mul bx
shr cx,2
add ax,cx
and ax,0ffeh
mov word ptr cs:[MousePosXY],ax
mov di,ax
push word ptr es:[di]
pop word ptr cs:[Covered]
mov word ptr es:[di],0ca20h
TxtModeEnd:
jmp MouseIntRet


VideoMode320x200x8:
mov ax,0a000h
mov es,ax
cmp byte ptr cs:[VideoMode1InitFlag],0
jz VideoMode1Init

mov si,offset VideoMode1Buf
mov di,cs:[MousePosXY]
mov cx,8
RestoreVideoMode1:
push cx
push di
mov cx,8
rep movsb
pop di
add di,320
pop cx
loop RestoreVideoMode1
jmp GetVideoMode1Pos

VideoMode1Init:
mov byte ptr cs:[VideoMode1InitFlag],1
call StoreVideoMode1
jmp VideoMode1End


GetVideoMode1Pos:
mov ax,cs:[MousePosY]
mov bx,320
mul bx
add ax,cs:[MousePosX]
mov cs:[MousePosXY],ax
call StoreVideoMode1

mov di,cs:[MousePosXY]
mov al,0ch
mov cx,8
VideoMode1CursorLine:
push cx
push di
mov cx,8
rep stosb
pop di 
add di,320
pop cx
loop VideoMode1CursorLine
test byte ptr cs:[MouseStatus],1
jz VideoMode1End
mov al,06h
mov di,cs:[MousePosXY]
sub di,321
stosb
VideoMode1End:
jmp MouseIntRet

VideoMode640x480x4:
jmp MouseIntRet
VesaVideoMode:
jmp MouseIntRet


StoreVideoMode1:
push ds
push es
mov ax,es
mov ds,ax
mov ax,cs
mov es,ax
mov si,cs:[MousePosXY]
mov di,offset VideoMode1Buf
mov cx,8
StoreVideoMode1Line:
push cx
push si
mov cx,8
rep movsb
pop si
add si,320
pop cx
loop StoreVideoMode1Line
pop es
pop ds
ret


MouseStatus		db 0
MouseDeltaX		db 0
MouseDeltaY		db 0
MouseCounter		db 0
MousePosX		dw 0
MousePosY		dw 0
MousePosXY		dw 0
Covered			dw 0
TxtInitFlag		db 0
VideoMode		dw 0
VideoMode1InitFlag		db 0
VideoMode1Buf		db 64 dup (0)



CorProcessorIntProc:
pushad
push ds
push es
xor al,al
out 0f0h,al
mov al,20h
out 20h,al
out 0a0h,al
mov ax,cs
mov ds,ax
mov ax,0b800h
mov es,ax
mov si,offset MsgProcessorError
mov di,3840
call ShowIntMsg
int 2
pop es
pop ds
popad
iret
MsgProcessorError	db 'PROCESSOR ERROR!',0


Int2Proc proc near
finit
lss sp,dword ptr cs:[DriverStackPtr]
	db 0eah
	dw offset ToGetCommand
	dw 1000h
iret
Int2Proc endp	



Int16Proc Proc near
sti		;INT xx instruction will clear int flag and trap flag 
push si
push ds
mov ax,40h
mov ds,ax
WaitKeyBufFull:
mov si,ds:[1ah]
cmp si,word ptr ds:[1ch]
jz WaitKeyBufFull
add si,2
cmp si,3eh
jnz NotKbdBufEnd
mov si,1eh
NotKbdBufEnd:
mov ax,ds:[si]
mov ds:[1ah],si
KeyBufEmpty:
pop ds
pop si
iret
Int16Proc endp



Int1bProc proc near
mov ax,3
int 10h
lss sp,dword ptr cs:[DriverStackPtr]
	db 0eah
	dw offset ToGetCommand
	dw 1000h
iret
Int1bProc endp




Int1cProc proc near
iret
Int1cProc endp

Int23Proc proc near
int 1bh
iret
Int23Proc endp

IntIretProc proc near
iret
IntIretProc endp


DriverLen	dw $
Driver ends



Code segment para use16
assume cs:code
start:
mov ax,cs
mov es,ax
mov ax,201h
mov bx,offset MbrData
mov cx,1
mov dx,80h
int 13h
mov ax,301h
mov bx,offset MbrData
mov cx,2
mov dx,80h
int 13h

mov ax,NewMbr
mov ds,ax
mov si,0
mov di,offset MbrData
mov cx,ds:[NewMbrLen]
rep movsb
mov ax,301h
mov bx,offset MbrData
mov cx,1
mov dx,80h
int 13h

mov ax,Kernel
mov es,ax
mov ax,es:[KernelLen]
shr ax,9
inc al
mov ah,3
mov bx,0
mov cx,10
mov dx,80h
int 13h

mov ax,Driver
mov es,ax
mov ax,es:[DriverLen]
shr ax,9
inc al
mov ah,3
mov bx,0
mov cx,30
mov dx,80h
int 13h
mov al,1
out 92h,al

MbrData 	db 200h dup (0)
Code ends



NewMbr segment para use16
assume cs:NewMbr
cli
mov ax,1000h
mov es,ax
mov ds,ax

mov ax,201h
mov bx,0
mov cx,2
mov dx,80h
int 13h
mov ax,301h
mov bx,0
mov cx,1
mov dx,80h
int 13h

mov ax,214h
mov bx,0
mov cx,10
mov dx,80h
int 13h
mov ax,2000h
mov es,ax
mov ds,ax
mov ss,ax
mov sp,0ff00h
mov ax,214h
mov bx,0
mov cx,30
mov dx,80h
int 13h
		db 0eah
		dw 0
		dw 1000h

NewMbrLen 	dw $
NewMbr ends

end start

