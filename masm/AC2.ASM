.386p
stack segment stack
db 100h dup (0)
stack ends
 
data segment para use16
prdtable dq 4 dup (0)
prdaddr dd 0
slot0 dw  09800h
slot4321 dt 0      
slot8765 dt 0
slotcba9 dt 0
handle dw 0
highpart dw 0
lowpart dw 0
sipos dw 0
dipos dw 0
leftchannel dw 0
rightchannel dw 0
loadbuffer dw 2000h
wavdataseg dw 5000h
wavheader db 2ch dup (0)
headersize dw 2ch
volume dw 480h
wavname db 'f:\asm\wavefile\shut.wav',0
data ends



code segment para  use16
assume cs:code
start:
call init
circle:
call readfile
mov word ptr es:[sipos],0
mov word ptr es:[dipos],0
mov cx,2
read:
push cx
call ac97
call waitempty
pop cx
loop read
jmp circle




init proc near
xor eax,eax
mov ebx,eax
mov ax,data
mov ds,ax
mov es,ax
shl eax,4
mov bx,offset prdtable
add eax,ebx
mov es:[prdaddr],eax
cld
mov di,offset prdtable
mov cx,4
xor eax,eax
mov ax,es:[wavdataseg]
shl eax,4
fillPRD:
push eax
stosd
cmp ecx,0
jz endfill
mov eax,0000fa00h
stosd
jmp next00
endfill:
mov eax,8000fa00h  
stosd
next00:
pop eax
add eax,10000h
loop fillPRD
mov word ptr es:[wavdataseg],5000h

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
mov es:[highpart],dx
mov es:[lowpart],ax
mov ax,4200h
mov bx,es:[handle]
mov cx,0
mov dx,0
int 21h
mov ax,3f00h
mov bx,es:[handle]
mov cx,es:[headersize]
mov dx,offset wavheader
int 21h
mov cx,es:[lowpart]
sub cx,ax
mov es:[lowpart],cx
mov cx,es:[highpart]
sbb cx,0
mov es:[highpart],cx
ret
init endp





readfile proc near
mov ax,es:[loadbuffer]
mov ds,ax
mov ax,es:[highpart]
cmp ax,0
jnz block
mov ax,es:[lowpart]
cmp ax,0
jz toquit
detail:
mov ax,3f00h
mov bx,es:[handle]
mov cx,es:[lowpart]
mov dx,0
int 21h
mov word ptr es:[lowpart],0
jmp endfile
block:
mov ax,3f00h
mov bx,es:[handle]
mov cx,0fa00h
mov dx,0
int 21h
mov cx,es:[lowpart]
sub cx,ax
mov es:[lowpart],cx
mov cx,es:[highpart]
sbb cx,0
mov es:[highpart],cx
endfile:
ret
toquit:
call quit
readfile endp




ac97 proc near
mov ax,es:[wavdataseg]
mov gs,ax
mov cx,4
cld
fillnextseg:
push cx
mov cx,2000  
copytoslot:
push cx
mov si,es:[sipos]
lodsw
mov es:[leftchannel],ax
lodsw
mov es:[rightchannel],ax
mov es:[sipos],si
mov ax,es:[leftchannel]
mov di,offset slot4321
add di,8
stosw
mov di,offset slot4321
add di,4
xor eax,eax
mov ax,es:[rightchannel]
shl eax,12
stosd

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
jz codecplay
jmp near ptr fillnextseg
codecplay:
mov dx,0fa2ch
mov eax,2
out dx,eax
mov dx,0fa1bh
mov al,2
out dx,al
mov dx,0fa10h
mov eax,es:[prdaddr]
out dx,eax
mov dx,0fa15h
mov al,3
out dx,al
mov dx,0f002h
mov ax,es:[volume]
out dx,ax
mov dx,0f006h
out dx,ax
mov dx,0f008h
out dx,ax
mov dx,0f018h
out dx,ax
mov dx,0fa1bh
mov al,1
out dx,al
ret
ac97 endp





quit proc near
mov ax,3e00h
mov bx,es:[handle]
int 21h
mov ah,4ch
int 21h
quit endp




waitempty proc near
waitbufferfree:
mov dx,0fa16h
in ax,dx
test al,4
jz waitbufferfree
out dx,ax
ret
waitempty endp
code ends
end start