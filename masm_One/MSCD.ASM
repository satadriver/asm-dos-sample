;MSFλ��Ҫ�󷵵�ַ��ʽΪMSF��ַ��ʽ�����λһ��Ҫ��1��
;MSF��ַ��ʽ��ָ�����е�����ʵ�ʱ�д���λ�ã���С��λ��f,75��F�ֶ���Ϊһ��S�ֶ�
;��60��s�ֶ���Ϊһ��M�ֶΡ�F�ֶε���Чֵ��ΧΪ0��74��S�ֶε���Чֵ��ΧΪ0��59
;M�ֶε���;Чֵ��ΧΪ0��99��MSF��ַ�����ݸ�ʽ��4���ֽ����
;��һ�ֽ�Ϊ�����ֽڣ��ڶ��ֽ�ΪM�ֶΣ������ֽ�ΪS�ֶΣ������ֽ�;ΪF�ֶΡ�
;�������ݸ�ʽ�ڵڶ��ֽں͵ھ��ֽ��У�
;����Ϊ����ֵ���ص�������ʽҲ��ͬ����CD���̲�����һ������Ϳ����ˡ�
;��Ŀ����ָ��Ҫ����TOC���ݵ���Ŀ�ţ�������ЧֵΪ00H-63H,Ҳ����0-99��
;����Ŀ��ΪAAHʱ�򷵻����Ź��̵Ľ���MSF��ַ


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