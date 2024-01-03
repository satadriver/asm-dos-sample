#define	NDIS_WDM 1

#define NDIS_MINIPORT_DRIVER
#define NDIS50_MINIPORT   1 

#include "ndis.h"  // AFTER preceding directives

#include "driver.h"
#include "8139.h"
 

PDEVICE_OBJECT      g_deviceObject;
PADAPTER			g_adapter;

NTSTATUS
DriverEntry(
    IN PDRIVER_OBJECT  DriverObject,
    IN PUNICODE_STRING  RegistryPath
    )
{
	NDIS_STATUS		Status = NDIS_STATUS_SUCCESS; 
	NDIS_HANDLE		NdisWrapperHandle;
	NDIS_MINIPORT_CHARACTERISTICS	R8139Char;

    UNICODE_STRING                  ntDeviceName;
    UNICODE_STRING                  win32DeviceName;


    RtlInitUnicodeString(&ntDeviceName, L"\\Device\\miniport-rtl");
    Status = IoCreateDevice (
							 DriverObject,
                             0,
                             &ntDeviceName,
                             FILE_DEVICE_UNKNOWN,
                             0,
                             FALSE,
                             &g_deviceObject
							 );

    
	if(Status != NDIS_STATUS_SUCCESS)
		DbgPrint("DriverEntry:IoCreateDevice failure. \n");
	else{
		RtlInitUnicodeString(&win32DeviceName, L"\\DosDevices\\miniport-rtl");
		Status = IoCreateSymbolicLink( &win32DeviceName, &ntDeviceName );
		if(Status != NDIS_STATUS_SUCCESS){
			IoDeleteDevice(g_deviceObject);
			DbgPrint("DriverEntry:IoCreateSymbolicLink failure. \n");
		}else
			DbgPrint("DriverEntry:IoCreateDevice success. \n");
	}

//	g_deviceObject->Flags |= DO_DIRECT_IO;

	//init wrapper
	NdisMInitializeWrapper(
		&NdisWrapperHandle,
		DriverObject,
		RegistryPath,
		NULL
		);
	//clear zero
	NdisZeroMemory(&R8139Char, sizeof(NDIS_MINIPORT_CHARACTERISTICS));
 
	R8139Char.MajorNdisVersion	= 5;
	R8139Char.MinorNdisVersion	= 0;
	R8139Char.InitializeHandler = RInit;
	R8139Char.HaltHandler		= RHalt;
	R8139Char.QueryInformationHandler	= RQuery;
	R8139Char.SetInformationHandler	= RSet;
	R8139Char.ResetHandler		= RReset;
	R8139Char.ReturnPacketHandler	= RReturnPkt;
	R8139Char.SendPacketsHandler	= RSendPkts;
	R8139Char.ISRHandler			= RIsr;
	R8139Char.HandleInterruptHandler= RIsrDpc;
	R8139Char.CheckForHangHandler= RCheck;
//	R8139Char.DisableInterruptHandler = RDisint;

	//register miniport
	Status = NdisMRegisterMiniport(
				NdisWrapperHandle,
				&R8139Char,
				sizeof(NDIS_MINIPORT_CHARACTERISTICS)
				);

	if(Status != NDIS_STATUS_SUCCESS)
		NdisTerminateWrapper(NdisWrapperHandle, NULL);


    DriverObject->MajorFunction[IRP_MJ_CREATE] = ROpen;
    DriverObject->MajorFunction[IRP_MJ_CLOSE]  = RClose;
	DriverObject->MajorFunction[IRP_MJ_READ]   = RRead;
	DriverObject->MajorFunction[IRP_MJ_WRITE]  = RWrite;
	DriverObject->MajorFunction[IRP_MJ_CLEANUP]  = RCleanup;
    DriverObject->MajorFunction[IRP_MJ_DEVICE_CONTROL]  = RIoControl;
	DriverObject->DriverUnload = RUnload;

	return Status;
}


NDIS_STATUS 
RInit(
    OUT PNDIS_STATUS  OpenErrorStatus,
    OUT PUINT  SelectedMediumIndex,
    IN PNDIS_MEDIUM  MediumArray,
    IN UINT  MediumArraySize,
    IN NDIS_HANDLE  MiniportAdapterHandle,
    IN NDIS_HANDLE  WrapperConfigurationContext
    )
{
	NDIS_STATUS		Status = NDIS_STATUS_SUCCESS;
	UINT			i;
	ULONG			ulReadSize;
	ULONG			ulVenDevID;

	PNDIS_RESOURCE_LIST	resList;
	CM_PARTIAL_RESOURCE_DESCRIPTOR	resDesc;

	PADAPTER			adapter;
	NDIS_HANDLE  ConfigurationHandle;

	USHORT	TmpCommand;
	
	KdPrint(("go into RInit \n"));

    for (i = 0; i < MediumArraySize; i++){
        if (MediumArray[i] == NdisMedium802_3) 
			break;
    }
    if (i == MediumArraySize){
        KdPrint(("802.3 Media type not found.\n"));
        return NDIS_STATUS_UNSUPPORTED_MEDIA;
    }
    // Select ethernet
    *SelectedMediumIndex = i;

	//alloc adapter context mem
	Status = NdisAllocateMemoryWithTag(
				&adapter,
				sizeof(ADAPTER),
				'9318'
				);
	if(Status != NDIS_STATUS_SUCCESS) goto err;
	NdisZeroMemory(adapter, sizeof(ADAPTER));
	g_adapter = adapter;
	adapter->MiniportAdapterHandle = MiniportAdapterHandle;
	adapter->WrapperConfigurationContext = WrapperConfigurationContext;


	//find resourcs
	ulReadSize = NdisReadPciSlotInformation(
						MiniportAdapterHandle,
						0,
						0,
						&ulVenDevID,
						4
						);
	if(ulVenDevID != 0x813910ec){
		DbgPrint("no find our nic card. \n");
		Status = NDIS_STATUS_FAILURE; 
		goto err;
	}
	
	//我们的设备,获得资源
	Status = NdisMPciAssignResources(
						MiniportAdapterHandle,
						i,
						&resList
						);
	if(Status != NDIS_STATUS_SUCCESS) goto err;
		
	for(i = 0; i < resList->Count; i ++){
		resDesc = resList->PartialDescriptors[i];
		switch(resDesc.Type){
		// I/O 端口
		case CmResourceTypePort:
			adapter->BaseIO = (ULONG)resDesc.u.Port.Start.LowPart;
			ASSERT(0x100 == resDesc.u.Port.Length);
			break;
		// IRQ
		case CmResourceTypeInterrupt:
			adapter->IRQLevel = resDesc.u.Interrupt.Level;
			adapter->IRQVector = resDesc.u.Interrupt.Vector;
			adapter->IRQAffinity = resDesc.u.Interrupt.Affinity;
			//share
			adapter->IRQMode = resDesc.Flags & (CM_RESOURCE_INTERRUPT_LEVEL_SENSITIVE | CM_RESOURCE_INTERRUPT_LATCHED);
			break;
		// MEMERY
		case CmResourceTypeMemory:
			ASSERT(0x100 == resDesc.u.Memory.Length);
			break;
		// DMA
		case CmResourceTypeDma:
			break;
		default:
			break;
		}
	}//for

	//regist to NDIS library
	NdisMSetAttributes(
				MiniportAdapterHandle,
				adapter,
				TRUE,//DMABusMaster,
				NdisInterfacePci
				);


	//enable dma
	NdisReadPciSlotInformation(
		adapter->MiniportAdapterHandle,
		0,
		PCI_COMMAND,
		&TmpCommand,
		2
		);

	TmpCommand |= PCI_COMMAND_IO | PCI_COMMAND_MEMORY | PCI_COMMAND_MASTER;

	NdisWritePciSlotInformation(
		adapter->MiniportAdapterHandle,
		0,
		PCI_COMMAND,
		&TmpCommand,
		2
		);
 
	//Registering Ports
	Status = NdisMRegisterIoPortRange(
							(PVOID*)&adapter->ioaddr,
							adapter->MiniportAdapterHandle,
							adapter->BaseIO,
							0x100
							);

	if(NDIS_STATUS_SUCCESS != Status) goto err;

	//interrupt
	Status = NdisMRegisterInterrupt(
						&adapter->IntObj,
						adapter->MiniportAdapterHandle,
						adapter->IRQVector,
						adapter->IRQLevel,
						TRUE,
						TRUE,
						adapter->IRQMode
						);
	if(NDIS_STATUS_SUCCESS != Status) goto err;

	//dma
	Status = NdisMAllocateMapRegisters(
						adapter->MiniportAdapterHandle,
						0,//must 0
						CM_RESOURCE_DMA_32,
						1,
						256//dma transtrate max = 2k
						);
	if(NDIS_STATUS_SUCCESS != Status) goto err;

	//RESET 
	ResetNIC(adapter);

	((USHORT*)adapter->NetworkAddress)[0] = opEEPROM((PUCHAR)(adapter->ioaddr+Cfg9346), 7, OP_READ, 0);
	((USHORT*)adapter->NetworkAddress)[1] = opEEPROM((PUCHAR)(adapter->ioaddr+Cfg9346), 8, OP_READ, 0);
	((USHORT*)adapter->NetworkAddress)[2] = opEEPROM((PUCHAR)(adapter->ioaddr+Cfg9346), 9, OP_READ, 0);
	DbgPrint("NodeAddress = %x-%x-%x-%x-%x-%x \n", 
				adapter->NetworkAddress[0],adapter->NetworkAddress[1],adapter->NetworkAddress[2],adapter->NetworkAddress[3],adapter->NetworkAddress[4],adapter->NetworkAddress[5]
				);


	Status = AllocRes(adapter);
	if(NDIS_STATUS_SUCCESS != Status) goto err;

	Status = StartDevice(adapter);
	if(NDIS_STATUS_SUCCESS != Status) goto err;

	KdPrint(("claim system resource succeesfully. \n"));

	
	return Status;

err:
	KdPrint(("claim system resource failure. \n"));

	FreeRes(adapter);
	return Status;
}



//IRQL:DISPATCH_LEVEL
NDIS_STATUS 
RSet(
    IN NDIS_HANDLE  Context,
    IN NDIS_OID  Oid,
    IN PVOID  inbuf,
    IN ULONG  buf_size,
    OUT PULONG  BytesRead,
    OUT PULONG  BytesNeeded
    )
{
    NDIS_STATUS     Status = NDIS_STATUS_SUCCESS;
	UINT		i;
    PADAPTER   adapter = (PADAPTER)Context;


	switch(Oid){
	case OID_802_3_MULTICAST_LIST:
	//	DbgPrint("OID_802_3_MULTICAST_LIST. \n");
        if ( buf_size > 8)
            return (NDIS_STATUS_INVALID_LENGTH);
		else
			NdisMoveMemory(adapter->mc_filter, inbuf, buf_size);
		break;

    case OID_GEN_CURRENT_PACKET_FILTER:
	//	DbgPrint("OID_GEN_CURRENT_PACKET_FILTER. \n");
        // Verify the Length
        if (buf_size != 4)
            return (NDIS_STATUS_INVALID_LENGTH);
        adapter->PacketFilter = *(PULONG)inbuf;
        *BytesRead = buf_size;
        break;
    case OID_GEN_CURRENT_LOOKAHEAD:
        if (buf_size != 4)
            return (NDIS_STATUS_INVALID_LENGTH);
        *BytesRead = 4;
        break;
    default:
        Status = NDIS_STATUS_INVALID_OID;
        break;
	}

	return Status;
}



NDIS_STATUS 
RQuery(
    IN NDIS_HANDLE  Context,
    IN NDIS_OID  Oid,
    IN PVOID  inbuf,
    IN ULONG  buf_size,
    OUT PULONG  BytesWritten,
    OUT PULONG  BytesNeeded
    )
{
    NDIS_STATUS     Status = NDIS_STATUS_SUCCESS;
	UINT		i;
    PADAPTER   adapter = (PADAPTER)Context;


static NDIS_OID        OID_LIST[] =
    {
		//	Required OIDs
		OID_GEN_SUPPORTED_LIST,//					0x00010101
		OID_GEN_HARDWARE_STATUS,//					0x00010102
		OID_GEN_MEDIA_SUPPORTED,//					0x00010103
		OID_GEN_MEDIA_IN_USE,//						0x00010104
		OID_GEN_MAXIMUM_LOOKAHEAD,//				0x00010105
		OID_GEN_MAXIMUM_FRAME_SIZE,//				0x00010106
		OID_GEN_LINK_SPEED,//						0x00010107
		OID_GEN_TRANSMIT_BUFFER_SPACE,//			0x00010108
		OID_GEN_RECEIVE_BUFFER_SPACE,//				0x00010109
		OID_GEN_TRANSMIT_BLOCK_SIZE,//				0x0001010A
		OID_GEN_RECEIVE_BLOCK_SIZE,//				0x0001010B
		OID_GEN_VENDOR_ID,//						0x0001010C
		OID_GEN_VENDOR_DESCRIPTION,//				0x0001010D
		OID_GEN_CURRENT_PACKET_FILTER,//			0x0001010E
		OID_GEN_CURRENT_LOOKAHEAD,//				0x0001010F
		OID_GEN_DRIVER_VERSION,//					0x00010110
		OID_GEN_MAXIMUM_TOTAL_SIZE,//				0x00010111
		OID_GEN_PROTOCOL_OPTIONS,//					0x00010112
		OID_GEN_MAC_OPTIONS,//						0x00010113
		OID_GEN_MEDIA_CONNECT_STATUS,//				0x00010114
		OID_GEN_MAXIMUM_SEND_PACKETS,//				0x00010115
		OID_GEN_VENDOR_DRIVER_VERSION,//			0x00010116
		OID_GEN_SUPPORTED_GUIDS,//					0x00010117
		OID_GEN_NETWORK_LAYER_ADDRESSES,//			0x00010118	// Set only
		OID_GEN_TRANSPORT_HEADER_OFFSET,//			0x00010119  // Set only

		// 802.3 Objects (Ethernet)
		OID_802_3_PERMANENT_ADDRESS,//				0x01010101
		OID_802_3_CURRENT_ADDRESS,//				0x01010102
		OID_802_3_MULTICAST_LIST,//					0x01010103
		OID_802_3_MAXIMUM_LIST_SIZE,//				0x01010104
		OID_802_3_MAC_OPTIONS,//					0x01010105

		NDIS_802_3_MAC_OPTION_PRIORITY,//			0x00000001

		OID_802_3_RCV_ERROR_ALIGNMENT,//			0x01020101
		OID_802_3_XMIT_ONE_COLLISION,//				0x01020102
		OID_802_3_XMIT_MORE_COLLISIONS,//			0x01020103

		OID_802_3_XMIT_DEFERRED,//					0x01020201
		OID_802_3_XMIT_MAX_COLLISIONS,//			0x01020202
		OID_802_3_RCV_OVERRUN,//					0x01020203
		OID_802_3_XMIT_UNDERRUN,//					0x01020204
		OID_802_3_XMIT_HEARTBEAT_FAILURE,//			0x01020205
		OID_802_3_XMIT_TIMES_CRS_LOST,//			0x01020206
		OID_802_3_XMIT_LATE_COLLISIONS,//			0x01020207

		// 用户定义
		USER_OID_REV_BYTE,//						0x02000000
		USER_OID_XMIT_BYTE	,//						0x02000001
		//	Required statistics
		OID_GEN_XMIT_OK,//							0x00020101
		OID_GEN_RCV_OK,//							0x00020102
		OID_GEN_XMIT_ERROR,//						0x00020103
		OID_GEN_RCV_ERROR,//						0x00020104
		OID_GEN_RCV_NO_BUFFER,//					0x00020105

    };


	*BytesWritten = 4;

    switch (Oid){
	case USER_OID_REV_BYTE:
        *((PULONG)inbuf) =  adapter->rev_byte; 
		break;
	
	case USER_OID_XMIT_BYTE:
        *((PULONG)inbuf) =  adapter->xmit_byte; 
		break;

	case OID_GEN_SUPPORTED_LIST:
		if(buf_size < sizeof(OID_LIST)){
			*BytesNeeded = sizeof(OID_LIST);
			Status = NDIS_STATUS_INVALID_LENGTH;
		}else{
			NdisMoveMemory(inbuf, OID_LIST, sizeof(OID_LIST));
			*BytesWritten = sizeof(OID_LIST);
		}
        break;
	case OID_GEN_CURRENT_PACKET_FILTER:
		if(buf_size >= 4){
			*(PULONG)inbuf = adapter->PacketFilter;
			*BytesWritten = 4;
		}else
			*BytesNeeded = 4;
		break;
	case OID_GEN_MAC_OPTIONS:
        *((PULONG)inbuf) = (ULONG)(NDIS_MAC_OPTION_TRANSFERS_NOT_PEND |
            NDIS_MAC_OPTION_COPY_LOOKAHEAD_DATA  |
            NDIS_MAC_OPTION_NO_LOOPBACK
            );
        break;
    case OID_GEN_HARDWARE_STATUS:
		*((NDIS_HARDWARE_STATUS*)inbuf) = NdisHardwareStatusReady;
        break;
    case OID_GEN_MEDIA_SUPPORTED:
    case OID_GEN_MEDIA_IN_USE:
		*((NDIS_MEDIUM*)inbuf) = (NDIS_MEDIUM)(NdisMedium802_3);
        break;
    case OID_GEN_MAXIMUM_LOOKAHEAD:
    case OID_GEN_CURRENT_LOOKAHEAD:
    case OID_GEN_MAXIMUM_FRAME_SIZE:
        *((PULONG)inbuf) = MAX_ETHERNET_FRAME_SIZE - MAC_HEADER_SIZE;
        break;
    case OID_GEN_MAXIMUM_TOTAL_SIZE:
    case OID_GEN_TRANSMIT_BLOCK_SIZE:
    case OID_GEN_RECEIVE_BLOCK_SIZE:
        *((PULONG)inbuf) = (ULONG)MAX_ETHERNET_FRAME_SIZE;
        break;
    case OID_GEN_LINK_SPEED:
        *((PULONG)inbuf) =  1000000; //100m
        break;
    case OID_GEN_TRANSMIT_BUFFER_SPACE:
		DbgPrint("data=%x, len=%x\n", inbuf, buf_size);
        *((PULONG)inbuf) = (ULONG) MAX_ETHERNET_FRAME_SIZE * 4;
        break;
    case OID_GEN_RECEIVE_BUFFER_SPACE:
        *((PULONG)inbuf) = (ULONG)RING_BUF_SIZE;
        break;
    case OID_GEN_VENDOR_ID:
        *((PULONG)inbuf) = *(PULONG)adapter->NetworkAddress;
        break;
    case OID_GEN_VENDOR_DESCRIPTION:
        *((PULONG)inbuf) = (ULONG)'0900';
        break;
    case OID_GEN_DRIVER_VERSION:
        *((PULONG)inbuf) = (USHORT)0x0201;
        break;
    case OID_GEN_MAXIMUM_SEND_PACKETS:
        *((PULONG)inbuf) = (ULONG) NUM_OF_DESC;
        break;
    case OID_GEN_MEDIA_CONNECT_STATUS:
        *((PULONG)inbuf) = (ULONG)NdisMediaStateConnected;
        break;
		//
		// 802.3 Objects (Ethernet)
		//
	case OID_802_3_PERMANENT_ADDRESS://				0x01010101
        NdisMoveMemory(inbuf, adapter->NetworkAddress, 6);
		*BytesWritten = 6;
        break;
	case OID_802_3_CURRENT_ADDRESS://				0x01010102
        NdisMoveMemory(inbuf, adapter->NetworkAddress, 6);
		*BytesWritten = 6;
        break;
	case OID_802_3_MULTICAST_LIST://					0x01010103
        if (buf_size < 8)
            return (NDIS_STATUS_INVALID_LENGTH);
		else
			NdisMoveMemory(inbuf, adapter->mc_filter, buf_size);
        break;
	case OID_802_3_MAXIMUM_LIST_SIZE://				0x01010104
        *((PULONG)inbuf) = (ULONG)MULTICAST_FILTER_LIMIT;
        break;
	case OID_802_3_MAC_OPTIONS://					0x01010105
		Status = NDIS_STATUS_NOT_SUPPORTED;
        break;
	case NDIS_802_3_MAC_OPTION_PRIORITY://			0x00000001
		Status = NDIS_STATUS_NOT_SUPPORTED;
        break;

	case OID_802_3_RCV_ERROR_ALIGNMENT://			0x01020101
        *((PULONG)inbuf) = (ULONG)0;
        break;
	case OID_802_3_XMIT_ONE_COLLISION://				0x01020102
        *((PULONG)inbuf) = (ULONG)0;
        break;
	case OID_802_3_XMIT_MORE_COLLISIONS://			0x01020103
        *((PULONG)inbuf) = (ULONG)0;
        break;

	case OID_802_3_XMIT_DEFERRED://					0x01020201
        *((PULONG)inbuf) = (ULONG)0;
        break;
	case OID_802_3_XMIT_MAX_COLLISIONS://			0x01020202
        *((PULONG)inbuf) = (ULONG)0;
        break;
	case OID_802_3_RCV_OVERRUN://					0x01020203
        *((PULONG)inbuf) = (ULONG)0;
        break;
	case OID_802_3_XMIT_UNDERRUN://					0x01020204
        *((PULONG)inbuf) = (ULONG)0;
        break;
	case OID_802_3_XMIT_HEARTBEAT_FAILURE://			0x01020205
        *((PULONG)inbuf) = (ULONG)0;
        break;
	case OID_802_3_XMIT_TIMES_CRS_LOST://			0x01020206
        *((PULONG)inbuf) = (ULONG)0;
        break;
	case OID_802_3_XMIT_LATE_COLLISIONS://			0x01020207
        *((PULONG)inbuf) = (ULONG)0;
        break;

		//
		//	Required statistics
		//
	case OID_GEN_XMIT_OK://							0x00020101
		*((PULONG)inbuf) = adapter->XMIT_OK;
        break;

	case OID_GEN_RCV_OK://							0x00020102
		*((PULONG)inbuf) = adapter->RCV_OK;
        break;

	case OID_GEN_XMIT_ERROR://						0x00020103
		*((PULONG)inbuf) = adapter->XMIT_ERR;
        break;

	case OID_GEN_RCV_ERROR://						0x00020104
		*((PULONG)inbuf) = adapter->RCV_ERR;
        break;

	case OID_GEN_RCV_NO_BUFFER://					0x00020105
		*((PULONG)inbuf) = adapter->RCV_NO_BUFFER;
        break;

    default:
		break;
    }

    return (Status);
}


//IRQL:DISPATCH_LEVEL
VOID
RReturnPkt(
    IN NDIS_HANDLE  MiniportAdapterContext,
    IN PNDIS_PACKET  Packet
    )
{
	PADAPTER	adapter = (PADAPTER)MiniportAdapterContext;

	//GetBackPkt(adapter, Packet);
}


//IRQL:DISPATCH_LEVEL
//#pragma LOCK_CODE
VOID
RSendPkts(
    IN NDIS_HANDLE  MiniportAdapterContext,
    IN PPNDIS_PACKET  PacketArray,
    IN UINT  NumberofPackets
    )
/*++
	Sending Packets on a Busmaster DMA NIC
--*/
{
	PADAPTER	adapter = (PADAPTER)MiniportAdapterContext;
	UINT		i;
	
//	DbgPrint("RSendPkts:NumberofPackets=%x \n", NumberofPackets);

	for(i = 0; i < NumberofPackets; i ++){
		SendPkt(
			adapter, 
			PacketArray[i]
			);
	}//for

}

//IRQL:DISPATCH_LEVEL
//USED BY RSendPkts
//#pragma LOCK_CODE
BOOLEAN
SendPkt(
	IN PADAPTER		 adapter,
    IN PNDIS_PACKET  Packet
	)
/*++
	发送一个包
--*/
{
	static UINT		pkt_len;
	PUCHAR		vaddr;
	ULONG		paddr;


	if(adapter->FreeTxDesc > 0){//有空闲的描述寄存器
		adapter->FreeTxDesc --;
		vaddr = adapter->tx_bufs + (adapter->cur_tx * TX_BUF_SIZE);
		paddr = NdisGetPhysicalAddressLow(adapter->tx_bufs_dma) + (adapter->cur_tx * TX_BUF_SIZE);
	
		//1.COPY 包内容
		pkt_len = CopyPktToBuf(
							Packet,
							vaddr
							);
		adapter->xmit_byte += pkt_len;

		//dma oparater
		NDIS_SET_PACKET_STATUS(Packet, NDIS_STATUS_SUCCESS);
		IssueCMD(adapter, adapter->cur_tx, paddr, pkt_len);
	
		adapter->cur_tx = NextTxDesc(adapter->cur_tx);

		return TRUE;
	}//has free tsd

	DbgPrint("SendPkt failure. no free txdesc. pkt_len=%x,cur_tx=%x \n", pkt_len, adapter->cur_tx);
	//由 NDIS 排队包
	NDIS_SET_PACKET_STATUS(Packet, NDIS_STATUS_RESOURCES);

	return FALSE;
}


//IRQL:DISPATCH_LEVEL
//USED BY SendPkt
VOID
IssueCMD(
	PADAPTER	adapter,
	UINT		cur_tx,
	ULONG		paddr,
	UINT		len
	)
{
	ULONG offset = cur_tx << 2;
	ULONG	tmpTSD;
	UCHAR	tmpCMD;

	NdisRawReadPortUchar(adapter->ioaddr + ChipCmd, &tmpCMD);
	ASSERT(tmpCMD & CmdTxEnb);

	if(len < MIN_ETHERNET_FRAME_SIZE)	
		len = MIN_ETHERNET_FRAME_SIZE;


	NdisRawWritePortUlong(
		adapter->ioaddr + TxAddr0 + offset,
		paddr
		);

	NdisRawWritePortUlong(
		adapter->ioaddr + TxStatus0 + offset,
		len | (2 << 16)//64
		);
}


//IRQL:DISPATCH_LEVEL
//USED BY SendPkt
//#pragma LOCK_CODE
ULONG
CopyPktToBuf(
			PNDIS_PACKET packet,
			PUCHAR buff
			)
{

	PUCHAR			WritePtr = buff;
	UINT			BufferCount;
	PNDIS_BUFFER	srcBuff, NextBuff;
	UINT			PacketLength, BufferLength;
	UINT				i;
	PUCHAR			Address;

	NdisQueryPacket(
		packet,
		NULL,
		&BufferCount,
		&srcBuff,
		&PacketLength
		);

	ASSERT(PacketLength <= TX_BUF_SIZE); //每个发送包长

	for(i = 0; i < BufferCount; i ++){
		NdisQueryBuffer(
			srcBuff,
			&Address,
			&BufferLength
			);
		NdisMoveMemory(
				WritePtr,
				Address,
				BufferLength
				);

		WritePtr += BufferLength;

		NdisGetNextBuffer(
			srcBuff,
			&NextBuff
			);

		srcBuff = NextBuff;
	}//for

	return PacketLength;
}



typedef struct tagISR_STATUS{
	USHORT	ROK:1;
	USHORT	RER:1;
	USHORT	TOK:1;
	USHORT	TER:1;
	USHORT	RXOVW:1;
	USHORT	LINKCHG:1;
	USHORT	RXFIFOOVW:1;
	USHORT	REV:6;
	USHORT	LENCHG:1;
	USHORT	TIMEOUT:1;
	USHORT	SERR:1;
}ISR_STATUS, *PISR_STATUS;

//IRQL:DIRQL
//USED BY NDIS
//#pragma LOCK_CODE
VOID
RIsr(
    OUT PBOOLEAN  InterruptRecognized,
    OUT PBOOLEAN  QueueMiniportHandleInterrupt,
    IN NDIS_HANDLE  MiniportAdapterContext
    )
{
	PADAPTER	adapter = (PADAPTER)MiniportAdapterContext;
	USHORT		curISR, Tmp;
	UCHAR		cmd;

	//read isr status
	NdisRawReadPortUshort(adapter->ioaddr + IntrStatus, &curISR);
	NdisRawWritePortUshort(adapter->ioaddr + IntrStatus, curISR);
	DbgPrint("RIsr:IntrStatus=%x,FreeTxDesc=%x \n", curISR, adapter->FreeTxDesc);


	if(curISR & R39_INTERRUPT_MASK){

		NdisRawWritePortUshort(adapter->ioaddr + IntrMask, 0);
		adapter->curISR = curISR & R39_INTERRUPT_MASK;
		
		//is our interrupt
		*InterruptRecognized = TRUE;
		*QueueMiniportHandleInterrupt = TRUE;

	}else{
		//is not our interrupt
		*InterruptRecognized = FALSE;
		*QueueMiniportHandleInterrupt = FALSE;
	}
}

//IRQL:DISPATCH_LEVEL
//USED BY NDIS
//#pragma LOCK_CODE
VOID 
RIsrDpc(
    IN NDIS_HANDLE  MiniportAdapterContext
    )
{
	PADAPTER	adapter = (PADAPTER)MiniportAdapterContext;
	UCHAR		TmpTCR;
	ULONG		Tmplong;
	USHORT		cur_rx;
	USHORT		link_changed;

	USHORT		write_ptr;


    if(adapter->curISR & RxUnderrun){
		DbgPrint("RIsrDpc:RxUnderrun(link chg) \n");
	}

	//TX
    if((adapter->curISR & TxOK)||(adapter->curISR & TxErr)){
		TxInt(adapter);
	}

	//RX
	if(adapter->curISR & RxOK){
		RxInt(adapter);
	}

    if( adapter->curISR & (RxErr|RxOverflow|RxFIFOOver)){
		//chip write ptr
		NdisRawReadPortUshort(adapter->ioaddr + RxBufAddr, &write_ptr);

		DbgPrint("RIsrDpc:RxErr|RxOverflow|RxFIFOOver, write_ptr=%x,read_ptr=%x \n", write_ptr, adapter->read_ptr);
		//更新 RxBufPtr(读寄存器) -> RxReadOffset
		adapter->read_ptr = write_ptr % RING_BUF_SIZE;
		NdisRawWritePortUshort(adapter->ioaddr + RxBufPtr, adapter->read_ptr - 16);
		NdisRawWritePortUshort(adapter->ioaddr + IntrStatus, RxOK);
	}

	//enable interrupt
	NdisRawWritePortUshort(adapter->ioaddr + IntrMask, R39_INTERRUPT_MASK);
}


//IRQL:PASSIVE_LEVEL 
//USED BY RInit
//#pragma PAGE_CODE
VOID
FreeRes(
			PADAPTER	adapter
			)
{
	int		i;


	
	//free i/o
	if(adapter->ioaddr != 0){
		NdisMDeregisterIoPortRange(
			adapter->MiniportAdapterHandle,
			adapter->BaseIO,
			0x100,
			(PVOID)&adapter->ioaddr
			);
	}

	//free dma
	if(adapter){
		NdisMFreeMapRegisters(adapter->MiniportAdapterHandle);
	}
	//free interrupt
	if(adapter->IRQVector > 0){
		NdisMDeregisterInterrupt(adapter->MiniportAdapterHandle);
	}

	//free tx_bufs
	if(adapter->tx_bufs != NULL)
			NdisMFreeSharedMemory(
				adapter->MiniportAdapterHandle,
				TX_BUF_SIZE * NUM_OF_DESC,
				FALSE,//not cached
				adapter->tx_bufs,
				adapter->tx_bufs_dma
				);

	//free tx_bufs
	if(adapter->rx_bufs != NULL)
			NdisMFreeSharedMemory(
				adapter->MiniportAdapterHandle,
				RX_BUF_SIZE * NUM_OF_PACKETS,
				FALSE,//not cached
				adapter->rx_bufs,
				adapter->rx_bufs_dma
				);

	//free rx_ring
	if(adapter->rx_ring != NULL)
			NdisMFreeSharedMemory(
				adapter->MiniportAdapterHandle,
				RING_BUF_SIZE + RING_BUF_PAD,
				FALSE,//not cached
				adapter->rx_ring,
				adapter->rx_ring_dma
				);


	if(adapter->buf_pool != NULL)
		NdisFreeBufferPool(adapter->buf_pool);


	if(adapter->pkt_pool != NULL)
		NdisFreeBufferPool(adapter->pkt_pool);

	//free adapter mem
	NdisFreeMemory(
		(PVOID)adapter,
		sizeof(ADAPTER),
		0
		);

}

VOID
OpenPOWNER(
		PADAPTER	adapter
		)
{
	UCHAR	TmpUCHAR;

	NdisRawReadPortUchar(adapter->ioaddr + Config1, &TmpUCHAR);
	if(LWAKE & TmpUCHAR){
		DbgPrint("oh, no powner. \n");
		TmpUCHAR &= ~LWAKE;
		TmpUCHAR |= Cfg1_PM_Enable;

		//unlock
		NdisRawWritePortUchar(adapter->ioaddr + Cfg9346, Cfg9346_Unlock);

		NdisRawWritePortUchar(adapter->ioaddr + Config1, TmpUCHAR);

		NdisRawReadPortUchar(adapter->ioaddr + Config4, &TmpUCHAR);
		TmpUCHAR &= ~LWPTN;
		NdisRawWritePortUchar(adapter->ioaddr + Config4, TmpUCHAR);

		//lock
		NdisRawWritePortUchar(adapter->ioaddr + Cfg9346, Cfg9346_Lock);
	}
}

VOID
ResetNIC(
		PADAPTER	adapter
		)
{
	UCHAR	TmpCM;

	//reset device
	NdisRawWritePortUchar(adapter->ioaddr + ChipCmd, CmdReset|1);

	//test rest success ?
	do{
		NdisRawReadPortUchar(adapter->ioaddr + ChipCmd, &TmpCM);
	}while(TmpCM & CmdReset);

	DbgPrint("Reset operate complete. ChipCmd=%x \n", TmpCM);

	//enable io,mem
	NdisRawReadPortUchar(adapter->ioaddr + Config1, &TmpCM);
	ASSERT(TmpCM & Cfg1_PIO);
	ASSERT(TmpCM & Cfg1_MMIO);
}

//IRQL:PASSIVE_LEVEL 
//USED BY RInit
//#pragma PAGE_CODE
NDIS_STATUS
StartDevice(
		PADAPTER	adapter
		)
{
	UCHAR	TmpCM;
	ULONG	Tmplong;
	UINT	i;
	USHORT	TmpShort;
	
	
//	SetMII(adapter);

	//enable dma Tx/Rx
	NdisRawWritePortUchar(adapter->ioaddr + ChipCmd, CmdRxEnb | CmdTxEnb);

	//config rx
	NdisRawWritePortUlong(adapter->ioaddr + RxConfig, rtl8139_rx_config);
	//config tx
	NdisRawWritePortUlong(adapter->ioaddr + TxConfig, RL_TXCFG_CONFIG);

	/* init Rx ring buffer DMA address */
	NdisRawWritePortUlong(adapter->ioaddr + RxBuf, NdisGetPhysicalAddressLow(adapter->rx_ring_dma));

	//clear 0
	NdisRawWritePortUlong(adapter->ioaddr + RxMissed, 0);


	//all mult
    adapter->PacketFilter = NDIS_PACKET_TYPE_DIRECTED | NDIS_PACKET_TYPE_MULTICAST;
	NdisRawWritePortUlong(adapter->ioaddr + MAR0, 0x80004000);
	NdisRawWritePortUlong(adapter->ioaddr + MAR0 + 4, 0);
	((PULONG)adapter->mc_filter)[0] = 0x80004000;
	((PULONG)adapter->mc_filter)[1] = 0;

	//enable dma Tx/Rx
	NdisRawWritePortUchar(adapter->ioaddr + ChipCmd, CmdRxEnb | CmdTxEnb);

	//enable int
	NdisRawWritePortUshort(adapter->ioaddr + IntrMask, R39_INTERRUPT_MASK);
	
	return NDIS_STATUS_SUCCESS;
}

//IRQL:PASSIVE_LEVEL 
//USED BY RInit
//#pragma PAGE_CODE
NDIS_STATUS
AllocRes(
		PADAPTER	adapter
		)
{
	PUCHAR		Addr;
	UINT		bufsize;

	NDIS_STATUS	Status;
	UINT		i;
	PVOID		VirtualAddress;
	NDIS_PHYSICAL_ADDRESS	PhysicalAddress;
	ULONG		phy;

	//rx_ring
	NdisMAllocateSharedMemory(
			adapter->MiniportAdapterHandle,
			RING_BUF_SIZE + RING_BUF_PAD,
			FALSE,//not cached
			&adapter->rx_ring, //虚拟地址
			&PhysicalAddress //物理地址
			);
	if(adapter->rx_ring == NULL)
		return STATUS_INSUFFICIENT_RESOURCES;
	adapter->rx_ring_dma = PhysicalAddress;
	//align to 32?
	DbgPrint("rx_ring=%x, rx_ring_dma=%x \n",adapter->rx_ring,NdisGetPhysicalAddressLow(PhysicalAddress));

	//tx_bufs
	NdisMAllocateSharedMemory(
			adapter->MiniportAdapterHandle,
			TX_BUF_SIZE * NUM_OF_DESC,
			FALSE,//not cached
			&adapter->tx_bufs, //虚拟地址
			&PhysicalAddress //物理地址
			);
	if(adapter->tx_bufs == NULL)
		return STATUS_INSUFFICIENT_RESOURCES;
	adapter->tx_bufs_dma = PhysicalAddress;
	//align to 32
	DbgPrint("tx_bufs=%x, tx_bufs_dma=%x \n",adapter->tx_bufs,NdisGetPhysicalAddressLow(PhysicalAddress));

	//rx_bufs
	NdisMAllocateSharedMemory(
			adapter->MiniportAdapterHandle,
			RX_BUF_SIZE * NUM_OF_PACKETS,
			FALSE,//not cached
			&adapter->rx_bufs, //虚拟地址
			&PhysicalAddress //物理地址
			);
	if(adapter->rx_bufs == NULL)
		return STATUS_INSUFFICIENT_RESOURCES;
	adapter->rx_bufs_dma = PhysicalAddress;
	//align to 32
	DbgPrint("rx_bufs=%x, rx_bufs_dma=%x \n",adapter->rx_bufs,NdisGetPhysicalAddressLow(PhysicalAddress));

	//分配 Packet pool,Buffer pool to rx
	NdisAllocatePacketPool(
		&Status,
		&adapter->pkt_pool,
		NUM_OF_PACKETS,	
		16
		);
	if(Status != NDIS_STATUS_SUCCESS)
		return STATUS_INSUFFICIENT_RESOURCES;
	DbgPrint("pkt_pool = %x \n", adapter->pkt_pool);

	NdisAllocateBufferPool(
		&Status,
		&adapter->buf_pool,
		NUM_OF_PACKETS	
		); 
	if(Status != NDIS_STATUS_SUCCESS)
		return STATUS_INSUFFICIENT_RESOURCES;
	DbgPrint("buf_pool = %x \n", adapter->buf_pool);


	for(i = 0; i < NUM_OF_PACKETS; i ++){
		NdisAllocatePacket(
			&Status,
			&adapter->pkt_desc[i],
			adapter->pkt_pool
			);
		if(Status != NDIS_STATUS_SUCCESS)
			return STATUS_INSUFFICIENT_RESOURCES;

		NdisAllocateBuffer(
			&Status,
			&adapter->buf_desc[i],
			adapter->buf_pool,
			adapter->rx_bufs + (i * RX_BUF_SIZE),
			RX_BUF_SIZE
			);
		//connection buf_desc->pkt_desc
		NdisChainBufferAtBack(
			adapter->pkt_desc[i],
			adapter->buf_desc[i]
			);
	}

	adapter->read_ptr = 0;

	adapter->FreeRxPkt = NUM_OF_PACKETS;
	adapter->cur_rx = 0;
	adapter->dirty_rx = 0;

	adapter->FreeTxDesc = NUM_OF_DESC;
	adapter->cur_tx = 0;
	adapter->dirty_tx = 0;

	return NDIS_STATUS_SUCCESS;
}


//IRQL:DISPATCH_LEVEL
//USED BY RIsrDpc
VOID
TxInt(
	PADAPTER adapter
	)
/*++
	发送中断处理
--*/
{
	UINT	i = 0;
    ULONG       Offset;
    ULONG       tmpTSD;


//	DbgPrint("TxInt:adapter->dirty_tx=%x \n", adapter->dirty_tx);
	while((i < 4)&&(adapter->FreeTxDesc < 4)){
		Offset = (i) << 2;
	    NdisRawReadPortUlong(adapter->ioaddr + TxStatus0 + Offset, &tmpTSD);

		if(tmpTSD & (TxStatOK | TxUnderrun | TxAborted)){
			//err
			if(tmpTSD & (TxUnderrun | TxAborted)){
				adapter->XMIT_ERR ++;
			}else{
				adapter->XMIT_OK ++;
			}

			adapter->FreeTxDesc ++;
		//	adapter->dirty_tx = NextTxDesc(adapter->dirty_tx);
			NdisMSendResourcesAvailable(adapter->MiniportAdapterHandle);
			i ++;
		}
	}//while
}

//IRQL:DISPATCH_LEVEL
//USED BY RIsrDpc
VOID
RxInt(
	PADAPTER adapter
	)
/*++
	接收中断处理
--*/
{
	UCHAR			TmpCMD;
	UINT			NumOfPkt = 0;
	PNDIS_PACKET	RevPacket[NUM_OF_PACKETS];

	UINT			i;
	NDIS_STATUS		Status;

	PUCHAR			buf;
	PNDIS_BUFFER	buf_desc;
	UINT			buf_len;

	do{
		//读命令寄存器 ChipCmd 
		NdisRawReadPortUchar(adapter->ioaddr + ChipCmd, &TmpCMD);
		if((TmpCMD & (UCHAR)RxBufEmpty)){
			adapter->RCV_NO_BUFFER ++;
			break;//缓冲区为空
		}
		//有接收包
		RevPacket[NumOfPkt] = RevOnePacket(adapter);
		if(RevPacket[NumOfPkt])	NumOfPkt ++;
		else break;

	}while(TRUE);

	if(NumOfPkt > 0){
	//	DbgPrint("RxInt:NumOfPkt=%x, RCV_OK=%x \n", NumOfPkt, adapter->RCV_OK);
		NdisMIndicateReceivePacket(
				adapter->MiniportAdapterHandle,
				RevPacket,
				NumOfPkt
				);

		adapter->FreeRxPkt += NumOfPkt;
	}//if
}

//IRQL:DISPATCH_LEVEL
//USED RxInt
//#pragma LOCK_CODE
PNDIS_PACKET
RevOnePacket(
		PADAPTER adapter
		)
{
	PUCHAR		ReadPtr;
	USHORT		write_ptr;
	PPACKETHEADER	head;

	NDIS_STATUS	Status;

	USHORT		pkt_size;
	USHORT		max_byte;

	PUCHAR			buf;
	PNDIS_PACKET	pkt_desc;
	PNDIS_BUFFER	buf_desc;

	INT		i;

	ReadPtr = adapter->rx_ring + adapter->read_ptr; 

	//chip write ptr
	NdisRawReadPortUshort(adapter->ioaddr + RxBufAddr, &write_ptr);
	write_ptr = write_ptr % RING_BUF_SIZE;
	if(write_ptr > adapter->read_ptr)
		max_byte = write_ptr - adapter->read_ptr;
	else
		max_byte = write_ptr + RING_BUF_SIZE - adapter->read_ptr;


	head = (PPACKETHEADER)ReadPtr;
	if(PacketOK(head)){
		if(adapter->FreeRxPkt <= 0) goto RES_BAD; //没有空 rx_pkt
		pkt_size = *((PUSHORT)(ReadPtr + 2)) - 4;

		if(head->PAM) {
			adapter->RCV_OK ++;
			adapter->rev_byte += pkt_size;
		}
/*		DbgPrint("write_ptr=%x,read_ptr=%x,ReadPtr=%x, max_byte=%x\n", write_ptr,adapter->read_ptr,ReadPtr,max_byte);
		if(head->MAR) 
			DbgPrint("RevOnePacket:multicase pkt. ");
		else if(head->PAM){ 
			adapter->RCV_OK ++;
			DbgPrint("RevOnePacket:phy dest pkt.");
		}else if(head->BAR)
			DbgPrint("RevOnePacket:broadcast pkt.");

		for(i = 0; i < 12; i ++)
			DbgPrint("%02x-", *(ReadPtr + 4 + i));
		DbgPrint(", cur_rx=%x", adapter->cur_rx);
		DbgPrint("\n");
*/
		if(pkt_size + 8 > max_byte){
			DbgPrint("pkt_size + 8 > max_byte(%x) \n", max_byte);
			return NULL;
		}
		adapter->FreeRxPkt --;	//可用包个数 - 1
		pkt_desc = adapter->pkt_desc[adapter->cur_rx];
		//内存接收包
		NdisMoveMemory(
			adapter->rx_bufs + (adapter->cur_rx * RX_BUF_SIZE),
			ReadPtr + 4,
			pkt_size
			);

		NdisAdjustBufferLength(
			adapter->buf_desc[adapter->cur_rx],
			pkt_size
			);

		adapter->cur_rx = NextRxDesc(adapter->cur_rx);

		NDIS_SET_PACKET_STATUS(pkt_desc, NDIS_STATUS_RESOURCES);
	}else{//PACKETOK
		//err
		DbgPrint("RevOnePacket:rev packet error. \n");
		RxErrHandle(adapter);
		return NULL;
	}

	//下移读位置
	adapter->read_ptr = (adapter->read_ptr + pkt_size + 8 + 3) & (~3); //对齐 32
	adapter->read_ptr %= RING_BUF_SIZE;

	//更新 RxBufPtr(读寄存器) -> RxReadOffset
	NdisRawWritePortUshort(adapter->ioaddr + RxBufPtr, adapter->read_ptr - 16);

	return pkt_desc;

RES_BAD:
	DbgPrint("resources not enought for rev pkt. \n");
	return NULL;
}

VOID
RxErrHandle(
		PADAPTER adapter
		)
{
	UCHAR		TmpCM;
	ULONG		TmpLong;

		NdisRawReadPortUlong(adapter->ioaddr + RxMissed, &TmpLong);
		adapter->ERR_COUNT += TmpLong;
		NdisRawWritePortUlong(adapter->ioaddr + RxMissed, 0);
		adapter->RCV_ERR ++;

		//更新 RxBufPtr(读寄存器) -> RxReadOffset
		NdisRawWritePortUshort(adapter->ioaddr + RxBufPtr, adapter->read_ptr - 16);
}

//IRQL:DISPATCH_LEVEL
//USED RxInt
//#pragma LOCK_CODE
BOOLEAN
PacketOK(
	PPACKETHEADER p
	)
{
    BOOLEAN BadPacket = p->RUNT ||p->LONG ||p->CRC  ||p->FAE;

    if(BadPacket
		||(p->PacketLength > MAX_ETHERNET_FRAME_SIZE)
		||(p->PacketLength < MIN_ETHERNET_FRAME_SIZE)){
	    return FALSE;
    }else{
		return TRUE;
    }
}



#define		BMCR_RST		0x8000	//bit15
#define		BMCR_SPEED		0x2000	//bit13
#define		BMCR_AUTONEG	0x1000	//bit12
#define		BMCR_RSTAUTO	0x200	//bit9
#define		BMCR_DUPLEX		0x100	//bit8

#define		BMSR_AUTOCOMP	0x20	//bit5

VOID
SetMII(
		PADAPTER	adapter
		)
{
	USHORT	TmpShort;
	USHORT	media, ad, lp;

	//reset
	NdisRawWritePortUshort(adapter->ioaddr + BasicModeCtrl, BMCR_RST);
	do{
		NdisRawReadPortUshort(adapter->ioaddr + BasicModeCtrl, &TmpShort);
	}while(TmpShort & BMCR_RST);
	DbgPrint("MII reset complete. \n");

	NdisRawReadPortUshort(adapter->ioaddr + BasicModeCtrl, &TmpShort);
	TmpShort |= BMCR_AUTONEG | BMCR_RSTAUTO;
	NdisRawWritePortUshort(adapter->ioaddr + BasicModeCtrl, TmpShort);

	//set duplx
	do{
		NdisRawReadPortUshort(adapter->ioaddr + BasicModeStatus, &TmpShort);
	}while(!(TmpShort & BMSR_AUTOCOMP));
	DbgPrint("MII AUTONEG complete. \n");

  //link ok
	NdisRawReadPortUshort(adapter->ioaddr + BasicModeStatus, &TmpShort);
	if(! (TmpShort & PHY_BMSR_LINKSTAT)){
		DbgPrint("link error.\n");
		return;
	}
	DbgPrint("link ok.\n");

	//
	NdisRawReadPortUshort(adapter->ioaddr + BasicModeCtrl, &media);
	NdisRawReadPortUshort(adapter->ioaddr + NWayAdvert, &ad);
	NdisRawReadPortUshort(adapter->ioaddr + NWayLPAR, &lp);

		if (ad & PHY_ANAR_100BT4 && lp & PHY_ANAR_100BT4) {
			media |= PHY_BMCR_SPEEDSEL;
			media &= ~PHY_BMCR_DUPLEX;
			DbgPrint("(100baseT4)\n");
		} else if (ad & PHY_ANAR_100BTXFULL &&
			lp & PHY_ANAR_100BTXFULL) {
			media |= PHY_BMCR_SPEEDSEL;
			media |= PHY_BMCR_DUPLEX;
			DbgPrint("(full-duplex, 100Mbps)\n");
		} else if (ad & PHY_ANAR_100BTXHALF &&
			lp & PHY_ANAR_100BTXHALF) {
			media |= PHY_BMCR_SPEEDSEL;
			media &= ~PHY_BMCR_DUPLEX;
			DbgPrint("(half-duplex, 100Mbps)\n");
		} else if (ad & PHY_ANAR_10BTFULL &&
			lp & PHY_ANAR_10BTFULL) {
			media &= ~PHY_BMCR_SPEEDSEL;
			media |= PHY_BMCR_DUPLEX;
			DbgPrint("(full-duplex, 10Mbps)\n");
		} else {
			media &= ~PHY_BMCR_SPEEDSEL;
			media &= ~PHY_BMCR_DUPLEX;
			DbgPrint("(half-duplex, 10Mbps)\n");
		}

	NdisRawWritePortUshort(adapter->ioaddr + BasicModeCtrl, media);
}

BOOLEAN
RCheck(
    IN NDIS_HANDLE  MiniportAdapterContext
)
{
//    PADAPTER   adapter = (PADAPTER)MiniportAdapterContext;
//		DbgPrint("RCheck. \n");

/*	if(adapter->FreeTxDesc == 0){//	return TRUE;
		adapter->FreeTxDesc = 4;
		adapter->cur_tx = 0;
	}
*/
	return FALSE;
}


#define	EIGHT_BIT_MODE	0//定义 93C46 读写模式


USHORT
opEEPROM(
		PUCHAR		ioaddr,//93c46 port addr
		ULONG		locate, //寄存器位置
		OP_ENUM		op,	//操作类型
		USHORT		data
		)
{
	int			i, addrlen;
	UCHAR		TmpVal;
	USHORT		retval = 0;

	switch(op){
	case OP_WRITE:	

#if (EIGHT_BIT_MODE)	//8BIT MODE
		locate = (op << 15) | (locate << 8) | ((UCHAR)data);
		addrlen = 18;
#else	//16BIT MODE
		locate = (op << 22) | (locate << 16) | data;
		addrlen = 25;
#endif

		break;
	case OP_READ:
	case OP_ERASE:

#if (EIGHT_BIT_MODE)	//8BIT MODE
		locate = (op << 7) | locate;
		addrlen = 10;
#else	//16BIT MODE
		locate = (op << 6) | locate;
		addrlen = 9;
#endif
		
		break;
	default: 
		return 0;
	}


	NdisRawWritePortUchar(ioaddr, EE_ENB & ~EE_CS); //进入编程状态
	NdisRawWritePortUchar(ioaddr, EE_ENB); //select chip

	for(i = addrlen; i >= 0; i --){//串行写入
		TmpVal = (locate & (1 << i)) ? EE_DI : 0;
		NdisRawWritePortUchar(ioaddr, EE_ENB | TmpVal);
		NdisRawWritePortUchar(ioaddr, EE_ENB | TmpVal | EE_CLK); //raise clk
	}

	NdisRawWritePortUchar(ioaddr, EE_ENB); //low clk

	//read result
	for(i = 0; i < 16; i ++){
		NdisRawWritePortUchar(ioaddr, EE_ENB | EE_CLK); //raise clk
		NdisRawReadPortUchar(ioaddr, &TmpVal);
		TmpVal &= EE_DO;
		retval = (retval << 1) | TmpVal;
		NdisRawWritePortUchar(ioaddr, EE_ENB); //low clk
	}
	NdisRawWritePortUchar(ioaddr, ~EE_CS);

	return retval;
}//finish

//IRQL:DISPATCH_LEVEL
NDIS_STATUS 
RReset(
    OUT PBOOLEAN  AddressingReset,
    IN NDIS_HANDLE  MiniportAdapterContext
    )
{
	NDIS_STATUS		Status = NDIS_STATUS_SUCCESS;
	PADAPTER		adapter = (PADAPTER)MiniportAdapterContext;

	DbgPrint("RReset \n");

	while(adapter->FreeRxPkt != NUM_OF_PACKETS) 
		DbgPrint("RReset: FreeRxPkt=%x \n", adapter->FreeRxPkt);
		
	while(adapter->FreeTxDesc != NUM_OF_DESC) 
		DbgPrint("RReset: FreeTxDesc=%x \n", adapter->FreeTxDesc);
		
	NdisRawWritePortUshort(adapter->ioaddr + IntrMask, 0);
	NdisRawWritePortUchar(adapter->ioaddr + ChipCmd, 0);
   
	ResetNIC(adapter);
	StartDevice(adapter);

	adapter->read_ptr = 0;

	adapter->FreeRxPkt = NUM_OF_PACKETS;
	adapter->cur_rx = 0;
	adapter->dirty_rx = 0;

	adapter->FreeTxDesc = NUM_OF_DESC;
	adapter->cur_tx = 0;
	adapter->dirty_tx = 0;

	return Status;
}

VOID 
RHalt(
    IN NDIS_HANDLE  MiniportAdapterContext
    )
{
    PADAPTER   adapter = (PADAPTER)MiniportAdapterContext;

	DbgPrint("RHalt \n");

	while(adapter->FreeRxPkt != NUM_OF_PACKETS) 
		DbgPrint("RHalt: FreeRxPkt=%x \n", adapter->FreeRxPkt);
		
	while(adapter->FreeTxDesc != NUM_OF_DESC) 
		DbgPrint("RHalt: FreeTxDesc=%x \n", adapter->FreeTxDesc);
		
	NdisRawWritePortUshort(adapter->ioaddr + IntrMask, 0);
	NdisRawWritePortUchar(adapter->ioaddr + ChipCmd, 0);

   
	FreeRes((PADAPTER)MiniportAdapterContext);
}

      
