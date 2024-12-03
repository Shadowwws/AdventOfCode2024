%define SYS_EXIT 60
%define SYS_WRITE 1
%define STDOUT 1
%define SYS_READ 0
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define STDIN 0

section .rodata
input:
  incbin "3.in"
inputend:

mulstr: db "mul("

section .text
global _start
_start:
  
    mov rsi, input ; input
    xor r15, r15
    mov edi, dword [mulstr] ; string to match

_solve:
    cmp rsi, inputend
    je _itoa
    ;cmp dword [rsi], edi
    mov ebx, [rsi] ; compare if we match "mul("
    cmp ebx, edi
    je _atoi
    inc rsi
    jmp _solve

_atoi:
    add rsi, 4 ; go to the number
    mov r8, ',' ; first delimiter

 .setup:
    xor rax, rax

 .inner: ; read number
    imul rax, 10
    movzx rbx, byte [rsi]
    add rax, rbx
    sub rax, 48
    inc rsi
    cmp byte [rsi], r8b ; match delimiter => add number
    je .new
    cmp byte [rsi], '0' ; not a delimiter nor a number => corrupt instruction
    jl _solve
    cmp byte [rsi], '9' ; not a delimiter nor a number => corrupt instruction
    jg _solve
    jmp .inner

  .new:
    inc rsi
    push rax ; add the number
    cmp r8, ')' ; check if it the last delimiter => let's compute
    je _add
    mov r8, ')' ; change the delimiter
    jmp .setup

_add: ; result += mul
    pop rax
    pop rbx
    mul rbx
    add r15, rax
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
