.model small
.386p
.data
num0 dw 1234h
num1 dw 4000h dup (0ffffh)

.code
start:
mov ax,@data
mov ds,ax
mov es,ax
;mov eax,cr0
;btr eax,29
;btr eax,30
;mov cr0,eax

mov bx,3800h
mov ax,word ptr ds:[bx+num0]
;dw 090fh
mov eax,cr0
bts eax,29
bts eax,30
mov cr0,eax
mov eax,12345678h
mov dword ptr ds:[bx+num0],eax
mov ax,word ptr ds:[bx+num0]
mov ah,0
int 16h
mov ah,4ch
int 21h
end start