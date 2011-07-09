; -------------------------------------------------------
; TECO2_AD (file:teco2_AD.asm)
;
START		EQU	%00
ADtst		EQU	%07	; AD check failed
PASS		EQU	%12345	; PASSED all checks
	; ----------------------------------------------

OVFCNTR		EQU	%00034	; overflow counter

	; ----------------------------------------------
	; ERASEABLE MEMORY -- DATA SEGMENT

		ORG	%100	; start of data area
curtest	DS	START	; current test
savQ		DS	%0     ; save result
ADk		DS	-0	; AD test

	; ----------------------------------------------
	; ENTRY POINTS

	; program (re)start
		ORG	GOPROG
		TC	goMAIN

	; ----------------------------------------------
	; FIXED MEMORY -- SHARED DATA SEGMENT
	; ----------------------------------------------
	; MAIN PROGRAM
goMAIN		EQU	*
		INHINT		; disable interrupts
repeat		TCR	begin

	; Test basic instructions.
		TCR	chkAD

	; Passed all tests.
		TCR	finish

fail		EQU	*
		XCH	curtest	; load last passed test into A
		TS	curtest

end		EQU	*
		TC	end	; finished, TC trap

	; ----------------------------------------------
	; INITIALIZE FOR START OF TESTING

STRTcode	DS	START

begin		EQU	*
		XCH	STRTcode
		TS	curtest	; set current test code to START
		RETURN
		
	; ----------------------------------------------
	; TEST AD INSTRUCTION SUBROUTINE
	; L:	AD	K
	; Verifies the following:
	; - Set C(A) = b(A) + C(K)
	; - Take next instruction from L+1
	; - if C(A) has positive overflow,
	; -- increment overflow counter by 1
	; - if C(A) has negative overflow,
	; -- decrement overflow counter by 1

ADcode		DS	ADtst	; code for this test
ADplus0	DS	+0
ADplus1	DS	1
ADmin1		DS	-1

AD25252	DS	%25252	; +10922 decimal (10 1010 1010 1010)
AD12525	DS	%12525	; +5461 decimal  (01 0101 0101 0101)
AD37777	DS	%37777	; largest positive number (11 1111 1111 1111)
AD12524	DS	%12524	; positive overflow of %25252+%25252

AD52525	DS	%52525	; -10922 decimal
AD65252	DS	%65252	; -5461 decimal
AD40000	DS	%40000	; largest negative number (100 0000 0000 0000)
AD65253	DS	%65253	; negative overflow of %52525+65252 (110 1010 1010 1011)

ADcurtest	DS	START	; current test
ADsavQ		DS	%0     ; save result
ADADk		DS	-0	; AD test


chkAD		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	ADcode
		TS	curtest	; set current test code to this test

	; ----------------------------------------------
	; TEST3: sum positive, overflow
	; initialize overflow counter and positive overflow storage

	      ; ------------------------------------------
		CAF	ADcurtest    ; reinitialize
		TS	curtest
		CAF	ADsavQ       ; reinitialize
		TS	savQ
		CAF	ADADk        ; reinitialize
		TS	ADk
    	      ; ------------------------------------------


		CAF	ADplus0
		TS	OVFCNTR
		TS	ADk

	; add: %25252 + %25252 = %52524 (sign + 14 magnitude)
		CAF	AD25252
		AD	AD25252
		TS	ADk	; store positive overflow
		TC	fail

	; verify ADk = %12524
		CS	ADk	; get -A
		AD	AD12524	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; ----------------------------------------------
	; verify overflow counter =%00001
		CS	OVFCNTR	; get -A
		AD	ADplus1	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; ----------------------------------------------
		XCH	savQ
		TS	Q	; restore return address
		RETURN
	; ----------------------------------------------


	; ----------------------------------------------
	; PASSED ALL TESTS!

PASScode	DS	PASS

finish		EQU	*
		CAF	PASScode
		TS	curtest	; set current test code to PASS
		RETURN

	; ----------------------------------------------
