;==========================================================================
; SCALE FACTOR ROUTINES (file:bank40_2.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 330-332.
;==========================================================================

DEGOUTSF	EQU	*
		CAF	ZERO
		TS	MPAC+2		; set index for full scale
		TC	FIXRANGE
		TC	*+2		; no augment needed (SFTEMP1 and 2 are 0)
		TC	SETAUG		; set augmenter according to C(MPAC+2)
		TC	DEGCOM

SETAUG		EQU	*
		CAF	ZERO		; loads SFTEMP1 and SFTEMP2 with the
		INDEX	MPAC+2		; DP augmenter constant
		AD	DEGTAB		; was DCA DEGTAB, DXCH SFTEMP1 in Block II
		XCH	SFTEMP1

		CAF	ZERO
		INDEX	MPAC+2
		AD	DEGTAB+1
		XCH	SFTEMP1+1

		TC	Q

FIXRANGE	EQU	*
		XCH	Q
		TS	FR_RETQ

		CCS	MPAC		; if MPAC is +, return to L+1
		TC	FR_RETQ		; if MPAC is -, return to L+2 after
		TC	FR_RETQ		; masking out the sign bit
		TC	*+1		; was TCF *+1 in Block II
		CS	BIT15
		MASK	MPAC
		TS	MPAC
		INDEX	FR_RETQ
		TC	1

DEGCOM		EQU	*
		CAF	ZERO		; was INDEX MPAC+2, DCA DEGTAB, DXCH MPAC in Block II
		INDEX	MPAC+2		; loads multiplier, does SHORTMP, and
		AD	DEGTAB+1	; adds augmenter
		XCH	MPAC+1		; adjusted angle in A

		CAF	ZERO
		INDEX	MPAC+2
		AD	DEGTAB
		XCH	MPAC

		TC	SHORTMP

		XCH	SFTEMP1+1	; was DXCH SFTEMP1, DAS MPAC in Block II
		AD	MPAC+1
		TS	MPAC+1		; skip on overflow
		CAF	ZERO		; otherwise, make interword carry=0

		AD	SFTEMP1		
		AD	MPAC
		TS	MPAC		; skip on overflow
		CAF	ZERO		; otherwise, make interword carry=0


		TC	SCOUTEND

DEGTAB		EQU	*
		DS	%05605		; Hi part of .18
		DS	%03656		; Lo part of .18
		DS	%16314		; Hi part of .45
		DS	%31463		; Lo part of .45


ARTOUTSF	EQU	*
		XCH	SFTEMP1+1	; was DXCH SFTEMP1, DXCH MPAC in Block II
		XCH	MPAC+1		; assumes point at left of DP SFCON
		XCH	SFTEMP1
		XCH	MPAC

		TC	PRSHRTMP	; if C(A) = -0, SHORTMP fails to give -0
SCOUTEND	TC	POSTJUMP
		CADR	DSPDCEND



;--------------------------------------------------------------------------
; READLO
; Picks up fresh data for both HI and LO and leaves it in MPAC, MPAC+1.
; This is needed for time display. It zeroes MPAC+2, but does not force
; TPAGREE.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.332.
;--------------------------------------------------------------------------

READLO		EQU	*
		XCH	Q
		TS	TEM4		; save return address

		INDEX	MIXBR
		TC	*

		TC	RDLONOR		; MIXBR=1, so normal noun

		CAF	ZERO		; MIXBR=2, so mixed noun
		INDEX	DECOUNT		; was INDEX DECOUNT, CA IDAD1TEM in Block II
		AD	IDAD1TEM	; get IDADDTAB entry for comp K of noun
		MASK	LOW11		; E bank
		TC	SETEBANK	; set EB, leave E address in A


	; Dereference noun address to move components of noun into MPAC, MPAC+1
	; mixed           normal
	; C(E SUBK)       C(E)
	; C((E SUBK)+1)   C(E+1)

READLO1		EQU	*
		TS	ADDRWD1		; temp store addr for immediate use below

		CAF	ZERO		; was INDEX A, DCA Q, DXCH MPAC in Block II
		INDEX	ADDRWD1
		AD	0
		TS	MPAC

		CAF	ZERO
		INDEX	ADDRWD1
		AD	1
		TS	MPAC+1

		CAF	ZERO
		TS	MPAC+2

		TC	TEM4		; return

RDLONOR		CAF	ZERO		; was CA NOUNADD in Block II
		AD	NOUNADD
ENDRDLO		TC	READLO1

