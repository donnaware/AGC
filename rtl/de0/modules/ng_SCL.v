// --------------------------------------------------------------------
// ng_SCL.v - Clock Scaler
//
// The 1.024 MHz AGC clock is divided by two to produce a 512 kHz signal 
// called the MASTER FREQUENCY; this signal is further divided through a 
// SCALER, first byfive to produce a 102.4 kHz signal. This is then divided
// by two through 17 successive stages called F1 (51.2 kHz) through F17
// (0.78125 Hz). The F10 stage (100 Hz) is fed back into the AGC to 
// increment the real-time clock and other priority counters in the PROC
// module. The F17 stage is used to intermittently run the AGC when it 
// operates in the STANDBY mode.  The F10, F13, and F17 outputs of the 
// SCALER feed into a synchronous one-shot that produces a short output
// pulse on the rising edge of the input.
// --------------------------------------------------------------------
module ng_SCL(
	input  					CLK1,				// Clock Pulse 1
	input 					NPURST,			// Master reset, negative logic
	input 					SCL_ENAB,		// Scaler Enable
	output					F10X,				// Read Time clock signal
	output					F13X,				// 12.5 Hz
	output					F17X				// .8 Hz
);

wire SL_RSTA = NPURST;								// Reset Signal

// --------------------------------------------------------------------
// Counter Logic:
// --------------------------------------------------------------------
reg [ 3:0] Mcnt;										// Master Counter
always @(posedge CLK1 or negedge SL_RSTA) 	// Counter logic
   if(!SL_RSTA)       Mcnt <= 4'h0;				// Clear register on reset
	else if(MCT_PE)   Mcnt <= 4'h0;				// Request load D1
   else if(MCT_CET)  Mcnt <= Mcnt + 4'd1;		// Increment counter

wire MCT_PE  = Mcnt[0] & Mcnt[3];				// Trip to reset at 10
wire MCT_CET = SCL_ENAB;							// Enable signal

reg [16:0] Fcnt;										// Frequency counter
always @(posedge CLK1 or negedge SL_RSTA) 	// Counter logic
   if(!SL_RSTA)      Fcnt <= 17'd0;				// Clear register on reset
   else if(FCT_CET)  Fcnt <= Fcnt + 17'd1;	// Increment counter
	
wire FCT_CET = MCT_PE;								// Count 1 when Mcnt hits 10

// --------------------------------------------------------------------
// NOTE: // A JK Flip Flop can be instantiated using the following code:
// always@(negedge CLK or negedge CLN or negedge PRN) 
//    if     (!CLN) Q <= 0;
//    else if(!PRN) Q <= 1;
//    else          Q <= (~Q & J) | (Q & ~K);   // parens not needed
// --------------------------------------------------------------------
wire F10X_IN =  Fcnt[ 9];			// Input to F10X puls shaper
wire F13X_IN =  Fcnt[12];			// Input to F13X puls shaper
wire F17X_IN =  Fcnt[16];			// Input to F17X puls shaper

// --------------------------------------------------------------------
// Pulse Shaper; shortens pulse length to 1 CLK1 length
// --------------------------------------------------------------------
reg Q10A, Q10B;										// Registers
always@(negedge CLK1 or negedge SL_RSTA) 
    if(!SL_RSTA)  Q10A <= 1'b0;						// Master clear
    else          Q10A <= ~Q10A & Q10B | Q10A & F10X_IN;

always@(negedge CLK1 or negedge SL_RSTA) 
    if(!SL_RSTA)  Q10B <= 1'b0;						// Master clear
    else          Q10B <= ~Q10B & !(Q10A | !F10X_IN);

wire J10A = Q10B;
wire K10A = !F10X_IN;
wire J10B = !(Q10A | !F10X_IN); 
wire K10B = Q10B;

reg Q13A, Q13B;										// Registers
always@(negedge CLK1 or negedge SL_RSTA) 
    if(!SL_RSTA)  Q13A <= 1'b0;						// Master clear
    else          Q13A <= ~Q13A & J13A | Q13A & ~K13A;

always@(negedge CLK1 or negedge SL_RSTA) 
    if(!SL_RSTA)  Q13B <= 1'b0;						// Master clear
    else          Q13B <= ~Q13B & J13B | Q13B & ~K13B;

wire J13A = Q13B;
wire K13A = !F13X_IN;
wire J13B = !(Q13A | !F13X_IN); 
wire K13B = Q13B;

reg Q17A, Q17B;										// Registers
always@(negedge CLK1 or negedge SL_RSTA) 
    if(!SL_RSTA)  Q17A <= 1'b0;						// Master clear
    else          Q17A <= ~Q17A & J17A | Q17A & ~K17A;

always@(negedge CLK1 or negedge SL_RSTA) 
    if(!SL_RSTA)  Q17B <= 1'b0;						// Master clear
    else          Q17B <= ~Q17B & J17B | Q17B & ~K17B;

wire J17A = Q17B;
wire K17A = !F17X_IN;
wire J17B = !(Q17A | !F17X_IN); 
wire K17B = Q17B;


assign F10X = Q10B;		// Make output assignments
assign F13X = Q13B;		// Make output assignments
assign F17X = Q17B;		// Make output assignments

// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------

