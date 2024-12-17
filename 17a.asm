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

_fillregisters:
    add rsi, 12

  .setup: ; convert to number
    xor rax, rax

 .inner:
    imul rax, 10
    movzx rbx, byte [rsi]
    add rax, rbx
    sub rax, 48
    inc rsi
    cmp byte [rsi], 10
    jne .inner

    mov r8, rax

    add rsi, 39

_run:

    mov rdi, rsi
    mov rax, [reg]

  .inner:
    cmp rsi, inputend
    jae _end
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
    call _print
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

_print:
    push rsi
    push rdi

    add rcx, 48
    push rcx

    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 1
    syscall

    mov qword [rsp], ','

    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 1
    syscall

    add rsp, 8

    pop rdi
    pop rsi
    ret

_end:
    mov rax, 60
    mov rdi, 0
    syscall