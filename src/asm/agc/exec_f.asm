;==========================================================================
; EXEC (file:exec_f.asm)
;
; Version:  1.0
; Author:   John Pultorak
; Date:     04/26/2002
;
; PURPOSE:
; Constants and source code for EXEC.
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
; A job is scheduled for execution by calling 'NOVAC' and 
; furnishing the job priority and starting address.
;	L	XCH	JOB_PRIORITY
;	L+1	TC	NOVAC
;	L+2	DS	JOB_ADDRESS
;	L+3	... execution resumes here
;
; JOB_PRIORITY = a positive integer from %3 - %37776 where a higher number 
;    indicates higher priority. Priorities below 3 are reserved for
;    internal EXEC use: 0=no job, 1=sleeping job, 2=dummy job.
;    Priority %37777 is also reserved for woken jobs.
; JOB_ADDRESS = starting address of the job.
;
; **** WARNING **** If NOVAC is not being called from an interrupt, be sure to
; inhibit interrupts before calling it to protect the integrity of the list.
;
; When a new job is added, the new job's record (core set) is 
; initialized with a copy of the current job's record (MPAC and other
; parameters), except for the new job priority and address, which are
; set by the 'add job' routine. Therefore, data can be stored into
; MPAC prior to starting a new job as a method of passing data into
; the new job.
;
; Jobs terminate themselves by jumping to ENDOFJOB. This removes them 
; from the EXEC scheduler:
;	TC	ENDOFJOB
;
; Jobs can suspend themselves (yield to a higher priority job) by 
; executing the following sequence. If there is no other job of
; higher priority, executing of the yielded job resumes at L+2
;	L	CCS	newJob
;	L+1	TC	CHANG1
;	L+2	... execution resumes here
;
; If there is no other job of equal or higher priority, the branch is 
; not taken.
;
; Jobs can put themselves to sleep by calling JOBSLEEP. The address
; where execution of the sleeping job should resume must be in register 
; A before calling JOBSLEEP. The job will remain sleeping until JOBWAKE 
; is called:
;
;	L	CAF	WAKECADR
;	L+1	TC	JOBSLEEP
;	(does not return from JOBSLEEP)
;
; Sleeping jobs are awakened by calling JOBWAKE. The address where
; execution of the sleeping job should resume must be in register A.
; JOBWAKE returns to the address after the call and execution continues
; for the calling job. The job that was sleeping will now be the next
; job to execute.
;
;	L	CAF	WAKECADR
;	L+1	TC	JOBWAKE
;	L+2	... execution continues here
;
;==========================================================================

EX_WAKE_PRIO	DS	%37777		; waking job priority (highest)
EX_DUMMY_PRIO	DS	%00002		; dummy job priority (lowest runnable)
EX_SLEEP_PRIO	DS	%00001		; sleeping job; must be < dummy

EX_jobCurStart	DS	EX_currentJob	; starting address for current job

EX_jobRecSize	DS	JRECSZ		; size of a job record (words)
EX_jobLstStart	DS	EX_jobList	; starting address for jobList
EX_jobLstEnd	DS	MAXJOBS+EX_jobList
EX_jobLstEnd1	DS	MAXJOBS-1+EX_jobList
EX_numJobs	DS	MAXJOBS-1	; init loop counter for all jobs
EX_numJobs1	DS	MAXJOBS-2	; init loop counter for all jobs - 1

	; enumerated types for setting change flag:
EX_changeJob	DS	CHGJOB		; change job
EX_keepJob	DS	KEEPJOB		; keep job


;--------------------------------------------------------------------------
; EX_exec -- EXEC SCHEDULER
;
; Executes the highest priority job. Enables interrupts while the job is 
; running. Once called, this function never returns.
;--------------------------------------------------------------------------

EX_exec		EQU	*		; entry point
	
	; Add a dummy job (lowest priority) that never terminates.

		CAF	EX_DUMMY_PRIO	; job priority
		TC	NOVAC
		DS	dumJob		; 14 bit job address
		INHINT			; inhibit RUPTs enab by addJob

	; Get the next job to run.

EX_MN_findJob	EQU	*
		TCR	EX_remove

	; compare priority of current job to priority of next waiting job.
	; If next job has same priority as current job, set the newJob 
	; flag so they will be scheduled round-robin.

		CS	PRIORITY	; get priority of current job

		INDEX	EX_jobLstStart
		INDEX	0
		AD	PRIORITY	; compare with priority of next job

		CCS	A		; next job has equal priority?
		TC	EX_MN_setFlg	; >0 (error!)
		TC	EX_MN_setFlg	; +0 yes, set flag 
		TC	*+2		; <0 no,  clear flag
		TC	EX_MN_setFlg	; -0 yes, set flag

		CAF	EX_keepJob	; clear change flag
		TS	newJob
		TC	EX_MN_runJob

EX_MN_setFlg	EQU	*
		CAF	EX_changeJob	; set change flag
		TS	newJob


	; Start the job. Interrupts are reenabled before 'EX_curJobPtr' is 
	; referenced, but the interrupts can only call 'NOVAC' which does 
	; not change 'EX_curJobPtr'.

	; The job address is always 14-bit, so check whether the address falls
	; within erasable or fixed-fixed memory. If so, use it as-is; otherwise,
	; set the bank register and change the address to 12-bit.

EX_MN_runJob	EQU	*
		CAF	ZERO
		AD	LOC
		TS	EX_MN_runAddr	; save job's 14 bit address

		COM		
		AD	bankAddr	; -(14bitAddr)+%6000
		CCS	A		; job is bank addressed?
		TC	EX_MN_runIt	; >0 no, just run it, as is
		TC	*+2		; +0 yes
		TC	*+1		; <0 yes

		CAF	ZERO
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
		TC	EX_MN_findJob	; get next job

	; job is sleeping. Keep the job record, but drop the priority so it
	; is below the priority of the dummy job. This will keep the job
	; from running until JOBWAKE is called. The address where it should
	; resume running when awoken is in register A.

JOBSLEEP	EQU	*
		INHINT			; inhibit interrupts
		TS	LOC		; save restart address

		CAF	EX_SLEEP_PRIO
		TS	PRIORITY	; set sleeping priority
		TS	EX_IS_newPrio

		TC	EX_MN_mvRec	; finish up


	; Job is suspended. Keep the job record, but update the address, so 
	; execution will resume at the point after suspension.

CHANG1		EQU	*
		INHINT			; inhibit interrupts
		XCH	Q
		TS	EX_MN_runAddr	; save job's 12 bit restart address

		COM		
		AD	bankAddr	; -(12bitAddr)+%6000
		CCS	A		; job is bank addressed?
		TC	EX_MN_notBank	; >0 no, just save it, as is
		TC	*+2		; +0 yes
		TC	*+1		; <0 yes

		CS	bankAddr	; 12bitAddr - %6000
		AD	EX_MN_runAddr	
		AD	BANK		; make it a 14-bit address
		TC	EX_MN_saveIt

EX_MN_notBank	EQU	*
		CAF	ZERO
		AD	EX_MN_runAddr	; get restart address

EX_MN_saveIt	EQU	*
		TS	LOC		; save job's new starting address

		CAF	ZERO
		AD	JOBPRIOBASE
		TS	PRIORITY
		TS	EX_IS_newPrio	; restore job priority to nominal value

	; given the priority, find the insertion point in the list. Copy
	; the current job into the list at the correct insertion point.

EX_MN_mvRec	EQU	*
		TCR	EX_findIns
		TS	EX_IS_jobPtr	; save address of insertion point

	; copy all fields in current record to list

		XCH	EX_jobRecSize
		TS	EX_MN_field

EX_MN_loop3	EQU	*
		CCS	EX_MN_field	; done?
		TC	*+2		; not yet
		TC	EX_MN_done3	; yes
		TS	EX_MN_field

	; copy this field to list

		CAF	ZERO
		INDEX	EX_IS_jobPtr
		AD	0		; get index to record in list
		AD	EX_MN_field	; add field displacement
		TS	EX_MN_findx	; save index to field in list

		CAF	ZERO
		INDEX	EX_MN_field
		AD	EX_currentJob	; get field from current job
		INDEX	EX_MN_findx
		TS	EX_currentJob	; copy field to list

		TC	EX_MN_loop3

EX_MN_done3	EQU	*
		TC	EX_MN_findJob	; get next job


;--------------------------------------------------------------------------
; JOBWAKE - wake up the job identified by address in register A
;
; Search jobList for a job with address matching the address in A.
; If found, bump the priority up to the highest level, so the job
; will be the next to run.
;
; This is a 'public' function. It assumes that interrupts are already
; disabled before it is called. Disabling interrupts during JOBWAKE
; is necessary to preserve the integrity of the joblist.
;--------------------------------------------------------------------------

JOBWAKE		EQU	*
		TS	EX_JW_CADR	; save job address
		XCH	Q
		TS	EX_JW_saveQ	; save return address

	; Search the joblist for the job to wake (job address matches
	; EX_JW_CADR).

		CAF	ZERO
		TS	EX_JW_foundit	; clear 'found it' flag

		CAF	EX_jobLstEnd1	; set pointer to back of list
		TS	EX_JW_jobPtr

		AD	NEG1		; set pointer to rec in front of it
		TS	EX_JW_jobPtr2

		CAF	EX_numJobs1	; loop for number of jobs minus 1
EX_JW_loop	EQU	*
		TS	EX_JW_loopCnt

	; if foundit=0, job has not been found yet. Keep searching toward
	;   the front of the list. 
	; if foundit=1, the job has been found and removed from the list.
	;   push all jobs in front of the removed job one step to the back
	;   to fill in the gap and to make room at the front of the list
	;   for the awoken job.

		CCS	EX_JW_foundit	; already found job to wake?
		TC	EX_JW_moveRec	; >0, yes

	; Is this the job?

		CS	EX_JW_CADR
		INDEX	EX_JW_jobPtr
		INDEX	0
		AD	LOC
		CCS	A		; found job to wake?
		TC	EX_JW_bumpPtr	; >0, no
		TC	*+2		; +0, yes
		TC	EX_JW_bumpPtr	; <0, no

	; found the job to wake.

		CAF	ONE
		TS	EX_JW_foundit	; set 'found it' flag

	; save record index for awoken job

		INDEX	EX_JW_jobPtr
		XCH	0
		TS	EX_JW_fndIndx	; index for awoken job

	; bump prior record back

EX_JW_moveRec	EQU	*
		INDEX	EX_JW_jobPtr2
		XCH	0
		INDEX	EX_JW_jobPtr
		XCH	0
	
EX_JW_bumpPtr	EQU	*
		XCH	EX_JW_jobPtr	; bump job pointer forward 1 record
		AD	NEG1
		TS	EX_JW_jobPtr

		AD	NEG1		; set pointer to record in front of it
		TS	EX_JW_jobPtr2

		CCS	EX_JW_loopCnt	; done bumping jobs backward?
		TC	EX_JW_loop	; not yet

		CCS	EX_JW_foundit	; found job to wake?
		TC	*+2		; >0, yes
		TC	EX_JW_done	; no

		XCH	EX_JW_fndIndx	; put awoken job on front of list
		INDEX	EX_jobLstStart
		TS	0

EX_JW_done	EQU	*

	; Is the awoken job at the front of the list?
	; (If it was already there before we started searching, 'foundIt'
	; will be false (0) so we need to make this test).

		CS	EX_JW_CADR
		INDEX	EX_jobLstStart
		INDEX	0
		AD	LOC
		CCS	A		; woken job at front of list?
		TC	EX_JW_return	; >0, no
		TC	*+2		; +0, yes
		TC	EX_JW_return	; <0, no

	; set awoken priority and change job flag

		CAF	EX_WAKE_PRIO
		INDEX	EX_jobLstStart
		INDEX	0
		TS	PRIORITY	; set waking priority

		CAF	EX_changeJob	; set the change flag
		TS	newJob

EX_JW_return	EQU	*
		TC	EX_JW_saveQ	; return


;--------------------------------------------------------------------------
; SPVAC - ADD A JOB TO THE JOBLIST
;
; Similar to NOVAC, but used by VERB 37. The job CADR is in register A.
; The job priority is in NEWPRIO. Return to the address in Q.
;
; NOVAC differs from SPVAC, because NOVAC has the job CADR at the address
; in Q, and returns to Q+1. Also, in NOVAC the job priority is in A.
;
; This is a 'public' function. It can be called from a job 
; or from an interrupt.
;--------------------------------------------------------------------------

SPVAC		EQU	*
		TS	EX_IS_newLoc	; store new job address
		XCH	Q
		TS	EX_AJ_saveQ	; save return address


	; add new job to end of list

		CAF	ZERO
		AD	NEWPRIO
		TS	EX_IS_newPrio
		TS	EX_IS_newPrioB	; store new job priority

		TCR	EX_findIns	; find insertion point in list
		TS	EX_IS_jobPtr	; save address of insertion point

	; Initialize relevant fields in new job. The remaining fields
	; should already be zeroed.


	; Initialize fields for new job record. New job inherits copy of
	; MPAC from current job, so copy all fields in current job to new 
	; job in list

		XCH	EX_jobRecSize
		TS	EX_AJ_field

EX_SP_loop1	EQU	*
		CCS	EX_AJ_field	; done?
		TC	*+2		; not yet
		TC	EX_SP_done1	; yes
		TS	EX_AJ_field

	; copy this field to list

		CAF	ZERO
		INDEX	EX_IS_jobPtr
		AD	0		; get index to record in list
		AD	EX_AJ_field	; add field displacement
		TS	EX_AJ_findx	; save index to field in list

		CAF	ZERO
		INDEX	EX_AJ_field
		AD	EX_currentJob	; get field from current job
		INDEX	EX_AJ_findx
		TS	EX_currentJob	; copy field to list

		TC	EX_SP_loop1

	; now, overwrite fields in the record with the priority
	; and location unique to this job.

EX_SP_done1	EQU	*
		CAF	ZERO
		AD	EX_IS_newPrio
		INDEX	EX_IS_jobPtr
		INDEX	0
		TS	PRIORITY	; set priority field

		CAF	ZERO
		AD	EX_IS_newPrioB
		INDEX	EX_IS_jobPtr
		INDEX	0
		TS	JOBPRIOBASE	; set nominal priority field

		CAF	ZERO
		AD	EX_IS_newLoc
		INDEX	EX_IS_jobPtr
		INDEX	0
		TS	LOC		; set address field


	; Set changeflag if priority of new job >= priority of current job

EX_SP_testFlg	EQU	*
		CS	PRIORITY	; get -priority of current job
		
		AD	EX_AJ_jobPrio	; add positive priority of new job
		CCS	A		; new job is highest priority?
		TC	*+3		; >0, yes
		TC	*+2		; +0, yes
		TC	EX_SP_done2	; <0, no, current job is higher priority

		CAF	EX_changeJob	; set the change flag
		TS	newJob

EX_SP_done2	EQU	*
		XCH	EX_AJ_saveQ
		TS	Q
		RETURN

;--------------------------------------------------------------------------
; FINDVAC - not implemented
;
;--------------------------------------------------------------------------

FINDVAC		TC	Q		; just return


;--------------------------------------------------------------------------
; NOVAC - ADD A JOB TO THE JOBLIST
;
; Search jobList for an empty slot. If found, put the new job in the 
; empty slot. If the new job has the same, or higher, priority than the 
; current job, set the change flag to 'CHGJOB' (change jobs at the next
; opportunity).
;
; This is a 'public' function. It can be called from a job 
; or from an interrupt.
;--------------------------------------------------------------------------

NOVAC		EQU	*
		TS	EX_AJ_jobPrio	; save job priority
		XCH	Q
		TS	EX_AJ_saveQ	; save return address-1


	; add new job to end of list

		CAF	ZERO
		AD	EX_AJ_jobPrio
		TS	EX_IS_newPrio
		TS	EX_IS_newPrioB	; store new job priority

		INDEX	EX_AJ_saveQ	; indirectly address addJobQ
		CAF	0
		TS	EX_IS_newLoc	; store new job address

		TCR	EX_findIns	; find insertion point in list
		TS	EX_IS_jobPtr	; save address of insertion point

	; Initialize relevant fields in new job. The remaining fields
	; should already be zeroed.



	; Initialize fields for new job record. New job inherits copy of
	; MPAC from current job, so copy all fields in current job to new 
	; job in list

		XCH	EX_jobRecSize
		TS	EX_AJ_field

EX_AJ_loop1	EQU	*
		CCS	EX_AJ_field	; done?
		TC	*+2		; not yet
		TC	EX_AJ_done1	; yes
		TS	EX_AJ_field

	; copy this field to list

		CAF	ZERO
		INDEX	EX_IS_jobPtr
		AD	0		; get index to record in list
		AD	EX_AJ_field	; add field displacement
		TS	EX_AJ_findx	; save index to field in list

		CAF	ZERO
		INDEX	EX_AJ_field
		AD	EX_currentJob	; get field from current job
		INDEX	EX_AJ_findx
		TS	EX_currentJob	; copy field to list

		TC	EX_AJ_loop1

	; now, overwrite fields in the record with the priority
	; and location unique to this job.

EX_AJ_done1	EQU	*
		CAF	ZERO
		AD	EX_IS_newPrio
		INDEX	EX_IS_jobPtr
		INDEX	0
		TS	PRIORITY	; set priority field

		CAF	ZERO
		AD	EX_IS_newPrioB
		INDEX	EX_IS_jobPtr
		INDEX	0
		TS	JOBPRIOBASE	; set nominal priority field

		CAF	ZERO
		AD	EX_IS_newLoc
		INDEX	EX_IS_jobPtr
		INDEX	0
		TS	LOC		; set address field


	; Set changeflag if priority of new job >= priority of current job

EX_AJ_testFlg	EQU	*
		CS	PRIORITY	; get -priority of current job
		
		AD	EX_AJ_jobPrio	; add positive priority of new job
		CCS	A		; new job is highest priority?
		TC	*+3		; >0, yes
		TC	*+2		; +0, yes
		TC	EX_AJ_done2	; <0, no, current job is higher priority

		CAF	EX_changeJob	; set the change flag
		TS	newJob

EX_AJ_done2	EQU	*
		XCH	EX_AJ_saveQ
		AD	ONE
		TS	Q
		RETURN


;--------------------------------------------------------------------------
; EX_initEX - INITIALIZE EXEC
;
; Initialize the eraseable memory segment for EXEC. Necessary in 
; case the AGC is restarted.
;--------------------------------------------------------------------------

EX_initEX	EQU	*
		XCH	Q
		TS	EX_IN_saveQ	; save return address

		CAF	EX_keepJob	; clear change flag
		TS	newJob		

		CAF	ZERO
		TS	PRIORITY	; set current job record to NIL

	; Iterate through jobList, initialize each element on the list so it
	; points to its own job record.

		CAF	EX_jobLstStart	; init pointer to start of list
		TS	EX_IN_jobPtr

		CAF	ZERO
		AD	EX_jobRecSize
		TS	EX_IN_recIndex

		CAF	EX_numJobs	; loop for number of jobs
EX_IN_loop1	EQU	*
		TS	EX_IN_loopCnt

		XCH	EX_IN_recIndex
		INDEX	EX_IN_jobPtr
		TS	0		; initialize record index
		AD	EX_jobRecSize
		TS	EX_IN_recIndex	; bump index to next record

		XCH	EX_IN_jobPtr	; bump job pointer back 1 record
		AD	ONE
		TS	EX_IN_jobPtr
		
		CCS	EX_IN_loopCnt	; done clearing jobList?
		TC	EX_IN_loop1	; not yet


	; Iterate through job records, initialize each field to zero.

		CAF	EX_jobLstStart	; init pointer to start of list
		TS	EX_IN_jobPtr

		CAF	EX_numJobs	; loop for number of jobs
EX_IN_loop2	EQU	*
		TS	EX_IN_loopCnt

	; loop for number of fields in each record

		XCH	EX_jobRecSize
		TS	EX_IN_field

EX_IN_loop3	EQU	*
		CCS	EX_IN_field	; done?
		TC	*+2		; not yet
		TC	EX_IN_done	; yes
		TS	EX_IN_field

	; set the field to zero

		CAF	ZERO
		INDEX	EX_IN_jobPtr
		AD	0		; get index to record
		AD	EX_IN_field	; add field displacement
		TS	EX_IN_findx	; save index to field
		CAF	ZERO
		INDEX	EX_IN_findx
		TS	EX_currentJob	; clear field

		TC	EX_IN_loop3

	; done clearing all fields in record, so do next record

EX_IN_done	EQU	*
		XCH	EX_IN_jobPtr	; bump job pointer back 1 record
		AD	ONE
		TS	EX_IN_jobPtr
		
		CCS	EX_IN_loopCnt	; done clearing jobList?
		TC	EX_IN_loop2	; not yet

		TC	EX_IN_saveQ	; return


;--------------------------------------------------------------------------
; EX_findIns - FIND INSERTION POINT INTO SORTED LIST
;
; Insert a job record into the sorted list. Use 'EX_IS_newPrio',
; EX_IS_newPrioB and 'EX_IS_newLoc' to set the fields of record to 
; be inserted.
; Performs an insertion sort, with the records sorted by priority.
; Highest priority is at the front of the list. If several records
; have the same priority, the records inserted first will appear first
; in the list. NIL records have a priority of zero.
;--------------------------------------------------------------------------

EX_findIns	EQU	*
		XCH	Q
		TS	EX_IS_saveQ	; save return address

		CAF	EX_jobLstEnd1	; set pointer to back of list
		TS	EX_IS_jobPtr

		AD	NEG1		; set pointer to rec in front of it
		TS	EX_IS_jobPtr2

		CAF	ZERO
		INDEX	EX_IS_jobPtr
		INDEX	0
		AD	PRIORITY	; check last record on list

		CCS	A		; list full?
		TC	EX_FI_done	; >0 yes

	; Work from the back of the list to the front, pushing each record
	; to the back until the insertion point is found.

		CAF	EX_numJobs1	; loop for number of jobs minus 1
EX_FI_loop	EQU	*
		TS	EX_IS_loopCnt

		CAF	ZERO
		INDEX	EX_IS_jobPtr2
		INDEX	0
		AD	PRIORITY
		CCS	A		; previous record is NIL?
		TC	*+2		; no, so check it
		TC	EX_FI_bumpPtr	; yes, so skip to next record


	; Is this the insertion point?

		CS	EX_IS_newPrio
		INDEX	EX_IS_jobPtr2
		INDEX	0
		AD	PRIORITY
		CCS	A		; found insertion point?
		TC	EX_FI_insRec	; >0 yes
		TC	EX_FI_insRec	; +0 yes
		TC	*+2		; <0 no, keep checking
		TC	EX_FI_insRec	; -0 yes

	; No, bump the record toward the back of the list.

		INDEX	EX_IS_jobPtr2
		XCH	0
		INDEX	EX_IS_jobPtr
		XCH	0
		INDEX	EX_IS_jobPtr2
		XCH	0

EX_FI_bumpPtr	EQU	*
		XCH	EX_IS_jobPtr	; bump job pointer forward 1 record
		AD	NEG1
		TS	EX_IS_jobPtr

		AD	NEG1		; set pointer to record in front of it
		TS	EX_IS_jobPtr2

		CCS	EX_IS_loopCnt	; done bumping jobs backward?
		TC	EX_FI_loop	; not yet

	; New record should be inserted at EX_IS_jobPtr.

EX_FI_insRec	EQU	*

EX_FI_done	EQU	*
		CAF	ZERO
		AD	EX_IS_jobPtr	; get insertion spot in list
		TC	EX_IS_saveQ	; return


;--------------------------------------------------------------------------
; EX_remove - REMOVE JOB FROM FRONT OF LIST
;
; Remove job from front of list and copy it to the current job. Bubble
; any remaining jobs toward the front of the list.
;--------------------------------------------------------------------------

EX_remove	EQU	*
		XCH	Q
		TS	EX_RM_saveQ	; save return address

		CAF	EX_jobLstStart	; set pointer to front of list
		TS	EX_RM_jobPtr

		AD	ONE		; set pointer to next rec behind it
		TS	EX_RM_jobPtr2

	; Dequeue the record at the top of the list (the next job to run).
	; Make it the current job by copying it to the current job record.

		XCH	EX_jobRecSize
		TS	EX_RM_field

EX_RM_loop1	EQU	*
		CCS	EX_RM_field	; done?
		TC	*+2		; not yet
		TC	EX_RM_done1	; yes
		TS	EX_RM_field

	; copy field from list to current job

		CAF	ZERO
		INDEX	EX_RM_jobPtr
		AD	0		; get index to record
		AD	EX_RM_field	; add field displacement
		TS	EX_RM_findx	; save index to field
		CAF	ZERO
		INDEX	EX_RM_findx
		AD	EX_currentJob	; get field
		INDEX	EX_RM_field
		TS	EX_currentJob	; move to current job

		TC	EX_RM_loop1

	; done copying record for current job. Restore the current job to 
	; its default priority, in case it was previously elevated.

EX_RM_done1	EQU	*
		CAF	ZERO
		AD	JOBPRIOBASE
		TS	PRIORITY

		INDEX	EX_RM_jobPtr
		XCH	0
		TS	EX_RM_savePtr	; so we can move it to the end later


	; Loop through the remaining records in the job list and
	; bubble them up to the front.

		CAF	EX_numJobs1	; loop for number of jobs minus 1
EX_RM_loop2	EQU	*
		TS	EX_RM_loopCnt


		INDEX	EX_RM_jobPtr2
		XCH	0
		INDEX	EX_RM_jobPtr
		TS	0

		CCS	A		; remainder of list empty?
		TC	*+2		; >0, no
		TC	EX_RM_done2	; +0, yes, so exit

		XCH	EX_RM_jobPtr	; bump job pointer back 1 record
		AD	ONE
		TS	EX_RM_jobPtr

		AD	ONE		; set pointer to record behind it
		TS	EX_RM_jobPtr2

		CCS	EX_RM_loopCnt	; done bumping jobs upward?
		TC	EX_RM_loop2	; not yet

	; Since we removed a record, the last record on the list
	; should be NIL.

EX_RM_done2	EQU	*
		XCH	EX_RM_savePtr	
		INDEX	EX_RM_jobPtr	; move the index for the top record
		TS	0		; to the bottom of the list

	; set all fields in NIL record to zero

		XCH	EX_jobRecSize
		TS	EX_RM_field

EX_RM_loop3	EQU	*
		CCS	EX_RM_field	; done?
		TC	*+2		; not yet
		TC	EX_RM_done3	; yes
		TS	EX_RM_field

	; set this field to zero

		CAF	ZERO
		INDEX	EX_RM_jobPtr
		AD	0		; get index to record
		AD	EX_RM_field	; add field displacement
		TS	EX_RM_findx	; save index to field
		CAF	ZERO
		INDEX	EX_RM_findx
		TS	EX_currentJob	; clear field

		TC	EX_RM_loop3

EX_RM_done3	EQU	*
		TC	EX_RM_saveQ	; return


;--------------------------------------------------------------------------
; DUMMY JOB - runs at the lowest priority and never terminates. Ensures 
; that there is always at least one job executing. Sleeping jobs are
; given a lower priority than the dummy job.
;
; The dummy job controls the computer activity light on the DSKY. When
; the dummy job is running, the light is off. When the dummy job is
; preempted by a higher priority job, the light is on.
;
; I couldn't find good information on the computer activity light 
; in COLOSSUS, so this is my best guess concerning its operation. It
; seems consistent witht the MPEG video of the Apollo 11 DSKY.
;--------------------------------------------------------------------------


	; entering dummy job -- turn off computer activity light

dumJob		EQU	*
		CAF	ZERO
		AD	DSALMOUT
		MASK	NOTACTLT
		TS	DSALMOUT	; turn bit1 off

	; runtime loop for dummy job

dumJob1		EQU	*
		CCS	newJob		; check for context switch
		TC	dumJob2		; yes
		TC	dumJob1		; no

	; exiting dummy job -- turn on computer activity light

dumJob2		EQU	*
		CS	DSALMOUT	; inclusive OR bit 1 with 1 using
		MASK	NOTACTLT	; Demorgan's theorem
		COM
		TS	DSALMOUT

		TC	CHANG1		; exit to run higher priority job
		TC	dumJob		; job done, return here, light off again

NOTACTLT	DS	%77776		; 1's compliment of bit1 (comp activity light)
