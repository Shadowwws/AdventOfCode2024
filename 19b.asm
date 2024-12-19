section .data
input:
  incbin "19.in"
inputend:

cache: TIMES 128 dq -1
cacheend:

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
    push rsi ; beginning of the big towel
    push 0 ; score of the big towel
    push rsi ; current part of the big towel
    call _search
    add rsp, 8
    add r15, qword [rsp] ; add the score of the towel
    add rsp, 16
    call _resetcache

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
    push rax

    mov rsi, [rbp+16] ; current towel to create

    cmp byte [rsi], 10 ; we're at the end, so it's 1
    je .gotit

    mov rax, 0

    ; check if we have the score of this part in cache
    sub rsi, qword [rbp+32]
    cmp qword [cache+8*rsi], -1
    jne .gotcache

    mov r9, r8 ; list of little towels
    mov rsi, [rbp+16]

  .inner:
    cmp r9, r10 ; end of little towels list
    jl .end
    mov rdi, [r9] ; string
    mov rcx, 9 ; bigger than the size of the towels, not used
    repe cmpsb ; compare little and big towel
    dec rsi
    dec rdi
    cmp byte [rdi], 0 ; it's a match
    jne .notfound

    push qword [rbp+32]
    push rax
    push rsi
    call _search ; remove the part that matched and call again
    add rsp, 8
    add rax, qword [rsp] ; add score
    add rsp, 16

  .notfound: ; next little towel
    sub r9, 8
    mov rsi, [rbp+16]
    jmp .inner

  .gotcache:
    mov rax, qword [cache+8*rsi]
    jmp .end

  .gotit:
    mov rax, 1

  .end:
    mov rsi, [rbp+16]

    sub rsi, qword [rbp+32]
    mov qword [cache+8*rsi], rax ; update cache (even when not needed)
    mov [rbp+24], rax
    pop rax
    pop r9
    pop rdi
    pop rsi
    pop rbp
    ret

_resetcache:
    push r8
    mov r8, cache

  .inner:
    cmp r8, cacheend
    jae .end
    mov qword [r8], -1
    add r8, 8
    jmp .inner

  .end:
    pop r8
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