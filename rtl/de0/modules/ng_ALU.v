// --------------------------------------------------------------------
// ng_ALU - Arithmetic Logic Unit Module
// --------------------------------------------------------------------
`include "ControlPulses.h"
// --------------------------------------------------------------------
module ng_ALU(
	input  						CLK2,				// Clock Pulse 2
	input  		[100:0]		CP,				// Control Pulse
	input  		[ 15:0]		WRITE_BUS,		// Write input bus
	output  		[ 15:0]		ALU_OUT			// ALU output
);

// --------------------------------------------------------------------
// Control signal definitions
// --------------------------------------------------------------------
wire  WB			= CP[`CPX(`WB)];	// Write B
wire  WX			= CP[`CPX(`WX)];	// Write X
wire  WY			= CP[`CPX(`WY)];	// Write Y
wire  WYX		= CP[`CPX(`WYX)];	// Write Y (do not reset)
wire  CI			= CP[`CPX(`CI)];	// Carry in
wire  RB			= CP[`CPX(`RB)];	// Read B
wire  RC			= CP[`CPX(`RC)];	// Read C
wire  RU			= CP[`CPX(`RU)];	// Read SUM

// --------------------------------------------------------------------
// Register Storage
// --------------------------------------------------------------------
reg   [15:0] B;     // A Register
reg   [15:0] X;     // Q Register
reg   [15:0] Y;     // Z Register
reg          C;     // C Register

// --------------------------------------------------------------------
// Instantiate Registers: B, X, Y  and CI
// --------------------------------------------------------------------
always @(posedge CLK2) 
	if(!WB) B <= WRITE_BUS;  			// Load reg B on WB assertion

always @(posedge CLK2) 
	if(!WY | !WYX) Y <= WRITE_BUS;  	// Load reg Y on either assertion
	
always @(posedge CLK2) 
   if(!WY)      X <= 16'h0000;   	// Clear reg X on WY assertion
   else if(!WX) X <= WRITE_BUS;  	// Load reg X on WX assertion

always @(posedge CLK2) 
   if(CI & !WY) C <= 1'b0;   			// Clear CI register
   else if(!CI) C <= 1'b1;   			// Set CI register 

// --------------------------------------------------------------------
// 16 bit adder function  
//
//  111 1100 0000 0000   
//  432 1098 7654 3210
//  111 1111 1111 1111
// --------------------------------------------------------------------
wire        C_In  = EOC | C; 		  // Carry in is from last time
wire        C_Out = SUM[16];		  // Carry bit is the 17th bit 
wire [16:0] SUM   = {1'b0,X} + {1'b0,Y} + {16'h0,C_In};   // B side of ALU

// --------------------------------------------------------------------
// Carry out register 
// NOTE: A JK FF instantiated as equivalent D Reg
// always@(negedge CLK) Q <= ~Q & D | Q & D;
// --------------------------------------------------------------------
reg  EOC; 		// Register
reg  EOC_Q; 	// Register
always@(posedge CLK2) EOC_Q <= C_Out;
always@(negedge CLK2) EOC   <= EOC_Q;

// --------------------------------------------------------------------
// ALU Function generator:
// A and B are 16 bit inputs. Result in F.
// Slection is as follows:
// 
//	RB	RC	RU	 Func
//  0  0  0   A
//  0  0  1   A
//  0  1  0   A
//  0  1  1   A
//  1  0  0  !A + B
//  1  0  1  !A
//  1  1  0   B
//  1  1  1   Logic 0
// --------------------------------------------------------------------
wire [15:0] A_in = B;					//	A side of ALU is B reg
wire [15:0] B_in = SUM[15:0];		   //	B side of ALU is sum
reg  [15:0] Func;							// Function Output 
wire [2:0] sel_cntl = {RB, RC, RU}; // Function selection bits
always @(A_in or B_in or sel_cntl)  begin
	case(sel_cntl)
	    3'b000: Func =  A_in;			// 0 - Identity A, F outputs whatever is on A
	    3'b001: Func =  A_in;			// 1 - Identity A
	    3'b010: Func =  A_in;			// 2 - Identity A
	    3'b011: Func =  A_in;			// 3 - Identity A
	    3'b100: Func = ~A_in | B_in;	// 4 - Compliment A and Add to B, no carry out	
	    3'b101: Func = ~A_in;			// 5 - Bitwise complinebt if A
	    3'b110: Func =  B_in;			// 6 - Identity B, F outputs whatever is on B	
	    3'b111: Func = 16'h0000;		// 7 - Output is zero
	endcase
end
assign ALU_OUT = Func; // Make output assignment

// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------


