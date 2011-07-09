;==========================================================================
; PINBALL NOUN TABLES (file:bank42_3.asm)
;
; The following routines are for reading the noun tables and the scale
; factor (SF) tables (which are in a separate bank from the rest of
; PINBALL). These reading routines are in the same bank as the tables.
; They are called by DXCH Z (translated to DXCHJUMP for Block I).
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 263-279.
;==========================================================================

;--------------------------------------------------------------------------
; Noun table info from COLOSSUS, p.325
;
; noun code < 40 : normal noun case
; noun code >= 40: mixed noun case

;--------------------------------------------------------------------------
; NNADTAB:
; for normal noun case, NNADTAB contains one CADR for each noun.
;	+entry	= noun CADR
;	+0	= noun not used.
;	-entry	= machine CADR (E or F) to be specified.
;	-1	= channel to be specified (not used for Block I);
;	-0	= augment of last machine CADR supplied.

; for mixed noun case, NNADTAB contains one indirect address (IDADDREL) 
; in low 10 bits, and the component code number in the high 5 bits.

; Examples:
;	NNADTAB	= %00042 ; CADR for octal address 42
;	NNADTAB	= %00000 ; noun not used
;	NNADTAB	= %40000 ; specify machine address
;	NNADTAB	= %77777 ; augment last address

;--------------------------------------------------------------------------
; NNTYPETAB (normal case):
; a packed table of the form: MMMMM NNNNN PPPPP

; for the normal case:
; 	MMMMM (bits 15-11): COMPONENT CODE NUMBER (p.263)
;		00000 = 1 component
;		00001 = 2 component
;		00010 = 3 component
;		X1XXX = bit4=1, decimal only
;		1XXXX = bit5=1, no load
;
;	NNNNN (bits 10-6): SF ROUTINE CODE NUMBER (p.263)
;		00000 = octal only
;		00001 = straight fractional (decimal)
;		00010 = CDU degrees (XXX.XX)
;		00011 = arithmetic SF
;		00100 = arith DP1, OUT(mult by 2EXP14 at end),	IN(straight)
;		00101 = arith DP2, OUT(straight),		IN(SL 7 at end)
;		00110 = Y optics degrees (XX.XXX max at 89.999)
;		00111 = arith DP3, OUT(SL 7 at end)		IN(straight)
;		01000 = whole hours in R1, whole minutes (mod 60) in R2,
;			seconds (mod 60) 0XX.XX in R3   *** alarms if used with octal
;
;	PPPPP (bits 5-1): SF CONSTANT CODE NUMBER (p.263)
;		00000 = whole,	use arith

; Examples:
;	NNTYPTAB = %00000 ; 1 comp, octal only
;	NNTYPTAB = %02000 ; 2 comp, octal only
;	NNTYPTAB = %04000 ; 3 comp, octal only
;	NNTYPTAB = %00040 ; 1 comp ,straight fractional
;	NNTYPTAB = %04040 ; 3 comp ,straight fractional

;--------------------------------------------------------------------------
; NNTYPETAB (mixed case):
; a packed table of the form: MMMMM NNNNN PPPPP

; for the mixed case (3 component):
; 	MMMMM (bits 15-11)	= SF constant3 code number.
;	NNNNN (bits 10-6)	= SF constant2 code number.
;	PPPPP (bits 5-1)	= SF constant1 code number.
	
; for the mixed case (2 component):
;	NNNNN (bits 10-6)	= SF constant2 code number.
;	PPPPP (bits 5-1)	= SF constant1 code number.

; for the mixed case (1 component):
;	PPPPP (bits 5-1)	= SF constant1 code number.

;--------------------------------------------------------------------------
; IDADDTAB (mixed case only):
; there is also an indirect address table for mixed case only.
; Each entry contains one ECADR. IDADDREL is the relative address of
; the first of these entries.

; There is one entry in this table for each component of a mixed noun.
; They are listed in order of ascending K.

;--------------------------------------------------------------------------
; RUTMXTAB (mixed case only):
; there is also a scale factor routine number table for mixed case only.
; There is one entry per mixed noun. The form is: QQQQQ RRRRR SSSSS

; for the 3 component case
; 	QQQQQ (bits 15-11)	= SF routine3 code number.
;	RRRRR (bits 10-6)	= SF routine2 code number.
;	SSSSS (bits 5-1)	= SF routine1 code number.

; for the 2 component case
;	RRRRR (bits 10-6)	= SF routine2 code number.
;	SSSSS (bits 5-1)	= SF routine1 code number.


; In octal display and load (oct or dec) verbs, exclude use of verbs whose
; component number is greater than the number of components in noun.
; (All machine address to be specified nouns are 3 component)
; In multi-component load verbs, no mixing of octal and decimal data
; component words is allowed; alarm if violation.

; In decimal loads of data, 5 numerical chars must be keyed in before
; each enter; if not, alarm.


;--------------------------------------------------------------------------
; LODNNTAB
; loads NNADTEM with the NNADTAB entry, NNTYPTEM with the NNTYPTAB
; entry. If the noun is mixed, IDAD1TEM is loaded with the first IDADTAB
; entry, IDAD2TEM the second IDADTAB entry, IDAD3TEM the third IDADTAB
; entry, RUTMXTEM with the RUTMXTAB entry. MIXBR is set for mixed=2
; or normal=1 noun.
;
; NOTE: in BlockII, NNADTEM = -1 means use an I/O channel instead of a
; memory address (channel specified in NOUNCADR). Block I does not have 
; I/O channels.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.265.
;--------------------------------------------------------------------------

LODNNTAB	EQU	*
		TS	GTSF_RET	; save return CADR

		INDEX	NOUNREG
		CAF	NNADTAB
		TS	NNADTEM

		INDEX	NOUNREG
		CAF	NNTYPTAB
		TS	NNTYPTEM

		CS	NOUNREG
		AD	MIXCON
		CCS	A		; was BZMF LODMIXNN in Block II
		TC	*+4		; >0
		TC	*+2		; +0, noun number G/E first mixed noun
		TC	*+1		; <0, noun number G/E first mixed noun
		TC	LODMIXNN	; -0, noun number G/E first mixed noun


		CAF	ONE		; noun number L/ first mixed noun
		TS	MIXBR		; normal, +1 into MIXBR

		TC	LODNLV

LODMIXNN	EQU	*
		CAF	TWO		; mixed, +2 into MIXBR
		TS	MIXBR

		INDEX	NOUNREG
		CAF	RUTMXTAB-40	; first mixed noun = 40
		TS	RUTMXTEM

		CAF	LOW10
		MASK	NNADTEM
		TS	Q		; temp

		INDEX	A
		CAF	IDADDTAB
		TS	IDAD1TEM	; load IDAD1TEM with first IDADDTAB entry

		INDEX	Q
		CAF	IDADDTAB+1
		TS	IDAD2TEM	; load IDAD2TEM with 2nd IDADDTAB entry

		INDEX	Q
		CAF	IDADDTAB+2
		TS	IDAD3TEM	; load IDAD3TEM with 3rd IDADDTAB entry

LODNLV		EQU	*
		CAF	ZERO	
		AD	GTSF_RET	; load return CADR
		TC	DXCHJUMP	; return

MIXCON		DS	%50		; 1st mixed noun = 40 (DEC 40)

;--------------------------------------------------------------------------
; GTSFOUT
; On entry, SFTEMP1 contains SFCONUM X 2.
; Loads SFTEMP1, SFTEMP2 with the DP SFOUTAB entries
;
; GTSFIN
; On entry, SFTEMP1 contains SFCONUM X 2.
; Loads SFTEMP1, SFTEMP2 with the DP SFINTAB entries
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.266.
;--------------------------------------------------------------------------

GTSFOUT		EQU	*
		TS	GTSF_RET	; save return CADR

		XCH	SFTEMP1
		TS	Q		; temp

		INDEX	Q
		CAF	SFOUTAB
		TS	SFTEMP1

		INDEX	Q
		CAF	SFOUTAB+1
		TS	SFTEMP2

SFCOM		EQU	*
		CAF	ZERO	
		AD	GTSF_RET	; load return CADR
		TC	DXCHJUMP	; return

GTSFIN		EQU	*
		TS	GTSF_RET	; save return CADR

		XCH	SFTEMP1
		TS	Q		; temp

		INDEX	Q
		CAF	SFINTAB
		TS	SFTEMP1

		INDEX	Q
		CAF	SFINTAB+1
		TS	SFTEMP2

		TC	SFCOM

;--------------------------------------------------------------------------
; NOUN ADDRESS TABLE (NNADTAB)
; Indexed by noun number (0-39 decimal for normal nouns).
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.266.
;--------------------------------------------------------------------------

NNADTAB		EQU	*		; NN - NORMAL NOUNS
		DS	%0		; 00 - not in use
		DS	%40000		; 01 - specify machine address (fractional)
		DS	%40000		; 02 - specify machine address (whole)
		DS	%40000		; 03 - specify machine address (degrees)
		DS	%00036		; 04 - spare *********** TEST, CHANGE TO ZERO
		DS	%0		; 05 - spare
		DS	%0		; 06 - spare
		DS	%0		; 07 - spare
		DS	%0		; 08 - spare
		ECADR	FAILREG		; 09 - alarm codes
		DS	%0		; 10 - spare
		DS	%0		; 11 - spare
		DS	%0		; 12 - spare
		DS	%0		; 13 - spare
		DS	%0		; 14 - spare
		DS	%77777		; 15 - increment machine address
		DS	%0		; 16 - spare
		DS	%0		; 17 - spare
		DS	%0		; 18 - spare
		DS	%0		; 19 - spare
		DS	%0		; 20 - spare
		DS	%0		; 21 - spare
		DS	%0		; 22 - spare
		DS	%0		; 23 - spare
		DS	%0		; 24 - spare
		DS	%0		; 25 - spare
		ECADR	DSPTEM1		; 26 - prio/delay, adres, BBCON
		DS	%0		; 27 - spare
		DS	%0		; 28 - spare
		DS	%0		; 29 - spare
		DS	%0		; 30 - spare
		DS	%0		; 31 - spare
		DS	%0		; 32 - spare
		DS	%0		; 33 - spare
		DS	%0		; 34 - spare
		DS	%0		; 35 - spare
		ECADR	TIME2		; 36 - time of AGC clock (hrs, min, sec)
		DS	%0		; 37 - spare
		DS	%0		; 38 - spare
		DS	%0		; 39 - spare
	; end of normal nouns

	; start of mixed nouns

		DS	%0		; 40 - spare
		DS	%0		; 41 - spare
		DS	%0		; 42 - spare
		DS	%0		; 43 - spare
		DS	%0		; 44 - spare
		DS	%0		; 45 - spare
		DS	%0		; 46 - spare
		DS	%0		; 47 - spare
		DS	%0		; 48 - spare
		DS	%0		; 49 - spare
		DS	%0		; 50 - spare
		DS	%0		; 51 - spare
		DS	%0		; 52 - spare
		DS	%0		; 53 - spare
		DS	%0		; 54 - spare
		DS	%0		; 55 - spare
		DS	%0		; 56 - spare
		DS	%0		; 57 - spare
		DS	%0		; 58 - spare
		DS	%0		; 59 - spare
		DS	%0		; 60 - spare
		DS	%0		; 61 - spare
		DS	%0		; 62 - spare
		DS	%0		; 63 - spare
		DS	%0		; 64 - spare
		DS	%0		; 65 - spare
		DS	%0		; 66 - spare
		DS	%0		; 67 - spare
		DS	%0		; 68 - spare
		DS	%0		; 69 - spare
		DS	%0		; 70 - spare
		DS	%0		; 71 - spare
		DS	%0		; 72 - spare
		DS	%0		; 73 - spare
		DS	%0		; 74 - spare
		DS	%0		; 75 - spare
		DS	%0		; 76 - spare
		DS	%0		; 77 - spare
		DS	%0		; 78 - spare
		DS	%0		; 79 - spare
		DS	%0		; 80 - spare
		DS	%0		; 81 - spare
		DS	%0		; 82 - spare
		DS	%0		; 83 - spare
		DS	%0		; 84 - spare
		DS	%0		; 85 - spare
		DS	%0		; 86 - spare
		DS	%0		; 87 - spare
		DS	%0		; 88 - spare
		DS	%0		; 89 - spare
		DS	%0		; 90 - spare
		DS	%0		; 91 - spare
		DS	%0		; 92 - spare
		DS	%0		; 93 - spare
		DS	%0		; 94 - spare
		DS	%0		; 95 - spare
		DS	%0		; 96 - spare
		DS	%0		; 97 - spare
		DS	%0		; 98 - spare
		DS	%0		; 99 - spare
	; end of mixed nouns

;--------------------------------------------------------------------------
; NOUN TYPE TABLE (NNTYPTAB)
; Indexed by noun number (0-39 decimal for normal nouns).
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.269.
;--------------------------------------------------------------------------

NNTYPTAB	EQU	*		; NN - NORMAL NOUNS
		DS	%0		; 00 - not in use
		DS	%04040		; 01 - 3 component (fractional)
		DS	%04140		; 02 - 3 component (whole)
		DS	%04102		; 03 - 3 component (CDU degrees)
		DS	%0		; 04 - spare
		DS	%0		; 05 - spare
		DS	%0		; 06 - spare
		DS	%0		; 07 - spare
		DS	%0		; 08 - spare
		DS	%04000		; 09 - 3 component, octal only
		DS	%0		; 10 - spare
		DS	%0		; 11 - spare
		DS	%0		; 12 - spare
		DS	%0		; 13 - spare
		DS	%0		; 14 - spare
		DS	%0		; 15 - 1 component, octal only
		DS	%0		; 16 - spare
		DS	%0		; 17 - spare
		DS	%0		; 18 - spare
		DS	%0		; 19 - spare
		DS	%0		; 20 - spare
		DS	%0		; 21 - spare
		DS	%0		; 22 - spare
		DS	%0		; 23 - spare
		DS	%0		; 24 - spare
		DS	%0		; 25 - spare
		DS	%04000		; 26 - 3 component, octal only
		DS	%0		; 27 - spare
		DS	%0		; 28 - spare
		DS	%0		; 29 - spare
		DS	%0		; 30 - spare
		DS	%0		; 31 - spare
		DS	%0		; 32 - spare
		DS	%0		; 33 - spare
		DS	%0		; 34 - spare
		DS	%0		; 35 - spare
		DS	%24400		; 36 - 3 component, HMS, (dec only)
		DS	%0		; 37 - spare
		DS	%0		; 38 - spare
		DS	%0		; 39 - spare
	; end of normal nouns

	; start of mixed nouns

		DS	%0		; 40 - spare
		DS	%0		; 41 - spare
		DS	%0		; 42 - spare
		DS	%0		; 43 - spare
		DS	%0		; 44 - spare
		DS	%0		; 45 - spare
		DS	%0		; 46 - spare
		DS	%0		; 47 - spare
		DS	%0		; 48 - spare
		DS	%0		; 49 - spare
		DS	%0		; 50 - spare
		DS	%0		; 51 - spare
		DS	%0		; 52 - spare
		DS	%0		; 53 - spare
		DS	%0		; 54 - spare
		DS	%0		; 55 - spare
		DS	%0		; 56 - spare
		DS	%0		; 57 - spare
		DS	%0		; 58 - spare
		DS	%0		; 59 - spare
		DS	%0		; 60 - spare
		DS	%0		; 61 - spare
		DS	%0		; 62 - spare
		DS	%0		; 63 - spare
		DS	%0		; 64 - spare
		DS	%0		; 65 - spare
		DS	%0		; 66 - spare
		DS	%0		; 67 - spare
		DS	%0		; 68 - spare
		DS	%0		; 69 - spare
		DS	%0		; 70 - spare
		DS	%0		; 71 - spare
		DS	%0		; 72 - spare
		DS	%0		; 73 - spare
		DS	%0		; 74 - spare
		DS	%0		; 75 - spare
		DS	%0		; 76 - spare
		DS	%0		; 77 - spare
		DS	%0		; 78 - spare
		DS	%0		; 79 - spare
		DS	%0		; 80 - spare
		DS	%0		; 81 - spare
		DS	%0		; 82 - spare
		DS	%0		; 83 - spare
		DS	%0		; 84 - spare
		DS	%0		; 85 - spare
		DS	%0		; 86 - spare
		DS	%0		; 87 - spare
		DS	%0		; 88 - spare
		DS	%0		; 89 - spare
		DS	%0		; 90 - spare
		DS	%0		; 91 - spare
		DS	%0		; 92 - spare
		DS	%0		; 93 - spare
		DS	%0		; 94 - spare
		DS	%0		; 95 - spare
		DS	%0		; 96 - spare
		DS	%0		; 97 - spare
		DS	%0		; 98 - spare
		DS	%0		; 99 - spare
	; end of mixed nouns

;--------------------------------------------------------------------------
; SCALE FACTOR INPUT TABLE (SFINTAB)
; Indexed by SF constant code number x 2 PPPPP (0-19 decimal; 0-23 octal)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.272.
;--------------------------------------------------------------------------

SFINTAB		EQU	*
		DS	%00006		; 00 - whole, DP time (sec)
		DS	%03240		; 00

		DS	%00000		; 01 - spare
		DS	%00000		; 01

		DS	%00000		; 02 - CDU degrees, Y optics degrees
		DS	%00000		; 02   (SFCONs in DEGINSF, OPTDEGIN

		DS	%00000		; 03
		DS	%00000		; 03

		DS	%00000		; 04
		DS	%00000		; 04

		DS	%00000		; 05
		DS	%00000		; 05

		DS	%00000		; 06
		DS	%00000		; 06

		DS	%00000		; 07
		DS	%00000		; 07

		DS	%00000		; 10
		DS	%00000		; 10

		DS	%00000		; 11
		DS	%00000		; 11

		DS	%00000		; 12
		DS	%00000		; 12

		DS	%00000		; 13
		DS	%00000		; 13

		DS	%00000		; 14
		DS	%00000		; 14

		DS	%00000		; 15
		DS	%00000		; 15

		DS	%00000		; 16
		DS	%00000		; 16

		DS	%00000		; 17
		DS	%00000		; 17

		DS	%00000		; 20
		DS	%00000		; 20

		DS	%00000		; 21
		DS	%00000		; 21

		DS	%00000		; 22
		DS	%00000		; 22

		DS	%00000		; 23
		DS	%00000		; 23

;--------------------------------------------------------------------------
; SCALE FACTOR OUTPUT TABLE (SFOUTAB)
; Indexed by SF constant code number x 2 PPPPP (0-19 decimal; 0-23 octal)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.273.
;--------------------------------------------------------------------------

SFOUTAB		EQU	*
		DS	%05174		; 00 - whole, DP time (sec)
		DS	%13261		; 00

		DS	%00000		; 01 - spare
		DS	%00000		; 01

		DS	%00000		; 02 - CDU degrees, Y optics degrees
		DS	%00000		; 02   (SFCONs in DEGOURSF, OPTDEGOUT

		DS	%00000		; 03
		DS	%00000		; 03

		DS	%00000		; 04
		DS	%00000		; 04

		DS	%00000		; 05
		DS	%00000		; 05

		DS	%00000		; 06
		DS	%00000		; 06

		DS	%00000		; 07
		DS	%00000		; 07

		DS	%00000		; 10
		DS	%00000		; 10

		DS	%00000		; 11
		DS	%00000		; 11

		DS	%00000		; 12
		DS	%00000		; 12

		DS	%00000		; 13
		DS	%00000		; 13

		DS	%00000		; 14
		DS	%00000		; 14

		DS	%00000		; 15
		DS	%00000		; 15

		DS	%00000		; 16
		DS	%00000		; 16

		DS	%00000		; 17
		DS	%00000		; 17

		DS	%00000		; 20
		DS	%00000		; 20

		DS	%00000		; 21
		DS	%00000		; 21

		DS	%00000		; 22
		DS	%00000		; 22

		DS	%00000		; 23
		DS	%00000		; 23


	; SCALE FACTOR INPUT ROUTINE TABLE is on pp. 342, 343 of COLOSSUS
	; SCALE FACTOR OUTPUT ROUTINE TABLE is on p. 329 of COLOSSUS

;--------------------------------------------------------------------------
; MIXED NOUN ADDRESS TABLE (IDADDTAB)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.274.
;--------------------------------------------------------------------------

	; ** currently, the table is not populated **

IDADDTAB	EQU	*
		DS	%0		; 40 - spare component
		DS	%0		; 40 - spare component
		DS	%0		; 40 - spare component

		DS	%0		; 41 - spare component
		DS	%0		; 41 - spare component
		DS	%0		; 41 - spare component

		DS	%0		; 42 - spare component
		DS	%0		; 42 - spare component
		DS	%0		; 42 - spare component

		DS	%0		; 43 - spare component
		DS	%0		; 43 - spare component
		DS	%0		; 43 - spare component

		DS	%0		; 44 - spare component
		DS	%0		; 44 - spare component
		DS	%0		; 44 - spare component

		DS	%0		; 45 - spare component
		DS	%0		; 45 - spare component
		DS	%0		; 45 - spare component

		DS	%0		; 46 - spare component
		DS	%0		; 46 - spare component
		DS	%0		; 46 - spare component

		DS	%0		; 47 - spare component
		DS	%0		; 47 - spare component
		DS	%0		; 47 - spare component

		DS	%0		; 48 - spare component
		DS	%0		; 48 - spare component
		DS	%0		; 48 - spare component

		DS	%0		; 49 - spare component
		DS	%0		; 49 - spare component
		DS	%0		; 49 - spare component

		DS	%0		; 50 - spare component
		DS	%0		; 50 - spare component
		DS	%0		; 50 - spare component

		DS	%0		; 51 - spare component
		DS	%0		; 51 - spare component
		DS	%0		; 51 - spare component

		DS	%0		; 52 - spare component
		DS	%0		; 52 - spare component
		DS	%0		; 52 - spare component

		DS	%0		; 53 - spare component
		DS	%0		; 53 - spare component
		DS	%0		; 53 - spare component

		DS	%0		; 54 - spare component
		DS	%0		; 54 - spare component
		DS	%0		; 54 - spare component

		DS	%0		; 55 - spare component
		DS	%0		; 55 - spare component
		DS	%0		; 55 - spare component

		DS	%0		; 56 - spare component
		DS	%0		; 56 - spare component
		DS	%0		; 56 - spare component

		DS	%0		; 57 - spare component
		DS	%0		; 57 - spare component
		DS	%0		; 57 - spare component

		DS	%0		; 58 - spare component
		DS	%0		; 58 - spare component
		DS	%0		; 58 - spare component

		DS	%0		; 59 - spare component
		DS	%0		; 59 - spare component
		DS	%0		; 59 - spare component

		DS	%0		; 60 - spare component
		DS	%0		; 60 - spare component
		DS	%0		; 60 - spare component

		DS	%0		; 61 - spare component
		DS	%0		; 61 - spare component
		DS	%0		; 61 - spare component

		DS	%0		; 62 - spare component
		DS	%0		; 62 - spare component
		DS	%0		; 62 - spare component

		DS	%0		; 63 - spare component
		DS	%0		; 63 - spare component
		DS	%0		; 63 - spare component

		DS	%0		; 64 - spare component
		DS	%0		; 64 - spare component
		DS	%0		; 64 - spare component

		DS	%0		; 65 - spare component
		DS	%0		; 65 - spare component
		DS	%0		; 65 - spare component

		DS	%0		; 66 - spare component
		DS	%0		; 66 - spare component
		DS	%0		; 66 - spare component

		DS	%0		; 67 - spare component
		DS	%0		; 67 - spare component
		DS	%0		; 67 - spare component

		DS	%0		; 68 - spare component
		DS	%0		; 68 - spare component
		DS	%0		; 68 - spare component

		DS	%0		; 69 - spare component
		DS	%0		; 69 - spare component
		DS	%0		; 69 - spare component

		DS	%0		; 70 - spare component
		DS	%0		; 70 - spare component
		DS	%0		; 70 - spare component

		DS	%0		; 71 - spare component
		DS	%0		; 71 - spare component
		DS	%0		; 71 - spare component

		DS	%0		; 72 - spare component
		DS	%0		; 72 - spare component
		DS	%0		; 72 - spare component

		DS	%0		; 73 - spare component
		DS	%0		; 73 - spare component
		DS	%0		; 73 - spare component

		DS	%0		; 74 - spare component
		DS	%0		; 74 - spare component
		DS	%0		; 74 - spare component

		DS	%0		; 75 - spare component
		DS	%0		; 75 - spare component
		DS	%0		; 75 - spare component

		DS	%0		; 76 - spare component
		DS	%0		; 76 - spare component
		DS	%0		; 76 - spare component

		DS	%0		; 77 - spare component
		DS	%0		; 77 - spare component
		DS	%0		; 77 - spare component

		DS	%0		; 78 - spare component
		DS	%0		; 78 - spare component
		DS	%0		; 78 - spare component

		DS	%0		; 79 - spare component
		DS	%0		; 79 - spare component
		DS	%0		; 79 - spare component

		DS	%0		; 80 - spare component
		DS	%0		; 80 - spare component
		DS	%0		; 80 - spare component

		DS	%0		; 81 - spare component
		DS	%0		; 81 - spare component
		DS	%0		; 81 - spare component

		DS	%0		; 82 - spare component
		DS	%0		; 82 - spare component
		DS	%0		; 82 - spare component

		DS	%0		; 83 - spare component
		DS	%0		; 83 - spare component
		DS	%0		; 83 - spare component

		DS	%0		; 84 - spare component
		DS	%0		; 84 - spare component
		DS	%0		; 84 - spare component

		DS	%0		; 85 - spare component
		DS	%0		; 85 - spare component
		DS	%0		; 85 - spare component

		DS	%0		; 86 - spare component
		DS	%0		; 86 - spare component
		DS	%0		; 86 - spare component

		DS	%0		; 87 - spare component
		DS	%0		; 87 - spare component
		DS	%0		; 87 - spare component

		DS	%0		; 88 - spare component
		DS	%0		; 88 - spare component
		DS	%0		; 88 - spare component

		DS	%0		; 89 - spare component
		DS	%0		; 89 - spare component
		DS	%0		; 89 - spare component

		DS	%0		; 90 - spare component
		DS	%0		; 90 - spare component
		DS	%0		; 90 - spare component

		DS	%0		; 91 - spare component
		DS	%0		; 91 - spare component
		DS	%0		; 91 - spare component

		DS	%0		; 92 - spare component
		DS	%0		; 92 - spare component
		DS	%0		; 92 - spare component

		DS	%0		; 93 - spare component
		DS	%0		; 93 - spare component
		DS	%0		; 93 - spare component

		DS	%0		; 94 - spare component
		DS	%0		; 94 - spare component
		DS	%0		; 94 - spare component

		DS	%0		; 95 - spare component
		DS	%0		; 95 - spare component
		DS	%0		; 95 - spare component

		DS	%0		; 96 - spare component
		DS	%0		; 96 - spare component
		DS	%0		; 96 - spare component

		DS	%0		; 97 - spare component
		DS	%0		; 97 - spare component
		DS	%0		; 97 - spare component

		DS	%0		; 98 - spare component
		DS	%0		; 98 - spare component
		DS	%0		; 98 - spare component

		DS	%0		; 99 - spare component
		DS	%0		; 99 - spare component
		DS	%0		; 99 - spare component
	; end of mixed noun address table

;--------------------------------------------------------------------------
; MIXED NOUN SCALE FACTOR ROUTINE TABLE (RUTMXTAB)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.278.
;--------------------------------------------------------------------------

	; ** currently, the table is not populated **

RUTMXTAB	EQU	*
		DS	%0		; 40 - spare
		DS	%0		; 41 - spare
		DS	%0		; 42 - spare
		DS	%0		; 43 - spare
		DS	%0		; 44 - spare
		DS	%0		; 45 - spare
		DS	%0		; 46 - spare
		DS	%0		; 47 - spare
		DS	%0		; 48 - spare
		DS	%0		; 49 - spare
		DS	%0		; 50 - spare
		DS	%0		; 51 - spare
		DS	%0		; 52 - spare
		DS	%0		; 53 - spare
		DS	%0		; 54 - spare
		DS	%0		; 55 - spare
		DS	%0		; 56 - spare
		DS	%0		; 57 - spare
		DS	%0		; 58 - spare
		DS	%0		; 59 - spare
		DS	%0		; 60 - spare
		DS	%0		; 61 - spare
		DS	%0		; 62 - spare
		DS	%0		; 63 - spare
		DS	%0		; 64 - spare
		DS	%0		; 65 - spare
		DS	%0		; 66 - spare
		DS	%0		; 67 - spare
		DS	%0		; 68 - spare
		DS	%0		; 69 - spare
		DS	%0		; 70 - spare
		DS	%0		; 71 - spare
		DS	%0		; 72 - spare
		DS	%0		; 73 - spare
		DS	%0		; 74 - spare
		DS	%0		; 75 - spare
		DS	%0		; 76 - spare
		DS	%0		; 77 - spare
		DS	%0		; 78 - spare
		DS	%0		; 79 - spare
		DS	%0		; 80 - spare
		DS	%0		; 81 - spare
		DS	%0		; 82 - spare
		DS	%0		; 83 - spare
		DS	%0		; 84 - spare
		DS	%0		; 85 - spare
		DS	%0		; 86 - spare
		DS	%0		; 87 - spare
		DS	%0		; 88 - spare
		DS	%0		; 89 - spare
		DS	%0		; 90 - spare
		DS	%0		; 91 - spare
		DS	%0		; 92 - spare
		DS	%0		; 93 - spare
		DS	%0		; 94 - spare
		DS	%0		; 95 - spare
		DS	%0		; 96 - spare
		DS	%0		; 97 - spare
		DS	%0		; 98 - spare
		DS	%0		; 99 - spare
	; end of mixed noun scale factor routine table

