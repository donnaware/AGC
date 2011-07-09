//-------------------------------------------------------------------------------------------------
// ng_MON.v - Monitor module 
//
// In the original Pultorak desing, this Module was used to contain all the front panel switches
// and Display indicator LED's. In this FPGA experiment, most of that is not needed since the FPGA
// has adequate current drive capability to directly drive standard LED's (about 8ma) so this module
// Now basically is just providing switch debouncing and logic.
//-------------------------------------------------------------------------------------------------
module ng_MON(
	input 					m_reset,			// Master reset button input	
	input 					clk_mode,		// Clock Mode selection
	input 					step_mode,		// Step Mode
	input 					run_step,		// Run Step selection
	input 					standby,			// Standby mode selector
	input 					inst_step,		// Instruction step button
	input 					clock_step,		// Clock Step button
	input  					DBNCLK,			// Debouncer Clock (200Hz) input
	output 					NPURST,			// Master reset, negative logic
	output 					MCLK,				// Manual Clock 
	output 					FCLK,				// Fast Clock 
	output 					INST,				// Instruction increment
	output 					NRUN,				// Run mode, negative logic
	output 					NSA,				// Standby allowed, negative logic
	output 					NSTEP 			// Next Step, negative logic
);

// --------------------------------------------------------------------
// Reset Button Debouncer
// --------------------------------------------------------------------
Button_Debouncer u1(.clk(DBNCLK), .PB(!m_reset), .PB_state(NPURST));

// --------------------------------------------------------------------
// Direct Output assignments:
// Here all switches and buttons are SPST and have a weak pull up
// resistor tied to Vcc so the default state is high.
// --------------------------------------------------------------------
assign FCLK  = !clk_mode;			// Invert switch state
assign INST  = !step_mode;			// Instruction step mode
assign NRUN  = !run_step;			// Run or step mode
assign NSA   =  standby;			// Standby mode selector switch
assign NSTEP =  !Q1;					// Step mode
assign MCLK  =   Q2;					// Manual Clock output

//-------------------------------------------------------------------------------------------------
// NOTE: A D Flip Flop can be instantiated using the following code:
// always@(negedge CLK or negedge CLN or negedge PRN) 
//    if     (!CLN) Q <= 0;
//    else if(!PRN) Q <= 1;
//    else          Q <= D;
//-------------------------------------------------------------------------------------------------
reg  Q1, Q2; 											// Clock Registers
always@(negedge DBNCLK or negedge NPURST) 	// Flip Flop 1
    if(!NPURST) Q1 <= 1'b1;						// Set to high
    else        Q1 <= !inst_step;				// Load the switch state
	 
always@(negedge DBNCLK or negedge NPURST) 	// Flip Flop 2
    if(!NPURST) Q2 <= 1'b1;						// Set to high
    else        Q2 <= !clock_step;				// Load the switch state

	 
//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------


