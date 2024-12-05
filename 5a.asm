%define SYS_EXIT 60
%define SYS_WRITE 1
%define STDOUT 1
%define SYS_READ 0
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define STDIN 0

section .rodata
input:
  incbin "5.in"
inputend:

section .data
order: TIMES 10000 db 0 ; to stock the rules / order[first*100+second] = 1

section .text
global _start
_start:
  
    mov rsi, input ; input
    mov r14, order
    xor r15, r15

_parserules:

    cmp byte [rsi], 10 ; end of parsing
    je _prints

  .setup:
    xor rax, rax

  .inner:
    imul rax, 10
    movzx rbx, byte [rsi]
    add rax, rbx
    sub rax, 48
    inc rsi
    cmp byte [rsi], '|'
    je .middle
    cmp byte [rsi], 10
    jne .inner
    jmp .end

  .middle: ; read first number
    mov r8, rax
    inc rsi
    jmp .setup

  .end: ; read the second
    mov r9, r8
    imul r9, 100
    add r9, rax
    mov byte [r14+r9], 1 ; add the rule at first*100 + second
    inc rsi
    jmp _parserules

_prints:
    mov rbp, rsp
    inc rsi

  .setup:
    cmp rsi, inputend
    jae _itoa
    xor rax, rax

  .inner: ; read the prints
    imul rax, 10
    movzx rbx, byte [rsi]
    add rax, rbx
    sub rax, 48
    inc rsi
    cmp byte [rsi], ','
    je .store
    cmp byte [rsi], 10
    jne .inner
    jmp .check

  .store: ; store the prints in the stack
    push rax
    inc rsi
    jmp .setup

  .check:
    push rax
    mov r8, rbp
    sub r8, 8

  .checkouter: ; outer loop for the number we are checking
    cmp r8, rsp
    jle .good
    mov r9, r8
    sub r9, 8

  .checkinner: ; inner loop for the number we are checking to
    mov r10, [r8]
    mov r11, [r9]

    imul r11, 100
    add r11, r10

    cmp byte [r14+r11], 1 ; check if a rule against our order exists ( so if order[second*100+first] == 1)
    je .wrong

    sub r9, 8 ; next inner number
    cmp r9, rsp
    jae .checkinner

    sub r8, 8 ; next outer number
    jmp .checkouter

  .wrong: ; if order is wrong, reset stack and go to next prints
    mov rsp, rbp
    inc rsi
    jmp .setup

  .good:
    mov rax, rbp
    sub rax, rsp
    shr rax, 4
    imul rax, 8 ; take the middle value
    add r15, qword [rsp+rax] ; sum
    mov rsp, rbp
    inc rsi
    jmp .setup

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
