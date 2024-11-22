#	CS2340 Term Project - Audio Component
#
#	Author: Serhan Doganay
#	Date: 11-22-2024 
#	Location: UTD
#

WrongSound:
	li $a0, 48	# Pitch: C3
	li $a1, 200	# Duration: 0.2 seconds
	li $a2, 80	# Instrument: Synth Lead 1 (square)
	li $a3, 100	# Volume: 100
	li $v0, 31	# MIDI async
	syscall		# Play the sound
	jr $ra		# Return
	
PassSound:
	li $a0, 72	# Pitch: C5
	li $a1, 200	# Duration: 0.2 seconds
	li $a2, 10	# Instrument: Music Box
	li $a3, 100	# Volume: 100
	li $v0, 31	# MIDI async
	syscall		# Play the sound
	jr $ra		# Return
	
WinSound:
	li $a0, 79	# Pitch: G5
	li $a1, 200	# Duration: 0.3 seconds
	li $a2, 10	# Instrument: Music Box
	li $a3, 100	# Volume: 100
	li $v0, 33	# MIDI sync
	syscall		# Play the sound
	
	li $a0, 81	# Pitch: A5
	li $a1, 200	# Duration: 0.2 seconds
	li $a2, 10	# Instrument: Music Box
	li $a3, 100	# Volume: 100
	li $v0, 33	# MIDI sync
	syscall		# Play the sound
	
	li $a0, 83	# Pitch: B5
	li $a1, 200	# Duration: 0.3 seconds
	li $a2, 10	# Instrument: Music Box
	li $a3, 100	# Volume: 100
	li $v0, 33	# MIDI sync
	syscall		# Play the sound
	
	li $a0, 84	# Pitch: C6
	li $a1, 200	# Duration: 0.2 seconds
	li $a2, 10	# Instrument: Music Box
	li $a3, 100	# Volume: 100
	li $v0, 33	# MIDI sync
	syscall		# Play the sound
	jr $ra		# Return