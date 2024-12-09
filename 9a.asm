section .rodata
input:
  incbin "9.in"
inputend:

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

_solve: ; double pointer, r8 : current empty space / r9 : current file block
    xor rax, rax
    mov r8, rbp
    mov r9, rsp

  .inner:
    call _findempty ; find next empty space
    cmp rax, 1 ; if no free space then it's the end
    je _count
    mov r10, [r9] ; move
    mov [r8], r10 ; the 
    mov qword [r9], -1 ; block

  .skipempty: ; skip empty space becuase we don't move them
    add r9, 8
    cmp qword [r9], -1
    je .skipempty
    jmp .inner


_findempty:
    sub r8, 8
    cmp r8, r9
    jle .none
    cmp qword [r8], -1
    jne _findempty
    ret

  .none:
    mov rax, 1
    ret

_count:
    xor rcx, rcx
    xor rax, rax
    mov r8, rbp
    xor r15, r15 ; result

  .inner:
    sub r8, 8
    cmp qword [r8], -1
    je _itoa
    mov rax, rcx
    mul qword [r8]
    add r15, rax
    inc rcx
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