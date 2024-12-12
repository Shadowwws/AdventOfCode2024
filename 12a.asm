section .data
input:
  incbin "12.in"
inputend:

; push start to queue
; pop element, check up/down/right/left, each diff neighbour is +1 to its score, add the same neighbour to queue
; set visited element to -element or element +32 shit
; when queue is empty, all area done

section .text
global _start
_start:
    mov rsi, input
    mov rbp, rsp
    xor r15, r15
    mov r14, 141

_solve:
    cmp rsi, inputend
    je _itoa

    cmp byte [rsi], 10
    je .endl

    cmp byte [rsi], 'Z'
    ja .visited

    call _fill

  .endl:
  .visited:
    inc rsi
    jmp _solve

_fill: ; check the 4 neighbours, if a neighbour is with the same character then add to the queue. Modify the tile we processed so we don't process again
    push rbp
    mov rbp, rsp
    xor rcx, rcx
    xor rdx, rdx

    push rsi

  .inner:
    cmp rbp, rsp
    je .end

    pop rax
    movzx r9, byte [rax]
    mov r11, r9
    add r11, 65
    mov byte [rax], r11b
    inc rdx

  .checkup:
    mov r13, .checkright
    lea r8, [rax-141]
    cmp r8, input
    jl .notsame

    movzx r10, byte [r8]
    cmp r10, r9
    je .same

    sub r10, 65
    cmp r10, r9
    je .oldsame

    jmp .notsame

  .checkright:
    mov r13, .checkdown
    lea r8, [rax+1]

    movzx r10, byte [r8]
    cmp r10, r9
    je .same

    sub r10, 65
    cmp r10, r9
    je .oldsame

    jmp .notsame

  .checkdown:
    mov r13, .checkleft
    lea r8, [rax+r14]
    cmp r8, inputend
    jae .notsame

    movzx r10, byte [r8]
    cmp r10, r9
    je .same

    sub r10, 65
    cmp r10, r9
    je .oldsame

    jmp .notsame

  .checkleft:
    mov r13, .inner
    lea r8, [rax-1]
    cmp r8, input
    jl .notsame

    movzx r10, byte [r8]
    cmp r10, r9
    je .same

    sub r10, 65
    cmp r10, r9
    je .oldsame

    jmp .notsame

  .same:
    call _inqueueoradd
    jmp r13

  .notsame: ; neighbour with different value => perimeter += 1
    inc rcx
    jmp r13

  .oldsame:
    jmp r13

  .end:
    mov rax, rdx
    xor rdx, rdx
    mul rcx
    add r15, rax

    pop rbp
    ret

_inqueueoradd: ; add the new neighbour if it's not already in the queue
    mov r10, rsp
    sub r10, 8

  .inner:
    add r10, 8
    cmp r10, rbp
    ja .notfound
    cmp [r10], r8
    jne .inner

  .found:
    ret 

  .notfound:
    pop r10
    push r8
    jmp r10

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