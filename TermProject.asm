#	CS2340 Term Project
#
#	Authors: Hatice Kahraman & Serhan Doganay
#	Date: 09-25-2024 
#	Location: UTD
#

.include "SysCalls.asm"

.text

Main:
	jal InitTimer		# initialize timer
	
	jal rng_main		# initialize random numbers
	jal InitializeGrid	# draw the board gridlines
	jal UpdateBoard		# assign letters to the cells
	jal CardFlip_main 	# handle the card flipping logic
	
	jal UpdateTimer		# update and display time 
	
	li $v0, SysExit		# service call: exit 
	syscall			# exit the program

.include "RandomNumberGen.asm"
.include "Graphics.asm"
.include "CardFlip.asm"
.include "Counter.asm"
.include "Time.asm"
.include "Audio.asm"