; -------------------------------------------------------
; ovrfl (file:ovrfl.asm)
; -------------------------------------------------------
START		EQU	%00000		; Initial value
FAIL		EQU	%00007		; Overflow check failed
PASS		EQU	%12345		; Overflow PASSED check
OVFCNTR	EQU	%00034		; overflow counter

	; ----------------------------------------------
	; ERASEABLE MEMORY -- DATA SEGMENT
	; ----------------------------------------------
		ORG	%100	; start of data area
curtest	DS	START	; current test

	; ----------------------------------------------
	; MAIN PROGRAM ENTRY POINT:
	; ----------------------------------------------
		ORG	GOPROG		; Octal 02000
goMAIN		EQU	*		; program entry point
		INHINT			; disable interrupts
repeat		EQU	*		; program entry point
		TC	chkOVRFL 	; Test instructions.
done		EQU	*		; trap point
		TC	done		; finished, TC trap
;		TC	repeat		; finished, TC trap


	; ----------------------------------------------
	; TEST Overflow
	; L:	AD	K
	; Verifies the following:
	; - Set C(A) = b(A) + C(K)
	; - Take next instruction from L+1
	; - if C(A) has positive overflow,
	; -- increment overflow counter by 1
	; - if C(A) has negative overflow,
	; -- decrement overflow counter by 1
	; ----------------------------------------------
STRTcode	DS	START		; Start code value
PASScode	DS	PASS		; pass code
FAILcode	DS	FAIL		; fail code

ADplus0	DS	+0
ADplus1	DS	 1

AD25252	DS	%25252	; +10922 decimal (10 1010 1010 1010)
AD37777	DS	%37777	; largest positive number (11 1111 1111 1111)
AD40000	DS	%40000	; largest negative number (100 0000 0000 0000)

	; ----------------------------------------------
	; START of TEST
	; ----------------------------------------------
chkOVRFL	EQU	*		; entry point for test
		CAF	STRTcode	; Initialize result code
		TS	curtest	; set current test code to PASS

	; ----------------------------------------------
	; TEST3: sum positive, overflow
	; initialize overflow counter and positive overflow storage
	; ----------------------------------------------
		CAF	ADplus0
		TS	OVFCNTR

	; add: %25252 + %25252 = %52524 (sign + 14 magnitude) X=0x2AAA Y=0x2AAA U=0x5554 CO=0x0000 CI=0x0000  
		CAF	AD25252
		AD	AD25252

	; ----------------------------------------------
	; verify overflow counter =%00001
	; ----------------------------------------------
		CS	OVFCNTR	; get -A
		AD	ADplus1	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; ----------------------------------------------
	; PASSED TEST!
	; ----------------------------------------------
		CAF	PASScode	; fall through if passed
		TS	curtest	; set current test code to PASS
		TC	done		; Return to main program
	; ----------------------------------------------
	; FAILED TEST!
	; ----------------------------------------------
fail		EQU	*
		CAF	FAILcode	; load fail code
		TS	curtest	; set current test code to PASS
		TC	done		; Return to main program
	; ----------------------------------------------


