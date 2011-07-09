; TECO_STBY (file:stby.asm)
;
; Tests the standby operation.

	; program (re)start
		ORG	GOPROG
		TC	goMAIN

ofbit		DS	%200	; OUT1, bit 8 initiates standby


	; MAIN PROGRAM

goMAIN		EQU	*

	; standby is disabled
		NOOP
		NOOP

	; enable standby
		XCH	ofbit
		TS	OUT1

infLoop		EQU	*
		TC	infLoop



