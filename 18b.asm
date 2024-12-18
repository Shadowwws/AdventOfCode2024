section .rodata
input:
  incbin "18.in"
inputend:

section .data
grid: TIMES 71*71 db '.'

visited: TIMES 71*71 dd 1000000
visitedend:
score: dq 1000000

section .text
global _start
_start:
    mov rdi, input
    mov rcx, 1024
    mov rsi, grid

_fillgrid:
    mov qword [score], 1000000
    call _atoi
    inc rdi
    mov r8, rax
    call _atoi
    inc rdi
    mov r9, rax
    imul r9, 71
    add r9, r8

    mov byte [grid+r9], '#'

    push 0
    push 0
    push 0
    call _path
    call _resetvisited
    cmp qword [score], 1000000
    jne _fillgrid
    sub rdi, 6

    mov rax, 1
    mov rsi, rdi
    mov rdi, 1
    mov rdx, 6
    syscall
    jmp _end

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

    cmp qword [score], 1000000
    jne .dontupdatescore

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

_resetvisited:
    mov r10, visited

  .inner:
    mov dword [r10], 1000000
    add r10, 4
    cmp r10, visitedend
    jl .inner

    ret

_atoi: ; Read number

 .setup:
    xor rax, rax

 .inner:
    imul rax, 10
    movzx rbx, byte [rdi]
    add rax, rbx
    sub rax, 48
    inc rdi
    cmp byte [rdi], ','
    je .end
    cmp byte [rdi], 10
    jne .inner

  .end:
    ret

_end:
    mov rax, 60
    mov rdi, 0
    syscall