// --------------------------------------------------------------------
// ng_CRG Central register Module
// --------------------------------------------------------------------
`include "ControlPulses.h"
// --------------------------------------------------------------------
module ng_CRG(
	input  						CLK2,				// Clock Pulse 2
	input  		[100:0]		CP,				// Control Pulse
	input  		[ 15:0]		WRITE_BUS,		// Control Pulse
	output  		[ 15:0]		A_REG_BUS,		// A Register output
	output 		[ 15:0]		LP_REG_BUS,		// LP Register output
	output 		[ 15:0]		Q_REG_BUS,		// Q Register output
	output 		[ 15:0]		Z_REG_BUS		// Z Register output
);

// --------------------------------------------------------------------
// Register Storage
// --------------------------------------------------------------------
reg	[ 15:0]		A;			// A Register
reg	[ 15:0]		Q;			// Q Register
reg	[ 15:0]		Z;			// Z Register
reg	[ 15:0]		LP;		// LP Register

// --------------------------------------------------------------------
// Register output assignments
// --------------------------------------------------------------------
assign A_REG_BUS  = A;
assign LP_REG_BUS = LP;
assign Q_REG_BUS  = Q;
assign Z_REG_BUS  = Z;

// --------------------------------------------------------------------
// Control Signals
// --------------------------------------------------------------------
wire 	GENRST  		= CP[`CPX(`GENRST)];		// General reset signal
wire  WA				= CP[`CPX(`WA)];			// Write A
wire  WA0			= CP[`CPX(`WA0)];			// Write register at address 0 (A)
wire  WALP			= CP[`CPX(`WALP)];		// Write A and LP
wire	WQ				= CP[`CPX(`WQ)];			// Write Q
wire	WA1			= CP[`CPX(`WA1)];			// Write register at address 1 (Q)
wire	WLP			= CP[`CPX(`WLP)];			// Write LP
wire	WA3			= CP[`CPX(`WA3)];			// Write register at address 3 (LP)
wire	WZ				= CP[`CPX(`WZ)];			// Write Z
wire	WA2			= CP[`CPX(`WA2)];			// Write register at address 2 (Z)

// --------------------------------------------------------------------
// Instantiate Register A Latch
// --------------------------------------------------------------------
always @(posedge CLK2) begin 				// Instantiate the A latch
	if(!GENRST) A <= 16'h0000; 
	else if(!WA | !WA0) 	A <= WRITE_BUS; // Write to A, No Shift 
	else if(!WALP) begin						 // If a shift is requested
		A[15]    <= WRITE_BUS[15];		 	 // MSBit
		A[14]    <= WRITE_BUS[15];		 	 // Duplicate it
		A[13:0]  <= WRITE_BUS[14:1];	 	 // Shifted
	end
end 

// --------------------------------------------------------------------
// Instantiate Register LP Latch
// --------------------------------------------------------------------
always @(posedge CLK2) begin 		// Instantiate the LP latch
	if(!GENRST) LP <= 16'h0000; 
	else if(!WLP | !WA3) begin 
		LP[15  ] <= WRITE_BUS[0];		// LSB to MSBit
		LP[14  ] <= WRITE_BUS[0];		// Duplicate it
		LP[12:0] <= WRITE_BUS[13:1];	// Shifted
	end 
	if(!WALP | !WLP | !WA3) LP[13] <= !(WALP | !WRITE_BUS[0]);	// Handle Bit 14	
end 

// --------------------------------------------------------------------
// Instantiate Register Q Latch
// --------------------------------------------------------------------
always @(posedge CLK2) begin 		// Instantiate the Q latch
	if(!GENRST) 			Q <= 16'h0000; 
	else if(!WQ | !WA1)	Q <= WRITE_BUS; 
end 

// --------------------------------------------------------------------
// Instantiate Register Z Latch
// --------------------------------------------------------------------
always @(posedge CLK2) begin 	// Instantiate the Z latch
	if(!GENRST) 			Z <= 16'h0000; 
	else if(!WZ | !WA2)	Z <= WRITE_BUS; 
end 

// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------

