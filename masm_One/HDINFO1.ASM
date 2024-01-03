.386

Stack segment stack
db 1000h dup (0)
stack ends

Kernel Segment para use16
assume cs:kernel
start:
mov ax,cs
mov ds,ax
mov es,ax
jmp MainProc

align 10h
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
NextDisk	db 236 dup (0) ;at most 24 logic disks

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

FileName	db 'e:\tender.bmp',0
		db 80h dup (0)
NameBuf		db 10h dup (0)
DirLen     	dw 0
CluTable	dd 0
CluSize		dd 0
FileSize	dd 0
DataSeg		dw 5000h
MsgInput    	db 'Please Input File Name:',0
MsgNotFound	db 'Not Found File!',0


MainProc:
call GetDiskInfo
call CalcDiskInfo
ToGetCommand:
;Call GetCommand
call OpenFile
call ReadFile
call ShowBmp
;call RunExe
;jmp ToGetCommand
FileFailure:
jmp ToGetCommand


ShowBmp proc near
mov ax,13h
int 10h
mov ax,cs:[DataSeg]
mov ds,ax
mov ax,0a000h
mov es,ax
mov cx,0fa00h
mov si,1078
mov di,0
rep movsb
mov ah,0
int 16h
mov ax,3
int 10h
mov ah,4ch
int 21h
int 19h
ret
ShowBmp endp


Init proc near
cli
cld
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

mov ax,0
mov es,ax
mov di,41ah
mov ax,1eh
stosw
stosw
mov di,21h
shl di,2
;mov ax,offset KbdIntProc
stosw
mov ax,2000h
stosw
mov di,1bh
shl di,2
;mov ax,offset IntReturn
stosw
mov ax,2000h
stosw
mov al,0fdh
out 21h,al
mov al,0ffh
out 0a1h,al
sti
mov ax,3
int 10h
ret
Init endp


GetCommand proc near
mov ax,cs
mov ds,ax
mov ax,0b800h
mov es,ax
cld
call ShowInput

mov si,offset FileName
mov cx,90h
mov al,0
ClearBuf:
mov ds:[si],al
inc si
loop ClearBuf

mov si,offset FileName
GetKey:
mov ax,si
sub ax,offset FileName
cmp ax,80h
jb NotMaxPath
mov si,offset FileName
NotMaxPath:

mov ah,0
int 16h

;push si
;push ds
;mov ax,40h
;mov ds,ax
;NoKey:
;mov si,ds:[1ah]
;cmp si,ds:[1ch]
;jz Nokey
;add si,2
;cmp si,3eh
;jnz KbdBufHead
;mov si,1eh
;KbdBufHead:
;mov ds:[1ah],si
;mov ax,ds:[si]
;pop ds
;pop si

cmp al,1bh
jz KeyEscape
cmp al,8
jz KeyBack
cmp al,9
jz KeyTab
cmp al,0dh
jz KeyEnter

mov ds:[si],al
inc si
mov ah,0ah
mov es:[di],ax
add di,2
call ShowArrow
jmp GetKey

KeyBack:
dec si
cmp si,offset FileName
jae CheckInputMsg
mov si,offset FileName
CheckInputMsg:
mov byte ptr ds:[si],0
sub di,2
cmp di,160
jae KeyBackOk
mov di,160
KeyBackOk:
mov ax,720h
mov es:[di],ax
call ShowArrow
jmp GetKey

KeyTab:
and di,0fff8h
add di,8
call ShowArrow
jmp GetKey

KeyEnter:
;mov ax,di
;mov bl,160
;div bl
;sub bl,ah
;movzx bx,bl
;add di,bx
;call ShowArrow
ret

KeyEscape:
MOV AX,3
INT 10H
mov ah,4ch
int 21h
mov ax,0
mov ds,ax
mov es,ax
mov si,7c00h
mov ebx,2
mov cx,1
call ReadSec
mov ax,301h
mov bx,7c00h
mov cx,1
mov dx,80h
int 13h

	db 0eah
	dw 07c00h
	dw 0

GetCommand endp


ShowInput proc near
mov si,offset MsgInput
mov di,0
mov ah,0ch
ToShowNextChar:
lodsb
cmp al,0
jz ShowInputEnd
stosw
jmp ToShowNextChar
ShowInputEnd:
mov di,160
call ShowArrow
ret
ShowInput endp


ShowArrow proc near
push ax
push dx
mov ax,di
shr ax,1
shl ax,8
mov al,0fh
mov dx,3d4h
out dx,ax
mov ax,di
shr ax,1
mov al,0eh
out dx,ax
pop dx
pop ax
ret
ShowArrow endp



RunExe proc near
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
mov ax,cs:[DataSeg]
mov ds,ax
mov es,ax
mov sp,word ptr ds:[10h]
mov ax,word ptr ds:[0eh]
add ax,bp 
mov ss,ax
mov ax,ds
sub ax,10h
mov ds,ax
mov es,ax
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








GetDiskInfo proc near
xor ebx,ebx
mov cx,0
mov si,offset MbrBase
call ReadSec

GetMasterPart:
mov si,offset MbrBase
add si,1c6h		 
lodsd
mov ebx,eax
mov cx,1
mov si,offset DbrBase
call ReadSec
call CheckNTFS
cmp  ax,1
jz   SearchNextExp
call CopyBPB

SearchNextExp:
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
call CheckBoot
cmp ax,1
jnz ExtPartEnd
mov si,offset EbrBase
add si,1c6h
lodsd
add eax,cs:[ExtPartPtr]
mov cs:[ExtpartPtr],eax
mov ebx,eax
mov cx,1
mov si,offset DbrBase
call ReadSec
mov si,offset DbrBase
call CheckBoot
cmp ax,1
jnz ExtPartEnd
call CheckFAT32 
cmp ax,1
jnz ExtPartEnd
call CopyBPB

ExtExtPart:
mov si,offset EbrBase
add si,1cah
lodsd
cmp eax,0
jz ExtPartENd
add eax,cs:[ExtPartPtr]
mov cs:[ExtPartPtr],eax
mov ebx,eax
mov cx,1
mov si,offset EbrBase
call ReadSec
jmp ExtMainPart
ExtPartEnd:
shr word ptr cs:[DiskInc],5
ret
GetDiskInfo endp



CheckBoot proc near
add si,1feh
mov ax,ds:[si]
cmp ax,0aa55h
jnz CheckBootRet
mov ax,1
ret
CheckBootRet:
mov ax,0
ret
CheckBoot endp


CheckNTFS proc near
mov si,offset DbrBase
add si,3
mov eax,ds:[si]
cmp eax,5346544eh
jnz CheckNTFSret
mov ax,1
ret
CheckNTFSret:
mov ax,0			;;;;;;;;;;;;;;
ret
CheckNTFS endp


CheckFat32 proc near
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
CheckFat32 endp



CopyBPB proc near
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
CopyBPB endp



CalcDiskInfo proc near
mov ax,cs
mov ds,ax
mov es,ax
mov bx,0
mov cx,cs:[DiskInc]
CalcFAT:
push cx
mov eax,cs:[bx+Disk1Hidden]
mov dx,cs:[bx+Disk1Reserved]
movzx edx,dx
add eax,edx
mov cs:[bx+Disk1FATptr],eax
add bx,20h
pop cx
loop CalcFAT

mov bx,0
mov cx,cs:[DiskInc]
CalcFDT:
push cx
mov eax,cs:[bx+Disk1FATSize]
mov dl,cs:[bx+Disk1FATnum]
movzx edx,dl
mul edx
add eax,cs:[bx+Disk1FATptr]
mov cs:[bx+Disk1FDTptr],eax
add bx,20h
pop cx
loop CalcFDT
ret
CalcDiskInfo endp




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
pushad
push ds
push es
mov ax,cs
mov ds,ax
mov ax,0b800h
mov es,ax
mov di,1600
mov si,offset MsgNotFound
mov ah,0ch
ShowChar:
lodsb
cmp al,0
jz EndChar
stosw
jmp ShowChar
EndChar:
pop es
pop ds
popad
add sp,2
jmp FileFailure

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
mov eax,cs:[FileSize]
mov edx,0
div ecx
cmp edx,0
jz IntegerClu
inc eax
IntegerClu:
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
mov bx,cs:[PartInc]
sub eax,cs:[bx+Disk1FirstClu]
mov cl,cs:[bx+Disk1SecPerClu]
movzx ecx,cl
mul ecx
add eax,cs:[bx+Disk1FDTptr]
mov cs:[ExtPartPtr],eax
add si,word ptr cs:[CluSize]
pop cx
loop Read
pop es
pop ds
popad
ret
ReadFile Endp


GetCluNum proc near
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
GetCluNum endp





Translate proc near
pushad
mov si,offset NameBuf
mov di,si
mov cx,11	;;;;;;;;;;;;;;;;;
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
popad
ret
Translate endp



ReadDir proc near
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
push cx
push si
push di
mov cx,11
repz cmpsb
cmp cx,0
jz FindShortName
pop di
pop si
add si,20h
pop cx
loop SearchFileName
call ErrorPath
FindShortName:
pop di
pop si
pop cx
push si
add si,14h
lodsw
mov word ptr cs:[CluTable+2],ax
pop si
mov si,1ah
lodsw
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
ReadDir endp




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



kernel ends
end start
