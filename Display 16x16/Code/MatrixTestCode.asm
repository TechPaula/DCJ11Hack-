NOP

	
CLEAR:
	mov #140000, r4		; dot display address
	mov #100, r1		; counter

CLRLP:
	mov #0, (r4)		; clear dot column
	add #2, r4
	dec r1				; decrease counter
	cmp r1, #0			; are we at 0?
	bgt CLRLP			; if not, do it again
	
	CLC					; clear all the flags
	CLV
	CLZ
	CLN

SETUP:
	mov #140000, r4		; dot display address
	mov #060000, r0		; display address
	mov #17, r1			; counter
	mov #52, (r0)		; display first character "*"
	jsr r3, DELAY		; Short Delay
	
LOOPLEFT:
	mov #40, (r0)		; put in a blank space
	add #2, r0			; point to next character

	mov #0, (r4)		; clear dots
	add #2, r4			; point to next row
		
	mov #52, (r0)		; put a "*" ion new place
	mov #377, (r4)		; column of dots
	
	jsr r3, DELAY		; short delay

	dec r1				; decrease counter	
	cmp r1, #0			; are we at 0?
	bgt LOOPLEFT		; if not, do it again
	

LOOPRIGHT:
	mov #40, (r0)		; put in a blank space
	sub #2, r0			; point to next character

	mov #0, (r4)		; clear dots
	sub #2, r4			; point to next row

	mov #52, (r0)		; put a "*" ion new place
	mov #377, (r4)		; column of dots
	
	jsr r3, DELAY		; short delay
	
	inc r1				; increase counter
	cmp r1, #17			; are we at 15?
	blt LOOPRIGHT		; if not, do it again

	br LOOPLEFT			; do it all over again

DELAY:
	mov #017777,r2		; delay amount
	
DELAYLOOP:
	dec r2				; decrease counter
	cmp r2, #0			; are we at 0?
	bgt DELAYLOOP		; if not, do it again
	;halt				; used for debugging only
	rts r3				; return from subroutine
	