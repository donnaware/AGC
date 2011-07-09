;==========================================================================
; DISPLAY ROUTINES (file:bank41_6.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 359-360.
;==========================================================================

;--------------------------------------------------------------------------
; MMCHANG -- MAJOR MODE CHANGE
; Uses noun display until ENTER; then it uses MODE display. It goes to 
; MODROUT with the new MM code in A, but not displayed in MM lights.
; It demands 2 numerical characters be punched in for new MM code.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.359.
;--------------------------------------------------------------------------

MMCHANG		EQU	*
		TC	REQMM		; ENTPASHI assumes the TC GRQMM at MMCHANG
					; if this moves at all, must change
					; MMADREF at ENTPASHI
		CAF	BIT5		; OCT 20 = ND2
		AD	DSPCOUNT	; DSPCOUNT must = -ND2

		CCS	A		; was BZF *+2 in Block II
		TC	*+4		; >0
		TC	*+2		; +0
		TC	*+2		; <0
		TC	*+2		; -0

		TC	ALMCYCLE	; DSPCOUNT not -ND2. Alarm and recycle.

		CAF	ZERO
		XCH	NOUNREG
		TS	MPAC

		CAF	ND1
		TS	DSPCOUNT

		TC	BANKCALL
		DS	_2BLANK

		CS	VD1		; block num char in
		TS	DSPCOUNT

		CAF	ZERO		; was CA MPAC in Block II
		AD	MPAC
		TC	POSTJUMP
		DS	MODROUTR	; go thru standard loc.

MODROUTR	EQU	V37


REQMM		EQU	*
		CS	Q
		TS	REQRET
		CAF	ND1
		TS	DSPCOUNT
		CAF	ZERO
		TS	NOUNREG
		TC	BANKCALL
		DS	_2BLANK
		TC	FLASHON
		CAF	ONE
		TS	DECBRNCH	; set for dec
		TC	ENTEXIT


;--------------------------------------------------------------------------
; VBRQEXEC -- REQUEST EXECUTIVE
;
; Enters request to EXEC for any address with any priority. It does ENDOFJOB
; after entering request. Display syst is released. It assumes NOUN 26 has been
; preloaded with:
; COMPONENT 1 -- priority (bits 10-14), bit1=0 for NOVAC, bit1=1 for FINDVAC
; COMPONENT 2 -- job CADR (14 bit; was 12 bit in Block II)
; COMPONENT 3 -- not used (was BBCON in Block II)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.360.
;--------------------------------------------------------------------------

VBRQEXEC	EQU	*
		CAF	BIT1
		MASK	DSPTEM1
		CCS	A
		TC	SETVAC		; if bit1=1, FINDVAC
		CAF	TCNOVAC		; if bit1=0, NOVAC

	; sets up to call NOVAC or FINDVAC thru MPAC as follows:
	; MPAC 		= TC NOVAC
	; MPAC+1	= job CADR
	; MPAC+2	= TC ENDOFJOB
	; MPAC+3	= temp store for job PRIO

REQEX1		EQU	*
		TS	MPAC		; TC NOVAC or TC FINDVAC into MPAC
		CS	BIT1
		MASK	DSPTEM1
		TS	MPAC+3		; PRIO into MPAC+3 as a temp (was +4)

REQUESTC	EQU	*
		TC	RELDSP
		CAF	ZERO		; was CA ENDINST in Block II
		AD	ENDINST
		TS	MPAC+2		; TC ENDOFJOB into MPAC+2 (was +3)

		CAF	ZERO		; set BBCON for Block II dropped
		AD	DSPTEM1+1	; job adres into MPAC+1
		TS	MPAC+1

		CAF	ZERO		; was CA MPAC+4 in Block II
		AD	MPAC+3		; PRIO in A
		INHINT
		TC	MPAC

SETVAC		EQU	*
		CAF	TCFINDVAC
		TC	REQEX1


;--------------------------------------------------------------------------
; VBRQWAIT -- REQUEST WAITLIST
;
; Enters request to WAITLIST for any address with any delay. It does ENDOFJOB
; after entering request. Display syst is released. It assumes NOUN 26 has been
; preloaded with:
; COMPONENT 1 -- delay (low bits)
; COMPONENT 2 -- task CADR (14 bit; was 12 bit in Block II)
; COMPONENT 3 -- not used (was BBCON in Block II)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.360.
;--------------------------------------------------------------------------

VBRQWAIT	EQU	*
		CAF	TCWAIT
		TS	MPAC		; TC WAITLIST into MPAC
		CAF	ZERO		; was CA DSPTEM1 in Block II
		AD	DSPTEM1		; time delay
ENDRQWT		TC	REQUESTC-1

	; REQUESTC will put task address in MPAC+1, TC ENDOFJOB in MPAC+2.
	; It will take the time delay out of MPAC+3 and leave it in A, INHINT
	; and TC MPAC.

