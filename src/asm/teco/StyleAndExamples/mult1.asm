; AGC test (file:mult1.asm)
;
; Test values
;
; largest positive value = %037777 (+16383 decimal)
; largest negative value = %040000 (-16383 decimal)

; plus 0 (1's compliment = %000000
; minus0 (1's compliment = %177777

; signs for result in A and LP always agree.
; LP contains 14 LSBs, A contains 14 MSBs and sign.
;
; %037777 * %037777 = %1777700001   Result: A=%037776  LP=%000001
; %037777 * %040000   Result: A=%140001  LP=%177776
; %040000 * %037777   Result: A=%140001  LP=%177776
; %040000 * %040000   Result: A=%037776  LP=%000001

; %000000 * %000000   Result: A=%000000  LP=%000000
; %000000 * %177777   Result: A=%177777  LP=%177777
; %177777 * %000000   Result: A=%177777  LP=%177777
; %177777 * %177777   Result: A=%000000  LP=%000000


		ORG	EXTENDER
		DS	%47777	; needed for EXTEND

		ORG	%100

; ----------------------------------------------
		ORG	GOPROG
		TC	chkMP

	; MP test values
mult1		DS	%00000
mult2		DS	%77777

chkMP		EQU	*

		CAF	mult1
		EXTEND
		MP	mult2

		TC	loop1
	
	; ----------------------------------------------

		ORG	%2100
loop1		EQU	*
		TC	loop1


		ORG	%2400
fail		EQU 	*
loop4		EQU	*
		TC	loop4
