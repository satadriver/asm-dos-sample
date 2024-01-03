;MSF位是要求返地址格式为MSF地址格式，这个位一般要置1。
;MSF地址格式是指光盘中的数据实际被写入的位置，最小单位是f,75个F字段则为一个S字段
;而60个s字段则为一个M字段。F字段的有效值范围为0－74，S字段的有效值范围为0－59
;M字段的有;效值范围为0－99。MSF地址的数据格式由4个字节组成
;第一字节为保留字节，第二字节为M字段，第三字节为S字段，第四字节;为F字段。
;返回数据格式在第二字节和第九字节中，
;设它为的数值返回的数据形式也不同，在CD光盘播放中一般置零就可以了。
;曲目号是指定要返回TOC数据的曲目号，它的有效值为00H-63H,也就是0-99号
;当曲目号为AAH时则返回整张光盘的结束MSF地址


.model small
.286
.data

readsubchannel db 42h,2,40h,1,0,0,0,0,0ch,0,0,0 
;send  :cmd       ,msf     ,subq        ,subchannle format,.........,lsb,...
;return :reserved, audio ,msblenth ,lsb                         ,01     ,adr+cntr,
;current song     ,current index       ,msb addr(word)      ,0       ,0
;0                        ,msb                     ,0                            ,0                 

readtop db             43h,2,0    ,0,0,0,0,0,0ch,0,0,0
;send  : cmd   ,msf, returndata format ,0,0,0,sound num,msblen,lsb
;return data format,0,0


playmsf db            47h,0,0    ,0,0,0,0,0,0    ,0,0,0
;send  cmd,0,0,m,s,f,end m,end s,end f,0,0,0


feedback db 100h dup (0)
identifydata db 100h dup (0)

testfail db 'SELF TEST ERROR,QUIT$'
lenth dw $
.code
start:
mov ax,@data
mov ds,ax
mov si,offset readsubchannel
mov ax,2000h
mov es,ax
mov di,si
mov cx,offset lenth
sub cx,si
rep movsb
mov ax,es
mov ds,ax


;call test

call identify
mov si,offset playmsf
call cmd
mov ah,4ch
int 21h




identify proc near
push ax
push cx
push dx
push di
push es

mov dx,1f7h
mov al,0a1h
out dx,al
l1:
in al,dx
cmp al,58h
jnz l1
mov di,offset identifydata
mov cx,100h
mov dx,1f0h
rep insw

pop es
pop di
pop dx
pop cx
pop ax
ret
identify endp


cmd proc near
push ax
push cx
push dx
push di
push es
mov al,6
mov dx,1f4h
out dx,al
mov al,0
mov dx,1f5h
out dx,al

mov dx,3f6h
mov al,0a0h
out dx,al
nop
nop 
nop
NOP
NOP
mov cx,12
l2:
mov al,ds:[si]
out dx,al
nop 
nop
nop
nop
nop
nop
inc si
loop l2
nop 
nop
nop
nop
nop
nop

mov di,offset feedback
mov dx,1f0h
mov cx,100h
rep insw
pop es
pop di
pop dx
pop cx
pop ax
ret
cmd endp

selftest proc near
push ax
push cx
push dx
push ds

mov al,090h
mov dx,3f6h
out dx,al

mov dx,1f1h
l0:
inc cx
cmp cx,0ffffh
jz testfailure

in al,dx
cmp al,1
jz next

cmp al,81h
jz next


cmp al,0
jz next
jnz l0
testfailure:
mov ah,9
mov dx,offset testfail
int 21h
mov ah,0
int 16h
mov ah,4ch
int 21h

next:
pop ds
pop dx
pop cx
pop ax
ret
selftest endp
end start