;by Luo Yun Bin
;http://asm.yeah.net 

;����ӳ������������ʾ�������ͣ����״̬�ȵ�
;�ڳ����ʼ��ʱִ��

;����Ҫ�õ���һЩ���������Լ����壬ע���С��

flag             db        ?    ;��־λ��λ 7 �� 1 ��ʾ��װ�����
vga_type        db        ?    ;��ʾ������
video_mode      db       ?     ;��ʾģʽ
vga_win1        dw        ?    ;��Ƶ����,�ݴ� VESA �Ĵ���״̬
vga_win2        dw        ?    ;
vga_win3        dw        ?    ;

                ...

TEST_VGA PROC

		push	0			;����Ƿ�װ�����������
		pop	ds
		cmp	word ptr ds:[33h*4],0
		jz	no_mouse
		or	cs:flag,10000000b	;has mouse installed
no_mouse:
		push	cs
		pop	ds
		mov	ah,1bh			;����Ƿ��� VGA ������ʾ��
		xor	bx,bx
		mov	di,offset file_end
		int	10h
		cmp	al,1bh
		jnz	tv_no_vga
		mov	ax,4f00h		;����Ƿ�֧�� VESA ����
		mov	di,offset file_end
		int	10h
		cmp	al,4fh
		jz	tv_is_vesa
		mov	dx,3c4h			;����Ƿ� TVGA 9000 ��
		mov	al,0eh			;��һ�����ճ��ģ��Ҳ�������
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
		mov	dx,3cdh			;����Ƿ� ET6000 ��
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
		int	20h		;�� VGA ���˳�

TEST_VGA	ENDP

                ...

;================================================================
;������ʾ���������ݲ������µ���ʾģʽ�� 80 x 25 �ı� (ģʽ 3��
SAVE_SCR	PROC
		push	ds
		push	es
		test	flag,10000000b		;��ǰ��
		jz	ss_no_mouse
		mov	ax,16h			;�������״̬
		mov	dx,offset mouse_buffer
		int	33h
ss_no_mouse:
		mov	ax,1c01h		;������Ƶ״̬
		mov	bx,offset video_buffer
		mov	cx,7
		int	10h
		mov	ah,0fh			;����ԭ��ʾģʽ
		int	10h
		mov	video_mode,al
		cmp	al,3			;80 x 25 x 16 ɫ
		jz	ss_mode3
		cmp	al,7			;80 x 25 �ڰ�
		jz	ss_mode7
		xor	ax,ax			;����Ϊͼ�η�ʽ������ʾ������
		call	vga_page
		call	vga_base
		call	save_vram
		mov	ax,0083h		;�����µ���ʾģʽ���������ʾ�ڴ�
		int	10h

		push	0b800h
		pop	ds			;������ʾ�ڴ�
		xor	si,si
		mov	cx,1000h
		mov	di,offset ram_buffer
		push	cs
		push	ds
		cld
		rep	movsb
		xor	di,di			;
		mov	cx,80*25
		mov	ax,57b1h		;��䱳������Ȼ�����ַ�
		cld
		rep	stosw
scr_ret:
		pop	es
		pop	ds
		ret
ss_mode3:
		call	save_vram		;��ʾģʽ 3 ������ʾ RAM
		jmp	short scr_ret
ss_mode7:
		push	0b000h			;��ʾģʽ 7 ������ʾ RAM
		pop	ds
		call	save_vram1
		mov	ax,3
		int	10h
		call	restore_vram
		jmp	short scr_ret
SAVE_SCR	ENDP
SAVE_VRAM	PROC
		push	0b800h			;����ʾ�ڴ汣�浽�Լ��Ļ�����
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

		push	0b800h			;�ָ���ʾ����������
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
		mov	ax,4f05h		;���� VESA ��ʾ��״̬
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
		mov	dx,3c4h			;��һ�����ճ��ģ��Ҳ�������
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
;���ӳ���Ϊ�ָ�ԭ������ʾ����
;���Լ��ĳ���ִ�����ʹ��
RESTORE_SCR	PROC
		push	cs
		pop	ds
		mov	al,video_mode		;���ݲ�ͬ��ԭ��ʾģʽ��ͬ����
		cmp	al,3
		jz	rs_mode3
		cmp	al,7
		jz	rs_mode7
		push	0b800h			;����Ϊͼ�η�ʽ�ָ���ʾ����
		pop	es
		push	cs
		pop	ds
		mov	si,offset ram_buffer
		xor	di,di
		mov	cx,1000h
		cld
		rep	movsb			;�ָ���ʾ RAM

		mov	ah,2
		call	vga_page
		call	vga_base
		call	restore_vram
		xor	ah,ah			;�ָ���ԭ������ʾģʽ
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
		mov	ax,1c02h		;�ָ���Ƶ״̬
		mov	bx,offset video_buffer
		mov	cx,7
		int	10h
		test	flag,10000000b
		jz	rs_no_mouse
		mov	ax,17h			;�ָ����״̬
		mov	dx,offset mouse_buffer
		int	33h
rs_no_mouse:
		ret
rs_mode7:
		mov	ax,7			;��ʾģʽ 7 �ָ�
		int	10h
		push	0b000h
		pop	es
		call	restore_vram1
		jmp	short rs_mode31
RESTORE_SCR	ENDP