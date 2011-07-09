;==========================================================================
; DISPLAY ROUTINES (file:bankff_3.asm)
;
; Adapted from the AGC Block II COLOSSUS rev 249 assembly listing, 
; Oct 28, 1968, pp. 363-364.
;==========================================================================

; COLOSSUS p. 364 - comments are taken from the Block I flow charts with some
; additional annotations by me.


NVSUB		EQU	*
		TS	NVSUB_A		; more gymnastics for Block II conversion

		CAF	ZERO		; was LXCH 7 in Block II
		TS	NVSUB_L		; zero NVMONOPT options

	; save C(A). C(A) should be holding the noun/verb code; C(L) should
	; be holding NVMONOPT options. In this Block I version, the NVMONOPT
	; options should be placed in NVSUB_L before calling NVMONOPT.

		XCH	NVSUB_A

NVMONOPT	EQU	*
		TS	NVTEMP

	; Test DSPLOCK (+NZ=busy; +0=display system available)
	; Display is blocked by DSPLOCK=1 or external monitor bit set (bit 14)

		CAF	BIT14
		MASK	MONSAVE1	; external monitor bit
		AD	DSPLOCK
		CCS	A
		TC	Q		; dsp syst blocked, ret to 1, calling loc

	; Store calling line +2 in NVQTEM

		CAF	ONE		; dsp syst available
NVSBCOM		AD	Q
		TS	NVQTEM		; 2+calling loc into NVQTEM

	; Force bit 15 of MONSAVE to 1, turn off bit 14.

		XCH	NVSUB_L		; was LXCH MONSAVE2 in Block II
		XCH	MONSAVE2	; store NVMONOPT options
		TS	NVSUB_L		; replaces LXCH by working through A instead

		TC	KILMONON	; turn on kill monitor bit

	; Store calling bank in NVBNKTEM
	; ** this was changed quite a bit from Block II **

NVSUBCOM	EQU	*
		CAF	ZERO
		AD	BANK
		TS	NVBNKTEM

		TC	MYBANKCALL	; go to NVSUB1 thru standard loc
		CADR	NVSUBR

NVSRRBNK	CADR	NVSUB1		; ****** WHAT'S THIS FOR?? ********


	; Restore calling bank and TC NVQTEM
	; ** this was changed quite a bit from Block II **

NVSUBEND	EQU	*
		CAF	ZERO
		AD	NVBNKTEM
		TS	BANK		; restore calling bank
		TC	NVQTEM
	