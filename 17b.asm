section .rodata
input:
  incbin "17.in"
inputend:

reg: dq _run.xdv, _run.bxl, _run.bst, _run.jnz, _run.bxc, _run.out, _run.xdv, _run.xdv

section .text
global _start
_start:
    mov rsi, input
    xor r8, r8   ; A
    xor r9, r9   ; B
    xor r10, r10 ; C
    mov rbp, rsp

_readprogram:
  .inner:
    inc rsi
    cmp word [rsi], 2570
    jne .inner

    add rsi, 11
    mov rdi, rsi

  .read:
    cmp rsi, inputend
    jae _search
    movzx rax, byte [rsi]
    sub rax, 48
    push rax
    add rsi,2
    jmp .read

_run:
    mov r13, r14

  .inner:
    movzx rax, byte [rsi]
    sub rax, 48
    add rsi, 2
    movzx rbx, byte [rsi]
    sub rbx, 48

    mov r12, [reg+8*rax]
    jmp r12

  .xdv:
    mov r11, rax
    xor rdx, rdx
    mov rax, r8

    call _getcombo

  .actualdiv:
    mov rbx, 1
    shl rbx, cl
    div rbx

    cmp r11, 0
    je .adv
    cmp r11, 6
    je .bdv
    jmp .cdv

  .bxl:
    xor r9, rbx
    jmp .nextinstruction

  .bst:
    call _getcombo
    and rcx, 7
    mov r9, rcx
    jmp .nextinstruction

  .jnz:
    cmp r8, 0
    je .nextinstruction

    lea rsi, [rdi+rbx]
    jmp .inner

  .bxc:
    xor r9, r10
    jmp .nextinstruction

  .out:
    call _getcombo
    and rcx, 7
    cmp rcx, qword [r13]
    jne .nope
    sub r13, 8
    cmp r13, rsp
    je .good
    jmp .nextinstruction

  .adv:
    mov r8, rax
    jmp .nextinstruction

  .bdv:
    mov r9, rax
    jmp .nextinstruction
  
  .cdv:
    mov r10, rax
    jmp .nextinstruction

  .nextinstruction:
    add rsi, 2
    jmp .inner

  .good:
    mov rax, 0
    ret

  .nope:
    mov rax, 1
    ret

_getcombo:
    cmp rbx, 3
    jle .literal

    cmp rbx, 4
    cmove rcx, r8

    cmp rbx, 5
    cmove rcx, r9

    cmp rbx, 6
    cmove rcx, r10
    jmp .end

  .literal:
    mov rcx, rbx

  .end:
    ret

_search:
    sub rbp, 8
    mov r14, rsp
    xor r15, r15
  .inner:
    mov r8, r15
    xor r9, r9
    xor r10, r10
    mov rsi, rdi
    call _run
    cmp rax, 0
    je .good
    inc r15
    test r15, 0b111
    jz .reset
    jmp .inner

  .good:
    cmp r14, rbp
    je _itoa
    add r14, 8
    shl r15, 3
    jmp .inner

  .reset:
    shr r15, 3
    sub r14, 8
    jmp .inner

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