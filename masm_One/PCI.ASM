.model small
.386
.stack
.data
str0 db "E:\ASM\MASM\PCI.TXT",00
.code
start:
mov ax,0b800h
mov es,ax
mov di,0

mov eax,80001000h  ;fa hdd  f8 lpc,fb=smbus,d0=usb
read:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx

call far ptr shift

pop eax
add eax,4
cmp al,0
jnz read

quit:
mov  ah,0
int 16h
mov ax,3
int 10h
mov ah,4ch
int 21h

shift proc far
push eax
push ecx
push edx
mov edx,eax
;shr EDX,16
;SHL EAX,16
;ADD EDX,EAX
mov ecx,28
l0:
mov eax,edx
shr eax,cl
and al,0fh
cmp al,9
jbe digital0
add al,7
digital0:
add al,30h
mov ah,42h
stosw
sub cl,4
cmp cl,-4
jnz l0
mov eax,07200720h
stosd
pop edx
pop ecx
pop eax
retf
shift endp
end start

