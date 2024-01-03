;send 4000h bytes to 60000h from 100000h
;in debug32 u can see the differ between 0ffffh:10h and 0:0
;and 60000h is the same to 0ffffh:10h=100000h
;in debug u can not close the A20,cause the DOS will protect the A20
;in debug u can also see the data after A20
;control port 92h is effective to open and close A20 
;if U close A20,the data from 60000h is the same to 0:0

.386p
data segment para use16
org             0

Null            dq 0
Pm16Seg         dq 000098000000ffffh
Buffer          dq 000092000000ffffh
A20Seg		     dq 000092100000ffffh
Normal          dq 000092000000ffffh
GdtLen          =$-Null
GdtLimit        dw GdtLen-1
GdtBase         dd 0

StackPtr        dd 0
OUtMem          db 4000h dup (0)

RmTop           db 4000h dup (0)
                
data ends



code segment para use16
assume cs:code
start:
xor eax,eax
mov ax,data
mov ds,ax
mov es,ax
shl eax,4
mov ds:[GdtBase],eax
mov word ptr ds:[Buffer+2],ax
shr eax,16
mov byte ptr ds:[buffer+4],al

xor eax,eax
mov ax,Pm16
shl eax,4
mov word ptr ds:[Pm16Seg+2],ax
shr eax,16
mov byte ptr ds:[Pm16Seg+4],al

mov ax,ss
shl eax,16
mov ax,sp
mov ds:[StackPtr],eax

mov al,0
out 92h,al
push ds
push es
mov ax,0ffffh
mov ds,ax
mov ax,5000h
mov es,ax
mov si,10h
mov di,0
mov cx,1000h
cld
rep movsd
pop es
pop ds


cli
mov al,2
out 92h,al
lgdt qword ptr ds:[GdtLimit]
mov eax,cr0
or al,1
mov cr0,eax

db 0eah
dw 0
dw 8

DosMOde:
mov ax,data
mov ds,ax
mov es,ax
lss sp,dword ptr ds:[StackPtr]
mov ax,6000h
mov es,ax
mov di,0
mov si,offset Rmtop
mov cx,1000h
cld
rep movsd
mov al,0
out 92h,al
mov ah,4ch
int 21h
code ends




Pm16 segment para use16
assume cs:pm16
mov ax,10h
mov es,ax
mov ax,18h
mov ds,ax
mov esi,0
mov di,offset RmTop
movzx edi,di
mov cx,1000h
copy:
mov eax,ds:[esi]
mov es:[edi],eax
add esi,4
add edi,4
loop copy

ToDOs:
mov eax,cr0
and al,0feh
mov cr0,eax
mov ax,20h
mov ds,ax
mov es,ax
mov ss,ax
jmp far ptr DosMOde
Pm16 ends
end start
