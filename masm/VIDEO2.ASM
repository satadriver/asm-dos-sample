.386p
BmpDataSeg segment para use16
dd 4000h dup (0)
BmpDataSeg ends


Param segment para use16
NullSelector            dq 0
PmCode16Selector        dq 000098000000ffffh
PmCode32Selector        dq 004098000000ffffh
ParamSelector           dq 00cf92000000ffffh  ;Data 
BmpDataSelector         dq 00cf92000000ffffh  ;BmpDataSeg
BmpBufSelector          dq 00cf92800000ffffh  ;Buf
VesaSelector            dq 00cf92000000ffffh  ;VesaBase
Stack32Selecotor        dq 004092400000ffffh  ;Stack?? A20 is Enabled??????
Rm16Selector            dq 000092000000ffffh
gdtend                  =$-NullSelector
gdtlimit                dw gdtend-1
gdtbase                 dd 0

bmpname    	        db 'Drink001.bmp',0    ;240x360x32bit bitmap
bmpnum     	        dd 0
bmpfilenum 	        dd 81
handle     	        dd 0
bmphead    	        db 36h  dup (0)

videoscanline 	     	dd 2560
bmpscanline   	     	dd 960
vesainfo     	     	db 100h dup (0)
endflag    	        dd 0
stackptr   	        dd 0
edipos     	        dd 0
RmBmpDataseg  	        dw 0
ShowBase               	dd 0
NotFound 	        db 'Not Found File',24h
msgStart		db "Hi,I'm Tom,How Are U?",24h
Param ends



RmCode16 segment para use16
assume cs:RmCode16
start:


Main proc near
call init

toread:
call readdata
mov ax,ss
shl eax,16
mov ax,sp
mov dword ptr es:[stackptr],eax
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
dosmode:
mov ax,Param
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[stackptr]
cmp dword ptr ds:[EndFlag],1
jnz ToRead
jmp Quit
Main endp



init proc near
xor eax,eax
mov ax,Param
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
shl eax,4
mov ds:[gdtbase],eax
mov word ptr ds:[ParamSelector+2],ax
shr eax,16
mov byte ptr ds:[ParamSelector+4],al

xor eax,eax
mov ax,BmpDataSeg
mov word ptr ds:[RmBmpDataSeg],ax
shl eax,4
mov word ptr ds:[BmpDataSelector+2],ax
shr eax,16
mov byte ptr ds:[BmpDataSelector+4],al

xor eax,eax
mov ax,PmCode16
shl eax,4
mov word ptr ds:[PmCode16Selector+2],ax
shr eax,16
mov byte ptr ds:[PmCode16Selector+4],al

xor eax,eax
mov ax,PmCode32
shl eax,4
mov word ptr ds:[PmCode32Selector+2],ax
shr eax,16
mov byte ptr ds:[PmCode32Selector+4],al

mov ax,4f01h
mov di,offset VesaINFO
mov cx,112h
int 10h
mov eax,dword ptr es:[vesainfo+28h]
mov word ptr ds:[VesaSelector+2],ax
shr eax,16
mov byte ptr ds:[VesaSelector+4],al
mov byte ptr ds:[VesaSelector+7],ah

call readbmphead
call SetVesaMode
ret
Align 10h
init endp





SetVesaMode proc near
mov ax,4f02h
mov bx,112h
int 10h             ;640x480x32bit video mode
mov ax,4f06h
mov bx,0
mov cx,640
int 10h
mov ax,4f06h
mov bx,1
int 10h
mov word ptr ds:[videoscanline],bx  ;bx=bytes/perline,cx=pixel nums/perline
;mov ah,9
;mov dx,offset msgStart
;int 21h

mov eax,480
sub eax,dword ptr ds:[bmphead+16h]
mov ebx,ds:[videoscanline]
mul ebx
sub ebx,ds:[bmpscanline]
shr ebx,1
add eax,ebx
mov ds:[ShowBase],eax
ret
setvesamode endp



readbmphead proc near
mov ax,3d00h
mov dx,offset bmpname
int 21h
jc Quit
mov bx,ax
mov ax,3f00h
mov cx,36h
mov dx,offset bmphead
int 21h
mov ax,3e00h
int 21h
ret
readbmphead endp



readdata proc near
mov ax,3d00h
mov dx,offset bmpname
int 21h
jnc FoundFile
Quit:
mov ax,4f02h
mov bx,3
int 10h
mov ah,4ch
int 21h
FoundFile:
mov bx,ax
mov word ptr ds:[handle],ax
mov ax,4200h
mov cx,word ptr ds:[bmphead+0ch]
mov dx,word ptr ds:[bmphead+0ah]
int 21h
mov ax,es:[RmBmpDataSeg]
mov ds,ax
mov ax,word ptr es:[bmphead+0ch]
cmp ax,word ptr es:[bmphead+4]
jnz readblock
readdetail:
mov ax,3f00h
mov bx,word ptr es:[handle]
mov cx,word ptr es:[bmphead+22h]
mov dx,0
int 21h
mov dword ptr es:[endflag],0ffh
jmp readdata_ret
readblock:
mov ax,3f00h
mov bx,word ptr es:[handle]
mov cx,0ffffh
mov dx,0
int 21h
mov ax,3f00h
mov cx,1
mov dx,0ffffh
int 21h
inc word ptr es:[bmphead+0ch]
readdata_ret:
mov ax,3e00h
mov bx,word ptr es:[handle]
int 21h
ret
readdata endp
RmCode16 ends



PmCode16 segment para use16
assume cs:PmCode16
mov ax,18h
mov fs,ax
mov gs,ax
mov ax,20h
mov ds,ax
mov ax,28h
mov es,ax
mov ax,38h
mov ss,ax
mov esp,1000h
mov edi,fs:[edipos]
mov esi,0
cmp dword ptr fs:[endflag],0ffh
jz copydetail

mov ecx,4000h
copyblock:
mov eax,ds:[esi]
mov es:[edi],eax
add esi,4
add edi,4
loop copyblock
mov fs:[edipos],edi

todosmode:
mov ax,40h
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,cr0
and al,0feh
mov cr0,eax
jmp far ptr dosmode

copydetail:
mov cx,word ptr fs:[bmphead+22h]
movzx ecx,cx
copyBYTE:
mov al,ds:[esi]
mov es:[edi],al
inc esi
inc edi
loop copybyte
mov fs:[edipos],edi

setsequence:
mov edi,fs:[edipos]
mov esi,edi
sub esi,dword ptr fs:[bmpscanline]
sub edi,dword ptr fs:[bmphead+22h]
mov ecx,dword ptr fs:[bmphead+16h]
shr ecx,1
exchangecolumn:
push ecx
push esi
push edi
mov ecx,dword ptr fs:[bmphead+12h]
xchgline:
mov eax,es:[esi]
mov ebx,es:[edi]
xchg eax,ebx
mov es:[esi],eax
mov es:[edi],ebx
add esi,4
add edi,4
loop xchgline
pop edi
pop esi
pop ecx
sub esi,fs:[bmpscanline]
add edi,fs:[bmpscanline]
loop exchangecolumn

mov si,offset BmpName
add si,6
movzx esi,si
mov ax,word ptr fs:[esi]
cmp ah,39h
jz decimal
inc ah
jmp NextBmpName
Decimal:
inc al
mov ah,30h 
NextBmpName:
mov word ptr fs:[esi],ax

inc dword ptr fs:[bmpnum]
mov dword ptr fs:[endflag],0
mov word ptr fs:[bmphead+0ch],0

mov eax,fs:[bmpnum]
cmp eax,fs:[bmpfilenum]
jz to32bitPmMode
db 0eah
dw offset todosmode
dw 8
to32bitPMmode:
db 0eah
dw 0
dw 10h
PmCode16 ends




PmCode32 segment para use32
assume cs:PmCode32
mov ax,28h
mov ds,ax
mov ax,30h
mov es,ax

mov ecx,640*480
mov edi,0
mov eax,0ffffffffh
SetBk:
rep stosd
;inc eax
;loop SetBk

StartShow:
mov dword ptr fs:[bmpnum],0
mov esi,0

showvideo:
mov edi,fs:[ShowBase]
mov ecx,dword ptr fs:[bmphead+16h]
show:
push ecx
push edi

mov ecx,dword ptr fs:[bmphead+12h]
rep movsd

pop edi
add edi,fs:[videoscanline]
pop ecx
loop show

mov ecx,0
waittime:
mov al,0
out 43h,al
in al,40h
cmp al,0
jnz waittime
inc ecx
cmp ecx,256
jnz waittime

in al,60h
cmp al,1
jnz Next
mov dword ptr fs:[endFlag],1
db 0eah
dw offset ToDosMode
dw 0
dw 8
Next:
inc dword ptr fs:[bmpnum]
mov eax,dword ptr fs:[bmpnum]
cmp eax,fs:[bmpfilenum]
jz ToStartShow
db 0eah
dw offset showvideo
dw 0
dw 10h
ToStartShow:
db 0eah
dw offset StartShow
dw 0
dw 10h


settimer proc near
mov al,36h
out 43h,al
mov ax,0
out 40h,al
xchg ah,al
out 40h,al
ret
settimer endp

PmCode32 ends
end start