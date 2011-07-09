//---------------------------------------------------------------------------
#include <vcl.h>
//---------------------------------------------------------------------------
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <iostream.h>
#include <stdio.h>
#pragma hdrstop
#include "CPMGenUnit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner) : TForm(Owner)
{
}
//---------------------------------------------------------------------------
// CPM Microcode ROM GENERATOR
//---------------------------------------------------------------------------
#define MAXPULSES 15
#define MAX_IPULSES 5 // no more than 5 instruction-generated pulses active at any time

//---------------------------------------------------------------------------
// **inferred; not defined in orignal R393 AGC4 spec.
//---------------------------------------------------------------------------
enum cpType {
	NO_PULSE = 0,

	// OUTPUTS FROM SUBSYSTEM A
	CI		=1,		// Carry in
	CLG		=2,		// Clear G
	CLCTR	=3,		// Clear loop counter
	CTR		=4,		// Loop counter
	GP		=5,		// Generate Parity
	KRPT	=6,		// Knock down Rupt priority
	NISQ	=7,		// New instruction to the SQ register
	RA		=8,		// Read A
	RB		=9,		// Read B
	RB14	=10,	// Read bit 14
	RC		=11,	// Read C
	RG		=12,	// Read G
	RLP		=13,	// Read LP
	RP2		=14,	// Read parity 2
	RQ		=15,	// Read Q
	RRPA	=16,	// Read RUPT address
	RSB		=17,	// Read sign bit
	RSCT	=18,	// Read selected counter address
	RU		=19,	// Read sum
	RZ		=20,	// Read Z
	R1		=21,	// Read 1
	R1C		=22,	// Read 1 complimented
	R2		=23,	// Read 2
	R22		=24,	// Read 22
	R24		=25,	// Read 24
	ST1		=26,	// Stage 1
	ST2		=27,	// Stage 2
	TMZ		=28,	// Test for minus zero
	TOV		=29,	// Test for overflow
	TP		=30,	// Test parity
	TRSM	=31,	// Test for resume
	TSGN	=32,	// Test sign
	TSGN2	=33,	// Test sign 2
	WA		=34,	// Write A
	WALP	=35,	// Write A and LP
	WB		=36,	// Write B
	WGx		=37,	// Write G (do not reset)
	WLP		=38,	// Write LP
	WOVC	=39,	// Write overflow counter
	WOVI	=40,	// Write overflow RUPT inhibit
	WOVR	=41,	// Write overflow
	WP		=42,	// Write P
	WPx		=43,	// Write P (do not reset)
	WP2		=44,	// Write P2
	WQ		=45,	// Write Q
	WS		=46,	// Write S
	WX		=47,	// Write X
	WY		=48,	// Write Y
	WYx		=49,	// Write Y (do not reset)
	WZ		=50,	// Write Z


	// OUTPUTS FROM SUBSYSTEM A; USED AS INPUTS TO SUBSYSTEM B ONLY;
	// NOT USED OUTSIDE CPM
	RSC		=51,	// Read special and central (output to B only, not outside CPM)
	WSC		=52,	// Write special and central (output to B only, not outside CPM)
	WG		=53,	// Write G (output to B only, not outside CPM)

	// OUTPUTS FROM SUBSYSTEM A; USED AS INPUTS TO SUBSYSTEM C ONLY;
	// NOT USED OUTSIDE CPM
	SDV1	=54,	// Subsequence DV1 is currently active
	SMP1	=55,	// Subsequence MP1 is currently active
	SRSM3	=56,	// Subsequence RSM3 is currently active

	// EXTERNAL OUTPUTS FROM SUBSYSTEM B
	//
	RA0		=57,	// Read register at address 0 (A)
	RA1		=58,	// Read register at address 1 (Q)
	RA2		=59,	// Read register at address 2 (Z)
	RA3		=60,	// Read register at address 3 (LP)
	RA4		=61,	// Read register at address 4
	RA5		=62,	// Read register at address 5
	RA6		=63,	// Read register at address 6
	RA7		=64,	// Read register at address 7
	RA10	=65,	// Read register at address 10 (octal)
	RA11	=66,	// Read register at address 11 (octal)
	RA12	=67,	// Read register at address 12 (octal)
	RA13	=68,	// Read register at address 13 (octal)
	RA14	=69,	// Read register at address 14 (octal)
	RBK		=70,	// Read BNK
	WA0		=71,	// Write register at address 0 (A)
	WA1		=72,	// Write register at address 1 (Q)
	WA2		=73,	// Write register at address 2 (Z)
	WA3		=74,	// Write register at address 3 (LP)
	WA10	=75,	// Write register at address 10 (octal)
	WA11	=76,	// Write register at address 11 (octal)
	WA12	=77,	// Write register at address 12 (octal)
	WA13	=78,	// Write register at address 13 (octal)
	WA14	=79,	// Write register at address 14 (octal)
	WBK		=80,	// Write BNK
	WGn		=81,	// Write G (normal gates)**
	W20		=82,	// Write into CYR
	W21		=83,	// Write into SR
	W22		=84,	// Write into CYL
	W23		=85,	// Write into SL


	// THESE ARE THE LEFTOVERS -- THEY'RE PROBABLY USED IN SUBSYSTEM C
	//
	GENRST	=86,	// General Reset**
	CLINH	=87,	// Clear INHINT**
	CLINH1	=88,	// Clear INHINT1**
	CLSTA	=89,	// Clear state counter A (STA)**
	CLSTB	=90,	// Clear state counter B (STB)**
	CLISQ	=91,	// Clear SNI**
	CLRP	=92,	// Clear RPCELL**
	INH		=93,	// Set INHINT**
	RPT		=94,	// Read RUPT opcode **
	SBWG	=95,	// Write G from memory
	SETSTB	=96,	// Set the ST1 bit of STB
	WE		=97,	// Write E-MEM from G
	WPCTR	=98,	// Write PCTR (latch priority counter sequence)**
	WSQ		=99,	// Write SQ
	WSTB	=100,	// Write stage counter B (STB)**
	R2000	=101,	// Read 2000 **
};

static cpType glbl_cp[MAXPULSES]; // current set of asserted control pulses (MAXPULSES)

enum scType { // identifies subsequence for a given instruction
	SUB0=0,		// ST2=0, ST1=0
	SUB1=1,		// ST2=0, ST1=1
	SUB2=2,		// ST2=1, ST1=0
	SUB3=3		// ST2=1, ST1=1
};

enum brType {
	BR00	=0,	// BR1=0, BR2=0
	BR01	=1,	// BR1=0, BR2=1
	BR10	=2,	// BR1=1, BR2=0
	BR11	=3,	// BR1=1, BR2=1
	NO_BR	=4	// NO BRANCH
};

struct controlSubStep {
	brType br; // normally no branch (NO_BR)
	cpType pulse[MAX_IPULSES]; // contains 0 - MAXPULSES control pulses
};

struct controlStep {
	controlSubStep substep[4]; // indexed by brType (BR00, BR01, BR10, BR11)
};

struct subsequence {
	controlStep tp[11]; // indexed by tpType (TP1-TP11)
};

struct sequence {
	subsequence* subseq[4]; // indexed by scType
};

#define STEP_INACTIVE \
	NO_BR,	{NO_PULSE, NO_PULSE, NO_PULSE, NO_PULSE, NO_PULSE}, \
	NO_BR,	{NO_PULSE, NO_PULSE, NO_PULSE, NO_PULSE, NO_PULSE}, \
	NO_BR,	{NO_PULSE, NO_PULSE, NO_PULSE, NO_PULSE, NO_PULSE}, \
	NO_BR,	{NO_PULSE, NO_PULSE, NO_PULSE, NO_PULSE, NO_PULSE}

#define STEP(p1, p2, p3, p4, p5) \
	NO_BR,	{ p1, p2, p3, p4, p5}, \
	NO_BR,	{NO_PULSE, NO_PULSE, NO_PULSE, NO_PULSE, NO_PULSE}, \
	NO_BR,	{NO_PULSE, NO_PULSE, NO_PULSE, NO_PULSE, NO_PULSE}, \
	NO_BR,	{NO_PULSE, NO_PULSE, NO_PULSE, NO_PULSE, NO_PULSE}

subsequence SUB_TC0 = {
	STEP (	RB,		WY,			WS,			CI,			NO_PULSE	), // TP 1
	STEP_INACTIVE, // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP (	RA,		WOVI,		NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 4
	STEP_INACTIVE, // TP 5
	STEP_INACTIVE, // TP 6
	STEP (	RG,		RSC,		WB,			WP,			NO_PULSE	), // TP 7
	STEP (	RZ,		WQ,			GP,			TP,			NO_PULSE	), // TP 8
	STEP (	RB,		WSC,		WG,			NO_PULSE,	NO_PULSE	), // TP 9
	STEP (	RU,		WZ,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 10
	STEP (	NISQ,	NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 11
};

subsequence SUB_CCS0 = {		
	STEP (	RB,		WS,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP (	RZ,		WY,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP_INACTIVE, // TP 4
	STEP_INACTIVE, // TP 5
	STEP (	RG,		RSC,		WB,			TSGN,		WP			), // TP 6
	BR00,	RC,		TMZ,		NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 7
	BR01,	RC,		TMZ,		NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR10,	RB,		TMZ,		NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR11,	RB,		TMZ,		NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR00,	GP,		TP,			NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 8
	BR01,	R1,		WX,			GP,			TP,			NO_PULSE,
	BR10,	R2,		WX,			GP,			TP,			NO_PULSE,
	BR11,	R1,		R2,			WX,			GP,			TP,
	STEP (	RB,		WSC,		WG,			NO_PULSE,	NO_PULSE	), // TP 9
	BR00,	RC,		WA,			NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 10
	BR01,	WA,		R1C,		NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR10,	RB,		WA,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR11,	WA,		R1C,		NO_PULSE,	NO_PULSE,	NO_PULSE,
	STEP (	RU,		ST1,		WZ,			NO_PULSE,	NO_PULSE	) // TP 11
};

subsequence SUB_CCS1 = {		
	STEP (	RZ,		WY,			WS,			CI,			NO_PULSE	), // TP 1
	STEP_INACTIVE, // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP (	RU,		WZ,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 4
	STEP (	RA,		WY,			CI,			NO_PULSE,	NO_PULSE	), // TP 5
	STEP_INACTIVE, // TP 6
	STEP (	RG,		RSC,		WB,			WP,			NO_PULSE	), // TP 7
	STEP (	RU,		WB,			GP,			TP,			NO_PULSE	), // TP 8
	STEP_INACTIVE, // TP 9
	STEP (	RC,		WA,			WOVI,		NO_PULSE,	NO_PULSE	), // TP 10
	STEP (	RG,		RSC,		WB,			NISQ,		NO_PULSE	)  // TP 11
};

subsequence SUB_NDX0 = {		
	STEP (	RB,		WS,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP_INACTIVE, // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP (	RA,		WOVI,		NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 4
	STEP_INACTIVE, // TP 5
	STEP_INACTIVE, // TP 6
	STEP (	RG,		RSC,		WB,			WP,			NO_PULSE	), // TP 7
	STEP (	GP,		TP,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 8
	STEP (	RB,		WSC,		WG,			NO_PULSE,	NO_PULSE	), // TP 9
	STEP (	TRSM,	NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 10
	STEP (	ST1,	NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 11
};

subsequence SUB_NDX1 = {		
	STEP (	RZ,		WY,			WS,			CI,			NO_PULSE	), // TP 1
	STEP_INACTIVE, // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP (	RU,		WZ,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 4
	STEP_INACTIVE, // TP 5
	STEP (	RB,		WY,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 6
	STEP (	RG,		RSC,		WB,			WP,			NO_PULSE	), // TP 7
	STEP (	RB,		WX,			GP,			TP,			NO_PULSE	), // TP 8
	STEP (	RB,		WSC,		WG,			NO_PULSE,	NO_PULSE	), // TP 9
	STEP_INACTIVE, // TP 10
	STEP (	RU,		WB,			WOVI,		NISQ,		NO_PULSE	), // TP 11
};

subsequence SUB_RSM3 = {
	STEP (	R24,	WS,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP_INACTIVE, // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP_INACTIVE, // TP 4
	STEP_INACTIVE, // TP 5
	STEP_INACTIVE, // TP 6
	STEP (	RG,		WZ,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 7
	STEP_INACTIVE, // TP 8
	STEP_INACTIVE, // TP 9
	STEP_INACTIVE, // TP 10
	STEP (	NISQ,	NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 11
};

subsequence SUB_XCH0 = {		
	STEP (	RB,		WS,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP (	RA,		WP,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP (	WP2,	NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 4
	STEP_INACTIVE, // TP 5
	STEP_INACTIVE, // TP 6
	STEP (	RG,		RSC,		WB,			WP,			NO_PULSE	), // TP 7
	STEP (	GP,		TP,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 8
	STEP (	RA,		WSC,		WG,			RP2,		NO_PULSE	), // TP 9
	STEP (	RB,		WA,			WOVI,		NO_PULSE,	NO_PULSE	), // TP 10
	STEP (	ST2,	NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 11
};

subsequence SUB_CS0 = {		
	STEP (	RB,		WS,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP_INACTIVE, // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP_INACTIVE, // TP 4
	STEP_INACTIVE, // TP 5
	STEP_INACTIVE, // TP 6
	STEP (	RG,		RSC,		WB,			WP,			NO_PULSE	), // TP 7
	STEP (	GP,		TP,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 8
	STEP (	RB,		WSC,		WG,			NO_PULSE,	NO_PULSE	), // TP 9
	STEP (	RC,		WA,			WOVI,		NO_PULSE,	NO_PULSE	), // TP 10
	STEP (	ST2,	NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 11
};

subsequence SUB_TS0 = {		
	STEP (	RB,		WS,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP (	RA,		WB,			TOV,		WP,			NO_PULSE	), // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	BR00,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 4
	BR01,	RZ,		WY,			CI,			NO_PULSE,	NO_PULSE,	   // overflow
	BR10,	RZ,		WY,			CI,			NO_PULSE,	NO_PULSE,	   // underflow
	BR11,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR00,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 5
	BR01,	R1,		WA,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR10,	WA,		R1C,		NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR11,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,
	STEP_INACTIVE, // TP 6
	BR00,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 7
	BR01,	RU,		WZ,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR10,	RU,		WZ,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR11,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,
	STEP (	GP,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 8
	STEP (	RB,		WSC,		WG,			NO_PULSE,	NO_PULSE	), // TP 9
	STEP (	RA,		WOVI,		NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 10
	STEP (	ST2,	NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 11
};

subsequence SUB_AD0 = {		
	STEP (	RB,		WS,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP (	RA,		WY,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP_INACTIVE, // TP 4
	STEP_INACTIVE, // TP 5
	STEP_INACTIVE, // TP 6
	STEP (	RG,		RSC,		WB,			WP,			NO_PULSE	), // TP 7
	STEP (	RB,		WX,			GP,			TP,			NO_PULSE	), // TP 8
	STEP (	RB,		WSC,		WG,			NO_PULSE,	NO_PULSE	), // TP 9
	STEP_INACTIVE, // TP 10
	STEP (	RU,		WA,			WOVC,		ST2,		WOVI		), // TP 11
};

//---------------------------------------------------------------------------
// Note: AND is performed using DeMorgan's Theorem: the inputs are inverted, a
// logical OR is performed, and the result is inverted. The implementation of the
// OR (at TP8) is somewhat unorthodox: the inverted inputs are in registers U
// and C. The OR is achieved by gating both registers onto the read/write bus
// simultaneously. (The bus only transfers logical 1's; register-to-register transfers
// are performed by clearing the destination register and then transferring the
// 1's from the source register to the destination). When the 1's from both
// registers are simultaneously gated onto the bus, the word on the bus is a logical
// OR of both registers.
//---------------------------------------------------------------------------
subsequence SUB_MASK0 = {
	STEP (	RB,		WS,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP (	RA,		WB,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP (	RC,		WY,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 4
	STEP_INACTIVE, // TP 5
	STEP_INACTIVE, // TP 6
	STEP (	RG,		RSC,		WB,			WP,			NO_PULSE	), // TP 7
	STEP (	RU,		RC,			WA,			GP,			TP			), // TP 8  (CHANGED)
	STEP_INACTIVE, // TP 9
	STEP (	RA,		WB,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 10 (CHANGED)
	STEP (	RC,		WA,			ST2,		WOVI,		NO_PULSE	), // TP 11
};

subsequence SUB_MP0 = {
	STEP (	RB,		WS,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP (	RA,		WB,			TSGN,		NO_PULSE,	NO_PULSE	), // TP 2
	STEP (	RSC,	WG,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	BR00,	RB,		WLP,		NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 4
	BR01,	RB,		WLP,		NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR10,	RC,		WLP,		NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR11,	RC,		WLP,		NO_PULSE,	NO_PULSE,	NO_PULSE,
	STEP (	RLP,	WA,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 5
	STEP_INACTIVE, // TP 6
	BR00,	RG,		WY,			WP,			NO_PULSE,	NO_PULSE,	   // TP 7
	BR01,	RG,		WY,			WP,			NO_PULSE,	NO_PULSE,
	BR10,	RG,		WB,			WP,			NO_PULSE,	NO_PULSE,
	BR11,	RG,		WB,			WP,			NO_PULSE,	NO_PULSE,
	BR00,	GP,		TP,			NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 8
	BR01,	GP,		TP,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR10,	RC,		WY,			GP,			TP,			NO_PULSE,
	BR11,	RC,		WY,			GP,			TP,			NO_PULSE,
	STEP (	RU,		WB,			TSGN2,		NO_PULSE,	NO_PULSE	), // TP 9
	BR00,	RA,		WLP,		TSGN,		NO_PULSE,	NO_PULSE,	   // TP 10
	BR01,	RA,		RB14,		WLP,		TSGN,		NO_PULSE,
	BR10,	RA,		WLP,		TSGN,		NO_PULSE,	NO_PULSE,
	BR11,	RA,		RB14,		WLP,		TSGN,		NO_PULSE,
	BR00,	ST1,	WALP,		NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 11
	BR01,	R1,		ST1,		WALP,		R1C,		NO_PULSE,
	BR10,	RU,		ST1,		WALP,		NO_PULSE,	NO_PULSE,
	BR11,	RU,		ST1,		WALP,		NO_PULSE,	NO_PULSE,
};

subsequence SUB_MP1 = {		
	STEP (	RA,		WY,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP (	RLP,	WA,			TSGN,		NO_PULSE,	NO_PULSE	), // TP 2
	BR00,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 3
	BR01,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR10,	RB,		WX,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR11,	RB,		WX,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	STEP (	RA,		WLP,		NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 4
	STEP (	RLP,	TSGN,		NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 5
	STEP (	RU,		WALP,		NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 6
	STEP (	RA,		WY,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 7
	BR00,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 8
	BR01,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR10,	RB,		WX,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR11,	RB,		WX,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	STEP (	RLP,	WA,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 9
	STEP (	RA,		WLP,		CTR,		NO_PULSE,	NO_PULSE	), // TP 10
	STEP (	RU,		ST1,		WALP,		NO_PULSE,	NO_PULSE	), // TP 11
};

subsequence SUB_MP3 = {		
	STEP (	RZ,		WY,			WS,			CI,			NO_PULSE	), // TP 1
	STEP (	RLP,	TSGN,		NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP (	RU,		WZ,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 4
	STEP (	RA,		WY,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 5
	BR00,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 6
	BR01,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR10,	RB,		WX,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR11,	RB,		WX,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	STEP (	RG,		RSC,		WB,			WP,			NO_PULSE	), // TP 7
	STEP (	RLP,	WA,			GP,			TP,			NO_PULSE	), // TP 8
	STEP (	RB,		WSC,		WG,			NO_PULSE,	NO_PULSE	), // TP 9
	STEP (	RA,		WLP,		NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 10
	STEP (	RU,		WALP,		NISQ,		NO_PULSE,	NO_PULSE	), // TP 11
};

subsequence SUB_DV0 = {		
	STEP (	RB,		WS,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP (	RA,		WB,			TSGN,		NO_PULSE,	NO_PULSE	), // TP 2
	STEP (	RSC,	WG,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	BR00,	RC,		WA,			NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 4
	BR01,	RC,		WA,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR10,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR11,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR00,	R1,		WLP,		NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 5
	BR01,	R1,		WLP,		NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR10,	R2,		WLP,		NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR11,	R2,		WLP,		NO_PULSE,	NO_PULSE,	NO_PULSE,
	STEP (	RA,		WQ,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 6
	STEP (	RG,		WB,			TSGN,		WP,			NO_PULSE	), // TP 7
	STEP (	RB,		WA,			GP,			TP,			NO_PULSE	), // TP 8
	BR00,	RLP,	R2,			WB,			NO_PULSE,	NO_PULSE,	   // TP 9
	BR01,	RLP,	R2,			WB,			NO_PULSE,	NO_PULSE,
	BR10,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR11,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR00,	RB,		WLP,		NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 10
	BR01,	RB,		WLP,		NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR10,	RC,		WA,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR11,	RC,		WA,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	STEP (	R1,		ST1,		WB,			NO_PULSE,	NO_PULSE	), // TP 11
};

subsequence SUB_DV1 = {		
	STEP (	R22,	WS,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP (	RQ,		WG,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 2
	STEP (	RG,		WQ,			WY,			RSB,		NO_PULSE	), // TP 3
	STEP (	RA,		WX,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 4
	STEP (	RLP,	TSGN2,		NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 5
	STEP_INACTIVE, // TP 6
	STEP (	RU,		TSGN,		NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 7
	BR00,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 8
	BR01,	NO_PULSE,NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR10,	RU,		WQ,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR11,	RU,		WQ,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR00,	RB,		RSB,		WG,			NO_PULSE,	NO_PULSE,	   // TP 9
	BR01,	RB,		RSB,		WG,			NO_PULSE,	NO_PULSE,
	BR10,	RB,		WG,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR11,	RB,		WG,			NO_PULSE,	NO_PULSE,	NO_PULSE,
	STEP (	RG,		WB,			TSGN,		NO_PULSE,	NO_PULSE	), // TP 10
	BR00,	ST1,	NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,	   // TP 11
	BR01,	ST1,	NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE,
	BR10,	RC,		WA,			ST2,		NO_PULSE,	NO_PULSE,
	BR11,	RB,		WA,			ST2,		NO_PULSE,	NO_PULSE,
};

subsequence SUB_SU0 = {		
	STEP (	RB,		WS,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP (	RA,		WY,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP_INACTIVE, // TP 4
	STEP_INACTIVE, // TP 5
	STEP_INACTIVE, // TP 6
	STEP (	RG,		RSC,		WB,			WP,			NO_PULSE	), // TP 7
	STEP (	RC,		WX,			GP,			TP,			NO_PULSE	), // TP 8
	STEP (	RB,		WSC,		WG,			NO_PULSE,	NO_PULSE	), // TP 9
	STEP_INACTIVE, // TP 10
	STEP (	RU,		WA,			WOVC,		ST2,		WOVI		), // TP 11
};

subsequence SUB_RUPT1 = {		
	STEP (	R24,	WY,			WS,			CI,			NO_PULSE	), // TP 1
	STEP_INACTIVE, // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP_INACTIVE, // TP 4
	STEP_INACTIVE, // TP 5
	STEP_INACTIVE, // TP 6
	STEP_INACTIVE, // TP 7
	STEP_INACTIVE, // TP 8
	STEP (	RZ,		WG,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 9
	STEP (	RU,		WZ,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 10
	STEP (	ST1,	ST2,		NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 11
};

subsequence SUB_RUPT3 = {		
	STEP (	RZ,		WS,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP (	RRPA,	WZ,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 2
	STEP (	RZ,		KRPT,		WG,			NO_PULSE,	NO_PULSE	), // TP 3
	STEP_INACTIVE, // TP 4
	STEP_INACTIVE, // TP 5
	STEP_INACTIVE, // TP 6
	STEP_INACTIVE, // TP 7
	STEP_INACTIVE, // TP 8
	STEP (	RB,		WSC,		WG,			NO_PULSE,	NO_PULSE	), // TP 9
	STEP_INACTIVE, // TP 10
	STEP (	ST2,	NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 11
};

subsequence SUB_STD2 = {		
	STEP (	RZ,		WY,			WS,			CI,			NO_PULSE	), // TP 1
	STEP_INACTIVE, // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP (	RU,		WZ,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 4
	STEP_INACTIVE, // TP 5
	STEP_INACTIVE, // TP 6
	STEP (	RG,		RSC,		WB,			WP,			NO_PULSE	), // TP 7
	STEP (	GP,		TP,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 8
	STEP (	RB,		WSC,		WG,			NO_PULSE,	NO_PULSE	), // TP 9
	STEP_INACTIVE, // TP 10
	STEP (	NISQ,	NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 11
};

subsequence SUB_PINC = {		
	STEP (	WS,		RSCT,		NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP_INACTIVE, // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP (	R1,		WY,			NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 4
	STEP_INACTIVE, // TP 5
	STEP (	RG,		WX,			WP,			NO_PULSE,	NO_PULSE	), // TP 6
	STEP (	TP,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 7
	STEP (	WP,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 8
	STEP (	RU,		CLG,		WPx,		NO_PULSE,	NO_PULSE	), // TP 9
	STEP (	RU,		WGx,		WOVR,		NO_PULSE,	NO_PULSE	), // TP 10
	STEP_INACTIVE, // TP 11
};

subsequence SUB_MINC = {		
	STEP (	WS,		RSCT,		NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP_INACTIVE, // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP (	WY,		R1C,		NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 4
	STEP_INACTIVE, // TP 5
	STEP (	RG,		WX,			WP,			NO_PULSE,	NO_PULSE	), // TP 6
	STEP (	TP,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 7
	STEP (	WP,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 8
	STEP (	RU,		CLG,		WPx,		NO_PULSE,	NO_PULSE	), // TP 9
	STEP (	RU,		WGx,		WOVR,		NO_PULSE,	NO_PULSE	), // TP 10
	STEP_INACTIVE, // TP 11
};

subsequence SUB_SHINC = {
	STEP (	WS,		RSCT,		NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 1
	STEP_INACTIVE, // TP 2
	STEP (	WG,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 3
	STEP (	WY,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 4
	STEP_INACTIVE, // TP 5
	STEP (	RG,		WYx,		WX,			WP,			NO_PULSE	), // TP 6
	STEP (	TP,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 7
	STEP (	WP,		NO_PULSE,	NO_PULSE,	NO_PULSE,	NO_PULSE	), // TP 8
	STEP (	RU,		CLG,		WPx,		NO_PULSE,	NO_PULSE	), // TP 9
	STEP (	RU,		WGx,		WOVR,		NO_PULSE,	NO_PULSE	), // TP 10
	STEP_INACTIVE, // TP 11
};

char* subseqString[] =  {
	"TC0",
	"CCS0",
	"CCS1",
	"NDX0",
	"NDX1",
	"RSM3",
	"XCH0",
	"CS0",
	"TS0",
	"AD0",
	"MASK0",
	"MP0",
	"MP1",
	"MP3",
	"DV0",
	"DV1",
	"SU0",
	"RUPT1",
	"RUPT3",
	"STD2",
	"PINC0",
	"MINC0",
	"SHINC0",
	"NO_SEQ"
};

enum subseq {
	TC0		=0,
	CCS0	=1,
	CCS1	=2,
	NDX0	=3,
	NDX1	=4,
	RSM3	=5,
	XCH0	=6,
	CS0		=7,
	TS0		=8,
	AD0		=9,
	MASK0	=10,
	MP0		=11,
	MP1		=12,
	MP3		=13,
	DV0		=14,
	DV1		=15,
	SU0		=16,
	RUPT1	=17,
	RUPT3	=18,
	STD2	=19,
	PINC0	=20,
	MINC0	=21,
	SHINC0	=22,
	NO_SEQ	=23
};

enum tpType {
	STBY		=0,
	PWRON		=1,
	TP1			=2,		// TIME PULSE 1: start of memory cycle time (MCT)
	TP2			=3,
	TP3			=4,
	TP4			=5,
	TP5			=6,
	TP6			=7,		// EMEM is available in G register by TP6
	TP7			=8,		// FMEM is available in G register by TP7
	TP8			=9,
	TP9			=10,
	TP10		=11,	// G register written to memory beginning at TP10
	TP11		=12,	// TIME PULSE 11: end of memory cycle time (MCT)
	TP12		=13,	// select new subsequence/select new instruction
	SRLSE		=14,	// step switch release
	WAIT		=15
};

//---------------------------------------------------------------------------
// Combinational logic decodes instruction and the stage count
// to get the instruction subsequence.
//---------------------------------------------------------------------------
subseq instructionSubsequenceDecoder(int SB2_field, int SB1_field, int SQ_field, int STB_field)
{
	static subseq decode[16][4] = {
		{	TC0,		RUPT1,		STD2,		RUPT3	}, // 00
		{	CCS0,		CCS1,		NO_SEQ,		NO_SEQ	}, // 01
		{	NDX0,		NDX1,		NO_SEQ,		RSM3	}, // 02
		{	XCH0,		NO_SEQ,		STD2,		NO_SEQ	}, // 03

		{	NO_SEQ,		NO_SEQ,		NO_SEQ,		NO_SEQ	}, // 04
		{	NO_SEQ,		NO_SEQ,		NO_SEQ,		NO_SEQ	}, // 05
		{	NO_SEQ,		NO_SEQ,		NO_SEQ,		NO_SEQ	}, // 06
		{	NO_SEQ,		NO_SEQ,		NO_SEQ,		NO_SEQ	}, // 07
		{	NO_SEQ,		NO_SEQ,		NO_SEQ,		NO_SEQ	}, // 10

		{	MP0,		MP1,		NO_SEQ,		MP3		}, // 11
		{	DV0,		DV1,		STD2,		NO_SEQ	}, // 12
		{	SU0,		NO_SEQ,		STD2,		NO_SEQ	}, // 13

		{	CS0,		NO_SEQ,		STD2,		NO_SEQ	}, // 14
		{	TS0,		NO_SEQ,		STD2,		NO_SEQ	}, // 15
		{	AD0,		NO_SEQ,		STD2,		NO_SEQ	}, // 16
		{	MASK0,		NO_SEQ,		STD2,		NO_SEQ	}  // 17

	};

	if(SB2_field == 0 && SB1_field == 1)      return PINC0;
	else if(SB2_field == 1 && SB1_field == 0) return MINC0;
	else                                      return decode[SQ_field][STB_field];
}
//---------------------------------------------------------------------------
void clearControlPulses()
{
	for(unsigned i=0; i<MAXPULSES; i++)
		glbl_cp[i] = NO_PULSE;
}
//---------------------------------------------------------------------------
void assert(cpType* pulse)
{
	int j = 0;
	for(unsigned  i= 0; i < MAXPULSES && j < MAX_IPULSES && pulse[j] != NO_PULSE; i++) {
		if(glbl_cp[i] == NO_PULSE) {
			glbl_cp[i] = pulse[j];
			j++;
		}
	}
}
//---------------------------------------------------------------------------
void assert(cpType pulse)
{
	for(unsigned i = 0; i < MAXPULSES; i++) {
		if(glbl_cp[i] == NO_PULSE) {
			glbl_cp[i] = pulse;
			break;
		}
	}
}
//---------------------------------------------------------------------------
void get_CPM_A(int CPM_A_address)
{
	// EPROM address bits (bit 1 is LSB)
	//  1:		register BR2
	//  2:		register BR1
	//  3-6:	register SG (4)
	//  7,8:	register STB (2)
	//  9-12:	register SQ (4)
	//  13:		STB_01
	//	14:		STB_02

    //-----------------------------------------------------------------------
	// EPROM emulator
    //-----------------------------------------------------------------------
	int SB2_field = (CPM_A_address >> 13) & 0x1;
	int SB1_field = (CPM_A_address >> 12) & 0x1;
	int SQ_field  = (CPM_A_address >> 8)  & 0xf;
	int STB_field = (CPM_A_address >> 6)  & 0x3;
	int SG_field  = (CPM_A_address >> 2)  & 0xf;
	int BR1_field = (CPM_A_address >> 1)  & 0x1;
	int BR2_field = (CPM_A_address     )  & 0x1;
 
	// Decode the current instruction subsequence (glbl_subseq).
	subseq glbl_subseq = instructionSubsequenceDecoder(SB2_field, SB1_field, SQ_field, STB_field);

	static subsequence* subsp[] =  {
		&SUB_TC0,	&SUB_CCS0,	&SUB_CCS1,	&SUB_NDX0,	&SUB_NDX1,	&SUB_RSM3,	
		&SUB_XCH0,	&SUB_CS0,	&SUB_TS0,	&SUB_AD0,	&SUB_MASK0,	&SUB_MP0,	
		&SUB_MP1,	&SUB_MP3,	&SUB_DV0,	&SUB_DV1,	&SUB_SU0,	&SUB_RUPT1,	
		&SUB_RUPT3,	&SUB_STD2,	&SUB_PINC,	&SUB_MINC,	&SUB_SHINC,0
	};

	clearControlPulses();   	// Clear old control pulses.

	// Get new control pulses for the current instruction subsequence.
	if(glbl_subseq != NO_SEQ && SG_field >= TP1 && SG_field <= TP11) {
		subsequence* subseqP = subsp[glbl_subseq];
		if(subseqP) {    // index t-2 because TP1=2, but array is indexed from zero
			controlStep& csref = subseqP->tp[SG_field-2];

			brType b = (brType) ((BR1_field << 1) | BR2_field);
			controlSubStep& cssref = csref.substep[b];
			if(cssref.br == NO_BR) cssref = csref.substep[0];

			cpType* p = cssref.pulse;
			assert(p);
		}
	}

	// Implement these here, because the instruction sequence decoder
	// function is buried in the CPM-A ROM and so, identification of
	// the sequences is not available outside CPM-A. CPM-C needs info
	// on these 3 sequences.
	switch(glbl_subseq) {
	    case DV1:	assert(SDV1); break;
	    case MP1:	assert(SMP1); break;
	    case RSM3:	assert(SRSM3); break;
	}
}
//---------------------------------------------------------------------------
char* cpTypeString[] = {
	"NO_PULSE",

	// OUTPUTS FROM SUBSYSTEM A
	"CI", "CLG", "CLCTR", "CTR", "GP", "KRPT", "NISQ", "RA", "RB",
	"RB14", "RC", "RG", "RLP", "RP2", "RQ", "RRPA", "RSB", "RSCT", 
	"RU", "RZ", "R1", "R1C", "R2", "R22", "R24", "ST1", "ST2", "TMZ", 
	"TOV", "TP", "TRSM", "TSGN", "TSGN2", "WA", "WALP", "WB", "WGx", 
	"WLP", "WOVC", "WOVI", "WOVR", "WP", "WPx", "WP2", "WQ", "WS", 
	"WX", "WY", "WYx", "WZ",

	// OUTPUTS FROM SUBSYSTEM A; USED AS INPUTS TO SUBSYSTEM B ONLY;
	// NOT USED OUTSIDE CPM
	//
	"RSC", "WSC", "WG",

	// OUTPUTS FROM SUBSYSTEM A; USED AS INPUTS TO SUBSYSTEM C ONLY;
	// NOT USED OUTSIDE CPM
	//
	"SDV1", "SMP1", "SRSM3",

	// EXTERNAL OUTPUTS FROM SUBSYSTEM B
	//
	"RA0", "RA1", "RA2", "RA3", "RA4", "RA5", "RA6", "RA7", "RA10", "RA11", 
	"RA12", "RA13", "RA14", "RBK", "WA0", "WA1", "WA2", "WA3", "WA10", 
	"WA11", "WA12", "WA13", "WA14", "WBK", "WGn", "W20", "W21", "W22", "W23",

	// THESE ARE THE LEFTOVERS -- THEY'RE PROBABLY USED IN SUBSYSTEM C
	//
	"GENRST", "CLINH", "CLINH1", "CLSTA", "CLSTB", "CLISQ", "CLRP", "INH", 
	"RPT", "SBWG", "SETSTB", "WE", "WPCTR", "WSQ", "WSTB", "R2000"
};

//---------------------------------------------------------------------------
// for debug purposes only
//---------------------------------------------------------------------------
char* printControlPulses()
{
	static char buf[MAXPULSES*6];
	strcpy(buf,"");

	for(unsigned i=0; i<MAXPULSES && glbl_cp[i] != NO_PULSE; i++) {
		strcat(buf, cpTypeString[glbl_cp[i]]);
		strcat(buf," ");
	}
	return buf;
}

//---------------------------------------------------------------------------
// return the EPROM word corresponding to the pulses in glbl_cp.
//---------------------------------------------------------------------------
unsigned writeEPROM(int lowBit)
{
	unsigned EPROMword = 0x00; // no pulses; default
	for(unsigned i=0; i<MAXPULSES && glbl_cp[i] != NO_PULSE; i++) {
		int pulse = glbl_cp[i] - lowBit;
		if(pulse < 0 || pulse > 7) continue; // pulse is not in this EPROM
		EPROMword |= 0x01 << pulse;
	}

	// The CPM-A control signals are negative logic, so we need to
	// bit-flip the word. No signal is a 1, and an asserted signal is
	// a 0:
	return ((~EPROMword) & 0xff);
}

//---------------------------------------------------------------------------
const unsigned agcMemSize = 0x3fff+1; // # of cells in a 16-bit address range

void __fastcall TForm1::writeEPROMdata(FILE* fpObj, int lowBit)
{
	// Some parameters that control file format. You can change maxBytes
	// without affecting anything else. 'addressBytes' is determined by
	// the choosen S-Record format.
	const int maxBytes = 20;  // set limit on record length
	const int addressBytes = 3; // 24-bit address range
	const int sumCheckBytes = 1;

	const int maxdata = maxBytes - addressBytes - sumCheckBytes;

	int i=0; // current EPROM address
	int sumCheck = 0;
	while(i < agcMemSize) {
        // get dataByteCount; the number of bytes of EPROM data per record.
		int dataByteCount = maxdata;
		if(i + dataByteCount >= agcMemSize) {
			dataByteCount = agcMemSize - i;
		}
		// write record header (*** 3 byte address assumed ***)
		int totalByteCount = dataByteCount + addressBytes + sumCheckBytes;
		fprintf(fpObj, "S2%02X%06X", totalByteCount, i);
		sumCheck = totalByteCount & 0xff;
		sumCheck = (sumCheck + ((i & 0xff0000) >> 16)) % 256;
		sumCheck = (sumCheck + ((i & 0x00ff00) >>  8)) % 256;
		sumCheck = (sumCheck + ((i & 0x0000ff)      )) % 256;

		// write data bytes into record
		for(int j=0; j<dataByteCount; j++)  {
			get_CPM_A(i+j); // get CPM-A pulses for address i+j
            int data = writeEPROM(lowBit); // comvert pulses to EPROM format
			fprintf(fpObj, "%02X", data);
			sumCheck = (sumCheck + data) % 256;

		}
		// terminate record by adding the checksum and a newline.
		fprintf(fpObj, "%02X\n", (~sumCheck) & 0xff);

		i += dataByteCount;
	}
	// write an end-of-file record here
	i = 0; // use address zero for last record
	sumCheck  = 0x04; // byte count
	sumCheck = (sumCheck + ((i & 0xff0000) >> 16)) % 256;
	sumCheck = (sumCheck + ((i & 0x00ff00) >>  8)) % 256;
	sumCheck = (sumCheck + ((i & 0x0000ff)      )) % 256;
	fprintf(fpObj, "S804%06X%02X", i, (~sumCheck) & 0xff);
}

//---------------------------------------------------------------------------
void __fastcall TForm1::EPROMHexFile(char *filename, int lowBit)
{
	FILE* fpObj = fopen(filename, "w");
	if(!fpObj) {
		StatusBar1->SimpleText = "fopen failed for object file";
		exit(-1);
	}
	writeEPROMdata(fpObj, lowBit);  // pulses
	fclose(fpObj);
}

//---------------------------------------------------------------------------
void __fastcall TForm1::makeEPROMfiles(void)
{
    StatusBar1->SimpleText = "Writing EPROM files using S-Record format (s2f)";

    EPROMHexFile("CPM1_8.hex",    1);  // pulses  1 -  8
    EPROMHexFile("CPM9_16.hex",   9);  // pulses  9 - 16
	EPROMHexFile("CPM17_24.hex", 17);  // pulses 17 - 24
	EPROMHexFile("CPM25_32.hex", 25);  // pulses 25 - 32
	EPROMHexFile("CPM33_40.hex", 33);  // pulses 33 - 40
	EPROMHexFile("CPM41_48.hex", 41);  // pulses 41 - 48
	EPROMHexFile("CPM49_56.hex", 49);  // pulses 49 - 56
}

//---------------------------------------------------------------------------
// return the EPROM word corresponding to the pulses in glbl_cp.
//---------------------------------------------------------------------------
unsigned writeEPROM56(int lowBit)
{
	unsigned EPROMword = 0x00; // no pulses; default
	for(unsigned i=0; i<MAXPULSES && glbl_cp[i] != NO_PULSE; i++) {
		int pulse = glbl_cp[i] - lowBit;
		if(pulse < 0 || pulse > 7) continue; // pulse is not in this EPROM
		EPROMword |= 0x01 << pulse;
	}
	return ((~EPROMword) & 0xff);
}
//---------------------------------------------------------------------------
// Dump contents of CPM EPROM in HEX format for FPGA implementation of AGC
//---------------------------------------------------------------------------
void __fastcall TForm1::dumpEPROM(void)
{
	FILE *fpObj = fopen("CPM_dump.hex", "w");
	if(!fpObj) {
		StatusBar1->SimpleText = "fopen failed for object file";
		return;
	}
    byte data;
	int i=0; // current EPROM address
	while(i < agcMemSize) {
		get_CPM_A(i);                      // get CPM-A pulses for address
        data = writeEPROM56(49); fprintf(fpObj, "%02X", data); // pulses 49 - 56
        data = writeEPROM56(41); fprintf(fpObj, "%02X", data); // pulses 41 - 48
        data = writeEPROM56(33); fprintf(fpObj, "%02X", data); // pulses 33 - 40
        data = writeEPROM56(25); fprintf(fpObj, "%02X", data); // pulses 25 - 32
        data = writeEPROM56(17); fprintf(fpObj, "%02X", data); // pulses 17 - 24
        data = writeEPROM56( 9); fprintf(fpObj, "%02X", data); // pulses  9 - 16
        data = writeEPROM56( 1); fprintf(fpObj, "%02X", data); // pulses  1 -  8
		fprintf(fpObj, "\n");  // terminate record by adding a newline.
		i++;
	}
    fclose(fpObj);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::GenEPROMSButton1Click(TObject *Sender)
{
    StatusBar1->SimpleText = "Generating EPROM files.";
    makeEPROMfiles();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::DumpEPROMSButton1Click(TObject *Sender)
{
    StatusBar1->SimpleText = "Generating CMP Microcode dump";
    dumpEPROM();
    Memo1->Lines->LoadFromFile("CPM_dump.hex");
}
//---------------------------------------------------------------------------
// for debug purposes only
//---------------------------------------------------------------------------
void __fastcall TForm1::HexCPMButton1Click(TObject *Sender)
{
    StatusBar1->SimpleText = "Generating CMP big endian dump";
    TStringList *CPM = new TStringList();
	int cpma = 0;                    // current CPM address
	while(cpma < agcMemSize) {
		get_CPM_A(cpma);
        unsigned __int64 cp_data = 0xFFFFFFFFFFFFFF;    // no pulses by default
    	for(unsigned i = 0; i < MAXPULSES; i++) {
            if(glbl_cp[i] != NO_PULSE) {
    	    	unsigned __int64 pulse = (unsigned __int64)glbl_cp[i];
                unsigned __int64 one   = 1;  // This is needed so it will not degault to 32 bits
                cp_data &= ~(one << (pulse-1));
            }
    	}
        CPM->Add(IntToHex((__int64)cp_data,14));
		cpma++;
	}
    CPM->SaveToFile("CPM_hex.dat");
    delete CPM;
    Memo1->Lines->LoadFromFile("CPM_bigendian.dat");
}
//---------------------------------------------------------------------------
void __fastcall TForm1::BinaryButton1Click(TObject *Sender)
{
    char cpm[56];

    StatusBar1->SimpleText = "CMP binary dump";
    TStringList *CPMF = new TStringList();

	int cpma = 0;                    // current CPM address
	while(cpma < agcMemSize) {
        for(unsigned i =0; i < 56; i++) cpm[i] = '1'; // Set to all 1's
    	get_CPM_A(cpma);
    	for(unsigned i = 0; i < MAXPULSES; i++) {
	    	if(glbl_cp[i]) cpm[glbl_cp[i]-1] = '0';  // assert the bit
    	}
        AnsiString tmp;
        for(unsigned i = 0; i <56; i++) {
            tmp = tmp + AnsiString(cpm[55-i]);
        }
        CPMF->Add(tmp);
		cpma++;
	}
    CPMF->SaveToFile("CPM_binary.dat");
    delete CPMF;
    Memo1->Lines->LoadFromFile("CPM_binary.dat");
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ListButton1Click(TObject *Sender)
{
    StatusBar1->SimpleText = "CMP binary dump";
    TStringList *CPM_LIST = new TStringList();

	int cpma = 0;                    // current CPM address
	while(cpma < agcMemSize) {
    	get_CPM_A(cpma);
        AnsiString tmp  = IntToHex(cpma,4) + ": ";
        AnsiString tmp2 = "  (";
    	for(int i=0; i < MAXPULSES; i++) {
            if(glbl_cp[i] != NO_PULSE) {
                tmp  = tmp  + cpTypeString[glbl_cp[i]] + " ";
                tmp2 = tmp2 + glbl_cp[i] + ", ";
            }
	    }
        tmp = tmp + tmp2 + ")"; 
        CPM_LIST->Add(tmp);
		cpma++;
    }
    CPM_LIST->SaveToFile("CPM_LIST.TXT");
    delete CPM_LIST;
    Memo1->Lines->LoadFromFile("CPM_LIST.TXT");
}
//---------------------------------------------------------------------------

