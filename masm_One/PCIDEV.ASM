.386
code segment para use16
assume cs:code
start:

jmp Main

PciDevBuf  	db 1000h dup (0)
ItemNum		dw 0
CurrentPos 	dw 0
ColorFont		db 0ah
ColorRed		db 04eh

Main proc near
Call SearchDev
call showDev
call ForView
call Quit
Main endp


SearchDev proc near
cld
mov ax,cs
mov ds,ax
mov es,ax
mov di,offset PciDevBuf
mov eax,80000008h
NextFunc:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in  eax,dx
cmp eax,0ffffffffh
jz SearchNextFunc
stosd
pop eax
stosd
push eax
inc word ptr ds:[ItemNum]
SearchNextFunc:
pop eax
add eax,100h
cmp eax,80ffff08h
jbe NextFunc
ret
SearchDev endp



ShowDev proc near
mov ax,3
int 10h
mov ax,cs
mov ds,ax
mov ax,0b800h
mov es,ax
mov si,offset PciDevBuf
mov di,0
ShowNext:
lodsd
cmp eax,0
jz ShowEnd
call HexToAscii
mov eax,200020h
stosd
stosd
lodsd
cmp eax,0
jz ShowEnd
call HexToAscii
mov ax,di
mov bx,160
mov dx,0
div bx
sub bx,dx
add di,bx
jmp ShowNext
ShowEnd:
ret
ShowDev endp



HexToAscii proc near
mov cx,4
ShowHex:
push eax
rol eax,cl
and al,0fh
cmp al,9
jbe Decimal
add al,7
Decimal:
add al,30h
mov ah,ds:[ColorFont]
stosw
pop eax
add cl,4
cmp cx,36
jnz ShowHex
ret
HexToAscii endp



SetBack proc near
push ax
mov ax,cs:[CurrentPos]
mov bx,160
mul bx
push ax
shr ax,1
mov bx,ax
mov al,0fh
mov ah,bl
mov dx,3d4h
out dx,ax
mov al,0eh
mov ah,bh
out dx,ax
pop ax
mov di,ax
inc di
mov cx,80
pop ax
FillBack:
stosb
inc di
loop FillBack
ret
SetBack endp




ForView proc near
WaitMov:
mov al,cs:[ColorRed]
call SetBack
mov ah,0
int 16h
cmp al,1bh
jz ViewOver
cmp ah,48h
jz Up
cmp ah,50h
jz Down
cmp al,0dh
jnz WaitMov

Call ShowSpace
call Showdev
jmp WaitMov

Down:
mov al,cs:[ColorFont]
call SetBack
add word ptr cs:[CurrentPos],1
mov ax,cs:[ItemNum]
cmp word ptr cs:[CurrentPos],ax
jl WaitMov
dec ax
mov word ptr cs:[CurrentPos],ax
jmp WaitMov
Up:
mov al,cs:[ColorFont]
call SetBack
sub word ptr cs:[CurrentPos],1
cmp word ptr cs:[CurrentPos],0
jge WaitMov
mov word ptr cs:[CurrentPos],0
jmp WaitMov

ViewOver:
ret
ForView endp


ShowSpace proc near
mov ax,3
int 10h
mov si,cs:[CurrentPos]
mov di,0
shl si,3
add si,4
add si,offset PciDevBuf
lodsd
sub eax,8
mov cx,40h

ShowDevSpace:
push eax
push cx
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
call HexToAscii
mov eax,720720h
stosd
pop cx
pop eax
add eax,4
loop ShowDevSpace
mov ah,0
int 16h
ret
ShowSpace endp


quit proc near
mov ax,3
int 10h
mov ah,4ch
int 21h
Quit endp
code ends
end start