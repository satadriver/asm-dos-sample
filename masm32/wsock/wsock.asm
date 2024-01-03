.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\wsock2.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\wsock2.lib



.code

_DlgMain proc,hWnd,uMsg,wParam,lParam

mov eax,uMsg
.if eax==WM_INITDIALOG

.elseif eax==WM_CLOSE

.else
mov eax,0
ret
.endif
mov eax,1
ret
_DlgMain endp



start:
invoke GetModuleHandel,0
mov _hInstance,eax
invoke DialogBoxParam,eax,DLG_MAIN,0,offset _DlgMain,0
invoke EndProcess,0
end start