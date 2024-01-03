.386p 
stack segment stack
db 400h dup (0)
stack ends

data segment para use16
org 0
prdtable dq 4 dup (0)
wavname db 'f:\asm\wavefile\l.wav',0
handle dw 0
filepointer dd 0
highpageremain dw 0
lowpageremain dw 0
rate dw 0
volume dw 480h
slot0 dw  09800h
slot4321 dt 0      
slot8765 dt 0
slotcba9 dt 0
siPos dw 0
diPos dw 0
leftchannel dw 0
rightchannel dw 0
wavdataaddr dd 50000h
wavdataseg dd  50000h
wavheader db 2ch dup (0)
prdAddr dd 0
data ends



code segment para use16
assume cs:code
start:
mov ax,3
int 10h
mov al,36h
out 43h,al
mov al,0a9h
out 40h,al
mov al,4
out 40h,al
mov ax,data
mov ds,ax
mov es,ax
mov di,offset prdtable
mov cx,2
fillPRD:
push cx
mov eax,ds:[wavdataaddr]
stosd
add eax,10000h
mov ds:[wavdataaddr],eax
cmp cx,0
jz endfill
mov eax,0000fa00h
stosd
jmp next00
endfill:
mov eax,8000fa00h  
stosd
next00:
pop cx
loop fillPRD
xor eax,eax
xor ebx,ebx
mov ax,es
shl eax,4
mov bx,offset prdtable
add eax,ebx
mov es:[PrdAddr],eax


cld
mov ax,3d00h
mov dx,offset wavname
int 21h
mov di,offset handle
stosw
mov bx,ax
mov ax,4202h
mov cx,0
mov dx,0
int 21h
mov es:[highpageremain],dx
mov es:[lowpageremain],ax
mov ax,4200h
mov bx,es:[handle]
mov cx,0
mov dx,0
int 21h
mov ax,3f00h
mov bx,es:[handle]
mov cx,2ch
mov dx,offset wavheader
int 21h
mov ax,es:[lowpageremain]
sub ax,2ch
mov es:[lowpageremain],ax
mov ax,es:[highpageremain]
sbb ax,0
mov es:[highpageremain],ax
mov eax,es:[filepointer]
add ax,2ch
mov es:[filepointer],eax
mov si,offset wavheader
add si,18h
mov di,offset rate
lodsw
stosw

mov ax,4000h
mov ds,ax
circle:
call readfile
mov cx,48
lll:
call ac97
waittime:
mov dx,0fa16h
in ax,dx
test al,4
jz waittime
mov dx,0fa16h
mov al,4
out dx,ax
loop lll
mov ax,es:[highpageremain]
cmp ax,0
jnz circle
mov ax,es:[lowpageremain]
cmp ax,0
jz toquit
jmp circle
toquit:
call quit


readfile proc near
push ds
push es
pushad
mov ax,es:[highpageremain]
cmp ax,0
jz readdetail
mov ax,3f00h
mov bx,es:[handle]
mov cx,0fa00h
mov dx,0
int 21h
mov bx,es:[lowpageremain]
sub bx,0fa00h
mov es:[lowpageremain],bx
mov bx,es:[highpageremain]
sbb bx,0
mov es:[highpageremain],bx
mov eax,es:[filepointer]
add eax,0fa00h
mov es:[filepointer],eax
jmp toreturn
readdetail:
xor eax,eax
mov ax,3f00h
mov bx,es:[handle]
mov cx,es:[lowpageremain]
mov dx,0
int 21h
mov word ptr es:[lowpageremain],0
mov ebx,es:[filepointer]
add bx,es:[lowpageremain]
mov es:[filepointer],ebx
toreturn:
popad
pop es
pop ds
ret
readfile endp




ac97 proc near
push ds
push es
pushad
mov eax,es:[wavdataseg]
shr eax,4
mov gs,ax
mov ax,4000h
mov ds,ax
mov cx,2
fillnextseg:
push ecx
mov cx,333
copytoslot:
push cx
mov si,es:[sipos]
lodsw
mov es:[leftchannel],ax
mov es:[rightchannel],ax
mov es:[sipos],si
mov di,offset slot4321
add di,8
mov ax,es:[leftchannel]
stosw

;mov di,offset slot4321
;add di,4
;xor eax,eax
;mov ax,es:[leftchannel]
;shl eax,12
;stosd

;mov di,offset slot8765
;add di,5
;mov si,offset slot4321
;add si,5
;mov cx,5
;copychannel:
;mov al,es:[si]
;mov es:[di],al
;inc si
;inc di
;loop copychannel

;mov di,offset slot8765
;inc di
;xor eax,eax
;mov ax,es:[leftchannel]
;shl eax,16
;stosd

;mov di,offset slotcba9
;xor eax,eax
;mov ax,es:[rightchannel]
;shl eax,4
;stosd

mov si,offset slot0
mov di,es:[dipos]
mov cx,8
copy:
mov eax,es:[si]
mov gs:[di],eax
add si,4
add di,4
loop copy

mov es:[dipos],di
pop cx
dec cx
cmp cx,0
jz nextseg
jmp  near ptr copytoslot
nextseg:
mov ax,gs
add ax,1000h
mov gs,ax
mov word ptr es:[dipos],0
pop ecx
dec cx
cmp cx,0
jz toplay
jmp near ptr fillnextseg
toplay:
call codecplay
popad
pop es
pop ds
ret
ac97 endp

codecplay proc near
mov dx,0fa10h
mov eax,es:[prdaddr]
out dx,eax
mov dx,0f000h
mov ax,0
out dx,ax
mov dx,0f002h
mov ax,es:[volume]
out dx,ax
mov dx,0f006h
out dx,ax
mov dx,0f008h
out dx,ax
mov dx,0f018h
out dx,ax
mov ax,es:[rate]
mov dx,0f02ch
out dx,ax
mov dx,0f02eh
out dx,ax
mov dx,0f030h
out dx,ax
mov dx,0f032h
out dx,ax
mov dx,0f036h
out dx,ax
mov dx,0f038h
out dx,ax
mov dx,0fa1bh
mov al,1
out dx,al
ret
codecplay endp

timer proc near
push ds
push si
mov ax,40h
mov ds,ax
mov si,6ch
lodsw
add ax,1000
mov bx,ax
sub si,2
checksec:
lodsw
sub si,2
cmp ax,bx
jb checksec
pop si
pop ds
ret
timer endp

quit proc near
mov ah,4ch
int 21h
quit endp
code ends
end start
