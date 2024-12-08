section .data
input:
  incbin "8.in"
inputend:

coords: TIMES 760 db 0 ; array of 76 (character range) * 10 bytes (2 bytes per antenna * 4 max same antenna + 1 end of antenna)
coordsend:

section .text
global _start
_start:

    mov rsi, input ; input
    mov rbp, rsp
    mov rdi, rsi
    xor r15, r15 ; result
    mov r10, 51 ; grid size

_solve: ; read all antennas

    cmp rsi, inputend ; end of file
    je _count

  .inner:
    cmp byte [rsi], '.'
    je .iter

    cmp byte [rsi], 10
    je .iter

    movzx r9, byte [rsi]
    sub r9, 48

    lea r8, [8*r9+coords]
    add r8, r9
    add r8, r9

    sub r8, 2

  .empty:
    add r8, 2
    cmp word [r8], 0
    jne .empty

    mov rax, rsi
    sub rax, rdi

    mov word [r8], ax ; store antenna coordinates in its antenna list (some hashmap without hash)

  .iter:
    inc rsi
    jmp _solve

_count:

    mov rdi, coords
    sub rdi, 10

  .next: ; Find the characters which have an antenna
    add rdi, 10
    cmp rdi, coordsend ; No more characters
    jae _itoa
    cmp word [rdi], 0
    je .next

    push rdi ; Save current antenna character

  .outer: ; First antenna
    push rdi
    movzx r8, word [rdi]
    mov rax, r8
    div r10

    mov r11, rax ; x coord
    mov r12, rdx ; y coord

  .inner: ; Second antenna
    xor rdx, rdx ; reset rdx because div uses rdx for the value divided :)
    add rdi, 2
    movzx r9, word [rdi]
    cmp r9, 0
    je .end

    mov rax, r9
    div r10

    mov r13, rax ; x coord
    mov r14, rdx ; y coord

    sub r13, r11 ; x delta

    sub r14, r12 ; y delta

  .up: ; Check upward/before first antenna antinode
    cmp r11, r13
    jl .down ; Lower bound for x

    mov rcx, r12
    sub rcx, r14
    cmp rcx, 0
    jl .down ; lower bound for y
    cmp rcx, 50
    ja .down ; upper bound for y

    mov rcx, r11
    sub rcx, r13 ; antinode x coord

    imul rcx, 51

    add rcx, r12
    sub rcx, r14 ; antinode x*51+y coord

    cmp byte [input+rcx], '#' ; we only want unique antinode
    je .down

    inc r15
    mov byte [input+rcx], '#'

  .down: ; Check downward/after second antenna antinode
    add rax, r13
    cmp rax, 50
    jae .inner ; Upper bound for x

    add rdx, r14
    cmp rdx, 0
    jl .inner ; lower bound for y
    cmp rdx, 50
    ja .inner ; upper bound for y

    mov rcx, rax ; antinode x coord

    imul rcx, 51

    add rcx, rdx ; antinode x*51+y coord

    cmp byte [input+rcx], '#' ; we only want unique antinode
    je .inner

    inc r15
    mov byte [input+rcx], '#'

    jmp .inner

  .end: ; Take next first antenna
    pop rdi
    add rdi, 2
    cmp word [rdi], 0
    jne .outer

    pop rdi
    jmp .next

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