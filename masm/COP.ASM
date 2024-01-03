;float exception interrupt process:
;1.enable FERR
;2.if in real mode,set int 75h
;3.if in protect mode,set int 10h and set d5(numeric error) in cr0
;4.clear mask bit in 82c59
;5.clear int 2 to alow slave interrupt
;6.clear float exception mask
;7.check fsw d15
;8.call old int 75h

.386p
CopExpProc segment para use16
assume cs:CopExpProc
MainCopExp:
pushf		;why must call old exception vector?????
call dword ptr cs:[OldCopExpVector]
pop dword ptr cs:[FpuExpAddr]
sub sp,4
cli
pushad
push ds
push es
push fs
push gs
fstcw word ptr cs:[FpuCw]
and word ptr cs:[FpuCw],0ffc0h
fstsw word ptr cs:[FpuSw]
mov al,0
out 0f0h,al
fclex
finit

mov ax,cs:[FpuSw]	;d15=1 indicate this is a float exception
test ax,8000h
jz OtherError

mov ax,0b800h
mov es,ax
mov ax,cs
mov ds,ax
mov edi,1600
mov cx,240
mov ax,0e020h
rep stosw		;clear background
mov si,offset szBusy
mov di,1600
mov ah,0e1h
call ShowErrorCode

mov ax,cs:[FpuSw]
test ax,80h
jz OtherError

test ax,1
jz TestDe
mov di,1760
mov si,offset szIe
mov ah,0e2h
call ShowErrorCode
jmp ShowErrorEnd

TestDe:
test ax,2
jz TestZe

mov di,1760
mov si,offset szDe
mov ah,0e2h
call ShowErrorCode
jmp ShowErrorEnd

TestZe:
test ax,4
jz TestOe

mov di,1760
mov si,offset szZe
mov ah,0e2h
call ShowErrorCode
jmp ShowErrorEnd

TestOe:
test ax,8
jz TestUe

mov di,1760
mov si,offset szOe
mov ah,0e2h
call ShowErrorCode
jmp ShowErrorEnd

TestUe:
test ax,16
jz TestPe

mov di,1760
mov si,offset szUe
mov ah,0e2h
call ShowErrorCode
jmp ShowErrorEnd

TestPe:
test ax,32
jz TestSf

mov di,1760
mov si,offset szPe
mov ah,0e2h
call ShowErrorCode
jmp ShowErrorEnd

TestSf:
test ax,64
jz OtherError
mov si,offset szSf
mov di,1760
mov ah,0e2h
call ShowErrorCode
jmp ShowErrorEnd

OtherError:
mov di,1760
mov si,offset szOther
mov ah,0e2h
call ShowErrorCode

ShowErrorEnd:
call ShowErrorAddr
fldcw word ptr cs:[FpuCw]
mov al,20h
out 0a0h,al
out 20h,al
pop gs
pop fs
pop es
pop ds
popad
sti
iret

ShowErrorCode:
lodsb
cmp al,0
jz ShowErrorCodeEnd
stosw
jmp ShowErrorCode
ShowErrorCodeEnd:
ret

ShowErrorAddr:
mov di,1920
mov si,offset szExpAddr
mov ah,0e4h
call ShowErrorCode

mov cl,28
ShowDecimal:
mov eax,cs:[FpuExpAddr]
shr eax,cl
and al,0fh
cmp al,9
jbe HexToDecimal
add al,7
align 10h
HexToDecimal:
add al,30h
mov ah,0e4h
stosw
sub cl,4
cmp cl,12
jnz NoSeperator
mov al,3ah
mov ah,0e4h
stosw
NoSeperator:
cmp cl,-4
jnz ShowDecimal
ret


OldCopExpVector     	dd 0
FpuCw               	dw 0
FpuSw               	dw 0
FpuExpAddr	    	dd 0
szBusy		    	db 'FPU EXCEPTION!',0
szOther		    	db 'NOT FPU EXCEPTION!',0
szIe			db 'ERROR CODE:Invalid Operation Exception!',0
szDe			db 'ERROR CODE:Denormalized Operand Exception!',0
szZe			db 'ERROR CODE:Zero Divide Exception!',0
szOe			db 'ERROR CODE:Overflow Exception!',0
szUe			db 'ERROR CODE:Underflow Exception!',0
szPe			db 'ERROR CODE:Precision Exception!',0
szSf			db 'ERROR CODE:Stack Fault!',0
szExpAddr		db 'FPU exception address is:',0

start:
mov ax,CopExpProc
mov ds,ax
mov ah,9
mov dx,offset szBeforeInstall
int 21h
mov ah,0
int 16h
cmp al,1bh
jnz NotQuit
mov ah,4ch
int 21h

NotQuit:
mov eax,cr0
test eax,1
jz NotInPmMode

mov ah,9
mov dx,offset szInPmMode
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h

NotInPmMode:
test eax,10h
jnz ExistCoprocessor

mov ah,9
mov dx,offset szNoCoprocessor
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h

ExistCoprocessor:
and eax,0ffffffc0h      ;clear protect mode exception
mov cr0,eax

mov eax,80000008h       ;Enable Coprocessor FERR
SeekISAbridge:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
shr eax,16
cmp ax,0601h
jz FindISAbridge
pop eax
add eax,100h
cmp eax,81000008h
jb SeekISAbridge
mov ah,9
mov dx,offset szNoISA
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h
FindISAbridge:
pop eax
mov al,0d0h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
or eax,2000h
out dx,eax

in al,0a1h              ;enable Fpu interruption
and al,0dfh
out 0a1h,al
in al,21h
and al,0fbh
out 21h,al

mov ax,0                ;save and set new Fpu interruption
mov es,ax
mov di,75h
shl di,2
mov eax,dword ptr es:[di]
mov dword ptr ds:[OldCopExpVector],eax
xor eax,eax
mov ax,CopExpProc
shl eax,16
mov ax,offset MainCopExp
mov dword ptr es:[di],eax

finit
fstcw word ptr ds:[FpuCw]
and word ptr ds:[FpuCw],0ffc0h      ;Unmask Fpu Exception
fldcw word ptr ds:[FpuCw]

mov ah,9
mov dx,offset szInstallOk
int 21h
mov ax,3100h
mov dx,offset start
add dx,0fh
shr dx,4
add dx,10h
int 21h

szBeforeInstall     	db 0dh,0ah
			db '---[Sample of Coprocessor Exception Management]---',0dh,0ah
                    	db 'This program can show you some notices if your computer encounter float error.'
                    	db ':). LIMITED by angryBird,satadriver@sina.cn,2013/11/1.',0dh,0ah
                    	db 0dh,0ah
                    	db '------Press ESC TO QUIT AND NOT INSTALL,any other key to continue------',0dh,0ah,24h                                      
szInstallOk         	db 0dh,0ah
			db '------Coprocessor Installed Completion!------',0dh,0ah,24h
szNoISA             	db 0dh,0ah
			db '------Can not Found ISA controller!------',0dh,0ah,24h
szNoCoprocessor     	db 0dh,0ah
			db '------Can not Found Independent Coprocessor!------',0dh,0ah,24h
szInPmMode          	db 0dh,0ah
			db '------This Program can only Run in DOS mode!------',0dh,0ah,24h
CopExpProc ends
end start