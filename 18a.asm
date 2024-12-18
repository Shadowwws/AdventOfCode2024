section .rodata
input:
  incbin "18.in"
inputend:

section .data
grid: TIMES 71*71 db '.'

visited: TIMES 71*71 dd 1000000
score: dq 1000000

section .text
global _start
_start:
    mov rsi, input
    mov rcx, 1024

_fillgrid:
    call _atoi
    inc rsi
    mov r8, rax
    call _atoi
    inc rsi
    mov r9, rax
    imul r9, 71
    add r9, r8

    mov byte [grid+r9], '#'
    dec rcx
    jnz _fillgrid


    push 0
    push 0
    push 0
    mov rsi, grid
    call _path
    jmp _itoa

_path:
    push rbp
    mov rbp, rsp
    push r8
    push r9
    push r10
    push r11
    push r12
    push rax

    mov r8, [rbp+16]
    mov r9, [rbp+24]
    mov rax, [rbp+32]

    mov r12, r9
    imul r12, 71
    add r12, r8
    cmp r12, 5040
    ;cmp r12, 48
    je .foundend
    
    inc rax

  .findnextnode:
  ; right
    mov r10, r8
    mov r11, r9
    add r10, 1
    cmp r10, 71
    je .down
    mov r12, r11
    imul r12, 71
    add r12, r10
    cmp eax, [visited + 4*r12]
    jae .down
    mov [visited + 4*r12], eax
    cmp byte [rsi+r12], "#"
    je .down
    push rax
    push r11
    push r10
    call _path
    add rsp, 24

  .down:
    mov r10, r8
    mov r11, r9
    add r11, 1
    cmp r11, 71
    je .left
    mov r12, r11
    imul r12, 71
    add r12, r10
    cmp eax, [visited + 4*r12]
    jae .left
    mov [visited + 4*r12], eax
    cmp byte [rsi+r12], "#"
    je .left
    push rax
    push r11
    push r10
    call _path
    add rsp, 24

  .left:
    mov r10, r8
    mov r11, r9
    sub r10, 1
    cmp r10, 0
    jl .up
    mov r12, r11
    imul r12, 71
    add r12, r10
    cmp eax, [visited + 4*r12]
    jae .up
    mov [visited + 4*r12], eax
    cmp byte [rsi+r12], "#"
    je .up
    push rax
    push r11
    push r10
    call _path
    add rsp, 24

  .up:
    mov r10, r8
    mov r11, r9
    sub r11, 1
    cmp r11, 0
    jl .dontupdatescore
    mov r12, r11
    imul r12, 71
    add r12, r10
    cmp eax, [visited + 4*r12]
    jae .dontupdatescore
    mov [visited + 4*r12], eax
    cmp byte [rsi+r12], "#"
    je .dontupdatescore
    push rax
    push r11
    push r10
    call _path
    add rsp, 24
    jmp .dontupdatescore

  .foundend:
    cmp [score], rax
    jl .dontupdatescore
    mov [score], rax
    
  .dontupdatescore:
    pop rax
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rbp
    ret

_atoi: ; Read number

 .setup:
    xor rax, rax

 .inner:
    imul rax, 10
    movzx rbx, byte [rsi]
    add rax, rbx
    sub rax, 48
    inc rsi
    cmp byte [rsi], ','
    je .end
    cmp byte [rsi], 10
    jne .inner

  .end:
    ret

; Following part from alajpie, just to print the result, pretty fast and independant from the challenge.
_itoa:
    mov rbp, rsp
    mov r10, 10
    sub rsp, 22
                       
    mov byte [rbp-1], 10  
    lea r12, [rbp-2]
    ; r12: string pointer
    mov rax, [score]

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