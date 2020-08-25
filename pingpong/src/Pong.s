align 4
segment .data
segment .bss
segment .text
extern  switch_to_sched
extern  runqput
extern  malloc
extern Ping_ping 
; global methods declare
; global Pong_methods
global Pong_pong 
global Pong_init 
; global methods declare

Pong_init:
Pong_init_realloc:
    PUSH DWORD 4096
    CALL malloc
    ADD  ESP, 4
    CMP  DWORD EAX, 0
    JE   Pong_init_realloc
    MOV  DWORD [EAX + 4096 - 1*4], 0    ; other 
    MOV  DWORD [EAX + 4096 - 2*4], 0    ; bounces 
    MOV  DWORD [EAX + 4096 - 24 + 12], 0    ; system_next
    MOV  DWORD [EAX + 4096 - 24 + 8], 0     ; lock
    LEA  ECX,  [EAX + 4096 - 24 - 4]
    MOV  DWORD [EAX + 4096 - 24 + 4], ECX   ; Pre ESP
    LEA  ECX,  [EAX + 4096 - 24]
    MOV  DWORD [EAX + 4096 - 24], ECX       ; Pre EBP
    LEA  ECX,  [Pong_doactions]
    MOV  DWORD [EAX + 4096 - 24 - 4], ECX   ; Pong_doactions
    ADD  DWORD EAX, 4096 - 24
    PUSH DWORD EBP
    PUSH DWORD EAX
    CALL runqput
    POP  DWORD EAX
    POP  DWORD EBP
    ; init code goes here

    ; Pong_init_code

 
    ; init code ends here
    RET
Pong_doactions:
Pong_doactions_start:
    PUSH DWORD EBP
    ; CALL Pong_action
    CALL Pong_ping
    POP  EBP
    CALL switch_to_sched
    JMP  Pong_doactions_start
    RET  ; never be here

;define method Pong_pong
Pong_pong:
Pong_pong_start:
    MOV  DWORD ECX, [ESP + 4 + 4*2]   ; + 4 * num(para)
Pong_pong_checklock:
    MOV  DWORD EAX, 1           ;lock
    XCHG EAX, [ECX + 8]
    CMP  DWORD EAX, 0
    JNE  Pong_pong_suspend
Pong_pong_checkguard:
    ; method guard starts here
	JMP Pong_pong_succeed
    ; method guard ends here
Pong_pong_checkguard_fail:
    MOV  DWORD [ECX + 8], 0     ; unlock
Pong_pong_suspend:
    PUSH DWORD EBP
    CALL runqput
    POP  EBP
    CALL switch_to_sched
    JMP  Pong_pong_start
Pong_pong_succeed:
    ; method body starts here
    	;_startproc
; %bb.0:
	push	edi
	;_def_cfa_offset 8
	push	esi
	;_def_cfa_offset 12
	sub	esp, 20
	;_def_cfa_offset 32
	;_offset esi, -12
	;_offset edi, -8
	mov	eax, dword   [esp + 44]
	mov	ecx, dword   [esp + 40]
	mov	edx, dword   [esp + 36]
	mov	esi, dword   [esp + 32]
	mov	dword   [esp + 16], eax
	mov	eax, dword   [esp + 32]
	mov	edi, dword   [esp + 40]
	mov	dword   [edi + 16], eax
	mov	eax, dword   [esp + 36]
	mov	edi, dword   [esp + 40]
	mov	dword   [edi + 20], eax
	mov	dword   [esp + 12], esi ; 4-byte Spill
	mov	dword   [esp + 8], ecx ; 4-byte Spill
	mov	dword   [esp + 4], edx ; 4-byte Spill
	add	esp, 20
	pop	esi
	pop	edi
	;ret
.Lfunc_end0:
	;.size	Pong_pong, .Lfunc_end0-Pong_pong

    ; method body ends here
Pong_pong_unlock:
    MOV  DWORD ECX, [ESP + 4 + 4*2]   ; + 4 * num(para)
    PUSH DWORD EAX              ; for the return val
    PUSH DWORD EBP
    PUSH DWORD ECX
    CALL runqput
    POP  DWORD ECX
    POP  DWORD EBP
    POP  DWORD EAX              ; for the return val
    ; unlock
    MOV DWORD [ECX + 8], 0
Pong_pong_ret:
    RET
 
; define action
; Pong: ping 
Pong_ping:
Pong_ping_start:
    MOV  DWORD ECX, [ESP + 4]
    ; action guard start
    MOV DWORD EDX, [ECX + 20]
    CMP EDX, 0
    JG Pong_ping_succeed

    ; action guard end
Pong_ping_checkguard_fail:
	RET
Pong_ping_succeed:
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
	mov	edx, dword   [esp + 32]
	mov	edx, dword   [edx + 16]
	mov	esi, dword   [esp + 16]
	mov	dword   [esp], eax
	mov	dword   [esp + 4], edx
	mov	dword   [esp + 8], esi
	mov	dword   [esp + 12], ecx ; 4-byte Spill
	call	Ping_ping
	mov	eax, dword   [esp + 32]
	mov	dword   [eax + 20], 0
	add	esp, 24
	pop	esi
	;ret
.Lfunc_end1:
	;.size	Pong_ping, .Lfunc_end1-Pong_ping

    ; action body end
    RET