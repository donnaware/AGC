; TECO2 (file:teco2.asm)
;
; Version:	1.0
; Author:	John Pultorak
; Date:		9/14/2001
;
; PURPOSE:
; Test and checkout program for the Block 1 Apollo Guidance Computer.
; Tests extracode instructions: MP, DV, SU
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

DVtst		EQU	%02	; DV check failed

PASS		EQU	%12345	; PASSED all checks
	; ----------------------------------------------

		ORG	EXTENDER
		DS	%47777	; needed for EXTEND

OVFCNTR		EQU	%00034	; overflow counter

	; ----------------------------------------------
	; ERASEABLE MEMORY -- DATA SEGMENT

		ORG	%100	; start of data area
curtest		DS	START	; current test
savQ		DS	%0


	; DV test
DVsavA		DS	%0
DVindex		DS	%0
DVXTND		DS	%0	; indexed extend


	; ----------------------------------------------
	; ENTRY POINTS

	; program (re)start
		ORG	GOPROG
		TC	goMAIN

	; interrupt service entry points
		ORG	T3RUPT
		TS	ARUPT
		XCH	Q
		TS	QRUPT
		TC	goT3

		ORG	ERRUPT
		TS	ARUPT
		XCH	Q
		TS	QRUPT
		TC	goER

		ORG	DSRUPT		
		TS	ARUPT
		XCH	Q
		TS	QRUPT
		TC	goDS

		ORG	KEYRUPT
		TS	ARUPT
		XCH	Q
		TS	QRUPT
		TC	goKEY

	
		ORG	UPRUPT
		TS	ARUPT
		XCH	Q
		TS	QRUPT
		TC	goUP


	; ----------------------------------------------
	; FIXED MEMORY -- SHARED DATA SEGMENT

	; ----------------------------------------------
	; MAIN PROGRAM

goMAIN		EQU	*
		INHINT		; disable interrupts

		TCR	begin

	; Test extracode instructions.
		TCR	chkDV

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
	; TEST DV INSTRUCTION SUBROUTINE
	; L:	DV	K
	; Verifies the following:
	; - Set C(A) = b(A) / C(K)
	; - Set C(Q) = - abs(remainder)
	; - Set C(LP) > 0 if quotient is positive
	; - Set C(LP) < 0 if quotient is negative
	; - Take next instruction from L+1

DVcode		DS	DVtst	; code for this test

	; DV test values
	;                          
DVstart		DS	3	; loop DVstart+1 times

	; C(A) test values
div1		EQU	*
		DS	%00000	; check #00 (+0/+0)
		DS	%00000	; check #01 (+0/-0)
		DS	%77777	; check #02 (-0/+0)
		DS	%77777	; check #03 (-0/-0)

	; C(K) test values
div2		EQU	*
		DS	%00000	; check #00 (+0/+0)
		DS	%77777	; check #01 (+0/-0)
		DS	%00000	; check #02 (-0/+0)
		DS	%77777	; check #03 (-0/-0)

	; A = quotient
DVchkA		EQU	*
		DS	%37777	; check #00 (+0/+0)
		DS	%40000	; check #01 (+0/-0)
		DS	%40000	; check #02 (-0/+0)
		DS	%37777	; check #03 (-0/-0)

	; Q = remainder
DVchkQ		EQU	*
		DS	%77777	; check #00 (+0/+0)
		DS	%77777	; check #01 (+0/-0)
		DS	%77777	; check #02 (-0/+0)
		DS	%77777	; check #03 (-0/-0)

	; LP = sign
DVchkLP		EQU	*
		DS	%00001	; check #00 (+0/+0)
		DS	%40000	; check #01 (+0/-0)
		DS	%40001	; check #02 (-0/+0)
		DS	%00001	; check #03 (-0/-0)

chkDV		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	DVcode
		TS	curtest	; set code identifying current test


		; Decrementing loop
		;	- always executes at least once (tests at end of loop)		
		;	- loops 'DVstart+1' times; decrements DVindex
		XCH	DVstart	; initialize loop counter

		;------------------------------

		; DV check starts here
		; uses DVindex to access test values
DVloop		EQU	*
		TS	DVindex	; save new index

		CAF	EXTENDER
		AD	DVindex
		TS	DVXTND

		INDEX	DVindex
		CAF	div1
		INDEX	DVXTND	; EXTEND using DVindex
		DV	div2
		TS	DVsavA
		
	; verify C(Q)
		CS	Q	; get -A
		INDEX	DVindex
		AD	DVchkQ	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; verify C(A)
		CS	DVsavA	; get -A
		INDEX	DVindex
		AD	DVchkA	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; verify C(LP)
		CS	LP	; get -A
		INDEX	DVindex
		AD	DVchkLP	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

		; end of DV check
		;------------------------------

		CCS	DVindex	; done?
		TC	DVloop	; not yet, do next check

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
	; INTERRUPT SERVICE ROUTINE

goT3		EQU	*
goER		EQU	*
goDS		EQU	*
goKEY		EQU	*
goUP		EQU	*


endRUPT		EQU	*
		XCH	QRUPT	; restore Q
		TS	Q
		XCH	ARUPT	; restore A
		RESUME		; finished, go back



