; AGC test (file:intdiv.asm)
;

		ORG	EXTENDER
		DS	%47777	; needed for EXTEND

	; ----------------------------------------------
	; eraseable memory
	; Integer division test values

		ORG	%100
dividnd		DS	+100
divisor		DS	+30

	; ----------------------------------------------
	; fixed memory
		ORG	GOPROG
		TC	chkDV

one		DS	%1	; in fixed memory

chkDV		EQU	*
		CAF	one
		EXTEND
		DV	divisor	; A = 1/divisor
		EXTEND
		MP	dividnd	; A = A * dividend
	
	; ----------------------------------------------

loop1		EQU	*
		TC	loop1
