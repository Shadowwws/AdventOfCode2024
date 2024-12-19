section .data
input:
  incbin "19.in"
inputend:

section .text
global _start
_start:
    mov rsi, input
    xor r15, r15
    mov rdi, rsi
    mov rbp, rsp

_parse:
  .inner:
    inc rdi
    cmp byte [rdi], 10
    je .end
    cmp byte [rdi], ","
    jne .inner

  .store:
    mov byte [rdi], 0
    push rsi
    add rdi, 2
    mov rsi, rdi
    jmp .inner

  .end:
    mov byte [rdi], 0
    push rsi
    add rdi, 2
    mov rsi, rdi

_solve:
    mov r8, rbp
    sub r8, 8
    mov r10, rsp
  .search:
    cmp rsi, inputend
    jae _itoa
    push rsi ; towel beginning
    mov rbx, 0 ; little "issolved" variable
    call _search
    add rsp, 8

  .nexttowels:
    inc rsi
    cmp byte [rsi], 10
    jne .nexttowels

    inc rsi
    jmp .search

_search:
    push rbp
    mov rbp, rsp
    push rsi
    push rdi
    push r9

    mov rsi, [rbp+16] ; current towel to create
    mov r9, r8 ; list of little towels
    cmp rbx, 1
    je .end

  .inner:
    cmp r9, r10 ; end of little towels list
    jl .end
    mov rdi, [r9] ; string
    mov rcx, 8
    repe cmpsb ; compare little and big
    dec rdi
    cmp byte [rdi], 0 ; it's a match
    jne .notfound

    dec rsi
    push rsi
    call _search ; remove the matched part and call again
    add rsp, 8
    inc rsi

  .notfound:
    dec rsi
    cmp byte [rsi], 10 ; hey, it's actually the end, so it's possible
    je .gotit

    sub r9, 8
    mov rsi, [rbp+16]
    jmp .inner

  .gotit:
    cmp rbx, 1
    je .end
    mov rbx, 1
    inc r15

  .end:
    pop r9
    pop rdi
    pop rsi
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