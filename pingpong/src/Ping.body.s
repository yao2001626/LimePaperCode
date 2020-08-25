	.text
	.intel_syntax noprefix
	.file	"Ping.c"
	.globl	Ping_ping               # -- Begin function Ping_ping
	.p2align	4, 0x90
	.type	Ping_ping,@function
Ping_ping:                              # @Ping_ping
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
	.size	Ping_ping, .Lfunc_end0-Ping_ping
	.cfi_endproc
                                        # -- End function
	.globl	Ping_pong               # -- Begin function Ping_pong
	.p2align	4, 0x90
	.type	Ping_pong,@function
Ping_pong:                              # @Ping_pong
	.cfi_startproc
# %bb.0:
	push	edi
	.cfi_def_cfa_offset 8
	push	esi
	.cfi_def_cfa_offset 12
	sub	esp, 36
	.cfi_def_cfa_offset 48
	.cfi_offset esi, -12
	.cfi_offset edi, -8
	mov	eax, dword ptr [esp + 52]
	mov	ecx, dword ptr [esp + 48]
	mov	dword ptr [esp + 32], eax
	mov	eax, dword ptr [esp + 48]
	mov	edx, dword ptr [esp + 48]
	mov	edx, dword ptr [edx + 20]
	sub	edx, 1
	mov	esi, dword ptr [esp + 48]
	mov	esi, dword ptr [esi + 16]
	mov	edi, dword ptr [esp + 32]
	mov	dword ptr [esp], eax
	mov	dword ptr [esp + 4], edx
	mov	dword ptr [esp + 8], esi
	mov	dword ptr [esp + 12], edi
	mov	dword ptr [esp + 28], ecx # 4-byte Spill
	call	Pong_pong
	mov	eax, dword ptr [esp + 48]
	mov	dword ptr [eax + 20], 0
	add	esp, 36
	pop	esi
	pop	edi
	ret
.Lfunc_end1:
	.size	Ping_pong, .Lfunc_end1-Ping_pong
	.cfi_endproc
                                        # -- End function

	.ident	"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"
	.section	".note.GNU-stack","",@progbits
