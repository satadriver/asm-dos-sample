DISP MACRO VAR					;宏定义
        MOV AH,09H				;将形参中所存的以结尾的字符串显示在屏幕上
        MOV DX,OFFSET VAR
        INT 21H
ENDM
SCANKEY MACRO					;宏定义
        LOCAL LLL				;为标号LLL建立唯一的从??0001H到??FFFFH的符号
LLL:    MOV AH,01H				;等待是否有键按下
        INT 16H
        JZ LLL					;无则继续等待
        MOV AH,0				;否则读出键值
        INT 16H
ENDM
DATA SEGMENT
TEXT DB  'THE QUICK BROWN FOX JUMPS OVER LAZY DOG'
     DB  0DH,0AH
     DB  'THE QUICK BROWN FOX JUMPS OVER LAZY DOG'
     DB  0DH,0AH
     DB  'THE QUICK BROWN FOX JUMPS OVER LAZY DOG'
     DB  0DH,0AH,'$'
COUNT EQU $-TEXT								;TEXT的总长度
BUF DB COUNT DUP(?)
MESG DB  'TO MAKE A DMA REQUEST!'
     DB  'THEN STRIKE ANY KEY!',0DH,0AH,'$'
DATA ENDS
STACK SEGMENT STACK 'STACK'
        DB 256 DUP(?)
STACK ENDS
CODE SEGMENT 
    ASSUME CS:CODE,DS:DATA,SS:STACK
BEG:    MOV AX,DATA								;主程序部分
        MOV DS,AX								;装入数据段
        CALL I8237R								;DMA通道1读出初始化
        DISP MESG								;显示操作提示
        SCANKEY									;等待直到有键按下,读出键值
LAST1:  IN AL,08H								;读DMA状态寄存器
        AND AL,02H								;传送是否结束
        JZ LAST1								;否则继续等待传送结束
        CALL I8237W								;DMA通道1写入初始化
        DISP MESG								;显示操作提示
        SCANKEY									;等待直到有键按下,读出键值
LAST2:  IN AL,08H								;读DMA状态寄存器
        AND AL,02H								;传送是否结束
        JZ LAST2								;否则继续等待传送结束
        DISP BUF								;显示BUF中DMA读写传送的最后结果
        MOV AH,4CH
        INT 21H									;结束程序并返回DOS
I8237R PROC										;DMA通道1读出初始化
        MOV AL,05H
        OUT 0AH,AL								;通道1屏蔽触发器置1
        MOV AL,01001001B						;通道1方式字,单字节写传送
        OUT 0BH,AL								;自动加1变址,不自动预置
        MOV AL,0
        OUT 0CH,AL								;先/后触发器置0
        MOV AX,DATA								;AX为TEXT的段基址
        MOV BX,OFFSET TEXT						;BX为TEXT的有效地址
        CALL ADDRMOV							;计算输出TEXT单元的20位物理地址
        RET
I8237R ENDP
I8237W PROC 						;DMA通道1写入初始化
        MOV AL,05H
        OUT 0AH,AL					;通道1屏蔽触发器置1
        MOV AL,01000101B			;通道1方式字,单字节写传送
        OUT 0BH,AL					;自动加1变址,不自动预置
        MOV AL,0
        OUT 0CH,AL					;先/后触发器置0
        MOV AX,DATA					;AX为BUF的段基址
        MOV BX,OFFSET BUF			;BX为BUF的有效地址
        CALL ADDRMOV				;计算并输出BUF单元的20位物理地址
        RET
I8237W ENDP
ADDRMOV PROC						;计算并输出某地址
        MOV CX,0004H				;计算用AX:BX表示的物理地址
LL:     SAL AX,1
        RCL CH,1					;将移位时的溢出计入CH
        DEC CL
        JNZ LL
        ADD AX,BX					;AX<=AX*4+BX
        JNC NEXT11
        INC CH
NEXT11: OUT 02H,AL					;低8位存入通道1基本地址寄存器
        MOV AL,AH
        OUT 02H,AL					;中8位存入通道1基本地址寄存器
        MOV AL,CH
        OUT 83H,AL					;高4位存入通道1页面寄存器
        MOV AX,COUNT-1				;要传送的字节数减1传给基本字节寄存器
        OUT 03H,AL
        MOV AL,AH
        OUT 03H,AL
        MOV AL,01
        OUT 0AH,AL					;解除通道1屏蔽
        RET
ADDRMOV ENDP
CODE ENDS
END BEG	
