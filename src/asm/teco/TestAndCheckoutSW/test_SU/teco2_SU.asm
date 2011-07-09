; TECO2_SU (file:teco2_SU.asm)
;
; Version:	1.0
; Author:	John Pultorak
; Date:		9/14/2001
;
; PURPOSE:
; Test and checkout program for the Block 1 Apollo Guidance Computer.
; Tests extracode instructions: SU
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

MPtst		EQU	%01	; MP check failed
DVtst		EQU	%02	; DV check failed
SUtst		EQU	%03	; SU check failed

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

	; SU test
SUk		DS	-0

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
		TCR	chkSU

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
	; TEST SU INSTRUCTION SUBROUTINE
	; L:	SU	K
	; Verifies the following:
	; - Set C(A) = b(A) - C(K)
	; - Take next instruction from L+1
	; - if C(A) has positive overflow,
	; -- increment overflow counter by 1
	; - if C(A) has negative overflow,
	; -- decrement overflow counter by 1

SUcode		DS	SUtst	; code for this test

SUplus0		DS	+0
SUplus1		DS	1
SUmin1		DS	-1

SU25252		DS	%25252	; +10922 decimal
SU12525		DS	%12525	; +5461 decimal
SU37777		DS	%37777	; largest positive number
SU12524		DS	%12524	; positive overflow of %25252+%25252

SU52525		DS	%52525	; -10922 decimal
SU65252		DS	%65252	; -5461 decimal
SU40000		DS	%40000	; largest negative number
SU65253		DS	%65253	; negative overflow of %52525+65252

chkSU		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	SUcode
		TS	curtest	; set current test code to this test

	; NOTE: these test are similar to the checks for AD, but
	; the AD augend value has been changed to negative and AD has
	; been changed to SU. The results produced by this change
	; are identical to AD, and so the checks are the same.

	; TEST1: difference positive, no overflow
	; sub: %25252 - %65252 = %37777 (sign + 14 magnitude)
		CAF	SU25252
		EXTEND
		SU	SU65252
	; verify C(A) = %37777
		COM		; get -A
		AD	SU37777	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; TEST2: difference negative, no overflow (sign + 14 magnitude)
	; sub: %52525 - %12525 = %40000
		CAF	SU52525
		EXTEND
		SU	SU12525
	; verify C(A) = %40000
		COM		; get -A
		AD	SU40000	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; TEST3: difference positive, overflow
	; initialize overflow counter and positive overflow storage
		CAF	SUplus0
		TS	OVFCNTR
		TS	SUk
	; sub: %25252 - %52525 = %52524 (sign + 14 magnitude)
		CAF	SU25252
		EXTEND
		SU	SU52525
		TS	SUk	; store positive overflow
		TC	fail
	; verify SUk = %12524
		CS	SUk	; get -A
		AD	SU12524	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; verify overflow counter =%00001
		CS	OVFCNTR	; get -A
		AD	SUplus1	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; TEST4: difference negative, overflow
		CAF	SUplus0
		TS	OVFCNTR
		TS	SUk
	; add: %52525 + %25252 = %25253 (sign + 14 magnitude)
		CAF	SU52525
		EXTEND
		SU	SU25252
		TS	SUk	; store negative overflow
		TC	fail
	; verify SUk = %65253
		CS	SUk	; get -A
		AD	SU65253	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; verify overflow counter =%77776
		CS	OVFCNTR	; get -A
		AD	SUmin1	; put (-A) + expected value in A
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


