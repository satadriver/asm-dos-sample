;        CLOCK program
;        by LuoYunBin Apr,1993

DISPLAY_COLOR    EQU    0EH    ;init color

CODE        SEGMENT
            ASSUME     CS:CODE,DS:CODE
            ORG     0C0H

CLOCK        DB    0
MINU         DB    0
SECOND       DB    0
BEEP_TIME    DB    0
LAST_SEC     DB    0
OFF1C        DW    ?
SEG1C        DW    ?
DISPLAY_DATA    DB    0,0,':',0,0,':',0,0

        ORG   100H
start:
        jmp   install
int1c:
        pushf
        push   es
        push   ds
        push   ax

        push   cs
        pop    ds

        xor    ax,ax
        mov    es,ax
        mov    al,es:[0449h]         ;get display mode

        mov    word ptr v_buffer-2,0b800h
        mov    byte ptr clock_place-2,72*2

        cmp    al,3               ;the clock may display
        jbe    text_color         ;at mode 0,1,2,3,7
        cmp    al,7
        jz     text_mon
        mov    word ptr v_buffer-2,es
        jmp    short calu
text_color:
        cmp    al,1
        ja     calu
        mov    byte ptr clock_place-2,32*2
        jmp    short calu
text_mon:
        mov    word ptr v_buffer-2,0b000h
calu:
        push    bx
        push    cx
        push    dx
        push    di
        push    si

        mov    cx,es:[046eh]         ;get clock timers
        mov    dx,es:[046ch]

        mov    ax,cx             ;counter=cx:dx
        mov    bx,dx
        shl    dx,1
        rcl    cx,1
        shl    dx,1
        rcl    cx,1

        add    dx,bx
        adc    ax,cx
        xchg   dx,ax             ;dx:ax=cx:dx*5

        mov    cx,0e90bh
        div    cx             ;divide by E90B*E90B

        mov    bx,ax
        xor    ax,ax
        div    cx

        mov    dx,bx
        mov    cx,00c8h
        div    cx

        cmp    dl,100
        jb     clock_0

        sub    dl,100
clock_0:
        cmc
        rcl    ax,1
        mov    dl,0
        rcl    dx,1
        mov    cl,60
        div    cx

        mov    second,dl
        div    cl

        mov    minu,ah
        mov    clock,al
code1:
        jmp    short code2         ;when speaker on here is NOP

        dec    beep_time         ;dec alarm time
        jz     turn_sp_off

        cmp    last_sec,1         ;every 10 min's beep
        jz     dat0
        
        cmp    last_sec,59         ;59 min 59 sec's beep
        jnz    dat1
        
        mov    cl,6
        mov    ch,3
        mov    bx,800h
        jmp    short dat2
dat0:
        mov    cl,3
        mov    ch,2
        mov    bx,200h
dat2:
        mov    al,beep_time
        xor    ah,ah
        div    cl
        
        cmp    ah,ch
        jz     short speak_on1

        or     ah,ah             ;after 1 count off
        jz     dat1

        in     al,61h
        and    al,0fch
        out    61h,al
dat1:
        jmp    short disp_clock
turn_sp_off:
        in     al,61h
        and    al,0fch
        out    61h,al             ;turn off the speaker

        mov    word ptr code1,-1     ;move code1 (jmp code2)
code2:
        mov    al,ah             ;al is minute
        mov    ah,dl             ;ah is second

        or     ah,ah
        jz     is_sec0

        cmp    ah,1
        jz     is_sec1
        
        cmp    al,59             ;59 min
        jnz    disp_clock

        cmp    ah,59
        jnz    disp_clock

        mov    beep_time,15
        mov    bx,800h
        jmp    short speak_on
is_sec1:
        mov    last_sec,0ffh
        jmp    short disp_clock
is_sec0:
        or     al,al
        jz     is_min0

        mov    cl,10         ;if is every 10 min
        div    cl
        or     ah,ah
        jnz    disp_clock
        
        mov    cl,3
        mul    cl
        dec    al
        mov    beep_time,al
        inc    ah
        mov    bx,200h
        jmp    short speak_on
is_min0:
        mov    beep_time,18
        mov    bx,400h
speak_on:
        cmp    last_sec,ah         ;then not oprate
        mov    last_sec,ah
        jz     disp_clock
speak_on1:
        mov    al,0b6h
        out    43h,al
        mov    ax,bx
        out    42h,al
        mov    al,ah
        out    42h,al

        in     al,61h             ;turn on the speaker
        or     al,3
        out    61h,al
        mov    word ptr code1,9090h     ;move code1 (NOP)
disp_clock:
        mov    al,clock
        mov    si,offset display_data
        push   si
        call   hex_to_asc         ;turn HEX to ASC II code
        mov    al,minu
        call   hex_to_asc
        mov    al,second
        call   hex_to_asc
        pop    si
        cmp    byte ptr [si],'0'
        jnz    mov_data

        mov    byte ptr [si],' '
mov_data:
        mov    ax,0b800h         ;buffer    segment
v_buffer:
        or     ax,ax
        jz     i1cquit
        mov    es,ax
        mov    di,72*2
clock_place:
        mov    cx,8
        cld
        mov    ah,display_color     ;the color is yellow
code3:
        jmp    short is_vga

        mov    dx,3dah
m_loop:
        in     al,dx
        test   al,8
        jnz    n3

        test   al,1
        jnz    m_loop
n2:
        in     al,dx
        test   al,1
        jz     n2
n3:
        lodsb
        stosw
        loop    m_loop
        jmp     short i1cquit
is_vga:
        lodsb
        stosw
        loop    is_vga
i1cquit:
        pop    si
        pop    di
        pop    dx
        pop    cx
        pop    bx
        pop    ax
        pop    ds
        pop    es
        popf
        iret

HEX_TO_ASC    PROC    NEAR

        cbw
        mov    cl,10
        div    cl

        add    ax,'00'
        mov    ds:[si],ax

        add    si,3

        ret

HEX_TO_ASC    ENDP

;    new int 9 keyboard program
;    Ctrl-Alt-U to unload
;        C to change clock color
;        B to change clock background color

int9:
        pushf
        push   ax
        push   ds
        xor    ax,ax
        mov    ds,ax
        mov    al,ds:[0417h]
        and    al,0ch
        cmp    al,0ch
        jz     ctrl_alt_down         ;if Ctrl-Alt press down
to_old9:
        pop    ds
        pop    ax
        popf
        DB    0EAH
OFF9        DW    ?
SEG9        DW    ?

ctrl_alt_down:
        in     al,60h
        cmp    al,80h         ;if release key
        jae    to_old9
        cmp    al,24         ;o key
        jz     right_key
        cmp    al,46         ;c key
        jz     right_key
        cmp    al,22         ;u key
        jz     right_key
        cmp    al,48         ;b key
        jnz    to_old9
right_key:
        push   ax
        in     al,61h
        mov    ah,al
        or     al,80h
        out    61h,al
        xchg   ah,al
        out    61h,al             ;answer the keyboard
        pop    ax

        cmp    al,22             ;u key
        jz     un_load

        push   cs
        pop    ds
        cmp    al,24             ;o key
        jz     key_o
        cmp    al,46             ;c key
        jz     key_c

        mov    al,byte ptr code3-1     ;is "b" key:change back color
        mov    ah,al
        and    al,0f0h
        add    al,10h
        cmp    al,80h
        jnz    bc_1
        xor    al,al
bc_1:
        and    ah,0fh
        or     al,ah
        jmp    short chg_color
key_c:
        mov    al,byte ptr code3-1
        mov    ah,al
        and    al,0fh
        inc    al
        cmp    al,10h
        jnz    fc_1
        xor    al,al
fc_1:
        and    ah,0f0h
        or     al,ah
chg_color:
        mov    byte ptr code3-1,al
        jmp    short key_iret
un_load:
        push   es
        les    ax,dword ptr cs:off9
        mov    ds:[0024h],ax
        mov    ds:[0026h],es
        les    ax,dword ptr cs:off1c
        mov    ds:[0070h],ax
        mov    ds:[0072h],es
        push   cs
        pop    ax
        dec    ax
        mov    ds,ax
        mov    word ptr ds:[0001],0
        pop    es
        jmp    short key_iret
key_o:
        cmp    byte ptr int1c,9ch     ;code of PUSHF
        jz     turn_off

        mov    byte ptr int1c,9ch
        jmp    short key_iret
turn_off:
        mov    byte ptr int1c,0cfh     ;code of IRET
key_iret:
        mov    al,20h
        out    20h,al             ;send EOI command
        pop    ds
        pop    ax
        popf
        iret
install:
        mov    byte ptr display_data+2,':'
        mov    byte ptr display_data+5,':'
        mov    ax,word ptr code1
        mov    word ptr code2-2,ax
        mov    si,81h
        mov    bp,offset int9         ;bp is str point
        cld
re_load:
        lodsb
        cmp    al,' '
        jz     re_load
        cmp    al,0dh
        jz     com_line_end
        cmp    al,'?'
        jz     help
        or     al,20h
        cmp    al,'u'
        jz     no_key_int
        cmp    al,'h'
        jnz    re_load
help:
        mov    dx,offset d_help
        mov    ah,9
        int    21h
        int    20h
com_line_end:
        clc
        jmp    short have_key_int
no_key_int:
        stc
have_key_int:
        pushf
        mov    ax,351ch
        int    21h
        mov    off1c,bx
        mov    seg1c,es
        cmp    bx,offset int1c
        jnz    not_loaded

        mov    dx,offset d_has
        mov    ah,9
        int    21h
        jmp    quit
not_loaded:
        popf
        jc     skip_key
        mov    ax,3509h
        int    21h

        mov    off9,bx
        mov    seg9,es
        mov    dx,offset int9
        mov    ax,2509h
        int    21h             ;set keyboard intrupter vector
        mov    bp,offset install
skip_key:
        mov    ax,251ch
        mov    dx,offset int1c
        int    21h             ;set clock interupter vector

        mov    ah,0fh             ;if is MDA,color=09
        int    10h
        cmp    al,07h
        jnz    is_color
        mov    byte ptr ds:code3-1,09h
is_color:
        mov    ah,1bh             ;if is VGA,then not test snow
        xor    bx,bx
        push   cs
        pop    es
        mov    di,offset buffer
        int    10h
        cmp    al,1bh
        jz     vga_card
        mov    word ptr ds:code3,9090h
vga_card:
        mov    bx,bp
        add    bx,000fh
        shr    bx,1
        shr    bx,1
        shr    bx,1
        shr    bx,1
        mov    ah,4ah
        int    21h

        push   cs
        pop    ax
        dec    ax
        mov    ds,ax
        mov    word ptr ds:[0001h],0008h
quit:
        int    20h

D_help  db    '<<< CLOCK >>> Version 1.4',0dh,0ah
        db    '(c)1995 By Luo Yun Bin of HuangYan post office.',0dh,0ah
        db     'phone:0576-4114689',0dh,0ah
        db    'BP: 0576-126 call 117654',0dh,0ah
        db    'Usage:',0dh,0ah
        db    9,'Ctrl-Alt-U: unload from memory.',0dh,0ah
        db    9,'Ctrl-Alt-C: change color.',0dh,0ah
        db    9,'Ctrl-Alt-B: change backgroud color.',0dh,0ah
        db    9,'Ctrl-Alt-O: turn on/off.',0dh,0ah
        db    '$'

D_HAS   db    'CLOCK has been installed!',0dh,0ah,'$'

BUFFER  EQU    THIS BYTE

CODE    ENDS
        END    start