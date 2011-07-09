;==========================================================================
; DISPLAY ROUTINES (file:bank40_6.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 356-358.
;==========================================================================

;--------------------------------------------------------------------------
; DSPIN -- DISPLAY RELAY CODE
;
; For DSPIN, place 0-25 oct into COUNT to select the character (same as DSPCOUNT), 
; 5 bit relay code into CODE. Both are destroyed. If bit 14 of COUNT is 1, sign is 
; blanked with left char.
; For DSPIN11, place 0,1 into CODE, 2 into COUNT, rel address of DSPTAB entry
; into DSREL. 
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.356.
;--------------------------------------------------------------------------

DSPIN		EQU	*
		XCH	Q		; cant use L for RETURN, since many of the
		TS	DSEXIT		; routines calling DSPIN use L as RETURN

	; Set DSREL to index into DSPTAB; the index corresponds to the display character
	; referenced by COUNT (which is derived from DSPCOUNT)

		CAF	LOW5
		MASK	COUNT
		TS	SR		; divides by 2
		XCH	SR
		TS	DSREL

	; Check COUNT (derived from DSPCOUNT) to find whether the character to be 
	; displayed is in the right (Bits 5-1) or left (Bits 10-6) bits of the 
	; DSPTAB word.

		CAF	BIT1
		MASK	COUNT
		CCS	A
		TC	*+2		; >0, left if COUNT is odd
		TC	DSPIN1-1	; +0, right if COUNT is even

	; Character to be displayed should be in the left bits (Bit 10-6), so 
	; shift it left into bits 10-6.

		XCH	CODE
		TC	SLEFT5		; does not use CYL
		TS	CODE

	; Set COUNT as an enumerated type; tells how to mask the new character
	; into the relay word.
	; 0 = mask new character into right side of relayword (bits 5-1)
	; 1 = mask into left side (bits 10-6) and leave old sign (bit 11) alone.
	; 2 = mask into left side (bits 10-6) and blank sign bit (bit 11)

		CAF	BIT14
		MASK	COUNT
		CCS	A
		CAF	TWO		; >0, BIT14 = 1, blank sign
		AD	ONE		; +0, BIT14 = 0, leave sign alone

		TS	COUNT

	; New display character in CODE has been bit-shifted into the correct (left 
	; or right) bit position. All other bits are zeroed.

DSPIN1		EQU	*
		INHINT

	; Get the existing display word from DSPTAB. Words that have already been
	; displayed will be positive; words yet to be displayed will be negative.
	; Use CCS to load the absolute value of the display word. Since CCS decrements
	; it, we need to add 1 to restore the value.

		INDEX	DSREL
		CCS	DSPTAB
		TC	*+2		; >0, old word already displayed
		TC	DSLV		; +0, illegal DSPCOUNT (was TC CCSHOLE)
		AD	ONE		; <0, old word not displayed yet

		TS	DSMAG		; store the old relay word

	; Now, mask off the portion of the old relay word corresponding to the
	; new character. Subtract the new character from the old to see whether
	; they are the same.

		INDEX	COUNT
		MASK	DSMSK		; mask with 00037, 01740, 02000, or 03740
		EXTEND
		SU	CODE

	; Old code same as new code? If so, we don't need to redisplay it.

		CCS	A		; was BZF DSLV in Block II
		TC	DFRNT		; >0
		TC	DSLV		; +0, same, so return
		TC	DFRNT		; <0
		TC	DSLV		; -0, same, so return

	; New code is different.

DFRNT		EQU	*		; different
		INDEX	COUNT
		CS	DSMSK		; mask with 77740, 76037, 75777, or 74037
		MASK	DSMAG
		AD	CODE

	; Store new DSPTAB word and get the old (previous) word. If the old word is
	; negative, it had not been displayed yet, so NOUT (the count of undisplayed
	; words) has already been incremented for this DSPTAB word. If the old word 
	; is positive, it has already been displayed, so we need to increment NOUT
	; to tell DSPOUT to display the new word.

		CS	A
		INDEX	DSREL
		XCH	DSPTAB

		CCS	A		; was BZMF DSLV in Block II
		TC	*+4		; >0
		TC	*+2		; +0, DSPTAB entry was -
		TC	*+1		; <0, DSPTAB entry was -
		TC	DSLV		; -0, DSPTAB entry was -

		XCH	NOUT		; DSPTAB entry was + (was INCR NOUT in Block II)
		AD	ONE
		TS	NOUT

DSLV		RELINT
		TC	DSEXIT		; return


DSMSK	EQU	*
		DS	%00037		; COUNT=0
		DS	%01740		; COUNT=1
		DS	%02000		; COUNT=2
		DS	%03740		; COUNT=3

; For 11DSPIN, put rel address of DSPTAB entry into A, 1 in BIT11 or 0 in
; BIT11 of CODE. I changed the name to _11DSPIN because my assembler doesn't
; like labels that start with a digit.

_11DSPIN	EQU	*
		TS	DSREL
		CAF	TWO
		TS	COUNT
		XCH	Q		; must use same return as DSPIN
		TS	DSEXIT
		TC	DSPIN1

DSPOCTIN	EQU	*
		TC	DSPIN		; so DSPOCTWD doesn't use SWCALL
		CAF	*+2
		TC	BANKJUMP
ENDSPOCT	DS	OCTBACK


	; DSPALARM finds TC NVSUBEND in ENTRET for NVSUB initiated routines.
	; Abort with 01501.
	; DSPALARM finds TC ENDOFJOB in ENTRET for keyboard initiated routines.
	; do TC ENTRET.

PREDSPAL	EQU	*
		CS	VD1
		TS	DSPCOUNT

DSPALARM	EQU	*
		CS	NVSBENDL
		AD	ENTEXIT

		CCS	A		; was BZF CHARALRM+2 in Block II
		TC	*+4		; >0
		TC	*+2		; +0
		TC	*+2		; <0
		TC	CHARALRM+2	; -0

		CS	MONADR		; if this is a monitor, kill it
		AD	ENTEXIT

		CCS	A		; was BZF *+2 in Block II
		TC	*+4		; >0
		TC	*+2		; +0
		TC	*+2		; <0
		TC	*+2		; -0

		TC	*+2
		TC	KILMONON

CHARALRM	EQU	*
		TC	FALTON		; not NVSUB initiated, turn on OPR error
		TC	ENDOFJOB

		TC	POODOO
		DS	%01501
MONADR		DS	PASTEVB
NVSBENDL	TC	NVSUBEND

