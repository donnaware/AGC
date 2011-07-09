;==========================================================================
; DISPLAY ROUTINES (file:bank41_4.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 352.
;==========================================================================

;--------------------------------------------------------------------------
; DSPFMEM -- DISPLAY FIXED MEMORY
; Used to display (in octal) any fixed register. It is used with NOUN =
; machine CADR to be specified. The FCADR of the desired location is then
; punched in. It handles F/F (FCADR 4000-7777)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.352.
;--------------------------------------------------------------------------

DSPFMEM		EQU	*
		CAF	R1D1		; If F/F, DATACALL uses bank 02 or 03
		TS	DSPCOUNT

		CAF	ZERO		; was CA NOUNCADR, TC SUPDACAL in Block II
		AD	NOUNCADR	; original FCADR loaded still in NOUNCADR
		TC	DATACALL	; call with FCADR in A

		TC	DSPOCTWD
ENDSPF		TC	ENDOFJOB
