;       CD-ROM eject/load progrm
;       Ver 1.20 ------ Jan 6,1996

CODE		SEGMENT
		ASSUME	CS:CODE,DS:CODE
		ORG	100H
START:
		jmp	install
COPYRIGHT	DB	'CD-ROM drive eject/close prg. V1.20',0dh,0ah
		DB	'Copyright (c) by Luo Yun Bin, Jan 6,1996',0dh,0ah
		DB	'http://asm.yeah.net,Email: luoyunbin@telekbird.com.cn'
		DB	0dh,0ah,0ah,24h
D_HELP		DB	'Usage: EJ [drive:] [/?|/L|/U]',0dh,0ah
		DB	'       /?  -------- Display this help',0dh,0ah
		DB	'       /L  -------- Lock door',0dh,0ah
		DB	'       /U  -------- Unlock door',0dh,0ah,24h
MESS_WAIT	DB	'[ENTER] to close, [Esc] to quit.',24h
MESS_ESC	DB	'tray keep open...',0dh,0ah,24h
MESS_NO_CD	DB	'MSCDEX not installed!',0dh,0ah,24h
MESS_STATUS	DB	'There are '
DRV_NUMBER	DB	'0 CD-ROM drive(s) starting at '
DRV		DB	'A:',0dh,0ah,24h
MESS_DRV	DB	0dh,'                                  ',0dh
		DB	'drive '
DRV1		DB	'A: ',24h
MESS_EJECT	DB	'ejecting....',24h
MESS_CLOSE	DB	'closing ....',24h
MESS_LOCK	DB	'locking ....',24h
MESS_UNLOCK	DB	'unlocking...',24h
MESS_DONE	DB	' Done!',0dh,0ah,24h
CD_DRV		DW	?
FLAG		DB	?
;======================================================
REQ_HEAD	DB	1ah,0		;IOCTL input
REQ_CMD		DB	3
REQ_ERR		DW	?
		DB	9 dup (0)
BUF_OFF		DW	buffer
BUF_SEG		DW	?
BUF_LEN		DW	?
		DB	6 dup (0)
;======================================================
BUFFER		DB	5 dup (0)	;Max used 5 bytes
CMD_LINE	PROC
		mov	si,81h		;处理命令行参数
		mov	di,80h
		cld
cmd_reload:
		lodsb
		cmp	al,0dh
		jz	conv_end	;将命令行小写字母换成大写
		cmp	al,'a'
		jb	conv_ok
		cmp	al,'z'
		ja	conv_ok
		sub	al,20h
conv_ok:
		stosb
		jmp	short cmd_reload
conv_end:
		xor	al,al
		stosb
		
		mov	si,80h
cmd_reload1:
		lodsb
		or	al,al
		jz	cmd_end
		cmp	al,'/'
		jz	cmd_switch
		cmp	al,':'
		jnz	cmd_reload1
		mov	al,[si-2]
		cmp	al,'A'
		jb	cmd_end
		cmp	al,'Z'
		ja	cmd_end
		sub	al,'A'
		xor	ah,ah
		mov	cd_drv,ax
		jmp	short cmd_reload1
cmd_switch:
		lodsb
		cmp	al,'?'
		jz	cmd_help
		cmp	al,'L'
		jz	cmd_lock
		cmp	al,'U'
		jz	cmd_unlock
		jmp	short cmd_reload1
cmd_end:
		ret
cmd_help:
		mov	dx,offset d_help
		call	print
		int	20h
cmd_lock:
		or	flag,1
		jmp	short cmd_reload1
cmd_unlock:
		or	flag,2
		jmp	short cmd_reload1
CMD_LINE	ENDP
CD_INT		PROC
		mov	ax,1510h
		mov	buf_seg,cs
		mov	bx,offset req_head
		mov     cx,cd_drv
		int     2fh
		
		ret
CD_INT		ENDP
GET_STATUS	PROC
		mov     buffer,6
		mov	buf_len,5
		mov	req_cmd,3
		call    cd_int
		ret
GET_STATUS	ENDP
EJECT_DISK	PROC
		mov	dx,offset mess_drv
		call	print
		mov	dx,offset mess_eject
		call	print
		mov	buffer,0
		mov	buf_len,1
		mov	req_cmd,0ch
		call    cd_int
		mov     dx,offset mess_done
		call    print
		ret
EJECT_DISK      ENDP
CLOSE_TRAY      PROC
		mov     dx,offset mess_drv
		call    print
		mov     dx,offset mess_close
		call    print
		mov	buffer,5
		mov	buf_len,1
		mov	req_cmd,0ch
		call	cd_int
		mov     dx,offset mess_done
		call    print
		ret
CLOSE_TRAY      ENDP
LOCK_DOOR	PROC
		mov	dx,offset mess_drv
		call	print
		mov	dx,offset mess_lock
		call	print
		
		mov	word ptr buffer,0101h
		mov	buf_len,2
		mov	req_cmd,0ch
		call	cd_int
		
		mov	dx,offset mess_done
		call	print
		ret
LOCK_DOOR	ENDP
UNLOCK_DOOR	PROC
		mov	dx,offset mess_drv
		call	print
		mov	dx,offset mess_unlock
		call	print
		
		mov	word ptr buffer,0001h
		mov	buf_len,2
		mov	req_cmd,0ch
		call	cd_int
		
		mov	dx,offset mess_done
		call	print
		ret
UNLOCK_DOOR	ENDP
CHECK_CDROM     PROC
		mov     ax,1500h
		xor     bx,bx
		int     2fh
		or      bx,bx		;BX = CD-ROM numbers
		jnz     mscdex_installed
		mov     dx,offset mess_no_cd
		call    print
		int     20h
mscdex_installed:
		mov     bp,cx
		xor     bh,bh
		add     bp,bx
		dec     bp
		cmp     cd_drv,cx
		jb      re_set
		cmp     cd_drv,bp
		jbe     par_ok
re_set:
		mov     cd_drv,cx
par_ok:
		add     drv_number,bl
		add     drv,cl
		mov     cx,cd_drv
		add     drv1,cl
		mov     dx,offset mess_status
		call    print
		ret
CHECK_CDROM     ENDP
PRINT		PROC
		mov     ah,9
		int     21h
		ret
PRINT		ENDP
install:
		mov     dx,offset copyright
		call    print
		call	cmd_line
		call    check_cdrom		;检测 CD-ROM 状态
		test	flag,1			;如果 /L 参数则 Lock_door
		jz	ins1
		call	lock_door
		int	20h
ins1:
		test	flag,2			;如果 /U 参数则 unlock_door
		jz	ins2
		call	unlock_door
		int	20h
ins2:
		call    get_status
		test	word ptr buffer+1,1	;如果现在在出盒状态则转入盒
		jnz	close_it
		call    eject_disk		;打开 CD-ROM
		mov     dx,offset mess_wait	;等待
		call    print
		xor     ax,ax
		int     16h
		cmp     al,1bh
		jz      _esc_quit
close_it:
		call    close_tray		;关闭 CD-ROM
		int     20h
_esc_quit:
		mov     dx,offset mess_drv
		call    print
		mov     dx,offset mess_esc
		call    print
		int     20h
CODE		ENDS
		END	START
