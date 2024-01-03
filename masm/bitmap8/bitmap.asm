;**************************************************************************************
;
;        This Code Show a 256 Color bitmap file in 13h mode. Support negative 
;        coordinate and auto cut out. The 'Bitmap' function have there para: 
;        the pointer to bitmap file name, X coordinate and Y coordinate. The 
;        function can be called like this:
; 
;        push Y coordinate
;        push X coordinate
;        push offset ImageSrc
;        call Bitmap
; 
;                         Written By Nirvana     
;                         email:westdatas@163.com
;                         oicq :19820914
;**************************************************************************************

Stack    Segment
         Stk          db    65535    dup(?)
Stack    Ends
Data     Segment
         ImageBuffer  db    65078    dup(?)
	 ImageSrc     db    'bitmap.bmp',0
	 Eflag        db    ?
	 OpenErrorMsg db    'open file error',24h
	 Not256Color  db    'Not a 256 color bitmap',24h
	 handle       dw    ?
Data     Ends
Code     Segment
         Assume cs:Code,ds:Data,ss:Stack
Start:
         mov ax,Data
	 mov ds,ax
	 mov di,-100
         mov si,50
	 mov dx,offset ImageSrc
	 push si
	 push di
	 push dx
	 call Bitmap
	 mov ax,0
	 int 16h
         mov ax,4c01h
         int 21h
          
BitMap   Proc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                          ;
;               ===================                                        ;
;             * Local Variable list *                                      ;
;               ===================                                        ;
;                                                                          ;
;        (1)  BmpWidth           (:Word)                                   ;
;        (2)  BmpOnScreenWidth   (:Word)                                   ;
;        (3)  BytePerRow         (:Word)                                   ;
;        (4)  LeftCutWidth       (:Word)                                   ;
;        (5)  BmpHeight          (:Word)                                   ;
;        (6)  BmpOnScreenHeight  (:Word)                                   ;
;        (7)  BytePerPixel       (:Word)                                   ;
;        (8)  PaletteOffset      (:Word)                                   ;
;        (9)  ImgDataOffset      (:Word)                                   ;
;        (10) RowOffset          (:Word)                                   ;
;                                                                          ;
;                                                                          ;
;===========================================================================

         push bp
	 mov bp,sp
	 sub sp,20
	 push ax
	 push bx
	 push cx
	 push dx
	 push si
	 push di
	 push es
         mov dx,[bp+4]
	 mov ax,3d00h
	 int 21h           ;Open the bitmap file
	 jnc OpenOk
	 mov Eflag,0
Error:                     ;Show error message
         cmp Eflag,0
	 jz  OpenError
         cmp Eflag,1
	 jz  Not256
OpenError:
         mov dx,offset OpenErrorMsg
	 jmp showtext
Not256:
         mov dx,offset Not256Color
	 jmp ShowText
ShowText:
	 mov ah,09h
	 int 21h
	 jmp exit
OpenOk:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                          ;
;        Read  first 4 byte of the file in order to get the file size      ;;;;;;;;;;;;
;                                                                          ;         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         ;;
                                                                                     ;;
         mov bx,ax                                                                   ;;
	 mov handle,bx                                                               ;;
         mov dx,offset ImageBuffer                                                   ;;
         mov cx,4                                                                    ;;
         mov ax,3f00h                                                                ;;
         int 21h           ;Read the first 4 byte to memory                          ;;
	 mov ax,3e00h                                                                ;;
	 mov bx,handle                                                               ;;
	 int 21h           ;Close the bitmap file                                    ;;
	                                                                             ;;
;====================================================================================;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                          ;     
;        Read The entire bitmap file to memory                             ;;;;;;;;;;;;
;                                                                          ;         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         ;;
                                                                                     ;;
	 mov si,2                                                                    ;;
	 mov cx,[si]       ;Save the bitmap file entire size to CX Register          ;;
	 mov dx,[bp+4]     ;                                                         ;;
	 mov ax,3d00h                                                                ;;
	 int 21h           ;Open the bitmap file again                               ;;
	 mov bx,ax                                                                   ;;
	 mov handle,bx                                                               ;;
         mov dx,offset ImageBuffer                                                   ;;
         mov ax,3f00h                                                                ;;
         int 21h           ;Read the entire bitmap file to memory                    ;;
	 mov ax,3e00h                                                                ;;
	 mov bx,handle                                                               ;;
	 int 21h           ;Close the bitmap file                                    ;;
                                                                                     ;;
;====================================================================================;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                          ;
;        Save Information to local variable                                ;;;;;;;;;;;;
;                                                                          ;         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         ;;
                                                                                     ;;
         mov si,012h                                                                 ;;
         mov ax,[si]                                                                 ;;
	 mov [bp-2],ax     ;Save BmpWidth                                            ;;
	 mov [bp-4],ax     ;Save BmpOnScreenWidth                                    ;;
	 mov [bp-6],ax     ;Save BytePerRow                                          ;;
         mov cl,4                                                                    ;;
	 div cl                                                                      ;;
	 cmp ah,0                                                                    ;;
	 jz  NoDwAA        ;No Dword align adjust                                    ;;
	 mov cl,4                                                                    ;;
	 sub cl,ah                                                                   ;;
	 add [bp-6],cl                                                               ;;
NoDwAA:                                                                              ;;
         mov cx,0                                                                    ;;
	 mov [bp-8],cx     ;Save LeftCutWidth,Default = 0                            ;;
	 mov si,016h                                                                 ;;
	 mov ax,[si]                                                                 ;;
	 mov [bp-10],ax    ;Save BmpHeight                                           ;;
	 mov [bp-12],ax    ;Save BmpOnScreenHeight                                   ;;
         mov si,01ch                                                                 ;;
	 mov ax,[si]                                                                 ;;
	 mov [bp-14],ax    ;Save BitPerPixel                                         ;;
	 mov si,0eh                                                                  ;;
	 mov ax,[si]       ;Save bmpfileheader length                                ;;
	 add ax,14                                                                   ;;
	 mov [bp-16],ax    ;Save PaletteOffset                                       ;;
         mov si,0ah                                                                  ;;
	 mov ax,[si]                                                                 ;;
	 mov [bp-18],ax    ;Save ImgDataOffset                                       ;;
         ;mov [bp-20],0     ;Save RowOffset                                          ;;
                                                                                     ;;
;====================================================================================;;

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;                                                                                    
;        Seve the value to Local variable
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

         jmp CoorDinateX
exitzz:
         jmp exit
CoordinateX:         
	 mov ax,[bp+6]     ;X coordinate
	 push ax
	 and ah,80
	 pop ax
	 jz  PositiveX     ;If X coordinate>=0,jump
	 mov ax,[bp+6]
	 push ax
	 not ax
	 inc ax
	 mov [bp-8],ax     ;Save LeftCutWidth
	 pop ax
	 add ax,[bp-2]     ;X coordinate add BmpWidth
	 jnc exitzz        ;Exit if X coordinate add BmpWidth < 0
	 jz exitzz         ;Exit if X coordinate add BmpWidth = 0
	 push ax
	 mov cx,320
	 sub cx,ax
	 mov [bp-20],cx    ;Save RowOffset
         add ax,[bp-8]     
	 mov [bp-4],ax     ;Save BmpOnScreenWidth + LeftCut
	 pop ax
	 mov cx,320
	 cmp cx,ax
	 jnc NoWOverf      ;No Width Overflow
	 mov ax,[bp-8]
	 add ax,320
	 mov [bp-4],ax     ;Save BmpOnScreenWidth = 320 + LeftCutWidth
	 mov ax,0
	 mov [bp-20],ax
NoWOverf: 
         mov ax,0
         mov [bp+6],ax
	 jmp CoordinateY
PositiveX:
         cmp ax,320
	 jnc exitzz
         mov cx,320
	 sub cx,[bp-2]
	 mov [bp-20],cx
	 add ax,[bp-2]
	 mov cx,320
	 cmp cx,ax
	 jnc CoordinateY
	 mov ax,320
	 sub ax,[bp+6]
	 mov [bp-4],ax     ;Save OnScreenWidth
	 mov cx,320
	 sub cx,ax
	 mov [bp-20],cx    ;SaveRowOffset
CoordinateY:
         mov ax,[bp+8]     ;Y coordinate
         push ax
	 and ah,80
	 pop ax
	 jz PositiveY
	 add ax,[bp-10]
	 jnc exitzz1
	 jz exitzz1
	 mov [bp-10],ax    ;Save BmpHeight
	 mov [bp-12],ax    ;Save OnScreenHeight
	 mov cx,0
         mov [bp+8],cx
	 mov cx,200
         cmp cx,ax
	 jnc SetInt10      ;No Height Overflow
	 mov cx,200
	 mov [bp-12],cx
NoHOverf:        
	 jmp SetInt10
exitzz1:
         jmp exit
PositiveY:
         cmp ax,200
	 jnc exitzz1
	 add ax,[bp-10]
	 mov cx,200
	 cmp cx,ax
	 jnc SetInt10
	 mov ax,200
	 sub ax,[bp+8]
	 mov [bp-12],ax

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

;**************************************************************************************
;                                                                                    
;        Set the Palette register and copy image data to video buffer which 
;        address start at A000:0000.
;
;**************************************************************************************

SetInt10:
         mov ax,013h     
         int 10h          ;Set Video Mode to 13h
         mov dx,03c6h
         mov ax,0ffh
         out dx,ax
	 mov si,[bp-16]
	 mov di,0
	 mov cx,256
SetPalette:        
         mov dx,03c8h
         mov ax,di
         out dx,al
         mov dx,03c9h
         mov al,byte ptr[si+2]
	 push bx
         mov bl,63
         mul bl
         mov bl,0ffh
         div bl
	 pop bx
         out dx,al
	 mov al,byte ptr[si+1]
	 push bx
         mov bl,63
         mul bl
         mov bl,0ffh
         div bl
	 pop bx
         out dx,al
	 mov al,byte ptr[si]
	 push bx
         mov bl,63
         mul bl
         mov bl,0ffh
         div bl
	 pop bx
         out dx,al
      	 add si,4
	 inc di
	 loop SetPalette
Showbmp:
         mov ax,0a000h    ;Video memory start address   
	 mov es,ax
	 mov ax,[bp+8]
         mov cx,320
	 mul cx
	 add ax,[bp+6]
	 mov di,ax
vertical:
         cmp word ptr[bp-12],0
	 jz exit
	 dec word ptr[bp-10]
	 dec word ptr[bp-12]
	 mov ax,[bp-10]
	 mul word ptr[bp-6]
	 mov bx,ax
	 add bx,[bp-18]
	 mov si,0
	 add si,[bp-8]
horizon:
         cmp si,word ptr[bp-4]
	 jz horizonend
	 mov al,[bx][si]
	 mov es:[di],al
	 inc si
	 inc di
	 jmp horizon
horizonend:
         add di,[bp-20]
	 jmp Vertical
	
;**************************************************************************************

exit:
         pop es
	 pop di
	 pop si
	 pop dx
	 pop cx
	 pop bx
	 pop ax
         add sp,20
	 pop bp
	 ret 6
Bitmap   endp
Code     Ends
         End Start 