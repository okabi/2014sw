	GLOBAL	x
	COMMON	x, 4
	GLOBAL	f
f	push	ebp
	mov	ebp, esp
	sub	esp, 20
; 関数fの本体ここから
; local_vars: x:level2 => -4
; WHILEここから
; local_vars: x:level3 => -8
; local_vars: y:level3 => -12
; local_vars: x:level4 => -16
; local_vars: z:level4 => -20
; WHILEここまで
; local_vars: w:level3 => -8
; 関数fの本体ここまで
Lret	mov	esp, ebp
	pop	ebp
	ret
	GLOBAL	g
g	push	ebp
	mov	ebp, esp
	sub	esp, 4
; 関数gの本体ここから
; local_vars: z:level2 => -4
	push	x:VAR:level0
	push	x:VAR:level0
	call	f
	call	g
; 関数gの本体ここまで
Lret	mov	esp, ebp
	pop	ebp
	ret
