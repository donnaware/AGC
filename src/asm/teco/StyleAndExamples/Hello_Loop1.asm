;-------------------------------------------------------------------------
; AGC Programming example (hello.asm)
;
; This is the equivalent of the venerable "hello world" program found for
; just about every language and computer. Here it is for the AGC. Except
; since we do not have an alpha console, we will use 01134, which, when
; a seven segment display is help upside down, spells Hello.
; 
;-------------------------------------------------------------------------
	ORG	EXTENDER
	DS	%47777	; needed for EXTEND

	ORG	%2100
;-------------------------------------------------------------------------
; The way the display works in the 

;  15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
; |PB|D3|D2|D1|D0|PM|B3|B2|B1|B0|BE|A3|A2|A1|A0|AE|
; +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
; 
; PB        Parity Bit, always 0
; D3..D0    Realy Word: Digit location 0 - 15, 0 is blank, 1 is digit pair lcoation 1 and so on
; PM        DSPC:  Plus minus bit 
; B4..B0    DSPH: The left BCD digit in the pair
; A4..A0    DSPL: The right BCV digit in the pair
;
; Bits   Bit     Bits   Bits 
; 15-12  11      10-6   5-1
; RLYWD  DSPC    DSPH   DSPL
; -----  ------  ----   -----
; 1011           MD1    MD2
; 1010   FLASH   VD1    VD2
; 1001           ND1    ND2
; 1000   UPACT          R1D1
; 0111   +R1S    R1D2   R1D3
; 0110   -R1S    R1D4   R1D5
; 0101   +R2S    R2D1   R2D2
; 0100   -R2S    R2D3   R2D4
; 0011           R2D5   R3D1
; 0010   +R3S    R3D2   R3D3
; 0001   -R3S    R3D4   R3D5
;
; Digit AGC Code  BCD Equivalent
; ----- --------  --------------
; Blank 00000     1111
; 0     10101     0000
; 1     00011     0001
; 2     11001     0010
; 3     11011     0011
; 4     01111     0100
; 5     11110     0101
; 6     11100     0110
; 7     10011     0111
; 8     11101     1000
; 9     11111     1001
;                      1 1111 1 00000 00000
;                      5 4321 0 98765 43210
;                      - ---- - ----- -----
D_HE	DS	$0B6F	; 0 0001 0 11011 01111 
D_LL	DS	$1273	; 0 0010 0 10011 10011
D_O_	DS	$1815	; 0 0011 0 00000 10101 

;-------------------------------------------------------------------------
	ORG	GOPROG
Loop	EQU	*

; do this stuff over and over again forever

	CAF	D_HE
	TS	OUT0		; WRITE to OUT0 

	CAF	D_LL
	TS	OUT0		; WRITE to OUT0 

	CAF	D_O_
	TS	OUT0		; WRITE to OUT0 

;-------------------------------------------------------------------------
	TC	Loop

;-------------------------------------------------------------------------
