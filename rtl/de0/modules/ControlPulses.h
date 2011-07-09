// --------------------------------------------------------------------
// ng_AGC Control Pulse Matrix signal definitions
// --------------------------------------------------------------------
`define    CPX(sig)	(sig-1)	// Compute The CPM signal
`define    SLX(sig)	(sig-1)	// Compute The SELECT signal

// --------------------------------------------------------------------
// OUTPUTS FROM SUBSYSTEM A
// --------------------------------------------------------------------
`define    CI		 1		// Carry in
`define    CLG		 2		// Clear G
`define    CLCTR	 3		// Clear loop counter
`define    CTR		 4		// Loop counter
`define    GP		 5		// Generate Parity
`define    KRPT	 6		// Knock down Rupt priority
`define    NISQ	 7		// New instruction to the SQ register
`define    RA		 8		// Read A
`define    RB		 9		// Read B
`define    RB14	10		// Read bit 14
`define    RC		11		// Read C
`define    RG		12		// Read G
`define    RLP		13		// Read LP
`define    RP2		14		// Read parity 2
`define    RQ		15		// Read Q
`define    RRPA	16		// Read RUPT address
`define    RSB		17		// Read sign bit
`define    RSCT	18		// Read selected counter address
`define    RU		19		// Read sum
`define    RZ		20		// Read Z
`define    R1		21		// Read 1
`define    R1C		22		// Read 1 complimented
`define    R2		23		// Read 2
`define    R22		24		// Read 22
`define    R24		25		// Read 24
`define    ST1		26		// Stage 1
`define    ST2		27		// Stage 2
`define    TMZ		28		// Test for minus zero
`define    TOV		29		// Test for overflow
`define    TP		30		// Test parity
`define    TRSM	31		// Test for resume
`define    TSGN	32		// Test sign
`define    TSGN2	33		// Test sign 2
`define    WA		34		// Write A
`define    WALP	35		// Write A and LP
`define    WB		36		// Write B
`define    WGX		37		// Write G (do not reset)
`define    WLP		38		// Write LP
`define    WOVC	39		// Write overflow counter
`define    WOVI	40		// Write overflow RUPT inhibit
`define    WOVR	41		// Write overflow
`define    WP		42		// Write P
`define    WPX		43		// Write P (do not reset)
`define    WP2		44		// Write P2
`define    WQ		45		// Write Q
`define    WS		46		// Write S
`define    WX		47		// Write X
`define    WY		48		// Write Y
`define    WYX		49		// Write Y (do not clear X)
`define    WZ		50		// Write Z

// --------------------------------------------------------------------
// OUTPUTS FROM SUBSYSTEM A; USED AS INPUTS TO SUBSYSTEM B ONLY;
// NOT USED OUTSIDE CPM
// --------------------------------------------------------------------
`define    RSC		51		// Read special and central (output to B only, not outside CPM)
`define    WSC		52		// Write special and central (output to B only, not outside CPM)
`define    WG		53		// Write G (output to B only, not outside CPM)

// --------------------------------------------------------------------
// OUTPUTS FROM SUBSYSTEM A; USED AS INPUTS TO SUBSYSTEM C ONLY;
// NOT USED OUTSIDE CPM
// --------------------------------------------------------------------
`define    SDV1	54		// Subsequence DV1 is currently active
`define    SMP1	55		// Subsequence MP1 is currently active
`define    SRSM3	56		// Subsequence RSM3 is currently active

// --------------------------------------------------------------------
// EXTERNAL OUTPUTS FROM SUBSYSTEM B
// --------------------------------------------------------------------
`define    RA0		57		// Read register at address 0 (A)
`define    RA1		58		// Read register at address 1 (Q)
`define    RA2		59		// Read register at address 2 (Z)
`define    RA3		60		// Read register at address 3 (LP)
`define    RA4		61		// Read register at address 4
`define    RA5		62		// Read register at address 5
`define    RA6		63		// Read register at address 6
`define    RA7		64		// Read register at address 7
`define    RA10	65		// Read register at address 10 (octal)
`define    RA11	66		// Read register at address 11 (octal)
`define    RA12	67		// Read register at address 12 (octal)
`define    RA13	68		// Read register at address 13 (octal)
`define    RA14	69		// Read register at address 14 (octal)
`define    RBK		70		// Read BNK
`define    WA0		71		// Write register at address 0 (A)
`define    WA1		72		// Write register at address 1 (Q)
`define    WA2		73		// Write register at address 2 (Z)
`define    WA3		74		// Write register at address 3 (LP)
`define    WA10	75		// Write register at address 10 (octal)
`define    WA11	76		// Write register at address 11 (octal)
`define    WA12	77		// Write register at address 12 (octal)
`define    WA13	78		// Write register at address 13 (octal)
`define    WA14	79		// Write register at address 14 (octal)
`define    WBK		80		// Write BNK
`define    WGN		81		// Write G (normal gates)**
`define    W20		82		// Write into CYR
`define    W21		83		// Write into SR
`define    W22		84		// Write into CYL
`define    W23		85		// Write into SL

// --------------------------------------------------------------------
// EXTERNAL OUTPUTS FROM SUBSYSTEM C
// --------------------------------------------------------------------
`define    GENRST	86		// General Reset**
`define    CLINH	87		// Clear INHINT**
`define    CLINH1	88		// Clear INHINT1**
`define    CLSTA	89		// Clear state counter A (STA)**
`define    CLSTB	90		// Clear state counter B (STB)**
`define    CLISQ	91		// Clear SNI**
`define    CLRP	92		// Clear RPCELL**
`define    INH		93		// Set INHINT**
`define    RPT		94		// Read RUPT opcode **
`define    SBWG	95		// Write G from memory
`define    SETSTB	96		// Set the ST1 bit of STB
`define    WE		97		// Write E-MEM from G
`define    WPCTR	98		// Write PCTR (latch priority counter sequence)**
`define    WSQ		99		// Write SQ
`define    WSTB  100		// Write stage counter B (STB)**
`define    R2000 101		// Read 2000 **


// --------------------------------------------------------------------
// ADDRESS SELECTION SUBSYSTEM Signals:
// --------------------------------------------------------------------
`define    GTR_1777	6		// Greater than Octal 1777
`define    GTR_27 	5		// Greater than Octal 27
`define    EQU_25	 	4		// Equal   to   Octal 25
`define    GTR_17		3		// Greater than Octal 17
`define    EQU_17	 	2		// Equal   to   Octal 17
`define    EQU_16	 	1		// Equal   to   Octal 16


//-------------------------------------------------------------------------------------------------
// (TPG) - Time Pulse Generator Signals:
//-------------------------------------------------------------------------------------------------
`define  TP_Standby	0
`define  TP_PowerOn	1
`define  TP_1			2
`define  TP_2			3
`define  TP_3			4
`define  TP_4			5
`define  TP_5			6
`define  TP_6			7
`define  TP_7			8
`define  TP_8			9
`define  TP_9			10
`define  TP_10			11
`define  TP_11			12
`define  TP_12			13
`define  TP_SRELSE	14
`define  TP_Wait		15

// --------------------------------------------------------------------
// END
// --------------------------------------------------------------------
