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
	; r6  normally used for stack pointer, when I use it, things don't work.
	; r7  program counter
	;
	; Memory map
	; o000100 -> 001100 = results page (256 words)
	; o001100 -> 002100 = calculation page (256 words)
	; o002500 -> 002777 = Variables
	;	o002500 = Y position
	;   o002502 = X position
	;	o002504 = Iteration
	;   
	; o003000 Code start
	

	nop
	jmp INIT

.org 000100
RSLT: .word 000000

.org 001100
CALC: .word 000000

.org 002500
ADDY: .word 000000			; Y position 
ADDX: .word 000000			; X position
VLTL: .word 000000			; value of square top left
VLTC: .word 000000			; value of square top center
VLTR: .word 000000			; value of square top right
VLL:  .word 000000			; value of square to left
VLR:  .word 000000			; value of square to right
VLBL: .word 000000			; value of square bottom left
VLBC: .word 000000			; value of square bottom center
VLBR: .word 000000			; value of square bottom right
ITER: .word 000000			; number of iterations
TMP:  .word 000000			; temporary storage


.org 003000
INIT:					; should be at o003000
	clr r0
	clr r1
	clr r2
	clr r3
	clr r4
	clr r5
	MOV #000076,r6		; STACK POINTER set (note it goes DOWN as it fills)

	jsr r5, MDISP		; show start message
	
	jsr r5, SETUP		; set initial memory values

	jsr r5, SHOWR		; Show results on 16x16 matrix
	
	

;-----------------------------------------------------
; main loop

MAIN:
	
	; Figure out where we are in memory
	mov #ADDY, r4		; Y position memory location
	mov (r4), r3		; get Y position
	asl r3				; multiply by 2
	add #CALC, r3		; add in offset to get Y position in memory
	
	mov #ADDX, r4		; X position memory location
	mov (r4), r2		; get X position

	jsr r6, MULF		; multiply r2 by o000040 to get X address
	
	add r2, r3			; add on X offset to address	
						; r3 now holds address in memory we're looking at!
						
	
	



	; check if we've reached the ends of the column or row
	; end of column?
INCY:
	mov #ADDY, r4		; Y position memory location
	mov (r4), r3		; get Y position
	inc r3				; increment it

	cmp r3, #000020		; are we at the end of the column?
	beq INCX			; if we are, increment X
	
	mov r3, (r4)		; if not save Y
	br MAIN				; and do next Y position
	
INCX:
	clr r3				; clear Y position
	mov r3, (r4) 		; save Y position
	
	mov #ADDX, r4		; X position memory location
	mov (r4), r3		; get X position
	inc r3				; increment it

	cmp r3, #000020		; are we at the end of the column?
	beq ITCOMP			; if we have, the we've done one interation
	
	mov r3, (r4)		; save X
	br MAIN
	
ITCOMP: 
	clr r3				
	mov #ADDY, r4		; Y position memory location
	mov r3, (r4) 		; reset Y
	mov #ADDX, r4		; X position memory location
	mov r3, (r4) 		; reset X
	
	; MEMCOPY from o001100 to o000100
	; delay
	; jsr r6, SHOWR		; Show results on 16x16 matrix
	
	HALT


; ----------------------------------------------------
; copy page from CALC: to RSLT:
; 	trashes r0 and r1
CPYP:

; ----------------------------------------------------
; multiply r2 by o000040
; 	trashes r0 and r1
MULF:
	mov #000040, r0		; we're multiplying by o000040
	
	cmp r2, #0000000	; are we multiplying by 0?
	beq MULE			; if so skip
 
	mov r2, r1			; take a copy
    clr r2				; clear it
	
MULL:
	add r1, r2			; add original r2 to r2
	dec r0				; decrease multiply
	cmp r0, #000000		; have we hit zero?
	bgt MULL			; if not do it again

MULE:					; if it is, we're done
	rts r6


; ----------------------------------------------------
; Show result on matrix
; 	trashes r0, r1, r2, r3, r4
;		r0 = value for 8bit column data
;		r1 = working refister
;		r2 = number of columns
;		r3 = number  of columns complete
;		r4 = address in results page
;		//r5 = address of dot matrix
SHOWR:
	; convert contents of RAM (r4) to display (r5)
	mov #TMP, r3
	mov #140000, (r3)	; save 16x16 display address in temp 
	
	mov #RSLT, r4 	; results page address
	clr r3			; number of columns done
	clr r2			; number of sets of columns
	
DILP:	
	clr r0			; clear result
	mov (r4), r1	; get contents of ram held by r4
	cmp r1, #0		; is it 0?
	beq SKP1		; if not, don't set the bit
	add #000001, r0	; set bit in r0
	
SKP1:	
	add #000002, r4	; add 16 to r4
	mov (r4), r1	; get contents of ram held by r4
	cmp r1, #0		; is it 0?
	beq SKP2		; if not, don't set the bit
	add #000002, r0	; set bit in r0
	
SKP2:	
	add #000002, r4	; add 16 to r4
	mov (r4), r1	; get contents of ram held by r4
	cmp r1, #0		; is it 0?
	beq SKP3		; if not, don't set the bit
	add #000004, r0	; set bit in r0

SKP3:	
	add #000002, r4	; add 16 to r4
	mov (r4), r1	; get contents of ram held by r4
	cmp r1, #0		; is it 0?
	beq SKP4		; if not, don't set the bit
	add #000010, r0	; set bit in r0
	
SKP4:	
	add #000002, r4	; add 16 to r4
	mov (r4), r1	; get contents of ram held by r4
	cmp r1, #0		; is it 0?
	beq SKP5		; if not, don't set the bit
	add #000020, r0	; set bit in r0
	
SKP5:	
	add #000002, r4	; add 16 to r4
	mov (r4), r1	; get contents of ram held by r4
	cmp r1, #0		; is it 0?
	beq SKP6		; if not, don't set the bit
	add #000040, r0	; set bit in r0
	
SKP6:	
	add #000002, r4	; add 16 to r4
	mov (r4), r1	; get contents of ram held by r4
	cmp r1, #0		; is it 0?
	beq SKP7		; if not, don't set the bit
	add #000100, r0	; set bit in r0
	
SKP7:	
	add #000002, r4	; add 16 to r4
	mov (r4), r1	; get contents of ram held by r4
	cmp r1, #0		; is it 0?
	beq DILE		; if not, don't set the bit
	add #000200, r0	; set bit in r0
	
DILE:
	mov #TMP, r1	; put the TMP address into r1 
	mov (r1),r1

	mov r0, (r1)	; put it in the display
	sub #000016, r4	; take off all the addition we did
	add #000040, r4	; go to next address
	
	mov #TMP, r1	; put the TMP address into r1 
	mov (r1),r0		; take contents of address held by r1 and put it in r0
	add #2, r0		; point display to next address
	mov r0, (r1)	; put the new address back in temp
	
	halt

	inc r3			; increase column counter
	cmp r3, #000020	; have we done 32 (2x16 sets of 8 bits)
	blt DILP
	
	mov #000030, r4 ; second part of results data
	clr r3
	inc r2
	cmp r2, #000002
	blt DILP
	
	rts r5

	
; ----------------------------------------------------
; setup memory
;	trashes r0, r1, r3
SETUP:
	clr r3					; clear loop counter
	mov #RSLT, r1			; mov result memory location into r5
	mov #ISTP, r0			; start matrix address
	
ILOP:
	mov (r0), (r1)			; copy contents of  address R0 to contents of address r1
	inc r3					; increase loop counter
	add #2, r0				; increase pointer
	add #2, r1				; increase pointer
	cmp r3, #000400			; have we done 256 addresses?
	blt ILOP


	clr r3
CLRL:						; clear next 256 locations
	mov #000000, (r1)		; Make sure it's all zero
	inc r3
	add #2, r0				; increase pointer
	add #2, r1				; increase pointer
	cmp r3, #000400			; have we done 256 addresses?
	blt CLRL
	
	rts r5


; ----------------------------------------------------
; show display message
;	trashes r0,r1,r3
MDISP:
	; display message
	mov #060036, r1			; Display address (left most character)
	mov #MESG, r0			; Start message
	clr r3					; loop counter

MLOP:
	mov (r0), (r1)			; copy contents of address held in R0 to contents of address held in r1
	inc r3					; increase loop counter
	add #2, r0				; increase pointer
	sub #2, r1				; increase pointer
	cmp r3, #000020			; have we done 16 characters?
	blt MLOP

	rts r5
	

; ----------------------------------------------------
; constant stuff

	; Holds the initial step, 16 across then 16 down
ISTP:
	; COL 1
	.word 177777
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000

	; COL 2
	.word 000000
	.word 000000
	.word 000000
	.word 177777
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 177777
	.word 177777
	.word 000000

	; COL 3
	.word 000000
	.word 177777
	.word 000000
	.word 177777
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 177777
	.word 000000
	.word 177777
	.word 000000

	; COL 4
	.word 000000
	.word 000000
	.word 177777
	.word 177777
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000

	; COL 5
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 177777
	.word 000000
	.word 177777
	.word 000000
	.word 000000
	.word 000000

	; COL 6
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000

	; COL 7
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 177777
	.word 000000
	.word 177777
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000

	; COL 8
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 177777
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000

	; COL 9
	.word 000000
	.word 177777
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 177777
	.word 177777
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000

	; COL 10
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000

	; COL 11
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 177777
	.word 000000
	.word 000000
	.word 000000

	; COL 12
	.word 000000
	.word 000000
	.word 000000
	.word 177777
	.word 177777
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 177777
	.word 000000
	.word 177777
	.word 000000
	.word 000000

	; COL 13
	.word 000000
	.word 000000
	.word 000000
	.word 177777
	.word 177777
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 177777
	.word 000000
	.word 177777
	.word 000000
	.word 000000

	; COL 14
	.word 000000
	.word 177777
	.word 177777
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 177777
	.word 000000
	.word 000000
	.word 177777
	.word 000000
	.word 000000
	.word 000000

	; COL 15
	.word 000000
	.word 177777
	.word 177777
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 177777
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000

	; COL 16
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 177777
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000
	.word 000000




;	message for text display
MESG:
	.word 000114 
	.word 000151 
	.word 000146 
	.word 000145 
	.word 000040 
	.word 000126 
	.word 000061 
	.word 000040 
	.word 000111 
	.word 000072 
	.word 000060 
	.word 000060 
	.word 000060 
	.word 000060 
	.word 000060 
	.word 000060

