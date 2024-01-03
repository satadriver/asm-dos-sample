.386p
stack segment stack
db 400h dup (0)
stack ends


data segment para use16
gdt0 dq 0
gdt1 dq 000098000000ffffh
gdt2 dq 004098000000ffffh
gdt3 dq 0
gdt4 dq 0
gdt5 dq 004092000000ffffh  ;data seg descriptor
gdt6 dq 00cf92400000ffffh  ;32 bit ds seg descriptor
gdt7 dq 0d0cf92000000ffffh ;integreted video memory descriptor
gdt8 dq 004092000000ffffh  ;32 bit stack
gdt9 dq 000092000000ffffh  ;normal descriptor 
GDT10 dq 0040920b8000ffffh
gdt11 dq 01cf92000000ffffh

align 16
gdtlen=$-gdt0
gdtlimit dw gdtlen-1
gdtbase  dd 0
align 16
diskcsecperclu db 0
diskcfat dd 0
diskcfdt dd 0
diskdsecperclu db 0
diskdfat dd 0
diskdfdt dd 0
diskesecperclu db 0
diskefat dd 0
diskefdt dd 0
diskfsecperclu db 0
diskffat dd 0
diskffdt dd 0
diskgsecperclu db 0
diskgfat dd 0
diskgfdt dd 0
diskdata db 200h dup (0)
fileinfo db 'f:\asm\masm1\fileinfo.dat',0
filename db 'f\lake    bmp',0
handle dw 0
stackptr dd 0
destsector dd 0
baseport dw 170h
sectornum dw 0
filefirstcluster dw 0
filemount dd 0
currentcluster dd 0
interval1 dd 0
interval2 dd 0
msgnotfound db 'NOT FOUND FILE,PRESS ANY KEY TO QUIT....$'
data ends







pm16 segment para use16
assume cs:pm16
db 0eah
dw 0
dw 10h
todosmode:
mov ax,48h
mov ds,ax
mov es,ax
mov ss,ax
mov gs,ax
mov fs,ax
mov eax,cr0
and al,0feh
mov cr0,eax
jmp far ptr dosmode
pm16 ends




readfile segment para use32
assume cs:readfile
mov ax,28h
mov ds,ax
mov ax,30h
mov es,ax
mov ax,38h
mov gs,ax
mov ax,40h
mov ss,ax
mov esp,10000h
mov ax,58h
mov fs,ax

mov si,offset filename
lodsb
cmp al,'c'
jz diskd
cmp al,'d'
jz diske
cmp al,'f'
jz diskf
cmp al,'f'
jz diskg
db 0eah
dw offset todosmode
dw 8



diskd:
mov dword ptr ds:[interval1],20h
mov dword ptr ds:[interval2],9
jmp toread
diske:
mov dword ptr ds:[interval1],40h
mov dword ptr ds:[interval2],18
jmp toread
diskf:
mov dword ptr ds:[interval1],40h
mov dword ptr ds:[interval2],27
jmp toread
diskg:
mov dword ptr ds:[interval1],20h
mov dword ptr ds:[interval2],9
jmp toread

toread:
mov esi,offset fileinfo
push dword ptr ds:[esi+0ch+interval1]
pop eax
mov ds:[sectornum],ax
push es
mov ax,58h
mov es,ax
mov edi,0
mov si,offset diskcfat
push dword ptr ds:[esi+interval2]
pop eax
call readsector
pop es
mov esi,offset diskcfdt
mov eax,ds:[esi+interval2]
mov esi,offset diskcsecperclu
mov cl,byte ptr ds:[esi+interval2]
movzx cx,cl
mov ds:[sectornum],cx
mov edi,0
call readsector
mov esi,offset diskcsecperclu
mov al,byte ptr ds:[esi+interval2]
call findfile



xor edi,edi
mov di,ds:[filefirstcluster]
mov ds:[currentcluster],edi


mov ax,ds:[filefirstcluster]
movzx eax,ax
mov bl,ds:[diskdsecperclu]
movzx ebx,bl
mov ds:[sectornum],bx
mov edi,0

nextblock:
push edi
push ebx
sub eax,2
mul ebx
mov esi,offset diskcfdt
add eax,ds:[esi+interval2]
call readsector
mov edi,ds:[currentcluster]
shl edi,2
mov eax,fs:[edi]
mov ds:[currentcluster],eax
cmp eax,0ffffffffh
jz endfile
cmp eax,0fffffff8h
jnb endfile
pop ebx
pop edi
jmp nextblock

endfile:
mov ecx,edi
shr ecx,2
mov esi,0
mov edi,0
showbmp:
mov eax,es:[esi]
mov gs:[edi],eax
add esi,4
add edi,4
loop showbmp
db 0eah
dw offset todosmode
dw 0
dw 8

searchfile proc near
mov bl,16
mul bl
mov cx,ax
movzx ecx,cx
mov edi,0
checkname:
push ecx
push edi
mov ecx,11
mov esi,offset filename
add esi,2
repz cmpsb
cmp ecx,0
jz findfile
pop edi
add edi,20h
pop ecx
loop checkname
mov ax,50h
mov es,ax
mov edi,7f0h
mov esi,offset msgnotfound
mov ah,7
showmsgnotfound:
lodsb
cmp al,24h
jz returndos
stosw
jmp showmsgnotfound
returndos:
db 0eah
dw offset todosmode
dw 0
dw 8

findfile:
pop edi
pop ecx
add edi,1ah
mov ax,word ptr es:[edi]
mov ds:[filefirstcluster],ax
add edi,2
mov eax,dword ptr es:[edi]
mov ds:[filemount],eax
ret
searchfile endp



readsector proc near
mov dx,ds:[baseport]
add dx,5
mov al,0
out dx,al
dec dx
out dx,al
dec dx
mov eax,ds:[destsector]
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
mov dx,ds:[baseport]
add dx,2
mov ax,ds:[sectornum]
xchg ah,al
out dx,al
xchg ah,al
out dx,al
mov dx,ds:[baseport]
add dx,7
mov al,29h
out dx,al
mov ax,ds:[sectornum]
movzx eax,ax
mov ebx,100h
mul ebx
mov ecx,eax
mov dx,ds:[baseport]
add dx,7
waitfree:
in al,dx
cmp al,58h
jnz waitfree
mov dx,ds:[baseport]
rep insw
ret
readsector endp
readfile ends







code segment para use16
assume cs:code
start:
call initdisk
call switchmode



initdisk proc near
xor eax,eax
mov ebx,eax
mov ax,data
mov ds,ax
mov es,ax
shl eax,4
push eax
mov word ptr ds:[gdt5+2],ax
shr eax,16
mov byte ptr ds:[gdt5+4],al
pop eax
mov bx,offset gdt0
add eax,ebx
mov ds:[gdtbase],eax

mov ax,3d00h
mov dx,offset fileinfo
int 21h
jnc next
mov ah,9
mov dx,offset msgnotfound
int 21h
mov ah,0
int 16h
call quit
next:
mov es:[handle],ax
mov bx,ax
mov ax,3f00h
mov cx,200h
mov dx,offset diskdata
int 21h

mov si,offset diskdata
mov di,offset diskcsecperclu
mov cx,5
cld
getfatfdt:
push cx
push si
lodsb     ;sectors/cluster
stosb
lodsw    ;reserved
movzx eax,ax
push eax
inc si
mov ebx,dword ptr es:[si] ;hidden sectors
add eax,ebx
stosd
dec si
lodsb ;fat number
movzx ebx,al
lodsd                     ;hidden sectors
push eax
lodsd  ;sector toltal
lodsd  ;sectors/fat
mul ebx
pop ebx
add eax,ebx
pop ebx
add eax,ebx
stosd
pop si
add si,20h
pop cx
loop getfatfdt
ret
initdisk endp








switchmode proc near
mov ax,stack
mov ss,ax
SHL eax,16
MOV AX,sp
mov dS:[STACKPTR],eax
cli
lgdt qword ptr ds:[gdtlimit]
mov al,2
out 92h,al
mov ax,4f02h
mov bx,11bh
int 10h
mov ax,4f06h
mov bx,0
mov cx,1280
int 10h
mov eax,cr0
or al,1
mov cr0,eax
db 0eah
dw 0
dw 8
dosmode:
mov ax,data
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[stackptr]
mov ax,3
int 10h
mov ah,4ch
int 21h
switchmode endp




quit proc near
mov ax,3
int 10h
mov ah,0
int 16h
mov ah,4ch
int 21h
quit endp



code ends
end start



