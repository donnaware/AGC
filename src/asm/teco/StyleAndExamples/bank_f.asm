;==========================================================================
; BANK INTERCOMMUNICATION (source code) memory segment (file:bank_f.asm)
;
; Version:	1.0
; Author:	John Pultorak
; Date:		01/19/2002
;
; PURPOSE:
; Contains bank intercommunication routines.
;
;==========================================================================

;--------------------------------------------------------------------------
; BANKCALL
; Do a bank jump to the location referenced by the 14-bit address referenced
; in Q. Does not affect register A (but assumes A does not contain an 
; overflow). Functionally identical to POSTJUMP.
; Usage:
;	TC	BANKCALL	; bank jump to CADR
;	DS	MYCADR		; the 14-bit address
; returns here.
; 
;
; This source is missing from my incomplete listing of COLOSSUS. The
; implementation here is inferred from the usage in the COLOSSUS DSKY
; routines.
;
; Inferred from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968.
;--------------------------------------------------------------------------

BANKCALL	EQU	*
		TS	BCA		; save A

		INDEX	Q		; load the CADR into A
		CAF	0
		TS	ADDRWD1		; save 14-bit destination address

		XCH	Q
		TS	BCRET		; save old return address-1

		XCH	BANK
		TS	BCBANK		; save old bank

		CS	ADDRWD1		; -(14bitAddr)+%6000
		AD	bankAddr
		CCS	A		; CADR is bank addressed?
		TC	DOBANKCALL	; >0 no, just run it, as is
		TC	*+2		; +0 yes
		TC	*+1		; <0 yes

		CAF	ZERO
		AD	ADDRWD1
		TS	BANK		; set the bank

		MASK	lowAddr		; get lowest 10-bits of address
		AD	bankAddr	; set bits 11,12 for fixed-switchable
		TS	ADDRWD1

DOBANKCALL	EQU	*
		XCH	BCA		; restore A
		INDEX	ADDRWD1		; apply indirect address to next instr.
		TC	0		; make the jump

	; Jump returns here; restore the old bank and return

		TS	BCA		; save A
		XCH	BCBANK
		TS	BANK

		XCH	BCRET
		AD	ONE		; skip CADR
		TS	Q

		XCH	BCA		; restore A
		RETURN


;--------------------------------------------------------------------------
; POSTJUMP
; Do a bank jump to the location referenced by the 14-bit address referenced
; in Q.  Does not affect register A (but assumes A does not contain an 
; overflow). Functionally identical to BANKCALL
; Usage:
;	TC	POSTJUMP	; bank jump to CADR
;	DS	MYCADR		; the 14-bit address
; returns here.
; 
;
; This source is missing from my incomplete listing of COLOSSUS. The
; implementation here is inferred from the usage in the COLOSSUS DSKY
; routines.
;
; Inferred from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968.
;--------------------------------------------------------------------------

POSTJUMP	EQU	*
		TS	PJA		; save A

		INDEX	Q		; load the CADR into A
		CAF	0
		TS	ADDRWD1		; save 14-bit destination address

		XCH	Q
		TS	PJRET		; save old return address-1

		XCH	BANK
		TS	PJBANK		; save old bank

		CS	ADDRWD1		; -(14bitAddr)+%6000
		AD	bankAddr
		CCS	A		; CADR is bank addressed?
		TC	DOPOSTJUMP	; >0 no, just run it, as is
		TC	*+2		; +0 yes
		TC	*+1		; <0 yes

		CAF	ZERO
		AD	ADDRWD1
		TS	BANK		; set the bank

		MASK	lowAddr		; get lowest 10-bits of address
		AD	bankAddr	; set bits 11,12 for fixed-switchable
		TS	ADDRWD1

DOPOSTJUMP	EQU	*
		XCH	PJA		; restore A
		INDEX	ADDRWD1		; apply indirect address to next instr.
		TC	0		; make the jump

	; Jump returns here; restore the old bank and return

		TS	PJA		; save A

		XCH	PJBANK
		TS	BANK

		XCH	PJRET
		AD	ONE		; skip CADR
		TS	Q

		XCH	PJA		; restore A
		RETURN


;--------------------------------------------------------------------------
; BANKJUMP
; Do a bank jump to the location referenced by the 14-bit address in A.
; Usage:
; CADRSTOR	DS	MYCADR
;
;		CAF	CADRSTOR	; load the 14-bit address
;		TC	BANKJUMP	; bank jump to CADR
; returns here.
;
; This source is missing from my incomplete listing of COLOSSUS. The
; implementation here is inferred from the usage in the COLOSSUS DSKY
; routines.
;
; Inferred from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968.
;--------------------------------------------------------------------------

BANKJUMP	EQU	*
		TS	ADDRWD1		; save 14-bit destination address

		XCH	Q
		TS	BJRET		; save old return address

		XCH	BANK
		TS	BJBANK		; save old bank

		CS	ADDRWD1		; -(14bitAddr)+%6000
		AD	bankAddr
		CCS	A		; CADR is bank addressed?
		TC	DOBANKJUMP	; >0 no, just run it, as is
		TC	*+2		; +0 yes
		TC	*+1		; <0 yes

		CAF	ZERO
		AD	ADDRWD1
		TS	BANK		; set the bank

		MASK	lowAddr		; get lowest 10-bits of address
		AD	bankAddr	; set bits 11,12 for fixed-switchable
		TS	ADDRWD1

DOBANKJUMP	EQU	*
		INDEX	ADDRWD1		; apply indirect address to next instr.
		TC	0		; make the jump

	; Jump returns here; restore the old bank and return

		XCH	BJBANK
		TS	BANK

		XCH	BJRET
		TS	Q
		RETURN

