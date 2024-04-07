		br 0100					; code starts at 000100 (octal)
.blkb 76

START:
		mov #MESG, r0			; the start of the message
		mov #060036,r1			; display address
		clr r3					; clr our counter

LOOP:
		mov (r0),(r1)				; move value in r0 to address held in r1
		inc r3
		dec r1
		dec r1
		inc r0
		inc r0
		cmp r3,#M_LEN
		blt LOOP
		
END:
		halt
		
MESG: .word 000110
	  .word 000145
	  .word 000154
	  .word 000154
	  .word 000157
	  .word 000162
	  .word 000154
	  .word 000144
	  .word 000041
	  .word 000040
	  .word 000040
	  .word 000040
	  .word 000040
	  .word 000040
	  .word 000040
	  .word 000040
	  
M_LEN:.word 16d						; message is 16 characters long