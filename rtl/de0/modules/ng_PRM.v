// --------------------------------------------------------------------
// ng_PRM Priority Mux - Bus Arbiter
// --------------------------------------------------------------------
`include "ControlPulses.h"
// --------------------------------------------------------------------
module ng_PRM(
	input  						CLK1,				// Clock Pulse 1
	input  		[100:0]		CP,				// Control Pulse
	input   		[  5:0]		SELECT,			// Select Input
	input  		[ 15:0]		INP_RD_BUS,		// INP READ BUS     01
	input  		[ 15:0]		OUT_RD_BUS,		// OUT READ BUS     02
	input  		[ 15:0]		ADR_RD_BUS,		// ADR READ BUS     03
	input  		[ 15:0]		MBF_RD_BUS,		// MBF READ BUS     04
	input  		[ 15:0]		CTR_RD_BUS,		// CRT READ BUS     05
	input  		[ 15:0]		INT_RD_BUS,		// INT READ BUS     06
	input  		[ 15:0]		AREG_RD_BUS,	// A REG READ BUS   07
	input  		[ 15:0]		LPREG_RD_BUS,	// LP REG READ BUS  08
	input  		[ 15:0]		QREG_RD_BUS,	// Q REG READ BUS   09
	input  		[ 15:0]		ZREG_RD_BUS,	// Z REG READ BUS   10
	input  		[ 15:0]		ALU_RD_BUS,		// ALU READ BUS     11
	output 		[ 15:0]		WRITE_OUT_BUS	// Write Output bus
);


// --------------------------------------------------------------------
// Assign Control Signals
// --------------------------------------------------------------------
wire  RA		 = CP[`CPX(`RA)];			  // CP signal - Read A
wire  RG     = CP[`CPX(`RG)];			  // CP signal - Read G
wire	RLP	 = CP[`CPX(`RLP)];		  // CP signal - Read LP
wire	RQ		 = CP[`CPX(`RQ)];			  // CP signal - Read Q
wire	RRPA   = CP[`CPX(`RRPA)];		  // CP signal - Read RUPT address
wire	RSCT   = CP[`CPX(`RSCT)];		  // CP signal - Read selected counter address
wire	RZ		 = CP[`CPX(`RZ)];			  // CP signal - Read Z
wire  RA0	 = CP[`CPX(`RA0)];		  // CP signal - Read register at address 0 (A)
wire	RA1	 = CP[`CPX(`RA1)];		  // CP signal - Read register at address 1 (Q)
wire	RA2	 = CP[`CPX(`RA2)];		  // CP signal - Read register at address 2 (Z)
wire	RA3	 = CP[`CPX(`RA3)];		  // CP signal - Read register at address 3 (LP)
wire	RA4    = CP[`CPX(`RA4)];		  // CP signal - Read register at address 4
wire	RA11   = CP[`CPX(`RA11)];		  // CP signal - Read register at address 11 (octal) 
wire	RBK    = CP[`CPX(`RBK)];		  // CP signal - Read BANK
wire	GTR_17 = SELECT[`SLX(`GTR_17)]; // Select Bus Signal

// --------------------------------------------------------------------
// 11 x 16 mux with default 0
// This section replaces the tri-state logic with a mux, the default
// is to place ALU output on Read bus on negative edge of CLK1
// --------------------------------------------------------------------
wire  EN_INP   =  RA4;  				// if==0, select INP Bus
wire  EN_OUT   =  RA11; 				// if==0, select OUT
wire  EN_ADR   =  RBK;  				// if==0, select ADR
wire  EN_CTR   =  RSCT;  				// if==0, select CTR
wire  EN_INT   =  RRPA;  				// if==0, select INT
wire  EN_MBF   =  RG  | GTR_17;  	// if==0, select MBF
wire  EN_AREG  =  RA  & RA0; 			// if==0, select A Reg
wire  EN_QREG  =  RQ  & RA1; 			// if==0, select Q Reg
wire  EN_ZREG  =  RZ  & RA2; 			// if==0, select Z Reg
wire  EN_LPREG =  RLP & RA3; 			// if==0, select LP Reg

reg	[15:0]		READ_OUT_BUS;		// Read Output Register
wire [9:0] Sel = {EN_INP,EN_OUT,EN_ADR,EN_MBF,EN_CTR,EN_INT,EN_AREG,EN_LPREG,EN_QREG,EN_ZREG};
always @(Sel or INP_RD_BUS or OUT_RD_BUS or ADR_RD_BUS or MBF_RD_BUS or CTR_RD_BUS or INT_RD_BUS or AREG_RD_BUS or LPREG_RD_BUS or QREG_RD_BUS or ZREG_RD_BUS or ALU_RD_BUS) begin
//always @(posedge CLK1) begin
	case(Sel)        
		10'b1111111110 : READ_OUT_BUS = ZREG_RD_BUS;		// Z  REG BUS  0
		10'b1111111101 : READ_OUT_BUS = QREG_RD_BUS;		// Q  REG BUS  1
		10'b1111111011 : READ_OUT_BUS = LPREG_RD_BUS;	// LP REG BUS  2
		10'b1111110111 : READ_OUT_BUS = AREG_RD_BUS;		// A  REG BUS  3
		10'b1111101111 : READ_OUT_BUS = INT_RD_BUS;		// INT    BUS  4
		10'b1111011111 : READ_OUT_BUS = CTR_RD_BUS;		// CTR    BUS  5
		10'b1110111111 : READ_OUT_BUS = MBF_RD_BUS;		// MBF    BUS  6
		10'b1101111111 : READ_OUT_BUS = ADR_RD_BUS;		// ADR    BUS  7
		10'b1011111111 : READ_OUT_BUS = OUT_RD_BUS;		// OUT    BUS  8
		10'b0111111111 : READ_OUT_BUS = INP_RD_BUS;		// INP    BUS  9
		default        : READ_OUT_BUS = ALU_RD_BUS;		// ALU    BUS  default   
	endcase
end

// --------------------------------------------------------------------
// Bus Controller Sub-section
// --------------------------------------------------------------------
wire  RB14		= CP[`CPX(`RB14)];		// Read bit 14
wire  R1			= CP[`CPX(`R1)];			// Read 1
wire  R1C		= CP[`CPX(`R1C)];			// Read 1 complimented
wire  R2			= CP[`CPX(`R2)];			// Read 2
wire  RSB		= CP[`CPX(`RSB)];			// Read sign bit
wire  R22		= CP[`CPX(`R22)];			// Read 22
wire  R24		= CP[`CPX(`R24)];			// Read 24
wire  R2000		= CP[`CPX(`R2000)];			// Read 1 complimented

// --------------------------------------------------------------------
// Bus Control Section:
// This is where the Read Bus is put onto the write bus on CLK1.
// This OR'ing arrangement allows certain bits to be set by the 
// controler module.
//
//         1 111 110 000 000 000
// Signal  5 432 109 876 543 210        Octal
// ------- - --- --- --- --- ---       ------
// RB14    0 010 000 000 000 000  16'o 020000
// R1      0 000 000 000 000 001  16'o 000001
// R1C     1 111 111 111 111 110  16'o 177776
// R2      0 000 000 000 000 010  16'o 000002
// RSB     1 000 000 000 000 000  16'o 100000
// R22     0 000 000 000 010 010  16'o 000022
// R24     0 000 000 000 010 100  16'o 000024
// R2000   0 000 010 000 000 000  16'o 002000
// --------------------------------------------------------------------
assign WRITE_OUT_BUS[15] = READ_OUT_BUS[15] | !R1C | !RSB        ;
assign WRITE_OUT_BUS[14] = READ_OUT_BUS[14] | !R1C               ;
assign WRITE_OUT_BUS[13] = READ_OUT_BUS[13] | !R1C | !RB14       ;
assign WRITE_OUT_BUS[12] = READ_OUT_BUS[12] | !R1C               ;
assign WRITE_OUT_BUS[11] = READ_OUT_BUS[11] | !R1C               ;
assign WRITE_OUT_BUS[10] = READ_OUT_BUS[10] | !R1C | !R2000      ;
assign WRITE_OUT_BUS[ 9] = READ_OUT_BUS[ 9] | !R1C               ;
assign WRITE_OUT_BUS[ 8] = READ_OUT_BUS[ 8] | !R1C               ;
assign WRITE_OUT_BUS[ 7] = READ_OUT_BUS[ 7] | !R1C               ;
assign WRITE_OUT_BUS[ 6] = READ_OUT_BUS[ 6] | !R1C               ;
assign WRITE_OUT_BUS[ 5] = READ_OUT_BUS[ 5] | !R1C               ;
assign WRITE_OUT_BUS[ 4] = READ_OUT_BUS[ 4] | !R1C | !R22 | !R24 ;
assign WRITE_OUT_BUS[ 3] = READ_OUT_BUS[ 3] | !R1C               ;
assign WRITE_OUT_BUS[ 2] = READ_OUT_BUS[ 2] | !R1C |        !R24 ;
assign WRITE_OUT_BUS[ 1] = READ_OUT_BUS[ 1] | !R1C | !R2  | !R22 ;
assign WRITE_OUT_BUS[ 0] = READ_OUT_BUS[ 0] | !R1                ;

// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------

