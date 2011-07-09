; TECO5 (file:teco5.asm)
;
; Version:	1.0
; Author:	John Pultorak
; Date:		9/14/2001
;
; PURPOSE:
; Test and checkout program for the Block 1 Apollo Guidance Computer.
; Tests interrupts.
;
; OPERATION:
; Tests the interrupts by initializing 4 counters to zero and then
; entering a loop where the 1st counter (mainCtr) is incremented on
; each iteration of the loop. 
;
; Interrupts are disabled and enabled during each iteration by INHINT
; and RELINT instructions.
;
; Interrupts are automatically inhibited during part of each iteration by
; an overflow condition in register A.
;
; Interrupt service routines for T3RUPT, DSRUPT (aka T4RUPT) and KEYRUPT
; increment their own counters upon each interrupt.
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

	; ----------------------------------------------

	; ----------------------------------------------
	; ERASEABLE MEMORY -- DATA SEGMENT

		ORG	%47	; start of data area
mainCtr		DS	%0

T3Ctr		DS	%0	; counts T3RUPTs
DSCtr		DS	%0	; counts DSRUPTs (T4RUPT)
KYCtr		DS	%0	; counts KEYRUPT

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

		ORG	DSRUPT	; aka T4RUPT	
		TS	ARUPT
		XCH	Q
		TS	QRUPT
		TC	goDS

		ORG	KEYRUPT
		TS	ARUPT
		XCH	Q
		TS	QRUPT
		TC	goKEY


	; ----------------------------------------------
	; FIXED MEMORY -- SHARED DATA SEGMENT

ZERO		DS	%0
ONE		DS	%1
AD25252		DS	%25252	;+10922 dec, see TECO1 AD test
AD52525		DS	%52525	;-10922 dec, see TECO1 AD test

	; ----------------------------------------------
	; MAIN PROGRAM

goMAIN		EQU	*
		INHINT		; disable interrupts

	; clear counters for interrupts and for interations
	; though main loop.

		CAF	ZERO
		TS	mainCtr	; mainCtr = 0
		TS	T3Ctr	; T3Ctr = 0
		TS	DSCtr	; DSCtr = 0
		TS	KYCtr	; KYCtr = 0

	; keeps bumping mainCtr in an infinite loop.
	; interrupts are disabled and enabled on each
	; iteration of the loop.

infLoop		EQU	*

		INHINT		; disable interrupt

	; increment mainCtr while interrupt is inhibited.

		CAF	ZERO
		AD	mainCtr	; load mainCtr into A
		AD	ONE	; incr

		RELINT		; enable interrupts

		TS	mainCtr	; store increment value

	; create a positive overflow in A. Interrupts are inhibited
	; while A contains an overflow. The overflow is produced
	; by adding %25252 + %25252 = %52524 (sign + 14 magnitude).
	; This is the overflow test in TECO1 for the AD instruction.

		CAF	AD25252
		AD	AD25252	; positive overflow

		NOOP		; interrupt should be inhib
		NOOP

	; remove the overflow, this reenables the interrupt.

		CAF	ZERO	; clear the overflow in A

		NOOP		; interrupt should be reenab
		NOOP

	; create a negative overflow in A. Interrupts are inhibited
	; while A contains an overflow. The overflow is produced
	; by adding %52525 + %52525 = %25253 (sign + 14 magnitude).
	; This is the overflow test in TECO1 for the AD instruction.

		CAF	AD52525
		AD	AD52525	; positive overflow

		NOOP		; interrupt should be inhib
		NOOP

	; remove the overflow, this reenables the interrupt.

		CAF	ZERO	; clear the overflow in A

		NOOP		; interrupt should be reenab
		NOOP


		TC	infLoop	; mainCtr no overflow
		TC	infLoop	; mainCtr overflowed

	; ----------------------------------------------
	; INTERRUPT SERVICE ROUTINE

goT3		EQU	*
		CAF	ZERO
		AD	T3Ctr	; load T3Ctr into A
		AD	ONE	; incr
		TS	T3Ctr	; store
		TC	endRUPT

goDS		EQU	*
		CAF	ZERO
		AD	DSCtr	; load DSCtr into A
		AD	ONE	; incr
		TS	DSCtr	; store
		TC	endRUPT

goKEY		EQU	*
		CAF	ZERO
		AD	KYCtr	; load KYCtr into A
		AD	ONE	; incr
		TS	KYCtr	; store
		TC	endRUPT

endRUPT		EQU	*
		XCH	QRUPT	; restore Q
		TS	Q
		XCH	ARUPT	; restore A
		RESUME		; finished, go back



