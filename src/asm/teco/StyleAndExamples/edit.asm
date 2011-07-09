; AGC test (file:edit.asm)
;
; Test values
;

		ORG	EXTENDER
		DS	%47777	; needed for EXTEND

		ORG	%100
MPindex		DS	%0
MPXTND		DS	%0	; indexed extend

	; ----------------------------------------------
		ORG	GOPROG
		TC	chkMP

	; MP test values
	;                          
MPstart		DS	7	; loop MPstart+1 times

	; C(A) test values
mp1		EQU	*
		DS	%37777	; check #00
		DS	%37777	; check #01
		DS	%40000	; check #02
		DS	%40000	; check #03
		DS	%00000	; check #04
		DS	%00000	; check #05
		DS	%77777	; check #06
		DS	%77777	; check #07

	; C(K) test values
mp2		EQU	*
		DS	%37777	; check #00
		DS	%40000	; check #01
		DS	%37777	; check #02
		DS	%40000	; check #03
		DS	%00000	; check #04
		DS	%77777	; check #05
		DS	%00000	; check #06
		DS	%77777	; check #07

	; A = upper product
MPchkA		EQU	*
		DS	%37776	; check #00
		DS	%40001	; check #01
		DS	%40001	; check #02
		DS	%37776	; check #03
		DS	%00000	; check #04
		DS	%77777	; check #05
		DS	%77777	; check #06
		DS	%00000	; check #07

	; LP = lower product
MPchkLP		EQU	*
		DS	%00001	; check #00
		DS	%77776	; check #01
		DS	%77776	; check #02
		DS	%00001	; check #03
		DS	%00000	; check #04
		DS	%77777	; check #05
		DS	%77777	; check #06
		DS	%00000	; check #07


chkMP		EQU	*
	; Decrementing loop
	;	- always executes at least once (tests at end of loop)		
	;	- loops 'MPstart+1' times; decrements MPindex
		XCH	MPstart	; initialize loop counter

	;------------------------------
	; MP check starts here
	; uses MPindex to access test values
MPloop		EQU	*
		TS	MPindex	; save new index

		CAF	EXTENDER
		AD	MPindex
		TS	MPXTND

		INDEX	MPindex
		CAF	mp1
		INDEX	MPXTND	; EXTEND using MPindex
		MP	mp2

	; verify C(A)
		COM		; get -A
		INDEX	MPindex
		AD	MPchkA	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; verify C(LP)
		CS	LP	; get -A
		INDEX	MPindex
		AD	MPchkLP	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; end of MP check
	;------------------------------

		CCS	MPindex	; done?
		TC	MPloop	; not yet, do next check

		TC	loop1
	; ----------------------------------------------

		ORG	%2300
loop1		EQU	*
		TC	loop1

		ORG	%2400
fail		EQU	*
		TC	fail
