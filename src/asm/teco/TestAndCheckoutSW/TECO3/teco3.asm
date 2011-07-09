; TECO3 (file:teco3.asm)
;
; PURPOSE:
; Test and checkout program for the Block 1 Apollo Guidance Computer.
; Tests editing registers: CYR, SR, CYL, SL.
;
; OPERATION:
; Enters an infinite loop at the end of the test. The A register contains 
; the code for the test that failed, or the PASS code if all tests 
; succeeded. See test codes below.
;
START		EQU	%00
CYRtst		EQU	%01	; CYR check failed
SRtst		EQU	%02	; SR check failed
CYLtst		EQU	%03	; CYL check failed
SLtst		EQU	%04	; SL check failed

PASS		EQU	%12345	; PASSED all checks
	; ----------------------------------------------

		ORG	EXTENDER
		DS	%47777	; needed for EXTEND

	; ----------------------------------------------
	; ERASEABLE MEMORY -- DATA SEGMENT

		ORG	%100	; start of data area
curtest		DS	START	; current test
savQ		DS	%0

	; CYR test values
CYRval		DS	%0	; current test value
iCYR		DS	%0	; current index

	; SR test values
SRval		DS	%0	; current test value
iSR		DS	%0	; current index

	; CYL test values
CYLval		DS	%0	; current test value
iCYL		DS	%0	; current index

	; SL test values
SLval		DS	%0	; current test value
iSL		DS	%0	; current index

	; ----------------------------------------------
	; ENTRY POINTS

	; program (re)start
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

	; ----------------------------------------------
	; MAIN PROGRAM

goMAIN		EQU	*
		INHINT		; disable interrupts

		TCR	begin

	; Test extracode instructions.
		TCR	chkCYR
		TCR	chkSR
		TCR	chkCYL
		TCR	chkSL

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
	; TEST CYR EDITING FUNCTION SUBROUTINE
	; Rotate a test value right through CYR 15 times.
	; Test the value against an expected value for each time.
	; After 15 rotations, the value should equal the initial
	; value.

CYRcode		DS	CYRtst	; code for this test

	; CYR test values
CYRinit		DS	%03431	; init test value
CYRindx		DS	14	; loop CYRindx+1 times

	; check CYR against these values
CYRbase		EQU	*
		DS	%03431	; check #0 (back to start)
		DS	%07062	; check #1
		DS	%16144	; check #2
		DS	%34310	; check #3
		DS	%70620	; check #4
		DS	%61441	; check #5
		DS	%43103	; check #6
		DS	%06207	; check #7
		DS	%14416	; check #8
		DS	%31034	; check #9
		DS	%62070	; check #10
		DS	%44161	; check #11
		DS	%10343	; check #12
		DS	%20706	; check #13
		DS	%41614	; check #14

chkCYR		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	CYRcode
		TS	curtest	; set current test code to this test

		XCH	CYRinit	; init value to rotate
		TS	CYRval

		XCH	CYRindx	; load init index

CYRloop		EQU	*
		TS	iCYR	; save index

	; rotate A right (CYR)
		XCH	CYRval
		TS	CYR	; rotate
		XCH	CYR	; put result in A
		TS	CYRval

	; verify C(A)
		COM		; get -A
		INDEX	iCYR
		AD	CYRbase	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
		
	; loop back to test next value
		CCS	iCYR	; done?
		TC	CYRloop	; not yet, do next check

		XCH	savQ
		TS	Q	; restore return address
		RETURN

	; ----------------------------------------------
	; TEST SR EDITING FUNCTION SUBROUTINE
	; Shift a test value right through SR 15 times.
	; Test the value against an expected value for each time.
	; After 15 shifts, the value should equal the sign (SG).

SRcode		DS	SRtst	; code for this test

	; SR test values
SRinitP		DS	%03431	; positive init test value
SRinitN		DS	%44346	; negative init test value
SRindx		DS	14	; loop SRindx+1 times

	; check SR against these values (positive)
SRbaseP		EQU	*
		DS	%00000	; check #0 (back to start)
		DS	%00000	; check #1
		DS	%00000	; check #2
		DS	%00000	; check #3
		DS	%00000	; check #4
		DS	%00001	; check #5
		DS	%00003	; check #6
		DS	%00007	; check #7
		DS	%00016	; check #8
		DS	%00034	; check #9
		DS	%00070	; check #10
		DS	%00161	; check #11
		DS	%00343	; check #12
		DS	%00706	; check #13
		DS	%01614	; check #14

	; check SR against these values (negative)
SRbaseN		EQU	*
		DS	%77777	; check #0 (back to start)
		DS	%77777	; check #1
		DS	%77776	; check #2
		DS	%77774	; check #3
		DS	%77771	; check #4
		DS	%77762	; check #5
		DS	%77744	; check #6
		DS	%77710	; check #7
		DS	%77621	; check #8
		DS	%77443	; check #9
		DS	%77107	; check #10
		DS	%76216	; check #11
		DS	%74434	; check #12
		DS	%71071	; check #13
		DS	%62163	; check #14

chkSR		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	SRcode
		TS	curtest	; set current test code to this test

	; TEST 1: shift a postive value.
		XCH	SRinitP	; init value to shift
		TS	SRval

		XCH	SRindx	; load init index


SRloopP		EQU	*
		TS	iSR	; save index

	; shift A right (SR)
		XCH	SRval
		TS	SR	; shift
		XCH	SR	; put result in A
		TS	SRval

	; verify C(A)
		COM		; get -A
		INDEX	iSR
		AD	SRbaseP	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
		
	; loop back to test next value
		CCS	iSR	; done?
		TC	SRloopP	; not yet, do next check

	; TEST 2: shift a negative value
		XCH	SRinitN	; init value to shift
		TS	SRval

		XCH	SRindx	; load init index


SRloopN		EQU	*
		TS	iSR	; save index

	; shift A left (SR)
		XCH	SRval
		TS	SR	; shift
		XCH	SR	; put result in A
		TS	SRval

	; verify C(A)
		COM		; get -A
		INDEX	iSR
		AD	SRbaseN	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
		
	; loop back to test next value
		CCS	iSR	; done?
		TC	SRloopN	; not yet, do next check

		XCH	savQ
		TS	Q	; restore return address
		RETURN

	; ----------------------------------------------
	; TEST CYL EDITING FUNCTION SUBROUTINE
	; Rotate a test value left through CYL 15 times.
	; Test the value against an expected value for each time.
	; After 15 rotations, the value should equal the initial
	; value.

CYLcode		DS	CYLtst	; code for this test

	; CYL test values
CYLinit		DS	%03431	; init test value
CYLindx		DS	14	; loop CYLindx+1 times

	; check CYL against these values
CYLbase		EQU	*
		DS	%03431	; check #0 (back to start)
		DS	%41614	; check #1
		DS	%20706	; check #2
		DS	%10343	; check #3
		DS	%44161	; check #4
		DS	%62070	; check #5
		DS	%31034	; check #6
		DS	%14416	; check #7
		DS	%06207	; check #8
		DS	%43103	; check #9
		DS	%61441	; check #10
		DS	%70620	; check #11
		DS	%34310	; check #12
		DS	%16144	; check #13
		DS	%07062	; check #14

chkCYL		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	CYLcode
		TS	curtest	; set current test code to this test

		XCH	CYLinit	; init value to rotate
		TS	CYLval

		XCH	CYLindx	; load init index

CYLloop		EQU	*
		TS	iCYL	; save index

	; rotate A left (CYL)
		XCH	CYLval
		TS	CYL	; rotate
		XCH	CYL	; put result in A
		TS	CYLval

	; verify C(A)
		COM		; get -A
		INDEX	iCYL
		AD	CYLbase	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
		
	; loop back to test next value
		CCS	iCYL	; done?
		TC	CYLloop	; not yet, do next check

		XCH	savQ
		TS	Q	; restore return address
		RETURN

	; ----------------------------------------------
	; TEST SL EDITING FUNCTION SUBROUTINE
	; Shift a test value left through SL 15 times.
	; Test the value against an expected value for each time.
	; After 15 shifts, the value should equal the sign (SG).

SLcode		DS	SLtst	; code for this test

	; SL test values
SLinitP		DS	%03431	; positive init test value
SLinitN		DS	%44346	; negative init test value
SLindx		DS	14	; loop SLindx+1 times

	; check SL against these values (positive)
SLbaseP		EQU	*
		DS	%00000	; check #0 (back to start)
		DS	%00000	; check #1
		DS	%20000	; check #2
		DS	%10000	; check #3
		DS	%04000	; check #4
		DS	%22000	; check #5
		DS	%31000	; check #6
		DS	%14400	; check #7
		DS	%06200	; check #8
		DS	%03100	; check #9
		DS	%21440	; check #10
		DS	%30620	; check #11
		DS	%34310	; check #12
		DS	%16144	; check #13
		DS	%07062	; check #14

	; check SL against these values (negative)
SLbaseN		EQU	*
		DS	%77777	; check #0 (back to start)
		DS	%77777	; check #1
		DS	%57777	; check #2
		DS	%67777	; check #3
		DS	%73777	; check #4
		DS	%55777	; check #5
		DS	%46777	; check #6
		DS	%63377	; check #7
		DS	%71577	; check #8
		DS	%74677	; check #9
		DS	%56337	; check #10
		DS	%47157	; check #11
		DS	%43467	; check #12
		DS	%61633	; check #13
		DS	%50715	; check #14

chkSL		EQU	*
		XCH	Q
		TS	savQ	; save return address

		CAF	SLcode
		TS	curtest	; set current test code to this test

	; TEST 1: shift a postive value.
		XCH	SLinitP	; init value to shift
		TS	SLval

		XCH	SLindx	; load init index


SLloopP		EQU	*
		TS	iSL	; save index

	; shift A left (SL)
		XCH	SLval
		TS	SL	; shift
		XCH	SL	; put result in A
		TS	SLval

	; verify C(A)
		COM		; get -A
		INDEX	iSL
		AD	SLbaseP	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
		
	; loop back to test next value
		CCS	iSL	; done?
		TC	SLloopP	; not yet, do next check

	; TEST 2: shift a negative value
		XCH	SLinitN	; init value to shift
		TS	SLval

		XCH	SLindx	; load init index

SLloopN		EQU	*
		TS	iSL	; save index

	; shift A left (SL)
		XCH	SLval
		TS	SL	; shift
		XCH	SL	; put result in A
		TS	SLval

	; verify C(A)
		COM		; get -A
		INDEX	iSL
		AD	SLbaseN	; put (-A) + expected value in A
		CCS	A	; compare
		TC	fail	; >0 (A < expected value)
		TC	fail	; +0
		TC	fail	; <0 (A > expected value)
		
	; loop back to test next value
		CCS	iSL	; done?
		TC	SLloopN	; not yet, do next check

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



