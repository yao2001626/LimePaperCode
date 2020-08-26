	.text
	.intel_syntax noprefix
	.file	"Node.c"
	.globl	Node_pass               # -- Begin function Node_pass
	.p2align	4, 0x90
	.type	Node_pass,@function
Node_pass:                              # @Node_pass
	.cfi_startproc
# %bb.0:
	push	esi
	.cfi_def_cfa_offset 8
	sub	esp, 16
	.cfi_def_cfa_offset 24
	.cfi_offset esi, -8
	mov	eax, dword ptr [esp + 32]
	mov	ecx, dword ptr [esp + 28]
	mov	edx, dword ptr [esp + 24]
	mov	dword ptr [esp + 8], ecx
	mov	ecx, dword ptr [esp + 24]
	mov	esi, dword ptr [esp + 8]
	mov	dword ptr [esi + 20], ecx
	mov	dword ptr [esp + 4], eax # 4-byte Spill
	mov	dword ptr [esp], edx    # 4-byte Spill
	add	esp, 16
	pop	esi
	ret
.Lfunc_end0:
	.size	Node_pass, .Lfunc_end0-Node_pass
	.cfi_endproc
                                        # -- End function
	.globl	Node_setNext            # -- Begin function Node_setNext
	.p2align	4, 0x90
	.type	Node_setNext,@function
Node_setNext:                           # @Node_setNext
	.cfi_startproc
# %bb.0:
	push	esi
	.cfi_def_cfa_offset 8
	sub	esp, 16
	.cfi_def_cfa_offset 24
	.cfi_offset esi, -8
	mov	eax, dword ptr [esp + 32]
	mov	ecx, dword ptr [esp + 28]
	mov	edx, dword ptr [esp + 24]
	mov	dword ptr [esp + 8], ecx
	mov	ecx, dword ptr [esp + 24]
	mov	esi, dword ptr [esp + 8]
	mov	dword ptr [esi + 16], ecx
	mov	dword ptr [esp + 4], eax # 4-byte Spill
	mov	dword ptr [esp], edx    # 4-byte Spill
	add	esp, 16
	pop	esi
	ret
.Lfunc_end1:
	.size	Node_setNext, .Lfunc_end1-Node_setNext
	.cfi_endproc
                                        # -- End function
	.globl	Node_forward            # -- Begin function Node_forward
	.p2align	4, 0x90
	.type	Node_forward,@function
Node_forward:                           # @Node_forward
	.cfi_startproc
# %bb.0:
	push	esi
	.cfi_def_cfa_offset 8
	sub	esp, 24
	.cfi_def_cfa_offset 32
	.cfi_offset esi, -8
	mov	eax, dword ptr [esp + 36]
	mov	ecx, dword ptr [esp + 32]
	mov	dword ptr [esp + 16], eax
	mov	eax, dword ptr [esp + 32]
	mov	eax, dword ptr [eax + 20]
	sub	eax, 1
	mov	edx, dword ptr [esp + 32]
	mov	edx, dword ptr [edx + 16]
	mov	esi, dword ptr [esp + 16]
	mov	dword ptr [esp], eax
	mov	dword ptr [esp + 4], edx
	mov	dword ptr [esp + 8], esi
	mov	dword ptr [esp + 12], ecx # 4-byte Spill
	call	Node_pass
	mov	eax, dword ptr [esp + 32]
	mov	dword ptr [eax + 20], 0
	add	esp, 24
	pop	esi
	ret
.Lfunc_end2:
	.size	Node_forward, .Lfunc_end2-Node_forward
	.cfi_endproc
                                        # -- End function

	.ident	"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"
	.section	".note.GNU-stack","",@progbits
