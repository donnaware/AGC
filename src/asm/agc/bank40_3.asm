;==========================================================================
; WORD DISPLAY ROUTINES (file:bank40_3.asm)
;
; AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.336.
;==========================================================================

;--------------------------------------------------------------------------
; DSPDPDEC
; This is a special purpose verb for displaying a double precision AGC
; word as 10 decimal digits on the AGC display panel. It can be used with
; any noun, except mixed nouns. It displays the contents of the register
; NOUNADD is pointing to. If used with nouns which are inherently not DP
; such as the CDU counters, the display will be garbage.
; Display is in R1 and R2 only with the sign in R1.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.353.
;--------------------------------------------------------------------------

DSPDPDEC	EQU	*
		INDEX	MIXBR
		TC	*+0
		TC	*+2		; normal noun
		TC	DSPALARM

		CAF	ZERO
		INDEX	NOUNADD
		AD	0		; was DCA 0, DXCH MPAC in Block II
		TS	MPAC

		CAF	ZERO
		INDEX	NOUNADD
		AD	1		; was DCA 0, DXCH MPAC in Block II
		TS	MPAC+1

		CAF	R1D1
		TS	DSPCOUNT

		CAF	ZERO
		TS	MPAC+2

		TC	TPAGREE
		TC	DSP2DEC
ENDDPDEC	TC	ENTEXIT

		


