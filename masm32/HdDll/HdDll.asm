.686
.model flat,stdcall
option casemap:none
include         \asm\masm32\include\windows.inc
include         \asm\masm32\include\kernel32.inc
include         \asm\masm32\include\user32.inc
include         \asm\masm32\include\gdi32.inc
include         \asm\masm32\include\advapi32.inc
include         \asm\masm32\include\wsock32.inc
includelib      \asm\masm32\lib\ws2_32.lib
includelib      \asm\masm32\lib\kernel32.lib
includelib      \asm\masm32\lib\user32.lib
includelib      \asm\masm32\lib\gdi32.lib
includelib      \asm\masm32\lib\advapi32.lib

USERNAME_PASSWORD_LEN                           =16
USER_INFO_LEN                                   =34
USER_NAME_LEN                                   =16
USER_PASSWORD_LEN                               =16
UDP_PORT                                        =3308
THREAD_CPU_RATIO                                =4
BUF_MULTI_RATIO                                 =2
MAX_RECORD_SUM                                  =10000h
FILE_POINTDIR_SIZE                              =200000h
FILE_USERINFO_SIZE                              =100000H
ENCRYPTION_KEY                                  =0FFH
UDP_PACKAGE_SIZE                                =512
UDP_PACKAGE_HEADER_SIZE                         =16
RECORDING_INDEX_SIZE                            =32
SMALLEST_SAMPLE_PERIOD                          =20
BOOL_PACK_FLAG                                  =2
FLOAT_PACK_FLAG                                 =1
INVALID_POINT_VALUE                             =0ffffffffh

_DLG_CLIENT_SHOWVALUE                           =1000h
_LIST_CLIENT_SHOWVALUE                          =1001h


.data
align                                           qword
_stSystemInfo                                   SYSTEM_INFO             <>
_stCriticalUserInfo                             CRITICAL_SECTION        <>
_stCriticalPointDir                             CRITICAL_SECTION        <>
_stCriticalReadData                             CRITICAL_SECTION        <>
_stCriticalRealTime                             CRITICAL_SECTION        <>
_stCriticalMemToFile                            CRITICAL_SECTION        <>
_stCriticalDcsToMem                             CRITICAL_SECTION        <>
_stCriticalTransInfo                            CRITICAL_SECTION        <>      ;读文件记录时多线程传递参数

_stRecvAddr                                     sockaddr_in             <> 

szDataBaseFileName                              db 'DataBase.dat',0
szIndexFileName                                 db 'DataBase.idx',0
szPointDirFileName                              db 'PointDir.txt',0
szUserInfoFileName                              db 'UserInfo.txt',0
szJournalFileName                               db 'Journal.txt',0


szClientShowValue                               db '%04d年%02d月%02d日%02d时%02d分%02d秒:%08d',0dh,0ah,0
szInit                                          db ' ',0dh,0ah
                                                db ' ',0dh,0ah
                                                db ' ',0dh,0ah
                                                db '****************************************',0dh,0ah
                                                db '%s数据库开始启动',0dh,0ah
                                                db '****************************************',0dh,0ah,0
szThreadError                                   db '(ERROR)创建线程失败!',0dh,0ah,0
szEventError                                    db '(ERROR)创建事件失败!',0dh,0ah,0
szMemAllocError                                 db '(ERROR)分配内存失败!',0dh,0ah,0
szInputError                                    db '(ERROR)读文件参数错误!',0dh,0ah,0
szSetPriorityClassError                         db '(ERROR)优先级设置错误!',0dh,0ah,0
szFileMapError                                  db '(ERROR)创建文件内存映射失败!',0dh,0ah,0
szFileNoConfig                                  db '(ERROR)未发现配置文件,初始化失败!',0dh,0ah,0

szAdminLogon                                    db 'admin',11 dup (20h),'123456',10 dup (20h),0dh,0ah
szDcsSampleCnt                                  db '检索到的数据记录点数量:%d',0dh,0ah,0
szCreateIndex                                   db '新建索引文件!',0dh,0ah,0
szOpenIndex                                     db '成功打开索引文件!',0dh,0ah,0
szCreateDataBase                                db '新建数据库文件!',0dh,0ah,0
szOpenDataBase                                  db '成功打开数据库文件!',0dh,0ah,0
szCreateJournal                                 db '新建日志文件!',0dh,0ah,0
szOpenJournal                                   db '成功打开日志文件!',0dh,0ah,0
szCreatePointDir                                db '新建点目录文件!',0dh,0ah,0
szOpenPointDir                                  db '成功打开点目录文件!',0dh,0ah,0
szCreateUserInfo                                db '新建用户信息文件',0dh,0ah,0
szOpenUserInfo                                  db '成功打开用户信息文件',0dh,0ah,0
szQuit                                          db '所有线程已退出,数据库即将关闭!',0dh,0ah,0
szSystemTime                                    db '%04d年%02d月%02d日%02d时%02d分%02d秒',0
szPointInsert                                   db '%s在点:%s前成功插入点:%s!',0dh,0ah,0
szPointAdd                                      db '%s成功添加点:%s!',0dh,0ah,0
szPointDelete                                   db '%s成功删除点:%s!',0dh,0ah,0
szPointModify                                   db '%s成功将点:%s修改为点:%s!',0dh,0ah,0
szPointSeek                                     db '%s成功查询点:%s!',0dh,0ah,0
szGetPointTable                                 db '%s成功读取点目录文件!',0dh,0ah,0
szJournalWrite                                  db '%s写入第%d%d条记录,总共耗时%d%d微秒.'
                                                db '当前包括缓冲区在内的总的记录条数为:%d%d',0dh,0ah,0
szJournalPack                                   db '%s为止共计收到%d%d个UDP数据包,共计解包%d%d个UDP个',0dh,0ah,0
szJournalSeek                                   db '%s二分查询次数:%d次,总共耗时:%d微秒',0dh,0ah,0
szJournalRead                                   db '%s读出第%d%d条----第%d%d条记录,总计读出的记录条数:%d,计时:%d微秒!',0dh,0ah,0
szModifyValue                                   db '%s修改从%d%d条开始的%d条记录!',0dh,0ah,0
szEncryptPointDir                               db '%s点目录文件关闭时已经正确加密!',0dh,0ah,0
szDecryptPointDir                               db '%s点目录文件打开时已经正确解密!',0dh,0ah,0
szEncryptUserInfo                               db '%s用户信息文件关闭时已经正确加密!',0dh,0ah,0
szDecryptUserInfo                               db '%s用户信息文件打开时已经正确解密!',0dh,0ah,0
szSeekUserInfo                                  db '%s查询用户信息:%s!',0dh,0ah,0
szAddUserInfo                                   db '%s增加用户信息:%s!',0dh,0ah,0
szDeleteUserInfo                                db '%s删除用户信息:%s!',0dh,0ah,0
szSocketError                                   db '%s网络初始化错误!',0dh,0ah,0
szRecvUdpPackError                              db '%sUDP数据包传送中出现错误，是否因为程序已退出？',0dh,0ah,0   
szRecordingWriteError                           db '%s写入记录过程中发生错误,错误码为:%d!',0dh,0ah,0
szUdpUnpackQuit                                 db 'UdpUnpack terminate!',0dh,0ah,0
szRecvUdpPackQuit                               db 'RecvUdp terminate!',0dh,0ah,0
szStoreRecordingQuit                            db 'StoreRecord terminate!',0dh,0ah,0
szWaitSamplePeriodQuit                          db 'WaitPeriod terminate!',0dh,0ah,0
szMsgException                                  db '%s程序发生严重异常,异常地址为:%08x,异常错误码为:%08x,异常标志位:%08x!',0dh,0ah,0
szExceptionGetDcsData                           db '%sDCS数据缓存发生异常,异常地址为:%d!',0dh,0ah,0                            

szDllEntry                                      db 'DllEntry函数加载地址为:                     %08x',0dh,0ah,0
szProcTerminate                                 db '_ProcTerminate函数加载地址为:               %08x',0dh,0ah,0
szProcInit                                      db '_ProcInit函数加载地址为:                    %08x',0dh,0ah,0   
szProcOpenFile                                  db '_ProcOpenFile函数加载地址为:                %08x',0dh,0ah,0 
szProcModifyData                                db '_ProcModifyData函数加载地址为:              %08x',0dh,0ah,0
szProcReadData                                  db '_ProcReadData函数加载地址为:                %08x',0dh,0ah,0
szProcReadInterval                              db '_ProcReadInterval函数加载地址为:            %08x',0dh,0ah,0
szThreadReadData                                db '_ThreadReadData线程加载地址为:              %08x',0dh,0ah,0     
szThreadSeekIndex                               db '_ThreadSeekIndex线程加载地址为:             %08x',0dh,0ah,0
szThreadReadSector                              db '_ThreadReadSector线程加载地址为:            %08x',0dh,0ah,0
szThreadWaitSamplePeriod                        db '_ThreadWaitSamplePeriod线程加载地址为:      %08x',0dh,0ah,0
szThreadRecvUdpPack                             db '_ThreadRecvUdpPack线程加载地址为:           %08x',0dh,0ah,0
szThreadUdpUnpack                               db '_ThreadUdpUnpack线程加载地址为:             %08x',0dh,0ah,0
szThreadStoreRecording                          db '_ThreadStoreRecording线程加载地址为:        %08x',0dh,0ah,0
szThreadJournalOfWriteInfo                      db '_ThreadJournalOfWriteInfo线程加载地址为:    %08x',0dh,0ah,0 
szThreadRealTimeData                            db '_ThreadRealTimeData线程加载地址为:          %08x',0dh,0ah,0
szProcRegistryInfo                              db '_ProcRegistryInfo函数加载地址为:            %08x',0dh,0ah,0
szProcGetRealTimeData                           db '_ProcGetRealTimeData函数加载地址为:         %08x',0dh,0ah,0   
szProcInsertPoint                               db '_ProcInsertPoint函数加载地址为:             %08x',0dh,0ah,0
szProcAddPoint                                  db '_ProcAddPoint函数地加载址为:                %08x',0dh,0ah,0
szProcDeletePoint                               db '_ProcDeletePoint函数加载地址为:             %08x',0dh,0ah,0
szProcModifyPoint                               db '_ProcModifyPoint函数加载地址为:             %08x',0dh,0ah,0         
szProcSeekPoint                                 db '_ProcSeekPoint函数加载地址为:               %08x',0dh,0ah,0
szProcGetPointTable                             db '_ProcGetPointTable函数加载地址为:           %08x',0dh,0ah,0
szProcSeekUser                                  db '_ProcSeekUser函数加载地址为:                %08x',0dh,0ah,0
szProcAddUser                                   db '_ProcAddUser函数加载地址为:                 %08x',0dh,0ah,0
szProcDeleteUser                                db '_ProcDeleteUser函数加载地址为:              %08x',0dh,0ah,0

align                           qword
_dqRecvPackCnt                  dq 0
_dqUnPackCnt                    dq 0
_dqRecordingCntSum              dq 0
_dqFileTotalRecording           dq 0
_hSockRecv                      dd 0
_dwSamplePeriod                 dd 200 
_dwStoreRecordingPeriod         dd 16000 
     
_dwDcsSampleCnt                 dd 0
_dwFreeRecordCnt                dd 0
_dwDataRecordingSize            dd 0

_lpUdpPackRecvBuf               dd 0
_lpUdpPackRecvBufHead           dd 0
_lpUdpPackRecvBufEnd            dd 0
_lpUdpPackRecvBufLimit          dd 0
_dwUdpPackRecvBufSize           dd 0

_lpUdpPackAddrBuf               dd 0
_lpUdpPackAddrBufHead           dd 0
_lpUdpPackAddrBufEnd            dd 0
_lpUdpPackAddrBufLimit          dd 0
_dwUdpPackAddrBufSize           dd 0

_dwRecordingCntOfBuf            dd 0
_dwRecordingLimitOfBuf          dd 0
      
_lpRecordingBuf                 dd 0
_lpRecordingBufHead             dd 0
_lpRecordingBufEnd              dd 0
_lpRecordingBufLimit            dd 0
_dwRecordingBufSize             dd 0

_lpRecordReservedBuf            dd 0
_lpRecordReservedBufHead        dd 0
_lpRecordReservedBufLimit       dd 0
_lpIndexReservedBuf             dd 0
_lpIndexReservedBufHead         dd 0
_lpIndexReservedBufLimit        dd 0

_lpRecordingIndexBuf            dd 0
_lpRecordingIndexBufHead        dd 0
_lpRecordingIndexBufEnd         dd 0
_lpRecordingIndexBufLimit       dd 0  
_dwRecordingIndexBufSize        dd 0

_lpPointDirBuf                  dd 0
_dwPointDirBufSize              dd 0
_lpUserInfoBuf                  dd 0
_dwUserInfoBufSize              dd 0

_lpReadQueueInfoBuf             dd 0
_dwReadQueueInfoBufSize         dd 0
_dwRltDataTableBufSize          dd 0
_lpRltDataTableBuf              dd 0

_hFileDataBase                  dd 0
_hFileIndex                     dd 0
_hFilePointDir                  dd 0
_hFileJournal                   dd 0
_hFileUserInfo                  dd 0
_hFileMappingUserInfo           dd 0
_hFileMapPointDir               dd 0

_hThreadWaitSamplePeriod        dd 0
_hThreadRecvUdpPack             dd 0
_hThreadUdpUnpack               dd 0
_hThreadStoreRecording          dd 0
_hThreadRealTimeData            dd 0

_lpRealTimeDataBuf              dd 0

_hEventRealTimeData             dd 0
_hEventStoreRecording           dd 0

_hDllInstance                   dd 0
_hThisProcess                   dd 0

_dwSecsPerClu                   dd 0
_dwBytesPerSec                  dd 0
_dwFreeCluCnt                   dd 0
_dwCluCnt                       dd 0

_flTerminate                    dd 0
_dwRunningThreadCnt             dd 0
_lpOldExceptionFilter           dd 0

_hDlgShowValue                  dd 0

szOpenScmError                          db 'scm error',0
szOpenServiceError                      db 'open Service error',0
szRegistryServiceError                  db 'Registry error',0
szDispatcherServiceError                db 'dispatcher error',0
szServiceName                           db '清竹公司大数据处理服务',0
szModuleFileName                        db 'D:\masm32\hddata\hddll\IOCPServerWin32Console.exe',0





.code

DllEntry proc,hDllInstance,dwReason,dwReserved
mov eax,dwReason
.if eax==DLL_PROCESS_ATTACH
push            hDllInstance
pop             _hDllInstance
mov eax,TRUE
leave
retn 12
.elseif eax==DLL_THREAD_ATTACH
mov eax,TRUE
leave 
retn 12
.elseif eax==DLL_THREAD_DETACH
mov eax,TRUE
leave
retn 12
.elseif eax==DLL_PROCESS_DETACH               ;为何此处不能设置为自动退出？因为手动调用了_ProcTerminate,若进程再次调用则发生异常
call _ProcTerminate
mov eax,TRUE
leave
retn 12
.endif
DllEntry endp










_ProcTerminate proc
local @szBuf[200h]:byte
local @szBuffer[100h]:byte
local @dwCounter

push ebx
push esi
push edi

cld
invoke EnterCriticalSection,addr _stCriticalPointDir

jmp DebugModeNoEncrypt

mov esi,_lpPointDirBuf
mov eax,FILE_POINTDIR_SIZE
cmp dword ptr [eax+esi-8],1
jz PointDirEncrypted
mov dword ptr [eax+esi-8],1
mov esi,_lpPointDirBuf
mov edi,_lpPointDirBuf
mov ecx,FILE_POINTDIR_SIZE
sub ecx,8
EncryptePointDir:
lodsb
xor al,ENCRYPTION_KEY
stosb
loop EncryptePointDir
PointDirEncrypted:
lea eax,@szBuffer
push eax
call _ProcSysTimeToAsc
invoke wsprintf,addr @szBuf,addr szEncryptPointDir,addr @szBuffer
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0

DebugModeNoEncrypt:

mov esi,_lpUserInfoBuf
mov ebx,FILE_USERINFO_SIZE
cmp dword ptr [esi+ebx-8],1
jz FileInfoEncrypt
mov dword ptr [esi+ebx-8],1
mov ecx,FILE_USERINFO_SIZE
sub ecx,8
mov esi,_lpUserInfoBuf
mov edi,esi
DecryptUserInfo:
lodsb
xor al,ENCRYPTION_KEY
stosb
loop DecryptUserInfo
FileInfoEncrypt:
lea eax,@szBuffer
push eax
call _ProcSysTimeToAsc
invoke wsprintf,addr @szBuf,addr szEncryptUserInfo,addr @szBuffer
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0  

invoke closesocket,_hSockRecv
invoke WSACleanup
mov _flTerminate,1
WaitConsoleThreadRet:
cmp _dwRunningThreadCnt,0
jnz WaitConsoleThreadRet
invoke WriteFile,_hFileJournal,addr szQuit,sizeof szQuit-1,addr @dwCounter,0

mov esi,_lpRltDataTableBuf
mov ecx,_dwRltDataTableBufSize
shr ecx,3
CheckPointOrdinal:
push ecx
push esi
lodsd
cmp eax,0ffffffffh
jnz GetValidService
GetNextValidService:
pop esi
add esi,8
pop ecx
loop CheckPointOrdinal
jmp NotFoundValidService
GetValidService:
mov edi,[esi]
mov dword ptr [esi],0ffffffffh
mov dword ptr [esi-4],0ffffffffh
push edi
invoke VirtualFree,edi,_stSystemInfo.dwPageSize,MEM_DECOMMIT           
pop edi
invoke VirtualFree,edi,0,MEM_RELEASE
jmp GetNextValidService

NotFoundValidService:
invoke VirtualFree,_lpUdpPackRecvBuf,_dwUdpPackRecvBufSize,MEM_DECOMMIT
invoke VirtualFree,_lpUdpPackRecvBuf,0,MEM_RELEASE
invoke VirtualFree,_lpUdpPackAddrBuf,_dwUdpPackAddrBufSize,MEM_DECOMMIT
invoke VirtualFree,_lpUdpPackAddrBuf,0,MEM_RELEASE
invoke VirtualFree,_lpRecordingBuf,_dwRecordingBufSize,MEM_DECOMMIT
invoke VirtualFree,_lpRecordingBuf,0,MEM_RELEASE
invoke VirtualFree,_lpRecordReservedBuf,_dwRecordingBufSize,MEM_DECOMMIT
invoke VirtualFree,_lpRecordReservedBuf,0,MEM_RELEASE
invoke VirtualFree,_lpRecordingIndexBuf,_dwRecordingIndexBufSize,MEM_DECOMMIT
invoke VirtualFree,_lpRecordingIndexBuf,0,MEM_RELEASE
invoke VirtualFree,_lpIndexReservedBuf,_dwRecordingIndexBufSize,MEM_DECOMMIT
invoke VirtualFree,_lpIndexReservedBuf,0,MEM_RELEASE
invoke VirtualFree,_lpRltDataTableBuf,_dwRltDataTableBufSize,MEM_DECOMMIT
invoke VirtualFree,_lpRltDataTableBuf,0,MEM_RELEASE
invoke VirtualFree,_lpReadQueueInfoBuf,_dwReadQueueInfoBufSize,MEM_DECOMMIT
invoke VirtualFree,_lpReadQueueInfoBuf,0,MEM_RELEASE

invoke UnmapViewOfFile,_lpPointDirBuf
invoke CloseHandle,_hFileMapPointDir
invoke CloseHandle,_hFilePointDir
invoke UnmapViewOfFile,_lpUserInfoBuf
invoke CloseHandle,_hFileMappingUserInfo
invoke CloseHandle,_hFileUserInfo
invoke CloseHandle,_hEventStoreRecording
invoke CloseHandle,_hEventRealTimeData
invoke CloseHandle,_hThreadWaitSamplePeriod
invoke CloseHandle,_hThreadRealTimeData
invoke CloseHandle,_hThreadUdpUnpack
invoke CloseHandle,_hThreadStoreRecording
invoke CloseHandle,_hThreadRecvUdpPack
invoke CloseHandle,_hFileDataBase
invoke CloseHandle,_hFileIndex 

invoke CloseHandle,_hFileJournal
invoke LeaveCriticalSection,addr _stCriticalPointDir
invoke DeleteCriticalSection,addr _stCriticalUserInfo
invoke DeleteCriticalSection,addr _stCriticalPointDir
invoke DeleteCriticalSection,addr _stCriticalDcsToMem
invoke DeleteCriticalSection,addr _stCriticalMemToFile
invoke DeleteCriticalSection,addr _stCriticalRealTime
invoke DeleteCriticalSection,addr _stCriticalReadData
invoke DeleteCriticalSection,addr _stCriticalTransInfo
invoke SetUnhandledExceptionFilter,_lpOldExceptionFilter
invoke ExitProcess,0
pop edi
pop esi
pop ebx
mov eax,1
mov edx,0
leave
retn 0                            
_ProcTerminate endp










_ProcInit proc
local @stWsaData:WSADATA
local @dwCounter
local @szBuffer[100h]:byte
local @szBuf[200h]:byte

push ebx
push esi
push edi     
call _ProcOpenFile

invoke WSAStartup,0202h,addr @stWsaData
        .if eax!=ERROR_SUCCESS
        jmp WsaStartupError
        .endif
invoke socket,AF_INET,SOCK_DGRAM,IPPROTO_UDP
        .if eax==SOCKET_ERROR
        jmp SocketError
        .endif
mov _hSockRecv,eax
mov _stRecvAddr.sin_family,AF_INET
invoke htons,UDP_PORT
mov _stRecvAddr.sin_port,ax
mov _stRecvAddr.sin_addr,INADDR_ANY
invoke bind,_hSockRecv,addr _stRecvAddr,sizeof sockaddr_in
        .if eax==SOCKET_ERROR
        invoke closesocket,_hSockRecv
        SocketError:
        invoke WSACleanup
        WsaStartupError:
        lea eax,@szBuffer
        push eax
        call _ProcSysTimeToAsc
        invoke wsprintf,addr @szBuf,addr szSocketError,addr @szBuffer
        mov ecx,eax
        invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
        call _ProcTerminate
        invoke ExitProcess,0  
        .endif 

lea ebx,_ProcNewExceptionFilter
invoke SetUnhandledExceptionFilter,ebx
mov _lpOldExceptionFilter,eax
invoke InitializeCriticalSection,addr _stCriticalUserInfo
invoke InitializeCriticalSection,addr _stCriticalPointDir
invoke InitializeCriticalSection,addr _stCriticalDcsToMem
invoke InitializeCriticalSection,addr _stCriticalMemToFile
invoke InitializeCriticalSection,addr _stCriticalRealTime
invoke InitializeCriticalSection,addr _stCriticalReadData
invoke InitializeCriticalSection,addr _stCriticalTransInfo

mov ebx,_stSystemInfo.dwPageSize
mov ecx,ebx
shl ecx,BUF_MULTI_RATIO
mov eax,_dwDcsSampleCnt
shl eax,2
add eax,sizeof SYSTEMTIME
push eax
push ebx
dec ebx
and eax,ebx
pop ebx
sub ebx,eax
add ecx,ebx
pop eax
add eax,ecx
mov _dwDataRecordingSize,eax
shr ecx,2
mov _dwFreeRecordCnt,ecx

mov eax,_dwStoreRecordingPeriod
mov edx,0
mov ebx,_dwSamplePeriod
div ebx
mov _dwRecordingLimitOfBuf,eax
mov ebx,_dwDataRecordingSize
mul ebx
shl eax,BUF_MULTI_RATIO
mov _dwRecordingBufSize,eax
invoke VirtualAlloc,NULL,_dwRecordingBufSize,MEM_COMMIT,PAGE_READWRITE
        .if eax==0
        invoke WriteFile,_hFileJournal,addr szMemAllocError,sizeof szMemAllocError-1,addr @dwCounter,0
        call _ProcTerminate
        .endif
mov _lpRecordingBuf,eax 
mov _lpRecordingBufHead,eax
mov _lpRecordingBufEnd,eax
mov ecx,_dwRecordingBufSize
shr ecx,BUF_MULTI_RATIO
add eax,ecx
mov _lpRecordingBufLimit,eax

invoke VirtualAlloc,NULL,_dwRecordingBufSize,MEM_COMMIT,PAGE_READWRITE
        .if eax==0
        invoke WriteFile,_hFileJournal,addr szMemAllocError,sizeof szMemAllocError-1,addr @dwCounter,0
        call _ProcTerminate
        .endif
mov _lpRecordReservedBuf,eax 
mov _lpRecordReservedBufHead,eax
mov ecx,_dwRecordingBufSize
shr ecx,BUF_MULTI_RATIO
add eax,ecx
mov _lpRecordReservedBufLimit,eax

mov eax,_dwRecordingLimitOfBuf
mov ebx,RECORDING_INDEX_SIZE
mul ebx
shl eax,BUF_MULTI_RATIO
mov _dwRecordingIndexBufSize,eax
invoke VirtualAlloc,NULL,_dwRecordingIndexBufSize,MEM_COMMIT,PAGE_READWRITE
        .if eax==0
        invoke WriteFile,_hFileJournal,addr szMemAllocError,sizeof szMemAllocError-1,addr @dwCounter,0
        call _ProcTerminate
        .endif
mov _lpRecordingIndexBuf,eax
mov _lpRecordingIndexBufHead,eax
mov _lpRecordingIndexBufEnd,eax
mov ecx,_dwRecordingIndexBufSize
shr ecx,BUF_MULTI_RATIO
add eax,ecx
mov _lpRecordingIndexBufLimit,eax

invoke VirtualAlloc,NULL,_dwRecordingIndexBufSize,MEM_COMMIT,PAGE_READWRITE
        .if eax==0
        invoke WriteFile,_hFileJournal,addr szMemAllocError,sizeof szMemAllocError-1,addr @dwCounter,0
        call _ProcTerminate
        .endif
mov _lpIndexReservedBuf,eax
mov _lpIndexReservedBufHead,eax
mov ecx,_dwRecordingIndexBufSize
shr ecx,BUF_MULTI_RATIO
add eax,ecx
mov _lpIndexReservedBufLimit,eax

mov eax,_dwRecordingBufSize
mov _dwUdpPackRecvBufSize,eax 
invoke VirtualAlloc,NULL,_dwUdpPackRecvBufSize,MEM_COMMIT,PAGE_READWRITE
        .if eax==0
        invoke WriteFile,_hFileJournal,addr szMemAllocError,sizeof szMemAllocError-1,addr @dwCounter,0
        call _ProcTerminate
        .endif
mov _lpUdpPackRecvBuf,eax
mov _lpUdpPackRecvBufHead,eax
mov _lpUdpPackRecvBufEnd,eax
add eax,_dwUdpPackRecvBufSize
mov _lpUdpPackRecvBufLimit,eax

mov eax,_dwUdpPackRecvBufSize
mov edx,0
mov ebx,UDP_PACKAGE_SIZE
div ebx
mov _dwUdpPackAddrBufSize,eax
invoke VirtualAlloc,NULL,_dwUdpPackAddrBufSize,MEM_COMMIT,PAGE_READWRITE
        .if eax==0
        invoke WriteFile,_hFileJournal,addr szMemAllocError,sizeof szMemAllocError-1,addr @dwCounter,0
        call _ProcTerminate
        .endif
mov _lpUdpPackAddrBuf,eax
mov _lpUdpPackAddrBufHead,eax
mov _lpUdpPackAddrBufEnd,eax
add eax,_dwUdpPackAddrBufSize
mov _lpUdpPackAddrBufLimit,eax

mov eax,_stSystemInfo.dwPageSize
mov _dwRltDataTableBufSize,eax
invoke VirtualAlloc,NULL,_dwRltDataTableBufSize,MEM_COMMIT,PAGE_READWRITE
        .if eax==0
        invoke WriteFile,_hFileJournal,addr szMemAllocError,sizeof szMemAllocError-1,addr @dwCounter,0
        call _ProcTerminate
        .endif
mov _lpRltDataTableBuf,eax
mov edi,eax
mov ecx,_dwRltDataTableBufSize
shr ecx,2
mov eax,0ffffffffh
cld
rep stosd

mov eax,_stSystemInfo.dwPageSize
mov _dwReadQueueInfoBufSize,eax
invoke VirtualAlloc,NULL,_dwReadQueueInfoBufSize,MEM_COMMIT,PAGE_READWRITE
        .if eax==0
        invoke WriteFile,_hFileJournal,addr szMemAllocError,sizeof szMemAllocError-1,addr @dwCounter,0
        call _ProcTerminate
        .endif
mov _lpReadQueueInfoBuf,eax

invoke CreateEvent,NULL,TRUE,FALSE,NULL
        .if eax==0
        invoke WriteFile,_hFileJournal,addr szEventError,sizeof szEventError-1,addr @dwCounter,0
        call _ProcTerminate
        .endif
mov _hEventStoreRecording,eax  
invoke CreateEvent,NULL,TRUE,FALSE,NULL
        .if eax==0
        invoke WriteFile,_hFileJournal,addr szEventError,sizeof szEventError-1,addr @dwCounter,0
        call _ProcTerminate
        .endif
mov _hEventRealTimeData,eax                     ;自动事件会丢失数据，为什么？？？

lea ebx,_ThreadRealTimeData
invoke CreateThread,0,0,ebx,0,0,0
        .if eax==0
        invoke WriteFile,_hFileJournal,addr szThreadError,sizeof szThreadError-1,addr @dwCounter,0
        call _ProcTerminate
        .endif
mov _hThreadRealTimeData,eax
lea ebx,_ThreadStoreRecording
invoke CreateThread,0,0,ebx,0,0,0
        .if eax==0
        invoke WriteFile,_hFileJournal,addr szThreadError,sizeof szThreadError-1,addr @dwCounter,0
        call _ProcTerminate
        .endif
mov _hThreadStoreRecording,eax
lea ebx,_ThreadUdpUnpack
invoke CreateThread,0,0,ebx,0,0,0
        .if eax==0
        invoke WriteFile,_hFileJournal,addr szThreadError,sizeof szThreadError-1,addr @dwCounter,0
        call _ProcTerminate
        .endif
mov _hThreadUdpUnpack,eax

lea ebx, _ThreadRecvUdpPack
invoke CreateThread,0,0,ebx,0,0,0
        .if eax==0
        invoke WriteFile,_hFileJournal,addr szThreadError,sizeof szThreadError-1,addr @dwCounter,0
        call _ProcTerminate
        .endif
mov _hThreadRecvUdpPack,eax

lea ebx,_ThreadWaitSamplePeriod
invoke CreateThread,0,0,ebx,0,0,0
        .if eax==0
        invoke WriteFile,_hFileJournal,addr szThreadError,sizeof szThreadError-1,addr @dwCounter,0
        call _ProcTerminate
        .endif
mov _hThreadWaitSamplePeriod,eax

pop edi
pop esi
pop ebx
mov eax,1
mov edx,0
leave
retn 0                          ; 为何不能用RET指令:RET是宏指令,RETN是机器码
_ProcInit endp













_ProcOpenFile proc 
local @stOverlappedRead:OVERLAPPED
local @dwCounter
local @dqFileSize:qword
local @lpFileBuf
local @lpPointDirEnd
local @dwPointDirOrdinal
local @lpCurrentPointHead
local @dwPointIdLen
local @szBuffer[100h]:byte
local @szBuf[400h]:byte

push ebx
push esi
push edi
invoke GetDiskFreeSpace,0,offset _dwSecsPerClu,offset _dwBytesPerSec,offset _dwFreeCluCnt,offset _dwCluCnt
invoke GetSystemInfo,addr _stSystemInfo
invoke CreateFile,offset szJournalFileName,GENERIC_READ OR GENERIC_WRITE,FILE_SHARE_READ,0,OPEN_EXISTING,\
FILE_ATTRIBUTE_NORMAL or FILE_FLAG_RANDOM_ACCESS ,NULL
        .if eax==INVALID_HANDLE_VALUE
        invoke CreateFile,offset szJournalFileName,GENERIC_READ OR GENERIC_WRITE,FILE_SHARE_READ,0,CREATE_ALWAYS,\
        FILE_ATTRIBUTE_NORMAL or FILE_FLAG_RANDOM_ACCESS,NULL
        mov _hFileJournal,eax
        lea eax,@szBuffer
        push eax
        call _ProcSysTimeToAsc        
        invoke wsprintf,addr @szBuf,addr szInit,addr @szBuffer
        mov ecx,eax
        invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
        invoke WriteFile,_hFileJournal,addr szCreateJournal,sizeof szCreateJournal-1,addr @dwCounter,0
        .else
        mov _hFileJournal,eax  
        invoke SetFilePointerEx,_hFileJournal,0,0,0,FILE_END
        lea eax,@szBuffer
        push eax
        call _ProcSysTimeToAsc
        invoke wsprintf,addr @szBuf,addr szInit,addr @szBuffer
        mov ecx,eax
        invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
        invoke WriteFile,_hFileJournal,addr szOpenJournal,sizeof szOpenJournal-1,addr @dwCounter,0
        .endif

lea ebx,DllEntry
invoke wsprintf,addr @szBuf,addr szDllEntry,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcTerminate
invoke wsprintf,addr @szBuf,addr szProcTerminate,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcInit
invoke wsprintf,addr @szBuf,addr szProcInit,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcOpenFile
invoke wsprintf,addr @szBuf,addr szProcOpenFile,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcModifyData
invoke wsprintf,addr @szBuf,addr szProcModifyData,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcReadData
invoke wsprintf,addr @szBuf,addr szProcReadData,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ThreadReadData
invoke wsprintf,addr @szBuf,addr szThreadReadData,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ThreadSeekIndex
invoke wsprintf,addr @szBuf,addr szThreadSeekIndex,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ThreadReadSector
invoke wsprintf,addr @szBuf,addr szThreadReadSector,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcReadInterval
invoke wsprintf,addr @szBuf,addr szProcReadInterval,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ThreadWaitSamplePeriod
invoke wsprintf,addr @szBuf,addr szThreadWaitSamplePeriod,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ThreadRecvUdpPack
invoke wsprintf,addr @szBuf,addr szThreadRecvUdpPack,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ThreadUdpUnpack
invoke wsprintf,addr @szBuf,addr szThreadUdpUnpack,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ThreadStoreRecording
invoke wsprintf,addr @szBuf,addr szThreadStoreRecording,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ThreadJournalOfWriteInfo
invoke wsprintf,addr @szBuf,addr szThreadJournalOfWriteInfo,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ThreadRealTimeData
invoke wsprintf,addr @szBuf,addr szThreadRealTimeData,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcRegistryInfo
invoke wsprintf,addr @szBuf,addr szProcRegistryInfo,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcGetRealTimeData
invoke wsprintf,addr @szBuf,addr szProcGetRealTimeData,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcInsertPoint
invoke wsprintf,addr @szBuf,addr szProcInsertPoint,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcAddPoint
invoke wsprintf,addr @szBuf,addr szProcAddPoint,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcDeletePoint
invoke wsprintf,addr @szBuf,addr szProcDeletePoint,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcModifyPoint
invoke wsprintf,addr @szBuf,addr szProcModifyPoint,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcSeekPoint
invoke wsprintf,addr @szBuf,addr szProcSeekPoint,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcGetPointTable
invoke wsprintf,addr @szBuf,addr szProcGetPointTable,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcSeekUser
invoke wsprintf,addr @szBuf,addr szProcSeekUser,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcAddUser
invoke wsprintf,addr @szBuf,addr szProcAddUser,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea ebx,_ProcDeleteUser
invoke wsprintf,addr @szBuf,addr szProcDeleteUser,ebx
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0

invoke CreateFile,offset szDataBaseFileName,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ,0,OPEN_EXISTING,\
FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED or FILE_FLAG_NO_BUFFERING or FILE_FLAG_WRITE_THROUGH or \
FILE_FLAG_SEQUENTIAL_SCAN,NULL
        .if eax==INVALID_HANDLE_VALUE
        invoke CreateFile,offset szDataBaseFileName,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ,0,CREATE_ALWAYS,\
        FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED or FILE_FLAG_NO_BUFFERING or FILE_FLAG_WRITE_THROUGH or \
        FILE_FLAG_SEQUENTIAL_SCAN,NULL
        mov _hFileDataBase,eax
        invoke WriteFile,_hFileJournal,addr szCreateDataBase,sizeof szCreateDataBase-1,addr @dwCounter,0
        .else
        mov _hFileDataBase,eax
        invoke WriteFile,_hFileJournal,addr szOpenDataBase,sizeof szOpenDataBase-1,addr @dwCounter,0
        .endif

invoke VirtualAlloc,0,dword ptr _stSystemInfo.dwPageSize,MEM_COMMIT,PAGE_READWRITE
        .if eax==0
        invoke WriteFile,_hFileJournal,addr szMemAllocError,sizeof szMemAllocError-1,addr @dwCounter,0
        call _ProcTerminate
        .endif
mov @lpFileBuf,eax
invoke CreateFile,offset szIndexFileName,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ,0,OPEN_EXISTING,\
FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED or FILE_FLAG_NO_BUFFERING or FILE_FLAG_WRITE_THROUGH or \
FILE_FLAG_SEQUENTIAL_SCAN,NULL
        .if eax!=INVALID_HANDLE_VALUE
        mov _hFileIndex,eax
        invoke GetFileSizeEx,_hFileIndex,addr @dqFileSize
        mov eax,dword ptr [@dqFileSize]
        mov edx,dword ptr [@dqFileSize+4]
        sub eax,_dwBytesPerSec
        sbb edx,0 
        lea esi,@stOverlappedRead
        mov dword ptr [esi+8],eax         
        mov dword ptr [esi+12],edx
        mov dword ptr [esi],0
        mov dword ptr [esi+4],0
        invoke CreateEvent,0,TRUE,0,0
        mov @stOverlappedRead.hEvent,eax
        invoke ReadFile,_hFileIndex,@lpFileBuf,_dwBytesPerSec,addr @dwCounter,addr @stOverlappedRead
                .if eax==0
                invoke GetLastError
                        .if eax==ERROR_IO_PENDING      
                        invoke WaitForSingleObject,@stOverlappedRead.hEvent,INFINITE
                        invoke GetOverlappedResult,_hFileIndex,addr @stOverlappedRead,addr @dwCounter,TRUE
                        mov eax,@dwCounter
                                .if eax==_dwBytesPerSec
                                jmp ToGetRecordCntSum
                                .else
                                jmp ToCreateNewIndexFile                    
                                .endif
                        .elseif eax==ERROR_HANDLE_EOF
                        jmp ToCreateNewIndexFile
                        .else
                        jmp ToCreateNewIndexFile                        
                        .endif
                .else
                mov eax,@dwCounter
                        .if eax==_dwBytesPerSec
                        ToGetRecordCntSum:
                        sub eax,16
                        mov esi,@lpFileBuf
                        mov edx,[eax+esi]
                        mov dword ptr [_dqRecordingCntSum],edx
                        mov edx,[eax+esi+4]   
                        mov dword ptr [_dqRecordingCntSum+4],edx
                        invoke WriteFile,_hFileJournal,addr szOpenIndex,sizeof szOpenIndex-1,addr @dwCounter,0  
                        .else
                        jmp ToCreateNewIndexFile
                        .endif   
                .endif 
        .else
        ToCreateNewIndexFile:
        invoke CreateFile,offset szIndexFileName,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ,0,CREATE_ALWAYS,\
        FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED or FILE_FLAG_NO_BUFFERING or FILE_FLAG_WRITE_THROUGH or \
        FILE_FLAG_SEQUENTIAL_SCAN,NULL
        mov _hFileIndex,eax          
        mov dword ptr _dqRecordingCntSum,0
        mov dword ptr [_dqRecordingCntSum+4],0
        invoke WriteFile,_hFileJournal,addr szCreateIndex,sizeof szCreateIndex-1,addr @dwCounter,0
        .endif
invoke CloseHandle,@stOverlappedRead.hEvent
invoke VirtualFree,@lpFileBuf,_stSystemInfo.dwPageSize,MEM_DECOMMIT
invoke VirtualFree,@lpFileBuf,0,MEM_RELEASE

invoke CreateFile,offset szPointDirFileName,GENERIC_READ OR GENERIC_WRITE,0,0,OPEN_EXISTING,\
FILE_ATTRIBUTE_NORMAL or FILE_FLAG_RANDOM_ACCESS,NULL
        .if eax!=INVALID_HANDLE_VALUE
        mov _hFilePointDir,eax       
        invoke WriteFile,_hFileJournal,addr szOpenPointDir,sizeof szOpenPointDir-1,addr @dwCounter,0
        ToMemMapping:
        invoke GetFileSizeEx,_hFilePointDir,addr @dqFileSize
        invoke CreateFileMapping,_hFilePointDir,0,PAGE_READWRITE,0,FILE_POINTDIR_SIZE,0         ;计算方式比例大约为每条记录128B
                .if eax==0
                invoke WriteFile,_hFileJournal,addr szFileMapError,sizeof szFileMapError-1,addr @dwCounter,0
                call _ProcTerminate
                .endif  
        mov _hFileMapPointDir,eax
        invoke MapViewOfFile,_hFileMapPointDir,FILE_MAP_READ or FILE_MAP_WRITE,0,0,0
                .if eax==0
                invoke WriteFile,_hFileJournal,addr szFileMapError,sizeof szFileMapError-1,addr @dwCounter,0
                call _ProcTerminate
                .endif  
        mov _lpPointDirBuf,eax
        mov esi,FILE_POINTDIR_SIZE
        cmp dword ptr [eax+esi-4],0
        jnz NotFirstOpen
        mov ecx,dword ptr [@dqFileSize]
        mov _dwPointDirBufSize,ecx
        mov dword ptr [eax+esi-4],ecx
        jmp CheckEncrypted
        NotFirstOpen:   
        mov ecx,dword ptr [eax+esi-4]
        mov _dwPointDirBufSize,ecx 
        
        CheckEncrypted:
        cmp dword ptr [eax+esi-8],0
        jz NotEncrypted
        mov dword ptr [eax+esi-8],0
        mov esi,_lpPointDirBuf
        mov edi,_lpPointDirBuf
        mov ecx,FILE_POINTDIR_SIZE
        sub ecx,8
        cld
        Decrypted:
        lodsb
        xor al,ENCRYPTION_KEY
        stosb
        loop Decrypted    
        lea eax,@szBuffer
        push eax
        call _ProcSysTimeToAsc
        invoke wsprintf,addr @szBuf,addr szDecryptPointDir,addr @szBuffer
        mov ecx,eax
        invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0  
        
        .else
        invoke CreateFile,offset szPointDirFileName,GENERIC_READ OR GENERIC_WRITE,FILE_SHARE_READ,0,CREATE_ALWAYS,\
        FILE_ATTRIBUTE_NORMAL or FILE_FLAG_RANDOM_ACCESS,NULL
        mov _hFilePointDir,eax
        invoke WriteFile,_hFileJournal,addr szCreatePointDir,sizeof szCreatePointDir-1,addr @dwCounter,0
        jmp ToMemMapping
        .endif  
        
NotEncrypted:
mov @dwPointDirOrdinal,0
mov ebx,_dwPointDirBufSize
mov esi,_lpPointDirBuf
add ebx,esi
mov @lpPointDirEnd,ebx
GetFirstDot:
cmp esi,@lpPointDirEnd
jae ReachFileEnd
lodsb
cmp al,2ch
jnz GetFirstDot
GetSecondDot:
lodsb
cmp al,2ch
jnz GetSecondDot
mov @dwPointIdLen,0
GetPointIdLen:
lodsb
cmp al,2ch
jz CheckPointIdLen
inc @dwPointIdLen
jmp GetPointIdLen
CheckPointIdLen:
cmp @dwPointIdLen,0
jz ReachFileEnd
GetPointInfoEnd:
lodsb
cmp esi,@lpPointDirEnd
jae ReachFileEnd
cmp al,0ah
jnz GetPointInfoEnd
inc @dwPointDirOrdinal
jmp GetFirstDot

ReachFileEnd:
inc @dwPointDirOrdinal
mov eax,@dwPointDirOrdinal
cmp eax,1
jnz NotEmptyPointDir
invoke WriteFile,_hFileJournal,addr szFileNoConfig,sizeof szFileNoConfig-1,addr @dwCounter,0
call _ProcTerminate
NotEmptyPointDir:
mov _dwDcsSampleCnt,eax
invoke wsprintf,addr @szBuf,addr szDcsSampleCnt,dword ptr _dwDcsSampleCnt
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0


invoke CreateFile,offset szUserInfoFileName,GENERIC_READ OR GENERIC_WRITE,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
cmp eax,INVALID_HANDLE_VALUE
jz FirstOpenService
mov _hFileUserInfo,eax
jmp NextOperation
FirstOpenService:
invoke CreateFile,offset szUserInfoFileName,GENERIC_READ OR GENERIC_WRITE,FILE_SHARE_READ,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
mov _hFileUserInfo,eax
invoke WriteFile,_hFileUserInfo,addr szAdminLogon,sizeof szAdminLogon,addr @dwCounter,0
NextOperation:
invoke GetFileSizeEx,_hFileUserInfo,addr @dqFileSize
invoke CreateFileMapping,_hFileUserInfo,0,PAGE_READWRITE,0,FILE_USERINFO_SIZE,0
mov _hFileMappingUserInfo,eax
invoke MapViewOfFile,_hFileMappingUserInfo,FILE_MAP_READ OR FILE_MAP_WRITE,0,0,0
mov _lpUserInfoBuf,eax
mov esi,eax
mov ebx,FILE_USERINFO_SIZE
cmp dword ptr [esi+ebx-4],0
jnz ToGetUserInfoSize
mov eax,dword ptr [@dqFileSize]
mov dword ptr [esi+ebx-4],eax
mov _dwUserInfoBufSize,eax
jmp ToDecryptUserInfo
ToGetUserInfoSize:
mov eax,dword ptr [esi+ebx-4]
mov _dwUserInfoBufSize,eax
ToDecryptUserInfo:
cmp dword ptr [esi+ebx-8],0
jz FileInfoDecrypt
mov dword ptr [esi+ebx-8],0
mov ecx,FILE_USERINFO_SIZE
sub ecx,8
mov esi,_lpUserInfoBuf
mov edi,esi
DecryptUserInfo:
lodsb
xor al,ENCRYPTION_KEY
stosb
loop DecryptUserInfo
FileInfoDecrypt:

lea eax,@szBuffer
push eax
call _ProcSysTimeToAsc
invoke wsprintf,addr @szBuf,addr szDecryptUserInfo,addr @szBuffer
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0  

pop edi
pop esi
pop ebx
leave           ;对于函数(不包括线程),若有调用参数或局部变量之一,则编译器默认加ENTER指令,因此要用LEAVE指令清空堆栈             
retn 0          ;RET指令是宏指令，而RETN是机器码
_ProcOpenFile endp











_ProcModifyData proc,lpszPointId,lpQueryTimeHead,lpModifyValue
local @dwRecordHeadNum:qword
local @dwSeekHeadOver
local @dwSeekHeadFoundCnt
local @lpRecordHeadPointer
local @lpRecordHeadDateTime

local @dwQueryDataBufSize
local @lpQueryDataBuf
local @dwQueryPointOrdinal
local @lpModifyValuePointer
local @dwModifyValueCnt

local @dwSectorDetail
local @dwBytesCnt
local @dwPointIdLen
local @lpFileEnd
local @dqRecordHeadPointer:qword
local @stQueryTimeHead:SYSTEMTIME
local @stOverlapped:OVERLAPPED
local @szBuf[100h]:byte
local @szBuffer[80h]:byte

push ebx
push esi
push edi
lock inc dword ptr [_dwRunningThreadCnt]               
cld
mov esi,lpszPointId
GetPointIdLen:
lodsb
cmp al,0
jnz GetPointIdLen
dec esi
sub esi,lpszPointId
cmp esi,0
jz ModifyFault
mov @dwPointIdLen,esi

mov @dwModifyValueCnt,0
mov esi,lpModifyValue
mov @lpModifyValuePointer,esi
GetValueCnt:
lodsd
cmp eax,0
jz GetValueCntOk
inc dword ptr @dwModifyValueCnt
jmp GetValueCnt
GetValueCntOk:
cmp dword ptr @dwModifyValueCnt,0
jz ModifyFault

invoke EnterCriticalSection,addr _stCriticalPointDir
mov ebx,_dwPointDirBufSize
add ebx,_lpPointDirBuf
mov @lpFileEnd,ebx
mov @dwQueryPointOrdinal,0
mov esi,_lpPointDirBuf
SeekFirstDot:
lodsb
cmp al,2ch
jnz SeekFirstDot
SeekSecondDot:
lodsb
cmp al,2ch
jnz SeekSecondDot
SeekPointId:
mov edi,lpszPointId
mov ecx,@dwPointIdLen
repz cmpsb
jz CheckLastChar 
GetEnterSymbol:
lodsb
cmp esi,@lpFileEnd
jae NotFoundId
cmp al,0ah
jnz GetEnterSymbol
inc @dwQueryPointOrdinal
jmp SeekFirstDot
NotFoundId:
invoke LeaveCriticalSection,addr _stCriticalPointDir
jmp ModifyFault

CheckLastChar:
lodsb
cmp al,2ch
jnz NotFoundId
invoke LeaveCriticalSection,addr _stCriticalPointDir
mov esi,lpQueryTimeHead
mov eax,[esi]
mov @stQueryTimeHead.wYear,ax
mov eax,[esi+4]
mov @stQueryTimeHead.wMonth,ax
mov eax,[esi+8]
mov @stQueryTimeHead.wDay,ax
mov eax,[esi+12]
mov @stQueryTimeHead.wHour,ax
mov eax,[esi+16]
mov @stQueryTimeHead.wMinute,ax
mov eax,[esi+20]
mov @stQueryTimeHead.wSecond,ax
mov @stQueryTimeHead.wDayOfWeek,0
mov @stQueryTimeHead.wMilliseconds,0

mov @dwSeekHeadOver,0
mov @dwSeekHeadFoundCnt,0
lea esi,@dqRecordHeadPointer
mov @lpRecordHeadPointer,esi
lea esi,@stQueryTimeHead
mov @lpRecordHeadDateTime,esi
lea ebx,_ThreadSeekIndex
lea esi,@lpRecordHeadDateTime
invoke CreateThread,0,0,ebx,esi,0,0
invoke CloseHandle,eax

WaitSeekHeadOver:
invoke Sleep,SMALLEST_SAMPLE_PERIOD
mov eax,@dwSeekHeadOver
test eax,1
jz WaitSeekHeadOver
mov eax,@dwSeekHeadFoundCnt
test eax,1
jz ModifyFault
                                        
mov eax,@dwQueryPointOrdinal
shl eax,2
add eax,sizeof SYSTEMTIME
add dword ptr [@dqRecordHeadPointer],eax
adc dword ptr [@dqRecordHeadPointer+4],0
mov eax,dword ptr [@dqRecordHeadPointer]
mov ebx,_dwBytesPerSec
dec ebx
and eax,ebx
mov @dwSectorDetail,eax
not ebx
and dword ptr [@dqRecordHeadPointer],ebx
                              
mov eax,_stSystemInfo.dwPageSize
mov @dwQueryDataBufSize,eax
invoke VirtualAlloc,NULL,@dwQueryDataBufSize,MEM_COMMIT,PAGE_READWRITE
mov @lpQueryDataBuf,eax

invoke CreateEvent,0,TRUE,0,0
mov @stOverlapped.hEvent,eax

lea esi,@stOverlapped
mov dword ptr [esi],0
mov dword ptr [esi+4],0
mov eax,dword ptr [@dqRecordHeadPointer]
mov dword ptr [esi+8],eax
mov eax,dword ptr [@dqRecordHeadPointer+4]
mov dword ptr [esi+12],eax

ToReadData:
lea esi,@stOverlapped
mov dword ptr [esi],0
mov dword ptr [esi+4],0
invoke ReadFile,_hFileDataBase,@lpQueryDataBuf,_dwBytesPerSec,addr @dwBytesCnt,addr @stOverlapped
        .if eax==0
        invoke GetLastError
                .if eax==ERROR_IO_PENDING
                invoke GetOverlappedResult,_hFileDataBase,addr @stOverlapped,addr @dwBytesCnt,TRUE
                mov eax,@dwBytesCnt
                        .if eax==_dwBytesPerSec
                        jmp WriteData
                        .else
                        ToModifyError:
                        jmp ModifyError
                        .endif
                .elseif eax==ERROR_INVALID_USER_BUFFER
                invoke Sleep,0
                jmp ToReadData
                .elseif eax==ERROR_NOT_ENOUGH_MEMORY
                invoke Sleep,0
                jmp ToReadData
                .elseif eax==ERROR_HANDLE_EOF
                jmp ModifyComplete
                .else
                jmp ToModifyError
                .endif
        .else
        mov eax,@dwBytesCnt
                .if eax==_dwBytesPerSec
                jmp WriteData
                .else
                jmp ToModifyError
                .endif
        .endif
        
WriteData:
mov esi,@lpModifyValuePointer
mov edi,@lpQueryDataBuf
add edi,@dwSectorDetail
movsd

RewriteData:
lea esi,@stOverlapped
mov dword ptr [esi],0
mov dword ptr [esi+4],0
invoke WriteFile,_hFileDataBase,@lpQueryDataBuf,_dwBytesPerSec,addr @dwBytesCnt,addr @stOverlapped
        .if eax==0
        invoke GetLastError
                .if eax==ERROR_IO_PENDING
                invoke GetOverlappedResult,_hFileDataBase,addr @stOverlapped,addr @dwBytesCnt,TRUE
                mov eax,@dwBytesCnt
                        .if eax==_dwBytesPerSec
                        jmp WriteDataOk
                        .else
                        jmp ToModifyError
                        .endif
                .elseif eax==ERROR_INVALID_USER_BUFFER
                invoke Sleep,0
                jmp RewriteData
                .elseif eax==ERROR_NOT_ENOUGH_MEMORY
                invoke Sleep,0
                jmp RewriteData
                .elseif eax==ERROR_HANDLE_EOF
                jmp ModifyComplete
                .else
                jmp ToModifyError
                .endif
        .else
        mov eax,@dwBytesCnt
                .if eax==_dwBytesPerSec
                jmp WriteDataOk
                .else
                jmp ToModifyError
                .endif
        .endif      

WriteDataOk:
dec dword ptr @dwModifyValueCnt
cmp dword ptr @dwModifyValueCnt,0
jz ModifyComplete
add dword ptr @lpModifyValuePointer,4
mov eax,_dwDataRecordingSize
lea esi,@stOverlapped
add dword ptr [esi+8],eax
adc dword ptr [esi+12],0
jmp ToReadData

ModifyComplete:
invoke VirtualFree,@lpQueryDataBuf,@dwQueryDataBufSize,MEM_DECOMMIT
invoke VirtualFree,@lpQueryDataBuf,0,MEM_RELEASE
invoke CloseHandle,@stOverlapped.hEvent

lea eax,@szBuffer
push eax
call _ProcSysTimeToAsc
mov esi,@lpModifyValuePointer
add esi,4
sub esi,lpModifyValue
shr esi,2
invoke wsprintf,addr @szBuf,addr szModifyValue,addr @szBuffer,dword ptr [@dwRecordHeadNum+4],dword ptr [@dwRecordHeadNum],esi
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwModifyValueCnt,0

lock dec dword ptr [_dwRunningThreadCnt]               
pop edi
pop esi
pop ebx
mov eax,1
mov edx,0
leave
retn 12         

ModifyError:
invoke VirtualFree,@lpQueryDataBuf,@dwQueryDataBufSize,MEM_DECOMMIT
invoke VirtualFree,@lpQueryDataBuf,0,MEM_RELEASE
invoke CloseHandle,@stOverlapped.hEvent
ModifyFault:
lock dec dword ptr [_dwRunningThreadCnt]               
pop edi
pop esi
pop ebx
mov eax,0
mov edx,0
leave
retn 12                  ;注意RETN 与RET 指令编译器会翻译成不同的指令，在这里只能用RETN指令而不能用RET指令
_ProcModifyData endp















_ProcReadData proc,lpszPointId,lpQueryTimeHead,lpQueryTimeEnd
push ebx
push esi
push edi

lock inc dword ptr [_dwRunningThreadCnt]               
invoke EnterCriticalSection,addr _stCriticalReadData
mov esi,_lpReadQueueInfoBuf
mov ebx,esi
add ebx,_dwReadQueueInfoBufSize
cld
CheckValidPos:
lodsd
cmp eax,0
jz GetValidPos
add esi,28              ;32B ervery struct
cmp esi,ebx
jb CheckValidPos

invoke LeaveCriticalSection,addr _stCriticalReadData
lock dec dword ptr [_dwRunningThreadCnt]               
pop edi
pop esi
pop ebx
mov eax,0
mov edx,0
leave
retn 12

GetValidPos:
sub esi,4
mov eax,lpszPointId
mov [esi],eax
mov eax,lpQueryTimeHead
mov [esi+4],eax
mov eax,lpQueryTimeEnd
mov [esi+8],eax
push esi
push esi
push esi
push esi
invoke CreateEvent,0,TRUE,0,0
pop esi
mov [esi+12],eax
lea ebx,_ThreadReadData
invoke CreateThread,0,0,ebx,esi,0,0
invoke CloseHandle,eax

invoke LeaveCriticalSection,addr _stCriticalReadData
pop esi
invoke WaitForSingleObject,dword ptr [esi+12],INFINITE
pop esi
invoke CloseHandle,dword ptr [esi+12]
pop esi
mov eax,[esi+16]
mov edx,[esi+20]
pop edi
pop esi
pop ebx
lock dec dword ptr [_dwRunningThreadCnt]               
leave                                           ;调用参数或局部变量都需要恢复ESP，EBP
retn 12
_ProcReadData endp











;这里传入的参数为年月日时分秒格式的6个整形变量
_ThreadReadData proc,lpReadInfo   
align qword
local @dqBeginCnt:qword
local @dqEndCnt:qword
local @dqCntPerSec:qword
local @dwTimeConst
local @dwReadTimeCost
local @dwSeekTimeCost
local @szBuffer[100h]:byte
local @szBuf[200h]:byte
local @dwCounter

local @dwFirstSeekTimes
local @dqFirstSeekEndCnt:qword
local @dqRecordHeadNum:qword
local @dwSeekHeadOver
local @dwSeekHeadFoundCnt
local @lpRecordHeadPointer
local @lpRecordHeadDateTime

local @dwSecondSeekTimes
local @dqSecondSeekEndCnt:qword
local @dqRecordEndNum:qword
local @dwSeekEndOver
local @dwSeekEndFoundCnt
local @lpRecordEndPointer
local @lpRecordEndDateTime

local @dwQueryDataBufSize
local @dwReadSectorBufSize

local @dwReadSectorErrorCnt
local @dwSectorDetail
local @dqDataPointer:qword
local @lpQueryDataBuf 
local @lpReadSectorBuf
local @dwThreadCntOfReadSector
local @dqRecordHeadPointer:qword
local @dwSeekCntPerThread

local @dqRecordEndPointer:qword

local @dwQueryPointCnt
local @dwQueryPointOrdinal
local @dwPointIdLen
local @lpFileEnd
local @stQueryTimeHead:SYSTEMTIME
local @stQueryTimeEnd:SYSTEMTIME
local @stFileTimeHead:FILETIME
local @stFileTimeEnd:FILETIME

local @lpszPointId
local @lpQueryTimeHead
local @lpQueryTimeEnd

invoke QueryPerformanceCounter,addr @dqBeginCnt
cld
mov esi,lpReadInfo
lodsd
mov @lpszPointId,eax
lodsd
mov @lpQueryTimeHead,eax
lodsd
mov @lpQueryTimeEnd,eax

mov esi,@lpszPointId
GetPointIdLen:
lodsb
cmp al,0
jnz GetPointIdLen
dec esi
sub esi,@lpszPointId
cmp esi,0
jz ReadDataFault
mov @dwPointIdLen,esi 

invoke EnterCriticalSection,addr _stCriticalPointDir
mov ebx,_dwPointDirBufSize
add ebx,_lpPointDirBuf
mov @lpFileEnd,ebx
mov @dwQueryPointOrdinal,0
mov esi,_lpPointDirBuf
SeekFirstDot:
lodsb
cmp al,2ch
jnz SeekFirstDot
SeekSecondDot:
lodsb
cmp al,2ch
jnz SeekSecondDot
SeekPointId:
mov edi,@lpszPointId
mov ecx,@dwPointIdLen
repz cmpsb
jz CheckLastChar
GetEnterSymbol:
lodsb
cmp esi,@lpFileEnd
jae NotFoundId
cmp al,0ah
jnz GetEnterSymbol
inc @dwQueryPointOrdinal
jmp SeekFirstDot
NotFoundId:
invoke LeaveCriticalSection,addr _stCriticalPointDir
jmp ReadDataFault

CheckLastChar:
lodsb
cmp al,2ch
jnz NotFoundId
invoke LeaveCriticalSection,addr _stCriticalPointDir
mov esi,@lpQueryTimeHead
mov edi,@lpQueryTimeEnd
mov ecx,6
repz cmpsd
jae ReadDataFault

mov esi,@lpQueryTimeHead
mov eax,[esi]
mov @stQueryTimeHead.wYear,ax
mov ebx,[esi+4]
mov @stQueryTimeHead.wMonth,bx
mov ecx,[esi+8]
mov @stQueryTimeHead.wDay,cx
mov edx,[esi+12]
mov @stQueryTimeHead.wHour,dx
mov edi,[esi+16]
mov @stQueryTimeHead.wMinute,di
mov esi,[esi+20]
mov @stQueryTimeHead.wSecond,si
mov @stQueryTimeHead.wDayOfWeek,0
mov @stQueryTimeHead.wMilliseconds,0

mov esi,@lpQueryTimeEnd
mov eax,[esi]
mov @stQueryTimeEnd.wYear,ax
mov ebx,[esi+4]
mov @stQueryTimeEnd.wMonth,bx
mov ecx,[esi+8]
mov @stQueryTimeEnd.wDay,cx
mov edx,[esi+12]
mov @stQueryTimeEnd.wHour,dx
mov edi,[esi+16]
mov @stQueryTimeEnd.wMinute,di
mov esi,[esi+20]
mov @stQueryTimeEnd.wSecond,si
mov @stQueryTimeEnd.wDayOfWeek,0
mov @stQueryTimeEnd.wMilliseconds,0

mov @dwSeekHeadOver,0
mov @dwSeekHeadFoundCnt,0
lea esi,@dqRecordHeadPointer
mov @lpRecordHeadPointer,esi
lea esi,@stQueryTimeHead
mov @lpRecordHeadDateTime,esi
lea ebx,_ThreadSeekIndex
lea esi,@lpRecordHeadDateTime
invoke CreateThread,0,0,ebx,esi,0,0
cmp eax,0
jnz CreateEventFirstOk
mov dword ptr @dwSeekEndOver,1
mov dword ptr @dwSeekHeadOver,1
mov dword ptr @dwSeekHeadFoundCnt,0
mov dword ptr @dwSeekEndFoundCnt,0
jmp WaitSeekHeadOver
CreateEventFirstOk:
invoke CloseHandle,eax

mov @dwSeekEndOver,0
mov @dwSeekEndFoundCnt,0
lea esi,@dqRecordEndPointer
mov @lpRecordEndPointer,esi
lea esi,@stQueryTimeEnd
mov @lpRecordEndDateTime,esi
lea ebx,_ThreadSeekIndex
lea esi,@lpRecordEndDateTime
invoke CreateThread,0,0,ebx,esi,0,0
cmp eax,0
jnz CreateEventSecondOk
mov dword ptr @dwSeekEndOver,1
mov dword ptr @dwSeekEndFoundCnt,0
jmp WaitSeekHeadOver
CreateEventSecondOk:
invoke CloseHandle,eax

WaitSeekHeadOver:
invoke Sleep,SMALLEST_SAMPLE_PERIOD
mov eax,@dwSeekHeadOver
test eax,@dwSeekEndOver
jz WaitSeekHeadOver

mov eax,@dwSeekHeadFoundCnt
test eax,@dwSeekEndFoundCnt
jz ReadDataFault

mov eax,dword ptr [@dqRecordEndPointer]
mov edx,dword ptr [@dqRecordEndPointer+4]
mov ebx,dword ptr [@dqRecordHeadPointer]
mov ecx,dword ptr [@dqRecordHeadPointer+4]
mov dword ptr [@dqDataPointer],ebx
mov dword ptr [@dqDataPointer+4],ecx
sub eax,ebx
sbb edx,ecx
mov ebx,_dwDataRecordingSize
div ebx
cmp eax,0
jz ReadDataFault
mov @dwQueryPointCnt,eax
                                        
mov eax,@dwQueryPointOrdinal
shl eax,2
add eax,sizeof SYSTEMTIME
add dword ptr [@dqDataPointer],eax
adc dword ptr [@dqDataPointer+4],0
mov eax,dword ptr [@dqDataPointer]
mov ebx,_dwBytesPerSec
dec ebx
and eax,ebx
mov @dwSectorDetail,eax
not ebx
and dword ptr [@dqDataPointer],ebx
                              
mov eax,@dwQueryPointCnt
mov ecx,_stSystemInfo.dwNumberOfProcessors
shl ecx,THREAD_CPU_RATIO
mov ebx,ecx
push eax
push ecx
dec ecx
and eax,ecx
pop ecx
sub ecx,eax
pop eax
cmp ecx,ebx
jz NoNeedToExtend
add eax,ecx
NoNeedToExtend:                           ;此处可能内存越界！！！！！！！！！！！！！！！
push eax
SeekCntPerThread:
shr ebx,1
cmp ebx,0
jz ToGetPointPos                      
shr eax,1
jmp SeekCntPerThread
ToGetPointPos:
mov @dwSeekCntPerThread,eax
pop eax
mov ebx,4
add ebx,sizeof SYSTEMTIME
mul ebx
mov ebx,_stSystemInfo.dwPageSize
dec ebx
not ebx
and eax,ebx  
add eax,_stSystemInfo.dwPageSize                ;为何此处这样处理？？防止内存越界？？？？？
add eax,_stSystemInfo.dwPageSize
mov @dwQueryDataBufSize,eax
invoke VirtualAlloc,NULL,@dwQueryDataBufSize,MEM_COMMIT,PAGE_READWRITE
cmp eax,0
jz ReadDataFault
mov @lpQueryDataBuf,eax
mov edi,eax
mov eax,@dwQueryDataBufSize
mov dword ptr [edi],eax
mov eax,@dwQueryPointCnt
mov dword ptr [edi+4],eax
add @lpQueryDataBuf,8

mov eax,_stSystemInfo.dwNumberOfProcessors
shl eax,THREAD_CPU_RATIO
mov ebx,_stSystemInfo.dwPageSize
shl ebx,1                               ;为何此处必须为2？
mul ebx
mov @dwReadSectorBufSize,eax
invoke VirtualAlloc,NULL,@dwReadSectorBufSize,MEM_COMMIT,PAGE_READWRITE
mov @lpReadSectorBuf,eax

mov @dwReadSectorErrorCnt,0
mov @dwThreadCntOfReadSector,0
mov ecx,_stSystemInfo.dwNumberOfProcessors
shl ecx,THREAD_CPU_RATIO
CreateReadThread:
push ecx
lea ebx,_ThreadReadSector
lea edi,@dwThreadCntOfReadSector
invoke CreateThread,0,0,ebx,edi,0,0
invoke CloseHandle,eax
pop ecx
loop CreateReadThread

invoke Sleep,0
WaitThreadEnd:
invoke Sleep,_dwSamplePeriod
cmp dword ptr @dwThreadCntOfReadSector,0
jnz WaitThreadEnd

cmp dword ptr @dwReadSectorErrorCnt,0
jnz ReadDataError

mov esi,lpReadInfo
mov edi,esi
mov ecx,3
mov eax,0
rep stosd
mov eax,@lpQueryDataBuf
sub eax,8
mov [esi+16],eax
mov edx,0
mov [esi+20],edx
invoke SetEvent,dword ptr [esi+12]
invoke VirtualFree,@lpReadSectorBuf,@dwReadSectorBufSize,MEM_DECOMMIT
invoke VirtualFree,@lpReadSectorBuf,0,MEM_RELEASE 

mov dword ptr [@dwTimeConst],1000000
invoke QueryPerformanceCounter,addr @dqEndCnt
invoke QueryPerformanceFrequency,addr @dqCntPerSec
finit                                           ;DLL可以正常运行浮点指令
fild qword ptr @dqBeginCnt
fild qword ptr @dqEndCnt
fsub st(0),st(1)
fild dword ptr @dwTimeConst
fmul st(0),st(1)
fild qword ptr @dqCntPerSec
fdivp st(1),st(0)
fist dword ptr @dwReadTimeCost
finit                                           ;DLL可以正常运行浮点指令
fild qword ptr @dqBeginCnt
fild qword ptr @dqSecondSeekEndCnt
fsub st(0),st(1)
fild dword ptr @dwTimeConst
fmul st(0),st(1)
fild qword ptr @dqCntPerSec
fdivp st(1),st(0)
fist dword ptr @dwSeekTimeCost

lea eax,@szBuffer
push eax
call _ProcSysTimeToAsc
invoke wsprintf,addr @szBuf,addr szJournalSeek,addr @szBuffer,dword ptr @dwSecondSeekTimes,dword ptr @dwSeekTimeCost
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
invoke wsprintf,addr @szBuf,addr szJournalRead,addr @szBuffer,dword ptr [@dqRecordHeadNum+4],dword ptr [@dqRecordHeadNum],\
       dword ptr [@dqRecordEndNum+4],dword ptr [@dqRecordEndNum],dword ptr [@dwQueryPointCnt],dword ptr [@dwReadTimeCost]  
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
leave
retn 4          

ReadDataError:
invoke VirtualFree,@lpQueryDataBuf,@dwQueryDataBufSize,MEM_DECOMMIT
invoke VirtualFree,@lpQueryDataBuf,0,MEM_RELEASE
invoke VirtualFree,@lpReadSectorBuf,@dwReadSectorBufSize,MEM_DECOMMIT
invoke VirtualFree,@lpReadSectorBuf,0,MEM_RELEASE 
ReadDataFault:
mov esi,lpReadInfo
mov edi,esi
mov ecx,3
mov eax,0
rep stosd
mov dword ptr [esi+16],0
mov dword ptr [esi+20],0
invoke SetEvent,dword ptr [esi+12]
invoke WriteFile,_hFileJournal,addr szInputError,sizeof szInputError-1,addr @dwReadSectorErrorCnt,0
ErrorInputParam:
leave
retn 4                  
_ThreadReadData endp
;多个线程同时调用同一个函数有什么影响？
;上述所有线程存在于同一个进程中，共享相同的地址空间，共享函数同样存在于该共享地址空间中。
;因为各个线程的SS:ESP不同，因此返回地址和入口参数不会混淆，若是在共享函数中存在中间性的暂时的局部变量，
;则所有线程都可能有机会改变这些局部变量，局部变量可能会在线程切换中发生改变，但是各个线程堆栈不同，共享函数不改变各个线程局部变量
 ;sizeof计算数据（包括数组、变量、类型、结构体等）所占内存空间，用字节数表示。





_ThreadSeekIndex proc,lpSeekIndexInfo
local @stOverlappedRead:OVERLAPPED
local @dwReadCnt
local @lpReadIndexBuf
local @dwReadIndexBufSize
local @dwBigBlockSize
local @dwSeekTimes

local @dqSeekingPtr:qword
local @dqHeadOffset:qword
local @dqEndOffset:qword

cld
invoke CreateEvent,0,TRUE,0,0
cmp eax,0
jz CreateEventFailure
mov @stOverlappedRead.hEvent,eax

mov eax,_dwBytesPerSec
shl eax,4
mov @dwReadIndexBufSize,eax
invoke VirtualAlloc,NULL,@dwReadIndexBufSize,MEM_COMMIT,PAGE_READWRITE 
cmp eax,0
jnz  MemoryAllocOk   
invoke CloseHandle,@stOverlappedRead.hEvent
CreateEventFailure:
mov esi,lpSeekIndexInfo
mov dword ptr [esi+8],0
mov dword ptr [esi+12],1
leave
retn 4
MemoryAllocOk:
mov @lpReadIndexBuf,eax

mov dword ptr [@dqHeadOffset],0
mov dword ptr [@dqHeadOffset+4],0  

mov edx,dword ptr [_dqRecordingCntSum+4]
mov eax,dword ptr [_dqRecordingCntSum]
mov ebx,_dwRecordingLimitOfBuf                          ;注意此处指令的作用是保证不会达到文件末尾而发生错误
dec ebx
not ebx
and eax,ebx
shld edx,eax,5
shl eax,5
mov dword ptr [@dqEndOffset],eax
mov dword ptr [@dqEndOffset+4],edx

shrd eax,edx,1
shr edx,1
mov ebx,_dwBytesPerSec
dec ebx
not ebx
and eax,ebx
mov dword ptr [@dqSeekingPtr],eax
mov dword ptr [@dqSeekingPtr+4],edx

mov @dwSeekTimes,0
ToSearchRecording:
mov eax,dword ptr [@dqEndOffset]
mov edx,dword ptr [@dqEndOffset+4]
sub eax,dword ptr [@dqHeadOffset]
sbb edx,dword ptr [@dqHeadOffset+4]
cmp edx,0
jg HalfSearch
jl ReadError
mov @dwBigBlockSize,eax
cmp eax,0
jl ReadError
cmp eax,@dwReadIndexBufSize
jbe LastMiniBlock

HalfSearch: 
inc @dwSeekTimes
lea esi,@stOverlappedRead
mov dword ptr [esi],0
mov dword ptr [esi+4],0
push dword ptr [@dqSeekingPtr]
pop dword ptr [esi+8]
push dword ptr [@dqSeekingPtr+4]
pop dword ptr [esi+12] 
invoke ReadFile,_hFileIndex,@lpReadIndexBuf,_dwBytesPerSec,addr @dwReadCnt,addr @stOverlappedRead
                .if eax==NULL
                invoke GetLastError
                        .if eax==ERROR_IO_PENDING
                        invoke GetOverlappedResult,_hFileIndex,addr @stOverlappedRead,addr @dwReadCnt,TRUE
                        mov eax,@dwReadCnt                                  
                                .if eax==_dwBytesPerSec
                                jmp HalfCheckDateTime
                                .else
                                jmp ReadError
                                .endif 
                        .elseif eax==ERROR_INVALID_USER_BUFFER
                        invoke Sleep,0
                        jmp HalfSearch
                        .elseif eax==ERROR_NOT_ENOUGH_MEMORY
                        invoke Sleep,0
                        jmp HalfSearch
                        .elseif eax==ERROR_HANDLE_EOF
                        jmp ReadError
                        .else
                        jmp ReadError
                        .endif
                .else
                mov eax,@dwReadCnt
                        .if eax==_dwBytesPerSec
                        jmp HalfCheckDateTime
                        .else
                        jmp ReadError
                        .endif 
                .endif
                
;local @dwRecordHeadNum
;local @dwSeekEndOver
;local @dwSeekEndFoundCnt
;local @lpRecordEndPointer
;local @lpRecordEndDateTime

HalfCheckDateTime:
mov esi,lpSeekIndexInfo
mov esi,[esi]
mov edi,@lpReadIndexBuf
mov word ptr [edi+4],0
mov ecx,7
repe cmpsw                              ;此处可以改进，只需要比较7个
jz HalfSearchFind
ja ToFileEnd
jb ToFileHead

ToFileEnd:
mov eax,dword ptr [@dqSeekingPtr]
mov edx,dword ptr [@dqSeekingPtr+4]
mov dword ptr [@dqHeadOffset],eax
mov dword ptr [@dqHeadOffset+4],edx
mov ebx,dword ptr [@dqEndOffset]
mov ecx,dword ptr [@dqEndOffset+4]
sub ebx,eax
sbb ecx,edx
shrd ebx,ecx,1
shr ecx,1
mov eax,_dwBytesPerSec
dec eax
not eax
and ebx,eax
add dword ptr [@dqSeekingPtr],ebx
adc dword ptr [@dqSeekingPtr+4],ecx
jmp ToSearchRecording

ToFileHead:
mov eax,dword ptr [@dqSeekingPtr]
mov edx,dword ptr [@dqSeekingPtr+4]
mov dword ptr [@dqEndOffset],eax
mov dword ptr [@dqEndOffset+4],edx
sub eax,dword ptr [@dqHeadOffset]
sbb edx,dword ptr [@dqHeadOffset+4]
shrd eax,edx,1
shr edx,1
mov ebx,_dwBytesPerSec
dec ebx
not ebx
and eax,ebx
sub dword ptr [@dqSeekingPtr],eax
sbb dword ptr [@dqSeekingPtr+4],edx
jmp ToSearchRecording

LastMiniBlock:
inc @dwSeekTimes
lea esi,@stOverlappedRead
mov dword ptr [esi],0
mov dword ptr [esi+4],0
push dword ptr [@dqHeadOffset]
pop dword ptr [esi+8]
push dword ptr [@dqHeadOffset+4]
pop dword ptr [esi+12]
invoke ReadFile,_hFileIndex,@lpReadIndexBuf,@dwBigBlockSize,addr @dwReadCnt,addr @stOverlappedRead
                .if eax==0                              ;MSDN说异步读写dwReadCount参数必须为0，但实际证明是错误的？到底怎么回事？
                invoke GetLastError
                        .if eax==ERROR_IO_PENDING
                        invoke GetOverlappedResult,_hFileIndex,addr @stOverlappedRead,addr @dwReadCnt,TRUE
                        mov eax,@dwReadCnt                                  
                                .if eax==@dwBigBlockSize
                                jmp LastCheckDateTime
                                .else
                                ReadError:
                                mov esi,lpSeekIndexInfo
                                mov dword ptr [esi+8],0
                                mov dword ptr [esi+12],1
                                invoke VirtualFree,@lpReadIndexBuf,@dwReadIndexBufSize,MEM_DECOMMIT
                                invoke VirtualFree,@lpReadIndexBuf,0,MEM_RELEASE
                                invoke CloseHandle,@stOverlappedRead.hEvent
                                leave
                                retn 4
                                .endif 
                        .elseif eax==ERROR_INVALID_USER_BUFFER
                        invoke Sleep,0
                        jmp LastMiniBlock
                        .elseif eax==ERROR_NOT_ENOUGH_MEMORY
                        invoke Sleep,0
                        jmp LastMiniBlock
                        .elseif eax==ERROR_HANDLE_EOF
                        jmp ReadError
                        .else
                        jmp ReadError
                        .endif
                .else
                mov eax,@dwReadCnt
                        .if eax==@dwBigBlockSize
                        jmp LastCheckDateTime
                        .else
                        jmp ReadError
                        .endif 
                .endif

LastCheckDateTime:  
mov ecx,@dwReadCnt
shr ecx,5
mov esi,lpSeekIndexInfo
mov esi,[esi]
mov edi,@lpReadIndexBuf
Check:
push ecx
push esi
push edi
mov word ptr [edi+4],0
mov ecx,7
repz cmpsw                     
jz LastBlockFind
pop edi
add edi,32
pop esi
pop ecx
loop Check
jmp ReadError

LastBlockFind:
pop edi
pop esi
pop ecx
add edi,14
HalfSearchFind:
add edi,2
mov eax,[edi]                                   ;此处不要忘记减1，最多45亿条记录 若一秒最多20条，最少可用8年 若一秒5条，最少30年
mov edx,[edi+4]
sub eax,1                                       ;索引号从1开始
sbb edx,0
mov esi,lpSeekIndexInfo
mov dword ptr [esi+16],eax
mov dword ptr [esi+20],edx
mov ebx,_dwDataRecordingSize                    ;此处由于32位运算限制了记录条数，以后将改为64位运算，取消这一限制
mul ebx
mov edi,[esi+4]
mov dword ptr [edi],eax
mov dword ptr [edi+4],edx
mov dword ptr [esi+8],1         ;先置找到标志，再置结束标志，为什么？？？？？？？？？？
mov dword ptr [esi+12],1        ;注意结束查找标志应在取得记录偏移后才能置位，否则可能主线程已经被通知结束，而在读记录时发生错误
add esi,24
push esi
invoke QueryPerformanceCounter,esi
pop esi
push @dwSeekTimes
pop dword ptr [esi+8]
invoke VirtualFree,@lpReadIndexBuf,@dwReadIndexBufSize,MEM_DECOMMIT
invoke VirtualFree,@lpReadIndexBuf,0,MEM_RELEASE
invoke CloseHandle,@stOverlappedRead.hEvent
leave
retn 4
_ThreadSeekIndex endp








;local @dwReadSectorErrorCnt
;local @dwSectorDetail
;local @dqDataPointer:qword
;local @lpQueryDataBuf 
;local @lpReadSectorBuf
;local @dwThreadReadSectorCnt            ;<---参数入口指针
;local @dqRecordHeadPointer:qword
;local @dwSeekCntPerThread

_ThreadReadSector proc,lpThreadParam
local @stOverlappedData:OVERLAPPED
local @stOverlappedTime:OVERLAPPED
local @dwTimeReadCnt
local @dwDataReadCnt

local @dwSectorDetail
local @lpQueryDataPointer
local @lpReadValueBufPointer
local @lpReadTimeBufPointer
local @dwSeekCntPerThread

invoke EnterCriticalSection,addr _stCriticalTransInfo          ;加上该函数出错！！！！！为什么
cld
mov esi,lpThreadParam
mov eax,dword ptr [esi]
mov ebx,4
add ebx,sizeof SYSTEMTIME
mul ebx
add eax,dword ptr [esi+8]
mov @lpQueryDataPointer,eax

mov eax,dword ptr [esi]                 ;注意：为何不能改变数据段地址？因为主程序还要释放该内存，若是改变了改地址，释放时出错
shl eax,1
mov ebx,_stSystemInfo.dwPageSize
mul ebx
add eax,dword ptr [esi+4]
mov @lpReadTimeBufPointer,eax
add eax,_stSystemInfo.dwPageSize
mov @lpReadValueBufPointer,eax
lock inc dword ptr [esi]                ;lock 指令只能用于运算指令

lea edi,@stOverlappedTime
mov dword ptr [edi],0
mov dword ptr [edi+4],0
mov eax,[esi-8]
mov edx,[esi-4]
mov dword ptr [edi+8],eax
mov dword ptr [edi+12],edx
mov eax,_dwDataRecordingSize
lock add dword ptr [esi-8],eax
lock adc dword ptr [esi-4],0

lea edi,@stOverlappedData
mov dword ptr [edi],0
mov dword ptr [edi+4],0
mov eax,[esi+12]
mov edx,[esi+16]
mov dword ptr [edi+8],eax
mov dword ptr [edi+12],edx
mov eax,_dwDataRecordingSize
lock add dword ptr [esi+12],eax
lock adc dword ptr [esi+16],0
invoke LeaveCriticalSection,addr _stCriticalTransInfo

mov eax,[esi+20]
mov @dwSectorDetail,eax
mov @dwSeekCntPerThread,0

invoke CreateEvent,0,TRUE,0,0
cmp eax,0
jz CreateEventFirstFailure
mov @stOverlappedTime.hEvent,eax
invoke CreateEvent,0,TRUE,0,0
cmp eax,0
jnz CreateEventAllOk
invoke CloseHandle,@stOverlappedTime.hEvent
CreateEventFirstFailure:
mov esi,lpThreadParam
lock dec dword ptr [esi]
leave 
retn 4
CreateEventAllOk:
mov @stOverlappedData.hEvent,eax

mov eax,[esi+12]
mov edx,[esi+16]
sub eax,dword ptr [esi-8]
sbb edx,dword ptr [esi-4]
cmp eax,_dwBytesPerSec
jae ReadAllSector

ReadTimeSector:
invoke ReadFile,_hFileDataBase,@lpReadTimeBufPointer,_dwBytesPerSec,addr @dwTimeReadCnt,addr @stOverlappedTime
        .if eax==0
        invoke GetLastError
                .if eax==ERROR_IO_PENDING
                invoke WaitForSingleObject,@stOverlappedTime.hEvent,INFINITE
                invoke GetOverlappedResult,_hFileDataBase,addr @stOverlappedTime,addr @dwTimeReadCnt,TRUE
                mov eax,@dwTimeReadCnt
                        .if eax==_dwBytesPerSec
                        GetQueryInfo:
                        mov esi,@lpReadTimeBufPointer
                        mov edi,@lpQueryDataPointer
                        mov ecx,4
                        rep movsd
                        mov esi,@lpReadTimeBufPointer
                        add esi,@dwSectorDetail
                        movsd

                        CheckReadTimeSectorEnd:
                        inc @dwSeekCntPerThread
                        mov eax,@dwSeekCntPerThread
                        mov esi,lpThreadParam
                        cmp eax,[esi-12]
                        jae ThreadWorkEnd

                        mov eax,4
                        add eax,sizeof SYSTEMTIME
                        mov ebx,_stSystemInfo.dwNumberOfProcessors
                        shl ebx,THREAD_CPU_RATIO
                        mul ebx
                        add @lpQueryDataPointer,eax

                        lea esi,@stOverlappedTime
                        mov dword ptr [esi],0
                        mov dword ptr [esi+4],0
                        mov eax,_dwDataRecordingSize
                        mov ebx,_stSystemInfo.dwNumberOfProcessors
                        shl ebx,THREAD_CPU_RATIO
                        mul ebx
                        add dword ptr [esi+8],eax
                        adc dword ptr [esi+12],edx
                        jmp ReadTimeSector
                        .else
                        ReadTimeSectorError:
                        mov esi,lpThreadParam
                        lock dec dword ptr [esi]
                        lock inc dword ptr [esi+24]
                        invoke CloseHandle,@stOverlappedTime.hEvent
                        invoke CloseHandle,@stOverlappedData.hEvent
                        leave
                        retn 4
                        .endif

                .elseif eax==ERROR_INVALID_USER_BUFFER
                invoke Sleep,0
                lea esi,@stOverlappedTime
                mov dword ptr [esi],0
                mov dword ptr [esi+4],0
                jmp ReadTimeSector
                .elseif eax==ERROR_NOT_ENOUGH_MEMORY
                invoke Sleep,0
                lea esi,@stOverlappedTime
                mov dword ptr [esi],0
                mov dword ptr [esi+4],0
                jmp ReadTimeSector
                .elseif eax==ERROR_HANDLE_EOF
                jmp ThreadWorkEnd
                .else
                jmp ReadTimeSectorError
                .endif 
        .else
        mov eax,@dwTimeReadCnt
                .if eax==_dwBytesPerSec
                jmp GetQueryInfo
                .else
                jmp ReadTimeSectorError
                .endif
        .endif
                      
ReadAllSector:
invoke ReadFile,_hFileDataBase,@lpReadTimeBufPointer,_dwBytesPerSec,addr @dwTimeReadCnt,addr @stOverlappedTime
        .if eax==0
        invoke GetLastError
                .if eax==ERROR_IO_PENDING
                ReadDataSector:
                invoke ReadFile,_hFileDataBase,@lpReadValueBufPointer,_dwBytesPerSec,addr @dwDataReadCnt,addr @stOverlappedData
                        .if eax==0
                        invoke GetLastError
                                .if eax==ERROR_IO_PENDING
                                invoke WaitForSingleObject,@stOverlappedTime.hEvent,INFINITE
                                invoke WaitForSingleObject,@stOverlappedData.hEvent,INFINITE                               
                                invoke GetOverlappedResult,_hFileDataBase,addr @stOverlappedTime,addr @dwTimeReadCnt,TRUE
                                invoke GetOverlappedResult,_hFileDataBase,addr @stOverlappedData,addr @dwDataReadCnt,TRUE
                                CheckDataReadCnt:
                                mov eax,@dwDataReadCnt
                                        .if eax==_dwBytesPerSec
                                        CheckTimeReadCnt:
                                        mov eax,@dwTimeReadCnt
                                                .if eax==_dwBytesPerSec
                                                jmp ReadNextSec
                                                .else
                                                ReadAllError:
                                                mov esi,lpThreadParam
                                                lock dec dword ptr [esi]
                                                lock inc dword ptr [esi+24]
                                                invoke CloseHandle,@stOverlappedTime.hEvent
                                                invoke CloseHandle,@stOverlappedData.hEvent
                                                leave
                                                retn 4
                                                .endif                                       
                                        .else
                                        jmp ReadAllError
                                        .endif                                
                                .elseif eax==ERROR_INVALID_USER_BUFFER
                                invoke Sleep,0
                                lea esi,@stOverlappedData
                                mov dword ptr [esi],0
                                mov dword ptr [esi+4],0
                                jmp ReadDataSector
                                .elseif eax==ERROR_NOT_ENOUGH_MEMORY
                                invoke Sleep,0
                                lea esi,@stOverlappedData
                                mov dword ptr [esi],0
                                mov dword ptr [esi+4],0
                                jmp ReadDataSector
                                .elseif eax==ERROR_HANDLE_EOF
                                jmp ThreadWorkEnd
                                .else
                                jmp ReadAllError
                                .endif
                        .else
                        mov eax,@dwDataReadCnt
                                .if eax==_dwBytesPerSec
                                invoke GetOverlappedResult,_hFileDataBase,addr @stOverlappedTime,addr @dwTimeReadCnt,TRUE
                                jmp CheckTimeReadCnt
                                .else
                                jmp ReadAllError
                                .endif
                        .endif
                .elseif eax==ERROR_INVALID_USER_BUFFER
                invoke Sleep,0
                lea esi,@stOverlappedTime
                mov dword ptr [esi],0
                mov dword ptr [esi+4],0
                jmp ReadAllSector
                .ELSEIF eax==ERROR_NOT_ENOUGH_MEMORY
                invoke Sleep,0
                lea esi,@stOverlappedTime
                mov dword ptr [esi],0
                mov dword ptr [esi+4],0
                jmp ReadAllSector
                .elseif eax==ERROR_HANDLE_EOF
                jmp ThreadWorkEnd
                .else
                jmp ReadAllError
                .endif 
        .else
        mov eax,@dwTimeReadCnt
                .if eax==_dwBytesPerSec
                jmp ReadDataSector
                .else
                jmp ReadAllError
                .endif
        .endif

ReadNextSec:
mov esi,@lpReadTimeBufPointer
mov edi,@lpQueryDataPointer
mov ecx,4
rep movsd
mov esi,@lpReadValueBufPointer
add esi,@dwSectorDetail
movsd

CheckReadAllEnd:
inc @dwSeekCntPerThread
mov eax,@dwSeekCntPerThread
mov esi,lpThreadParam
cmp eax,[esi-12]
jae ThreadWorkEnd

mov eax,4
add eax,sizeof SYSTEMTIME
mov ebx,_stSystemInfo.dwNumberOfProcessors
shl ebx,THREAD_CPU_RATIO
mul ebx
add @lpQueryDataPointer,eax

lea esi,@stOverlappedTime
mov dword ptr [esi],0
mov dword ptr [esi+4],0
mov eax,_dwDataRecordingSize
mov ebx,_stSystemInfo.dwNumberOfProcessors
shl ebx,THREAD_CPU_RATIO
mul ebx
add dword ptr [esi+8],eax
adc dword ptr [esi+12],edx

lea esi,@stOverlappedData
add dword ptr [esi+8],eax
adc dword ptr [esi+12],edx
mov dword ptr [esi],0
mov dword ptr [esi+4],0
jmp ReadAllSector

ThreadWorkEnd:
mov esi,lpThreadParam
lock dec dword ptr [esi]
invoke CloseHandle,@stOverlappedTime.hEvent
invoke CloseHandle,@stOverlappedData.hEvent
leave 
retn 4
_ThreadReadSector endp










_ProcReadInterval proc,lpszPointId,lpQueryTimeHead,lpQueryTimeEnd,nSecInterval
local @dwGroupCnt
local @lpGroupBuf
local @dwGroupBufSize
local @lpReadParam
local @lpRecvBuf
local @dwItemCnt
local @dwTotalValue

push ebx
push esi
push edi
lock inc dword ptr [_dwRunningThreadCnt]               
invoke EnterCriticalSection,addr _stCriticalReadData
mov esi,_lpReadQueueInfoBuf
mov ebx,esi
add ebx,_dwReadQueueInfoBufSize
cld
CheckValidPos:
lodsd
cmp eax,0
jz GetValidPos
add esi,28              ;32B ervery struct
cmp esi,ebx
jb CheckValidPos

invoke LeaveCriticalSection,addr _stCriticalReadData
InvalidParam:
lock dec dword ptr [_dwRunningThreadCnt]               
pop edi
pop esi
pop ebx
mov eax,0
mov edx,0
leave
retn 16

GetValidPos:
sub esi,4
mov @lpReadParam,esi
mov eax,lpszPointId
mov dword ptr [esi],eax
mov eax,lpQueryTimeHead
mov dword ptr [esi+4],eax
mov eax,lpQueryTimeEnd
mov dword ptr [esi+8],eax

invoke CreateEvent,0,TRUE,0,0
mov esi,@lpReadParam
mov dword ptr [esi+12],eax

lea ebx,_ThreadReadData
invoke CreateThread,0,0,ebx,esi,0,0
invoke CloseHandle,eax

invoke LeaveCriticalSection,addr _stCriticalReadData
mov esi,@lpReadParam
invoke WaitForSingleObject,dword ptr [esi+12],INFINITE
mov esi,@lpReadParam
invoke CloseHandle,dword ptr [esi+12]

mov esi,@lpReadParam
mov esi,dword ptr [esi+16]
cmp esi,0
jz InvalidParam
mov @lpRecvBuf,esi
mov eax,nSecInterval
mov ebx,1000
mul ebx
mov ebx,_dwSamplePeriod
div ebx
mov @dwItemCnt,eax
mov ebx,eax
mov eax,dword ptr [esi+4]
mov edx,0
div ebx
cmp eax,0
jle InvalidParam
mov @dwGroupCnt,eax
mov ebx,4
add ebx,sizeof SYSTEMTIME
mul ebx
mov ebx,_stSystemInfo.dwPageSize
dec ebx
not ebx
and eax,ebx
add eax,_stSystemInfo.dwPageSize
add eax,_stSystemInfo.dwPageSize
mov @dwGroupBufSize,eax
invoke VirtualAlloc,0,@dwGroupBufSize,MEM_COMMIT,PAGE_READWRITE
mov @lpGroupBuf,eax
mov ecx,@dwGroupBufSize
mov dword ptr [eax],ecx
mov ecx,@dwGroupCnt
mov dword ptr [eax+4],ecx
add dword ptr @lpGroupBuf,8

mov edi,@lpGroupBuf
mov esi,@lpRecvBuf
add esi,8
mov ecx,@dwGroupCnt
NextEverageValue:
push ecx
mov ecx,4
rep movsd
mov ecx,@dwItemCnt
mov @dwTotalValue,0
GetTotalValue:
lodsd
add @dwTotalValue,eax
add esi,sizeof SYSTEMTIME
loop GetTotalValue
mov eax,@dwTotalValue
mov edx,0
mov ebx,@dwItemCnt
div ebx
stosd
sub esi,sizeof SYSTEMTIME
pop ecx
loop NextEverageValue

mov esi,@lpRecvBuf
mov ecx,dword ptr [esi]
invoke VirtualFree,@lpRecvBuf,ecx,MEM_DECOMMIT
invoke VirtualFree,@lpRecvBuf,0,MEM_RELEASE

mov eax,@lpGroupBuf
sub eax,8
mov edx,0
pop edi
pop esi
pop ebx
lock dec dword ptr [_dwRunningThreadCnt]               
leave 
retn 16
_ProcReadInterval endp











_ThreadWaitSamplePeriod proc
local @dqPrevRecvPackCnt:qword
local @dwCounter

cld
lock inc dword ptr [_dwRunningThreadCnt]
mov eax,dword ptr [_dqRecvPackCnt]
mov edx,dword ptr [_dqRecvPackCnt+4]
mov dword ptr [@dqPrevRecvPackCnt],eax
mov dword ptr [@dqPrevRecvPackCnt+4],edx
mov ecx,_dwSamplePeriod
shl ecx,BUF_MULTI_RATIO
invoke Sleep,ecx

WaitTime:
cmp dword ptr _flTerminate,1
jz KillThisThread
mov esi,_lpRecordingBufHead
invoke GetLocalTime,esi                  ;GetLocalTime参数是否只能先定义为SYSTEMTIME结构？空下16个字节不行么？？？？？行！！！！！
invoke Sleep,_dwSamplePeriod
mov eax,dword ptr [_dqRecvPackCnt]
mov edx,dword ptr [_dqRecvPackCnt+4]
cmp eax,dword ptr [@dqPrevRecvPackCnt]
jz WaitTime
mov dword ptr [@dqPrevRecvPackCnt],eax
mov dword ptr [@dqPrevRecvPackCnt+4],edx
mov esi,_lpRecordingBufHead
mov edi,_lpRecordingIndexBufHead
mov ecx,8
rep movsw
mov eax,dword ptr [_dqRecordingCntSum]
mov edx,dword ptr [_dqRecordingCntSum+4]
add eax,1
adc edx,0
mov dword ptr [_dqRecordingCntSum],eax
mov dword ptr [_dqRecordingCntSum+4],edx 
stosd
mov eax,edx
stosd 

mov eax,_lpRecordingBufHead
mov _lpRealTimeDataBuf,eax

mov eax,_dwDataRecordingSize
lock xadd _lpRecordingBufHead,eax
mov ebx,RECORDING_INDEX_SIZE
lock xadd _lpRecordingIndexBufHead,ebx

invoke SetEvent,_hEventRealTimeData

mov eax,_lpRecordingIndexBufHead
cmp eax,_lpRecordingIndexBufLimit
jb WaitTime
sub eax,_lpRecordingIndexBuf
mov edx,0
mov ebx,RECORDING_INDEX_SIZE
div ebx                              ;edx must be 0!?   
mov ebx,_dwRecordingLimitOfBuf
div ebx
cmp edx,0
jnz WaitTime

mov eax,dword ptr [_dqRecordingCntSum]
mov edx,dword ptr [_dqRecordingCntSum+4]
mov dword ptr [_dqFileTotalRecording],eax
mov dword ptr [_dqFileTotalRecording+4],edx
;先换头指针，再换基地址，最后交换界限，为什么？？？？？
mov ebx,_lpRecordReservedBuf
lock xchg dword ptr _lpRecordingBuf,ebx
mov _lpRecordReservedBuf,ebx

mov ecx,_lpRecordingBufHead
lock xchg dword ptr _lpRecordReservedBufHead,ecx
mov _lpRecordingBufHead,ecx

mov ebx,_lpRecordReservedBufLimit
lock xchg dword ptr _lpRecordingBufLimit,ebx
mov _lpRecordReservedBufLimit,ebx

mov esi,_lpIndexReservedBuf
lock xchg dword ptr _lpRecordingIndexBuf,esi
mov _lpIndexReservedBuf,esi

mov edx,_lpRecordingIndexBufHead
lock xchg dword ptr _lpIndexReservedBufHead,edx
mov _lpRecordingIndexBufHead,edx

mov esi,_lpIndexReservedBufLimit
lock xchg dword ptr _lpRecordingIndexBufLimit,esi
mov _lpIndexReservedBufLimit,esi

invoke SetEvent,_hEventStoreRecording
jmp WaitTime

KillThisThread:
lock dec dword ptr [_dwRunningThreadCnt]
invoke SetEvent,_hEventStoreRecording                   ;用于控制写记录的线程结束
invoke WriteFile,_hFileJournal,addr szWaitSamplePeriodQuit,sizeof szWaitSamplePeriodQuit-1,addr @dwCounter,0

leave
retn 0
_ThreadWaitSamplePeriod endp











;若是开启多个线程，还要解决多个线程的共享问题
_ThreadRecvUdpPack proc
local @szBuf[100h]:byte
local @szBuffer[80h]:byte
local @dwCounter
local @stSendAddr:sockaddr_in
local @dwSendAddrSize:dword

mov @dwSendAddrSize,sizeof sockaddr_in
lock inc dword ptr [_dwRunningThreadCnt]
cld

RecvUdpData:
invoke recvfrom,_hSockRecv,_lpUdpPackRecvBufHead,UDP_PACKAGE_SIZE,0,addr @stSendAddr,addr @dwSendAddrSize
cmp eax,SOCKET_ERROR
jz RecvFromError
cmp eax,UDP_PACKAGE_SIZE
jnz RecvFromError

inc dword ptr [_dqRecvPackCnt]
adc dword ptr [_dqRecvPackCnt+4],0

mov edi,_lpUdpPackAddrBufHead
mov eax,_lpUdpPackRecvBufHead
stosd
cmp edi,_lpUdpPackAddrBufLimit
jb PacketBufNotEnd
mov edi,_lpUdpPackAddrBuf
PacketBufNotEnd:
mov _lpUdpPackAddrBufHead,edi

mov eax,_lpUdpPackRecvBufHead
add eax,UDP_PACKAGE_SIZE
cmp eax,_lpUdpPackRecvBufLimit
jb RecvNextUdpData
mov eax,_lpUdpPackRecvBuf
RecvNextUdpData:
mov _lpUdpPackRecvBufHead,eax
jmp RecvUdpData

RecvFromError:
lea eax,@szBuffer
push eax
call _ProcSysTimeToAsc
invoke wsprintf,addr @szBuf,addr szRecvUdpPackError,addr @szBuffer
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lock dec dword ptr [_dwRunningThreadCnt]
leave
retn 0
_ThreadRecvUdpPack endp









_ThreadUdpUnpack proc
local @szBuf[100h]:byte
local @szBuffer[80h]:byte
local @dwCounter

lock inc dword ptr [_dwRunningThreadCnt]
cld

NoPackNow:
cmp dword ptr _flTerminate,1
jz KillThisThread
invoke Sleep,SMALLEST_SAMPLE_PERIOD                         
mov esi,_lpUdpPackAddrBufEnd
cmp esi,_lpUdpPackAddrBufHead
jz NoPackNow

UnPackUdpData:
lodsd
push esi
mov esi,eax
test word ptr [esi+10],BOOL_PACK_FLAG
jnz BoolData

FloatData:
movzx ecx,word ptr [esi+8]              ;注意MOVZX指令的用法！！！！！
cmp ecx,0
jz UnpackNext
shr ecx,3
add esi,UDP_PACKAGE_HEADER_SIZE
CopyFloatData:
lodsw
movzx edi,ax                            ;注意MOVZX指令的用法！！！！！
shl edi,2
add edi,sizeof SYSTEMTIME
add edi,dword ptr [_lpRecordingBufHead]
add esi,2
movsd
loop CopyFloatData
jmp UnpackNext

BoolData:
movzx ecx,word ptr [esi+8]
cmp ecx,0
jz UnpackNext
shr ecx,2
add esi,UDP_PACKAGE_HEADER_SIZE
CopyBoolData:
lodsw
movzx edi,ax
shl edi,2
add edi,sizeof SYSTEMTIME
add edi,dword ptr [_lpRecordingBufHead]
lodsw
movzx eax,ax
stosd
loop CopyBoolData

UnpackNext:
inc dword ptr [_dqUnPackCnt]
adc dword ptr [_dqUnPackCnt+4],0
pop esi
cmp esi,_lpUdpPackAddrBufLimit
jb PackEndNotReachLimit
mov esi,_lpUdpPackAddrBuf
PackEndNotReachLimit:
mov _lpUdpPackAddrBufEnd,esi
cmp esi,_lpUdpPackAddrBufHead
jnz UnPackUdpData
jmp NoPackNow

KillThisThread:
lock dec dword ptr [_dwRunningThreadCnt]
invoke WriteFile,_hFileJournal,addr szUdpUnpackQuit,sizeof szUdpUnpackQuit-1,addr @dwCounter,0
leave
retn 0
_ThreadUdpUnpack endp














_ProcExceptionGetDcsData proc,lpExceptionRecord,lpSeh,lpContext,lpDispatcher
local @szBuf[100h]:byte
local @szBuffer[200h]:byte
local @dwCounter

pushad
mov esi,lpExceptionRecord
mov edi,lpContext
assume esi:ptr EXCEPTION_RECORD,edi:ptr CONTEXT
mov eax,[esi].ExceptionCode
        .if eax==0c0000005h
        AccessViolation:
                mov ebx,[esi].ExceptionFlags
                test ebx,1
                jz ExceptionContinueable
                call _ProcTerminate
                invoke ExitProcess,0
                ExceptionContinueable:
                mov eax,lpSeh
                push [eax+8]
                pop [edi].regEip
                push [eax+12]
                pop [edi].regEbp
                push eax
                pop [edi].regEsp 

                push esi
                push edi              
                lea eax,@szBuf
                push eax
                call _ProcSysTimeToAsc
                pop edi
                pop esi
                invoke wsprintf,addr @szBuffer,addr szExceptionGetDcsData,addr @szBuf,[esi].ExceptionAddress    
                mov ecx,eax
                invoke WriteFile,_hFileJournal,addr @szBuffer,ecx,addr @dwCounter,0
                assume fs:nothing
                mov ebx,fs:[0]
                lea edi,_ProcExceptionGetDcsData
                UnWindNext:
                cmp [ebx+4],edi
                jz UnwindAll
                mov ebx,[ebx]
                jmp UnWindNext
                UnwindAll:
                assume fs:nothing
                mov fs:[0],ebx
                invoke RtlUnwind,lpSeh,0,0,0

                assume esi:nothing,edi:nothing
                popad
                mov eax,ExceptionContinueExecution
                jmp QuitException
                
        .elseif eax==0c0000006h
        jz AccessViolation
        
        .elseif eax==0c0000027h
        UnWindProc:
        assume esi:nothing,edi:nothing
        popad
        mov eax,ExceptionContinueSearch
        jmp QuitException

        .elseif eax==80000003h          ; int 3

        .elseif eax==0c000001dh         ; invalid instruction

        .elseif eax==0c0000094h         ;dividen by 0

        .elseif eax==80000004h          ;int 1

        .elseif eax==0c00000fdh         ;stack overflow

        .else
        mov eax,dword ptr [esi+4]
        test eax,2
        jnz UnWindProc
        test eax,4
        jnz UnWindProc
        .endif

QuitException:                
leave
retn 12
_ProcExceptionGetDcsData endp










;Functions such as ReadFile and WriteFile set event handle to the nonsignaled state before they begin an I/O operation. 
;When the operation has completed, the handle is set to the signaled state
_ThreadStoreRecording proc
align qword
local @dqBeginCount:qword
local @dqFileDataSize:qword
local @dqFileIndexSize:qword
local @dwRecordWriteCnt
local @dwIndexWriteCnt
local @stOverlappedRecord:OVERLAPPED
local @stOverlappedIndex:OVERLAPPED
local @dwRecordWriteSum
local @dwIndexWriteSum
local @szBuf[100h]:byte
local @szBuffer[80h]:byte
local @dwCounter
local @dwWriteErrorCode

lock inc dword ptr [_dwRunningThreadCnt]
invoke CreateEvent,0,TRUE,0,0
mov @stOverlappedRecord.hEvent,eax
invoke CreateEvent,0,TRUE,0,0
mov @stOverlappedIndex.hEvent,eax

WaitWriteFile:
invoke WaitForSingleObject,_hEventStoreRecording,INFINITE
invoke ResetEvent,_hEventStoreRecording
cmp dword ptr [_flTerminate],1
jz TerminateThisThread

invoke QueryPerformanceCounter,addr @dqBeginCount
mov ecx,_lpRecordReservedBufHead
sub ecx,_lpRecordReservedBuf 
mov @dwRecordWriteSum,ecx
mov eax,_lpIndexReservedBufHead 
sub eax,_lpIndexReservedBuf
mov @dwIndexWriteSum,eax    
lea esi,@stOverlappedIndex
mov dword ptr [esi+8],0ffffffffh
mov dword ptr [esi+12],0ffffffffh
lea edi,@stOverlappedRecord
mov dword ptr [edi+8],0ffffffffh
mov dword ptr [edi+12],0ffffffffh
invoke GetFileSizeEx,_hFileDataBase,addr @dqFileDataSize
invoke GetFileSizeEx,_hFileDataBase,addr @dqFileIndexSize

WriteData:
lea esi,@stOverlappedRecord
mov dword ptr [esi],0
mov dword ptr [esi+4],0                          
invoke WriteFile,_hFileDataBase,_lpRecordReservedBuf,dword ptr @dwRecordWriteSum,addr @dwRecordWriteCnt,addr @stOverlappedRecord
        .if eax==0
        invoke GetLastError
                .if eax==ERROR_IO_PENDING
                WriteIndexAPC:
                lea esi,@stOverlappedIndex
                mov dword ptr [esi],0
                mov dword ptr [esi+4],0     
                invoke WriteFile,_hFileIndex,_lpIndexReservedBuf,dword ptr @dwIndexWriteSum,addr @dwIndexWriteCnt,\
                addr @stOverlappedIndex
                        .if eax==0
                        invoke GetLastError
                                .if eax==ERROR_IO_PENDING
                                invoke WaitForSingleObject,@stOverlappedIndex.hEvent,INFINITE
                                invoke GetOverlappedResult,_hFileIndex,addr @stOverlappedIndex,addr @dwIndexWriteCnt,TRUE    
                                CheckWriteCnt:  
                                invoke WaitForSingleObject,@stOverlappedRecord.hEvent,INFINITE
                                invoke GetOverlappedResult,_hFileDataBase,addr @stOverlappedRecord,addr @dwRecordWriteCnt,TRUE                                                     
                                mov eax,@dwIndexWriteCnt
                                        .if eax==@dwIndexWriteSum
                                        mov eax,@dwRecordWriteCnt
                                                .if eax==@dwRecordWriteSum
                                                jmp WriteFileOk
                                                .else
                                                WriteError:                                          
                                                jmp WriteRecordingError              
                                                .endif
                                        .else
                                        jmp WriteError
                                        .endif
                                .elseif eax==ERROR_INVALID_USER_BUFFER
                                invoke Sleep,0
                                jmp WriteIndexAPC
                                .ELSEIF eax==ERROR_NOT_ENOUGH_MEMORY
                                invoke Sleep,0
                                jmp WriteIndexAPC
                                .else
                                jmp WriteError             
                                .endif
                        .else
                        mov eax,@dwIndexWriteCnt
                                .if eax==@dwIndexWriteSum
                                jmp CheckWriteCnt
                                .else
                                jmp WriteError
                                .endif
                        .endif
                .elseif eax==ERROR_INVALID_USER_BUFFER
                invoke Sleep,0
                jmp WriteData
                .ELSEIF eax==ERROR_NOT_ENOUGH_MEMORY
                invoke Sleep,0
                jmp WriteData
                .else 
                jmp WriteError
                .endif
        .else
        mov eax,@dwRecordWriteCnt
                .if eax==@dwRecordWriteSum
                jmp WriteIndexAPC
                .else
                jmp WriteError
                .endif
        .endif 
WriteFileOk:
mov edi,_lpRecordReservedBuf
mov ecx,_lpRecordReservedBufHead
sub ecx,edi
shr ecx,2
mov eax,INVALID_POINT_VALUE
rep stosd
mov edi,_lpIndexReservedBuf
mov ecx,_lpIndexReservedBufHead
sub ecx,edi
shr ecx,2
rep stosd
mov edx,_lpRecordReservedBuf
lock xchg dword ptr _lpRecordReservedBufHead,edx
mov ebx,_lpIndexReservedBuf
lock xchg dword ptr _lpIndexReservedBufHead,ebx   
lea esi,@dqBeginCount
lea ebx,_ThreadJournalOfWriteInfo
invoke CreateThread,0,0,ebx,esi,0,0
invoke CloseHandle,eax
jmp WaitWriteFile

WriteRecordingError:
lea eax,@szBuffer
push eax
call _ProcSysTimeToAsc
invoke GetLastError
mov @dwWriteErrorCode,eax
invoke wsprintf,addr @szBuf,addr szRecordingWriteError,addr @szBuffer,@dwWriteErrorCode
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lea esi,@stOverlappedRecord
mov eax,dword ptr [@dqFileDataSize]
mov edx,dword ptr [@dqFileDataSize+4]
mov dword ptr [esi+8],eax
mov dword ptr [esi+12],edx
lea edi,@stOverlappedIndex
mov eax,dword ptr [@dqFileIndexSize]
mov edx,dword ptr [@dqFileIndexSize+4]
mov dword ptr [edi+8],eax
mov dword ptr [edi+12],edx
jmp WriteData                    ;忽略错误，继续写入

TerminateThisThread:
invoke CloseHandle,@stOverlappedRecord.hEvent
invoke CloseHandle,@stOverlappedIndex.hEvent
lock dec dword ptr [_dwRunningThreadCnt]
invoke WriteFile,_hFileJournal,addr szStoreRecordingQuit,sizeof szStoreRecordingQuit-1,addr @dwCounter,0
leave
retn 0
_ThreadStoreRecording endp






 


;sizeof计算数据（包括数组、变量、类型、结构体等）所占内存空间,用字节数表示。
_ThreadJournalOfWriteInfo proc,lpBeginCount
align qword
local @dqBeginCount:qword
local @dqEndCount:qword
local @dqCountPerSec:qword
local @dqWriteRecordCost:qword
local @dwMicroSecPerSec
local @szBuffer[100h]:byte
local @szBuf[200h]:byte
local @dwCounter

lock inc dword ptr [_dwRunningThreadCnt] 
mov dword ptr @dwMicroSecPerSec,1000000
mov esi,lpBeginCount
mov eax,[esi]
mov edx,[esi+4]
mov dword ptr [@dqBeginCount],eax
mov dword ptr [@dqBeginCount+4],edx
invoke QueryPerformanceCounter,addr @dqEndCount
invoke QueryPerformanceFrequency,addr @dqCountPerSec
finit
fild qword ptr @dqBeginCount
fild qword ptr @dqEndCount
fsub st(0),st(1)
fild dword ptr @dwMicroSecPerSec
fmul st(0),st(1)
fild qword ptr @dqCountPerSec
fdivp st(1),st(0)
fistp qword ptr @dqWriteRecordCost      ;fistp可弹出64为整数，fist只能弹出32为整数？？？？？

lea eax,@szBuffer
push eax
call _ProcSysTimeToAsc
invoke wsprintf,addr @szBuf,addr szJournalWrite,addr @szBuffer,dword ptr [_dqFileTotalRecording+4],\
dword ptr [_dqFileTotalRecording],dword ptr [@dqWriteRecordCost+4],dword ptr [@dqWriteRecordCost],\
dword ptr [_dqRecordingCntSum+4],dword ptr [_dqRecordingCntSum]
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
invoke wsprintf,addr @szBuf,addr szJournalPack,addr @szBuffer,dword ptr dword ptr [_dqRecvPackCnt+4],dword ptr [_dqRecvPackCnt],\
dword ptr [_dqUnPackCnt+4],dword ptr [_dqUnPackCnt]
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0
lock dec dword ptr [_dwRunningThreadCnt]
leave
retn 4
_ThreadJournalOfWriteInfo endp











_ThreadRealTimeData proc
local @dwQueryPointOrdinal
local @lpRltDataBufHead
local @lpRltDataBufEnd
local @lpDcsInputBufPointer
local @lpDcsInputBuf

cld
lock inc dword ptr [_dwRunningThreadCnt]

WaitEventRealTimeData:
invoke WaitForSingleObject,_hEventRealTimeData,INFINITE
invoke ResetEvent,_hEventRealTimeData
cmp dword ptr [_flTerminate],1
jz TerminateThisThread
mov esi,_lpRltDataTableBuf
mov ecx,_dwRltDataTableBufSize
shr ecx,3
cld
CheckRealTimeDataRequest:
push ecx
push esi
lodsd
cmp eax,0ffffffffh
jnz GetValidRequest
CheckRequestEnd:
pop esi
add esi,8
pop ecx
loop CheckRealTimeDataRequest
jmp WaitEventRealTimeData

GetValidRequest:
mov @dwQueryPointOrdinal,eax
lodsd
cmp eax,[eax]
jnz CheckRequestEnd
mov @lpRltDataBufHead,eax
add eax,_stSystemInfo.dwPageSize
mov @lpRltDataBufEnd,eax

mov esi,@lpRltDataBufHead
mov edi,[esi+8]
mov esi,_lpRealTimeDataBuf
push esi
mov ecx,4
rep movsd
pop esi
mov ebx,@dwQueryPointOrdinal
shl ebx,2
add ebx,sizeof SYSTEMTIME
add esi,ebx
movsd
cmp edi,@lpRltDataBufEnd
jb PointerInRange
mov esi,@lpRltDataBufHead
mov edi,esi
add edi,16
mov dword ptr [esi+8],edi
jmp CheckRequestEnd
PointerInRange:
mov esi,@lpRltDataBufHead
mov dword ptr [esi+8],edi
jmp CheckRequestEnd

TerminateThisThread:
lock dec dword ptr [_dwRunningThreadCnt]
leave
retn 0
_ThreadRealTimeData endp










_ProcRegistryInfo proc,lpszPointId,flSignal
local @dwQueryPointOrdinal
local @dwQueryPointIdLen
local @lpPointDirFileEnd
local @lpRealTimeDataBuf

push ebx
push esi
push edi

cld
mov esi,lpszPointId
GetPointIdLen:
lodsb
cmp al,0
jnz GetPointIdLen
dec esi
sub esi,lpszPointId
cmp esi,0
jz ParamError
mov @dwQueryPointIdLen,esi

invoke EnterCriticalSection,addr _stCriticalPointDir
mov ebx,_lpPointDirBuf
add ebx,_dwPointDirBufSize
mov @lpPointDirFileEnd,ebx
mov @dwQueryPointOrdinal,0
mov esi,_lpPointDirBuf
SeekFirstDot:
lodsb
cmp al,2ch
jnz SeekFirstDot
SeekSecondDot:
lodsb
cmp al,2ch
jnz SeekSecondDot
mov edi,lpszPointId
mov ecx,@dwQueryPointIdLen
repz cmpsb
jz CheckLastChar
GetEnterSymbol:
lodsb
cmp esi,@lpPointDirFileEnd
jae ParamError
cmp al,0ah
jnz GetEnterSymbol
inc @dwQueryPointOrdinal
jmp SeekFirstDot

ParamError:
invoke LeaveCriticalSection,addr _stCriticalPointDir
pop edi
pop esi
pop ebx
mov eax,0
mov edx,0
leave
retn 8


CheckLastChar:
lodsb
cmp al,2ch
jnz ParamError
invoke LeaveCriticalSection,addr _stCriticalPointDir
cmp flSignal,0
jz CancelRegistryInfo

mov esi,_lpRltDataTableBuf
mov ecx,_dwRltDataTableBufSize
shr ecx,3
CheckEmptyRoom:
push ecx
push esi
lodsd
cmp eax,0ffffffffh
jz GetEmptyRoom
pop esi
add esi,8
pop ecx
loop CheckEmptyRoom
jmp RealTimeDataInfoBufFull

GetEmptyRoom:
invoke VirtualAlloc,NULL,_stSystemInfo.dwPageSize,MEM_COMMIT,PAGE_READWRITE
mov @lpRealTimeDataBuf,eax
pop esi
pop ecx
mov ebx,@dwQueryPointOrdinal
mov dword ptr [esi],ebx
mov dword ptr [esi+4],eax
mov edi,@lpRealTimeDataBuf
mov dword ptr [edi],eax
add eax,16
mov dword ptr [edi+4],eax
mov dword ptr [edi+8],eax
pop edi
pop esi
pop ebx
mov eax,1
mov edx,0
leave
retn 8

RealTimeDataInfoBufFull:
pop edi
pop esi
pop ebx
mov eax,0
mov edx,0
leave
retn 8



CancelRegistryInfo:
mov esi,_lpRltDataTableBuf
mov ecx,_dwRltDataTableBufSize
shr ecx,3
CheckPointOrdinal:
push ecx
push esi
lodsd
cmp eax,@dwQueryPointOrdinal
jz GetPointOrdinal
pop esi
add esi,8
pop ecx
loop CheckPointOrdinal
jmp NotFoundPointOrdinal

GetPointOrdinal:
pop esi
pop ecx
mov edi,[esi+4]
mov dword ptr [esi],0ffffffffh
mov dword ptr [esi+4],0ffffffffh
push edi
invoke VirtualFree,edi,_stSystemInfo.dwPageSize,MEM_DECOMMIT            ;此处内存已释放，总函数不必释放了
pop edi
invoke VirtualFree,edi,0,MEM_RELEASE
pop edi
pop esi
pop ebx
mov eax,1
mov edx,0
leave
retn 8

NotFoundPointOrdinal:
pop edi
pop esi
pop ebx
mov eax,0
mov edx,0
leave
retn 8
_ProcRegistryInfo endp












_ProcGetRealTimeData proc,lpszPointId
local @dwQueryPointOrdinal
local @dwQueryPointIdLen
local @lpPointDirFileEnd
local @lpQueryDataBuf
local @lpRealTimeDataBufHead
local @lpRealTimeDataBufEnd
local @dwRealTimeDataCnt

push ebx
push esi
push edi
cld
mov esi,lpszPointId
GetPointIdLen:
lodsb
cmp al,0
jnz GetPointIdLen
dec esi
sub esi,lpszPointId
cmp esi,0
jz ErrorParam
mov @dwQueryPointIdLen,esi

invoke EnterCriticalSection,addr _stCriticalPointDir
mov ebx,_dwPointDirBufSize
add ebx,_lpPointDirBuf
mov @lpPointDirFileEnd,ebx
mov @dwQueryPointOrdinal,0
mov esi,_lpPointDirBuf
SeekFirstDot:
lodsb
cmp al,2ch
jnz SeekFirstDot
SeekSecondDot:
lodsb
cmp al,2ch
jnz SeekSecondDot
mov edi,lpszPointId
mov ecx,@dwQueryPointIdLen
repz cmpsb
jz CheckLastChar
GetEnterSymbol:
lodsb
cmp esi,@lpPointDirFileEnd
jae ErrorParam
cmp al,0ah
jnz GetEnterSymbol
inc @dwQueryPointOrdinal
jmp SeekFirstDot

ErrorParam:
invoke LeaveCriticalSection,addr _stCriticalPointDir
pop edi
pop esi
pop ebx
mov eax,0
mov edx,0
leave
retn 4


CheckLastChar:
lodsb
cmp al,2ch
jnz ErrorParam
invoke LeaveCriticalSection,addr _stCriticalPointDir
mov esi,_lpRltDataTableBuf
mov ecx,_dwRltDataTableBufSize
shr ecx,3
CheckRltDataTable:
push ecx
push esi
lodsd
cmp eax,@dwQueryPointOrdinal
jz GetQueryPointOrdinal
pop esi
add esi,8
pop ecx
loop CheckRltDataTable
GetRealTimeDataError:
pop edi
pop esi
pop ebx
mov eax,0
mov edx,0
leave
retn 4

GetQueryPointOrdinal:
pop esi
pop ecx
mov eax,[esi+4]
mov @lpRealTimeDataBufHead,eax
cmp eax,dword ptr [eax]
jnz GetRealTimeDataError
invoke VirtualAlloc,NULL,_stSystemInfo.dwPageSize,MEM_COMMIT,PAGE_READWRITE
mov @lpQueryDataBuf,eax
mov dword ptr [eax],eax
mov edi,eax
add edi,8                               ;接收缓冲比实时数据缓冲区大，因此复制时不会发生溢出

mov ebx,@lpRealTimeDataBufHead
mov esi,[ebx+4]
mov edx,[ebx+8]
add ebx,_stSystemInfo.dwPageSize
mov @dwRealTimeDataCnt,0

CopyDataToBuf:
cmp esi,edx
jz CopyDataOk
cmp esi,ebx
jae RewindEndPointer
CopyToBuf:
mov ecx,5
rep movsd
inc @dwRealTimeDataCnt
jmp CopyDataToBuf

RewindEndPointer:
mov esi,@lpRealTimeDataBufHead
add esi,16
jmp CopyDataToBuf

CopyDataOk:
mov edi,@lpRealTimeDataBufHead
mov [edi+4],esi
mov ebx,@lpQueryDataBuf
push @dwRealTimeDataCnt
pop dword ptr [ebx+4]
pop edi
pop esi
pop ebx
mov eax,@lpQueryDataBuf
mov edx,0
leave
retn 4
_ProcGetRealTimeData endp













;所有的点的格式必须要保证格式，切最大长度不能超过２５６字节
_ProcInsertPoint proc stdcall,lpszPointID,lpszPointContent
local @dwDotCnt
local @lpCurrentRecordEnd
local @lpCurrentRecordHead
local @dwPointIdLen
local @dwPointContentLen
local @dwFileEndPos
local @lpInsertID
local @dwInsertIdLen
local @lpInsertHead
local @lpInsertEnd
local @flFound
local @lpszPointContent[200h]:byte
local @szBuf[200h]:byte
local @szBufTime[100h]:byte

push ebx
push esi
push edi
invoke EnterCriticalSection,addr _stCriticalPointDir
cmp dword ptr _dwPointDirBufSize,0
jz InvalidParam

cld
mov esi,lpszPointID
GetPointIdLen:
lodsb
cmp al,0
jnz GetPointIdLen
dec esi              
sub esi,lpszPointID
cmp esi,0
jz InvalidParam
mov @dwPointIdLen,esi

mov esi,lpszPointContent
mov @dwDotCnt,0
GetInsertID:
lodsb
cmp al,2ch
jnz GetInsertID
inc @dwDotCnt
cmp @dwDotCnt,2
jnz GetInsertID
mov @lpInsertID,esi

mov @dwInsertIdLen,0
GetInsertIdLen:
lodsb
cmp al,2ch
jz GetInsertIdEnd
inc @dwInsertIdLen
jmp GetInsertIdLen

GetInsertIdEnd:
cmp @dwInsertIdLen,0
jz InvalidParam

GetPointContentLen:
lodsb
cmp al,0
jnz GetPointContentLen
dec esi              
sub esi,lpszPointContent
cmp esi,0
jz InvalidParam
mov @dwPointContentLen,esi

mov esi,lpszPointContent
lea edi,@lpszPointContent
mov ecx,@dwPointContentLen
rep movsb
mov eax,0a0dh
stosd
add @dwPointContentLen,2

mov eax,_lpPointDirBuf
add eax,_dwPointDirBufSize
mov @dwFileEndPos,eax

mov esi,_lpPointDirBuf
mov @lpCurrentRecordHead,esi
GetCurrentRecordEnd:
lodsb
cmp al,0ah
jnz GetCurrentRecordEnd
mov @lpCurrentRecordEnd,esi

mov @flFound,0
mov @dwDotCnt,0
mov esi,_lpPointDirBuf
GetRecordId:
lodsb
cmp al,2ch
jnz GetRecordId
inc @dwDotCnt
cmp @dwDotCnt,2
jnz GetRecordId

mov @dwDotCnt,0
mov ecx,@dwInsertIdLen
mov edi,@lpInsertID
push esi
repz cmpsb
jnz CheckInsertID
lodsb
cmp al,2ch
jz FindSamePoint
;注意:  不能将比较运算完成后所得的ECX值作为比较相等的参考依据.原因是什么????????????
;原因:例如若要比较1和2的值是否相等,他们的长度都为１,比较完成后ECX==0,但是他们却不相等

CheckInsertID:
pop esi
mov ecx,@dwPointIdLen
mov edi,lpszPointID
repz cmpsb
jnz GetCurrentRecordStart
lodsb
cmp al,2ch
jz GetNextRecordStart
;注意:  不能将比较运算完成后所得的ECX值作为比较相等的参考依据.原因是什么????????????
;原因:例如若要比较1和2的值是否相等,他们的长度都为１,比较完成后ECX==0,但是他们却不相等

GetCurrentRecordStart:
lodsb
cmp esi,@dwFileEndPos
jae GetPointEnd                       
cmp al,0ah
jnz GetCurrentRecordStart
mov @lpCurrentRecordHead,esi
jmp GetRecordId

GetNextRecordStart:
mov dword ptr @flFound,1
push @lpCurrentRecordHead
pop @lpInsertHead
GetNextRecordStartAddr:
lodsb
cmp esi,@dwFileEndPos
jae FindPointEndLast                       
cmp al,0ah
jnz GetNextRecordStartAddr
mov @lpInsertEnd,esi
mov @lpCurrentRecordHead,esi
jmp GetRecordId

FindPointEndLast:
mov @lpInsertEnd,esi

GetPointEnd:
mov @lpCurrentRecordEnd,esi
cmp @flFound,1
jnz InvalidParam

std
mov eax,@lpInsertHead
sub eax,_lpPointDirBuf
mov ecx,_dwPointDirBufSize
sub ecx,eax
mov esi,_lpPointDirBuf
add esi,_dwPointDirBufSize
dec esi
mov edi,esi
add edi,@dwPointContentLen
rep movsb

lea esi,@lpszPointContent
add esi,@dwPointContentLen
dec esi
mov ecx,@dwPointContentLen
rep movsb

cld
mov ecx,@dwPointContentLen
add _dwPointDirBufSize,ecx

mov esi,FILE_POINTDIR_SIZE
mov eax,_lpPointDirBuf
push _dwPointDirBufSize
pop dword ptr [esi+eax-4]

mov eax,_dwFreeRecordCnt
cmp eax,0
jz NotEnoughSpace
lock inc dword ptr _dwDcsSampleCnt
lock dec _dwFreeRecordCnt

NotEnoughSpace:
invoke LeaveCriticalSection,addr _stCriticalPointDir

lea eax,@szBufTime
push eax
call _ProcSysTimeToAsc

invoke wsprintf,addr @szBuf,addr szPointInsert,addr @szBufTime,lpszPointID,lpszPointContent
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwDotCnt,0

pop edi
pop esi
pop ebx
mov eax,1
mov edx,0
leave
retn 8

FindSamePoint:
pop esi
InvalidParam:
invoke LeaveCriticalSection,addr _stCriticalPointDir
pop edi
pop esi
pop ebx
mov eax,0
mov edx,0
leave
retn 8
_ProcInsertPoint endp













_ProcAddPoint proc,lpszPointContent
local @dwPointContentLen
local @dwPointIdLen
local @dwFileEndPos
local @dwDotCnt
local @szBuf[200h]:byte
local @szBufTime[100h]:byte
local @lpPointID

push ebx
push esi
push edi
invoke EnterCriticalSection,addr _stCriticalPointDir

cld
mov esi,lpszPointContent
mov @dwDotCnt,0
GetPointIdHeadPos:
lodsb
cmp al,2ch
jnz GetPointIdHeadPos
inc @dwDotCnt
cmp @dwDotCnt,2
jnz GetPointIdHeadPos
mov @lpPointID,esi

mov @dwPointIdLen,0
GetPointIdLen:
lodsb
cmp al,2ch
jz GetPointIdEndPos
inc @dwPointIdLen
jmp GetPointIdLen

GetPointIdEndPos:
cmp @dwPointIdLen,0
jz KeepLenth

GetPointContentLen:
lodsb
cmp al,0
jnz GetPointContentLen
dec esi              
sub esi,lpszPointContent
cmp esi,0
jz KeepLenth
mov @dwPointContentLen,esi

cmp dword ptr _dwPointDirBufSize,0
jz ToAddPointDir

mov eax,_lpPointDirBuf
add eax,_dwPointDirBufSize
mov @dwFileEndPos,eax

mov @dwDotCnt,0                         
mov esi,_lpPointDirBuf
GetRecordId:                            ;检查是否有重复的数据记录
lodsb
cmp al,2ch
jnz GetRecordId
inc @dwDotCnt
cmp @dwDotCnt,2
jnz GetRecordId

mov @dwDotCnt,0
mov ecx,@dwPointIdLen
mov edi,@lpPointID
repz cmpsb
jnz GetCurrentRecordHead
lodsb
cmp al,2ch
jz KeepLenth
;注意:  不能将比较运算完成后所得的ECX值作为比较相等的参考依据.原因是什么????????????
;原因:例如若要比较1和2的值是否相等,他们的长度都为１,比较完成后ECX==0,但是他们却不相等

GetCurrentRecordHead:
lodsb
cmp esi,@dwFileEndPos
jae ToAddPointDir                       
cmp al,0ah
jnz GetCurrentRecordHead
jmp GetRecordId

ToAddPointDir:
mov edi,_lpPointDirBuf
add edi,_dwPointDirBufSize
cmp word ptr [edi-2],0a0dh
jz HaveChangeLine
mov ax,0a0dh
stosw
add _dwPointDirBufSize,2
HaveChangeLine:
mov esi,lpszPointContent
mov ecx,@dwPointContentLen
rep movsb
mov ax,0a0dh
stosw
add dword ptr @dwPointContentLen,2

mov eax,@dwPointContentLen
add _dwPointDirBufSize,eax
mov esi,FILE_POINTDIR_SIZE
mov eax,_lpPointDirBuf
push _dwPointDirBufSize
pop dword ptr [esi+eax-4]

mov eax,_dwFreeRecordCnt
cmp eax,0
jz NotEnoughSpace
lock inc dword ptr _dwDcsSampleCnt
lock dec _dwFreeRecordCnt
NotEnoughSpace:
invoke LeaveCriticalSection,addr _stCriticalPointDir

lea eax,@szBufTime
push eax
call _ProcSysTimeToAsc
invoke wsprintf,addr @szBuf,addr szPointAdd,addr @szBufTime,lpszPointContent
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwDotCnt,0
pop edi
pop esi
pop ebx
mov eax,1
mov edx,0
leave
retn 4

KeepLenth:
invoke LeaveCriticalSection,addr _stCriticalPointDir
pop edi
pop esi
pop ebx
mov eax,0
mov edx,0
leave
retn 4
_ProcAddPoint endp














_ProcDeletePoint proc,lpszPointID
local @dwDotCnt
local @lpCurrentRecordEnd
local @lpCurrentRecordHead
local @dwPointIdLen
local @dwFileEndPos
local @szBuf[200h]:byte
local @szBufTime[100h]:byte

push ebx
push esi
push edi
invoke EnterCriticalSection,addr _stCriticalPointDir
cmp _dwPointDirBufSize,0
jz ReachFileEnd

cld
mov esi,lpszPointID
GetPointIdLen:
lodsb
cmp al,0
jnz GetPointIdLen
dec esi            
sub esi,lpszPointID
cmp esi,0
jz ReachFileEnd
mov @dwPointIdLen,esi

mov eax,_lpPointDirBuf
add eax,_dwPointDirBufSize
mov @dwFileEndPos,eax

mov esi,_lpPointDirBuf
mov @lpCurrentRecordHead,esi
GetCurrentRecordEnd:
lodsb
cmp al,0ah
jnz GetCurrentRecordEnd
mov @lpCurrentRecordEnd,esi

mov @dwDotCnt,0
mov esi,_lpPointDirBuf
GetRecordId:
lodsb
cmp al,2ch
jnz GetRecordId
inc @dwDotCnt
cmp @dwDotCnt,2
jnz GetRecordId
mov @dwDotCnt,0
mov ecx,@dwPointIdLen
mov edi,lpszPointID
repz cmpsb
jnz GetCurrentRecordHead
lodsb
cmp al,2ch
jz GetNextRecordStart
;注意:  不能将比较运算完成后所得的ECX值作为比较相等的参考依据.原因是什么????????????
;原因:例如若要比较1和2的值是否相等,他们的长度都为１,比较完成后ECX==0,但是他们却不相等

GetCurrentRecordHead:
lodsb
cmp esi,@dwFileEndPos
jae ReachFileEnd                         ;此处末尾与文件冲突么？？？？？
cmp al,0ah
jnz GetCurrentRecordHead
mov @lpCurrentRecordHead,esi
jmp GetRecordId

GetNextRecordStart:
lodsb
cmp esi,@dwFileEndPos 
jae GetPointEnd                     
cmp al,0ah
jnz GetNextRecordStart
GetPointEnd:
mov @lpCurrentRecordEnd,esi

mov eax,@lpCurrentRecordEnd
sub eax,_lpPointDirBuf
mov ecx,_dwPointDirBufSize
sub ecx,eax
mov esi,@lpCurrentRecordEnd
mov edi,@lpCurrentRecordHead
rep movsb

mov ecx,@lpCurrentRecordEnd
sub ecx,@lpCurrentRecordHead
sub _dwPointDirBufSize,ecx
mov al,0
rep stosb

mov esi,FILE_POINTDIR_SIZE
mov eax,_lpPointDirBuf
push _dwPointDirBufSize
pop dword ptr [esi+eax-4]

mov eax,_dwDcsSampleCnt
cmp eax,0
jz IsEmptyFile
lock dec dword ptr _dwDcsSampleCnt
lock inc _dwFreeRecordCnt
IsEmptyFile:
invoke LeaveCriticalSection,addr _stCriticalPointDir

lea eax,@szBufTime
push eax
call _ProcSysTimeToAsc
invoke wsprintf,addr @szBuf,addr szPointDelete,addr @szBufTime,lpszPointID
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwDotCnt,0
pop edi
pop esi
pop ebx
mov eax,1
mov edx,0
leave
retn 4

ReachFileEnd:
invoke LeaveCriticalSection,addr _stCriticalPointDir
pop edi
pop esi
pop ebx
mov eax,0
mov edx,0
leave
retn 4
_ProcDeletePoint endp















_ProcModifyPoint proc,lpszPointID,lpszPointContent
local @dwDotCnt
local @lpCurrentRecordEnd
local @lpCurrentRecordHead
local @dwPointIdLen
local @dwPointContentLen
local @dwFileEndPos
local @lpInsertID
local @dwInsertIdLen
local @lpszPointContent[100h]:byte
local @szBuf[200h]:byte
local @szBufTime[100h]:byte

push ebx
push esi
push edi
invoke EnterCriticalSection,addr _stCriticalPointDir
cmp dword ptr _dwPointDirBufSize,0
jz InvalidParam

cld
mov esi,lpszPointID
GetPointIdLen:
lodsb
cmp al,0
jnz GetPointIdLen
dec esi              
sub esi,lpszPointID
cmp esi,0
jz InvalidParam
mov @dwPointIdLen,esi

mov @dwDotCnt,0
mov esi,lpszPointContent
GetInsertIDHeadPos:
lodsb
cmp al,2ch
jnz GetInsertIDHeadPos
inc @dwDotCnt
cmp @dwDotCnt,2
jnz GetInsertIDHeadPos
mov @lpInsertID,esi

mov @dwInsertIdLen,0
GetInsertIdLen:
lodsb
cmp al,2ch
jz GetInsertIdEnd
inc @dwInsertIdLen
jmp GetInsertIdLen

GetInsertIdEnd:
cmp @dwInsertIdLen,0
jz InvalidParam

GetPointContentLen:
lodsb
cmp al,0
jnz GetPointContentLen
dec esi              
sub esi,lpszPointContent
cmp esi,0
jz InvalidParam
mov @dwPointContentLen,esi

mov ecx,@dwInsertIdLen
cmp ecx,@dwPointIdLen
jnz InvalidParam
mov esi,lpszPointID
mov edi,@lpInsertID
repz cmpsb
jnz InvalidParam

mov esi,lpszPointContent
lea edi,@lpszPointContent
mov ecx,@dwPointContentLen
rep movsb
mov eax,0a0dh
stosd
add @dwPointContentLen,2

mov eax,_lpPointDirBuf
add eax,_dwPointDirBufSize
mov @dwFileEndPos,eax

mov esi,_lpPointDirBuf
mov @lpCurrentRecordHead,esi
GetCurrentRecordEnd:
lodsb
cmp al,0ah
jnz GetCurrentRecordEnd
mov @lpCurrentRecordEnd,esi

mov @dwDotCnt,0
mov esi,_lpPointDirBuf
GetRecordId:
lodsb
cmp al,2ch
jnz GetRecordId
inc @dwDotCnt
cmp @dwDotCnt,2
jnz GetRecordId

mov @dwDotCnt,0
mov ecx,@dwPointIdLen
mov edi,lpszPointID
repz cmpsb 
jnz GetCurrentRecordStart
lodsb
cmp al,2ch
jz GetNextRecordStart
;注意:  不能将比较运算完成后所得的ECX值作为比较相等的参考依据.原因是什么????????????
;原因:例如若要比较1和2的值是否相等,他们的长度都为１,比较完成后ECX==0,但是他们却不相等

GetCurrentRecordStart:
lodsb
cmp esi,@dwFileEndPos
jae InvalidParam                       
cmp al,0ah
jnz GetCurrentRecordStart
mov @lpCurrentRecordHead,esi
jmp GetRecordId

GetNextRecordStart:
lodsb
cmp esi,@dwFileEndPos
jae FindPointEndLast                       
cmp al,0ah
jnz GetNextRecordStart
FindPointEndLast:
mov @lpCurrentRecordEnd,esi

mov eax,@lpCurrentRecordEnd
sub eax,@lpCurrentRecordHead
mov ebx,@dwPointContentLen
cmp eax,ebx
jae ShortLine

sub ebx,eax
push ebx
mov esi,_lpPointDirBuf
add esi,_dwPointDirBufSize
dec esi
mov edi,esi
add edi,ebx
mov eax,@lpCurrentRecordEnd
sub eax,_lpPointDirBuf
mov ecx,_dwPointDirBufSize
sub ecx,eax
std
rep movsb

lea esi,@lpszPointContent
add esi,@dwPointContentLen
dec esi
mov ecx,@dwPointContentLen
rep movsb

pop ebx
add _dwPointDirBufSize,ebx
cld
jmp ModifyLenth


ShortLine:
cld
sub eax,ebx
push eax
lea esi,@lpszPointContent
mov edi,@lpCurrentRecordHead
mov ecx,@dwPointContentLen
rep movsb

mov ebx,@lpCurrentRecordEnd
sub ebx,_lpPointDirBuf
mov ecx,_dwPointDirBufSize
sub ecx,ebx
mov esi,@lpCurrentRecordEnd
rep movsb
pop ecx
sub _dwPointDirBufSize,ecx
mov al,0
rep stosb

ModifyLenth:
mov esi,FILE_POINTDIR_SIZE
mov eax,_lpPointDirBuf
push _dwPointDirBufSize
pop dword ptr [esi+eax-4]

invoke LeaveCriticalSection,addr _stCriticalPointDir
lea eax,@szBufTime
push eax
call _ProcSysTimeToAsc
invoke wsprintf,addr @szBuf,addr szPointModify,addr @szBufTime,lpszPointID,lpszPointContent
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwDotCnt,0

pop edi
pop esi
pop ebx
mov eax,1
mov edx,0
leave
retn 8


InvalidParam:
invoke LeaveCriticalSection,addr _stCriticalPointDir
pop edi
pop esi
pop ebx
mov eax,0
mov edx,0
leave
retn 8
_ProcModifyPoint endp












_ProcSeekPoint proc,lpszPointID
local @lpCurrentRecordEnd
local @lpCurrentRecordHead
local @dwPointIdLen
local @dwFileEndPos
local @dwDotCnt
local @szBuf[200h]:byte
local @szBufTime[100h]:byte
local @szBuffer[200h]:byte
local @lpSeekPointBuf

push ebx
push esi
push edi
invoke EnterCriticalSection,addr _stCriticalPointDir
cmp dword ptr _dwPointDirBufSize,0
jz ReachFileEnd

cld
mov esi,lpszPointID
GetPointIdLen:
lodsb
cmp al,0
jnz GetPointIdLen
dec esi            
sub esi,lpszPointID
cmp esi,0
jz ReachFileEnd
mov @dwPointIdLen,esi

mov eax,_lpPointDirBuf
add eax,_dwPointDirBufSize
mov @dwFileEndPos,eax

mov esi,_lpPointDirBuf
mov @lpCurrentRecordHead,esi
GetCurrentRecordEnd:
lodsb
cmp al,0ah
jnz GetCurrentRecordEnd
mov @lpCurrentRecordEnd,esi

mov @dwDotCnt,0
mov esi,_lpPointDirBuf
GetRecordId:
lodsb
cmp al,2ch
jnz GetRecordId
inc @dwDotCnt
cmp @dwDotCnt,2
jnz GetRecordId
mov @dwDotCnt,0
mov ecx,@dwPointIdLen
mov edi,lpszPointID
repz cmpsb
jnz GetCurrentRecordHead
lodsb
cmp al,2ch
jz GetNextRecordStart
;注意:  不能将比较运算完成后所得的ECX值作为比较相等的参考依据.原因是什么????????????
;原因:例如若要比较1和2的值是否相等,他们的长度都为１,比较完成后ECX==0,但是他们却不相等

GetCurrentRecordHead:
lodsb
cmp esi,@dwFileEndPos
jae ReachFileEnd
cmp al,0ah
jnz GetCurrentRecordHead
mov @lpCurrentRecordHead,esi
jmp GetRecordId

GetNextRecordStart:
lodsb
cmp esi,@dwFileEndPos
jae GetPointEnd                       
cmp al,0ah
jnz GetNextRecordStart
GetPointEnd:
mov @lpCurrentRecordEnd,esi

invoke VirtualAlloc,0,_stSystemInfo.dwPageSize,MEM_COMMIT,PAGE_READWRITE
mov @lpSeekPointBuf,eax
mov edi,eax
mov esi,@lpCurrentRecordHead
mov ecx,@lpCurrentRecordEnd
sub ecx,@lpCurrentRecordHead
rep movsb

invoke LeaveCriticalSection,addr _stCriticalPointDir
lea eax,@szBufTime
push eax
call _ProcSysTimeToAsc
lea edi,@szBuffer
mov esi,@lpSeekPointBuf
mov ecx,@lpCurrentRecordEnd
sub ecx,@lpCurrentRecordHead
sub ecx,2
rep movsb
mov al,0
stosb
invoke wsprintf,addr @szBuf,addr szPointSeek,addr @szBufTime,addr @szBuffer
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwDotCnt,0

mov eax,@lpSeekPointBuf
mov edx,0
pop edi
pop esi
pop ebx
leave 
retn 4

ReachFileEnd:
invoke LeaveCriticalSection,addr _stCriticalPointDir
mov eax,0
mov edx,0
pop edi
pop esi
pop ebx
leave 
retn 4
_ProcSeekPoint endp






_ProcGetPointTable proc
local @szBuffer[100h]:byte
local @szBuf[200h]:byte
local @dwCounter

push ebx
push esi
push edi
invoke EnterCriticalSection,addr _stCriticalPointDir
cmp  _dwPointDirBufSize,0
jz NullBuf

lea eax,@szBuffer
push eax
call _ProcSysTimeToAsc
invoke wsprintf,addr @szBuf,addr szGetPointTable,addr @szBuffer
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0

mov eax,_lpPointDirBuf
mov esi,_dwPointDirBufSize
mov byte ptr [esi+eax],0
invoke LeaveCriticalSection,addr _stCriticalPointDir
mov eax,_lpPointDirBuf
mov edx,0
pop edi
pop esi
pop ebx
leave
retn 0

NullBuf:
invoke LeaveCriticalSection,addr _stCriticalPointDir
pop edi
pop esi
pop ebx
mov eax,0
mov edx,0
leave
retn 0
_ProcGetPointTable endp










_ProcSysTimeToAsc proc,lpOutPutBuf
local @stSystemTime:SYSTEMTIME

push ebx
push esi
push edi
invoke GetLocalTime,addr @stSystemTime
mov ax,@stSystemTime.wYear
movzx eax,ax
mov bx,@stSystemTime.wMonth
movzx ebx,bx
mov cx,@stSystemTime.wDay
movzx ecx,cx
mov dx,@stSystemTime.wHour
movzx edx,dx
mov di,@stSystemTime.wMinute
movzx edi,di
mov si,@stSystemTime.wSecond
movzx esi,si
invoke wsprintf,lpOutPutBuf,addr szSystemTime,eax,ebx,ecx,edx,edi,esi
mov edx,0
pop edi
pop esi
pop ebx
leave
retn 4
_ProcSysTimeToAsc endp


        







_ProcNewExceptionFilter proc,lpExceptionPoint
local @szBuffer[100h]:byte
local @szBuf[200h]:byte
local @dwCounter

pushad
lea eax,@szBuffer
push eax
call _ProcSysTimeToAsc
mov esi,lpExceptionPoint
assume esi:ptr EXCEPTION_POINTERS
mov edi,[esi].ContextRecord
mov esi,[esi].pExceptionRecord
assume esi:ptr EXCEPTION_RECORD,edi:ptr CONTEXT
invoke wsprintf,addr @szBuf,addr szMsgException,addr @szBuffer,[esi].ExceptionAddress,[esi].ExceptionCode,[esi].ExceptionFlags
mov ecx,eax
invoke WriteFile,_hFileJournal,addr @szBuf,ecx,addr @dwCounter,0

call _ProcTerminate
invoke ExitProcess,0
popad
mov eax,EXCEPTION_CONTINUE_SEARCH
leave
retn 4
_ProcNewExceptionFilter endp












;用户信息文件初始化:16个字节的用户名（不足用空格补齐），16个字节的密码（不足用空格补齐），回车换行符
_ProcSeekUser proc,lpszUserName,lpszPassWord
local @szPassWord[USER_PASSWORD_LEN]:byte
local @szUserName[USER_NAME_LEN]:byte
local @lpUserInfoEnd

push ebx
push esi
push edi
cld
mov esi,lpszUserName
lea edi,@szUserName
GetUserNameLen:
lodsb
cmp al,0
jz GetUserNameEnd
stosb
jmp GetUserNameLen
GetUserNameEnd:
mov esi,edi
lea ebx,@szUserName
sub esi,ebx
cmp esi,0
jz InvalidParam
cmp esi,USERNAME_PASSWORD_LEN
ja InvalidParam
mov ecx,sizeof @szUserName
sub ecx,esi
mov al,20h
rep stosb

mov esi,lpszPassWord
lea edi,@szPassWord
GetPassWordLen:
lodsb
cmp al,0
jz GetPassWordEnd
stosb
jmp GetPassWordLen
GetPassWordEnd:
mov esi,edi
lea ebx,@szPassWord
sub esi,ebx
cmp esi,0
jz InvalidParam
cmp esi,USERNAME_PASSWORD_LEN
ja InvalidParam
mov ecx,sizeof @szPassWord
sub ecx,esi
mov al,20h
rep stosb

invoke EnterCriticalSection,addr _stCriticalUserInfo
cmp dword ptr _dwUserInfoBufSize,0
jz ToInvalidParam

mov esi,_lpUserInfoBuf
mov ebx,esi
add ebx,_dwUserInfoBufSize
mov @lpUserInfoEnd,ebx

CheckNextUser:
push esi
lea edi,@szUserName
mov ecx,sizeof @szUserName
repz cmpsb
jnz ToCheckNextUser

mov ecx,sizeof @szPassWord
lea edi,@szPassWord
repz cmpsb
jnz ToCheckNextUser

pop esi
jmp GetUserNameCorrect

ToCheckNextUser:
pop esi
add esi,USER_INFO_LEN
cmp esi,@lpUserInfoEnd
jb CheckNextUser

ToInvalidParam:
invoke LeaveCriticalSection,addr _stCriticalUserInfo
InvalidParam:
mov eax,0
mov edx,0
pop edi
pop esi
pop ebx
leave
retn 8

GetUserNameCorrect:
lea esi,szAdminLogon
lea edi,@szUserName
mov ecx,sizeof @szUserName
repz cmpsb
jz AdminiatratorLogon
invoke LeaveCriticalSection,addr _stCriticalUserInfo
mov eax,1
mov edx,0
pop edi
pop esi
pop ebx
leave
retn 8

AdminiatratorLogon:
invoke LeaveCriticalSection,addr _stCriticalUserInfo
mov eax,2
mov edx,0
pop edi
pop esi
pop ebx
leave
retn 8
_ProcSeekUser endp








_ProcAddUser proc,lpszUserName,lpszPassWord                            
local @szPassWord[USER_PASSWORD_LEN]:byte       ;高位       
local @szUserName[USER_NAME_LEN]:byte           ;低位
local @lpUserInfoEnd

push ebx
push esi
push edi
cld
mov esi,lpszUserName
lea edi,@szUserName
GetUserNameLen:
lodsb
cmp al,0
jz GetUserNameEnd
stosb
jmp GetUserNameLen
GetUserNameEnd:
mov esi,edi
lea ebx,@szUserName
sub esi,ebx
cmp esi,0
jz InvalidParam
cmp esi,USERNAME_PASSWORD_LEN
ja InvalidParam
mov ecx,sizeof @szUserName
sub ecx,esi
mov al,20h
rep stosb

mov esi,lpszPassWord
lea edi,@szPassWord
GetPassWordLen:
lodsb
cmp al,0
jz GetPassWordEnd
stosb
jmp GetPassWordLen
GetPassWordEnd:
mov esi,edi
lea ebx,@szPassWord
sub esi,ebx
cmp esi,0
jz InvalidParam
cmp esi,USERNAME_PASSWORD_LEN
ja InvalidParam
mov ecx,sizeof @szPassWord
sub ecx,esi
mov al,20h
rep stosb

invoke EnterCriticalSection,addr _stCriticalUserInfo
cmp dword ptr _dwUserInfoBufSize,0
jz AddUserInfo

mov esi,_lpUserInfoBuf
mov ebx,esi
add ebx,_dwUserInfoBufSize
mov @lpUserInfoEnd,ebx

CheckNextUser:
push esi
lea edi,@szUserName
mov ecx,sizeof @szUserName
repz cmpsb
jz FoundSameInfo

pop esi
add esi,USER_INFO_LEN
cmp esi,@lpUserInfoEnd
jb CheckNextUser

AddUserInfo:
lea esi,@szUserName
mov edi,_lpUserInfoBuf
add edi,_dwUserInfoBufSize
mov ecx,sizeof @szUserName
add ecx,sizeof @szPassWord
rep movsb
mov ax,0a0dh
stosw
add dword ptr [_dwUserInfoBufSize],USER_INFO_LEN
push dword ptr [_dwUserInfoBufSize]
mov esi,_lpUserInfoBuf
mov ebx,FILE_USERINFO_SIZE
pop dword ptr [esi+ebx-4]
invoke LeaveCriticalSection,addr _stCriticalUserInfo
mov eax,1
mov edx,0
pop edi
pop esi
pop ebx
leave
retn 8

FoundSameInfo:
pop esi
invoke LeaveCriticalSection,addr _stCriticalUserInfo
InvalidParam:
mov eax,0
mov edx,0
pop edi
pop esi
pop ebx
leave
retn 8
_ProcAddUser endp








_ProcDeleteUser proc,lpszUserName,lpszPassWord
local @szPassWord[USER_PASSWORD_LEN]:byte
local @szUserName[USER_NAME_LEN]:byte
local @lpUserInfoEnd

push ebx
push esi
push edi
cld
mov esi,lpszUserName
lea edi,@szUserName
GetUserNameLen:
lodsb
cmp al,0
jz GetUserNameEnd
stosb
jmp GetUserNameLen
GetUserNameEnd:
mov esi,edi
lea ebx,@szUserName
sub esi,ebx
cmp esi,0
jz InvalidParam
cmp esi,USERNAME_PASSWORD_LEN
ja InvalidParam
mov ecx,sizeof @szUserName
sub ecx,esi
mov al,20h
rep stosb

lea esi,szAdminLogon
lea edi,@szUserName
mov ecx,sizeof @szUserName
repz cmpsb
jz InvalidParam
invoke EnterCriticalSection,addr _stCriticalUserInfo
cmp dword ptr _dwUserInfoBufSize,0
jz NotFoundSameInfo

mov esi,_lpUserInfoBuf
mov ebx,esi
add ebx,_dwUserInfoBufSize
mov @lpUserInfoEnd,ebx

CheckNextName:
push esi
lea edi,@szUserName
mov ecx,sizeof @szUserName
repz cmpsb
jz GetSameUserName
pop esi
add esi,USER_INFO_LEN
cmp esi,@lpUserInfoEnd
jb CheckNextName

NotFoundSameInfo:
invoke LeaveCriticalSection,addr _stCriticalUserInfo
InvalidParam:
mov eax,0
mov edx,0
pop edi
pop esi
pop ebx
leave
retn 8

GetSameUserName:
pop esi
mov edi,esi
add esi,USER_INFO_LEN
mov eax,esi
sub eax,_lpUserInfoBuf
mov ecx,_dwUserInfoBufSize
sub ecx,eax
rep movsb
mov ecx,esi
sub ecx,edi
push ecx
mov al,0
rep stosb

pop ecx
sub dword ptr [_dwUserInfoBufSize],ecx
push dword ptr [_dwUserInfoBufSize]
mov esi,_lpUserInfoBuf
mov ebx,FILE_USERINFO_SIZE
pop dword ptr [esi+ebx-4]
invoke LeaveCriticalSection,addr _stCriticalUserInfo
mov eax,1
mov edx,0
pop edi
pop esi
pop ebx
leave
retn 8
_ProcDeleteUser endp











_ProcClientShowValue proc,lpValueBuf,nOrdinal
local @dwValue
local @szBuf[200h]:byte

push ebx
push esi
push edi
cmp nOrdinal,1
jnz ToAddTo
lea ebx,_ThreadCreateDlg
invoke CreateThread,0,0,ebx,0,0,0
invoke CloseHandle,eax
WaitInitOk:
cmp _hDlgShowValue,0
jz WaitInitOk
ToAddTo:
mov esi,lpValueBuf
mov ax,word ptr [esi]
movzx eax,ax
mov bx,word ptr [esi+2]
movzx ebx,bx
mov cx,word ptr [esi+6]
movzx ecx,cx
mov dx,word ptr [esi+8]
movzx edx,dx
mov di,word ptr [esi+10]
movzx edi,di
push dword ptr [esi+16]
pop dword ptr @dwValue
mov si,word ptr [esi+12]
movzx esi,si
invoke wsprintf,addr @szBuf,addr szClientShowValue,eax,ebx,ecx,edx,edi,esi,@dwValue
invoke SendDlgItemMessage,_hDlgShowValue,_LIST_CLIENT_SHOWVALUE,LB_ADDSTRING,0,addr @szBuf
ClientShowValueEnd:
pop edi
pop esi
pop ebx
mov eax,1
mov edx,0
leave
retn 8
_ProcClientShowValue endp







_ThreadCreateDlg proc       
lea ebx,_DlgProcShowValue
invoke DialogBoxParam,_hDllInstance,_DLG_CLIENT_SHOWVALUE,0,ebx,0               ;为什么不用得到模块句柄，而要用链接库句柄？？？？？
leave
retn 0
_ThreadCreateDlg endp







_DlgProcShowValue proc,hWnd,uMsg,wParam,lParam
local @dwValue
local @szBuf[200h]:byte

push ebx
push esi
push edi
mov eax,uMsg
        .if eax==WM_INITDIALOG
        push hWnd
        pop _hDlgShowValue  
        .elseif eax==WM_CLOSE
        mov _hDlgShowValue,0
        invoke EndDialog,hWnd,0
        .else
        mov eax,TRUE
        pop edi
        pop esi
        pop ebx
        leave
        mov eax,FALSE
        retn 16
        .endif
mov eax,TRUE
pop edi
pop esi
pop ebx
leave
retn 16
_DlgProcShowValue endp





_ProcService proc
local @hScmManager
local @hService
local @stServiceTableEntry:SERVICE_TABLE_ENTRY

push ebx
push esi
push edi
invoke OpenSCManager,0,0,SC_MANAGER_ALL_ACCESS
        .if eax==0
        invoke MessageBox,0,offset szOpenScmError,0,MB_OK
        .endif
mov @hScmManager,eax

invoke OpenService,@hScmManager,offset szServiceName,SERVICE_QUERY_CONFIG
        .if eax==0
        invoke CreateService,@hScmManager,offset szServiceName,offset szServiceName,SERVICE_ALL_ACCESS,SERVICE_WIN32_OWN_PROCESS,\
        SERVICE_AUTO_START,SERVICE_ERROR_NORMAL,addr szModuleFileName,0,0,0,0,0
                .if eax==0
                invoke MessageBox,0,offset szOpenServiceError,0,MB_OK
                .else
                mov @hService,eax
                .endif
        .else
        mov @hService,eax
        .endif
invoke CloseServiceHandle,@hScmManager

lea esi,@stServiceTableEntry
lea ebx,szServiceName
mov dword ptr [esi],ebx
lea edi,_ProcServiceMain
mov dword ptr [esi+4],edi
invoke StartServiceCtrlDispatcher,addr @stServiceTableEntry
                .if eax==0
                invoke MessageBox,0,offset szDispatcherServiceError,0,MB_OK
                .endif           
pop edi
pop esi
pop ebx
leave
retn 0
_ProcService endp





_ProcServiceMain proc
local @stServiceStatus:SERVICE_STATUS
local @hServiceStatus:SERVICE_STATUS_HANDLE

push ebx
push esi
push edi
invoke RtlZeroMemory,addr @stServiceStatus,sizeof SERVICE_STATUS
mov @stServiceStatus.dwServiceType,SERVICE_WIN32_OWN_PROCESS
mov @stServiceStatus.dwCurrentState,SERVICE_START_PENDING
mov @stServiceStatus.dwControlsAccepted,SERVICE_ACCEPT_STOP
mov @stServiceStatus.dwWin32ExitCode,0
mov @stServiceStatus.dwServiceSpecificExitCode,0
mov @stServiceStatus.dwCheckPoint,0
mov @stServiceStatus.dwWaitHint,0
invoke SetServiceStatus,@hServiceStatus,addr @stServiceStatus

lea ebx,_ProcServiceHandler
invoke RegisterServiceCtrlHandler,addr szServiceName,ebx
                .if eax==0
                invoke MessageBox,0,offset szRegistryServiceError,0,MB_OK
                .endif
mov @hServiceStatus,eax

mov @stServiceStatus.dwWin32ExitCode,S_OK
mov @stServiceStatus.dwCheckPoint,0
mov @stServiceStatus.dwWaitHint,0
mov @stServiceStatus.dwCurrentState,SERVICE_RUNNING
invoke SetServiceStatus,@hServiceStatus,addr @stServiceStatus

mov ecx,100
ToSleep:
push ecx
invoke Sleep,1000
pop ecx
loop ToSleep

mov @stServiceStatus.dwCurrentState,SERVICE_STOPPED
invoke SetServiceStatus,@hServiceStatus,addr @stServiceStatus
    
pop edi
pop esi
pop ebx
leave
retn 0
_ProcServiceMain endp





_ProcServiceHandler proc,dwOpCode
push ebx
push esi
push edi

pop edi
pop esi
pop ebx
leave
retn 4
_ProcServiceHandler endp






_ProcRestart proc




_ProcRestart endp


end DllEntry