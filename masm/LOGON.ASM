.386
LogIn segment para use16
assume cs:LogIn
Start:
mov ax,LogIn
mov ds,ax
mov es,ax

mov ax,201h
mov bx,offset MbrBase
mov cx,1		;C\H\S mode 1=LBA mode 0
mov dx,80h
int 13h
mov bx,offset MbrBase
cmp dword ptr es:[bx+NewMbrFlag],12345678h
jz ToQuit

mov ax,301h
mov bx,offset MbrBase
mov cx,5
mov dx,80h
int 13h

mov ax,Code
mov es,ax
mov ax,302h
mov bx,0
mov cx,6
mov dx,80h
int 13h

mov ax,NewMbr
mov ds,ax
mov ax,LogIn
mov es,ax
mov si,0
mov di,offset MbrBase
mov cx,ds:[NewMbrLen]
cld
rep movsb
mov ax,301h
mov bx,offset MbrBase
mov cx,1
mov dx,80h
int 13h

mov al,0feh
out 64h,al
toQuit:
mov ah,9
mov dx,offset MsgCreation
int 21h
mov ah,4ch
int 21h
MbrBase 	db 200h dup (0)
MsgCreation	db 'LogIn Has Been Loaded!',24h
LogIn ends



NewMbr segment para use16
assume cs:NewMbr
cli
mov ax,1000h
mov es,ax
mov ds,ax
mov ax,202h
mov bx,0
mov cx,6
mov dx,80h
int 13h
db 0eah
dw 0
dw 1000h
NewMbrFlag	dd 12345678h
NewMbrLen 	dw $
NewMbr ends




Code segment para use16
assume cs:Code
mov ax,3
int 10h
mov ax,0b800h
mov es,ax
mov ax,cs
mov ds,ax
mov ss,ax
mov sp,0ff00h
WaitFree:
in al,64h
test al,1
jz BeFree
in al,60h
jmp WaitFree
cld
BeFree:
call ShowFrame
mov si,offset PassWord
lodsd
cmp eax,0
jnz GetPassWord

GetNewPassWord:
call ClearBack
mov si,offset MsgFirst
call ShowMsg
call WaitPassWord
mov eax,ds:[Buffer]
mov ds:[PassWord],eax
call ClearBack
mov si,offset MsgNext
call ShowMsg
call WaitPassWord
mov eax,ds:[Buffer]
cmp eax,dword ptr ds:[PassWord]
jnz GetNewPassWord
jmp ToLoad

align 10h
GetPassWord:
call ClearBack
mov si,offset MsgLogOn
call ShowMsg
call WaitPassWord
mov eax,ds:[Buffer]
cmp eax,dword ptr ds:[PassWord]
jnz GetPassWord
align 10h
ToLoad:
mov ax,cs
mov es,ax
mov ds,ax
mov ax,302h
mov bx,0
mov cx,6
mov dx,80h
int 13h
mov ax,0
mov es,ax
mov ds,ax
mov ax,201h
mov bx,7c00h
mov cx,5
mov dx,80h
int 13h
db 	0eah
dw 	07c00h
dw 	0

WaitPassWord proc near
mov si,offset Buffer
mov cx,4
WaitKey:
in al,64h
test al,1
jz WaitKey
in al,60h
cmp al,1ch
jz WaitKey
cmp al,2
jb WaitKey
cmp al,0bh
jbe LegacyCode
cmp al,10h
jb WaitKey
cmp al,19h
jbe LegacyCode
cmp al,1eh
jb WaitKey
cmp al,26h
jbe LegacyCode
cmp al,2ch
jb WaitKey
cmp al,32h
jbe LegacyCode
jmp WaitKey

LegacyCode:
mov ds:[si],al
inc si
mov ax,0a2ah
stosw
call ShowArrow
loop WaitKey
WaitEnter:
in al,60h
cmp al,1ch
jnz WaitEnter
ret
WaitPassWord endp



ShowMsg Proc near
mov di,1920
add di,40
Show:
lodsb
cmp al,0
jz EndShow
mov ah,0ch
stosw
jmp Show
EndShow:
call ShowArrow
ret
ShowMsg endp


ShowArrow proc near
push ax
push di
mov ax,di
shr ax,1	;why cursor position is char pos/2?????
shl ax,8
mov al,0fh
mov dx,3d4h
out dx,ax
mov ax,di
shr ax,1
mov al,0eh
mov dx,3d4h
out dx,ax
pop di
pop ax
ret
ShowArrow endp


ClearBack proc near
mov di,1920
add di,2
mov cx,78
mov ax,0c20h
rep stosw
ret
ClearBack endp


ShowFrame proc near
mov di,1760
mov ah,9
mov al,0dah
stosw
mov cx,78
mov al,0c4h
rep stosw
mov al,0bfh
stosw

mov al,0b3h
stosw
mov cx,78
mov al,20h
rep stosw
mov al,0b3h
stosw

mov al,0c0h
stosw
mov al,0c4h
mov cx,78
rep stosw
mov al,0d9h
stosw
ret
ShowFrame endp



MsgFirst	db 'Please Input New PassWord:',0
MsgNext		db 'Please Input New PassWord Again:',0
MsgLogOn	db 'Please Input Password:',0
PassWord	dd 0
Buffer		dd 0
Code ends
end start