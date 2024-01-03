.386
code segment para use16
assume cs:code
start:
mov ax,code
mov ds,ax
mov ax,0b800h
mov es,ax
mov ax,3
int 10h
mov di,0
cld
in al,21h
or al,2
out 21h,al
getkey:
in al,64h
test al,1
jz getkey
in al,60h
cmp al,1
jz exit

mov bl,al
shr al,4
cmp al,9
jbe Dec2
add al,7
dec2:
add al,30h
mov ah,0ah
stosw
mov al,bl
and al,0fh
cmp al,9
jbe dec1
add al,7
dec1:
add al,30h
mov ah,0ah
stosw
jmp getkey
exit:
in al,21h
and al,0fdh
out 21h,al
mov ah,4ch
int 21h
code ends
end start