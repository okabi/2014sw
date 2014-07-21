	GLOBAL	l
l:
	push	ebp
	mov	ebp, esp
	mov	eax, [ebp+16]
	push	eax
	mov	eax, [ebp+12]
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	add	eax, ebx
	pop	ebx
	add	eax, ebx
l_ret:
	mov	esp, ebp
	pop	ebp
	ret
	GLOBAL	r
r:
	push	ebp
	mov	ebp, esp
	mov	eax, 3
	push	eax
	mov	eax, 2
	push	eax
	mov	eax, 1
	push	eax
	call	l
	pop	ebx
	pop	ebx
	pop	ebx
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	add	eax, ebx
r_ret:
	mov	esp, ebp
	pop	ebp
	ret
	GLOBAL	rsl1
rsl1:
	push	ebp
	mov	ebp, esp
	mov	eax, 3
	push	eax
	mov	eax, 2
	push	eax
	mov	eax, 1
	push	eax
	call	l
	pop	ebx
	pop	ebx
	pop	ebx
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	sub	eax, ebx
rsl1_ret:
	mov	esp, ebp
	pop	ebp
	ret
	GLOBAL	rsl2
rsl2:
	push	ebp
	mov	ebp, esp
	mov	eax, 4
	push	eax
	call	r
	pop	ebx
	push	eax
	mov	eax, 3
	push	eax
	mov	eax, 2
	push	eax
	mov	eax, 1
	push	eax
	call	l
	pop	ebx
	pop	ebx
	pop	ebx
	pop	ebx
	sub	eax, ebx
rsl2_ret:
	mov	esp, ebp
	pop	ebp
	ret
	GLOBAL	arth
arth:
	push	ebp
	mov	ebp, esp
	sub	esp, 4
	mov	dword [ebp-4], 10
	mov	eax, [ebp+12]
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	sub	eax, ebx
	mov	[ebp+8], eax
	mov	dword eax, 1
	push	eax
	mov	eax, [ebp+8]
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	sub	eax, ebx
	pop	ebx
	sub	eax, ebx
	mov	[ebp-4], eax
	mov	eax, [ebp-4]
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	add	eax, ebx
arth_ret:
	mov	esp, ebp
	pop	ebp
	ret
	EXTERN	chk
	EXTERN	chk
	EXTERN	chk
	EXTERN	chk
	EXTERN	chk
	GLOBAL	main
main:
	push	ebp
	mov	ebp, esp
	mov	eax, 6
	push	eax
	mov	eax, 3
	push	eax
	mov	eax, 2
	push	eax
	mov	eax, 1
	push	eax
	call	l
	pop	ebx
	pop	ebx
	pop	ebx
	push	eax
	call	chk
	pop	ebx
	pop	ebx
	mov	eax, 16
	push	eax
	mov	eax, 10
	push	eax
	call	r
	pop	ebx
	push	eax
	call	chk
	pop	ebx
	pop	ebx
	mov	eax, 4
	push	eax
	mov	eax, 10
	push	eax
	call	rsl1
	pop	ebx
	push	eax
	call	chk
	pop	ebx
	pop	ebx
	mov	eax, -4
	push	eax
	call	rsl2
	push	eax
	call	chk
	pop	ebx
	pop	ebx
	mov	eax, 9
	push	eax
	mov	eax, 4
	push	eax
	mov	eax, 2
	push	eax
	call	arth
	pop	ebx
	pop	ebx
	push	eax
	call	chk
	pop	ebx
	pop	ebx
main_ret:
	mov	esp, ebp
	pop	ebp
	ret
