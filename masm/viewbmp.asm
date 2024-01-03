.386p
stack segment stack
db 400h dup (0)
stack ends

pmstack segment para use16
db 400h dup (0)
pmstack ends

data segment para use16
bmpnamelen db 20h
bmpnameactuallen db 0
bmpname db 20h dup (0)
filehandle dw 0
bmpheader db 36h dup (0)
bmpcolortable db 400h dup (0)
lowpageremain dw 0
highpagereamin dw 0
filepointer dd 0
dsbaseseg dw 6000h

gdtlimit dw gdtlen-1
gdtbase dd 0
stackpointer dd 0
message0 db 'this program will show BMP file,press ESC to quit,press any key to continue...',0ah,0dh,24h
message1 db 'input BMP file name here:',24h
message2 db 'not support BMP mode,press any key to quit....',24h
vesaheader db 100h dup (0)
data ends

gdtseg segment para use16
org 0
gdt0 dq 0
gdt1 dq 000098000000ffffh  ;code1 base
gdt2 dq 004098000000ffffh  ;code2 base
gdt3 dq 004098000000ffffh
gdt4 dq 004098000000ffffh
gdt5 dq 004092060000ffffh
gdt6 dq 004092070000ffffh
gdt7 dq 004092080000ffffh
gdt8 dq 004092090000ffffh
gdt9 dq 000092000000ffffh  ;data base
gdt10 dq 00cf92000000ffffh ;integreted vedio memory address
gdt11 dq 004092000000ffffh
gdtlen=$-gdt0
gdtseg ends

code0 segment para use16
assume cs:code0
start:
call initpmmode
circle:
call getbmpname
call getbmppara

call readfile


mov di,offset stackpointer
mov ax,stack
shl eax,16
mov ax,sp
stosd
cli
lgdt qword ptr es:[gdtlimit]
out 0eeh,al
mov eax,cr0
or eax,1
mov cr0,eax
db 0eah
dw 0
dw 8
dosmode:
mov ax,3
int 10h
mov ax,data
mov ds,ax
mov es,ax
lss sp,dword ptr es:[stackpointer]
jmp circle




















initpmmode proc near
mov ax,data
mov ds,ax
mov es,ax
xor eax,eax
mov ax,gdtseg
shl eax,4
xor ebx,ebx
mov bx,offset gdt0
add eax,ebx
mov es:[gdtbase],eax


push ds
push es
mov ax,gdtseg
mov es,ax


xor eax,eax
mov ax,data
shl eax,4
mov es:[gdt9+2],ax
shr eax,16
mov es:[gdt9+4],al
xor eax,eax
mov ax,code1
shl eax,4
mov es:[gdt1+2],ax
shr eax,16
mov es:[gdt1+4],al
xor eax,eax
mov ax,code2
shl eax,4
mov es:[gdt2+2],ax
shr eax,16
mov es:[gdt2+4],al
xor eax,eax
mov ax,pmstack
shl eax,4
mov es:[gdt11+2],ax
shr eax,16
mov es:[gdt11+4],al
mov ax,4f01h
mov di,offset vesaheader
mov cx,112h
int 10h
mov si,offset vesaheader
add si,28h
lodsd
mov es:[gdt10+2],ax
shr eax,16
mov es:[gdt10+4],al
mov es:[gdt10+7],ah
pop es
pop ds
ret
initpmmode endp



getbmpname proc near
mov ax,data
mov ds,ax
mov es,ax
mov ah,9
mov dx,offset message0
int 21h
mov ah,0
int 16h
cmp al,1bh
jz toquit
mov ah,9
mov dx,offset message1
int 21h


mov ah,0ah
mov dx,offset bmpnamelen
int 21h
ret
toquit:
mov ah,4ch
int 21h
getbmpname endp


getbmppara proc near
mov ax,3d00h
mov dx,offset bmpname 
int 21h
mov es:[filehandle],ax
mov bx,ax
mov ax,3f00h
mov cx,36h
mov dx,offset bmpheader
int 21h
mov si,offset bmpheader
add si,22h
lodsd
mov di,offset lowpageremain
stosd
mov si,offset bmpheader
add si,1ch
lodsw
cmp ax,8
jz getcolor
call 
mov ax,3f00h
mov cx,400h
mov dx,offset bmpcolortable
int 21h
cld
mov si,offset bmpcolortable
mov cx,100h
mov ax,0
setcolor:
push ax
mov dx,3c8h
out dx,al
inc dx     ;为什么不用MOV DX，3C9H？？
add si,2
lodsb
shr al,2
out dx,al
sub si,2
lodsb
shr al,2
out dx,al
sub si,2
lodsb
shr al,2
out dx,al
add si,3
pop ax
inc ax
loop setcolor
mov ax,3e00h
mov bx,es:[filehandle]
int 21h
mov di,offset bmpname
mov al,0
mov cx,20h
cld
rep stosb
ret
getbmppara endp





readfile proc near
mov ax,bmpbaseseg
mov ds,ax
mov ax,4202h
mov bx,es:[filehandle]
mov cx,es:[highpageremain]
mov dx,es:[lowpageremain]
int 21h
mov ax,es:[highpageremain]
cmp ax,0
jz readdetail
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
mov bx,es:[highpageremain]
dec bx
mov es:[highpageremain],bx
mov eax,es:[filepointer]
add eax,10000h
mov es:[filepointer],eax
mov ax,ds
add ax,1000h
cmp ax,0a000h
jz toreturn
mov ds,ax
jmp readfile
readdetail:
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
ret
readfile endp

code1 segment para use16
assume cs:code1
db 0eah
dw 0
dw 10h
returndos:
mov ax,48h
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,cr0
and al,0
mov cr0,eax
jmp far ptr dosmode
code1 ends

setvediomode proc near


mov ax,es:[bmpheader+1ch]
cmp al,8
jz color256
cmp al,24
jz color24b
cmp al,32
jz color24b
call undesiredformat
color8:
mov es:[vesaheader+12h]
lodsd
push eax
cmp ax,1024
jz weight1024
cmp ax,800
jz weight800
cmp ax,640
jz weight640
call undesiredformat
weight1024:
mov ax,4f02h
mov bx,107h
int 10h
mov ax,4f06h
mov bx,0
pop ecx
int 10h


weight800:
mov ax,4f02h
mov bx,105h
int 10h
mov ax,4f06h
mov bx,0
pop ecx
int 10h

weight640:
mov ax,4f02h
mov bx,101h
int 10h
mov ax,4f06h
mov bx,0
pop ecx
int 10h
jmp 


code2 segment para use32
assume cs:code2



undesiredformat proc near
mov ah,9
mov dx,offset message2
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h
ret
undesiredformat endp
