; XCH1 (file:xch1.asm)
; test XCH instruction


		ORG	100	; start of data area
val2		EQU	*	; 100 decimal
		DS	0	; *** stores val1 here ***

		ORG	GOPROG

	; test XCH; assumes that TC works as well.
	;

start		XCH	val1	; put 12345 in reg A
		XCH	val2	; store 12345 in loc 100
              XCH	val3	; put 54321 in reg A
		XCH	val2	; store 12345 in loc 100

end		TC	start

val1		DS	%12345
val3		DS	%54321


