;==========================================================================
; DISPLAY ROUTINES (file:bank42_1.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 333-336.
;==========================================================================

;--------------------------------------------------------------------------
; HMSOUT -- OUTPUT SCALE FACTOR ROUTINE
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.333.
;--------------------------------------------------------------------------

HMSOUT		EQU	*
		TC	BANKCALL	; read fresh data for HI and LO into MPAC,
		DS	READLO		; MPAC+1.

		TC	TPAGREE		; make DP data agree
		TC	SEPSECNR	; leave frac sec/60 in MPAC, MPAC+1, leave
					; whole min in bit13 of LOWTEMOUT and above
		TC	DMP		; use only fract sec/60 mod 60
		ADRES	SECON2		; mult by .06

		CAF	R3D1		; gives CENT1-SEC/10EXP5 mod 60
		TS	DSPCOUNT

		TC	BANKCALL	; display sec mod 60
		DS	DSPDECWD

		TC	SEPMIN		; remove rest of seconds
		CAF	MINCON2		; leave fract min/60 in MPAC+1, leave
		XCH	MPAC		; whole hours in MPAC
		TS	HITEMOUT	; save whole hours
		CAF	MINCON2+1
		XCH	MPAC+1		; use only fract min/60 mod 60
		TC	PRSHRTMP	; if C(A) = -0, SHORTMP fails to give -0.
					; mult by .0006
		CAF	R2D1		; gives min/10EXP5 mod 60
		TS	DSPCOUNT

		TC	BANKCALL	; display min mod 60
		DS	DSPDECWD


		CAF	HRCON1		; was DCA HRCON1, DXCH MPAC in Block II
		TS	MPAC
		CAF	HRCON1+1
		TS	MPAC+1		; minutes, seconds have been removed
		
		CAF	ZERO		; was CA HITEMOUT in Block II
		AD	HITEMOUT	; use whole hours
		TC	PRSHRTMP	; if C(A) = -0, SHORTMP fails to give -0.
					; mult by .16384
		CAF	R1D1		; gives hours/10EXP5
		TS	DSPCOUNT

		TC	BANKCALL	; use regular DSPDECWD, with round off
		DS	DSPDECWD

		TC	ENTEXIT

SECON1		DS	%25660		; 2EXP12/6000
		DS	%31742

SECON2		DS	%01727		; .06 for seconds display
		DS	%01217

MINCON2		DS	%00011		; .0006 for minutes display
		DS	%32445

MINCON1		DS	%02104		; .066..66 upped by 2EXP-28
		DS	%10422

HRCON1		DS	%05174		; .16384 decimal
		DS	%13261


	; ************* missing stuff ****************

SEPSECNR	EQU	*
		XCH	Q		; this entry avoid rounding by .5 secs
		TS	SEPSCRET

		TC	DMP		; mult by 2EXP12/6000
		ADRES	SECON1		; gives fract sec/60 in bit12 of MPAC+1

		CAF	ZERO		; was DCA MPAC, DXCH HITEMOUT in Block II
		AD	MPAC		; save minutes and hours
		XCH	HITEMOUT

		CAF	ZERO
		AD	MPAC+1
		XCH	HITEMOUT+1

		TC	TPSL1
		TC	TPSL1		; gives fract sec/60 in MPAC+1, MPAC+2
	
		CAF	ZERO
		XCH	MPAC+2		; leave fract sec/60 in MPAC, MPAC+1
		XCH	MPAC+1
		XCH	MPAC

		TC	SEPSCRET


SEPMIN		EQU	*
		XCH	Q		; finds whole minutes in bit13
		TS	SEPMNRET	; of LOWTEMOUT and above.

		CAF	ZERO
		AD	LOTEMOUT	; removes rest of seconds

		EXTEND			; leaves fract min/60 in MPAC+1
		MP	BIT3		; leaves whole hours in MPAC
		EXTEND			; SR 12, throw away LP
		MP	BIT13		; SR 2?, take from LP. = SL 12

		XCH	LP		; was LXCH MPAC+1 in Block II
		TS	MPAC+1		; this forces bits 12-1 to 0 if +,
					; forces bits 12-1 to 1 if -.

		CAF	ZERO
		AD	HITEMOUT
		TS	MPAC

		TC	DMP		; mult by 1/15
		ADRES	MINCON1		; gives fract min/60 in MPAC+1
ENDSPMIN	TC	SEPMNRET	; gives whole hours in MPAC


		
