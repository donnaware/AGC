;==========================================================================
; KEYRUPT (file:keyrupt_f.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 77.
;==========================================================================

;--------------------------------------------------------------------------
; KEYRUPT -- KEYBOARD INTERRUPT HANDLER
;
; Performs keyRUPT functions. Triggered by a keyboard key entry. N-key
; rollover, implemented as follows: When an interrupt occurs, the current
; job record is saved and then restored when the job resumes after the
; interrupt. The job record includes MPAC, a set of general purpose
; registers assigned to the job. When the keyboard interrupt occurs, the
; interrupt handler stores the keyboard character in MPAC. A job is then
; started to process the character. The new job copies its MPAC fields from
; the current job, so the character is copied to storage owned by the job.
; When additional keyboard interrupts occur, they start their own jobs.
; Up to 7 jobs can be waiting in a queue for execution, so as many as
; 7 keyboard characters can be enqueued for processing. Since all keyboard
; jobs have the same priority, they are enqueued in the order received.
; Its OK for the keyboard handler to modify the MPAC of the interrupted job
; because the interrupted job's record is restored at the end of the
; interrupt service routine.
;
; Not included in my partial AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, so I had to improvise it from the original flow charts in
; E-1574, p.77.
;--------------------------------------------------------------------------

CHRPRIO		DS	%37776		; priority of CHARIN job (highest)

KEYPROG		EQU	*
		XCH	Q
		TS	KEYRET		; save return address

	; prepare to EXEC a job to handle the keystroke.

		XCH	IN0
		MASK	LOW5
		XCH	MPAC		; save keyboard code
		XCH	KP_MPAC		; save previous MPAC

	; create the job. It terminates when it finishes processing the key.

		CAF	CHRPRIO		; CHARIN job priority
		TC	NOVAC
		CADR	CHARIN		; 14 bit CHARIN job address

		XCH	KP_MPAC
		XCH	MPAC		; restore previous MPAC
	
		XCH	KEYRET
		TS	Q		; restore return address
		RETURN



