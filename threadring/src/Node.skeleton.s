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
    ;Node_pass_body
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
    ;Node_setNext_body
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
    ;Node_forward_body
    ; action body end
    RET