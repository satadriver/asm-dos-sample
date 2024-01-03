DATA    SEGMENT
;定义0-N个字模
MAP1    DB 001H,080H,0E7H,081H,0C1H,06H,00H,0CH,082H,021H
    DB 0CDH,02EH

;由于程序支持画N个字模，下面的定义变量在画图之前才被赋值
WID    DW ?    ;图的宽度(像素)
HEI    DW ?    ;图的高度
TMP1    DW ?    ;行中像素游标(横向)
TMP2    DW ?    ;行数游标(纵向)
CNT    DB 0    ;比特游标，从0-7
XORG    DW ?    ;控制图像的初始X
YORG    DW ?    ;控制图像的初始Y

DATA    ENDS

CODE    SEGMENT
    ASSUME    DS:DATA,CS:CODE
MAIN:
    MOV    AX,DATA
    MOV    DS,AX
        
        
    ;*****进入图形模式****    
    MOV    AH,0
    MOV    AL,12H    ;640*480
    INT    10H    ;调用中断使设置生效
    

    ;*****画图****
    ;初始坐标,载入字模的位置
    
    LEA    SI,MAP1
    MOV    XORG,0
    MOV    YORG,0
    MOV    WID,640
    MOV    HEI,480
    CALL    DRAW

    ;*****按键退出*****
    MOV    AH,0            
    INT    16H                
                            
    MOV    AX,0003H        ;还原文字模式            
    INT    10H        ;调用中断使设置生效
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
    
    LODSB    ;读出字模的一个字节到AL
NEXT2:
    SHL    AL,1    ;逐个BIT读出
    JNC    NEXT1    

    ;调用中断画点
    PUSH    AX
    MOV    AH,0CH
    MOV    AL,15    ;确定画图颜色,0-15
    INT    10H
    POP    AX

NEXT1:
    INC    CNT    ;一个字节所有BIT读完以后载入下一个字节
    CMP    CNT,8
    JNZ    NEXT3
    LODSB
    MOV    CNT,0
NEXT3:
    INC    CX
    DEC    TMP1
    JNZ    NEXT2    ;TMP!=0则上去继续，TMP1=0则换行
    PUSH    BX
    MOV    BX,WID    ;TMP1至零
    MOV    TMP1,BX
    POP    BX
    MOV    CX,XORG
    INC    DX
    DEC    TMP2
    JNZ    NEXT2    ;所有行读完结束，没读完上去继续
    RET
DRAW    ENDP
CODE    ENDS
    END    MAIN
