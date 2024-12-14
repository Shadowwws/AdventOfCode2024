section .rodata
input:
  incbin "14.in"
inputend:

section .data
x: db 0
y: db 0
xd: db 0
yd: db 0

xs: TIMES 500 db 0
ys: TIMES 500 db 0
xds: TIMES 500 db 0
yds: TIMES 500 db 0

board: TIMES 10403 db '.'
boardend:

endl: db 10

section .text
global _start
_start:
    
    mov rsi, input
    xor r15, r15 ; number of rounds
    mov r8, 101 ; width
    mov r9, 103 ; heigth
    mov r10, 50 ; quarter x delim
    mov r11, 51 ; quarter y delim
    xor rcx, rcx

_parse:

    cmp rsi, inputend
    jae _play

    add rsi, 2
    call _atoi
    mov [xs+rcx], al

    inc rsi
    call _atoi
    mov [ys+rcx], al

    add rsi, 3
    cmp byte [rsi], '-'
    je .negativexd
    call _atoi
    mov [xds+rcx], al
    jmp .ydlabel

  .negativexd:
    inc rsi
    call _atoi
    mov [xds+rcx], r8b
    sub [xds+rcx], al

  .ydlabel:
    inc rsi
    cmp byte [rsi], '-'
    je .negativeyd
    call _atoi
    mov [yds+rcx], al
    jmp .play

  .negativeyd:
    inc rsi
    call _atoi
    mov [yds+rcx], r9b
    sub [yds+rcx], al

  .play:
    inc rcx
    inc rsi
    jmp _parse

_play:

    xor rcx, rcx
    mov r14, 1
    mov r13, 1

  .outer: 
    cmp r13b, 0
    je _itoa
    call _resetboard
    mov rcx, 0
    xor r13, r13

  .inner: ; do a second with all the robots
    cmp rcx, 500
    je .outerend

    mov dil, byte [xs+rcx]
    mov byte [x], dil
    mov dil, byte [ys+rcx]
    mov byte [y], dil
    mov dil, byte [xds+rcx]
    mov byte [xd], dil
    mov dil, byte [yds+rcx]
    mov byte [yd], dil

    xor rdx, rdx

    movzx rax, byte [xd]
    movzx rbx, byte [x]
    add rax, rbx

    div r8

    mov byte [x], dl ; new x coord = x+xd

    xor rdx, rdx

    movzx rax, byte [yd]
    movzx rbx, byte [y]
    add rax, rbx

    div r9

    mov byte [y], dl ; new y coord = y+yd

    movzx rax, byte [y]
    mul r8
    movzx rbx, byte [x]
    add rax, rbx
    cmp byte [board+rax], '#' ; if a '#' is already here then it's duplicate so no tree
    cmove r13, r14
    mov byte [board+rax], '#'

  .end:
    mov dil, byte [x]
    mov byte [xs+rcx], dil
    mov dil, byte [y]
    mov byte [ys+rcx], dil
    mov dil, byte [xd]
    mov byte [xds+rcx], dil
    mov dil, byte [yd]
    mov byte [yds+rcx], dil

    inc rcx ; next robot
    jmp .inner

  .outerend:
    inc r15 
    jmp .outer

_resetboard: ; reset the board for next round
    mov rdi, board

  .inner:
    cmp rdi, boardend
    je .end
    mov byte [rdi], '.'
    inc rdi
    jmp .inner

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

_draw: ; draw the board
    push rcx
    push r14

    mov r14, board

  .inner:
    cmp r14, boardend
    jae .end

    mov rax, 1
    mov rdi, 1
    mov rsi, r14
    mov rdx, r8
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, endl
    mov rdx, 1
    syscall

    add r14, r8
    jmp .inner

  .end:
    mov rax, 1
    mov rdi, 1
    mov rsi, endl
    mov rdx, 1
    syscall

    pop r14
    pop rcx
    ret
    
; Following part from alajpie, just to print the result, pretty fast and independant from the challenge.
_itoa:
    call _draw

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