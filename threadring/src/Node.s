align 4
segment .data
segment .bss
segment .text
extern  switch_to_sched
extern  runqput
extern  malloc
; global methods declare
; global Node_methods
global Node_pass 
global Node_setNext 
global Node_init 
; global methods declare

Node_init:
Node_init_realloc:
    PUSH DWORD 4096
    CALL malloc
    ADD  ESP, 4
    CMP  DWORD EAX, 0
    JE   Node_init_realloc
    MOV  DWORD [EAX + 4096 - 1*4], 0    ; next 
    MOV  DWORD [EAX + 4096 - 2*4], 0    ; token 
    MOV  DWORD [EAX + 4096 - 24 + 12], 0    ; system_next
    MOV  DWORD [EAX + 4096 - 24 + 8], 0     ; lock
    LEA  ECX,  [EAX + 4096 - 24 - 4]
    MOV  DWORD [EAX + 4096 - 24 + 4], ECX   ; Pre ESP
    LEA  ECX,  [EAX + 4096 - 24]
    MOV  DWORD [EAX + 4096 - 24], ECX       ; Pre EBP
    LEA  ECX,  [Node_doactions]
    MOV  DWORD [EAX + 4096 - 24 - 4], ECX   ; Node_doactions
    ADD  DWORD EAX, 4096 - 24
    PUSH DWORD EBP
    PUSH DWORD EAX
    CALL runqput
    POP  DWORD EAX
    POP  DWORD EBP
    ; init code goes here

    ; Node_init_code

 
    ; init code ends here
    RET
Node_doactions:
Node_doactions_start:
    PUSH DWORD EBP
    ; CALL Node_action
    CALL Node_forward
    POP  EBP
    CALL switch_to_sched
    JMP  Node_doactions_start
    RET  ; never be here

;define method Node_pass
Node_pass:
Node_pass_start:
    MOV  DWORD ECX, [ESP + 4 + 4*1]   ; + 4 * num(para)
Node_pass_checklock:
    MOV  DWORD EAX, 1           ;lock
    XCHG EAX, [ECX + 8]
    CMP  DWORD EAX, 0
    JNE  Node_pass_suspend
Node_pass_checkguard:
    ; method guard starts here
	JMP Node_pass_succeed
    ; method guard ends here
Node_pass_checkguard_fail:
    MOV  DWORD [ECX + 8], 0     ; unlock
Node_pass_suspend:
    PUSH DWORD EBP
    CALL runqput
    POP  EBP
    CALL switch_to_sched
    JMP  Node_pass_start
Node_pass_succeed:
    ; method body starts here
    	;_startproc
; %bb.0:
	push	esi
	;_def_cfa_offset 8
	sub	esp, 16
	;_def_cfa_offset 24
	;_offset esi, -8
	mov	eax, dword   [esp + 32]
	mov	ecx, dword   [esp + 28]
	mov	edx, dword   [esp + 24]
	mov	dword   [esp + 8], ecx
	mov	ecx, dword   [esp + 24]
	mov	esi, dword   [esp + 8]
	mov	dword   [esi + 20], ecx
	mov	dword   [esp + 4], eax ; 4-byte Spill
	mov	dword   [esp], edx    ; 4-byte Spill
	add	esp, 16
	pop	esi
	;ret
.Lfunc_end0:
	;.size	Node_pass, .Lfunc_end0-Node_pass

    ; method body ends here
Node_pass_unlock:
    MOV  DWORD ECX, [ESP + 4 + 4*1]   ; + 4 * num(para)
    PUSH DWORD EAX              ; for the return val
    PUSH DWORD EBP
    PUSH DWORD ECX
    CALL runqput
    POP  DWORD ECX
    POP  DWORD EBP
    POP  DWORD EAX              ; for the return val
    ; unlock
    MOV DWORD [ECX + 8], 0
Node_pass_ret:
    RET
 
;define method Node_setNext
Node_setNext:
Node_setNext_start:
    MOV  DWORD ECX, [ESP + 4 + 4*1]   ; + 4 * num(para)
Node_setNext_checklock:
    MOV  DWORD EAX, 1           ;lock
    XCHG EAX, [ECX + 8]
    CMP  DWORD EAX, 0
    JNE  Node_setNext_suspend
Node_setNext_checkguard:
    ; method guard starts here
	JMP Node_setNext_succeed
    ; method guard ends here
Node_setNext_checkguard_fail:
    MOV  DWORD [ECX + 8], 0     ; unlock
Node_setNext_suspend:
    PUSH DWORD EBP
    CALL runqput
    POP  EBP
    CALL switch_to_sched
    JMP  Node_setNext_start
Node_setNext_succeed:
    ; method body starts here
    	;_startproc
; %bb.0:
	push	esi
	;_def_cfa_offset 8
	sub	esp, 16
	;_def_cfa_offset 24
	;_offset esi, -8
	mov	eax, dword   [esp + 32]
	mov	ecx, dword   [esp + 28]
	mov	edx, dword   [esp + 24]
	mov	dword   [esp + 8], ecx
	mov	ecx, dword   [esp + 24]
	mov	esi, dword   [esp + 8]
	mov	dword   [esi + 16], ecx
	mov	dword   [esp + 4], eax ; 4-byte Spill
	mov	dword   [esp], edx    ; 4-byte Spill
	add	esp, 16
	pop	esi
	;ret
.Lfunc_end1:
	;.size	Node_setNext, .Lfunc_end1-Node_setNext

    ; method body ends here
Node_setNext_unlock:
    MOV  DWORD ECX, [ESP + 4 + 4*1]   ; + 4 * num(para)
    PUSH DWORD EAX              ; for the return val
    PUSH DWORD EBP
    PUSH DWORD ECX
    CALL runqput
    POP  DWORD ECX
    POP  DWORD EBP
    POP  DWORD EAX              ; for the return val
    ; unlock
    MOV DWORD [ECX + 8], 0
Node_setNext_ret:
    RET
 
; define action
; Node: forward 
Node_forward:
Node_forward_start:
    MOV  DWORD ECX, [ESP + 4]
    ; action guard start
    MOV DWORD EDX, [ECX + 20]
    CMP EDX, 0
    JG Node_forward_succeed

    ; action guard end
Node_forward_checkguard_fail:
	RET
Node_forward_succeed:
    ; action body start
    	;_startproc
; %bb.0:
	push	esi
	;_def_cfa_offset 8
	sub	esp, 24
	;_def_cfa_offset 32
	;_offset esi, -8
	mov	eax, dword   [esp + 36]
	mov	ecx, dword   [esp + 32]
	mov	dword   [esp + 16], eax
	mov	eax, dword   [esp + 32]
	mov	eax, dword   [eax + 20]
	sub	eax, 1
	mov	edx, dword   [esp + 32]
	mov	edx, dword   [edx + 16]
	mov	esi, dword   [esp + 16]
	mov	dword   [esp], eax
	mov	dword   [esp + 4], edx
	mov	dword   [esp + 8], esi
	mov	dword   [esp + 12], ecx ; 4-byte Spill
	call	Node_pass
	mov	eax, dword   [esp + 32]
	mov	dword   [eax + 20], 0
	add	esp, 24
	pop	esi
	;ret
.Lfunc_end2:
	;.size	Node_forward, .Lfunc_end2-Node_forward

    ; action body end
    RET