;==========================================================================
; SCALE FACTOR ROUTINES (file:bank40_4.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 343-346.
;==========================================================================

DEGINSF		EQU	*
		TC	DMP		; SF routine for dec degrees
		ADRES	DEGCON1		; mult by 5.5 5(10)X2EXP-3
		CCS	MPAC+1		; this rounds off MPAC+1 before shift
		CAF	BIT11		; left 3, and causes 360.00 to OF/UF
		TC	*+2		; when shifted left and alarm
		CS	BIT11
		AD	MPAC+1
		TC	_2ROUND+2
		TC	TPSL1		; left 1
DEGINSF2	TC	TPSL1		; left 2
		TC	TESTOFUF
		TC	TPSL1		; returns if no OF/UF (left 3)
		CCS	MPAC
		TC	SIGNFIX		; if +, go to SIGNFIX
		TC	SIGNFIX		; if +0, go to SIGNFIX
		COM			; if -, use -MAGNITUDE + 1
		TS	MPAC		; -f -0; use +0
SIGNFIX		CCS	MPAC+6
		TC	SGNTO1		; if overflow
		TC	ENDSCALE	; no overflow/underflow
		CCS	MPAC		; if UF, force sign to 0 except -180
		TC	CCSHOLE
		TC	NEG180
		TC	*+1
		XCH	MPAC
		MASK	POSMAX
		TS	MPAC

ENDSCALE	EQU	*
		TC	POSTJUMP
		CADR	PUTCOM2

NEG180		CS	POSMAX
		TC	ENDSCALE-1

SGNTO1		EQU	*
		CS	MPAC		; if OV force sign to 1
		MASK	POSMAX
		CS	A
		TC	ENDSCALE-1

DEGCON1		DS	%26161
		DS	%30707

DEGCON2		DS	%21616
		DS	%07071

; ************ missing stuff ***************

ARTHINSF	EQU	*
		TC	DMP		; scales MPAC, +1 by SFTEMP1, SFTEMP2
		ADRES	SFTEMP1		; assumes point between HI and LO parts
		XCH	MPAC+2		; of SFCON, shifts results left by 14.
		XCH	MPAC+1		; (by taking results from MPAC+1, MPAC+2)
		XCH	MPAC

		CCS	A		; was BZF BINROUND in Block II
		TC	*+4		; >0
		TC	*+2		; +0
		TC	*+2		; <0
		TC	BINROUND	; -0

		TC	ALMCYCLE	; too large a load, alarm and recycle

BINROUND	EQU	*
		TC	_2ROUND
		TC	TESTOFUF
		TC	ENDSCALE


; ************ missing stuff ***************

_2ROUND		EQU	*
		XCH	MPAC+1
		DOUBLE
		TS	MPAC+1
		TC	Q		; if MPAC+1 does not OF/UF
		AD	MPAC
		TS	MPAC
		TC	Q		; if MPAC does not OF/UF
		TS	MPAC+6
_2RNDEND	TC	Q

TESTOFUF	EQU	*
		CCS	MPAC+6		; returns if no OF/UF
		TC	ALMCYCLE	; OF, alarm and recycle
		TC	Q
		TC	ALMCYCLE	; UF, alarm and recycle
