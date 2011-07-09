;==========================================================================
; EXEC erasable memory segment (file:exec_e.asm)
;
; Version:	1.0
; Author:	John Pultorak
; Date:		04/26/2002
;
; PURPOSE:
; Eraseable memory variables and structures for the EXEX. See the EXEC
; source code file for more information.
;
; The COLOSSUS version of this is on p. 70.
;
; ERRATA: The current version of the EXEC does not set the BANKSET parameter.
; Instead, it stores the 14-bit CADR in LOC. Also, the JOBPRIOBASE field
; has been added.
;==========================================================================


MAXJOBS		EQU	7		; max number jobs (not incl current job)

JRECSZ		EQU	13		; size of job record (words)


	; (COLOSSUS, p. 70)
	; dynamically allocated core sets for EXEC jobs (8 sets)

	; record for current (running) job
	; Job priority: 0=no job, 1=lowest priority job, 2=...

EX_currentJob	EQU	*


MPAC		EQU	*		; multi-purpose accumulator
		DS	0
		DS	0
		DS	0
		DS	0
		DS	0
		DS	0
		DS	0

MODE		DS	0		; +1 for TP, +0 for DP, or -1 for vector
LOC		DS	0		; location associated with job
BANKSET		DS	0		; usually contains bank setting
PUSHLOC		DS	0		; word of packed interpretive parameters
PRIORITY	DS	0		; priority of present job and work area
JOBPRIOBASE	DS	0		; nominal job priority


	; records for additional jobs waiting to run

JREC0		EQU	*
		ORG	JREC0+JRECSZ

JREC1		EQU	*
		ORG	JREC1+JRECSZ

JREC2		EQU	*
		ORG	JREC2+JRECSZ

JREC3		EQU	*
		ORG	JREC3+JRECSZ

JREC4		EQU	*
		ORG	JREC4+JRECSZ

JREC5		EQU	*
		ORG	JREC5+JRECSZ

JREC6		EQU	*
		ORG	JREC6+JRECSZ


	; sorted list of jobs to run. The list is sorted by job priority
	; with the highest priority job at the top of the list. Each
	; entry on the list is a word index to a job record; the indexes are
	; relative to 'EX_currentJob', but the current job is not on the
	; list.

EX_jobList	EQU	*
		ORG	EX_jobList+MAXJOBS


LOCCTR		EQU	EX_jobList	; index to next job record


CHGJOB		EQU	1		; change jobs at next opportunity
KEEPJOB		EQU	0		; keep the same job
newJob		DS	0		; change flag (set to CHGJOB or KEEPJOB)

EX_JW_saveQ	DS	0		; return address
EX_JW_loopCnt	DS	0		; loop counter
EX_JW_CADR	DS	0		; address of job to wake
EX_JW_foundit	DS	0		; 0=job not found, 1=found
EX_JW_jobPtr	DS	0		; points to job rec in list
EX_JW_jobPtr2	DS	0		; points to job rec ahead of jobPtr
EX_JW_fndIndx	DS	0		; index to awoken record

EX_AJ_saveQ	DS	0		; return address
EX_AJ_loopCnt	DS	0		; loop counter
EX_AJ_jobPrio	DS	0		; priority of new job
EX_AJ_jobPtr	DS	0		; initialized to EX_jobList at startup

EX_IN_saveQ	DS	0		; return address
EX_IN_loopCnt	DS	0		; loop counter
EX_IN_jobPtr	DS	0		; points to job rec in list
EX_IN_recIndex	DS	0		; record index init counter
EX_IN_field	DS	0		; index to field from start of record
EX_IN_findx	DS	0		; total index to field 

EX_MN_runAddr	DS	0		; address of job to run
EX_MN_field	DS	0		; index to field from start of record
EX_MN_findx	DS	0		; total index to field 

EX_RM_saveQ	DS	0		; return address
EX_RM_jobPtr	DS	0		; points to job rec in list
EX_RM_jobPtr2	DS	0		; points to job rec behind jobPtr
EX_RM_savePtr	DS	0		; tmp store for index taken off list
EX_RM_loopCnt	DS	0		; loop counter
EX_RM_retval	DS	0		; tmp store for return value
EX_RM_field	DS	0		; index to field from start of record
EX_RM_findx	DS	0		; total index to field 

EX_IS_newPrio	DS	0		; INPUT: priority to be inserted
EX_IS_newPrioB	DS	0		; INPUT: nominal priority to be inserted
EX_IS_newLoc	DS	0		; INPUT: address to be inserted
EX_IS_saveQ	DS	0		; return address
EX_IS_jobPtr	DS	0		; points to job rec in list
EX_IS_jobPtr2	DS	0		; points to job rec ahead of jobPtr
EX_IS_loopCnt	DS	0		; loop counter
