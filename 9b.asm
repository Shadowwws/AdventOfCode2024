section .rodata
input:
  incbin "9.in"
inputend:

section .data
done: TIMES 20000 db 0

section .text
global _start
_start:

    mov rsi, input ; input
    mov rbp, rsp
    xor rcx, rcx

_read:
  
  .number:
    cmp rsi, inputend
    jae _solve

    movzx rax, byte [rsi]
    inc rsi
    sub rax, 48

    cmp rax, 0
    jle .empty

  .addnumber: ; add a block file
    push rcx
    dec rax
    jnz .addnumber

    inc rcx

  .empty:
    cmp rsi, inputend
    jae _solve

    movzx rax, byte [rsi]
    inc rsi
    sub rax, 48

    cmp rax, 0
    jle _read

  .addempty: ; add empty space
    push -1
    dec rax
    jnz .addempty

    jmp _read

_solve:
    xor rax, rax
    mov r8, rbp
    mov r9, rsp

  .inner:
    mov r11, 0

  .size: ; compute the size of the current file block
    inc r11
    mov r10, [r9+8*r11]
    cmp r10, [r9]
    je .size

  ; If it's already been moved we don't need to move it again
    mov r10, [r9]
    cmp byte [done+r10], 1
    je .nextchunk

    mov byte [done+r10], 1

    call _findgoodsizeempty ; search for a large enough empty space
    cmp rax, 1
    je .nextchunk

  .move: ; do the move with a loop, xchg with pointers in my dream
    mov r10, [r9]
    mov [r8], r10
    mov qword [r9], -1
    add r9, 8
    sub r8, 8
    dec r11
    jnz .move
    sub r9, 8
    jmp .skipempty

  .nextchunk: ; go to the next chunk if we didn't move this one
    mov rax, 8
    mul r11
    add r9, rax 

  .skipempty: ; find next chunk
    cmp r9, rbp
    jae _count
    cmp qword [r9], -1
    jne .inner
    add r9, 8
    jmp .skipempty

_findempty: ; find next empty tile, independant of its size
    sub r8, 8
    cmp r8, r9
    jle .none
    cmp qword [r8], -1
    jne _findempty
    ret

  .none:
    mov rax, 1
    ret

_findgoodsizeempty: ; r11 = disired size / search a large enough empty space
    mov r8, rbp ; always start from beginning

  .outer: ; go to the next empty space
    call _findempty
    cmp rax, 1
    je .none
    xor rax, rax
    xor rcx, rcx
    
  .inner: ; compute its size
    dec rcx
    cmp qword [r8+8*rcx], -1
    je .inner
   
    neg rcx
    cmp rcx, r11
    jl .outer
    jmp .end

  .none:
    mov rax, 1
  .end:
    ret

_count:
    mov rcx, -1
    xor rax, rax
    mov r8, rbp
    xor r15, r15 ; result

  .inner:
    inc rcx
    sub r8, 8
    cmp r8, rsp
    je _itoa
    cmp qword [r8], -1
    je .inner
    mov rax, rcx
    mul qword [r8]
    add r15, rax
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