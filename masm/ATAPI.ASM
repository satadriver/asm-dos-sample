;u have some tip to remember in ur heart:
;1 DMA flag=0
;2 Packet command must send 3 times
;3 Slave bit=0e0h,not 0a0h or 0
 
.386
Code segment para use16
assume cs:code

start:
Main Proc near
mov ax,Code
mov ds,ax
mov es,ax

mov dx,1f6h
mov byte ptr ds:[SlaveFlag],0f0h
call AtaPrimary
cmp word ptr ds:[AtapiPort],0
jnz MainProc
mov dx,1f6h
mov byte ptr ds:[SlaveFlag],0e0h
call AtaPrimary
cmp byte ptr ds:[AtapiPort],0
jnz MainProc
mov dx,176h
mov byte ptr ds:[SlaveFlag],0f0h
call AtaPrimary
cmp word ptr ds:[AtapiPort],0
jnz MainProc
mov dx,176h
mov byte ptr ds:[SlaveFlag],0e0h
call AtaPrimary
cmp word ptr ds:[AtapiPort],0
jnz MainProc

mov byte ptr ds:[SlaveFlag],0e0h
call GetSataPort
call CheckSataPort
cmp word ptr ds:[AtapiPort],0
jz NoCd

MainProc:
mov ah,9
mov dx,offset msgOpen
int 21h
mov ah,0
int 16h
mov si,offset PacketOpen
mov ds:[CommandEA],si
call SendCommand
mov ah,9
mov dx,offset msgClose
int 21h
mov ah,0
int 16h
mov si,offset PacketClose
mov ds:[CommandEA],si
call SendCommand
ToQuit:
call QUit
NOCd:
mov ah,9
mov dx,offset msgNoDevice
int 21h
jmp Quit
Main endp



GetSataPort proc near
pushad
cld
mov di,offset SataPort
mov eax,80000008h
NextFunc:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in  eax,dx
shr eax,16
cmp eax,0101h
jnz ToNextFunc

pop eax
push eax
add eax,8
mov cx,4
GetPort:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in  eax,dx
and al,0feh
stosw
inc word ptr ds:[SataPortNum]
pop eax
add eax,4
loop GetPort

ToNextFunc:
pop eax
add eax,100h
cmp eax,80010000h
jb NextFunc
popad
ret
GetSataPort endp



CheckSataPort proc near
pushad
mov si,offset SataPort
mov cx,ds:[SataPortNum]
cmp cx,0
jz  EndCheck
CheckNext:
lodsw
mov dx,ax
add dx,7
mov al,0a1h
out dx,al
call WaitTime
in al,dx
cmp al,58h
jnz Nextport
sub dx,7
mov ds:[AtapiPort],dx
call ReadBuf
jmp EndCheck
NextPort:
loop CheckNext
EndCheck:
popad
ret
CheckSataPort endp




SendCommand proc near
cli
pushad
mov dx,ds:[AtapiPort]
add dx,7
call WaitFree
call WaitRdy
mov al,0a0h
out dx,al
call WaitFree
call WaitRdy
call WaitRqt
mov dx,ds:[AtapiPort]
inc dx
mov al,ds:[DMAflag]
out dx,al
add dx,3
in al,dx
mov cl,al
inc dx
in al,dx
mov ch,al
inc dx
mov al,ds:[SlaveFlag]
out dx,al
shr cx,1
mov cx,6
mov dx,ds:[AtapiPort]
mov si,ds:[CommandEA]
rep outsw
add dx,7
call WaitFree
call WaitRdy
sti
popad
ret
SendCommand endp



ReadBuf Proc near
pushad
mov dx,ds:[AtapiPort]
add dx,4
in al,dx
mov cl,al
inc dx
in al,dx
mov ch,al
Resend:
push cx
shr cx,1
mov dx,ds:[AtapiPort]
mov di,offset DataBuf
rep insw
add dx,5
in al,dx
mov ah,al
dec dx
in al,dx
pop cx
cmp ax,cx
jnz Resend
mov dx,ds:[AtapiPort]
add dx,7
call WaitFree
call WaitRdy
popad
ret
ReadBuf endp



WaitFree proc near
in al,dx
test al,80h
jnz WaitFree
ret
WaitFree endp

WaitRdy proc near
in al,dx
test al,40h
jz WaitRdy
ret
WaitRdy endp

WaitRqt proc near
in al,dx
test al,8
jz WaitRqt
ret
WaitRqt endp



WaitTime proc near
pushad
sti
mov ax,40h
mov fs,ax
mov eax,fs:[6ch]
inc eax
mov ebx,eax
WaitSec:
mov eax,fs:[6ch]
cmp eax,ebx
jbe WaitSec
popad
ret
WaitTime endp


AtaPrimary proc near
pushad
mov al,ds:[SlaveFlag]
out dx,al
inc dx
mov al,0a1h
out dx,al
call WaitTime
in al,dx
cmp al,58h
jnz NotAtaPort
sub dx,7
mov ds:[AtapiPort],dx
call ReadBuf
NotAtaPort:
popad
ret
AtaPrimary endp


Quit proc near
mov ah,4ch
int 21h
Quit endp



CommandEA		dw 0
DmaFlag			db 1
SlaveFlag		db 0
AtapiPort 		dw 0
SataPort 		db 40h dup (0)
SataPortNum 		dw 0
DataBuf			dw 200h dup (0)
PacketOpen 		db 1bh,3 dup (0),2,7 dup (0)
PacketClose 		db 1bh,3 dup (0),3,7 dup (0)
msgOpen			db 'Press any key to Eject the CD_ROM:',24h
msgClose		db 0ah,0dh,'Press any Key to Close the Tray:',24h
msgNoDevice		db 'Not Found CD_ROM!',0ah,0dh,24h
Code ends
end Start
