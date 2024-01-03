.386
code segment para use16
assume cs:code
org 100h
start:
jmp main
align 10h
diPos 			dw 0
ShowPos			dw 1600
buffer 			db 1000h dup (0)
ARDS   			db 20 dup (0)
counter 		dw 0
Continuation_Value 	dd 0
color			db 42h
ShiftBits		db 28
msg_error 		db 'Error occurred!,quit now!',0ah,0dh,24h


main:
mov ax,3
int 10h
mov ax,cs
mov ds,ax
mov es,ax
mov di,offset buffer
mov ds:[diPos],di
cld

nextARSD:
mov eax,0e820h
MOV EBX,ds:[Continuation_value]
mov ecx,20
mov edx,534d4150h
mov di,offset ARDS
int 15h
jc error
mov ds:[Continuation_Value],ebx
cmp eax,534d4150h
jnz error
MoveData:
mov si,offset ARDS
mov di,ds:[diPos]
add si,4
lodsd
stosd
sub si,8
lodsd
stosd
add si,8
lodsd
stosd
sub si,8
lodsd
stosd
add si,4
lodsd
stosd
inc word ptr ds:[counter]
cmp dword ptr ds:[Continuation_Value],0
jz ReadEnd
add word ptr ds:[DiPos],20
jmp nextARSD

readEnd:
call show_ARDS

quit:
mov ah,4ch
int 21h
error:
mov ah,9
mov dx,offset msg_error
int 21h
jmp quit


show_ARDS PROC NEAR
mov ax,0b800h
mov es,ax
mov di,ds:[ShowPos]
mov si,offset buffer
mov cx,ds:[counter]
cmp cx,0
jz Show_End
show:
push cx
lodsd
call translate
lodsd
call translate
add di,4
lodsd
call translate
lodsd
call translate
add di,4
lodsd
call translate
mov dx,0
mov ax,di
mov bx,160
div bx
sub bx,dx
add di,bx
pop cx
loop show
Show_End:
ret
show_ARDS ENDP


Translate proc near
mov cx,8
Translate_Show:
push cx
mov cl,ds:[ShiftBits]
push eax
shr eax,cl
and al,0fh
cmp al,9
jbe Decimal
add al,7
Decimal:
add al,30h
mov ah,ds:[color]
stosw
sub byte ptr ds:[ShiftBits],4
pop eax
pop cx
loop Translate_Show
ret
Translate endp

code ends
end start