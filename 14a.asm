section .rodata
input:
  incbin "14.in"
inputend:

section .data
x: db 0
y: db 0
xd: db 0
yd: db 0
q1: dq 0
q2: dq 0
q3: dq 0
q4: dq 0

section .text
global _start
_start:
    
    mov rsi, input
    xor r15, r15 ; result
    mov r8, 101 ; width
    mov r9, 103 ; heigth
    mov r10, 50 ; quarter x delim
    mov r11, 51 ; quarter y delim

_parse:

    cmp rsi, inputend
    jae _count

    add rsi, 2
    call _atoi
    mov [x], al

    inc rsi
    call _atoi
    mov [y], al

    add rsi, 3
    cmp byte [rsi], '-'
    je .negativexd
    call _atoi
    mov [xd], al
    jmp .ydlabel

  .negativexd:
    inc rsi
    call _atoi
    mov [xd], r8b
    sub [xd], al

  .ydlabel:
    inc rsi
    cmp byte [rsi], '-'
    je .negativeyd
    call _atoi
    mov [yd], al
    jmp .play

  .negativeyd:
    inc rsi
    call _atoi
    mov [yd], r9b
    sub [yd], al

  .play:
    call _play
    inc rsi
    jmp _parse

_play: ; do 100 seconds for the robot with coords in x,y
    mov rcx, 100
    xor rdx, rdx

    movzx rax, byte [xd]
    mul rcx
    movzx rbx, byte [x]
    add rax, rbx

    div r8

    mov byte [x], dl

    xor rdx, rdx

    movzx rax, byte [yd]
    mul rcx
    movzx rbx, byte [y]
    add rax, rbx

    div r9

    mov byte [y], dl

    ; find which quarter he's in

    cmp byte [x], r10b 
    je .end
    jl .q12
    ja .q34

  .q12:
    cmp byte [y], r11b
    je .end
    jl .q1

  .q2:
    add qword [q2], 1
    jmp .end

  .q1:
    add qword [q1], 1
    jmp .end

  .q34:
    cmp byte [y], r11b
    je .end
    jl .q3

  .q4:
    add qword [q4], 1
    jmp .end

  .q3:
    add qword [q3], 1

  .end:
    ret

_atoi: ; Read number

 .setup:
    xor rax, rax

 .inner:
    imul rax, 10
    movzx rbx, byte [rsi]
    add rax, rbx
    sub rax, 48
    inc rsi
    cmp byte [rsi], ','
    je .end
    cmp byte [rsi], 10
    je .end
    cmp byte [rsi], 32
    jne .inner

  .end:
    ret 

_count: ; compute solutions from quarter population
    mov rax, [q1]
    mul qword [q2]
    mul qword [q3]
    mul qword [q4]

    mov r15, rax ; to not change _itoa to not mess with myself on the next day
    
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