; XCH2 (file:xch2.asm)
; test XCH instruction

		ORG	GOPROG

	; test XCH; assumes that TC works as well.
	;

		XCH	val1	; put val1 in reg A
end		TC	end

val1		DS	%12347

