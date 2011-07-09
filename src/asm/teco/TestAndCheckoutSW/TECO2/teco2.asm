; TECO2 (file:teco2.asm)

; PURPOSE:
; Test and checkout program for the Block 1 Apollo Guidance Computer.
; Tests extracode instructions: MP, DV, SU
;
; OPERATION:
; Enters an infinite loop at the end of the test. The A register contains 
; the code for the test that failed, or the PASS code if all tests 
; succeeded. See test codes below.
START		EQU	%00
MPtst		EQU	%01	; MP check failed
DVtst		EQU	%02	; DV check failed
SUtst		EQU	%03	; SU check failed
OVFCNTR	EQU	%00034	; overflow counter

PASS		EQU	%12345	; PASSED all checks

	; ----------------------------------------------
		ORG	EXTENDER
		DS	%47777	; needed for EXTEND

	; ----------------------------------------------
	; ERASEABLE MEMORY -- DATA SEGMENT
	; ----------------------------------------------
		ORG	%100	; start of data area
curtest	DS	START	; current test
savQ		DS	%0
MPindex	DS	%0	; MP test
MPXTND		DS	%0	; indexed extend
DVsavA		DS	%0	; DV test
DVindex	DS	%0
DVXTND		DS	%0	; indexed extend
SUk		DS	-0	; SU test

	; ----------------------------------------------
	; ENTRY POINTS
	; ----------------------------------------------
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
	; FIXED MEMORY -- SHARED DATA SEGMENT
	; MAIN PROGRAM

	; ----------------------------------------------
goMAIN		EQU	*
		INHINT		; disable interrupts
		TCR	begin

	; Test extracode instructions.
		TCR	chkMP
		TCR	chkDV
		TCR	chkSU

	; Passed all tests.
		TCR	finish

fail		EQU	*
		XCH	curtest	; load last passed test into A
		TS	curtest

end		EQU	*
		TC	end	; finished, TC trap

	; ----------------------------------------------
	; INITIALIZE FOR START OF TESTING

STRTcode	DS	START

begin		EQU	*
		XCH	STRTcode
		TS	curtest	; set current test code to START
		RETURN
		
	; ----------------------------------------------
	; TEST MP INSTRUCTION SUBROUTINE
	; L:	MP	K
	; Verifies the following
	; - Set C(A,LP) = b(A) * C(K)
	; - Take next instruction from L+1
	; ----------------------------------------------

MPcode		DS	MPtst	; code for this test

	; MP test values
	;                          
MPstart	DS	31	; loop MPstart+1 times

	; C(A) test values
mp1		EQU	*
	; check boundary conditions
		DS	%37777	; check #00 (+16383 * +16383)
		DS	%37777	; check #01 (+16383 * -16383)
		DS	%40000	; check #02 (-16383 * +16383)
		DS	%40000	; check #03 (-16383 * -16383)
		DS	%00000	; check #04 (+0 * +0)
		DS	%00000	; check #05 (+0 * -0)
		DS	%77777	; check #06 (-0 * +0)
		DS	%77777	; check #07 (-0 * -0)
	; randomly selected checks (one word product)
		DS	%00007	; check #08 (7 * 17)
		DS	%00021	; check #09 (17 * 7)
		DS	%00035	; check #10 (29 * 41)
		DS	%00051	; check #11 (41 * 29)
		DS	%00065	; check #12 (53 * 67)
		DS	%00103	; check #13 (67 * 53)
		DS	%00117	; check #14 (79 * 97)
		DS	%00141	; check #15 (97 * 79)
		DS	%00153	; check #16 (107 * 127)
		DS	%00177	; check #17 (127 * 107)
	; randomly selected checks (two word product)
		DS	%00375	; check #18 (253 * 197)
		DS	%00305	; check #19 (197 * 253)
		DS	%00655	; check #20 (429 * 351)
		DS	%00537	; check #21 (351 * 429)
		DS	%02455	; check #22 (1325 * 1067)
		DS	%02053	; check #23 (1067 * 1325)
		DS	%11151	; check #24 (4713 * 3605)
		DS	%07025	; check #25 (3605 * 4713)
		DS	%20032	; check #26 (8218 * 7733)
		DS	%17065	; check #27 (7733 * 8218)
		DS	%30273	; check #28 (12475 * 11501)
		DS	%26355	; check #29 (11501 * 12475)
		DS	%37553	; check #30 (16235 * 15372)
		DS	%36014	; check #31 (15372 * 16235)

	; C(K) test values
mp2		EQU	*
	; check boundary conditions
		DS	%37777	; check #00 (+16383 * +16383)
		DS	%40000	; check #01 (+16383 * -16383)
		DS	%37777	; check #02 (-16383 * +16383)
		DS	%40000	; check #03 (-16383 * -16383)
		DS	%00000	; check #04 (+0 * +0)
		DS	%77777	; check #05 (+0 * -0)
		DS	%00000	; check #06 (-0 * +0)
		DS	%77777	; check #07 (-0 * -0)
	; randomly selected checks (one word product)
		DS	%00021	; check #08 (7 * 17)
		DS	%00007	; check #09 (17 * 7)
		DS	%00051	; check #10 (29 * 41)
		DS	%00035	; check #11 (41 * 29)
		DS	%00103	; check #12 (53 * 67)
		DS	%00065	; check #13 (67 * 53)
		DS	%00141	; check #14 (79 * 97)
		DS	%00117	; check #15 (97 * 79)
		DS	%00177	; check #16 (107 * 127)
		DS	%00153	; check #17 (127 * 107)
	; randomly selected checks (two word product)
		DS	%00305	; check #18 (253 * 197)
		DS	%00375	; check #19 (197 * 253)
		DS	%00537	; check #20 (429 * 351)
		DS	%00655	; check #21 (351 * 429)
		DS	%02053	; check #22 (1325 * 1067)
		DS	%02455	; check #23 (1067 * 1325)
		DS	%07025	; check #24 (4713 * 3605)
		DS	%11151	; check #25 (3605 * 4713)
		DS	%17065	; check #26 (8218 * 7733)
		DS	%20032	; check #27 (7733 * 8218)
		DS	%26355	; check #28 (12475 * 11501)
		DS	%30273	; check #29 (11501 * 12475)
		DS	%36014	; check #30 (16235 * 15372)
		DS	%37553	; check #31 (15372 * 16235)

	; A = upper product
MPchkA		EQU	*
	; check boundary conditions
		DS	%37776	; check #00
		DS	%40001	; check #01
		DS	%40001	; check #02
		DS	%37776	; check #03
		DS	%00000	; check #04
		DS	%77777	; check #05
		DS	%77777	; check #06
		DS	%00000	; check #07
	; randomly selected checks
		DS	%00000	; check #08 (7 * 17)
		DS	%00000	; check #09 (17 * 7)
		DS	%00000	; check #10 (29 * 41)
		DS	%00000	; check #11 (41 * 29)
		DS	%00000	; check #12 (53 * 67)
		DS	%00000	; check #13 (67 * 53)
		DS	%00000	; check #14 (79 * 97)
		DS	%00000	; check #15 (97 * 79)
		DS	%00000	; check #16 (107 * 127)
		DS	%00000	; check #17 (127 * 107)
	; randomly selected checks (two word product)
		DS	%00003	; check #18 (253 * 197)
		DS	%00003	; check #19 (197 * 253)
		DS	%00011	; check #20 (429 * 351)
		DS	%00011	; check #21 (351 * 429)
		DS	%00126	; check #22 (1325 * 1067)
		DS	%00126	; check #23 (1067 * 1325)
		DS	%02015	; check #24 (4713 * 3605)
		DS	%02015	; check #25 (3605 * 4713)
		DS	%07446	; check #26 (8218 * 7733)
		DS	%07446	; check #27 (7733 * 8218)
		DS	%21065	; check #28 (12475 * 11501)
		DS	%21065	; check #29 (11501 * 12475)
		DS	%35600	; check #30 (16235 * 15372)
		DS	%35600	; check #31 (15372 * 16235)

	; LP = lower product
MPchkLP		EQU	*
	; check boundary conditions
		DS	%00001	; check #00
		DS	%77776	; check #01
		DS	%77776	; check #02
		DS	%00001	; check #03
		DS	%00000	; check #04
		DS	%77777	; check #05
		DS	%77777	; check #06
		DS	%00000	; check #07
	; randomly selected checks
		DS	%00167	; check #08 (7 * 17)
		DS	%00167	; check #09 (17 * 7)
		DS	%02245	; check #10 (29 * 41)
		DS	%02245	; check #11 (41 * 29)
		DS	%06737	; check #12 (53 * 67)
		DS	%06737	; check #13 (67 * 53)
		DS	%16757	; check #14 (79 * 97)
		DS	%16757	; check #15 (97 * 79)
		DS	%32425	; check #16 (107 * 127)
		DS	%32425	; check #17 (127 * 107)
	; randomly selected checks (two word product)
		DS	%01261	; check #18 (253 * 197)
		DS	%01261	; check #19 (197 * 253)
		DS	%06063	; check #20 (429 * 351)
		DS	%06063	; check #21 (351 * 429)
		DS	%11217	; check #22 (1325 * 1067)
		DS	%11217	; check #23 (1067 * 1325)
		DS	%00235	; check #24 (4713 * 3605)
		DS	%00235	; check #24 (3605 * 4713)
		DS	%30542	; check #26 (8218 * 7733)
		DS	%30542	; check #27 (7733 * 8218)
		DS	%00437	; check #28 (12475 * 11501)
		DS	%00437	; check #29 (11501 * 12475)
		DS	%06404	; check #30 (16235 * 15372)
		DS	%06404	; check #31 (15372 * 16235)

chkMP		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	MPcode
		TS	curtest	; set current test code to this test

	; Decrementing loop
	;	- always executes at least once (tests at end of loop)		
	;	- loops 'MPstart+1' times; decrements MPindex
		XCH	MPstart	; initialize loop counter

	;------------------------------
	; MP check starts here
	; uses MPindex to access test values
	;------------------------------
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

		XCH	savQ
		TS	Q	; restore return address
		RETURN



	; ----------------------------------------------
	; TEST DV INSTRUCTION SUBROUTINE
	; L:	DV	K
	; Verifies the following:
	; - Set C(A) = b(A) / C(K)
	; - Set C(Q) = - abs(remainder)
	; - Set C(LP) > 0 if quotient is positive
	; - Set C(LP) < 0 if quotient is negative
	; - Take next instruction from L+1

DVcode		DS	DVtst	; code for this test

	; DV test values
	;                          
DVstart		DS	31	; loop DVstart+1 times

	; C(A) test values
div1		EQU	*
		DS	%00000	; check #00 (+0/+0)
		DS	%00000	; check #01 (+0/-0)
		DS	%77777	; check #02 (-0/+0)
		DS	%77777	; check #03 (-0/-0)

		DS	%00000	; check #04 (+0/+1)
		DS	%00000	; check #05 (+0/-1)
		DS	%77777	; check #06 (-0/+1)
		DS	%77777	; check #07 (-0/-1)

		DS	%00000	; check #08 (+0/+16383)
		DS	%00000	; check #09 (+0/-16383)
		DS	%77777	; check #10 (-0/+16383)
		DS	%77777	; check #11 (-0/-16383)

		DS	%37776	; check #12 (+16382/+16383)
		DS	%37776	; check #13 (+16382/-16383)
		DS	%40001	; check #14 (-16382/+16383)
		DS	%40001	; check #15 (-16382/-16383)

		DS	%37777	; check #16 (+16383/+16383)
		DS	%37777	; check #17 (+16383/-16383)
		DS	%40000	; check #18 (-16383/+16383)
		DS	%40000	; check #19 (-16383/-16383)

		DS	%00001	; check #20 (+1/+2)
		DS	%00001	; check #21 (+1/+3)
		DS	%00001	; check #22 (+1/+4)
		DS	%00001	; check #23 (+1/+5)
		DS	%00001	; check #24 (+1/+6)
		DS	%00001	; check #25 (+1/+7)
		DS	%00001	; check #26 (+1/+8)

		DS	%00001	; check #27 (+1/+6)
		DS	%00002	; check #28 (+2/+12)
		DS	%00004	; check #29 (+4/+24)
		DS	%00010	; check #30 (+8/+48)
		DS	%00020	; check #31 (+16/+96)

	; C(K) test values
div2		EQU	*
		DS	%00000	; check #00 (+0/+0)
		DS	%77777	; check #01 (+0/-0)
		DS	%00000	; check #02 (-0/+0)
		DS	%77777	; check #03 (-0/-0)

		DS	%00001	; check #04 (+0/+1)
		DS	%77776	; check #05 (+0/-1)
		DS	%00001	; check #06 (-0/+1)
		DS	%77776	; check #07 (-0/-1)

		DS	%37777	; check #08 (+0/+16383)
		DS	%40000	; check #09 (+0/-16383)
		DS	%37777	; check #10 (-0/+16383)
		DS	%40000	; check #11 (-0/-16383)

		DS	%37777	; check #12 (+16382/+16383)
		DS	%40000	; check #13 (+16382/-16383)
		DS	%37777	; check #14 (-16382/+16383)
		DS	%40000	; check #15 (-16382/-16383)

		DS	%37777	; check #16 (+16383/+16383)
		DS	%40000	; check #17 (+16383/-16383)
		DS	%37777	; check #18 (-16383/+16383)
		DS	%40000	; check #19 (-16383/-16383)

		DS	%00002	; check #20 (+1/+2)
		DS	%00003	; check #21 (+1/+3)
		DS	%00004	; check #22 (+1/+4)
		DS	%00005	; check #23 (+1/+5)
		DS	%00006	; check #24 (+1/+6)
		DS	%00007	; check #25 (+1/+7)
		DS	%00010	; check #26 (+1/+8)

		DS	%00006	; check #27 (+1/+6)
		DS	%00014	; check #28 (+2/+12)
		DS	%00030	; check #29 (+4/+24)
		DS	%00060	; check #30 (+8/+48)
		DS	%00140	; check #31 (+16/+96)

	; A = quotient
DVchkA		EQU	*
		DS	%37777	; check #00 (+0/+0)
		DS	%40000	; check #01 (+0/-0)
		DS	%40000	; check #02 (-0/+0)
		DS	%37777	; check #03 (-0/-0)

		DS	%00000	; check #04 (+0/+1)
		DS	%77777	; check #05 (+0/-1)
		DS	%77777	; check #06 (-0/+1)
		DS	%00000	; check #07 (-0/-1)

		DS	%00000	; check #08 (+0/+16383)
		DS	%77777	; check #09 (+0/-16383)
		DS	%77777	; check #10 (-0/+16383)
		DS	%00000	; check #11 (-0/-16383)

		DS	%37776	; check #12 (+16382/+16383)
		DS	%40001	; check #13 (+16382/-16383)
		DS	%40001	; check #14 (-16382/+16383)
		DS	%37776	; check #15 (-16382/-16383)

		DS	%37777	; check #16 (+16383/+16383)
		DS	%40000	; check #17 (+16383/-16383)
		DS	%40000	; check #18 (-16383/+16383)
		DS	%37777	; check #19 (-16383/-16383)

		DS	%20000	; check #20 (+1/+2)
		DS	%12525	; check #21 (+1/+3)
		DS	%10000	; check #22 (+1/+4)
		DS	%06314	; check #23 (+1/+5)
		DS	%05252	; check #24 (+1/+6)
		DS	%04444	; check #25 (+1/+7)
		DS	%04000	; check #26 (+1/+8)

		DS	%05252	; check #27 (+1/+6)
		DS	%05252	; check #28 (+2/+12)
		DS	%05252	; check #29 (+4/+24)
		DS	%05252	; check #30 (+8/+48)
		DS	%05252	; check #31 (+16/+96)

	; Q = remainder
DVchkQ		EQU	*
		DS	%77777	; check #00 (+0/+0)
		DS	%77777	; check #01 (+0/-0)
		DS	%77777	; check #02 (-0/+0)
		DS	%77777	; check #03 (-0/-0)

		DS	%77777	; check #04 (+0/+1)
		DS	%77777	; check #05 (+0/-1)
		DS	%77777	; check #06 (-0/+1)
		DS	%77777	; check #07 (-0/-1)

		DS	%77777	; check #08 (+0/+16383)
		DS	%77777	; check #09 (+0/-16383)
		DS	%77777	; check #10 (-0/+16383)
		DS	%77777	; check #11 (-0/-16383)

		DS	%40001	; check #12 (+16382/+16383)
		DS	%40001	; check #13 (+16382/-16383)
		DS	%40001	; check #14 (-16382/+16383)
		DS	%40001	; check #15 (-16382/-16383)

		DS	%40000	; check #16 (+16383/+16383)
		DS	%40000	; check #17 (+16383/-16383)
		DS	%40000	; check #18 (-16383/+16383)
		DS	%40000	; check #19 (-16383/-16383)

		DS	%77777	; check #20 (+1/+2)
		DS	%77776	; check #21 (+1/+3)
		DS	%77777	; check #22 (+1/+4)
		DS	%77773	; check #23 (+1/+5)
		DS	%77773	; check #24 (+1/+6)
		DS	%77773	; check #25 (+1/+7)
		DS	%77777	; check #26 (+1/+8)

		DS	%77773	; check #27 (+1/+6)
		DS	%77767	; check #28 (+2/+12)
		DS	%77757	; check #29 (+4/+24)
		DS	%77737	; check #30 (+8/+48)
		DS	%77677	; check #31 (+16/+96)

	; LP = sign
DVchkLP		EQU	*
		DS	%00001	; check #00 (+0/+0)
		DS	%40000	; check #01 (+0/-0)
		DS	%40001	; check #02 (-0/+0)
		DS	%00001	; check #03 (-0/-0)

		DS	%00001	; check #04 (+0/+1)
		DS	%40000	; check #05 (+0/-1)
		DS	%40001	; check #06 (-0/+1)
		DS	%00001	; check #07 (-0/-1)

		DS	%00001	; check #08 (+0/+16383)
		DS	%40000	; check #09 (+0/-16383)
		DS	%40001	; check #10 (-0/+16383)
		DS	%00001	; check #11 (-0/-16383)

		DS	%00001	; check #12 (+16382/+16383)
		DS	%40000	; check #13 (+16382/-16383)
		DS	%40001	; check #14 (-16382/+16383)
		DS	%00001	; check #15 (-16382/-16383)

		DS	%00001	; check #16 (+16383/+16383)
		DS	%40000	; check #17 (+16383/-16383)
		DS	%40001	; check #18 (-16383/+16383)
		DS	%00001	; check #19 (-16383/-16383)

		DS	%00001	; check #20 (+1/+2)
		DS	%00001	; check #21 (+1/+3)
		DS	%00001	; check #22 (+1/+4)
		DS	%00001	; check #23 (+1/+5)
		DS	%00001	; check #24 (+1/+6)
		DS	%00001	; check #25 (+1/+7)
		DS	%00001	; check #26 (+1/+8)

		DS	%00001	; check #27 (+1/+6)
		DS	%00001	; check #28 (+2/+12)
		DS	%00001	; check #29 (+4/+24)
		DS	%00001	; check #30 (+8/+48)
		DS	%00001	; check #31 (+16/+96)


chkDV		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	DVcode
		TS	curtest	; set code identifying current test


		; Decrementing loop
		;	- always executes at least once (tests at end of loop)		
		;	- loops 'DVstart+1' times; decrements DVindex
		XCH	DVstart	; initialize loop counter

		;------------------------------

		; DV check starts here
		; uses DVindex to access test values
DVloop		EQU	*
		TS	DVindex	; save new index

		CAF	EXTENDER
		AD	DVindex
		TS	DVXTND

		INDEX	DVindex
		CAF	div1
		INDEX	DVXTND	; EXTEND using DVindex
		DV	div2
		TS	DVsavA
		
	; verify C(Q)
		CS	Q	; get -A
		INDEX	DVindex
		AD	DVchkQ	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; verify C(A)
		CS	DVsavA	; get -A
		INDEX	DVindex
		AD	DVchkA	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; verify C(LP)
		CS	LP	; get -A
		INDEX	DVindex
		AD	DVchkLP	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

		; end of DV check
		;------------------------------

		CCS	DVindex	; done?
		TC	DVloop	; not yet, do next check

		XCH	savQ
		TS	Q	; restore return address
		RETURN
	; ----------------------------------------------
	; TEST SU INSTRUCTION SUBROUTINE
	; L:	SU	K
	; Verifies the following:
	; - Set C(A) = b(A) - C(K)
	; - Take next instruction from L+1
	; - if C(A) has positive overflow,
	; -- increment overflow counter by 1
	; - if C(A) has negative overflow,
	; -- decrement overflow counter by 1

SUcode		DS	SUtst	; code for this test

SUplus0		DS	+0
SUplus1		DS	1
SUmin1		DS	-1

SU25252		DS	%25252	; +10922 decimal
SU12525		DS	%12525	; +5461 decimal
SU37777		DS	%37777	; largest positive number
SU12524		DS	%12524	; positive overflow of %25252+%25252

SU52525		DS	%52525	; -10922 decimal
SU65252		DS	%65252	; -5461 decimal
SU40000		DS	%40000	; largest negative number
SU65253		DS	%65253	; negative overflow of %52525+65252

chkSU		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	SUcode
		TS	curtest	; set current test code to this test

	; NOTE: these test are similar to the checks for AD, but
	; the AD augend value has been changed to negative and AD has
	; been changed to SU. The results produced by this change
	; are identical to AD, and so the checks are the same.

	; TEST1: difference positive, no overflow
	; sub: %25252 - %65252 = %37777 (sign + 14 magnitude)
		CAF	SU25252
		EXTEND
		SU	SU65252
	; verify C(A) = %37777
		COM		; get -A
		AD	SU37777	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; TEST2: difference negative, no overflow (sign + 14 magnitude)
	; sub: %52525 - %12525 = %40000
		CAF	SU52525
		EXTEND
		SU	SU12525
	; verify C(A) = %40000
		COM		; get -A
		AD	SU40000	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; TEST3: difference positive, overflow
	; initialize overflow counter and positive overflow storage
		CAF	SUplus0
		TS	OVFCNTR
		TS	SUk
	; sub: %25252 - %52525 = %52524 (sign + 14 magnitude)
		CAF	SU25252
		EXTEND
		SU	SU52525
		TS	SUk	; store positive overflow
		TC	fail
	; verify SUk = %12524
		CS	SUk	; get -A
		AD	SU12524	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; verify overflow counter =%00001
		CS	OVFCNTR	; get -A
		AD	SUplus1	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; TEST4: difference negative, overflow
		CAF	SUplus0
		TS	OVFCNTR
		TS	SUk
	; add: %52525 + %25252 = %25253 (sign + 14 magnitude)
		CAF	SU52525
		EXTEND
		SU	SU25252
		TS	SUk	; store negative overflow
		TC	fail
	; verify SUk = %65253
		CS	SUk	; get -A
		AD	SU65253	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; verify overflow counter =%77776
		CS	OVFCNTR	; get -A
		AD	SUmin1	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

		XCH	savQ
		TS	Q	; restore return address
		RETURN
	; ----------------------------------------------
	; PASSED ALL TESTS!

PASScode	DS	PASS

finish		EQU	*
		CAF	PASScode
		TS	curtest	; set current test code to PASS
		RETURN

	; ----------------------------------------------
	; INTERRUPT SERVICE ROUTINE

goT3		EQU	*
goER		EQU	*
goDS		EQU	*
goKEY		EQU	*
goUP		EQU	*


endRUPT		EQU	*
		XCH	QRUPT	; restore Q
		TS	Q
		XCH	ARUPT	; restore A
		RESUME		; finished, go back



