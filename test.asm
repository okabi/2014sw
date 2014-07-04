	GLOBAL	fact
fact:
	push	ebp
	mov	ebp, esp
	sub	esp, 8
	mov	dword [ebp-8], 1
	mov	eax, [ebp+8]
	mov	[ebp-4], eax
fact_whilestart0:
	mov	dword eax, 0
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	cmp	eax, ebx
	setg	al
	movzx	eax, al
	cmp	eax, 0
	je	fact_whileend0
	mov	eax, [ebp-4]
	push	eax
	mov	eax, [ebp-8]
	pop	ebx
	imul	eax, ebx
	mov	[ebp-8], eax
fact_whilemid0:
	mov	dword eax, 1
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	sub	eax, ebx
	mov	[ebp-4], eax
	jmp	fact_whilestart0
fact_whileend0:
	mov	eax, [ebp-8]
fact_ret:
	mov	esp, ebp
	pop	ebp
	ret
	GLOBAL	fib
fib:
	push	ebp
	mov	ebp, esp
	sub	esp, 0
	mov	eax, 1
	push	eax
	mov	dword eax, 0
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	sete	al
	movzx	eax, al
	cmp	eax, 0
	cmp	eax, 0
	jne	fib_logical0
	mov	dword eax, 1
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	sete	al
	movzx	eax, al
	cmp	eax, 0
	cmp	eax, 0
	jne	fib_logical0
	pop	eax
	mov	eax, 0
	push	eax
fib_logical0:
	pop	eax
	cmp	eax, 0
	je	fib_else0
	mov	eax, [ebp+8]
	jmp	fib_ret
fib_else0:
	mov	dword eax, 2
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	sub	eax, ebx
	push	eax
	call	fib
	pop	ebx
	push	eax
	mov	dword eax, 1
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	sub	eax, ebx
	push	eax
	call	fib
	pop	ebx
	pop	ebx
	add	eax, ebx
	jmp	fib_ret
fib_if0:
fib_ret:
	mov	esp, ebp
	pop	ebp
	ret
	GLOBAL	sum
sum:
	push	ebp
	mov	ebp, esp
	sub	esp, 8
	mov	dword [ebp-8], 0
	mov	dword [ebp-4], 1
sum_whilestart0:
	mov	eax, [ebp+8]
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	cmp	eax, ebx
	setle	al
	movzx	eax, al
	cmp	eax, 0
	je	sum_whileend0
	mov	eax, [ebp-4]
	push	eax
	mov	eax, [ebp-8]
	pop	ebx
	add	eax, ebx
	mov	[ebp-8], eax
sum_whilemid0:
	mov	dword eax, 1
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	add	eax, ebx
	mov	[ebp-4], eax
	jmp	sum_whilestart0
sum_whileend0:
	mov	eax, [ebp-8]
sum_ret:
	mov	esp, ebp
	pop	ebp
	ret
	GLOBAL	compNum
compNum:
	push	ebp
	mov	ebp, esp
	sub	esp, 4
	mov	dword [ebp-4], 1
	mov	dword eax, 0
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	setl	al
	movzx	eax, al
	cmp	eax, 0
	je	compNum_if0
	mov	dword eax, 2
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	imul	eax, ebx
	mov	[ebp-4], eax
compNum_if0:
	mov	eax, 0
	push	eax
	mov	dword eax, 5
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	setle	al
	movzx	eax, al
	cmp	eax, 0
	cmp	eax, 0
	je	compNum_logical0
	mov	dword eax, 0
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	setge	al
	movzx	eax, al
	cmp	eax, 0
	cmp	eax, 0
	je	compNum_logical0
	pop	eax
	mov	eax, 1
	push	eax
compNum_logical0:
	pop	eax
	cmp	eax, 0
	je	compNum_if1
	mov	dword eax, 3
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	imul	eax, ebx
	mov	[ebp-4], eax
compNum_if1:
	mov	eax, 1
	push	eax
	mov	dword eax, 10
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	setle	al
	movzx	eax, al
	cmp	eax, 0
	cmp	eax, 0
	jne	compNum_logical1
	mov	dword eax, 5
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	setge	al
	movzx	eax, al
	cmp	eax, 0
	cmp	eax, 0
	jne	compNum_logical1
	pop	eax
	mov	eax, 0
	push	eax
compNum_logical1:
	pop	eax
	cmp	eax, 0
	je	compNum_if2
	mov	dword eax, 5
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	imul	eax, ebx
	mov	[ebp-4], eax
compNum_if2:
	mov	eax, 1
	push	eax
	mov	dword eax, 10
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	sete	al
	movzx	eax, al
	cmp	eax, 0
	cmp	eax, 0
	jne	compNum_logical2
	mov	eax, 0
	push	eax
	mov	dword eax, 20
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	setne	al
	movzx	eax, al
	cmp	eax, 0
	cmp	eax, 0
	je	compNum_logical3
	mov	dword eax, 1
	push	eax
	mov	dword eax, 10
	push	eax
	mov	eax, [ebp+8]
	cdq
	pop	ebx
	idiv	dword ebx
	pop	ebx
	cmp	eax, ebx
	setg	al
	movzx	eax, al
	cmp	eax, 0
	cmp	eax, 0
	je	compNum_logical3
	pop	eax
	mov	eax, 1
	push	eax
compNum_logical3:
	pop	eax
	cmp	eax, 0
	cmp	eax, 0
	jne	compNum_logical2
	pop	eax
	mov	eax, 0
	push	eax
compNum_logical2:
	pop	eax
	cmp	eax, 0
	je	compNum_if3
	mov	dword eax, 7
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	imul	eax, ebx
	mov	[ebp-4], eax
compNum_if3:
	mov	eax, [ebp-4]
compNum_ret:
	mov	esp, ebp
	pop	ebp
	ret
	GLOBAL	mod
mod:
	push	ebp
	mov	ebp, esp
	sub	esp, 4
	mov	dword eax, 0
	push	eax
	mov	eax, [ebp+12]
	pop	ebx
	cmp	eax, ebx
	sete	al
	movzx	eax, al
	cmp	eax, 0
	je	mod_else0
	mov	dword [ebp-4], 0
	jmp	mod_if0
mod_else0:
	mov	eax, [ebp+12]
	push	eax
	mov	eax, [ebp+8]
	cdq
	pop	ebx
	idiv	dword ebx
	mov	eax, edx
	mov	[ebp-4], eax
mod_if0:
	mov	eax, [ebp-4]
mod_ret:
	mov	esp, ebp
	pop	ebp
	ret
