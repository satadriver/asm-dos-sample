;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;                                  *程序说明*                             
;===============================================================================================
;                              
;                          
;          对话框是由线条和矩形组合而成,标准windows对话框一共使用了5种颜色,分别是:
;      #D4D0C8,#0E296E,#FFFFFF,#808080,#404040.其中#D4D0C8是对话框主体颜色,
;      #0E296E是标题栏颜色,其他三种颜色是对话框边框使用的颜色,对话框边框主要用于营
;      造对话框立体效果.
;   
;          本程序由于使用的是640*480*16色显示模式,无法取到标准windows程序所需要的5种
;      颜色,所以使用相近的颜色进行替换.
;
;          我在网上找了好久关于640*480*16色模式的相关资料,最终还是没有找到详细的资料.
;      自己写了一个画点函数(程序中的DrawPointb),但是使用这个函数画矩形时有点问题,当颜色
;      号是奇数时正常,如果颜色号是偶数时,矩形将不能正确显示.本程序中使用的画点函数是在网
;      上找的,不过这个函数也有一点问题,就是速度非常慢,如果画点去添满整个屏幕,将使用好长的
;      时间.所以程序中的大背景是用我理解的那种方法画的,其他的都使用DrawPoint函数.如果谁
;      有比较详细的640*480*16色显示模式的相关资料,不要忘了告诉我.
; 
;          汉字显示和用C语言显示的方式有点区别,因为在实模式下每个段最大容量是64K,而字库          
;      文件有一百多K,所以不能一次将字库文件读入,我使用的方法是把字库文件打开,然后每显示
;      一个汉字,移动一次指针,将指针移动到响应的点阵然后读取一个字的点阵信息到内存,直到字符
;      串显示完毕.
;
;          如果程序要在裸机下运行,则需要将要显示的汉字的点阵信息从字库中提取出来.显示汉字
;      的子程序也要做相应的修改.
;
;          由于时间不是很宽裕,基本上没有写注释,各个函数的作用:
;
;          1.ConfirmTCan(按钮由确定状态变为取消状态)
;          2.CanTConfirm(按钮由取消状态变为确定状态)
;          3.ShowHanZi(显示汉字子程序)
;          4.DrawDialog(显示对话框子程序)
;          5.DrawButtonNoSelected(画一个未选中状态的按钮)
;          6.DrawButtonOnSelected(画一个选中状态的按钮)
;          7.DrawRect(画矩形子程序)
;          8.DrawPoint(画点子程序)
;
;          ************Tab键或者方向键控制按钮焦点变换******************************
;
;                                       e-mail:westdatas@163.com  OICQ:19820914
;                                       Nirvana     2006.8.1
;==============================================================================================


.286
data        segment
            flag     db  0h
            words    db  '警告',0
	    words0   db  '您确定要退出系统吗？',0
	    words1   db  '确定',0
	    words2   db  '取消',0
	    words3   db  '开始',0
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

