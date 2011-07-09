; TECO3 (file:teco3_SL.asm)
;
; Version:	1.0
; Author:	John Pultorak
; Date:		9/14/2001
;
; PURPOSE:
; Test and checkout program for the Block 1 Apollo Guidance Computer.
; Tests editing registers: SL.
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

SLtst		EQU	%02	; SL check failed

PASS		EQU	%12345	; PASSED all checks
	; ----------------------------------------------
	; ERASEABLE MEMORY -- DATA SEGMENT

		ORG	%100	; start of data area
curtest		DS	START	; current test
savQ		DS	%0


	; SL test values
SLval		DS	%0	; current test value
iSL		DS	%0	; current index

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

	; Test extracode instructions.
		TCR	chkSL

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
	; TEST SL EDITING FUNCTION SUBROUTINE
	; Shift a test value left through SL 15 times.
	; Test the value against an expected value for each time.
	; After 15 shifts, the value should equal the sign (SG).

SLcode		DS	SLtst	; code for this test

	; SL test values
SLinitP		DS	%03431	; positive init test value
SLinitN		DS	%44346	; negative init test value
SLindx		DS	14	; loop SLindx+1 times

	; check SL against these values (positive)
SLbaseP		EQU	*
		DS	%00000	; check #0 (back to start)
		DS	%00000	; check #1
		DS	%20000	; check #2
		DS	%10000	; check #3
		DS	%04000	; check #4
		DS	%22000	; check #5
		DS	%31000	; check #6
		DS	%14400	; check #7
		DS	%06200	; check #8
		DS	%03100	; check #9
		DS	%21440	; check #10
		DS	%30620	; check #11
		DS	%34310	; check #12
		DS	%16144	; check #13
		DS	%07062	; check #14

	; check SL against these values (negative)
SLbaseN		EQU	*
		DS	%77777	; check #0 (back to start)
		DS	%77777	; check #1
		DS	%57777	; check #2
		DS	%67777	; check #3
		DS	%73777	; check #4
		DS	%55777	; check #5
		DS	%46777	; check #6
		DS	%63377	; check #7
		DS	%71577	; check #8
		DS	%74677	; check #9
		DS	%56337	; check #10
		DS	%47157	; check #11
		DS	%43467	; check #12
		DS	%61633	; check #13
		DS	%50715	; check #14

chkSL		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	SLcode
		TS	curtest	; set current test code to this test

	; TEST 1: shift a postive value.
		XCH	SLinitP	; init value to shift
		TS	SLval

		XCH	SLindx	; load init index


SLloopP		EQU	*
		TS	iSL	; save index

	; shift A left (SL)
		XCH	SLval
		TS	SL	; shift
		XCH	SL	; put result in A
		TS	SLval

	; verify C(A)
		COM		; get -A
		INDEX	iSL
		AD	SLbaseP	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
		
	; loop back to test next value
		CCS	iSL	; done?
		TC	SLloopP	; not yet, do next check

	; TEST 2: shift a negative value
		XCH	SLinitN	; init value to shift
		TS	SLval

		XCH	SLindx	; load init index

SLloopN		EQU	*
		TS	iSL	; save index

	; shift A left (SL)
		XCH	SLval
		TS	SL	; shift
		XCH	SL	; put result in A
		TS	SLval

	; verify C(A)
		COM		; get -A
		INDEX	iSL
		AD	SLbaseN	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
		
	; loop back to test next value
		CCS	iSL	; done?
		TC	SLloopN	; not yet, do next check

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


