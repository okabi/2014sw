	GLOBAL	fact
fact:
	push	ebp
	mov	ebp, esp
	sub	esp, 8
; 関数factの本体ここから
; local_vars: n:VAR:level1 => 8
; local_vars: i:VAR:level2 => -4
; local_vars: ans:VAR:level2 => -8
; = ここから(ans:VAR:level2, 1)
	mov	eax, 1
	mov	[ebp-8], eax
; = ここまで(ans:VAR:level2, 1)
; FORここから
; = ここから(i:VAR:level2, n:VAR:level1)
	mov	eax, [ebp+8]
	mov	[ebp-4], eax
; = ここまで(i:VAR:level2, n:VAR:level1)
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
; = ここから(ans:VAR:level2, ["*", "ans:VAR:level2", "i:VAR:level2"])
; * ここから(ans:VAR:level2, i:VAR:level2)
	mov	eax, [ebp-4]
	push	eax
	mov	eax, [ebp-8]
	pop	ebx
	imul	eax, ebx
; * ここまで(ans:VAR:level2, i:VAR:level2)
	mov	[ebp-8], eax
; = ここまで(ans:VAR:level2, ["*", "ans:VAR:level2", "i:VAR:level2"])
fact_whilemid0:
; = ここから(i:VAR:level2, ["-", "i:VAR:level2", 1])
; - ここから(i:VAR:level2, 1)
	mov	dword eax, 1
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	sub	eax, ebx
; - ここまで(i:VAR:level2, 1)
	mov	[ebp-4], eax
; = ここまで(i:VAR:level2, ["-", "i:VAR:level2", 1])
	jmp	fact_whilestart0
fact_whileend0:
; FORここまで
	mov	eax, [ebp-8]
	jmp	fact_ret
; 関数factの本体ここまで
fact_ret:
	mov	esp, ebp
	pop	ebp
	ret
	GLOBAL	fib
fib:
	push	ebp
	mov	ebp, esp
	sub	esp, 0
; 関数fibの本体ここから
; local_vars: n:VAR:level1 => 8
; IFここから
; || ここから(["==", "n:VAR:level1", 0], ["==", "n:VAR:level1", 1])
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
; || ここまで(["==", "n:VAR:level1", 0], ["==", "n:VAR:level1", 1])
	je	fib_else0
	mov	eax, [ebp+8]
	jmp	fib_ret
	jmp	fib_if0
fib_else0:
; この先else
; + ここから(["FCALL", "fib", [["-", "n:VAR:level1", 1]]], ["FCALL", "fib", [["-", "n:VAR:level1", 2]]])
; - ここから(n:VAR:level1, 2)
	mov	dword eax, 2
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
	mov	dword eax, 1
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
fib_if0:
; IFここまで
; 関数fibの本体ここまで
fib_ret:
	mov	esp, ebp
	pop	ebp
	ret
	GLOBAL	sum
sum:
	push	ebp
	mov	ebp, esp
	sub	esp, 8
; 関数sumの本体ここから
; local_vars: n:VAR:level1 => 8
; local_vars: i:VAR:level2 => -4
; local_vars: ans:VAR:level2 => -8
; = ここから(ans:VAR:level2, 0)
	mov	eax, 0
	mov	[ebp-8], eax
; = ここまで(ans:VAR:level2, 0)
; FORここから
; = ここから(i:VAR:level2, 1)
	mov	eax, 1
	mov	[ebp-4], eax
; = ここまで(i:VAR:level2, 1)
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
sum_whilemid0:
; = ここから(i:VAR:level2, ["+", "i:VAR:level2", 1])
; + ここから(i:VAR:level2, 1)
	mov	dword eax, 1
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	add	eax, ebx
; + ここまで(i:VAR:level2, 1)
	mov	[ebp-4], eax
; = ここまで(i:VAR:level2, ["+", "i:VAR:level2", 1])
	jmp	sum_whilestart0
sum_whileend0:
; FORここまで
	mov	eax, [ebp-8]
	jmp	sum_ret
; 関数sumの本体ここまで
sum_ret:
	mov	esp, ebp
	pop	ebp
	ret
	GLOBAL	compNum
compNum:
	push	ebp
	mov	ebp, esp
	sub	esp, 4
; 関数compNumの本体ここから
; local_vars: n:VAR:level1 => 8
; local_vars: ret:VAR:level2 => -4
; = ここから(ret:VAR:level2, 1)
	mov	eax, 1
	mov	[ebp-4], eax
; = ここまで(ret:VAR:level2, 1)
; IFここから
	mov	dword eax, 0
	push	eax
	mov	eax, [ebp+8]
	pop	ebx
	cmp	eax, ebx
	setl	al
	movzx	eax, al
	cmp	eax, 0
	je	compNum_else0
; = ここから(ret:VAR:level2, ["*", "ret:VAR:level2", 2])
; * ここから(ret:VAR:level2, 2)
	mov	dword eax, 2
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	imul	eax, ebx
; * ここまで(ret:VAR:level2, 2)
	mov	[ebp-4], eax
; = ここまで(ret:VAR:level2, ["*", "ret:VAR:level2", 2])
	jmp	compNum_if0
compNum_else0:
; この先else
compNum_if0:
; IFここまで
; IFここから
; && ここから(["<=", "n:VAR:level1", 5], [">=", "n:VAR:level1", 0])
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
; && ここまで(["<=", "n:VAR:level1", 5], [">=", "n:VAR:level1", 0])
	je	compNum_else1
; = ここから(ret:VAR:level2, ["*", "ret:VAR:level2", 3])
; * ここから(ret:VAR:level2, 3)
	mov	dword eax, 3
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	imul	eax, ebx
; * ここまで(ret:VAR:level2, 3)
	mov	[ebp-4], eax
; = ここまで(ret:VAR:level2, ["*", "ret:VAR:level2", 3])
	jmp	compNum_if1
compNum_else1:
; この先else
compNum_if1:
; IFここまで
; IFここから
; || ここから(["<=", "n:VAR:level1", 10], [">=", "n:VAR:level1", 5])
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
; || ここまで(["<=", "n:VAR:level1", 10], [">=", "n:VAR:level1", 5])
	je	compNum_else2
; = ここから(ret:VAR:level2, ["*", "ret:VAR:level2", 5])
; * ここから(ret:VAR:level2, 5)
	mov	dword eax, 5
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	imul	eax, ebx
; * ここまで(ret:VAR:level2, 5)
	mov	[ebp-4], eax
; = ここまで(ret:VAR:level2, ["*", "ret:VAR:level2", 5])
	jmp	compNum_if2
compNum_else2:
; この先else
compNum_if2:
; IFここまで
; IFここから
; || ここから([[["==", "n:VAR:level1", 10]]], [[["&&", ["!=", "n:VAR:level1", 20], [">", ["/", "n:VAR:level1", 10], 1]]]])
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
; && ここから(["!=", "n:VAR:level1", 20], [">", ["/", "n:VAR:level1", 10], 1])
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
; / ここから(n:VAR:level1, 10)
	mov	dword eax, 10
	push	eax
	mov	eax, [ebp+8]
	cdq
	pop	ebx
	idiv	dword ebx
; / ここまで(n:VAR:level1, 10)
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
; && ここまで(["!=", "n:VAR:level1", 20], [">", ["/", "n:VAR:level1", 10], 1])
	cmp	eax, 0
	jne	compNum_logical2
	pop	eax
	mov	eax, 0
	push	eax
compNum_logical2:
	pop	eax
	cmp	eax, 0
; || ここまで([[["==", "n:VAR:level1", 10]]], [[["&&", ["!=", "n:VAR:level1", 20], [">", ["/", "n:VAR:level1", 10], 1]]]])
	je	compNum_else3
; = ここから(ret:VAR:level2, ["*", "ret:VAR:level2", 7])
; * ここから(ret:VAR:level2, 7)
	mov	dword eax, 7
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	imul	eax, ebx
; * ここまで(ret:VAR:level2, 7)
	mov	[ebp-4], eax
; = ここまで(ret:VAR:level2, ["*", "ret:VAR:level2", 7])
	jmp	compNum_if3
compNum_else3:
; この先else
compNum_if3:
; IFここまで
	mov	eax, [ebp-4]
	jmp	compNum_ret
; 関数compNumの本体ここまで
compNum_ret:
	mov	esp, ebp
	pop	ebp
	ret
	GLOBAL	mod
mod:
	push	ebp
	mov	ebp, esp
	sub	esp, 4
; 関数modの本体ここから
; local_vars: x:VAR:level1 => 8
; local_vars: y:VAR:level1 => 12
; local_vars: z:VAR:level2 => -4
; IFここから
	mov	dword eax, 0
	push	eax
	mov	eax, [ebp+12]
	pop	ebx
	cmp	eax, ebx
	sete	al
	movzx	eax, al
	cmp	eax, 0
	je	mod_else0
; = ここから(z:VAR:level2, 0)
	mov	eax, 0
	mov	[ebp-4], eax
; = ここまで(z:VAR:level2, 0)
	jmp	mod_if0
mod_else0:
; この先else
; = ここから(z:VAR:level2, ["%", "x:VAR:level1", "y:VAR:level1"])
; % ここから(x:VAR:level1, y:VAR:level1)
	mov	eax, [ebp+12]
	push	eax
	mov	eax, [ebp+8]
	cdq
	pop	ebx
	idiv	dword ebx
	mov	eax, edx
; % ここまで(x:VAR:level1, y:VAR:level1)
	mov	[ebp-4], eax
; = ここまで(z:VAR:level2, ["%", "x:VAR:level1", "y:VAR:level1"])
mod_if0:
; IFここまで
	mov	eax, [ebp-4]
	jmp	mod_ret
; 関数modの本体ここまで
mod_ret:
	mov	esp, ebp
	pop	ebp
	ret
