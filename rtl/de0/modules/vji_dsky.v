// --------------------------------------------------------------------
// Virtual JTAG DSKY console
// --------------------------------------------------------------------
module vji_dsky(
	input					clk, 				// main clock
	input			[7:0]	data_in,			// data input
	output reg	[3:0] sel_out,       // select output register
	output reg	[4:0] key_pad,			// KeyPad output
	output 				key_rdy,			// Keyboard valid signal. 
	output reg			test_out       // Test output line
);

// --------------------------------------------------------------------
// Instantiate Virtual JTAG
// --------------------------------------------------------------------
wire tdo;					// vjtag output data signals
wire tck; 					// vjtag Clock signals
wire tdi; 					// vjtag input data signals
wire capture_dr;			// Captutre data register signal
wire shift_dr;				// data Shift state
wire update_dr;			// data Update state
wire update_ir;			// instruction register update state
virt_jtag virt_jtag_inst(
    .tck    ( tck ),								// vjtag clock
    .tdi    ( tdi ),								// vjtag data in
    .tdo    ( tdo ),								// vjtag data out
    .ir_in  ( Control_reg ),					// Instruction register input
    .ir_out ( 3'b000 ),							// Instruction register output
    .virtual_state_cdr ( capture_dr ),		// Capture DR state
    .virtual_state_sdr ( shift_dr   ), 	// Shift DR state
    .virtual_state_udr ( update_dr  ), 	// Update DR state
    .virtual_state_uir ( update_ir  )  	// Update IR state
);

// --------------------------------------------------------------------
// VJI control constants
// --------------------------------------------------------------------
parameter  SEL   	= 3'b001;		// single write transaction 
parameter  POP   	= 3'b010;		// single read  transaction
parameter  KEY   	= 3'b011;		// select output 
parameter  NOP		= 3'b111;		// not used

// --------------------------------------------------------------------
//	VJI register bank
// --------------------------------------------------------------------
reg  [7:0] push_in;							// Push in register
reg  [7:0] push_out;							// Push out register
wire [2:0] Control_reg;						// Instruction register

// --------------------------------------------------------------------
//	Control register state sense
// --------------------------------------------------------------------
wire crPOP = (Control_reg == POP);		// We are poping
wire crSEL = (Control_reg == SEL);		// We are selecting
wire crKEY = (Control_reg == KEY);		// We are sending a key

// --------------------------------------------------------------------
// Write buffer pulse :  tck @ 5-7 MHz;  wrclk @ 50 MHz.
// will clock up wrclk to 100 MHz if necessary to perform edge detect
// --------------------------------------------------------------------
always @(posedge tck) begin
	if((crSEL | crKEY) && shift_dr) push_in <= {tdi, push_in[7:1]};
end

always @(posedge clk) begin
	if(crKEY && update_dr) begin
		key_pad  <= push_in[4:0];
	end
	else if(crSEL) begin
		sel_out  <= push_in[3:0];
		test_out <= push_in[7];
	end 
end

assign key_rdy = (crKEY && update_dr);

// --------------------------------------------------------------------
//	Read buffer on capture DR
// --------------------------------------------------------------------
always @(posedge tck) begin
	if(crPOP && capture_dr) begin
		push_out <= data_in;
	end
	else if(crPOP && shift_dr) begin
		push_out <= {push_out[0], push_out[7:1]};
	end
end

assign tdo = push_out[0];
	
// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------
