.386p
code segment para use16
assume cs:code
new_nmi:
pushad
push ds
push es
push fs
push gs

mov ax,cs
mov ds,ax
mov ax,0b800h
mov es,ax
mov di,cs:[ShowPos]

in al,61h
test al,80h
jz IOcheckError

RAMparityError:
mov si,offset szRAMparityError
call ShowMsg 
jmp ProcessEnd

IOcheckError:
test al,40h
jz OtherError
mov si,offset szIoCheckError
call ShowMsg 
jmp ProcessEnd

OtherError:
mov si,offset szOtherError
call ShowMsg 
jmp ProcessEnd

ProcessEnd:
pushf
call dword ptr cs:[old_nmi_ip]

pop gs
pop fs
pop es
pop ds
popad
iret

ShowMsg proc
mov di,cs:[ShowPos]
show_msg:
lodsb
cmp al,0
jz ShowMsgEnd
mov ah,cs:[color]
stosw
jmp show_msg
ShowMsgEnd:
add word ptr cs:[ShowPos],160
cmp word ptr cs:[ShowPos],3200
jb NotShowBack
mov word ptr cs:[ShowPos],1600
NotShowBack:
ret
ShowMsg endp

szRamParityError        db 'RAM Parity error!',0
szIoCheckError          db 'IO check error!',0
szOtherError            db 'Other error!',0
old_nmi_ip              dw 0
old_nmi_cs              dw 0
ShowPos                 dw 1600
color                   db 02h




start:
cli
mov ax,0
mov es,ax
mov di,2
shl di,2
push word ptr es:[di]
pop word ptr cs:[old_nmi_ip]
mov ax,offset new_nmi
stosw
push word ptr es:[di]
pop word ptr cs:[old_nmi_cs]
mov ax,seg new_nmi
stosw

in al,61h
or al,0ch
out 61h,al
mov al,0                ;d7=0,enable NMI
out 70h,al
sti

mov ax,3100h
mov dx,offset start
add dx,0fh
shr dx,4
add dx,10h
int 21h

code ends
end start