
rq      struc           ;λַ---��-----�x-------
len     db      ?       ; 00 device driver request header �L��
subunit db      ?       ; 01 subunit��0
command db      ?       ; 02 ����a
status  dw      ?       ; 03 ���ؠ�B
reverse dq      ?       ; 05 ������0
address db      ?       ; 0D ý�w������
trn_off dw      ?       ; 0E �����Y��λַ��ƫ��λַ
trn_seg dw      ?       ;    �^��λַ
len_tr  dw      ?       ; 12 �����Y���L��
rq      ends

rq1     struc           ;λַ---��-----�x-------
len1    db      ?       ; 00 device driver request header �L��
subuni1 db      ?       ; 01 subunit��0
comman1 db      ?       ; 02 ����a
status1 dw      ?       ; 03 ���ؠ�B
revers1 dq      ?       ; 05 ������0
addres1 db      ?       ; 0D λַģʽ
ply_sec dd      ?       ; 0E �_ʼ����Ņ^
ply_tim dd      ?       ; 12 �����r�g
rq1     ends

        .286
;***************************************
cd_data segment
;��һ�О���ÿһ��܉����ʼ�Ņ^��̖��ÿһ��܉�� 4 ��λԪ�M
track   db      100 dup ( 4 dup(0) )    ;028 ��ʼ�Ņ^�Y��

;ӍϢ��
mes1    db      '�]�й���C$'
mes2    db      '�@Ƭ������� '
mes2_no db      '00 �����ӣ���Ҫ �� �ڎ��ף�$'

;�õ����Ƭ�Y������� device driver request header
disk_info       rq      <13h,0,3,?,0,0,offset dsk_ifo,seg cd_data,7>
dsk_ifo         db      0ah,?
total_tracks    db      ?       ;038 ��܉����
ending_sector   dd      ?

;�õ���܉�Y������� device driver request header
track_info      rq      <13h,0,3,?,0,0,offset trk_ifo,seg cd_data,7>
trk_ifo         db      0bh
track_no        db      1       ;044 ��܉��̖
track_start     dd      ?       ;045 ԓ��܉֮��ʼλ�ã�MM:SS:FF
track_ctl       db      ?

;������܉����� device driver request header
play            rq1     <15h,0,84h,?,0,0,?,?>

;������һЩ׃��
cd_driver       dw      ?       ;052 CDROM�C��̖
cd_data ends
;***************************************
stack   segment stack           ;055 �ѯB�^��
        db      20 dup ('my stack')
stack   ends
;***************************************
code    segment
        assume  cs:code,ds:cd_data
;---------------------------------------
start:  push    ds              ;062 ��ʽ�a�_ʼ
        sub     ax,ax
        push    ax
        mov     ax,cd_data
        mov     ds,ax
        mov     es,ax

        sub     bx,bx
        mov     ax,1500h
        int     2fh             ;071 �õ���һ̨CDROM�C��̖
        or      bx,bx
        jnz     play0
        mov     dx,offset mes1  ;074 �]��CDROM�C
        mov     ah,9
        int     21h
exit:   mov     ax,4c01h        ;077 �Y����ʽ
        int     21h

play0:  mov     cd_driver,cx    ;080 �õ����Ƭ�Y��
        mov     bx,offset disk_info
        mov     ax,1510h        ;082 �ڴ˳�ʽ������Ҫ���YӍ�ǿ�������
        int     2fh             ;083 �������������� total_tracks

        mov     al,total_tracks ;085 ������������ ASCII �a��
        call    al2dec          ;086 ��ʽ���� mes2 �ִ��Y

;���µĳ�ʽĿ���ǵõ�ÿһ��܉����ʼ�Ņ^��̖
        mov     dl,0
        mov     di,offset track ;090 ÿһ��܉����ʼ�Ņ^��̖��� track �Y
play1:  mov     cx,cd_driver
        mov     bx,offset track_info
        mov     ax,1510h
        int     2fh             ;094 ���������@һ��܉����ʼ�r�g���
        cld                     ;095 track_start �_ʼ�� 4 ��λԪ�M
;����ʼ�r�g�D�Q�ɴŅ^��̖���Ņ^��̖=��*60*75+��*75+��-150���Ҟ� 32 λԪ
        mov     si,offset track_start
        lodsb                   ;098 AL=��
        cbw
        mov     bx,ax           ;100 BX=��
        mov     cl,75
        lodsb                   ;102 AL=��
        mul     cl              ;103 AX=��*75
        push    dx
        add     bx,ax           ;105 BX=��*75+��
        mov     cx,60*75
        sub     bx,150          ;107 BX=��*75+��-150
        lodsw
        sub     dx,dx           ;109 DX:AX=��
        mul     cx              ;110 DX:AX=60*75*��
        add     ax,bx
        adc     dx,0            ;112 DX:AX=60*75*��+��*75+��-150
        mov     [di],ax         ;113 ���� track ���׃���Y
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

        mov     dx,offset mes2  ;125 ӡ������܉��
        mov     ah,9
        int     21h
play2:  call    key_in          ;128 ݔ��Ҫ �ĸ������K��� BX
        cmp     bl,total_tracks ;129 �z���Ƿ��ڿ���܉���Ĺ�����
        jbe     play4
        mov     cx,2            ;131 ���ڹ����ȣ�������ǰ�Θ���λ�ɸ�
play3:  mov     dl,08h
        mov     ah,2
        int     21h
        loop    play3
        jmp     play2
                                ;137 ��Ҫ�����܉����һ��܉����ʼ�Ņ^����
play4:  dec     bx              ;138 device driver request header �Y
        mov     di,offset play.ply_sec
        mov     cx,4
        shl     bx,2
        mov     si,offset track
        add     si,bx           ;143 ȡ��Ҫ������܉��ʼ�Ņ^λַ
        rep     movsw

;Ҫ������܉�ĴŅ^�L�ȵ����һ��܉����ʼ�Ņ^�pҪ������܉��ʼ�Ņ^
        mov     di,offset play.ply_tim
        mov     si,offset play.ply_sec
        mov     ax,[di]
        mov     bx,2
        sub     ax,[si]
        mov     [di],ax
        mov     ax,[di+bx]
        sbb     ax,[si+bx]
        mov     [di+bx],ax
        mov     bx,offset play  ;156 ������܉
        mov     cx,cd_driver
        mov     ax,1510h
        int     2fh

        mov     ax,4c00h        ;161 �Y����ʽ
        int     21h
;---------------------------------------
;�ѿ���܉��׃�� ASCII �a�K��� mes2_no ̎
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
;ݔ��Ҫ�������܉��̖�����ؕr BX=Ҫ�������܉��̖
key_in  proc    near
        sub     bx,bx
        mov     cx,0a00h
key0:   mov     ah,0
        int     16h     ;181 �I�P���ճ�ʽ
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
        mul     ch      ;192 ��ݔ��ʮλ���ʑ��ѵ�һ��ݔ��Ĕ�
        add     bx,ax   ;193 ���� 10���ټ��ϬF��ݔ��Ă�λ��
        inc     cl
        cmp     cl,2
        jne     key0
        ret
key_in  endp
;---------------------------------------
code    ends
;***************************************
        end     start   ;202 ԭʼ��ʽ�Y��