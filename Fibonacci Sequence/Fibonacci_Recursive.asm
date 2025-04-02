    .data
input:      .string "Enter a number: "
space:      .string ", "
buffer:     .space 4

    .text
    .globl _start

_start:
    la a0, input
    li a7, 4
    ecall

    li a7, 5
    ecall
    mv t0, a0

    li t1, 0             # fib(0) = 0
    li t2, 1             # fib(1) = 1
    li t3, 0             # counter, starting from 0

    li a7, 1
    mv a0, t1
    ecall                # Print fib(0)

    la a0, space
    li a7, 4
    ecall                # Print ", "

    li a7, 1
    mv a0, t2
    ecall                # Print fib(1)

    la a0, space
    li a7, 4
    ecall                # Print ", "

    addi t3, t3, 2       # Start from the 2nd Fibonacci number t3 = t3 + 2

    mv a0, t3
    jal fib_recursive

done:
    li a7, 10
    ecall

fib_recursive:
    bge a0, t0, return

    add t4, t1, t2       # fib(t) = fib(t-1) + fib(t-2)
    mv t1, t2            # Update fib(t-1) = fib(t)
    mv t2, t4            # Update fib(t) = fib(t+1)

    li a7, 1
    mv a0, t4
    ecall

    la a0, space
    li a7, 4
    ecall                # Print the Fibonacci number

    addi t3, t3, 1
    mv a0, t3
    jal fib_recursive

return:
    ret
