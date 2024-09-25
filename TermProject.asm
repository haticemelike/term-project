#	CS2340 Lecture 1.  Mars demo of syscall
#
#	Author: Alice Wang
#	Date: 05-03-2024 
#	Location: UTD
#

.include "SysCalls.asm" 	# include this file in all programs
.data 
	msg: 	.asciiz "Hello World!"
	ArrayA: .word 1,2,3,4,5,6,7


.text
	li $v0, SysReadInt	# service call: read integer from keyboard to $v0
	syscall			# run system call
	move $s0, $v0		# $s0 = $v0

	li $v0, SysPrintInt  	# service call: print integer (SysCalls.asm)
	move $a0, $s0		# $a0 = $s0
	syscall			# run system call

	li $v0, SysPrintString	# service call: print string (SysCalls.asm)
	la $a0, msg		# load address of string to $a0
	syscall			# run system call
	
	li $v0, SysExit		# service call: exit 
	syscall
	
	
	
