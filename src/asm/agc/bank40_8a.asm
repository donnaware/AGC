;==========================================================================
; DISPLAY ROUTINES (file:bank40_8a.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 376.
;==========================================================================

;--------------------------------------------------------------------------
; MISCELLANEOUS SERVICE ROUTINES IN FIXED-FIXED
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.376.
;--------------------------------------------------------------------------

NVSUBSY1	EQU	*
		TS	NBSUBSY1_L	; save CADR
		TC	ISCADR_P0	; abort if CADRSTOR not = +0
		TC	ISLIST_P0	; abort if DSPLIST not = +0
		TC	RELDSPON
		CAF	ZERO		; was CA L in Block II
		AD	NBSUBSY1_L
		TS	DSPLIST
ENDNVBSY	TC	JOBSLEEP		