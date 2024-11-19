#	CS2340 Term Project - Card "Flipping" Mechanism 
#
#	Author: Hatice Kahraman
#	Date: 09-25-2024 
#	Location: UTD
#

.data
card_states:    .byte 0:16      # Array to track card states: 0 = hidden, 1 = revealed
user_prompt1:   .asciiz "Enter the first card number to flip (1-16): "
user_prompt2:   .asciiz "Enter the second card number to flip (1-16): "
match_msg:      .asciiz "It's a match!\n"
no_match_msg:   .asciiz "Not a match.\n"
all_matched_msg: .asciiz "Congratulations! All pairs matched!\n"
delay_time:     .word 2000000   # Adjust delay time as needed
cards_left: .word 16  		# Total number of cards

.text
.globl CardFlip_main

CardFlip_main:
    li $t0, 0              	# Initialize matched pairs counter ($t0 - matched_pairs counter)
    lw $s2, cards_left     	# Load total number of cards ($s2 - cards_left counter)

game_loop:
    # Display the number of cards left
    jal DisplayCardsLeft
    
    # Prompt user for first card to flip
    la $a0, user_prompt1
    li $v0, SysPrintString
    syscall
    li $v0, SysReadInt
    syscall
    addi $s0, $v0, -1      	# Store first card index in $s0

    # Prompt user for second card to flip
    la $a0, user_prompt2
    li $v0, SysPrintString
    syscall
    li $v0, SysReadInt
    syscall
    addi $s1, $v0, -1      	# Store second card index in $s1

    jal RevealCards		# Reveal selected cards
    jal DrawBoardCLI		# Draw board with the revealed cards
    jal DisplayCardsLeft	# Update the cards left count
    jal CheckMatch		# Check if cards are a match
    beq $v0, 1, handle_match  	# If match, go to handle_match

    # Not a match
    la $a0, no_match_msg     	# Print "Not a match."
    li $v0, SysPrintString
    syscall
    jal Delay                	# Short delay to show the flipped cards
    jal HideCards
    j game_loop              	# Loop back to play again

handle_match:
    la $a0, match_msg        	# Print "It's a match!"
    li $v0, SysPrintString
    syscall
    addi $t0, $t0, 1         	# Increment match counter
    addi $s2, $s2, -2        	# Decrement cards left by 2
    sw $s2, cards_left       	# Update the cards_left variable

    # Check if all pairs are matched
    beqz $s2, game_end
    j game_loop

game_end:
    jal DrawBoardCLI           	# Draw the final board
    jal DisplayCardsLeft     	# Display final cards left count (should be 0)
    la $a0, all_matched_msg
    li $v0, SysPrintString
    syscall
    jr $ra                   	# End game and return
           

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
    blt $t3, 8, factor_first

    # Product card is $t3, factor card is $t4
    addi $t5, $t3, -8        	# Adjust product index
    move $t6, $t4            	# Factor index
    j verify_match

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
    mul $t9, $t7, $t8

    # Load the product
    sll $t5, $t5, 2          	# Multiply index by 4
    lw $t0, products($t5)

    # Compare calculated product with stored product
    beq $t9, $t0, match

no_match:
    li $v0, 0                	# Set return value to 0 (no match)
    jr $ra

match:
    li $v0, 1                	# Set return value to 1 (match)
    jr $ra

# Reveal the selected cards by updating their state
RevealCards:
    li $t5, 1                   # Set to revealed state
    sb $t5, card_states($s0)
    sb $t5, card_states($s1)
    jr $ra


# Hide the selected cards by resetting their state
HideCards:
    li $t5, 0                   # Set to hidden state
    sb $t5, card_states($s0)
    sb $t5, card_states($s1)
    jr $ra

# Delay function for brief pause
Delay:
    lw $t0, delay_time          # Load delay time
delay_loop:
    addi $t0, $t0, -1
    bgtz $t0, delay_loop        # Loop until delay time is exhausted
    jr $ra
