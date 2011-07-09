; AGC Programming Style example (file:loop2.asm)
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

	ORG	EXTENDER
	DS	%47777	; needed for EXTEND

	ORG	%100
xval	DS	0	; somewhere in eraseable memory
; ----------------------------------------------
	ORG	GOPROG

; Decrementing loop:
;	- always executes at least once (tests at end of loop)
	- loops 'xstart' times; decrements xval

	XCH	xstart
	TS	xval

goback	EQU	*
	CCS	xval
	TC	inloop
	TC	done
inloop	EQU	*
	TS	xval
	; do something useful (OK to change register A)
	TC	goback
; ----------------------------------------------

done	EQU	*
	TC	done

xstart	DS	5	; somewhere in fixed memory
