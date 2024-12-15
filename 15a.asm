section .data
input:
  incbin "15.in"
inputend:


section .text
global _start
_start:
    
    mov rsi, input
    xor r15, r15 ; number of rounds
    mov r9, 51 ; width
    mov rdi, input

_parse:
    cmp byte [rsi], "@"
    je .robot

    cmp word [rsi], 2570 ; "\n\n"
    je .instructions

    inc rsi
    jmp _parse

  .robot:
    mov r8, rsi
    sub r8, input
    inc rsi
    jmp _parse

  .instructions:
    inc rsi
    jmp _play

_play:

  .inner:
    inc rsi
    cmp rsi, inputend
    je _count

    cmp byte [rsi], 10
    je .inner

    cmp byte [rsi], "<"
    je .left

    cmp byte [rsi], "^"
    je .up

    cmp byte [rsi], ">"
    je .right

  ; down

  .down:
    mov r10, r8
    add r10, r9
    cmp byte [rdi+r10], "."
    je .exchange

    cmp byte [rdi+r10], "#"
    je .inner

    mov r11, r10

  .searchdown:
    add r10, r9
    cmp byte [rdi+r10], "O"
    je .searchdown

    cmp byte [rdi+r10], "."
    je .move
    jmp .inner

  ; up

  .up:
    mov r10, r8
    sub r10, r9
    cmp byte [rdi+r10], "."
    je .exchange

    cmp byte [rdi+r10], "#"
    je .inner

    mov r11, r10

  .searchup:
    sub r10, r9
    cmp byte [rdi+r10], "O"
    je .searchup

    cmp byte [rdi+r10], "."
    je .move
    jmp .inner

  ; right
    
  .right:
    mov r10, r8
    add r10, 1
    cmp byte [rdi+r10], "."
    je .exchange

    cmp byte [rdi+r10], "#"
    je .inner

    mov r11, r10

  .searchright:
    add r10, 1
    cmp byte [rdi+r10], "O"
    je .searchright

    cmp byte [rdi+r10], "."
    je .move
    jmp .inner

  ; left

  .left:
    mov r10, r8
    sub r10, 1
    cmp byte [rdi+r10], "."
    je .exchange

    cmp byte [rdi+r10], "#"
    je .inner

    mov r11, r10

  .searchleft:
    sub r10, 1
    cmp byte [rdi+r10], "O"
    je .searchleft

    cmp byte [rdi+r10], "."
    je .move
    jmp .inner

  .exchange:
    movzx rax, byte [rdi+r8]
    movzx rbx, byte [rdi+r10]
    mov byte [rdi+r8], bl
    mov byte [rdi+r10], al
    mov r8, r10
    jmp .inner

  .move:
    mov byte [rdi+r10], "O"
    mov byte [rdi+r8], "."
    mov byte [rdi+r11], "@"
    mov r8, r11
    jmp .inner

_count:
    mov rsi, input
    xor rdx, rdx

  .inner:
    inc rsi
    cmp rsi, inputend
    je _itoa
    cmp byte [rsi], "O"
    jne .inner
    
    mov rax, rsi
    sub rax, rdi

    div r9

    imul rax, 100

    add r15, rax
    add r15, rdx
    xor rdx, rdx
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