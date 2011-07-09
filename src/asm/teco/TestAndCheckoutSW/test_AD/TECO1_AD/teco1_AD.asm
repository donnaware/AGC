; TECO1_AD (file:teco1_AD.asm)
;
; Version:	1.0
; Author:	John Pultorak
; Date:		9/14/2001
;
; PURPOSE:
; Test and checkout program for the Block 1 Apollo Guidance Computer.
; Tests basic instructions: AD.
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

ADtst		EQU	%07	; AD check failed

PASS		EQU	%12345	; PASSED all checks
	; ----------------------------------------------

OVFCNTR		EQU	%00034	; overflow counter

	; ----------------------------------------------
	; ERASEABLE MEMORY -- DATA SEGMENT

		ORG	%100	; start of data area
curtest		DS	START	; current test
savQ		DS	%0

	; AD test
ADk		DS	-0

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
ADplus0		DS	+0
ADplus1		DS	1
ADmin1		DS	-1

AD25252		DS	%25252	; +10922 decimal
AD12525		DS	%12525	; +5461 decimal
AD37777		DS	%37777	; largest positive number
AD12524		DS	%12524	; positive overflow of %25252+%25252

AD52525		DS	%52525	; -10922 decimal
AD65252		DS	%65252	; -5461 decimal
AD40000		DS	%40000	; largest negative number
AD65253		DS	%65253	; negative overflow of %52525+65252

chkAD		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	ADcode
		TS	curtest	; set current test code to this test

	; TEST1: sum positive, no overflow
	; add: %25252 + %12525 = %37777 (sign + 14 magnitude)
		CAF	AD25252
		AD	AD12525
	; verify C(A) = %37777
		COM		; get -A
		AD	AD37777	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; TEST2: sum negative, no overflow (sign + 14 magnitude)
	; add: %52525 + %65252 = %40000
		CAF	AD52525
		AD	AD65252
	; verify C(A) = %40000
		COM		; get -A
		AD	AD40000	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; TEST3: sum positive, overflow
	; initialize overflow counter and positive overflow storage
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
	; verify overflow counter =%00001
		CS	OVFCNTR	; get -A
		AD	ADplus1	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; TEST4: sum negative, overflow
		CAF	ADplus0
		TS	OVFCNTR
		TS	ADk
	; add: %52525 + %52525 = %25253 (sign + 14 magnitude)
		CAF	AD52525
		AD	AD52525
		TS	ADk	; store negative overflow
		TC	fail
	; verify ADk = %65253
		CS	ADk	; get -A
		AD	AD65253	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; verify overflow counter =%77776
		CS	OVFCNTR	; get -A
		AD	ADmin1	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

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
