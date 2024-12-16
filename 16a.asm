section .data
input:
  incbin "16.in"
inputend:

section .data
score: dq 800000
visited: TIMES 4*20022 dq 10000000

upper: dq 0
up: dq -142
right: dq 1
down: dq 142
left: dq -1
lower: dq 0

section .text
global _start
_start:
    mov rsi, input
    xor r15, r15

_findend:
    inc rsi
    cmp byte [rsi], "E"
    jne _findend

    mov r9, rsi
    sub r9, input

_findstart:
    inc rsi
    cmp byte [rsi], "S"
    jne _findstart

    mov r8, rsi
    sub r8, input

_solve:
    mov rsi, input
    push 1000
    push up
    push r8
    call _path
    jmp _itoa

_path:
    push rbp
    mov rbp, rsp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push rax
    push rbx

    mov rbx, 0
    mov r8, [rbp+16]
    mov r9, r8
    mov r10, [rbp+24]
    mov rax, [rbp+32]
    mov r11, [r10]
    lea r12, [r10+8]
    lea r14, [r10-8]
    cmp qword [r12], 0
    jne .lowerbound
    lea r12, [r10-24]

  .lowerbound:
    cmp qword [r14], 0
    jne .findnextnode
    lea r14, [r10+24]

  .findnextnode:
    inc rax
    cmp rax, [score]
    ja .dontupdatescore
    add r9, r11
    mov rcx, r9
    imul rcx, 32
    call _normalizedirection
    cmp rax, [visited + rcx]
    ja .dontupdatescore
    mov [visited + rcx], rax
    cmp byte [rsi+r9], "E"
    je .foundend
    cmp byte [rsi+r9], "#"
    je .sealpath
    cmp byte [rsi+r9], "0"
    je .dontupdatescore

  ; +90 degres

    mov r13, r9
    add r13, qword [r12]
    cmp byte [rsi+r13], "."
    jne .continue
    add rax, 1000
    cmp rax, [score]
    ja .dontupdatescore
    mov byte [rsi+r9], "0"
    push rax
    push r12
    push r9
    call _path
    add rsp, 24
    sub rax, 1000
    mov byte [rsi+r9], "."
    mov rbx, 1

  .continue:

  ; - 90 degre

    mov r13, r9
    add r13, qword [r14]
    cmp byte [rsi+r13], "."
    jne .next
    add rax, 1000
    cmp rax, [score]
    ja .dontupdatescore
    mov byte [rsi+r9], "0"
    push rax
    push r14
    push r9
    call _path
    add rsp, 24
    sub rax, 1000
    mov byte [rsi+r9], "."
    mov rbx, 1

  .next:
    jmp .findnextnode

  .sealpath:
    cmp rbx, 1
    je .dontupdatescore
    mov r9, r8
    add r9, r11
    ;add qword [calls], 1
    mov byte [rsi+r9], "#"
    ;call _draw
    jmp .dontupdatescore

  .foundend:
    cmp [score], rax
    jl .dontupdatescore
    mov [score], rax
    
  .dontupdatescore:
    pop rbx
    pop rax
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rbp
    ret

_normalizedirection:
    cmp r10, up
    jne .notup
    add rcx, 0
    ret

  .notup:
    cmp r10, right
    jne .notright
    add rcx, 8
    ret

  .notright:
    cmp r10, down
    jne .notdown
    add rcx, 16
    ret

  .notdown:
    add rcx, 24
    ret

; Following part from alajpie, just to print the result, pretty fast and independant from the challenge.
_itoa:
    mov rbp, rsp
    mov r10, 10
    sub rsp, 22
                       
    mov byte [rbp-1], 10  
    lea r12, [rbp-2]
    ; r12: string pointer
    mov rax, [score]

 .loop:
    xor edx, edx
    div r10
    add rdx, 48
    mov [r12], dl
    dec r12
    cmp r12, rsp
    jne .loop

    mov r9, rsp
    mov r11, 22
 .trim:
    inc r9
    dec r11
    cmp byte [r9], 48
    je .trim

    mov rax, 1
    mov rdi, 1
    mov rsi, r9
    mov rdx, r11
    syscall

    mov rax, 60
    mov rdi, 0
    syscall