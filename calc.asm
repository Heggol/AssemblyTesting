section .bss
    num1 resb 8          ; reserve space for the first number
    num2 resb 8          ; reserve space for the second number
    operator resb 8      ; reserve space for the operator (added more space)
    result resb 16       ; reserve space for the result
    calc_result resq 1   ; add a 8 byte storage for numeric result

section .data ; data for user input
    division_error_msg db "Error: Division by zero is not allowed.", 10, 0
    l_division_error_msg equ $ - division_error_msg
    prompt_num1 db "Enter the first number: ", 0
    len_prompt_num1 equ $ - prompt_num1
    prompt_operator db "Enter the operator (+, -, *, /): ", 0
    len_prompt_operator equ $ - prompt_operator
    prompt_num2 db "Enter the second number: ", 0
    len_prompt_num2 equ $ - prompt_num2
    prompt_result db "Result: ", 0
    len_prompt_result equ $ - prompt_result
    newline db 10, 0

section .text
    global _start

_start:
    ; prompt for the first number
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; stdout
    mov rsi, prompt_num1         ; buffer
    mov rdx, len_prompt_num1     ; length
    syscall

    ; read the first number
    mov rsi, num1
    call read_input

    ; prompt for the operator
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; stdout
    mov rsi, prompt_operator     ; buffer
    mov rdx, len_prompt_operator ; length
    syscall

    ; read the operator
    mov rsi, operator
    call read_input

    ; prompt for the second number
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; stdout
    mov rsi, prompt_num2         ; buffer
    mov rdx, len_prompt_num2     ; length
    syscall

    ; read the second number
    mov rsi, num2
    call read_input

    ; convert the first number from string to integer
    mov rsi, num1
    call str_to_int
    mov r8, rax          ; store the first number in r8

    ; convert the second number from string to integer
    mov rsi, num2
    call str_to_int
    mov r9, rax          ; store the second number in r9

    ; perform the operation based on the operator
    mov al, byte [operator]
    cmp al, '+'
    je do_addition
    cmp al, '-'
    je do_subtraction
    cmp al, '*'
    je do_multiplication
    cmp al, '/'
    je do_division
    ; exit if invalid operator
    jmp exit

do_addition:
    mov rax, r8                  ; move the first number to rax register
    add rax, r9                  ; add the second number to rax register
    mov [calc_result], rax       ; store the result in memory
    jmp print_result             ; jump to print result to print the result (duh)

do_subtraction:
    mov rax, r8                  ; move the first number to rax register
    sub rax, r9                  ; subtract the second number from rax register
    mov [calc_result], rax       ; store the result in memory
    jmp print_result             ; jump to print result to print the result (duh)

do_multiplication:
    mov rax, r8                  ; move the first number to rax register
    imul rax, r9                 ; do integer multiplication with the second number and the rax register
    mov [calc_result], rax       ; store the result in memory
    jmp print_result             ; jump to print result to print the result (duh)

do_division:
    mov rax, r8                  ; move the first number to rax register
    mov rbx, r9                  ; move the second number to rbx register
    cmp rbx, 0                   ; check if rbx is zero
    je division_by_zero          ; jump to division by zero function if user is stupid 
    xor rdx, rdx                 ; clear rdx for division
    div rbx                      ; divide rax with rbx and store inwith remainder in rdx
    mov [calc_result], rax       ; store the result in memory
    jmp print_result             ; jump to print result to print the result (duh)

    division_by_zero:
    ; print error message for division by zero
    mov rdi, 1                   ; stdout
    mov rsi, newline             ; buffer
    mov rdx, 1                   ; length
    mov rax, 1                   ; syscall: write
    syscall

    mov rsi, division_error_msg  ; buffer
    mov rdx, l_division_error_msg ; length
    mov rax, 1                   ; syscall: write
    syscall

    ; Exit
    mov rax, 60                  ; syscall: exit
    mov rdi, 1                   ; status: 1 (error)
    syscall

print_result:
    ; Print the result prompt
    mov rdi, 1                   ; stdout
    mov rsi, prompt_result       ; buffer
    mov rdx, len_prompt_result   ; length
    mov rax, 1                   ; syscall: write
    syscall

    mov rax, [calc_result]       ; ;oad the result from memory

    ; convert the result to string
    call int_to_str

    ; print a newline
    mov rax, 1                   ; syscall: write
    mov rdi, 1                   ; stdout
    mov rsi, newline             ; buffer
    mov rdx, 1                   ; length
    syscall

exit:
    ; exit the program
    mov rax, 60          ; syscall: exit
    xor rdi, rdi         ; status: 0
    syscall

; read input from stdin
read_input:
    mov rax, 0           ; syscall: read
    mov rdi, 0           ; stdin
    mov rdx, 8           ; max input size
    syscall
    mov byte [rsi + rax - 1], 0 ; null terminate
    ret

str_to_int:
    xor rax, rax         ; clear rax
    xor rbx, rbx         ; clear rbx
convert_loop:
    mov bl, byte [rsi]
    cmp bl, 10           ; check for newline
    je convert_done
    cmp bl, 0            ; check for null terminate Round 1
    je convert_done
    sub bl, '0'          ; convert ASCII to integer
    imul rax, rax, 10    ; multiply rax by 10
    add rax, rbx         ; add the digit to rax
    inc rsi              ; move to the next character
    jmp convert_loop
convert_done:
    ret

int_to_str:
    ; save result first
    push rax             ; save number to print
    push rbx             ; save other registers
    push rcx
    push rdx
    push r10
    push r11

    ; get the number to print
    mov rax, [rsp + 40]  ; get the number from the stack (5 registers * 8 bytes = 40 bytes)
    
    ; setup for conversion
    mov rbx, 10          ; set Base 10
    mov rcx, result      ; buffer location
    add rcx, 15          ; move to end of buffer
    mov byte [rcx], 0    ; null terminate Round 2
    dec rcx              ; move back one position
    
    ; check if zero
    cmp rax, 0
    jne .convert_loop
    mov byte [rcx], '0'  ; if zero, just print '0'
    jmp .print_result
    
.convert_loop:
    test rax, rax        ; check if more digits
    jz .print_result
    xor rdx, rdx         ; clear rdx register for division
    div rbx              ; rax/10, remainder in rdx
    add dl, '0'          ; convert remainder to ASCII
    mov [rcx], dl        ; store digit
    dec rcx              ; move backward in buffer
    jmp .convert_loop    ; jump back to beginning of loop

.print_result:
    ; print the result
    inc rcx              ; move back to first digit
    ; calculate length of result
    mov r10, result      ; pointer to start of result buffer
    add r10, 15          ; move to end of buffer (null terminator)
    mov r11, rcx         ; copy pointer to first digit
    sub r10, r11         ; calculate length (end - start)

    mov rax, 1           ; syscall: write
    mov rdi, 1           ; stdout
    mov rsi, rcx         ; start of string of numbers
    mov rdx, r10         ; length of string
    syscall
    
    ; restore registers to original state
    pop r11
    pop r10
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret