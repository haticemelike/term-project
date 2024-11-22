#	CS2340 Term Project - Card "Flipping" Mechanism + Exit Game
#
#	Author: Hatice Kahraman
#	Date: 09-25-2024 
#	Location: UTD
#

.data
card_states:    .byte 0:16      # Array to track card states: 0 = hidden, 1 = revealed
user_prompt1:   .asciiz "Enter the first card letter (A-P) or '.' to exit / '!' to restart: "
user_prompt2:   .asciiz "Enter the second card letter (A-P) or '.' to exit / '!' to restart: "
wrong_card_msg:	.asciiz "Please select a different pair of cards.\n"
match_msg:      .asciiz "It's a match!\n"
no_match_msg:   .asciiz "Not a match.\n"
all_matched_msg: .asciiz "Congratulations! All pairs matched! Press '!' to play again\n"
delay_time:     .word 3000000   # Adjust delay time as needed
cards_left: .word 16  		# Total number of cards
restart_char: .byte '.'          # Special character for restarting

.text
.globl CardFlip_main

CardFlip_main:
    addi $sp, $sp, -4		# Give the stack 4 bytes to work with
    sw $ra, 0($sp)		# Store the return address to the stack
    
    li $t0, 16			# 16 cards
    la $t1, cards_left		# t1 points to cards_left
    sw $t0, 0($t1)		# We have 16 cards left

    li $t0, 0              	# Initialize matched pairs counter ($t0 - matched_pairs counter)
    lw $s2, cards_left     	# Load total number of cards ($s2 - cards_left counter)

game_loop:
    # Display the number of cards left
    jal DisplayCardsLeft	# Call the display method
    jal UpdateTimer		# Call the display elapsed time method
    
    # Prompt user for first card to flip or restart
    la $a0, user_prompt1	# Load the first user prompt string
    li $v0, SysPrintString	# Prepare to print a string
    syscall			# Print the string
    
    li $v0, SysReadChar		# Expect a char from the keyboard (a cell ID)
    syscall			# Read the char
    
    # Exit if the user presses "."
    beq $v0, 46, exit_game 	# If "." is pressed, jump to exit_game
    # Restart if the user presses "!"
    beq $v0, 33, restart_game	# If "!" is pressed, jump to restart_game
    
    blt $v0, 97, upper1		# Did the user input an uppercase or a lowercase letter?
    addi $s0, $v0, -97		# The user entered a lowercase letter. Convert that to a cell index #.
    j end_input1		# Skip past the uppercase code.
    
upper1:
    addi $s0, $v0, -65      	# The user entered an uppercase letter. Convert that to a cell index #.
    
end_input1:
    la $a0, newline		# Load the new line string
    li $v0, SysPrintString	# Prepare to print a string
    syscall			# Make a new line

    # Prompt user for second card to flip
    la $a0, user_prompt2	# Load the second user prompt string
    li $v0, SysPrintString	# Prepare to print a string
    syscall			# Print the string
    
    li $v0, SysReadChar		# Anticipate a response from the keyboard
    syscall			# Await a char from the keyboard
    
    # Exit if the user presses "."
    beq $v0, 46, exit_game  	# If "." is pressed, jump to exit_game
    # Restart if the user presses "!"
    beq $v0, 33, restart_game	# If "!" is pressed, jump to restart_game
    
    blt $v0, 97, upper2		# Did the user input an uppercase or a lowercase letter?
    addi $s1, $v0, -97		# The user entered a lowercase letter. Convert that to a cell index #.
    j end_input2		# Skip past the uppercase code.
    
upper2:
    addi $s1, $v0, -65      	# The user entered an uppercase letter. Convert that to a cell index #.
    
end_input2:
    la $a0, newline		# Load the new line string
    li $v0, SysPrintString	# Prepare to print a string
    syscall			# Make a new line
    
    # The user can't input the same card twice, or a card that's already revealed, or a card that doesn't exist
    bgt $s0, 15, invalid_inputs	# The first card doesn't exist
    bgt $s1, 15, invalid_inputs	# The second card doesn't exist
    beq $s0, $s1, invalid_inputs# The user inputted the same card
    lb $t3, card_states($s0)	# Load the first card's state
    beq $t3, 1, invalid_inputs	# The first card had already been revealed
    lb $t3, card_states($s1)	# Load the second card's state
    beq $t3, 1, invalid_inputs	# The second card had already been revealed
    j valid_inputs		# Otherwise, the user inputted valid cards
    
invalid_inputs:
    la $a0, wrong_card_msg	# Prompt the user to select different cards
    li $v0, SysPrintString	# Prepare to print a string to the console
    syscall			# Print the string to the console
    
    li $a0, 0			# Go to the leftmost unit on the bitmap display
    li $a1, 0			# Go to the topmost unit on the bitmap display
    la $a2, clearMsg		# Get the string to clear the line
    jal DrawText		# Draw the string to the bitmap display
    li $a0, 0			# Go to the leftmost unit on the bitmap display
    li $a1, 0			# Go to the topmost unit on the bitmap display
    la $a2, badCardMsg		# Load the message to pick different cards
    jal DrawText		# Draw the string to the bitmap display
    j game_loop			# Have the user pick different cards

valid_inputs:
    jal RevealCards		# Reveal selected cards
    jal UpdateBoard		# Draw board with the revealed cards
    jal CheckMatch		# Check if cards are a match
    beq $v0, 1, handle_match  	# If match, go to handle_match

    # Not a match
    jal WrongSound		# Play the sound effect for an incorrect match
    la $a0, no_match_msg     	# Print "Not a match."
    li $v0, SysPrintString	# Set the syscall to print string
    syscall			# Print the string
    li $a0, 0			# Go to the leftmost unit on the bitmap display
    li $a1, 0			# Go to the topmost unit on the bitmap display
    la $a2, clearMsg		# Get the string to clear the line
    jal DrawText		# Draw the string to the bitmap display
    li $a0, 0			# Go to the leftmost unit on the bitmap display
    li $a1, 0			# Go to the topmost unit on the bitmap display
    la $a2, bmpFailMsg		# Load the fail message
    jal DrawText		# Draw the string to the bitmap display
    jal Delay                	# Short delay to show the flipped cards
    jal HideCards		# Flip the cards over
    jal UpdateBoard		# Draw board with the hidden cards
    j game_loop              	# Loop back to play again

handle_match:
    jal PassSound		# Play the sound effect for a correct match
    la $a0, match_msg        	# Print "It's a match!"
    li $v0, SysPrintString	# Set the syscall to print the string
    syscall			# Print the string
    li $a0, 0			# Go to the leftmost unit on the bitmap display
    li $a1, 0			# Go to the topmost unit on the bitmap display
    la $a2, clearMsg		# Get the string to clear the line
    jal DrawText		# Draw the string to the bitmap display
    li $a0, 0			# Go to the leftmost unit on the bitmap display
    li $a1, 0			# Go to the topmost unit on the bitmap display
    la $a2, bmpPassMsg		# Load the pass message
    jal DrawText		# Draw the string to the bitmap display
    addi $t0, $t0, 1         	# Increment match counter
    addi $s2, $s2, -2        	# Decrement cards left by 2
    sw $s2, cards_left       	# Update the cards_left variable

    # Check if all pairs are matched
    beqz $s2, game_end		# If there are 0 cards left, then end the game
    j game_loop			# Otherwise, continue the game

game_end:
    jal WinSound		# Play the sound effect for having won the game
    jal UpdateBoard           	# Draw the final board
    jal DisplayCardsLeft     	# Display final cards left count (should be 0)
    jal UpdateTimer		# Display elapsed time
    la $a0, all_matched_msg	# Load the string for all cards matched
    li $v0, SysPrintString	# Load the print string syscall
    syscall			# Print the string
    li $a0, 0			# Go to the leftmost unit on the bitmap display
    li $a1, 0			# Go to the topmost unit on the bitmap display
    la $a2, clearMsg		# Get the string to clear the line
    jal DrawText		# Draw the string to the bitmap display
    li $a0, 0			# Go to the leftmost unit on the bitmap display
    li $a1, 0			# Go to the topmost unit on the bitmap display
    la $a2, gameEndMsg		# Load the congratulations message
    jal DrawText		# Draw the string to the bitmap display
    
    # Does the player want to restart?
    li $v0, SysReadChar		# Expect a char from the keyboard
    syscall			# Read the char
    beq $v0, 33, restart_game	# If "!" is pressed, jump to restart_game
    
exit_game:
    lw $ra, 0($sp)		# Restore the return address from the stack
    addi $sp, $sp, 4		# Restore the stack
    jr $ra                   	# End game and return

restart_game:
    # Clear card_states
    la $t0, card_states		# Load card_states to t0
    li $t1, 0			# int i = 0
    
card_state_reset:
    add $t2, $t0, $t1		# Have t2 point to card_states[i]
    sb $zero, 0($t2)		# card_states[i] = 0

    addi $t1, $t1, 1		# i++
    slti $t2, $t1, 16		# Is i < 16?
    bnez $t2, card_state_reset	# Loop if so

    j Main			# Restart the program

# Check if the two selected cards match
CheckMatch:
    # Load the cell pair indices for both cards
    lb $t3, cellPairs($s0)  	# First card's cell pair index 
    lb $t4, cellPairs($s1)  	# Second card's cell pair index 

    # Check if one card is a factor and the other is its product
    blt $t3, 8, check_factor_product  # If first card is a factor card
    blt $t4, 8, check_factor_product  # If second card is a factor card
    j no_match  		      # If neither is a factor card, no match

check_factor_product:
    # Determine which card is the factor card and which is the product card
    blt $t3, 8, factor_first	# Numbers less than 8 signify a factor

    # Product card is $t3, factor card is $t4
    addi $t5, $t3, -8        	# Adjust product index
    move $t6, $t4            	# Factor index
    j verify_match		# Skip the factor code

factor_first:
    # Factor card is $t3, product card is $t4
    addi $t5, $t4, -8        	# Adjust product index
    move $t6, $t3            	# Factor index

verify_match:
    # Load factor1 and factor2
    sll $t6, $t6, 2          	# Multiply index by 4
    lw $t7, factor1($t6)     	# Load first factor
    lw $t8, factor2($t6)     	# Load second factor

    # Multiply factors
    mul $t9, $t7, $t8		# t9 = factor1*factor2

    # Load the product
    sll $t5, $t5, 2          	# Multiply index by 4
    lw $t0, products($t5)	# Load that index's product

    # Compare calculated product with stored product
    beq $t9, $t0, match		# Skip if the numbers match

no_match:
    li $v0, 0                	# Set return value to 0 (no match)
    jr $ra			# Return

match:
    li $v0, 1                	# Set return value to 1 (match)
    jr $ra			# Return

# Reveal the selected cards by updating their state
RevealCards:
    li $t5, 1                   # Set to revealed state
    sb $t5, card_states($s0)	# Set card A to be revealed
    sb $t5, card_states($s1)	# Set card B to be revealed
    jr $ra			# Return


# Hide the selected cards by resetting their state
HideCards:
    li $t5, 0                   # Set to hidden state
    sb $t5, card_states($s0)	# Set card A to be hidden
    sb $t5, card_states($s1)	# Set card B to be hidden
    jr $ra			# Return

# Delay function for brief pause
Delay:
    lw $t0, delay_time          # Load delay time
delay_loop:
    addi $t0, $t0, -1		# Decrement the delay counter
    bgtz $t0, delay_loop        # Loop until delay time is exhausted
    jr $ra			# Return
