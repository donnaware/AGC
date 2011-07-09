;==========================================================================
; AGC documentation (file:doc.asm)
;
; Version:  1.0
; Author:   John Pultorak
; Date:     06/01/2002
;
; PURPOSE:
; Documents AGC ops source code.
;==========================================================================


;--------------------------------------------------------------------------
; DSKY OPERATION
;
;	verb/noun (V/N) flash: When the verb and noun indicators flash
;		at 1Hz, the DSKY is waiting for keyboard input.
;
;
; Display elapsed time from the AGC clock:
;	<VERB> <0> <6> <NOUN> <3> <6> <ENTER>
;
; Test display lights
;	a) <VERB> <3> <5> <ENTER>
;	b) all DSKY lamps and display segments illuminate for 5 sec.
;	c) after 5 sec, the DSKY lamps extinguish
;
; Load component 1 for dataset at octal address 50 with octal 123
;	a) <VERB> <2> <1> <NOUN> <0> <1> <ENTER>
;	b) verb/noun display flashes; waiting for address
;	c) <5> <0> <ENTER>
;	d) verb/noun display flash continues; waiting for data
;	e) <1> <2> <3> <ENTER>
;	f) octal word from R1 is loaded at address 50,
;
; Display component 1 of dataset at octal address 50:
;	a) <VERB> <0> <1> <NOUN> <0> <1> <ENTER>
;	b) verb/noun display flashes; waiting for address
;	c) <5> <0> <ENTER>
;	d) octal word from address 50 is displayed in R1
;
; Load 3 component dataset at octal address 50 with octal values
;   123,456,701
;	a) <VERB> <2> <5> <NOUN> <0> <1> <ENTER>
;	b) verb/noun display flashes; waiting for address
;	c) <5> <0> <ENTER>
;	d) verb/noun display flash continues; waiting for data
;	e) <1> <2> <3> <ENTER>
;	f) <4> <5> <6> <ENTER>
;	g) <7> <0> <1> <ENTER>
;	h) octal word from R1 is loaded at address 50,
;	octal word from R2 is loaded at address 51,
;	octal word from R3 is loaded at address 52
;
; Display 3 component dataset beginning at address 50:
;	a) <VERB> <0> <5> <NOUN> <0> <1> <ENTER>
;	b) verb/noun display flashes; waiting for address
;	c) <5> <0> <ENTER>
;	d) octal word from address 50 is displayed in R1,
;	octal word from address 51 is displayed in R2,
;	octal word from address 52 is displayed in R3
;
;--------------------------------------------------------------------------


;--------------------------------------------------------------------------
; COLOSSUS REGULAR VERBS (00-39 decimal)
;
; This is adapted from the Apollo 204 accident report posted on multiple
; web sites by Richard F. Drushel. The information has been changed as
; necessary to be consistent with usage in COLOSSUS.
;
;
; Verb |                               |
; Code |          Description          |               Remarks
;      |                               |
; 01   |  Display octal comp 1 in R1   |  Performs octal display of data on
;      |                               |  REGISTER 1.
;      |                               |
; 02   |  Display octal comp 2 in R2   |  Performs octal display of data on
;      |                               |  REGISTER 1.
;      |                               |
; 03   |  Display octal comp 3 in R3   |  Performs octal display of data on
;      |                               |  REGISTER 1.
;      |                               |
; 04   |  Display octal comp 1,2       |  Performs octal display of data on
;      |  in R1,R2                     |  REGISTER 1 and REGISTER 2
;      |                               |
; 05   |  Display octal comp 1,2,3     |  Performs octal display of data on
;      |  in R1,R2,R3                  |  REGISTER 1, REGISTER 2, and REGISTER 3.
;      |                               |
; 06   |  Display decimal in R1 or     |  Performs decimal display of data on
;      |  R1,R2 or R1,R2,R3            |  appropriate registers.  The scale
;      |                               |  factors, types of scale factor
;      |                               |  routines, and component information
;      |                               |  are stored within the machine for each
;      |                               |  noun which it is required to display
;      |                               |  in decimal.
;      |                               |
; 07   |  Display DP decimal in R1,R2  |  Performs a double precision decimal
;      |                               |  display of data on REGISTER 1 and
;      |                               |  REGISTER 2.  It does no scale
;      |                               |  factoring.  It merely performs a 10-
;      |                               |  character, fractional decimal
;      |                               |  conversion of two consecutive, erasable
;      |                               |  registers, using REGISTER 1 and
;      |                               |  REGISTER 2.  The sign is placed in the
;      |                               |  REGISTER 1 sign position with the
;      |                               |  REGISTER 2 sign position remaining
;      |                               |  blank.  It cannot be used with mixed
;      |                               |  nouns.  Its intended use is primarily
;      |                               |  with "machine address to be specified"
;      |                               |  nouns.
;      |                               |
; 08   |  (Spare)                      |
;      |                               |
; 09   |  (Spare)                      |
;      |                               |
; 10   |  (Spare)                      |
;      |                               |
; 11   |  Monitor octal comp 1 in R1   |  Performs octal display of updated data
;      |                               |  every 1/2 second on REGISTER 1.
;      |                               |
; 12   |  Monitor octal comp 2 in R2   |  Performs octal display of updated data
;      |                               |  every 1/2 second on REGISTER 1.
;      |                               |
; 13   |  Monitor octal comp 3 in R3   |  Performs octal display of updated data
;      |                               |  every 1/2 second on REGISTER 1.
;      |                               |
; 14   |  Monitor octal comp 1,2       |  Performs octal display of updated data
;      |  in R1,R2                     |  every 1/2 second on REGISTER 1 and
;      |                               |  REGISTER 2.
;      |                               |
; 15   |  Monitor octal comp 1,2,3     |  Performs octal display of updated data
;      |  in R1,R2,R3                  |  every 1/2 second on REGISTER 1,
;      |                               |  REGISTER 2, and REGISTER 3.
;      |                               |
; 16   |  Monitor decimal in R1 or     |  Performs decimal display of updated
;      |  R1,R2, or R1,R2,R3           |  data every 1/2 second on appropriate
;      |                               |  registers.
;      |                               |
; 17   |  Monitor DP decimal in R1,R2  |  Performs double precision display of
;      |                               |  decimal data on REGISTER 1 and
;      |                               |  REGISTER 2.  No scale factoring is
;      |                               |  performed.  Provides 10-character,
;      |                               |  fractional decimal conversion of two
;      |                               |  consecutive erasable registers.  The
;      |                               |  sign is placed in the sign-bit
;      |                               |  position of REGISTER 1.  REGISTER 2
;      |                               |  sign bit is blank.
;      |                               |
; 18   |  (Spare)                      |
;      |                               |
; 19   |  (Spare)                      |
;      |                               |
; 20   |  (Spare)                      |
;      |                               |
; 21   |  Load component 1 into R1     |  Performs data loading.  Octal
;      |                               |  quantities are unsigned.  Decimal
;      |                               |  quantities are preceded by + or -
;      |                               |  sign.  Data is displayed on REGISTER
;      |                               |  1.
;      |                               |
; 22   |  Load component 2 into R2     |  Performs data loading.  Octal
;      |                               |  quantities are unsigned.  Decimal
;      |                               |  quantities are preceded by + or -
;      |                               |  sign.  Data is displayed on REGISTER
;      |                               |  2.
;      |                               |
; 23   |  Load component 3 into R3     |  Performs data loading.  Octal
;      |                               |  quantities are unsigned.  Decimal
;      |                               |  quantities are preceded by + or -
;      |                               |  sign.  Data is displayed on REGISTER
;      |                               |  3.
;      |                               |
; 24   |  Load component 1,2 into      |  Performs data loading.  Octal
;      |  R1,R2                        |  quantities are unsigned.  Decimal
;      |                               |  quantities are preceded by + or -
;      |                               |  sign.  Data is displayed on REGISTER
;      |                               |  1 and REGISTER 2.
;      |                               |
; 25   |  Load component 1,2,3 into    |  Performs data loading.  Octal
;      |  R1,R2,R3                     |  quantities are unsigned.  Decimal
;      |                               |  quantities are preceded by + or -
;      |                               |  sign.  Data is displayed on REGISTER
;      |                               |  1, REGISTER 2, and REGISTER 3.
;      |                               |
; 26   |  (Spare)                      |
;      |                               |
; 27   |  Display fixed memory         |  This verb is included to permit
;      |                               |  displaying the contents of fixed
;      |                               |  memory in any bank.  Its intended use
;      |                               |  is for checking program ropes and the
;      |                               |  BANK positions of program ropes.
;      |                               |
; 28   |  (Spare)                      |
;      |                               |
; 29   |  (Spare)                      |
;      |                               |
; 30   |  Request EXECUTIVE            |  Enters request to executive routine
;      |  (Used only during ground     |  for any machine address with priority
;      |  checkout.)                   |  involved.  This verb assumes that the
;      |                               |  desired priority has been loaded into
;      |                               |  bits 10-14 of the prio/delay register
;      |                               |  (noun 26).  This verb is used with the
;      |                               |  noun, "machine address to be
;      |                               |  specified".  The complete address of
;      |                               |  the desired location is then keyed in.
;      |                               |  (Refer to "Machine address to be
;      |                               |  specified" in paragraph on Verb/Noun
;      |                               |  Formats.)
;      |                               |
; 31   |  Request WAITLIST             |  Enters request to "waitlist routine"
;      |  (Used only during ground     |  for any machine address with delay
;      |  checkout.)                   |  involved.  This verb assumes that the
;      |                               |  desired number of 10-millisecond units
;      |                               |  of delay has been loaded into the low
;      |                               |  order bits of the prio/delay register
;      |                               |  (noun 26).  This verb is used with the
;      |                               |  "machine address to be specified" noun.
;      |                               |  The complete address of the desired
;      |                               |  location is then keyed in.  (Refer to
;      |                               |  "Machine address to be specified" in
;      |                               |  paragraph on Verb/Noun Formats.)
;      |                               |
; 32   |  Recycle                      |
;      |                               |
; 33   |  Proceed (without data)       |  Informs routine requesting data that
;      |                               |  the operator chooses not to load
;      |                               |  fresh data, but wishes the routine to
;      |                               |  continue as best it can with old data.
;      |                               |  Final decision for what action should
;      |                               |  be taken is left to the requesting
;      |                               |  routine.
;      |                               |
; 34   |  Terminate                    |  Informs routine requesting data to be
;      |                               |  loaded that the operator chooses not
;      |                               |  to load fresh data and wishes the
;      |                               |  routine to terminate.  Final decision
;      |                               |  for what action should be taken is
;      |                               |  left to the requesting routine.  If
;      |                               |  monitor is on, it is turned off.
;      |                               |
; 35   |  Test lights                  |
;      |                               |
; 36   |  Request fresh start          |  Initializes the program control
;      |                               |  software and the keyboard and display
;      |                               |  system program.
;      |                               |
; 37   |  Change program (major mode)  |  Change to new major mode.  (Refer to
;      |                               |  "Change major mode" in paragraph on
;      |                               |  Verb/Noun Formats.)
;      |                               |
;--------------------------------------------------------------------------



;--------------------------------------------------------------------------
; COLOSSUS EXTENDED VERBS (40-99 decimal)
;
; Not implemented. Use of these verbs triggers the 'check fail' indicator.
;--------------------------------------------------------------------------



;--------------------------------------------------------------------------
; COLOSSUS NORMAL NOUNS (00-39 decimal)
;
; This is adapted from the Apollo 204 accident report posted on multiple
; web sites by Richard F. Drushel. The information has been changed as
; necessary to be consistent with usage in COLOSSUS.
;
;
; Noun |                                               |
; Code |          Description                          |  Scale/Units
;      |                                               |
; 01   |  Specify machine address (frac)               |  .XXXXX FRAC
;      |                                               |  .XXXXX FRAC
;      |                                               |  .XXXXX FRAC
;      |                                               | 
; 02   |  Specify machine address (whole)              |  XXXXX INTEGER
;      |                                               |  XXXXX INTEGER
;      |                                               |  XXXXX INTEGER
;      |                                               | 
; 03   |  Specify machine address (degree)             |  XXX.XX DEG
;      |                                               |  XXX.XX DEG
;      |                                               |  XXX.XX DEG
;      |                                               | 
; 04   |  (Spare)                                      |
;      |                                               |
; 05   |  (Spare)                                      |
;      |                                               |
; 06   |  (Spare)                                      |
;      |                                               |
; 07   |  (Spare)                                      |
;      |                                               |
; 08   |  (Spare)                                      |
;      |                                               |
; 09   |  Alarm codes                                  |  OCT
;      |                                               |  OCT
;      |                                               |  OCT
;      |                                               |
; 10   |  (Spare)                                      |
;      |                                               |
; 11   |  (Spare)                                      |
;      |                                               |
; 12   |  (Spare)                                      |
;      |                                               |
; 13   |  (Spare)                                      |
;      |                                               |
; 14   |  (Spare)                                      |
;      |                                               |
; 15   |  Increment address                            |  OCT
;      |                                               |
;      |                                               |
; 16   |  (Spare)                                      |
;      |                                               |
; 17   |  (Spare)                                      |
;      |                                               |
; 18   |  (Spare)                                      |
;      |                                               |
; 19   |  (Spare)                                      |
;      |                                               |
; 20   |  (Spare)                                      |
;      |                                               |
; 21   |  (Spare)                                      |
;      |                                               |
; 22   |  (Spare)                                      |
;      |                                               |
; 23   |  (Spare)                                      |
;      |                                               |
; 24   |  (Spare)                                      |
;      |                                               |
; 25   |  (Spare)                                      |
;      |                                               |
; 26   |  Prio/delay, address                          |  OCT (prio/delay)
;      |                                               |  OCT (14-bit CADR)
;      |                                               |  (not used)
;      |                                               |
; 27   |  (Spare)                                      |
;      |                                               |
; 28   |  (Spare)                                      |
;      |                                               |
; 29   |  (Spare)                                      |
;      |                                               |
; 30   |  (Spare)                                      |
;      |                                               |
; 31   |  (Spare)                                      |
;      |                                               |
; 32   |  (Spare)                                      |
;      |                                               |
; 33   |  (Spare)                                      |
;      |                                               |
; 34   |  (Spare)                                      |
;      |                                               |
; 35   |  (Spare)                                      |
;      |                                               |
; 36   |  Time of CMC clock:                           |
;      |    REGISTER 1                                 |  00XXX. hours
;      |    REGISTER 2                                 |  000XX. minutes
;      |    REGISTER 3                                 |  0XX.XX seconds
;      |                                               |
; 37   |  (Spare)                                      |
;      |                                               |
; 38   |  (Spare)                                      |
;      |                                               |
; 39   |  (Spare)                                      |
;      |                                               |
;--------------------------------------------------------------------------



;--------------------------------------------------------------------------
; COLOSSUS MIXED NOUNS (40-99 decimal)
;
; Not implemented.
;--------------------------------------------------------------------------



;--------------------------------------------------------------------------
; AGC ADDRESS ASSIGNMENTS
;
; Central Registers
;
;	000000		A		accumulator
;	000001		Q		subroutine return address
;	000002		Z		program counter
;	000003		LP		lower product register
;
; Input Registers
;
;	000004		IN0
;	000005		IN1
;	000006		IN2
;	000007		IN3
;
; Output Registers
;
;	000010		OUT0
;	000011		OUT1
;	000012		OUT2
;	000013		OUT3
;	000014		OUT4
;
; Memory Bank Select
;
;	000015		BANK
;
; Interrupt Control
;
;	000016		RELINT		re-enable interrupts
;	000017		INHINT		inhibit interrupts
;
; Editing Registers
;
;	000020		CYR		cycle right
;	000021		SR		shift rRight
;	000022		CYL		cycle left
;	000023		SL		shift left
;
; Interrupt Storage Area
;
;	000024		ZRUPT		save program counter (Z)
;	000025		BRUPT		save B register
;	000026		ARUPT		save accumulator (A)
;	000027		QRUPT		save Q register
;
;	000030 - 000033	NOT USED
;
; Involuntary Counters
;
;	000034		OVCTR		arithmetic overflow counter
;	000035		TIME2		AGC clock (high)
;	000036		TIME1		AGC clock (low)
;	000037		TIME3		WAITLIST (T3) timer
;	000040		TIME4		DISPLAY (T4) timer
;
; Involuntary Counters -- currently unused
;
;	000041 - 000056	NOT USED
;
; Eraseable Memory
;
;	000057 - 001777
;
; Start of fixed memory
;
;	002000		GOPROG		AGC (re)start vector
;
;	002004		T3RUPT		interrupt vector for TIME3 (T3RUPT)
;	020010		ERRUPT		interrupt vector
;	020014		DSRUPT		interrupt vector for DSRUPT (T4RUPT)
;	020020		KEYRUPT		interrupt vector for keyboard
;	020024		UPRUPT		interrupt vector for uplink
;--------------------------------------------------------------------------



;--------------------------------------------------------------------------
; AGC TABLES (name, file, description)
;
; Keyboard/display
;	CHARIN2		bank40_1.asm	keyboard character table
;	INRELTAB	bank40_1.asm	DSKY register/display table map
;	DSPTAB		dsky_e.asm	display table for DSKY
;
; Verbs:
;	VERBTAB		bank41_1.asm	regular verb routines (00-39)
;
; Nouns:
;	NNADTAB		bank42_3.asm	noun address table (00-99)
;	NNTYPTAB	bank42_3.asm	noun type table (00-99)
;	SFINTAB		bank42_3.asm	noun input scale factor select
;	SFOUTAB		bank42_3.asm	nout output scale factor select
;	IDADDTAB	bank42_3.asm	mixed noun address table (40-99)
;	RUTMXTAB	bank42_3.asm	mixed noun scale factor routine (40-99)
;
; Noun scale factor routines:
;	SFOUTABR	bank41_1.asm	scale factor output routines
;	SFINTABR	bank41_2.asm	scale factor input routines
;
; Major Modes:
;	FCADRMM		bank04_1.asm	entry points for MM jobs
;	EPREMM1		bank04_1,asm	priorities for MM jobs
;--------------------------------------------------------------------------

