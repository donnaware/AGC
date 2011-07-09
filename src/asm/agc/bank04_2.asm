;==========================================================================
; DSPMM - DISPLAY MODREG (file: bank04_2.asm)
;
; DSPMM does not display MODREG directly. It puts EXEC request with
; prio=CHARPRIO for DSPMMJB and returns to caller.
;
; If MODREG contains -0, DSPMMJB blanks the MODE lights.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 369.
;==========================================================================


DSPMM		EQU	*
		XCH	Q
		TS	MPAC
		INHINT
		CAF	CHRPRIO
		TC	NOVAC
		CADR	DSPMMJB
		RELINT
ENDSPMM		TC	MPAC


	