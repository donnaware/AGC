;==========================================================================
; DISPLAY ROUTINES (file:bankff_4.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 366-368.
;==========================================================================


KILMONON	EQU	*		; force bit 15 of MONSAVE1 to 1.
		CAF	BIT15		; this is the kill monitor bit.
		TS	MONSAVE1	; turn off bit 14, the external
		TC	Q		; monitor bit.



; COLOSSUS p. 367

ENDIDLE		EQU	*
		XCH	Q		; was LXCH Q in Block II
		TS	ENDIDLE_L	; return address into L

		TC	ISCADR_P0	; abort if CADRSTOR not= +0
		TC	ISLIST_P0	; abort if DSPLIST not= +0

		CAF	ZERO		; was CA L in Block II
		AD	ENDIDLE_L	; don't set DSPLOCK to 1 so can use
		MASK	LOW10		; ENDIDLE with NVSUB initiated monitor.
		AD	BANK		; same strategy for CADR as MAKECADR
		TS	CADRSTOR
		TC	JOBSLEEP

ENDINST		TC	ENDOFJOB

ISCADR_P0	EQU	*
		CCS	CADRSTOR	; aborts (code 1206 if CADRSTOR not= +0
		TC	DSPABORT	; returns if CADRSTOR = +0
		TC	Q
		TC	DSPABORT

ISLIST_P0	EQU	*
		CCS	DSPLIST		; aborts (code 1206 if DSPLIST not= +0
		TC	DSPABORT	; returns if DSPLIST = +0
		TC	Q
DSPABORT	TC	POODOO
		DS	%1206
		

; BLANKSUB blanks any combination of R1, R2, R3. Call with blanking code in A.
; BIT1=1 blanks R1, BIT2=1 blanks R2, BIT3=1 blanks R3. Any combination of these
; three bits is accepted.
;
; DSPCOUNT is restored to the state it was in before BLANKSUB was executed.

BLANKSUB	EQU	*
		MASK	SEVEN
		TS	NVTEMP		; store blanking code in NVTEMP
		CAF	BIT14
		MASK	MONSAVE1	; external monitor bit
		AD	DSPLOCK
		CCS	A
		TC	Q		; dsp syst blocked. Return to 1+calling loc
		XCH	Q		; was INCR Q in Block II
		AD	ONE		; set return for 2+calling location
		TS	BLANKSUB_Q	; was TC Q in Block II

		CCS	NVTEMP
		TC	*+2		; was TCF in Block II
		TC	BLANKSUB_Q	; nothing to blank, Return to 2+calling loc


	; the return address+2 is now in BLANKSUB_Q. We need to call BLNKSUB1 in
	; in "bank 40", so we'll have to save the bank register so that we can
	; return to the address in BLANKSUB_Q. The block II code had a bunch of
	; tricky stuff involving the both bank bits and superbit. Block I doesn't
	; need to worry about that, so we can substitute this simplified code.
	; As in the Block II code, the return bank gets saved to BUF and the return
	; address+2 gets saved to BUF+1.

		CAF	ZERO
		AD	BLANKSUB_Q
		XCH	BUF+1		; set return for 2+calling loc

		CAF	ZERO
		AD	BANK
		XCH	BUF		; save return bank

		CAF	BSUB1ADDR
		TC	DXCHJUMP	; bank jump to BLNKSUB1 rtne 
BSUB1ADDR	CADR	BLNKSUB1

	; this is my attempt to implement the return from BLNKSUB1. In BII, it executes
	; as part of the BLNKSUB1 routine:
	;     DXCH BUF
	;     TC SUPDXCHZ+1
	; to jump from the BLNKSUB1 bank to the calling bank.

BS_SUPDXCHZ	EQU	*
		XCH	BUF
		XCH	BANK		; restore the calling bank bits
		TC	BUF+1		; return to calling loc+2 (set in BLANKSUB)
