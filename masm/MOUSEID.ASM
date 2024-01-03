.model small
.386
.code
start:
call WaitIn
mov al,0a8h
out 64h,al
call WaitIn
mov al,0d4h
out 64h,al
call waitIn
mov al,0f4h
out 60h,al
call waitIn
mov al,60h
out 60h,al
call WaitIn
mov al,47h
out 60h,al

call WaitIn
mov al,0d4h
out 64h,al
l0:
call WaitIn
mov al,0f2h
out 60h,al
call WaitOut
in al,60h
cmp al,0fah
jnz l0
in al,60h
mov bl,al
mov cl,al
mov dl,al
mov ah,4ch
int 21h


waitIn proc near
in al,64h
test al,2
jnz WaitIn
ret

WaitOut proc near
in al,64h
test al,1
jz WaitOut
ret
end start