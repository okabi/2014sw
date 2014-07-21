	.file	"c_fun.c"
	.section	.rodata
.LC0:
	.string	"OK\n"
.LC1:
	.string	"NG\n"
	.text
	.globl	chk
	.type	chk, @function
chk:
.LFB0:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$24, %esp
	movl	8(%ebp), %eax
	cmpl	12(%ebp), %eax
	jne	.L2
	movl	$.LC0, %eax
	jmp	.L3
.L2:
	movl	$.LC1, %eax
.L3:
	movl	%eax, (%esp)
	call	printf
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE0:
	.size	chk, .-chk
	.globl	vv
	.data
	.align 32
	.type	vv, @object
	.size	vv, 40
vv:
	.long	3
	.long	5
	.long	1
	.long	8
	.long	7
	.long	6
	.long	2
	.long	10
	.long	4
	.long	9
	.text
	.globl	v
	.type	v, @function
v:
.LFB1:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	movl	8(%ebp), %eax
	movl	vv(,%eax,4), %eax
	popl	%ebp
	.cfi_def_cfa 4, 4
	.cfi_restore 5
	ret
	.cfi_endproc
.LFE1:
	.size	v, .-v
	.globl	set_v
	.type	set_v, @function
set_v:
.LFB2:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	movl	8(%ebp), %eax
	movl	12(%ebp), %edx
	movl	%edx, vv(,%eax,4)
	popl	%ebp
	.cfi_def_cfa 4, 4
	.cfi_restore 5
	ret
	.cfi_endproc
.LFE2:
	.size	set_v, .-set_v
	.ident	"GCC: (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3"
	.section	.note.GNU-stack,"",@progbits
