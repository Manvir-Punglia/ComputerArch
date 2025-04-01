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
    mv t0, a0            # store input


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

fib_loop:
    bge t3, t0, done     # If counter >= input + 1, exit loop

    add t4, t1, t2       # fib(t) = fib(t-1) + fib(t-2)
    mv t1, t2            # Update fib(t-1) = fib(t)
    mv t2, t4            # Update fib(t) = fib(t+1)

    li a7, 1
    mv a0, t4
    ecall                # Print the Fibonacci number

    la a0, space
    li a7, 4
    ecall                # Print ", "

    addi t3, t3, 1       # Increase counter
    j fib_loop

done:
    li a7, 10
    ecall                # Exit
