;==========================================================================
; DISPLAY ROUTINES (file:bank40_9.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 381-382.
;==========================================================================

;--------------------------------------------------------------------------
; ERROR - Error light reset.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.381.
;--------------------------------------------------------------------------

ERROR		EQU	*
		XCH	_2122REG		; restore original C(DSPLOCK), thus error
		TS	DSPLOCK			; light reset leaves DSPLOCK unchanged

	; omitted some stuff in COLOSSUS here

		CS	ERCON			; turn off UPTL, OPER ERR, PROG ALM
		MASK	DSALMOUT
		TS	DSALMOUT

TSTAB		CAF	BINCON			; dec 10
		TS	ERCNT			; ERCNT = count
		INHINT
		INDEX	ERCNT
		CCS	DSPTAB
		AD	ONE
		TC	ERPLUS
		AD	ONE

ERMINUS		CS	A
		MASK	NOTBIT12
		TC	ERCOM

ERPLUS		CS	A
		MASK	NOTBIT12
		CS	A

ERCOM		INDEX	ERCNT
		TS	DSPTAB
		RELINT
		CCS	ERCNT
		TC	TSTAB+1

		CAF	ZERO			; clear the error codes for PROG ALM
		TS	FAILREG
		TS	FAILREG+1
		TS	FAILREG+2

		TC	ENDOFJOB

NOTBIT12	DS	%73777


ERCON		DS	%504			; channel 11 bits 3,7,9
