;==========================================================================
; WAITLIST (file:waitlist_e.asm)
;
; Version:  1.0
; Author:   John Pultorak
; Date:     11/15/2001
;
; PURPOSE:
; Eraseable memory variables and structures for the WAITLIST. See the
; WAITLIST source code file for more information.
;==========================================================================


MAXTASK		EQU	7		; max number of tasks
MAXVAL		EQU	%037777		; largest pos 15-bit int (+16383 dec)
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
WL_T3_oldBank	DS	0		; current bank

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

