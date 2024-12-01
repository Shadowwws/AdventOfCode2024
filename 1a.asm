%define SYS_EXIT 60
%define SYS_WRITE 1
%define STDOUT 1
%define SYS_READ 0
%define SYS_OPEN 2
%define SYS_CLOSE 3
%define STDIN 0

section .rodata
input:
  incbin "1.in"
inputend:

section .text
global _start
_start:
  
    mov rsi, input ; input
    xor r9, r9 ; used as a size counter of my array in my stack (could probably just check with rbp but later, and useful for debug)
    xor r15, r15 ; final result
    mov rbp, rsp ; now we use it, when popping the elements to know when to end
    
_atoi:                    ; Convert input to int

    cmp rsi, inputend ; end of file
    jae _solve

 .setup:
    xor eax, eax

 .inner:
    imul rax, 10
    movzx rbx, byte [rsi]
    add rax, rbx
    sub rax, 48
    inc rsi
    cmp byte [rsi], 32
    je .sum
    cmp byte [rsi], 10
    jne .inner
    push rax ; add the new read number to the stack 
    add r9, 8
    inc rsi
    jmp _atoi

  .sum:
    push rax ; add the new read number to the stack 
    add r9, 8
    add rsi, 3 ; 3 spaces between the columns, wtf
    jmp _atoi

_solve: ; at this point numbers from the first column are accessible at [rsp + 8 + 16*k] and number from the second column are accessible at [rsi + 16*k]
  .left:
    xor rcx, rcx ; to read at [rsp + 16*k]
    mov r12, .right ; to tell _sort where to jump
    jmp _sort ; sorting 

  .right:
    mov rcx, 8 ; to read at [rsp + 8 + 16*k]
    mov r12, .work ; to tell _sort where to jump
    jmp _sort ; sorting

  .work: ; now it's sorted, so we just take and substract
    pop rax ; second column element
    pop rbx ; first column element
    sub rax, rbx ; take the diff
    mov rbx, rax    ; abs()
    neg rax         ; abs()
    cmovl rax, rbx  ; abs()
    add r15, rax ; add result
    cmp rsp, rbp ; check if we're at the end
    jne .work ; not end
    jmp _itoa ; end => print

_sort: ; sorting alg, bubble sort like
    mov r11, rcx ; remember the start

  .outer:
    mov r10, 0 ; the good = True to know when to stop sorting
    mov rcx, r11 ; start of array index

  .inner:
    mov rdx, 16
    add rdx, rcx ; next_element (rcx is current element)
    cmp rdx, r9 ; check for end of array
    jae .check
    mov r13, [rsp+rcx]
    mov r14, [rsp+rdx]
    cmp r13, r14 ; comparaison
    ja .swap ; wrong order => swap
    add rcx, 16 ; next element
    jmp .inner

  .swap:
    mov [rsp+rcx], r14 ; swapping
    mov [rsp+rdx], r13 ; swapping
    add rcx, 16 ; next element
    mov r10, 1 ; good = False => continue sorting
    jmp .inner

  .check:
    cmp r10, 0
    jne .outer

  .end:
    jmp r12

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
