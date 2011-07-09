;==========================================================================
; DISPLAY ROUTINES (file:bank41_8.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 379-380.
;==========================================================================


VBTSTLTS	EQU	*
		INHINT

	; heavily modified from the original Block II code...

		CS	DSALMOUT	; turn on lights
		MASK	TSTCON1		; inclusive OR light bits with 1's using
		COM			; Demorgan's theorem
		TS	DSALMOUT

		CAF	TEN

TSTLTS1		TS	ERCNT
		CS	FULLDSP
		INDEX	ERCNT
		TS	DSPTAB

		CCS	ERCNT
		TC	TSTLTS1
		CS	FULLDSP1
		TS	DSPTAB+1	; turn on 3 plus signs
		TS	DSPTAB+4
		TS	DSPTAB+6

		CAF	ELEVEN
		TS	NOUT

		TC	FLASHON

		CAF	SHOLTS
		TC	WAITLIST
		CADR	TSTLTS2

		TC	ENDOFJOB	; DSPLOCK is left busy (from keyboard
					; action) until TSTLTS3 to ensure that
					; lights test will be seen.


FULLDSP		DS	%05675		; display all 8's
FULLDSP1	DS	%07675		; display all 8's and +

	; 1's Comp of UPTEL=bit3, KEY REL=bit5, oper err=bit7, PROG ALM=bit 9

TSTCON1		DS	%77253		

SHOLTS		DS	%764		; 5 sec

TSTLTS2		EQU	*
		CAF	CHRPRIO		; called by WAITLIST
		TC	NOVAC
		CADR	TSTLTS3
		TC	TASKOVER

TSTLTS3		EQU	*
		INHINT
		CAF	TSTCON1		; turn off lights
		MASK	DSALMOUT
		TS	DSALMOUT

		RELINT

		TC	BANKCALL	; redisplay C(MODREG)
		CADR	DSPMM
		TC	KILMONON	; turn on kill monitor bit
		TC	FLASHOFF	; turn off V/N flash
		TC	POSTJUMP	; does RELDSP and goes to PINBRNCH if
		CADR	TSTLTS4		; ENDIDLE is awaiting operator response
