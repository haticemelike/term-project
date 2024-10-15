.include "SysCalls.asm"

.data
    seed:        .word 12345          # Seed for random number generator
    factor1:     .word 0:8            # Array to hold 8 factor1 values
    factor2:     .word 0:8            # Array to hold 8 factor2 values
    products:    .word 0:8            # Array to hold 8 products
    equation_msg: .asciiz "Equation: "  # Debugging message for equations
    product_msg:  .asciiz " Product: "  # Debugging message for products
    multiply_msg: .asciiz " x "         # Multiply sign string
    newline:     .asciiz "\n"          # Newline character

.text
.globl main

main:
    # Set up the random number generator with a seed
    li $a0, 0                  # Pseudorandom generator ID (any int works)
    lw $a1, seed               # Load the seed
    li $v0, SysRandInt          # Syscall for setting random seed
    syscall

    # Generate 8 random equations and products
    jal GenerateRandomEquations

    # Print all generated cards (equations and products)
    jal PrintAllCards

    jr $ra                      # Return to exit program

# Generate random equations and products
GenerateRandomEquations:
    li $t0, 0                   # Initialize counter (0 to 7 for 8 iterations)
    li $a1, 12                  # Set upper bound for random numbers (1-12)

generate_loop:
    # Generate random factor1
    li $v0, SysRandIntRange      # Syscall for generating random number in range
    li $a0, 0                   # Random generator ID
    syscall                     # Random number now in $a0
    addi $a0, $a0, 1            # Adjust range to 1-12
    sw $a0, factor1($t0)        # Store in factor1 array

    # Generate random factor2
    li $v0, SysRandIntRange      # Syscall for generating random number in range
    li $a0, 0                   # Random generator ID
    syscall
    addi $a0, $a0, 1            # Adjust range to 1-12
    sw $a0, factor2($t0)        # Store in factor2 array

    # Calculate product = factor1 * factor2
    lw $t1, factor1($t0)        # Load factor1
    lw $t2, factor2($t0)        # Load factor2
    mul $t3, $t1, $t2           # Calculate product
    sw $t3, products($t0)       # Store product in products array

    # Increment counter and loop for 8 iterations
    addi $t0, $t0, 4
    blt $t0, 32, generate_loop

    jr $ra                      # Return from function

# Print all 16 cards (8 equations and 8 products)
PrintAllCards:
    li $t0, 0                   # Counter (0 to 7 for 8 cards)

print_loop:
    # Print equation "Equation: factor1 x factor2 Product: product"
    la $a0, equation_msg        # Load equation debug message
    li $v0, SysPrintString      # Syscall to print string
    syscall

    lw $t1, factor1($t0)        # Load factor1
    move $a0, $t1               # Move factor1 to $a0
    li $v0, SysPrintInt         # Syscall to print integer
    syscall

    # Print " x "
    la $a0, multiply_msg        # Load " x " string
    li $v0, SysPrintString      # Syscall to print string
    syscall

    lw $t2, factor2($t0)        # Load factor2
    move $a0, $t2               # Move factor2 to $a0
    li $v0, SysPrintInt         # Syscall to print integer
    syscall

    # Print " Product: "
    la $a0, product_msg         # Load product debug message
    li $v0, SysPrintString      # Syscall to print string
    syscall

    lw $t3, products($t0)       # Load product
    move $a0, $t3               # Move product to $a0
    li $v0, SysPrintInt         # Syscall to print integer
    syscall

    # Print newline to move to the next line
    la $a0, newline
    li $v0, SysPrintString      # Syscall to print newline
    syscall

    # Increment counter and loop for 8 equations/products
    addi $t0, $t0, 4
    blt $t0, 32, print_loop

    jr $ra                      # Return from function
