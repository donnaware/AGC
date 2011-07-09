; XCH2 (file:xch2.asm)
; test XCH instruction

		ORG	$100
val2		DS	%12343


		ORG	GOPROG

	; test XCH; assumes that TC works as well.
	;

		XCH	val1	; put val1 in reg A
		XCH	val2
end		TC	end

val1		DS	%0

