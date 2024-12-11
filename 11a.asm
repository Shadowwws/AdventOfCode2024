section .data
input:
  incbin "11.in"
inputend:

section .text
global _start
_start:
    mov rsi, input
    mov rbp, rsp
    xor r15, r15
  
_atoi: ; Read number

 .setup:
    xor rax, rax

 .inner:
    imul rax, 10
    movzx rbx, byte [rsi]
    add rax, rbx
    sub rax, 48
    inc rsi
    cmp byte [rsi], ' '
    je .list
    cmp byte [rsi], 10
    jne .inner
    push rax ; create a new stone on the stack
    mov [rsp+8], rsp
    push 0
    jmp _turns ; End of line, we can work on the stones

  .list: ; create a new stone on the stack
    cmp rbp, rsp
    je .first
    push rax
    mov [rsp+8], rsp ; link with the previous stone
    push 0
    inc rsi
    jmp _atoi

  .first: ; create a new stone on the stack
    push rax
    push 0
    inc rsi
    jmp _atoi

_turns:
  
    mov r10, 0
    mov r8, rbp
    sub r8, 8

  .turn:
    mov rax, [r8]
    cmp rax, 0
    je .zero

    call _numofdigits

    mov rdx, rcx
    and rdx, 1
    jz .even

    xor rdx, rdx
    imul rax, 2024 ; rule 3
    mov [r8], rax
    jmp .normalend

  .zero: ; rule 1
    mov qword [r8], 1
    
  .normalend: ; go to next stone
    sub r8, 8
    mov r8, [r8]
    cmp r8, 0
    jne .turn
    jmp .nextturn

  .even: ; rule 2, split in two by dividing by a power of 10, and create a new stone
    xor rdx, rdx
    shr rcx, 1
    call _power

    div rcx

    mov [r8], rax
    mov r9, [r8-8]

    push rdx ; new stone
    mov [r8-8], rsp
    push r9

    cmp r9, 0
    je .nextturn

    mov r8, r9

    cmp r8, 0
    jne .turn

  .nextturn: ; done a turn on all stones, go back to the first
    inc r10
    cmp r10, 25
    je _count
    mov r8, rbp
    sub r8, 8
    jmp .turn

_power: ; compute 10 ** rcx in rcx
    push rax

    mov rax, rcx
    mov rcx, 1

  .inner:
    imul rcx, 10
    dec rax
    jnz .inner

    pop rax
    ret

_numofdigits: ; count the number of digits
    mov r12, 1
    mov rcx, 0

  .inner:
    inc rcx
    imul r12, 10
    cmp r12, rax
    jle .inner

    ret

_count: ; count the number of stones
    mov r8, rbp
    sub r8, 8

  .l:
    inc r15
    mov r8, [r8-8]
    cmp r8, 0
    jne .l

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