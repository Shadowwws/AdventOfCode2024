section .data
input:
  incbin "11.in"
inputend:

oldbrk: dq 0

section .text
global _start
_start:
    mov rsi, input
    mov rbp, rsp
    xor r15, r15
    mov r13, 0 ; previous stone
    mov rdi, 0 ; first stone
  
_atoi: ; Read number

 .setup:
    xor rax, rax

 .inner:
    imul rax, 10
    movzx rbx, byte [rsi]
    add rax, rbx
    sub rax, 48
    inc rsi
    cmp byte [rsi], ' '
    je .list
    cmp byte [rsi], 10
    jne .inner
    call _new ; create a new stone
    mov [r14], rax
    mov qword [r14+8], 0
    mov qword [r14+16], 1
    mov [r13+8], r14 ; link with previous stone
    jmp _turns ; End of line, we can work on the stones

  .list:
    cmp r13, 0
    je .first
    call _new ; create a new stone
    mov [r14], rax
    mov qword [r14+8], 0
    mov qword [r14+16], 1
    mov [r13+8], r14 ; link with previous stone
    inc rsi
    mov r13, r14  ; change previous
    jmp _atoi

  .first:
    call _new ; create a new stone
    mov [r14], rax
    mov qword [r14+8], 0
    mov qword [r14+16], 1
    inc rsi
    mov r13, r14 ; change previous
    mov rdi, r14 ; set first stone
    jmp _atoi


_turns:
  
    mov r10, 0
    mov r8, rdi

  .turn:
    mov rax, [r8]
    cmp rax, 0
    je .zero

    call _numofdigits

    mov rdx, rcx
    and rdx, 1
    jz .even

    xor rdx, rdx
    imul rax, 2024 ; rule 3
    mov [r8], rax
    jmp .normalend

  .zero: ; rule 1
    mov qword [r8], 1
    
  .normalend: ; go to next stone
    add r8, 8
    mov r8, [r8]
    cmp r8, 0
    jne .turn
    jmp .nextturn

  .even: ; rule 2, split in two by dividing by a power of 10, and create a new stone
    xor rdx, rdx
    shr rcx, 1
    call _power

    div rcx

    mov [r8], rax
    mov r9, [r8+8]

    call _new ; new stone

    mov [r14], rdx
    mov [r8+8], r14
    mov [r14+8], r9
    mov rdx, [r8+16]
    mov [r14+16], rdx

    cmp r9, 0
    je .nextturn

    mov r8, r9

    cmp r8, 0
    jne .turn

  .nextturn: ; done a turn on all stones, we regroup the stones then go back to the first
    call _regroup
    inc r10
    cmp r10, 75
    je _count
    mov r8, rdi
    jmp .turn

_regroup: ; regroup the stones, we have a counter for each number on the stone and we merge the counters when they have the same number. Save space and time
    push r8
    push r9
    push r10
    push r11
    mov r8, rdi

  .outer:
    cmp r8, 0
    je .end
    mov rax, [r8]
    mov r9, r8

  .inner:
    mov r11, r9 ; save previous stone
    mov r9, [r9+8]
    cmp r9, 0
    je .innerend
    cmp rax, [r9]
    jne .inner
    mov r10, [r9+16]
    add [r8+16], r10 ; update counter
    
    mov r10, [r9+8]
    mov [r11+8], r10 ; update link to remove the now unused space. Indeed it's not freed, so we could use less space with malloc probably
    
    mov r9, r11

    jmp .inner

  .innerend:
    mov r8, [r8+8]
    jmp .outer

  .end:
    pop r11
    pop r10
    pop r9
    pop r8

    ret

_new: ; create free space of 24 bytes, technically it increases the limit of the data section, like a heap stack
    push rax
    push rdi

    cmp qword [oldbrk], 0
    jne .good

    mov rax, 12
    mov rdi, 0
    syscall ; because brk updates the limit of the data section we have to give it an exact adress, so we need the base adress for the first call

    jmp .brk

  .good:

    mov rax, [oldbrk]

  .brk:

    lea rdi, [rax + 24]
    mov r14, rax
    mov rax, 12
    syscall

    mov [oldbrk], rax

    pop rdi
    pop rax
    ret

_power: ; compute 10 ** rcx in rcx
    push rax

    mov rax, rcx
    mov rcx, 1

  .inner:
    imul rcx, 10
    dec rax
    jnz .inner

    pop rax
    ret

_numofdigits: ; count the number of digits
    mov r12, 1
    mov rcx, 0

  .inner:
    inc rcx
    imul r12, 10
    cmp r12, rax
    jle .inner

    ret

_count: ; count the number of stones
    mov r8, rdi

  .l:
    add r15, [r8+16]
    mov r8, [r8+8]
    cmp r8, 0
    jne .l

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