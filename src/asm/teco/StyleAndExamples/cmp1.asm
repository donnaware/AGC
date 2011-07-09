; AGC Programming Style example (file:cmp1.asm)
;
; Test Results:
;	A = value of register A after CCS (the diminished absolute value)
;	loop = branch taken
;
;       val1    val2    A       loop
;       ----    ----    -       ----
;        0       0      0       loop4 (L+4)
;        0      -0      0       loop4 (L+4)
;       -0       0      0       loop2 (L+2)
;       -0      -0      0       loop4 (L+4)     -0 is %77777 octal

;        5       5      0       loop4 (L+4)
;       -5      -5      0       loop4 (L+4)     -5 is %77772 octal
;	 1       2	0	loop1 (L+1)
;        2       4	1	loop1 (L+1)
;        4       2	1	loop3 (L+3)
;        2       1      0       loop3 (L+3)

	ORG	EXTENDER
	DS	%47777	; needed for EXTEND

	ORG	%100
val1	DS	-0
val2	DS	0
; ----------------------------------------------
	ORG	GOPROG
	
; Compare val1 and val2; values may be in fixed or eraseable memory;
;	- does not change contents of memory;
;	- modifies contents of A
	CS	val1
	AD	val2	; put (-val1) + val2 in A
	CCS	A
	TC	loop1	; >0
	TC	loop2	; +0
	TC	loop3	; <0
	TC	loop4	; -0

	; ----------------------------------------------

	ORG	%2100
loop1	EQU	*
	TC	loop1

	ORG	%2200
loop2	EQU	*
	TC	loop2

	ORG	%2300
loop3	EQU	*
	TC	loop3

	ORG	%2400
loop4	EQU	*
	TC	loop4
