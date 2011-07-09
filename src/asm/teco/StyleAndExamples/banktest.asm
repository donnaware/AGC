; TEST5 (file:test5.asm)
;
; Similar to TEST2, but includes interrupt handlers
; Initialize a block of memory starting at 'baseadr' and extending for
; 'initcnt' words.
;
; Exercise the following instructions (incompletely)
;   TC, CCS, INDEX, XCH, TS, AD
;
; Does not exercise:
;   CS, MASK, MP, DV, SU
;
; includes a subroutine and interrupt handlers


		ORG	EXTENDER
		DS	%47777	; needed for EXTEND

	; ----------------------------------------------
	; ERASEABLE MEMORY -- DATA SEGMENT

		ORG	%100	; start of data area

		INCL	dsky_e.asm


	; ----------------------------------------------
	; MAIN PROGRAM -- ENTRY POINTS

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


;--------------------------------------------------------------------------
; FIXED MEMORY CONSTANTS (shared)
;--------------------------------------------------------------------------

ofbit		DS	%200		; OUT1, bit 8 initiates standby

NEG0		DS	-0
NEG2		DS	-2

ZERO		DS	0
ONE		DS	1
TWO		DS	2
THREE		DS	3
FOUR		DS	4
FIVE		DS	5
SEVEN		DS	7
TEN		DS	10

BIT1		DS	%1
BIT7		DS	%00100
BIT11		DS	%02000
BIT12		DS	%04000
BIT14		DS	%20000
BIT15		DS	%40000

bankAddr	DS	%6000		; fixed-switchable addr range starts here
lowAddr		DS	%1777		; mask for 10-bit address
OCT1400		DS	%1400

NOUTCON		DS	11

	; ----------------------------------------------
	; MAIN PROGRAM

TESTVAL1	EQU	%45
TESTVAL2	EQU	%46
TESTVAL3	EQU	%47
TESTVAL4	EQU	%50
TESTVAL5	EQU	%51
TESTVAL6	EQU	%52

B7ADDR		DS	B7FUNC

goMAIN		EQU	*
	; first, check for standby operation
		XCH	ofbit
		TS	OUT1


		CAF	ZERO
		AD	TESTVAL1
		AD	ONE
		TS	TESTVAL1

		TC	BANKCALL
		DS	B6FUNC

		CAF	ZERO
		AD	TESTVAL3
		AD	ONE
		TS	TESTVAL3
		
		CAF	B7ADDR
		TC	BANKJUMP

forever		TC	forever	; finished, TC trap
		

		INCL	bank_f.asm

	; ----------------------------------------------
	; INTERRUPT SERVICE ROUTINE

ireg		EQU	%43	; reg incremented upon interrupt

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




		ORG	BANK6
B6FUNC		CAF	ZERO
		AD	TESTVAL2
		AD	ONE
		TS	TESTVAL2
		TC	Q
		TC	forever

		ORG	BANK7
B7FUNC		CAF	ZERO
		AD	TESTVAL4
		AD	ONE
		TS	TESTVAL4

		TC	BANKCALL
		DS	B10FUNC
		
		CAF	ZERO
		AD	TESTVAL6
		AD	ONE
		TS	TESTVAL6

		TC	forever

		ORG	BANK10
B10FUNC		CAF	ZERO
		AD	TESTVAL5
		AD	ONE
		TS	TESTVAL5
		TC	Q
		TC	forever
