#	CS2340 Term Project
#
#	Authors: Hatice Kahraman & Serhan Doganay
#	Date: 09-25-2024 
#	Location: UTD
#

.include "SysCalls.asm"

.text
	jal rng_main		# initialize random numbers
	jal DrawBoard		# draw the board
	jal CardFlip_main 
	
	li $v0, SysExit		# service call: exit 
	syscall			# exit the program

.include "RandomNumberGen.asm"
.include "Graphics.asm"
.include "CardFlip.asm"
.include "Counter.asm"
