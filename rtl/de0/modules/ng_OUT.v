// --------------------------------------------------------------------
// ng_OUT Output Buffer and Display Port
// --------------------------------------------------------------------
`include "ControlPulses.h"
// --------------------------------------------------------------------
module ng_OUT(
	input  						CLK2,				// Clock Pulse 2
	input							PARALM,			// Parity Alarm signal
	input							STBY,				// Standby signal 
	input  		[ 15:0]		WRITE_BUS,		// Control Pulse
	input  		[100:0]		CP,				// Control Pulse
	input			[  7:0]		Aux1,				// Auxilliary Inpuit
	input			[  7:0]		Aux2,				// Auxilliary Inpuit
	input			[  3:0] 		SEL,				// Output register selector
	output reg	[  7:0]		DSP_OUT,			// Output Port output
	output  		[ 15:0]		OUT_BUS,			// Output Port output
	output						OUT8				// Output line 8
);

// --------------------------------------------------------------------
// Control Registers
// --------------------------------------------------------------------
wire 	GENRST = CP[`CPX(`GENRST)];		// General reset signal
wire	WA10	 = CP[`CPX(`WA10)  ];		// Register @ addr 10 (octal) DSPL
wire	WA11	 = CP[`CPX(`WA11)  ];		// Register @ addr 11 (octal) PANEL

// --------------------------------------------------------------------
// Register Storage
// --------------------------------------------------------------------
// Bits    Bit    Bits   Bits
// 14-11    10     9-5    4-0
// RLYWD  DSPC    DSPH   DSPL
// -----  ------  ----   -----
// 1011           MD1    MD2
// 1010   FLASH   VD1    VD2
// 1001           ND1    ND2
// 1000   UPACT          R1D1
// 0111   +R1S    R1D2   R1D3
// 0110   -R1S    R1D4   R1D5
// 0101   +R2S    R2D1   R2D2
// 0100   -R2S    R2D3   R2D4
// 0011           R2D5   R3D1
// 0010   +R3S    R3D2   R3D3
// 0001   -R3S    R3D4   R3D5
// 
// --------------------------------------------------------------------
reg [15:0] OUT;              // Declare OUT Register
reg [ 7:0] disreg [0:15];    // Display Display Registers

wire [3:0] bcd_l, bcd_h; 
DSPtoBCD bcd_u1(.DSP(WRITE_BUS[4:0]), .BCD(bcd_l));  // Decode Low BCD Nibble
DSPtoBCD bcd_u2(.DSP(WRITE_BUS[9:5]), .BCD(bcd_h));  // Decode high BCD Nibble
wire [7:0] dis_bcd = {bcd_h, bcd_l};

// --------------------------------------------------------------------
// Instantiate Register Display
// --------------------------------------------------------------------
wire [3:0] ot_sel = WRITE_BUS[14:11];
always @(posedge CLK2) begin
	if(!WA10) begin
		if(ot_sel < 4'd12) disreg[ot_sel] <= dis_bcd; 
		if(WRITE_BUS[10])  disreg[4'd12]  <= {4'b0000,ot_sel};
	end
end

// --------------------------------------------------------------------
// Mux auxilliary input with other inputs
// --------------------------------------------------------------------
wire [7:0] mux_out; 
always @(SEL or PANEL or disreg or Aux1 or Aux2) begin
	case(SEL)
		4'd0   : DSP_OUT <= PANEL;
		4'd1   : DSP_OUT <= disreg[SEL];  // R3D4   R3D5
		4'd2   : DSP_OUT <= disreg[SEL];  // R3D2   R3D3
		4'd3   : DSP_OUT <= disreg[SEL];  // R2D5   R3D1
		4'd4   : DSP_OUT <= disreg[SEL];  // R2D3   R2D4
		4'd5   : DSP_OUT <= disreg[SEL];  // R2D1   R2D2
		4'd6   : DSP_OUT <= disreg[SEL];  // R1D4   R1D5
		4'd7   : DSP_OUT <= disreg[SEL];  // R1D2   R1D3
		4'd8   : DSP_OUT <= disreg[SEL];  // R1D1
		4'd9   : DSP_OUT <= disreg[SEL];  // NOUN
		4'd10  : DSP_OUT <= disreg[SEL];  // VERB
		4'd11  : DSP_OUT <= disreg[SEL];  // MODE
		4'd12  : DSP_OUT <= disreg[SEL];  // Panel Register
		4'd13  : DSP_OUT <= Aux1;  		 // Auxilliary output 1
		4'd14  : DSP_OUT <= Aux2;			 // Auxilliary output 2
		4'd15  : DSP_OUT <= 8'h55;			 // Test value
	endcase
end

// --------------------------------------------------------------------
// Instantiate Register OUT Latch
// --------------------------------------------------------------------
always @(posedge CLK2) begin 	
	if(!GENRST) 	OUT <= 16'h0000; 
	else if(!WA11)	OUT <= WRITE_BUS; 
end 

assign OUT_BUS = OUT;
assign OUT8		= OUT[7];

// --------------------------------------------------------------------
// Panel output assignements
// --------------------------------------------------------------------
wire [7:0] PANEL;
assign PANEL[7] = OUT[7];	// Output 8
assign PANEL[6] = STBY;		// Standby signal 
assign PANEL[5] = PARALM;	// Parity Alarm
assign PANEL[4] = OUT[4];	// Processor Alarm
assign PANEL[3] = OUT[3];	// Operator Error
assign PANEL[2] = OUT[2];	// Key Release
assign PANEL[1] = OUT[1];	// Uplink
assign PANEL[0] = OUT[0];	// Computer activity 

// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------

// --------------------------------------------------------------------
// 5 Bit DSP code to BCD COde Converter
// --------------------------------------------------------------------
module DSPtoBCD(
	input			[4:0] DSP,
	output reg	[3:0] BCD
);

always @(DSP) begin
	case(DSP)
		5'b00000: BCD = 4'b1111;	// Blank
		5'b10101: BCD = 4'b0000;	// 0
		5'b00011: BCD = 4'b0001;	// 1
		5'b11001: BCD = 4'b0010;	// 2
		5'b11011: BCD = 4'b0011;	// 3
		5'b01111: BCD = 4'b0100;	// 4
		5'b11110: BCD = 4'b0101;	// 5
		5'b11100: BCD = 4'b0110;	// 6
		5'b10011: BCD = 4'b0111;	// 7
		5'b11101: BCD = 4'b1000;	// 8
		5'b11111: BCD = 4'b1001;	// 9
		default:  BCD = 4'b1111;	// Blank
	endcase
end

// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------

