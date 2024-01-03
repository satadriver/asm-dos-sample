.386p
stack segment stack
db 1000h dup (0)
stack ends

data segment para use16
prdtable dq 20h dup (0)
gdt0 dq  0
gdt1 dq 000098000000ffffh
gdt2 dq 004098000000ffffh
gdt3 dq 004092000000ffffh  ;es
gdt4 dq 00cf92060000ffffh  ;wav data
gdt5 dq 00cf92400000ffffh  ;gs
gdt6 dq 004092800000ffffh  ;stack
gdt7 dq 000092000000ffffh
gdtlenth=$-gdt0

prdaddr dd 0
gdtlimit dw 3fh ;gdtlenth-1
gdtbase dd 0

wavname db 'f:\asm\wavefile\shut.wav',0
handle dw 0
highpage dw 0
lowpage dw 0
volume dw 480h
slot0 dw  09800h
slot4321 dt 0      
slot8765 dt 0
slotcba9 dt 0
esiPos dd 0
ediPos dd 0
leftchannel dw 0
rightchannel dw 0
wavdataseg dw  6000h
destdata dd 400000h
sspointer dd 0
num dw 0
wavheader db 100h dup (0)
data ends




code1 segment para use16
assume cs:code1
db 0eah
dw 0
dw 10h
todos:
mov ax,38h
mov ds,ax
mov es,ax
mov ss,ax
mov fs,ax
mov gs,ax
mov eax,cr0
and al,0
mov cr0,eax
jmp far ptr dos
code1 ends


code2 segment para use32
assume cs:code2
mov ax,18h
mov es,ax
mov ax,20h
mov ds,ax
mov ax,28h
mov gs,ax
mov ax,30h
mov ss,ax
mov sp,8000h

mov dword ptr es:[esipos],0
circle:
mov ecx,3
push ecx
call ac97
mov dx,0fa16h
waitfree:
in ax,dx
test al,4
jz waitfree
pop ecx
loop circle

topm16:
db 0eah
dw offset todos
dw 0
dw 8

ac97 proc near
mov ecx,24000
mov dword ptr es:[edipos],0
copytoslot:
push ecx
mov esi,es:[esipos]
lodsw
mov es:[leftchannel],ax
lodsw
mov es:[rightchannel],ax
mov es:[esipos],esi
mov edi,offset slot4321
add edi,8
mov ax,es:[rightchannel]
stosw
mov edi,offset slot4321
add edi,4
xor eax,eax
mov ax,es:[rightchannel]
shl eax,12
stosd

mov esi,offset slot0
mov edi,es:[edipos]
mov cx,8
copy:
mov eax,es:[esi]
mov gs:[edi],eax
add esi,4
add edi,4
loop copy

mov es:[edipos],edi
pop ecx
dec ecx
cmp ecx,0
jz toplay
jmp  near ptr copytoslot

toplay:
call codecplay
ret
ac97 endp

codecplay proc near
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
mov al,11
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
codecplay endp
code2 ends





code0 segment para use16
assume cs:code0
start:

call init
l00:
in al,60h
cmp al,1
jnz l00
call readfile
l11:
in al,60h
cmp al,39h
jnz l11
mov ax,ss
shl eax,16
mov ax,sp
mov dword ptr es:[sspointer],eax
cli
lgdt qword ptr es:[gdtlimit]
mov al,2
out 92h,al
mov eax,cr0
or al,1
mov cr0,eax
db 0eah
dw 0
dw 8
dos:
mov ax,data
mov ds,ax
mov es,ax
lss sp,dword ptr es:[sspointer]
mov ah,4ch
int 21h


init proc near
xor eax,eax
mov ax,data
mov ds,ax
mov es,ax
shl eax,4
push eax
xor ebx,ebx
mov bx,offset prdtable
add eax,ebx
mov es:[prdaddr],eax
pop eax
xor ebx,ebx
mov bx,offset gdt0
add eax,ebx
mov es:[gdtbase],eax

xor eax,eax
mov ax,code1
shl eax,4
mov word ptr es:[gdt1+2],ax
shr eax,16
mov byte ptr es:[gdt1+4],al
mov byte ptr es:[gdt1+7],ah
xor eax,eax
mov ax,code2
shl eax,4
mov word ptr es:[gdt2+2],ax
shr eax,16
mov byte ptr es:[gdt2+4],al
mov byte ptr es:[gdt2+7],ah
cld
mov di,offset prdtable
mov cx,12
mov eax,ds:[destdata]
fillPRD:
push eax
stosd
cmp cx,0
jz endfill
mov eax,0000fa00h
stosd
jmp next00
endfill:
mov eax,8000fa00h  
stosd
next00:
pop eax
add eax,0fa00h
loop fillPRD

mov ax,3d00h
mov dx,offset wavname
int 21h
jc goquit
mov es:[handle],ax
mov bx,ax
mov ax,4202h
mov cx,0
mov dx,0
int 21h
mov es:[highpage],dx
mov es:[lowpage],ax
mov ax,4200h
mov bx,es:[handle]
mov cx,0
mov dx,0
int 21h
mov ax,3f00h
mov bx,es:[handle]
mov cx,3ah
mov dx,offset wavheader
int 21h
mov cx,es:[lowpage]
sub cx,3ah
mov es:[lowpage],cx
mov cx,es:[highpage]
sbb cx,0
mov es:[highpage],cx
ret
goquit:
call quit
init endp






readfile proc near
mov ax,es:[wavdataseg]
mov ds,ax
mov word ptr es:[num],0
nextblock:
mov ax,es:[highpage]
cmp ax,0
jnz block
mov ax,es:[lowpage]
cmp ax,0
jz toquit
mov ax,3f00h
mov bx,es:[handle]
mov cx,es:[lowpage]
mov dx,0
int 21h
mov word ptr es:[lowpage],0
jmp toret

block:
mov ax,3f00h
mov bx,es:[handle]
mov cx,0ffffh
mov dx,0
int 21h
mov ax,3f00h
mov bx,es:[handle]
mov cx,1
mov dx,0ffffh
int 21h
mov cx,es:[highpage]
dec cx
mov es:[highpage],cx
inc word ptr es:[num]
mov ax,es:[num]
cmp ax,1
jz toret
mov ax,ds
add ax,1000h
mov ds,ax

jmp nextblock

toret:
mov ax,3e00h
mov bx,es:[handle]
int 21h
ret
toquit:
call quit
readfile endp




quit proc near
mov ah,4ch
int 21h
quit endp

code0 ends
end start
