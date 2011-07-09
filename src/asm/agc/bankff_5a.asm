;==========================================================================
; DISPLAY ROUTINES (file:bankff_5a.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 376-378.
;==========================================================================

;--------------------------------------------------------------------------
; MISCELLANEOUS SERVICE ROUTINES IN FIXED-FIXED
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.376.
;--------------------------------------------------------------------------

; RELDSP
; used by VBPROC, VBTERM, VBRQEXEC, VBRQWAIT, VBRELDSP, EXTENDED VERB
; DISPATCHER, VBRESEQ, and RECALTST.

; RELDSP1
; used by monitor set up, VBRELDSP

RELDSP		EQU	*
		XCH	Q		; set DSPLOCK to +0, turn RELDSP light
		TS	RELRET		; off, search DSPLIST
		CS	BIT14
		INHINT
		MASK	MONSAVE1
		TS	MONSAVE1	; turn off external monitor bit
		CCS	DSPLIST
		TC	*+2
		TC	RELDSP2		; list empty
		CAF	ZERO
		XCH	DSPLIST
		TC	JOBWAKE

RELDSP2		EQU	*
		RELINT
		CS	BIT5		; turn off KEY RLSE light
		MASK	DSALMOUT	; was WAND DSALMOUT in Block II
		TS	DSALMOUT

		CAF	ZERO
		TS	DSPLOCK
		TC	RELRET

RELDSP1		EQU	*
		XCH	Q		; set DSPLOCK to +0, No DSPLIST search
		TS	RELRET		; turn KEY RLSE light off if DSPLIST is
					; empty. Leave KEY RLSE light alone if
					; DSPLIST is not empty.
		CCS	DSPLIST
		TC	*+2		; + not empty, leave KEY RLSE light alone
		TC	RELDSP2		; +0, list empty, turn off KEY RLSE light
		CAF	ZERO		; - not empty, leave KEY RLSE light alone
		TS	DSPLOCK
		TC	RELRET


;--------------------------------------------------------------------------
; NEWMODEA
;
; The new major mode is in register A. Store the major mode in MODREG and update
; the major mode display.
;
; I couldn't find this in my COLOSSUS listing, so I borrowed it from UPDATVB-1
; (but modified it to work with the major mode instead of the verb).
;--------------------------------------------------------------------------

NEWMODEA	EQU	*
		TS	MODREG		; store new major mode
		XCH	Q
		TS	NEWMODEA_Q	; save Q

		CAF	MD1
		TS	DSPCOUNT
		
		CAF	ZERO
		AD	MODREG

		TC	BANKCALL
		CADR	DSPDECVN

		TC	NEWMODEA_Q	; return

;-------------------------------------------------------------------------
; POODOO - Program alarm.
;
; Turn on program alarm light and store alarm code in FAILREG. The alarm code 
; is retrieved from the address pointed to by Q. The most recent code is stored 
; in FAILREG. Older codes are scrolled to FAILREG+1,+2. Older CADRs are 
; scrolled down.
;
; This was missing from my COLOSSUS listing, so I had to guess at the 
; implementation, based upon calling references in COLOSSUS, and textual
; descriptions of normal noun 9 which retrieves alarm codes.
;-------------------------------------------------------------------------


POODOO		EQU	*
		XCH	Q
		TS	MPAC
		CS	DSALMOUT	; inclusive OR bit 9 with 1 using
		MASK	NOTPALT		; Demorgan's theorem
		COM
		TS	DSALMOUT	; turn on PROG ALM light
		XCH	FAILREG+1	; scroll previous codes down
		TS	FAILREG+2
		XCH	FAILREG
		TS	FAILREG+1
		INDEX	MPAC		; indirectly address Q
		CAF	0		; (gets alarm code)
		TS	FAILREG		; store alarm code
		TC	ENDOFJOB

NOTPALT		DS	%77377		; 1's compliment of bit9 (PROG ALM)



;-------------------------------------------------------------------------
; PINBRNCH
;
; This is supposed to restore the DSKY display to its former state in the 
; event of error. According to COLOSSUS, it works if you use "Margaret's" 
; code. I don't have that portion of the listing, so I just terminate
; the job, which seems to be an acceptable work-around, even though the
; old display is not restored.
;-------------------------------------------------------------------------

PINBRNCH	TC	ENDOFJOB

		