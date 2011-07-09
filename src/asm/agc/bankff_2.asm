;==========================================================================
; DISPLAY ROUTINES (file:bankff_2.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 358.
;==========================================================================

;--------------------------------------------------------------------------
; ALMCYCLE
; Turns on check fail light, redisplays the original verb that was executed,
; and recycles to execute the original verb/noun combination that was last
; executed. Used for bad data during load verbs and by MCTBS. Also by MMCHANG
; if 2 numerical chars were not punched in for MM code.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.358.
;--------------------------------------------------------------------------

ALMCYCLE	EQU	*
		TC	FALTON		; turn on check fail light
		CS	VERBSAVE	; get original verb that was executed
		TS	REQRET		; set for ENTPAS0
		TC	BANKCALL	; puts original verb into VERBREG and
		DS	UPDATVB-1	; displays it in verb lights
		TC	POSTJUMP
ENDALM		DS	ENTER

