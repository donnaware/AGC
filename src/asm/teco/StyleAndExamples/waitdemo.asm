; WAITLIST demonstration (file:waitdemo.asm)
;
; Version:	1.0
; Author:	John Pultorak
; Date:		11/13/2001
;
; PURPOSE:
; AGC WAITLIST demonstration program.
;
; OPERATION:
; TBD.
;
; ERRATA:
; - Written for the AGC4R assembler. The assembler directives and syntax
; differ somewhat from the original AGC assembler.
; - No special effort was made to optimize the algorithms or memory usage.
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
	; WAITLIST data area
	; ==============================================

MAXTASK		EQU	7		; max number of tasks
MAXVAL		EQU	%037777		; largest pos 15-bit int (+16383 decimal)
MAXDELAY	EQU	12000		; 120 seconds (in .01 sec ticks)
MAXTIMEOUT	EQU	MAXVAL-MAXDELAY+1 ; TIME3 setting for MAXDELAY


	; task delta t: number of 10 mSec ticks until timeout.
	;   i.e.: 0=timeout, 1=10mS until timeout, 2=20mS until timeout...
	;   maximum time delay is 120 (decimal) seconds.
	;
	; If a task record is empty (unused), the address is always set to
	; zero and the time is set to MAXDELAY.

	; task record structure
TSKTIME		EQU	0		; offset to task delta time
TSKADDR		EQU	1		; offset to 14-bit task address

TRECSZ		EQU	2		; size of task record (words)

	; Array of all task records
WL_taskList	EQU	*
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


WL_IN_saveQ	DS	0		; return address
WL_IN_taskPtr	DS	0		; points to task rec in list
WL_IN_loopCnt	DS	0		; loop counter

WL_AT_saveQ	DS	0		; return address
WL_AT_taskPtr	DS	0		; points to task rec in list
WL_AT_newTime	DS	0		; time to be inserted
WL_AT_timeLeft	DS	0		; time remaining until timeout
WL_AT_loopCnt	DS	0		; loop counter

WL_T3_saveQ	DS	0		; return address

WL_ST_saveQ	DS	0		; return address
WL_ST_taskPtr	DS	0		; points to task rec in list
WL_ST_newTime	DS	0		; time-out time
WL_ST_loopCnt	DS	0		; loop counter

WL_RT_saveQ	DS	0		; return address
WL_RT_runAddr	DS	0		; address of task to run

WL_RM_saveQ	DS	0		; return address
WL_RM_taskPtr	DS	0		; points to task rec in list
WL_RM_taskPtr2	DS	0		; points to task rec behind taskPtr
WL_RM_loopCnt	DS	0		; loop counter
WL_RM_retval	DS	0		; tmp store for return value

WL_IS_newTime	DS	0		; INPUT: time to be inserted
WL_IS_newAddr	DS	0		; INPUT: address to be inserted
WL_IS_saveQ	DS	0		; return address
WL_IS_taskPtr	DS	0		; points to task rec in list
WL_IS_taskPtr2	DS	0		; points to task rec ahead of taskPtr
WL_IS_loopCnt	DS	0		; loop counter

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
		TS	ARUPT
		XCH	Q
		TS	QRUPT
		TC	goDS

		ORG	KEYRUPT		; DSKY keyboard interrupt entry point
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

time1		DS	%50

goMAIN		EQU	*
		INHINT			; inhibit interrupts

	; first, check for standby operation.
		XCH	ofbit
		TS	OUT1

		TCR	WL_initWL	; initialize WAITLIST

		CAF	time1		; add a test task
		TC	WL_addTask
		DS	task1		; 14-bit task address

		RELINT
theend		TC	theend

	; ==============================================
	; WAITLIST constants
	; ----------------------------------------------

WL_taskRecSize	DS	TRECSZ		; size of a task record (words)
WL_tskLstStart	DS	WL_taskList	; starting address for task list
WL_tskLstEnd	DS	MAXTASK-1@TRECSZ+WL_taskList
WL_numTasks	DS	MAXTASK-1	; init loop counter for all tasks
WL_numTasks1	DS	MAXTASK-2	; init loop counter for all tasks - 1

WL_maxVal	DS	MAXVAL
WL_maxDelay	DS	MAXDELAY
WL_maxTimeOut	DS	MAXTIMEOUT


	; ----------------------------------------------
	; WL_initWL - INITIALIZE WAITLIST
	;
	; Subroutine initializes the eraseable memory segment for WAITLIST. 
	; Necessary in case the AGC is restarted.
	;
	; Note: the valid range for TIME3 is 10440 to 37777 (which spans 
	;   12000 (base 10) ticks, which corresponds to 120 seconds)
	;   positive overflow occurs at 40000, which triggers T3RUPT.  
	;   TIME3 values of 0 to 10437 are illegal; these values occur
	;   after timeout when the counter overflows. TIME3 values in this
	;   range indicate that timeout has occurred and that T3RUPT is
	;   presently occuring, or is pending.
	; ----------------------------------------------
WL_initWL	EQU	*
		XCH	Q
		TS	WL_IN_saveQ	; save return address

		CAF	WL_maxTimeOut
		TS	TIME3

	; Iterate through task list and initialize all records to NIL

		CAF	WL_tskLstStart	; init pointer to start of list
		TS	WL_IN_taskPtr

		CAF	WL_numTasks	; loop for number of tasks
WL_IN_loop	EQU	*
		TS	WL_IN_loopCnt

		CAF	WL_maxDelay
		INDEX	WL_IN_taskPtr
		TS	TSKTIME

		CAF	zero
		INDEX	WL_IN_taskPtr
		TS	TSKADDR

		XCH	WL_IN_taskPtr	; bump task pointer back 1 record
		AD	WL_taskRecSize
		TS	WL_IN_taskPtr

		CCS	WL_IN_loopCnt	; done checking task list?
		TC	WL_IN_loop	; not yet

		XCH	WL_IN_saveQ
		TS	Q		; restore return address
		RETURN

	; ----------------------------------------------
	; WL_addTask - ADD TASK TO WAITLIST
	;
	; Subroutine adds a task to WL_taskList. The following conditions are
	; true upon entry.
	; 1) The task list is sorted so the next task scheduled for execution 
	;    is at the front of the list.
	; 2) If no tasks are currently scheduled, the task record at the front
	;    of the list will be NIL.
	; 3) Unused (NIL) records in the task list have their time fields set to
	;    MAXDELAY and their address fields set to zero.
	; 4) If any tasks are on the waitlist, the time field in that task's
	;    record will contain the remaining time AFTER the next timeout. The
	;    task scheduled for execution at timeout will have a time remaining
	;    of zero. 
	;    Any other tasks that will execute at that time will also have a time of 
	;    zero. Tasks that will execute some time in the future AFTER timeout 
	;    will have nonzero times; these times indicate the additional time 
	;    needed after the next timeout.
	;
	; WL_addTask can be called from from an interrupt, or from normal execution.
	; It is the only public function of the waitlist.
	;
	; A task is scheduled for execution by calling 'WL_addTask' and 
	; furnishing the time-out time and starting address.
	;	L	XCH	TASK_TIMEOUT	; in 10 mSec ticks
	;	L+1	TC	WL_addTask
	;	L+2	DS	TASK_ADDRESS	; 14-bit address
	;	L+3	... execution resumes here
	;
	; TASK_TIMEOUT = a positive integer from 1 - MAXDELAY that specifies the delay
	;    in 10 mSec ticks. Maximum delay is 12000 (2 minutes).
	; TASK_ADDRESS = starting address of the task (14-bit address)
	;
	; Tasks execute when TIME3 overflows and generates an interrupt (T3RUPT).
	; Tasks terminate themselves by jumping to ENDTASK.
	;	TC	ENDTASK
	;
	; Because tasks execute during an interrupt, they should be fairly short.
	; Tasks can initiate longer operations by scheduling a 'job' using EXEC.
	; ----------------------------------------------

WL_addTask	EQU	*
		INHINT
		TS	WL_AT_newTime	; save task time
		XCH	Q
		TS	WL_AT_saveQ	; save return address-1

		CAF	zero
		INDEX	WL_tskLstEnd
		AD	TSKADDR
		CCS	A		; list full?
		TC	WL_AT_done	; >0 yes, so give up

	; Calculate time remaining until currently scheduled time-out.

		CAF	zero
		AD	TIME3		; get time
		TS	WL_AT_timeLeft	; save it, temporarily

	; Did TIME3 recently overflow? If so, we are inside T3RUPT, or T3RUPT
	; is pending. TIME3 values from 0 - 10437 are not legal, so they
	; indicate that an overflow has occurred.

		CS	WL_maxTimeOut
		AD	WL_AT_timeLeft
		CCS	A		; TIME3 recently overflowed?
		TC	WL_AT_noOvf	; >0 no
		TC	WL_AT_noOvf	; +0 no
		TC	*+2		; <0 yes
		TC	WL_AT_noOvf	; -0 no

	; TIME3 already timed-out, so we must be inside T3RUPT, or T3RUPT
	; is pending. Just add the new task to the list. No time correction
	; is necessary; the epoch is NOW.

		CAF	zero
		AD	WL_AT_newTime
		TS	WL_IS_newTime	; set time field in new task record

		INDEX	WL_AT_saveQ	; indirectly address WL_AT_saveQ
		CAF	0		
		TS	WL_IS_newAddr	; set addr field in new task record

		TCR	WL_insert	; add new task to task list
		TC	WL_AT_done

	; TIME3 has not timed out yet. Calculate time remaining until timeout
	; (timeout occurs when TIME3 overflows)

WL_AT_noOvf	EQU	*
		CS	WL_AT_timeLeft	; get -TIME3
		AD	WL_maxVal
		AD	one
		TS	WL_AT_timeLeft	; time left = -TIME3 + %37777 + 1

	; Compare that time against the timeout for the new task.

WL_AT_chkOrder	EQU	*
		CS	WL_AT_newTime
		AD	WL_AT_timeLeft
		CCS	A		; compare new task to current
		TC	WL_AT_mkFirst	; >0 (make new task 1st)
		TC	*+2		; +0
		TC	*+1		; <0

	; The new task does not need to run before the current time-out, so
	; just add it to the list. Subtract the remaining time interval from the 
	; new task's time, so the new task will have the same epoch as the other 
	; tasks on the list.

		CS	WL_AT_timeLeft
		AD	WL_AT_newTime	; make epoch correction
		TS	WL_IS_newTime	; set time field in new task record

		INDEX	WL_AT_saveQ	; indirectly address WL_AT_saveQ
		CAF	0		
		TS	WL_IS_newAddr	; set addr field in new task record

		TCR	WL_insert	; add new task to task list
		TC	WL_AT_done

	; The new task needs to run prior to the current time-out. Add the time
	; remaining to all tasks currently on the list to change their epoch
	; to NOW.

WL_AT_mkFirst	EQU	*
		CAF	WL_tskLstStart	; set pointer to front of list
		TS	WL_AT_taskPtr

		CAF	WL_numTasks	; loop for number of tasks
WL_AT_loop	EQU	*
		TS	WL_AT_loopCnt

		CAF	zero
		INDEX	WL_AT_taskPtr
		AD	TSKADDR
		CCS	A		; end of list?
		TC	*+2		; >0 no, so keep going
		TC	WL_AT_schTsk	; +0 yes, add the new task

		CAF	zero
		INDEX	WL_AT_taskPtr
		AD	TSKTIME
		AD	WL_AT_timeLeft	; time-out = time-out + timeLeft
		INDEX	WL_AT_taskPtr
		TS	TSKTIME		

		XCH	WL_AT_taskPtr	; bump task pointer back 1 record
		AD	WL_taskRecSize
		TS	WL_AT_taskPtr
		
		CCS	WL_AT_loopCnt	; done fixing the times?
		TC	WL_AT_loop	; not yet

	; Now that the tasks all share the same epoch, add the new task to the
	; list and call the scheduler to schedule the next task.

WL_AT_schTsk	EQU	*
		CAF	zero
		AD	WL_AT_newTime
		TS	WL_IS_newTime	; set time field in new task record

		INDEX	WL_AT_saveQ	; indirectly address WL_AT_saveQ
		CAF	0		
		TS	WL_IS_newAddr	; set addr field in new task record

		TCR	WL_insert	; add new task to task list
		
		TCR	WL_schedTask	; schedule the next task

WL_AT_done	EQU	*
		XCH	WL_AT_saveQ		
		AD	one
		TS	Q		; restore return address
		RELINT
		RETURN

	; ----------------------------------------------
	; T3Task - T3 TIMEOUT
	;
	; Perform WAITLIST activities when TIME3 times-out. Called by the 
	; T3 interrupt handler.
	; ----------------------------------------------
	
WL_TIME3task	EQU	*
		XCH	Q
		TS	WL_T3_saveQ	; save return address

	; Execute all timed-out tasks.

		TCR	WL_runTasks

	; Set up TIME3 to overflow at the next task's time-out.
	; Adjust the time-outs for all remaining tasks.

		TCR	WL_schedTask

		XCH	WL_T3_saveQ
		TS	Q		; restore return address
		RETURN

	; ----------------------------------------------
	; WL_runTasks - RUN TIMED-OUT TASK(S)
	;
	; Runs all tasks timed-out on WL_taskList. Tasks are removed
	; from the list before they are run.
	; ----------------------------------------------

WL_runTasks	EQU	*
		XCH	Q
		TS	WL_RT_saveQ	; save return address

	; loop, checking the task on the front of the list. If it is
	; timed out, remove it from the list and run it.

WL_RT_loop	EQU	*
		CAF	zero
		INDEX	WL_tskLstStart
		AD	TSKTIME
		CCS	A		; task timed out?
		TC	WL_RT_done	; >0 no, so we are done
		TC	*+2		; +0
		TC	*+1		; <0

	; This task has timed out, so run it.

		TCR	WL_remove	; remove task from list
		TS	WL_RT_runAddr	; save 14-bit address of task to run

	; The task address is always 14-bit, so check whether the address falls
	; within erasable or fixed-fixed memory. If so, use it as-is; otherwise,
	; set the bank register and change the address to 12-bit.

		COM			; -(14bitAddr)+%6000
		AD	bankAddr
		CCS	A		; task is bank addressed?
		TC	WL_RT_runIt	; >0 no, just run it, as is
		TC	*+2		; +0 yes
		TC	*+1		; <0 yes

		CAF	zero
		AD	WL_RT_runAddr
		TS	BANK		; set the bank

		MASK	lowAddr		; get lowest 10-bits of address
		AD	bankAddr	; set bits 11,12 for fixed-switchable
		TS	WL_RT_runAddr

WL_RT_runIt	EQU	*
		INDEX	WL_RT_runAddr	; apply indirect address to next instr.
		TC	0		; run the task

ENDTASK		EQU	*		; task returns here
		TC	WL_RT_loop	; check next task on list

WL_RT_done	EQU	*
		XCH	WL_RT_saveQ
		TS	Q		; restore return address
		RETURN

	; ----------------------------------------------
	; WL_schedTask - SCHEDULE NEXT TASK
	;
	; Schedule task on the front of list for the next time-out. Adjust the 
	; time-out for all other tasks on the list, so they contain the remaining
	; time after the next timeout.
	; ----------------------------------------------

WL_schedTask	EQU	*
		XCH	Q
		TS	WL_ST_saveQ	; save return address

		CAF	zero
		INDEX	WL_tskLstStart
		AD	TSKADDR
		CCS	A		; task scheduled?
		TC	*+2		; >0 yes
		TC	WL_ST_noTask	; +0 no, so we are done

		CAF	zero
		INDEX	WL_tskLstStart
		AD	TSKTIME
		TS	WL_ST_newTime	; save the new task's time-out

	; Iterate through all tasks on the list. Subtract the time-out time
	; from each task. (The 1st task on the list will now have a time-out
	; of zero)

		CAF	WL_tskLstStart	; set pointer to front of list
		TS	WL_ST_taskPtr

		CAF	WL_numTasks	; loop for number of tasks
WL_ST_loop	EQU	*
		TS	WL_ST_loopCnt

		CAF	zero
		INDEX	WL_ST_taskPtr
		AD	TSKADDR
		CCS	A		; end of list?
		TC	*+2		; >0 no, so keep going
		TC	WL_ST_setT3	; +0 yes, set TIME3

		CAF	zero
		INDEX	WL_ST_taskPtr
		AD	TSKTIME
		EXTEND
		SU	WL_ST_newTime	; time-out = time-out - newtime
		INDEX	WL_ST_taskPtr
		TS	TSKTIME		

		XCH	WL_ST_taskPtr	; bump task pointer back 1 record
		AD	WL_taskRecSize
		TS	WL_ST_taskPtr
		
		CCS	WL_ST_loopCnt	; done fixing the times?
		TC	WL_ST_loop	; not yet

	; Set TIME3 to overflow at the time-out of the task on the front
	; of the list: TIME3 = %37777 - WL_ST_newTime + 1

WL_ST_setT3	EQU	*
		CS	WL_ST_newTime
		AD	WL_maxVal
		AD	one
		TS	TIME3		; overflow at new time-out time
		TC	WL_ST_done

WL_ST_noTask	EQU	*
		CAF	WL_maxTimeOut
		TS	TIME3		; nothing scheduled, reset the clock

WL_ST_done	EQU	*
		XCH	WL_ST_saveQ
		TS	Q		; restore return address
		RETURN

	; ----------------------------------------------
	; WL_insert - INSERT TASK INTO SORTED LIST
	;
	; Insert a task record into the sorted list. Use 'WL_IS_newTime' and
	; 'WL_IS_newAddr' to set the fields of record to be inserted.
	; Performs an insertion sort, with the records sorted by time.
	; Lowest times are at the front of the list. If several records
	; have the same time, the records inserted first will appear first
	; in the list. NIL records have a time of NOTASK and a address
	; of positive zero.
	; ----------------------------------------------

WL_insert	EQU	*
		XCH	Q
		TS	WL_IS_saveQ	; save return address

		CAF	WL_tskLstEnd	; set pointer to back of list
		TS	WL_IS_taskPtr

		EXTEND
		SU	WL_taskRecSize	; set pointer to rec in front of it
		TS	WL_IS_taskPtr2

		CAF	zero
		INDEX	WL_IS_taskPtr
		AD	TSKADDR
		CCS	A		; list full?
		TC	WL_IS_done	; >0 yes

	; Work from the back of the list to the front, pushing each record
	; to the back until the insertion point is found.

		CAF	WL_numTasks1	; loop for number of tasks minus 1
WL_IS_loop	EQU	*
		TS	WL_IS_loopCnt

		CAF	zero
		INDEX	WL_IS_taskPtr2
		AD	TSKADDR
		CCS	A		; previous record is NIL?
		TC	*+2		; no, so check it
		TC	WL_IS_bumpPtr	; yes, so skip to next record


	; Is this the insertion point?

		CS	WL_IS_newTime
		INDEX	WL_IS_taskPtr2
		AD	TSKTIME
		CCS	A		; found insertion point?
		TC	*+4		; >0 no, keep checking
		TC	WL_IS_insRec	; +0 yes
		TC	WL_IS_insRec	; <0 yes
		TC	WL_IS_insRec	; -0 yes

	; No, bump the record toward the back of the list.

		CAF	zero
		INDEX	WL_IS_taskPtr2
		AD	TSKTIME
		INDEX	WL_IS_taskPtr
		TS	TSKTIME		; copy time field

		CAF	zero
		INDEX	WL_IS_taskPtr2
		AD	TSKADDR
		INDEX	WL_IS_taskPtr
		TS	TSKADDR		; copy address field

WL_IS_bumpPtr	EQU	*
		XCH	WL_IS_taskPtr	; bump task pointer forward 1 record
		EXTEND
		SU	WL_taskRecSize
		TS	WL_IS_taskPtr

		EXTEND
		SU	WL_taskRecSize	; set pointer to record in front of it
		TS	WL_IS_taskPtr2

		CCS	WL_IS_loopCnt	; done bumping tasks backward?
		TC	WL_IS_loop	; not yet

	; Insert new record.

WL_IS_insRec	EQU	*
		CAF	zero
		AD	WL_IS_newTime
		INDEX	WL_IS_taskPtr
		TS	TSKTIME		; set time field

		CAF	zero
		AD	WL_IS_newAddr
		INDEX	WL_IS_taskPtr
		TS	TSKADDR		; set address field

WL_IS_done	EQU	*
		XCH	WL_IS_saveQ
		TS	Q		; restore return address
		RETURN

	; ----------------------------------------------
	; WL_remove - REMOVE TASK FROM FRONT OF LIST
	;
	; Returns the address of the task in register A. If the list is
	; empty, it returns zero in A. If a task is removed from the list,
	; the remaining tasks are moved up to the front.
	; ----------------------------------------------

WL_remove	EQU	*
		XCH	Q
		TS	WL_RM_saveQ	; save return address

		CAF	WL_tskLstStart	; set pointer to front of list
		TS	WL_RM_taskPtr

		AD	WL_taskRecSize	; set pointer to next rec behind it
		TS	WL_RM_taskPtr2

	; Save the address of record at the front of the list.

		CAF	zero
		INDEX	WL_RM_taskPtr
		AD	TSKADDR
		TS	WL_RM_retval	; get address of 1st task

		CCS	A		; list empty?
		TC	*+2		; >0, no
		TC	WL_RM_done	; +0, yes, so exit

	; Loop through the remaining records in the task list and
	; bubble them up to the front.

		CAF	WL_numTasks1	; loop for number of tasks minus 1
WL_RM_loop	EQU	*
		TS	WL_RM_loopCnt

		CAF	zero
		INDEX	WL_RM_taskPtr2
		AD	TSKTIME
		INDEX	WL_RM_taskPtr
		TS	TSKTIME		; copy time field

		CAF	zero
		INDEX	WL_RM_taskPtr2
		AD	TSKADDR
		INDEX	WL_RM_taskPtr
		TS	TSKADDR		; copy address field

		CCS	A		; remainder of list empty?
		TC	*+2		; >0, no
		TC	WL_RM_done	; +0, yes, so exit

		XCH	WL_RM_taskPtr	; bump task pointer back 1 record
		AD	WL_taskRecSize
		TS	WL_RM_taskPtr

		AD	WL_taskRecSize	; set pointer to record behind it
		TS	WL_RM_taskPtr2

		CCS	WL_RM_loopCnt	; done bumping tasks upward?
		TC	WL_RM_loop	; not yet

	; Since we removed a record, the last record on the list
	; should be NIL.

		CAF	WL_maxDelay
		INDEX	WL_RM_taskPtr
		TS	TSKTIME		; set time field to NIL

		CAF	zero
		INDEX	WL_RM_taskPtr
		TS	TSKADDR		; set address field to NIL

WL_RM_done	EQU	*
		XCH	WL_RM_saveQ
		TS	Q		; restore return address
		XCH	WL_RM_retval	; return task address in A
		RETURN

	; ----------------------------------------------
	; RUPT (INTERRUPT) SERVICE ROUTINES
	; ----------------------------------------------

goT3		EQU	*
		TCR	WL_TIME3task	; handle WAITLIST interrupt
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
	; TEST TASKS
TADDR1		EQU	%50
TADDR2		EQU	%51
TADDR3		EQU	%52
TADDR4		EQU	%53
TADDR5		EQU	%54
TADDR6		EQU	%55
TADDR7		EQU	%56

		ORG	%22000

	; TEST CODE - TASK 1
task1		EQU	*
		XCH	TADDR1
		AD	one
		TS	TADDR1

		CAF	time1
		TC	WL_addTask
		DS	task1

		TC	ENDTASK
