;==========================================================================
; DISPLAY ROUTINES (file:bank40_8.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 369-371.
;==========================================================================

BLNKSUB1	EQU	*
		CAF	ZERO			; was CA DSPCOUNT in Block II
		AD	DSPCOUNT		; save old DSPCOUNT for later restoration
		TS	BUF+2

		CAF	BIT1			; test bit 1. See if R1 to be blanked.
		TC	TESTBIT
		CAF	R1D1
		TC	_5BLANK-1

		CAF	BIT2			; test bit 2. See if R2 to be blanked.
		TC	TESTBIT
		CAF	R2D1
		TC	_5BLANK-1

		CAF	BIT3			; test bit 3. See if R3 to be blanked.
		TC	TESTBIT
		CAF	R3D1
		TC	_5BLANK-1

		CAF	ZERO			; was CA BUF+2 in Block II
		AD	BUF+2			; restore DSPCOUNT to state it had
		TS	DSPCOUNT		; before BLANKSUB

		TC	BS_SUPDXCHZ		; was DXCH BUF, TC SUPDXCHZ+1 in BII



TESTBIT		EQU	*
		MASK	NVTEMP			; NVTEMP contains blanking code
		CCS	A
		TC	Q			; if current bit = 1, return to L+1
		INDEX	Q			; if current bit = 0, return to L+3
		TC	2

DSPMMJB		EQU	*
		CAF	MD1			; gets here thru DSPMM
		XCH	DSPCOUNT
		TS	DSPMMTEM		; save DSPCOUNT
		CCS	MODREG
		AD	ONE
		TC	DSPDECVN		; if MODREG is + or +0, display MODREG
		TC	*+2			; if MODREG is -NZ, do nothing
		TC	_2BLANK			; if MODREG is -0, blank MM
		XCH	DSPMMTEM		; restore DSPCOUNT
		TS	DSPCOUNT
		TC	ENDOFJOB

;--------------------------------------------------------------------------
; RECALTST
; Entered directly after data is loaded (or resequence verb is executed),
; terminate verb is executed, or proceed without data verb is executed.
; It wakes up job that did TC ENDIDLE.
; If CADRSTOR not = +0, it puts +0 into DSPLOCK, and turns off KEY RLSE
; light if DSPLIST is empty (leaves KEY RLSE light alone if not empty).
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.370.
;--------------------------------------------------------------------------

RECALTST	EQU	*
		CCS	CADRSTOR
		TC	RECAL1
		TC	ENDOFJOB		; normal exit if keyboard initiated.

RECAL1		EQU	*
		CAF	ZERO
		XCH	CADRSTOR
		INHINT
		TC	JOBWAKE
		CCS	LOADSTAT
		TC	DOPROC			; + proceed without data
		TC	ENDOFJOB		; pathological case exit
		TC	DOTERM			; - terminate
		CAF	TWO			; -0, data in or resequence

RECAL2		EQU	*
		INDEX	LOCCTR
		AD	LOC			; loc is + for basic jobs
		INDEX	LOCCTR
		TS	LOC

		CAF	ZERO			; save verb in MPAC, noun in MPAC+1 at
		AD	NOUNREG			; time of response to ENDIDLE for
		INDEX	LOCCTR			; possible later testing by job that has
		TS	MPAC+1			; been waked up

		CAF	ZERO
		AD	VERBREG
		INDEX	LOCCTR
		TS	MPAC

		RELINT

RECAL3		EQU	*
		TC	RELDSP
		TC	ENDOFJOB

DOTERM		EQU	*
		CAF	ZERO
		TC	RECAL2

DOPROC		EQU	*
		CAF	ONE
		TC	RECAL2
