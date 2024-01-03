.model small
.code
start:
cli
mov al,0d0h
out 64h,al
l0:in al,64h
test al,1
jz l0
in al,60h
or al,81h
mov bl,al
l1:
in al,64h
test al,2
jnz l1
mov al,0d1h
out 64h,al
l2:
in al,64h
test al,2
jnz l2
mov al,bl
out 60h,al
l4:in al,64h
test al,2
jnz l4
mov al,0aeh
out 64h,al
l3:
in al,64h
test al,1
jz l3
in al,60h
cmp al,1
jz quit

sti
l5:in al,64h
test al,2
jnz l5
mov al,0d1h
out 64h,al
l6:in al,64h
test al,2
jnz l6
and bl,0efh
mov al,bl
out 60h,al

int 3



quit:
mov ah,4ch
int 21h
end start

