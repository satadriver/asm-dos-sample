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


#define	EIGHT_BIT_MODE	0//定义 93C46 读写模式

#if (EIGHT_BIT_MODE)
	#define	FLAG			0x0
	#define	VID				0x2
	#define	DID				0x4
	#define	NET_ADDR_ID		0xe
#else
	#define	FLAG			0x0
	#define	VID				0x1
	#define	DID				0x2
	#define	NET_ADDR_ID		0x7
#endif


USHORT
opEEPROM(
		PUCHAR		ioaddr,//93c46 port addr
		ULONG		locate, //寄存器位置
		OP_ENUM		op,	//操作类型
		USHORT		data//读删操作时忽略
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

	DbgPrint("retval=%x\n", retval);
	return retval;
}//finish


//读网卡地址
USHORT	addr[3];

for(i = 0; i < 3; i ++)
	addr[i] = opEEPROM(
					ioaddr,//93c46 port addr
					NET_ADDR_ID + i, //寄存器位置
					OP_READ,	//操作类型
					0//读删操作时忽略
					);
