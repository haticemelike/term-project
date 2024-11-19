#	CS2340 Term Project - Graphics Component
#
#	Author: Serhan Doganay
#	Date: 09-25-2024 
#	Location: UTD
#

# BITMAP NOTES
# UNIT Width: 4px; Height: 4 px
# DISPLAY Width: 512px; Height: 512 px
# BASE ADDRESS: 0x10000000 (global data)
# Each word represents a unit: 00,rr,gg,bb

# DIVIDE THE DISPLAY INTO A 6X6 GRID (128 x 128 display -> 21.33 x 21.33 per grid square. I'll round this down to 20 x 20)
# Each square should be 20 x 20 units. The border will be contribute an extra pixel on top of that.
# The multiplication (x) character can be represented as a 3x3 arrangement. The worst case scenario is having ##x## in a box.
# With this, the digits can each be 5 digits wide.

.data
    # The characters are an array of 7 bytes; each byte represents a row, and the binary representation of each row represents which of the three pixels in that row are "on"
    ZERO_CHAR:	.byte 2,5,5,5,5,5,2
    ONE_CHAR:	.byte 1,1,1,1,1,1,1
    TWO_CHAR:	.byte 2,5,1,2,4,4,7
    THREE_CHAR:	.byte 2,5,1,2,1,5,2
    FOUR_CHAR:	.byte 5,5,5,7,1,1,1
    FIVE_CHAR:	.byte 7,4,6,1,1,5,2
    SIX_CHAR:	.byte 2,5,4,6,5,5,2
    SEVEN_CHAR:	.byte 7,1,1,2,2,4,4
    EIGHT_CHAR:	.byte 2,5,5,2,5,5,2
    NINE_CHAR:	.byte 2,5,5,3,1,5,2
    CROSS_CHAR:	.byte 0,0,5,2,5,0,0
    
    dispAddr:	.word 0x10000000

.text

SetUnit:			# a0 = (int) x-coordinate; a1 = (int) y-coordinate; a2 = (bool) on
    mul $t0, $a1, 128		# y:0 starts at 0; y:1 starts at 128; y:2 starts at 256...
    add $t0, $t0, $a0		# Add the x-coordinate to find the unit index that corresponds to this position
    sll $t0, $t0, 2		# Multiply the index by 4 to make this word-friendly
    
    la $t1, dispAddr		# Get the base display address for the bitmap display
    lw $t1, 0($t1)		# Dereference the display address pointer
    add $t1, $t1, $t0		# Get the absolute address of this unit
    
    sub $t2, $zero, $a2		# If the "on" argument is 0, then t2 is 0. Otherwise, t2 is 0xFFFFFFFF.
    sw $t2, 0($t1)		# Set the bitmap ?RGB value to the unit in question
    
    jr $ra			# Return
    
DrawLine:			# a0 = (int) startX; a1 = (int) startY; a2 = (int) length; a3 = (int) direction (0=horizontal,1=vertical)
    addi $sp, $sp, -12		# Give the stack 4 bytes to work with
    sw $s1, 8($sp)		# Store s1 in the stack
    sw $s0, 4($sp)		# Store s0 in the stack
    sw $ra, 0($sp)		# Store the return address to the stack
    
    li $s0, 0			# int i = 0
    move $s1, $a2		# Don't lose track of the length
    li $a2, 1			# Set the SetUnit "on" parameter to 1

line_loop:
    jal SetUnit			# Draw the line one unit at a time

    beqz $a3, increment_x	# If the direction is 0, then x++
    addi $a1, $a1, 1		# Otherwise, y++
    j post_updateline		# Skip the x++
increment_x:
    addi $a0, $a0, 1		# x++
post_updateline:
    addi $s0, $s0, 1		# i++
    slt $t0, $s0, $s1		# Is i < length?
    bnez $t0, line_loop		# If so, then repeat the loop
    
    lw $ra, 0($sp)		# Restore the return address from the stack
    lw $s0, 4($sp)		# Pop s0 from the stack
    lw $s1, 8($sp)		# Pop s1 from the stack
    addi $sp, $sp, 12		# Pop the stack
    jr $ra			# Return
    
DrawNumber:			# a0 = (int) x-coordinate (topleft); a1 = (int) y-coordinate (topleft); a2 = (int) number (for our intents and purposes, "*" is a number (10))
    addi $sp, $sp, -24		# Give the stack 4 bytes to work with
    sw $s3, 20($sp)		# Store s4 in the stack
    sw $s3, 16($sp)		# Store s3 in the stack
    sw $s2, 12($sp)		# Store s2 in the stack
    sw $s1, 8($sp)		# Store s1 in the stack
    sw $s0, 4($sp)		# Store s0 in the stack
    sw $ra, 0($sp)		# Store the return address to the stack
    
    mul $s2, $a2, 7		# Multiply the number by 7 to get its offset in the .data table
    la $t1, ZERO_CHAR		# Have t1 point to the beginning of the number bitmap table
    add $s2, $t1, $s2		# Have s2 point to the this specific number's bitmap data
    
    move $s0, $a0		# Keep a record of the topleft corner [X]
    move $s1, $a1		# [Y]
    
    li $s3, 0			# i = 0
num_loop:
    lb $s4, 0($s2)		# Retrieve the current row's bitmap data
    
    andi $t3, $s4, 4		# Check out the leftmost unit in this row
    beqz $t3, check_middle	# If the leftmost unit is OFF, then skip this code
    
    move $a0, $s0		# a0 = base X coordinate
    move $a1, $s1		# a1 = get the correct Y coordinate
    li $a2, 1			# Turn on this unit
    jal SetUnit			# Set the unit
    
check_middle:
    andi $t3, $s4, 2		# Check out the middle unit in this row
    beqz $t3, check_right	# If the middle unit is OFF, then skip this code
    
    addi $a0, $s0, 1		# a0 = base X coordinate + 1
    move $a1, $s1		# a1 = get the correct Y coordinate
    li $a2, 1			# Turn on this unit
    jal SetUnit			# Set the unit
    
check_right:
    andi $t3, $s4, 1		# Check out the rightmost unit in this row
    beqz $t3, end_num_loop	# If the rightmost unit is OFF, then skip this code
    
    addi $a0, $s0, 2		# a0 = base X coordinate + 2
    move $a1, $s1		# a1 = get the correct Y coordinate
    li $a2, 1			# Turn on this unit
    jal SetUnit			# Set the unit

end_num_loop:
    addi $s2, $s2, 1		# Have s2 point to the next row's bitmap data
    addi $s1, $s1, 1		# Prepare to draw to the next row
    addi $s3, $s3, 1		# i++
    slti $t2, $s3, 7		# Is i < 7?
    bnez $t2, num_loop		# If so, then repeat the loop
    
    lw $ra, 0($sp)		# Restore the return address from the stack
    lw $s0, 4($sp)		# Pop s0 from the stack
    lw $s1, 8($sp)		# Pop s1 from the stack
    lw $s2, 12($sp)		# Pop s2 from the stack
    lw $s3, 16($sp)		# Pop s3 from the stack
    lw $s4, 20($sp)		# Pop s4 from the stack
    addi $sp, $sp, 24		# Pop the stack
    jr $ra			# Return

InitializeGrid:
    # HORIZ: (20,20), (20,40), (20,60), (20,80), (20,100)
    # VERT: (20,20), (40,20), (60,20), (80,20), (100,20)
    # ..Except the lines should increment by 21, not by 20, to account for the borders
    addi $sp, $sp, -4		# Give the stack 4 bytes to work with
    sw $s0, 4($sp)		# Store s0 in the stack
    sw $ra, 0($sp)		# Store the return address to the stack
    
    li $s0, 0			# i = 0
grid_loop:
    li $a0, 20			# Start the x-coordinate of the line at 20
    mul $a1, $s0, 21		# Set the y-coordinate of the line at i*21
    add $a1, $a1, 20		# Add another 20 units to the y
    li $a2, 85			# Make the line 85 units long (4 cells * 20 units/cell + 5 borders * 1 unit/border)
    li $a3, 0			# Make the line horizontal
    jal DrawLine		# Draw the line
    
    li $a1, 20			# Start the y-coordinate of the line at 20
    mul $a0, $s0, 21		# Set the x-coordinate of the line at i*21
    add $a0, $a0, 20		# Add another 20 units to the x
    li $a2, 85			# Make the line 85 units long (4 cells * 20 units/cell + 5 borders * 1 unit/border)
    li $a3, 1			# Make the line vertical
    jal DrawLine		# Draw the line

    addi $s0, $s0, 1		# i++
    slti $t0, $s0, 5		# Is i < 5?
    bnez $t0, grid_loop		# If so, then repeat the loop
    
    # TESTTESTTEST!!!!!!!
    li $a0, 0
    li $a1, 0
    li $a2, 0
    jal DrawNumber
    
    li $a0, 10
    li $a1, 0
    li $a2, 1
    jal DrawNumber
    
    li $a0, 20
    li $a1, 0
    li $a2, 2
    jal DrawNumber
    
    li $a0, 30
    li $a1, 0
    li $a2, 3
    jal DrawNumber
    
    li $a0, 40
    li $a1, 0
    li $a2, 4
    jal DrawNumber
    
    li $a0, 50
    li $a1, 0
    li $a2, 5
    jal DrawNumber
    
    li $a0, 60
    li $a1, 0
    li $a2, 6
    jal DrawNumber
    
    li $a0, 70
    li $a1, 0
    li $a2, 7
    jal DrawNumber
    
    li $a0, 80
    li $a1, 0
    li $a2, 8
    jal DrawNumber
    
    li $a0, 90
    li $a1, 0
    li $a2, 9
    jal DrawNumber
    
    li $a0, 100
    li $a1, 0
    li $a2, 10
    jal DrawNumber
    # ENDTEST!!!!!!!!!!!!
    
    lw $ra, 0($sp)		# Restore the return address from the stack
    lw $s0, 4($sp)		# Pop s0 from the stack
    addi $sp, $sp, 8		# Pop the stack
    jr $ra			# Return

DrawBoardCLI:
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
    
