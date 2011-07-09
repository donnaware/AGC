;==========================================================================
; AGC (file:agc.asm)
;
; Version:  1.0
; Author:   John Pultorak
; Date:     6/7/2002
;
; PURPOSE:
; AGC Block I demonstration. Includes most of the AGC operating system:
; WAITLIST, EXEC, PINBALL (DSKY routines), NOUN tables, VERB tables, 
; bank intercommunication routines, the KEY, T3, and T4 interrupt handlers,
; and some dual precision (DP) math routines. 
;
; The interpreter is not currently implemented.
;
; Where available, the source is from the Apollo 8 command module computer (CMC) 
; load (called COLOSSUS). In cases where COLOSSUS source is not available, 
; functionally equivalent code was constructed using COLOSSUS calling and return 
; parameters and according to specifications in the technical reports given below.
;
; OPERATION:
; TBD.
;
; ERRATA:
; - Adapted for the AGC4R assembler. The assembler directives and syntax
; differ somewhat from the original AGC assembler.
; - some of the original source was missing from the COLOSSUS listing and
; had to be reverse engineered. Those portions probably differ somewhat
; from the original code in implementation, but should be functionally
; identical.
; - because the COLOSSUS source is for a block II AGC, but the AGC
; implemented here is block I, about 5% of COLOSSUS had to be translated
; to equivalent block I code.
;
; SOURCES:
; Information on the Block I architecture: instruction set, instruction
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
;
;	E, C. Hall, "Journey to the Moon: The History of the Apollo 
;		Guidance Computer", AIAA, Reston VA, 1996.
;
; AGC software information was obtained from:
;
;	AGC Block II COLOSSUS rev 249 assembly listing, Oct 28, 1968. (A
;		listing of the 1st 50% of the build. It encludes the entire
;		eraseable memory, restart initialization, T4RUPT, and the
;		entire set of DSKY routines. About 5% of instructions
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
;		portions of the dual precision (DP) math library.
;
;==========================================================================

		INCL	doc.asm

	; ERASEABLE MEMORY DECLARATIONS

		ORG	BANK0		; immediately following counters
		INCL	waitlist_e.asm	; WAITLIST variables
		INCL	exec_e.asm	; EXEC variables
		INCL	dsky_e.asm	; DSKY variables

	; FIXED MEMORY DECLARATIONS

		ORG	EXTENDER
		DS	%47777		; needed for EXTEND

;--------------------------------------------------------------------------
; RESTART/INTERRUPT ENTRY POINTS
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


	; restore Q and A registers and resume

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
		TCR	WL_TIME3task	; handle T3RUPT for WAITLIST
		TC	endRUPT

goER		EQU	*
		TC	endRUPT

goDS		EQU	*
		TCR	T4PROG		; handle T4RUPT for DSKY display
		TC	endRUPT

goKEY		EQU	*
		TCR	KEYPROG		; handle keyrupt for keyboard entry
		TC	endRUPT

goUP		EQU	*
		TC	endRUPT

;--------------------------------------------------------------------------
; FIXED MEMORY CONSTANTS
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
ELEVEN		DS	11

	; must be in reverse order. Pinball treats this as a table
	; and indexes thru it.

BIT15		DS	%40000
BIT14		DS	%20000
BIT13		DS	%10000
BIT12		DS	%04000
BIT11		DS	%02000
BIT10		DS	%01000
BIT9		DS	%00400
BIT8		DS	%00200
BIT7		DS	%00100
BIT6		DS	%00040
BIT5		DS	%00020
BIT4		DS	%00010
BIT3		DS	%00004
BIT2		DS	%00002
BIT1		DS	%00001

LOW7		DS	%00177

bankAddr	DS	%6000		; fixed-switchable addr range starts here
lowAddr		DS	%1777		; mask for 10-bit address
OCT1400		DS	%1400

NOUTCON		DS	11

POSMAX		DS	%37777

;-------------------------------------------------------------------------
; CLRMEM - INITIALIZE ERASEABLE MEMORY
;
; Uses QRUPT and ARUPT as scratchpad. This is OK, because interrupts
; are disabled anyway. All eraseable memory above the AGC clock (TIME1,
; TIME2) is cleared. The AGC clock is not cleared because this might
; be a restart or a startup from standby mode.
;-------------------------------------------------------------------------

CLRMEM		EQU	*
		XCH	Q
		TS	QRUPT		; save return address

		XCH	CLRMEM_WC	; init count of words to clear
		TS	ARUPT

CLRMEM_CHK	EQU	*
		CCS	ARUPT
		TC	CLRMEM_WORD
		TC	QRUPT		; return

CLRMEM_WORD	EQU	*
		TS	ARUPT
		CAF	CLRMEM_VAL
		INDEX	ARUPT
		TS	CLRMEM_BADDR	; clear a word
		TC	CLRMEM_CHK	; done?

CLRMEM_VAL	EQU	ZERO		; set memory to this value
CLRMEM_BADDR	EQU	TIME3		; base address to clear
CLRMEM_WC	DS	%1777-TIME3+1	; clear everything >= TIME3


;-------------------------------------------------------------------------
; FRESH START
;
; AGC starts executing here, following power-up, or restart.
;-------------------------------------------------------------------------

V37BANK		DS	%10000		; BANK (4) containg PREMM1, FCADRMM1
SAMASK		DS	%37600		; mask to zero lower 7 bits


goMAIN		EQU	*
SLAP1		EQU	goMAIN		; entry for V36 (fresh start request)

		INHINT

	; First, check for standby operation. Loosely based on the standby 
	; algorithm in R-393. Probably should flash the 'computer activity'
	; light as well.

		CAF	BIT8		; add 2 to 7th power to AGC clock
		AD	TIME1
		TS	TIME1

		CAF	ZERO		; skipped on ovf and C(A) set to 1
		AD	TIME2		; bump TIME2 with overflow, if any
		TS	TIME2

		CAF	SAMASK		; zero the LSBs of TIME1
		MASK	TIME1
		TS	TIME1

		XCH	ofbit		; enable standby operation
		TS	OUT1

		TC	CLRMEM		; clear everything but the AGC clock

	; set fresh start major mode to P00 (AGC CMC idle)

		CAF	V37BANK
		TS	BANK		; bank for major mode tables

		CAF	NOV37MM		; assumes BANK is set (above)
		TS	MINDEX		; index to P00


goMMchange	EQU	*
		INHINT			; inhibit interrupts

	; Initialize WAITLIST and EXEC eraseable memory. Initialize DSKY eraseable
	; memory (but don't initialize BANK or MINDEX; they are used to start the
	; main job for this major mode.

		TCR	EX_initEX	; initialize EXEC
		TCR	WL_initWL	; initialize WAITLIST
		TCR	DK_initDK	; initialize DSKY

	; Start the major mode job. This is modified from COLOSSUS because block I
	; doesn't have E-bank and my SPVAC interface is a little different from the 
	; original. The references to PREMM1 and FCADRMM1 assume that the BANK is
	; set to the one containing those tables.

V37XEQ		EQU	*
		INHINT
		INDEX	MINDEX
		CAF	PREMM1
		TS	MMTEMP

		MASK	HI5		; obtain priority bits 15-11
		TC	RIGHT5
		TC	RIGHT5		; shift right to bits 5-1
		TS	NEWPRIO		; store PRIO for SPVAC

		INDEX	MINDEX
		CAF	FCADRMM1

		TC	SPVAC		; job CADR in C(A), job prio in NEWPRIO

V37XEQC		EQU	*
		CAF	ZERO		; was CA MMTEMP in Block II
		AD	MMTEMP		; upon return from FINDVAC, place the
		MASK	LOW7		; new MM in MODREG (the low 7 bits of
		TC	NEWMODEA	; PHSERDT1)

		TC	RELDSP		; release display

	; Start the EXEC.

		TC	EX_exec		; never returns


;-------------------------------------------------------------------------
; AGC LIBRARIES
;
; System services in fixed-fixed memory.
;-------------------------------------------------------------------------

		INCL	waitlist_f.asm	; WAITLIST, incl. T3RUPT handler
		INCL	exec_f.asm	; EXEC
		INCL	bank_f.asm	; bank intercommunication routines
		INCL	T4rupt_f.asm	; T4RUPT handler
		INCL	keyrupt_f.asm	; KEYRUPT handler
		INCL	math_f.asm	; DP math routines

BANKFF_1	EQU	*


;-------------------------------------------------------------------------
; PINBALL
;
; Now, do the "pinball game" (DSKY) routines.
;
; Mimic the bank assignments in COLOSSUS. Since this is a block I AGC that
; has fewer banks, different bank numbers are used, but the sequence and
; relative allocation of routines to various banks is preserved.
;-------------------------------------------------------------------------

	; don't change BANK04_1 without also changing V37BANK

BANK04_1	EQU	BANK4		; was BANK 04 in COLOSSUS

BANK40_1	EQU	BANK5		; was BANK 40 in COLOSSUS
BANK41_1	EQU	BANK6		; was BANK 41 in COLOSSUS
BANK42_1	EQU	BANK7		; was BANK 42 in COLOSSUS
BANK43_1	EQU	BANK10		; was BANK 43 in COLOSSUS

	; start of COLOSSUS routines

		ORG	BANK04_1	; COLOSSUS pp. 192-204
		INCL	bank04_1.asm
BANK04_2	EQU	*

		ORG	BANK40_1	; COLOSSUS pp. 310-317
		INCL	bank40_1.asm
BANK40_2	EQU	*

		ORG	BANK41_1	; COLOSSUS pp. 318-329
		INCL	bank41_1.asm
BANK41_2	EQU	*

		ORG	BANK40_2	; COLOSSUS pp. 330-332
		INCL	bank40_2.asm
BANK40_3	EQU	*

		ORG	BANK42_1	; COLOSSUS pp. 333-336
		INCL	bank42_1.asm
BANK42_2	EQU	*

		ORG	BANK40_3	; COLOSSUS pp. 336
		INCL	bank40_3.asm
BANK40_4	EQU	*

		ORG	BANK41_2	; COLOSSUS pp. 337-342
		INCL	bank41_2.asm
BANK41_3	EQU	*

		ORG	BANK40_4	; COLOSSUS pp. 343-346
		INCL	bank40_4.asm
BANK40_5	EQU	*

		ORG	BANK42_2
BANK42_3	EQU	*

		ORG	BANK41_3
		INCL	bank41_3.asm	; COLOSSUS pp. 349-351
BANK41_4	EQU	*

		ORG	BANKFF_1
		INCL	bankff_1.asm	; COLOSSUS pp. 351
BANKFF_2	EQU	*

		ORG	BANK41_4
		INCL	bank41_4.asm	; COLOSSUS pp. 352
BANK41_5	EQU	*

		ORG	BANK40_5	; COLOSSUS pp. 353-355
		INCL	bank40_5.asm
BANK40_6	EQU	*

		ORG	BANK41_5	; COLOSSUS pp. 355-356
		INCL	bank41_5.asm
BANK41_6	EQU	*

		ORG	BANK40_6	; COLOSSUS pp. 356-358
		INCL	bank40_6.asm
BANK40_7	EQU	*

		ORG	BANKFF_2	; COLOSSUS pp. 358
		INCL	bankff_2.asm
BANKFF_3	EQU	*

		ORG	BANK41_6	; COLOSSUS pp. 359-360
		INCL	bank41_6.asm
BANK41_7	EQU	*

		ORG	BANK40_7	; COLOSSUS pp. 360-362
		INCL	bank40_7.asm
BANK40_8	EQU	*

		ORG	BANKFF_3	; COLOSSUS pp. 363-364
		INCL	bankff_3.asm
BANKFF_4	EQU	*

		ORG	BANK41_7	; COLOSSUS pp. 365-366
		INCL	bank41_7.asm
BANK41_8	EQU	*

		ORG	BANKFF_4	; COLOSSUS pp. 366-368
		INCL	bankff_4.asm
BANKFF_5	EQU	*

		ORG	BANK04_2	; COLOSSUS pp. 369
		INCL	bank04_2.asm
BANK04_3	EQU	*

		ORG	BANK40_8	; COLOSSUS pp. 369-371
		INCL	bank40_8.asm
BANK40_8a	EQU	*

		ORG	BANKFF_5	; COLOSSUS pp. 372-376
		INCL	bankff_5.asm
BANKFF_5a	EQU	*

		ORG	BANK40_8a	; COLOSSUS pp. 376
		INCL	bank40_8a.asm
BANK40_9	EQU	*

		ORG	BANKFF_5a	; COLOSSUS pp. 376-378
		INCL	bankff_5a.asm
BANKFF_6	EQU	*

		ORG	BANK41_8	; COLOSSUS pp. 379-380
		INCL	bank41_8.asm
BANK41_9	EQU	*

		ORG	BANK40_9	; COLOSSUS pp. 381-382
		INCL	bank40_9.asm
BANK40_10	EQU	*

	; end of PINBALL routines

	; PINBALL NOUN tables

		ORG	BANK42_3
		INCL	bank42_3.asm	; COLOSSUS pp. 263-279
BANK42_4	EQU	*

	; extended verb tables

		ORG	BANK43_1
		INCL	bank43_1.asm	; COLOSSUS pp. 230-232
BANK43_2	EQU	*


;--------------------------------------------------------------------------
; TEST JOBS & TASKS
;--------------------------------------------------------------------------

		ORG	BANKFF_6

;--------------------------------------------------------------------------
; MAJOR MODES
;--------------------------------------------------------------------------

		ORG	BANK11

;--------------------------------------------------------------------------
; P00 CMC IDLE PROGRAM 
; 
; Does nothing
;--------------------------------------------------------------------------

P00		EQU	*

	; Start any jobs or tasks needed at AGC initialization.

		CAF	time1		; add a test task
		TC	WAITLIST
		CADR	task1		; 14-bit task address
		TC	ENDOFJOB


	; TEST CODE - task started by P00

time1		DS	1000		; 10 seconds

task1		EQU	*
		XCH	prio1		; job priority
		TC	NOVAC
		CADR	job1		; 14 bit job address

		TC	TASKOVER


	; TEST CODE - job started by task

prio1		DS	%3		; lowest priority

job1		EQU	*
		CAF	ZERO
		AD	%53
		AD	ONE
		TS	%53		; incr data at this address
		TC	ENDOFJOB

;--------------------------------------------------------------------------
; P01 DEMO PROGRAM 
; 
; Calls pinball: verb 1, noun 4.
;--------------------------------------------------------------------------

nvcode1		DS	%0204		; verb 01, noun 04
restart1_addr	DS	P01_restart
tcadr1		DS	%42


P01		EQU	*
		CAF	tcadr1		; load 'machine address to be specified'
		TS	MPAC+2


P01_restart	EQU	*
		CAF	nvcode1
		TC	NVSUB

		TC	*+2		; display busy
		TC	ENDOFJOB	; execution of verb/noun succeeded

		CAF	restart1_addr
		TC	NVSUBUSY	; go to sleep until display released

		TC	ENDOFJOB	; error: another job is already waiting


;--------------------------------------------------------------------------
; P02 DEMO PROGRAM 
; 
; Calls pinball: verb 21, noun 2.
;
; Sleeps if DSKY is busy until KEYREL. Executes verb 21, noun 2 to do
; an external load. Then it sleeps with ENDIDLE until the user loads
; the data or terminatest the load with PROCEED or TERMINATE.
; NOTE: routines that call ENDIDLE must be in fixed-switchable memory
;--------------------------------------------------------------------------

nvcode2		DS	%05202		; verb 21, noun 02
restart2_addr	DS	P02_restart
tcadr2		DS	%42


P02		EQU	*
		CAF	tcadr2
		TS	MPAC+2

P02_restart	EQU	*
		CAF	nvcode2
		TC	NVSUB

		TC	*+2		; display busy
		TC	P02_wait	; execution of verb/noun succeeded

		CAF	restart2_addr
		TC	NVSUBUSY	; go to sleep until display released
		TC	ENDOFJOB	; another job is already sleeping

P02_wait	EQU	*
		TC	ENDIDLE
		TC	P02_ter		; terminate
		TC	P02_pwd		; proceed without data
		CAF	ONE		; data in
		TS	%43		; set loc=1
		TC	ENDOFJOB

P02_pwd		EQU	*		; proceed without data
		CAF	TWO
		TS	%43		; set loc=2
		TC	ENDOFJOB

P02_ter		EQU	*		; terminate
		CAF	THREE
		TS	%43		; set loc=3
		TC	ENDOFJOB


;--------------------------------------------------------------------------
; P03 DEMO PROGRAM 
; 
; Nearly identical to P02, except that the job does not go to sleep
; waiting for the load with ENDIDLE. Instead, it busy-waits on LOADSTAT.
; NOTE: routines that call ENDIDLE must be in fixed-switchable memory
;--------------------------------------------------------------------------

nvcode3		DS	%05202		; verb 21, noun 02
restart3_addr	DS	P03_restart
tcadr3		DS	%42


P03		EQU	*
		CAF	tcadr3
		TS	MPAC+2

P03_restart	EQU	*
		CAF	nvcode3
		TC	NVSUB

		TC	*+2		; display busy
		TC	P03_wait	; execution of verb/noun succeeded

		CAF	restart3_addr
		TC	NVSUBUSY	; go to sleep until display released
		TC	ENDOFJOB	; another job is already sleeping

P03_wait	EQU	*
		CCS	LOADSTAT
		TC	P03_pwd		; >0, verb "proceed w/o data" has been keyed in
		TC	P03_yield	; +0, waiting for data
		TC	P03_ter		; <0, verb "terminate" has been keyed in
		NOOP			; -0, load has been completed

		CAF	ONE		; data in
		TS	%43		; set loc=1
		TC	ENDOFJOB

P03_yield	EQU	*
		CAF	ONE
		AD	%43
		TS	%43		; incr loc while busy-waiting

		CCS	newJob		; yield to higher priority job?
		TC	CHANG1		; yes
		TC	P03_wait	; no, keep busy-waiting

P03_pwd	EQU	*			; proceed without data
		CAF	TWO
		TS	%43		; set loc=2
		TC	ENDOFJOB

P03_ter		EQU	*		; terminate
		CAF	THREE
		TS	%43		; set loc=3
		TC	ENDOFJOB


;--------------------------------------------------------------------------
; P04 DEMO PROGRAM 
; 
; Calls pinball: monitor verb 11, noun 04.
;--------------------------------------------------------------------------

nvcode4		DS	%02604		; verb 11, noun 04
restart4_addr	DS	P04_restart
tcadr4		DS	%42
;mon_option	DS	%6
mon_option	DS	%2206


P04		EQU	*
		CAF	tcadr4		; load 'machine address to be specified'
		TS	MPAC+2


P04_restart	EQU	*
		CAF	mon_option	; paste verb 09, blank R2, R3
		TS	NVSUB_L

		CAF	nvcode4
		TC	NVMONOPT	; was NVSUB

		TC	*+2		; display busy
		TC	ENDOFJOB	; execution of verb/noun succeeded

		CAF	restart4_addr
		TC	NVSUBUSY	; go to sleep until display released

		TC	ENDOFJOB	; error: another job is already waiting


;--------------------------------------------------------------------------
; P78 DEMO PROGRAM 
; 
;--------------------------------------------------------------------------

P78		EQU	*
		CAF	ZERO
		AD	%51
		AD	ONE
		TS	%51		; incr data at this address
		TC	ENDOFJOB

;--------------------------------------------------------------------------
; P79 DEMO PROGRAM 
; 
;--------------------------------------------------------------------------

P79		EQU	*
		CAF	ZERO
		AD	%52
		AD	ONE
		TS	%52		; incr data at this address
		TC	ENDOFJOB


