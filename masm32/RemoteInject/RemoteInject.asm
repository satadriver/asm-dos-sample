.386
.model flat, stdcall
option casemap:none
include		   \masm32\include\windows.inc
include		   \masm32\include\user32.inc
include		   \masm32\include\kernel32.inc
includelib	         \masm32\lib\user32.lib
includelib	         \masm32\lib\kernel32.lib

.data
pLoadLibraryA	      dd	0
pGetProcAddress         dd	0
pGetModuleHandleA       dd	0
pDllKernel32            dd    0
pRemoteBase	            dd	0
pRemoteThreadBase       dd    0
hDeskTop                dd    0
dwRemoteProcessID	      dd	0
dwRemoteMainThreadID	dd	0
hRemoteProcess	      dd	0
hRemoteMainThread       dd    0


.const
szErrOpen	            db	'无法打开远程线程explorer!',0
szDesktopClassName      db	'Progman',0
szDesktopCaption	      db	'Program Manager',0
szDllKernel32           db	'Kernel32.dll',0
szLoadLibraryA	      db	'LoadLibraryA',0
szGetProcAddress        db	'GetProcAddress',0
szGetModuleHandleA      db	'GetModuleHandleA',0




.code
REMOTE_CODE_START	equ this byte
_pLoadLibraryA	      dd	0
_pGetProcAddress        dd	0
_pGetModuleHandleA      dd	0
_pDllKernel32           dd    0
_pRemoteBase	      dd	0
_pRemoteThreadBase      dd    0
_hDeskTop               dd    0
_dwRemoteProcessID	dd	0
_dwRemoteMainThreadID	dd	0
_hRemoteProcess	      dd	0
_hRemoteMainThread      dd    0


pDllUser32              dd 0  
pMessageBoxA            dd 0 
szDllUser32             db 'User32.dll',0
szMessageBoxA           db 'MessageBoxA',0
szMsgTxt                db 'Hello,Remote Injection!',0dh,0ah,0


_RemoteThread	proc
local DeltaModule

call Coordinate
Coordinate:
pop ebx
sub ebx,offset Coordinate
mov DeltaModule,ebx

mov edi,offset szDllUser32
add edi,DeltaModule
push edi
mov esi,offset _pLoadLibraryA
add esi,DeltaModule
mov esi,[esi]
call esi
mov edi,offset pDllUser32
add edi,DeltaModule
mov [edi],eax

mov esi,offset szMessageBoxA
add esi,DeltaModule
push esi
mov esi,offset pDllUser32
add esi,DeltaModule
mov esi,[esi]
push esi
mov esi,offset _pGetProcAddress
add esi,DeltaModule
mov esi,[esi]
call esi
mov esi,offset pMessageBoxA
add esi,DeltaModule
mov [esi],eax

push MB_OK
push 0
mov eax,offset szMsgTxt
add eax,DeltaModule
push eax
push 0
mov ebx,offset pMessageBoxA
add ebx,DeltaModule
mov ebx,[ebx]
call ebx

ret
_RemoteThread endp

REMOTE_CODE_END		equ this byte
REMOTE_CODE_LENGTH	equ offset REMOTE_CODE_END - offset REMOTE_CODE_START



start:
		invoke GetModuleHandle,addr szDllKernel32
		mov pDllKernel32,eax
		invoke GetProcAddress,pDllKernel32,offset szLoadLibraryA
		mov pLoadLibraryA,eax
		invoke GetProcAddress,pDllKernel32,offset szGetProcAddress
		mov pGetProcAddress,eax
		invoke GetProcAddress,pDllKernel32,offset szGetModuleHandleA
		mov pGetModuleHandleA,eax

		invoke	FindWindow,addr szDesktopClassName,addr szDesktopCaption
            mov         hDeskTop,eax
		invoke	GetWindowThreadProcessId,hDeskTop,offset dwRemoteProcessID
		mov	      dwRemoteMainThreadID,eax
		invoke	OpenProcess,PROCESS_CREATE_THREAD or PROCESS_VM_OPERATION or PROCESS_VM_WRITE,FALSE,dwRemoteProcessID
		.if	eax
			mov	hRemoteProcess,eax
			invoke VirtualAllocEx,hRemoteProcess,NULL,REMOTE_CODE_LENGTH,MEM_COMMIT or MEM_RESERVE,PAGE_EXECUTE_READWRITE
			.if	eax
				mov	 pRemoteBase,eax
				invoke WriteProcessMemory,hRemoteProcess,pRemoteBase,offset REMOTE_CODE_START,REMOTE_CODE_LENGTH,NULL
				invoke WriteProcessMemory,hRemoteProcess,pRemoteBase,offset pLoadLibraryA,44,NULL
				mov	 eax,pRemoteBase
				add	 eax,offset _RemoteThread - offset REMOTE_CODE_START
                        mov    pRemoteThreadBase,eax
				invoke	CreateRemoteThread,hRemoteProcess,NULL,0,pRemoteThreadBase,0,0,NULL
				invoke	CloseHandle,eax
			.endif
			invoke	CloseHandle,hRemoteProcess
		.else
			invoke	MessageBox,NULL,addr szErrOpen,NULL,MB_OK or MB_ICONWARNING
		.endif
		invoke	ExitProcess,NULL
end	start
