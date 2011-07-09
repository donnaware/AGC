// --------------------------------------------------------------------
// ng_INT Central register Module
// --------------------------------------------------------------------
`include "ControlPulses.h"
// --------------------------------------------------------------------
module ng_INT(
	input                   CPO4, 			// Clock Pulse Interrupt1
	input  						CPO5,				// Clock Pulse Interrupt3
	input  						KB_STR,  		// Keyboard Interrupt4
	input  						CLK2,				// Clock Pulse 2
	input  		[100:0]		CP,				// Control Pulse
	input  		[ 15:0]		WRITE_BUS,		// Control Pulse
	output  		[ 15:0]		INT_BUS,			// INT Register output
	output						IRQ				// Interrupt request
);

// --------------------------------------------------------------------
// JTAG Debugging Probes
// --------------------------------------------------------------------
//JTAG_Probe	INT_OUT16(.probe(INT_BUS));
//                              3      3        3        3         1        1      1     1
//JTAG_Probe	INT_TST16(.probe({RPCELL,pri_level,pri_out, rst_RUPT, KRPT, CLRP, pri_EO,IT_SEL}));
//                            15   14    13     12    11  10   9     8     7,     6,     5,       4,       3,           2,           1,   0
JTAG_Probe	INT_TST2(.probe({IRQ,rgINH,rgINH1,KB_STR,RPT,INH,CLINH,CLINH1,WOVI,rgRUPT1,rgRUPT3,rgRUPT4,WRITE_BUS[15],WRITE_BUS[14],KRPT,CLRP  }));

// --------------------------------------------------------------------
// Output Assignments 
// --------------------------------------------------------------------
assign IRQ = !(IT_INH & IT_INH1 & pri_EO & IT_SEL);

// --------------------------------------------------------------------
// Control Signal Assignments
// --------------------------------------------------------------------
wire 	GENRST  	= CP[`CPX(`GENRST)];		// General reset signal
wire 	RPT  		= CP[`CPX(`RPT)];			// Read RUPT opcode 
wire 	CLRP		= CP[`CPX(`CLRP)];		// Clear RPCELL
wire 	INH  		= CP[`CPX(`INH)];			// Set INHINT
wire 	CLINH		= CP[`CPX(`CLINH)];		// Clear INHINT
wire 	CLINH1	= CP[`CPX(`CLINH1)];		// Clear INHINT1
wire 	WOVI 		= CP[`CPX(`WOVI)];		// Write overflow RUPT inhibit
wire 	KRPT		= CP[`CPX(`KRPT)];		// Knock down Rupt priority

// --------------------------------------------------------------------
// Register Storage
// --------------------------------------------------------------------
reg 		 rgINH;		// Inhibit   Interrupt register
reg 		 rgINH1;		// Inhibit 1 Interrupt register
reg 		 rgRUPT1; 	// Interrupt register 1
reg 		 rgRUPT3; 	// Interrupt register 3
reg 		 rgRUPT4;	// Interrupt register 4
reg [2:0] RPCELL;		// RP Register

// --------------------------------------------------------------------
// Interrupt Inhibit Logic
//
// NOTE: A JK FF can be instantiated using this code:
// always@(negedge CLK or negedge CLN or negedge PRN) 
//    if     (!CLN) Q <= 0;
//    else if(!PRN) Q <= 1;
//    else          Q <= ~Q & J | Q & ~K;
// --------------------------------------------------------------------
reg rgINH_i;				// internal Inhibit Interrupt register
always@(posedge CLK2) 
	rgINH_i  <= (~rgINH_i  & !(INH & GENRST)) | (rgINH_i  & CLINH);

always@(negedge CLK2) rgINH <= rgINH_i;	// Transfer to outputs on negative edge

reg rgINH1_i;				// internal Inhibit Interrupt register
wire IT_INH1_J = (WRITE_BUS[15] ^ WRITE_BUS[14]) & ~WOVI;
always@(posedge CLK2) 
   if(!GENRST) rgINH1_i <= 1'b0;
	else        rgINH1_i <= (~rgINH1_i & IT_INH1_J) | (rgINH1_i & CLINH1);

always@(negedge CLK2) rgINH1 <= rgINH1_i;	// Transfer to outputs on negative edge

wire IT_INH  = !rgINH;
wire IT_INH1 = !rgINH1;

// --------------------------------------------------------------------
// Interrupt Latches
// --------------------------------------------------------------------
wire IT_RST 	= !(CLK2 & !GENRST);				// Reset Signal sync with clock
wire rst_RUPT1 = rst_RUPT[0] & IT_RST; 		// Rupt reset wires
reg  rgRUPT1_i; 										// Interrupt register 1
always@(posedge CPO4 or negedge rst_RUPT1) 	// Interrupt latch 1
   if(!rst_RUPT1) rgRUPT1_i <= 1'b0;			// Release latch
   else 				rgRUPT1_i <= 1'b1;			// Set latch

always@(negedge CPO4 or negedge rst_RUPT1) rgRUPT1 <= rgRUPT1_i;
								

wire rst_RUPT3 = rst_RUPT[1] & IT_RST; 		// Rupt reset wires
reg  rgRUPT3_i; 										// Interrupt register 3
always@(posedge CPO5 or negedge rst_RUPT3) 	// Interrupt latch 3
   if(!rst_RUPT3) rgRUPT3_i <= 1'b0;				// Release latch
   else 				rgRUPT3_i <= 1'b1;				// Set latch

always@(negedge CPO5 or negedge rst_RUPT3) rgRUPT3 <= rgRUPT3_i;
	
	
reg rgRUPT4_i;
always@(posedge KB_STR or negedge rst_RUPT4) // Interrupt latch 4
   if(!rst_RUPT4)		rgRUPT4_i <= 1'b0;				// Release latch
   else if(KB_STR) 	rgRUPT4_i <= 1'b1;				// Set latch

always@(negedge KB_STR or negedge rst_RUPT4) rgRUPT4 <= rgRUPT4_i;	
	
wire rst_RUPT4 = IT_RST & rst_RUPT[2]; 		// Rupt reset wires
 
// --------------------------------------------------------------------
// Prioritize the interrupts
// --------------------------------------------------------------------
wire [2:0] pri_level = {rgRUPT1, rgRUPT3, rgRUPT4}; // Priority level
reg  [2:0] pri_out;		// seected priority
always @(pri_level) begin 
	casex(pri_level) 
		3'b1XX  : pri_out <= 3'b001;  // priority 6, pri_out = 1
		3'b01X  : pri_out <= 3'b011;  // priority 4, pri_out = 3
		3'b001  : pri_out <= 3'b100;  // priority 3, pri_out = 4
		default : pri_out <= 3'b111;  // priority X, pri_out = 7
	endcase 
end 
wire pri_EO = |pri_level;	// =1 if were any activated 

// --------------------------------------------------------------------
// Instantiate Register RPCELL at address
// 2004 = RUPT 1 (TIME3)(octal RUPT addr)
// 2014 = RUPT 3 (TIME4)
// 2020 = RUPT 4 (KBD)
// --------------------------------------------------------------------
always @(posedge CLK2) begin 		
	if(!GENRST) 	RPCELL <= 3'h0; 
	else if(!CLRP) RPCELL <= 3'h0; 
	else if(!RPT)	RPCELL <= pri_out; 
end 
wire IT_SEL = !(|RPCELL);
assign INT_BUS = {11'b0000_0100_000,RPCELL,2'b00};

// --------------------------------------------------------------------
// Interrupt Reset Logic
// --------------------------------------------------------------------
reg [2:0] rst_RUPT;						   		// Rupt reset 
always @(posedge CLK2) begin 
	if(!KRPT) begin 
		case(pri_out) 
			3'b001 : rst_RUPT <= 3'b110;		// Priority 1
			3'b011 : rst_RUPT <= 3'b101;		// Priority 3
			3'b100 : rst_RUPT <= 3'b011;		// Priority 4
			default: rst_RUPT <= 3'b111; 		// Priority 7
		endcase 
	end
	else rst_RUPT <= 3'b111; 
end 

// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------

