.model large
.386p
.stack
.data
ALIGN 16
diskCsecperclu db 0 ;0dh
diskCres dw 0       ;0eh--0fh
diskCfatnum db 0    ;10h
diskChid dd 0       ;1ch
diskCsectol dd 0    ;20h
diskCsecnumperfat dd 0  ;24h
diskCfirclunum DD 0    ;2ch
diskCstonum dw 0    ;32h
ALIGN 16
diskDsecperclu db 0 ;0dh
diskDres dw 0       ;0eh--0fh
diskDfatnum db 0    ;10h
diskDhid dd 0       ;1ch
diskDsectol dd 0    ;20h
diskDsecnumperfat dd 0  ;24h
diskDfirclunum  DD  0  ;2ch
diskDstonum dw 0    ;32h
ALIGN 16
diskEsecperclu db 0 ;0dh
diskEres dw 0       ;0eh--0fh
diskEfatnum db 0    ;10h
diskEhid dd 0       ;1ch
diskEsectol dd 0    ;20h
diskEsecnumperfat dd 0  ;24h
diskEfirclunum  DD  0  ;2ch
diskEstonum dw 0    ;32h
ALIGN 16
diskFsecperclu db 0 ;0dh
diskFres dw 0       ;0eh--0fh
diskFfatnum db 0    ;10h
diskFhid dd 0       ;1ch
diskFsectol dd 0    ;20h
diskFsecnumperfat dd 0  ;24h
diskFfirclunum  DD   0 ;2ch
diskFstonum dw 0    ;32h 

 ALIGN 16
diskGsecperclu db 0 ;0dh
diskGres dw 0       ;0eh--0fh
diskGfatnum db 0    ;10h
diskGhid dd 0       ;1ch
diskGsectOl dd 0    ;20h
diskGsecnumperfat dd 0  ;24h
diskGfirclunum  DD  0  ;2ch
diskGstonum dw 0    ;32h   


ALIGN 16
EXTPRT1SECNUM DD 0
extprt2secnum dd 0
extprt3secnum dd 0
extprt4secnum dd 0
extprt5secnum dd 0

diskCsecnum dd 0
diskDsecnum dd 0
diskEsecnum dd 0
diskFsecnum dd 0
diskGsecnum dd 0
diskHsecnum dd 0

MBRdata db 200h dup (0)
diskcbpb DB 200H DUP (0)
extprt1DBR db 200h dup (0)
DISKDBPB db 200h dup (0)
extprt2DBR db 200h dup (0)
diskEBPB db 200h dup (0)
extprt3DBR DB 200H DUP (0)
DISKFBPB DB 200H DUP (0)
extprt4DBR DB 200H DUP (0)
DISKGBPB DB 200H DUP (0)
extprt5DBR db 200h dup (0)
diskHBPB db 200h dup (0)

baseport dw 0
destsector dd 0
sectornum dw 0
diskinfo db 'fileinfo.DAT0',00
diskinfo1 db 'fileinfo.DAT1',00
.code
start:

cli
MOV AX,@DATA
MOV DS,AX
MOV ES,AX
mov dx,1f7h
mov al,0a0h
out dx,al
mov cx,100h
loop $
in al,dx
test al,1
jnz port1f0
mov word ptr es:[baseport],170h
jmp next0
port1f0:
mov word ptr es:[baseport],1f0h



next0:
mov dword ptr es:[destsector],0
mov word ptr es:[sectornum],1
mov di,offset MBRdata
call readsector

mov si,offset MBRdata
add si,1beh
ADD SI,4
lodsb
cmp al,7
jz diskCnotfat32
dec si
add si,4
lodsd
mov es:[diskCsecnum],eax
mov dword ptr es:[destsector],EAX
mov word ptr es:[sectornum],1
mov di,offset diskCbpb
call readsector
mov si,offset diskCBPB
add si,0dh
mov di,offset diskCsecperclu
lodsb
stosb
lodsw
stosw
lodsb
stosb
mov si,offset diskCBPB
add si,1ch
lodsd
stosd
lodsd
stosd
lodsd
stosd
mov si,offset diskCBPB
add si,2ch
lodsd
stosd
mov si,offset diskCBPB
add si,32h
lodsw
stosw


DISKCNOTfat32:
MOV SI,OFFSET MBRDATA
ADD SI,1BEH
add si,14h
lodsb
cmp al,7
jnz extprt1isfat32
jmp nextdisk

extprt1isfat32:
dec si
add si,4
lodsd
mov es:[extprt1secnum],eax
mov dword ptr es:[destsector],eax
mov di,offset extprt1DBR
mov word ptr es:[sectornum],1
call readsector

mov si,offset extprt1DBR
add si,1beh
add si,8
lodsd
add eax,es:[extprt1secnum]
mov es:[diskDsecnum],eax

mov dword ptr es:[destsector],eax
mov di,offset diskDBPB
mov word ptr es:[sectornum],1
call readsector
mov si,offset diskDBPB
add si,0dh
mov di,offset diskDsecperclu
lodsb
stosb
lodsw
stosw
lodsb
stosb
mov si,offset diskDBPB
add si,1ch
lodsd
stosd
lodsd
stosd
lodsd
stosd
mov si,offset diskDBPB
add si,2ch
lodsd
stosd
mov si,offset diskDBPB
add si,32h
lodsw
stosw

mov si,offset extprt1DBR
add si,1beh
add si,18h
lodsd
add eax,es:[extprt1secnum]
mov es:[extprt2secnum],eax

mov dword ptr es:[destsector],eax
mov di,offset extprt2DBR
mov word ptr es:[sectornum],1
call readsector

mov si,offset extprt2DBR
add si,1beh
add si,8
lodsd
add eax,es:[extprt2secnum]
mov es:[diskEsecnum],eax
mov dword ptr es:[destsector],eax
mov di,offset diskEBPB
mov word ptr es:[sectornum],1
call readsector

mov si,offset diskEBPB
add si,0dh
mov di,offset diskEsecperclu
lodsb
stosb
lodsw
stosw
lodsb
stosb
mov si,offset diskEBPB
add si,1ch
lodsd
stosd
lodsd
stosd
lodsd
stosd
mov si,offset diskEBPB
add si,2ch
lodsd
stosd
mov si,offset diskEBPB
add si,32h
lodsw
stosw


mov si,offset extprt2DBR
add si,1beh
add si,18H
lodsd
add eax,es:[extprt2secnum]
mov es:[extprt3secnum],eax
mov dword ptr es:[destsector],eax
mov di,offset extprt3DBR
mov word ptr es:[sectornum],1
call readsector

mov si,offset extprt3DBR
add si,1beh
add si,8
lodsd
add eax,es:[extprt3secnum]
mov es:[diskFsecnum],eax
mov dword ptr es:[destsector],eax
mov di,offset diskFBPB
mov word ptr es:[sectornum],1
call readsector
mov si,offset diskFBPB
add si,0dh
mov di,offset diskFsecperclu
lodsb
stosb
lodsw
stosw
lodsb
stosb
mov si,offset diskFBPB
add si,1ch
lodsd
stosd
lodsd
stosd
lodsd
stosd
mov si,offset diskFBPB
add si,2ch
lodsd
stosd
mov si,offset diskFBPB
add si,32h
lodsw
stosw

nextdisk:
MOV si,offset MBRdata
add si,1beh
add si,28h
lodsd
mov es:[DISKGSECNUM],eax
mov dword ptr es:[destsector],eax
mov di,offset diskGBPB
mov word ptr es:[sectornum],1
call readsector
mov si,offset diskGBPB
add si,0dh
mov di,offset diskGsecperclu
lodsb
stosb
lodsw
stosw
lodsb
stosb
mov si,offset diskGBPB
add si,1ch
lodsd
stosd
lodsd
stosd
lodsd
stosd
mov si,offset diskGBPB
add si,2ch
lodsd
stosd
mov si,offset diskGBPB
add si,32h
lodsw
stosw

MOV AX,3C00H
MOV DX,OFFSET DISKinfo1
INT 21H
MOV BX,AX
MOV AX,4000H
MOV CX,OFFSET MBRDATA
MOV DX,OFFSET extprt1secnum
int 21h
mov ax,3e00h
int 21h
MOV AX,3C00H
MOV DX,OFFSET DISKinfo
INT 21H
MOV BX,AX
MOV AX,4000H
MOV CX,OFFSET MBRDATA
MOV DX,OFFSET DISKCsecperclu
int 21h
mov ax,3e00h
int 21h
sti
MOV AH,4CH
INT 21H

readsector proc near
mov dx,es:[baseport]
add dx,5
mov al,0
out dx,al
dec dx
out dx,al
dec dx
mov eax,es:[destsector]
rol eax,8
out dx,al
add dx,2
rol eax,8
out dx,al
dec dx
rol eax,8
out dx,al
dec dx
rol eax,8
out dx,al
mov dx,es:[baseport]
add dx,2
mov ax,es:[sectornum]
xchg ah,al
out dx,al
xchg ah,al
out dx,al
mov dx,es:[baseport]
add dx,7
mov al,29h
out dx,al
mov ax,es:[sectornum]
movzx eax,ax
mov ebx,100h
mul ebx
mov ecx,eax
mov dx,es:[baseport]
add dx,7
waitfree:
in al,dx
cmp al,58h
jnz waitfree
mov dx,es:[baseport]
rep insw
ret
readsector endp


writesector proc near
mov dx,es:[baseport]+5
mov al,0
out dx,al
dec dx
out dx,al
dec dx
mov eax,es:[destsector]
rol eax,8
out dx,al
add dx,2
rol eax,8
out dx,al
dec dx
rol eax,8
out dx,al
dec dx
rol eax,8
out dx,al
mov dx,es:[baseport]+2
mov ax,es:[sectornum]
xchg ah,al
out dx,al
xchg ah,al
out dx,al
mov dx,es:[baseport]+7
mov al,39h
out dx,al
mov ax,es:[sectornum]
movzx eax,ax
mov ebx,100h
mul ebx
mov ecx,eax
mov dx,es:[baseport]+7
waitfree1:
in al,dx
cmp al,58h
jnz waitfree1
mov dx,es:[baseport]
rep outsw
ret
writesector endp
END START