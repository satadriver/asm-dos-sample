.386
KbdIntProc  segment para use16
assume cs:KbdIntProc



KeyMain proc near
cli
pushad
push ds
push es
push fs
push gs
mov al,20h
out 20h,al

mov ax,cs
mov ds,ax
mov es,ax   
mov fs,ax
mov gs,ax
;cld
;mov di,offset ScanCode
;FetchScanCode:
;in al,64h
;test al,1
;jz EndScanCode		;msut clear kbd_obf_reg
;in al,60h
;stosb
;jmp FetchScanCode
;EndScanCode:

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
KeyMain endp



Analysis proc near
mov ax,40h
mov es,ax			;from now on es is Not Changed!
cmp byte ptr ds:[scancode],1dh
jnz notmakeCTRL
or byte ptr es:[17h],4
ret
notmakeCTRL:
cmp byte ptr ds:[scancode],2ah		;SHIFT LEFT
jnz checkMAKEshiftright
or byte ptr es:[17h],2
RET
checkMAKEshiftright:
cmp byte ptr ds:[scancode],36h
jnz notmakeshiftright
or byte ptr es:[17h],1
ret
notmakeSHIFTright:
cmp byte ptr ds:[scancode],38h
jnz notmakeALT
OR byte ptr es:[17h],8
ret
notmakeALT:
cmp byte ptr ds:[scancode],3ah
jnz notmakecapslock
call makecapslock
ret
notmakecapslock:
cmp byte ptr ds:[scancode],46h
jnz notmakescrolllock
call makescrolllock
ret
notmakescrolllock:
cmp byte ptr ds:[scancode],45h
jnz notmakenumslock
call makenumsLock
ret
notmakenumslock:
cmp byte ptr ds:[scancode],0b6h
jnz CHECKbreakshiftLEFT
AND BYTE PTR ES:[17H],0FEH
RET
CHECKBREAKSHIFTLEFT:
cmp byte ptr ds:[scancode],0aah
jnz notbreakshiftRight
and byte ptr es:[17h],0fDh
ret
notbreakshiftRight:
cmp byte ptr ds:[scancode],9dh
jnz notbreakCTRL
AND byte ptr es:[17h],0FBH
ret
notbreakCTRL:
cmp byte ptr ds:[scancode],0b8h
jnz notbreakALT
AND byte ptr es:[17h],0F7h
ret
notbreakALT:
cmp byte ptr ds:[scancode],52h
jnz notmakeinsert
Xor byte ptr es:[17h],80h
jmp MakeNormal			;Insert has code
notmakeinsert:
cmp byte ptr ds:[scancode],53h
jnz NotMakeDelete
test byte ptr es:[17h],4
jz ToMakeNormal
test byte ptr es:[17h],8
jz ToMakeNormal
call Reset			;to realize the reset or Shut or Go windows!!

NotMakeDelete:
cmp byte ptr ds:[scancode],80h
jae AnalysisReturn
ToMakeNormal:
call makenormal
AnalysisReturn:
ret
Analysis endp



MakeNormal proc near


cmp byte ptr cs:[Scancode],2eh
jz CtrlBreak
cmp byte ptr cs:[ScanCode],45h
jnz CheckNumLock
CtrlBreak:
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
jnz KeyCapsLock

test byte ptr es:[17h],3
jnz SHIFTKEY

NormalKey:
mov bx,offset ScanCodeNormal
jmp ScanCodeToAsc
ShiftKey:
mov bx,offset ScanCodeShift
jmp ScanCodeToAsc

KEYCAPSLOCK:
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
mov al,byte ptr ds:[scancode]
xlat
mov ah,byte ptr ds:[scancode]
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
mov es:[di],ax
mov word ptr es:[1ch],di	;Kbd buf head
;mov es:[di],ax
;add di,2
;cmp di,3eh
;jb DetailNotEnd
;mov di,1eh
;DetailNotEnd:
;mov word ptr es:[1ch],di	;Kbd buf end
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


waitout proc near
in al,64h
test al,1
jz waitout
ret
waitout endp



waitin proc near
in al,64h
test al,2
jnz waitin
ret
waitin endp



Reset proc near
jmp Shut
cli
mov ax,0b800h
mov es,ax
mov di,0
lea si,ds:[MsgReset]
cld
ShowMsgReset:
mov ah,ds:[MsgColor]
lodsb
cmp al,0dh
jz NextLine
cmp al,0
jz Choose
stosw
jmp ShowMsgReset
NextLine:
mov ax,di
mov dx,0
mov bx,160
div bx
sub bx,dx
add di,bx
jmp ShowMsgReset

Choose:
in al,60h
cmp al,31h
jz ReStart
cmp al,32h
jz Shut
cmp al,33h
jz ToWindows
jmp Choose

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

restart:
mov dx,0cf9h
mov al,4
out dx,al
ret

ToWindows:
sti
int 19h
reset endp



scancode    dd 0
LEDflag     db 0
MsgColor    db 42h
oldintip    dw 0
oldintCS    DW 0

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


MsgReset	db 'Input the Number You Want to do:',0dh
		db '1:RESET',0DH
		DB '2:SHUT',0DH
		DB '3:TO WINDOWS',0,0


start:
cli
cld
mov ax,KbdIntProc
mov ds,ax
mov ax,0
mov es,ax
mov di,9
shl di,2
mov ax,es:[di]
mov ds:[oldintIP],ax
mov ax,offset KeyMain
stosw
mov ax,es:[di]
mov ds:[oldintCS],AX
mov ax,seg KeyMain
stosw

sti
mov ax,3100h
mov dx,offset Start
add dx,0fh
shr dx,4
add dx,10h
int 21h

KbdIntProc ends
end start