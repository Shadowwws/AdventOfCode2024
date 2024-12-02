%define SYS_EXIT 60
%define SYS_WRITE 1
%define STDOUT 1
%define SYS_READ 0
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define STDIN 0

section .rodata
input:
  incbin "2.in"
inputend:

section .data
list: TIMES 16 dq 0
listend:

section .text
global _start
_start:
  
    mov rsi, input ; input
    xor r15, r15 ; final result
    mov rbp, rsp
    mov rdi, list
    mov r12, 1

_solve:

    mov r14, _solve
    cmp rsi, inputend ; end of file
    jae _itoa

 .setup:
    xor rax, rax

 .inner:
    imul rax, 10
    movzx rbx, byte [rsi]
    add rax, rbx
    sub rax, 48
    inc rsi
    cmp byte [rsi], 32
    je .check
    cmp byte [rsi], 10
    jne .inner
    mov r14, _count ; when at the end of the line, we check the rapport

  .check:
    inc rsi
    mov [rdi], rax ; add the number to the list
    add rdi, 8
    jmp r14

_check:

    pop rcx ; return address
    pop r8 ; first number of the rapport
    mov r11, 2 ; number for wrong number (cmovcc doesn't like immediate values)
    mov r14, -1 ; initial value

  .thecheck:
    xor r13, r13 ; increasing/decreasing/wrong value
    cmp rsp, rbp ; end of the rapport
    je .good
    pop rax ; next number
    mov r9, r8
    sub r9, rax 
    cmovl r13, r12 ; increasing or decreasing
    mov r10, r9    ; abs()
    neg r9         ; abs()
    cmovl r9, r10  ; abs() 
    cmp r9, 1 ; compare distance betweent the two numbers
    cmovl r13, r11 

    cmp r9, 3 ; compare distance betweent the two numbers
    cmovg r13, r11

    cmp r13, r11 ; if it's a wrong number => not good
    je .notgood

    cmp r14, -1
    cmove r14, r13

    cmp r14, r13 ; compare if the increase/decrease match
    jne .notgood
    mov r8, rax
    mov r14, r13
    jmp .thecheck

  .notgood:
    mov rsp, rbp ; don't forget to reset the stack (rapport)
    mov rax, 1 ; not good
    push rcx
    ret

  .good:
    xor rax, rax ; good
    push rcx
    ret

_count:

    mov rdi, list ; our rapport
    mov rdx, -1 ; index of the value we'll not use (start at -1 to have a run with the full list)
    xor rcx, rcx ; index of the current value we push

  .fill:
    cmp qword [rdi], 0
    je .check
    cmp rcx, rdx ; skip the one value
    je .skip
    push qword [rdi] ; add the number to the list we'll check

  .skip:
    add rdi, 8
    inc rcx
    jmp .fill

  .check:
    call _check
    cmp rax, 0
    je .good
    inc rdx
    mov rdi, list ; reset the pointer
    cmp qword [rdi + 8*rdx], 0 ; end of the rapport
    je .notgood
    xor rcx, rcx
    jmp .fill

  .good:
    inc r15

  .notgood:
    mov rsp, rbp
    jmp _resetlist

_resetlist: ;  name self explanatory
    mov rdi, list

  .inner:
    cmp rdi, listend
    jae .end
    mov qword [rdi], 0
    add rdi, 8
    jmp .inner

  .end:
    mov rdi, list
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
