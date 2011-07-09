// --------------------------------------------------------------------
// ng_ADR.v - Address decoding and Bank Register selection logic
// --------------------------------------------------------------------
`include "ControlPulses.h"
// --------------------------------------------------------------------
module ng_ADR(
	input  						CLK2,				// Clock Pulse 2
	input  		[ 15:0]		WRITE_BUS,		// Control Pulse
	input  		[100:0]		CP,				// Control Pulse
	output  		[  5:0]		SELECT,			// Select Input
	output  		[ 13:0]		ADDRESS,			// Address Input
	output 		[ 15:0]		ADR_BUS			// ADR Module Bank reg output
);

// --------------------------------------------------------------------
// JTAG Debugging Probes
// --------------------------------------------------------------------
//JTAG_Probe1	 Probe1_EQU_17(.probe( EQU_17  ));
//JTAG_Probe14 Probe1_ADDR  (.probe( ADDRESS ));

// --------------------------------------------------------------------
// Control pulse definitions
// --------------------------------------------------------------------
wire 	GENRST	= CP[`CPX(`GENRST)];				// General reset signal
wire  WBK      = CP[`CPX(`WBK)];					// Write BANK
wire  WS       = CP[`CPX(`WS)];					// Write S

// --------------------------------------------------------------------
// Register Storage
// --------------------------------------------------------------------
reg	[ 3:0]		BNK;		// BANK Register
reg	[11:0]		S;			// S Register

// --------------------------------------------------------------------
// Instantiate Register S Latch
// --------------------------------------------------------------------
always @(posedge CLK2) begin 				// on positive edge
	if(!GENRST)  S <= 12'h000; 			// Clear to 0
	else if(!WS) S <= WRITE_BUS[11:0]; 	// Load with bottom 12 bits 
end 

// --------------------------------------------------------------------
// Instantiate Register BNK Latch
// --------------------------------------------------------------------
always @(posedge CLK2) begin 					// on positive edge
	if(!GENRST)   BNK <= 4'h0; 				// Clear to 0
	else if(!WBK) BNK <= WRITE_BUS[13:10];	// Load with top 4 bits
end 

assign ADR_BUS = {2'b00, BNK, 10'h00};	// Place Bank reg on output bus

// --------------------------------------------------------------------
// Form up Address output
// --------------------------------------------------------------------
wire  Bnk_sel = !(!(BNK[3] | BNK[2]) | !(S[11] & S[10])); // 1=use BNK

wire [3:0] BANK    =  Bnk_sel ? BNK : {2'b00, S[11:10]};    // Mux

assign ADDRESS = {BANK, S[9:0]};

// --------------------------------------------------------------------
// Selection Logic
// --------------------------------------------------------------------
wire  GTR_1777	= !(ADDRESS >  14'o1777);	// Greater than Octal 1777
wire	GTR_17	= !(ADDRESS >  14'o0017);	// Greater than Octal 17
wire	GTR_27 	= !(ADDRESS >  14'o0027);	// Greater than Octal 27
wire	EQU_25	= !(ADDRESS == 14'o0025);	// Equal   to   Octal 25
wire	EQU_17	= !(ADDRESS == 14'o0017);	// Equal   to   Octal 17
wire  EQU_16	= !(ADDRESS == 14'o0016);	// Equal   to   Octal 16

// --------------------------------------------------------------------
// Selection definitions
// --------------------------------------------------------------------
assign SELECT[`SLX(`GTR_1777)] = GTR_1777;	// Greater than Octal 1777
assign SELECT[`SLX(`GTR_17)  ] = GTR_17;		// Greater than Octal 17
assign SELECT[`SLX(`GTR_27)  ] = GTR_27;		// Greater than Octal 27
assign SELECT[`SLX(`EQU_25)  ] = EQU_25;		// Equal   to   Octal 25
assign SELECT[`SLX(`EQU_17)  ] = EQU_17;		// Equal   to   Octal 17
assign SELECT[`SLX(`EQU_16)  ] = EQU_16;		// Equal   to   Octal 16

// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------

