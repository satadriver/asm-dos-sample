DISP MACRO VAR					;�궨��
        MOV AH,09H				;���β���������Խ�β���ַ�����ʾ����Ļ��
        MOV DX,OFFSET VAR
        INT 21H
ENDM
SCANKEY MACRO					;�궨��
        LOCAL LLL				;Ϊ���LLL����Ψһ�Ĵ�??0001H��??FFFFH�ķ���
LLL:    MOV AH,01H				;�ȴ��Ƿ��м�����
        INT 16H
        JZ LLL					;��������ȴ�
        MOV AH,0				;���������ֵ
        INT 16H
ENDM
DATA SEGMENT
TEXT DB  'THE QUICK BROWN FOX JUMPS OVER LAZY DOG'
     DB  0DH,0AH
     DB  'THE QUICK BROWN FOX JUMPS OVER LAZY DOG'
     DB  0DH,0AH
     DB  'THE QUICK BROWN FOX JUMPS OVER LAZY DOG'
     DB  0DH,0AH,'$'
COUNT EQU $-TEXT								;TEXT���ܳ���
BUF DB COUNT DUP(?)
MESG DB  'TO MAKE A DMA REQUEST!'
     DB  'THEN STRIKE ANY KEY!',0DH,0AH,'$'
DATA ENDS
STACK SEGMENT STACK 'STACK'
        DB 256 DUP(?)
STACK ENDS
CODE SEGMENT 
    ASSUME CS:CODE,DS:DATA,SS:STACK
BEG:    MOV AX,DATA								;�����򲿷�
        MOV DS,AX								;װ�����ݶ�
        CALL I8237R								;DMAͨ��1������ʼ��
        DISP MESG								;��ʾ������ʾ
        SCANKEY									;�ȴ�ֱ���м�����,������ֵ
LAST1:  IN AL,08H								;��DMA״̬�Ĵ���
        AND AL,02H								;�����Ƿ����
        JZ LAST1								;��������ȴ����ͽ���
        CALL I8237W								;DMAͨ��1д���ʼ��
        DISP MESG								;��ʾ������ʾ
        SCANKEY									;�ȴ�ֱ���м�����,������ֵ
LAST2:  IN AL,08H								;��DMA״̬�Ĵ���
        AND AL,02H								;�����Ƿ����
        JZ LAST2								;��������ȴ����ͽ���
        DISP BUF								;��ʾBUF��DMA��д���͵������
        MOV AH,4CH
        INT 21H									;�������򲢷���DOS
I8237R PROC										;DMAͨ��1������ʼ��
        MOV AL,05H
        OUT 0AH,AL								;ͨ��1���δ�������1
        MOV AL,01001001B						;ͨ��1��ʽ��,���ֽ�д����
        OUT 0BH,AL								;�Զ���1��ַ,���Զ�Ԥ��
        MOV AL,0
        OUT 0CH,AL								;��/�󴥷�����0
        MOV AX,DATA								;AXΪTEXT�Ķλ�ַ
        MOV BX,OFFSET TEXT						;BXΪTEXT����Ч��ַ
        CALL ADDRMOV							;�������TEXT��Ԫ��20λ�����ַ
        RET
I8237R ENDP
I8237W PROC 						;DMAͨ��1д���ʼ��
        MOV AL,05H
        OUT 0AH,AL					;ͨ��1���δ�������1
        MOV AL,01000101B			;ͨ��1��ʽ��,���ֽ�д����
        OUT 0BH,AL					;�Զ���1��ַ,���Զ�Ԥ��
        MOV AL,0
        OUT 0CH,AL					;��/�󴥷�����0
        MOV AX,DATA					;AXΪBUF�Ķλ�ַ
        MOV BX,OFFSET BUF			;BXΪBUF����Ч��ַ
        CALL ADDRMOV				;���㲢���BUF��Ԫ��20λ�����ַ
        RET
I8237W ENDP
ADDRMOV PROC						;���㲢���ĳ��ַ
        MOV CX,0004H				;������AX:BX��ʾ�������ַ
LL:     SAL AX,1
        RCL CH,1					;����λʱ���������CH
        DEC CL
        JNZ LL
        ADD AX,BX					;AX<=AX*4+BX
        JNC NEXT11
        INC CH
NEXT11: OUT 02H,AL					;��8λ����ͨ��1������ַ�Ĵ���
        MOV AL,AH
        OUT 02H,AL					;��8λ����ͨ��1������ַ�Ĵ���
        MOV AL,CH
        OUT 83H,AL					;��4λ����ͨ��1ҳ��Ĵ���
        MOV AX,COUNT-1				;Ҫ���͵��ֽ�����1���������ֽڼĴ���
        OUT 03H,AL
        MOV AL,AH
        OUT 03H,AL
        MOV AL,01
        OUT 0AH,AL					;���ͨ��1����
        RET
ADDRMOV ENDP
CODE ENDS
END BEG	
