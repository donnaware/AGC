; AGC test (file:dad.asm)
;
; Double precision add (from R-393, 3-23)

; Test values
;


		ORG	EXTENDER
		DS	%47777	; needed for EXTEND

		ORG	%100

	; multiple precision accumulator
mpac		EQU	*
		DS	0	; msbs
		DS	1	; lsbs
		DS	0

	; 
addrwd		EQU	*
		DS	0	; msbs
		DS	1	; lsbs

	; ----------------------------------------------
		ORG	GOPROG
		TC	dad

zero		DS	0

	; add addrwd(n, n+1) to mpac(n, n+1)
dad		EQU	*
		XCH	mpac+1
		INDEX	addrwd
		AD	1
		TS	mpac+1
		CAF	zero

		AD	mpac
		INDEX	addrwd
		AD	0
		XCH	mpac
	
	; ----------------------------------------------

loop1		EQU	*
		TC	loop1

