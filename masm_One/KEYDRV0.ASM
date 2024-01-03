.386
keyboard segment para use16
assume cs:keyboard

KeyIntProc:
getscancode proc near
pushad
push ds
push es
push fs
push gs
mov ax,cs
mov ds,ax
mov ax,40h
mov es,ax
mov ax,0b800h
mov fs,ax

mov si,offset scancode
getcode:
in al,64h
test al,1
jz endgetcode
in al,60h
mov ds:[si],al
inc si
jmp getcode
endgetcode:
call singlecode
jmp endintrrupt
getscancode endp



singlecode proc near
cmp byte ptr ds:[scancode],1
jnz notmakeESC
CALL makeESC
ret 
notmakeESC:
cmp byte ptr ds:[scancode],0eh
jnz notmakebackspace
call makebackspace
ret
notmakebackspace:
cmp byte ptr ds:[scancode],0fh
jnz notmakeTAB
call maketab
ret
notmakeTAB:
cmp byte ptr ds:[scancode],1ch
jnz notmakeENTER
CALL makeENTER
ret 
notmakeENTER:
cmp byte ptr ds:[scancode],1dh
jnz notmakeCTRL
or byte ptr es:[17h],4
ret
notmakeCTRL:
cmp byte ptr ds:[scancode],02ah
jnz checkMAKEshiftright
or byte ptr es:[17h],2
RET
checkMAKEshiftright:
cmp byte ptr ds:[scancode],036h
jnz notmakeshiftright
or byte ptr es:[17h],1
ret
notmakeSHIFTright:
cmp byte ptr ds:[scancode],37h
jnz notmakeprintscreen
call makeprintscreen
ret
notmakeprintscreen:
cmp byte ptr ds:[scancode],38h
jnz notmakeALT
OR byte ptr es:[17h],8
ret
notmakeALT:
cmp byte ptr ds:[scancode],3ah
jnz notmakecapslock
call makecapslock
ret
notmakecapslock:
cmp byte ptr ds:[scancode],46h
jnz notmakescrolllock
call makescrolllock
ret
notmakescrolllock:
cmp byte ptr ds:[scancode],45h
jnz notmakenumslock
call makenumslOck
ret
notmakenumslock:
cmp byte ptr ds:[scancode],0b6h
jnz CHECKbreakshiftLEFT
AND BYTE PTR ES:[17H],0FEH
RET
CHECKBREAKSHIFTLEFT:
cmp byte ptr ds:[scancode],0aah
jnz notbreakshift
and byte ptr es:[17h],0fDh
ret
notbreakshift:
cmp byte ptr ds:[scancode],9dh
jnz notbreakCTRL
AND byte ptr es:[17h],0FBH
ret
notbreakCTRL:
cmp byte ptr ds:[scancode],0b8h
jnz notbreakALT
AND byte ptr es:[17h],0F7h
ret
notbreakALT:
cmp byte ptr ds:[scancode],3bh
jae checkfunction
call makenormal
ret
checkfunction:
cmp byte ptr ds:[scancode],44h
ja makeKP
call makefunc
ret
makeKP:
test byte ptr es:[17h],20h
jz smallkbd
call makenormal 
ret
smallkbd:
cmp byte ptr ds:[scancode],52h
jnz notmakeinsert
call makeinsert
ret
notmakeinsert:
cmp byte ptr ds:[scancode],47h
jnz notmakeHOME
CALL MAKEHOME
RET
notmakeHOME:
CMP byte PTR ds:[scancode],4fh
jnz notmakeEND
call makeEND
RET
notmakeEND:
CMP byte PTR ds:[scancode],49h
jnz notmakePAGEUP
call makePAGEUP
RET
notmakepageup:
CMP byte PTR ds:[scancode],51h
jnz notmakePAGEDOWN
call makePAGEDOWN
RET
notmakePAGEDOWN:
CMP byte PTR ds:[scancode],48h
jnz notmakeARROWUP
call makeARROWUP
RET
notmakeARROWUP:
CMP byte PTR ds:[scancode],4Bh
jnz notmakeARROWLEFT
call makEARROWLEFT
RET
notmakeARROWLEFT:
CMP byte PTR ds:[scancode],50h
jnz notmakeARROWDOWN
call makeARROWDOWN
RET
notmakeARROWDOWN:
CMP byte PTR ds:[scancode],4Dh
jnz notmakeARROWRIGHT
call makeARROWRIGHT
RET
notmakeARROWRIGHT:
cmp byte ptr ds:[scancode],53h
jz makedeletekey
jmp notmakedeletekey
makedeletekey:
test byte ptr es:[17h],4
jz notpressctrl_alt
test byte ptr es:[17h],8
jz notpressctrl_alt
call reset
ret
notpressctrl_alt:
call makedelete
ret
notmakedeletekey:
ret 
singlecode endp


endintrrupt proc near
;call setcursor
;cmp word ptr es:[1ch],3eh
;jnz KeyPtrNext
;mov word ptr es:[1ah],1eh
;mov word ptr es:[1ch],1eh
;jmp toendintret
;KeyPtrNext:
;mov ax,word ptr es:[1ch]
;mov word ptr es:[1ah],ax
;toendintret:
mov al,20h
out 20h,al
pop gs
pop fs
pop es
pop ds
popad
iret
endintrrupt endp


makenormal proc near
cmp byte ptr ds:[scancode],80h
jb notanybreak
ret
notanybreak:
test byte ptr es:[17h],20h
jnz checkisbig45h
jmp notnumslocks
checkisbig45h:
cmp byte ptr ds:[scancode],45h
jae shiftkey
notnumslocks:
test byte ptr es:[17h],40h
jnz keycapslock
test byte ptr es:[17h],1
jnz SHIFTKEY
test byte ptr es:[17h],2
jnz SHIFTKEY
normalmakekey:
mov bx,offset scancodenormal
jmp translate
KEYCAPSLOCK:
cmp BYTE PTR ds:[scancode],10h
jae nextcheck0
jmp normalmakekey
nextcheck0:
cmp BYTE PTR ds:[scancode],19h
jbe shiftkey
cmp BYTE PTR ds:[scancode],1eh
jae nextcheck1
jmp normalmakekey
nextcheck1:
cmp BYTE PTR ds:[scancode],26h
jbe shiftkey
CMP byte ptr ds:[scancode],2ch
jae nextcheck2
jmp normalmakekey
nextcheck2:
cmp byte ptr ds:[scancode],32h
jbe shiftkey
jmp normalmakekey
SHIFTKEY:
mov bx,offset scancodeshift
translate:
mov al,byte ptr ds:[scancode]
xlat
mov ah,byte ptr ds:[scancode]
mov di,word ptr es:[1ah]


add di,2
cmp di,3ch
jbe NotEnd
mov di,1eh
NotEnd:
mov word ptr es:[1ah],di
mov es:[di],ax
add di,2
mov word ptr es:[1ch],di


mov ah,7
mov ds:[currentkey],ax
test byte ptr es:[17h],80h
jnz insertmode
;call notinsertmode
;jmp makenormalret

insertmode:
mov di,ds:[screenpos]
mov fs:[di],ax
makenormalret:
add word ptr ds:[currentpos],2
add word ptr ds:[screenpos],2
ret
makenormal endp


notinsertmode proc near
mov ax,ds:[screenpos]
push ax
mov dx,0
mov bx,160
div bx
sub bx,dx
pop ax
add ax,bx
sub ax,4
mov di,ax
movedata:
cmp di,ds:[screenpos]
jb toendfile
mov ax,fs:[di]
mov fs:[di+2],ax
sub di,2
jmp movedata
toendfile:
mov di,ds:[screenpos]
mov ax,ds:[currentkey]
mov fs:[di],ax
ret
notinsertmode endp




setcursor proc near
mov ax,ds:[screenpos]
shr ax,1
xchg ah,al
push ax
mov dx,3d4h
mov al,0fh
out dx,ax
mov dx,3d4h
pop ax
xchg ah,al
mov al,0eh
out dx,ax
ret
setcursor endp

setled proc near
call waitin
mov al,0edh
out 60h,al
call waitout
in al,60h
cmp al,0fah
jnz setled
call waitin
mov al,ds:[ledflag]
out 60h,al
call waitout                  ;here u get return byte 0fah,but why can't read it out ??????
ret
setled endp

waitout proc near
in al,64h
test al,1
jz waitout
ret
waitout endp

waitin proc near
in al,64h
test al,2
jnz waitin
ret
waitin endp


makeESC proc near
;in al,64h
;test al,1
;jz MAKEESC
;in al,60h
mov ax,0
mov es,ax
mov di,9
shl di,2
mov ax,ds:[oldintIP]
stosw
mov ax,ds:[oldintCS]
stosw
ret
makeESC endp



makepause proc near
;mov ah,9
;mov dx,offset makepausemsg
;int 21h
ret
makepause endp

makeinsert proc near
test byte ptr es:[17h],80h
jnz resetinsert
or byte ptr es:[17h],80h
ret
resetinsert:
and byte ptr es:[17h],7fh
ret
makeinsert endp


makedelete proc near
mov ax,ds:[screenpos]
push ax
mov bx,160
mov dx,0
div bx
sub bx,dx
pop cx
add cx,bx
mov di,ds:[screenpos]
movedataforward:
cmp di,cx
jz makedeleteret
add di,2
mov ax,fs:[di]
mov fs:[di-2],ax
jmp movedataforward
sub word ptr ds:[currentpos],2
makedeleteret:
ret
makedelete endp


makehome proc near
mov ax,ds:[screenpos]
mov dx,0
mov bx,160
div bx
sub word ptr ds:[screenpos],dx
ret
makehome endp


makeend proc near
mov ax,ds:[screenpos]
mov dx,0
mov bx,160
div bx
sub bx,dx
add bx,ds:[screenpos]
CHECKISALPHA:
sub bx,2
cmp fs:[bx],720h
jnz tomakeendret
jmp checkISALPHA
tomakeENDret:
mov ds:[screenpos],bx
ret
makeend endp


makepageup proc near
sub word ptr ds:[screenpos],3200
sub word ptr ds:[pagepos],3200
mov ah,byte ptr ds:[pagepos]
mov al,0dh
mov dx,3d4h
out dx,ax
mov dx,3d4h
mov al,0ch
mov ah,byte ptr ds:[pagepos+1]
out dx,ax
ret
makePAGEUP endp



makePAGEDOWN proc near
add word ptr ds:[pagepos],3200
add word ptr ds:[screenpos],3200
mov ah,byte ptr ds:[pagepos]
mov al,0dh
mov dx,3d4h
out dx,ax
mov dx,3d4h
mov al,0ch
mov ah,byte ptr ds:[pagepos+1]
out dx,ax
ret
makePAGEDOWN endp



makeARROWLEFT proc near
sub word ptr ds:[screenpos],2
ret
makeARROWLEFT endp



makeARROWRIGHT proc near
add word ptr ds:[screenpos],2
ret
makeARROWRIGHT endp



makeARROWUP proc near
cmp word ptr ds:[screenpos],160
jBe ARROWUP_ret
cmp word ptr ds:[screenpos],7ffh
jbe lineup160
sub word ptr ds:[screenpos],160
sub word ptr ds:[pagepos],160
mov ah,byte ptr ds:[pagepos]
mov al,0dh
mov dx,3d4h
out dx,ax
mov dx,3d4h
mov al,0ch
mov ah,byte ptr ds:[pagepos+1]
out dx,ax
jmp arrowup_ret
lineup160:
sub word ptr ds:[screenpos],160
arrowup_ret:
ret
makeARROWUP endp



makeARROWDOWN proc near
cmp word ptr ds:[screenpos],7FFH
JBE LINEDOWN160
add word ptr ds:[pagepos],160
add word ptr ds:[screenpos],160
mov ah,byte ptr ds:[pagepos]
mov al,0dh
mov dx,3d4h
out dx,ax
mov dx,3d4h
mov al,0ch
mov ah,byte ptr ds:[pagepos+1]
out dx,ax
jmp arrowdown_ret
LINEDOWN160:
add word ptr ds:[screenpos],160
ARROWdown_RET:
ret
makeARROWDOWN endp


MAKEprintscreen proc near
;mov ah,9
;mov dx,offset makeprintscreenmsg
;int 21h
ret
makeprintscreen endp

MAKEbaCkspace proc near
sub word ptr ds:[screenpos],2
mov di,word ptr ds:[screenpos]
mov word ptr fs:[di],720h
ret
makebackspace endp


maketab proc near
add word ptr ds:[screenpos],16
ret
maketab endp


makeENTER proc near
mov ax,ds:[screenpos]
mov dx,0
mov bx,160
div bx
sub bx,dx
add word ptr ds:[screenpos],bx
ret
makeENTER endp


makescrolllock proc near
test byte ptr es:[17h],10h
jnz resetscroll
or byte ptr es:[17h],10h
or byte ptr ds:[ledflag],1
call setled
jmp MAKESCROLLRET
resetscroll:
and byte ptr es:[17h],0efh
and byte ptr ds:[ledflag],0feh
call setled
MAKESCROLLRET:
ret
makescrolllock endp

makenumslock proc near
test byte ptr es:[17h],20h
jnz resetnums
or byte ptr es:[17h],20h
or byte ptr ds:[ledflag],2
call setled
jmp MAKENUMSret
resetnums:
and byte ptr es:[17h],0dfh
and byte ptr ds:[ledflag],0fdh
call setled
MAKENUMSRET:
ret
makenumslock endp

makecapslock proc near
test byte ptr es:[17h],40h
jnz resetcaps
or byte ptr es:[17h],40h
or byte ptr ds:[ledflag],4
call setled
jmp MAKECAPSRET
resetcaps:
and byte ptr es:[17h],0bfh
and byte ptr ds:[ledflag],0fbh
call setled
MAKECAPSRET:
ret
makecapslock endp


makefunc proc near
;mov ah,9
;mov dx,offset makefuncmsg
;int 21h
ret
makefunc endp




reset proc near
mov ax,3
int 10h
mov ax,900h
mov dx,offset msg
int 21h
input:
in al,64h
test al,1
jz input
in al,60h
cmp al,2
jz shut
cmp al,3
jz restart
cmp al,4
jz gowindows
cmp al,5
jz goback
jmp input
shut:
mov dx,0cf8h
mov eax,8000f840h ;LPC bus NO.0,DEV NO.31,FUNC NO.0,BASE ADDRESS 40H
out dx,eax
mov dx,0cfch
in eax,dx
and al,0feh      ;BIT=1 rePRESENT THE ADDRESS IS REGISTER,OTHERWISE IS MEMORY
mov dx,ax
push dx
add dx,30h ;base reg +30h
in ax,dx
and ax,0ffefh
out dx,ax
pop dx
add dx,5  ;base reg+5
in al,dx
or al,3ch
out dx,al
restart:
mov dx,0cf9h
mov al,4
out dx,al
gowindows:
call makeesc
mov al,20h
out 20h,al
int 19h

goback:
in al,64h
test al,1
jz gobackret
in al,60h
jmp goback
gobackret:
ret

reset endp




scancode    dq 0
codenumber  db 0
kbdseg      dw 5000h
screenpos   dw 0
currentpos  DW 0
currentkey  DW 0
pagepos     dw 0
LEDflag     db 0
oldintip    dw 0
oldintCS    DW 0
cursorlow   dw 0
cursorhight dw 0
flag        db 0




scancodenormal  db 0,1bh,31h,32h,33h,34h,35h,36h,37h,38h,39h,30h,'-','=',8,9,'q'
                db 'w','e','r','t','y','u','i','o','p','[',']',0dh,0,'a','s','d'
                db 'f','g','h','j','k','l',';',"'",'`',0,'\','z','x','c','v','b'
                db 'n','m', ',' , '.', '/', 0, 0, 0,' ',0,0,0,0,0,0,0
                db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                db 0,0,0
scancodeshift   db 0,1bh,'!@#$%^&*()_+',8,9,'Q'
                db 'WERTYUIOP{}',0,0,'ASD'
                DB 'FGHJKL:"~',0,'|ZXCVB'
                DB 'NM<>?',0,0,0,' ',0,0,0,0,0,0,0
                DB 0,0,0,0,0,0,'789-456+1230.'

msg             db 'Select the number U want to do:',0ah,0dh
                db '1:Shut     down computer',0ah,0dh
                db '2:Restart  computer',0ah,0dh
                db '3:Go   	   to Windows',0ah,0dh
                db '4:Go       back',0ah,0dh,24h 

makeprintscreenMSG    db 'Do you really want to save this screen into a TXT file?',0ah,0dh,24h
makepausemsg          db 'U have had make a pause key!',0ah,0dh,24h
makefuncmsg           db 'U have had make a function key!',0ah,0dh,24h
kbdlen dw $




start:
cli
cld
mov ax,keyboard 
mov ds,ax
mov ax,0
mov es,ax
mov di,9
shl di,2
MOV ax,es:[di]
mov ds:[oldintIP],ax
mov ax,offset KeyIntProc
stosw
mov ax,es:[di]
mov ds:[oldintCS],AX
mov ax,seg KeyIntProc
stosw

sti
mov ax,3100h
mov dx,offset Start
add dx,0fh
shr dx,4
add dx,10h
int 21h

KeyBoard ends
end start