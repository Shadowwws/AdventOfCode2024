section .data
input:
  incbin "6.in"
inputend:

section .text
global _start
_start:

    mov rsi, input ; input
    mov rbp, rsp
    xor r15, r15 ; result

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

    push r8
    push r9

    xor r10, r10 ; guard direction ; 0 = UP, 1 = RIGHT, 2 = DOWN, 3 = LEFT

    xor r14, r14 ; to reset direction

_solve: ; Original path of the guard

    mov rcx, r8
    imul rcx, 131
    add rcx, r9 ; curr coord

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

    cmp r8, 130
    jae _itoa
    cmp r9, 130
    jae _itoa

    cmp r8, 0
    jl _itoa

    cmp r9, 0
    jl _itoa

    mov r13, r11
    imul r13, 131
    add r13, r12 ; next coord
    
    cmp byte [rsi+r13], "#" ; we turn
    je .turn

    cmp byte [rsi+rcx], "X" ; we've already been here
    je .rerun

    mov r13, rcx

    call _test ; we add an obstacle where we are, so we don't try useless obstacle

    mov byte [rsi+r13], "X" ; state that we were here

  .rerun:

    mov r8, r11
    mov r9, r12
    jmp _solve

  .turn:
    inc r10 ; change direction
    cmp r10, 4 ; cheap %4
    cmove r10, r14
    jmp _solve

_test: ; Run the guard path with a new obstacle
    
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13

    mov r8, [rbp-8]
    mov r9, [rbp-16]

    mov rax, r13 ; new obstacle
    xor r10, r10

    mov rbx, rsp ; save rsp

  .loop:

    mov rcx, r8
    imul rcx, 131
    add rcx, r9 ; curr coord

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

    cmp r11, 130 ; oob
    jae .end
    cmp r12, 130 ; oob
    jae .end

    cmp r11, 0 ; oob
    jl .end
    cmp r12, 0 ; oobs
    jl .end

    mov r13, r11
    imul r13, 131
    add r13, r12 ; next coord
    
    cmp byte [rsi+r13], "#" ; we turn
    je .turn

    cmp r13, rax ; new obstacle, we turn
    je .turn

    mov r8, r11
    mov r9, r12
    jmp .loop

  .turn:
    shl rcx, 3
    add rcx, r10 ; compute the coord + the direction

    call _detectloop ; detect if we've already been here
    cmp rax, 0 ; yes ? => then it's a loop
    je .good

    push rcx ; add current coord

    inc r10
    cmp r10, 4
    cmove r10, r14
    jmp .loop

  .good:
    inc r15 ; increase loop counter

  .end:
    mov rsp, rbx
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8

    ret

_detectloop: ; loop over past coords to see if we've been here
    mov rdi, rsp

  .loop:
    cmp rdi, rbx
    je .notfound
    cmp [rdi], rcx
    je .found
    add rdi, 8
    jmp .loop

  .found:
    mov rax, 0

  .notfound:
    ret

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