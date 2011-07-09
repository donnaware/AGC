;==========================================================================
; MATH LIBRARY (file:math_f.asm)
;
; Version:  1.0
; Author:   John Pultorak
; Date:     03/01/2002
;
; PURPOSE:
; Contains double precision math routines.
;==========================================================================

;--------------------------------------------------------------------------
; TPAGREE
; Force the signs in a triple precision (TP) word to agree. The word is
; in MPAC, MPAC+1, MPAC+2
;
; The sign of the corrected number is always the sign of the most-significant
; non-zero word.
;
; This isn't included in my partial COLOSSUS listing, so I had to invent
; my own version.
;--------------------------------------------------------------------------


TPAGREE		EQU	*
		XCH	Q
		TS	MATH_Q		; return address

	; Find the sign to convert to. It will be the sign
	; of the most significant non-zero word.

TPA_SGN0	EQU	*
		CCS	MPAC
		TC	TPA_P0		; >0, sign will be +
		TC	TPA_SGN1	; +0, still don't know sign, check MPAC+1
		TC	TPA_M0		; <0, sign will be -
		TC	TPA_SGN1	; -0, still don't know sign, check MPAC+1


	; MPAC is non-zero positive, so reconcile signs to a positive number.

TPA_P0		EQU	*
		CCS	MPAC+1
		TC	TPA_P1+2	; >0, MPAC+1 is OK, check MPAC+2
		TC	TPA_PZ0		; +0, 
		TC	*+2		; <0, fix MPAC+1
		TC	TPA_PZ0		; -0, 

		CAF	TPA_MPAC0	; borrow from MPAC to correct MPAC+1
		TC	TPA_FIXP
		TC	TPA_P1+2	; MPAC+1 is now non-zero positive; check MPAC+2

	; MPAC is non-zero positive, MPAC+1 is zero

TPA_PZ0		EQU	*
		CCS	MPAC+2
		TC	*+5		; >0, zero MPAC+1, MPAC+2 is OK
		TC	*+2		; +0, MPAC+1, +2 both zero
		TC	TPA_PZ0FIX	; <0,

		CAF	ZERO		; make sure they're both +0
		TS	MPAC+2
		CAF	ZERO
		TS	MPAC+1
		TC	MATH_Q

	; MPAC is non-zero positive, MPAC+1 is zero, MPAC+2 is non-zero negative.
	; Solution: borrow from MPAC, transfer borrowed value to MPAC+1, but also
	; borrow from MPAC+1, use borrowed value to correct MPAC+2.

TPA_PZ0FIX	EQU	*
		XCH	MPAC+2		; move MPAC+2 to MPAC+1 so we can use
		TS	MPAC+1		; our standard correction function

		CAF	TPA_MPAC0	; borrow from MPAC to correct MPAC+1
		TC	TPA_FIXP

		CAF	MAXPOS		; move corrected value from MPAC+1 back
		XCH	MPAC+1		; to MPAC+2. Set MPAC+1 to correct value
		TS	MPAC+2		; borrowed from MPAC.
		TC	MATH_Q


	; The MPAC is non-zero negative, so reconcile signs to a negative number.

TPA_M0		EQU	*
		CCS	MPAC+1
		TC	*+4		; >0, fix MPAC+1
		TC	TPA_MZ0		; +0, 
		TC	TPA_M1+2	; <0, MPAC+1 is OK, check MPAC+2
		TC	TPA_MZ0		; -0, 

		CAF	TPA_MPAC0	; borrow from MPAC to correct MPAC+1
		TC	TPA_FIXM
		TC	TPA_M1+2

	; MPAC is non-zero negative, MPAC+1 is zero

TPA_MZ0		EQU	*
		CCS	MPAC+2
		TC	TPA_MZ0FIX	; >0, 
		TC	*+2		; +0, MPAC+1, +2 both zero
		TC	*+3		; <0, zero MPAC+1, MPAC+2 is OK

		CAF	NEG0		; make sure they're both -0
		TS	MPAC+2
		CAF	NEG0
		TS	MPAC+1
		TC	MATH_Q

	; MPAC is non-zero negative, MPAC+1 is zero, MPAC+2 is non-zero positive
	; Solution: borrow from MPAC, transfer borrowed value to MPAC+1, but also
	; borrow from MPAC+1, use borrowed value to correct MPAC+2.

TPA_MZ0FIX	EQU	*
		XCH	MPAC+2		; move MPAC+2 to MPAC+1 so we can use
		TS	MPAC+1		; our standard correction function

		CAF	TPA_MPAC0	; borrow from MPAC to correct MPAC+1
		TC	TPA_FIXM

		CAF	MAXNEG		; move corrected value from MPAC+1 back
		XCH	MPAC+1		; to MPAC+2. Set MPAC+1 to correct value
		TS	MPAC+2		; borrowed from MPAC.
		TC	MATH_Q


	; MPAC was zero, so we still don't know the sign. Check MPAC+1.

TPA_SGN1	EQU	*
		CCS	MPAC+1
		TC	TPA_P1		; >0, sign will be +
		TC	TPA_SGN2	; +0, still don't know sign, check MPAC+2
		TC	TPA_M1		; <0, sign will be -
		TC	TPA_SGN2	; -0, still don't know sign, check MPAC+2

	; MPAC+1 is non-zero positive, so reconcile signs to a positive number.

TPA_P1		EQU	*
		CAF	ZERO		
		TS	MPAC		; set MPAC to +0

		CCS	MPAC+2
		TC	MATH_Q		; >0, all words are positive
		TC	MATH_Q		; +0, all words are positive
		TC	*+4		; <0, MPAC+2 is nonzero -
		CAF	ZERO		; -0, change to +0 and we're done
		TS	MPAC+2
		TC	MATH_Q

		CAF	TPA_MPAC1	; borrow from MPAC+1 to correct MPAC+2
		TC	TPA_FIXP
		TC	MATH_Q

	; MPAC+1 is non-zero negative, so reconcile signs to a negative number.

TPA_M1		EQU	*
		CAF	NEG0		
		TS	MPAC		; set MPAC to -0

		CCS	MPAC+2
		TC	*+7		; >0, MPAC+2 is nonzero +
		TC	*+3		; +0, change to -0 and we're done
		TC	MATH_Q		; <0, all words are negative
		TC	MATH_Q		; -0, all words are negative

		CAF	NEG0		; +0, change to -0 and we're done
		TS	MPAC+2
		TC	MATH_Q

		CAF	TPA_MPAC1	; borrow from MPAC+1 to correct MPAC+2
		TC	TPA_FIXM
		TC	MATH_Q

	; MPAC and MPAC+1 were both zero, so we still don't know the sign. 
	; Check MPAC+2.

TPA_SGN2	EQU	*
		CCS	MPAC+2
		TC	TPA_P2		; >0, sign is +
		TC	TPA_P3		; +0, number is all zeros
		TC	TPA_M2		; <0, sign is -
		TC	TPA_P3		; -0, number is all zeros

TPA_P2		CAF	ZERO
		TC	*+5		; set MPAC, MPAC+1 to +0

TPA_M2		CAF	NEG0		; set MPAC, MPAC+1 to -0
		TC	*+3

TPA_P3		CAF	ZERO
		TS	MPAC+2		; set MPAC, MPAC+1, MPAC+2 to +0

		TS	MPAC+1
		TS	MPAC
		TC	MATH_Q	



MAXPOS		DS	%37777		; largest non-overflow pos number
MAXNEG		DS	%40000		; largest non-overflow neg number

TPA_MPAC0	DS	MPAC
TPA_MPAC1	DS	MPAC+1


;--------------------------------------------------------------------------
; TPA_FIXM
; Reconcile the signs in a double precision word. The most significant word
; is in C(A), the lesser word in C(A+1). Reconcilliation occurs by borrowing
; from C(A) and adding the borrowed amount to C(A+1). C(A) is assumed to be
; negative non-zero number and C(A+1) positive non-zero. The reconciliation
; makes both numbers negative.
;
; This is part of my implementation of TPAGREE.
;--------------------------------------------------------------------------

TPA_FIXM	EQU	*
		TS	ADDRWD1

		INDEX	ADDRWD1
		CS	0		; borrow from 1st word
		CCS	A
		COM
		INDEX	ADDRWD1
		TS	0

		CAF	MAXNEG
		AD	NEG1		; create negative overflow
		INDEX	ADDRWD1
		AD	1		; correct 2nd word, changes sign
		INDEX	ADDRWD1
		TS	1
		TC	Q


;--------------------------------------------------------------------------
; TPA_FIXP
; Reconcile the signs in a double precision word. The most significant word
; is in C(A), the lesser word in C(A+1). Reconcilliation occurs by borrowing
; from C(A) and adding the borrowed amount to C(A+1). C(A) is assumed to be
; positive non-zero number and C(A+1) negative non-zero. The reconciliation
; makes both numbers positive.
;
; This is part of my implementation of TPAGREE.
;--------------------------------------------------------------------------

TPA_FIXP	EQU	*
		TS	ADDRWD1

		INDEX	ADDRWD1
		CCS	0		; borrow from 1st word
		INDEX	ADDRWD1
		TS	0

		CAF	MAXPOS
		AD	ONE		; create positive overflow
		INDEX	ADDRWD1
		AD	1		; correct 2nd word, changes sign
		INDEX	ADDRWD1
		TS	1
		TC	Q


;--------------------------------------------------------------------------
; SHORTMP -- MULTIPLY DOUBLE WORD BY A SINGLE WORD
; Multiply C(MPAC, MPAC+1) by the contents of A. Put the product in MPAC,
; MPAC+1, MPAC+2.
;;
; These aren't included in my partial COLOSSUS listing, so I had to invent
; my own version.
;--------------------------------------------------------------------------

SHORTMP		EQU	*
		TS	SHORTMP_A

	; MPAC+2 = MPAC+1 * A

		EXTEND
		MP	MPAC+1
		TS	SHORTMP_OVFL
		XCH	LP
		TS	MPAC+2

	; MPAC+1 = (MPAC * A) + overflow

		XCH	SHORTMP_A
		EXTEND
		MP	MPAC
		TS	SHORTMP_OVFH
		XCH	LP
		AD	SHORTMP_OVFL
		TS	MPAC+1		; skip on overflow
		CAF	ZERO		; otherwise, make interword carry=0

	; MPAC = overflow

		AD	SHORTMP_OVFH
		TS	MPAC

		TC	Q		; return
		

;--------------------------------------------------------------------------
; DMP -- DOUBLE PRECISION MULTIPLY
; Multiply val, val+1 with C(MPAC, MPAC+1). 'ADDRWD1' contains the
; address of 'val'. The product appears in MPAC, MPAC+1, MPAC+2
;
; This isn't included in my partial COLOSSUS listing, but is taken from
; the double precision math examples in R-393.
;--------------------------------------------------------------------------

DMP		EQU	*
		INDEX	Q
		CAF	0
		AD	EXTENDER
		TS	ADDRWD1

		XCH	MPAC+1
		TS	OVCTR
		INDEX	ADDRWD1
		MP	1
		XCH	OVCTR

		INDEX	ADDRWD1
		MP	0
		XCH	OVCTR
		AD	LP
		XCH	MPAC
		TS	MPAC+2
		INDEX	ADDRWD1
		MP	1
		XCH	OVCTR
		XCH	MPAC	
		AD	LP
		XCH	MPAC+2

		INDEX	ADDRWD1
		MP	0
		XCH	OVCTR
		AD	MPAC
		AD	LP
		XCH	MPAC+1
		XCH	OVCTR
		TS	MPAC

		XCH	Q		; skip next word on return
		AD	ONE
		TS	Q
		TC	Q


