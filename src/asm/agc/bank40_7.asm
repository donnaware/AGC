;==========================================================================
; DISPLAY ROUTINES (file:bank40_7.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 360-362.
;==========================================================================

;--------------------------------------------------------------------------
; VBPROC -- PROCEED WITHOUT DATA
; VBTERM -- TERMINATE
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.360.
;--------------------------------------------------------------------------

VBPROC		EQU	*
		CAF	ONE			; proceed without data
		TS	LOADSTAT
		TC	KILMONON		; turn on kill monitor bit
		TC	RELDSP
		TC	FLASHOFF
		TC	RECALTST		; see if there is any recall from endidle

VBTERM		EQU	*
		CS	ONE
		TC	VBPROC+1		; term verb sets loadstat neg

;--------------------------------------------------------------------------
; VBRESEQ
; Wakes ENDIDLE at same line as final enter of load (L+3). Main use is
; intended as response to internally initiated flashing displays in ENDIDLE.
; Should not be used with load verbs, please perform, or please mark verbs
; because they already use L+3 in another context.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.361.
;--------------------------------------------------------------------------

VBRESEQ		EQU	*
		CS	ZERO			; make it look like data in.
		TC	VBPROC+1

	; flash is turned off by proceed without data, terminate,
	; resequence, end of load.


;--------------------------------------------------------------------------
; VBRELDSP
; This routine always turns off the UPACT light and always clears
; DSPLOCK.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.362.
;--------------------------------------------------------------------------

VBRELDSP	EQU	*

	; some code here to turn off the UPACT light is omitted

		CCS	_2122REG		; old DSPLOCK
		CAF	BIT14
		MASK	MONSAVE1		; external monitor bit (EMB)
		CCS	A
		TC	UNSUSPEN		; old DSPLOCK and EMB both 1, unsuspend

TSTLTS4		TC	RELDSP			; not unsuspending external monitor,
		CCS	CADRSTOR		; release display system and
		TC	*+2			; do reestablish if CADRSTOR is full
		TC	ENDOFJOB
		TC	POSTJUMP
		CADR	PINBRNCH

UNSUSPEN	EQU	*
		CAF	ZERO			; external monitor is suspended
		TS	DSPLOCK			; just unsuspend it by clearing DSPLOCK
		CCS	CADRSTOR		; turn key release light off if both
		TC	ENDOFJOB		; CADRSTOR and DSPLIST are empty
		TC	RELDSP1
		TC	ENDOFJOB


