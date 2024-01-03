;指令 FSIN与FCOS的机器码是0fed9h与0ffd9h,masm5.0并不能汇编为正确的指令，需要直接写入机器码
.386p
stack segment stack
db 200h dup (0)
stack ends

data segment para use16
gdt0 dq 0
gdt1 dq 000098000000ffffh
gdt2 dq 004098000000ffffh
gdt3 dq 004092000000ffffh ;ds
gdt4 dq 00cf92050000ffffh ;5000h
gdt5 dq 10cf92000000ffffh ;buffer
gdt6 dq 004f92000000ffffh ;d0000000h
gdt7 dq 004092800000ffffh ;ss
gdt8 dq 000092000000ffffh ;noamal
gdtend=$-gdt0
gdtlimit dw gdtend-1
gdtbase dd 0

x1              	dd 0
y1              	dd 0
x2              	dd 512
y2              	dd 384
deltax          	dd 0
deltay          	dd 0
deltax_sign     	dd 0
deltay_sign     	dd 0
deltaxplus      	dd 0
deltaYplus      	dd 0
rato_x          	dd 0
rato_y          	dd 0
centerx         	dd 512
centery         	dd 384
dotx            	dd 0
doty            	dd 0
radius          	dd 300
angle           	dd 0
angle_new  	  	dd 0
anglemin	      	dd 0
anglehour	      	dd 0
arc             	dd 180
scanline        	dd 0  
linewidth               dd 0
seclinewidth		dd 8
minlinewidth		dd 30
hourlinewidth 		dd 35
dotradius_small 	dd 6
dotradius_big   	dd 20
hourcolor		db 1
mincolor		db 2
seccolor		db 4
color           	db 0
restoreflag     	dd 0
STOREFLAG  	        DD 0
esipos          	dd 0
edipos          	dd 0
stackptr        	dd 0
startflag       	dd 0
TRUNCATE	      	DD 0
truncateSEC	   	DD 15
TRUNCATEmin	   	dd 15
truncateHOUR	   	DD 100
currentlinebuf   	db 2000h dup (0)
currentminbuf	   	db 2000h dup (0)
currenthourbuf   	db 2000h dup (0)
vesainfo         	db 100h dup (0)
bmpname          	db 'Demo.bmp',0
handle           	dw 0
bmphead          	db 36h dup (0)
colortable       	db 400h dup (0)
endflag          	dd 0
ac97_mixer_base		dw 0
volume			dw 0
volume_para		dw 0
ac97_flag		dd 0
msg_nodevice 		db 'no device found',0ah,0dh,24h
data ends


code segment para use16
assume cs:code
start:

call init
call readbmphead
call setcolor
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
mov ax,data
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[stackptr]
cmp dword ptr ds:[endflag],0ffh
jnz toread
mov ax,4f02h
mov bx,3
int 10h
mov ah,4ch
int 21h



readbmphead proc near
mov ax,data
mov ds,ax
mov es,ax
mov ax,3d00h
mov dx,offset bmpname
int 21h
mov bx,ax
mov ds:[handle],ax
mov ax,3f00h
mov bx,ds:[handle]
mov cx,436h
mov dx,offset bmphead
int 21h
mov ax,3e00h
mov bx,ds:[handle]
int 21h
ret
readbmphead endp


setcolor proc near
mov al,0
mov dx,3c8h
out dx,al
mov dx,3c9h
mov si,offset colortable
mov cx,100h
setpalette:
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
loop setpalette
ret
setcolor endp



readdata proc near
mov ax,data
mov ds,ax
mov es,ax
mov ax,3d00h
mov dx,offset bmpname
int 21h
mov bx,ax
mov ds:[handle],ax
mov ax,4200h
mov bx,ds:[handle]
mov cx,word ptr ds:[bmphead+0ah+2]
mov dx,word ptr ds:[bmphead+0ah]
int 21h
mov ax,5000h
mov ds,ax
mov ax,word ptr es:[bmphead+0ah+2]
cmp ax,word ptr es:[bmphead+22h+2]
jnz readblock
mov dword ptr es:[endflag],0ffh
jmp readdata_ret
readblock:
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
inc word ptr es:[bmphead+0ah+2]
readdata_ret:
mov ax,3e00h
mov bx,es:[handle]
int 21h
ret
readdata endp




init proc near
mov ax,stack
mov ss,ax
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


mov ax,4f01h
mov di,offset vesaINFO
mov cx,101h
int 10h
mov eax,dword ptr es:[vesainfo+28h]
mov word ptr ds:[gdt6+2],ax
shr eax,16
mov byte ptr ds:[gdt6+4],al
mov byte ptr ds:[gdt6+7],ah

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

mov ax,4f02h
mov bx,105h
int 10h
mov ax,4f06h
mov bx,1
int 10h
mov word ptr dS:[scanline],cx

call get_ac97_mixer_base
call settimer
ret
init endp



settimer proc near
in al,61h
or al,1
out 61h,al
mov al,0b6h
out 43h,al
mov ax,1193
out 42h,al
xchg ah,al
out 42h,al
ret
settimer endp


get_ac97_mixer_base proc near
mov eax,80000008h
next_func:
push eax
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
and eax,0ffffff00h
cmp eax,04010000h
jz find_dev
pop eax
add eax,100h
cmp eax,80ffff08h
jbe next_func
no_device:
mov ah,9
mov dx,offset msg_nodevice
int 21h
mov word ptr ds:[ac97_mixer_base],0
ret
find_dev:
pop eax
and eax,0ffffff00h
add eax,10h
mov dx,0cf8h
out dx,eax
mov dx,0cfch
in eax,dx
test al,1
jz no_device
and al,0feh
mov ds:[ac97_mixer_base],ax
add ax,0ah
mov dx,ax
in ax,dx
mov ax,480h
mov ds:[volume],ax
mov dword ptr ds:[ac97_flag],1
ret
get_ac97_mixer_base endp
code ends




code1 segment para use16
assume cs:code1
mov ax,18h
mov gs,ax
mov fs,ax
mov ax,20h
mov ds,ax
mov ax,28h
mov es,ax
mov ax,38h
mov ss,ax
mov esp,1000h
cmp dword ptr fs:[endflag],0ffh
jz tobit32
mov edi,fs:[edipos]
mov esi,0
mov ecx,10000h
copydata:
mov al,ds:[esi]
mov es:[edi],al
inc esi
inc edi
dec ecx
cmp ecx,0
jnz copydata
mov fs:[edipos],edi
todos:
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
tobit32:
db 0eah
dw 0
dw 10h
code1 ends





code2 segment para use32
assume cs:code2
mov ax,28h
mov ds,ax
mov ax,30h
mov es,ax
mov esi,fs:[edipos]
sub esi,fs:[scanline]
mov edi,0
mov ecx,dword ptr fs:[bmphead+16h]
copybmp:
push ecx
push esi
mov ecx,fs:[scanline]
rep movsb
pop esi
sub esi,fs:[scanline]
pop ecx
loop copybmp


mov ax,18h
mov ds,ax
mov ax,30h
mov es,ax



drawclock proc near
mov ecx,60
drawclocKpot:
push ecx
mov si,offset angle
movzx esi,si
call near ptr getpos
mov eax,ds:[angle]
mov edx,0
mov ebx,30
div ebx
cmp edx,0
jz SETDOTbig
mov ecx,ds:[dotradius_small]
mov eax,1024
mul ecx
shr eax,1
sub edi,eax
drawclockrec_small:
push ecx
push edi
mov al,ds:[color]
mov ecx,ds:[dotradius_small]
rep stosb
pop edi
add edi,ds:[scanline]
pop ecx
loop drawclockrec_small
jmp near ptr nextclockrec 
setdotbig:
mov ecx,ds:[dotradius_big]
mov eax,1024
mul ecx
shr eax,1
sub edi,eax
drawclockRec_big:
push ecx
push edi
mov al,ds:[color]
mov ecx,ds:[dotradius_big]
rep stosb
pop edi
add edi,ds:[scanline]
pop ecx
loop drawclockREc_big
nextclockrec:
add dword ptr ds:[angle],6
pop ecx
dec ecx
cmp ecx,0
jz drawclockret
db 0eah
dw offset drawclockpot
dw 0
dw 10h
drawclockret:
nop
drawclock endp







call getsec
mov ebx,6
mul ebx
mov ebx,90
sub ebx,eax
;mov ds:[angle],ebx
mov ds:[angle_new],ebx
cmp dword ptr ds:[startflag],0
jnz drawclockend
jmp first

drawclockend:
wait_second:
call getsec
mov ebx,6
mul ebx
mov ebx,90
sub ebx,eax
cmp ebx,ds:[angle]
jz wait_second
mov dword ptr ds:[angle_new],ebx
call playsound

mov dword ptr ds:[restoreflag],1
mov si,offset angle
movzx esi,si
call getpos
push dword ptr ds:[doty]
pop dword ptr ds:[y1]
push dword ptr ds:[dotx]
pop dword ptr ds:[x1]
mov si,offset currentlinebuf
movzx esi,si
mov dword ptr ds:[esipos],esi
push dword ptr ds:[truncateSEC]
pop dword ptr ds:[truncate]

push dword ptr ds:[seclinewidth]
pop dword ptr ds:[linewidth]
call line
mov dword ptr ds:[restoreflag],0
cmp dword ptr ds:[angle],90
jz refreshclock
jmp onlysetsecond

refreshclock:
mov dword ptr ds:[restoreflag],1
mov si,offset anglemin
movzx esi,si
call getpos
push dword ptr ds:[doty]
pop dword ptr ds:[y1]
push dword ptr ds:[dotx]
pop dword ptr ds:[x1]
push dword ptr ds:[truncateMIN]
pop dword ptr ds:[truncate]
mov si,offset currentminbuf
movzx esi,si
mov dword ptr ds:[esipos],esi

push dword ptr ds:[minlinewidth]
pop dword ptr ds:[linewidth]
call line

mov si,offset anglehour
movzx esi,si
call getpos
push dword ptr ds:[doty]
pop dword ptr ds:[y1]
push dword ptr ds:[dotx]
pop dword ptr ds:[x1]
mov si,offset currenthourbuf
movzx esi,si
mov dword ptr ds:[esipos],esi
push dword ptr ds:[truncateHOUR]
pop dword ptr ds:[truncate]

push dword ptr ds:[hourlinewidth]
pop dword ptr ds:[linewidth]
call line
mov dword ptr ds:[restoreflag],0

first:
call getmin
mov ebx,6
mul ebx
mov ebx,90
sub ebx,eax
mov ds:[anglemin],ebx

mov al,0bh
out 70h,al
in al,71h
and al,0fdh
out 71h,al
call gethour
mov ebx,30
mul ebx
mov ebx,90
sub ebx,eax
mov ds:[anglehour],ebx
mov dword ptr ds:[startflag],1



mov si,offset anglemin
movzx esi,si
call getpos
push dword ptr ds:[doty]
pop dword ptr ds:[y1]
push dword ptr ds:[dotx]
pop dword ptr ds:[x1]
mov si,offset currentminbuf
movzx esi,si
mov dword ptr ds:[esipos],esi
push esi

push dword ptr ds:[truncateMIN]
Pop dword ptr ds:[truncate]
push dword ptr ds:[minlinewidth]
pop dword ptr ds:[linewidth]
mov al,ds:[mincolor]
MOV byte ptr ds:[color],al
mov dword ptr ds:[storeflag],1
call line

pop esi
mov dword ptr ds:[storeflag],0
call line

mov si,offset anglehour
movzx esi,si
call getpos
push dword ptr ds:[doty]
pop dword ptr ds:[y1]
push dword ptr ds:[dotx]
pop dword ptr ds:[x1]
mov si,offset currenthourbuf
movzx esi,si
mov dword ptr ds:[esipos],esi
push esi
push dword ptr ds:[truncateHOUR]
pop dword ptr ds:[truncate]

push dword ptr ds:[hourlinewidth]
pop dword ptr ds:[linewidth]
mov al,ds:[hourcolor]
mov byte ptr ds:[color],al
mov dword ptr ds:[storeflag],1
call line
pop esi
mov dword  ptr ds:[storeflag],0
call line

onlysetsecond:
mov dword ptr ds:[restoreflag],0
push dword ptr ds:[angle_new]
pop dword ptr ds:[angle]

mov si,offset angle
movzx esi,si
call getpos
push dword ptr ds:[doty]
pop dword ptr ds:[y1]
push dword ptr ds:[dotx]
pop dword ptr ds:[x1]
mov si,offset currentlinebuf
movzx esi,si
mov dword ptr ds:[esipos],esi
push esi
push dword ptr ds:[truncateSEC]
pop dword ptr ds:[truncate]

push dword ptr ds:[seclinewidth]
pop dword ptr ds:[linewidth]
mov dword ptr ds:[storeflag],1
mov al,ds:[seccolor]
mov byte ptr ds:[color],al
call line
pop esi
mov dword ptr ds:[storeflag],0
call line

waitesc:
in al,60h
cmp al,1
jz toback
db 0eah
dw offset drawclockend
dw 0
dw 10h
tobacK:
db 0eah
dw offset todos
dw 0
dw 8




getpos proc near
finit
fild dword ptr ds:[arc]
fild dword ptr ds:[esi]   ;esi is offset angle,or offset anglemin,or offset anglehour
fdiv st(0),st(1)
fldpi
fmul st(0),st(1)
dw 0fed9h 
fild dword ptr ds:[radius]
fmul st(0),st(1)
fild dword ptr dS:[centery]
fsub st(0),st(1)
fist dword ptr ds:[doty]
finit
fild dword ptr ds:[arc]
fild dword ptr ds:[esi]
fdiv st(0),st(1)
fldpi
fmul st(0),st(1)
dw 0ffd9h
fild dword ptr ds:[radius]
fmul st(0),st(1)
fild dword ptr ds:[centerx]
fadd st(0),st(1)
fist dword ptr ds:[dotx]
mov eax,ds:[doty]
mov ebx,ds:[scanline]
mul ebx
add eax,ds:[dotx]
mov edi,eax
retn
getpos endp


line proc near
mov ecx,ds:[linewidth]
push ecx
shr ecx,1
sub dword ptr ds:[x2],ecx
sub dword ptr ds:[y2],ecx
pop ecx

drawline:
push ecx

mov eax,dword ptr ds:[x1]
mov ebx,dword ptr ds:[x2]
sub eax,ebx
mov dword ptr ds:[deltax],eax
mov dword ptr ds:[deltax_sign],eax
mov ecx,dword ptr ds:[y1]
mov edx,dword ptr ds:[y2]
sub ecx,edx
mov dword ptr ds:[deltay],ecx
mov dword ptr ds:[deltay_sign],ecx
cmp eax,80000000h
jb notnegx
neg eax
notnegx:
mov dword ptr ds:[deltaxplus],eax
cmp ecx,80000000h
jb notnegy
neg ecx
notnegy:
mov dword ptr ds:[deltayplus],ecx
cmp eax,ecx
jle yx
jmp xy
yx:
mov ecx,dword ptr ds:[deltayplus]
sub ecx,ds:[truncate]
slopelineyx:
push ecx
finit
fild dword ptr ds:[deltay]
fild dword ptr ds:[deltax]
fdiv st(0),st(1)
fild dword ptr ds:[deltay_sign]
fmul st(0),st(1)
fistp dword ptr ds:[rato_x]
mov eax,dword ptr ds:[y1]
sub eax,dword ptr ds:[deltay_sign]
mov ebx,ds:[scanline]
mul ebx
add eax,ds:[x1]
sub eax,ds:[rato_x]
mov edi,eax
cmp dword ptr ds:[restoreflag],1
jnz notrestore
call restore
jmp nextpix
notrestore:
cmp dword ptr ds:[storeflag],1
jnz notstore
call store
jmp nextpix
notstore:
call near ptr drawpixel
nextpix:
cmp dword ptr ds:[deltay_sign],80000000h
jb plusdeltay
inc dword ptr ds:[deltay_sign]
jmp nextyx
plusdeltay:
dec dword ptr ds:[deltay_sign]
nextyx:
pop ecx
dec ecx
cmp ecx,0
jz drawnextlineYX
db 0eah
dw OFFSET SLOPELINEYX
DW 0
DW 10H
DRAWNEXTLINEyx:
pop ecx
inc dword ptr ds:[x2]
inc dword ptr ds:[y2]
dec ecx
cmp ecx,0
jz tolineret
db 0eah
dw offset drawline
dw 0
dw 10h

tolineret:
DB 0EAH
DW OFFSET LINERET
DW 0
DW 10H
xy:
mov ecx,dword ptr ds:[deltaxplus]
sub ecx,ds:[truncate]
slopelinexy:
push ecx
finit
fild dword ptr ds:[deltax]
fild dword ptr ds:[deltay]
fdiv st(0),st(1)
fild dword ptr ds:[deltax_sign]
fmul st(0),st(1)
fistp dword ptr ds:[rato_y]
mov eax,dS:[y1]
sub eax,dword ptr ds:[rato_y]
mov ebx,ds:[scanline]
mul ebx
add eax,ds:[x1]
sub eax,ds:[deltax_sign]
mov edi,eax
cmp dword ptr ds:[restoreflag],1
jnz notrestorexy
call restore
jmp nextpixXY
notrestorexy:
cmp dword ptr ds:[storeflag],1
jnz notstoreXY
call store
JMP nextpixXY
NOTSTORExy:
call near ptr drawpixel
nextpixxy:
cmp dword ptr ds:[deltax_sign],80000000h
jbe plusdeltax
inc dword ptr ds:[deltax_sign]
jmp nextxy
plusdeltax:
dec dword ptr ds:[deltax_sign]
nextxy:
pop ecx
dec ecx
cmp ecx,0
jz drawnextline
DB 0EAH
DW OFFSET slopelinexy
DW 0
DW 10H
drawnextline:
pop ecx
inc dword ptr ds:[x2]
inc dword ptr ds:[y2]
dec ecx
cmp ecx,0
jz lineret
db 0eah
dw offset drawline
dw 0
dw 10h

lineret:
push dword ptr ds:[centerx]
pop dword ptr ds:[x2]
push dword ptr ds:[centery]
pop dword ptr ds:[y2]
retn
line endp




getsec proc near
xor eax,eax
mov al,0
out 70h,al
in al,71h
push eax
shr eax,4
mov ebx,6
mul ebx
mov ebx,eax
pop eax
sub eax,ebx
ret
getsec endp

getmin proc near
xor eax,eax
mov al,2
out 70h,al
in al,71h
push eax
shr eax,4
mov ebx,6
mul ebx
mov ebx,eax
pop eax
sub eax,ebx
ret
getmin endp

gethour proc near
xor eax,eax
mov al,4
out 70h,al
in al,71h
push eax
shr eax,4
mov ebx,6
mul ebx
mov ebx,eax
pop eax
sub eax,ebx
ret
gethour endp


drawpixel proc near
mov al,ds:[color]
stosb
retn
drawpixel endp


store proc near
mov esi,ds:[esipos]
mov al,es:[edi]
mov ds:[esi],al
inc dword ptr ds:[esipos]
retn
store endp



restore proc near
mov esi,ds:[esipos]
mov al,ds:[esi]
mov es:[edi],al
inc dword ptr ds:[esipos]
retn
restore endp


playsound proc near
cmp dword ptr ds:[ac97_flag],1
jz pronounce
in al,61h
or al,3
out 61h,al
call waittime
in al,61h
and al,0fdh   ;can not disenable timer2 (bit 0=0)
out 61h,al
ret
pronounce:
mov dx,ds:[ac97_mixer_base]
add dx,2
mov ax,1fh
out dx,ax                    ; out dx,ax is wrong,why???
mov dx,ds:[ac97_mixer_base]
add dx,0ah

cmp ds:[angle],90
jnz second_beep

mov ax,4a0h
mov cx,10h
minute_beep_1:
push cx
push ax
out dx,ax
call waittime
pop ax
sub ax,20h
pop cx
dec cx
cmp cx,0
jnz minute_beep_1
;minute_beep_2:
;push ax
;out dx,ax
;call waittime
;pop ax
;add ax,2
;cmp ax,4a0h
;jnz minute_beep_2
jmp close_beep


second_beep:
mov ax,980h
out dx,ax
call waittime
close_beep:
mov dx,ds:[ac97_mixer_base]
mov ax,0
out dx,ax
retn
playsound endp


waittime proc near
pushad
mov cx,0
wait_slot:
in al,42h
cmp al,0
jnz wait_slot
inc cx
cmp cx,5120
jnz wait_slot
popad
ret
waittime endp

code2 ends
end start