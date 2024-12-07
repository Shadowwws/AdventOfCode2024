section .data
input:
  incbin "7.in"
inputend:

section .text
global _start
_start:

    mov rsi, input ; input
    mov rbp, rsp
    xor r15, r15 ; result

_atoi:

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
    cmp byte [rsi], ' '
    je .list
    cmp byte [rsi], ':'
    je .num
    cmp byte [rsi], 10
    jne .inner
    push rax
    jmp _test

  .num:
    mov r8, rax
    add rsi, 2
    jmp _atoi

  .list:
    push rax
    inc rsi
    jmp _atoi

_test:
    
    mov r9, rbp
    sub r9, 8 ; first element
    mov rax, [r9] ; we move the first element in rax, easier for computations
    sub r9, 8 ; next element

    ; compute the number of element in r10
    mov r10, rbp
    sub r10, rsp
    shr r10, 3 ; each number is 8 bytes so we divide by 8
    sub r10, 1 ; first element is already in
    
    ; compute the number of possibilities 3**r10 in rcx
    mov rcx, 1
  .power:
    imul rcx, 3
    dec r10
    jnz .power

    mov r14, 3 ; divider for rax later
    mov r11, rcx ; save the number

  .loop:
    cmp r9, rsp
    jl .check ; all list done

    push rax ; save rax because we need it for division
    mov rax, rcx
    div r14 ; compute rcx % 3 in rdx
    mov rcx, rax
    pop rax ; restore rax

    cmp rdx, 0 ; if rcx % 3 == 0 we add
    je .addsign

    cmp rdx, 1 ; if rcx % 3 == 1 we mul
    je .mulsign

    mov r12, 1 ; number used to multiply the result for our concat which is rax * power_of_10_above(r13) + r13
    mov r13, [r9] ; put number in register for comparison

  .concat: ; if rcx % 3 == 2 we concat
    imul r12, 10
    cmp r12, r13
    jle .concat ; find power of 10 above the number

    mul r12
    add rax, qword [r9]
    sub r9, 8
    jmp .loop

  .mulsign:
    mul qword [r9]
    sub r9, 8
    jmp .loop

  .addsign:
    add rax, qword [r9]
    sub r9, 8
    jmp .loop

  .check:
    cmp rax, r8 ; if we have the result then it's good
    je .good
    sub r11, 1 ; next possiblity
    cmp r11, -1
    je .end ; all possibilities done, then it's not good
    mov rcx, r11
    mov r9, rbp
    sub r9, 8
    mov rax, [r9] ; reset the number
    sub r9, 8
    jmp .loop

  .good:
    add r15, rax

  .end:
    mov rsp, rbp ; reset list
    inc rsi
    jmp _atoi

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