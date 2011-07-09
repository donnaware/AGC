; TECO3 (file:teco3_CYL.asm)
;
; Version:	1.0
; Author:	John Pultorak
; Date:		9/14/2001
;
; PURPOSE:
; Test and checkout program for the Block 1 Apollo Guidance Computer.
; Tests editing registers: CYL.
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

CYLtst		EQU	%03	; CYL check failed

PASS		EQU	%12345	; PASSED all checks
	; ----------------------------------------------
	; ERASEABLE MEMORY -- DATA SEGMENT

		ORG	%100	; start of data area
curtest		DS	START	; current test
savQ		DS	%0


	; CYL test values
CYLval		DS	%0	; current test value
iCYL		DS	%0	; current index


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
		TCR	chkCYL

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
	; TEST CYL EDITING FUNCTION SUBROUTINE
	; Rotate a test value left through CYL 15 times.
	; Test the value against an expected value for each time.
	; After 15 rotations, the value should equal the initial
	; value.

CYLcode		DS	CYLtst	; code for this test

	; CYL test values
CYLinit		DS	%03431	; init test value
CYLindx		DS	14	; loop CYLindx+1 times

	; check CYL against these values
CYLbase		EQU	*
		DS	%03431	; check #0 (back to start)
		DS	%41614	; check #1
		DS	%20706	; check #2
		DS	%10343	; check #3
		DS	%44161	; check #4
		DS	%62070	; check #5
		DS	%31034	; check #6
		DS	%14416	; check #7
		DS	%06207	; check #8
		DS	%43103	; check #9
		DS	%61441	; check #10
		DS	%70620	; check #11
		DS	%34310	; check #12
		DS	%16144	; check #13
		DS	%07062	; check #14

chkCYL		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	CYLcode
		TS	curtest	; set current test code to this test

		XCH	CYLinit	; init value to rotate
		TS	CYLval

		XCH	CYLindx	; load init index

CYLloop		EQU	*
		TS	iCYL	; save index

	; rotate A left (CYL)
		XCH	CYLval
		TS	CYL	; rotate
		XCH	CYL	; put result in A
		TS	CYLval

	; verify C(A)
		COM		; get -A
		INDEX	iCYL
		AD	CYLbase	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
		
	; loop back to test next value
		CCS	iCYL	; done?
		TC	CYLloop	; not yet, do next check

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


