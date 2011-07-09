// --------------------------------------------------------------------
// ng_TPG.v - Time Pulse Generator
//
// AGC instructions are implemented in groups of 12 steps, called timing pulses. The timing
// pulses, named TP1 through TP12, are produced by the Time Pulse Generator (TPG). Each set
// of 12 timing pulses is called an instruction subsequence. Simple instructions, such as TC,
// execute in a single subsequence of 12 pulses. More complex instructions require several
// subsequences.
// --------------------------------------------------------------------
module ng_TPG(
	input  					CLK1,				// Clock Pulse 1
	input  					CLK0,				// Clock Pulse 0
	input 					NPURST,			// Master reset, negative logic
	input 					F17X,				// Clock divided by 17
	input 					FCLK,				// Fast Clock enable
	input 					F13X,				// Clock divided by 13
	input 					INST,				// Instruction increment
	input 					NRUN,				// Run mode, negative logic
	input 					SNI,				// SELECT NEXT INST 1=select next instruction (SNI register)
	input 					OUT8,				// Output 8 standby enable
	input 					NSA,				// Standby allowed, negative logic
	input 					NSTEP,			// Next Step, negative logic
	output reg	[3:0]		TPG,				// Time Pulse regsiter output 
	output					STBY				// Standby alert signal
);

// --------------------------------------------------------------------
// Time Pulse Gate Signals
// --------------------------------------------------------------------
wire	TPG0 = !(!NPURST | !(F17X | !FCLK));	// Time Pulse Gate 0
wire	TPG1 = !(!F13X & FCLK);						// Time Pulse Gate 1
wire	TPG2 = !(!(INST & !SNI) & NRUN);			// Time Pulse Gate  2
wire	TPG3 = !(!SNI | !OUT8 | NSA);				// Time Pulse Gate 3
wire	TPG4 = NSTEP;									// Time Pulse Gate 4
wire	TPG5 = !(NSTEP & NRUN);						// Time Pulse Gate 5

// --------------------------------------------------------------------
// Counter Control Signals
// --------------------------------------------------------------------
wire	CNT_D1 = !(!NTP12 & TPG3);
wire	CNT_PE = !(!(!TPG3|NTP12) | !(NTP12|!TPG2|TPG3) | !(NWAIT|!TPG5));
wire	CNT_CET = !(!(NWAIT|TPG5) | (!(NSTBY|TPG0) | !(NPWRON|TPG1) | !(NSRLSE|TPG4)));

// --------------------------------------------------------------------
// Counter Logic:
// --------------------------------------------------------------------
always @(posedge CLK1 or negedge NPURST) 
   if(!NPURST)       TPG <= 4'h0;						// Clear register on reset
	else if(!CNT_PE)  TPG <= {2'b00, CNT_D1, 1'b0};	// Request load D1
   else if(CNT_CET)  TPG  <= TPG + 4'd1;				// Increment counter

// --------------------------------------------------------------------
// Time Pulse values:
// 
// TPG
// ---
//  0      Standby
//  1      Power on
//  2 - 13 Instruction sequence
//      14 Sequence release
//      15  Wait
// --------------------------------------------------------------------
wire NSTBY	= !(TPG ==  0);
wire NPWRON = !(TPG ==  1);
wire NTP12  = !(TPG == 13);
wire NSRLSE = !(TPG == 14);
wire NWAIT  = !(TPG == 15);

assign STBY = NSTBY;

// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------

