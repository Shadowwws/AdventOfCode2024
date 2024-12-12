section .data
input:
  incbin "12.in"
inputend:

done: TIMES inputend-input db 0
doneend:

up: db 0
down: db 0
left: db 0
right: db 0

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
    mov rdi, done

_solve:
    cmp rsi, inputend
    je _itoa

    cmp byte [rsi], 10
    je .endl

    cmp byte [rdi], 1
    je .visited

    call _fill

  .endl:
  .visited:
    inc rsi
    inc rdi
    jmp _solve

_fill: ; check the 4 neighbours, if a neighbour is with the same character then add to the queue. Keep track of the tile processed in the "done" array
    push rbp
    mov rbp, rsp
    xor rcx, rcx
    xor rdx, rdx

    push rsi

  .inner:
    mov dword [up], 0
    cmp rbp, rsp
    je .end

    pop rax
    movzx r9, byte [rax]
    mov r10, rax
    sub r10, input
    mov byte [done+r10], 1
    inc rdx

  .checkup:
    mov r13, .checkright
    lea r8, [rax-141]
    cmp r8, input
    jl .notsame

    movzx r10, byte [r8]
    cmp r10, r9
    je .same

    je .oldsame

    jmp .notsame

  .checkright:
    mov r13, .checkdown
    lea r8, [rax+1]

    movzx r10, byte [r8]
    cmp r10, r9
    je .same

    jmp .notsame

  .checkdown:
    mov r13, .checkleft
    lea r8, [rax+r14]
    cmp r8, inputend
    jae .notsame

    movzx r10, byte [r8]
    cmp r10, r9
    je .same

    jmp .notsame

  .checkleft:
    mov r13, .check
    lea r8, [rax-1]
    cmp r8, input
    jl .notsame

    movzx r10, byte [r8]
    cmp r10, r9
    je .same

    jmp .notsame

  .check:
    call _checkedge
    jmp .inner

  .same:
    mov r10, r8
    sub r10, input
    cmp byte [done+r10], 1
    je .oldsame
    call _inqueueoradd
    jmp r13

  .notsame:
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

_checkedge: ; checking if the current tile in rax is an edge or not. Can be 2 edges (1 "inside" and 1 "outside")
    xor r12, r12
    xor r11, r11

  ; "inside" edges

    lea r10, [rax-141]
    cmp r10, input
    setl [up]
    jl .down

    movzx r11, byte [r10]
    cmp r11, r9
    setne [up]

  .down:
    lea r10, [rax+r14]
    cmp r10, inputend
    setae [down]
    jae .right

    movzx r11, byte [r10]
    cmp r11, r9
    setne [down]

  .right:
    lea r10, [rax+1]
    movzx r11, byte [r10]
    cmp r11, r9
    setne [right]

  .left:
    lea r10, [rax-1]
    movzx r11, byte [r10]
    cmp r11, r9
    setne [left]

    movzx r10, byte [up]
    movzx r11, byte [right]

    test r10, r11
    jz .ul

    inc rcx

  .ul:

    movzx r11, byte [left]

    test r10, r11
    jz .dleft

    inc rcx

  .dleft:

    movzx r10, byte [down]

    test r10, r11
    jz .dr

    inc rcx

  .dr:

    movzx r11, byte [right]

    test r10, r11
    jz .diagul

    inc rcx

  ; "outside" edges

  .diagul:

    lea r10, [rax-142]
    movzx r11, byte [r10]
    cmp r11, r9
    jne .edgeul

  .diagur:

    lea r10, [rax-140]
    movzx r11, byte [r10]
    cmp r11, r9
    jne .edgeur

  .diagdl:

    lea r10, [rax+140]
    movzx r11, byte [r10]
    cmp r11, r9
    jne .edgedl

  .diagdr:

    lea r10, [rax+142]
    movzx r11, byte [r10]
    cmp r11, r9
    jne .edgedr

    jmp .notedge

  .edgeul:
    cmp byte [up], 1
    je .diagur

    cmp byte [left], 1
    je .diagur

    inc rcx

    jmp .diagur

  .edgeur:
    cmp byte [up], 1
    je .diagdl

    cmp byte [right], 1
    je .diagdl

    inc rcx

    jmp .diagdl


  .edgedl:
    cmp byte [down], 1
    je .diagdr

    cmp byte [left], 1
    je .diagdr

    inc rcx

    jmp .diagdr

  .edgedr:
    cmp byte [down], 1
    je .notedge

    cmp byte [right], 1
    je .notedge

    inc rcx

  .notedge:
    ret

  .edge:
    inc rcx
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