  ; ===========================================
  ; rxapi.inc copyright MASM32 1998 - 2005
  ; ===========================================

IFNDEF RXAPI_INC
RXAPI_INC equ <1>

AppendServerList PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ConvertMaxUsesField PROTO :DWORD,:DWORD
GetAccessDescriptors PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetLanmanSessionKey PROTO :DWORD,:DWORD
GetModalsDescriptors PROTO :DWORD,:DWORD,:DWORD,:DWORD
GetShareInfoDescriptors PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
GetUserDescriptors PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
MIDL_user_allocate PROTO :DWORD
MIDL_user_free PROTO :DWORD
MIDL_user_size PROTO :DWORD
MapResourceName PROTO :DWORD,:DWORD
NetApiBufferAllocate PROTO :DWORD,:DWORD
NetApiBufferFree PROTO :DWORD
NetUseGetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD
NetWkstaGetInfo PROTO :DWORD,:DWORD,:DWORD
NetpAdjustPreferedMaximum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
NetpAssertFailed PROTO :DWORD,:DWORD,:DWORD,:DWORD
NetpBreakPoint PROTO 
NetpConvertServerInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
NetpConvertWkstaInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
NetpConvertWorkstationList PROTO :DWORD
NetpCopyStrArrayToTStrArray PROTO :DWORD,:DWORD
NetpCopyStrToWStr PROTO :DWORD,:DWORD
NetpCopyStringToBuffer PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
NetpCopyWStrToStrDBCS PROTO :DWORD,:DWORD
NetpDbgDisplayTimestamp PROTO :DWORD,:DWORD
NetpDbgDisplayTod PROTO :DWORD,:DWORD
NetpDbgHexDump PROTO :DWORD,:DWORD
NetpFileStructureInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
NetpIsPrintQueueNameValid PROTO :DWORD
NetpIsUncComputerNameValid PROTO :DWORD
NetpLocalTimeToGmtTime PROTO :DWORD,:DWORD
NetpLocalTimeZoneOffset PROTO 
NetpMemoryAllocate PROTO :DWORD
NetpMemoryFree PROTO :DWORD
NetpNtStatusToApiStatus PROTO :DWORD
NetpPrintQStructureInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
NetpRdrFsControlTree PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
NetpRotateLogonHours PROTO :DWORD,:DWORD,:DWORD
NetpServiceStructureInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
NetpSessionStructureInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
NetpStrArraySize PROTO :DWORD
NetpUnicodeToDBCSLen PROTO :DWORD
NetpWkstaStructureInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RapConvertSingleEntry PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RapStructureSize PROTO :DWORD,:DWORD,:DWORD
RapTotalSize PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxGetServerInfoLevelEquivalent PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetAccessAdd PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetAccessDel PROTO :DWORD,:DWORD
RxNetAccessEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetAccessGetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetAccessGetUserPerms PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetAccessSetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetAuditClear PROTO :DWORD,:DWORD,:DWORD
RxNetAuditRead PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetCharDevControl PROTO :DWORD,:DWORD,:DWORD
RxNetCharDevEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetCharDevGetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetConfigGet PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetConfigGetAll PROTO :DWORD,:DWORD,:DWORD
RxNetConfigSet PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetConnectionEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetErrorLogClear PROTO :DWORD,:DWORD,:DWORD
RxNetErrorLogRead PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetFileClose PROTO :DWORD,:DWORD
RxNetFileEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetFileGetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetGetDCName PROTO :DWORD,:DWORD,:DWORD
RxNetGroupAdd PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetGroupAddUser PROTO :DWORD,:DWORD,:DWORD
RxNetGroupDel PROTO :DWORD,:DWORD
RxNetGroupDelUser PROTO :DWORD,:DWORD,:DWORD
RxNetGroupEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetGroupGetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetGroupGetUsers PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetGroupSetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetGroupSetUsers PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetLogonEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetMessageBufferSend PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetMessageNameAdd PROTO :DWORD,:DWORD
RxNetMessageNameDel PROTO :DWORD,:DWORD
RxNetMessageNameEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetMessageNameGetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetRemoteTOD PROTO :DWORD,:DWORD
RxNetServerDiskEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetServerEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetServerEnumWorker PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetServerGetInfo PROTO :DWORD,:DWORD,:DWORD
RxNetServerSetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetServiceControl PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetServiceEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetServiceGetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetServiceInstall PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetSessionDel PROTO :DWORD,:DWORD,:DWORD
RxNetSessionEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetSessionGetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetShareAdd PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetShareCheck PROTO :DWORD,:DWORD,:DWORD
RxNetShareDel PROTO :DWORD,:DWORD,:DWORD
RxNetShareEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetShareGetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetShareSetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetStatisticsGet PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetUseAdd PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetUseDel PROTO :DWORD,:DWORD,:DWORD
RxNetUseEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetUseGetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetUserAdd PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetUserDel PROTO :DWORD,:DWORD
RxNetUserEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetUserGetGroups PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetUserGetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetUserModalsGet PROTO :DWORD,:DWORD,:DWORD
RxNetUserModalsSet PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetUserPasswordSet PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetUserSetGroups PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetUserSetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetWkstaGetInfo PROTO :DWORD,:DWORD,:DWORD
RxNetWkstaSetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetWkstaUserEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetpListCanonicalize PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetpNameCanonicalize PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetpNameCompare PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetpNameValidate PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxNetpPathCanonicalize PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetpPathCompare PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxNetpPathType PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxPrintDestAdd PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxPrintDestControl PROTO :DWORD,:DWORD,:DWORD
RxPrintDestDel PROTO :DWORD,:DWORD
RxPrintDestEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxPrintDestGetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxPrintDestSetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxPrintJobContinue PROTO :DWORD,:DWORD
RxPrintJobDel PROTO :DWORD,:DWORD
RxPrintJobEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxPrintJobGetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxPrintJobPause PROTO :DWORD,:DWORD
RxPrintJobSetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxPrintQAdd PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxPrintQContinue PROTO :DWORD,:DWORD
RxPrintQDel PROTO :DWORD,:DWORD
RxPrintQEnum PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxPrintQGetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxPrintQPause PROTO :DWORD,:DWORD
RxPrintQPurge PROTO :DWORD,:DWORD
RxPrintQSetInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxpConvertAuditArray PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxpConvertAuditEntryVariableData PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxpConvertErrorLogArray PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxpConvertSessionInfo PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxpCopyAndConvertSessions PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxpEstimateLogSize PROTO :DWORD,:DWORD,:DWORD,:DWORD
RxpGetConnectionDataDescs PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxpGetPrintDestInfoDescs PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxpGetPrintJobInfoDescs PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxpGetPrintQInfoDescs PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxpGetUseDataDescs PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxpGetWkstaInfoLevelEquivalent PROTO :DWORD,:DWORD,:DWORD
RxpSessionMatches PROTO :DWORD,:DWORD,:DWORD
RxpSetField PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
RxpWkstaGetOldInfo PROTO :DWORD,:DWORD,:DWORD
ServerRelocationRoutine PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SystemFunction006 PROTO :DWORD,:DWORD
SystemFunction012 PROTO :DWORD,:DWORD,:DWORD
SystemFunction016 PROTO :DWORD,:DWORD,:DWORD
_security_check_cookie PROTO :DWORD
get_group_descriptors PROTO :DWORD,:DWORD,:DWORD,:DWORD

ELSE
echo -----------------------------------------
echo WARNING Duplicate include file rxapi.inc
echo -----------------------------------------
ENDIF