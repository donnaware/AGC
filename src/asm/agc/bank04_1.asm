;==========================================================================
; MAJOR MODE CHANGE (file:bank04_1.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 192-204.
;==========================================================================

;--------------------------------------------------------------------------
; VERB 37
;
; In COLOSSUS, a successful V37 apparently also restarts the AGC. Here,
; we implement a subset of COLOSSUS to kick off a job associated with the
; verb.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.192-204.
;--------------------------------------------------------------------------


V37		EQU	*		; verb 37
		TS	MMNUMBER	; save major mode

	; ** skipped quite a bit of guidance system-related code **

		TC	CHECKTAB

	; ** skipped more guidance system-related code **

V37BAD		EQU	*
		TC	RELDSP		; releases display from astronaut
		TC	POSTJUMP	; bring back last normal display if there
		CADR	PINBRNCH	; was one, OY

	; Search table for entry matching major mode number. Table entries
	; are sorted by major mode number, so the search occurs in order from
	; lowest number to highest.

CHECKTAB	EQU	*
		CAF	ZERO		; was CA NOV37MM in Block II
		AD	NOV37MM		; the no. of MM in table (minus 1)

AGAINMM		TS	MPAC+1

		CAF	ZERO		; was CA PREMM1 in Block II
		INDEX	MPAC+1
		AD	PREMM1		; obtain which MM this is for
		MASK	LOW7
		COM
		AD	MMNUMBER
		CCS	A		; MMNUMBER - current table MM number

		CCS	MPAC+1		; if GR, see if anymore in list
		TC	AGAINMM		; yes, get next one (was TCF)
		TC	V37NONO		; last time or passed MM (was TCF)

	; Found the index into the major mode table for entry matching the
	; major mode number input by the user.

		CAF	ZERO		; was CA MPAC+1 in Block II
		AD	MPAC+1
		TS	MINDEX		; save index for later

		TC	goMMchange	; in Block II, jumped to restart AGC

	; Requested MM doesn't exist

V37NONO		EQU	*
		TC	FALTON		; come here if MM requested doesn't exist
		TC	V37BAD



;--------------------------------------------------------------------------
; FCADRMM
;
; For verb 37, two tables are maintained. Each table has an entry for each
; major mode that can be started from the keyboard. The entries are put
; into the table with the entry for the highest major mode coming first,
; to the lowest major mode which is the last entry in the table.
;
; The FCADRMM table contains the FCADR of the starting job of the major mode.
;
; The entries in this table must match the entries in PREMM1 below.
;--------------------------------------------------------------------------

FCADRMM1	EQU	*
		CADR	P79
		CADR	P78
		CADR	P04
		CADR	P03
		CADR	P02
		CADR	P01
		CADR	P00
		; etc *********

;--------------------------------------------------------------------------
; PREMM1
;
; The PREMM1 table contains the E-bank, major mode, and priority information.
; It is in the following form:
;
; PPP PPE EEM MMM MMM
;
; Where,
;	the 7 'M' bits contain the major mode number
;	the 3 'E' bits contain the E-bank number (ignored in Block I)
;	the 5 'P' bits contain the priority at which the job is to be started
;
; The entries in this table must match the entries in FCADRMM1 above.
;--------------------------------------------------------------------------

PREMM1		EQU	*
		DS	%26117		; MM 79, PRIO 13
		DS	%26116		; MM 78, PRIO 13
		DS	%26004		; MM 04, PRIO 13
		DS	%26003		; MM 03, PRIO 13
		DS	%26002		; MM 02, PRIO 13
		DS	%26001		; MM 01, PRIO 13
		DS	%26000		; MM 00, PRIO 13
		; etc *********
EPREMM1		EQU	*

NOV37MM		DS	EPREMM1-PREMM1-1 ; number of entries in table (minus 1)

