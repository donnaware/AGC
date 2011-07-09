; TECO5 (file:teco5.asm)
;
	; program (re)start
		ORG	GOPROG
		TC	goMAIN

	; interrupt service entry points
		ORG	T3RUPT	; (RUPT1)
		NOOP
		CAF	INTESTV1	; put test value i A
		RESUME

		ORG	DSRUPT	; (RUPT3) aka T4RUPT	
		NOOP
		CAF	INTESTV3	; put test value i A
		RESUME

		ORG	KEYRUPT	; (RUPT4)
		NOOP
		CAF	INTESTV4	; put test value i A
		RESUME

	; MAIN PROGRAM

goMAIN		EQU	*
		NOOP
		INHINT		; disable interrupt
		NOOP
		RELINT		; enable interrupts
infLoop	EQU	*
		NOOP
		TC	infLoop

INTESTV1	DS	%11111	; a test value
INTESTV3	DS	%33333	; a test value
INTESTV4	DS	%44444	; a test value



