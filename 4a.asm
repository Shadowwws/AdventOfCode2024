%define SYS_EXIT 60
%define SYS_WRITE 1
%define STDOUT 1
%define SYS_READ 0
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define STDIN 0

section .rodata
input:
  incbin "4.in"
inputend:

section .text
global _start
_start:
  
    mov rsi, input ; input
    dec rsi
    xor r15, r15

_solve:
    inc rsi
    cmp rsi, inputend
    je _itoa
    jmp _search

_search:

  .horizontalright:
    mov rax, rsi
    add rax, 3
    cmp rax, inputend
    jae .horizontalleft
    mov bl, [rsi]
    cmp bl, "X"
    jne .horizontalleft
    mov bl, [rsi+1]
    cmp bl, "M"
    jne .horizontalleft
    mov bl, [rsi+2]
    cmp bl, "A"
    jne .horizontalleft
    mov bl, [rsi+3]
    cmp bl, "S"
    jne .horizontalleft
    inc r15

  .horizontalleft:
    mov rax, rsi
    sub rax, 3
    cmp rax, input
    jl .verticaldown
    mov bl, [rsi]
    cmp bl, "X"
    jne .verticaldown
    mov bl, [rsi-1]
    cmp bl, "M"
    jne .verticaldown
    mov bl, [rsi-2]
    cmp bl, "A"
    jne .verticaldown
    mov bl, [rsi-3]
    cmp bl, "S"
    jne .verticaldown
    inc r15

  .verticaldown:
    mov rax, rsi
    add rax, 423
    cmp rax, inputend
    jae .verticalup
    mov bl, [rsi]
    cmp bl, "X"
    jne .verticalup
    mov bl, [rsi+141]
    cmp bl, "M"
    jne .verticalup
    mov bl, [rsi+282]
    cmp bl, "A"
    jne .verticalup
    mov bl, [rsi+423]
    cmp bl, "S"
    jne .verticalup
    inc r15

  .verticalup:
    mov rax, rsi
    sub rax, 423
    cmp rax, input
    jl .diagonaleftup
    mov bl, [rsi]
    cmp bl, "X"
    jne .diagonaleftup
    mov bl, [rsi-141]
    cmp bl, "M"
    jne .diagonaleftup
    mov bl, [rsi-282]
    cmp bl, "A"
    jne .diagonaleftup
    mov bl, [rsi-423]
    cmp bl, "S"
    jne .diagonaleftup
    inc r15

  .diagonaleftup:
    mov rax, rsi
    sub rax, 426
    cmp rax, input
    jl .diagonaleftdown
    mov bl, [rsi]
    cmp bl, "X"
    jne .diagonaleftdown
    mov bl, [rsi-142]
    cmp bl, "M"
    jne .diagonaleftdown
    mov bl, [rsi-284]
    cmp bl, "A"
    jne .diagonaleftdown
    mov bl, [rsi-426]
    cmp bl, "S"
    jne .diagonaleftdown
    inc r15

  .diagonaleftdown:
    mov rax, rsi
    add rax, 420
    cmp rax, inputend
    jae .diagonalrightup
    mov bl, [rsi]
    cmp bl, "X"
    jne .diagonalrightup
    mov bl, [rsi+140]
    cmp bl, "M"
    jne .diagonalrightup
    mov bl, [rsi+280]
    cmp bl, "A"
    jne .diagonalrightup
    mov bl, [rsi+420]
    cmp bl, "S"
    jne .diagonalrightup
    inc r15

  .diagonalrightup:
    mov rax, rsi
    sub rax, 420
    cmp rax, input
    jl .diagonalrightdown
    mov bl, [rsi]
    cmp bl, "X"
    jne .diagonalrightdown
    mov bl, [rsi-140]
    cmp bl, "M"
    jne .diagonalrightdown
    mov bl, [rsi-280]
    cmp bl, "A"
    jne .diagonalrightdown
    mov bl, [rsi-420]
    cmp bl, "S"
    jne .diagonalrightdown
    inc r15

  .diagonalrightdown:
    mov rax, rsi
    add rax, 426
    cmp rax, inputend
    jae _solve
    mov bl, [rsi]
    cmp bl, "X"
    jne _solve
    mov bl, [rsi+142]
    cmp bl, "M"
    jne _solve
    mov bl, [rsi+284]
    cmp bl, "A"
    jne _solve
    mov bl, [rsi+426]
    cmp bl, "S"
    jne _solve
    inc r15
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
