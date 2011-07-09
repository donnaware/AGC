;==========================================================================
; DISPLAY ROUTINES (file:bankff_1.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 351.
;==========================================================================

PASTEVB		EQU	*
		CAF	MID7
		MASK	MONSAVE2	; NVMONOPT paste option
		TS	PASTE_TMP

		CCS	A		; was BZF *+2 in Block II
		TC	*+2		; >0,
		TC	*+2		; +0,
		TC	*+2		; <0,
		TC	*+3		; -0,

		XCH	PASTE_TMP
		TC	PASTEOPT	; paste please verb for NVMONOPT

		CAF	ZERO		; was CA MONSAVE in BII
		AD	MONSAVE		; paste monitor verb - paste option is 0

PASTEOPT	EQU	*
		TS	CYR		; shift right 7, was TS EDOP, CA EDOP in BII
		CS	CYR
		CS	CYR
		CS	CYR
		CS	CYR
		CS	CYR
		CS	CYR
		XCH	CYR
		MASK	LOW7		; place monitor verb or please verb into

		TC	BANKCALL	; VERBREG and display it.
		CADR	UPDATVB-1

		CAF	ZERO		; zero REQRET so that pasted verbs can
		TS	REQRET		; be executed by operator.

		CAF	ZERO
		AD	MONSAVE2	; was CA MONSAVE2 in BII
		TC	BLANKSUB	; process NVMONOPT blank option if any (p. 368)
		TC	*+1
ENDPASTE	TC	ENDOFJOB

MID7		DS	%37600
