//-------------------------------------------------------------------------------------------------
// ng_CLG.v - Clock and Time Ulse Generator module 
//
// In the original Pultorak desing, this was 3 separate modules; the CLK, TPG and SLC (Clock, Time 
// Pulse Generator and the Scaler). I combined them in this FPGA implementation and also included 
// the PLL which steps down the system clock from 50Mhz to 2.048Mhz. 
//-------------------------------------------------------------------------------------------------
`include "ControlPulses.h"
// --------------------------------------------------------------------
module ng_CLG(
	input  					CLK0,				// System Clock (50Mhz)
	input 					NPURST,			// Master reset, negative logic
	input 					MCLK,				// Manual Clock 
	input 					FCLK,				// Fast Clock 
	input 					INST,				// Instruction increment
	input 					NRUN,				// Run mode, negative logic
	input 					NSA,				// Standby allowed, negative logic
	input 					NSTEP,			// Next Step, negative logic
	input 					SNI,				// SELECT NEXT INST 1=select next instruction (SNI register)
	input 					OUT8,				// Output 8 standby enable
	input 					CLK_SEL,			// Clock Select
	input 					SCL_ENAB,		// Scaler Enable
	input						Slow_Clock,		// Slow Clock input from external source
	output  					CLK1,				// Clock Pulse 1
	output					CLK2,				// Clock Pulse 2
	output reg	[3:0]		TPG,				// Time Pulse regsiter output 
	output					STBY,				// Standby alert signal
	output					F10X,				// Read Time clock signal
	output					F13X,				// 12.5 Hz
	output					F17X,				// About 1Hz
	output					DBNCLK,			// Debouncer Clock (200Hz)
	output					CLK_2MHZ			// 2Mhz clock output
);

//-------------------------------------------------------------------------------------------------
// Instantiate FPGA built in PLL to divide clock down to 2.048 using a divider/multiplier ratio 
// of 128/3125. 
// --------------------------------------------------------------------
wire CLK_256K;										// 256Khz clock
altpll0	pll_u1(.inclk0(CLK0),.c0(CLK_2MHZ), .c1(CLK_256K));
	
//-------------------------------------------------------------------------------------------------
//  Slow Clock and Debounce Clock Generation:
//  In the Pultorak design, these clocks were sourced from an external 555 timer, or this exercise, 
//  I am using a simple divider. 
//
//  Input Clock  = 256,000 Hz (From second PLL output)
//	 Div    4 Clock = 64,000Hz
//	 Div   16 Clock = 16,000Hz
//	 Div  256 Clock =  1,000Hz
//	 Div 2048 Clock =    125Hz
//
// It may also be possible to use the Scaler outputs for this instead
//
//-------------------------------------------------------------------------------------------------
reg  [19:0] Counter;                                		// For dividing clock speed down
always @(posedge CLK_256K) 
    if(!NPURST) Counter <= 20'd0;   			// Reset counter
	 else        Counter <= Counter + 20'd1;  // increment  counter

reg booted; 
always @(posedge CLK_256K) 
   if(!NPURST) booted <= 1'b0;
	else if(Counter == 20'h7FFFF) booted <= 1'b1;

wire SLOW_COUNT = Counter[15];
wire CLK_SLOW = booted ? SLOW_COUNT : CLK_2MHZ; // Reset speed up

reg  [10:0] dbnceCntr;                                		// For dividing clock speed down
always @(posedge CLK_256K) dbnceCntr <= dbnceCntr + 11'd1;  // increment  counter
assign DBNCLK = dbnceCntr[10];   // 125Hz

//-------------------------------------------------------------------------------------------------
// (CLK) Clock Section:
// The original AGC used asynchronous logic driven by a 4-phase clock. The Pultorak recreation uses 
// synchronous logic driven by a 2-phase nonoverlapping clock using 2 Flip Flops. 
//-------------------------------------------------------------------------------------------------
wire CLOCK  = !(!(CLK_SLOW & CLK_SEL) & !(!CLK_SEL & CLK_2MHZ));  // CLK Select
wire CK_CLK = !((MCLK | FCLK) & !(FCLK & CLOCK)); 

//-------------------------------------------------------------------------------------------------
// NOTE: A JK Flip Flop can be instantiated using the following code:
// always@(negedge CLK or negedge CLN or negedge PRN) 
//    if     (!CLN) Q <= 0;
//    else if(!PRN) Q <= 1;
//    else          Q <= ~Q & J | Q & ~K;
//-------------------------------------------------------------------------------------------------
reg  Q1, Q2; 											// Clock Registers
always@(negedge CK_CLK or negedge NPURST) 	// Flip Flop 1
    if(!NPURST) Q1 <= 1'b1;
    else        Q1 <= (~Q1 & ~Q2) | (Q1 & ~Q2);
	
always@(posedge CK_CLK or negedge NPURST)  	// Flip Flop 2
    if(!NPURST) Q2 <= 1'b1;
    else        Q2 <= (~Q2 &  Q1) | (Q2 & Q1);

assign CLK1	= !(~Q1 |  Q2);		// Clock output assignments
assign CLK2	= !( Q1 | ~Q2);		// Clock output assignments

//-------------------------------------------------------------------------------------------------
// (TPG) - Time Pulse Generator section:
// AGC instructions are implemented in groups of 12 steps, called timing pulses. The timing pulses, 
// named TP1 through TP12, are produced by the Time Pulse Generator (TPG). Each set of 12 timing 
// pulses is called an instruction subsequence. Simple instructions, such as TC, execute in a single 
// subsequence of 12 pulses. More complex instructions require several subsequences.
//-------------------------------------------------------------------------------------------------
wire NSTBY	= !(TPG == `TP_Standby);
wire NPWRON = !(TPG == `TP_PowerOn);
wire NTP12  = !(TPG == `TP_12     );
wire NSRLSE = !(TPG == `TP_SRELSE );
wire NWAIT  = !(TPG == `TP_SRELSE );

//-------------------------------------------------------------------------------------------------
// Counter Control Signals
//-------------------------------------------------------------------------------------------------
wire	TPG_0 = !(!NPURST | !(F17X | !FCLK));		// Time Pulse Gate 0
wire	TPG_1 = !(!F13X & FCLK);						// Time Pulse Gate 1
wire	TPG_2 = !(!(INST & !SNI) & NRUN);			// Time Pulse Gate 2
wire	TPG_3 = !(!SNI | !OUT8 | NSA);				// Time Pulse Gate 3
wire	TPG_4 =   NSTEP;									// Time Pulse Gate 4
wire	TPG_5 = !(NSTEP & NRUN);						// Time Pulse Gate 5

wire  CNT_D1  = !(!NTP12 & TPG_3);
wire  CNT_PE  = !(!(!TPG_3 | NTP12) | !(NTP12  | !TPG_2 | TPG_3) | !(NWAIT | !TPG_5));
wire  CNT_CET = !((!(NSTBY | TPG_0) | !(NPWRON | TPG_1) | !(NSRLSE | TPG_4)) | !(NWAIT | TPG_5));

//-------------------------------------------------------------------------------------------------
// Counter Logic:
//-------------------------------------------------------------------------------------------------
always @(posedge CLK1 or negedge NPURST) 				// Counter 
   if(!NPURST)       TPG <= 4'h0;						// Clear register on reset
	else if(!CNT_PE)  TPG <= {2'b00, CNT_D1, 1'b0};	// Request load D1
   else if(CNT_CET)  TPG  <= TPG + 4'd1;				// Increment counter

assign STBY = NSTBY;

//-------------------------------------------------------------------------------------------------
// (SCL)- Clock Scaler:
// The 1.024 MHz AGC clock is divided by two to produce a 512 kHz signal called the MASTER FREQUENCY; 
// this signal is further divided through a SCALER, first byfive to produce a 102.4 kHz signal. This 
// is then divided by two through 17 successive stages called F1 (51.2 kHz) through F17 (0.78125 Hz). 
// The F10 stage (100 Hz) is fed back into the AGC to increment the real-time clock and other priority
// counters in the PROC module. The F17 stage is used to intermittently run the AGC when it operates 
// in the STANDBY mode.  The F10, F13, and F17 outputs of the SCALER feed into a synchronous one-shot 
// that produces a short output pulse on the rising edge of the input.
//-------------------------------------------------------------------------------------------------
wire SL_RSTA = NPURST;								// Reset Signal

//-------------------------------------------------------------------------------------------------
// Counter Logic:
//
// Signal   Name     Frequency
// -------- -------  -------------
// CLK1     CLK1      1024 Khz
// Mcnt[ 0] MASTER	 512 Khz
// MCT_PE   M10      102.4 KHz
// Fcnt[ 0] F01       51.2 KHz
// Fcnt[ 1] F02       25.6 Khz
// Fcnt[ 2] F03       12.8 Khz
// Fcnt[ 3] F04        6.4 Khz
// Fcnt[ 4] F05        3.2 Khz
// Fcnt[ 5] F06        1.6 Khz
// Fcnt[ 6] F07          800 Hz
// Fcnt[ 7] F08          400 Hz
// Fcnt[ 8] F09          200 Hz
// Fcnt[09] F10          100 Hz
// Fcnt[10] F11           50 Hz
// Fcnt[11] F12           25 Hz
// Fcnt[12] F13           12.5 Hz
// Fcnt[13] F14            6.25 Hz
// Fcnt[14] F15            3.125 Hz
// Fcnt[15] F16            1.5625 Hz
// Fcnt[16] F17            0.78125 Hz
//-------------------------------------------------------------------------------------------------
reg [ 3:0] Mcnt;										// Master Counter
always @(posedge CLK1 or negedge SL_RSTA) 	// Counter logic
   if(!SL_RSTA)      Mcnt <= 4'h0;				// Clear register on reset
	else if(MCT_PE)   Mcnt <= 4'h0;				// Request load D1
   else if(MCT_CET)  Mcnt <= Mcnt + 4'd1;		// Increment counter

wire MCT_PE  = (Mcnt == 4'd10);					// Trip to reset at 10
wire MCT_CET = SCL_ENAB;							// Enable signal

reg [16:0] Fcnt;										// Frequency counter
always @(posedge CLK1 or negedge SL_RSTA) 	// Counter logic
   if(!SL_RSTA)      Fcnt <= 17'd0;				// Clear register on reset
   else if(FCT_CET)  Fcnt <= Fcnt + 17'd1;	// Increment counter
	
wire FCT_CET = MCT_PE;								// Count 1 when Mcnt hits 10

//-------------------------------------------------------------------------------------------------
// Pulse Shaper; shortens pulse length to 1 CLK1 length
//-------------------------------------------------------------------------------------------------
//wire F10X_IN =  Fcnt[ 3];			// Input to F10X puls shaper
wire   F10X_IN =  Fcnt[ 9];			// Input to F10X puls shaper
wire   F13X_IN =  Fcnt[12];			// Input to F13X puls shaper
wire   F17X_IN =  Fcnt[16];			// Input to F17X puls shaper

//-------------------------------------------------------------------------------------------------
// NOTE: A JK Flip Flop can be instantiated using the following code:
// always@(negedge CLK or negedge CLN or negedge PRN) 
//    if     (!CLN) Q <= 0;
//    else if(!PRN) Q <= 1;
//    else          Q <= (~Q & J) | (Q & ~K);   // parens not needed
//-------------------------------------------------------------------------------------------------
wire CLK1N = ~CLK1;
reg Q10A, Q10B;										// Registers
always@(negedge CLK1N or negedge SL_RSTA) 
    if(!SL_RSTA)  Q10A <= 1'b0;						// Master clear
    else          Q10A <= ~Q10A & Q10B | Q10A & F10X_IN;

always@(negedge CLK1N or negedge SL_RSTA) 
    if(!SL_RSTA)  Q10B <= 1'b0;						// Master clear
    else          Q10B <= ~Q10B & !(Q10A | !F10X_IN) ;

reg Q13A, Q13B;										// Registers
always@(negedge CLK1N or negedge SL_RSTA) 
    if(!SL_RSTA)  Q13A <= 1'b0;						// Master clear
    else          Q13A <= ~Q13A & Q13B | Q13A & F13X_IN;

always@(negedge CLK1N or negedge SL_RSTA) 
    if(!SL_RSTA)  Q13B <= 1'b0;						// Master clear
    else          Q13B <= ~Q13B & !(Q13A | !F13X_IN);

reg Q17A, Q17B;										// Registers
always@(negedge CLK1N or negedge SL_RSTA) 
    if(!SL_RSTA)  Q17A <= 1'b0;						// Master clear
    else          Q17A <= ~Q17A & Q17B | Q17A & F17X_IN;

always@(negedge CLK1N or negedge SL_RSTA) 
    if(!SL_RSTA)  Q17B <= 1'b0;						// Master clear
    else          Q17B <= ~Q17B & !(Q17A | !F17X_IN);

//-------------------------------------------------------------------------------------------------
assign F10X = Q10B;		// Make output assignments
assign F13X = Q13B;		// Make output assignments
assign F17X = Q17B;		// Make output assignments

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
