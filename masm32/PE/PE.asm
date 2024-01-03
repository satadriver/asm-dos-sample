.386
.model flat,stdcall
option casemap:none

include     \masm32\include\windows.inc
include     \masm32\include\user32.inc
include     \masm32\include\kernel32.inc
include     \masm32\include\comdlg32.inc
includelib  \masm32\lib\comdlg32.lib
includelib  \masm32\lib\user32.lib
includelib  \masm32\lib\kernel32.lib

DLG_MAIN 	=1000H
LTXT_INPUT 	=1010H
LTXT_SHOW 	=1011H
BTN_FIND 	=1020H
BTN_QUIT 	=1021H
TXT_SHOW	    =1030H





.data
_hInstance      dd 0
hWindow         dd 0
szPeExt         db '*.exe;*.dll;*.scr;*.fon;*.drv;*.sys',0,0
szFileName      db MAX_PATH dup (0)

szFileTooBig    db 'File is too big too open!',0dh,0ah,0
szOpenFileError db 'Open file error!',0dh,0ah,0
szMemoryError   db 'Memory allocation error!',0dh,0ah,0



.code 



_ProcOpenFile proc
local stOfn:OPENFILENAME

invoke RtlZeroMemory,addr stOfn,sizeof OPENFILENAME
mov stOfn.lStructSize,sizeof OPENFILENAME
mov stOfn.lpstrFilter,offset szPeExt
mov stOfn.lpstrFile,offset szFileName
mov stOfn.nMaxFile,MAX_PATH
mov stOfn.Flags,OFN_PATHMUSTEXIST OR OFN_FILEMUSTEXIST
push hWindow
pop stOfn.hwndOwner
invoke GetOpenFileName,addr stOfn
.if eax==TRUE
invoke lstrlen,offset szFileName
    .if eax
    invoke SetDlgItemText,hWindow,TXT_SHOW,offset szFileName
    call _ProcMain
    ret
    .endif
.endif
_ProcOpenFile endp




_ProcMain proc
local hFile
local FileSizeHigh
local FileSizeLow
local lpMemory
local lpNtHeader

invoke CreateFile,offset szFileName,GENERIC_READ OR GENERIC_WRITE,FILE_SHARE_READ OR FILE_SHARE_WRITE,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
.if eax==INVALID_HANDLE_VALUE
invoke MessageBox,0,offset szOpenFileError,0,MB_OK
invoke ExitProcess,0
.endif
mov hFile,eax
invoke GetFileSize,hFile,addr FileSizeHigh
mov FileSizeLow,eax
.if FileSizeHigh
invoke MessageBox,0,offset szFileTooBig,0,MB_OK
invoke ExitProcess,0
.endif
invoke GlobalAlloc,GPTR,dword ptr [FileSizeLow]
.if eax
mov lpMemory,eax
.else
invoke MessageBox,0,offset szMemoryError,0,MB_OK
invoke ExitProcess,0
.endif

mov esi,lpMemory
add esi,[esi+3ch]
mov lpNtHeader,esi
assume esi:ptr IMAGE_NT_HEADER


_ProcMain endp





_ProcDlgMain proc,hWnd,uMsg,wParam,lParam


mov eax,uMsg
.if eax==WM_INITDIALOG
push hWnd
pop hWindow

.elseif eax==WM_CLOSE
invoke EndDialog,hWnd,0

.elseif eax==WM_COMMAND
mov eax,wParam
    .if ax==BTN_FIND
    call _ProcOpenFile
    .elseif ax==BTN_QUIT
    invoke SendMessage,hWnd,WM_CLOSE,0,0
    .endif
.else
mov eax,FALSE
ret
.endif
mov eax,TRUE
ret

_ProcDlgMain endp



start:
invoke GetModuleHandle,0
mov _hInstance,eax
invoke DialogBoxParam,_hInstance,DLG_MAIN,0,offset _ProcDlgMain,0
invoke ExitProcess,0
end start