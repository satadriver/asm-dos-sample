#include "stdio.h"
#include "dos.h"
#include "alloc.h"
unsigned char *buffer,*buffer1;
unsigned long offset,offset1,delta,segment,physical;
main()
{
	buffer=(unsigned char*)malloc(1600/sizeof(int));
	offset=FP_OFF(buffer);
	if(offset&0x3)
	{
		delta=4-(offset&0x3);
		offset1=offset+delta;
		buffer1=buffer+delta;
	}
	segment=FP_SEG(buffer1);
	physical=(segment<<4)+offset1;

	printf("%x\n",buffer);
	printf("%x\n",offset);
	printf("%x\n",delta);
	printf("%x\n",offset1);
	printf("%x\n",buffer1);
	printf("%x\n",segment);
	printf("%x\n",physical);
}