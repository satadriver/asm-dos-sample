.386p

Descriptor segment page
GetDescQHLP                 dd 0
GetDescQELP                 dd 0

			    db 0ff8h dup (0)
SetAddrQHLP                 dd 0
SetAddrQELP                 dd 0

			    db 0ff8h dup (0)
GetAllDescQHLP              dd 0
GetAllDescQELP              dd 0

align                       10h
GDsetupTDLP                 dd 0
GDsetupTDCS                 dd 1d800000h
GDsetupToken                dd 00e0002dh
GDsetupDataBuf              dd 0
GDsetupData                 db 80h,06h,00,01h,00,00,12h,00,8 dup (0)
align                       10h
GDinTDLP                    dd 0
GDinTDCS                    dd 1d800000h
GDinToken                   dd 00e80069h
GDinDataBuf                 dd 0
GDinData                    db 1024 dup (0)
align                       10h
GDoutTDLP                   dd 0
GDoutTDCS                   dd 1d800000h
GDoutToken                  dd 0ffe800e1h        ;recv bytes number is what?
GDoutDataBuf                dd 0
GDoutData                   db 1024 dup (0)

align                       10h
SAsetupTDLP                 dd 0
SAsetupTDCS                 dd 1d800000h
SAsetupToken                dd 00e0002dh
SAsetupDataBuf              dd 0
SAsetupData                 db 00,05h,02h,00,00,00,00,00,8 dup (0)            ;set addr = 1 ?????
align                       10h
SAinTDLP                    dd 0
SAinTDCS                    dd 1d800000h
SAinToken                   dd 0ffe80069h
SAinDataBuf                 dd 0
SAinData                    db 1024 dup (0)

align                       10h
GADsetupTDLP                dd 0
GADsetupTDCS                dd 1d800000h
GADsetupToken               dd 00e0022dh
GADsetupDataBuf             dd 0
GADsetupData                db 80h,06h,00,01h,00,00,12h,00,8 dup (0)
align                       10h
GADin0TDLP                  dd 0
GADin0TDCS                  dd 1d800000h
GADin0Token                 dd 00e80269h
GADin0DataBuf               dd 0
GADin0Data                  db 1024 dup (0)
align                       10h
GADin1TDLP                  dd 0
GADin1TDCS                  dd 1d800000h
GADin1Token                 dd 00e00269h
GADin1DataBuf               dd 0
GADin1Data                  db 1024 dup (0)
align                       10h
GADin2TDLP                  dd 0
GADin2TDCS                  dd 1d800000h
GADin2Token                 dd 00280269h	;2B
GADin2DataBuf               dd 0
GADin2Data                  db 1024 dup (0)
align                       10h
GADoutTDLP                  dd 0
GADoutTDCS                  dd 1d800000h
GADoutToken                 dd 0ffe802e1h
GADoutDataBuf               dd 0
GADoutData                  db 1024 dup (0)
DescriptorEnd               dw $
Descriptor ends



CodeSeg segment para use16
assume cs:CodeSeg
USBint0Proc:
pushad
push ds
push es
push fs
push gs
mov ax,cs
mov ds,ax
mov ax,0b800h
mov es,ax
mov si,offset USBport
mov cl,cs:[USBportCnt]
movzx cx,cl
cld
SeekInt0Port:
push cx
push si
lodsw
call CheckIntPort
pop si
add si,4
pop cx
loop SeekInt0Port

mov al,20h
out 20h,al
pop gs
pop fs
pop es
pop ds
popad
iret



USBint1Proc:
pushad
push ds
push es
push fs
push gs
mov ax,cs
mov ds,ax
mov ax,0b800h
mov es,ax
mov si,offset USBport
mov cl,cs:[USBportCnt]
movzx cx,cl
cld
SeekInt1Port:
push cx
push si
lodsw
call CheckIntPort
pop si
add si,4
pop cx
loop SeekInt1Port
mov al,20h
out 20h,al
out 0a0h,al
pop gs
pop fs
pop es
pop ds
popad
iret

CheckIntPort proc
mov dx,ax
add dx,2
in ax,dx
cmp ax,0
jnz CheckHCHalt
;mov si,offset szNoInt
;call ShowIntMsg
jmp NotIntPort

CheckHCHalt:
test ax,20h
jz CheckControllerError
mov ax,20h
out dx,ax
mov si,offset szHCHalt
call ShowIntMsg

CheckControllerError:
test ax,10h
jz CheckSystemError
mov ax,10h
out dx,ax
mov si,offset szProcessError
call ShowIntMsg

CheckSystemError:
test ax,8
jz CheckResume
mov ax,8
out dx,ax
mov si,offset szHostSystemError
call ShowIntMsg

CheckResume:
test ax,4
jz CheckIntError
mov ax,4
out dx,ax
mov si,offset szResumeDetect
call ShowIntMsg

CheckIntError:
test ax,2
jz CheckInt
mov ax,2
out dx,ax
mov si,offset szUSBerrorInt
call ShowIntMsg

CheckInt:
test ax,1
jz NotIntPort
mov ax,1
out dx,ax
mov si,offset szUSBint
call ShowIntMsg

add dx,4
in ax,dx
mov bl,al
shr al,4
cmp al,9
jbe NotHeximal0
add al,7
NotHeximal0:
add al,30h
mov byte ptr cs:[FrameNum],al
mov al,bl
and al,0fh
cmp al,9
jbe NotHeximal1
add al,7
NotHeximal1:
add al,30h
mov esi,offset FrameNum
mov byte ptr cs:[esi+1],al
mov si,offset szFrameNum
call ShowIntMsg

add dx,2
xor eax,eax
mov ax,5000h
shl eax,4
add eax,1000h
or eax,2
cmp eax,53002h
jae NotIntPort
out dx,eax
sub dx,8
mov ax,1
out dx,ax

NotIntPort:
ret
CheckIntPort endp


ShowIntMsg proc
pushad
mov di,cs:[ShowPos]
ShowMsg:
lodsb
cmp al,0
jz ShowEnd
mov ah,cs:[ShowColor]
stosw
jmp ShowMsg
ShowEnd:
add word ptr cs:[ShowPos],160
cmp word ptr cs:[ShowPos],3200
jb NotResetShowPos
mov word ptr cs:[ShowPos],1600
NotResetShowPos:
popad
ret
ShowIntMsg endp



USBport             dw 20h dup (0)
USBportCnt          db 0
ShowColor           db 2
ShowPos             dw 1600
szUSBint            db 'USB interruption!',0
szUSBerrorInt       db 'USB error!',0
szResumeDetect      db 'Resume Detect!',0
szHostSystemError   db 'Host system error!',0
szProcessError      db 'Host controller error!',0
szHCHalt            db 'HCHalt!',0
szNoInt             db 'No interrupt bit is set!other interruption?',0

szFrameNum          db 'Frame number is:'
FrameNum            dd 0
                    

start:
call DetectUSB 
call InitUSBint
call InitDesc

mov bx,Descriptor
mov ds,bx
mov ax,3100h
mov dx,offset start
add dx,ds:[DescriptorEnd]
add dx,2
add dx,0fh
shr dx,4
add dx,10h
int 21h





InitUSBint  proc
cli
mov eax,8000f8d0h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
or eax,100h                             ;LPC offset 0d0h,d8=1 enable APIC
out dx,eax

in al,21h                           
and al,0fbh                        
out 21h,al

mov cl,cs:[USBportCnt]
movzx cx,cl
mov bx,offset USBport
mov si,0
SetUSBintVector:
push cx
push bx
push si
mov eax,8000f860h                       ;LPC offset 60h,61h,62h,63h is for IntPin 1,2,3,4        
add al,byte ptr cs:[bx+si+3]
dec al
mov dx,0cf8h                        
out dx,eax
mov dx,0cfch
in eax,dx
mov al,byte ptr cs:[bx+si+2]           ;bit7=0,enable pci routine to 8259 interruption
and al,7fh
out dx,eax                  

cmp byte ptr cs:[bx+si+2],8
jb Set8259MasterInt

mov cl,cs:[bx+si+2]
sub cl,8
mov ch,1
shl ch,cl
not ch
in al,0a1h
and al,ch
out 0a1h,al

not ch
mov dx,4d1h                             ;PCI interrupt level strigger mode
in al,dx
or al,ch
out dx,al

mov al,cs:[bx+si+2]           
sub al,8
movzx ax,al
add ax,70h
shl ax,2
mov di,ax
mov ax,0
mov es,ax
mov ax,offset USBint1Proc
mov es:[di],ax
add di,2
mov ax,seg USBint1Proc
mov es:[di],ax
pop si
add si,4
pop bx
pop cx
loop SetUSBintVector
sti
ret

Set8259MasterInt:
mov cl,cs:[bx+si+2]
mov ch,1
shl ch,cl
not ch
in al,21h
and al,ch
out 21h,al

not ch
mov dx,4d0h
in al,dx
or al,ch
out dx,al

mov al,cs:[bx+si+2]
movzx ax,al
add al,8
shl ax,2
mov di,ax
mov ax,0
mov es,ax
mov ax,offset USBint0Proc
mov es:[di],ax
add di,2
mov ax,seg USBint0Proc
mov es:[di],ax
pop si
add si,4
pop bx
pop cx
dec cx
cmp cx,0
jnz SetUSBintVector
sti
ret
InitUSBint endp



DetectUSB proc
mov eax,80000008h
DetectDev:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in  eax,dx
shr eax,16
cmp eax,0c03h
jnz DetectNextDev

pop eax
push eax
push eax
add eax,18h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in  eax,dx
and ax,0fffeh
mov bl,cs:[USBportCnt]
movzx bx,bl
shl bx,2
mov di,offset USBport
add di,bx
mov cs:[di],ax

add di,2
pop eax
add eax,34h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in  eax,dx
mov cs:[di],ax
inc byte ptr cs:[USBportCnt]

DetectNextDev:
pop eax
add eax,100h
cmp eax,81000008h
jb  DetectDev
cmp word ptr cs:[USBportCnt],0
jz NoUSBdev

mov al,cs:[USBportCnt]
and al,0fh
cmp al,9
jbe  NotHex
add al,7
NotHex:
add al,30h
mov cs:[szUSBdevCnt],al
mov ax,cs
mov ds,ax
mov ah,9
mov dx,offset szUSBdev
int 21h
ret

NoUSBdev:
mov ax,cs
mov ds,ax
mov ah,9
mov dx,offset szNoUSBdev
int 21h
mov ah,4ch
int 21h
szNoUSBdev              db 'Not found USB device!',0dh,0ah,24h
szUSBdev                db 'Found USB device number:'
szUSBdevCnt             db 0
                        db 0dh,0ah,24h
DetectUSB endp





InitDesc proc
mov ax,Descriptor
mov ds,ax
mov ax,5000h
mov es,ax
mov si,0
mov di,0
mov cx,ds:[DescriptorEnd]
cld
rep movsb

xor eax,eax
mov ax,5000h
mov ds,ax
mov es,ax
shl eax,4
mov ecx,eax
xor ebx,ebx

mov eax,ecx
mov bx,offset SetAddrQHLP
add eax,ebx
or eax,2                            ;valid,QH
mov ds:[GetDescQHLP],eax
mov eax,ecx
mov bx,offset GetAllDescQHLP
add eax,ebx
or eax,2                            ;valid,QH
mov ds:[SetAddrQHLP],eax
mov dword ptr ds:[GetAllDescQHLP],1

mov eax,ecx
mov bx,offset GDsetupTDLP
add eax,ebx                         ;valid,TD
mov ds:[GetDescQELP],eax
mov eax,ecx
mov bx,offset GDinTDLP
add eax,ebx
or eax,4                            ;valid,TD,depth
mov ds:[GDsetupTDLP],eax
mov eax,ecx
mov bx,offset GDoutTDLP
add eax,ebx
or eax,4                            ;valid,TD,depth
mov ds:[GDinTDLP],eax
mov dword ptr ds:[GDoutTDLP],1      ;last TD
mov eax,ecx
mov bx,offset GDsetupData
add eax,ebx
mov ds:[GDsetupDataBuf],eax
mov eax,ecx
mov bx,offset GDinData
add eax,ebx
mov ds:[GDinDataBuf],eax
mov eax,ecx
mov bx,offset GDoutData
add eax,ebx
mov ds:[GDoutDataBuf],eax

mov eax,ecx
mov bx,offset SAsetupTDLP
add eax,ebx                         ;valid,TD
mov ds:[SetAddrQELP],eax
mov eax,ecx
mov bx,offset SAinTDLP
add eax,ebx
or eax,4                            ;valid,TD,depth
mov ds:[SAsetupTDLP],eax
mov dword ptr ds:[SAinTDLP],1       ;last QH,QH
mov eax,ecx
mov bx,offset SAsetupData
add eax,ebx
mov ds:[SAsetupDataBuf],eax
mov eax,ecx
mov bx,offset SAinData
add eax,ebx
mov ds:[SAinDataBuf],eax


mov eax,ecx
mov bx,offset GADsetupTDLP
add eax,ebx                         ;valid,TD
mov ds:[GetAllDescQELP],eax
mov eax,ecx
mov bx,offset GADin0TDLP
add eax,ebx
or eax,4                            ;valid,TD,depth
mov ds:[GADsetupTDLP],eax
mov eax,ecx
mov bx,offset GADin1TDLP
add eax,ebx
or eax,4                            ;valid,TD,depth
mov ds:[GADin0TDLP],eax
mov eax,ecx
mov bx,offset GADin2TDLP
add eax,ebx
or eax,4                            ;valid,TD,depth
mov ds:[GADin1TDLP],eax
mov eax,ecx
mov bx,offset GADoutTDLP
add eax,ebx
or eax,4                            ;valid,TD,depth
mov ds:[GADin2TDLP],eax
mov dword ptr ds:[GADoutTDLP],1
mov eax,ecx
mov bx,offset GADsetupData
add eax,ebx
mov ds:[GADsetupDataBuf],eax
mov eax,ecx
mov bx,offset GADin0Data
add eax,ebx
mov ds:[GADin0DataBuf],eax
mov eax,ecx
mov bx,offset GADin1Data
add eax,ebx
mov ds:[GADin1DataBuf],eax
mov eax,ecx
mov bx,offset GADin2Data
add eax,ebx
mov ds:[GADin2DataBuf],eax
mov eax,ecx
mov bx,offset GADoutData
add eax,ebx
mov ds:[GADoutDataBuf],eax

mov cl,cs:[USBportCnt]
movzx cx,cl
mov bx,offset USBport
SetUSBCMD:
push cx
push bx
mov dx,cs:[bx]
mov ax,6
out dx,ax

add dx,2
mov ax,3fh
out dx,ax

add dx,2
mov ax,0fh
out dx,ax

add dx,2
mov ax,0
out dx,ax

add dx,2
xor eax,eax
mov ax,5000h
shl eax,4
or eax,2
out dx,eax

sub dx,8
mov ax,1
out dx,ax

pop bx
add bx,4
pop cx
dec cx
cmp cx,0
jnz SetUSBCMD
ret
InitDesc endp



CodeSeg ends
end start