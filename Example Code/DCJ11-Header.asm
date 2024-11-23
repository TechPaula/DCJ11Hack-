	; DCJ11 ASM template
	;
	; o000000 -> o077776  - RAM
	; o060000 -> o060020  - Text display 
	;							Shadowed in RAM, so you can read what you wrote
	; o100000 -> o137776  - ROM
	;
	; o140000 -> o140100  - Dot Display (2 sets of 32 bytes, writing to both make a slightly brighter dot)
	;							Stored as lowest 8 bits!
	;
	; o177564 			  - Serial port status
	; o177566			  - Serial port OUT register
	;
	; .blkb 76 sets the start of code at o000100 
	;
	; r0 -> r5 general purpose registers
	; r6  normally used for stack pointer, but can be used as general purpose
	; r7  program counter
	;
	


