#	CS2340 Term Project - Timer calculation and display
#
#	Author: Hatice Kahraman
#	Date: 09-25-2024 
#	Location: UTD
#

.data
start_time:    .word 0        		# Store the start time in milliseconds
elapsed_time:  .word 0        		# Store the current elapsed time in milliseconds
elapsed_msg: .asciiz "Elapsed Time : "
colon: .asciiz ":"           		# Colon symbol for time format
zero:         .asciiz "0"           	# Leading zero

.text
.globl InitTimer
.globl UpdateTimer

# Initialize the timer by recording the start time
InitTimer:
        li $v0, 30            	# System call 30: Get current time in milliseconds
        syscall
        sw $a0, start_time    	# Store start time in memory
        li $v0, 0            	# Reset elapsed time in memory
        sw $v0, elapsed_time
        jr $ra

# Update the timer, calculate, and display elapsed time in "MM:SS" format with leading zeros
UpdateTimer:
        li $v0, 30            	# System call 30: Get current time in milliseconds
        syscall
        lw $t0, start_time    	# Load start time
        subu $t1, $a0, $t0    	# Calculate elapsed time: current time - start time
        sw $t1, elapsed_time  	# Save the elapsed time in memory

        # Convert milliseconds to seconds
        li $t2, 1000
        divu $t1, $t2         	# Integer division: elapsed_time / 1000
        mflo $t3              	# $t3 = elapsed time in seconds

        # Convert seconds to "MM:SS"
        li $t4, 60            	# Load 60 into $t4
        divu $t3, $t4         	# Divide elapsed seconds by 60
        mflo $t5              	# $t5 = minutes
        mfhi $t6              	# $t6 = remaining seconds

        # Display "Elapsed Time: "
        li $v0, SysPrintString  # Syscall to print string
        la $a0, elapsed_msg   	# Load "Elapsed Time: "
        syscall

        # Print minutes
        li $v0, SysPrintInt     # Syscall to print integer
        move $a0, $t5         	# Load minutes into $a0
        syscall

        # Print colon
        li $v0, SysPrintString  # Syscall to print string
        la $a0, colon         	# Load colon
        syscall

        # Check if seconds need a leading zero
        li $t7, 10            	# Load 10 into $t7
        blt $t6, $t7, PrintLeadingZero  # If seconds < 10, print leading zero

        # Print seconds without leading zero
        li $v0, SysPrintInt     # Syscall to print integer
        move $a0, $t6         	# Load seconds into $a0
        syscall
        b PrintNewline        	# Skip leading zero printing

PrintLeadingZero:
        li $v0, SysPrintString  # Syscall to print string
        la $a0, zero          	# Load "0"
        syscall

        # Print seconds (after leading zero)
        li $v0, SysPrintInt     # Syscall to print integer
        move $a0, $t6         	# Load seconds into $a0
        syscall

PrintNewline:
        # Print newline
        li $v0, SysPrintString  # Syscall to print string
        la $a0, newline       	# Load newline
        syscall

        jr $ra                	# Return to caller