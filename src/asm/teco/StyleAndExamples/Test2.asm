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
; ----------------------------------------------------------
	ORG	GOPROG

; Decrementing loop:
;	- always executes at least once (tests at end of loop)
;	- loops 'xstart' times; decrements xval

	XCH	xstart
	TS	xval

goback	EQU	*
	CCS	xval
	TC	inloop
	TC	done
inloop	EQU	*
	TS	xval

; do something useful (OK to change register A)
	XCH	REL00
	TS	OUT0		; was EXTEND/WRITE OUT0 in block II

	XCH	REL01
	TS	OUT0		; was EXTEND/WRITE OUT0 in block II

	XCH	REL02
	TS	OUT0		; was EXTEND/WRITE OUT0 in block II

	XCH	REL03
	TS	OUT0		; was EXTEND/WRITE OUT0 in block II

	XCH	REL04
	TS	OUT0		; was EXTEND/WRITE OUT0 in block II

	XCH	REL05
	TS	OUT0		; was EXTEND/WRITE OUT0 in block II

	XCH	REL06
	TS	OUT0		; was EXTEND/WRITE OUT0 in block II

	XCH	REL07
	TS	OUT0		; was EXTEND/WRITE OUT0 in block II

	XCH	REL08
	TS	OUT0		; was EXTEND/WRITE OUT0 in block II

	XCH	REL09
	TS	OUT0		; was EXTEND/WRITE OUT0 in block II



	TC	goback
; ----------------------------------------------

done	EQU	*
	TC	done

xstart	DS	5	; somewhere in fixed memory

;                      1 1111 1 00000 00000
;                      5 4321 0 98765 43210
;                      - ---- - ----- -----
REL00	DS	$0AB5   ; 0 0001 0 10101 10101    10   
REL01	DS	$12A3   ; 0 0010 0 10101 00011     1
REL02	DS	$1AB9   ; 0 0011 0 10101 11001    12
REL03	DS	$22BB   ; 0 0100 0 10101 11011    13
REL04	DS	$2AAF   ; 0 0101 0 10101 01111     7
REL05	DS	$32BE   ; 0 0110 0 10101 11110    15
REL06	DS	$3ABC   ; 0 0111 0 10101 11100    14
REL07	DS	$42B3   ; 0 1000 0 10101 10011     9
REL08	DS	$4ABD   ; 0 1001 0 10101 11101
REL09	DS	$52BF   ; 0 1010 0 10101 11111
REL0A	DS	$5AA0   ; 0 1011 0 10101 00000
REL0B	DS	$62A0   ; 0 1100 0 10101 00000



RELTAB0	DS	%04025  ; 0 0001 0 10101 10101    
RELTAB1	DS	%10003  ; 0 0010 0 10101 00011
RELTAB2	DS	%14031  ; 0 0011 0 10101 11001
RELTAB3	DS	%20033  ; 0 0100 0 10101 11011
RELTAB4	DS	%24017  ; 0 0101 0 10101 01111
RELTAB5	DS	%30036  ; 0 0110 0 10101 11110
RELTAB6	DS	%34034  ; 0 0111 0 10101 11100
RELTAB7	DS	%40023  ; 0 1000 0 10101 10011
RELTAB8	DS	%44035  ; 0 1001 0 10101 11101
RELTAB9	DS	%50037  ; 0 1010 0 10101 11111
RELTABA	DS	%54000  ; 0 1011 0 10101 00000
RELTABB	DS	%60000  ; 0 1100 0 10101 00000



; Bits   Bit     Bits   Bits 
; 15-12  11      10-6   5-1
; RLYWD  DSPC    DSPH   DSPL
; -----  ------  ----   -----
; 1011           MD1    MD2
; 1010   FLASH   VD1    VD2
; 1001           ND1    ND2
; 1000   UPACT          R1D1
; 0111   +R1S    R1D2   R1D3
; 0110   -R1S    R1D4   R1D5
; 0101   +R2S    R2D1   R2D2
; 0100   -R2S    R2D3   R2D4
; 0011           R2D5   R3D1
; 0010   +R3S    R3D2   R3D3
; 0001   -R3S    R3D4   R3D5

;Digit AGC 74LS47
;Blank 00000 1111
;0 10101 0000
;1 00011 0001
;2 11001 0010
;3 11011 0011
;4 01111 0100
;5 11110 0101
;6 11100 0110
;7 10011 0111
;8 11101 1000
;9 11111 1001


