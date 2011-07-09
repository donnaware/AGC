;==========================================================================
; WORD DISPLAY ROUTINES (file:bank40_5.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 353-355.
;==========================================================================

DSPSIGN		EQU	*
		XCH	Q
		TS	DSPWDRET

		CCS	MPAC
		TC	*+8		; >0, positive sign
		TC	*+7		; +0, positive sign

		AD	ONE
		TS	MPAC
		TC	M_ON		; display minus sign
		CS	MPAC+1
		TS	MPAC+1
		TC	DSPWDRET

		TC	P_ON		; display plus sign

		TC	DSPWDRET	; return


;--------------------------------------------------------------------------
; DSPRND
; Round up decimal fraction by 5 EXP -6. This was entirely coded in
; Block II instructions, so I translated it to the functional
; equivalent in Block I code.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.353.
;--------------------------------------------------------------------------

DSPRND		EQU	*
		CAF	DECROUND
		AD	MPAC+1
		TS	MPAC+1		; skip on overflow
		CAF	ZERO		; otherwise, make interword carry=0
		AD	MPAC
		TS	MPAC		; skip on overflow
		TC	Q		; return
		
		CAF	DPOSMAX+1	; number overflows, so set to max
		TS	MPAC+1
		CAF	DPOSMAX
		TS	MPAC
		TC	Q		; return

DPOSMAX		EQU	*		; max positive decimal fraction
		DS	%37777
		DS	%34000


;--------------------------------------------------------------------------
; DSPDECTWD -- DISPLAY DECIMAL WORD
; Converts C(MPAC, MPAC+1) into a sign and 5 char decimal starting in loc
; specified in DSPCOUNT. it rounds by 5 exp 6.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.353.
;--------------------------------------------------------------------------

DSPDECWD	EQU	*
		XCH	Q
		TS	WDRET

		TC	DSPSIGN
		TC	DSPRND
		CAF	FOUR

DSPDCWD1	EQU	*
		TS	WDCNT
		CAF	BINCON
		TC	SHORTMP

TRACE1		EQU	*
		INDEX	MPAC
		CAF	RELTAB
		MASK	LOW5
		TS	CODE
		CAF	ZERO
		XCH	MPAC+2
		XCH	MPAC+1
		TS	MPAC
		XCH	DSPCOUNT

TRACE1S		EQU	*
		TS	COUNT
		CCS	A		; decrement DSPCOUNT except at +0
		TS	DSPCOUNT
		TC	DSPIN
		CCS	WDCNT
		TC	DSPDCWD1	; >0, not done yet

		CS	VD1		; +0
		TS	DSPCOUNT
		TC	WDRET		; return

		DS	%00000
DECROUND	DS	%02476


;--------------------------------------------------------------------------
; DSPDECNR
; Converts C(MPAC, MPAC+1) into a sign and 5 char decimal starting in loc 
; specified in DSPCOUNT. It does not round.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.354.
;--------------------------------------------------------------------------

DSPDECNR	EQU	*
		XCH	Q
		TS	WDRET
		TC	DSPSIGN
		TC	DSPDCWD1-1


;--------------------------------------------------------------------------
; DSPDC2NR 
; Converts C(MPAC, MPAC+1) into a sign and 2 char decimal starting in loc 
; specified by DSPCOUNT. It does not round.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.354.
;--------------------------------------------------------------------------

DSPDC2NR	EQU	*
		XCH	Q
		TS	WDRET
		TC	DSPSIGN
		CAF	ONE
		TC	DSPDCWD1

;--------------------------------------------------------------------------
; DSP2DEC 
; Converts C(MPAC) and C(MPAC+1) into a sign and 10 char decimal starting 
; in the loc specified in DSPCOUNT.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.354.
;--------------------------------------------------------------------------

DSP2DEC		EQU	*
		XCH	Q
		TS	WDRET
		CAF	ZERO
		TS	CODE
		CAF	THREE
		TC	_11DSPIN	; -R2 off
		CAF	FOUR
		TC	_11DSPIN	; +R2 off
		TC	DSPSIGN
		CAF	R2D1
END2DEC		TC	DSPDCWD1


;--------------------------------------------------------------------------
; DSPDECVN
; Displays C(A) upon entry as a 2 char decimal beginning in the
; loc specified in DSPCOUNT.
; C(A) should be in form N x 2EXP-14. This is scaled to form N/100 before
; display conversion.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.353.
;--------------------------------------------------------------------------

DSPDECVN	EQU	*
		EXTEND
		MP	VNDSPCON	; mult by .01

		XCH	LP		; was LXCH MPAC in Block II
		TS	MPAC		; take results from LP (mult by 2EXP14)

		CAF	ZERO
		TS	MPAC+1
		XCH	Q
		TS	WDRET
		TC	DSPDC2NR+3	; no sign, no round, 2 char

VNDSPCON	DS	%00244		; .01 rounded up

GOVNUPDT	EQU	*
		TC	DSPDECVN	; this is not for general use. Really part
		TC	POSTJUMP	; of UPDATVB
		DS	UPDAT1+2

