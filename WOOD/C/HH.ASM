	name	hh
_text	segment	byte public 'code'
dgroup	group	_data,_bss
	assume	cs:_text,ds:dgroup,ss:dgroup
_text	ends
_data	segment word public 'data'
_d@	label	byte
_data	ends
_bss	segment word public 'bss'
_b@	label	byte
_bss	ends
_text	segment	byte public 'code'
; Line 7
_main	proc	near
	push	si
	push	bp
	mov	bp,sp
; Line 8
; Line 9
; Line 10
	mov	si,-128
	jmp	short @5
@4:
; Line 11
	push	si
	call	near ptr _ho_clower
	pop	cx
	push	ax
	cmp	si,65
	jl	@18
	cmp	si,90
	jg	@18
	mov	ax,si
	or	ax,32
	jmp	short @17
@18:
	mov	ax,si
@17:
	pop	dx
	cmp	dx,ax
	je	@3
; Line 12
	cmp	si,65
	jl	@20
	cmp	si,90
	jg	@20
	mov	ax,si
	or	ax,32
	jmp	short @19
@20:
	mov	ax,si
@19:
	push	ax
	push	si
	call	near ptr _ho_clower
	pop	cx
	push	ax
	push	si
	mov	ax,offset _s@
	push	ax
	call	near ptr _printf
	mov	sp,bp
; Line 13
@3:
	inc	si
@5:
	cmp	si,128
	jl	@4
	mov	si,-128
	jmp	short @10
@9:
; Line 14
	mov	ax,si
	mov	ah,0
	mov	bx,ax
	mov	al,byte ptr dgroup:_ta_cvals[bx+128]
	cbw	
	push	ax
	cmp	si,65
	jl	@22
	cmp	si,90
	jg	@22
	mov	ax,si
	or	ax,32
	jmp	short @21
@22:
	mov	ax,si
@21:
	pop	dx
	cmp	dx,ax
	je	@8
; Line 15
	cmp	si,65
	jl	@24
	cmp	si,90
	jg	@24
	mov	ax,si
	or	ax,32
	jmp	short @23
@24:
	mov	ax,si
@23:
	push	ax
	push	si
	call	near ptr _ho_clower
	pop	cx
	push	ax
	push	si
	mov	ax,offset _s@+15
	push	ax
	call	near ptr _printf
	mov	sp,bp
; Line 16
@8:
	inc	si
@10:
	cmp	si,128
	jl	@9
	mov	si,-128
	jmp	@15
@14:
; Line 17
	or	si,si
	jge	@28
	xor	ax,ax
	jmp	short @27
@28:
	mov	ax,si
@27:
	cmp	ax,65
	jl	@26
	or	si,si
	jge	@30
	xor	ax,ax
	jmp	short @29
@30:
	mov	ax,si
@29:
	cmp	ax,90
	jg	@26
	or	si,si
	jge	@32
	xor	ax,ax
	jmp	short @31
@32:
	mov	ax,si
@31:
	or	ax,32
	jmp	short @25
@26:
	or	si,si
	jge	@34
	xor	ax,ax
	jmp	short @33
@34:
	mov	ax,si
@33:
@25:
	push	ax
	mov	al,byte ptr dgroup:_ta_cvals[si+128]
	cbw	
	pop	dx
	cmp	dx,ax
	je	@13
; Line 18
	cmp	si,65
	jl	@36
	cmp	si,90
	jg	@36
	mov	ax,si
	or	ax,32
	jmp	short @35
@36:
	mov	ax,si
@35:
	push	ax
	push	si
	call	near ptr _ho_clower
	pop	cx
	push	ax
	push	si
	mov	ax,offset _s@+30
	push	ax
	call	near ptr _printf
	mov	sp,bp
; Line 19
@13:
	inc	si
@15:
	cmp	si,128
	jge	@37
	jmp	@14
@37:
	pop	bp
	pop	si
	ret	
_main	endp
; Line 22
_tclower	proc	near
	push	bp
	mov	bp,sp
; Line 23
	mov	al,byte ptr [bp+4]
	mov	ah,0
	mov	bx,ax
	mov	al,byte ptr dgroup:_ta_cvals[bx+128]
	cbw	
; Line 24
	pop	bp
	ret	
_tclower	endp
; Line 26
_tlower	proc	near
	push	bp
	mov	bp,sp
; Line 27
	mov	bx,word ptr [bp+4]
	mov	al,byte ptr dgroup:_ta_cvals[bx+128]
	cbw	
; Line 28
	pop	bp
	ret	
_tlower	endp
; Line 30
_tl1	proc	near
	push	bp
	mov	bp,sp
; Line 31
	mov	bx,word ptr [bp+4]
	mov	al,byte ptr dgroup:_ta_cvals[bx+128]
	cbw	
; Line 32
	pop	bp
	ret	
_tl1	endp
; Line 34
_tl2	proc	near
	push	bp
	mov	bp,sp
; Line 35
	mov	bx,word ptr [bp+4]
	mov	al,byte ptr dgroup:_ta_cvals[bx+128]
	cbw	
; Line 36
	pop	bp
	ret	
_tl2	endp
_text	ends
_data	segment word public 'data'
	public	_xx
_xx	label	word
	dw	dgroup:_ta_cvals+128
_data	ends
_text	segment	byte public 'code'
; Line 39
_tl3	proc	near
	push	bp
	mov	bp,sp
; Line 40
	mov	bx,word ptr dgroup:_xx
	add	bx,word ptr [bp+4]
	mov	al,byte ptr [bx]
	cbw	
; Line 41
	pop	bp
	ret	
_tl3	endp
; Line 43
_tl4	proc	near
	push	bp
	mov	bp,sp
; Line 44
	mov	bx,word ptr dgroup:_xx
	add	bx,word ptr [bp+4]
	mov	al,byte ptr [bx]
	cbw	
; Line 45
	pop	bp
	ret	
_tl4	endp
_text	ends
_data	segment word public 'data'
_s@	label	byte
	db	49
	db	58
	db	32
	db	37
	db	100
	db	44
	db	32
	db	37
	db	100
	db	44
	db	32
	db	37
	db	100
	db	10
	db	0
	db	50
	db	58
	db	32
	db	37
	db	100
	db	44
	db	32
	db	37
	db	100
	db	44
	db	32
	db	37
	db	100
	db	10
	db	0
	db	51
	db	58
	db	32
	db	37
	db	100
	db	44
	db	32
	db	37
	db	100
	db	44
	db	32
	db	37
	db	100
	db	10
	db	0
_data	ends
	extrn	_ta_cvals:word
_text	segment	byte public 'code'
	public	_tclower
	public	_tlower
	public	_tl2
	extrn	_printf:near
	public	_tl3
	extrn	_ho_clower:near
	public	_tl4
	public	_tl1
	public	_main
_text	ends
	end
