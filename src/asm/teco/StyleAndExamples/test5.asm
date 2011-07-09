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

cntr		DS	%0	; loop counter
disp		DS	%0	; displacement added to base address
val		DS	%0	; current value

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


	; ----------------------------------------------
	; FIXED MEMORY -- DATA SEGMENT

baseadr		EQU	%45	; starting address

initcnt		DS	%5	; number of times to loop
one		DS	%1

initval		DS	%4	; initial value stored at index 0
incrval		DS	%1	;
initdsp		DS	%0

ofbit		DS	%200	; OUT1, bit 8 initiates standby

	; ----------------------------------------------
	; MAIN PROGRAM

goMAIN		EQU	*
	; first, check for standby operation
		XCH	ofbit
		TS	OUT1

	; initialize everything prior to looping.
	;

		XCH	initdsp	; copy initdsp to disp
		TS	initdsp
		TS	disp

		XCH	initval	; copy initval to val
		TS	initval
		TS	val

		XCH	initcnt	; copy initcnt to cntr
		TS	initcnt

	; loop starts here.
begin		EQU	*
		RELINT		; enable RUPT

		TS	cntr

		XCH	val

	; store the accumulator at the indexed location
	;
		INDEX	disp
		TS	baseadr

	; change the value used to initialize memory
	;
		TCR	newval	; jump sub to get new value
		TS	val

	; bump the displacement to increment the effective address
	; of the indexed store.
	;
		XCH	disp
		AD	one
		TS	disp

		INHINT		; disable RPUT (to test inhibit)

		CCS	cntr	; done?
		TC	begin	; not yet, go back

end		EQU	*
forever		RELINT		; enable RUPT
		TC	forever	; finished, TC trap
		
	; ----------------------------------------------
	; SUBROUTINE

	; subroutine to get a new value to store in memory.
	; Enter subroutine with old value in 'A'; return with
	; new value in 'A'
	;
newval		EQU	*
		AD	one
		RETURN


	; ----------------------------------------------
	; INTERRUPT SERVICE ROUTINE

ireg		EQU	%43	; reg incremented upon interrupt

goT3		EQU	*
goER		EQU	*
goDS		EQU	*
goKEY		EQU	*
goUP		EQU	*

		XCH	ireg
		AD	one
		TS	ireg

endRUPT		EQU	*
		XCH	QRUPT	; restore Q
		TS	Q
		XCH	ARUPT	; restore A
		RESUME		; finished, go back

