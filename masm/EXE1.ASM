;1.重定位地址的基地址是以EXE文件头长度加上装载地址之和，而不是以CS:IP为基地址;
;2.本程序的BUG在于，要先将重定位表项的内容取出并调整整个程序的段值，
;然后在EXE文件头最后的100H字节建立PSP,
;若是先在EXE文件头最后的100H处建立PSP，再取重定位项来调整程序段的段值，
;若是重定位项数比较多，则PSP会覆盖重定位项
;正规的操作是先读写文件头，在开辟内存（PSP+程序大小）读入PSP和程序
;3. DOS计算程序影象+100H+EXE文件头偏移0AH之和，若不能分配该内存，则出错返回，
;否则DOS计算程序影象+100H+EXE文件头偏移0CH之和，
;若不能分配则分配DOS计算程序影象+100H+EXE文件头偏移0AH之和的内存，否则
;分配DOS计算程序影象+100H+EXE文件头偏移0CH之和的内存
;4. compatible for PE file run in dos mode!
.386
stack segment stack
db 400h dup (0)
stack ends



PSPsegment segment para use16
db 100h dup (0)
PSPsegment ends




exesegment segment para use16       ;dup伪操作只能填充65535个字节，若是改为 db 10000H dup(0),连接错误 
exedata db 0ffffh dup (0)           ;段最大为65536字节大小
db 0
exesegment ends




extra_exesegment segment para use16
db 0ffffh dup (0)
db 0
extra_exesegment ends




data segment para use16
main_proc_PSP_BASE      DW 0
exesize_low             dw 0
exesize_high            dw 0
handle                  dw 0
exename_limit_lenth     db 40h
exename_fact_lenth      db 0
exe_name                db 40h dup (0)
exe_entrance_offset     dw 0
exe_entrance_seg        dw 0
stack_pointer           dw 0
stack_seg               dw 0
reallocation_seg        dw 0
reallocation_offset     dw 0
smile_position          dw 0
smile_color             db 1
reserved_char           dd 0
msg_input               db 'Input file name(xxxx.EXE or xxxx.COM) to execute',0ah,0dh
                        db 'CTRL+C/CTRL+BREAK to quit',0ah,0dh,24h
msg_notfoundfile        db 'Not found file,Press any key to continue...',0ah,0dh,24h
msg_largemode           db 'File too BIG to be executed,Press any key to continue...',0ah,0dh,24h
msg_notEXEorCOM         db 'NOT CORRECT file format,Press any key to continue...',0ah,0dh,24h
data ends




code segment para use16
assume cs:code
start:
call readfile
call set_int22h
cmp word ptr ds:[exedata],5a4dh  ;'MZ' is flag of exe file，COM FILE is all binary data
jz reallocation_exe
jmp reallocation_com




readfile proc near
;mov ax,data
;mov ds,ax
;PUSH ES
;POP WORD PTR FS:[MAIN_PROC_PSP_BASE]
mov ax,data
mov fs,ax
mov gs,ax
mov ds,ax
mov es,ax
mov ax,3
int 10h
mov ah,9
mov dx,offset msg_input
int 21h
call show_smile
mov ah,0ah
mov dx,offset exename_limit_lenth
int 21h

xor bx,bx
mov di,offset exe_name
MOV BL,byte ptr ds:[exename_fact_lenth]
add di,bx
mov si,di
sub si,3
lodsd

cmp eax,0d6d6f63h                   ; 'com'
jnz check_is_exe_caps
jmp exe_or_com
check_is_exe_caps:
cmp eax,0d4d4f43h                   ; 'COM'
jnz check_is_com
jmp exe_or_com
check_is_com:
cmp eax,0d657865h                   ; 'exe'
jnz check_is_com_caps
jmp exe_or_com
check_is_com_caps:
cmp eax,0d455845h                   ; 'EXE'
jz exe_or_com
CALL notEXEorCOM
exe_or_com:
mov al,0
stosb

mov ax,3d00h
mov dx,offset exe_name
int 21h
jnc open_success
jmp notfoundfile
open_success:
mov ds:[handle],ax
mov bx,ax
mov ax,4202h
mov cx,0
mov dx,0
int 21h
cmp dx,1
jbe mode_small
jmp mode_large
mode_small:
mov ds:[exesize_low],ax
mov ds:[exesize_high],dx
mov ax,4200h
mov bx,ds:[handle]
mov cx,0
mov dx,0
int 21h
mov ax,exesegment 
mov ds,ax

mov cx,fs:[exesize_high]
cmp cx,0
jz readfile_detail
dec cx
readfile_block:
push cx
push ds
mov ax,3f00h
mov bx,fs:[handle]
mov cx,0ffffh
mov dx,0
int 21h
mov ax,3f00h
mov bx,fs:[handle]
mov cx,1
mov dx,0ffffh
int 21h
pop ds
mov ax,ds
add ax,1000h
mov ds,ax
pop cx
loop readfile_block

readfile_detail:
mov ax,3f00h
mov bx,fs:[handle]
mov cx,fs:[exesize_low]
mov dx,0
int 21h
mov ax,3e00h                            ;文件操作后不要忘了关闭文件
mov bx,fs:[handle]
int 21h
ret
readfile endp




reallocation_exe proc near
;call CheckPE
mov bx,word ptr ds:[exedata+14h]
mov fs:[exe_entrance_offset],bx
mov bx,exesegment
add bx,word ptr ds:[exedata+8]
mov fs:[reallocation_seg],bx
add bx,word ptr ds:[exedata+16h]
mov fs:[exe_entrance_seg],bx

xor eax,eax
mov ax,word ptr ds:[exedata+16h]
shl eax,4
xor ebx,ebx
mov bx,word ptr ds:[exedata+14h]
add eax,ebx
cmp ax,0
jnz notmax_allocation
mov ax,fs:[reallocation_seg]
mov word ptr fs:[exe_entrance_seg],ax
mov word ptr fs:[exe_entrance_offset],0

notmax_allocation:
mov bx,fs:[reallocation_seg]
add bx,word ptr ds:[exedata+0eh]
mov fs:[stack_seg],bx
mov bx,word ptr ds:[exedata+10h]
mov fs:[stack_pointer],bx

mov cx,word ptr ds:[exedata+6]
cmp cx,0
jz set_register
mov ax,word ptr fs:[reallocation_seg]
mov es,ax
mov si,word ptr ds:[exedata+18h]
reallocat:
push cx
push es
add si,2
lodsw
mov bx,es
add ax,bx
mov es,ax
sub si,4
lodsw
;add ax,fs:[exe_entrance_offset]
mov di,ax
mov ax,word ptr es:[di]
add ax,fs:[reallocation_seg]
mov es:[di],ax
add si,2
pop es
pop cx
loop reallocat

;CALL createPSP_EXE             ;how could to set PSP correctly???

set_register:
MOV AX,3
INT 10H
MOV AX,200h ;sti
push ax
popf
push word ptr fs:[exe_entrance_offset]
pop word ptr cs:[exe_ip]
push word ptr fs:[exe_entrance_seg]
pop word ptr cs:[exe_cs]
xor esp,esp
lss sp,dword ptr fs:[stack_pointer]
mov cx,fs:[exesize_low]
movzx ecx,cx
mov bx,fs:[exesize_high]
movzx ebx,bx
mov ax,fs:[reallocation_seg]
sub ax,10h                      ;PSP
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov eax,0                       ;command line parameters,but is 0 here as no command line parameters
                                ;pagehigh of file,but here is 0 as only less 64kbs lenth file can be executed
mov edx,0
mov esi,0
mov edi,0
mov ebp,0
db 0Eah            
exe_ip  dw 0
exe_cs  dw 0
mov ah,4ch
int 21h
reallocation_exe endp





reallocation_com proc near
;call createPSP_COM              ;how could to set PSP correctly???              
MOV AX,3
INT 10H
MOV AX,200h
push ax
popf
mov cx,fs:[exesize_low]
movzx ecx,cx
mov bx,fs:[exesize_high]
movzx ebx,bx
push word ptr 100h
pop word ptr cs:[com_ip]
mov ax,pspsegment               ;be equalvalent to ds-10h also           
mov cs:[com_CS],ax
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov esp,0
push word ptr 0
mov eax,0                       ;command line parameters,but is 0 here as no command line parameters
                                ;pagehigh of file,but here is 0 as only less 64kbs lenth file can be executed
mov edx,0
mov esi,0
mov edi,0
mov ebp,0
db 0eAh                         ;长跳转 JMP FAR PTR XXXX 或JMP DWORD PTR XXXX:[XXXX]
com_ip  dw 100h
com_cs  dw 0
reallocation_com endp



CheckPE proc near
pushad
push ds
push es
push fs
push gs
mov ax,ExeSegment
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov si,3ch
lodsd
mov si,ax
lodsd
cmp eax,5045h
jnz NotPE
push ds
pop word ptr cs:[PeSeg]
mov si,8		;if Exe is PE file,offset 18h=IP=08h (often be 40h)
lodsw
shl ax,4
mov cs:[PeOffset],ax
mov ax,0
mov bx,0
mov cx,0
mov dx,0
mov si,0
mov di,0
mov bp,0
		db 0eah
PeOffset	dw 0
PeSeg		dw 0

NotPE:
pop gs
pop fs
pop es
pop ds
popad
ret
CheckPE endp


set_int22h proc near
push es
xor ax,ax
mov es,ax
mov di,22h
shl di,2
stosw
mov ax,int22h_seg
stosw
pop es
ret
set_int22h endp




createPSP_com proc near
mov ah,55h
mov dx,PSPsegment
int 21h
mov ax,pspsegment
call adjust_psp
ret
createPSP_com endp




createPSP_exe proc near
mov ah,55h
mov dx,fs:[reallocation_seg]
sub dx,10h
int 21h
mov ax,fs:[reallocation_seg]
sub ax,10h
call adjust_PSP
ret
createPSP_exe endp




adjust_PSP proc near
push ds
push es
push ax
mov ds,ax
mov si,2ch
lodsw
mov es,ax
mov ds,ax
mov si,0
check_process_enviroment:
lodsb
cmp al,0
jnz check_process_enviroment
lodsb
cmp al,0
jnz check_process_enviroment
add si,2
mov di,si
mov ax,data
mov ds,ax
mov si,offset exe_name
xor cx,cx
mov cl,fs:[exename_fact_lenth]
inc cx
rep movsb

pop ax
mov es,ax
mov di,80h
mov si,offset exename_fact_lenth
mov cl,fs:[exename_fact_lenth]
movzx cx,cl
inc cx
rep movsb
mov al,0dh
stosb

pop es
pop ds
ret
adjust_PSP endp




notfoundfile proc near
mov ax,data
mov ds,ax
mov ah,9
mov dx,offset msg_notfoundfile
int 21h
mov ah,0
int 16h
JMP start
notfoundfile endp



mode_large proc near
mov ah,9
mov dx,offset msg_largemode
int 21h
mov ah,0
int 16h
JMP start
mode_large endp




NOTEXEorCOM PROC NEAR
mov ah,9
mov dx,offset msg_notEXEorCOM
int 21h
mov ah,0
int 16h
JMP start
NOTEXEorCOM ENDP




show_smile proc near
pusha
push ds
push es
call settimer
mov ax,0b800h
mov es,ax
mov di,0
next_position:
push dword ptr es:[di]
pop dword ptr fs:[reserved_char]
mov ah,fs:[smile_color]
mov al,2
push ax
shl eax,16
pop ax
mov al,1
mov dword ptr es:[di],eax
mov fs:[smile_position],di

add di,2
cmp di,1000h
jb notreach_text_end
sub di,1000h
notreach_text_end:
inc byte ptr fs:[smile_color]
cmp byte ptr fs:[smile_color],10h
jnz notreach_bkgrd
mov byte ptr fs:[smile_color],1
notreach_bkgrd:
call waittime
mov eax,fs:[reserved_char]
push di
mov di,fs:[smile_position]
mov es:[di],eax
pop di

push ds
mov ax,40h
mov ds,ax
mov si,word ptr ds:[1ah]
cmp si,word ptr ds:[1ch]
jnz press_key_occurred
;mov ah,0bh
;int 21h
;cmp al,0
;jz next_position
pop ds
jmp next_position
press_key_occurred:
pop ds
pop es
pop ds
popa
ret
show_smile endp




waittime proc near
mov cx,0
timer0:
mov al,0
out 43h,al
in al,40h
cmp al,0
jnz timer0
inc cx
cmp cx,256
jnz timer0
ret
waittime endp





settimer proc near
mov al,36h
out 43h,al
mov ax,0
out 40h,al
xchg ah,al
out 40h,al
ret
settimer endp




quit proc near
mov ah,0
int 16h
mov ah,4ch
int 21h
quit endp
code ends



int22h_seg segment para use16
org 0
assume cs:int22h_seg
jmp far ptr start
int22h_seg ends
end start




mov ax,fs:[main_proc_psp_base]
mov ds,ax
mov si,2ch
lodsw
mov es,ax
mov ds,ax
mov si,0
check_process_enviroment_1:
lodsb
cmp al,0
jnz check_process_enviroment_1
lodsb
cmp al,0
jnz check_process_enviroment_1
add si,2
mov di,si
mov ax,data
mov ds,ax
mov si,offset exe_name
xor cx,cx
mov cl,fs:[exename_fact_lenth]
rep movsb
mov al,0
stosb
mov ax,fs:[main_proc_psp_base]
mov es,ax
mov di,80h
mov si,offset exename_fact_lenth
mov cl,fs:[exename_fact_lenth]
movzx cx,cl
inc cx
rep movsb
mov al,0dh
stosb


