; TC 2 (file:tc2.asm)
; test TC instruction

		ORG	GOPROG

	; initialize everything prior to looping.
	;

loc1		TC	loc2
		

		ORG	GOPROG+5
loc2		TC	loc1

