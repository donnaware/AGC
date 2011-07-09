;==========================================================================
; AGC (file:agc.asm)
;
; Version:	1.0
; Author:	John Pultorak
; Date:		4/7/2002
;
; PURPOSE:
; AGC Block 1 demonstration. Includes WAITLIST, EXEC, PINBALL (DSKY routines),
; NOUN tables, VERB tables.
;
; OPERATION:
; TBD.
;
; ERRATA:
; - Written for the AGC4R assembler. The assembler directives and syntax
; differ somewhat from the original AGC assembler.
; - No special effort was made to optimize the algorithms or memory usage.
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
; Supplementary AGC hardware information was obtained from:
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
;;
;	E, C. Hall, "Journey to the Moon: The History of the Apollo 
;		Guidance Computer", AIAA, Reston VA, 1996.
;
; AGC software information was obtained from:
;
;	AGC Block II COLOSSUS rev 249 assembly listing, Oct 28, 1968. (A
;		listing of the 1st 50% of the build. It encludes the entire
;		eraseable memory, restart initialization, T4RUPT, and the
;		entire set of DSKY routines. A small subset of instructions
;		had to be converted from Block II to Block I).
;
;	A. I. Green and J. J. Rocchio, "Keyboard and Display System Program 
;		for AGC (Program Sunrise)", E-1574, MIT Instrumentation 
;		Laboratory, Cambridge, MA, Aug. 1964. Contains detailed
;		flowcharts and design materials for the DSKY software.
;
;	A. Hopkins, R. Alonso, and H. Blair-Smith, "Logical Description 
;		for the Apollo Guidance Computer (AGC4)", R-393, 
;		MIT Instrumentation Laboratory, Cambridge, MA, Mar. 1963.
;		Contains the software interfaces for EXEC and WAITLIST, and
;		some examples of a dual precision (DP) math library.
;
;==========================================================================

	; ERASEABLE MEMORY DECLARATIONS

		ORG	BANK0		; immediately following counters
		INCL	exec_e.asm	; EXEC variables
;		INCL	dsky_e.asm	; DSKY variables

	; FIXED MEMORY DECLARATIONS

		ORG	EXTENDER
		DS	%47777		; needed for EXTEND

;--------------------------------------------------------------------------
; EXECUTION ENTRY POINTS
;--------------------------------------------------------------------------

	; Program (re)start
		ORG	GOPROG
		TC	goMAIN		; AGC (re)start begins here!

	; Interrupt vectors
		ORG	T3RUPT
		TS	ARUPT		; TIME3 interrupt vector
		XCH	Q
		TS	QRUPT
		TC	goT3

		ORG	ERRUPT
		TS	ARUPT
		XCH	Q
		TS	QRUPT
		TC	goER

		ORG	DSRUPT		; T4RUPT for DSKY display
		TS	ARUPT
		XCH	Q
		TS	QRUPT
		TC	goDS

		ORG	KEYRUPT		; DSKY keyboard interrupt vector
		TS	ARUPT
		XCH	Q
		TS	QRUPT
		TC	goKEY
	
		ORG	UPRUPT
		TS	ARUPT
		XCH	Q
		TS	QRUPT
		TC	goUP

endRUPT		EQU	*
		XCH	QRUPT		; restore Q
		TS	Q
		XCH	ARUPT		; restore A
		RESUME			; resume normal program execution

;--------------------------------------------------------------------------
; RUPT (INTERRUPT) SERVICE ROUTINES
;
; Upon entry, registers will contain these values:
; - ZRUPT: Prior contents of program counter (Z register).
; - BRUPT: Prior contents of B register.
; - ARUPT: Prior contents of accumulator (A register).
; - QRUPT: Prior contents of Q register.
;
; When the service routine is finished, jump to endRUPT to restore the A
; and Q registers. Call RESUME to restore Z and B, which causes a return
; to normal (non-interrupt) execution. Interrupts are disabled upon entry
; to the service routine; they are reenabled following RESUME.
;--------------------------------------------------------------------------

goT3		EQU	*
		TC	endRUPT

goER		EQU	*
		TC	endRUPT

goDS		EQU	*
		TC	endRUPT

goKEY		EQU	*
		TC	endRUPT

goUP		EQU	*
		TC	endRUPT

;--------------------------------------------------------------------------
; FIXED MEMORY CONSTANTS (shared)
;--------------------------------------------------------------------------

ofbit		DS	%200		; OUT1, bit 8 initiates standby

NEG0		DS	-0
NEG1		DS	-1
NEG2		DS	-2

ZERO		DS	0
ONE		DS	1
TWO		DS	2
THREE		DS	3
FOUR		DS	4
FIVE		DS	5
SIX		DS	6
SEVEN		DS	7
TEN		DS	10

BIT1		DS	%00001
BIT3		DS	%00004
BIT5		DS	%00020
BIT7		DS	%00100
BIT11		DS	%02000
BIT12		DS	%04000
BIT13		DS	%10000
BIT14		DS	%20000
BIT15		DS	%40000

LOW7		DS	%00177

bankAddr	DS	%6000		; fixed-switchable addr range starts here
lowAddr		DS	%1777		; mask for 10-bit address
OCT1400		DS	%1400

NOUTCON		DS	11

POSMAX		DS	%37777

;-------------------------------------------------------------------------
; MAIN PROGRAM
;
; AGC starts executing here, following power-up, or restart.
;-------------------------------------------------------------------------

THE_CADR	DS	job3

goMAIN		EQU	*
		INHINT			; inhibit interrupts

	; First, check for standby operation.

		XCH	ofbit
		TS	OUT1

	; Initialize WAITLIST and EXEC eraseable memory.

		TCR	EX_initEX	; initialize EXEC

	; Start any jobs or tasks needed at AGC initialization.
		XCH	prio1		; job priority
		TC	EX_addJob
		DS	job1		; 14 bit job address

		XCH	prio2		; job priority
		TC	EX_addJob
		DS	job2		; 14 bit job address

		XCH	prio3		; job priority
		TC	EX_addJob
		DS	job3		; 14 bit job address


	; Start the EXEC.

		TC	EX_exec		; never returns

;--------------------------------------------------------------------------
; Mimic the bank assignments in COLOSSUS. Since this is a block I AGC that
; has fewer banks, different bank numbers are used, but the sequence and
; relative allocation of routines to various banks is preserved.

	; library stuff in fixed-fixed.

		INCL	exec_f.asm	; EXEC

	

;--------------------------------------------------------------------------
; TEST DATA
;--------------------------------------------------------------------------


	; TEST JOBS
COUNT1		EQU	%44
COUNT2		EQU	%45
COUNT3		EQU	%46

prio1		DS	3
prio2		DS	3
prio3		DS	4

	; TEST CODE - JOB 3
job3		EQU	*
		CCS	newJob		; yield to higher priority job
		TC	CHANG1

		CAF	ZERO
		AD	COUNT3
		AD	ONE
		TS	COUNT3

		TC	ENDOFJOB 	; terminate job



		ORG	BANK11		; **** BANK 11 ****

	; TEST CODE - JOB 1
job1		EQU	*
		CAF	ZERO
		AD	COUNT1
		AD	ONE
		TS	COUNT1
		NOOP			; ignore skip

		CCS	newJob		; yield to higher priority job
		TC	CHANG1

		TC	job1

		ORG	BANK12		; **** BANK 12 ****

	; TEST CODE - JOB 2
job2		EQU	*
		CAF	ZERO
		AD	COUNT2
		AD	ONE
		TS	COUNT2
		NOOP			; ignore skip

		CCS	newJob		; yield to higher priority job
		TC	CHANG1

		TC	job2



