.386p
stack segment stack
db 100h dup (0)
stack ends

data segment para use16
gdt0 dq 0
gdt1 dq 000098000000ffffh
gdt2 dq 004098000000ffffh
gdt3 dq 004092000000ffffh
gdt4 dq 00cf92000000ffffh
gdt5 dq 10cf92000000ffffh
gdt6 dq 00cf92000000ffffh
gdt7 dq 004092800000ffffh
gdt8 dq 000092000000ffffh
gdtend=$-gdt0
gdtlimit dw gdtend-1
gdtbase dd 0


angry    	      db 'f:\cattom\angry001.bmp',0    ;240x360x32bit bitmap
blink           db 'f:\cattom\blink001.bmp',0
cymbal          db 'f:\cattom\cymbal01.bmp',0
drink           db 'f:\cattom\drink001.bmp',0
eat             db 'f:\cattom\eat00001.bmp',0
fart            db 'f:\cattom\fart0001.bmp',0
footle          db 'f:\cattom\footle01.bmp',0
footri          db 'f:\cattom\footri01.bmp',0
happy           db 'f:\cattom\happy001.bmp',0
knock           db 'f:\cattom\knock001.bmp',0
listen          db 'f:\cattom\listen01.bmp',0
pie             db 'f:\cattom\pie00001.bmp',0
scratc          db 'f:\cattom\scratc01.bmp',0
simple          db 'f:\cattom\simple01.bmp',0
sneeze          db 'f:\cattom\sneeze01.bmp',0
stomac          db 'f:\cattom\stomac01.bmp',0
talk            db 'f:\cattom\talk0001.bmp',0
zeh             db 'f:\cattom\zeh00001.bmp',0

angrynum     	  dd 26
blinknum        dd 3
cymbalnum       dd 13
drinknum        dd 81
eatnum          dd 40 
fartnum         dd 28
footlenum       dd 30
footrinum       dd 30
happynum        dd 29
knocknum        dd 81
listennum       dd 12
pienum          dd 23
scractnum       dd 56
simplenum       dd 25
sneezenum       dd 14
stomacnum       dd 34
talknum         dd 16
zehnum          dd 31

bmpnumoffset    dd 0
bmpnameoffset   dd 0
bmpnamenum      dd 0
bmpnamelen      dd 0
bmpfilenum 	  dd 0
totalbmpnum     dd 0
counter         dd 0

videoscanline    dd 2560
bmpscanline      dd 0

key              dd 0
backgroundflag   dd 0
endflag    	    dd 0
stackptr   	    dd 0
esipos     	    dd 0
edipos     	    dd 0
RMdataseg  	    dd 5000h

videoreserved    dd 8000000h
start_showaddr   dd 0
bkgrdbmphead     db 36h dup (0)
bmphead    	   db 36h  dup (0)
vesainfo     	   db 100h dup (0)
handle     	   dd 0
bkgrdbmpname     db 'f:\asm\bm\30.bmp',0
msgnotachar      db 'Input a character from a~r',0ah,0dh,24h
msgprogress      db 'Initiating,please wait......',0ah,0dh
transmitted      dw 3030h
                 db '/18 is completed......',0ah,0dh,24h
msgnotfound	    db 'not found file,please reinput...',0ah,0dh,24h
data ends

code segment para use16
assume cs:code
start:
main proc near
mov ax,3
int 10h
call init
toread:
sti
call readdata
getinPMmode:
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
mov ax,data
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[stackptr]
call calcpercent
mov ax,word ptr ds:[bmpnamenum]
shl ax,2
cmp word ptr ds:[bmpnumoffset],ax
jb toread
cli
mov al,37h
out 43h,al
mov al,0
out 40h,al
out 40h,al
mov ax,4f02h
mov bx,3
int 10h
mov ah,4ch
int 21h



getkey:
mov ax,data
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[stackptr]
sti
mov ax,3
int 10h
mov ah,9
mov dx,offset msgnotachar
int 21h
mov ah,0
int 16h
cmp al,61h
jb notachar
cmp al,72H
JA NOTACHAR
mov BYTE PTR ds:[key],al
call setvideomode
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
dw OFFset to32bitPMMODE
dw 8
NOTACHAR:
MOV AH,9
MOV DX,OFFSET MSGNOTACHAR
INT 21H
JMP GETKEY
main endp


init proc near
xor eax,eax
mov ax,data
mov ds,ax
mov es,ax
shl eax,4
push eax
mov word ptr ds:[gdt3+2],ax
shr eax,16
mov byte ptr ds:[gdt3+4],al
pop eax
xor ebx,ebx
mov bx,offset gdt0
add eax,ebx
mov ds:[gdtbase],eax

call readbmphead
mov eax,dword ptr ds:[bmphead+12h]
shl eax,2                             ;32bit bitmap
mov ds:[bmpscanline],eax

xor eax,eax
mov ax,word ptr ds:[rmDATAseg]
shl eax,4
mov word ptr ds:[gdt4+2],ax
shr eax,16
mov byte ptr ds:[gdt4+4],al

xor eax,eax
mov ax,code1
shl eax,4
mov word ptr ds:[gdt1+2],ax
shr eax,16
mov byte ptr ds:[gdt1+4],al

xor eax,eax
mov ax,code2
shl eax,4
mov word ptr ds:[gdt2+2],ax
shr eax,16
mov byte ptr ds:[gdt2+4],al

mov ax,4f01h
mov di,offset vesaINFO
mov cx,101h
int 10h
mov eax,dword ptr es:[vesainfo+28h]
mov word ptr ds:[gdt6+2],ax
shr eax,16
mov byte ptr ds:[gdt6+4],al
mov byte ptr ds:[gdt6+7],ah

mov ax,offset blink
sub ax,offset angry
mov word ptr ds:[bmpnamelen],ax


mov ax,offset bmpnumoffset 
mov bx,offset angrynum
sub ax,bx
shr ax,2
mov word ptr ds:[bmpnamenum],ax


mov si,offset angrynum
mov ebx,0
mov cx,word ptr ds:[bmpnamenum]
calctotal:
lodsd
add ebx,eax
loop calcTOTAL
MOV word ptr ds:[totalbmpnum],bx
ret
init endp




setvideomode proc near
mov ax,4f02h
mov bx,112h
int 10h             ;640x480x32bit video mode
mov ax,4f06h
mov bx,1
int 10h
mov word ptr ds:[videoscanline],bx  ;bx=bytes/perline,cx=pixel nums/perline
mov eax,480
sub eax,dword ptr ds:[bmphead+16h]
mov ebx,ds:[videoscanline]
mul ebx
sub ebx,ds:[bmpscanline]
shr ebx,1
add eax,ebx
mov ds:[start_showaddr],eax
ret
setvideomode endp


readbmphead proc near
mov ax,3d00h
mov dx,offset angry
int 21h
mov bx,ax
push bx
mov ax,3f00h
mov cx,36h
mov dx,offset bmphead
int 21h
mov ax,3e00h
pop bx
int 21h
ret
readbmphead endp



readdata proc near
mov ax,3d00h
mov dx,offset angry
add dx,word ptr ds:[bmpnameoffset]
int 21h
jnc foundfile
call notfound
foundfile:
mov bx,ax
mov word ptr ds:[handle],ax
mov ax,4200h
mov cx,word ptr ds:[bmphead+0ah+2]
mov dx,word ptr ds:[bmphead+0ah]
int 21h
mov ax,WORD PTR es:[RMdataSEG]
mov ds,ax
mov ax,word ptr es:[bmphead+0ah+2]
cmp ax,word ptr es:[bmphead+22h+2]
jnz readblock
readdetail:
mov ax,3f00h
mov bx,word ptr es:[handle]
mov cx,word ptr es:[bmphead+22h]
mov dx,0
int 21h
mov dword ptr es:[endflag],0ffh
mov di,offset angry
add di,word ptr es:[bmpnameoffset]
add di,16                        ;last 2 letters is ASCII 1---9
mov ax,es:[di] 
cmp ah,39h
jz decimal
inc ah
jmp retrieve
decimal:
inc al
mov ah,30h 
retrieve:
mov es:[di],ax
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
inc word ptr es:[bmphead+0ah+2]
readdata_ret:
mov ax,3e00h
mov bx,word ptr es:[handle]
int 21h
ret
readdata endp


notfound proc near
mov ah,9
mov dx,offset msgnotfound
int 21h
mov ah,4ch
int 21h
ret
notfound endp


calcpercent proc near
push word ptr ds:[bmpnumoffset]
pop word ptr ds:[transmitted]
mov ax,ds:[transmitted]
shr ax,2
push ax
daa
pop cx
shr cx,4
cmp cx,0
jz below10h

dec cx
adddecimal:
add ax,6
daa
loop adddecimal


below10h:
mov bx,ax
shr ax,4
and bx,0fh
mov ah,bl
add ax,3030h
mov ds:[transmitted],ax
mov ah,9
mov dx,offset msgprogress
int 21h
ret
calcpercent endp

code ends



code1 segment para use16
assume cs:code1
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
shr cx,2
copyBYTE:
mov eax,ds:[esi]
mov es:[edi],eax
add esi,4
add edi,4
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

mov dword ptr fs:[endflag],0
mov word ptr fs:[bmphead+0ah+2],0
inc dword ptr fs:[bmpfilenum]
mov eax,dword ptr fs:[bmpfilenum]
mov ebx,fs:[bmpnumoffset]
add bx,offset angrynum
cmp eax,dword ptr fs:[ebx]
jz nextvideo
jmp todosmode


NEXTVIDEO:
mov dword ptr fs:[bmpfilenum],0
ADD dword PTR fs:[bmpnumoffset],4

mov eax,dword ptr fs:[bmpnameoffset]
add eax,dword ptr fs:[bmpnamelen]
mov dword ptr fs:[bmpnameoffset],eax

mov eax,fs:[bmpnamenum]
shl eax,2
cmp dword ptr fs:[bmpnumoffset],eax
jae togetkey       
jmp todosmode


togetkey:
mov ax,40h
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax,cr0
and al,0feh
mov cr0,eax
jmp far ptr getkey

to32bitPMmode:
db 0eah
dw 0
dw 10h
code1 ends




code2 segment para use32
assume cs:code2
mov ax,18h
mov fs,ax
mov gs,ax
mov ax,28h
mov ds,ax
mov ax,30h
mov es,ax
mov ax,38h
mov ss,ax
mov esp,1000h
cld
call store_covered
call settimer

reshow:
mov dword ptr fs:[counter],0
mov ecx,dword ptr fs:[key]
sub ecx,61h
push ecx

shl ecx,2
add ecx,offset angrynum
mov eax,fs:[ecx]
mov fs:[bmpfilenum],eax

mov ebx,0
mov esi,offset angrynum
pop ecx
cmp ecx,0
jnz calc_addr
mov esi,0
jmp showvideo

calc_addr:
mov eax,fs:[esi]
add ebx,eax
add esi,4
;loop calc_addr
dec ecx
cmp ecx,0
jnz calc_addr

;sub ebx,eax
mov eax,dword ptr fs:[bmphead+22h]
mul ebx
mov esi,eax

showvideo:
push esi
mov edi,fs:[start_showaddr]
mov ebp,fs:[videoreserved]
mov ecx,dword ptr fs:[bmphead+16h]
show:
push ecx
push edi
mov ecx,dword ptr fs:[bmphead+12h]
stickup:
lodsd
cmp eax,0ffffffh
jnz notwhite
and eax,es:[ebp]
notwhite:
stosd
add ebp,4
loop stickup
pop edi
add edi,fs:[videoscanline]
pop ecx
loop show

mov cx,0
waittime:
mov al,0
out 43h,al
in al,40h
shl ax,8
in al,40h
xchg ah,al
cmp ax,0
jnz waittime
inc cx
cmp cx,70
jnz waittime

pop esi
add esi,dword ptr fs:[bmphead+22h]
inc dword ptr fs:[counter]
mov eax,dword ptr fs:[counter]
cmp eax,fs:[bmpfilenum]
jb nextpic
db 0eah
dw offset getscancode
dw 0
dw 10h

nextpic:
db 0eah
dw offset showvideo
dw 0
dw 10h


getscancode:
in al,64h
test al,1
jz GETSCANCODE
in al,60h
CMP AL,1
JNZ NOTESC
db 0eah
dw offset to16bit
dw 0
dw 10h
NOTESC:
cmp al,1eh
jnz nota
mov dword ptr fs:[key],61h
db 0eah
dw offset reshow
dw 0
dw 10h
nota:
cmp al,30h
jnz notb
mov dword ptr fs:[key],62h
db 0eah
dw offset reshow
dw 0
dw 10h

notb:
cmp al,2eh
jnz notc
mov dword ptr fs:[key],63h
db 0eah
dw offset reshow
dw 0
dw 10h
notc:
cmp al,20h
jnz notd
mov dword ptr fs:[key],64h
db 0eah
dw offset reshow
dw 0
dw 10h
notd:
cmp al,12h
jnz note
mov dword ptr fs:[key],65h
db 0eah
dw offset reshow
dw 0
dw 10h
note:
cmp al,21h
jnz notf
mov dword ptr fs:[key],66h
db 0eah
dw offset reshow
dw 0
dw 10h
notf:
cmp al,22h
jnz notg
mov dword ptr fs:[key],67h
db 0eah
dw offset reshow
dw 0
dw 10h
notg:
cmp al,23h
jnz noth
mov dword ptr fs:[key],68h
db 0eah
dw offset reshow
dw 0
dw 10h
noth:
cmp al,17h
jnz noti
mov dword ptr fs:[key],69h
db 0eah
dw offset reshow
dw 0
dw 10h
noti:
cmp al,24h
jnz notj
mov dword ptr fs:[key],6ah
db 0eah
dw offset reshow
dw 0
dw 10h
notj:
cmp al,25h
jnz notk
mov dword ptr fs:[key],6bh
db 0eah
dw offset reshow
dw 0
dw 10h
notk:
cmp al,26h
jnz notl
mov dword ptr fs:[key],6ch
db 0eah
dw offset reshow
dw 0
dw 10h
notl:
cmp al,32h
jnz notm
mov dword ptr fs:[key],6dh
db 0eah
dw offset reshow
dw 0
dw 10h
notm:
cmp al,31h
jnz notn
mov dword ptr fs:[key],6eh
db 0eah 
dw offset reshow
dw 0
dw 10h
notn:
cmp al,18h
jnz noto
mov dword ptr fs:[key],6fh
db 0eah
dw offset reshow
dw 0
dw 10h
noto:
cmp al,19h
jnz notp
mov dword ptr fs:[key],70h
db 0eah
dw offset notp
dw 0
dw 10h

notp:
cmp al,10h
jnz notq
mov dword ptr fs:[key],71h
db 0eah
dw offset reshow
dw 0
dw 10h
notq:
cmp al,13h
jnz notr
mov dword ptr fs:[key],72h
db 0eah
dw offset reshow
dw 0
dw 10h
notr:
db 0eah
dw offset getscancode
dw 0
dw 10h

to16bit:
db 0eah
dw offset todosmode
dw 0
dw 8


settimer proc near
mov al,37h
out 43h,al
mov ax,1193
out 40h,al
xchg ah,al
out 40h,al
ret
settimer endp


store_covered proc near
push ds
mov ax,30h
mov ds,ax
mov esi,fs:[start_showaddr]
mov edi,fs:[videoreserved]
mov ecx,dword ptr fs:[bmphead+16h]
reserve:
push ecx
push esi
mov ecx,dword ptr fs:[bmphead+12h]
rep movsd
pop esi
add esi,fs:[videoscanline]
pop ecx
loop reserve
pop ds
ret
store_covered  endp

code2 ends


end start









