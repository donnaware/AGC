;==========================================================================
; DISPLAY ROUTINES (file:bank41_5.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 355-356.
;==========================================================================

;--------------------------------------------------------------------------
; DSPOCTWD -- DISPLAY OCTAL WORD
; Displays C(A) upon entry as a 5 char octal starting in the DSP char
; specified in DSPCOUNT. It stops after 5 char have been displayed.
;
;
; DSP2BIT -- DISPLAY 2 OCTAL CHARS
; Displays C(A) upon entry as a 2 char oct beginning in the DSP
; loc specified in DSPCOUNT by pre-cycling right C(A) and using
; the logic of the 5 char octal display.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.355/356.
;--------------------------------------------------------------------------

DSPOCTWD	EQU	*
		TS	CYL
		XCH	Q
		TS	WDRET		; must use the same return as DSP2BIT

		CAF	BIT14		; to blank signs
		AD	DSPCOUNT	; was ADS DSPCOUNT in block II
		TS	DSPCOUNT

		CAF	FOUR

WDAGAIN		EQU	*
		TS	WDCNT
		CS	CYL
		CS	CYL
		CS	CYL
		CS	A

		MASK	DSPMSK
		INDEX	A
		CAF	RELTAB
		MASK	LOW5
		TS	CODE

		XCH	DSPCOUNT
		TS	COUNT
		CCS	A		; decrement DSPCOUNT except at +0
		TS	DSPCOUNT	; > 0
		TC	POSTJUMP	; + 0
		DS	DSPOCTIN

OCTBACK		EQU	*
		CCS	WDCNT
		TC	WDAGAIN

DSPLW		EQU	*
		CS	VD1		; to block numerical characters, clears
		TS	DSPCOUNT
		TC	WDRET		; * return

DSPMSK		EQU	SEVEN

DSP2BIT		EQU	*
		TS	CYR
		XCH	Q
		TS	WDRET
		CAF	ONE
		TS	WDCNT
		CS	CYR
		CS	CYR
		XCH	CYR
		TS	CYL
		TC	WDAGAIN+5



