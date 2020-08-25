	.text
	.intel_syntax noprefix
	.file	"Pong.c"
	.globl	Pong_pong               # -- Begin function Pong_pong
	.p2align	4, 0x90
	.type	Pong_pong,@function
Pong_pong:                              # @Pong_pong
	.cfi_startproc
# %bb.0:
	push	edi
	.cfi_def_cfa_offset 8
	push	esi
	.cfi_def_cfa_offset 12
	sub	esp, 20
	.cfi_def_cfa_offset 32
	.cfi_offset esi, -12
	.cfi_offset edi, -8
	mov	eax, dword ptr [esp + 44]
	mov	ecx, dword ptr [esp + 40]
	mov	edx, dword ptr [esp + 36]
	mov	esi, dword ptr [esp + 32]
	mov	dword ptr [esp + 16], eax
	mov	eax, dword ptr [esp + 32]
	mov	edi, dword ptr [esp + 40]
	mov	dword ptr [edi + 16], eax
	mov	eax, dword ptr [esp + 36]
	mov	edi, dword ptr [esp + 40]
	mov	dword ptr [edi + 20], eax
	mov	dword ptr [esp + 12], esi # 4-byte Spill
	mov	dword ptr [esp + 8], ecx # 4-byte Spill
	mov	dword ptr [esp + 4], edx # 4-byte Spill
	add	esp, 20
	pop	esi
	pop	edi
	ret
.Lfunc_end0:
	.size	Pong_pong, .Lfunc_end0-Pong_pong
	.cfi_endproc
                                        # -- End function
	.globl	Pong_ping               # -- Begin function Pong_ping
	.p2align	4, 0x90
	.type	Pong_ping,@function
Pong_ping:                              # @Pong_ping
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
	mov	edx, dword ptr [esp + 32]
	mov	edx, dword ptr [edx + 16]
	mov	esi, dword ptr [esp + 16]
	mov	dword ptr [esp], eax
	mov	dword ptr [esp + 4], edx
	mov	dword ptr [esp + 8], esi
	mov	dword ptr [esp + 12], ecx # 4-byte Spill
	call	Ping_ping
	mov	eax, dword ptr [esp + 32]
	mov	dword ptr [eax + 20], 0
	add	esp, 24
	pop	esi
	ret
.Lfunc_end1:
	.size	Pong_ping, .Lfunc_end1-Pong_ping
	.cfi_endproc
                                        # -- End function

	.ident	"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"
	.section	".note.GNU-stack","",@progbits
