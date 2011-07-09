; CCS1 (file:ccs1.asm)
; test CCS instruction
		ORG	100	; start of data area
val2		DS	-2
		ORG	GOPROG
		XCH	val1	; put val1 in reg A
		CCS	val2	; put DABS of val2 in A
		TC	loc1	; >0
		TC	loc2	; +0
		TC	loc3	; <0
		TC	loc4	; -0
loc1		TC	loc1
loc2		TC	loc2
loc3		TC	loc3
loc4		TC	loc4
;val1		DS	%12345
val1		DS	%00005


