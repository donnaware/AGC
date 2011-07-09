;==========================================================================
; DISPLAY ROUTINES (file:bank41_2.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 337-342.
;==========================================================================

;==========================================================================
; PINBALL GAME LOAD VERBS (file:bank41_2.asm)
;
; If alarm condition is detected during execute, check fail light is
; turned on and ENDOFJOB. If alarm condition is detected during enter
; of data, check fail is turned on and it recycles to execute of
; original load verb. Recycle caused by 1) decimal machine CADR,
; 2) mixture of octal/decimal data, 3) octal data into decimal only
; noun, 4) decimal data into octal only noun, 5) data too large for
; scale, 6) fewer than two data words loaded for HRS, MIN, SEC noun.
; For #2-6, alarm and recycle occur at final enter of set; for #1,
; alarm and recycle occur at enter of CADR.
;
; AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.337-343.
;==========================================================================

ABCLOAD		EQU	*
		CS	TWO
		TC	COMPTEST
		TC	NOUNTEST	; test if noun can be loaded

		CAF	VBSP1LD
		TC	UPDATVB-1
		TC	REQDATX

		CAF	VBSP2LD
		TC	UPDATVB-1
		TC	REQDATY

		CAF	VBSP3LD
		TC	UPDATVB-1
		TC	REQDATZ

PUTXYZ		EQU	*
		CS	SIX		; test that the 3 data words loaded are
		TC	ALLDC_OC	; all dec or all oct
		
		CAF	LODNNLOC	; was DCA LODNNLOC, DXCH Z in Block II
		TC	DXCHJUMP	; bank jump to noun table read rtne

		CAF	ZERO		; X comp
		TC	PUTCOM
		INDEX	NOUNADD
		TS	0

		CAF	ONE		; Y comp
		TC	PUTCOM
		INDEX	NOUNADD
		TS	1

		CAF	TWO		; Z comp
		TC	PUTCOM
		INDEX	NOUNADD
		TS	2

; *************** missing stuff *****************

; Omitted a bunch of code from here that does special stuff if the noun=7.
; (a noun that operates on I/O channels and flagbits)

		TC	LOADLV


ABLOAD		EQU	*
		CS	ONE
		TC	COMPTEST
		TC	NOUNTEST	; test if noun can be loaded

		CAF	VBSP1LD
		TC	UPDATVB-1
		TC	REQDATX

		CAF	VBSP2LD
		TC	UPDATVB-1
		TC	REQDATY

PUTXY		EQU	*
		CS	FIVE		; test that the 2 data words loaded are
		TC	ALLDC_OC	; all dec or all oct
		
		CAF	LODNNLOC	; was DCA LODNNLOC, DXCH Z in Block II
		TC	DXCHJUMP	; bank jump to noun table read rtne

		CAF	ZERO		; X comp
		TC	PUTCOM
		INDEX	NOUNADD
		TS	0

		CAF	ONE		; Y comp
		TC	PUTCOM
		INDEX	NOUNADD
		TS	1

		TC	LOADLV

ALOAD		EQU	*
		TC	REQDATX

		CAF	LODNNLOC	; was DCA LODNNLOC, DXCH Z in Block II
		TC	DXCHJUMP	; bank jump to noun table read rtne

		CAF	ZERO		; X comp
		TC	PUTCOM
		INDEX	NOUNADD
		TS	0
		TC	LOADLV

BLOAD		EQU	*
		CS	ONE
		TC	COMPTEST
		CAF	BIT15		; set CLPASS for PASS0 only
		TS	CLPASS
		TC	REQDATY
		CAF	LODNNLOC	; was DCA LODNNLOC, DXCH Z in Block II
		TC	DXCHJUMP	; bank jump to noun table read rtne
		CAF	ONE
		TC	PUTCOM
		INDEX	NOUNADD
		TS	1
		TC	LOADLV

CLOAD		EQU	*
		CS	TWO
		TC	COMPTEST
		CAF	BIT15		; set CLPASS for PASS0 only
		TS	CLPASS
		TC	REQDATZ
		CAF	LODNNLOC	; was DCA LODNNLOC, DXCH Z in Block II
		TC	DXCHJUMP	; bank jump to noun table read rtne
		CAF	TWO
		TC	PUTCOM
		INDEX	NOUNADD
		TS	2
		TC	LOADLV		; yes, COLOSSUS actually did this

LOADLV		EQU	*
		CAF	ZERO
		TS	DECBRNCH
		CS	ZERO
		TS	LOADSTAT
		CS	VD1		; to block numerical chars and
		TS	DSPCOUNT	; clears after a completed load
		TC	POSTJUMP	; after completed load, go to RECALTST
		DS	RECALTST	; to see if there is RECALL from ENDIDLE
		
VBSP1LD		DS	21		; VB21 = ALOAD
VBSP2LD		DS	22		; VB22 = BLOAD
VBSP3LD		DS	23		; VB23 = CLOAD

ALLDC_OC	EQU	*
		TS	DECOUNT		; test that data words loaded are either

		XCH	Q		; (needed to handle TCF conversion below)
		TS	ALLDC_OC_Q	; save return address

		CS	DECBRNCH	; all dec or all oct; alarms if not
		TS	SR
		CS	SR
		CS	SR		; shifted right 2
		CCS	A		; dec comp bits in low 3
		TC	*+2		; some ones in low 3 (was TCF in Block II)
		TC	ALLDC_OC_Q	; all zeros, all oct, OK so return
		AD	DECOUNT		; dec comp = 7 for 3comp, =6 for 2comp
					; (but it has been decremented by CCS)
		CCS	A		; must match 6 for 3comp, 5 for 2comp
		TC	*+4		; >0
		TC	*+2		; +0
		TC	*+2		; <0
		TC	*+2		; -0, was BZF *+2 in Block II

		TC	ALMCYCLE	; alarm and recycle (does not return)

		XCH	ALLDC_OC_Q	; restore return address
		TS	Q
GOQ		TC	Q		; all required are dec, OK
		
;--------------------------------------------------------------------------
; SFRUTNOR
; gets SF routine number for normal case.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.340.
;--------------------------------------------------------------------------

SFRUTNOR	EQU	*
		XCH	Q
		TS	EXITEM		; can't use L for return. TESTFORDP uses L.
		CAF	MID5
		MASK	NNTYPTEM
		TC	RIGHT5
		TC	EXITEM		; SF routine number in A


;--------------------------------------------------------------------------
; SFRUTMIX
; gets SF routine number for mixed case.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.340.
;--------------------------------------------------------------------------

SFRUTMIX	EQU	*
		XCH	Q		; gets SF routine number for mixed case
		TS	EXITEM

		INDEX	DECOUNT
		CAF	DISPLACE	; put TC GOQ, TC RIGHT5, or TC LEFT5 in L
		TS	SFRUTMIX_L

		INDEX	DECOUNT
		CAF	LOW5		; LOW5, MID5, or HI5 in A
		MASK	RUTMXTEM	; get HI5, MID5, or LOW5 of RUTMXTAB entry

		INDEX	SFRUTMIX_L
		TC	0

	; do TC GOQ (DECOUNT=0), do TC RIGHT5 (DECOUNT=1), do TC LEFT5 (DECOUNT=2)

SFRET1		TC	EXITEM		; SF routine number in A


SFCONUM		EQU	*
		XCH	Q		; gets 2X (SF constant number)
		TS	EXITEM
		INDEX	MIXBR
		TC	*+0
		TC	CONUMNOR	; normal noun
		INDEX	DECOUNT		; mixed noun
		CAF	DISPLACE
		TS	SFCONUM_L	; put TC GOQ, TC RIGHT5, or TC LEFT5 in L
		INDEX	DECOUNT
		CAF	LOW5
		MASK	NNTYPTEM
		INDEX	SFCONUM_L
		TC	0

	; do TC GOQ (DECOUNT=0), do TC RIGHT5 (DECOUNT=1), do TC LEFT5 (DECOUNT=2)

SFRET		DOUBLE			; 2X (SF constant number) in A
		TC	EXITEM


DISPLACE	EQU	*
		TC	GOQ
		TC	RIGHT5
		TC	LEFT5

CONUMNOR	EQU	*
		CAF	LOW5		; normal noun always gets low 5 of
		MASK	NNTYPTEM	; NNTYPTAB for SF CONUM
		DOUBLE
		TC	EXITEM		; 2X (SF constant number) in A

PUTCOM		EQU	*
		TS	DECOUNT
		XCH	Q
		TS	DECRET
		CAF	ZERO
		TS	MPAC+6
		INDEX	DECOUNT
		XCH	XREGLP
		TS	MPAC+1
		INDEX	DECOUNT
		XCH	XREG
		TS	MPAC
		INDEX	MIXBR
		TC	*
		TC	PUTNORM		; normal noun

	; if mixnoun, place address for component K into NOUNADD, set EBANK bits.

		INDEX	DECOUNT		; set IDADDTAB entry for component K
		CAF	ZERO		; of noun
		AD	IDAD1TEM	; was CA IDAD1TEM in Block II
		MASK	LOW11		; (ECADR) SUBK for current comp of noun
		TC	SETNCADR	; ECADR into NOUNCADR, sets EB, NOUNADD
		EXTEND			; C(NOUNADD) in A upon return
		SU	DECOUNT		; place (ESUBK)-K into NOUNADD
		TS	NOUNADD
		CCS	DECBRNCH
		TC	PUTDECSF	; + dec
		TC	DCTSTCYC	; +0 octal
		TC	SFRUTMIX	; test if dec only bit = 1. If so,
		TC	DPTEST		; alarm and recycle. If not, continue.
		TC	PUTCOM2		; no DP
					; test for DP scale for oct load. If so,
					; +0 into major part. Set NOUNADD for
					; loading octal word into minor part.

PUTDPCOM	EQU	*
		CAF	ZERO		; was INCR NOUNADD in Block II
		AD	NOUNADD		; DP (RSUBK)-K+1 or E+1
		AD	ONE
		TS	NOUNADD		: NOUNADD now set for minor part

		AD	DECOUNT		; (ESUBK)+1 or E+1 into DECOUNT
		TS	DECOUNT		; was ADS DECOUNT in Block II

		CAF	ZERO		; NOUNADD set for minor part
		INDEX	DECOUNT
		TS	-1		; zero major part (ESUBK or E1)
		TC	PUTCOM2

PUTNORM		EQU	*
		TC	SETNADD		; ECADR from NOUNCADR, sets EB, NOUNADD
		CCS	DECBRNCH
		TC	PUTDECSF	; +DEC
		TC	DCTSTCYC	; +0 octal
		TC	SFRUTNOR	; test if dec only bit = 1. If so,
		TC	DPTEST		; alarm and recycle. If not, continue.
		TC	PUTNORM_1	; no DP
		CAF	ZERO
		TS	DECOUNT
		TC	PUTDPCOM

PUTNORM_1	EQU	*		; eliminated Block II CHANNEL LOAD code

PUTCOM2		EQU	*
		XCH	MPAC
		TC	DECRET

GTSFINLC	DS	GTSFIN

; *************** missing stuff *****************

; PUTDECSF
; Finds MIXBR and DECOUNT still set from PUTCOM

PUTDECSF	EQU	*
		TC	SFCONUM		; 2X (SF CON NUM) in A
		TS	SFTEMP1

		CAF	GTSFINLC	; was DCA GTSFINLC, DXCH Z in Block II
		TC	DXCHJUMP	; bank jump to SF const table read rtne
					; loads SFTEMP1, SFTEMP2
		INDEX	MIXBR
		TC	*
		TC	PUTSFNOR
		TC	SFRUTMIX
		TC	PUTDCSF2
PUTSFNOR	TC	SFRUTNOR

PUTDCSF2	INDEX	A
		CAF	SFINTABR
		TC	BANKJUMP	; switch banks for expansion room
SFINTABR	CADR	GOALMCYC	; 0, alarm and recycle if dec load
		CADR	BINROUND	; 1
		CADR	DEGINSF		; 2
		CADR	ARTHINSF	; 3
		CADR	0		; 4 **********
		CADR	0		; 5 **********
		CADR	0		; 6 **********
		CADR	0		; 7 **********
		CADR	0		; 8 **********
		CADR	0		; 9 **********
		CADR	0		; 10 *********
		CADR	0		; 11 *********
		CADR	0		; 12 *********


; BUNCH OF TABLE ENTRIES GO HERE!!!!!

; ************ NEED TO ADD THE REST *************
		


