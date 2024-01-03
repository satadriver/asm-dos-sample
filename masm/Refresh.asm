.model small
.386
.stack 100H
.data
timeslot0 dw 0
timeslot1 dw 0
timeslot2 dw 0
timeslot3 dw 0
msg_timeslot db 'timer2 output interval is:',0ah,0dh

.code
start:
mov ax,@data
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax

mov al,0b6h
out 43h,al
mov ax,120  ;frequency=1193181.6 times/sec
out 42h,al
xchg ah,al
out 42h,al


call waitrefresh
call timedot
mov bx,ax
call waitrefresh
call timedot
sub ax,bx
mov ds:[timeslot0],ax


call waittimer2_out
call timedot
mov bx,ax
call waittimer2_out
call timedot
sub ax,bx
mov ds:[timeslot1],ax

call gettimer2_output
call timedot
mov bx,ax
call gettimer2_output
call timedot
sub ax,bx
mov ds:[timeslot2],ax 

mov ah,0
int 16h
mov ah,4ch
int 21h

gettimer2_output proc near
mov al,0e8h
out 43h,al
in al,42h
test al,80h
jz gettimer2_output
ret
gettimer2_output endp


timedot proc near
mov al,0d8h
out 43h,al
in al,42h
mov ah,al
in al,42h
xchg ah,al
ret
timedot endp



waitrefresh proc near
in al,61h
test al,10h
jz waitrefresh
ret
waitrefresh endp


waittimer2_out proc near
in al,61h
test al,20h
jz waittimer2_out
ret
waittimer2_out endp
end start

