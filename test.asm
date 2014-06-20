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
	GLOBAL	bigger
bigger	push	ebp
	mov	ebp, esp
	sub	esp, 0
; 関数biggerの本体ここから
; local_vars: n:VAR:level1 => 8
; IFここから
	mov	eax, 0
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	setle	al
	movzx	eax, al
	cmp	eax, 0
	je	bigger_if0
	mov	eax, 0
	jmp	bigger_ret
bigger_if0:
; この先else
; IFここまで
; IFここから
; && ここから([[["||", [">=", "n:VAR:level1", 1], [">=", "n:VAR:level1", 5]]]], ["<=", "n:VAR:level1", 10])
	mov	eax, 0
	push	eax
	cmp	eax, 0
	je	bigger_logical0
	cmp	eax, 0
	je	bigger_logical0
	pop	eax
	mov	eax, 1
	push	eax
bigger_logical0:
	pop	eax
	cmp	eax, 0
; && ここまで([[["||", [">=", "n:VAR:level1", 1], [">=", "n:VAR:level1", 5]]]], ["<=", "n:VAR:level1", 10])
	je	bigger_if1
	mov	eax, 1
	jmp	bigger_ret
bigger_if1:
; この先else
; IFここから
	mov	eax, 100
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	setl	al
	movzx	eax, al
	cmp	eax, 0
	je	bigger_if2
	mov	eax, 2
	jmp	bigger_ret
bigger_if2:
; この先else
	mov	eax, 3
	jmp	bigger_ret
; IFここまで
; IFここまで
; 関数biggerの本体ここまで
bigger_ret	mov	esp, ebp
	pop	ebp
	ret
