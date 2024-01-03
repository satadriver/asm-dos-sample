DATA    SEGMENT
;����0-N����ģ
MAP1    DB 001H,080H,0E7H,081H,0C1H,06H,00H,0CH,082H,021H
    DB 0CDH,02EH

;���ڳ���֧�ֻ�N����ģ������Ķ�������ڻ�ͼ֮ǰ�ű���ֵ
WID    DW ?    ;ͼ�Ŀ��(����)
HEI    DW ?    ;ͼ�ĸ߶�
TMP1    DW ?    ;���������α�(����)
TMP2    DW ?    ;�����α�(����)
CNT    DB 0    ;�����α꣬��0-7
XORG    DW ?    ;����ͼ��ĳ�ʼX
YORG    DW ?    ;����ͼ��ĳ�ʼY

DATA    ENDS

CODE    SEGMENT
    ASSUME    DS:DATA,CS:CODE
MAIN:
    MOV    AX,DATA
    MOV    DS,AX
        
        
    ;*****����ͼ��ģʽ****    
    MOV    AH,0
    MOV    AL,12H    ;640*480
    INT    10H    ;�����ж�ʹ������Ч
    

    ;*****��ͼ****
    ;��ʼ����,������ģ��λ��
    
    LEA    SI,MAP1
    MOV    XORG,0
    MOV    YORG,0
    MOV    WID,640
    MOV    HEI,480
    CALL    DRAW

    ;*****�����˳�*****
    MOV    AH,0            
    INT    16H                
                            
    MOV    AX,0003H        ;��ԭ����ģʽ            
    INT    10H        ;�����ж�ʹ������Ч
    MOV    AH,4CH                
    INT    21H

DRAW    PROC NEAR
    MOV    CX,XORG
    MOV    DX,YORG
    PUSH    BX
    MOV    BX,WID
    MOV    TMP1,BX
    MOV    BX,HEI
    MOV    TMP2,BX
    MOV    CNT,0
    POP    BX
    
    LODSB    ;������ģ��һ���ֽڵ�AL
NEXT2:
    SHL    AL,1    ;���BIT����
    JNC    NEXT1    

    ;�����жϻ���
    PUSH    AX
    MOV    AH,0CH
    MOV    AL,15    ;ȷ����ͼ��ɫ,0-15
    INT    10H
    POP    AX

NEXT1:
    INC    CNT    ;һ���ֽ�����BIT�����Ժ�������һ���ֽ�
    CMP    CNT,8
    JNZ    NEXT3
    LODSB
    MOV    CNT,0
NEXT3:
    INC    CX
    DEC    TMP1
    JNZ    NEXT2    ;TMP!=0����ȥ������TMP1=0����
    PUSH    BX
    MOV    BX,WID    ;TMP1����
    MOV    TMP1,BX
    POP    BX
    MOV    CX,XORG
    INC    DX
    DEC    TMP2
    JNZ    NEXT2    ;�����ж��������û������ȥ����
    RET
DRAW    ENDP
CODE    ENDS
    END    MAIN
