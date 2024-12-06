section .data
input:
  incbin "6.in"
inputend:

section .text
global _start
_start:

    mov rsi, input ; input

    mov r15, 1 ; result

_findguard:
    mov rdi, input ; used to search first index of guard
    mov rcx, inputend
    sub rcx, input ; size of input for search

    mov r8, rcx ; keep index in r8

    mov al, '^' ; guard character

    repne scasb ; search

    sub r8, rcx
    sub r8, 1 ; guard index, byte [rsi+r8], '^'

    mov byte [rsi+r8], "X"

    mov rax, r8
    mov bx, 131
    div bx
    mov r8, rax ; x coord
    mov r9, rdx ; y coord , real coord = x*131+y

    xor r10, r10 ; guard direction ; 0 = UP, 1 = RIGHT, 2 = DOWN, 3 = LEFT

    xor r14, r14 ; to reset direction

_solve:

    cmp r10, 0
    jne .notup

    mov r11, r8
    sub r11, 1 ; new x
    
    mov r12, r9 ; new y

    jmp .check

  .notup:
    cmp r10, 1
    jne .notright

    mov r11, r8 ; new x
    
    mov r12, r9
    add r12, 1 ; new y

    jmp .check

  .notright:
    cmp r10, 2
    jne .notdown

    mov r11, r8
    add r11, 1 ; new x
    
    mov r12, r9 ; new y

    jmp .check

  .notdown:

    mov r11, r8 ; new x
    
    mov r12, r9
    sub r12, 1 ; new y

  .check: 

    cmp r11, 130
    jae _itoa
    cmp r12, 130
    jae _itoa

    cmp r11, 0
    jl _itoa

    cmp r12, 0
    jl _itoa

    mov r13, r11
    imul r13, 131
    add r13, r12
    
    cmp byte [rsi+r13], "#" ; we turn
    je .turn

    cmp byte [rsi+r13], "X" ; we've already been here, so no count
    je .rerun

    inc r15 ; new place
    mov byte [rsi+r13], "X" ; leave our mark

  .rerun:

    mov r8, r11 ; update
    mov r9, r12 ; coords
    jmp _solve

  .turn:
    inc r10 ; change direction
    cmp r10, 4 ; cheap %4
    cmove r10, r14
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