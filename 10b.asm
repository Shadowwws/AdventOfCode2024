section .rodata
input:
  incbin "10.in"
inputend:

section .data
done: TIMES 3724 db 0
donend:

%define up r10
%define down r11
%define right r12
%define left r13

section .text
global _start
_start:

    mov rsi, input ; input
    mov rbp, rsp
    xor r8, r8
    xor r15, r15 ; result
    mov up, -61
    mov down, 61
    mov right, 1
    mov left, -1

_solve:
    cmp byte [rsi], '0'
    je .found

  .inner:
    inc rsi
    cmp rsi, inputend
    je _itoa
    cmp byte [rsi], '0'
    jne .inner

  .found:
    push rsi
    call _isgood
    jmp .inner

_isgood: ; [rbp+8] = start
    push rbp
    mov rbp, rsp
    push rax
    push rdi
    mov rax, [rbp+16]

    cmp byte [rax], '9'
    je .bingo

    movzx rdi, byte [rax]

  .up:
    lea rcx, [rax+up]
    cmp rcx, input
    jl .down
    movzx rbx, byte [rax+up]
    sub rbx, rdi
    cmp rbx, 1
    jne .down
    push rcx
    call _isgood
    pop rcx

  .down:
    lea rcx, [rax+down]
    cmp rcx, inputend
    jae .right
    movzx rbx, byte [rax+down]
    sub rbx, rdi
    cmp rbx, 1
    jne .right
    push rcx
    call _isgood
    pop rcx

  .right:
    movzx rbx, byte [rax+right]
    lea rcx, [rax+right]
    sub rbx, rdi
    cmp rbx, 1
    jne .left
    push rcx
    call _isgood
    pop rcx

  .left:
    movzx rbx, byte [rax+left]
    lea rcx, [rax+left]
    sub rbx, rdi
    cmp rbx, 1
    jne .end
    push rcx
    call _isgood
    pop rcx
    jmp .end

  .bingo:
    inc r15

  .end:
    mov [rbp+16], rcx
    pop rdi
    pop rax
    pop rbp
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