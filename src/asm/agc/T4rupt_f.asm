;==========================================================================
; T4RUPT (file:T4rupt_f.asm)
;
; Version:  1.0
; Author:   John Pultorak
; Date:     01/09/2002
;
; PURPOSE:
; Contains T4RUPT handler and DSPOUT subroutine to update DSKY.
;==========================================================================

; RELTAB is a packed table. RELAYWORD code in upper 4 bits, RELAY code
; in lower 5 bits. In COLOSSUS, p. 129.

RELTAB		EQU	*
		DS	%04025
		DS	%10003
		DS	%14031
		DS	%20033
		DS	%24017
		DS	%30036
		DS	%34034
		DS	%40023
		DS	%44035
		DS	%50037
		DS	%54000
RELTAB11	DS	%60000


;--------------------------------------------------------------------------
; DK_initDK - INITIALIZE DSKY
;
; Subroutine initializes the eraseable memory segment for DSKY displays.
; Blank DSKY registers program, verb, noun, R1, R2, R3.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, Fresh Start and Restart, p.187.
;--------------------------------------------------------------------------

DKTESTINIT	DS	%5265		; init DSKY to all zeroes (TEST ONLY)

DK_initDK	EQU	*
		XCH	Q
		TS	DK_IN_saveQ	; save return address

		CAF	TEN		; blank DSKY registers
DSPOFF		TS	MPAC	

		CS	BIT12
;		CS	DKTESTINIT	; set display to '0'

		INDEX	MPAC
		TS	DSPTAB
		CCS	MPAC
		TC	DSPOFF

	; followed by additional DSKY initialization p 187, 188)

		CAF	ZERO
		TS	DSPCNT
		TS	CADRSTOR
		TS	REQRET
		TS	CLPASS
		TS	DSPLOCK
		TS	MONSAVE		; kill monitor
		TS	MONSAVE1
		TS	VERBREG
		TS	NOUNREG
		TS	DSPLIST

		CAF	NOUTCON
		TS	NOUT

	; set DSKY display bit (sign bit). Word must be negative, but
	; not minus zero (find out where they do this in COLOSSUS)

		CS	ONE
		TS	FLAGWRD5

	; initialize DSPCNT (index into DSPTAB).

		CAF	ZERO
		AD	TABLNTH
		TS	DSPCNT

	; schedule 1st T4RUPT

		CAF	_120MRUPT	; reschedule interrupt for 120 mSec
		TS	TIME4

		XCH	DK_IN_saveQ
		TS	Q		; restore return address
		RETURN

;--------------------------------------------------------------------------
; T4PROG -- T4RUPT PROGRAM
;
; Performs T4RUPT (DSRUPT) functions. 
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.129.
;--------------------------------------------------------------------------

T4PROG		EQU	*
		XCH	Q
		TS	T4RET		; save return address

		TC	DSPOUT		; update DSKY display

		CAF	_120MRUPT	; reschedule interrupt for 120 mSec
		TS	TIME4

		XCH	T4RET
		TS	Q		; restore return address
		RETURN

;--------------------------------------------------------------------------
; DSPOUT -- PUTS OUT DISPLAYS
;
; Writes changes in the software display buffer to the AGC DSKY hardware
; display. 
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.131.
;--------------------------------------------------------------------------

DSPOUTSR	EQU	*
		TS	NOUT		; decrement NOUT

		CS	ZERO
		TS	DSRUPTEM	; set to -0 for 1st pass thru DSPTAB

		XCH	DSPCNT
		AD	NEG0		; to prevent +0
		TS	DSPCNT

DSPSCAN		EQU	*
		INDEX	DSPCNT
		CCS	DSPTAB		; test sign of DSPTAB + DSPCNT

		CCS	DSPCNT		; >0, already displayed, test DSPCNT
		TC	DSPSCAN-2	; if DSPCNT +, again
		TC	DSPLAY		; <0, not yet displayed

TABLNTH		DS	%12		; dec 10, length of DSPTAB
		CCS	DSRUPTEM	; if DSRUPTEM=+0, 2nd pass thru DSPTAB

_120MRUPT	DS	16372		; (DSPCNT=0), +0 into NOUT

		TS	NOUT		; DSRUPTEM=+0, every table entry was checked
		TC	DSPOUTEXIT	; return

		TS	DSRUPTEM	; DSRUPTEM=-0, 1st pass thru DSPTAB
		CAF	TABLNTH		; (DSPCNT=0), +0 into DSRUPTEM, pass again
		TC	DSPSCAN-1

		TC	DSPOUTEXIT	; return


DSPLAY		EQU	*
		AD	ONE
		INDEX	DSPCNT
		TS	DSPTAB		; replace positively
		MASK	LOW11		; remove bits 12 to 15
		TS	DSRUPTEM
		CAF	HI5
		INDEX	DSPCNT
		MASK	RELTAB		; pick up bits 12 to 15 of RELTAB entry
		AD	DSRUPTEM
		TS	OUT0		; was EXTEND/WRITE OUT0 in block II

		TC	DSPOUTEXIT	; return


DSPOUT		EQU	*
		XCH	Q
		TS	DSPOUTRET	; save return address

		CCS	FLAGWRD5	; no display unless DSKY flag (sign bit) on
		CAF	ZERO		; >0, DSKY disabled
		TC	NODSPOUT	; +0, DSKY disabled
		CCS	NOUT		; <0, DSKY enabled, so test NOUT
		TC	DSPOUTSR	; >0, handle display requests
		TC	NODSPOUT	; +0, no display requests

NODSPOUT	EQU	*
DSPOUTEXIT	EQU	*
		XCH	DSPOUTRET	; return to calling routine
		TS	Q
		RETURN

