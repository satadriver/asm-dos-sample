.386
clockSeg segment para use16
assume cs:clockSeg

Clock:
jmp Main
;****************************************************
Rect                db 0dah
                    db 78 dup (0c4h)
                    db 0bfh

                    db 0b3h
msgTime             db 'Current Time:'
CurrentHour         dw 0
                    db 3ah
CurrentMin          dw 0
                    db 3ah
CurrentSec          dw 0
msgTimeLen equ $-msgTime
                    db 78-msgTimeLen dup (20h)
                    db 0b3h
                    
                    db 0b3h
msgData             db 'Current Date:'
CurrentCentury      dw 0
Currentyear         dw 0
                    db 2fh
CurrentMonth        dw 0
                    db 2fh
CurrentDay          dw 0
msgDataLen equ $-msgData
                    db 78-msgDatalen dup (20h)
                    db 0b3h

                    db 0b3h
msgWeekDay          db 'Day  OF Week:'
CurrentWeekDay      dw 0
msgWeekDayLen equ $-msgWeekDay
                    db 78-msgWeekDayLen dup (20h)
                    db 0b3h
                    
                    db 0b3h
msgAlarm            db 'Alarm   Time:'
alarmhour           dw 0
                    db 3ah
alarmmin            dw 0
                    db 3ah
alarmsec            dw 0
                    db 0
msgAlarmLen equ $-msgAlarm
                    db 78-msgAlarmLen dup (20h)
                    db 0b3h

                    db 0c0h
                    db 78 dup (0c4h)
                    db 0d9h

VideoStore	    db 8000h dup (0)
RectPos 		dw 1600
RectHeight 		dw 6
RectWidth  		dw 80
color  			db 0ah
Counter 		dd 0
Ac97MasterBase 		dw 0
Ac97MixerBase  		dw 0
old_ip 			dw 0
old_cs 			dw 0
InitFlag		dw 0
;************************************************


Main:
sti
pushad
push ds
push es
push ss
push fs
push gs

mov al,20h
out 20h,al
out 0a0h,al

cmp word ptr cs:[InitFlag],1
jnz nextStep

call ResetAlarm
mov word ptr cs:[InitFlag],0

NextStep:
mov al,0ch
out 70h,al
in al,71h
test al,80h
jnz judgementInt
jmp IntReturn
JudgementInt:
test al,20h
jnz AlarmInt
test al,10h
jnz SecondInt
test al,40h
jnz PeriodInt

PeriodInt:
call PeriodIntProc
jmp IntReturn
AlarmInt:
call AlarmIntProc
jmp IntReturn
SecondInt:
call SecondIntProc
IntReturn:
pop gs
pop fs
pop ss
pop es
pop ds
popad
iret


AlarmIntProc proc near
CALL SAVEvIDEO
mov ax,3
int 10h
RefreshTime:
mov ax,cs
mov ds,ax
mov es,ax

mov al,0
mov di,offset CurrentSec
call GetTime
mov al,2
mov di,offset CurrentMin
call GetTime
mov al,4
mov di,offset CurrentHour
call GetTime

mov al,6
mov di,offset CurrentWeekDay
call GetTime

mov al,7
mov di,offset CurrentDay
call GetTime
mov al,8
mov di,offset CurrentMonth
call GetTime
mov al,9
mov di,offset CurrentYear
call GetTime
mov al,32h
mov di,offset CurrentCentury
call GetTime

mov al,1
mov di,offset AlarmSec
call GetTime
mov al,3
mov di,offset AlarmMin
call GetTime
mov al,5
mov di,offset AlarmHour
call GetTime

mov ax,0b800h
mov es,ax
mov si,offset rect
mov di,cs:[RectPos]
mov cx,cs:[RectHeight]
cld
copyFrame:
push cx
mov cx,RectWidth
mov ah,cs:[color]
copyLine:
lodsb
stosw
loop copyLine
pop cx
loop copyFrame

;in al,64h		;IF=0,this will be exception,why???
;test  al,1
mov ah,1
int 16h
jz ToRefreshTIme
jmp ToALarmRet
TORefreshTIme:
jmp RefreshTime

ToAlarmRet:

;mov ah,0
;int 16h

;PUSHAD
;CALL RESTOREvideo
;POPAD

cmp al,1bh
jnz AlarmRet
call restoreVideo
mov ax,0
mov es,ax
mov di,70h
shl di,2
push word ptr cs:[Old_ip]
pop word ptr es:[di]
push word ptr cs:[Old_cs]
pop word ptr es:[di+2]

AlarmRet:
call restoreVideo 
call ResetAlarm
ret
AlarmIntProc endp



PeriodIntProc proc near
mov ax,0b800h
mov es,ax
mov di,140
inc dword ptr cs:[counter]
mov eax,dword ptr cs:[counter]
mov cx,8
mov bl,28
Translate:
push eax
push cx
push bx
mov cl,bl
shr eax,cl
and al,0fh
cmp al,9
jbe NotHex
add al,7
NotHex:
add al,30h
mov ah,cs:[color]
stosw
pop bx
sub bl,4
pop cx
pop eax
loop Translate
ret
PeriodIntProc endp


SecondIntProc proc near
mov ax,0b800h
mov es,ax
mov di,0

mov al,4
call calc
mov al,2fh
mov ah,cs:[color]
stosw
mov al,2
call Calc
mov al,2fh
mov ah,cs:[color]
stosw
mov al,0
call calc
ret
SecondIntProc endp


Calc proc near
out 70h,al
mov ah,cs:[color]
in al,71h
push ax
shr al,4
add al,30h
stosw
pop ax
and al,0fh
add al,30h
stosw
ret
calc endp


ResetAlarm proc near
mov bl,0
call SetAlarm
mov bl,2
call SetALarm
mov bl,4
call SetALarm

mov al,1
out 70h,al
in al,71h
add al,30h
cmp al,60h
jl NoIncAlarm
sub al,60h
out 71h,al
mov al,3
out 70h,al
in al,71h
inc al
cmp al,59h
jbe NoIncAlarm
mov al,0
out 71h,al
mov al,5
out 70h,al
in al,71h
inc al
cmp al,24h
jb NoIncAlarm
mov al,0
out 71h,al
jmp ResetAlarmRet

NoIncAlarm:
out 71h,al
ResetAlarmRet:
ret
ResetALarm endp



GetTime proc near           ;al=num,ds:[si]=position
out 70h,al
in al,71h
push ax
shr al,4
add al,30h
stosb
NextHalf:
pop ax
and al,0fh
add al,30h
stosb
ret
GetTime endp

SaveVIdeo proc near
push es
mov ax,cs
mov es,ax
mov ax,4f04h
mov bx,offset VIdeoStore
mov cx,08h
mov dx,1
int 10h
pop es
ret
SaveVideo endp

ReStoreVideo proc near
push es
mov ax,cs
mov es,ax
mov ax,4f04h
mov cx,08H
mov dx,2
mov bx,offset VIdeoStore
int 10h
pop es
ret
RestoreVideo endp




MakeSound proc near
ret
MakeSound endp


SetAlarm proc near
mov al,bl
out 70h,al
in al,71h
push ax
inc bl
mov al,bl
out 70h,al
pop ax
out 71h,al
ret
SetAlarm endp


start:
cli
cld
mov ax,cs
mov ds,ax
mov ax,0
mov es,ax
mov di,70h
shl di,2
push word ptr es:[di]
pop word ptr ds:[old_ip]
mov ax,offset clock
stosw
push word ptr es:[di]
pop word ptr ds:[old_cs]
mov ax,seg clock
stosw

mov al,0bh
out 70h,al
mov al,72h
out 71h,al

in al,0a1h
and al,0feh
out 0a1h,al
in al,21h		;why need to clear mask of int 0ah??
and al,0fbh
;or al,4
out 21h,al

mov word ptr cs:[InitFlag],1

mov ah,9
mov dx,offset msgSuccess
int 21h

mov ax,3100h
mov dx,offset start
add dx,0fh
shr dx,4
add dx,10h
int 21h

msgSuccess      db 'Clock Drinver has been successfully loadded!',24h
clockSeg ends
end start
