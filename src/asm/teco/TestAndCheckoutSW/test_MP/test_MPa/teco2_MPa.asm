;-------------------------------------------------------------------------
; TECO2_MP (file:teco2_MP.asm)
; PURPOSE:
; Test and checkout program for the Block 1 Apollo Guidance Computer.
; Tests extracode instructions: MP
;
; OPERATION:
; Enters an infinite loop at the end of the test. The A register contains 
; the code for the test that failed, or the PASS code if all tests 
; succeeded. See test codes below.
;-------------------------------------------------------------------------
START		EQU	%00
MPtst		EQU	%01	; MP check failed
PASS		EQU	%12345	; PASSED all checks
	; ----------------------------------------------
		ORG	EXTENDER
		DS	%47777	; needed for EXTEND
OVFCNTR	EQU	%00034	; overflow counter

	; ----------------------------------------------
	; ERASEABLE MEMORY -- DATA SEGMENT
	; ----------------------------------------------
		ORG	%100	; start of data area
curtest	DS	START	; current test
savQ		DS	%0
MPindex	DS	%0	; MP test
MPXTND		DS	%0	; indexed extend

	; ----------------------------------------------
	; MAIN PROGRAM ENTRY POINT
	; ----------------------------------------------
		ORG	GOPROG
goMAIN		EQU	*
		INHINT		; disable interrupts
		TCR	begin
		TCR	chkMP	; Test extracode instructions.
		TCR	finish	; Passed all tests.
end		EQU	*
		TC	end	; finished, TC trap

fail		EQU	*
		XCH	curtest	; load last passed test into A
		TS	curtest
failend	EQU	*
		TC	failend	; finished, TC trap

	; ----------------------------------------------
	; INITIALIZE FOR START OF TESTING
	; ----------------------------------------------
STRTcode	DS	START
begin		EQU	*
		XCH	STRTcode
		TS	curtest	; set current test code to START
		RETURN

	; ----------------------------------------------
	; PASSED ALL TESTS!
	; ----------------------------------------------
PASScode	DS	PASS
finish		EQU	*
		CAF	PASScode
		TS	curtest	; set current test code to PASS
		RETURN
		
	; ----------------------------------------------
	; TEST MP INSTRUCTION SUBROUTINE
	; L:	MP	K
	; Verifies the following
	; - Set C(A,LP) = b(A) * C(K)
	; - Take next instruction from L+1
	; ----------------------------------------------
chkMP		EQU	*
		XCH	Q
		TS	savQ	; save return address
		CAF	MPcode
		TS	curtest	; set current test code to this test

	; ----------------------------------------------
	; Decrementing loop
	;	- always executes at least once (tests at end of loop)		
	;	- loops 'MPstart+1' times; decrements MPindex
	; ----------------------------------------------
		XCH	MPstart	; initialize loop counter

	;------------------------------
	; MP check starts here
	; uses MPindex to access test values
	; ----------------------------------------------
MPloop		EQU	*
		TS	MPindex	; save new index
		CAF	EXTENDER
		AD	MPindex
		TS	MPXTND

		INDEX	MPindex
		CAF	mp1
		INDEX	MPXTND	; EXTEND using MPindex
		MP	mp2

	; verify C(A)
		COM		; get -A
		INDEX	MPindex
		AD	MPchkA	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; verify C(LP)
		CS	LP	; get -A
		INDEX	MPindex
		AD	MPchkLP	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; ----------------------------------------------
	; end of MP check
	; ----------------------------------------------
		CCS	MPindex	; done?
		TC	MPloop		; not yet, do next check
		XCH	savQ
		TS	Q		; restore return address
		RETURN

	; ----------------------------------------------
MPcode		DS	MPtst	; code for this test
MPstart	DS	7	; loop MPstart+1 times 

	; C(A) test values
mp1		EQU	*
	; check boundary conditions
		DS	%37777	; check #00 (+16383 * +16383)
		DS	%37777	; check #01 (+16383 * -16383)
		DS	%40000	; check #02 (-16383 * +16383)
		DS	%40000	; check #03 (-16383 * -16383)
		DS	%00000	; check #04 (+0 * +0)
		DS	%00000	; check #05 (+0 * -0)
		DS	%77777	; check #06 (-0 * +0)
		DS	%77777	; check #07 (-0 * -0)

	; C(K) test values
mp2		EQU	*
	; check boundary conditions
		DS	%37777	; check #00 (+16383 * +16383)
		DS	%40000	; check #01 (+16383 * -16383)
		DS	%37777	; check #02 (-16383 * +16383)
		DS	%40000	; check #03 (-16383 * -16383)
		DS	%00000	; check #04 (+0 * +0)
		DS	%77777	; check #05 (+0 * -0)
		DS	%00000	; check #06 (-0 * +0)
		DS	%77777	; check #07 (-0 * -0)

	; A = upper product
MPchkA		EQU	*
	; check boundary conditions
		DS	%37776	; check #00
		DS	%40001	; check #01
		DS	%40001	; check #02
		DS	%37776	; check #03
		DS	%00000	; check #04
		DS	%77777	; check #05
		DS	%77777	; check #06
		DS	%00000	; check #07

	; LP = lower product
MPchkLP		EQU	*
	; check boundary conditions
		DS	%00001	; check #00
		DS	%77776	; check #01
		DS	%77776	; check #02
		DS	%00001	; check #03
		DS	%00000	; check #04
		DS	%77777	; check #05
		DS	%77777	; check #06
		DS	%00000	; check #07

;-------------------------------------------------------------------------
; END OF PROGRAM
;-------------------------------------------------------------------------
