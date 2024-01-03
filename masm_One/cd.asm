
rq      struc           ;位址---意-----義-------
len     db      ?       ; 00 device driver request header 長度
subunit db      ?       ; 01 subunit，0
command db      ?       ; 02 命令碼
status  dw      ?       ; 03 返回狀態
reverse dq      ?       ; 05 保留，0
address db      ?       ; 0D 媒體描述子
trn_off dw      ?       ; 0E 傳送資料位址，偏移位址
trn_seg dw      ?       ;    區段位址
len_tr  dw      ?       ; 12 傳送資料長度
rq      ends

rq1     struc           ;位址---意-----義-------
len1    db      ?       ; 00 device driver request header 長度
subuni1 db      ?       ; 01 subunit，0
comman1 db      ?       ; 02 命令碼
status1 dw      ?       ; 03 返回狀態
revers1 dq      ?       ; 05 保留，0
addres1 db      ?       ; 0D 位址模式
ply_sec dd      ?       ; 0E 開始演奏磁區
ply_tim dd      ?       ; 12 演奏時間
rq1     ends

        .286
;***************************************
cd_data segment
;下一行為存放每一音軌的起始磁區編號，每一音軌佔 4 個位元組
track   db      100 dup ( 4 dup(0) )    ;028 起始磁區資料

;訊息：
mes1    db      '沒有光碟機$'
mes2    db      '這片光碟共有 '
mes2_no db      '00 首曲子，您要聽第聽第幾首？$'

;得到光碟片資料所需的 device driver request header
disk_info       rq      <13h,0,3,?,0,0,offset dsk_ifo,seg cd_data,7>
dsk_ifo         db      0ah,?
total_tracks    db      ?       ;038 音軌總數
ending_sector   dd      ?

;得到音軌資料所需的 device driver request header
track_info      rq      <13h,0,3,?,0,0,offset trk_ifo,seg cd_data,7>
trk_ifo         db      0bh
track_no        db      1       ;044 音軌編號
track_start     dd      ?       ;045 該音軌之起始位置，MM:SS:FF
track_ctl       db      ?

;演奏音軌所需的 device driver request header
play            rq1     <15h,0,84h,?,0,0,?,?>

;底下是一些變數
cd_driver       dw      ?       ;052 CDROM機編號
cd_data ends
;***************************************
stack   segment stack           ;055 堆疊區段
        db      20 dup ('my stack')
stack   ends
;***************************************
code    segment
        assume  cs:code,ds:cd_data
;---------------------------------------
start:  push    ds              ;062 程式碼開始
        sub     ax,ax
        push    ax
        mov     ax,cd_data
        mov     ds,ax
        mov     es,ax

        sub     bx,bx
        mov     ax,1500h
        int     2fh             ;071 得到第一台CDROM機編號
        or      bx,bx
        jnz     play0
        mov     dx,offset mes1  ;074 沒有CDROM機
        mov     ah,9
        int     21h
exit:   mov     ax,4c01h        ;077 結束程式
        int     21h

play0:  mov     cd_driver,cx    ;080 得到光碟片資料
        mov     bx,offset disk_info
        mov     ax,1510h        ;082 在此程式中最重要的資訊是總歌曲數
        int     2fh             ;083 ，呼叫完後會存於 total_tracks

        mov     al,total_tracks ;085 將總歌曲數以 ASCII 碼的
        call    al2dec          ;086 形式存入 mes2 字串裏

;底下的程式目的是得到每一音軌的起始磁區編號
        mov     dl,0
        mov     di,offset track ;090 每一音軌的起始磁區編號存於 track 裏
play1:  mov     cx,cd_driver
        mov     bx,offset track_info
        mov     ax,1510h
        int     2fh             ;094 呼叫完後這一音軌的起始時間存於
        cld                     ;095 track_start 開始的 4 個位元組
;把起始時間轉換成磁區編號，磁區編號=分*60*75+秒*75+格-150，且為 32 位元
        mov     si,offset track_start
        lodsb                   ;098 AL=格
        cbw
        mov     bx,ax           ;100 BX=格
        mov     cl,75
        lodsb                   ;102 AL=秒
        mul     cl              ;103 AX=秒*75
        push    dx
        add     bx,ax           ;105 BX=秒*75+格
        mov     cx,60*75
        sub     bx,150          ;107 BX=秒*75+格-150
        lodsw
        sub     dx,dx           ;109 DX:AX=分
        mul     cx              ;110 DX:AX=60*75*分
        add     ax,bx
        adc     dx,0            ;112 DX:AX=60*75*分+秒*75+格-150
        mov     [di],ax         ;113 存入 track 列陣變數裏
        inc     di
        inc     di
        mov     [di],dx
        inc     di
        pop     dx
        inc     di
        inc     track_no
        inc     dl
        cmp     dl,total_tracks
        jnz     play1

        mov     dx,offset mes2  ;125 印出總音軌數
        mov     ah,9
        int     21h
play2:  call    key_in          ;128 輸入要聽的歌曲，並存於 BX
        cmp     bl,total_tracks ;129 檢查是否在總音軌數的範圍內
        jbe     play4
        mov     cx,2            ;131 不在範圍內，重新數入前游標退位兩格
play3:  mov     dl,08h
        mov     ah,2
        int     21h
        loop    play3
        jmp     play2
                                ;137 將要驗奏音軌及下一音軌的起始磁區存入
play4:  dec     bx              ;138 device driver request header 裏
        mov     di,offset play.ply_sec
        mov     cx,4
        shl     bx,2
        mov     si,offset track
        add     si,bx           ;143 取得要演奏音軌起始磁區位址
        rep     movsw

;要演奏音軌的磁區長度等於下一音軌的起始磁區減要演奏音軌起始磁區
        mov     di,offset play.ply_tim
        mov     si,offset play.ply_sec
        mov     ax,[di]
        mov     bx,2
        sub     ax,[si]
        mov     [di],ax
        mov     ax,[di+bx]
        sbb     ax,[si+bx]
        mov     [di+bx],ax
        mov     bx,offset play  ;156 演奏音軌
        mov     cx,cd_driver
        mov     ax,1510h
        int     2fh

        mov     ax,4c00h        ;161 結束程式
        int     21h
;---------------------------------------
;把總音軌數變成 ASCII 碼並存於 mes2_no 處
al2dec  proc    near
        cbw
        mov     cl,10
        mov     bx,offset mes2_no
        div     cl
        add     ax,3030h
        mov     [bx],ax
        ret
al2dec  endp
;---------------------------------------
;輸入要演奏的音軌編號，返回時 BX=要演奏的音軌編號
key_in  proc    near
        sub     bx,bx
        mov     cx,0a00h
key0:   mov     ah,0
        int     16h     ;181 鍵盤服務程式
        cmp     al,'0'
        jb      key0
        cmp     al,'9'
        ja      key0
        mov     dl,al
        mov     ah,2
        int     21h
        sub     al,'0'
        cbw
        xchg    ax,bx
        mul     ch      ;192 先輸入十位數故應把第一次輸入的數
        add     bx,ax   ;193 乘以 10，再加上現在輸入的個位數
        inc     cl
        cmp     cl,2
        jne     key0
        ret
key_in  endp
;---------------------------------------
code    ends
;***************************************
        end     start   ;202 原始程式結束