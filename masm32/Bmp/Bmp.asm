.686
.model flat,stdcall
option casemap:none
include         \masm32\include\windows.inc
include         \masm32\include\kernel32.inc
include         \masm32\include\user32.inc
include         \masm32\include\gdi32.inc
include         \masm32\include\advapi32.inc
include         \masm32\include\wsock32.inc
include         \masm32\include\comdlg32.inc
includelib      \masm32\lib\ws2_32.lib
includelib      \masm32\lib\kernel32.lib
includelib      \masm32\lib\user32.lib
includelib      \masm32\lib\gdi32.lib
includelib      \masm32\lib\advapi32.lib
includelib      \masm32\lib\comdlg32.lib

DlgMain         =1000h
ButtonOpen      =1001h
ButtonClose     =1002h
EditBmpName     =1003h




.data
dqFileSize      dq 0                ;when global variable is in a expression,it is address!!!!!
pAddress        dd 0                ;parameters entry
PixOffset       dd 0
PixWidth        dd 0
PixHeight       dd 0
PlaneNumber     dd 0
ColorNumber     dd 0
TotalSize       dd 0

hDcBmp          dd 0                ;must be global variable
hInstance       dd 0
hDlgMain        dd 0
hCursor         dd 0
szFileName      db MAX_PATH+1 dup (0)
szFilter        db 'ALL FILES(*.*)',0,'*.*',0,0

szNotExistFile  db 'File Not Found!',0
szMemAllocError db 'Memory Rellocate Error!',0
szWinCaption    db 'Windows Bitmap Viewer------Limited by satadriver@sina.cn',0
szOpenError     db 'File Open Error!',0
szReadError     db 'Read File Error!',0
szNoChoice      db 'You do not choose any BMP files!',0
szClassName     db 'My Class',0  
szWindowError   db 'Create Window Error!',0                         
szNotBmp        db 'Not Bitmap!',0
szCreateDcError db 'Bitmap mapping into DC error!',0

szBmpFormat     db 'BMP     Signature:      %s',0dh,0ah
                db 'Pixel   Offset:         %d',0dh,0ah
                db 'Pixel   Width:          %d',0dh,0ah
                db 'Pixel   Height:         %d',0dh,0ah
                db 'Plane   Number:         %d',0dh,0ah
                db 'Color   Number:         %d',0dh,0ah
                db 'Total   Size:           %d',0dh,0ah,0




.code
ProcWinMain proc,hWnd,uMsg,wParam,lParam        ;lParam can pass parameters,but it is stricted to some instance
local stPs:PAINTSTRUCT
local hDc
local hBmp
local pPixAddress
local bmiAddress
local szBuffer[200h]:byte

mov eax,uMsg
.if eax==WM_PAINT
invoke BeginPaint,hWnd,addr stPs
mov hDc,eax
mov eax,stPs.rcPaint.right
sub eax,stPs.rcPaint.left
mov ecx,stPs.rcPaint.bottom
sub ecx,stPs.rcPaint.top
invoke BitBlt,hDc,stPs.rcPaint.left,stPs.rcPaint.top,eax,ecx,hDcBmp,stPs.rcPaint.left,stPs.rcPaint.top,SRCCOPY
invoke EndPaint,hWnd,addr stPs

.elseif eax==WM_TIMER
invoke InvalidateRect,hWnd,0,0      ;parameters:hwnd,rect,bErase

.elseif eax==WM_CREATE              ;when create window,first parameter from lParam
mov esi,pAddress
mov eax,[esi+10]
mov PixOffset,eax
mov eax,dword ptr [esi+12h]
mov PixWidth,eax
mov eax,dword ptr [esi+16h]
mov PixHeight,eax
mov ax,word ptr [esi+1ah]
movzx eax,ax
mov PlaneNumber,eax
mov ax,word ptr [esi+1ch]
movzx eax,ax
mov ColorNumber,eax
mov eax,[esi+22h]
mov TotalSize,eax
invoke wsprintf,addr szBuffer,addr szBmpFormat,pAddress,PixOffset,PixWidth,PixHeight,PlaneNumber,ColorNumber,TotalSize
lea esi,szBuffer
mov dword ptr [esi+eax],0
invoke MessageBox,0,addr szBuffer,0,MB_OK

mov esi,pAddress
mov eax,[esi+10]
add eax,esi
mov pPixAddress,eax
mov eax,esi
add eax,14
mov bmiAddress,eax

invoke GetDC,hWnd
mov hDc,eax
invoke CreateCompatibleDC,hDc
mov hDcBmp,eax
invoke CreateCompatibleBitmap,hDc,PixWidth,PixHeight
mov hBmp,eax
invoke ReleaseDC,hWnd,hDc
invoke SelectObject,hDcBmp,hBmp
invoke SetDIBitsToDevice,hDcBmp,0,0,PixWidth,PixHeight,0,0,0,PixHeight,pPixAddress,bmiAddress,DIB_RGB_COLORS
.if !eax
invoke MessageBox,0,offset szCreateDcError,offset szCreateDcError,MB_OK
invoke VirtualFree,pAddress,dword ptr [dqFileSize],MEM_DECOMMIT
invoke VirtualFree,pAddress,0,MEM_RELEASE
invoke DeleteDC,hDcBmp
invoke DestroyWindow,hWnd
invoke PostQuitMessage,0
.endif

invoke DeleteObject,hBmp
invoke VirtualFree,pAddress,dword ptr [dqFileSize],MEM_DECOMMIT
invoke VirtualFree,pAddress,0,MEM_RELEASE
invoke SetTimer,hWnd,1,200,0

.elseif eax==WM_CLOSE
invoke DeleteDC,hDcBmp
invoke KillTimer,hWnd,1
invoke DestroyWindow,hWnd
invoke PostQuitMessage,0

.else
invoke DefWindowProc,hWnd,uMsg,wParam,lParam
ret
.endif
xor eax,eax
ret
ProcWinMain endp




ShowBmp proc
local stWndClass:WNDCLASSEX
local stMsg:MSG
local hWinMain
local Counter
local hBmp
local szBuffer[200h]:byte

invoke CreateFile,addr szFileName,GENERIC_READ OR GENERIC_WRITE,FILE_SHARE_READ or FILE_SHARE_WRITE,\
0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
.if eax==INVALID_HANDLE_VALUE
invoke MessageBox,0,offset szNotExistFile,szNotExistFile,MB_OK
ret
.endif
mov hBmp,eax
invoke GetFileSizeEx,hBmp,addr dqFileSize

invoke VirtualAlloc,0,dword ptr [dqFileSize],MEM_RESERVE OR MEM_COMMIT,PAGE_READWRITE
.if eax==0
invoke MessageBox,0,offset szMemAllocError,offset szMemAllocError,MB_OK
ret
.endif
mov pAddress,eax

invoke ReadFile,hBmp,pAddress,dword ptr [dqFileSize],addr Counter,0
.if eax==0
invoke MessageBox,0,offset szReadError,offset szReadError,MB_OK
ret
.else
mov eax,Counter
    .if eax!=dword ptr [dqFileSize]
    invoke MessageBox,0,offset szReadError,offset szReadError,MB_OK
    ret
    .endif
.endif
invoke CloseHandle,hBmp

mov esi,pAddress
cmp word ptr [esi],4d42h
jz Bitmap
cmp word ptr [esi],6d62h
jz Bitmap
NotBitmap:
invoke VirtualFree,pAddress,dword ptr [dqFileSize],MEM_DECOMMIT
invoke VirtualFree,pAddress,0,MEM_RELEASE
invoke MessageBox,0,offset szNotBmp,offset szNotBmp,MB_OK
ret

Bitmap:
mov esi,pAddress
mov dword ptr [esi+2],0
mov eax,[esi+10]
mov PixOffset,eax
mov eax,dword ptr [esi+12h]
mov PixWidth,eax
mov eax,dword ptr [esi+16h]
mov PixHeight,eax
mov ax,word ptr [esi+1ah]
movzx eax,ax
mov PlaneNumber,eax
mov ax,word ptr [esi+1ch]
movzx eax,ax
mov ColorNumber,eax
mov eax,[esi+22h]
mov TotalSize,eax
invoke wsprintf,addr szBuffer,addr szBmpFormat,pAddress,PixOffset,PixWidth,PixHeight,PlaneNumber,ColorNumber,TotalSize
lea esi,szBuffer
mov dword ptr [esi+eax],0
invoke MessageBox,0,addr szBuffer,0,MB_OK

invoke RtlZeroMemory,addr stWndClass,sizeof WNDCLASSEX      ;if without this ,will be erroe here
mov stWndClass.cbSize,sizeof WNDCLASSEX
push hInstance
pop stWndClass.hInstance                    ;all window has one instance?????
push hCursor
pop stWndClass.hCursor                      ;all window has one cursor?????
mov stWndClass.hbrBackground,COLOR_WINDOW+1
mov stWndClass.lpfnWndProc,offset ProcWinMain
mov stWndClass.style,CS_VREDRAW OR CS_HREDRAW
mov stWndClass.lpszClassName,offset szClassName         ;is it right?????can it be a integer?????
invoke RegisterClassEx,addr stWndClass
invoke CreateWindowEx,WS_EX_CLIENTEDGE,offset szClassName,offset szWinCaption,WS_OVERLAPPEDWINDOW,0,0,\
PixWidth,PixHeight,0,0,hInstance,0
.if !eax
invoke VirtualFree,pAddress,dword ptr [dqFileSize],MEM_DECOMMIT
invoke VirtualFree,pAddress,0,MEM_RELEASE
invoke MessageBox,0,offset szWindowError,offset szWindowError,MB_OK
ret
.endif
mov hWinMain,eax
invoke ShowWindow,hWinMain,SW_SHOWNORMAL
invoke UpdateWindow,hWinMain
lea esi,szClassName
inc byte ptr [esi]

.while TRUE
invoke GetMessage,addr stMsg,0,0,0
.break .if eax==0
invoke TranslateMessage,addr stMsg
invoke DispatchMessage,addr stMsg
.endw
ret
ShowBmp endp



OpenFileProc proc
local stOpenFile:OPENFILENAME

invoke RtlZeroMemory,addr stOpenFile,sizeof OPENFILENAME
mov stOpenFile.lStructSize,sizeof OPENFILENAME
mov eax,hDlgMain
mov stOpenFile.hwndOwner,eax
mov stOpenFile.lpstrFilter,offset szFilter
mov stOpenFile.lpstrFile,offset szFileName
mov stOpenFile.nMaxFile,MAX_PATH
mov stOpenFile.Flags,OFN_FILEMUSTEXIST OR OFN_PATHMUSTEXIST
invoke GetOpenFileName,addr stOpenFile      ;return value is user's chioce,if not choose,return 0
.if eax
call ShowBmp
.else
invoke MessageBox,0,offset szNoChoice,offset szNoChoice,MB_OK
.endif
ret
OpenFileProc endp








DlgMainProc proc,hWnd,uMsg,wParam,lparam
mov eax,uMsg

.if eax==WM_COMMAND
mov eax,wParam
    .if ax==ButtonClose
    invoke SendMessage,hWnd,WM_CLOSE,0,0                ;parameters:hwnd,msg,wparam,lparam
    .elseif ax==ButtonOpen
    call OpenFileProc
    .endif
    
.elseif eax==WM_INITDIALOG
push hWnd
pop hDlgMain
invoke LoadCursor,0,IDC_ARROW
mov hCursor,eax

.elseif eax==WM_CLOSE
invoke EndDialog,hWnd,0

.else
mov eax,0
ret
.endif
mov eax,1
ret
DlgMainProc endp




start:
invoke GetModuleHandle,0
mov hInstance,eax
invoke DialogBoxParam,hInstance,DlgMain,0,offset DlgMainProc,0
invoke ExitProcess,0
end start
