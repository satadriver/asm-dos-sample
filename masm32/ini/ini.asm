.386
.model flat,stdcall
option casemap:none
include		\masm32\include\windows.inc
include		\masm32\include\user32.inc
include		\masm32\include\kernel32.inc
include		\masm32\include\advapi32.inc 	;advance api32
includelib		\masm32\lib\advapi32.lib		;advance api32
includelib		\masm32\lib\user32.lib
includelib		\masm32\lib\kernel32.lib

.data
hkResult			dd 0
szFileName                       	db 'win.ini',0

szKeyValue		db 'd:\masm\nn.com',0
szSubKey			db 'Software\Microsoft\Windows\CurrentVersion\Run',0
szKeyName		db 'AutoBootRun',0

szSubKeyName_OpenAsm	db '.asm',0
szSubKeyFile_OpenAsm	db 'asmfile',0
szSubKey_OpenAsm		db 'asmfile\shell\open\command',0
szSubKeyValue_OpenAsm	db 'd:\masm32\qeditor.exe "%1"',0	;c:\windows\system32\Write.exe 

szDeleteKey		db '.asm\persistenthandler',0
szDeleteValue		db 'perceivedtype',0

stSecurityAttributes        	dd 12
                                          	dd 0
                                          	dd 1

szError                                 	db 'Error!',0

szMsg			db 100h dup (0)
wNextLine                           	dw 0a0dh
szInfo                                   	db 100h dup (0)
szBuffer                                	db 0ah,0dh,'Hi,INI file and Registry! I love you!',0ah,0dh

szFormat                              	db 'File Size is :%08d.',0ah,0dh,0
FileWriteCount                    	dd 0
nFileSize                               dd 0
hFileHandle                         	dd 0

.code
start:
invoke CreateFile,offset szFileName,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ \
or FILE_SHARE_WRITE or FILE_SHARE_DELETE,offset stSecurityAttributes,OPEN_ALWAYS,\
FILE_ATTRIBUTE_NORMAL,0
    .if eax==INVALID_HANDLE_VALUE
    call _ExProc
    .endif
mov hFileHandle,eax

invoke SetFilePointer,hFileHandle,0,0,FILE_END
    .if eax==-1
    call _ExProc
    .endif
mov nFileSize,eax
invoke wsprintf,offset szInfo,offset szFormat,nFileSize
invoke MessageBoxA,0,offset szInfo,0,MB_OK

invoke WriteFile,hFileHandle,offset wNextLine,sizeof  szBuffer+sizeof szInfo+2,offset FileWriteCount,0
    .if FileWriteCount!=sizeof szBuffer+sizeof szInfo+2
    call _ExProc
    .endif


invoke RegOpenKeyEx,HKEY_LOCAL_MACHINE,offset szSubKey,0,KEY_ALL_ACCESS,offset hkResult
	.if eax!=ERROR_SUCCESS
    	call _ExProc
    	.endif

invoke RegSetValueEx,hkResult,offset szKeyName,0,REG_SZ,offset szKeyValue,sizeof szKeyValue+1
	.if eax!=ERROR_SUCCESS
    	call _ExProc
    	.endif
invoke RegCloseKey,hkResult



invoke RegDeleteKey,HKEY_CLASSES_ROOT,offset szDeleteKey
invoke RegOpenKeyEx,HKEY_CLASSES_ROOT,offset szSubKeyName_OpenAsm,0,KEY_ALL_ACCESS,offset hkResult
invoke RegDeleteValue,hkResult,offset szDeleteValue

invoke RegCreateKeyEx,HKEY_CLASSES_ROOT,offset szSubKeyName_OpenAsm,0,0,REG_OPTION_NON_VOLATILE,\
KEY_ALL_ACCESS,0,offset hkResult,0
	.if eax!=ERROR_SUCCESS
    	call _ExProc
    	.endif
invoke RegSetValueEx,hkResult,0,0,REG_SZ,offset szSubKeyFile_OpenAsm,sizeof szSubKeyFile_OpenAsm+1
	.if eax!=ERROR_SUCCESS
    	call _ExProc
    	.endif
invoke RegCloseKey,hkResult

invoke RegCreateKeyEx,HKEY_CLASSES_ROOT,offset szSubKey_OpenAsm,0,0,REG_OPTION_NON_VOLATILE,\
KEY_ALL_ACCESS,0,offset hkResult,0
	.if eax!=ERROR_SUCCESS
    	call _ExProc
    	.endif
invoke RegSetValueEx,hkResult,0,0,REG_EXPAND_SZ,offset szSubKeyValue_OpenAsm,sizeof szSubKeyValue_OpenAsm+1
	.if eax!=ERROR_SUCCESS
    	call _ExProc
    	.endif
invoke RegCloseKey,hkResult

invoke lstrcpy,addr szInfo,addr szFileName
invoke lstrcat,addr szInfo,offset szFileName
invoke lstrlen,addr szInfo
invoke wsprintf,offset szMsg,offset szFormat,eax
invoke MessageBoxA,0,offset szMsg,0,MB_OK

invoke GetModuleFileName,0,addr szInfo,260
invoke MessageBox,0,addr szInfo,0,MB_OK
invoke ExitProcess,0

_ExProc proc 
    invoke MessageBoxA,0,offset szError,offset szError,MB_OK    
    invoke CloseHandle,hFileHandle
    invoke RegCloseKey,hkResult
    invoke ExitProcess,0
_ExProc endp
end start