	GLOBAL	x
	COMMON	x 4
	GLOBAL	f
f	push	ebp
	mov	ebp, esp
	sub	esp, 20
; 関数fの本体ここから
; local_vars: x:VAR:level2 => -4
; WHILEここから
; local_vars: x:VAR:level3 => -8
; local_vars: y:VAR:level3 => -12
; + ここから(x:VAR:level3, y:VAR:level3)
	mov	eax, [ebp-12]
	push	eax
	mov	eax, [ebp-8]
	pop	ebx
	add	eax, ebx
; + ここまで(x:VAR:level3, y:VAR:level3)
; local_vars: x:VAR:level4 => -16
; local_vars: z:VAR:level4 => -20
; = ここから(x:VAR:level4, ["-", ["*", "x:VAR:level4", 3], ["/", "z:VAR:level4", "x:VAR:level4"]])
; - ここから(["*", "x:VAR:level4", 3], ["/", "z:VAR:level4", "x:VAR:level4"])
; / めんどい
	push	eax
; * ここから(x:VAR:level4, 3)
	mov	eax, 3
	push	eax
	mov	eax, [ebp-16]
	pop	ebx
	imul	eax, ebx
; * ここまで(x:VAR:level4, 3)
	pop	ebx
	sub	eax, ebx
; - ここまで(["*", "x:VAR:level4", 3], ["/", "z:VAR:level4", "x:VAR:level4"])
	mov	[ebp-16], eax
; = ここまで(x:VAR:level4, ["-", ["*", "x:VAR:level4", 3], ["/", "z:VAR:level4", "x:VAR:level4"]])
; WHILEここまで
; local_vars: w:VAR:level3 => -8
; + ここから(["+", "x:VAR:level2", "y:VAR:level1"], w:VAR:level3)
	mov	eax, [ebp-8]
	push	eax
; + ここから(x:VAR:level2, y:VAR:level1)
	mov	eax, [ebp]
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	add	eax, ebx
; + ここまで(x:VAR:level2, y:VAR:level1)
	pop	ebx
	add	eax, ebx
; + ここまで(["+", "x:VAR:level2", "y:VAR:level1"], w:VAR:level3)
; + ここから(x:VAR:level2, y:VAR:level1)
	mov	eax, [ebp]
	push	eax
	mov	eax, [ebp-4]
	pop	ebx
	add	eax, ebx
; + ここまで(x:VAR:level2, y:VAR:level1)
; 関数fの本体ここまで
fret	mov	esp, ebp
	pop	ebp
	ret
	GLOBAL	g
g	push	ebp
	mov	ebp, esp
	sub	esp, 4
; 関数gの本体ここから
; local_vars: z:VAR:level2 => -4
	push	x:VAR:level0
	push	x:VAR:level0
	call	f
	pop	ebx
	pop	ebx
	call	g
; 関数gの本体ここまで
gret	mov	esp, ebp
	pop	ebp
	ret
