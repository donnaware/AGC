;==========================================================================
; DISPLAY ROUTINES (file:bank41_1.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 318-329.
;==========================================================================

;--------------------------------------------------------------------------
; ENTER -- PROCESS ENTER KEY
; Enter pass 0 is the execute function. Higher order enters are to load
; data. The sign of REQRET determines the pass, + for pass 0, - for higher
; passes.
; Machine CADR to be specified (MCTBS) nouns desire an ECADR to be loaded
; when used with load verbs, monitor verbs, or display verbs (except
; verb = fixed memory display, which requires a FCADR).
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.318.
;--------------------------------------------------------------------------

NVSUBR		TC	NVSUB1		; standard lead-ins, don't move
LOADLV1		TC	LOADLV

ENTER		EQU	*
		CAF	ZERO
		TS	CLPASS
		CAF	ENDINST
		TS	ENTRET

		CCS	REQRET
		TC	ENTPAS0		; if +, pass 0
		TC	ENTPAS0		; if +, pass 0
		TC 	*+1		; if -, not pass 0


	; not first pass thru ENTER, so enter data word

ENTPASHI	EQU	*
		CAF	MMADREF
		AD	REQRET		; if L/2 char in for MM code, alarm

		CCS	A		; and recycle (decide at MMCHANG+1)
		TC	*+4		; >0
		TC	*+2		; +0
		TC	*+2		; <0
		TC	ACCEPTWD	; -0, was BZF ACCEPTWD in Block II

		CAF	THREE		; if DEC, alarm if L/5 char in for data,
		MASK	DECBRNCH	; but leave REQRET - and flash on, so
		CCS	A		; operator can supply missing numerical
		TC	*+2		; characters and continue.
		TC	ACCEPTWD	; octal, any number of char OK.
		CCS	DSPCOUNT
		TC	GODSPALM	; less than 5 char DEC(DSPCOUNT is +)
		TC	GODSPALM	; less than 5 char DEC(DSPCOUNT is +)
		TC	*+1		; 5 char in (DSPCOUNT is -)

ACCEPTWD	EQU	*
		CS	REQRET		; 5 char in (DSPCOUNT is -)
		TS	REQRET		; set REQRET +
		TC	FLASHOFF
		TC	REQRET

ENTEXIT		EQU	ENTRET

MMADREF		DS	MMCHANG+1	; assumes TC REGMM at MMCHANG

LOWVERB		DS	28		; lower verb that avoids nount test.


	; first pass thru ENTER, so execute VERB/NOUN

ENTPAS0		EQU	*
		CAF	ZERO		; noun verb sub enters here
		TS	DECBRNCH
		CS	VD1		; block further num char, so that stray
		TS	DSPCOUNT	; char do not get into verb or nount lights.

	; test VERB

TESTVB		EQU	*
		CS	VERBREG		; if verb is G/E LOWVB, skip noun test
		TS	VERBSAVE	; save verb for possible recycle.
		AD	LOWVERB		; LOWVERB - VB

		CCS	A		; was BZMF VERBFAN in Block II
		TC	*+4		; >0
		TC	*+2		; +0, VERB G/E LOWVERB
		TC	*+1		; <0, VERB G/E LOWVERB
		TC	VERBFAN		; -0, VERB G/E LOWVERB

	; test NOUN

TESTNN		EQU	*

	; set MIXBR and put the noun address into NNADTEM
	; MIXBR is an enumerated type:
	; 1 = normal nouns
	; 2 = mixed nouns

		CAF	LODNNLOC	; was DCA LODNNLOC, DXCH Z in Block II
		TC	DXCHJUMP	; bank jump to noun table read rtne

		INDEX	MIXBR		; computed GOTO
		TC	*+0

		TC	*+2		; returns here for normal noun
		TC	MIXNOUN		; returns here for mixed noun

	; normal noun, so test noun address table entry (NNADTEM)

		CCS	NNADTEM		; normal
		TC	VERBFAN-2	; normal if +
		TC	GODSPALM	; not in use if +0
		TC	REQADD		; specify machine CADR if -

	; NNADTEM was -0, so just increment noun address (in NOUNCADR) and
	; set the result in NOUNADD

		XCH	NOUNCADR	; augment machine CADR if -0
		AD	ONE
		TS	NOUNCADR	; was INCR NOUNCADR in Block II

		TC	SETNADD		; set NOUNADD
		TC	INTMCTBS+3

	; NNADTEM was -, so noun address needs to be specified (loaded).

REQADD		EQU	*
		CAF	BIT15		; set CLPASS for pass0 only
		TS	CLPASS
		CS	ENDINST		; test if reach here from internal or
		AD	ENTEXIT		; from external

		CCS	A		; was BZF *+2 in Block II
		TC	*+4		; >0
		TC	*+2		; +0
		TC	*+2		; <0
		TC	*+2		; -0, external mach CADR to be specified

		TC	INTMCTBS

		TC	REQDATZ		; external mach CADR to be specified

		CCS	DECBRNCH	; alarm and recycle if decimal used
		TC	ALMCYCLE	; for MCTBS
		CS	VD1		; octal used OK
		TS	DSPCOUNT	; block num char in

		CCS	CADRSTOR
		TC	*+3		; external MCTBS display will leave flash
		TC	USEADD		; on if ENDIDLE not = +0
		TC	*+1
		TC	FLASHON

	; noun address has now been loaded into the Z register. Copy it into
	; NOUNCADR and NOUNADD and then jump to the VERBFAN.

USEADD		EQU	*
		XCH	ZREG
		TC	SETNCADR	; ECADR into NOUNCADR, set EB, NOUNADD

		CAF	LODNNLOC	; was DCA LODNNLOC, DXCH Z in Block II
		TC	DXCHJUMP	; bank jump to noun table read rtne

		TC	VERBFAN

LODNNLOC	DS	LODNNTAB	; *** uses 2 words in Block II ***
		DS	0





NEG5		DS	-5

	; If external (keyboard input), noun address is in register A.
	; If internal (S/W input), noun address is in MPAC+2.
	; Store the noun address into NOUNCADR and NOUNADD. If the verb
	; is O5. go directly to the VERBFAN; for all other verbs, display
	; the noun address in R3 and then go to the VERBFAN.

INTMCTBS	EQU	*

	; entry point for internal:

		CAF	ZERO		; was CA MPAC+2 in Block II
		AD	MPAC+2		; internal mach CADR to be specified

	; entry point for external (keyboard input):

		TC	SETNCADR	; store addr (A) into NOUNCADR and NOUNADD

		CS	FIVE		; NVSUB call left CADR in MAPC+2 for mach
		AD	VERBREG		; CADR to be specified.

		CCS	A		; was BZF VERBFAN in Block II
		TC	*+4		; >0
		TC	*+2		; +0
		TC	*+2		; <0
		TC	VERBFAN		; -0, don't display CADR if verb = 05

		CAF	R3D1		; verb not = 05, display CADR
		TS	DSPCOUNT

		CAF	ZERO		; was CA NOUNCADR in Block II
		AD	NOUNCADR
		TC	DSPOCTWD
		TC	VERBFAN

	; NNADTEM was + (normal), so just use the noun address straight from the
	; noun table (currently in A). The CCS instruction used to test the 
	; address also decremented it, so we add one to restore the correct address.

		AD	ONE
		TC	SETNCADR	; store addr (A) into NOUNCADR and NOUNADD


	; noun address is currently in NOUNCADR and NOUNADD.

VERBFAN		EQU	*
		CS	LST2CON
		AD	VERBREG		; verb-LST2CON

		CCS	A
		AD	ONE		; ver G/ LST2CON
		TC	*+2
		TC	VBFANDIR	; verb L/ LST2CON
		TS	MPAC
		TC	RELDSP		; release display syst
		TC	POSTJUMP	; go to GOEXTVB with VB-40 in MPAC
		DS	GOEXTVB

LST2CON		DS	40		; first list2 verb (extended verb)

VBFANDIR	EQU	*
		INDEX	VERBREG
		CAF	VERBTAB
		TC	BANKJUMP

VERBTAB		EQU	*
		CADR	GODSPALM	; VB00 Illegal
		CADR	DSPA		; VB01 display oct comp 1 (R1)
		CADR	DSPB		; VB02 display oct comp 2 (R1)
		CADR	DSPC		; VB03 display oct comp 3 (R1)
		CADR	DSPAB		; VB04 display oct comp 1,2 (R1,R2)
		CADR	DSPABC		; VB05 display oct comp 1,2,3 (R1,R2,R3)
		CADR	DECDSP		; VB06 decimal display
		CADR	DSPDPDEC	; VB07 DP decimal display (R1,R2)
		CADR	GODSPALM	; VB08 spare
		CADR	GODSPALM	; VB09 spare
		CADR	GODSPALM	; VB10 spare
		CADR	MONITOR		; VB11 monitor oct comp 1 (R1)
		CADR	MONITOR		; VB12 monitor oct comp 2 (R2)
		CADR	MONITOR		; VB13 monitor oct comp 3 (R3)
		CADR	MONITOR		; VB14 monitor oct comp 1,2 (R1,R2)
		CADR	MONITOR		; VB15 monitor oct comp 1,2,3 (R1,R2,R3)
		CADR	MONITOR		; VB16 monitor decimal
		CADR	MONITOR		; VB17 monitor DP decimal (R1,R2)
		CADR	GODSPALM	; VB18 spare
		CADR	GODSPALM	; VB19 spare
		CADR	GODSPALM	; VB20 spare
		CADR	ALOAD		; VB21 load comp 1 (R1)
		CADR	BLOAD		; VB22 load comp 2 (R2)
		CADR	CLOAD		; VB23 load comp 3 (R3)
		CADR	ABLOAD		; VB24 load comp 1,2 (R1,R2)
		CADR	ABCLOAD		; VB25 load comp 1,2,3 (R1,R2,R3)
		CADR	GODSPALM	; VB26 spare
		CADR	DSPFMEM		; VB27 fixed memory display
		CADR	GODSPALM	; VB28 spare
		CADR	GODSPALM	; VB29 spare
		CADR	VBRQEXEC	; VB30 request executive
		CADR	VBRQWAIT	; VB31 request waitlist
		CADR	VBRESEQ		; VB32 resequence
		CADR	VBPROC		; VB33 proceed (without data)
		CADR	VBTERM		; VB34 terminate
		CADR	VBTSTLTS	; VB35 test lights
		CADR	SLAP1		; VB36 fresh start
		CADR	MMCHANG		; VB37 change major mode
		CADR	GODSPALM	; VB38 spare
		CADR	GODSPALM	; VB39 spare



;--------------------------------------------------------------------------
; MIXNOUN
; NNADTAB contains a relative address, IDADDREL(in low 10 bits), referring
; to where 3 consecutive addresses are stored (in IDADDTAB).
; MIXNOUN gets data and stores in MIXTEMP, +1, +2. It sets NOUNADD for
; MIXTEMP.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.322.
;--------------------------------------------------------------------------

MIXNOUN		EQU	*
		TC	GODSPALM	; not currently implemented

	; ************ BUNCH OF MISSING STUFF ************


;--------------------------------------------------------------------------
; DPTEST
; enter with SF routine code number (SF ROUT) in A. Returns to L+1 if no DP. 
; Returns to L+2 if DP.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.322. Also, see p. 263.
;--------------------------------------------------------------------------

DPTEST		EQU	*
		TS	DPTEST_A
		XCH	Q
		TS	DPTEST_Q

		INDEX	DPTEST_A
		TC	*+1
		TC	DPTEST_Q	; octal only, no DP
		TC	DPTEST_Q	; straight fractional, no DP
		TC	DPTEST_Q	; CDU degrees (XXX.XX), no DP
		TC	DPTEST_Q	; arithmetic SF, no DP
		TC	DPTEST1		; DP1OUT
		TC	DPTEST1		; DP2OUT
		TC	DPTEST_Q	; Y OPTICS DEGREES, no DP
		TC	DPTEST1		; DP3OUT
		TC	DPTEST_Q	; HMS, no DP
		TC	DPTEST_Q	; MS, no DP
		TC	DPTEST1		; DP4OUT
		TC	DPTEST_Q	; arith1, no DP
		TC	DPTEST_Q	; 2INTOUT, no DP to get hi part in MPAC

DPTEST1		EQU	*
		INDEX	DPTEST_Q
		TC	1		; return to L+2


;--------------------------------------------------------------------------
; REQDATX, REQDATY, REQDATZ
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.323.
;--------------------------------------------------------------------------

REQDATX		EQU	*
		XCH	Q
		TS	REQ_Q

		CAF	R1D1
		TC	REQCOM

REQDATY		EQU	*
		XCH	Q
		TS	REQ_Q

		CAF	R2D1
		TC	REQCOM

REQDATZ		EQU	*
		XCH	Q
		TS	REQ_Q

		CAF	R3D1

REQCOM		TS	DSPCOUNT
		CS	REQ_Q
		TS	REQRET
		TC	BANKCALL
		DS	_5BLANK

		TC	FLASHON

ENDRQDAT	EQU	*
		TC	ENTEXIT


;--------------------------------------------------------------------------
; UPDATNN, UPDATVB
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.323.
;--------------------------------------------------------------------------

		TS	NOUNREG
UPDATNN		EQU	*
		XCH	Q
		TS	UPDATRET

		CAF	LODNNLOC	; was DCA LODNNLOC, DXCH Z in Block II
		TC	DXCHJUMP	; bank jump to noun table read rtne

		CCS	NNADTEM
		AD	ONE		; >0, normal
		TC	PUTADD		; +0, normal
		TC	PUTADD+1	; <0, MCTBS don't change NOUNADD
		TC	PUTADD+1	; -0, MCTBI don't change NOUNADD

PUTADD		EQU	*
		TC	SETNCADR	; ECADR into NOUNCADR, sets NOUNADD

		CAF	ND1
		TS	DSPCOUNT

		CAF	ZERO		; was CA NOUNREG in Block II
		AD	NOUNREG
		TC	UPDAT1


		TS	VERBREG
UPDATVB		EQU	*
		XCH	Q
		TS	UPDATRET

		CAF	VD1
		TS	DSPCOUNT

		CAF	ZERO		; was CA VERBREG in Block II
		AD	VERBREG

UPDAT1		EQU	*
		TC	POSTJUMP	; can't use SWCALL to go to DSPDECVN, since
		DS	GOVNUPDT	; UPDATVB can itself be called by SWCALL
		TC	UPDATRET


;--------------------------------------------------------------------------
; GOALMCYC, GODSPALM
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.324.
;--------------------------------------------------------------------------

GOALMCYC	TC	ALMCYCLE	; needed because bankjump cant handle F/F	

GODSPALM	TC	POSTJUMP
		DS	DSPALARM
		

;--------------------------------------------------------------------------
; DISPLAY VERBS
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.326.
;--------------------------------------------------------------------------

DSPABC		EQU	*
		CS	TWO
		TC	COMPTEST
		INDEX	NOUNADD
		CS	2
		XCH	BUF+2

DSPAB		EQU	*
		CS	ONE
		TC	COMPTEST
		INDEX	NOUNADD
		CS	1
		XCH	BUF+1

DSPA		EQU	*
		TC	DECTEST
		TC	TSTFORDP
		INDEX	NOUNADD
		CS	0

DSPCOM1		EQU	*
		XCH	BUF
		TC	DSPCOM2

DSPB		EQU	*
		CS	ONE
		TC	DCOMPTST
		INDEX	NOUNADD
		CS	1
		TC	DSPCOM1

DSPC		EQU	*
		CS	TWO
		TC	DCOMPTST
		INDEX	NOUNADD
		CS	2
		TC	DSPCOM1

DSPCOM2		EQU	*
		CS	TWO		;  A  B  C AB ABC
		AD	VERBREG		; -1 -0 +1 +2 +3   IN A
		CCS	A		; +0 +0 +0 +1 +2   IN A AFTER CCS
		TC	DSPCOM3
		TC	ENTEXIT
		TC	*+1

DSPCOM3		EQU	*
		TS	DISTEM		; +0, +1, +2 into DISTEM
		INDEX	A
		CAF	R1D1
		TS	DSPCOUNT
		INDEX	DISTEM
		CS	BUF
		TC	DSPOCTWD
		XCH	DISTEM
		TC	DSPCOM2+2


;--------------------------------------------------------------------------
; COMPTEST
; alarms if component number of verb (load or oct display) is
; greater than the highest component number of noun.
;
; DCOMPTST 
; alarms if decimal only bit (bit 4 of comp code number) = 1.
; If not, it performs regular COMPTEST.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.326.
;--------------------------------------------------------------------------

COMPTEST	EQU	*
		TS	SFTEMP1		; - verb comp
		XCH	Q		; was LXCH Q in block II
		TS	LXCH_LPRET	; save return address in faux LP

COMPTST1	EQU	*
		TC	GETCOMP
		TC	LEFT5
		MASK	THREE		; noun comp
		AD	SFTEMP1		; noun comp - verb comp
		CCS	A
		TC	LXCH_LPRET	; noun comp G/ verb comp; return
		TC	CCSHOLE
		TC	GODSPALM	; noun comp L/ verb comp

NDOMPTST	EQU	*
		TC	LXCH_LPRET	; noun comp = verb comp; return

DCOMPTST	EQU	*
		TS	SFTEMP1		; - verb comp

		XCH	Q		; was LXCH Q in block II
		TS	LXCH_LPRET	; save return address in faux LP

		TC	DECTEST
		TC	COMPTST1

;--------------------------------------------------------------------------
; DECTEST
; alarms if dec only bit = 1 (bit 4 of comp code number1). Returns if not.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.327.
;--------------------------------------------------------------------------

DECTEST		EQU	*
		XCH	Q		; was QXCH MPAC+2 in block II
		TS	MPAC+2		

		TC	GETCOMP
		MASK	BIT14

		CCS	A
		TC	GODSPALM
		TC	MPAC+2

;--------------------------------------------------------------------------
; DCTSTCYC
; alarms and recycles if dec only bit = 1  (bit 4 of comp code number). 
; Returns if not. Used by load verbs.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.327.
;--------------------------------------------------------------------------

DCTSTCYC	EQU	*
		XCH	Q		; was LXCH Q in block II
		TS	LXCH_LPRET	; save return address in faux LP

		TC	GETCOMP
		MASK	BIT14

		CCS	A
		TC	ALMCYCLE
		TC	LXCH_LPRET

;--------------------------------------------------------------------------
; NOUNTEST 
; alarms if no-load bit (bit 5 of comp code number) = 1
; if not, it returns.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.327.
;--------------------------------------------------------------------------

NOUNTEST	EQU	*
		XCH	Q		; was LXCH Q in block II
		TS	LXCH_LPRET	; save return address in faux LP

		TC	GETCOMP

		CCS	A
		TC	LXCH_LPRET
		TC	LXCH_LPRET
		TC	GODSPALM

;--------------------------------------------------------------------------
; TSTFORDP
; test for DP. If so, get minor part only.
; The Block II version had some code that checked for a -1 in NNADTEM
; which meant use an I/O channel instead of memory. This was removed
; for the Block I.
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.327.
;--------------------------------------------------------------------------


TSTFORDP	EQU	*
		XCH	Q		; was LXCH Q in block II
		TS	LXCH_LPRET	; save return address in faux LP

		INDEX	MIXBR
		TC	*
		TC	*+2		; normal
		TC	LXCH_LPRET	; mixed case already handled in MIXNOUN

		TC	SFRUTNOR
		TC	DPTEST
		TC	LXCH_LPRET	; no DP

		XCH	NOUNADD		; was INCR NOUNADD in Block II
		AD	ONE		; DP  E+1 into NOUNADD for minor part
		TS	NOUNADD

		TC	LXCH_LPRET

;--------------------------------------------------------------------------
; GETCOMP
;
; noun address is in NNADTEM
; noun type is in NNTYPTEM
;
; MIXBR is an enumerated type: 
; 1 = normal nouns 
; 2 = mixed nouns 
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.328.
;--------------------------------------------------------------------------

COMPICK		DS	NNTYPTEM
		DS	NNADTEM

GETCOMP		EQU	*
		INDEX	MIXBR		; normal		mixed
		CAF	COMPICK-1	; ADRES NNTYPTEM	ADRES NNADTEM

		INDEX	A
		CS	0		; C(NNTYPTEM)		C(NNADTEM)
		COM			; was CA 0 in Block II
		MASK	HI5

		TC	Q

;--------------------------------------------------------------------------
; DECDSP -- DECIMAL DISPLAY
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, p.328.
;--------------------------------------------------------------------------

DECDSP		EQU	*
		TC	GETCOMP
		TC	LEFT5
		MASK	THREE
		TS	DECOUNT		; comp number into DECOUNT

DSPDCGET	EQU	*
		TS	DECTEM		; picks up data
		AD	NOUNADD		; DECTEM  1COMP +0, 2COMP +1, 3COMP +2
		INDEX	A
		CS	0
		INDEX	DECTEM
		XCH	XREG		; cant use BUF since DMP uses it
		CCS	DECTEM
		TC	DSPDCGET	; more to get

DSPDCPUT	EQU	*
		CAF	ZERO		; displays data
		TS	MPAC+1		; DECOUNT 1COMP +0, 2COMP +1, 3COMP +2
		TS	MPAC+2
		INDEX	DECOUNT
		CAF	R1D1
		TS	DSPCOUNT
		INDEX	DECOUNT
		CS	XREG
		TS	MPAC
		TC	SFCONUM		; 2X (SF CON NUMB) in A
		TS	SFTEMP1

		CAF	GTSFOUTL	; was DCA GTSFOUTL, DXCH Z in Block II
		TC	DXCHJUMP	; bank jump to SF constant table read rtne

		INDEX	MIXBR
		TC	*+0
		TC	DSPSFNOR
		TC	SFRUTMIX
		TC	DECDSP3

DSPSFNOR	EQU	*
		TC	SFRUTNOR
		TC	DECDSP3
GTSFOUTL	DS	GTSFOUT

DSPDCEND	EQU	*
		TC	BANKCALL	; all SFOUT routines end here
		DS	DSPDECWD
		CCS	DECOUNT
		TC	*+2
		TC	ENTEXIT
		TS	DECOUNT
		TC	DSPDCPUT	; more to display

DECDSP3		EQU	*
		INDEX	A
		CAF	SFOUTABR
		TC	BANKJUMP

SFOUTABR	EQU	*
		CADR	PREDSPAL	; 0, alarm if dec display with octal only noun
		CADR	DSPDCEND	; 1 
		CADR	DEGOUTSF	; 2
		CADR	ARTOUTSF	; 3 
		CADR	0		; 4 **********
		CADR	0		; 5 **********
		CADR	0		; 6 **********
		CADR	0		; 7 **********
		CADR	HMSOUT		; 8
		CADR	0		; 9 **********
		CADR	0		; 10 *********
		CADR	0		; 11 *********
		CADR	0		; 12 *********




