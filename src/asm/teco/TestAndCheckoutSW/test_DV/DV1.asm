;-------------------------------------------------------------------------
; DV1 (file: DV1.asm)
; PURPOSE: Simple test of DV instruction
;; OPERATION: Enters an infinite loop at the end of the test. The A register contains 
; the result of dividing 2 numbers
;-------------------------------------------------------------------------
OVFCNTR		EQU	%00034	; overflow counter

	; ----------------------------------------------
	; MAIN PROGRAM ENTRY POINT:
	; ----------------------------------------------
		ORG	GOPROG
goMAIN		EQU	*
		INHINT		; disable interrupts

	; ----------------------------------------------
	; TEST DV INSTRUCTION SUBROUTINE
	; L:	DV	K
	; Verifies the following:
	; - Set C(A) = b(A) / C(K)
	; - Set C(Q) = - abs(remainder)
	; - Set C(LP) > 0 if quotient is positive
	; - Set C(LP) < 0 if quotient is negative
	; - Take next instruction from L+1
	; ----------------------------------------------

chkDV		EQU	*
		CAF	div2_00
		EXTEND 		; This is an extended instruction
		DV	div1_00

	; ----------------------------------------------
	; Trap at end
	; ----------------------------------------------
end		EQU	*
		TC	end	; finished, TC trap
	; ----------------------------------------------


	; ----------------------------------------------
	; C(A) test values
	; ----------------------------------------------
div1		DS	%00001	; check #20 (+1/+2)  ; == %20000
div2		DS	%00002	; check #20 (+1/+2)	; == %20000, R= %77777
div3		DS	%00003	; check #21 (+1/+3) ; == %12525, r=%77776

div1_00	DS	%00000	; check #00 (+0/+0)
div1_01	DS	%00000	; check #01 (+0/-0)
div1_02	DS	%77777	; check #02 (-0/+0)
div1_03	DS	%77777	; check #03 (-0/-0)

div2_00	DS	%00000	; check #00 (+0/+0)
div2_01	DS	%77777	; check #01 (+0/-0)
div2_02	DS	%00000	; check #02 (-0/+0)
div2_03	DS	%77777	; check #03 (-0/-0)

	; ----------------------------------------------
	; Extender code
	; ----------------------------------------------
		ORG	EXTENDER
		DS	%47777	; needed for EXTEND

;-------------------------------------------------------------------------
; END OF PROGRAM
;-------------------------------------------------------------------------
