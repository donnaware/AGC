; TECO1_xch (file:teco1_xch.asm)
;
; Version:	1.0
; Author:	John Pultorak
; Date:		9/14/2001
;
; PURPOSE:
; Test and checkout program for the Block 1 Apollo Guidance Computer.
; Tests basic instructions: XCH
;
; OPERATION:
; Enters an infinite loop at the end of the test. The A register contains 
; the code for the test that failed, or the PASS code if all tests 
; succeeded. See test codes below.
;
; ERRATA:
; - Written for the AGC4R assembler. The assembler directives and syntax
; differ somewhat from the original AGC assembler.
; - The tests attempt to check all threads, but are not exhaustive.
;
; SOURCES:
; Information on the Block 1 architecture: instruction set, instruction
; sequences, registers, register transfers, control pulses, memory and 
; memory addressing, I/O assignments, interrupts, and involuntary counters
; was obtained from:
;
;	A. Hopkins, R. Alonso, and H. Blair-Smith, "Logical Description 
;		for the Apollo Guidance Computer (AGC4)", R-393, 
;		MIT Instrumentation Laboratory, Cambridge, MA, Mar. 1963.
;
; Supplementary information was obtained from:
;
;	R. Alonso, J. H. Laning, Jr. and H. Blair-Smith, "Preliminary 
;		MOD 3C Programmer's Manual", E-1077, MIT Instrumentation 
;		Laboratory, Cambridge, MA, Nov. 1961.
;
;	B. I. Savage and A. Drake, "AGC4 Basic Training Manual, Volume I", 
;		E-2052, MIT Instrumentation Laboratory, Cambridge, 
;		MA, Jan. 1967.
;
;	E. C. Hall, "MIT's Role in Project Apollo, Volume III, Computer 
;		Subsystem", R-700, MIT Charles Stark Draper Laboratory, 
;		Cambridge, MA, Aug. 1972.
;
;	A. Hopkins, "Guidance Computer Design, Part VI", source unknown.
;
;	A. I. Green and J. J. Rocchio, "Keyboard and Display System Program 
;		for AGC (Program Sunrise)", E-1574, MIT Instrumentation 
;		Laboratory, Cambridge, MA, Aug. 1964.
;
;	E, C. Hall, "Journey to the Moon: The History of the Apollo 
;		Guidance Computer", AIAA, Reston VA, 1996.
;

START		EQU	%00

XCHtst		EQU	%04	; XCH check failed

PASS		EQU	%12345	; PASSED all checks
	; ----------------------------------------------


OVFCNTR		EQU	%00034	; overflow counter

	; ----------------------------------------------
	; ERASEABLE MEMORY -- DATA SEGMENT

		ORG	%100	; start of data area
curtest		DS	START	; current test
savQ		DS	%0


	; XCH test
	; pre-set in erasable memory because we don't
	; want to use XCH to initialize them prior to testing XCH.
XCHkP0		DS	+0
XCHkM0		DS	-0
XCHkalt1	DS	%52525	; alternating bit pattern 1
XCHkalt2	DS	%25252	; alternating bit pattern 2


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

		TCR	begin

	; Test basic instructions.
		TCR	chkXCH

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
	; TEST XCH INSTRUCTION SUBROUTINE
	; L:	XCH	K
	; Verifies the following:
	; - set C(A) = b(K)
	; - set C(K) = b(A)
	; - take next instruction from L+1

XCHcode		DS	XCHtst	; code for this test
	; XCH test values
XCHfP0		DS	+0
XCHfM0		DS	-0
XCHfalt1	DS	%52525	; alternating bit pattern 1
XCHfalt2	DS	%25252	; alternating bit pattern 2

chkXCH		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	XCHcode
		TS	curtest	; set current test code to this test

	; test - initial conditions: K=+0, A=-0
	; initialize A
		CS	XCHfP0
	; exchange A and K
		XCH	XCHkP0
	; test contents of A for expected value
		COM		; get -A
		AD	XCHfP0	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; test contents of K for expected value
		CS	XCHkP0	; get -A
		AD	XCHfM0	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; test - initial conditions: K=-0, A=+0
	; initialize A
		CS	XCHfM0
	; exchange A and K
		XCH	XCHkM0
	; test contents of A for expected value
		COM		; get -A
		AD	XCHfM0	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; test contents of K for expected value
		CS	XCHkM0	; get -A
		AD	XCHfP0	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; test - initial conditions: K=52525, A=25252
	; initialize A
		CS	XCHfalt1
	; exchange A and K
		XCH	XCHkalt1
	; test contents of A for expected value
		COM		; get -A
		AD	XCHfalt1	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; test contents of K for expected value
		CS	XCHkalt1	; get -A
		AD	XCHfalt2	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; test - initial conditions: K=25252, A=52525
	; initialize A
		CS	XCHfalt2
	; exchange A and K
		XCH	XCHkalt2
	; test contents of A for expected value
		COM		; get -A
		AD	XCHfalt2	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; test contents of K for expected value
		CS	XCHkalt2	; get -A
		AD	XCHfalt1	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; passed the test
		XCH	savQ
		TS	Q	; restore return address
		RETURN

	; ----------------------------------------------
	; PASSED ALL TESTS!

PASScode	DS	PASS

finish		EQU	*
		CAF	PASScode
		TS	curtest	; set current test code to PASS
		RETURN

	; ----------------------------------------------


