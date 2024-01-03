
                                                                                                                            
; ---------------------------------------------------------------------------                                               
; File Name   : C:\Documents and Settings\Administrator\桌面\新建文件夹\LIUGAI.bin                                          
; Format      : Binary file                                                                                                 
; Base Address: 0000h Range: 0100h - 0420h Loaded length: 0320h                                                             
                                                                                                                            
                .386                                                                                                        
                .model flat                                                                                                 
                                                                                                                            
; ===========================================================================                                               
                                                                                                                            
; Segment type: Pure code                                                                                                   
seg000          segment byte public 'CODE' use16                                                                            
                assume cs:seg000                                                                                            
                org 100h                                                                                                   
                assume es:nothing, ss:nothing, ds:nothing, fs:nothing, gs:nothing  
; ---------------------------------------------------------------------------                                   
start:        in      al, 21h                                                                               
                or      al, 2           ; 禁止键盘中断                                                                      
                out     21h, al         ; Interrupt controller, 8259A.                                                      
                push    cs                                                                                                  
                pop     ds                                                                                                  
                push    ds                                                                                                  
                pop     ds:word_39B       
                jmp        loc_130         ; 原代码为: cli                                                                                                         
                ;xor     ax, ax                                                                                              
                mov     es, ax                                                                                              
                mov     di, 3                                                                                               
                shl     di, 1           ; DI=6                                                                              
                shl     di, 1           ; DI=C,指向INT 3                                                                    
                mov     ax, es:[di]                                                                                         
                xchg    ax, ds:word_399 ; 保存INT 3原向量偏移值                                                             
                                                                                                                            
loc_120:                                ; hacker INT 3偏移地址                                                                
                mov     es:[di], ax                                                                                         
                inc     di                                                                                                  
                inc     di              ; 指向INT 3段位置                                                                   
                                                                                                                            
loc_125:                                                                                                                    
                mov     ax, es:[di]                                                                                         
                xchg    ax, ds:word_39B                                                                                     
                mov     es:[di], ax     ; hacker INT 3段地址                                                                  
                int     3               ; Trap to Debugger                                                                  
; ---------------------------------------------------------------------------                                               
                                                                                                                            
loc_130:                                ; CODE XREF: seg000:0100 j                                                          
                nop                                                                                                         
                nop                                                                                                         
                in      al, 21h         ; Interrupt controller, 8259A.                                                      
                and     al, 0FDh        ; 开放键盘中断                                                                      
                out     21h, al         ; Interrupt controller, 8259A.                                                      
                push    cs                                                                                                  
                pop     ds                                                                                                  
                xor     ax, ax                                                                                              
                int     33h             ; - MS MOUSE - RESET DRIVER AND READ STATUS                                         
                                        ; Return: AX = status                                                               
                                        ; BX = number of buttons                                                            
                cmp     al, 0FFh                                                                                            
                jz      short loc_14F                                                                                       
                mov     dx, 3BDh                                                                                            
                mov     ah, 9                                                                                               
                int     21h             ; DOS - PRINT STRING                                                                
                                        ; DSX -> string terminated by "$"                                                 
                lea     bx, loc_1A2                                                                                         
                jmp     bx                                                                                                  
; ---------------------------------------------------------------------------                                               
                                                                                                                            
loc_14F:                                ; CODE XREF: seg000:0140 j                                                          
                mov     ax, 12h                                                                                             
                int     10h             ; - VIDEO - SET VIDEO MODE                                                          
                                        ; AL = mode                                                                         
                call    sub_308                                                                                             
                push    cs                                                                                                  
                pop     es                                                                                                  
                call    sub_2F2                                                                                             
                cld                                                                                                         
                mov     ax, 1                                                                                               
                int     33h             ; - MS MOUSE - SHOW MOUSE CURSOR                                                    
                                        ; SeeAlso: AX=0002h, INT 16/AX=FFFEh                                                
                mov     ds:word_412, 140h                                                                                   
                mov     dx, 0F0h ; '?                                                                                       
                call    sub_292                                                                                             
                                                                                                                            
loc_16E:                                ; CODE XREF: seg000:018B j                                                          
                                        ; seg000:0195 j ...                                                                 
                mov     ah, 1                                                                                               
                int     16h             ; KEYBOARD - CHECK BUFFER, DO NOT CLEAR                                             
                                        ; Return: ZF clear if character in buffer                                           
                                        ; AH = scan code, AL = character                                                    
                                        ; ZF set if no character in buffer                                                  
                jz      short loc_17D                                                                                       
                mov     ah, 0                                                                                               
                int     16h             ; KEYBOARD - READ CHAR FROM BUFFER, WAIT IF EMPTY                                   
                                        ; Return: AH = scan code, AL = character                                            
                cmp     ah, 1                                                                                               
                jz      short loc_1A2                                                                                       
                                                                                                                            
loc_17D:                                ; CODE XREF: seg000:0172 j                                                          
                mov     ax, 3                                                                                               
                int     33h             ; - MS MOUSE - RETURN POSITION AND BUTTON STATUS                                    
                                        ; Return: BX = button status, CX = column, DX = row                                 
                call    sub_229                                                                                             
                call    sub_1BE                                                                                             
                cmp     bx, 1                                                                                               
                jnz     short loc_16E                                                                                       
                cmp     dx, 1Eh                                                                                             
                ja      short loc_197                                                                                       
                call    sub_271                                                                                             
                jmp     short loc_16E                                                                                       
; ---------------------------------------------------------------------------                                               
                                                                                                                            
loc_197:                                ; CODE XREF: seg000:0190 j                                                          
                cmp     dx, 1C7h                                                                                            
                ja      short loc_16E                                                                                       
                call    sub_283                                                                                             
                jmp     short loc_16E                                                                                       
; ---------------------------------------------------------------------------                                               
                                                                                                                            
loc_1A2:                                ; CODE XREF: seg000:017B j                                                          
                                        ; DATA XREF: seg000:0149 o                                                          
                xor     ax, ax                                                                                              
                mov     es, ax                                                                                              
                cli                                                                                                         
                mov     ax, ds:word_399                                                                                     
                mov     es:0Ch, ax                                                                                          
                mov     ax, ds:word_39B                                                                                     
                mov     es:0Eh, ax                                                                                          
                mov     ax, 3                                                                                               
                int     10h             ; - VIDEO - SET VIDEO MODE                                                          
                                        ; AL = mode                                                                         
                mov     ah, 4Ch                                                                                             
                int     21h             ; DOS - 2+ - QUIT WITH EXIT CODE (EXIT)                                             
                                        ; AL = exit code                                                                    
                                                                                                                            
; =============== S U B R O U T I N E =======================================                                               
                                                                                                                            
                                                                                                                            
sub_1BE         proc near               ; CODE XREF: seg000:0185 p                                                          
                push    si                                                                                                  
                push    di                                                                                                  
                cmp     cx, ds:word_3EE                                                                                     
                jnz     short loc_1CC                                                                                       
                cmp     dx, ds:word_3F0                                                                                     
                jz      short loc_1E1                                                                                       
                                                                                                                            
loc_1CC:                                ; CODE XREF: sub_1BE+6 j                                                            
                call    sub_2C2                                                                                             
                call    sub_292                                                                                             
                mov     ds:word_3EE, cx                                                                                     
                mov     ds:word_3F0, dx                                                                                     
                lea     si, unk_3F2                                                                                         
                call    sub_1E4                                                                                             
                                                                                                                            
loc_1E1:                                ; CODE XREF: sub_1BE+C j                                                            
                pop     di                                                                                                  
                pop     si                                                                                                  
                retn                                                                                                        
sub_1BE         endp                                                                                                        
                                                                                                                            
                                                                                                                            
; =============== S U B R O U T I N E =======================================                                               
                                                                                                                            
                                                                                                                            
sub_1E4         proc near               ; CODE XREF: sub_1BE+20 p                                                           
                                        ; sub_2F2+E p                                                                       
                push    bx                                                                                                  
                push    cx                                                                                                  
                push    dx                                                                                                  
                push    bp                                                                                                  
                mov     bp, cx                                                                                              
                mov     dx, dx                                                                                              
                mov     di, 10h                                                                                             
                                                                                                                            
loc_1EF:                                ; CODE XREF: sub_1E4+3E j                                                           
                mov     cx, 2                                                                                               
                                                                                                                            
loc_1F2:                                ; CODE XREF: sub_1E4+35 j                                                           
                push    cx                                                                                                  
                mov     bl, [si]                                                                                            
                mov     cx, 8                                                                                               
                                                                                                                            
loc_1F8:                                ; CODE XREF: sub_1E4+31 j                                                           
                push    cx                                                                                                  
                shl     bl, 1                                                                                               
                jb      short loc_202                                                                                       
                mov     al, 0                                                                                               
                jmp     short loc_213                                                                                       
; ---------------------------------------------------------------------------                                               
                db  90h ; ?
                                                                                                 
; ---------------------------------------------------------------------------                                               
                                                                                                                            
loc_202:                                ; CODE XREF: sub_1E4+17 j                                                           
                mov     al, byte ptr ds:aMouseIsNotInst+1Ah                                                                 
                mov     cx, bp                                                                                              
                cmp     cx, 27Fh                                                                                            
                ja      short loc_213                                                                                       
                xor     bh, bh                                                                                              
                mov     ah, 0Ch                                                                                             
                int     10h             ; - VIDEO - WRITE DOT ON SCREEN                                                     
                                        ; AL = color of dot, BH = display page                                              
                                        ; CX = column, DX = row                                                             
                                                                                                                            
loc_213:                                ; CODE XREF: sub_1E4+1B j                                                           
                                        ; sub_1E4+27 j                                                                      
                inc     bp                                                                                                  
                pop     cx                                                                                                  
                loop    loc_1F8                                                                                             
                inc     si                                                                                                  
                pop     cx                                                                                                  
                loop    loc_1F2                                                                                             
                dec     di                                                                                                  
                jz      short loc_224                                                                                       
                inc     dx                                                                                                  
                sub     bp, 10h                                                                                             
                jmp     short loc_1EF                                                                                       
; ---------------------------------------------------------------------------                                               
                                                                                                                            
loc_224:                                ; CODE XREF: sub_1E4+38 j                                                           
                pop     bp                                                                                                  
                pop     dx                                                                                                  
                pop     cx                                                                                                  
                pop     bx                                                                                                  
                retn                                                                                                        
sub_1E4         endp                                                                                                        
                                                                                                                            
                                                                                                                            
; =============== S U B R O U T I N E =======================================                                               
                                                                                                                            
                                                                                                                            
sub_229         proc near               ; CODE XREF: seg000:0182 p                                                          
                push    bx                                                                                                  
                push    cx                                                                                                  
                push    dx                                                                                                  
                push    si                                                                                                  
                mov     si, 3DAh                                                                                            
                mov     ax, cx                                                                                              
                call    sub_252                                                                                             
                mov     si, 3E1h                                                                                            
                mov     ax, dx                                                                                              
                call    sub_252                                                                                             
                mov     bh, 0                                                                                               
                mov     dx, 41h ; 'A'                                                                                       
                mov     ah, 2                                                                                               
                int     10h             ; - VIDEO - SET CURSOR POSITION                                                     
                                        ; DH,DL = row, column (0,0 = upper left)                                            
                                        ; BH = page number                                                                  
                mov     dx, 3D8h                                                                                            
                mov     ah, 9                                                                                               
                int     21h             ; DOS - PRINT STRING                                                                
                                        ; DSX -> string terminated by "$"                                                 
                pop     si                                                                                                  
                pop     dx                                                                                                  
                pop     cx                                                                                                  
                pop     bx                                                                                                  
                retn                                                                                                        
sub_229         endp                                                                                                        
                                                                                                                            
                                                                                                                            
; =============== S U B R O U T I N E =======================================                                               
                                                                                                                            
                                                                                                                            
sub_252         proc near               ; CODE XREF: sub_229+9 p                                                            
                                        ; sub_229+11 p                                                                      
                push    di                                                                                                  
                push    si                                                                                                  
                push    dx                                                                                                  
                push    cx                                                                                                  
                lea     di, aMouseIsNotInst+29h                                                                             
                mov     cx, 4                                                                                               
                                                                                                                            
loc_25D:                                ; CODE XREF: sub_252+18 j                                                           
                xor     dx, dx                                                                                              
                div     word ptr [di]                                                                                       
                or      al, 30h                                                                                             
                mov     [si], al                                                                                            
                mov     ax, dx                                                                                              
                inc     si                                                                                                  
                inc     di                                                                                                  
                inc     di                                                                                                  
                loop    loc_25D                                                                                             
                pop     cx                                                                                                  
                pop     dx                                                                                                  
                pop     si                                                                                                  
                pop     di                                                                                                  
                retn                                                                                                        
sub_252         endp                                                                                                        
                                                                                                                            
                                                                                                                            
; =============== S U B R O U T I N E =======================================                                               
                                                                                                                            
                                                                                                                            
sub_271         proc near               ; CODE XREF: seg000:0192 p                                                          
                call    sub_2C2                                                                                             
                mov     ah, 0Dh                                                                                             
                int     10h             ; - VIDEO - READ DOT ON SCREEN                                                      
                                        ; BH = display page, CX = column, DX = row                                          
                cmp     al, 0                                                                                               
                jz      short locret_282                                                                                    
                mov     byte ptr ds:aMouseIsNotInst+1Ah, al                                                                 
                call    sub_2F2                                                                                             
                                                                                                                            
locret_282:                             ; CODE XREF: sub_271+9 j                                                            
                retn                                                                                                        
sub_271         endp                                                                                                        
                                                                                                                            
                                                                                                                            
; =============== S U B R O U T I N E =======================================                                               
                                                                                                                            
                                                                                                                            
sub_283         proc near               ; CODE XREF: seg000:019D p                                                          
                push    cx                                                                                                  
                push    dx                                                                                                  
                dec     dx                                                                                                  
                xor     bh, bh                                                                                              
                mov     al, byte ptr ds:aMouseIsNotInst+1Ah                                                                 
                mov     ah, 0Ch                                                                                             
                int     10h             ; - VIDEO - WRITE DOT ON SCREEN                                                     
                                        ; AL = color of dot, BH = display page                                              
                                        ; CX = column, DX = row                                                             
                pop     dx                                                                                                  
                pop     cx                                                                                                  
                retn                                                                                                        
sub_283         endp                                                                                                        
                                                                                                                            
                                                                                                                            
; =============== S U B R O U T I N E =======================================                                               
                                                                                                                            
                                                                                                                            
sub_292         proc near               ; CODE XREF: seg000:016B p                                                          
                                        ; sub_1BE+11 p                                                                      
                push    bx                                                                                                  
                push    cx                                                                                                  
                push    dx                                                                                                  
                push    si                                                                                                  
                push    di                                                                                                  
                push    bp                                                                                                  
                mov     ds:word_412, cx                                                                                     
                mov     di, 8000h                                                                                           
                mov     bp, 10h                                                                                             
                mov     dx, dx                                                                                              
                                                                                                                            
loc_2A4:                                ; CODE XREF: sub_292+27 j                                                           
                mov     si, ds:word_412                                                                                     
                mov     cx, 10h                                                                                             
                                                                                                                            
loc_2AB:                                ; CODE XREF: sub_292+23 j                                                           
                push    cx                                                                                                  
                mov     cx, si                                                                                              
                mov     ah, 0Dh                                                                                             
                int     10h             ; - VIDEO - READ DOT ON SCREEN                                                      
                                        ; BH = display page, CX = column, DX = row                                          
                stosb                                                                                                       
                inc     si                                                                                                  
                pop     cx                                                                                                  
                loop    loc_2AB                                                                                             
                inc     dx                                                                                                  
                dec     bp                                                                                                  
                jnz     short loc_2A4                                                                                       
                pop     bp                                                                                                  
                pop     di                                                                                                  
                pop     si                                                                                                  
                pop     dx                                                                                                  
                pop     cx                                                                                                  
                pop     bx                                                                                                  
                retn                                                                                                        
sub_292         endp                                                                                                        
                                                                                                                            
                                                                                                                            
; =============== S U B R O U T I N E =======================================                                               
                                                                                                                            
                                                                                                                            
sub_2C2         proc near               ; CODE XREF: sub_1BE:loc_1CC p                                                      
                                        ; sub_271 p                                                                         
                push    bx                                                                                                  
                push    cx                                                                                                  
                push    dx                                                                                                  
                push    si                                                                                                  
                push    di                                                                                                  
                push    bp                                                                                                  
                mov     di, 8000h                                                                                           
                mov     bp, 10h                                                                                             
                mov     dx, ds:word_3F0                                                                                     
                                                                                                                            
loc_2D2:                                ; CODE XREF: sub_2C2+27 j                                                           
                mov     si, ds:word_3EE                                                                                     
                mov     cx, 10h                                                                                             
                                                                                                                            
loc_2D9:                                ; CODE XREF: sub_2C2+23 j                                                           
                push    cx                                                                                                  
                mov     cx, si                                                                                              
                mov     al, [di]                                                                                            
                mov     ah, 0Ch                                                                                             
                int     10h             ; - VIDEO - WRITE DOT ON SCREEN                                                     
                                        ; AL = color of dot, BH = display page                                              
                                        ; CX = column, DX = row                                                             
                inc     di                                                                                                  
                inc     si                                                                                                  
                pop     cx                                                                                                  
                loop    loc_2D9                                                                                             
                inc     dx                                                                                                  
                dec     bp                                                                                                  
                jnz     short loc_2D2                                                                                       
                pop     bp                                                                                                  
                pop     di                                                                                                  
                pop     si                                                                                                  
                pop     dx                                                                                                  
                pop     cx                                                                                                  
                pop     bx                                                                                                  
                retn                                                                                                        
sub_2C2         endp                                                                                                        
                                                                                                                            
                                                                                                                            
; =============== S U B R O U T I N E =======================================                                               
                                                                                                                            
                                                                                                                            
sub_2F2         proc near               ; CODE XREF: seg000:0159 p                                                          
                                        ; sub_271+E p                                                                       
                push    bx                                                                                                  
                push    cx                                                                                                  
                push    dx                                                                                                  
                push    si                                                                                                  
                mov     cx, 190h                                                                                            
                mov     dx, 5                                                                                               
                lea     si, unk_39D                                                                                         
                call    sub_1E4                                                                                             
                pop     si                                                                                                  
                pop     dx                                                                                                  
                pop     cx                                                                                                  
                pop     bx                                                                                                  
                retn                                                                                                        
sub_2F2         endp                                                                                                        
                                                                                                                            
                                                                                                                            
; =============== S U B R O U T I N E =======================================                                               
                                                                                                                            
                                                                                                                            
sub_308         proc near               ; CODE XREF: seg000:0154 p                                                          
                mov     ax, 0A000h                                                                                          
                mov     es, ax                                                                                              
                assume es:nothing                                                                                           
                mov     bp, 141h                                                                                            
                mov     cx, 10h                                                                                             
                mov     ah, 1                                                                                               
                                                                                                                            
loc_315:                                ; CODE XREF: sub_308+32 j                                                           
                mov     bl, ah                                                                                              
                push    cx                                                                                                  
                mov     dx, 3CEh                                                                                            
                xor     al, al                                                                                              
                out     dx, al          ; EGA: graph 1 and 2 addr reg:                                                      
                                        ; set/reset.                                                                        
                                        ; Data bits 0-3 select planes for write mode 00                                     
                inc     ax                                                                                                  
                not     ah                                                                                                  
                out     dx, ax          ; EGA: graph 1 and 2 addr reg:                                                      
                                        ; unknown register                                                                  
                lea     si, unk_362                                                                                         
                mov     di, bp                                                                                              
                mov     cx, 10h                                                                                             
                                                                                                                            
loc_32B:                                ; CODE XREF: sub_308+28 j                                                           
                movsb                                                                                                       
                movsb                                                                                                       
                add     di, 4Eh ; 'N'                                                                                       
                loop    loc_32B                                                                                             
                add     bp, 3                                                                                               
                mov     ah, bl                                                                                              
                inc     ah                                                                                                  
                pop     cx                                                                                                  
                loop    loc_315                                                                                             
                call    sub_352                                                                                             
                mov     al, 0FFh                                                                                            
                mov     di, 780h                                                                                            
                mov     cx, 50h ; 'P'                                                                                       
                rep stosb                                                                                                   
                mov     cx, 50h ; 'P'                                                                                       
                mov     di, 9010h                                                                                           
                rep stosb                                                                                                   
                retn                                                                                                        
sub_308         endp                                                                                                        
                                                                                                                            
                                                                                                                            
; =============== S U B R O U T I N E =======================================                                               
                                                                                                                            
                                                                                                                            
sub_352         proc near               ; CODE XREF: sub_308+34p                                                           
                push    ax                                                                                                  
                push    dx                                                                                                  
                mov     ax, 700h                                                                                            
                mov     dx, 3CEh                                                                                            
                out     dx, ax          ; EGA: graph 1 and 2 addr reg:                                                      
                                        ; unknown register                                                                  
                inc     ax                                                                                                  
                not     ah                                                                                                  
                out     dx, ax          ; EGA: graph 1 and 2 addr reg:                                                      
                                        ; unknown register                                                                  
                pop     dx                                                                                                  
                pop     ax                                                                                                  
                retn                                                                                                        
sub_352         endp                                                                                                        
                                                                                                                            
; ---------------------------------------------------------------------------                                               
unk_362         db 0FFh                 ; DATA XREF: sub_308+1Ao                                                           
                db 0FFh                                                                                   
                db  80h ;                                                                             
                db    1                                                                                      
                db 0BFh ; ?
                db 0FFh                                                                                                     
                db 0BFh ; ?                                                                                               
                db 0FFh                                                                                                     
                db 0BFh ; ?                                                                                                 
                db 0FFh                                                                                                     
                db 0BFh ; ?                                                                                                 
                db 0FFh                                                                                                     
                db 0BFh ; ?                                                                                                
                db 0FFh                                                                                                     
                db 0BFh ; ?                                                                                                
                db 0FFh                                                                                                     
                db 0BFh ; ?                                                                                                
                db 0FFh                                                                                                     
                db 0BFh ; ?                                                                                                
                db 0FFh                                                                                                     
                db 0BFh ; ?                                                                                                 
                db 0FFh                                                                                                     
                db 0BFh ; ?                                                                                                
                db 0FFh                                                                                                     
                db 0BFh ; ?                                                                                                 
                db 0FFh                                                                                                     
                db 0BFh ; ?                                                                                                
                db 0FFh                                                                                                     
                db 0BFh ; ?                                                                                                
                db 0FFh                                                                                                     
                db 0FFh                                                                                                     
                db 0FFh                                                                                                     
; ---------------------------------------------------------------------------   
; 解密代码部分:                                            
                sti                                                                                                         
                push    cs                                                                                                  
                pop     es                                                                                                  
                assume es:nothing                                                                                           
                cld                                                                                                         
                mov     si, 98h ; '?                                                                                        
                shl     si, 1           ; si=130h                                                                                   
                mov     di, si          ; 解密后还原在相同的位置                                                                                    
                mov     cx, 120h                                                                                            
                                                                                                                            
loc_390:                                ; CODE XREF: seg000:0395j                                                          
                lodsw                                                                                                       
                xor     ax, 0B0C1h      ; 这个是解密所需的指纹                                                                                    
                stosw                                                                                                       
                loop    loc_390                                                                                             
                cli                                                                                                         
                iret                                                                                                        
; ---------------------------------------------------------------------------                                               
word_399        dw 10B8h                ; DATA XREF: seg000:0118w                                                          
                                        ; seg000:01A7r                                                                     
word_39B        dw 0A7h                 ; DATA XREF: seg000:0109w                                                          
                                        ; seg000:0124w ...                                                                 
unk_39D         db  1Eh                 ; DATA XREF: sub_2F2+Ao                                                            
                db    3                                                                                                     
                db  21h ; !                                                                                                 
                db  83h ; ?                                                                                                 
                db  44h ; D                                                                                                 
                db  87h ; ?                                                                                                 
                db  4Eh ; N                                                                                                 
                db  47h ; G                                                                                                 
                db  8Ch ; ?                                                                                                 
                db  4Eh ; N                                                                                                 
                db 0A0h ; ?                                                                                                
                db  38h ; 8                                                                                                 
                db 0B8h ; ?                                                                                                 
                db 0B0h ; ?                                                                                                
                db 0B1h ; ?                                                                                                
                db  68h ; h                                                                                                 
                db  91h ; ?                                                                                                 
                db 0C4h ; ?                                                                                                
                db  81h ; ?                                                                                                 
                db  44h ; D                                                                                                 
                db  98h ; ?                                                                                                 
                db  84h ; ?                                                                                                 
                db  5Ch ; \                                                                                                 
                db    4                                                                                                     
                db  49h ; I                                                                                                 
                db 0C8h ; ?                                                                                                 
                db  21h ; !                                                                                                 
                db  88h ; ?                                                                                                 
                db  38h ; 8                                                                                                 
                db  30h ; 0                                                                                                 
                db  67h ; g                                                                                                 
                db 0C0h ; ?                                                                                                 
aMouseIsNotInst db 'Mouse is NOT installed!',0Dh,0Ah                                                                        
                db  24h ; $                                                                                                 
                db    7                 ; DATA XREF: sub_1E4:loc_202r                                                      
                                        ; sub_271+Bw ...                                                                   
                db  49h ; I                                                                                                 
                db  3Ah ; :                                                                                                 
                db  30h ; 0                                                                                                 
                db  32h ; 2                                                                                                 
                db  37h ; 7                                                                                                 
                db  46h ; F                                                                                                 
                db  20h                                                                                                     
                db  2Dh ; -                                                                                                 
                db  3Ah ; :                                                                                                 
                db  30h ; 0                                                                                                 
                db  30h ; 0                                                                                                 
                db  30h ; 0                                                                                                 
                db  43h ; C                                                                                                 
                db  24h ; $                                                                                                 
                db 0E8h ; ?            ; DATA XREF: sub_252+4o                                                             
                db    3                                                                                                     
                db  64h ; d                                                                                                 
                db    0                                                                                                     
                db  0Ah                                                                                                     
                db    0                                                                                                     
                db    1                                                                                                     
                db    0                                                                                                     
word_3EE        dw 140h                 ; DATA XREF: sub_1BE+2r                                                            
                                        ; sub_1BE+14w ...                                                                  
word_3F0        dw 0F0h                 ; DATA XREF: sub_1BE+8r                                                            
                                        ; sub_1BE+18w ...                                                                  
unk_3F2         db  60h ; `             ; DATA XREF: sub_1BE+1Co                                                           
                db    0                                                                                                     
                db  50h ; P                                                                                                 
                db    0                                                                                                     
                db  28h ; (                                                                                                 
                db    0                                                                                                     
                db  14h                                                                                                     
                db    0                                                                                                     
                db  3Eh ; >                                                                                                 
                db    0                                                                                                     
                db  21h ; !                                                                                                 
                db    0                                                                                                     
                db  7Ch ; |                                                                                                 
                db  80h ;                                                                                                  
                db  54h ; T                                                                                                 
                db  40h ; @                                                                                                 
                db  6Ah ; j                                                                                                 
                db  40h ; @                                                                                                 
                db  54h ; T                                                                                                 
                db  20h                                                                                                     
                db  28h ; (                                                                                                 
                db  18h                                                                                                     
                db  10h                                                                                                     
                db  34h ; 4                                                                                                 
                db  0Eh                                                                                                     
                db  6Ah ; j                                                                                                 
                db    1                                                                                                     
                db 0D4h ; ?                                                                                                 
                db    0                                                                                                     
                db 0A8h ; ?                                                                                                 
                db    0                                                                                                     
                db 0F0h ; ?                                                                                                 
word_412        dw 0                    ; DATA XREF: seg000:0162w                                                          
                                        ; sub_292+6w ...                                                                   
                db    0                                                                                                     
                db    0                                                                                                     
                db  29h ; )                                                                                                 
                db  3Ch ; <                                                                                                 
                db    0                                                                                                     
                db  74h ; t                                                                                                 
                db  25h ; %                                                                                                 
                db  26h ;                                                                                                  
                db  80h ;                                                                                                  
                db  7Dh ; }                                                                                                 
                db    2                                                                                                     
                db    2                                                                                                     
seg000          ends                                                                                                        
                                                                                                                            
                                                                                                                            
                end start 