.model small
.386
.data


.code
start:
mov ax,@data
mov es,ax
mov ax,13h
int 10h
mov ax,0a000h
mov ds,ax

next1:
mov eax,es:[xy]
mov edx,0
mov ebx,320
div ebx
sub eax,100
sub edx,100
push edx
mul eax
pop ebx
push eax
mov eax,ebx
mul eax
pop ebx
add eax,ebx
cmp eax,3600
jg next
mov esi,es:[xy]
mov byte ptr ds:[esi],0ah
next:
inc dword ptr es:[xy]
cmp dword ptr es:[xy],0fa00h
jz toquit

jmp next1


toquit:
mov ah,0
int 16h
mov ax,3
int 10h
mov ah,4ch
int 21h
end start
