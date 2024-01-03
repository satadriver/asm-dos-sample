;by Luo Yun Bin
;http://asm.yeah.net 

;这个子程序用来检测显示卡的类型，鼠标状态等等
;在程序初始化时执行

;文中要用到的一些缓冲区请自己定义，注意大小！

flag             db        ?    ;标志位，位 7 置 1 表示安装了鼠标
vga_type        db        ?    ;显示卡类型
video_mode      db       ?     ;显示模式
vga_win1        dw        ?    ;视频窗口,暂存 VESA 的窗口状态
vga_win2        dw        ?    ;
vga_win3        dw        ?    ;

                ...

TEST_VGA PROC

		push	0			;检测是否安装鼠标驱动程序
		pop	ds
		cmp	word ptr ds:[33h*4],0
		jz	no_mouse
		or	cs:flag,10000000b	;has mouse installed
no_mouse:
		push	cs
		pop	ds
		mov	ah,1bh			;检测是否是 VGA 以上显示卡
		xor	bx,bx
		mov	di,offset file_end
		int	10h
		cmp	al,1bh
		jnz	tv_no_vga
		mov	ax,4f00h		;检测是否支持 VESA 功能
		mov	di,offset file_end
		int	10h
		cmp	al,4fh
		jz	tv_is_vesa
		mov	dx,3c4h			;检测是否 TVGA 9000 卡
		mov	al,0eh			;这一段是照抄的，找不到资料
		out	dx,al
		inc	dx
		in	al,dx
		mov	bl,al
		xor	al,al
		out	dx,al
		in	al,dx
		xchg	al,bl
		out	dx,al
		test	bl,2
		jnz	tv_is_tvga
		mov	dx,3cdh			;检测是否 ET6000 卡
		in	al,dx
		mov	ah,al
		mov	al,11h
		out	dx,al
		in	al,dx
		xchg	ah,al
		out	dx,al
		cmp	ah,11h
		jz	tv_is_tseng
		mov	vga_type,4
		ret
tv_is_vesa:
		mov	vga_type,1
		ret
tv_is_tvga:
		mov	vga_type,2
		ret
tv_is_tseng:
		mov	vga_type,3
		ret
tv_no_vga:
		int	20h		;非 VGA 卡退出

TEST_VGA	ENDP

                ...

;================================================================
;保存显示缓冲区内容并设置新的显示模式到 80 x 25 文本 (模式 3）
SAVE_SCR	PROC
		push	ds
		push	es
		test	flag,10000000b		;见前面
		jz	ss_no_mouse
		mov	ax,16h			;保存鼠标状态
		mov	dx,offset mouse_buffer
		int	33h
ss_no_mouse:
		mov	ax,1c01h		;保存视频状态
		mov	bx,offset video_buffer
		mov	cx,7
		int	10h
		mov	ah,0fh			;保存原显示模式
		int	10h
		mov	video_mode,al
		cmp	al,3			;80 x 25 x 16 色
		jz	ss_mode3
		cmp	al,7			;80 x 25 黑白
		jz	ss_mode7
		xor	ax,ax			;以下为图形方式保存显示缓冲区
		call	vga_page
		call	vga_base
		call	save_vram
		mov	ax,0083h		;设置新的显示模式，不清除显示内存
		int	10h

		push	0b800h
		pop	ds			;保存显示内存
		xor	si,si
		mov	cx,1000h
		mov	di,offset ram_buffer
		push	cs
		push	ds
		cld
		rep	movsb
		xor	di,di			;
		mov	cx,80*25
		mov	ax,57b1h		;填充背景，不然有乱字符
		cld
		rep	stosw
scr_ret:
		pop	es
		pop	ds
		ret
ss_mode3:
		call	save_vram		;显示模式 3 保存显示 RAM
		jmp	short scr_ret
ss_mode7:
		push	0b000h			;显示模式 7 保存显示 RAM
		pop	ds
		call	save_vram1
		mov	ax,3
		int	10h
		call	restore_vram
		jmp	short scr_ret
SAVE_SCR	ENDP
SAVE_VRAM	PROC
		push	0b800h			;把显示内存保存到自己的缓冲区
		pop	ds
save_vram1:
		push	cs
		pop	ds
		xor	si,si
		mov	di,offset ram_buffer
		mov	cx,2000h
		cld
		rep	movsb
		ret

SAVE_VRAM	ENDP
RESTORE_VRAM	PROC

		push	0b800h			;恢复显示缓冲区内容
		pop	es
restore_vram1:
		xor	di,di
		push	cs
		pop	ds
		mov	si,offset ram_buffer
		mov	cx,2000h
		cld
		rep	movsb
		ret

RESTORE_VRAM	ENDP
VGA_PAGE	PROC
		cmp	vga_type,1
		jnz	other_vga1
		cmp	ah,1
		jz	vp_vesa2
		cmp	ah,2
		jz	vp_vesa1
		mov	ax,4f05h		;保存 VESA 显示卡状态
		mov	bx,0100h
		int	10h
		mov	vga_win1,dx
		mov	ax,4f05h
		mov	bx,0101h
		int	10h
		mov	vga_win2,dx
vp_vesa1:
		mov	ax,4f05h
		xor	bx,bx
		xor	dx,dx
		int	10h
		mov	ax,4f05h
		mov	bx,0001h
		xor	dx,dx
		int	10h
		ret
vp_vesa2:
		mov	ax,4f05h
		xor	bx,bx
		mov	dx,vga_win1
		int	10h
		mov	ax,4f05h
		mov	bx,0001h
		mov	dx,vga_win2
		int	10h
		ret
other_vga1:
		cmp	vga_type,3
		jnz	other_vga2
		mov	dx,3cdh
		cmp	ah,1
		jz	vp_tseng2
		cmp	ah,2
		jz	vp_tseng1
		in	al,dx
		mov	vga_win3,al
vp_tseng1:
		xor	al,al
		out	dx,al
		ret
vp_tseng2:
		mov	al,vga_win3
		out	dx,al
vp_ret:
		ret
other_vga2:
		cmp	vga_type,2
		jnz	vp_ret
		mov	al,0eh
		mov	dx,03c4h
		cmp	ah,1
		jz	vp_tvga2
		out	dx,al
		inc	dx
		in	al,dx
		cmp	ah,2
		jz	vp_tvga1
		mov	vga_win3,al
		xor	al,al
		out	dx,al
		ret
vp_tvga1:
		mov	al,2
		out	dx,al
		ret
vp_tvga2:
		mov	ah,vga_win3
		out	dx,ax
		ret
VGA_PAGE	ENDP
VGA_BASE	PROC
		mov	dx,3c4h			;这一段是照抄的，找不到资料
		mov	ax,402h
		out	dx,ax
		mov	ax,704h
		out	dx,ax
		mov	dx,3ceh
		mov	ax,0ff08h
		out	dx,ax
		mov	ax,0c06h
		out	dx,ax
		mov	ax,204h
		out	dx,ax
		mov	ax,5
		out	dx,ax
		ret
VGA_BASE	ENDP

;====================================================
;本子程序为恢复原来的显示内容
;在自己的程序执行完后使用
RESTORE_SCR	PROC
		push	cs
		pop	ds
		mov	al,video_mode		;根据不同的原显示模式不同处理
		cmp	al,3
		jz	rs_mode3
		cmp	al,7
		jz	rs_mode7
		push	0b800h			;以下为图形方式恢复显示内容
		pop	es
		push	cs
		pop	ds
		mov	si,offset ram_buffer
		xor	di,di
		mov	cx,1000h
		cld
		rep	movsb			;恢复显示 RAM

		mov	ah,2
		call	vga_page
		call	vga_base
		call	restore_vram
		xor	ah,ah			;恢复到原来的显示模式
		mov	al,video_mode
		or	al,80h
		int	10h
		mov	ah,1
		call	vga_base
		jmp	short rs_mode31
rs_mode3:
		call	restore_vram
rs_mode31:
		push	cs
		pop	es
		push	cs
		pop	ds
		mov	ax,1c02h		;恢复视频状态
		mov	bx,offset video_buffer
		mov	cx,7
		int	10h
		test	flag,10000000b
		jz	rs_no_mouse
		mov	ax,17h			;恢复鼠标状态
		mov	dx,offset mouse_buffer
		int	33h
rs_no_mouse:
		ret
rs_mode7:
		mov	ax,7			;显示模式 7 恢复
		int	10h
		push	0b000h
		pop	es
		call	restore_vram1
		jmp	short rs_mode31
RESTORE_SCR	ENDP