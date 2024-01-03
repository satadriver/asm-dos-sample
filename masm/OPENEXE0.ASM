.386p
stack segment stack use16
db 100h dup (0)
stack ends


DATA SEGMENT  para use16
LOCATEITEM DW 0
LOCATEVOLUME DW 0 
LOCATESS DW 0
LOCATESP DW 0
LOCATEIP DW 0
LOCATECS DW 0
LOCATEADDR DW 0
highpart dw 0
lowpart dw 0
handle dw 0
DEFAULTDS DW 0
realss dw 0
realsp dw 0
cursorlow dw 0
cursorhigh dw 0
loadseg dw 6000h
relocip dw 0
reloccs dw 0
realip dw 0
realcs dw 0
EXENAME DB 20h DUP (0)
MESSAGE DB 'this program is to run EXE file',0ah,0dh
db 'press ESC to quit.....',0ah,0dh
db "Input EXE file's name to run:",0AH,0DH,24h
ERROR DB 'FILE NOT FOUND,input exe name again....',0AH,0DH,24H
DATA ENDS






CODE SEGMENT para use16
ASSUME CS:CODE

START:
main proc near
MOV AX,DATA
MOV ES,AX
MOV DS,AX
call init
call getfileinfo
call preload
call load
jmp start
call quit
main endp







init proc near
mov di,offset exename
mov eax,0
mov cx,8
rep stosd
mov ax,3
int 10h
MOV AH,9
MOV DX,OFFSET MESSAGE
INT 21H

mov ax,00ah
mov dx,3d4h
out dx,ax
mov ax,00bh
out dx,ax
MOV AX,0B800H
MOV DS,AX
MOV SI,480
MOV DI,0
mov word ptr es:[cursorlow],0400fh    ;光标占用2字节   0EH为高字节，0FH为低字节，50H=80 ，0AH 0BH只是决;定光标的起始位置
mov word ptr es:[cursorhigh],010eh
cld
getfilename:
mov ax,word ptr es:[cursorlow]
mov dx,3d4h
out dx,ax
mov ax,word ptr es:[cursorhigh]
mov dx,3d4h
out dx,ax
MOV AH,0
INT 16H
CMP AL,8
JNZ checkenter
ifback:
SUB SI,2
cmp si,480
jge covertype
mov si,480
covertype:
MOV AX,20H
MOV DS:[SI],AX
sub word ptr es:[cursorlow],100h
cmp es:[cursorlow],0400fh
jge covercursor
mov word ptr es:[cursorlow],0400fh
covercursor:
dec di
cmp di,offset exename
jge notcover
mov di,offset exename
notcover:
JMP getfilename

checkenter:
CMP AL,0DH
jz toback
cmp al,1bh
jz toquit
mov es:[exename+di],al
MOV AH,0ah                
MOV DS:[SI],AX
ADD SI,2
inc di
add word ptr es:[cursorlow],100h
JMP getfilename
toback:
jmp getfileinfo
toquit:
call quit
init endp
;d7   d6  d5  d4        d3          d2  d1  d0      ;背景字符串最好用加亮属性来显示，否则颜色过暗引发眼睛疲劳  
;b       r    g    b    highlight      r     g    b



getfileinfo proc near
mov ax,data
mov ds,ax
MOV AX,3D00H
MOV DX,OFFSET EXENAME
INT 21H
JnC nextstep
TOERROR:
MOV AH,9
MOV DX,OFFSET ERROR
INT 21H
MOV AH,0
INT 16H
call main

NEXTSTEP:
MOV BX,AX
mov es:[handle],ax
MOV AX,4202H
MOV CX,0
MOV DX,0
INT 21H
mov es:[highpart],dx                                ;返回的数值恰好是文件的字节数，若加1回错误
mov es:[lowpart],ax
MOV AX,4200H
MOV CX,0 
MOV DX,0
INT 21H
MOV AX,es:[loadseg]
MOV DS,AX
mov cx,es:[highpart]
cmp cx,0
jz small

checkvolume:
push cx
MOV AX,3F00H
mov bx,es:[handle]
mov cx,0ffffh
MOV DX,0
INT 21H
MOV AX,3F00H
mov bx,es:[handle]
mov cx,1
MOV DX,0ffffh
INT 21H
mov ax,ds
add ax,1000h
mov ds,ax
pop cx
loop checkvolume

small:
MOV AX,3F00H
mov bx,es:[handle]
mov cx,es:[lowpart]
MOV DX,0
INT 21H

mov ax,es:[loadseg]
mov ds,ax
MOV DI,OFFSET LOCATEITEM
MOV SI,6
LODSW
STOSW
LODSW
STOSW
MOV SI,0EH
LODSW
STOSW
LODSW
STOSW
MOV SI,14H
LODSW
STOSW
LODSW
STOSW
LODSW
STOSW
toquit0:
ret
getfileinfo endp

preload proc near
cmp word ptr es:[locatecs],0fff0h
jnz next0
cmp word ptr es:[locateip],10h
jnz next0
mov word ptr es:[locatecs],0
mov word ptr es:[locateip],0
next0:
mov ax,es:[loadseg]
add ax,es:[locatevolume]
sub ax,10h
mov es:[defaultds],ax

mov ax,es:[locateip]
mov es:[realip],ax

mov ax,es:[loadseg]
add ax,es:[locatecs]
add ax,es:[locatevolume]
mov es:[realcs],ax

mov AX,ES:[LOCATESS]
add ax,es:[loadseg]
ADD AX,ES:[LOCATEVOLUME]
MOV es:[realss],AX

mov ax,ES:[LOCATESP]
MOV word ptr es:[realsp],ax

cld
MOV SI,es:[locateaddr]
MOV CX, ES:[LOCATEITEM]
cmp cx,0
jz toprev
setrelocatetable:
push cx
lodsw
mov di,ax
lodsw
add ax,es:[loadseg]
add ax,es:[locatevolume]
mov fs,ax
mov ax,fs:[di]
add ax,es:[loadseg]
add ax,es:[locatevolume]
mov fs:[di],ax
pop cx
loop setrelocatetable
toprev:
ret
preload endp





load proc near
mov ax,es:[realss]
mov ss,ax
mov sp,es:[realsp]
mov ax,es:[realip]
mov cs:[ipip],ax
mov ax,es:[realcs]
mov cs:[cscs],ax

mov bx,es:[highpart]
mov cx,es:[lowpart]
mov dx,0
mov si,0
mov di,0
mov bp,0
mov ax,es:[defaultds]
mov es,ax
mov ds,ax
mov ax,0
DB 0eAH
IPIP DW 0
CSCS DW 0
ret
load endp


quit proc near
mov ah,4ch
int 21h
quit endp
CODE ENDS
END START