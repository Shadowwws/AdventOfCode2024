section .data
input:
  incbin "15.in"
inputend:

newmap: TIMES 8192 db 0
newmapend:

done: TIMES 8192 db 0
donend:

section .text
global _start
_start:
    
    mov rsi, input
    xor r15, r15 ; number of rounds
    mov r9, 101 ; width
    mov rdi, newmap

_copy:

  .inner:
    cmp word [rsi], 2570 ; "\n\n"
    je _parse

    cmp byte [rsi], "#"
    je .wall

    cmp byte [rsi], "O"
    je .box

    cmp byte [rsi], "."
    je .empty

    cmp byte [rsi], 10
    je .space

  .robot:
    mov byte [rdi], "@"
    inc rdi
    mov byte [rdi], "."
    jmp .next

  .wall:
    mov byte [rdi], "#"
    inc rdi
    mov byte [rdi], "#"
    jmp .next

  .box:
    mov byte [rdi], "["
    inc rdi
    mov byte [rdi], "]"
    jmp .next

  .empty:
    mov byte [rdi], "."
    inc rdi
    mov byte [rdi], "."
    jmp .next

  .space:
    mov byte [rdi], 10

  .next:
    inc rdi
    inc rsi
    jmp .inner

_parse:

    inc rsi
    mov rdi, newmap

  .inner:

    cmp byte [rdi], "@"
    je .robot

    inc rdi
    jmp .inner

  .robot:
    mov r8, rdi
    sub r8, newmap
    jmp _play

_play: ; r8 = robot, rsi = instructions, rdi = newmap

    mov rdi, newmap

  .inner:
    ;call _drawboard
    call _resetdone
    inc rsi
    cmp rsi, inputend
    je _count

    cmp byte [rsi], 10
    je .inner

    cmp byte [rsi], "<"
    je .left

    cmp byte [rsi], "^"
    je .up

    cmp byte [rsi], ">"
    je .right

  ; down

  .down:
    mov r14, r9
    mov r10, r8
    add r10, r9
    cmp byte [rdi+r10], "."
    je .exchange

    cmp byte [rdi+r10], "#"
    je .inner

    mov r11, r10

    push r8
    call _search
    add rsp, 8
    cmp rax, 1
    je .inner

    cmp byte [rdi+r10-1], "["
    je .ld

  .rd:
    mov rcx, r10
    inc rcx
    push rcx
    call _search
    add rsp, 8
    cmp rax, 1
    je .inner
    
    push rcx
    call _move
    add rsp, 8
    dec rcx
    jmp .ed

  .ld:
    mov rcx, r10
    dec rcx
    push rcx
    call _search
    add rsp, 8
    cmp rax, 1
    je .inner
  
    push rcx
    call _move
    add rsp, 8
    inc rcx

  .ed:
    push rcx
    mov byte [done+rcx], 0
    call _move
    add rsp, 8

    mov byte [rdi+r10], "@"
    mov byte [rdi+r8], "."
    mov r8, r10
    jmp .inner
  ; up

  .up:
    mov r14, r9
    neg r14
    mov r10, r8
    sub r10, r9
    cmp byte [rdi+r10], "."
    je .exchange

    cmp byte [rdi+r10], "#"
    je .inner

    mov r11, r10

    push r8
    call _search
    add rsp, 8
    cmp rax, 1
    je .inner

    cmp byte [rdi+r10-1], "["
    je .lu

  .ru:
    mov rcx, r10
    inc rcx
    push rcx
    call _search
    add rsp, 8
    cmp rax, 1
    je .inner
    
    push rcx
    call _move
    add rsp, 8
    dec rcx
    jmp .eu

  .lu:
    mov rcx, r10
    dec rcx
    push rcx
    call _search
    add rsp, 8
    cmp rax, 1
    je .inner
  
    push rcx
    call _move
    add rsp, 8
    inc rcx

  .eu:
    push rcx
    mov byte [done+rcx], 0
    call _move
    add rsp, 8

    mov byte [rdi+r10], "@"
    mov byte [rdi+r8], "."
    mov r8, r10
    jmp .inner

  ; right
    
  .right:
    mov r10, r8
    add r10, 1
    cmp byte [rdi+r10], "."
    je .exchange

    cmp byte [rdi+r10], "#"
    je .inner

    mov r11, r10

  .searchright:
    add r10, 2
    cmp byte [rdi+r10], "["
    je .searchright

    cmp byte [rdi+r10], "."
    je .mover
    jmp .inner

  ; left

  .left:
    mov r10, r8
    sub r10, 1
    cmp byte [rdi+r10], "."
    je .exchange

    cmp byte [rdi+r10], "#"
    je .inner

    mov r11, r10

  .searchleft:
    sub r10, 2
    cmp byte [rdi+r10], "]"
    je .searchleft

    cmp byte [rdi+r10], "."
    je .movel
    jmp .inner

  .exchange:
    movzx rax, byte [rdi+r8]
    movzx rbx, byte [rdi+r10]
    mov byte [rdi+r8], bl
    mov byte [rdi+r10], al
    mov r8, r10
    jmp .inner

  .mover:
    cmp r10, r11
    je .moverend
    mov byte [rdi+r10], "]"
    dec r10
    mov byte [rdi+r10], "["
    dec r10
    jmp .mover

  .moverend:
    mov byte [rdi+r8], "."
    add r8, 1
    mov byte [rdi+r8], "@"
    jmp .inner

  .movel:
    cmp r10, r11
    je .movelend
    mov byte [rdi+r10], "["
    inc r10
    mov byte [rdi+r10], "]"
    inc r10
    jmp .movel
    
  .movelend:
    mov byte [rdi+r8], "."
    dec r8
    mov byte [rdi+r8], "@"
    jmp .inner

_count:
    mov rsi, newmap
    xor rdx, rdx

  .inner:
    inc rsi
    cmp rsi, newmapend
    je _itoa
    cmp byte [rsi], "["
    jne .inner
    
    mov rax, rsi
    sub rax, rdi

    div r9

    imul rax, 100

    add r15, rax
    add r15, rdx
    xor rdx, rdx
    jmp .inner

_move:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push rax

    mov r12, [rbp+16]
    movzx rax, byte [rdi+r12]

    mov r13, r12
    add r13, r14

    cmp byte [done+r12], 1
    je .end

    cmp byte [rdi+r12], "."
    je .end

    cmp byte [rdi+r13], "."
    je .moving

    push r13
    call _move
    add rsp, 8

  .moving:
    movzx rax, byte [rdi+r12]
    mov byte [rdi+r13], al
    mov byte [rdi+r12], "."
    mov byte [done+r13], 1

  .left:
    dec r13
    cmp byte [rdi+r13], al
    jne .right
    push r13
    call _move
    add rsp, 8
    
  .right:
    add r13, 2
    cmp byte [rdi+r13], al
    jne .end
    push r13
    call _move
    add rsp, 8
    dec r13

  .end:
    pop rax
    pop r13
    pop r12
    pop rbp
    ret

_search:
    push rbp
    mov rbp, rsp
    push r12
    push rbx

    mov r12, [rbp+16]
    movzx rbx, byte [rdi+r12]

    add r12, r14

    cmp byte [rdi+r12], "#"
    je .notmoving

    cmp byte [rdi+r12], "["
    jae .again

    mov rax, 0
    pop rbx
    pop r12
    pop rbp
    ret

  .notmoving:
    mov rax, 1
    pop rbx
    pop r12
    pop rbp
    ret

  .again:
    push r12
    call _search
    add rsp, 8
    cmp rax, 1
    je .notmoving

  .left:
    dec r12
    cmp byte [rdi+r12], bl
    jne .right
    push r12
    call _search
    add rsp, 8
    cmp rax, 1
    je .notmoving

  .right:
    add r12, 2
    cmp byte [rdi+r12], bl
    jne .good
    push r12
    call _search
    add rsp, 8
    cmp rax, 1
    je .notmoving

  .good:
    mov rax, 0
    pop rbx
    pop r12
    pop rbp
    ret

_resetdone:
    mov rdx, done

  .inner:
    mov byte [rdx], 0
    inc rdx
    cmp rdx, donend
    jne .inner

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