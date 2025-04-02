.global _start

_start:
    @ Clear entire 16-byte buffer
    ldr r0, =buffer
    mov r1, #0
    str r1, [r0], #4
    str r1, [r0], #4
    str r1, [r0], #4
    str r1, [r0]

    @ First number
    ldr r0, =prompt1
    bl print
    bl read_input
    bl convert_num
    mov r4, r0          @ num1 in r4

    @ Operator
    ldr r0, =prompt2
    bl print
    bl read_char
    mov r5, r0          @ operator in r5

    @ Second number
    ldr r0, =prompt3
    bl print
    bl read_input
    bl convert_num
    mov r6, r0          @ num2 in r6

    @ Calculate
    cmp r5, #'+'
    beq addition
    cmp r5, #'-'
    beq subtraction
    cmp r5, #'*'
    beq multiplication
    cmp r5, #'/'
    beq division
    b invalid_operator

addition:
    add r7, r4, r6
    b show_result

subtraction:
    sub r7, r4, r6
    b show_result

multiplication:
    mul r7, r4, r6
    b show_result

division:
    cmp r6, #0
    beq division_error
    mov r7, #0
div_loop:
    cmp r4, r6
    blt show_result
    sub r4, r4, r6
    add r7, r7, #1
    b div_loop

show_result:
    ldr r0, =result
    bl print
    mov r0, r7          @ Move result to r0 for printing
    bl print_number
    b exit

division_error:
    ldr r0, =err_div0
    bl print
    b exit

invalid_operator:
    ldr r0, =err_op
    bl print
    b exit

@ ===== SUBROUTINES =====
print:
    push {r7}           @ Preserve r7
    mov r7, #4          @ sys_write
    mov r1, r0          @ string address
    mov r0, #1          @ stdout
    mov r2, #0          @ length counter
count_loop:
    ldrb r3, [r1, r2]   @ load byte
    cmp r3, #0          @ check for null terminator
    addne r2, #1        @ increment length
    bne count_loop
    swi 0               @ syscall
    pop {r7}            @ Restore r7
    bx lr

read_input:
    push {r7}
    mov r7, #3          @ sys_read
    mov r0, #0          @ stdin
    ldr r1, =buffer
    mov r2, #12         @ max length
    swi 0
    pop {r7}
    bx lr

read_char:
    push {r7}
    mov r7, #3          @ sys_read
    mov r0, #0          @ stdin
    ldr r1, =buffer
    mov r2, #2          @ read 2 bytes
    swi 0
    ldrb r0, [r1]       @ get first char
    pop {r7}
    bx lr

convert_num:
    ldr r1, =buffer
    mov r0, #0
convert_loop:
    ldrb r2, [r1], #1
    cmp r2, #10         @ newline
    beq convert_done
    cmp r2, #0          @ null
    beq convert_done
    sub r2, #'0'        @ convert to digit
    mov r3, #10
    mul r0, r3, r0
    add r0, r0, r2
    b convert_loop
convert_done:
    bx lr

print_number:
    push {r4-r7}        @ Preserve all used registers
    ldr r1, =buffer
    mov r2, #0
    
    @ Handle zero case
    cmp r0, #0
    bne not_zero
    mov r3, #'0'
    strb r3, [r1]
    mov r3, #0
    strb r3, [r1, #1]
    b print_buffer
    
not_zero:
    mov r3, #100        @ hundreds place
    bl extract_digit
    mov r3, #10         @ tens place
    bl extract_digit
    mov r3, #1          @ units place
    bl extract_digit
    
    @ Skip leading zeros
    ldr r1, =buffer
    mov r2, #0
skip_zeros:
    ldrb r3, [r1, r2]
    cmp r3, #'0'
    addeq r2, #1
    beq skip_zeros
    
    @ Shift digits left
    mov r4, #0
shift_loop:
    ldrb r3, [r1, r2]
    strb r3, [r1, r4]
    add r2, #1
    add r4, #1
    cmp r3, #0
    bne shift_loop
    
print_buffer:
    ldr r0, =buffer
    bl print
    pop {r4-r7}         @ Restore registers
    bx lr

extract_digit:
    mov r4, #0
digit_loop:
    cmp r0, r3
    blt store_digit
    sub r0, r0, r3
    add r4, #1
    b digit_loop
store_digit:
    add r4, #'0'        @ Convert to ASCII
    strb r4, [r1], #1
    bx lr

exit:
    mov r7, #1          @ sys_exit
    swi 0

.data
prompt1:  .asciz "First number: "
prompt2:  .asciz "Operator (+-*/): "
prompt3:  .asciz "Second number: "
result:   .asciz "Result: "
err_div0: .asciz "Error: Division by zero\n"
err_op:   .asciz "Error: Invalid operator\n"

.bss
buffer: .space 16
