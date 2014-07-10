	GLOBAL	f
f:
	push	ebp
	mov	ebp, esp
	sub	esp, 8
	mov	dword [ebp-8], 0
	mov	dword [ebp-4], 1
f_whilestart0:
	mov	eax, [ebp+8]
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	cmp	eax, ebx
	setle	al
	movzx	eax, al
	cmp	eax, 0
	je	f_whileend0
	mov	eax, [ebp-4]
	push	eax
	mov	eax, [ebp-8]
	pop	ebx
	add	eax, ebx
	mov	[ebp-8], eax
f_whilemid0:
	mov	dword eax, 1
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	add	eax, ebx
	mov	[ebp-4], eax
	jmp	f_whilestart0
f_whileend0:
	mov	eax, [ebp-8]
f_ret:
	mov	esp, ebp
	pop	ebp
	ret
