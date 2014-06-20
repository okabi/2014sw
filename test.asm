	GLOBAL	fact
fact	push	ebp
	mov	ebp, esp
	sub	esp, 0
; 関数factの本体ここから
; local_vars: n:VAR:level1 => 8
; IFここから
	mov	eax, 1
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	setle	al
	movzx	eax, al
	cmp	eax, 0
	je	fact_if0
	mov	eax, 1
	jmp	fact_ret
fact_if0:
; この先else
; * ここから(n:VAR:level1, ["FCALL", "fact", [["-", "n:VAR:level1", 1]]])
; - ここから(n:VAR:level1, 1)
	mov	eax, 1
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	sub	eax, ebx
; - ここまで(n:VAR:level1, 1)
	push	eax
	call	fact
	pop	ebx
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	imul	eax, ebx
; * ここまで(n:VAR:level1, ["FCALL", "fact", [["-", "n:VAR:level1", 1]]])
	jmp	fact_ret
; IFここまで
; 関数factの本体ここまで
fact_ret	mov	esp, ebp
	pop	ebp
	ret
	GLOBAL	fib
fib	push	ebp
	mov	ebp, esp
	sub	esp, 0
; 関数fibの本体ここから
; local_vars: n:VAR:level1 => 8
; IFここから
	mov	eax, 0
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	sete	al
	movzx	eax, al
	cmp	eax, 0
	je	fib_if0
	mov	eax, 0
	jmp	fib_ret
fib_if0:
; この先else
; IFここから
	mov	eax, 1
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	sete	al
	movzx	eax, al
	cmp	eax, 0
	je	fib_if1
	mov	eax, 1
	jmp	fib_ret
fib_if1:
; この先else
; + ここから(["FCALL", "fib", [["-", "n:VAR:level1", 1]]], ["FCALL", "fib", [["-", "n:VAR:level1", 2]]])
; - ここから(n:VAR:level1, 2)
	mov	eax, 2
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	sub	eax, ebx
; - ここまで(n:VAR:level1, 2)
	push	eax
	call	fib
	pop	ebx
	push	eax
; - ここから(n:VAR:level1, 1)
	mov	eax, 1
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	sub	eax, ebx
; - ここまで(n:VAR:level1, 1)
	push	eax
	call	fib
	pop	ebx
	pop	ebx
	add	eax, ebx
; + ここまで(["FCALL", "fib", [["-", "n:VAR:level1", 1]]], ["FCALL", "fib", [["-", "n:VAR:level1", 2]]])
	jmp	fib_ret
; IFここまで
; IFここまで
; 関数fibの本体ここまで
fib_ret	mov	esp, ebp
	pop	ebp
	ret
	GLOBAL	sum
sum	push	ebp
	mov	ebp, esp
	sub	esp, 8
; 関数sumの本体ここから
; local_vars: n:VAR:level1 => 8
; local_vars: i:VAR:level2 => -4
; local_vars: ans:VAR:level2 => -8
; = ここから(i:VAR:level2, 1)
	mov	eax, 1
	mov	[ebp-4], eax
; = ここまで(i:VAR:level2, 1)
; = ここから(ans:VAR:level2, 0)
	mov	eax, 0
	mov	[ebp-8], eax
; = ここまで(ans:VAR:level2, 0)
; WHILEここから
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
; = ここから(ans:VAR:level2, ["+", "ans:VAR:level2", "i:VAR:level2"])
; + ここから(ans:VAR:level2, i:VAR:level2)
	mov	eax, [ebp-4]
	push	eax
	mov	eax, [ebp-8]
	pop	ebx
	add	eax, ebx
; + ここまで(ans:VAR:level2, i:VAR:level2)
	mov	[ebp-8], eax
; = ここまで(ans:VAR:level2, ["+", "ans:VAR:level2", "i:VAR:level2"])
; = ここから(i:VAR:level2, ["+", "i:VAR:level2", 1])
; + ここから(i:VAR:level2, 1)
	mov	eax, 1
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	add	eax, ebx
; + ここまで(i:VAR:level2, 1)
	mov	[ebp-4], eax
; = ここまで(i:VAR:level2, ["+", "i:VAR:level2", 1])
	jmp	sum_whilestart0
sum_whileend0:
; WHILEここまで
	mov	eax, [ebp-8]
	jmp	sum_ret
; 関数sumの本体ここまで
sum_ret	mov	esp, ebp
	pop	ebp
	ret
