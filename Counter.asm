#	CS2340 Term Project - Display sequence for number of cards left unmatched
#
#	Author: Hatice Kahraman
#	Date: 09-25-2024 
#	Location: UTD
#

.data
cards_left_msg: .asciiz "Cards left: "  # Message to display cards left

.text
.globl DisplayCardsLeft

DisplayCardsLeft:
    addi $sp, $sp, -4          # Give the stack 4 bytes to work with
    sw $ra, 0($sp)             # Store the return address in the stack

    # Print "Cards left: "
    la $a0, cards_left_msg     # Load the cards left message to a0
    li $v0, SysPrintString     # Syscall to print a string
    syscall                    # Print the string

    # Load and print the number of cards left
    lw $a0, cards_left         # Load the current value of cards_left
    li $v0, SysPrintInt        # Syscall to print an integer
    syscall                    # Print the string

    # Print a newline for better formatting
    la $a0, newline            # Load the new line string
    li $v0, SysPrintString     # Syscall to print a newline
    syscall                    # Print the string
    
    lw $a0, cards_left         # Load the current value of cards_left
    jal PrintCardsRemaining    # Update the bitmap display
    
    lw $ra, 0($sp)             # Restore the return address
    addi $sp, $sp, 4           # Restore the stack

    jr $ra                     # Return to the caller
