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
    inc rsi
    jmp _atoi

  .sum:
    push rax ; add the new read number to the stack 
    add rsi, 3 ; 3 spaces between the columns, wtf
    jmp _atoi

_solve: ; at this point numbers from the first column are accessible at [rsp + 8 + 16*k] and number from the second column are accessible at [rsi + 16*k]
    mov rcx, rsp
    add rcx, 8 ; to take element from 1st column
    mov r9, rsp

  .outer:
    xor rax, rax
    cmp rcx, rbp ; check if we did all elements of the first column
    jae _itoa
    mov r8, [rcx] ; first column element

  .inner:
    cmp r9, rbp ; check if we did all elements of the second column
    jae .end
    cmp r8, [r9] ; compare elements
    je .sum ; increase the occurence counter
    add r9, 16 ; next element
    jmp .inner

  .sum:
    inc rax ; nb of occurences
    add r9, 16
    jmp .inner  

  .end:
    mul r8 ; the multiplication thing
    add r15, rax ; add to result
    add rcx, 16 ; next element of 1st column
    mov r9, rsp ; don't forget to reset second column
    jmp .outer

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
