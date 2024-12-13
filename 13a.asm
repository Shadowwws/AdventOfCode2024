section .rodata
input:
  incbin "13.in"
inputend:

section .data
A: TIMES 2 dq 0
B: TIMES 2 dq 0
goal: TIMES 2 dq 0
varend:

section .text
global _start
_start:

    mov rsi, input ; input
    mov rbp, rsp
    xor r15, r15 ; result

_parse:
    mov rdi, A

  .inner:
    cmp rsi, inputend
    je _compute
    ja _itoa

    cmp byte [rsi], 10
    je _compute

    cmp byte [rsi], '+'
    je .readint

    cmp byte [rsi], '='
    je .readint

    inc rsi
    jmp .inner

  .readint:
    inc rsi
    call _atoi
    inc rsi
    mov [rdi], rax
    add rdi, 8
    jmp .inner

_atoi: ; Read number

 .setup:
    xor rax, rax

 .inner:
    imul rax, 10
    movzx rbx, byte [rsi]
    add rax, rbx
    sub rax, 48
    inc rsi
    cmp byte [rsi], ','
    je .end
    cmp byte [rsi], 10
    jne .inner

  .end:
    ret 

_compute: ; solving the equation like a matrix

    mov rax, [A]

  .first:
    mul qword [B+8] 

    mov rbx, rax

    mov rax, [B]
    mul qword [A+8]

    sub rbx, rax

    mov rax, rbx    ; abs()
    neg rbx         ; abs()
    cmovl rbx, rax  ; abs()

    mov rax, [goal]
    mul qword [B+8]

    mov rcx, rax

    mov rax, [goal+8]
    mul qword [B]

    sub rcx, rax

    mov rax, rcx    ; abs()
    neg rcx         ; abs()
    cmovl rcx, rax  ; abs()

    mov rax, rcx

    xor rdx, rdx
    div rbx ; rax = x1

  .second:
    cmp rdx, 0
    jne .notpossible

    push rax

    mul qword [A+8]

    mov rcx, rax

    mov rax, [goal+8]

    sub rax, rcx

    mov rbx, rax    ; abs()
    neg rax         ; abs()
    cmovl rax, rbx  ; abs()

    xor rdx, rdx
    div qword [B+8]

    cmp rdx, 0
    jne .notpossible

  .end:
    add r15, rax
    pop rax
    imul rax, 3
    add r15, rax

  .notpossible:
    inc rsi
    jmp _parse


; Following part from alajpie, just to print the result, pretty fast and independant from the challenge.
_itoa:
    mov rbp, rsp
    mov r10, 10
    sub rsp, 22
                       
    mov byte [rbp-1], 10  
    lea r12, [rbp-2]
    ; r12: string pointer
    mov rax, r15

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