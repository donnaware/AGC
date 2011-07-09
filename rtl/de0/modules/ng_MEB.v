// --------------------------------------------------------------------
// ng_MEB.v - Combination Memory, G Register and Buffer Mux 
// 
// This module is a combination of the MEM and MBF modules in the 
// Original Pultorak design. The Parity Checker is also added in
// Since that is super simple to do in verilog.
// --------------------------------------------------------------------
`include "ControlPulses.h"
// --------------------------------------------------------------------
module ng_MEB(
	input  						CLK2,				// Clock Pulse 2
	input   		[  5:0]		SELECT,			// Select Input
	input  		[ 15:0]		WRITE_BUS,		// Control Pulse
	input       [ 13:0]		Address,			// Address Input
	input  		[100:0]		CP,				// Control Pulse
	input  						CLR_PARALM,		// Clear Parity Alarm
	output  		[15:0]		MEM_BUS,			// MEB Output Port 
	output						PARALM 			// Parity Alarm Output
);

assign MEM_BUS[15  ] = G_REG[15  ];			// Assign output 
assign MEM_BUS[14  ] = G_REG[15  ];
assign MEM_BUS[13:0] = G_REG[13:0];

// --------------------------------------------------------------------
// negative logic, IF GTR_1777== 0. then ADDR > o1777) (ROM) ELSE RAM
// --------------------------------------------------------------------
wire	GTR_1777 = SELECT[`SLX(`GTR_1777)];	// Greater than Octal 1777 signal

// --------------------------------------------------------------------
// MEM Module: This section replaces the old MEM module
// RAM and ROM instantiated using Altera Megafunctions
// --------------------------------------------------------------------
wire [15:0] RAM_OUT;
wire [15:0] ROM_OUT;
RAM RAM_u1(.clock(CLK2),.address(Address[9:0]),.q(RAM_OUT),.data(MEM_IN),.wren(wr_en));
ROM ROM_u1(.clock(CLK2),.address(Address)     ,.q(ROM_OUT));

wire wr_en = !WE & GTR_1777;  // if GTR_1777==1, addr <= o1777

// --------------------------------------------------------------------
// SBWG WRITE G (MEM) 0=read eraseable or fixed memory onto memory bus
// --------------------------------------------------------------------
wire [15:0] MEM_OUT = GTR_1777 ?  RAM_OUT :  ROM_OUT;
wire  		 MOUT16 = MEM_OUT[15];			// MSB is the parity bit

wire [15:0] MEM_IN;
assign  		MEM_IN[15  ] = PAR_16;			// Parity bit goes here
assign  		MEM_IN[14  ] = G_REG[15  ];	// Move the MSB into next spot
assign  		MEM_IN[13:0] = G_REG[13:0];	// The rest stay the same

// --------------------------------------------------------------------
// MBF Module: This section replaces the old MBF module
// --------------------------------------------------------------------
wire 	GENRST  		= CP[`CPX(`GENRST)];		// General reset signal
wire  WGX         = CP[`CPX(`WGX)];			// Write G (do not reset)
wire	WGN         = CP[`CPX(`WGN)];			// Write G (normal gates)
wire	W20      	= CP[`CPX(`W20)];			// Write into CYR
wire	W21       	= CP[`CPX(`W21)];			// Write into SR
wire	W22       	= CP[`CPX(`W22)];			// Write into CYL
wire	W23       	= CP[`CPX(`W23)];			// Write into SL
wire	SBWG        = CP[`CPX(`SBWG)];		// Write G from memory

wire MB_AW  		= !WGN | !WGX;				// Port A to G
wire MB_BW  		= !W21 | !W20;				// Port B to G
wire MB_CW  		= !W22 | !W23;				// Port C to G
wire MB_DW  		= !SBWG;						// Port D to G

wire MB_B16       = !(!(WRITE_BUS[ 0] & !W20) & !(WRITE_BUS[15] & W20));
wire MB_C16 		= !(!(WRITE_BUS[13] & !W22) & !(WRITE_BUS[15] & W22));

// --------------------------------------------------------------------
// Instantiate Register G Latch
// --------------------------------------------------------------------
reg	[ 15:0]	G_REG;			// G Register
wire [3:0] Sel = {MB_DW, MB_CW, MB_BW, MB_AW};
always @(posedge CLK2) begin 
	if(!GENRST) G_REG <= 16'h0000; 
	else begin
		case(Sel)
			4'b0001 : begin							// Selecting Port A, no shifting
				G_REG[15]    = WRITE_BUS[15];		// MSBit
				G_REG[14]    = 1'b1;					// Bit not used
				G_REG[13:0]  = WRITE_BUS[13:0];	// No Shifting
			end
		
			4'b0010 : begin							// Selecting Port B, shift
				G_REG[15]    = MB_B16;				// MSBit is B16
				G_REG[14]    = 1'b1;					// Bit not used
				G_REG[13] 	 = WRITE_BUS[15]; 	// Shifting top bit
				G_REG[12:0]  = WRITE_BUS[13:1];	// Shifting the rest of the bits
			end
		
			4'b0100 : begin							// Selecting Port C, rotate through LSB
				G_REG[15]    = MB_C16;				// MSBit
				G_REG[14]    = 1'b1;					// Bit not used
				G_REG[13:1]  = WRITE_BUS[12:0];	// Shifting rest of bits
				G_REG[0]		 = WRITE_BUS[15];		// Rotate into lower bit
			end
		
			4'b1000 : begin							// Selecting Port D, Memory mode
				G_REG[15]    = MEM_OUT[14];		// MSBit
				G_REG[14]    = 1'b1;					// Bit not used
				G_REG[13:0]  = MEM_OUT[13:0];		// No Shifting			
			end
		
			default : ;	  // Do nothing
		endcase
	end
end

// --------------------------------------------------------------------
// PAR Module: Parity Generator Checker Section
// --------------------------------------------------------------------
wire	CLG 		= CP[`CPX(`CLG)];				// CP signal - Clear G
wire	GP 		= CP[`CPX(`GP) ];				// CP signal - Generate Parity
wire	RP2 		= CP[`CPX(`RP2)];				// CP signal - Read parity 2 
wire	WP 		= CP[`CPX(`WP) ];				// CP signal - Write P
wire	WPX 		= CP[`CPX(`WPX)];				// CP signal - Write P (do not reset)
wire	WP2 		= CP[`CPX(`WP2)];				// CP signal - Write P2
wire	TP 		= CP[`CPX(`TP) ];				// CP signal - Test parity
wire	WE 		= CP[`CPX(`WE) ];				// CP signal - Write E-MEM from G
wire	RG 		= CP[`CPX(`RG) ];				// CP signal - Read G
wire	GTR_27 	= SELECT[`SLX(`GTR_27)];	// Get SELECT signal

// --------------------------------------------------------------------
// Register Storage
// --------------------------------------------------------------------
reg	[ 15:0]		P;			// Parity Register
reg	 				P2;		// P2 Register
reg	 				G15;		// G15 Register
reg	 				PALM;		// PALM Register

// --------------------------------------------------------------------
// Instantiate P Register 
// --------------------------------------------------------------------
always @(posedge CLK2) begin 	
	if(!GENRST) 			P <= 16'h0000; 
	else if(!WP | !WPX)  P <= {PR_D15, WRITE_BUS[15], WRITE_BUS[13:0]};
end 

wire Par_bit = ^P[14:0];				// Generate ODD Parity (was PR_P_15)
wire Par_Alm = Par_bit ^ P[15];		// Generate the alarm (was PR_1_15)

// --------------------------------------------------------------------
// Instantiate G15 Register 
// --------------------------------------------------------------------
wire	PR_WG15  	= !WGX | !SBWG | !GP | !RP2;  // Load on any of these
wire  PR_D0 		= !(P2 & !RP2) & !(Par_Alm & !GP) & !(MOUT16 & !SBWG) & !(Par_Alm & !WGX);
 
always @(posedge CLK2) 
	if(!CLG) 			G15 <= 1'b0; 	// Clear G15 register
	else if(PR_WG15)	G15 <= PR_D0;	// Load  G15 register

wire PR_D15	= G15 & !RG;
wire PAR_16 = G15;			// no mux or gate needed due dedicated input port for ram

// --------------------------------------------------------------------
// Instantiate P2 Register 
// --------------------------------------------------------------------
always @(posedge CLK2)  
	if(!GENRST) 	P2 <= 1'b0; 	// Clear P2 register
	else if(!WP2)	P2 <=	Par_Alm;	// Load  P2 register

// --------------------------------------------------------------------
// Instantiate Register PALM Latch, 
// --------------------------------------------------------------------
wire	PR_WPLM = !TP & !GTR_27 &  Par_Alm;
always @(posedge CLK2)  
	if(!CLR_PARALM | !GENRST)  PALM <= 1'b0; 
	else if(PR_WPLM)           PALM <= Par_Alm;

assign PARALM = PALM;

// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------
