
 
  ;=====================================================
  ;
  ; Program: Detect ATAPI device exist or not
  ;        If exist, change status.
  ;        If now exist, do nothing.
  ;        Not affect ATA device.
  ; Environment: Pure DOS.
  ; Author: Jim Yu (Yu Ling)
  ; Data:   2004.07.15
  ; Version: 1.0.0
  ; Mail: Jim.Yu@Mic.Com.Tw
  ;
  .MODEL SMALL
  .586P
  .STACK 1024
  .DATA
      BSY    EQU    80h
      DRQ    EQU    8
      START_STOP_UNIT    EQU    1Bh
      EJECT_TRAY    EQU    2
      CLOSE_TRAY    EQU    3
      MODE_SENCE    EQU    5Ah
      STATUS_PAGE    EQU    2Ah
      SIZE_OF_CHANNEL_ITEM    EQU    15h
      SHOW_DOOR_OPEN    DB 'Door Opened.',0dh, 0ah, '$'
      SHOW_DOOR_CLOSE    DB 'Door Closed.',0dh, 0ah, '$'
      NOT_EXIST    DB 'Not Exist.',0dh, 0ah, '$'
      SS_CHANNEL    DB '4.Secondary Slave   $'
      SM_CHANNEL    DB '3.Secondary Master  $'
      PS_CHANNEL    DB '2.Primany Slave     $'
      PM_CHANNEL    DB '1.Primany Master    $'
      PACKET_COMMAND    DB 12 DUP(0)
  .CODE
  START:
      MOV    AX, @code
      MOV    DS, AX
      PUSH    DS
  
  ;Code start
      push    seg PACKET_COMMAND
      pop    ds
      mov    cx, 4
  next_device:
      call    show_channel
  
      call    detect_atapi
  
      jne    not_atapi
  
      call    detect_device
  
      jc    @f
      call    open_device
      call    open_device             ;Some ATAPI (e.g. DVD-ROM)
      call    open_device             ;Need send command 3 times.
      mov    dx, offset SHOW_DOOR_OPEN
      jmp    show_and_reset_device
  @@:
      call    close_device
      call    close_device             ;Some ATAPI (e.g. DVD-ROM)
      call    close_device             ;Need send command 3 times.
      mov    dx, offset SHOW_DOOR_CLOSE
  show_and_reset_device:
      mov    ah, 9
      int    21h
      call    reset_device
      jmp    check_device_finish
  not_atapi:
      mov    dx, offset NOT_EXIST
      mov    ah, 9
      int    21h
  check_device_finish:
      loop    next_device
  
  ;Code end
  
      POP    DS
      MOV    AX, 4C00h
      INT    21h
  
  ;=====================================================
  ;    procedure:    show_channel
  ;    in:    cx
  ;    out:    none
  ;    destroy:none
  show_channel    proc
      push    cx
      push    seg SS_CHANNEL
      pop    ds
      mov    dl, cl
      dec    dl
      mov    ax, SIZE_OF_CHANNEL_ITEM
      mul    dl
      mov    dx, ax
      add    dx, offset SS_CHANNEL
      mov    ah, 9
      int    21h
      pop    cx
      ret
  show_channel    endp
  
  ;=====================================================
  ;    procedure:    waid_idle
  ;    in:    dx
  ;    out:    CY = time out
  ;        NC = device idle
  ;    destroy:none
  wait_idle    proc
      push    cx
      push    dx
      push    ax
      
      or    dl, 7
      mov    cx, 0ffffh
  @@:
      call    in_al_dx
      test    al, BSY
      jz    @f
      loop    @b
  @@:
      pop    ax
      pop    dx
      pop    cx
      ret
  wait_idle    endp
  
  ;=====================================================
  ;    procedure:    req_data
  ;    in:    dx
  ;    out:    CY = time out
  ;        NC = device request data
  ;    destroy:none
  req_data    proc
      push    cx
      push    dx
      push    ax
  
      or    dl, 7
      mov    cx, 0ffffh
  @@:
      call    in_al_dx
      test    al, DRQ
      jnz    @f
      loop    @b
  @@:
      pop    ax
      pop    dx
      pop    cx
      ret
  req_data    endp
  
  ;=====================================================
  ;    procedure:    set_feature
  ;    in:    ax
  ;    out:    none
  ;    destroy:ax
  ;    Set 1X1 = 0
  ;    Set 1X4 = AL
  ;    Set 1X5 = AH
  ;    Send 1X7 0A0h
  set_feature    proc
      push    dx
      push    ax
  
      inc    dl
      xor    al, al
      call    out_dx_al
  
      pop    ax
  
      add    dl, 3
      call    out_dx_al
  
      inc    dl
      xchg    ah, al
      call    out_dx_al
  
      add    dl, 2
      mov    al, 0a0h
      call    out_dx_al
  
      pop    dx
      ret
  set_feature    endp
  
  ;=====================================================
  ;    procedure:    send_packet_command
  ;    in:    dx, si
  ;    out:    none
  ;    destroy:ax, si
  send_packet_command    proc
      push    cx
  
      mov    cx, 6
  @@:
      mov    ax, ds:[si]
      call    out_dx_ax
      xor    ax, ax
      mov    ds:[si], ax
      add    si, 2
      loop    @b
  
      call    wait_idle
  
      pop    cx
      ret
  send_packet_command    endp
  
  ;=====================================================
  ;    procedure:    detect_device
  ;    in:    cx
  ;    out:    CY = Tray Open
  ;        NC = Tray Close
  ;    destroy:dx, ax, si
  ;    Detect atapi device tray
  detect_device    proc
  
      call    set_device
  
      mov    ax, 090h
      call    set_feature
  
      call    wait_idle
  
  @@:
      mov    si, offset PACKET_COMMAND
  
      mov    ax, (STATUS_PAGE * 100h) + MODE_SENCE
      mov    ds:[si], al
      mov    ds:[si+2], ah
      mov    al, 90h
      mov    ds:[si+8], al
  
      call    send_packet_command
  
      call    req_data
  
      call    in_al_dx
      call    in_al_dx
      cmp    al, 70h
      je    door_close
      stc
      ret
  door_close:
      clc
      ret
  detect_device    endp
  
  ;=====================================================
  ;    procedure:    reset_device
  ;    in:    cx
  ;    out:    none
  ;        none
  ;    destroy:dx, ax, si
  ;    Open atapi device tray
  reset_device    proc
  
      call    set_device
  
      mov    ax, 0ffffh
      call    set_feature
  
      call    wait_idle
  
      call    req_data
  
      mov    si, offset PACKET_COMMAND
  
      xor    ax, ax
      call    send_packet_command
  
      ret
  reset_device    endp
  
  ;=====================================================
  ;    procedure:    open_device
  ;    in:    cx
  ;    out:    none
  ;        none
  ;    destroy:dx, ax, si
  ;    Open atapi device tray
  open_device    proc
  
      call    set_device
  
      mov    ax, 0fffeh
      call    set_feature
  
      call    wait_idle
  
      call    req_data
  
      mov    si, offset PACKET_COMMAND
  
      mov    ax, (EJECT_TRAY * 100h) + START_STOP_UNIT
      mov    ds:[si], al
      mov    ds:[si+4], ah
  
      call    send_packet_command
  
      ret
  open_device    endp
  
  ;=====================================================
  ;    procedure:    close_device
  ;    in:    cx
  ;    out:    none
  ;        none
  ;    destroy:dx, ax, si
  ;    Close atapi device tray
  close_device    proc
  
      call    set_device
  
      xor    ax, ax
      call    set_feature
  
      call    wait_idle
  
      call    req_data
  
      mov    si, offset PACKET_COMMAND
  
      mov    ax, (CLOSE_TRAY * 100h) + START_STOP_UNIT
      mov    ds:[si], al
      mov    ds:[si+4], ah
  
      call    send_packet_command
  
      ret
  close_device    endp
  
  ;=====================================================
  ;    procedure:    detect_atapi
  ;    in:    cx
  ;    out:    PO = not atapi device
  ;        PE = is atapi device
  ;    destroy:none
  detect_atapi    proc
      push    cx
      call    set_device
  
      call    wait_idle
  
      add    dl, 7
      mov    al, 0ech
      call    out_dx_al
  
      call    wait_idle
  
      sub    dx, 3
      call    in_al_dx
      xchg    ah, al
      inc    dx
      call    in_al_dx
  
      cmp    ax, 014ebh
  
      pop    cx
      ret
  detect_atapi    endp
  
  ;=====================================================
  ;    procedure:    set_device
  ;    in:    cx
  ;    out:    none
  ;    
  ;    destroy:dx, ax
  ;
  ;    Out 1X6 = 0A0h or 0B0h
  ;    Set DX = 1X0
  ;    Set AL = 0A0h or 0B0h
  set_device    proc
      mov    dx, cx
      cmp    dx, 2
      mov    dx, 1f6h
      ja    @f
      mov    dx, 176h
  @@:
  
      mov    ax, cx
      and    al, 1
      shl    al, 4
      or    al, 0a0h
  
      call    out_dx_al
  
      and    dl, 0F0h
      ret
  set_device    endp
  
  in_al_dx    proc
      in    al, dx
      out    0edh, al
      ret
  in_al_dx    endp
  
  in_ax_dx    proc
      in    ax, dx
      out    0edh, al
      ret
  in_ax_dx    endp
  
  out_dx_al    proc
      out    dx, al
      out    0edh, al
      ret
  out_dx_al    endp
  
  out_dx_ax    proc
      out    dx, ax
      out    0edh, al
      ret
  out_dx_ax    endp
  END START 

 

