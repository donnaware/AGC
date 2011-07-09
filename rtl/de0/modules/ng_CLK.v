// --------------------------------------------------------------------
// ng_CLK.v - Clock Generator module 
// --------------------------------------------------------------------
module ng_CLK(
	input 					NPURST,			// Master reset, negative logic
	input 					MCLK,				// Manual Clock 
	input 					FCLK,				// Fast Clock 
	input 					CLK_SLOW,		// Slow Clock
	input 					CLK_SEL,			// Clock Select
	input 					CLK_2MHZ,		// 2Mhz input Clock 
	output  					CLK1,				// Clock Pulse 1
	output					CLK2				// Clock Pulse 2
);

wire CLOCK  = !(!(CLK_SLOW & CLK_SEL) & !(!CLK_SEL & CLK_2MHZ));  // CLK Select
wire CK_CLK = !((MCLK | FCLK) & !(FCLK & CLOCK)); 

// --------------------------------------------------------------------
// NOTE: A JK Flip Flop can be instantiated using the following code:
// always@(negedge CLK or negedge CLN or negedge PRN) 
//    if     (!CLN) Q <= 0;
//    else if(!PRN) Q <= 1;
//    else          Q <= ~Q & J | Q & ~K;
// --------------------------------------------------------------------
reg  Q1, Q2; 
always@(negedge CK_CLK or negedge NPURST) 
    if(!NPURST) Q1 <= 1'b1;
    else        Q1 <= (~Q1 & ~Q2) | (Q1 & ~Q2);
	
always@(posedge CK_CLK or negedge NPURST) 
    if(!NPURST) Q2 <= 1'b1;
    else        Q2 <= (~Q2 &  Q1) | (Q2 & Q1);

assign CLK1	= !(~Q1 |  Q2);
assign CLK2	= !( Q1 | ~Q2);

// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------
