// --------------------------------------------------------------------
// Button Debouncer
// --------------------------------------------------------------------
module Button_Debouncer(
	input 			clk,			// "clk" is the clock
	input 			PB,			// "PB" is the glitched, asynchronous, active low push-button signal
	output	reg	PB_state		// 1 while the push-button is active (down)
);

reg 		 PB_sync_0;
reg 		 PB_sync_1;  
reg [1:0] PB_cnt;					// declare a 2-bit counter

// use two flipflops to synchronize the PB signal the "clk" clock domain
always @(posedge clk) PB_sync_0 <= ~PB;  			// invert PB to make PB_sync_0 active high
always @(posedge clk) PB_sync_1 <= PB_sync_0;

// When the push-button is pushed or released, we increment the counter
// The counter has to be maxed out before we decide that the push-button state has changed

wire	PB_idle = (PB_state==PB_sync_1);
wire 	PB_cnt_max = &PB_cnt;				// true when all bits of PB_cnt are 1's

always @(posedge clk) begin
	if(PB_idle)  PB_cnt <= 2'd0;  // nothing's going on
	else begin
		PB_cnt <= PB_cnt + 2'd1;  // something's going on, increment the counter
		if(PB_cnt_max) PB_state <= ~PB_state;  // if the counter is maxed out, PB changed!
	end
end

// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------

