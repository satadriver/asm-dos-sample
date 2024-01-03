#define	NDIS_WDM 1

#define NDIS_MINIPORT_DRIVER
#define NDIS50_MINIPORT   1 

#include "ndis.h"  // AFTER preceding directives
#include "driver.h"

typedef struct _PACKET_OID_DATA {
    ULONG           Oid;
    ULONG           Length;
    UCHAR           Data[1];
}PACKET_OID_DATA, *PPACKET_OID_DATA;

#define	IOCTL_PROTOCOL_QUERY_OID	0
#define	IOCTL_PROTOCOL_SET_OID		1


extern PADAPTER			g_adapter;
extern PDEVICE_OBJECT   g_deviceObject;


NTSTATUS
RIoControl(
    IN PDEVICE_OBJECT DeviceObject,
    IN PIRP Irp
    )
{
	NTSTATUS            status = STATUS_SUCCESS;

    PIO_STACK_LOCATION  irpSp;
    ULONG               functionCode;

	PPACKET_OID_DATA	OidData;
	ULONG				retByte, needByte;


    irpSp = IoGetCurrentIrpStackLocation(Irp);
    functionCode=irpSp->Parameters.DeviceIoControl.IoControlCode;
//    DbgPrint("RIoControl:functionCode=0x%08x \n", functionCode);
 
	//   IoMarkIrpPending(Irp);

    if(functionCode == IOCTL_PROTOCOL_SET_OID){
		OidData = Irp->AssociatedIrp.SystemBuffer;
		status = RSet(
					g_adapter,
					OidData->Oid,
					OidData->Data,
					OidData->Length,
					&retByte,
					&needByte
					);
		OidData->Length = retByte;
//		DbgPrint("RIoControl::OidData=%x,OidData->Oid=%x, OidData->Length=%x, OidData->Data=%x\n", OidData, OidData->Oid, OidData->Length,*((PULONG)OidData->Data));
	}else if(functionCode == IOCTL_PROTOCOL_QUERY_OID){
		OidData = Irp->AssociatedIrp.SystemBuffer;
		status = RQuery(
					g_adapter,
					OidData->Oid,
					OidData->Data,
					OidData->Length,
					&retByte,
					&needByte 
					);
         OidData->Length = retByte;
//		DbgPrint("RIoControl::OidData=%x,OidData->Oid=%x, OidData->Length=%x, OidData->Data=%x\n", OidData, OidData->Oid, OidData->Length,*((PULONG)OidData->Data));
	}else{
//		DbgPrint("RIoControl:unsuport oid request. \n");

        Irp->IoStatus.Status = STATUS_SUCCESS;
        IoCompleteRequest(Irp, IO_NO_INCREMENT);
  
		return STATUS_SUCCESS;
	}


	Irp->IoStatus.Information = irpSp->Parameters.DeviceIoControl.InputBufferLength;

//	status = STATUS_SUCCESS;
	Irp->IoStatus.Status = status;
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    
	return status;
}



NTSTATUS
ROpen(
    IN PDEVICE_OBJECT DeviceObject,
    IN PIRP Irp
    )
{
    NTSTATUS            status = STATUS_SUCCESS;

 //   DbgPrint("ROpen:\n");

	Irp->IoStatus.Status = status;
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    
    return status;
}



NTSTATUS
RClose(
    IN PDEVICE_OBJECT DeviceObject,
    IN PIRP Irp
    )
{
    NTSTATUS   status = STATUS_SUCCESS;

//    DbgPrint("RClose:\n");

	Irp->IoStatus.Status = status;
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    
    return status;
}

NTSTATUS
RIoComplete(
    IN PDEVICE_OBJECT DeviceObject,
    IN PIRP Irp,
    IN PVOID Context
    )
{

	return STATUS_SUCCESS;
}

NTSTATUS
RCleanup(
    IN PDEVICE_OBJECT DeviceObject,
    IN PIRP Irp
    )
{
    NTSTATUS            status = STATUS_SUCCESS;

 //   DbgPrint(("RCleanup\n"));

//    Irp->IoStatus.Information = 0;    
    Irp->IoStatus.Status = status;
    IoCompleteRequest (Irp, IO_NO_INCREMENT);

    return status;
}
NTSTATUS
RWrite(
    IN PDEVICE_OBJECT DeviceObject,
    IN PIRP Irp
    )
{
    NTSTATUS            status = STATUS_SUCCESS;

//    DbgPrint(("RCleanup\n"));

//    Irp->IoStatus.Information = 0;    
    Irp->IoStatus.Status = status;
    IoCompleteRequest (Irp, IO_NO_INCREMENT);

    return status;
}
NTSTATUS
RRead(
    IN PDEVICE_OBJECT DeviceObject,
    IN PIRP Irp
    )
{
    NTSTATUS            status = STATUS_SUCCESS;

//    DbgPrint(("RCleanup\n"));

//    Irp->IoStatus.Information = 0;    
    Irp->IoStatus.Status = status;
    IoCompleteRequest (Irp, IO_NO_INCREMENT);

    return status;
}

VOID
RUnload(
    IN PDRIVER_OBJECT DriverObject
    )
{
    NDIS_STATUS        status;
    UNICODE_STRING     win32DeviceName;

  //  DbgPrint(("Unload Enter\n"));

    RtlInitUnicodeString(&win32DeviceName, L"\\DosDevices\\miniport-rtl");
    IoDeleteSymbolicLink(&win32DeviceName);           
    if(g_deviceObject)
        IoDeleteDevice(g_deviceObject);
}


