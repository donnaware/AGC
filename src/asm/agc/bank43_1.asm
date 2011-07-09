;==========================================================================
; DISPLAY ROUTINES (file:bank43_1.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 230.
;==========================================================================

;--------------------------------------------------------------------------
; GOEXTVB -- EXTENDED VERBS
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.230.
;--------------------------------------------------------------------------

GOEXTVB		EQU	*
		INDEX	MPAC		; verb-40 is in MPAC
		TC	LST2FAN		; fan as before

LST2FAN		EQU	*
		TC	ALM_END		; VB40 - spare
		TC	ALM_END		; VB41 - spare
		TC	ALM_END		; VB42 - spare
		TC	ALM_END		; VB43 - spare
		TC	ALM_END		; VB44 - spare
		TC	ALM_END		; VB45 - spare
		TC	ALM_END		; VB46 - spare
		TC	ALM_END		; VB47 - spare
		TC	ALM_END		; VB48 - spare
		TC	ALM_END		; VB49 - spare
		TC	ALM_END		; VB50 - spare
		TC	ALM_END		; VB51 - spare
		TC	ALM_END		; VB52 - spare
		TC	ALM_END		; VB53 - spare
		TC	ALM_END		; VB54 - spare
		TC	ALM_END		; VB55 - spare
		TC	ALM_END		; VB56 - spare
		TC	ALM_END		; VB57 - spare
		TC	ALM_END		; VB58 - spare
		TC	ALM_END		; VB59 - spare
		TC	ALM_END		; VB60 - spare
		TC	ALM_END		; VB61 - spare
		TC	ALM_END		; VB62 - spare
		TC	ALM_END		; VB63 - spare
		TC	ALM_END		; VB64 - spare
		TC	ALM_END		; VB65 - spare
		TC	ALM_END		; VB66 - spare
		TC	ALM_END		; VB67 - spare
		TC	ALM_END		; VB68 - spare
		TC	ALM_END		; VB69 - spare
		TC	ALM_END		; VB70 - spare
		TC	ALM_END		; VB71 - spare
		TC	ALM_END		; VB72 - spare
		TC	ALM_END		; VB73 - spare
		TC	ALM_END		; VB74 - spare
		TC	ALM_END		; VB75 - spare
		TC	ALM_END		; VB76 - spare
		TC	ALM_END		; VB77 - spare
		TC	ALM_END		; VB78 - spare
		TC	ALM_END		; VB79 - spare
		TC	ALM_END		; VB80 - spare
		TC	ALM_END		; VB81 - spare
		TC	ALM_END		; VB82 - spare
		TC	ALM_END		; VB83 - spare
		TC	ALM_END		; VB84 - spare
		TC	ALM_END		; VB85 - spare
		TC	ALM_END		; VB86 - spare
		TC	ALM_END		; VB87 - spare
		TC	ALM_END		; VB88 - spare
		TC	ALM_END		; VB89 - spare
		TC	ALM_END		; VB90 - spare
		TC	ALM_END		; VB91 - spare
		TC	ALM_END		; VB92 - spare
		TC	ALM_END		; VB93 - spare
		TC	ALM_END		; VB94 - spare
		TC	ALM_END		; VB95 - spare
		TC	ALM_END		; VB96 - spare
		TC	ALM_END		; VB97 - spare
		TC	ALM_END		; VB98 - spare
		TC	ALM_END		; VB99 - spare


ALM_END		EQU	*
		TC	FALTON		; turn on operator error light
GOPIN		TC	POSTJUMP
		FCADR	PINBRNCH



		
