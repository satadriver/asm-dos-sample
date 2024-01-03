.386
stack segment stack
db 100h dup (0)
stack ends


code segment para use16
assume cs:code
start:

call reallocate
next_exe:
call get_exe_name
call execute_exe
jmp next_exe


reallocate proc near
mov ax,stack
mov ss,ax
mov ax,data
mov ds,ax
mov ax,3
int 10h
push es
pop word ptr ds:[psp_seg]
mov ax,ds:[psp_seg]
mov es,ax
mov bx,ds:[datalenth]
add bx,2
add bx,cs:[codelenth]
add bx,2
add bx,sp
add bx,2
add bx,0fh
shr bx,4
add bx,10h
mov ax,4a00h
int 21h      ;es:bx=start address
jnc reallocate_ret
mov ah,9
mov dx,offset msg_realloc_error
int 21h
add sp,2
jmp quit
reallocate_ret:
ret
reallocate endp



get_exe_name proc near
mov ax,data
mov es,ax
mov fs,ax
mov gs,ax
mov ah,9
mov dx,offset msg_input
int 21h
mov ah,0ah
mov dx,offset exename_limit_lenth
int 21h
mov di,offset exename
xor bx,bx
mov bl,ds:[exename_fact_lenth]
add di,bx
mov al,0
stosb
mov ax,3d00h
mov dx,offset exename
int 21h
jnc get_exe_name_ret
mov ah,9
mov dx,offset msg_notfound
int 21h
mov ah,0
int 16h
add sp,2
jmp next_exe
get_exe_name_ret:
mov bx,ax
mov ax,3e00h
int 21h
ret
get_exe_name endp



;1 4bh/21h destroy all register(except ip:cs)
;2 ip:cs is all right
;3 ss:sp must be kept in cs segment,so u can retrieve after process
;4 cld instruction is needed indeed
;5 reallocate memory at the beginning of program
;6 use 55h/21h
execute_exe proc near
pushad
push ds
push es
push fs
push gs
mov ax,ss
shl eax,16
mov ax,sp
mov dword ptr cs:[stack_ptr],eax
cld                              ;cld is important here
mov ax,4b00h
mov dx,offset exename
mov bx,offset env_seg
int 21h
lss sp,dword ptr cs:[stack_ptr]
pop gs
pop fs
pop es
pop ds
popad
mov ah,9
mov dx,offset msg_end
int 21h
mov ah,1
int 21h
ret
execute_exe endp


quit proc near
mov ah,4ch
int 21h
quit endp


stack_ptr 	dw 0
		dw 0
codelenth 	dw $
code ends



data segment para use16
enviroment 		db 'path=',0
			db 'comspect=a:command.com',0,0
commandline 		db 0,0dh
exename_limit_lenth 	db 40h 
exename_fact_lenth 	db 0
exename 		db 40h dup (0)
psp_seg			dw 0
;parameter block is:
;1 enviroment segment
;2 offset cmdline
;3 seg cmdline
;4 offset fcb1
;5 seg fcb1
;6 offset fcb2
;7 seg fcb1
env_seg 		dw seg data
cmdline_offset 		dw offset commandline
cmdline_seg 		dw seg commandline
fcb1_offset 		dw 0
fcb1_seg 		dw 0
fcb2_offset 		dw 0
fcb2_seg 		dw 0

msg_input    	  db 0dh,0ah,'Input the .exe or .com name to execute!',0dh,0ah
	  	  db 'Press CTRL+C or CTRL+BREAK to quit...',0dh,0ah,24h
msg_realloc_error db 0dh,0ah,'Reallocation error!',0dh,0ah,24h
msg_end      	  db 0dh,0ah,'File executed completed!',0dh,0ah,24h
msg_notfound	  db 0dh,0ah,'Not found file,check file name!',0dh,0ah,24h
datalenth 	  dw $
data ends
end start


