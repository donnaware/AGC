;-------------------------------------------------------------------------
; AGC Programming Style example (file:loop1.asm)
;
; Test Results:
;
;	xval	A	(A=after CCS)
;	----	-
;	5	4
;	4	3
;	3	2
;	2	1
;	1	0
;	0	0
;-------------------------------------------------------------------------

	ORG	EXTENDER
	DS	%47777	; needed for EXTEND

	ORG     %100
TEMP1	DS	0

;-------------------------------------------------------------------------
	ORG	GOPROG

;-------------------------------------------------------------------------
; Decrementing loop:
;	- always executes at least once (tests at end of loop)
;	- loops 'xstart' times; decrements xval
;-------------------------------------------------------------------------

	XCH	xstart
goback	EQU	*
	TS	TEMP1
	
	; do something useful (OK to change register A)

	TS	OUT0		; was EXTEND/WRITE OUT0 in block II

	CCS	TEMP1


	TC	goback

;-------------------------------------------------------------------------

loop1	EQU	*
	TC	loop1

xstart	DS	5	; somewhere in fixed memory

;-------------------------------------------------------------------------

