.386p

StackSeg segment page
db              400h dup (0)
StackSeg ends

StackSeg3 segment page
db		400h dup (0)
StackSeg3 ends

InfoSeg segment page
ShowPos         dd      0b8000h
szEnterProtect  db      'Now Enter Paging Protect Mode 32.',0
szEnterPl3	db 	'Now Enter Protect Privilidge 3.',0
szErrorCode	db 	'The Page Exception Error Code is:',0
szFaultPbitZero db      'Page Fault of NO EXISTING PAGE! The CR2 Value is:',0
szFaultAccess	db	'Page Fault of ACCESSING VIOLATION! the CR2 Value is:',0

szNotEnoughPage db      'Not enough valid page!',0
szPageOk        db      'Page Fault Process OK  !',0
szToDos		db	'Now Returning to DOS,Press Any Key to Continue...',0
InfoSeg ends


GdtSeg segment page
NullDesc        dq      0
RmDesc          dq      000092000000ffffh
PmCode16Desc    dq      000098000000ffffh
PmCode32Desc    dq      00cf9a000000ffffh
PmData32Desc    dq      00cff2000000ffffh
PmStack32Desc   dq      00409200000003ffh
PageFaultDesc   dq      00409a000000ffffh
InfoDesc        dq      0040f2000000ffffh
MainTssDesc	dq	0000890000000067h
PmStack3Desc	dq	0040f200000003ffh
PmCode32Pl3Desc dq 	00cffa000000ffffh
CallGateDesc	dq	0000ec0000180000h

PmDirectDesc	dq 	00cf9a000000ffffh

MainTss		dd 0
		dd 200h
		dd 28h
		dd 22 dup (0)
		dw 0
		dw $+2
		db 0ffh

align           qword
GdtReg          df      000000000067h
StackPointer    dd      0
GdtSeg ends



IdtSeg segment page
                dq      14 dup (0)
PageFault       dq      00008f0000300000h                
                dq      241 dup (0)

align           qword
IdtReg          df      0000000007ffh
align           qword
OldIdt          df      0
IdtSeg ends



RmCode16Seg segment page use16
assume cs:RmCode16Seg
start:

mov ax,4f02h
mov bx,3
int 10h

xor ebx,ebx                     ;段寄存器不能用MOVZX直接赋值给通用寄存器并清除寄存器高16位
mov bx,IdtSeg
mov es,bx
shl ebx,4
mov dword ptr es:[IdtReg+2],ebx

xor eax,eax
mov ax,GdtSeg
mov ds,ax
shl eax,4
mov dword ptr ds:[GdtReg+2],eax

xor eax,eax
mov ax,PmCode16Seg
shl eax,4
mov word ptr ds:[PmCode16Desc+2],ax
shr eax,16
mov byte ptr ds:[PmCode16Desc+4],al

xor eax,eax
mov ax,PmCode32Seg
shl eax,4
push ds
push eax
mov word ptr ds:[PmCode32Desc+2],ax
mov word ptr ds:[PmCode32Pl3Desc+2],ax
shr eax,16
mov byte ptr ds:[PmCode32Desc+4],al
mov byte ptr ds:[PmCode32Pl3Desc+4],al
xor ebx,ebx
mov bx,offset ReturnPl0
mov word ptr ds:[CallGateDesc],bx 

pop eax
mov ebx,0
mov bx,offset PmDirect
add eax,ebx
mov dx,PmCode32Seg
mov ds,dx
mov dword ptr ds:[PmDirectOffset],eax
pop ds

xor eax,eax
mov ax,StackSeg
shl eax,4
mov word ptr ds:[PmStack32Desc+2],ax
shr eax,16
mov byte ptr ds:[PmStack32Desc+4],al

xor eax,eax
mov ax,PageDefaultSeg
shl eax,4
mov word ptr ds:[PageFaultDesc+2],ax
shr eax,16
mov byte ptr ds:[PageFaultDesc+4],al

xor eax,eax
mov ax,InfoSeg
shl eax,4
mov word ptr ds:[InfoDesc+2],ax
shr eax,16
mov byte ptr ds:[InfoDesc+4],al

xor eax,eax
mov ax,StackSeg3
shl eax,4
mov word ptr ds:[PmStack3Desc+2],ax
shr eax,16
mov byte ptr ds:[PmStack3Desc+4],al

xor eax,eax
xor ebx,ebx
mov ax,ds
shl eax,4
mov bx,offset MainTss
add eax,ebx
mov word ptr ds:[MainTssDesc+2],ax
shr eax,16
mov byte ptr ds:[MainTssDesc+4],al

mov ax,ss
shl eax,16
mov ax,sp
mov dword ptr ds:[StackPointer],eax

cli
sidt qword ptr es:[OldIdt]
lidt qword ptr es:[IdtReg]
lgdt qword ptr ds:[GdtReg]
in al,92h
or al,2
out 92h,al
mov eax,cr0
or al,1
mov cr0,eax
                db 0eah
                dw offset PmCode16Start
                dw 10h

align 10h
ComeBackDos:
mov ax,GdtSeg
mov ds,ax
mov ax,IdtSeg
mov es,ax
lidt qword ptr es:[OldIdt]
lss sp,dword ptr ds:[StackPointer]
mov ax,4f02h
mov bx,3
int 10h
mov ah,4ch
int 21h
RmCode16Seg ends




PmCode16Seg segment para use16
assume cs:PmCode16Seg
PmCode16Start:
                db 0eah
                dw offset PmCode32Start
                dw 18h
ReturnDos:
mov ax,8
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,cr0
and al,0feh
mov cr0,eax
jmp far ptr ComeBackDos
PmCode16Seg ends



PmCode32Seg segment para use32
assume cs:PmCode32Seg
PmCode32Start:
mov ax,20h
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ax,28h
mov ss,ax
mov esp,200h
mov ax,40h
ltr ax

cld
mov ax,20h
mov ds,ax
mov es,ax
mov edi,00100000h
mov eax,00101007h
mov ecx,1024
InitPDE:
stosd
add eax,4096
loop InitPDE

mov edi,00101000h
mov eax,00000001h
mov ecx,00100000h
InitPTE:
stosd
add eax,4096
loop InitPTE

mov esi,00201000h
mov edi,00201000h
mov ecx,000c0000h
ClearP:
lodsd
and al,0feh
stosd
loop ClearP

mov eax,00100000h
mov cr3,eax

mov eax,cr0
or eax,80000000h
mov cr0,eax
jmp PageEnable
PageEnable:

mov ax,20h
mov es,ax
mov ax,38h
mov ds,ax
mov esi,offset szEnterProtect
mov edi,ds:[ShowPos]
add dword ptr ds:[ShowPos],160
mov ah,0fh
ShowInfo:
lodsb
cmp al,0
jz EndShowInfo
stosw
jmp ShowInfo
EndShowInfo:

mov ax,20h
mov ds,ax
mov es,ax
mov esi,0c0000000h
mov edi,0c0000000h
mov ecx,1000000h
Change:
lodsd
mov eax,12345678h
stosd
loop Change

		db 0eah
PmDirectOffset 	dd 0
		dw 60h

PmDirect:

mov ax,48h
add ax,3
movzx eax,ax
push eax
push dword ptr 200h
;pushfd		
mov ax,50h
add ax,3
movzx eax,ax
push eax
push offset PmCodePl3
;iretd			;is both iretd and ret could be using to ring3?
retf

PmCodePl3:
mov ax,3bh
mov ds,ax
mov ax,23h
mov es,ax
mov edi,0b8000h
mov ecx,1000h
mov ax,720h
rep stosw
mov esi,offset szEnterPl3
mov dword ptr ds:[ShowPos],0b8000h
mov edi,ds:[ShowPos]
add dword ptr ds:[ShowPos],160
mov ah,6
ShowPl3:
lodsb
cmp al,0
jz ShowPl3End
stosw
jmp ShowPl3
ShowPl3End:




	db 09ah
	dw 0
	dw 0
	dw 58h


ReturnPl0:
mov ax,20h
mov es,ax
mov ax,38h
mov ds,ax
mov esi,offset szToDos
add dword ptr ds:[ShowPos],160
mov edi,ds:[ShowPos]
mov ah,8fh
ShowEnd:
lodsb
cmp al,0
jz EndShow
stosw
jmp ShowEnd
EndShow:
in al,60h
test al,80h
jnz EndShow

PageClose:
mov eax,cr0
and eax,7fffffffh
mov cr0,eax
jmp PageDisable
PageDisable:
                db 0eah
                dw offset ReturnDos
                dw 0
                dw 10h
PmCode32Seg ends





PageDefaultSeg  segment page use32
assume cs:PageDefaultSeg

pushad
push ds
push es
push fs
push gs

cld
mov ax,38h
mov ds,ax
mov ax,20h
mov es,ax
mov edi,ds:[ShowPos]
mov esi,offset szErrorCode
mov ah,0fh
ShowErrorCode:
lodsb
cmp al,0
jz ShowErrorCodeEnd
stosw
jmp ShowErrorCode
ShowErrorCodeEnd:
mov eax,ss:[esp+48]
call HexToDecimal

mov eax,ss:[esp+48]
test eax,1
jz PbitZero
mov edi,ds:[ShowPos]
add edi,160
mov esi,offset szFaultAccess
mov ah,0fh
ShowAccess:
lodsb
cmp al,0
jz GoBackDos
stosw
jmp ShowAccess

GoBackDos:
mov eax,cr2
call HexToDecimal
mov eax,0
WaitSlot:
inc eax
cmp eax,80000000h
jnz WaitSlot
add esp,48
add esp,4
	db 0eah
	dw offset PageClose 
	dw 0
	dw 18h

PbitZero:
mov edi,ds:[ShowPos]
add edi,160
mov esi,offset szFaultPbitZero
mov ah,0fh
ShowZero:
lodsb
cmp al,0
jz ShowFaultEnd
stosw
jmp ShowZero

ShowFaultEnd:
mov eax,cr2
call HexToDecimal

mov ax,20h
mov ds,ax
mov es,ax
mov esi,00105000h	
mov ecx,00040000h
FindPage:
lodsd
test eax,1
jz NotValidPage
test eax,60h
jz FindValidpage
NotValidPage:
loop FindPage

mov ax,38h
mov ds,ax
mov ax,20h
mov es,ax
mov ah,0fh
mov edi,ds:[ShowPos]
add edi,320
mov esi,offset szNotEnoughPage
ShowNotEnoughPage:
lodsb
cmp al,0
jz GoBackDos
stosw
jmp ShowNotEnoughPage

FindValidPage:
sub esi,4

mov edi,cr2
mov ebx,edi
and ebx,003ff000h       ;Remeber to clear low 12 bits
shr ebx,12
shr edi,22
shl edi,2               ;Remeber the pure PDE is not offset 
shl ebx,2               ;Remeber the pure PTE is not offset
mov edx,cr3
and edx,0fffff000h      ;Remember to clear lower 12 bits
add edi,edx
mov edi,[edi]           ;this usage is ok,release youself to use it
and edi,0fffff000h      ;Remember to clear lower 12 bits
add edi,ebx
mov edx,[edi]
mov [edi],eax
mov [esi],edx

mov ebx,eax
mov ecx,edi
mov ax,38h
mov ds,ax
mov ax,20h
mov es,ax

mov edi,ds:[ShowPos]
add edi,1600
mov eax,ebx
call HexToDecimal

add edi,20
mov eax,ecx
call HexToDecimal

add edi,20
mov eax,edx
call HexToDecimal

add edi,20
mov eax,esi
call HexToDecimal

mov ah,0fh
mov esi,offset szPageOk
mov edi,ds:[ShowPos]
add edi,320
ShowOk:
lodsb
cmp al,0
jz ShowOkEnd
stosw
jmp ShowOk
ShowOkEnd:

PageExceptionEnd:
pop gs
pop fs
pop es
pop ds
popad
add esp,4
iretd



HexToDecimal:
pushad

mov edx,eax
shr eax,28
and eax,0fh
cmp al,9
jbe High0
add al,7
High0:
add al,30h
mov ah,24h
stosw

mov eax,edx
shr eax,24
and eax,0fh
cmp al,9
jbe High1
add al,7
High1:
add al,30h
mov ah,24h
stosw

mov eax,edx
shr eax,20
and eax,0fh
cmp al,9
jbe High2
add al,7
High2:
add al,30h
mov ah,24h
stosw

mov eax,edx
shr eax,16
and eax,0fh
cmp al,9
jbe High3
add al,7
High3:
add al,30h
mov ah,24h
stosw

mov eax,edx
shr eax,12
and eax,0fh
cmp al,9
jbe High4
add al,7
High4:
add al,30h
mov ah,24h
stosw

mov eax,edx
shr eax,8
and eax,0fh
cmp al,9
jbe High5
add al,7
High5:
add al,30h
mov ah,24h
stosw

mov eax,edx
shr eax,4
and eax,0fh
cmp al,9
jbe High6
add al,7
High6:
add al,30h
mov ah,24h
stosw

mov eax,edx
and eax,0fh
cmp al,9
jbe High7
add al,7
High7:
add al,30h
mov ah,24h
stosw

popad
ret
PageDefaultSeg ends
end start