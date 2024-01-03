.386P
PspSeg segment para use16
db 100h dup (0)
PspSeg ends



ComData segment para use16
dd 4000h dup (0)
ComData ends



Data segment para use16
msg_input                   	db 'please input .com file name:',0ah,0dh,24h
msg_notfound                	db 'not found file,please input file name again:',0ah,0dh,24h

comName_limit_lenth         	db 0ffh
comName_fact_lenth          	db 0
comName                    	db 80h dup (0)

handle                      	dw 0
FileSize           		dw 0
Data ends



Code segment para use16
assume cs:Code

Start:
call getfilename
call readfile
call relocate




getfilename proc near
mov ax,Data
mov ds,ax
mov es,ax
cld
mov ah,9
mov dx,offset msg_input
int 21h
mov ah,0ah
mov dx,offset comName_limit_lenth
int 21h
mov si,offset comName
xor bx,bx
mov bl,ds:[comName_fact_lenth]
add si,bx
mov di,si
sub si,4
lodsd
cmp eax,6d6f632eh ;'.com'
jz with_ext
cmp eax,4d4f432eh
jz With_Ext
mov eax,4d4f432eh
stosd
with_ext:
mov al,0
stosb
ret
getfilename endp




readfile proc near
mov ax,3d00h
mov dx,offset ComName
int 21h
jnc FoundFile
mov ah,9
mov dx,offset msg_notfound
int 21h
sub sp,2
jmp start
FoundFile:
mov bx,ax
mov es:[handle],ax
mov ax,4202h
mov cx,0
mov dx,0
int 21h
mov es:[FileSize],ax
mov ax,4200h
mov bx,es:[Handle]
mov cx,0
mov dx,0
int 21h
mov ax,ComData
mov ds,ax
mov ax,3f00h
mov bx,es:[Handle]
mov cx,es:[FileSize]
mov dx,0
int 21h
mov ax,3e00h
mov bx,es:[handle]
int 21h
ret
readfile endp




relocate proc near
mov cx,es:[FileSize]
mov ax,ds
sub ax,10h
mov word ptr cs:[ComSegment],ax
mov ds,ax

push ax			;must keep SS:SP before another process!!!
mov ax,ss
shl eax,16
mov ax,sp
add ax,4
mov dword ptr ds:[2eh],eax
pop ax

mov es,ax
mov fs,ax
mov gs,ax
cli			;must CLI  before Changing SS:SP!!!
mov ss,ax
mov sp,0
push word ptr 0cd20h 
sti

mov ax,0
mov bx,0
mov dx,0
mov bp,0
mov si,0
mov di,0

		db 0eah
comoffset       	dw 100H
comsegment      	dw 0
ret
relocate endp

Code ends
end start
