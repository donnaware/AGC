; EXEC demonstration (file:execdemo.asm)
;
; Version:	1.0
; Author:	John Pultorak
; Date:		11/11/2001
;
; PURPOSE:
; AGC EXEC demonstration program.
;
; OPERATION:
; TBD.
;
; ERRATA:
; - Written for the AGC4R assembler. The assembler directives and syntax
; differ somewhat from the original AGC assembler.
;
; SOURCES:
; Information on the Block 1 architecture: instruction set, instruction
; sequences, registers, register transfers, control pulses, memory and 
; memory addressing, I/O assignments, interrupts, and involuntary counters
; was obtained from:
;
;	A. Hopkins, R. Alonso, and H. Blair-Smith, "Logical Description 
;		for the Apollo Guidance Computer (AGC4)", R-393, 
;		MIT Instrumentation Laboratory, Cambridge, MA, Mar. 1963.
;
; Supplementary information was obtained from:
;
;	R. Alonso, J. H. Laning, Jr. and H. Blair-Smith, "Preliminary 
;		MOD 3C Programmer's Manual", E-1077, MIT Instrumentation 
;		Laboratory, Cambridge, MA, Nov. 1961.
;
;	B. I. Savage and A. Drake, "AGC4 Basic Training Manual, Volume I", 
;		E-2052, MIT Instrumentation Laboratory, Cambridge, 
;		MA, Jan. 1967.
;
;	E. C. Hall, "MIT's Role in Project Apollo, Volume III, Computer 
;		Subsystem", R-700, MIT Charles Stark Draper Laboratory, 
;		Cambridge, MA, Aug. 1972.
;
;	A. Hopkins, "Guidance Computer Design, Part VI", source unknown.
;
;	A. I. Green and J. J. Rocchio, "Keyboard and Display System Program 
;		for AGC (Program Sunrise)", E-1574, MIT Instrumentation 
;		Laboratory, Cambridge, MA, Aug. 1964.
;
;	E, C. Hall, "Journey to the Moon: The History of the Apollo 
;		Guidance Computer", AIAA, Reston VA, 1996.
;

	; ----------------------------------------------

		ORG	EXTENDER
		DS	%47777		; needed for EXTEND

	; ==============================================
	; ERASEABLE MEMORY:

		ORG	BANK0		; immediately following counters

	; ==============================================
	; EXEC data area
	; ==============================================
	;
MAXJOBS		EQU	7		; max number of jobs

	; job record structure
	; job priority: 0=no job, 1=lowest priority job, 2=...

JOBPRIO		EQU	0		; offset to job priority
JOBADDR		EQU	1		; offset to job address

JRECSZ		EQU	2		; size of job record (words)

	; Array of all job records

EX_jobList	EQU	*
		DS	0		; record 0
		DS	0

		DS	0		; record 1
		DS	0

		DS	0		; record 2
		DS	0

		DS	0		; record 3
		DS	0

		DS	0		; record 4
		DS	0

		DS	0		; record 5
		DS	0

		DS	0		; record 6
		DS	0

EX_curJobPtr	DS	EX_jobList	; pointer to currently running job


CHGJOB		EQU	1		; change jobs at next opportunity
KEEPJOB		EQU	0		; keep the same job
newJob		DS	0		; change flag (set to CHGJOB or KEEPJOB)

EX_AJ_saveQ	DS	0		; return address
EX_AJ_loopCnt	DS	0		; loop counter
EX_AJ_jobPrio	DS	0		; priority of new job
EX_AJ_jobPtr	DS	0		; initialized to EX_jobList at startup

EX_SJ_saveQ	DS	0		; return address
EX_SJ_loopCnt	DS	0		; loop counter
EX_SJ_jobPtr	DS	0		; points to job rec in list

EX_IN_saveQ	DS	0		; return address
EX_IN_loopCnt	DS	0		; loop counter
EX_IN_jobPtr	DS	0		; points to job rec in list

EX_BP_saveQ	DS	0		; return address
EX_BP_jobPtr	DS	0		; points to job rec in list

EX_MN_runAddr	DS	0		; address of job to run

	; ==============================================
	; FIXED MEMORY:

	; ----------------------------------------------
	; EXECUTION ENTRY POINTS
	; ----------------------------------------------

	; program (re)start
		ORG	GOPROG
		TC	goMAIN		; AGC (re)start begins here!

	; interrupt service entry points (H/W interrupt vectors)
		ORG	T3RUPT
		TS	ARUPT		; TIME3 interrupt entry point
		XCH	Q
		TS	QRUPT
		TC	goT3

		ORG	ERRUPT
		TS	ARUPT
		XCH	Q
		TS	QRUPT
		TC	goER

		ORG	DSRUPT		
		TS	ARUPT		; DSKY keyboard interrupt entry point
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
	; FIXED MEMORY CONSTANTS (shared)
	; ----------------------------------------------

ofbit		DS	%200		; OUT1, bit 8 initiates standby
zero		DS	0
one		DS	1
bankAddr	DS	%6000		; fixed-switchable addr range starts here
lowAddr		DS	%1777		; mask for 10-bit address

	; ----------------------------------------------
	; MAIN PROGRAM
	; ----------------------------------------------

goMAIN		EQU	*
		INHINT			; inhibit interrupts

	; first, check for standby operation.
		XCH	ofbit
		TS	OUT1

	; Initialize all EXEC eraseable memory variables
	; in case this is a restart.

		TCR	EX_initEX

	; add some test jobs to the jobList.
		XCH	prio1		; job priority
		TC	EX_addJob
		DS	job1		; 14 bit job address

		XCH	prio2		; job priority
		TC	EX_addJob
		DS	job2		; 14 bit job address

		XCH	prio3		; job priority
		TC	EX_addJob
		DS	job3		; 14 bit job address

	; start the EXEC.
		TC	EX_exec		; never returns

	; ==============================================
	; EXEC constants
	; ----------------------------------------------

EX_jobRecSize	DS	JRECSZ		; size of a job record (words)
EX_jobLstStart	DS	EX_jobList	; starting address for jobList
EX_jobLstEnd	DS	MAXJOBS@JRECSZ+EX_jobList
EX_numJobs	DS	MAXJOBS-1	; init loop counter for all jobs

	; enumerated types for setting change flag:
EX_changeJob	DS	CHGJOB		; change job
EX_keepJob	DS	KEEPJOB		; keep job

	; ----------------------------------------------
	; EX_exec -- EXEC
	;
	; Non-preemptive multitasking routines, originally implemented by J. H. 
	; Laning, Jr. for AGC3 and later adapted for AGC4. Briefly discussed in
	; R-393, which gives some of the software interfaces into the 
	; multitasking. This is my own recreation, and it only includes the job 
	; scheduling. The original EXEC also includes memory management for the 
	; eraseable memory; this is not reproduced here.
	; 
	; Overview: scheduled elements are called 'jobs'. Up to 7 jobs can be 
	; concurrently scheduled. An 8th 'dummy' job is always scheduled. Each 
	; job has an assigned priority (1-n, where 1 is the lowest priority). 
	; The highest priority job always executes. When that job terminates, 
	; the next highest priority job is selected for execution. If several 
	; jobs have the same priority, they are executed round-robin.
	;
	; A job is scheduled for execution by calling 'EX_addJob' and 
	; furnishing the job priority and starting address.
	;	L	XCH	JOB_PRIORITY
	;	L+1	TC	EX_addJob
	;	L+2	DS	JOB_ADDRESS
	;	L+3	... execution resumes here
	;
	; JOB_PRIORITY = a positive integer from 1 - n where a higher number 
	;    indicates higher priority.
	; JOB_ADDRESS = starting address of the job.
	;
	;
	; Jobs terminate themselves by jumping to ENDOFJOB. This removes them 
	; from the scheduler:
	;	TC	ENDOFJOB
	;
	; Jobs can suspend themselves (yield to a higher priority job) by 
	; executing the following sequence:
	;	CCS	newJob
	;	TC	CHANG1
	; If there is no other job of equal or higher priority, the branch is 
	; not taken.
	; ----------------------------------------------
	

	; Add a dummy job (lowest priority) that never terminates.

EX_exec		EQU	*		; entry point
		XCH	dumPrio		; job priority
		TC	EX_addJob
		DS	dumJob		; 14 bit job address
		INHINT			; inhibit RUPTs enab by addJob

	; Find the highest priority job. Return with the job record address 
	; in 'jobCur'

EX_MN_findJob	EQU	*
		TCR	EX_selJob

	; check for NULL job (should not happen)

		CCS	EX_curJobPtr
		TC	EX_MN_runJob	; >0, 14-bit address OK
		TC	EX_exec		; +0
		TC	EX_exec		; <0
		TC	EX_exec		; -0

	; Start the job. Interrupts are reenabled before 'EX_curJobPtr' is 
	; referenced, but the interrupts can only call 'EX_addJob' which does 
	; not change 'EX_curJobPtr'.

	; The job address is always 14-bit, so check whether the address falls
	; within erasable or fixed-fixed memory. If so, use it as-is; otherwise,
	; set the bank register and change the address to 12-bit.

EX_MN_runJob	EQU	*
		CAF	zero
		INDEX	EX_curJobPtr
		AD	JOBADDR
		TS	EX_MN_runAddr	; save job's 14 bit address

		COM		
		AD	bankAddr	; -(14bitAddr)+%6000
		CCS	A		; job is bank addressed?
		TC	EX_MN_runIt	; >0 no, just run it, as is
		TC	*+2		; +0 yes
		TC	*+1		; <0 yes

		CAF	zero
		AD	EX_MN_runAddr
		TS	BANK		; set the bank

		MASK	lowAddr		; get lowest 10-bits of address
		AD	bankAddr	; set bits 11,12 for fixed-switchable
		TS	EX_MN_runAddr

EX_MN_runIt	EQU	*
		RELINT			; enable interrupts
		INDEX	EX_MN_runAddr	; apply indirect address to next instr.
		TC	0		; run the job
	
	; Job is terminated. Delete the job record.

ENDOFJOB	EQU	*
		INHINT			; inhibit interrupts
		CAF	zero		; delete the job
		INDEX	EX_curJobPtr
		TS	JOBPRIO

		INDEX	EX_curJobPtr
		TS	JOBADDR

		TC	EX_MN_findJob	; get next job

	; Job is suspended. Keep the job record, but update the address, so 
	; execution will resume at the point after suspension.

CHANG1		EQU	*
		INHINT			; inhibit interrupts
		XCH	Q
		TS	EX_MN_runAddr	; save job's 14 bit restart address

		COM		
		AD	bankAddr	; -(14bitAddr)+%6000
		CCS	A		; job is bank addressed?
		TC	EX_MN_notBank	; >0 no, just save it, as is
		TC	*+2		; +0 yes
		TC	*+1		; <0 yes

		CS	bankAddr	; 12bitAddr - %6000
		AD	EX_MN_runAddr	
		AD	BANK		; make it a 14-bit address
		TC	EX_MN_saveIt

EX_MN_notBank	EQU	*
		CAF	zero
		AD	EX_MN_runAddr	; get restart address

EX_MN_saveIt	EQU	*
		INDEX	EX_curJobPtr
		TS	JOBADDR		; save restart address in the job's record
		TC	EX_MN_findJob	; get next job

	; ----------------------------------------------
	; EX_addJob - ADD A JOB TO THE JOBLIST
	;
	; Search jobList for an empty slot. If found, put the new job in the 
	; empty slot. If the new job has the same, or higher, priority than the 
	; current job, set the change flag to 'CHGJOB' (change jobs at the next 	; opportunity).
	;
	; This is the only 'public' function. It can be called from a job 
	; or from an interrupt. It disables interrupts to maintain the 
	; integrity of the jobList.
	; ----------------------------------------------

EX_addJob	EQU	*
		INHINT			; disable interrupts
		TS	EX_AJ_jobPrio	; save job priority
		XCH	Q
		TS	EX_AJ_saveQ	; save return address-1


	; Search jobList for an empty slot

		CAF	EX_numJobs	; number of slots to seach
EX_AJ_loop	EQU	*
		TS	EX_AJ_loopCnt

	; Check for empty slot

		INDEX	EX_AJ_jobPtr	; get the priority
		CS	JOBPRIO
		AD	zero		; is slot empty?
		CCS	A		; 
		TC	EX_AJ_bumpPtr	; >0
		TC	*+2		; +0 yes!
		TC	EX_AJ_bumpPtr	; <0

	; Found empty slot, so add new job there

		CAF	zero
		AD	EX_AJ_jobPrio
		INDEX	EX_AJ_jobPtr
		TS	JOBPRIO		; store new job priority

		INDEX	EX_AJ_saveQ	; indirectly address addJobQ
		CAF	0
		INDEX	EX_AJ_jobPtr
		TS	JOBADDR		; store new job address
		
		TC	EX_AJ_testFlg	; finished

	; Bump job pointer to next job record

EX_AJ_bumpPtr	EQU	*
		CAF	zero
		AD	EX_AJ_jobPtr
		TCR	EX_bumpJobPtr
		TS	EX_AJ_jobPtr

		CCS	EX_AJ_loopCnt	; done searching jobList?
		TC	EX_AJ_loop	; not yet

	; Fell through loop, so search failed - all slots are full; probably 
	; should set some alarm

		TC	EX_AJ_done

	; Set changeflag if priority of new job >= priority of current job

EX_AJ_testFlg	EQU	*
		INDEX	EX_curJobPtr	; get priority of current job
		CS	JOBPRIO		; make it a negative number
		
		AD	EX_AJ_jobPrio	; add positive priority of new job
		CCS	A		; new job is highest priority?
		TC	*+3		; >0, yes
		TC	*+2		; +0, yes
		TC	EX_AJ_done	; <0, no, current job is higher priority

		CAF	EX_changeJob	; set the change flag
		TS	newJob

EX_AJ_done	EQU	*
		XCH	EX_AJ_saveQ
		AD	one
		TS	Q
		RELINT			; enable interrupts
		RETURN

	; ----------------------------------------------
	; EX_selJob - SELECT NEXT JOB
	;
	; Select the next job for execution. Find the highest priority job by 
	; walking the jobList. If several jobs have the same priority, select 
	; the first job with the highest priority. Increment the current job 
	; pointer before searching, so jobs with the same priority are selected
	; in round-robin order. Upon return, 'EX_curJobPtr' holds the selected 
	; job.
	; ----------------------------------------------

EX_selJob	EQU	*
		XCH	Q
		TS	EX_SJ_saveQ	; save return address

		CAF	zero
		AD	EX_curJobPtr
		TCR	EX_bumpJobPtr	; bump pointer to next job
		TS	EX_curJobPtr

		CAF	zero
		AD	EX_curJobPtr
		TS	EX_SJ_jobPtr	; make it our initial choice

		CAF	EX_keepJob	; clear change flag
		TS	newJob

	; Search jobList for any job with a higher priority than our
	; initial choice.

		CAF	EX_numJobs	; number of slots to seach
EX_SJ_loop	EQU	*
		TS	EX_SJ_loopCnt

	; Compare job priority of this job against the current choice.

		INDEX	EX_curJobPtr	; get priority of current job
		CS	JOBPRIO		; make it a negative number
		INDEX	EX_SJ_jobPtr	; get highest prio (positive)
		AD	JOBPRIO		; compare
		CCS	A
		TC	EX_SJ_bumpPtr	; >0
		TC	EX_SJ_setFlg	; +0
		TC	EX_SJ_clrFlg	; <0

	; Priority of this job == highest priority job, so there are 
	; several jobs with the same priority

EX_SJ_setFlg	EQU	*
		CAF	EX_changeJob	; set change flag
		TS	newJob
		TC	EX_SJ_bumpPtr

	; Priority of this job > highest priority job, so make this job our
	; new choice.

EX_SJ_clrFlg	EQU	*
		CAF	EX_keepJob	; clear change flag
		TS	newJob

		CAF	zero
		AD	EX_curJobPtr
		TS	EX_SJ_jobPtr	; make it the new selection

EX_SJ_bumpPtr	EQU	*
		CAF	zero
		AD	EX_curJobPtr
		TCR	EX_bumpJobPtr	; bump pointer to next job
		TS	EX_curJobPtr

		CCS	EX_SJ_loopCnt	; done searching jobList?
		TC	EX_SJ_loop	; not yet

	; Found the highest priority job; make it the current job

		CAF	zero
		AD	EX_SJ_jobPtr
		TS	EX_curJobPtr

		XCH	EX_SJ_saveQ
		TS	Q		; restore return address
		RETURN

	; ----------------------------------------------
	; EX_bumpJobPtr - BUMP JOB RECORD POINTER
	;
	; Bumps the job pointer in register 'A' to the next job record. Wrap 
	; the pointer back to the front of the list if necessary and return 
	; with the bumped pointer in 'A'.
	; ----------------------------------------------

EX_bumpJobPtr	EQU	*
		TS	EX_BP_jobPtr	; save job pointer
		XCH	Q
		TS	EX_BP_saveQ	; save return address

		XCH	EX_BP_jobPtr	; bump the address by 1 job record
		AD	EX_jobRecSize
		TS	EX_BP_jobPtr

		COM			; check for wraparound
		AD	EX_jobLstEnd
		CCS	A
		TC	EX_BP_done	; >0
		TC	*+2		; +0 yes, need to handle wrap
		TC	EX_BP_done	; <0

		CAF	EX_jobLstStart
		TS	EX_BP_jobPtr	; reset address to top of list

EX_BP_done	EQU	*
		XCH	EX_BP_saveQ
		TS	Q		; restore return address
		XCH	EX_BP_jobPtr	; get return value
		RETURN

	; ----------------------------------------------
	; EX_initEX - INITIALIZE EXEC
	;
	; Initialize the eraseable memory segment for EXEC. Necessary in 
	; case the AGC is restarted.
	; ----------------------------------------------

EX_initEX	EQU	*
		XCH	Q
		TS	EX_IN_saveQ	; save return address

		CAF	EX_jobLstStart	; initialize jobList pointers
		TS	EX_curJobPtr
		TS	EX_AJ_jobPtr

		CAF	EX_keepJob	; clear change flag
		TS	newJob		

	; Iterate through jobList and zero all records

		CAF	EX_jobLstStart	; init pointer to start of list
		TS	EX_IN_jobPtr
		CAF	EX_numJobs	; loop for number of jobs
EX_IN_loop	EQU	*
		TS	EX_IN_loopCnt

		CAF	zero
		INDEX	EX_IN_jobPtr
		TS	JOBPRIO

		INDEX	EX_IN_jobPtr
		TS	JOBADDR

		XCH	EX_IN_jobPtr	; bump job pointer back 1 record
		AD	EX_jobRecSize
		TS	EX_IN_jobPtr
		
		CCS	EX_IN_loopCnt	; done clearing jobList?
		TC	EX_IN_loop	; not yet

		XCH	EX_IN_saveQ
		TS	Q		; restore return address
		RETURN

	; ----------------------------------------------
	; DUMMY JOB - runs at the lowest priority and never terminates. Ensures 
	; that there is always at least one job executing.
	; ----------------------------------------------

dumPrio		DS	1		; lowest priority

dumJob		EQU	*
		CCS	newJob		; check for context switch
		TC	CHANG1
		TC	dumJob

	; ----------------------------------------------
	; RUPT (INTERRUPT) SERVICE ROUTINES
	; ----------------------------------------------

goT3		EQU	*
		TC	endRUPT

goER		EQU	*
		TC	endRUPT

goDS		EQU	*
		TC	endRUPT

goKEY		EQU	*
		TC	endRUPT

goUP		EQU	*
		TC	endRUPT

endRUPT		EQU	*
		XCH	QRUPT		; restore Q
		TS	Q
		XCH	ARUPT		; restore A
		RESUME			; finished, go back

	; ----------------------------------------------
	; ----------------------------------------------

	; TEST JOBS
COUNT1		EQU	%44
COUNT2		EQU	%45
COUNT3		EQU	%46

prio1		DS	2
prio2		DS	2
prio3		DS	3

	; TEST CODE - JOB 3
job3		EQU	*
		CCS	newJob		; yield to higher priority job
		TC	CHANG1

		CAF	zero
		AD	COUNT3
		AD	one
		TS	COUNT3

		TC	ENDOFJOB 	; terminate job



		ORG	BANK11		; **** BANK 11 ****

	; TEST CODE - JOB 1
job1		EQU	*
		CAF	zero
		AD	COUNT1
		AD	one
		TS	COUNT1

		CCS	newJob		; yield to higher priority job
		TC	CHANG1

		TC	job1

		ORG	BANK12		; **** BANK 12 ****

	; TEST CODE - JOB 2
job2		EQU	*
		CAF	zero
		AD	COUNT2
		AD	one
		TS	COUNT2

		CCS	newJob		; yield to higher priority job
		TC	CHANG1

		TC	job2






