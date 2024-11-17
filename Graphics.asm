#	CS2340 Term Project - Graphics Component
#
#	Author: Serhan Doganay
#	Date: 09-25-2024 
#	Location: UTD
#

.text

DrawBoard:
    addi $sp, $sp, -8          # Give the stack 8 bytes to work with
    sw $zero, 4($sp)           # Clear one entry in the stack - this will be a column counter
    sw $ra, 0($sp)             # Store the return address to the stack

    li $t0, 0                  # i = 0 for looping through 16 cards
    la $t1, card_states        # Load card state array
    la $t2, cellPairs          # Load card content array (contains indexes for factors and products)

draw_loop:
    # Check if the card is revealed
    lb $t3, card_states($t0)   # Load state of the current card
    beq $t3, 0, print_front    # If state is 0, print the front (card index)

    # If revealed, show the equation or product (back of the card)
    lb $t4, cellPairs($t0)     # Load cell pair index for the current card
    blt $t4, 8, show_equation  # If < 8, it's an equation card
    sub $t4, $t4, 8            # Adjust for product cards
    j show_product

print_front:
    # Print the card index (1-16) as a placeholder for hidden cards
    addi $a0, $t0, 1           # Card number (1-16)
    li $v0, SysPrintInt        # Print the index
    syscall
    j drawloop_end             # Skip to end of draw loop

show_equation:
    # Print the equation in format "factor1 x factor2"
    sll $t4, $t4, 2            # t4 *= 4 to index factor arrays
    lw $t5, factor1($t4)       # Load factor1 for the equation
    lw $t6, factor2($t4)       # Load factor2 for the equation

    # Print factor1
    move $a0, $t5
    li $v0, SysPrintInt
    syscall

    # Print " x "
    la $a0, multiply_msg
    li $v0, SysPrintString
    syscall

    # Print factor2
    move $a0, $t6
    li $v0, SysPrintInt
    syscall
    j drawloop_end

show_product:
    # Print the product
    sll $t4, $t4, 2            # t4 *= 4 to index product array
    lw $t5, products($t4)      # Load product

    move $a0, $t5
    li $v0, SysPrintInt
    syscall

drawloop_end:
    # Print vertical bar for separation
    li $v0, SysPrintChar       # Prepare to print a char
    li $a0, 0x7C               # ASCII for '|'
    syscall		       # Print a vertical bar

    # Handle row wrapping
    lw $t3, 4($sp)             # Column counter
    addi $t3, $t3, 1	       # Column counter++
    bne $t3, 4, newline_end    # Skip past making a new row if we're not done with the row yet

    # Newline after 4 cards
    la $a0, newline	       # Set newline as the print argument
    li $v0, SysPrintString     # Syscall to print newline
    syscall                    # Make a new line
    li $t3, 0                  # Set the column counter to 0

newline_end:
    sw $t3, 4($sp)             # Save the column counter

    addi $t0, $t0, 1           # i++
    blt $t0, 16, draw_loop     # Repeat the loop if i < 16

    lw $ra, 0($sp)             # Restore the return address from the stack
    addi $sp, $sp, 8           # Pop the stack
    jr $ra                     # Return to exit program
    
