;==========================================================================
; DISPLAY ROUTINES (file:bankff_5.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 372-376.
;==========================================================================

;--------------------------------------------------------------------------
; MISCELLANEOUS SERVICE ROUTINES IN FIXED-FIXED
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.372.
;--------------------------------------------------------------------------

; SETNCADR
; Store the eraseable memory address from A into NOUNCADR and NOUNADD.
; (changed from Block II, because there is no bank addressing for block I)

; SETNADD
; Get the eraseable memory address from NOUNCADR and store it into NOUNADD.
; (changed from Block II, because there is no bank addressing for block I)
;
; SETEBANK
; E CADR arrives in A. E ADRES is "derived" and left in A.
; (changed from Block II, because there is no bank addressing for block I)

SETNCADR	EQU	*
		XCH	Q
		TS	SETNCADR_Q	; save return address
		XCH	Q		; restore A

		TS	NOUNCADR	; store ECADR
		MASK	LOW10
		TS	NOUNADD		; put E ADRES into NOUNADD
		TC	SETNCADR_Q

SETNADD		EQU	*
		XCH	Q
		TS	SETNCADR_Q	; save return address
		XCH	Q		; restore A

		CAF	ZERO
		AD	NOUNCADR	; get NOUNCADR
		TC	SETNCADR+4

SETEBANK	EQU	*
		MASK	LOW10
		TC	Q



R1D1		DS	%16		; these 3 constants form a packed table
R2D1		DS	%11		; don't separate
R3D1		DS	%4		; must stay here

RIGHT5		EQU	*
		TS	CYR
		CS	CYR
		CS	CYR
		CS	CYR
		CS	CYR
		XCH	CYR
		TC	Q

LEFT5		EQU	*
		TS	CYL
		CS	CYL
		CS	CYL
		CS	CYL
		CS	CYL
		XCH	CYL
		TC	Q

SLEFT5		EQU	*
		DOUBLE
		DOUBLE
		DOUBLE
		DOUBLE
		DOUBLE
		TC	Q

LOW5		DS	%00037		; these 3 constants form a packed table
MID5		DS	%01740		; don't separate
HI5		DS	%76000		; must stay here

TCNOVAC		TC	NOVAC
TCWAIT		TC	WAITLIST
;TCTSKOVR	TC	TASKOVER
TCFINDVAC	TC	FINDVAC

;CHRPRIO	DS	%30000		; EXEC priority of CHARIN
LOW11		DS	%3777
B12M1		EQU	LOW11
LOW8		DS	%377
LOW10		DS	%01777

VD1		DS	%23		; these 3 constants form a packed table
ND1		DS	%21		; don't separate
MD1		DS	%25		; must stay here

BINCON		DS	10

;**************** TURN ON/OFF OPERATOR ERROR LIGHT ******* p. 373

DSALMOUT	EQU	OUT1		; channel 11 in Block II is OUT1 in Block I

FALTON		EQU	*
		CS	DSALMOUT	; inclusive OR bit 7 with 1 using
		MASK	FALTOR		; Demorgan's theorem
		COM
		TS	DSALMOUT	; was bit 7 of channel 11 in Block II
		TC	Q

FALTOF		EQU	*
		CS	BIT7
		MASK	DSALMOUT
		TS	DSALMOUT	; was bit 7 of channel 11 in Block II
		TC	Q

FALTOR		DS	%77677		; 1's compliment of bit 7


;**************** TURN ON KEY RELEASE LIGHT ******* p. 373

RELDSPON	EQU	*
		CS	DSALMOUT	; inclusive OR bit 5 with 1 using
		MASK	RELDSPOR	; Demorgan's theorem
		COM
		TS	DSALMOUT	; was bit 5 of channel 11 in Block II
		TC	Q

RELDSPOR	DS	%77757		; 1's compliment of bit 5


; TPSL1
; Shift triple word MPAC, MPAC+1, MPAC+2 left 1 bit

TPSL1		EQU	*
		CAF	ZERO
		AD	MPAC+2
		AD	MPAC+2
		TS	MPAC+2		; skip on overflow

		CAF	ZERO		; otherwise, make interword carry=0
		AD	MPAC+1
		AD	MPAC+1
		TS	MPAC+1		; skip on overflow

		CAF	ZERO		; otherwise, make interword carry=0
		AD	MPAC
		AD	MPAC
		TS	MPAC		; skip on overflow

		TC	Q		; no net OV/UF
		TS	MPAC+6		; MPAC+6 set to +/- 1 for OV/UF
		TC	Q


; PRSHRTMP
; if MPAC, +1 are each +NZ or +0 and C(A)=-0, SHORTMP wrongly gives +0.
; if MPAC, +1 are each -NZ or -0 and C(A)=+0, SHORTMP wrongly gives +0.
; PRSHRTMP fixes first case only, by merely testing C(A) and if it = -0,
; setting result to -0.
; (Do not use PRSHRTMP unless MPAC, +1 are each +NZ or +0, as they are
; when they contain the SF constants).

PRSHRTMP	EQU	*
		TS	MPTEMP
		XCH	Q
		TS	PRSHRTMP_Q

		CCS	MPTEMP
		TC	DOSHRTMP	; C(A) +, do regular SHORTMP
		TC	DOSHRTMP	; C(A) +0, do regular SHORTMP
		TC	DOSHRTMP	; C(A) -, do regular SHORTMP
		CS	ZERO		; C(A) -0, force result to -0 and return
		TS	MPAC
		TS	MPAC+1
		TS	MPAC+2
		TC	PRSHRTMP_Q

DOSHRTMP	EQU	*
		CAF	ZERO
		AD	MPTEMP
		TC	SHORTMP
		TC	PRSHRTMP_Q




;**************** TURN ON/OFF V/N FLASH ******* p. 374
; this is handled by setting a bit in channel 11 in Block II.
; In Block I, it has to be set through the display table, so I 
; borrowed this method from SGNCOM (the DSKY +/- sign routine)
; Uses MYBANKCALL because BANKCALL is not reentrant and I dont
; understand its usage in COLOSSUS well enough to be certain 
; that FLASHON/FLASHOFF isn't being called somewhere through 
; BANKCALL.

FLASHON		EQU	*
		XCH	Q
		TS	FLASHRET

		CAF	BIT11
		TS	CODE
		CAF	FLSHTAB
		TC	MYBANKCALL
		CADR	_11DSPIN

		TC	FLASHRET

FLASHOFF	EQU	*
		XCH	Q
		TS	FLASHRET

		CAF	ZERO
		TS	CODE
		CAF	FLSHTAB
		TC	MYBANKCALL
		CADR	_11DSPIN

		TC	FLASHRET

FLSHTAB		DS	%11		; V/N flash




NVSUBUSY	EQU	*
		TC	POSTJUMP
		CADR	NVSUBSY1



		