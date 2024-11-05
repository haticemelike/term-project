#	CS2340 Term Project - Graphics Component
#
#	Author: Serhan Doganay
#	Date: 09-25-2024 
#	Location: UTD
#

.text
DrawBoard:
    addi $sp, $sp, -8		# Give the stack 8 bytes to work with
    sw $zero, 4($sp)		# Clear one entry in the stack - this will be a column counter
    sw $ra, 0($sp)		# Store the return address to the stack

    li $t0, 0			# int i = 0
    la $t1, cellPairs		# Set the cellPairs array to t1
    la $t2, factor1		# Set the first factors array to t2
    la $t3, factor2		# Set the second factors array to t3
    la $t4, products		# Set the products array to t4
    
draw_loop:
    add $t5, $t1, $t0		# t5 points to cellPairs[i]
    lb $t5, 0($t5)		# Read the value at t5
    blt $t5, 8, opt_factor	# Values < 8 mean that this cell will display the factors
    subi $t5, $t5, 8		# Otherwise, consider value - 8, and we will display the product
    sll $t5, $t5, 2		# t5 *= 4, for word-array purposes
    add $t5, $t5, $t4		# t5 points to products[cellPairs[i]]
    lw $t5, 0($t5)		# Read the value at t5
    
    li $v0, SysPrintInt		# Prepare to print an int
    move $a0, $t5		# Set the print argument to the product
    syscall			# Print the product
    
    j drawloop_end		# Skip past the factor code
    
opt_factor:
    sll $t5, $t5, 2		# t5 *= 4, for word-array purposes
    add $t6, $t5, $t2		# t6 points to factor1[cellPairs[i]]
    add $t7, $t5, $t3		# t7 points to factor2[cellPairs[i]]
    
    lw $t6, 0($t6)		# Read the value at t6
    lw $t7, 0($t7)		# Read the value at t7
    
    move $a0, $t6               # Move factor1 to $a0
    li $v0, SysPrintInt         # Syscall to print integer
    syscall			# Print the first factor

    # Print " x "
    la $a0, multiply_msg        # Load " x " string
    li $v0, SysPrintString      # Syscall to print string
    syscall			# Print the string

    move $a0, $t7               # Move factor2 to $a0
    li $v0, SysPrintInt         # Syscall to print integer
    syscall			# Print the second factor
    
drawloop_end:
    li $v0, SysPrintChar	# Prepare to print a char
    li $a0, 0x7C		# Set the char argument to the vertical bar character
    syscall			# Print a vertical bar
    
    lw $t5, 4($sp)		# t5 = column counter
    addi $t5, $t5, 1		# column counter++
    bne $t5, 4, newline_end	# Skip past making a new row if we're not done with the row yet
    
    la $a0, newline		# Set newline as the print argument
    li $v0, SysPrintString      # Syscall to print newline
    syscall			# Make a new line
    
    li $t5, 0			# Set the column counter to 0
    
newline_end:
    sw, $t5, 4($sp)		# Save the column counter

    addi $t0, $t0, 1		# i++
    blt $t0, 16, draw_loop	# Repeat the loop if i < 16
    
    lw $ra, 0($sp)		# Restore the return address from the stack
    addi $sp, $sp, 8		# Pop the stack
    jr $ra                      # Return to exit program