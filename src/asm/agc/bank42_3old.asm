;==========================================================================
; PINBALL NOUN TABLES (source code) memory segment (file:bank42_3.asm)
;
; The following routines are for reading the noun tables and the scale
; factor (SF) tables (which are in a separate bank from the rest of
; PINBALL). These reading routines are in the same bank as the tables.
; They are called by DXCH Z (translated to DXCHJUMP for Block I).
;;
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
		00101 = arith DP2, OUT(straight),		IN(SL 7 at end)
;
;	PPPPP (bits 5-1): SF CONSTANT CODE NUMBER (p.263)
;		00000 = whole,	use arith

; Examples:
:	NNTYPTAB = %00000 ; 1 comp, octal only
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
;--------------------------------------------------------------------------

; TEST DATA -- ROUTINE IS STUBBED

NNADTAB		DS	%00042		; CADR
;NNADTAB		DS	%40000		; specify machine address
;NNADTAB		DS	%77777		; augment last address

:NNTYPTAB	DS	%00000		; 1 comp, octal only
;NNTYPTAB	DS	%02000		; 2 comp, octal only
;NNTYPTAB	DS	%04000		; 3 comp, octal only
;NNTYPTAB	DS	%00040		; 1 comp ,straight fractional
NNTYPTAB	DS	%04040		; 3 comp ,straight fractional


LODNNTAB	EQU	*
		TS	IDAD2TEM	; save return CADR

		CAF	NNADTAB
		TS	NNADTEM

		CAF	NNTYPTAB
		TS	NNTYPTEM

		CAF	ONE		; normal
		TS	MIXBR

		CAF	ZERO	
		AD	IDAD2TEM	; load return CADR
		TC	DXCHJUMP	; return


;--------------------------------------------------------------------------
; GTSFOUT
; On entry, SFTEMP1 contains SFCONUM X 2.
; Loads SFTEMP1, SFTEMP2 with the DP SFOUTAB entries

_SET1		DS	%05174		; simulated entry from SFOUTAB
_SET2		DS	%13261

GTSFOUT		EQU	*
		TS	GTSF_RET	; save return CADR

		CAF	_SET1
		TS	SFTEMP1
		CAF	_SET2
		TS	SFTEMP2

		CAF	ZERO	
		AD	GTSF_RET	; load return CADR
		TC	DXCHJUMP	; return

;--------------------------------------------------------------------------
; GTSFIN
; Loads SFTEMP1, SFTEMP2 with the DP SFINTAB entries

GTSFIN		EQU	*
		TS	GTSF_RET	; save return CADR

; *************** SET SOMETHING IN HERE ******************

		CAF	ZERO	
		AD	GTSF_RET	; load return CADR
		TC	DXCHJUMP	; return

