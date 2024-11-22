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
    A_CHAR:	.byte 2,5,5,7,5,5,5		# 11
    B_CHAR:	.byte 6,5,5,6,5,5,6		# 12
    C_CHAR:	.byte 3,4,4,4,4,4,3		# 13
    D_CHAR:	.byte 6,5,5,5,5,5,6		# 14
    E_CHAR:	.byte 7,4,4,7,4,4,7		# 15
    F_CHAR:	.byte 7,4,4,6,4,4,4		# 16
    G_CHAR:	.byte 7,4,4,5,5,5,7		# 17
    H_CHAR:	.byte 5,5,5,7,5,5,5		# 18
    I_CHAR:	.byte 7,2,2,2,2,2,7		# 19
    J_CHAR:	.byte 7,2,2,2,2,2,4		# 20
    K_CHAR:	.byte 5,5,5,6,5,5,5		# 21
    L_CHAR:	.byte 4,4,4,4,4,4,7		# 22
    M_CHAR:	.byte 5,7,5,5,5,5,5		# 23
    N_CHAR:	.byte 7,5,5,5,5,5,5		# 24
    O_CHAR:	.byte 7,5,5,5,5,5,7		# 25
    P_CHAR:	.byte 7,5,5,7,4,4,4		# 26
    Q_CHAR:	.byte 7,5,5,5,7,2,1		# 27
    R_CHAR:	.byte 7,5,5,6,5,5,5		# 28
    S_CHAR:	.byte 3,4,4,2,1,1,6		# 29
    T_CHAR:	.byte 7,2,2,2,2,2,2		# 30
    U_CHAR:	.byte 5,5,5,5,5,5,7		# 31
    V_CHAR:	.byte 5,5,5,5,5,5,2		# 32
    W_CHAR:	.byte 5,5,5,5,7,7,2		# 33
    X_CHAR:	.byte 5,5,5,2,5,5,5		# 34
    Y_CHAR:	.byte 5,5,5,2,2,2,2		# 35
    Z_CHAR:	.byte 7,1,1,2,4,4,7		# 36
    COLON_CHAR:	.byte 0,2,2,0,2,2,0		# 37
    NULL_CHAR:	.byte -1,-1,-1,-1,-1,-1,-1	# 38 - 255 shall just have the special meaning of clearing the bitmap display
    
    dispAddr:	.word 0x10000000
    
    consoleMsg:	.asciiz "SELECT CARDS THROUGH THE CONSOLE"
    badCardMsg:	.asciiz "PLEASE SELECT DIFFERENT CARDS"
    bmpPassMsg:	.asciiz "ITS A MATCH"
    bmpFailMsg: .asciiz "TRY AGAIN"
    gameEndMsg:	.asciiz "CONGRATULATIONS YOU WIN"
    cdsLeftMsg:	.asciiz "   CARDS LEFT"
    bmpTimeMsg:	.asciiz "ELAPSED TIME: "
    clearMsg:	.asciiz "                                "

.text

SetUnit:			# a0 = (int) x-coordinate; a1 = (int) y-coordinate; a2 = (bool) on
    sll $t0, $a1, 7		# y:0 starts at 0; y:1 starts at 128; y:2 starts at 256...
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
    addi $sp, $sp, -24		# Give the stack 24 bytes to work with
    sw $s4, 20($sp)		# Store s4 in the stack
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
    
    bne $s4, -1, check_left	# If the bitmap data is not -1, then interpret this as bits which set bits on
    move $a0, $s0		# Get the first X value in the row
    move $a1, $s1		# Get the Y value
    li $a2, 0			# Turn this unit OFF
    jal SetUnit			# Set the unit
    addi $a0, $s0, 1		# Get the second X value
    move $a1, $s1		# Get Y
    li $a2, 0			# Turn this OFF
    jal SetUnit			# Set the unit
    addi $a0, $s0, 2		# Get the third X value
    move $a1, $s1		# Get Y
    li $a2, 0			# Turn this OFF
    jal SetUnit			# Set the unit
    j end_num_loop		# Skip to the end of the loop
    
check_left:
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
    
WriteToCell:			# a0 = cell number (0 for top left, 15 for bottom right), a1-a3&v0-v1 = chars (-1 if no char)
    addi $sp, $sp, -28		# Give the stack 28 bytes to work with
    sb $v1, 24($sp)		# Store the fifth digit in the stack
    sb $v0, 23($sp)		# Store the fourth digit in the stack
    sb $a3, 22($sp)		# Store the third digit in the stack
    sb $a2, 21($sp)		# Store the second digit in the stack
    sb $a1, 20($sp)		# Store the first digit in the stack
    sw $s3, 16($sp)		# Store s3 in the stack
    sw $s2, 12($sp)		# Store s2 in the stack
    sw $s1, 8($sp)		# Store s1 in the stack
    sw $s0, 4($sp)		# Store s0 in the stack
    sw $ra, 0($sp)		# Store the return address to the stack
    
    # First of all, how many chars are we working with?
    li $t0, 0			# i = 0
    beq $a1, -1, calc_spaces	# We have no chars (ideally should never happen). Leave.
    addi $t0, $t0, 1		# i++
    beq $a2, -1, calc_spaces	# We only have one char. Leave.
    addi $t0, $t0, 1		# i++
    beq $a3, -1, calc_spaces	# We have two chars. Leave.
    addi $t0, $t0, 1		# i++
    beq $v0, -1, calc_spaces	# We have three chars. Leave.
    addi $t0, $t0, 1		# i++
    beq $v1, -1, calc_spaces	# We have four chars. Leave.
    addi $t0, $t0, 1		# i++ (if we made it here, we have five chars)
calc_spaces:
    # Determine where the first digit should be drawn
    sll $t1, $t0, 1		# t1 = numChars * 2
    li $t2, 12			# t2 = 12
    sub $t1, $t2, $t1		# t1 = 12 - 2*numChars (X COORDINATE OF WHERE TO DRAW THE FIRST DIGIT)
    
    # Now find the top left corner of the cell
    andi $t2, $a0, 3		# t2 = cellNumber % 4. This represents the "xIndex" of the cell
    srl $t3, $a0, 2		# t3 = cellNumber / 4. This represents the "yIndex" of the cell
    mul $t2, $t2, 22		# xIndex *= 22 (account for the cell widths) 
    addi $t2, $t2, 20		# xIndex += 20 (account for the grid offset) (X_UNIT)
    mul $t3, $t3, 22		# yIndex *= 22 (account for the cell heights) 
    addi $t3, $t3, 20		# yIndex += 20 (account for the grid offset) (Y_UNIT)
    
    # Now find the absolute position for the top left corner of the first digit
    add $t2, $t2, $t1		# digitX = X_UNIT + digitX
    addi $t3, $t3, 8		# digitY = Y_UNIT + 8 (so that the digit prints in the middle of the cell)
   
    # Save our variables
    move $s0, $t0		# s0 holds the number of digits we have
    move $s1, $t2		# s1 holds the x coordinate of the first digit
    move $s2, $t3		# s2 holds the y coordinate of all the digits
      
    # Start the print loop
    li $s3, 0			# j = 0
digit_loop:
    # Which digit am I printing again? Check in stack[20 + j]
    addi $t0, $s3, 20		# t0 = 20 + j
    add $t0, $t0, $sp		# t0 points to stack[20+j]
    lb $a2, 0($t0)		# a2 reads stack[20+j] (the "jth" character)
    move $a0, $s1		# Set the x coordinate argument
    move $a1, $s2		# Set the y coordinate argument
    jal DrawNumber		# Draw the character

    addi $s3, $s3, 1		# j++
    addi $s1, $s1, 4		# digitX += 4
    slt $t0, $s3, $s0		# Is j < numChars?
    bnez $t0, digit_loop	# Loop if so
    
    lw $ra, 0($sp)		# Restore the return address from the stack
    lw $s0, 4($sp)		# Pop s0 from the stack
    lw $s1, 8($sp)		# Pop s1 from the stack
    lw $s2, 12($sp)		# Pop s2 from the stack
    lw $s3, 16($sp)		# Pop s3 from the stack
    addi $sp, $sp, 28		# Pop the stack
    jr $ra			# Return
    
ClearCell:			# a0 = cell number (0 for top left, 15 for bottom right)
    addi $sp, $sp, -8		# Give the stack 8 bytes to work with
    sw $a0, 4($sp)		# Store the cell number in the stack
    sw $ra, 0($sp)		# Store the return address in the stack
    
    li $a1, 38			# 38 maps to the null character (a 3x7 black square)
    li $a2, 38			# Set the second character
    li $a3, 38			# Set the third character
    li $v0, 38			# Set the fourth character
    li $v1, 38			# Set the fifth character
    jal WriteToCell		# Clear this cell
    
    lw $a0, 4($sp)		# Restore the cell number from the stack
    li $a1, 38			# 38 maps to the null character (a 3x7 black square)
    li $a2, 38			# Set the second character
    li $a3, 38			# Set the third character
    li $v0, 38			# Set the fourth character
    li $v1, -1			# No fifth character (so that this offsets the digits slightly)
    jal WriteToCell		# Clear this cell
    
    lw $ra, 0($sp)		# Restore the return address from the stack
    addi $sp, $sp, 8		# Pop the stack
    jr $ra			# Return
    
WriteMathToCell:		# a0 = cell number; a1 = number to print (literal number); a2 = second number (-1 if no second number) (renders as "a1*a2" if set)
    # numDigits = 1 by default (always assume we're printing at least one digit)
    # If a1 > 9, numDigits++ (two digits)
    # If a2 != -1 numDigits += 2 (one digit for the multiplication symbol, and one for the actual digit
    # If a2 > 9, numDigits++ (two digits)
    
    # numDigits = 1
    #
    # IF a1 >= 100,
    #   (I already know a1 must be the only number to print)
    #   STACK[0] = a1 / 100
    #   a1 -= 100
    #   STACK[1] = a1 / 10
    #   STACK[2] = a1 - 10
    #   ...jump straight to printing
    # IF a1 >= 10,
    #	numDigits++
    # 	STACK[0] = a1 / 10
    #	STACK[1] = a1 - 10
    # ELSE
    #	STACK[0] = a1
    #
    # IF a2 != -1,
    #	STACK[numDigits] = 'X'
    #   numDigits++
    #   IF a2 >= 10,
    #	  STACK[numDigits] = a2 / 10
    #	  STACK[numDigits+1] = a2 - 10
    #	ELSE
    #	  STACK[numDigits] = a2
    
    addi $sp, $sp, -12		# Give the stack 12 bytes to work with
    sw $ra, 0($sp)		# Store the return address in the stack
    li $t0, -1			# Set t0 = -1
    sb $t0, 4($sp)		# STACK[0] = -1
    sb $t0, 5($sp)		# STACK[1] = -1
    sb $t0, 6($sp)		# STACK[2] = -1
    sb $t0, 7($sp)		# STACK[3] = -1
    sb $t0, 8($sp)		# STACK[4] = -1
    
    li $t1, 1			# numDigits = 1
    
    blt $a1, 100, not_three	# Is the first number three digits?
    div $t0, $a1, 100		# The first number is three digits! Get a1 / 100 (first digit)
    sb $t0, 4($sp)		# STACK[0] = a1 / 100
    mul $t0, $t0, 100		# This basically just gets the hundreds place (t0)
    sub $a1, $a1, $t0		# a1 -= t0
    div $t0, $a1, 10		# Get a1 / 10 (second digit)
    sb $t0, 5($sp)		# STACK[1] = a1 / 10
    mul $t0, $t0, 10		# Get the tens place (t0)
    sub $t0, $a1, $t0		# Get a1 - t0 (for the third digit)
    sb $t0, 6($sp)		# STACK[2] = a1 - t0
    j stop_digits		# Jump to the printing code
    
not_three:
    blt $a1, 10, one_digit_A	# Is the first number one or two digits?
    div $t0, $a1, 10		# The first number is two digits! Get a1 / 10 (to get the first digit)
    sb $t0, 4($sp)		# STACK[0] = a1 / 10
    mul $t0, $t0, 10		# Get the tens place (t0)
    sub $t0, $a1, $t0		# Get a1 - t0 (to get the second digit)
    sb $t0, 5($sp)		# STACK[1] = a1 - t0
    addi $t1, $t1, 1		# numDigits++
    j check_second_digit	# Jump to check the second digit
    
one_digit_A:
    sb $a1, 4($sp)		# The first number is one digit! STACK[0] = a1
    
check_second_digit:
    beq $a2, -1, stop_digits	# Do we even have a second number? Skip this code if we don't
    add $t1, $t1, 4		# numDigits += 4 (not in the pseudocode, but it aligns with the fact that the character stack data starts at index 4
    add $t1, $t1, $sp		# numDigits += $sp (just to point to STACK[numDigits]
    li $t0, 10			# t0 = multiplication symbol
    sb $t0, 0($t1)		# STACK[numDigits] = multiplication symbol
    addi $t1, $t1, 1		# numDigits++
    
    blt $a2, 10, one_digit_B	# Is the second number one or two digits?
    div $t0, $a2, 10		# The second number is two digits! Get a2 / 10 (to get the first digit)
    sb $t0, 0($t1)		# STACK[numDigits] = a2 / 10
    subi $t0, $a2, 10		# Get a2 - 10 (to get the second digit)
    sb $t0, 1($t1)		# STACK[numDigits+1] = a2 - 10
    j stop_digits		# Jump to the printing code
    
one_digit_B:
    sb $a2, 0($t1)		# STACK[numDigits] = a2
    
stop_digits:
    lb $a1, 4($sp)		# Load a1 from STACK[0]
    lb $a2, 5($sp)		# Load a2 from STACK[1]
    lb $a3, 6($sp)		# Load a3 from STACK[2]
    lb $v0, 7($sp)		# Load v0 from STACK[3]
    lb $v1, 8($sp)		# Load v1 from STACK[4]
    jal WriteToCell		# Write the expression to the cell
    
    lw $ra, 0($sp)		# Restore the return address from the stack
    addi $sp, $sp, 12		# Restore the stack
    jr $ra			# Return
    
DrawText:			# a0 = x coordinate; a1 = y coordinate; a2 = char*
    # int i = 0
    # char c = a2[i]
    # while (c)
    #    if c == 0x20 // space
    #        DrawNumber(a0 + i*4, a1, 38)
    #    else
    #        DrawNumber(a0 + i*4, a1, c - 65 + 11)
    #    i++
    #    c = a2[i]
    addi $sp, $sp, -20		# Give the stack 16 bytes to work with
    sw $s0, 0($sp)		# Save s0
    sw $s1, 4($sp)		# Save s1
    sw $s2, 8($sp)		# Save s2
    sw $s3, 12($sp)		# Save s3
    sw $ra, 16($sp)		# Save the return address
    
    move $s0, $a0		# Save the original x coordinate
    move $s1, $a1		# Save the y coordinate
    move $s2, $a2		# Save the char*
    li $s3, 0			# i = 0
    
    add $t0, $s2, $s3		# Have t0 point to a2[i]
    lb $t0, 0($t0)		# t0 = a2[i]
    
text_while_loop:
    beqz $t0, end_text_while	# We hit a null character! Exit.
    
    sll $a0, $s3, 2		# a0 = i*4
    add $a0, $a0, $s0		# a0 += x coord
    move $a1, $s1		# a1 = y coord
    
    beq $t0, 0x20, handle_space	# This character is a space. Handle this
    beq $t0, 0x3A, handle_colon	# This character is a colon. Handle this
    subi $a2, $t0, 65		# Convert the letter to a number (A=0, B=1)
    addi $a2, $a2, 11		# Get the bitmap letter index
    
    j text_while_inc		# Skip the space code / colon code

handle_space:
    li $a2, 38			# a2 = the empty character
    j text_while_inc		# Skip the colon code
    
handle_colon:
    li $a2, 37			# a2 = the colon character

text_while_inc:
    jal DrawNumber		# Draw a character, whether it is a space or a letter

    addi $s3, $s3, 1		# i++
    add $t0, $s2, $s3		# Have t0 point to a2[i]
    lb $t0, 0($t0)		# t0 = a2[i]
    j text_while_loop		# Repeat the loop
    
end_text_while:    
    lw $ra, 16($sp)		# Restore the return address
    lw $s3, 12($sp)		# Restore s3
    lw $s2, 8($sp)		# Restore s2
    lw $s1, 4($sp)		# Restore s1
    lw $s0, 0($sp)		# Restore s0
    addi $sp, $sp, 20		# Restore the stack
    jr $ra			# Return
    
PrintCardsRemaining:		# a0 = # of cards remaining
    addi $sp, $sp, -8		# Give the stack 8 bytes to work with
    sw $ra, 0($sp)		# Store the return address in the stack
    sw $s0, 4($sp)		# Store s0 in the stack

    move $s0, $a0		# Save the # of cards
    
    li $a0, 0			# Go to the leftmost unit
    li $a1, 121			# Go to the topmost unit
    la $a2, clearMsg		# Fetch the empty string
    jal DrawText		# Print to screen
    li $a0, 0			# Go to the leftmost unit
    li $a1, 121			# Go to the topmost unit
    la $a2, cdsLeftMsg		# Fetch the cards remaining string
    jal DrawText		# Print to screen
    
    div $t0, $s0, 10		# t0 = tens digit
    mul $t1, $t0, 10		# Get the right place value
    sub $s0, $s0, $t1		# Subtract the tens from the number
    
    li $a0, 0			# Draw at X=0
    li $a1, 121			# Draw at Y=121
    move $a2, $t0		# Load the tens digit
    jal DrawNumber		# Print the number to the screen
    
    li $a0, 4			# Draw at X=4
    li $a1, 121			# Draw at Y=121
    move $a2, $s0		# Load the ones digit
    jal DrawNumber		# Print the number to the screen
    
    lw $s0, 4($sp)		# Restore s0
    lw $ra, 0($sp)		# Restore the return address
    addi $sp, $sp, 8		# Restore the stack
    jr $ra			# Return
    
PrintTime:			# a0 = elapsed minutes; a1 = elapsed seconds
    addi $sp, $sp, -16		# Give the stack 16 bytes to work with
    sw $ra, 0($sp)		# Store the return address in the stack
    sw $s0, 4($sp)		# Store s0 in the stack
    sw $s1, 8($sp)		# Store s1 in the stack
    sw $s2, 12($sp)		# Store s2 in the stack

    move $s0, $a0		# Save the minutes argument
    move $s1, $a1		# Save the seconds argument
    
    li $a0, 0			# Set the x value to 0
    li $a1, 113			# Set the y value to 113
    la $a2, clearMsg		# Fetch the empty string
    jal DrawText		# Print to screen

    li $a0, 0			# Set the x value to 0
    li $a1, 113			# Set the y value to 113
    la $a2, bmpTimeMsg		# Fetch the elapsed time string
    jal DrawText		# Print to string
    
    # Cap the display at 99 mins and 59 sec
    blt $s0, 99, displayTimeMMSS# Prepare to print the time
    li $s0, 99			# If the minutes argument exceeds 99, just print 99
    li $s1, 59			# Because we are past our 99th minute, just leave it as 59 seconds
    
displayTimeMMSS:
    div $s2, $s0, 10		# s2 = s0 / 10 (tens digit of the minutes)
    li $a0, 56			# Set the x value to 56
    li $a1, 113			# Set the y value to 113
    move $a2, $s2		# Print the tens digit of the number of minutes
    jal DrawNumber		# Write the number to the screen
    
    mul $s2, $s2, 10		# Get the tens digit in its proper place value
    sub $a2, $s0, $s2		# Subtract the tens from the minutes to isolate the ones, and write that number
    li $a0, 60			# Set the x value to 60
    li $a1, 113			# Set the y value to 113
    jal DrawNumber		# Write the number to the screen
    
    li $a0, 64			# Set the x value to 64
    li $a1, 113			# Set the y value to 113
    li $a2, 37			# Prepare to print the colon character
    jal DrawNumber		# Write the colon to the screen
    
    div $s2, $s1, 10		# s2 = s1 / 10 (tens digit of the seconds)
    li $a0, 68			# Set the x value to 68
    li $a1, 113			# Set the y value to 113
    move $a2, $s2		# Print the tens digit of the number of seconds
    jal DrawNumber		# Write the number to the screen
    
    mul $s2, $s2, 10		# Get the tens digit in its proper place value
    sub $a2, $s1, $s2		# Subtract the tens from the seconds to isolate the ones, and write that number
    li $a0, 72			# Set the x value to 72
    li $a1, 113			# Set the y value to 113
    jal DrawNumber		# Write the number to the screen
    
    lw $s2, 12($sp)		# Restore s2
    lw $s1, 8($sp)		# Restore s1
    lw $s0, 4($sp)		# Restore s0
    lw $ra, 0($sp)		# Restore the return address
    addi $sp, $sp, 16		# Restore the stack
    jr $ra			# Return

InitializeGrid:
    # HORIZ: (20,20), (20,40), (20,60), (20,80), (20,100)
    # VERT: (20,20), (40,20), (60,20), (80,20), (100,20)
    # ..Except the lines should increment by 22, not by 20, to account for the borders
    addi $sp, $sp, -8		# Give the stack 8 bytes to work with
    sw $s0, 4($sp)		# Store s0 in the stack
    sw $ra, 0($sp)		# Store the return address to the stack
    
    li $s0, 0			# i = 0
grid_loop:
    li $a0, 20			# Start the x-coordinate of the line at 20
    mul $a1, $s0, 22		# Set the y-coordinate of the line at i*22
    add $a1, $a1, 20		# Add another 20 units to the y
    li $a2, 89			# Make the line 85 units long (4 cells * 21 units/cell + 5 borders * 1 unit/border)
    li $a3, 0			# Make the line horizontal
    jal DrawLine		# Draw the line
    
    li $a1, 20			# Start the y-coordinate of the line at 20
    mul $a0, $s0, 22		# Set the x-coordinate of the line at i*22
    add $a0, $a0, 20		# Add another 20 units to the x
    li $a2, 89			# Make the line 85 units long (4 cells * 21 units/cell + 5 borders * 1 unit/border)
    li $a3, 1			# Make the line vertical
    jal DrawLine		# Draw the line

    addi $s0, $s0, 1		# i++
    slti $t0, $s0, 5		# Is i < 5?
    bnez $t0, grid_loop		# If so, then repeat the loop
    
    li $a0, 0			# Go to the leftmost unit
    li $a1, 0			# Go to the topmost unit
    la $a2, clearMsg		# Clear the line of junk from last time
    jal DrawText		# Print to screen
    
    li $a0, 0			# Go to the leftmost unit
    li $a1, 0			# Go to the topmost unit
    la $a2, consoleMsg		# Fetch the string containing user instructions
    jal DrawText		# Print to screen
    
    lw $ra, 0($sp)		# Restore the return address from the stack
    lw $s0, 4($sp)		# Pop s0 from the stack
    addi $sp, $sp, 8		# Pop the stack
    jr $ra			# Return

UpdateBoard:
    addi $sp, $sp, -12         # Give the stack 12 bytes to work with
    sw $s0, 8($sp)             # Store s0 in the stack
    sw $zero, 4($sp)           # Clear one entry in the stack - this will be a column counter
    sw $ra, 0($sp)             # Store the return address to the stack

    li $t0, 0                  # i = 0 for looping through 16 cards
    la $t1, card_states        # Load card state array
    la $t2, cellPairs          # Load card content array (contains indexes for factors and products)

draw_loop:
    move $s0, $t0

    # Check if the card is revealed
    lb $t3, card_states($t0)   # Load state of the current card
    beq $t3, 0, print_front    # If state is 0, print the front (card index)

    # If revealed, show the equation or product (back of the card)
    lb $t4, cellPairs($t0)     # Load cell pair index for the current card
    blt $t4, 8, show_equation  # If < 8, it's an equation card
    sub $t4, $t4, 8            # Adjust for product cards
    j show_product

print_front:
    # Print the card index (A-P) as a placeholder for hidden cards
    addi $a0, $t0, 65           # Card letter (A-P)
    li $v0, SysPrintChar        # Print the letter
    syscall
    
    # BITMAP    
    move $a0, $t0
    jal ClearCell
    move $t0, $s0
    move $a0, $t0
    addi $a1, $t0, 11
    li $a2, -1
    li $a3, -1
    li $v0, -1
    li $v1, -1
    jal WriteToCell
    move $t0, $s0
    
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
    
    # BITMAP
    move $a0, $t0
    jal ClearCell
    move $t0, $s0
    move $a0, $t0
    move $a1, $t5
    move $a2, $t6
    jal WriteMathToCell
    move $t0, $s0
    
    j drawloop_end

show_product:
    # Print the product
    sll $t4, $t4, 2            # t4 *= 4 to index product array
    lw $t5, products($t4)      # Load product

    move $a0, $t5
    li $v0, SysPrintInt
    syscall
    
    # BITMAP
    move $a0, $t0
    jal ClearCell
    move $t0, $s0
    move $a0, $t0
    move $a1, $t5
    li $a2, -1
    jal WriteMathToCell
    move $t0, $s0

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
    lw $s0, 8($sp)             # Restore s0 from the stack
    addi $sp, $sp, 12          # Pop the stack
    jr $ra                     # Return to exit program
    
