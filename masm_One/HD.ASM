.model huge
.386p
.stack
.data
ALIGN 16
diskCsecperclu db 0 ;0dh
diskCres dw 0       ;0eh--0fh
diskCfatnum db 0    ;10h
diskChid dd 0       ;1ch
diskCsectot dd 0    ;20h
diskCsecnumperfat dd 0  ;24h
diskCfirclunum DD 0    ;2ch
diskCstonum dw 0    ;32h
ALIGN 16
diskDsecperclu db 0 ;0dh
diskDres dw 0       ;0eh--0fh
diskDfatnum db 0    ;10h
diskDhid dd 0       ;1ch
diskDsectot dd 0    ;20h
diskDsecnumperfat dd 0  ;24h
diskDfirclunum  DD  0  ;2ch
diskDstonum dw 0    ;32h
ALIGN 16
diskEsecperclu db 0 ;0dh
diskEres dw 0       ;0eh--0fh
diskEfatnum db 0    ;10h
diskEhid dd 0       ;1ch
diskEsectot dd 0    ;20h
diskEsecnumperfat dd 0  ;24h
diskEfirclunum  DD  0  ;2ch
diskEstonum dw 0    ;32h
ALIGN 16
diskFsecperclu db 0 ;0dh
diskFres dw 0       ;0eh--0fh
diskFfatnum db 0    ;10h
diskFhid dd 0       ;1ch
diskFsectot dd 0    ;20h
diskFsecnumperfat dd 0  ;24h
diskFfirclunum  DD   0 ;2ch
diskFstonum dw 0    ;32h 
ALIGN 16
diskGsecperclu db 0 ;0dh
diskGres dw 0       ;0eh--0fh
diskGfatnum db 0    ;10h
diskGhid dd 0       ;1ch
diskGsectOt dd 0    ;20h
diskGsecnumperfat dd 0  ;24h
diskGfirclunum  DD  0  ;2ch
diskGstonum dw 0    ;32h   
align 16
db 22 dup (0)
align 16
db 22 dup (0)
align 16
db 22 dup (0)
align 16
db 22 dup (0)

ALIGN 16
EXTPRT1SECNUM DD 0
extprt2secnum dd 0
extprt3secnum dd 0
extprt4secnum dd 0
EXTPRT5SECNUM DD 0
extprt6secnum dd 0
extprt7secnum dd 0
extprt8secnum dd 0

diskCsecnum dd 0
diskDsecnum dd 0
diskEsecnum dd 0
diskFsecnum dd 0
diskGsecnum dd 0
diskhsecnum dd 0
diskisecnum dd 0
diskjsecnum dd 0
diskksecnum dd 0

MBRbase db 200h dup (0)
DISKCbpb db 200h dup (0)
extprt1EBR db 200h dup (0)
DISKDBPB db 200h dup (0)
DISKBPBinter dW 00h
disksecnumINTER dd 0
disknum dd 0
baseport dw 0
destsector dd 0
sectornum dw 0
extprtsecacc dd 0
diskinfo db 'fileinfo.DAT',00

.code
START:
mov ax,@data
mov ds,ax
mov es,ax

port170:
mov word ptr es:[baseport],170h

NEXT0:
cld
mov dword ptr es:[destsector],0
mov word ptr es:[sectornum],1
mov di,offset mbrbase
call readsector
mov si,offset mbrbase
add si,1beh
add si,4
lodsb
cmp al,7
jz notfat32_0

mov eax,dword ptr es:[mbrbase+1beh+8]
mov es:[destsector],eax
mov es:[diskcsecnum],eax
mov word ptr es:[sectornum],1
mov di,offset diskdbpb
call readsector
mov si,offset diskDbpb
add si,0dh
mov di,offset diskCsecperclu
lodsb
stosb
lodsw
stosw
lodsb
stosb
mov si,offset diskdBPB
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
inc dword ptr es:[disknum]


notfat32_0:
mov si,offset mbrbase
add si,1beh
add si,14h
lodsb
cmp al,7
jnz fat32prtext1

JMP tolastextprtebr

fat32prtext1:
mov si,offset mbrbase
add si,1beh
add si,18h
lodsd
mov es:[extprt1secnum],eax
mov es:[extprtsecacc],eax
PUSH DWORD PTR ES:[EXTPRT1SECNUM]

nextextprtEBR:
mov dword ptr es:[destsector],eax
mov word ptr es:[sectornum],1
mov di,offset extprt1EBR
call readsector

mov si,offset extprt1ebr
add si,1beh
add si,8
lodsd
POP EBX
ADD EAX,EBX
MOV EBX,ES:[disksecnuminter]
MOV DWORD PTR ES:[DISKDSECNUM+BX],EAX

mov dword ptr es:[destsector],eax
mov word ptr es:[sectornum],1
mov di,offset diskDbpb
call readsector

mov si,offset diskDbpb
add si,0dh
mov di,offset diskDsecperclu
ADD DI,ES:[DISKBPBINTER]
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
inc dword ptr es:[disknum]
ADD WORD PTR ES:[DISKBPBINTER],32
add Dword ptr es:[disksecnuminter],4

mov si,offset diskdbpb
add si,1feh
lodsw
cmp ax,0aa55h
jnz tolastextprtebr

mov si,offset extprt1ebr
add si,1beh
add si,18h
lodsd
add eax,es:[extprtsecacc]
mov es:[extprtsecacc],eax
MOV EBX,ES:[disksecnuminter]
MOV es:[extprt1secnum+BX],EAX
PUSH EAX
JMP NEXTEXTPRTEBR



tolastextprtebr:
MOV si,offset MBRBASE
add si,1beh
add si,28h
lodsd
MOV EBX,ES:[disksecnuminter]
MOV es:[extprt1secnum+BX],EAX
MOV es:[diskdsecnum+BX],EAX

mov dword ptr es:[destsector],eax
mov di,offset diskDBPB
mov word ptr es:[sectornum],1
call readsector

mov si,offset diskDBPB
add si,0dh
mov di,offset diskDsecperclu
ADD DI,ES:[DISKBPBINTER]
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
inc dword ptr es:[disknum]


MOV AX,3C00H
MOV DX,OFFSET DISKinfo
INT 21H
MOV BX,AX
MOV AX,4000H
MOV CX,OFFSET MBRBASE
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




get_hd_port proc near
mov eax,80000008h
toget_device:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
shr eax,16
cmp eax,0101h
jz find_device
pop eax
add eax,100h
cmp eax,80ffff08h
jbe toget_device
no_device:
mov ah,9
mov dx,offset msg_nodevice
int 21h
jmp quit
find_device:
pop eax
and eax,0ffffff00h
push eax
add eax,40h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and eax,80008000h
sub eax,80008000h
jz legacy_port
pop eax
add eax,10h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and eax,0fffeh
mov ds:[hd_base_port],ax
legacy_port:
pop eax
mov dx,177h
mov al,20h
out dx,al
mov cx,0ffffh
waitbuf_full:
dec cx
cmp cx,0
jnz waitfuf_full
in al,dx
cmp al,58h
jnz port_1f0h
mov dx,376h
mov al,0ch
out dx,al
mov al,2
out dx,al
mov word ptr ds:[hd_base_port],170h
ret
port_1f0h:
mov dx,3f6h
mov al,0ch
out dx,al
mov al,2
out dx,al
mov word ptr ds:[hd_base_port],1f0h
ret
get_hd_port endp

END START
