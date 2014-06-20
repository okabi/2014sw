	GLOBAL	fact
fact	push	ebp
	mov	ebp, esp
	sub	esp, 4
; 関数factの本体ここから
; local_vars: n:VAR:level1 => 8
; local_vars: i:VAR:level2 => -4
; = ここから(i:VAR:level2, 1)
	mov	eax, 1
	mov	[ebp-4], eax
; = ここまで(i:VAR:level2, 1)
; WHILEここから
fact_while0	mov	eax, 1
; = ここから(i:VAR:level2, ["*", "i:VAR:level2", "n:VAR:level1"])
; * ここから(i:VAR:level2, n:VAR:level1)
	mov	eax, [ebp+8]
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	imul	eax, ebx
; * ここまで(i:VAR:level2, n:VAR:level1)
	mov	[ebp-4], eax
; = ここまで(i:VAR:level2, ["*", "i:VAR:level2", "n:VAR:level1"])
; = ここから(n:VAR:level1, ["-", "n:VAR:level1", 1])
; - ここから(n:VAR:level1, 1)
	mov	eax, 1
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	sub	eax, ebx
; - ここまで(n:VAR:level1, 1)
	mov	[ebp+8], eax
; = ここまで(n:VAR:level1, ["-", "n:VAR:level1", 1])
	mov	eax, 1
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	setge	al
	movzx	eax, al
	cmp	eax, 0
	jne	fact_while0
; WHILEここまで
	mov	eax, [ebp-4]
	jmp	fact_ret
; 関数factの本体ここまで
fact_ret	mov	esp, ebp
	pop	ebp
	ret
