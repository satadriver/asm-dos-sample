.386p

MainCode segment para use16
assume cs:MainCode
IntProc8139:
cli
pushad
push ds
push es
push fs
push gs

mov ax,cs
mov ds,ax
mov ax,0b800h
mov es,ax
mov dx,cs:[PortBase8139]
add dx,3eh
in ax,dx

CheckRecvOk:
mov bx,1
test ax,bx
jz CheckCRCerror
mov si,offset szRecvOk
call ShowIntInfo

CheckCRCerror:
mov bx,2
test ax,bx
mov si,offset szCRCorFrameAlignment
call ShowIntInfo

CheckTransmitOk:
mov bx,4
test ax,bx
jz CheckTransmitError
mov si,offset szTransmitOK
call ShowIntInfo

CheckTransmitError:
mov bx,8
test ax,bx
jz CheckRxBufOverFlow
mov si,offset szTransmitError
call ShowIntInfo

CheckRxBufOverFlow:
mov bx,16
test ax,bx
jz CheckPacketUnderrun
mov si,offset szRxBufOverFlow
call ShowIntInfo

CheckPacketUnderrun:
mov bx,32
test ax,bx
jz CheckRxFifoOverFlow
mov si,offset szPacketUnderrun
call ShowIntInfo

CheckRxFifoOverFlow:
mov bx,64
test ax,bx
jz CheckCableLenthChange
mov si,offset szRxFifoOverFlow
call ShowIntInfo

CheckCableLenthChange:
mov bx,2000
test ax,bx
jz CheckTimeOut
mov si,offset szCableLenthChange
call ShowIntInfo

CheckTimeOut:
mov bx,4000h
test ax,bx
jz CheckSysError
mov si,offset szTimeOut
call ShowIntInfo

CheckSysError:
mov bx,8000h
test ax,bx
jz IntProcEnd
mov si,offset szSysError
call ShowIntInfo

IntProcEnd:
mov al,20h
out 20h,al
cmp byte ptr cs:[IntLine8139],8
jb NoNeedToEndIntHigh
out 0a0h,al
NoNeedToEndIntHigh:
pop gs
pop fs
pop es
pop ds
popad
iret


ShowIntInfo proc
pushad
cld
mov ax,bx
out dx,ax
mov ah,cs:[FontColor]
mov di,cs:[ShowPos]
ShowInfo:
lodsb
cmp al,0
jz ShowEnd
stosw
jmp ShowInfo
ShowEnd:
inc byte ptr cs:[FontColor]
mov bl,al
shr bl,4
cmp al,bl
jnz IncShowPos
inc byte ptr cs:[FontColor]
IncShowPos:
add word ptr cs:[ShowPos],160
cmp word ptr cs:[ShowPos],3840
jb ShowIntInfoReturn
mov word ptr cs:[ShowPos],160
ShowIntInfoReturn:
popad
ret
ShowIntInfo endp

BusDevFunc8139              dd 0
PortBase8139                dw 0
IntLine8139                 db 0
IntPin8139                  db 0
FontColor                   db 42h
ShowPos                     dw 1600

szRecvOk                    db 'Receive Package Ok!',0
szCRCorFrameAlignment       db 'CRC or FrameAlignment Error!',0
szTransmitOK                db 'Transmit Ok!',0
szTransmitError             db 'Transmit Error!',0        
szRxBufOverFlow             db 'Rx Buffer OverFlow!',0
szPacketUnderrun            db 'Packet Underrun!',0      
szRxFifoOverFlow            db 'Rx FIFO OverFlow!',0
szCableLenthChange          db 'Cable Lenth Changed!',0
szTimeOut                   db 'Time Out!',0
szSysError                  db 'System Error!',0

szBusFuncDev                db '8139 Bus Dev Func is:',0
szPortBase                  db '8139 Port Base is:',0
szIntLine                   db '8139 Int Line is:',0
szIntPin                    db '8139 Int Pin is:',0

start:
mov ax,cs
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax

call Seek8139Info
call SetIntVector
call Init8139

mov ax,3100h
mov dx,offset start
add dx,0fh
shr dx,4
add dx,10h
int 21h



Seek8139Info proc
mov eax,80000008h                                  ;08 09 0a 0b is pci device class-subclass number,start from bus0,device0,func 0
SeekEthernetDevice:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
shr eax,16
cmp ax,0200h		                                   ;02 netword device,00 ethernet device
jnz SeekNextDevice

pop eax
add eax,8
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and ax,0fffeh
mov cs:[PortBase8139],ax
pop eax
add eax,2ch
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in ax,dx
mov cs:[IntLine8139],al
mov cs:[IntPin8139],ah

mov ax,cs
mov ds,ax
mov ah,9
mov dx,offset szFind8139
int 21h
ret

SeekNextDevice:
pop eax
add eax,100h
cmp eax,81000008h
jb SeekEthernetDevice

mov ax,cs
mov ds,ax
mov ah,9
mov dx,offset szNoEthernetDevice
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h
szFind8139          db 'Find 8139 series Pci Netword adapter!',0dh,0ah,24h
szNoEthernetDevice  db 'Not Found Ethernet Device,Press Any Key To Quit!',0dh,0ah,24h
align 10h
Seek8139Info endp






SetIntVector  proc
mov eax,8000f860h                   ;LPC offset 60h,61h,62h,63h is for IntPin 1,2,3,4        
add al,byte ptr cs:[IntPin8139]
dec al
mov dx,0cf8h                        ;is right that access not aligned dword?
out dx,eax
mov dx,0cfch
in eax,dx
mov al,cs:[IntLine8139]             ;bit7=0,enable pci routine to 8259 interruption
and al,7fh
out dx,eax                  

mov eax,8000f8d0h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
or eax,100h                         ;LPC offset 0d0h,d8=1 enable APIC
out dx,eax

cmp byte ptr cs:[IntLine8139],8
jb Set8259LowInt

in al,21h                           ;is it neccessary to mask master pic?
and al,0fbh                             ;PCI interrupt mask IRQ
out 21h,al

mov cl,cs:[IntLine8139]
sub cl,8
mov bl,1
shl bl,cl
in al,0a1h
or al,bl
out 0a1h,al

mov dx,4d1h                         ;PCI interrupt level strigger
in al,dx
or al,bl
out dx,al

mov al,cs:[IntLine8139]             ;set int vector
sub al,8
movzx ax,al
add ax,70h
shl ax,2
mov di,ax
mov ax,0
mov es,ax
mov ax,offset IntProc8139
mov es:[di],ax
add di,2
mov ax,seg IntProc8139
mov es:[di],ax
ret

Set8259LowInt:
mov cl,cs:[IntLine8139]
mov bl,1
shl bl,cl
in al,21h
or al,bl
out 21h,al

mov dx,4d0h
in al,dx
or al,bl
out dx,al

mov al,cs:[IntLine8139]
movzx ax,al
add al,8
shl ax,2
mov di,ax
mov ax,0
mov es,ax
mov ax,offset IntProc8139
mov es:[di],ax
add di,2
mov ax,seg IntProc8139
mov es:[di],ax
ret
SetIntVector endp






Init8139 proc
mov dx,cs:[PortBase8139]
add dx,37h
mov al,10h
out dx,al
WaitInitOk:
in al,dx
test al,10h
jnz WaitInitOk
mov al,08h                      ;d3=1 enable receive package
out dx,al

mov dx,cs:[PortBase8139]
add dx,34h
mov ax,0
out dx,ax

mov dx,cs:[PortBase8139]
add dx,38h
mov ax,0
out dx,ax

mov dx,cs:[PortBase8139]
add dx,3ah
mov ax,0
out dx,ax

mov dx,cs:[PortBase8139]
add dx,44h
mov eax,0bfh                ;network bytes sequence?
out dx,eax

mov dx,cs:[PortBase8139]
add dx,40h
mov eax,62000200h           ;8139,adjust time,with CRC,64b DMA
out dx,eax


mov dx,cs:[PortBase8139]
add dx,10h
mov eax,0
out dx,eax
mov dx,cs:[PortBase8139]
add dx,20h
mov eax,00006000h
out dx,eax

mov dx,cs:[PortBase8139]
add dx,14h
mov eax,0
out dx,eax
mov dx,cs:[PortBase8139]
add dx,24h
mov eax,00006800h
out dx,eax

mov dx,cs:[PortBase8139]
add dx,18h
mov eax,0
out dx,eax
mov dx,cs:[PortBase8139]
add dx,28h
mov eax,00007000h
out dx,eax

mov dx,cs:[PortBase8139]
add dx,1ch
mov eax,0
out dx,eax
mov dx,cs:[PortBase8139]
add dx,2ch
mov eax,00007800h
out dx,eax

mov dx,cs:[PortBase8139]
add dx,30h
mov eax,00005000h           ;network bytes sequence?
out dx,eax

mov dx,cs:[PortBase8139]    ;enable intterrupt
add dx,3ch
mov ax,0ffffh               ;network bytes sequence?
out dx,ax

ret
Init8139 endp

MainCode ends
end start

