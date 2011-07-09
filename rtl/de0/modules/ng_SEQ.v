// --------------------------------------------------------------------
// ng_SEQ.v - Sequence generator module 
// 
// Sequence generator module contains the stage registers and branch 
// registers that (along with the time pulse generator) control 
// execution of the microinstruction sequence.
// --------------------------------------------------------------------
`include "ControlPulses.h"
// --------------------------------------------------------------------
module ng_SEQ(
	input  						CLK2,				// Clock Pulse 2
	input   		[  5:0]		SELECT,			// Select Input
	input  		[100:0]		CP,				// Control Pulse
	input  		[ 15:0]		WRITE_BUS,		// Control Pulse
	output reg					SNI,				// SELECT NEXT INST 1=select next instruction (SNI register)
	output reg					STB_0,STB_1,	// STAGE REG where STB_1 is MSB, STB_0 is LSB
	output reg					BR1,BR2,			// BRANCH REG 1 where BR1 is MSB, BR2 is LSB
	output reg	[  3:0]		SQ,	  			// INST REG where SQ_3 is MSB, SQ_0 is LSB
	output 						LOOP6				// LOOPCNTR EQ 6 0=LOOPCNTR is holding the number 6.
);

// --------------------------------------------------------------------
// General Control Signals
// --------------------------------------------------------------------
wire	GENRST	= CP[`CPX(`GENRST)];			// General reset signal
wire	WSQ		= CP[`CPX(`WSQ)   ];			// Write SQ
wire	NISQ		= CP[`CPX(`NISQ)  ];			// New instruction to the SQ register
wire	CLISQ		= CP[`CPX(`CLISQ) ];			// Clear SNI
wire	ST1		= CP[`CPX(`ST1)   ];			// Stage 1
wire	ST2		= CP[`CPX(`ST2)   ];			// Stage 2
wire	TRSM		= CP[`CPX(`TRSM)  ];			// Test for resume
wire	CLSTA		= CP[`CPX(`CLSTA) ];			// Clear state counter A (STA)
wire	WSTB		= CP[`CPX(`WSTB)  ];			// Write stage counter B (STB)
wire	CLSTB		= CP[`CPX(`CLSTB) ];			// Clear state counter B
wire	SETSTB	= CP[`CPX(`SETSTB)];			// Set the ST1 bit of STB
wire	TSGN		= CP[`CPX(`TSGN)  ];			// Test sign
wire	TSGN2		= CP[`CPX(`TSGN2) ];			// Test sign 2
wire	TOV		= CP[`CPX(`TOV)   ];			// Test for overflow
wire	TMZ		= CP[`CPX(`TMZ)   ];			// Test for minus zero
wire	CTR		= CP[`CPX(`CTR)   ];			// Loop counter
wire	CLCTR		= CP[`CPX(`CLCTR) ];			// Clear loop counter
wire	EQU_25	= SELECT[`SLX(`EQU_25)];	// Equal to Octal 25 signal

// --------------------------------------------------------------------
// Select Next instruction Logic
// --------------------------------------------------------------------
reg SNI1;									// Instantiate internal SNI register
always@(posedge CLK2) 			
   if(!GENRST)     SNI1 <= 1'b0;		// Reset condition, clear register
   else if(!CLISQ) SNI1 <= 1'b0;		// Signal to clear register
	else if(!NISQ)  SNI1 <= 1'b1;		// Signal to set register

always@(negedge CLK2) SNI <= SNI1;	// Transfer to outputs on negative edge
	
// --------------------------------------------------------------------
// Branch Register Logic
// --------------------------------------------------------------------
wire SQ_MZ   = &WRITE_BUS;				// All 1's is minus zero in 1's compliment
wire  OVER   = WRITE_BUS[14];			// bit 14 set is overflow condition
wire  SIGN   = WRITE_BUS[15];			// bit 15 set is negative number

reg  [1:0] BR;								// instantiate internal Branch register

wire SQ_BR1J = !(!(!TSGN &  SIGN) & !(!TOV &  SIGN  & !OVER));
wire SQ_BR1K = !(!(!TSGN & !SIGN) & !(!TOV & !SIGN) & !(!TOV &  OVER));
always@(posedge CLK2) 
   if(!GENRST) BR[0] <= 1'b0;
   else        BR[0] <= ~BR[0] & SQ_BR1J | BR[0] & ~SQ_BR1K;
always@(negedge CLK2) BR1 <= BR[0];	// Transfer to outputs on negative edge

wire SQ_BR2J = !(!(!TSGN2 &  SIGN) & !(!TOV & !SIGN & OVER) & !(!TMZ &  SQ_MZ));
wire SQ_BR2K = !(!(!TSGN2 & !SIGN) & !(!TOV &  SIGN) & !(!TOV & !OVER) & !(!TMZ & !SQ_MZ));
always@(posedge CLK2)
   if(!GENRST) BR[1] <= 1'b0;
   else        BR[1] <= ~BR[1] & SQ_BR2J | BR[1] & ~SQ_BR2K;
always@(negedge CLK2) BR2 <= BR[1];	// Transfer to outputs on negative edge
	
// --------------------------------------------------------------------
// Stage Register Logic
// --------------------------------------------------------------------
reg [1:0] STA;									// instantiate stage A internal register
wire SET2 = !ST2 | (!TRSM & !EQU_25);	// Conditions to set bit 1
always@(posedge CLK2) begin				// Stage Register A behavior
   if(!GENRST) 		STA    <= 2'b00;	// clear the register
	else if(!CLSTA)	STA    <= 2'b00;	// clear the register
   else begin
		if(!ST1)			STA[0] <= 1'b1;	// set bit 0 
		if(SET2)			STA[1] <= 1'b1;	// set bit 1
	end
end
reg [1:0] STA_Q;								// instantiate stage A output register
always@(negedge CLK2) STA_Q <= STA;		// Transfer to outputs on negative edge

reg [1:0] STB;									// instantiate stage B internal register
always@(posedge CLK2) begin				// Stage Register B behavior
   if(!GENRST) 		STB 	 <= 2'b00;	// clear the register
	else if(!CLSTB)	STB 	 <= 2'b00;	// clear the register
	else if(!SETSTB)	STB	 <= 2'b01;	// set bit 0 and clear bit 1
   else if(!WSTB)		STB 	 <= STA_Q;	// Transfer stA to stB
end
	
always@(negedge CLK2) STB_0 <= STB[0];	// Transfer to outputs on negative edge
always@(negedge CLK2) STB_1 <= STB[1];	// Transfer to outputs on negative edge
	
// --------------------------------------------------------------------
// Seqence Counter Output Register
// --------------------------------------------------------------------
always @(posedge CLK2) 
   if(!GENRST) 	SQ <= 4'h0;
   else if(!WSQ)  SQ <= WRITE_BUS[15:12];

// --------------------------------------------------------------------
// Seqence Counter Logic, used to count to 6
// --------------------------------------------------------------------
reg [3:0] seq_cntr;											// Counter register 
always @(posedge CLK2) 
   if(!GENRST)     seq_cntr <= 4'h0;					// Clear register on reset
	else if(!CLCTR) seq_cntr <= 4'h0;					// Request load 0  
   else if(!CTR)   seq_cntr <= seq_cntr + 4'd1;		// Increment counter

assign LOOP6 = !(seq_cntr == 3'd6);						// Loop on 6

// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------
