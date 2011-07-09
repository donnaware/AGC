;==========================================================================
; PINBALL GAME (file:bank40_1.asm)
;
; AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.310-317.
;==========================================================================

;--------------------------------------------------------------------------
; CHARIN -- PROCESS KEYBOARD CHARACTER FROM KEYRUPT
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.310.
;--------------------------------------------------------------------------

CHARIN		EQU	*
		CAF	ONE		; block display syst
		XCH	DSPLOCK		; make dsp syst busy, but save old
		TS	_2122REG	; C(DSPLOCK) for error light reset
		CCS	CADRSTOR	; all keys except ER turn on KR lite if
		TC	*+2		; CADRSTOR is full. This reminds operator
		TC	CHARIN2		; to re-establish a flashing display
		CS	ELRCODE1	; which he has obscured with displays of
		AD	MPAC		; his own (see remarks preceding routine
					; VBRELDSP).

		CCS	A		; was BZF CHARIN2 in Block II
		TC	*+4		; >0
		TC	*+2		; +0
		TC	*+2		; <0
		TC	CHARIN2		; -0

		TC	RELDSPON	

CHARIN2		EQU	*
		XCH	MPAC
		TS	CHAR
		INDEX	A
		TC	*+1		; input_code function
		TC	CHARALRM	; 0
		TC	NUM		; 1
		TC	NUM		; 2
		TC	NUM		; 3
		TC	NUM		; 4
		TC	NUM		; 5
		TC	NUM		; 6
		TC	NUM		; 7
		TC	_89TEST		, 10		8
		TC	_89TEST		; 11		9
		TC	CHARALRM	; 12
		TC	CHARALRM	; 13
		TC	CHARALRM	; 14
		TC	CHARALRM	; 15
		TC	CHARALRM	; 16
		TC	CHARALRM	; 17
		TC	NUM-2		; 20		0
		TC	VERB		; 21		VERB
		TC	ERROR		; 22		ERROR LIGHT RESET
		TC	CHARALRM	; 23
		TC	CHARALRM	; 24
		TC	CHARALRM	; 25
		TC	CHARALRM	; 26
		TC	CHARALRM	; 27
		TC	CHARALRM	; 30
		TC	VBRELDSP	; 31		KEY RELEASE
		TC	POSGN		; 32		+
		TC	NEGSGN		; 33		-
		TC	ENTERJMP	; 34		ENTER
		TC	CHARALRM	; 35
		TC	CLEAR		; 36		CLEAR
		TC	NOUN		; 37		NOUN

ELRCODE1	DS	%22
ENTERJMP	TC	POSTJUMP
		DS	ENTER

_89TEST		EQU	*
		CCS	DSPCOUNT
		TC	*+4		; >0
		TC	*+3		; +0
		TC	ENDOFJOB	; <0, block data in if DSPCOUNT is <0 or -0
		TC	ENDOFJOB	; -0

		CAF	THREE
		MASK	DECBRNCH
		CCS	A
		TC	NUM		; if DECBRNCH is +, 8 or 9 OK
		TC	CHARALRM	; if DECBRNCH is +0, reject 8 or 9

;--------------------------------------------------------------------------
; NUM -- PROCESS NUMERICAL KEYBOARD CHARACTER
; Assembles octal, 3 bits at a time. For decimal, it converts incoming word
; as a fraction, keeping results to DP (double precision).
; Octal results are left in XREG, YREG, or ZREG. High part of DEC in XREG,
; YREG, ZREG; the low parts in XREGLP, YREGLP, or ZREGLP).
; DECBRNCH is left at +0 for octal, +1 for +DEC, +2 for -DEC.
; If DSPCOUNT was left -, no more data is accepted.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.311.
;--------------------------------------------------------------------------

		CAF	ZERO
		TS	CHAR

NUM		EQU	*
		CCS	DSPCOUNT
		TC	*+4		; >0
		TC	*+3		; +0
		TC	*+1		; <0, block datain if DSPCOUNT is <0 or -0
		TC	ENDOFJOB	; -0
		TC	GETINREL
		CCS	CLPASS		; if CLPASS is >0 or +0, make it +0
		CAF	ZERO
		TS	CLPASS
		TC	*+1
		INDEX	CHAR
		CAF	RELTAB
		MASK	LOW5
		TS	CODE
		CAF	ZERO		; was CA DSPCOUNT in Block II
		AD	DSPCOUNT
		TS	COUNT
		TC	DSPIN
		CAF	THREE
		MASK	DECBRNCH
		CCS	A		; +0=octal, +1=+dec, +2=-dec
		TC	DECTOBIN	; >0
		INDEX	INREL		; +0 (octal)
		XCH	VERBREG
		TS	CYL
		CS	CYL
		CS	CYL
		XCH	CYL
		AD	CHAR
		TC	ENDNMTST

DECTOBIN	EQU	*
		INDEX	INREL
		XCH	VERBREG
		TS	MPAC		; sum x 2EXP-14 in MPAC
		CAF	ZERO
		TS	MPAC+1
		CAF	TEN		; 10 x 3EXP-14
		TC	SHORTMP		; 10SUM x 2EXP-28 in MPAC, MPAC+1

		XCH	MPAC+1
		AD	CHAR
		TS	MPAC+1
		TC	ENDNMTST	; no overflow

		AD	MPAC		; overflow, must be 5th character
		TS	MPAC

		TC	DECEND

ENDNMTST	EQU	*
		INDEX	INREL
		TS	VERBREG
		CS	DSPCOUNT
		INDEX	INREL
		AD	CRITCON

		CCS	A		; was BZF ENDNUM in Block II
		TC	*+4		; >0
		TC	*+2		; +0, DSPCOUNT = CRITCON
		TC	*+2		; <0
		TC	ENDNUM		; -0

		TC	MORNUM		; - , DSPCOUNT G/ CRITCON

ENDNUM		EQU	*
		CAF	THREE
		MASK	DECBRNCH
		CCS	A
		TC	DECEND

ENDALL		EQU	*
		CS	DSPCOUNT	; block NUMIN by placing DSPCOUNT
		TC	MORNUM+1	; negatively




DECEND		EQU	*
		CS	ONE
		AD	INREL

		CCS	A		; was BZMF ENDALL in Block II
		TC	*+4		; >0
		TC	*+2		; +0, INREL=0,1(VBREG,NNREG), leave whole
		TC	*+1		; <0, INREL=0,1(VBREG,NNREG), leave whole
		TC	ENDALL		; -0, INREL=0,1(VBREG,NNREG), leave whole

		TC	DMP		; if INREL=2,3,4(R1,R2,R3), convert to frac
					; mult sum x2EXP-28 in MPAC, MPAC+1 by
		ADRES	DECON		; 2EXP14/10EPX5. Gives(sum/10EXP5)x2EXP-14
					; in MPAC, +1, +2
		CAF	THREE
		MASK	DECBRNCH
		INDEX	A
		TC	*+0
		TC	PDECSGN

		CS	MPAC+1		; - case (was DCS, DXCH in Block II)
		TS	MPAC+1
		CS	MPAC+2
		TS	MPAC+2

PDECSGN		EQU 	*
		XCH	MPAC+2
		INDEX	INREL
		TS	XREGLP-2
		XCH	MPAC+1
		INDEX	INREL
		TS	VERBREG
		TC	ENDALL

MORNUM		EQU	*
		CCS	DSPCOUNT	; decrement DSPCOUNT
		TS	DSPCOUNT
		TC	ENDOFJOB

CRITCON		EQU	*
		DS	%22		; dec 18
		DS	%20		; dec 16
		DS	%12		; dec 10
		DS	%5
		DS	%0

DECON		EQU	*
		DS	%05174		; 2EXP14/10EXP5 = .16384 DEC
		DS	%13261
		
;--------------------------------------------------------------------------
; GETINREL
; Gets proper data register relative address for current C(DSPCOUNT) and
; puts into INREL: +0 VERBREG, 1 NOUNREG, 2 XREG, 3 YREG, 4 ZREG
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.313.
;--------------------------------------------------------------------------

GETINREL	EQU	*
		INDEX	DSPCOUNT
		CAF	INRELTAB
		TS	INREL		; (A TEMP, REG)
		TC	Q

INRELTAB	EQU	*
		DS	%4		; R3D5, 0 = DSPCOUNT
		DS	%4		; R3D4, 1
		DS	%4		; R3D3, 2
		DS	%4		; R3D2, 3
		DS	%4		; R3D1, 4		
		DS	%3		; R2D5, 5
		DS	%3		; R2D4, 6
		DS	%3		; R2D3, 7
		DS	%3		; R2D2, 8D
		DS	%3		; R2D1, 9D
		DS	%2		; R1D5, 10D
		DS	%2		; R1D4, 11D
		DS	%2		; R1D3, 12D
		DS	%2		; R1D2, 13D
		DS	%2		; R1D1, 14D
		TC	CCSHOLE		; no DSPCOUNT numbers
		DS	%1		; ND2, 16D
		DS	%1		; ND1, 17D
		DS	%0		; VD2, 18D
		DS	%0		; VD1, 19D


CCSHOLE		TC	ENDOFJOB	; can't find this anywhere; best guess


;--------------------------------------------------------------------------
; VERB
; Verb key was pressed; prepare to enter a 2 decimal digit verb.
; Blank the verb display and call ENDOFJOB.
;
; NOUN
; Noun key was pressed; prepare to enter a 2 decimal digit noun.
; Blank the noun display and call ENDOFJOB.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.314.
;--------------------------------------------------------------------------

VERB		EQU	*
		CAF	ZERO
		TS	VERBREG
		CAF	VD1

NVCOM		EQU	*
		TS	DSPCOUNT
		TC	_2BLANK
		CAF	ONE
		TS	DECBRNCH	; set for dec V/N code
		CAF	ZERO
		TS	REQRET		; set for ENTPAS0
		CAF	ENDINST		; if DSPALARM occurs before first ENTPAS0
		TS	ENTRET		; or NVSUB, ENTRET must already be set
					; to TC ENDOFJOB
		TC	ENDOFJOB

NOUN		EQU	*		
		CAF	ZERO
		TS	NOUNREG
		CAF	ND1		; ND1, OCT 21 (DEC 17)
		TC	NVCOM


;--------------------------------------------------------------------------
; NEGSGN
; Turn the minus sign on for the register selected by DSPCOUNT.
; Call ENDOFJOB when done.
; 
; POSGN
; Turn the plus sign on for the register selected by DSPCOUNT.
; Call ENDOFJOB when done.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.314.
;--------------------------------------------------------------------------

NEGSGN		EQU	*
		TC	SIGNTEST
		TC	M_ON
		CAF	TWO

BOTHSGN		EQU	*
		INDEX	INREL		; set DEC compu bit to 1 (in DECBRNCH)
		AD	BIT7		; Bit 5 for R1, bit 4 for R2, bit 3 for R3
		AD	DECBRNCH
		TS	DECBRNCH

PIXCLPAS	EQU	*
		CCS	CLPASS		; if CLPASS is + or +0, make it +0
		CAF	ZERO
		TS	CLPASS
		TC	*+1
		TC	ENDOFJOB

POSGN		EQU	*
		TC	SIGNTEST
		TC	P_ON
		CAF	ONE
		TC	BOTHSGN


;--------------------------------------------------------------------------
; P_ON
; Turn the plus sign on for register selected by DSPCOUNT. 
; Return when done.
;
; M_ON
; Turn the minus sign on for register selected by DSPCOUNT. 
; Return when done.

; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.314.
;--------------------------------------------------------------------------

P_ON		EQU	*
		XCH	Q		; was LXCH Q in block II
		TS	LXCH_LPRET	; save return address in faux LP

		TC	GETINREL
		INDEX	INREL
		CAF	SGNTAB-2
		TS	SGNOFF
		AD	ONE
		TS	SGNON

SGNCOM		EQU	*
		CAF	ZERO
		TS	CODE
		XCH	SGNOFF
		TC	_11DSPIN

		CAF	BIT11
		TS	CODE
		XCH	SGNON
		TC	_11DSPIN

		TC	LXCH_LPRET	; return

M_ON		EQU	*
		XCH	Q		; was LXCH Q in block II
		TS	LXCH_LPRET	; save return address in faux LP

		TC	GETINREL
		INDEX	INREL
		CAF	SGNTAB-2
		TS	SGNON
		AD	ONE
		TS	SGNOFF
		TC	SGNCOM

SGNTAB		EQU	*
		DS	%5		; -R1
		DS	%3		; -R2
		DS	%0		; -R3


;--------------------------------------------------------------------------
; SIGNTEST
; Test whether this is a valid point for entering a + or - sign character. 
; Returns if valid; calls ENDOFJOB if invalid.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.314.
;--------------------------------------------------------------------------

SIGNTEST	EQU	*
		XCH	Q		; was LXCH Q in block II
		TS	LXCH_LPRET	; save return address in faux LP

					; allows +,- only when DSPCOUNT=R1D1
		CAF	THREE		; R2D1, or D3D1. Allows only first of
		MASK	DECBRNCH	; consecutive +/- characters.
		CCS	A		; if low2 bits of DECBRNCH not=0, sign
		TC	ENDOFJOB	; for this word already in, reject.

		CS	R1D1
		TC	SGNTST1		; DSPCOUNT is R1D1?
		CS	R2D1
		TC	SGNTST1
		CS	R3D1
		TC	SGNTST1
		TC	ENDOFJOB	; no match found, sign illegal

SGNTST1		EQU	*
		AD	DSPCOUNT

		CCS	A		; was BZF *+2 in Block II
		TC	Q		; >0, no match, check next register
		TC	LXCH_LPRET	; +0, match found, sign is legal
		TC	Q		; <0, no match, check next register
		TC	LXCH_LPRET	; -0, match found, sign is legal


;--------------------------------------------------------------------------
; CLEAR -- PROCESS CLEAR KEY
; Clear blanks which R1, R2, R3 is current or last to be displayed (pertinent
; XREG, YREG, ZREG is cleared). Successive clears take care of each RX L/
; RC until R1 is done, then no further action.
;
; The single component load verbs allow only the single RC that is appropriate
; to be cleared.
;
; CLPASS = 0, PASSO, can be backed up
; CLPASS = +NZ, HIPASS, can be backed up
; CLPASS = -NZ, PASSO, cannot be backed up
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.316.
;--------------------------------------------------------------------------

CLEAR		EQU	*
		CCS	DSPCOUNT
		AD	ONE
		TC	*+2
		AD	ONE
		INDEX	A		; do not change DSPCOUNT because may later
		CAF	INRELTAB	; fail LEGALTST
		TS	INREL		; must set INREL, even for HIPASS
		CCS	CLPASS
		TC	CLPASHI		; +
		TC	*+2		; +0, if CCLPASS is +0 or -, it is PASS0
		TC	*+1		; -
		CAF	ZERO		; was CA INREL in Block II
		AD	INREL
		TC	LEGALTST
		TC	CLEAR1

CLPASHI		EQU	*
		CCS	INREL
		TS	INREL
		TC	LEGALTST

		CAF	DOUBLK+2	; +3 to - number, backs data requests
		AD	REQRET		; was ADS REQRET in Block II
		TS	REQRET

		CAF	ZERO		; was CA INREL in Block II
		AD	INREL
		TS	MIXTEMP		; temp storage for INREL

		CCS	VERBREG		; was DIM VERBREG in Block II
		TC	*+3
		TC	*+2
		TC	*+1
		TS	VERBREG		; decrement VERB and redisplay

		TC	BANKCALL
		DS	UPDATVB

		CAF	ZERO		; was CA MIXTEMP in Block II
		AD	MIXTEMP
		TS	INREL		; restore INREL

CLEAR1		EQU	*
		TC	CLR5

		XCH	CLPASS		; was INCR CLPASS in Block II
		AD	ONE
		TS	CLPASS		; only if CLPASS is + or +0

		TC	ENDOFJOB	; set for higher pass


;--------------------------------------------------------------------------
; CLR5
; blanks 5 char display word by calling _5BLANK, but avoids TC GETINREL.
; Returns when done.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.316.
;--------------------------------------------------------------------------

CLR5		EQU	*
		XCH	Q		; was LXCH Q in block II
		TS	LXCH_LPRET	; save return address in faux LP
		TC	_5BLANK+3	; uses _5BLANK, but avoids its TC GETINREL


;--------------------------------------------------------------------------
; LEGALTST
; Returns if LEGAL, calls ENDOFJOB if illegal.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.316.
;--------------------------------------------------------------------------

LEGALTST	EQU	*
		AD	NEG2
		CCS	A
		TC	Q		; LEGAL, INREL G/ 2
		TC	CCSHOLE
		TC	ENDOFJOB	; ILLEGAL, INREL = 0, 1
		TC	Q		; LEGAL, INREL = 2


;--------------------------------------------------------------------------
; _5BLANK
; blanks 5 char display word in R1,R2,or R3. It also zeroes XREG, YREG or 
; ZREG. Place any + DSPCOUNT number for pertinent RC into DSPCOUNT.
; DSPCOUNT is left set to left most DSP numb for RC just blanked.
; Returns when done.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.316.
;--------------------------------------------------------------------------

		TS	DSPCOUNT	; needed for BLANKSUB

_5BLANK		EQU	*
		XCH	Q		; was LXCH Q in block II
		TS	LXCH_LPRET	; save return address in faux LP

		TC	GETINREL
		CAF	ZERO
		INDEX	INREL
		TS	VERBREG		; zero X, Y, Z reg
		INDEX	INREL
		TS	XREGLP-2
		TS	CODE
		INDEX	INREL		; zero pertinent DEC comp bit
		CS	BIT7
		MASK	DECBRNCH
		MASK	BRNCHCON	; zero low 3 bits
		TS	DECBRNCH
		INDEX	INREL
		CAF	SINBLANK-2	; blank isolated char separately
		TS	COUNT
		TC	DSPIN

_5BLANK1	EQU	*
		INDEX	INREL
		CAF	DOUBLK-2
		TS	DSPCOUNT
		TC	_2BLANK

		CS	TWO
		AD	DSPCOUNT	; was ADS DSPCOUNT in Block II
		TS	DSPCOUNT

		TC	_2BLANK
		INDEX	INREL
		CAF	R1D1-2
		TS	DSPCOUNT	; set DSPCOUNT to leftmost DSP number
		TC	LXCH_LPRET	; of REG, just blanked


SINBLANK	EQU	*
		DS	%16		; DEC 14
		DS	%5
		DS	%4

DOUBLK		EQU	*
		DS	%15		; DEC 13
		DS	%11		; DEC 9
		DS	%3

BRNCHCON	DS	%77774


;--------------------------------------------------------------------------
; _2BLANK
; blanks 2 char, place DSP number of left char of the pair into DSPCOUNT. 
; This number is left in DSPCOUNT. Returns when done.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.317.
;--------------------------------------------------------------------------


_2BLANK		EQU	*
		XCH	Q
		TS	SAVEQ

		CAF	ZERO		; was CA DSPCOUNT in Block II
		AD	DSPCOUNT
		TS	SR
		CS	BLANKCON

		INHINT
		INDEX	SR
		XCH	DSPTAB

		CCS	A		; was BZMF *+2 in Block II
		TC	*+4		; >0
		TC	*+2		; +0, if old contents -, NOUT OK
		TC	*+1		; <0, if old contents -, NOUT OK
		TC	*+2		; -0, if old contents -, NOUT OK

		XCH	NOUT		; was INCR NOUT in Block II
		AD	ONE
		TS	NOUT		; if old contents +, +1 to NOUT
		RELINT
		
		TC	SAVEQ

BLANKCON	DS	%4000



