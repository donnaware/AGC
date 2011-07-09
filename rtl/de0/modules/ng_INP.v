// --------------------------------------------------------------------
// ng_INP Input Buffer Port
// --------------------------------------------------------------------
module ng_INP(
	input  						CLK2,				// AGC Main Clock
	input  						NSA,				// Stanby, negative logic
	input  		[ 4:0]		Keypad,			// Keypad input port
	input							Keyready,		// Signals a key value is ready
	output  		[15:0]		INP_BUS,			// Input Port output
	output  						KeyStrobe		// Short key strobe output
);

assign INP_BUS   = {2'b00, !NSA, 8'h00, Keypad};
//assign KeyStrobe = Keyready;

//-----------------------------------------------------------------------------
// Find Rising edge of Key ready line using a 3-bits shift register
// and syncronize it to the AGC main clock.
//-----------------------------------------------------------------------------
reg [2:0] DRedge;  
always @(posedge CLK2) DRedge <= {DRedge[1:0], Keyready};
wire DR_risingedge  = (DRedge[2:1] == 2'b01);      // now we can detect DR rising edge
assign KeyStrobe = DR_risingedge;

// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------

