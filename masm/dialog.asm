;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;                                  *����˵��*                             
;===============================================================================================
;                              
;                          
;          �Ի������������;�����϶���,��׼windows�Ի���һ��ʹ����5����ɫ,�ֱ���:
;      #D4D0C8,#0E296E,#FFFFFF,#808080,#404040.����#D4D0C8�ǶԻ���������ɫ,
;      #0E296E�Ǳ�������ɫ,����������ɫ�ǶԻ���߿�ʹ�õ���ɫ,�Ի���߿���Ҫ����Ӫ
;      ��Ի�������Ч��.
;   
;          ����������ʹ�õ���640*480*16ɫ��ʾģʽ,�޷�ȡ����׼windows��������Ҫ��5��
;      ��ɫ,����ʹ���������ɫ�����滻.
;
;          �����������˺þù���640*480*16ɫģʽ���������,���ջ���û���ҵ���ϸ������.
;      �Լ�д��һ�����㺯��(�����е�DrawPointb),����ʹ���������������ʱ�е�����,����ɫ
;      ��������ʱ����,�����ɫ����ż��ʱ,���ν�������ȷ��ʾ.��������ʹ�õĻ��㺯��������
;      ���ҵ�,�����������Ҳ��һ������,�����ٶȷǳ���,�������ȥ����������Ļ,��ʹ�úó���
;      ʱ��.���Գ����еĴ󱳾��������������ַ�������,�����Ķ�ʹ��DrawPoint����.���˭
;      �бȽ���ϸ��640*480*16ɫ��ʾģʽ���������,��Ҫ���˸�����.
; 
;          ������ʾ����C������ʾ�ķ�ʽ�е�����,��Ϊ��ʵģʽ��ÿ�������������64K,���ֿ�          
;      �ļ���һ�ٶ�K,���Բ���һ�ν��ֿ��ļ�����,��ʹ�õķ����ǰ��ֿ��ļ���,Ȼ��ÿ��ʾ
;      һ������,�ƶ�һ��ָ��,��ָ���ƶ�����Ӧ�ĵ���Ȼ���ȡһ���ֵĵ�����Ϣ���ڴ�,ֱ���ַ�
;      ����ʾ���.
;
;          �������Ҫ�����������,����Ҫ��Ҫ��ʾ�ĺ��ֵĵ�����Ϣ���ֿ�����ȡ����.��ʾ����
;      ���ӳ���ҲҪ����Ӧ���޸�.
;
;          ����ʱ�䲻�Ǻܿ�ԣ,������û��дע��,��������������:
;
;          1.ConfirmTCan(��ť��ȷ��״̬��Ϊȡ��״̬)
;          2.CanTConfirm(��ť��ȡ��״̬��Ϊȷ��״̬)
;          3.ShowHanZi(��ʾ�����ӳ���)
;          4.DrawDialog(��ʾ�Ի����ӳ���)
;          5.DrawButtonNoSelected(��һ��δѡ��״̬�İ�ť)
;          6.DrawButtonOnSelected(��һ��ѡ��״̬�İ�ť)
;          7.DrawRect(�������ӳ���)
;          8.DrawPoint(�����ӳ���)
;
;          ************Tab�����߷�������ư�ť����任******************************
;
;                                       e-mail:westdatas@163.com  OICQ:19820914
;                                       Nirvana     2006.8.1
;==============================================================================================


.286
data        segment
            flag     db  0h
            words    db  '����',0
	    words0   db  '��ȷ��Ҫ�˳�ϵͳ��',0
	    words1   db  'ȷ��',0
	    words2   db  'ȡ��',0
	    words3   db  '��ʼ',0
	    hzk      db  'HZK12',0
data        ends
code        segment
            assume    cs:code,ds:data
start:
	    mov ax,data
	    mov ds,ax
	    mov ax,12h
	    int 10h	    
            mov ax,0A000h
            mov es,ax     
            mov dx,03C4h   
            mov ax,0302h  
            out dx,ax     
            mov di,0      
            mov cx,38400
            mov ax,0FFh
            rep stosb
            mov ax,100
	    push ax
            mov ax,200
	    push ax
	    mov ax,120
	    push ax
	    mov ax,220
	    push ax
	    call DrawDialog
	    mov ax,22
	    push ax
            mov ax,61
	    push ax
	    mov ax,180
	    push ax
	    mov ax,240
	    push ax
	    call DrawButtonNoSelected
	    mov ax,22
	    push ax
            mov ax,61
	    push ax
	    mov ax,180
	    push ax
	    mov ax,340
	    push ax
	    call DrawButtonOnSelected	    
	    mov ax,25
	    push ax
            mov ax,640
	    push ax
	    mov ax,456
	    push ax
	    mov ax,0
	    push ax
	    call DrawButtonNoSelected
	    mov ax,20
	    push ax
            mov ax,40
	    push ax
	    mov ax,458
	    push ax
	    mov ax,2
	    push ax
	    call DrawButtonNoSelected
            mov ax,0fh
	    push ax
	    mov ax,offset hzk
            push ax
	    mov ax,offset words
	    push ax
	    mov ax,12
	    push ax
	    mov ax,126
	    push ax
	    mov ax,226
	    push ax
	    call ShowHanZi
	    mov ax,00h
	    push ax
	    mov ax,offset hzk
            push ax
	    mov ax,offset words0
	    push ax
	    mov ax,12
	    push ax
	    mov ax,156
	    push ax
	    mov ax,258
	    push ax
	    call ShowHanZi
	    mov ax,00h
	    push ax
	    mov ax,offset hzk
            push ax
	    mov ax,offset words1
	    push ax
	    mov ax,20
	    push ax
	    mov ax,184
	    push ax
	    mov ax,254
	    push ax
	    call ShowHanZi
	    mov ax,00h
	    push ax
	    mov ax,offset hzk
            push ax
	    mov ax,offset words2
	    push ax
	    mov ax,20
	    push ax
	    mov ax,184
	    push ax
	    mov ax,354
	    push ax
	    call ShowHanZi
	    mov ax,00h
	    push ax
	    mov ax,offset hzk
            push ax
	    mov ax,offset words3
	    push ax
	    mov ax,15
	    push ax
	    mov ax,462
	    push ax
	    mov ax,8
	    push ax
	    call ShowHanZi       
WaitPress:
            mov ah,00h
	    int 16h
            cmp ah,01ch
	    jz  DealEnter
	    cmp ah,04bh
	    jz  DealDitKey
	    cmp ah,048h
	    jz DealDitKey
	    cmp ah,04dh
	    jz DealDitKey
	    cmp ah,050h
	    jz DealDitKey
	    cmp ah,0fh
	    jz DealDitKey
	    jmp WaitPress
DealEnter:
            cmp flag,1
	    jz Exit
	    jmp WaitPress
DealDitKey:
            cmp flag,1
	    jz CTC
	    call CanTConfirm
	    xor flag,1
	    jmp WaitPress
CTC:
            call ConfirmTCan
	    xor flag,1
	    jmp WaitPress            
Exit:       
	    mov ax,4c01h
	    int 21h
ConfirmTCan proc
            mov ax,22
	    push ax
            mov ax,61
	    push ax
	    mov ax,180
	    push ax
	    mov ax,240
	    push ax
	    call DrawButtonNoSelected
	    mov ax,00h
	    push ax
	    mov ax,offset hzk
            push ax
	    mov ax,offset words1
	    push ax
	    mov ax,20
	    push ax
	    mov ax,184
	    push ax
	    mov ax,254
	    push ax
	    call ShowHanZi
	    mov ax,22
	    push ax
            mov ax,61
	    push ax
	    mov ax,180
	    push ax
	    mov ax,340
	    push ax
	    call DrawButtonOnSelected
	    mov ax,00h
	    push ax
	    mov ax,offset hzk
            push ax
	    mov ax,offset words2
	    push ax
	    mov ax,20
	    push ax
	    mov ax,184
	    push ax
	    mov ax,354
	    push ax
	    call ShowHanZi
            ret
ConfirmTCan endp

CanTConfirm proc
            mov ax,22
	    push ax
            mov ax,61
	    push ax
	    mov ax,180
	    push ax
	    mov ax,240
	    push ax
	    call DrawButtonOnSelected	    
	    mov ax,00h
	    push ax
	    mov ax,offset hzk
            push ax
	    mov ax,offset words1
	    push ax
	    mov ax,20
	    push ax
	    mov ax,184
	    push ax
	    mov ax,254
	    push ax
	    call ShowHanZi
	    mov ax,22
	    push ax
            mov ax,61
	    push ax
	    mov ax,180
	    push ax
	    mov ax,340
	    push ax
	    call DrawButtonNoSelected
	    mov ax,00h
	    push ax
	    mov ax,offset hzk
            push ax
	    mov ax,offset words2
	    push ax
	    mov ax,20
	    push ax
	    mov ax,184
	    push ax
	    mov ax,354
	    push ax
	    call ShowHanZi
	    ret
CanTConfirm endp
                        
ShowHanZi   proc ;(X[bp+4],Y[bp+6],Dis[bp+8],WordsPtr[bp+10],ZiKuPtr[bp+12],Color[bp+14])
            push bp
	    mov bp,sp
	    sub sp,30    ;x[bp-2],y[bp-4],handle[bp-6]
	    pusha
	    mov dx,[bp+12]
	    mov ax,3d00h
	    int 21h
	    mov [bp-6],ax
	    jnc shzNextC
	    mov word ptr[bp+12],1
shzExitZz:
	    jmp shzExit
shzNextC:           
	    mov si,[bp+10]
	    mov ax,[si]
	    cmp al,0
	    jz  shzExitZz
	    sub ax,0a1a1h
	    mov dl,ah
	    mov ah,94
            mul ah
	    mov dh,0
	    add ax,dx
            mov dx,24
	    mul dx
            mov cx,dx
	    mov dx,ax
	    mov bx,[bp-6]
	    mov ax,4200h
	    int 21h
            mov cx,24
            push ds
	    mov ax,ss
	    mov ds,ax
	    mov ah,03fh
	    mov dx,bp
	    sub dx,30
	    mov bx,[bp-6]
	    int 21h
	    pop ds

	    mov si,0
	    mov bx,[bp+12]
	    mov ax,[bp+4]
	    mov [bp-2],ax
	    mov ax,[bp+6]
	    mov [bp-4],ax
	    mov cx,12
shzNextRow:
            push cx
	    mov cx,12
	    mov dx,08000h
shzNextCol:
            mov ax,[bp-30][si]
	    xchg ah,al
            test ax,dx
	    jz shzNotDraw
	    push [bp+14]
	    push [bp-4]
	    push [bp-2]
	    call DrawPoint
shzNotDraw:
            inc word ptr[bp-2]
	    shr dx,1
            loop shzNextCol
	    pop cx
	    add si,2
	    inc word ptr[bp-4]
	    mov ax,[bp+4]
	    mov [bp-2],ax
	    loop shzNextRow
	    add word ptr[bp+10],2
	    mov ax,[bp+8]
	    add word ptr[bp+4],ax
	    jmp shzNextC	  
shzExit:
	    mov ah,03eh
	    mov bx,[bp-6]
	    int 21h
	    popa
	    add sp,30
	    pop bp
	    ret 12
ShowHanZi   endp

DrawDialog  proc    ;(x [bp+4],y [bp+6],width [bp+8],height [bp+10])
            push bp
	    mov bp,sp
	    push ax
	    
	    ;///////////////////////main window///////////////
            mov ax,07h
	    push ax
	    mov ax,[bp+10]
            push ax
	    mov ax,[bp+8]
	    push ax
	    mov ax,[bp+6]
	    push ax
	    mov ax,[bp+4]
	    push ax
	    call DrawRect
	    ;/////////////////////////////////////////////////

	    ;/////////////////////////blue banner/////////////
	    mov ax,01h
	    push ax
	    mov ax,20
	    push ax
	    mov ax,[bp+8]
	    sub ax,6
	    push ax
	    mov ax,[bp+6]
	    add ax,3
	    push ax
	    mov ax,[bp+4]
	    add ax,3
	    push ax
	    call DrawRect
	    ;/////////////////////////////////////////////////

	    ;///////////////////////Left white////////////////
	    mov ax,0fh
	    push ax
	    mov ax,[bp+10]
	    sub ax,3
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+6]
	    inc ax
	    push ax
	    mov ax,[bp+4]
	    inc ax
	    push ax
	    call DrawRect
            ;/////////////////////////////////////////////////

	    ;//////////////////////upper white////////////////
	    mov ax,0fh
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+8]
	    sub ax,3
	    push ax
	    mov ax,[bp+6]
	    inc ax
	    push ax
	    mov ax,[bp+4]
	    inc ax
	    push ax
	    call DrawRect
	    ;///////////////////////////////////////////////

	    ;/////////////////////right gray////////////////
	    mov ax,08h
	    push ax
            mov ax,[bp+10]
	    sub ax,2
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+6]
	    inc ax
	    push ax
	    mov ax,[bp+4]
	    add ax,[bp+8]
	    sub ax,1
	    push ax
	    call DrawRect
	    ;/////////////////////////////////////////////////

	    ;/////////////////////right black/////////////////
	    mov ax,00h
	    push ax
	    mov ax,[bp+10]
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+6]
	    push ax
	    mov ax,[bp+4]
	    add ax,[bp+8]
	    sub ax,1
	    push ax
	    call DrawRect
	    ;////////////////////////////////////////////////

	    ;//////////////////////bottom gray///////////////
	    mov ax,08h
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+8]
	    sub ax,2
	    push ax
	    mov ax,[bp+6]
	    add ax,[bp+10]
	    sub ax,2
	    push ax
	    mov ax,[bp+4]
	    inc ax
	    push ax
	    call DrawRect
	    ;////////////////////////////////////////////////

	    ;/////////////////////bottom black///////////////
	    mov ax,00h
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+8]
	    push ax
	    mov ax,[bp+6]
	    add ax,[bp+10]
	    sub ax,1
	    push ax
	    mov ax,[bp+4]
	    push ax
	    call DrawRect
	    pop ax
	    pop bp
	    ret 8
DrawDialog  endp
DrawButtonNoSelected  proc    ;(x [bp+4],y [bp+6],width [bp+8],height [bp+10])
            push bp
	    mov bp,sp
	    push ax
	    
	    ;///////////////////////main window///////////////
            mov ax,07h
	    push ax
	    mov ax,[bp+10]
            push ax
	    mov ax,[bp+8]
	    push ax
	    mov ax,[bp+6]
	    push ax
	    mov ax,[bp+4]
	    push ax
	    call DrawRect
	    ;////////////////////////////////////////////////

	    ;///////////////////////Left Black///////////////
	    mov ax,00h
	    push ax
	    mov ax,[bp+10]
	    dec ax
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+6]
	    push ax
	    mov ax,[bp+4]
	    push ax
	    call DrawRect
	    ;/////////////////////////////////////////////////

	    ;//////////////////////Top Black//////////////////
	    mov ax,00h
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+8]
	    dec ax
	    push ax
	    mov ax,[bp+6]
	    push ax
	    mov ax,[bp+4]
	    push ax
	    call DrawRect
	    ;/////////////////////////////////////////////////

	    ;///////////////////////Left white////////////////
	    mov ax,0fh
	    push ax
	    mov ax,[bp+10]
	    sub ax,3
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+6]
	    inc ax
	    push ax
	    mov ax,[bp+4]
	    inc ax
	    push ax
	    call DrawRect
            ;/////////////////////////////////////////////////

	    ;//////////////////////upper white////////////////
	    mov ax,0fh
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+8]
	    sub ax,3
	    push ax
	    mov ax,[bp+6]
	    inc ax
	    push ax
	    mov ax,[bp+4]
	    inc ax
	    push ax
	    call DrawRect
	    ;///////////////////////////////////////////////

	    ;/////////////////////right gray////////////////
	    mov ax,08h
	    push ax
            mov ax,[bp+10]
	    sub ax,2
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+6]
	    inc ax
	    push ax
	    mov ax,[bp+4]
	    add ax,[bp+8]
	    sub ax,1
	    push ax
	    call DrawRect
	    ;/////////////////////////////////////////////////

	    ;/////////////////////right black/////////////////
	    mov ax,00h
	    push ax
	    mov ax,[bp+10]
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+6]
	    push ax
	    mov ax,[bp+4]
	    add ax,[bp+8]
	    sub ax,1
	    push ax
	    call DrawRect
	    ;////////////////////////////////////////////////

	    ;//////////////////////bottom gray///////////////
	    mov ax,08h
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+8]
	    sub ax,2
	    push ax
	    mov ax,[bp+6]
	    add ax,[bp+10]
	    sub ax,2
	    push ax
	    mov ax,[bp+4]
	    inc ax
	    push ax
	    call DrawRect
	    ;////////////////////////////////////////////////

	    ;/////////////////////bottom black///////////////
	    mov ax,00h
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+8]
	    push ax
	    mov ax,[bp+6]
	    add ax,[bp+10]
	    sub ax,1
	    push ax
	    mov ax,[bp+4]
	    push ax
	    call DrawRect
	    pop ax
	    pop bp
	    ret 8
DrawButtonNoSelected  endp
DrawButtonOnSelected  proc    ;(x [bp+4],y [bp+6],width [bp+8],height [bp+10])
            push bp
	    mov bp,sp
	    push ax
	    
	    ;///////////////////////main window///////////////
            mov ax,07h
	    push ax
	    mov ax,[bp+10]
            push ax
	    mov ax,[bp+8]
	    push ax
	    mov ax,[bp+6]
	    push ax
	    mov ax,[bp+4]
	    push ax
	    call DrawRect
	    ;////////////////////////////////////////////////

	    ;///////////////////////Left Black///////////////
	    mov ax,00h
	    push ax
	    mov ax,[bp+10]
	    dec ax
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+6]
	    push ax
	    mov ax,[bp+4]
	    push ax
	    call DrawRect
	    ;/////////////////////////////////////////////////

	    ;//////////////////////Top Black//////////////////
	    mov ax,00h
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+8]
	    dec ax
	    push ax
	    mov ax,[bp+6]
	    push ax
	    mov ax,[bp+4]
	    push ax
	    call DrawRect
	    ;/////////////////////////////////////////////////

	    ;///////////////////////Left white////////////////
	    mov ax,0fh
	    push ax
	    mov ax,[bp+10]
	    sub ax,3
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+6]
	    inc ax
	    push ax
	    mov ax,[bp+4]
	    inc ax
	    push ax
	    call DrawRect
            ;/////////////////////////////////////////////////

	    ;//////////////////////upper white////////////////
	    mov ax,0fh
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+8]
	    sub ax,3
	    push ax
	    mov ax,[bp+6]
	    inc ax
	    push ax
	    mov ax,[bp+4]
	    inc ax
	    push ax
	    call DrawRect
	    ;///////////////////////////////////////////////

	    ;/////////////////////right gray////////////////
	    mov ax,08h
	    push ax
            mov ax,[bp+10]
	    sub ax,2
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+6]
	    inc ax
	    push ax
	    mov ax,[bp+4]
	    add ax,[bp+8]
	    sub ax,1
	    push ax
	    call DrawRect
	    ;/////////////////////////////////////////////////

	    ;/////////////////////right black/////////////////
	    mov ax,00h
	    push ax
	    mov ax,[bp+10]
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+6]
	    push ax
	    mov ax,[bp+4]
	    add ax,[bp+8]
	    sub ax,1
	    push ax
	    call DrawRect
	    ;////////////////////////////////////////////////

	    ;//////////////////////bottom gray///////////////
	    mov ax,08h
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+8]
	    sub ax,2
	    push ax
	    mov ax,[bp+6]
	    add ax,[bp+10]
	    sub ax,2
	    push ax
	    mov ax,[bp+4]
	    inc ax
	    push ax
	    call DrawRect
	    ;////////////////////////////////////////////////

	    ;/////////////////////bottom black///////////////
	    mov ax,00h
	    push ax
	    mov ax,1
	    push ax
	    mov ax,[bp+8]
	    push ax
	    mov ax,[bp+6]
	    add ax,[bp+10]
	    sub ax,1
	    push ax
	    mov ax,[bp+4]
	    push ax
	    call DrawRect
            ;////////////////////////////////////////////////

	    ;/////////////////////Button left black/////////

	    mov ax,00h
	    push ax
	    mov ax,[bp+6]
	    add ax,4
	    inc ax
	    mov bx,ax
	    push bx
	    mov dx,[bp+4]
	    add dx,4
	    push dx
	    call DrawPoint
            add bx,2
	    mov ax,[bp+10]
	    sub ax,7
            shr ax,1
	    mov cl,al
	    dec cl         
  lop:          
	    mov ax,00h
	    push ax
	    push bx
	    push dx
	    call DrawPoint
            add bx,2
            loop lop

	    ;/////////////////////Button left black/////////

            ;////////////////////Button right black/////////

            mov ax,00h
	    push ax
	    mov ax,[bp+6]
	    add ax,4
	    inc ax
	    mov bx,ax
	    push bx
	    mov dx,[bp+4]
	    add dx,[bp+8]
	    sub dx,5
	    push dx
	    call DrawPoint
            add bx,2           
	    mov ax,[bp+10]
	    sub ax,7
            shr ax,1
	    mov cl,al
	    dec cl
lop1:          
	    mov ax,00h
	    push ax
	    push bx
	    push dx
	    call DrawPoint
            add bx,2
            loop lop1
            ;///////////////////////////////////////////////

            ;////////////////////Button top black/////////         
	    mov ax,00h
	    push ax
	    mov dx,[bp+6]
	    add dx,4
	    push dx
	    mov bx,[bp+4]
	    add bx,4
	    inc bx
            push bx
	    call DrawPoint
	    add bx,2
	    mov ax,[bp+8]
	    sub ax,8
	    shr ax,1
	    mov cl,al
	    dec cl
	    mov ch,0
lop3:
            mov ax,0h
	    push ax
	    push dx
	    push bx
	    call DrawPoint
	    add bx,2
	    loop lop3
	    ;///////////////////////////////////////////////////


	    ;////////////////////Button bottom black/////////
       	    mov ax,00h
	    push ax
	    mov dx,[bp+6]
	    add dx,[bp+10]
	    sub dx,4
	    push dx
	    mov bx,[bp+4]
	    add bx,4
	    inc bx
            push bx
	    call DrawPoint
	    add bx,2
	    mov ax,[bp+8]
	    sub ax,8
	    shr ax,1
	    mov cl,al
	    dec cl
	    mov ch,0
lop4:
            mov ax,0h
	    push ax
	    push dx
	    push bx
	    call DrawPoint
	    add bx,2
	    loop lop4
	    ;///////////////////////////////////////////////////
	    pop ax
	    pop bp
	    ret 8
DrawButtonOnSelected  endp
;DrawBlackBorder proc ;(x,y,width,height,color) bp+4
            


DrawRect    proc    ;(x,y,width,height,color) bp+4
            push bp
	    mov bp,sp
	    pusha
DrawLineV:
	    mov ax,[bp+4]
	    mov dx,[bp+8]
DrawLineH:
	    push word ptr[bp+12]
	    push word ptr[bp+6]
	    push ax
	    call DrawPoint
	    inc ax
	    dec dx
	    jnz DrawLineH
	    inc word ptr[bp+6]
	    dec word ptr[bp+10]
	    jnz DrawLineV
	    popa
	    pop bp
	    ret 10
DrawRect    endp

DrawPoint   proc near
            push bp
            mov	bp,sp
            pusha
            mov	ax,0a000h
            mov	es,ax
            mov	ax,[bp+06h]   
            shl	ax,04h
            mov	bx,ax
            shl	ax,02h
            add	ax,bx
            mov	bx,[bp+04h]
            mov	cl,bl
            shr	bx,03h	
            add	bx,ax        ;offset=bx
            mov	ch,80h
            and	cl,07h
            shr	ch,cl        ;mask=ch
            ;Set BMR(Bit Mask Register) - mask
            mov	dx,03ceh
            mov	al,08h
            out	dx,al
            inc	dx           ;dx=03cfh
            mov	al,ch
            out	dx,al
            ;Load latch and Zero the pixel
	    sub	al,al
	    xchg  es:[bx],al
   	    ;Set MMR(Map Mask Register) - color
   	    sub	dx,0bh        ;dx=03c4h
   	    mov	al,02h
   	    out	dx,al
   	    mov	al,[bp+08h]
            inc	dx      ;dx=03c5h
            out	dx,al
   	    ;Set the pixel's value;
   	    mov	 es:[bx],ch
   	    ;Reset BMR - 0ffh
   	    add	 dx,09h  ;dx=03ceh
   	    mov	 al,08h
   	    out	 dx,al
   	    inc	 dx      ;dx=03cfh
   	    mov	 al,0ffh
            out	 dx,al
   	    ;Reset MMR - 0fh
   	    sub	 dx,0bh     ;dx=03c4h
   	    mov	 al,02h
   	    out	 dx,al
   	    mov	 al,0fh
   	    inc	 dx      ;dx=03c5h
   	    out	 dx,al
            ;
	    popa
            pop	bp
            ret	06
DrawPoint endp
DrawPointb  proc    ;(x,y,color)
            push bp
	    mov bp,sp
	    pusha
	    mov dx,03C4h
            mov al,02h 
            out dx,al
            mov dx,03c5h
            mov al,[bp+8]
	    out dx,al
	    mov ax,0280h
	    mov dx,[bp+6]
	    mul dx
	    add ax,[bp+4]
	    adc dx,0
	    mov cx,8
	    div cx
	    mov di,00h
	    add di,ax
	    mov ax,0a000h
	    mov es,ax
	    mov cl,dl
	    mov al,7fh
	    ror al,cl
            and es:[di],al
	    mov al,80h
	    shr al,cl
	    or es:[di],al
	    popa
	    pop bp
	    ret 6
DrawPointb  endp
code        ends
            end start

