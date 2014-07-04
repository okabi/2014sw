	GLOBAL	f
f:
	push	ebp
	mov	ebp, esp
	sub	esp, 0
	mov	dword eax, 0
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	setle	al
	movzx	eax, al
	cmp	eax, 0
	je	f_else0
	mov	eax, 1
	jmp	f_ret
f_else0:
	mov	dword eax, 1
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	sub	eax, ebx
	push	eax
	call	f
	pop	ebx
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	imul	eax, ebx
	jmp	f_ret
f_if0:
f_ret:
	mov	esp, ebp
	pop	ebp
	ret
