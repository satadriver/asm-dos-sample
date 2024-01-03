;若为ATA  则IRQ14对应MASTARY，IRQ15对应SECONDARY
;若为SATA则前一个BMIDEPORT端口对应MASTER，后一个端口对应SLAVE
;SATA配置空间顺序为MASTER_PRIMARY,MASTER_SECONDARY,SLAVE_PRIMARY,SLAVE_SECONDARY
;Pci int need:1 mask 2 Level Mode 3 Enable APIC 4 SEt PIRQ Control Reg 

.386p
Code Segment para use16
assume cs:code

HdIntProc:
pushad
push ds
push es

mov al,20h
out 20h,al
out 0a0h,al
mov dx,3f6h
in al,dx
mov dx,3f7h
in al,dx

pushf 
call dword ptr cs:[Old_IP]

mov ax,cs
mov ds,ax
mov ax,0b800h
mov es,ax
cld

mov dx,cs:[BmIdePort]
cmp dx,0
jnz CheckSataInt

mov si,offset HdintMessage
mov di,3250
jmp ShowIntMessage

CheckSataInt:
mov dx,cs:[BmIdePort]
in al,dx
mov si,offset SataIntMessage
mov di,3250

ShowIntMessage:
lodsb
cmp al,0
jz ShowMsgEnd
mov ah,0ah
stosw
jmp ShowIntMessage
ShowMsgEnd:
pop es
pop ds
popad
iret

Old_IP		dw 0
Old_CS		dw 0
HdPortBase	dw 0
BmIdePort	dw 0
IntLine		db 0
IntPin		db 0
SlaveFlag	db 0
SataFlag	db 0
HdInfo		db 200h dup (0)
HdIntMessage	db 'IDE Interruption Happening!',0
SataIntMessage	db 'SATA Interruption Happening!',0

Start:
jmp MainProc

HdPciPort	dw 24 dup (0)
PciPortNum	dw 0
NoDevice	db 'Not found Port',24h

MainProc Proc near
mov ax,cs
mov ds,ax
mov es,ax
mov ax,40h
mov gs,ax
mov fs,ax

cli
call GetPort
cmp byte ptr cs:[SataFlag],1
jz  SetSataInt
in  al,21h
and al,0fbh
out 21h,al
in  al,0a1h
cmp byte ptr cs:[SlaveFlag],0e0h
jz  AtaPrimary
and al,07fh
out 0a1h,al
mov di,77h
jmp SetVector
AtaPrimary:
and al,0bfh
out 0a1h,al
mov di,76h
jmp SetVector

SetSataInt:
mov eax,8000f860h
add al,cs:[IntPin]
dec al
mov dx,0cf8h
out dx,eax
mov dx,0cfch
mov al,cs:[IntLine]
out dx,al

mov eax,8000f8d0h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
or eax,100h
out dx,eax

mov bx,0
mov cl,cs:[IntLine]
movzx cx,cl
cmp cl,8
jae SubCtrl
mov di,8
add di,cx
bts bx,cl
mov dx,4d0h
in al,dx
or al,bl
out dx,al
in al,21h
or al,bl
out 21h,al
jmp SetVector
SubCtrl:
sub cl,8
mov di,70h
add di,cx
bts bx,cl
mov dx,4d1h
in al,dx
or al,bl
out dx,al
in al,0a1h
or al,bl
out 0a1h,al

SetVector:
mov ax,0
mov es,ax
shl di,2
push word ptr es:[di]
pop word ptr cs:[Old_IP]
mov ax,offset HdIntProc
stosw
push word ptr es:[di]
pop word ptr cs:[Old_CS]
mov ax,cs
stosw

sti
mov ax,3100h
mov dx,offset Start
add dx,0fh
shr dx,4
add dx,10h
int 21h
MainProc endp




GetPort proc near
mov dx,1f6h
mov al,0e0h
call CheckHdPort
cmp word ptr cs:[HdPortBase],0
jnz GetPortEnd

mov dx,1f6h
mov al,0f0h
call CheckHdPort
cmp word ptr cs:[HdPortBase],0
jnz GetPortEnd

mov dx,176h
mov al,0e0h
call CheckHdPort
cmp word ptr cs:[HdPortBase],0
jnz GetPortEnd

mov dx,176h
mov al,0f0h
call CheckHdPort
cmp word ptr cs:[HdPortBase],0
jnz GetPortEnd

call GetPciPort
mov byte ptr cs:[SlaveFlag],0e0h
call MasterSlave
cmp word ptr cs:[HdPortBase],0
jnz GetPortEnd
mov byte ptr cs:[SlaveFlag],0f0h
call MasterSlave
cmp word ptr cs:[HdPortBase],0
jnz GetPortEnd
mov ah,9
mov dx,offset NoDevice
int 21h
mov ah,4ch
int 21h
GetPortEnd:
ret

masterSlave:
mov si,offset HdPciPort
mov cx,cs:[PciPortNum]
CheckPciPort:
lodsw
mov dx,ax
add dx,6
mov al,cs:[SlaveFlag]
call CheckHdPort
cmp word ptr cs:[HdPortBase],0
jz NextPciPort
add si,6
lodsw
cmp byte ptr cs:[SlaveFlag],0e0h
jz MasterPrimary
add ax,8
MasterPrimary:
add ax,2
mov cs:[BmIdePort],ax
mov byte ptr cs:[SataFlag],1
ret
NextPciPort:
loop CheckPciPort
ret
GetPort endp



GetPciPort Proc near
pushad
mov di,offset HdPciPort
mov eax,80000008h
SearchPciDev:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in  eax,dx
shr eax,16
cmp eax,0101h
jnz ReadNextPciDev

pop eax
push eax
add eax,8
mov cx,6
Read6Port:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and ax,0fffeh
stosw
inc byte ptr cs:[PciPortNum]
pop eax
add eax,4
loop Read6Port

add eax,14h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in ax,dx
cmp ax,0
jz ReadNextPciDev
mov word ptr cs:[IntLine],ax

ReadNextPciDev:
pop eax
add eax,100h
cmp eax,80010008h
jb SearchPciDev
popad
ret
GetPciPort endp



CheckHdPort Proc near
push ax
push dx
out dx,al
inc dx
mov al,0ech
out dx,al
call WaitTime
in al,dx
cmp al,58h
jnz CheckHdPortEnd

pop dx
sub dx,6
mov cs:[HdPortBase],dx
pop ax
mov cs:[SlaveFlag],al
push cx
push di
mov cx,100h
mov di,offset HdInfo
cld
rep insw
pop di
pop cx
ret

CheckHdPortEnd:
pop dx
pop ax
ret

WaitTime:
push ax
mov ax,0
WaitTick:
in al,40h
cmp al,0
jnz WaitTick
inc ah
cmp ah,40h
jnz WaitTick
pop ax
ret
CheckHdPort endp


Code ends
end start


