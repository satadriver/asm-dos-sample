;DPT中的主分区起始扇区地址指向主分区，主分区（DPT第一项）无扩展分区表，所以主分区第一个扇区为引导扇区，可以立刻读取BPB
;DPT中的扩展分区起始扇区地址指向扩展分区表，而不是引导扇区，而且一个扩展分区可能有多个逻辑盘
;计算逻辑盘的引导扇区地址的正确方法是利用DPT中的扩展分区基扇区地址为基地址，加上逻辑盘的起始扇区，再加上逻辑盘的总扇区数
;得到下一逻辑盘的起始扇区地址
;最后一个分区表怎么处理？？？ 或者USB硬盘呢？？？
;the last extended partition will be get in above mean!!!
.386

HdInfo segment para use16
assume cs:HdInfo
start:
jmp MainProc

align 10h
Disk1SecPerClu  db 0
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
NextDisk	db 736 dup (0) ;at most 24 logic disk


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

FileName	db 'e:\tender.bmp'
		db 80h dup (0)
NameBuf		db 10h dup (0)
DirLen     	dw 0

CluTable	dd 0
CluSize		dd 0
FileSize	dd 0
DataSeg		dw 6000h


MsgNotFound    	db 'Not Found File',0
MainProc:
call GetDiskInfo
call CalcDiskInfo
call OpenFile
call ReadFile
call ShowBmp
LoadFailure:
mov ah,0
int 16h
mov ax,3
int 10h
mov ah,4ch
int 21h
in al,60h
cmp al,1
jnz LoadFailure
int 19h


ShowBmp Proc near
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
SetColor:
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
loop SetColor

mov si,1078
mov di,0fa00h
sub di,320
mov cx,200
ShowLine:
push cx
push di
mov cx,320
rep movsb
pop di
sub di,320
pop cx
loop ShowLine
ret
ShowBmp endp



GetDiskInfo proc near
cld
mov ax,cs
mov ds,ax
mov es,ax

xor ebx,ebx
mov cx,1
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
add si,cs:[PartInc]
add word ptr cs:[PartInc],10h
cmp word ptr cs:[PartInc],20h
jnz NextExtPart
jmp ExtPartEnd
NextExtPart:
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
jnz SearchNextExp
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
jnz SearchNextExp
call CheckFAT32 
cmp ax,1
jnz ExtExtPart
call CopyBPB

ExtExtPart:
mov si,offset EbrBase
add si,1cah
lodsd
cmp eax,0
jz SearchNextExp
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
lodsw
cmp ax,0aa55h
jnz CheckBootRet
mov ax,1
CheckBootRet:
ret
CheckBoot endp


CheckNTFS proc near
mov si,offset DbrBase
add si,3
lodsd
cmp eax,5346544eh
jnz CheckNTFSret
mov ax,1
CheckNTFSret:
ret
CheckNTFS endp


CheckFat32 proc near
mov si,offset DbrBase
add si,52h
lodsd
cmp eax,33544146h ;FAT3
jnz CheckFat32Ret
mov ax,1
CheckFat32Ret:
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
mov bx,0
mov cx,cs:[DiskInc]
CalcFAT:
mov eax,cs:[bx+Disk1Hidden]
mov dx,cs:[bx+Disk1Reserved]
movzx edx,dx
add eax,edx
mov cs:[bx+Disk1FATptr],eax
add bx,20h
dec cx
cmp cx,0
jnz CalcFAT
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
dec cx
cmp cx,0
jnz CalcFDT
ret
CalcDiskInfo endp




OpenFile Proc near
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
cmp ax,5c3ah		;':\'
jnz ErrorPath

mov bx,cs:[PartInc]
mov ebx,cs:[bx+Disk1FDTptr]
mov cs:[ExtPartPtr],ebx

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
mov ax,3
int 10h
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
add sp,2		;why add sp,2 is wrong here?????
jmp LoadFailure


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
mov ax,cs:[DataSeg]
mov ds,ax

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
;FAT32 Largest Cluster is 32KB,and it is also an Integer to divide 64kb

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

pop ds
popad
ret
ReadFile Endp


GetCluNum proc near
pushad
push ds
mov ax,cs
mov ds,ax
mov eax,cs:[CluTable]
shl eax,2
mov ecx,512
mov edx,0
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
;cmp eax,0fffffffh
;jnz GetCluRet
mov cs:[CluTable],eax
pop ds
popad
ret
GetCluRet:
add sp,6
jmp LoadFailure
GetCluNum endp





Translate proc near
pushad
mov si,offset NameBuf
mov di,si
mov cx,10h
AscChange:
lodsb
cmp al,7ah
jg NoChange
cmp al,61h
jl NoChange
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
mov ax,cs:[DataSeg]
mov ds,ax
mov si,0
mov bx,cs:[PartInc]
mov cl,cs:[bx+Disk1SecPerClu]
movzx cx,cl
mov ebx,cs:[ExtPartPtr]
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
add si,14h			;First Cluster high word
lodsw
mov word ptr cs:[CluTable+2],ax
pop si
add si,1ah			;First Cluster low word
lodsw
mov word ptr cs:[CluTable],ax
lodsd
mov cs:[FileSize],eax
mov bx,cs:[PartInc]
mov eax,cs:[CluTable]
sub eax,cs:[bx+Disk1FirstClu]
mov dl,cs:[bx+Disk1SecPerClu]
movzx edx,dl
mul edx
add eax,cs:[bx+Disk1FDTptr]
mov cs:[ExtPartPtr],eax
pop ds
popad
ret
ReadDir endp




ReadSec proc near
;[ds]:si=buffer
pushf
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
popf
ret
ReadSec endp

HdInfo ends
end start
