;==========================================================================
; DSKY erasable memory segment (file:dsky_e.asm)
;
; Version:	1.0
; Author:	John Pultorak
; Date:		12/14/2001
;
; PURPOSE:
; Eraseable memory variables and structures for the DSKY. See the EXEC
; source code file for more information.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968.
;==========================================================================

FLAGWRD5	DS	0


; GENERAL ERASABLE ASSIGNMENTS
; (COLOSSUS, p. 66)


; interrupt temporary storage pool
; (ITEMP1 through RUPTREG4)

ITEMP1		DS	0
WAITEXIT	EQU	ITEMP1
EXECTEM1	EQU	ITEMP1

ITEMP2		DS	0
WAITBANK	EQU	ITEMP2
EXECTEM2	EQU	ITEMP2

ITEMP3		DS	0
RUPTSTOR	EQU	ITEMP3
WAITADR		EQU	ITEMP3
NEWPRIO		EQU	ITEMP3

ITEMP4		DS	0
LOCCTR		EQU	ITEMP4
WAITTEMP	EQU	ITEMP4

ITEMP5		DS	0
NEWLOC		EQU	ITEMP5

ITEMP6		DS	0
NEWLOCP1	EQU	ITEMP6		; DP address

NEWJOB		DS	0		; COLOSSUS: must be at loc 68 due to wiring
RUPTREG1	DS	0
RUPTREG2	DS	0
RUPTREG3	DS	0
RUPTREG4	DS	0
KEYTEMP1	EQU	RUPTREG4
DSRUPTEM	EQU	RUPTREG4


; FLAGWORD reservations

STATE		EQU	*		; 12 words
		DS	0
		DS	0
		DS	0
		DS	0
		DS	0
		DS	0
		DS	0
		DS	0
		DS	0
		DS	0
		DS	0
		DS	0

FLAGFILL	EQU	*		; space for future flags
		DS	0
		DS	0
		DS	0
		DS	0

; pad load for DAPs
; (COLOSSUS, p. 67)

EMDOT		EQU	FLAGFILL

; exit for VB3

STATEXIT	EQU	FLAGFILL+2

; EXEC temporaries which may be used between CCS NEWJOBS.
; (INTB15P through RUPTMXM)

INTB15P		DS	0		; reflects 15th bit of indexable addresses
DSEXIT		EQU	INTB15P		; return for DSPIN
EXITEM		EQU	INTB15P		; return for scale factor routine select
BLANKRET	EQU	INTB15P		; return for 2BLANK

INTBIT15	DS	0		; similar to above
WRDRET		EQU	INTBIT15	; return for 5BLANK
WDRET		EQU	INTBIT15	; return for DSPWD
DECRET		EQU	INTBIT15	; return for PUTCOM (dec load)
_2122REG	EQU	INTBIT15	; temp for CHARIN

; The registers between ADDRWD and PRIORITY must stay in the following order
; for interpretive trace.

ADDRWD		DS	0		; 12 bit interpretive operand subaddress
POLISH		DS	0		; holds CADR made from POLISH address
UPDATRET	EQU	POLISH		; return for UPDATNN, UPDATVB
CHAR		EQU	POLISH		; temp for CHARIN
ERCNT		EQU	POLISH		; counter for error light reset
DECOUNT		EQU	POLISH		; counter for scaling and display (dec)

FIXLOC		DS	0		; work area address
OVFIND		DS	0		; set non-zero on overflow

VBUF		EQU	*		; temporary storage used for vectors
		DS	0
		DS	0
		DS	0
		DS	0
		DS	0
		DS	0
SGNON		EQU	VBUF		; temp for +,- on
NOUNTEM		EQU	VBUF		; counter for MIXNOUN fetch
DISTEM		EQU	VBUF		; counter for octal display verbs
DECTEM		EQU	VBUF		; counter for fetch (dec display verbs)

SGNOFF		EQU	VBUF+1		; temp for +,- off
NVTEMP		EQU	VBUF+1		; temp for NVSUB
SFTEMP1		EQU	VBUF+1		; storage for SF const hi part(=SFTEMP2-1)
HITEMIN		EQU	VBUF+1		; temp for load of hrs, min, sec
					; must = LOWTEMIN-1

CODE		EQU	VBUF+2		; for DSPIN
SFTEMP2		EQU	VBUF+2		; storage for SF const low part(=SFTEMP1+1)
LOWTEMIN	EQU	VBUF+2		; temp for load of hrs, min, sec
					; must = HITEMIN+1 

; (COLOSSUS, p. 68)

MIXTEMP		EQU	VBUF+3		; for MIXNOUN data
SIGNRET		EQU	VBUF+3		; return for +,- on

; Also, MIXTEMP+1 = VBUF+4, MIXTEMP+2 = VBUF+5

BUF		EQU	*		; temporary scalar storage
		DS	0
		DS	0
		DS	0

BUF2		DS	0
		DS	0

INDEXLOC	EQU	BUF		; contains address of specified index
SWWORD		EQU	BUF		; address of switch word
SWBIT		EQU	BUF+1		; switch bit within switch word
MPTEMP		DS	0		; temporary used in multiply and shift
DMPNTEMP	EQU	MPTEMP		; DMPSUB temporary
DOTINC		DS	0		; component increment for DOT subroutine
DVSIGN		EQU	DOTINC		; determines sign of DDV result
ESCAPE		EQU	DOTINC		; used in arcsin/arccos
ENTRET		EQU	DOTINC		; exit from enter

DOTRET		DS	0		; return from DOT subroutine
DVNORMCT	EQU	DOTRET		; dividend normalization count in DDV
ESCAPE2		EQU	DOTRET		; alternate arcsin/arccos switch
WDCNT		EQU	DOTRET		; char counter for DSPWD
INREL		EQU	DOTRET		; input buffer selector (X,Y,Z REG)

MATINC		DS	0		; vector increment in MXV and VXM
MAXDVSW		EQU	MATINC		; +0 if DP quotient is near one - else -1
POLYCNT		EQU	MATINC		; polynomial loop counter
DSPMMTEM	EQU	MATINC		; DSPCOUNT save for DSPMM
MIXBR		EQU	MATINC		; indicator for mixed or normal noun

TEM1		DS	0		; EXEC temp
POLYRET		EQU	TEM1
DSREL		EQU	TEM1		; rel address for DSPIN

TEM2		DS	0		; EXEC temp
DSMAG		EQU	TEM2		; magnitude store for DSPIN
IDADDTEM	EQU	TEM2		; mixnoun indirect address store

TEM3		DS	0		; EXEC temp
COUNT		EQU	TEM3		; for DSPIN

TEM4		DS	0		; EXEC temp
LSTPTR		EQU	TEM4		; list pointer for GRABUSY
RELRET		EQU	TEM4		; return for RELDSP
FREERET		EQU	TEM4		; return for FREEDSP
DSPWDRET	EQU	TEM4		; return for DSPSIGN
SEPSCRET	EQU	TEM4		; return for SEPSEC
SEPMNRET	EQU	TEM4		; return for SEPMIN

TEM5		DS	0		; EXEC temp
NOUNADD		EQU	TEM5		; temp storage for noun address

; (COLOSSUS, p. 69)

NNADTEM		DS	0		; temp for noun address table entry
NNTYPTEM	DS	0		; temp for noun type table entry
IDAD1TEM	DS	0		; temp for indir address table entry (MIXNN)
					; must - IDAD2TEM-1, = IDAD3TEM-2
IDAD2TEM	DS	0		; temp for indir address table entry (MIXNN)
					; must - IDAD2TEM+1, = IDAD3TEM-1
IDAD3TEM	DS	0		; temp for indir address table entry (MIXNN)
					; must - IDAD1TEM+2, = IDAD2TEM+1
RUTMXTEM	DS	0		; temp for SF rout table entry (MIXNN only)

; AX*SR*T storage

DEXDEX		EQU	TEM2		; B(1) tmp
DEX1		EQU	TEM3		; B(1) tmp
DEX2		EQU	TEM4		; B(1) tmp
RTNSAVER	EQU	TEM5		; B(1) tmp
TERM1TMP	EQU	BUF2		; B(2) tmp



; (COLOSSUS, p. 70) Note: the eraseable memory for the EXEC.
; Moved to the EXEC area


; (COLOSSUS, p. 72)
; unswitched for display interface routines

RESTREG		DS	0		; B(1) prm for display starts
NVWORD		DS	0
MARXNV		DS	0
NVSAVE		DS	0
; (retain the order of CADRFLSH to FAILREG+2 for downlink purposes)
CADRFLSH	DS	0		; B(1) tmp
CADRMARK	DS	0		; B(1) tmp
TEMPFLSH	DS	0		; B(1) tmp
FAILREG		DS	0		; B(3) prm  3 alarm-abort user=S 2CADR
		DS	0
		DS	0


; (COLOSSUS, p. 73)
; verb 37 storage

MINDEX		DS	0		; B(1) tmp index for major mode
MMNUMBER	DS	0		; B(1) tmp major mode requested via V37

; pinball interrupt storage

DSPCNT		DS	0		; B(1) prm DSPOUT counter

; pinball executive action

DSPCOUNT	DS	0		; display position indicator
DECBRNCH	DS	0		; octal=0, +dec=1, -dec=2
VERBREG		DS	0		; verb code
NOUNREG		DS	0		; noun code
XREG		DS	0		; R1 input buffer
YREG		DS	0		; R2 input buffer
ZREG		DS	0		; R3 input buffer
XREGLP		DS	0		; low part of XREG (for ded conv only)
YREGLP		DS	0		; low part of YREG (for ded conv only)
HITEMOUT	EQU	YREGLP		; temp for display of HRS, MIN, SEC
					;   must equal LOTEMOUT-1
ZREGLP		DS	0		; low part of ZREG (for ded conv only)
LOTEMOUT	EQU	ZREGLP		; temp for display of HRS, MIN, SEC
					;   must equal HITEMOUT+1
; (COLOSSUS, p. 74)

MODREG		DS	0		; mode code
DSPLOCK		DS	0		; keyboard/subroutine call interlock
REQRET		DS	0		; return register for load
LOADSTAT	DS	0		; status indicator for LOADTST
CLPASS		DS	0		; pass indicator clear
NOUT		DS	0		; activity counter for DSPTAB
NOUNCADR	DS	0		; machine CADR for noun
MONSAVE		DS	0		; N/V code for monitor (= MONSAVE1 - 1)
MONSAVE1	DS	0		; NOUNCADR for monitor (MATBS) = MONSAVE + 1
MONSAVE2	DS	0		; NVMONOPT options

; The 11 register table for the display panel (COLOSSUS, p.74, p.306)
; comment key =   RELADD: RELAYWD  BIT11  BITS10-6  BITS5-1

DSPTAB		EQU	*
		DS	0		; 0: 0001  -R3  R3D4( 1)  R3D5( 0)
		DS	0		; 1: 0010  +R3  R3D2( 3)  R3D3( 2)
		DS	0		; 2: 0011  ---  R2D5( 5)  R3D1( 4)	
		DS	0		; 3: 0100  -R2  R2D3( 7)  R2D4( 6)
		DS	0		; 4: 0101  +R2  R2D1(11)  R2D2(10)
		DS	0		; 5: 0110  -R1  R1D4(13)  R1D5(12)
		DS	0		; 6: 0111  +R1  R1D2(15)  R1D3(14)
		DS	0		; 7: 1000  ---  --------  R1D1(16)
		DS	0		; 8: 1001  ---  ND1 (21)  ND2 (20)
		DS	0		; 9: 1010  ---  VD1 (23)  VD2 (22)
		DS	0		; 10:1011  ---  MD1 (25)  MD1 (24)
		DS	0		; 11: C/S lights

NVQTEM		DS	0		; NVSUB storage for calling address
					; must = NVBNKTEM-1
NVBNKTEM	DS	0		; NVSUB storage for calling bank
					; must = NVQTEM+1
VERBSAVE	DS	0		; needed for recycle
CADRSTOR	DS	0		; ENDIDLE storage
DSPLIST		DS	0		; waiting reg for DSP syst internal use
EXTVRACT	DS	0		; extended verb activity interlock

DSPTEM1		DS	0		; buffer storage area 1 (mostly for time)
		DS	0
		DS	0

DSPTEM2		DS	0		; buffer storage area 2 (mostly for deg)
		DS	0
		DS	0

DSPTEMX		EQU	DSPTEM2		; B(2) S-S display buffer for external verbs
NORMTEM1	EQU	DSPTEM1		; B(3) DSP normal display registers

; display for extended verbs

OPTIONX		EQU	DSPTEMX		; B(2) extended verb option code N12(VB2)


; T4RUPT Erasable

DSRUPTSW	DS	0		; (COLOSSUS, p. 78)
T4RET		DS	0		; added, not part of COLOSSUS
DSPOUTRET	DS	0		; added, not part of COLOSSUS
DK_IN_saveQ	DS	0		; return for T4RUPT init


; Replacement for Block II LXCH instruction (not part of COLOSSUS)

LXCH_LPRET	DS	0		; LP return address
LXCH_A		DS	0		; save A


; Vars for DPTEST (not part of COLOSSUS)

DPTEST_A	DS	0
DPTEST_Q	DS	0


; Vars for REQDATX, REQDATY, REQDATZ (not part of COLOSSUS)

REQ_Q		DS	0


; Vars for SETNCADR (not part of COLOSSUS)

SETNCADR_Q	DS	0


; Vars for ALLDC_OC (not part of COLOSSUS)

ALLDC_OC_Q	DS	0


; Vars for SFRUTMIX (not part of COLOSSUS)

SFRUTMIX_L	DS	0


; Vars for SFCONUM (not part of COLOSSUS)

SFCONUM_L	DS	0


; Vars for GTSFOUT, GTSFIN (not part of COLOSSUS)

GTSF_RET	DS	0

; Vars for FIXRANGE (not part of COLOSSUS)

FR_RETQ		DS	0

; Vars for NVSUB (not part of COLOSSUS)

NVSUB_L		DS	0
NVSUB_A		DS	0

; Vars for ENDIDLE (not part of COLOSSUS)

ENDIDLE_L	DS	0

; Vars for NVSUBUSY (not part of COLOSSUS)

NBSUBSY1_L	DS	0

; Vars for FLASHON/FLASHOFF (not part of COLOSSUS)

FLASHRET	DS	0

; Vars for MATH LIB (not part of COLOSSUS)

SHORTMP_A	DS	0
SHORTMP_OVFL	DS	0
SHORTMP_OVFH	DS	0
ADDRWD1		DS	0
MATH_Q		DS	0
PRSHRTMP_Q	DS	0


; KEYRUPT Eraseable

KEYRET		DS	0		; added, not part of COLOSSUS
KEY_IN		DS	0		; temp for keybd code

SAVEQ		DS	0		; temp for return addr


; Bank intercommunication

BJBANK		DS	0
BJRET		DS	0

PJBANK		DS	0
PJRET		DS	0
PJA		DS	0

BCBANK		DS	0
BCRET		DS	0
BCA		DS	0

MBCBANK		DS	0
MBCRET		DS	0
MBCA		DS	0

DCBANK		DS	0
DCRET		DS	0

