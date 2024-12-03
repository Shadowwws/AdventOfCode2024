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

dostr: db "do()"

dontstr: db "don't()",0

section .text
global _start
_start:
  
    mov rsi, input ; input
    xor r15, r15
    xor rbx, rbx
    xor r10, r10
    xor r11, r11
    mov r10d, dword [mulstr] ; string "mul(" to match
    mov r11d, dword [dostr] ; string "do()" to match
    mov r12, qword [dontstr] ; string "don't()" to match
    mov r14, 0 ; Value to use if we find a do()
    mov r9, 1 ; Value to use if we find a don't()
    mov r13, 0 ; Current do/don't value

_solve:
    cmp rsi, inputend
    je _itoa
    mov ebx, dword [rsi]
    cmp rbx, r10 ; test for mul(
    je .doI
    cmp rbx, r11 ; test for do()
    cmove r13, r14
    mov rbx, qword [rsi]
    ;and rbx, 0x00ffffffffffffff doesn't work for some reason
    shl rbx, 8
    shr rbx, 8 ; remove the last character read because "don't()" is only 7 char
    cmp rbx, r12 ; test for don't()
    cmove r13, r9
    inc rsi
    jmp _solve

  .doI:
    cmp r13, 0 ; if we last saw a "do()" we go
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
