#	CS2340 Term Project - Random Factor Generator 
#
#	Author: Hatice Kahraman
#	Date: 09-25-2024 
#	Location: UTD
#

.data
    seed:        .word 12345          # Seed for random number generator
    factor1:     .word 0:8            # Array to hold 8 factor1 values
    factor2:     .word 0:8            # Array to hold 8 factor2 values
    products:    .word 0:8            # Array to hold 8 products
    cellPairs:	 .byte 0:16	      # Array to hold the cells which correspond to a factor/product pair. 16 bytes: [factor0,product0,factor1,product1]
    #boardNums:   .byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 # These represent cell positions in left-right, top-bottom order
    boardNums:   .byte 0:16           # These represent cell positions in left-right, top-bottom order
    multiply_msg: .asciiz " x "         # Multiply sign string
    newline:     .asciiz "\n"          # Newline character

.text
.globl rng_main

rng_main:
    addi $sp, $sp, -4		# Give the stack 4 bytes to work with
    sw $ra, 0($sp)		# Store the return address to the stack
    
    # Reset boardNums
    li $t0, 0			# i = 0
    la $t2, boardNums		# Have t2 point to boardNums
boardNum_reset:
    add $t1, $t2, $t0		# t1 points to boardNums[i]
    sb $t0, 0($t1)		# boardNums[i] = i

    addi $t0, $t0, 1		# i++
    slti $t1, $t0, 16		# Is i < 16?
    bnez $t1, boardNum_reset	# If so, then loop
    
    # Set up the random number generator with a seed
    li $a0, 0                   # Pseudorandom generator ID 
    lw $a1, seed                # Load the seed
    li $v0, SysRandInt          # Syscall for setting random seed
    syscall			# Establish the RNG

    # Generate 8 random equations and products
    jal GenerateRandomEquations	# Call the equation generator
    
    # Shuffle the board
    jal ShuffleBoard		# Call the board shuffler

    lw $ra, 0($sp)		# Restore the return address from the stack
    addi $sp, $sp, 4		# Pop the stack
    jr $ra                      # Return to exit program

# Generate random equations and products
GenerateRandomEquations:
    li $t0, 0                   # Initialize counter (0 to 7 for 8 iterations)
    li $a1, 12                  # Set upper bound for random numbers (1-12)

generate_loop:
    # Generate random factor1
    li $v0, SysRandIntRange     # Syscall for generating random number in range
    li $a0, 0                   # Random generator ID
    syscall                     # Random number now in $a0
    addi $a0, $a0, 1            # Adjust range to 1-12
    sw $a0, factor1($t0)        # Store in factor1 array

    # Generate random factor2
    li $v0, SysRandIntRange     # Syscall for generating random number in range
    li $a0, 0                   # Random generator ID
    syscall			# Get a random number
    addi $a0, $a0, 1            # Adjust range to 1-12
    sw $a0, factor2($t0)        # Store in factor2 array

    # Calculate product = factor1 * factor2
    lw $t1, factor1($t0)        # Load factor1
    lw $t2, factor2($t0)        # Load factor2
    mul $t3, $t1, $t2           # Calculate product
    sw $t3, products($t0)       # Store product in products array

    # Increment counter and loop for 8 iterations
    addi $t0, $t0, 4		# counter += 4
    blt $t0, 32, generate_loop	# If counter < 32, repeat

    jr $ra                      # Return from function
    
ShuffleBoard:
    li $t0, 0			# int i = 0
    la $t2, boardNums		# byte *boardNums
    la $t4, cellPairs		# byte *cellPairs
            
shuffle_start:
    li $t1, 16			# There are 16 cells in the board
    sub $t1, $t1, $t0		# int upperLimit = 16 - i (bc we're popping a random board element each iteration)
    
    li $v0, SysRandIntRange	# Prepare to generate a random number
    li $a0, 0			# Set the random id argument to 0
    move $a1, $t1		# Set the upper limit to upperLimit
    syscall			# Create a random number. Result represents an index of boardNums
    
    add $t3, $t2, $a0		# byte *currBoardNum = boardNums + index
    lb $t3, 0($t3)		# Get the currBoardNum
    add $t5, $t4, $t0		# byte *nextCellNum = cellPairs + i
    sb $t3, 0($t5)		# nextCellNum = currBoardNum
    
    move $t3, $a0		# int j = index

remove_start:
    add $t5, $t2, $t3		# byte *oldBoardNum = board[j]
    lb $t6, 1($t5)		# byte nextNum = oldBoardNum[1]
    sb $t6, 0($t5)		# oldBoardNum[0] = nextNum; This just shifts everything one space to the left

    addi $t3, $t3, 1		# j++
    blt $t3, $t1, remove_start	# Repeat inner loop if j < upperLimit

    addi $t0, $t0, 1		# i++
    blt $t0, 16, shuffle_start	# Repeat loop if i < 16
    
    jr $ra			# Return


