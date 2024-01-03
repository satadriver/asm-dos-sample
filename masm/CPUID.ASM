.386   ;why 386 instruction could exexcte the pentium instructions?
code SEGMENT PARA USE16
ASSUME CS:CODE
org 100h
start:
push ds
push word ptr 0
jmp ll0
str0 db "cpuid is:"
cpu db 16 dup (20h)
db 24h
ll0:
PUSHF
POP AX
OR AX,100H
PUSH AX
POPF

mov al,44h
mov dx,3f8h
out dx,al
;mov ax,3
;int 10h
mov ax,cs
mov ds,ax
mov eax,0
                         
dw 0a20fh        ; CPUID IS NOT RIGHT ; machine word of cpuid
;mov dword ptr ds:[cpu],eax
mov dword ptr ds:[cpu+4],ebx
mov dword ptr ds:[cpu+8],edx
mov dword ptr ds:[cpu+12],ecx

mov ax,0b800h
mov es,ax

;mov dx,3d4h
;mov al,0ch
;out dx,al
;mov dx,3d5h
;mov al,0
;out dx,al
;mov dx,3d4h
;mov al,0dh
;out dx,al
;mov dx,3d5h
;mov al,0a0h
;out dx,al

;mov dx,3d4h
;mov ax,0eh
;out dx,ax
;mov dx,3d4h
;mov ax,0f80fh
;out dx,ax

cld
mov ah,0ch           ;watch the attribute,to commplish blink and enhanced color
mov di,1600
mov si,offset str0
l0:
lodsb
cmp al,24h
jz outloop
stosw
jmp l0

outloop:
mov ah,0
int 16h
mov ah,4ch
int 21h
;int 20h

;1 int 20h

;2  mov ah,0 int 21h

;3 retf

;4 mov ah,4ch int 21h
;above 4 mentioned methods could all go back to DOS!!!
CODE ENDS
end start