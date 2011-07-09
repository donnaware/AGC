; TECO5 (file:teco5.asm)
;
; Version:	1.0
; Author:	John Pultorak
; Date:		9/14/2001
;
; PURPOSE:
; Test and checkout program for the Block 1 Apollo Guidance Computer.
; Tests I/O: interrupts, DSKY keyboard, and DSKY display.
;
; OPERATION:
; TBD.
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

		ORG	EXTENDER
		DS	%47777	; needed for EXTEND

	; ----------------------------------------------
	; ERASEABLE MEMORY -- DATA SEGMENT

		ORG	%100	; start of data area
curtest		DS	START	; current test
savQ		DS	%0

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

end		EQU	*
		TC	end	; finished, TC trap

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



