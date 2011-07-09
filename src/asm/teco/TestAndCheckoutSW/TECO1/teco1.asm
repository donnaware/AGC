; TECO1 (file:teco1.asm)
;
; PURPOSE:
; Test and checkout program for the Block 1 Apollo Guidance Computer.
; Tests basic instructions: TC, CCS, INDEX, XCH, CS, TS, AD, MASK.
;
; OPERATION:
; Enters an infinite loop at the end of the test. The A register contains 
; the code for the test that failed, or the PASS code if all tests 
; succeeded. See test codes below.
;
START		EQU	%00
TCtst		EQU	%01	; TC check failed
CCStst		EQU	%02	; CCS check failed
INDEXtst	EQU	%03	; INDEX check failed
XCHtst		EQU	%04	; XCH check failed
CStst		EQU	%05	; CS check failed
TStst		EQU	%06	; TS check failed
ADtst		EQU	%07	; AD check failed
MASKtst	EQU	%10	; MASK check failed
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
CCSk		DS	%0	; CCS test
INDXval	DS	 0	; INDEX test

	; XCH test
	; pre-set in erasable memory because we don't
	; want to use XCH to initialize them prior to testing XCH.
XCHkP0		DS	+0
XCHkM0		DS	-0
XCHkalt1	DS	%52525	; alternating bit pattern 1
XCHkalt2	DS	%25252	; alternating bit pattern 2

TSk		DS	-0	; TS test
ADk		DS	-0	; AD test

	; ----------------------------------------------
	; ENTRY POINTS
	; ----------------------------------------------
		ORG	GOPROG
		TC	goMAIN

	; ----------------------------------------------
	; interrupt service entry points
	; ----------------------------------------------
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
		INHINT			; disable interrupts
		TCR	begin		; Begin Test basic instructions.
		TCR	chkTC		;
		TCR	chkCCS		;
		TCR	chkINDEX	;
		TCR	chkXCH		;
		TCR	chkCS		;
		TCR	chkTS		;
		TCR	chkAD		;
		TCR	chkMASK	;

	; ----------------------------------------------
	; Passed all tests.
	; ----------------------------------------------
		TCR	finish
passend	EQU	*
		TC	passend	; finished, TC trap

	; ----------------------------------------------
	; Failure Exit Point
	; ----------------------------------------------
fail		EQU	*
		XCH	curtest	; load last passed test into A
		TS	curtest
end		EQU	*
		TC	end	; finished, TC trap

	; ----------------------------------------------
	; INITIALIZE FOR START OF TESTING
	; ----------------------------------------------
STRTcode	DS	START
begin		EQU	*
		XCH	STRTcode
		TS	curtest	; set current test code to START
		RETURN

	; ----------------------------------------------
	; PASSED ALL TESTS!
	; ----------------------------------------------
PASScode	DS	PASS
finish		EQU	*
		CAF	PASScode
		TS	curtest	; set current test code to PASS
		RETURN
	; ----------------------------------------------

		
	; ----------------------------------------------
	; TEST TC INSTRUCTION SUBROUTINE
	; L:	TC	K
	; Verifies the following:
	; - Set C(Q) = TC L+1
	; - Take next instruction from K, and proceed from there.
	; ----------------------------------------------
TCcode		DS	TCtst	; code for this test
Qtest		DS	TCret1	; expected return address
chkTC		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	TCcode
		TS	curtest	; set current test code to this test

	; attempt a jump
		TC	*+2	; make test jump
TCret1		TC	fail	; failed to jump

	; verify correct return address in Q
		CS	Q
		AD	Qtest	; put (-Q) + val2 in A
		CCS	A	; A = DABS
		TC	fail	; >0 (Q < Qtest)
		TC	fail	; +0 (never happens)
		TC	fail	; <0 (Q > Qtest)

	; passed the test
		XCH	savQ
		TS	Q	; restore return address
		RETURN

	; ----------------------------------------------
	; TEST CCS INSTRUCTION SUBROUTINE
	; L:	CCS	K
	; Verifies the following:
	; - take next instruction from L+n and proceed from there, where:
	; -- n = 1 if C(K) > 0
	; -- n = 2 if C(K) = +0
	; -- n = 3 if C(K) < 0
	; -- n = 4 if C(K) = -0
	; - set C(A) = DABS[C(K)], where DABS (diminished abs value):
	; -- DABS(a) = abs(a) - 1,	if abs(a) > 1
	; -- DABS(a) = +0, 		if abs(a) <= 1
	; ----------------------------------------------
CCScode		DS	CCStst	; code for this test
	; test values (K)
CCSkM2		DS	-2
CCSkM1		DS	-1
CCSkM0		DS	-0
CCSkP0		DS	+0
CCSkP1		DS	+1
CCSkP2		DS	+2

	; expected DABS values
CCSdM2		DS	1 	; for K=-2, DABS = +1
CCSdM1		DS	0	; for K=-1, DABS = +0
CCSdM0		DS	0	; for K=-0, DABS = +0
CCSdP0		DS	0	; for K=+0, DABS = +0
CCSdP1		DS	0	; for K=+1, DABS = +0
CCSdP2		DS	1	; for K=+2, DABS = +1

chkCCS		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	CCScode
		TS	curtest	; set current test code to this test

	; set K to -2 and execute CCS: 
	; check for correct branch
		CAF	CCSkM2	; set K = -2
		TS	CCSk
		CCS	CCSk	; A = DABS[C(K)]
		TC	fail	; K > 0
		TC	fail	; K= +0
		TC	*+2	; K < 0
		TC	fail	; K= -0
	; check for correct DABS in A (for K=-2, it should be 1)
		COM		; 1's compliment of A
		AD	CCSdM2	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; set K to -1 and execute CCS: 
	; check for correct branch
		CAF	CCSkM1	; set K = -1
		TS	CCSk
		CCS	CCSk	; A = DABS[C(K)]
		TC	fail	; K > 0
		TC	fail	; K= +0
		TC	*+2	; K < 0
		TC	fail	; K= -0
	; check for correct DABS in A (for K=-1, it should be +0)
		COM		; 1's compliment of A
		AD	CCSdM1	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; set K to -0 and execute CCS: 
	; check for correct branch
		CAF	CCSkM0	; set K = -0
		TS	CCSk
		CCS	CCSk	; A = DABS[C(K)]
		TC	fail	; K > 0
		TC	fail	; K= +0
		TC	fail	; K < 0
	; check for correct DABS in A (for K=-0, it should be +0)
		COM		; 1's compliment of A
		AD	CCSdM0	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; set K to +0 and execute CCS: 
	; check for correct branch
		CAF	CCSkP0	; set K = +0
		TS	CCSk
		CCS	CCSk	; A = DABS[C(K)]
		TC	fail	; K > 0
		TC	*+3	; K= +0
		TC	fail	; K < 0
		TC	fail	; K= -0
	; check for correct DABS in A (for K=+0, it should be +0)
		COM		; 1's compliment of A
		AD	CCSdP0	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; set K to +1 and execute CCS: 
	; check for correct branch
		CAF	CCSkP1	; set K = +1
		TS	CCSk
		CCS	CCSk	; A = DABS[C(K)]
		TC	*+4	; K > 0
		TC	fail	; K= +0
		TC	fail	; K < 0
		TC	fail	; K= -0
	; check for correct DABS in A (for K=+1, it should be +0)
		COM		; 1's compliment of A
		AD	CCSdP1	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; set K to +2 and execute CCS: 
	; check for correct branch
		CAF	CCSkP2	; set K = +2
		TS	CCSk
		CCS	CCSk	; A = DABS[C(K)]
		TC	*+4	; K > 0
		TC	fail	; K= +0
		TC	fail	; K < 0
		TC	fail	; K= -0
	; check for correct DABS in A (for K=+2, it should be +1)
		COM		; 1's compliment of A
		AD	CCSdP2	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; passed the test
		XCH	savQ
		TS	Q	; restore return address
		RETURN

	; ----------------------------------------------
	; TEST INDEX INSTRUCTION SUBROUTINE
	; L:	INDEX	K	(where K != 0025)
	; Verifies the following;
	; - Use the sum of C(L+1) + C(K) as the next instruction
	; -- just as if that sum had been taken from L+1.
	; ----------------------------------------------
INDXcode	DS	INDEXtst	; code for this test
INDXst		DS	5	; somewhere in fixed memory

INDXbas		DS	0	; base address for indexing
		DS	1
		DS	2
		DS	3
		DS	4
		DS	5

chkINDEX	EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	INDXcode
		TS	curtest	; set current test code to this test

	; Decrementing loop
	;	- always executes at least once (tests at end of loop)
	;	- loops 'INDXst+1' times; decrements INDXval

		XCH	INDXst	; initialize loop counter

INDXlop	EQU	*
		TS	INDXval

	; perform indexed CAF of values in INDXbas array;
	; index values range from 5 to 0
		INDEX	INDXval
		CAF	INDXbas

	; verify value retrieved using INDEX matches expected value
		COM		; get -A
		AD	INDXval	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

		CCS	INDXval	; done?
		TC	INDXlop	; not yet

		XCH	savQ
		TS	Q	; restore return address
		RETURN
	; ----------------------------------------------
	; TEST XCH INSTRUCTION SUBROUTINE
	; L:	XCH	K
	; Verifies the following:
	; - set C(A) = b(K)
	; - set C(K) = b(A)
	; - take next instruction from L+1
	; ----------------------------------------------
XCHcode	DS	XCHtst	; code for this test
	; XCH test values
XCHfP0		DS	+0
XCHfM0		DS	-0
XCHfalt1	DS	%52525	; alternating bit pattern 1
XCHfalt2	DS	%25252	; alternating bit pattern 2

chkXCH		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	XCHcode
		TS	curtest	; set current test code to this test

	; test - initial conditions: K=+0, A=-0
	; initialize A
		CS	XCHfP0
	; exchange A and K
		XCH	XCHkP0
	; test contents of A for expected value
		COM		; get -A
		AD	XCHfP0	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; test contents of K for expected value
		CS	XCHkP0	; get -A
		AD	XCHfM0	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; test - initial conditions: K=-0, A=+0
	; initialize A
		CS	XCHfM0
	; exchange A and K
		XCH	XCHkM0
	; test contents of A for expected value
		COM		; get -A
		AD	XCHfM0	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; test contents of K for expected value
		CS	XCHkM0	; get -A
		AD	XCHfP0	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; test - initial conditions: K=52525, A=25252
	; initialize A
		CS	XCHfalt1
	; exchange A and K
		XCH	XCHkalt1
	; test contents of A for expected value
		COM		; get -A
		AD	XCHfalt1	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; test contents of K for expected value
		CS	XCHkalt1	; get -A
		AD	XCHfalt2	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; test - initial conditions: K=25252, A=52525
	; initialize A
		CS	XCHfalt2
	; exchange A and K
		XCH	XCHkalt2
	; test contents of A for expected value
		COM		; get -A
		AD	XCHfalt2	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; test contents of K for expected value
		CS	XCHkalt2	; get -A
		AD	XCHfalt1	; put (-A) + expected value in A
		CCS	A	; A = DABS
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; passed the test
		XCH	savQ
		TS	Q	; restore return address
		RETURN

	; ----------------------------------------------
	; TEST CS INSTRUCTION SUBROUTINE
	; L:	CS	K
	; Verifies the following:
	; - Set C(A) = -C(K)
	; - Take next instruction from L+1
	; ----------------------------------------------
CScode		DS	CStst	; code for this test
	; test values (K)
CSkP0		DS	+0
CSkM0		DS	-0
CSkalt1	DS	%52525	; 1's C of CSkalt2
CSkalt2	DS	%25252	; 1's C of CSkalt1

chkCS		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	CScode
		TS	curtest	; set current test code to this test

	; clear and subtract +0
		CS	CSkP0	; load 1's compliment of K into A
		AD	CSkP0	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; clear and subtract -0
		CS	CSkM0	; load 1's compliment of K into A
		AD	CSkM0	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; clear and subtract alternating bit pattern %52525
		CS	CSkalt1	; load 1's compliment of K into A
		AD	CSkalt1	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; clear and subtract alternating bit pattern %25252
		CS	CSkalt2	; load 1's compliment of K into A
		AD	CSkalt2	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; passed the test
		XCH	savQ
		TS	Q	; restore return address
		RETURN

	; ----------------------------------------------
	; TEST TS INSTRUCTION SUBROUTINE
	; L;	TS 	K
	; Verifies the following:
	; - Set C(K) = b(A)
	; - If b(A) contains no overflow, 
	; -- C(A) = b(A); take next instruction from L+1
	; - If b(A) has positive overflow, C(A) = 000001; 
	; -- take next instruction from L+2
	; - If b(A) has negative overflow, C(A) = 177776; 
	; -- take next instruction from L+2
	; ----------------------------------------------
TScode		DS	TStst	; code for this test
TSone		DS	+1
TSzero		DS	+0
TSmzero		DS	-0
TSmone		DS	-1
TSkP1		DS	%37777	; TEST1: largest positive number w/no overflow
TSkM1		DS	%40000	; TEST2: largest negative number w/no overflow

chkTS		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	TScode
		TS	curtest	; set current test code to this test

	; initialize TSk to -0
		CAF	TSmzero
		XCH	TSk

	; TEST 1: store positive number, no overflow
		CAF	TSkP1
		TS	TSk
		TC	*+2	; no overflow
		TC	fail	; overflow
	; verify C(A) = b(A)
		COM		; get -A
		AD	TSkP1	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; verify C(K) = b(A)
		CS	TSkP1	; get -expected value
		AD	TSk	; put (-expected value) + C(K) into A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; TEST 2: store negative number, no overflow
		CAF	TSkM1
		TS	TSk
		TC	*+2	; no overflow
		TC	fail	; overflow
	; verify C(A) = b(A)
		COM		; get -A
		AD	TSkM1	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; verify C(K) = b(A)
		CS	TSkM1	; get -expected value
		AD	TSk	; put (-expected value) + C(K) into A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
		
	; TEST 3: store positive number, overflow
		CAF	TSkP1	; get largest positive number
		AD	TSone	; make it overflow; A = negative overflow
		TS	TSk	; store the positive overflow
		TC	fail	; no overflow
	; verify C(A) = 000001
		COM		; get -A
		AD	TSone	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; verify C(K) = positive overflow
		CS	TSzero	; get -expected value
		AD	TSk	; put (-expected value) + C(K) into A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; TEST 4: store negative number, overflow
		CAF	TSkM1	; get largest negative number
		AD	TSmone	; make it overflow; A = negative overflow
		TS	TSk	; store the negative overflow
		TC	fail	; no overflow
	; verify C(A) = 177776
		COM		; get -A
		AD	TSmone	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; verify C(K) = negative overflow
		CS	TSmzero	; get -expected value
		AD	TSk	; put (-expected value) + C(K) into A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

		XCH	savQ
		TS	Q	; restore return address
		RETURN

	; ----------------------------------------------
	; TEST AD INSTRUCTION SUBROUTINE
	; L:	AD	K
	; Verifies the following:
	; - Set C(A) = b(A) + C(K)
	; - Take next instruction from L+1
	; - if C(A) has positive overflow,
	; -- increment overflow counter by 1
	; - if C(A) has negative overflow,
	; -- decrement overflow counter by 1
	; ----------------------------------------------
ADcode		DS	ADtst	; code for this test
ADplus0	DS	+0
ADplus1	DS	1
ADmin1		DS	-1

AD25252	DS	%25252	; +10922 decimal
AD12525	DS	%12525	; +5461 decimal
AD37777	DS	%37777	; largest positive number
AD12524	DS	%12524	; positive overflow of %25252+%25252

AD52525	DS	%52525	; -10922 decimal
AD65252	DS	%65252	; -5461 decimal
AD40000	DS	%40000	; largest negative number
AD65253	DS	%65253	; negative overflow of %52525+65252

chkAD		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	ADcode
		TS	curtest	; set current test code to this test

	; TEST1: sum positive, no overflow
	; add: %25252 + %12525 = %37777 (sign + 14 magnitude)
		CAF	AD25252
		AD	AD12525
	; verify C(A) = %37777
		COM		; get -A
		AD	AD37777	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; TEST2: sum negative, no overflow (sign + 14 magnitude)
	; add: %52525 + %65252 = %40000
		CAF	AD52525
		AD	AD65252
	; verify C(A) = %40000
		COM		; get -A
		AD	AD40000	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; TEST3: sum positive, overflow
	; initialize overflow counter and positive overflow storage
		CAF	ADplus0
		TS	OVFCNTR
		TS	ADk
	; add: %25252 + %25252 = %52524 (sign + 14 magnitude)
		CAF	AD25252
		AD	AD25252
		TS	ADk	; store positive overflow
		TC	fail
	; verify ADk = %12524
		CS	ADk	; get -A
		AD	AD12524	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; verify overflow counter =%00001
		CS	OVFCNTR	; get -A
		AD	ADplus1	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

	; TEST4: sum negative, overflow
		CAF	ADplus0
		TS	OVFCNTR
		TS	ADk
	; add: %52525 + %52525 = %25253 (sign + 14 magnitude)
		CAF	AD52525
		AD	AD52525
		TS	ADk	; store negative overflow
		TC	fail
	; verify ADk = %65253
		CS	ADk	; get -A
		AD	AD65253	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
	; verify overflow counter =%77776
		CS	OVFCNTR	; get -A
		AD	ADmin1	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)

		XCH	savQ
		TS	Q	; restore return address
		RETURN

	; ----------------------------------------------
	; TEST MASK INSTRUCTION SUBROUTINE
	; L:	MASK	K
	; Verifies the following:
	; - Set C(A) = b(A) & C(K)
	; ----------------------------------------------
MASKcode	DS	MASKtst	; code for this test o10
MASK1		DS	%46314		;  
MASK2		DS	%25252		; Mask value 2
MASKval	DS	%04210		; expected result of MASK1 & MASK2

chkMASK	EQU	*
		XCH	Q		; get return address
		TS	savQ		; save return address
		CAF	MASKcode	; Load error code
		TS	curtest	; set current test code to this test

	; perform logical and of MASK1 and MASK2
		CAF	MASK1		; Load Mask 1
		MASK	MASK2		; Test MASK Instruction

	; verify C(A) = b(A) & C(K)
		COM			; get -A
		AD	MASKval	; put (-A) + expected value in A
		CCS	A		; compare
		TC	fail		; >0 (A < expected value)
		TC	fail		; +0
		TC	fail		; <0 (A > expected value)

	; passed the test
		XCH	savQ		; retreive return address
		TS	Q		; restore return address
		RETURN			; return to caller

	; ----------------------------------------------
	; INTERRUPT SERVICE ROUTINE
	; ----------------------------------------------
goT3		EQU	*
goER		EQU	*
goDS		EQU	*
goKEY		EQU	*
goUP		EQU	*
endRUPT	EQU	*
		XCH	QRUPT	; restore Q
		TS	Q
		XCH	ARUPT	; restore A
		RESUME		; finished, go back

	; ----------------------------------------------
	; END OF PROGRAM
	; ----------------------------------------------


