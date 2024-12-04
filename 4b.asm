%define SYS_EXIT 60
%define SYS_WRITE 1
%define STDOUT 1
%define SYS_READ 0
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define STDIN 0

section .rodata
input:
  incbin "4.in"
inputend:

section .text
global _start
_start:
  
    mov rsi, input ; input
    dec rsi
    xor r15, r15

_solve:
    inc rsi
    cmp rsi, inputend
    je _itoa
    jmp _search

_search:

    cmp byte [rsi], "A"
    jne _solve

    mov rax, rsi
    sub rax, 142
    cmp rax, input
    jl _solve

    mov rax, rsi
    add rax, 142
    cmp rax, inputend
    jae _solve

  .left:
    cmp byte [rsi-142], "M"
    jne .right

    cmp byte [rsi-140], "S"
    jne .right

    cmp byte [rsi+140], "M"
    jne .right

    cmp byte [rsi+142], "S"
    jne .right

    inc r15
    jmp _solve

  .right:

    cmp byte [rsi-142], "S"
    jne .up

    cmp byte [rsi-140], "M"
    jne .up

    cmp byte [rsi+140], "S"
    jne .up

    cmp byte [rsi+142], "M"
    jne .up

    inc r15
    jmp _solve

  .up:
    cmp byte [rsi-142], "M"
    jne .down

    cmp byte [rsi-140], "M"
    jne .down

    cmp byte [rsi+140], "S"
    jne .down

    cmp byte [rsi+142], "S"
    jne .down

    inc r15
    jmp _solve

  .down:
    cmp byte [rsi-142], "S"
    jne _solve

    cmp byte [rsi-140], "S"
    jne _solve

    cmp byte [rsi+140], "M"
    jne _solve

    cmp byte [rsi+142], "M"
    jne _solve

    inc r15
    jmp _solve

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
