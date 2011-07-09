// --------------------------------------------------------------------
// ng_PAR Parity Generator Checker Module
// --------------------------------------------------------------------
`include "ControlPulses.h"
// --------------------------------------------------------------------
module ng_PAR(
	input  						CLK2,				// Clock Pulse 1
	input  						CLR_PAR_ALM,	// Clear Parity Alarm
	input  						M_IN16,			// Memory bit 16 input	
	input  		[100:0]		CP,				// Control Pulse
	input   		[  5:0]		SELECT,			// Select Input
	input  		[ 15:0]		WRITE_BUS,		// Control Pulse
	output						M_OUT16,			// Parity output
	output						PARALM  			// Parity Alarm Output
);

wire 	GENRST  		= CP[85];					// General reset signal
wire	CLG 			= CP[`CPX(`CLG)];			// CP signal - Clear G
wire	WGX 			= CP[36];					// CP signal - Write G (do not reset)
wire	SBWG 			= CP[94];					// CP signal - Write G from memory
wire	GP 			= CP[4];						// CP signal - Generate Parity
wire	RP2 			= CP[13];					// CP signal - Read parity 2 
wire	WP 			= CP[41];					// CP signal - Write P
wire	WPX 			= CP[42];					// CP signal - Write P (do not reset)
wire	WP2 			= CP[43];					// CP signal - Write P2
wire	TP 			= CP[29];					// CP signal - Test parity
wire	WE 			= CP[96];					// CP signal - Write E-MEM from G
wire	RG 			= CP[11];					// CP signal - Read G

wire	GTR_27 		= SELECT[4];				// Get SELECT signal

wire	PR_RST 		= !(!GENRST & CLK2);
wire	PR_CG15 		= !(!CLG & CLK2);
wire	PR_WG15  	= !(!(WGX &  SBWG & GP & RP2) & CLK2);
wire	PR_WP			= !(!(WP & WPX) & CLK2);
wire	PR_WP2 		= !(!WP2 & CLK2);
wire	PR_WPLM 		= !(((TP | GTR_27 | !PR_P_15) | !PR_RST) & CLK2);

wire  PR_D0 		= !(!(!RP2 & PR_P2) & !(!GP & PR_1_15) & !(!SBWG & M_IN16) & !(!WGX & PR_1_15));
wire  PR_D7 		= !(!PR_G15 & RG);

// --------------------------------------------------------------------
// Register Storage
// --------------------------------------------------------------------
reg	[ 15:0]		P;			// Parity Register
reg	 				P2;		// P2 Register
reg	 				G15;		// G15 Register
reg	 				PALM;		// PALM Register

// --------------------------------------------------------------------
// Instantiate Register P2 Latch
// --------------------------------------------------------------------
always @(negedge PR_WP2 or negedge PR_RST) begin 
	if(!PR_RST) P2 <= 1'b0; 
	else 			P2 <=	PR_1_15;
end 
wire PR_P2 = P2;

// --------------------------------------------------------------------
// Instantiate Register G15 Latch
// --------------------------------------------------------------------
always @(negedge PR_WG15 or negedge PR_CG15) begin 
	if(!PR_CG15) G15 <= 1'b0; 
	else 			 G15 <= PR_D0;
end 
wire   PR_G15  = G15;
assign M_OUT16 = WE ? 1'bZ : PR_G15;

// --------------------------------------------------------------------
// Instantiate Register PALM Latch
// --------------------------------------------------------------------
always @(negedge PR_WPLM or negedge CLR_PAR_ALM) begin 
	if(!CLR_PAR_ALM) PALM <= 1'b0; 
	else 			     PALM <= PR_RST & PR_P_15;
end 
assign PARALM = PALM;

// --------------------------------------------------------------------
// Instantiate Register H Latch
// --------------------------------------------------------------------
always @(negedge PR_WP or negedge PR_RST) begin 	
	if(!PR_RST) P <= 16'h0000; 
	else 			P <= {PR_D7,WRITE_BUS[14:0]};
end 

wire PR_1_15 = ^P[14:0];				// Generate ODD Parity
wire PR_P_15 = PR_1_15 ^ P[15];		// Generate the alarm

// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------
