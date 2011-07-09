;==========================================================================
; DISPLAY ROUTINES (file:bank41_3.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 349-351.
;==========================================================================

; MONITOR allows other keyboard activity. It is ended by verb TERMINATE
; verb PROCEED WITHOUT DATA, verb RESEQUENCE, another monitor, or any
; NVSUB call that passes DSPLOCK (provided that the operator has somehow
; allowed the ending of a monitor which he has initiated through the
; keyboard.
;
; MONITOR action is suspended, but not ended, by any keyboard action,
; except error light reset. It begins again when KEY RELEASE is performed.
; MONITOR saves the noun and appropriate display verb in MONSAVE. It saves
; NOUNCADR in MONSAVE1, if noun = machine CADR to be specified. Bit 15 of
; MONSAVE1 is the kill monitor signal (killer bit). Bit 14 of MONSAVE1
; indicates the current monitor was externally initiated (external monitor
; bit). It is turned off by RELDSP and KILMONON.
;
; MONSAVE indicates if MONITOR is on (+=ON, +0=OFF)
; If MONSAVE is +, monitor enters no request, but turns killer bit off.
; If MONSAVE is +0, monitor enters request and turns killer bit off.
;
; NVSUB (if external monitor bit is off), VB=PROCEED WITHOUT DATA,
; VB=RESEQUENCE, and VB=TERMINATE turn kill monitor bit on.
;
; If killer bit is on, MONREQ enters no further requests, zeroes MONSAVE
; and MONSAVE1 (turning off killer bit and external monitor bit).
;
; MONITOR doesn't test for MATBS since NVSUB can handle internal MATBS now.


MONITOR		EQU	*
		CS	BIT15_14
		MASK	NOUNCADR

MONIT1		EQU	*
		TS	MPAC+1		; temp storage

		CS	ENTEXIT
		AD	ENDINST
		CCS	A
		TC	MONIT2

BIT15_14	DS	%60000
		TC	MONIT2

		CAF	BIT14		; externally initiated monitor
		AD	MPAC+1		; was ADS MPAC+1 in Block II
		TS	MPAC+1		; set bit 14 for MONSAVE1

		CAF	ZERO
		TS	MONSAVE2	; zero NVMONOPT options

MONIT2		EQU	*
		CAF	LOW7
		MASK	VERBREG
		TC	LEFT5
		TS	CYL
		CS	CYL
		XCH	CYL
		AD	NOUNREG
		TS	MPAC		; temp storage
		CAF	ZERO
		TS	DSPLOCK		; +0 into DSPLOCK so monitor can run
		CCS	CADRSTOR	; turn off KR lite if CADRSTOR and DSPLIST
		TC	*+2		; are both empty. (Lite comes on if new
		TC	RELDSP1		; monitor is keyed in over old monitor.)
		INHINT
		CCS	MONSAVE
		TC	*+4		; if MONSAVE was +, no request

		CAF	ONE		; if MONSAVE was 0, request MONREQ
		TC	WAITLIST
		CADR	MONREQ
		
		XCH	MPAC+1		; was DXCH MPAC, DXCH MONSAVE
		XCH	MONSAVE+1

		XCH	MPAC		; place monitor verb and noun into MONSAVE
		XCH	MONSAVE		; zero the kill monitor bit


		RELINT			; set up external monitor bit
		TC	ENTRET

MONREQ		EQU	*
		TC	LODSAMPT	; called by waitlist (see COLOSSUS p. 374)
		CCS	MONSAVE1	; time is snatched in RUPT for NOUN 65
		TC	*+4		; if killer bit = 0, enter requests
		TC	*+3		; if killer bit = 0, enter requests
		TC	KILLMON		; if killer bit = 1, no requests
		TC	KILLMON		; if killer bit = 1, no requests

		CAF	MONDEL
		TC	WAITLIST	; enter waitlist request for MONREQ
		CADR	MONREQ

		CAF	CHRPRIO
		TC	NOVAC		; enter EXEC request for MONDO
		CADR	MONDO

		TC	TASKOVER

KILLMON		EQU	*
		CAF	ZERO		; zero MONSAVE and turn killer bit off
		TS	MONSAVE
		TS	MONSAVE1	; turn off kill monitor bit
		TC	TASKOVER	; turn off external monitor bit

MONDEL		DS	%144		; for 1 sec monitor intervals

MONDO		EQU	*
		CCS	MONSAVE1	; called by EXEC
		TC	*+4		; if killer bit = 0, continue
		TC	*+3		; if killer bit = 0, continue
		TC	ENDOFJOB	; in case TERMINATE came since last MONREQ
		TC	ENDOFJOB	; in case TERMINATE came since last MONREQ
		CCS	DSPLOCK
		TC	MONBUSY		; NVSUB is busy
		CAF	LOW7
		MASK	MONSAVE
		TC	UPDATNN-1	; place noun into NOUNREG and display it
		CAF	MID7
		MASK	MONSAVE		; change monitor verb to display verb
		AD	MONREF		; -DEC10, starting in bit5

		TS	CYR		; shift right 7, was TS EDOP, CA EDOP in BII
		CS	CYR
		CS	CYR
		CS	CYR
		CS	CYR
		CS	CYR
		CS	CYR
		XCH	CYR
		MASK	LOW7

		TS	VERBREG
		CAF	MONBACK		; set return to PASTEVB after data display
		TS	ENTRET
		CS	BIT15_14
		MASK	MONSAVE1
		TS	MPAC+2		; display it and set NOUNCADR, NOUNADD,
ENDMONDO	TC	TESTNN		; EBANK
		
		
; COLOSSUS switches to fixed/fixed memory and inserts PASTEVB here--
; Probably, because their assembler couldn't handle forward references.

MONREF		DS	%75377		; -dec10, starting in bit8
MONBACK		CADR	PASTEVB		

MONBUSY		TC	RELDSPON	; turn key release light
		TC	ENDOFJOB

LODSAMPT	TC	Q		; ************************** FIX *****************************