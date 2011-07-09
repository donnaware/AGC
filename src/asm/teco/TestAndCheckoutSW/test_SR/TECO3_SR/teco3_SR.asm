; TECO3 (file:teco3_SR.asm)
;
; Version:	1.0
; Author:	John Pultorak
; Date:		9/14/2001
;
; PURPOSE:
; Test and checkout program for the Block 1 Apollo Guidance Computer.
; Tests editing registers: SR.
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

SRtst		EQU	%02	; SR check failed

PASS		EQU	%12345	; PASSED all checks
	; ----------------------------------------------
	; ERASEABLE MEMORY -- DATA SEGMENT

		ORG	%100	; start of data area
curtest		DS	START	; current test
savQ		DS	%0


	; SR test values
SRval		DS	%0	; current test value
iSR		DS	%0	; current index


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
		TCR	chkSR

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
	; TEST SR EDITING FUNCTION SUBROUTINE
	; Shift a test value right through SR 15 times.
	; Test the value against an expected value for each time.
	; After 15 shifts, the value should equal the sign (SG).

SRcode		DS	SRtst	; code for this test

	; SR test values
SRinitP		DS	%03431	; positive init test value
SRinitN		DS	%44346	; negative init test value
SRindx		DS	14	; loop SRindx+1 times

	; check SR against these values (positive)
SRbaseP		EQU	*
		DS	%00000	; check #0 (back to start)
		DS	%00000	; check #1
		DS	%00000	; check #2
		DS	%00000	; check #3
		DS	%00000	; check #4
		DS	%00001	; check #5
		DS	%00003	; check #6
		DS	%00007	; check #7
		DS	%00016	; check #8
		DS	%00034	; check #9
		DS	%00070	; check #10
		DS	%00161	; check #11
		DS	%00343	; check #12
		DS	%00706	; check #13
		DS	%01614	; check #14

	; check SR against these values (negative)
SRbaseN		EQU	*
		DS	%77777	; check #0 (back to start)
		DS	%77777	; check #1
		DS	%77776	; check #2
		DS	%77774	; check #3
		DS	%77771	; check #4
		DS	%77762	; check #5
		DS	%77744	; check #6
		DS	%77710	; check #7
		DS	%77621	; check #8
		DS	%77443	; check #9
		DS	%77107	; check #10
		DS	%76216	; check #11
		DS	%74434	; check #12
		DS	%71071	; check #13
		DS	%62163	; check #14

chkSR		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	SRcode
		TS	curtest	; set current test code to this test

	; TEST 1: shift a postive value.
		XCH	SRinitP	; init value to shift
		TS	SRval

		XCH	SRindx	; load init index


SRloopP		EQU	*
		TS	iSR	; save index

	; shift A right (SR)
		XCH	SRval
		TS	SR	; shift
		XCH	SR	; put result in A
		TS	SRval

	; verify C(A)
		COM		; get -A
		INDEX	iSR
		AD	SRbaseP	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
		
	; loop back to test next value
		CCS	iSR	; done?
		TC	SRloopP	; not yet, do next check

	; TEST 2: shift a negative value
		XCH	SRinitN	; init value to shift
		TS	SRval

		XCH	SRindx	; load init index


SRloopN		EQU	*
		TS	iSR	; save index

	; shift A left (SR)
		XCH	SRval
		TS	SR	; shift
		XCH	SR	; put result in A
		TS	SRval

	; verify C(A)
		COM		; get -A
		INDEX	iSR
		AD	SRbaseN	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
		
	; loop back to test next value
		CCS	iSR	; done?
		TC	SRloopN	; not yet, do next check

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


