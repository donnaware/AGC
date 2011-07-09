;-------------------------------------------------------------------------
; MP1 (file:MP1.asm)
; PURPOSE: Test and checkout program for the Block 1 Apollo Guidance Computer.
; Tests extracode instruction: MP
;
; OPERATION: Enters an infinite loop at the end of the test. The A register contains 
; the Least significant word of the result of multiplying 2 numbers together.
; and the LP contains the MSW.
;-------------------------------------------------------------------------

	; ----------------------------------------------
	; MAIN PROGRAM ENTRY POINT
	; ----------------------------------------------
		ORG	GOPROG
goMAIN		EQU	*
		INHINT		; disable interrupts

	;------------------------------
	; MP check starts here
	; uses MPindex to access test values
	;------------------------------
		CAF	mp1	; Get the first value
		EXTEND 	; this is an extended instruction
		MP	mp2	; multiply by the second value
		XCH	LP	; exchange so A has LSW and LP has MSW

end		EQU	*
		TC	end	; finished, TC trap

mp1		DS	%00007	; check #08 (7 * 17) = 119 (o167, 0x77)
mp2		DS	%00021	; check #08 (7 * 17)

	; ----------------------------------------------
		ORG	EXTENDER
		DS	%47777	; needed for EXTEND

;-------------------------------------------------------------------------
; END OF PROGRAM
;-------------------------------------------------------------------------
