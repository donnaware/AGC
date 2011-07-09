;==========================================================================
; AGC (file:testmath.asm)
;
; Version:	1.0
; Author:	John Pultorak
; Date:		2/03/2002
;
; PURPOSE:
; test math library
;
; OPERATION:
; TBD.
;
;
;==========================================================================

	; ERASEABLE MEMORY DECLARATIONS

		ORG	BANK0		; immediately following counters
		INCL	dsky_e.asm	; DSKY variables

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
BIT5		DS	%00020
BIT7		DS	%00100
BIT11		DS	%02000
BIT12		DS	%04000
BIT14		DS	%20000
BIT15		DS	%40000

bankAddr	DS	%6000		; fixed-switchable addr range starts here
lowAddr		DS	%1777		; mask for 10-bit address
OCT1400		DS	%1400

NOUTCON		DS	11

;-------------------------------------------------------------------------
; MAIN PROGRAM
;
; AGC starts executing here, following power-up, or restart.
;-------------------------------------------------------------------------

VAL		DS	+1
VAL1		DS	%40000		; largest negative value
VAL2		DS	%0

P1		DS	%00001
P0		DS	%00000
PHIGH		DS	%37777

M1		DS	%77776		; -1
M0		DS	%77777
MHIGH		DS	%40000


goMAIN		EQU	*
		INHINT			; inhibit interrupts

		CAF	P1
		TS	MPAC

		CAF	P1
		TS	MPAC+1

		CAF	M0
		TCR	SHORTMP
		

imdone		EQU	*
		TC	imdone
;--------------------------------------------------------------------------

	; library stuff in fixed-fixed.

		INCL	math_f.asm	; DP math routines


;--------------------------------------------------------------------------
; TEST DATA
;--------------------------------------------------------------------------

	