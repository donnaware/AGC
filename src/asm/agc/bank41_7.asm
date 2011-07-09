;==========================================================================
; DISPLAY ROUTINES (file:bank41_7.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 365-366.
;==========================================================================



; BLANKDSP blanks display according to option number in NVTEMP as follows:
; -4 full blank, -3 leave mode, -2 leave mode and verb, -1 blank R-S only

BLANKDSP	EQU	*
		AD	SEVEN		; 7,8,9,or 10 (A had 0,1,2,or 3)
		INHINT
		TS	CODE		; blank specified DSPTABS
		CS	BIT12
		INDEX	CODE
		XCH	DSPTAB

		CCS	A
		TC	INCR_NOUT	; was INCR NOUT in Block II
INCR_NOUT_RET	TC	*+1

		CCS	CODE
		TC	BLANKDSP+2
		RELINT
		INDEX	NVTEMP
		TC	*+5
		TC	*+1		; NVTEMP has -4 (never touch MODREG)
		TS	VERBREG		;            -3
		TS	NOUNREG		;            -2
		TS	CLPASS		;            -1

		CS	VD1
		TS	DSPCOUNT

		TC	FLASHOFF	; protect against invisible flash
		TC	ENTSET-2	; zeroes REQRET

INCR_NOUT	EQU	*
		XCH	NOUT		; was INCR NOUT in Block II
		AD	ONE		; have to make it a separate routine
		TS	NOUT		; because it was nested inside
		TC	INCR_NOUT_RET	; a CCS.

NVSUB1		EQU	*
		CAF	ENTSET		; in bank
		TS	ENTRET		; set return to NVSUBEND

		CCS	NVTEMP		; what now
		TC	*+4		; normal NVSUB call (execute VN or paste)
		TC	GODSPALM
		TC	BLANKDSP	; blank display as specified
		TC	GODSPALM

		CAF	LOW7
		MASK	NVTEMP
		TS	MPAC+3		; temp for noun (can't use MPAC, DSPDECVN
					;                uses MPAC, +1, +2
		CAF	ZERO		; was CA NVTEMP
		AD	NVTEMP		

		TS	CYR		; shift right 7, was TS EDOP, CA EDOP in BII
		CS	CYR
		CS	CYR
		CS	CYR
		CS	CYR
		CS	CYR
		CS	CYR
		XCH	CYR
		MASK	LOW7
		TS	MPAC+4		; temp for verb (can't use MPAC, DSPDECVN
					;                uses MPAC, +1, +2

		CCS	MPAC+3		; test noun (+NZ or +0)
		TC	NVSUB2		; if noun not +0, DC on

		CAF	ZERO		; was CA MPAC+4 in Block II
		AD	MPAC+4
		TC	UPDATVB-1	; if noun = +0, display verb then return

		CAF	ZERO		; zero REQRET so that pasted verbs can
		TS	REQRET		; be executed by operator

ENTSET		TC	NVSUBEND


NVSUB2		CCS	MPAC+4		; test verb (+NZ or +0)
		TC	*+5		; if verb not +0, go on

		CAF	ZERO		; was CA MPAC+3 in Block II
		AD	MPAC+3
		TC	UPDATNN-1	; if verb = +0, display noun, then return
		TC	NVSUBEND

		CAF	ZERO		; was CA MPAC+2 in Block II
		AD	MPAC+2		; temp for mach CADR to be spec, (DSPDECVN
		TS	MPAC+5		;              uses MPAC, +1, +2

		CAF	ZERO		; was CA MPAC+4 in Block II
		AD	MPAC+4
		TC	UPDATVB-1	; if both noun and verb not +0, display

		CAF	ZERO		; was CA MPAC+3 in Block II
		AD	MPAC+3		; both and go to ENTPAS0
		TC	UPDATNN-1

		CAF	ZERO
		TS	LOADSTAT	; set for waiting for data condition
		TS	CLPASS
		TS	REQRET		; set request for pass 0

		CAF	ZERO		; was CA MPAC+5 in Block II
		AD	MPAC+5		; restores mach CADR to be spec to MPAC+2
		TS	MPAC+2		; for use in INTMCTBS (in ENTPAS0)

ENDNVSB1	TC	ENTPAS0

; if internal mach CADR to be specified, MPAC+2 will be placed into 
; NOUNCADR in ENTPAS0 (INTMCTBS)


		
