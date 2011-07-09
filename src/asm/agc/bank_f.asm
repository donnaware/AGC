;==========================================================================
; BANK INTERCOMMUNICATION (file:bank_f.asm)
;
; Version:  1.0
; Author:   John Pultorak
; Date:     01/19/2002
;
; PURPOSE:
; Contains bank intercommunication routines.
; The source is missing from my (incomplete) listing of COLOSSUS. The
; implementation here is inferred from the usage in the COLOSSUS pinball
; routines. Some of these routines could probably be combined or optimized
; away if I understood the pinball software architecture a little better.
;==========================================================================

;--------------------------------------------------------------------------
; DXCHJUMP
; Do a bank jump to the CADR in register A. After the bank jump, the return
; CADR is in register A. Contents of register Q are destroyed.
; This is my attempt to implement the block I equivalent for
;	DCA	MY2CADR
;	DXCH	Z
;... which is used in some places in COLOSSUS to implement bank jumps. In that
; implementation, MY2CADR has the lower portion of the address in MYCADR and
; the bank portion in MY2CADR+1. DCA loads the lower address into A and the
; bank address into L. DXCH loads the lower address into Z and the bank portion
; into BB (both bank register), thereby doing a bank call. After the call,
; the lower return address is in A and the return bank is in L.
;--------------------------------------------------------------------------

DXCHJUMP	EQU	*
		TS	ADDRWD1		; save 14-bit destination address

		XCH	Q
		TS	DCRET		; save old return address

		XCH	BANK
		TS	DCBANK		; save old bank

	; put the 12-bit destination address in ADDRWD1

		CS	ADDRWD1		; -(14bitAddr)+%6000
		AD	bankAddr
		CCS	A		; CADR is bank addressed?
		TC	DODXCHCALL	; >0 no, just run it, as is
		TC	*+2		; +0 yes
		TC	*+1		; <0 yes

		CAF	ZERO
		AD	ADDRWD1
		TS	BANK		; set the bank

		MASK	lowAddr		; get lowest 10-bits of address
		AD	bankAddr	; set bits 11,12 for fixed-switchable
		TS	ADDRWD1		; save 12-bit destination address

	; put the 14-bit return CADR into A.

DODXCHCALL	EQU	*
		CS	DCRET		; get 12-bit return address	
		AD	bankAddr	; -(12bitAddr)+%6000
		CCS	A		; return address is bank addressed?
		TC	DC_NOTBANK	; >0 no, just use it, as is
		TC	*+2		; +0 yes
		TC	*+1		; <0 yes

		CS	bankAddr	; 12bitAddr - %6000
		AD	DCRET	
		AD	DCBANK		; put return CADR in A
		TC	*+3

DC_NOTBANK	EQU	*
		CAF	ZERO
		AD	DCRET		; put return CADR in A

		INDEX	ADDRWD1		; apply indirect address to next instr.
		TC	0		; make the jump


;--------------------------------------------------------------------------
; BANKCALL
; Do a bank jump to the location referenced by the 14-bit address referenced
; in Q. Does not affect register A (but assumes A does not contain an 
; overflow). Functionally identical to POSTJUMP.
; Usage:
;	TC	BANKCALL	; bank jump to CADR
;	DS	MYCADR		; the 14-bit address
; returns here if MYCADR calls TC Q.
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
; MYBANKCALL
; Functionally identical to BANKCALL. Used for converting the FLASHON/FLASHOFF
; COLOSSUS block II code to block I. In Block II, the V/N flash is controlled by
; setting a bit in an I/O channel. In Block I, a bit in the display table must
; be set using _11DSPIN. Because _11DSPIN is in fixed/switchable memory, but is
; called from fixed/fixed, a bank call function is needed. The original BANKCALL
; could not be used because it is not reentrant and I dont understand its usage 
; in COLOSSUS well enough to be certain  that FLASHON/FLASHOFF isn't already 
; being called somewhere through  BANKCALL.
;--------------------------------------------------------------------------

MYBANKCALL	EQU	*
		TS	MBCA		; save A

		INDEX	Q		; load the CADR into A
		CAF	0
		TS	ADDRWD1		; save 14-bit destination address

		XCH	Q
		AD	ONE		; skip CADR
		TS	MBCRET		; save old return address

		XCH	BANK
		TS	MBCBANK		; save old bank

		CAF	ZERO
		AD	ADDRWD1
		TS	BANK		; set the bank

		MASK	lowAddr		; get lowest 10-bits of address
		AD	bankAddr	; set bits 11,12 for fixed-switchable
		TS	ADDRWD1

		XCH	MBCA		; restore A
		INDEX	ADDRWD1		; apply indirect address to next instr.
		TC	0		; make the jump

	; Jump returns here; restore the old bank and return

		TS	MBCA		; save A
		XCH	MBCBANK
		TS	BANK

		XCH	MBCA		; restore A
		TC	MBCRET


;--------------------------------------------------------------------------
; POSTJUMP
; Do a bank jump to the location referenced by the 14-bit address referenced
; in Q.  Does not affect register A (but assumes A does not contain an 
; overflow). Functionally identical to BANKCALL
; Usage:
;	TC	POSTJUMP	; bank jump to CADR
;	DS	MYCADR		; the 14-bit address
; returns here if MYCADR calls TC Q.
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
; returns here if MYCADR calls TC Q
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


;--------------------------------------------------------------------------
; DATACALL
; Retrieve memory contents at location referenced by the 14-bit address in A.
; Usage:
; CADRSTOR	DS	MYCADR
;
;		CAF	CADRSTOR	; load the 14-bit address
;		TC	DATACALL	; return data in A
;
; Inferred from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968.
;--------------------------------------------------------------------------

DATACALL	EQU	*
		TS	ADDRWD1		; save 14-bit address

		XCH	Q
		TS	BJRET		; save old return address

		XCH	BANK
		TS	BJBANK		; save old bank

		CS	ADDRWD1		; -(14bitAddr)+%6000
		AD	bankAddr
		CCS	A		; CADR is bank addressed?
		TC	DODATACALL	; >0 no, just use it, as is
		TC	*+2		; +0 yes
		TC	*+1		; <0 yes

		CAF	ZERO
		AD	ADDRWD1
		TS	BANK		; set the bank

		MASK	lowAddr		; get lowest 10-bits of address
		AD	bankAddr	; set bits 11,12 for fixed-switchable
		TS	ADDRWD1

DODATACALL	EQU	*
		CAF	ZERO
		INDEX	ADDRWD1		; apply indirect address to next instr.
		AD	0		; load the word

		XCH	BJBANK		; restore the old bank
		TS	BANK

		XCH	BJBANK		; get the word
		TC	BJRET		; return



