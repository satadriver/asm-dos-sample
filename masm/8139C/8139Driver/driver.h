
#define		NUM_OF_DESC		4 

//ethernet
#define		MAX_ETHERNET_FRAME_SIZE	1518
#define		MIN_ETHERNET_FRAME_SIZE	64
#define		MAC_HEADER_SIZE			14

//Tx
#define		TX_BUF_SIZE		1536 //每个发送包长 1518 ->0x600 32bit align
#define		RX_BUF_SIZE		TX_BUF_SIZE

//Rx
#define		RING_BUF_SIZE	0x4000	//接收缓冲区 16 k
#define		RING_BUF_PAD	TX_BUF_SIZE

//
#define		NUM_OF_PACKETS	0x40	//每次接收包的个数

/* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
   The RTL chips use a 64 element hash table based on the Ethernet CRC.  */
#define		MULTICAST_FILTER_LIMIT		32

//包头
typedef struct tagPACKETHEADER{
	USHORT	ROK : 1;
	USHORT  FAE : 1;
	USHORT	CRC : 1;
	USHORT	LONG: 1;
	USHORT	RUNT: 1;
	USHORT	ISE : 1;
	USHORT	reserved : 7;
	USHORT	BAR : 1;
	USHORT	PAM : 1;
	USHORT	MAR : 1;
	USHORT   PacketLength;
}PACKETHEADER, *PPACKETHEADER;

//
typedef struct tagADAPTER{

	NDIS_HANDLE		MiniportAdapterHandle;
	NDIS_HANDLE		WrapperConfigurationContext;

	UCHAR		NetworkAddress[6];
	UCHAR		mc_filter[8];
	ULONG		PacketFilter;

	PUCHAR		ioaddr;
	//i/o
	ULONG		BaseIO;
	NDIS_MINIPORT_INTERRUPT	IntObj;

	//irq
	ULONG		IRQLevel;
	ULONG		IRQVector;
	ULONG		IRQAffinity;
	USHORT		IRQMode;

	PUCHAR		tx_bufs; // TX_BUF_SIZE * NUM_OF_DESC
	NDIS_PHYSICAL_ADDRESS		tx_bufs_dma;

	//2.接收:
	PUCHAR		rx_ring;
	NDIS_PHYSICAL_ADDRESS		rx_ring_dma;
	USHORT		read_ptr;

	PUCHAR		rx_bufs;
	NDIS_PHYSICAL_ADDRESS		rx_bufs_dma;

	//packet,buffer & pool
	NDIS_HANDLE		pkt_pool;
	NDIS_HANDLE		buf_pool;

	PNDIS_PACKET	pkt_desc[NUM_OF_PACKETS];
	PNDIS_BUFFER	buf_desc[NUM_OF_PACKETS];

	UINT			FreeRxPkt, FreeTxDesc;
	UINT			cur_rx, cur_tx, dirty_tx, dirty_rx;

	//isr status
	USHORT		curISR;

	//
	ULONG			ERR_COUNT;
	ULONG			XMIT_OK, XMIT_ERR;
	ULONG			RCV_OK, RCV_ERR;
	ULONG			RCV_NO_BUFFER;

	ULONG			rev_byte, xmit_byte;

	char twistie, twist_row, twist_col;	/* Twister tune state. */
}ADAPTER, *PADAPTER;




NDIS_STATUS 
RInit(
    OUT PNDIS_STATUS  OpenErrorStatus,
    OUT PUINT  SelectedMediumIndex,
    IN PNDIS_MEDIUM  MediumArray,
    IN UINT  MediumArraySize,
    IN NDIS_HANDLE  MiniportAdapterHandle,
    IN NDIS_HANDLE  WrapperConfigurationContext
    );

VOID 
RHalt(
    IN NDIS_HANDLE  MiniportAdapterContext
    );

RSet(
                   IN NDIS_HANDLE MiniportAdapterContext,
                   IN NDIS_OID Oid,
                   IN PVOID InformationBuffer,
                   IN ULONG InformationBufferLength,
                   OUT PULONG BytesRead,
                   OUT PULONG BytesNeeded
                   );

NDIS_STATUS 
RQuery(
    IN NDIS_HANDLE  MiniportAdapterContext,
    IN NDIS_OID  Oid,
    IN PVOID  InformationBuffer,
    IN ULONG  InformationBufferLength,
    OUT PULONG  BytesWritten,
    OUT PULONG  BytesNeeded
    );

NDIS_STATUS 
RReset(
    OUT PBOOLEAN  AddressingReset,
    IN NDIS_HANDLE  MiniportAdapterContext
    );

VOID
RReturnPkt(
    IN NDIS_HANDLE  MiniportAdapterContext,
    IN PNDIS_PACKET  Packet
    ); 

VOID
RSendPkts(
    IN NDIS_HANDLE  MiniportAdapterContext,
    IN PPNDIS_PACKET  PacketArray,
    IN UINT  NumberofPackets
    );

VOID
RIsr(
    OUT PBOOLEAN  InterruptRecognized,
    OUT PBOOLEAN  QueueMiniportHandleInterrupt,
    IN NDIS_HANDLE  MiniportAdapterContext
    );

VOID 
RIsrDpc(
    IN NDIS_HANDLE  MiniportAdapterContext
    );

VOID 
REnint(
    IN NDIS_HANDLE  MiniportAdapterContext
    );

VOID 
RDisint(
    IN NDIS_HANDLE  MiniportAdapterContext
    );

VOID
FreeRes(PADAPTER	adapter);

NDIS_STATUS
StartDevice(
		PADAPTER	adapter
		);

NDIS_STATUS
AllocRes(
		PADAPTER	adapter
		);

ULONG
CopyPktToBuf(
			PNDIS_PACKET packet,
			PUCHAR		 buffer
			);

VOID
IssueCMD(
	PADAPTER	adapter,
	UINT		cur_tx,
	ULONG		paddr,
	UINT		len
	);

BOOLEAN
SendPkt(
	IN PADAPTER		 adapter,
    IN PNDIS_PACKET  Packet
	);

VOID
TxInt(
			PADAPTER adapter
			);

VOID
RxInt(
			PADAPTER adapter
			);


BOOLEAN
PacketOK(
	PPACKETHEADER pPktHdr
	);


//
#define		INIT_CODE	//		code_seg("_ITEXT", "ICODE")
#define		PAGE_CODE	//		code_seg("_PTEXT", "PCODE")
#define		LOCK_CODE	//		code_seg("_LTEXT", "LCODE")




/*  EEPROM_Ctrl bits. */
#define EE_CS	0x08	/* EEPROM chip select. */
#define EE_CLK	0x04	/* EEPROM shift clock. */
#define EE_DI	0x02	/* EEPROM chip data in. */
#define EE_DO	0x01	/* EEPROM chip data out. */
#define EE_ENB	(0x80 | EE_CS)

#define EE_WRITE_CMD	5
#define EE_READ_CMD		6
#define EE_ERASE_CMD	7

typedef enum _OP_ENUM{
	OP_WRITE = EE_WRITE_CMD,
	OP_READ = EE_READ_CMD,
	OP_ERASE = EE_ERASE_CMD,
}OP_ENUM;


USHORT
opEEPROM(
		PUCHAR		ioaddr,//93c46 port addr
		ULONG		locate, //寄存器位置
		OP_ENUM		op,	//操作类型
		USHORT		data
		);

PNDIS_PACKET
RevOnePacket(
		PADAPTER adapter
		);


VOID
SetMII(
		PADAPTER	adapter
		);

VOID
ResetNIC(
		PADAPTER	adapter
		);
VOID
RxErrHandle(
		PADAPTER adapter
		);

#define	NextTxDesc(i)	(i) == (NUM_OF_DESC - 1) ? 0 : (i + 1)
#define	NextRxDesc(i)	(i) == (NUM_OF_PACKETS - 1) ? 0 : (i + 1)

#define R39_INTERRUPT_MASK \
	(PCIErr | PCSTimeout | RxUnderrun | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK)

BOOLEAN
RCheck(
    IN NDIS_HANDLE  MiniportAdapterContext
);


NTSTATUS
RIoControl(
    IN PDEVICE_OBJECT DeviceObject,
    IN PIRP Irp
    );

NTSTATUS
RClose(
    IN PDEVICE_OBJECT DeviceObject,
    IN PIRP Irp
    );

NTSTATUS
ROpen(
    IN PDEVICE_OBJECT DeviceObject,
    IN PIRP Irp
    );

VOID
RUnload(
    IN PDRIVER_OBJECT DriverObject
    );

NTSTATUS
RRead(
    IN PDEVICE_OBJECT DeviceObject,
    IN PIRP Irp
    );
NTSTATUS
RWrite(
    IN PDEVICE_OBJECT DeviceObject,
    IN PIRP Irp
    );

NTSTATUS
RCleanup(
    IN PDEVICE_OBJECT DeviceObject,
    IN PIRP Irp
    );



#define	USER_OID_REV_BYTE							0x02000000
#define	USER_OID_XMIT_BYTE							0x02000001

