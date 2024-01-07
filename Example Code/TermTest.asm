

.org 0000010

loop:	BIT $00000200,@$0177564		# check bit-7/ready of xmt status reg
		BEQ loop					# busy-loop while bit-7 is 0

		MOV $00000102,@$0177566		# send ASCII B to xmt data reg
		BR loop						# go send character again
		
