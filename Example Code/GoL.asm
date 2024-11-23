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
	; Memory map
	; o000010 -> 001100 = results page (256 words)
	; o001100 -> 002100 = calculation page (256 words)
	; o002500 -> 002777 = Variables
	;	o002500 = Y position
	;   o002502 = X position
	;	o002504 = Iteration
	;   
	; o003000 Code start
	

	nop
	jmp INIT



.blkb 002772
INIT:					; should be at o003000
	clr r0
	clr r2
	clr r3
	clr r4
	clr r5
	clr r6				; used for JSR/RTS

	jsr r6, MDISP		; show start message
	
	jsr r6, SETUP		; set initial memory values
	
	jsr r6, SHOWR		; Show results on 16x16 matrix

;-----------------------------------------------------
; main loop

MAIN:
	
	; do stuff




	; check if we've reached the ends of the column or row
	; end of column?
INCY:
	mov #002500, r4		; Y position memory location
	mov (r4), r3		; get Y position
	inc r3				; increment it

	cmp r3, #000020		; are we at the end of the column?
	beq INCX			; if we are, increment X
	
	mov r3, (r4)		; if not save Y
	br MAIN				; and do next Y position
	
INCX:
	clr r3				; clear Y position
	mov r3, (r4) 		; save Y position
	
	mov #002502, r4		; X position memory location
	mov (r4), r3		; get X position
	inc r3				; increment it

	cmp r3, #000020		; are we at the end of the column?
	beq ITCOMP			; if we have, the we've done one interation
	
	mov r3, (r4)		; save X
	br MAIN
	
ITCOMP: 
	clr r3				
	mov #002500, r4		; Y position memory location
	mov r3, (r4) 		; reset Y
	mov #002502, r4		; X position memory location
	mov r3, (r4) 		; reset X
	
	; MEMCOPY from o001100 to o000100
	; show the data
	; delay
	
	HALT
	
; ----------------------------------------------------
; Show result on matrix
SHOWR:
	; convert contents of RAM (r4) to display (r5)
	mov #140000, r5	; dot display address
	mov #000100, r4 ; results page address
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
	mov r0, (r5)	; put it in the display
	sub #000016, r4	; take off all the addition we did
	add #000040, r4	; go to next address
	add #2, r5		; point display to next address

	inc r3			; increase column counter
	cmp r3, #000020	; have we done 32 (2x16 sets of 8 bits)
	blt DILP
	
	mov #000030, r4 ; second part of results data
	clr r3
	inc r2
	cmp r2, #000002
	blt DILP
	
	rts r6

	
; ----------------------------------------------------
; setup memory
SETUP:
	clr r3
ILOP:
	mov (r0), (r5)			; copy contents of  address R0 to contents of address r5
	inc r3
	add #2, r0				; increase pointer
	add #2, r5				; increase pointer
	cmp r3, #000400			; have we done 256 addresses?
	blt ILOP


	clr r3
CLRL:						; clear next 256 locations
	mov #000000, (r5)		; Make sure it's all zero
	inc r3
	add #2, r0				; increase pointer
	add #2, r5				; increase pointer
	cmp r3, #000400			; have we done 256 addresses?
	blt CLRL
	


	rts r6


; ----------------------------------------------------
; show display message
MDISP:
	; display message
	mov #060036, r5
	mov #MESG, r0
	clr r3

MLOP:
	mov (r0), (r5)			; copy contents of  address R0 to contents of address r5
	inc r3
	add #2, r0				; increase pointer
	sub #2, r5				; increase pointer
	cmp r3, #000020			; have we done 16 characters?
	blt MLOP


	; put first step into RAM
	mov #000100, r5			; 000010 is first page of GoL memory
	mov #ISTP, r0			; the start of the message
	clr r3

	rts r6
	

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





MESG:
	.word 000107 
	.word 000141 
	.word 000155 
	.word 000145 
	.word 000040 
	.word 000117 
	.word 000146 
	.word 000040 
	.word 000114 
	.word 000151 
	.word 000146
	.word 000145	
	.word 000040
	.word 000126 
	.word 000061
	.word 000040
