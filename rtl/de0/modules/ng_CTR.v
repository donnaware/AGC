// --------------------------------------------------------------------
// ng_CTR.v - PRIORITY COUNTER
//
// Read Bus: (octal counter addr)
//    34 = cntr 1 (OVCTR)
//    35 = cntr 2 (TIME2)
//    36 = cntr 3 (TIME1)
//    37 = cntr 4 (TIME3) 
//    40 = cntr 5 (TIME4)
//
//  SB2  SB1
//   0   0    no counter or PINC and MINC simul active
//   0   1    PINC
//   1   0    MINC
//   1   1    not allowed
//
// --------------------------------------------------------------------
`include "ControlPulses.h"
// --------------------------------------------------------------------
module ng_CTR(
	input  						CLK2,				// Clock Pulse 2
	input  		[100:0]		CP,				// Control Pulse
	input  		[ 15:0]		WRITE_BUS,		// Control Pulse
	input 						F10X,				// Clock divided by 10
	output						SB01,SB02,		// Sequence Bus
	output 		[ 15:0]		CTR_BUS,			// CTR Module output
	output						CPO4,CPO5		// Counter P Overflow
);

// --------------------------------------------------------------------
// JTAG Debugging Probes
// --------------------------------------------------------------------
//                                 1    1      3        5           5       1
// JTAG_Probe	CTR_TST16(.probe ( { CPO5, CPO4, sel_ctr, pri_level, plus_in, min_in} ));
//                             15  14   13 12  11     10  9     8 7 6    5      4      3   2      1         0
JTAG_Probe	CTR_TST2(.probe({CPO5,CPO4, Yp,Ym,WOVR, SIGN,OVER, sel_ctr, WOVC, WPCTR, SB02,SB01, CT_P2P, plus_in[2]} ));

JTAG_Source1 Sourc1_F10X(.probe(F10X),.source(iF10X));
wire iF10X;
wire sTime1 = iF10X;
wire sTime2 = iF10X;
wire sTime4 = iF10X;

// --------------------------------------------------------------------
// General Control Signals
// --------------------------------------------------------------------
wire 	GENRST  		= CP[`CPX(`GENRST)];		// General reset signal
wire  WPCTR       = CP[`CPX(`WPCTR) ];		// Write PCTR (latch priority counter sequence)
wire  WOVC        = CP[`CPX(`WOVC)  ];		// Write overflow counter
wire  WOVR        = CP[`CPX(`WOVR)  ];		// Write overflow
wire  OVER    		= WRITE_BUS[14];			// bit 14 set is overflow condition
wire  SIGN    		= WRITE_BUS[15];			// bit 15 set is negative number

// --------------------------------------------------------------------
// Counter Trigger Registers
// 
// NOTE: JK FF can be instantiated using this code:
// always@(negedge CLK or negedge CLN or negedge PRN) 
//    if     (!CLN) Q <= 0;
//    else if(!PRN) Q <= 1;
//    else          Q <= ~Q & J | Q & ~K;
// --------------------------------------------------------------------
reg	[4:0]	plus_in_i;	 		// Plus  increment Register
reg	[4:0]	plus_in;	 		// Plus  increment Register
reg			min_in_i ; 		// Minus increment Register
reg			min_in ; 		// Minus increment Register

wire CT_RST = !(!GENRST & CLK2);
wire CT_RT2 = CT_RST & resetP[1];
wire CT_RT1 = CT_RST & resetP[2];
wire CT_RT3 = CT_RST & resetP[3];
wire CT_RT4 = CT_RST & resetP[4];

always @(posedge CT_P2P or negedge CT_RT2) 
   if(!CT_RT2) 		plus_in_i[1] <= 1'b0;
   else if(!CT_P2P)	plus_in_i[1] <= 1'b1;
always @(negedge CT_P2P or negedge CT_RT2) plus_in[1] <= plus_in_i[1]; 

always @(posedge F10X or negedge CT_RT1 or posedge sTime1) 
   if(!CT_RT1)     	plus_in_i[2] <= 1'b0;
	else if(sTime1) 	plus_in_i[2] <= 1'b1;
   else if(F10X)   	plus_in_i[2] <= 1'b1;
always @(negedge F10X or negedge CT_RT1 or posedge sTime1) plus_in[2] <= plus_in_i[2]; 

always @(posedge F10X or negedge CT_RT3 or posedge sTime2) 
   if(!CT_RT3)     	plus_in_i[3] <= 1'b0;
	else if(sTime2) 	plus_in_i[3] <= 1'b1;
   else if(F10X)   	plus_in_i[3] <= 1'b1;
always @(negedge F10X or negedge CT_RT3 or posedge sTime2) plus_in[3] <= plus_in_i[3]; 

always @(posedge F10X or negedge CT_RT4 or posedge sTime4) 
   if(!CT_RT4)     	plus_in_i[4] <= 1'b0;
	else if(sTime4) 	plus_in_i[4] <= 1'b1;
   else if(F10X)   	plus_in_i[4] <= 1'b1;
always @(negedge F10X or negedge CT_RT4 or posedge sTime4) plus_in[4] <= plus_in_i[4]; 
	
// --------------------------------------------------------------------
// Overflow Counter section
// --------------------------------------------------------------------
wire CT_R1P = CT_RST & resetP[0];
wire CT_P1P  = !(!SIGN & OVER & CLK2 & !WOVC);
always @(posedge CT_P1P or negedge CT_R1P) // OVCTR
   if(!CT_R1P)         plus_in_i[0] <= 1'b0;
   else if(!CT_P1P)	  plus_in_i[0] <= 1'b1;
always @(negedge CT_P1P or negedge CT_R1P) plus_in[0] <= plus_in_i[0]; 

wire CT_R1M = CT_RST & resetM;
wire CT_P1M  = !(SIGN & !OVER & CLK2 & !WOVC);
always @(posedge CT_P1M or negedge CT_R1M) // OVCTR
   if(!CT_R1M)         min_in_i <= 1'b0;
   else if(!CT_P1M)	  min_in_i <= 1'b1;
always @(negedge CT_P1M or negedge CT_R1M) min_in <= min_in_i; 
	
// --------------------------------------------------------------------
// Register Storage
// --------------------------------------------------------------------
reg	[4:0]		plus_cnt;		// Plus  Count Sync Register
reg	  			min_cnt;	 	 	// Minus Count Sync Register

// --------------------------------------------------------------------
// Instantiate Plus Count and Minus Count Registers
// --------------------------------------------------------------------
always @(posedge CLK2) begin 
	if(!GENRST) begin
		plus_cnt <= 5'h00;	 	// Clear to 0
		min_cnt  <= 1'b0;	 		// Clear to 0
	end
	else if(!WPCTR) begin		// was !(!WPCTR  & CLK2);
		plus_cnt <= plus_in; 	// Load 
		min_cnt  <= min_in; 		// Load 
	end
end 

// --------------------------------------------------------------------
// Prioritize 
// --------------------------------------------------------------------
wire [4:0] pri_level;
assign  pri_level[4] = plus_cnt[0] | min_cnt; // Highest Priority level
assign  pri_level[3] = plus_cnt[1];				 // Higher
assign  pri_level[2] = plus_cnt[2];				 // Medium
assign  pri_level[1] = plus_cnt[3];				 // Lower
assign  pri_level[0] = plus_cnt[4];				 // Lowest Priority level

reg  [2:0] sel_ctr;	// selected counter
always @(pri_level) begin 
	casex(pri_level) 
		5'b1XXXX : sel_ctr <= 3'b000;  // priority 1, selctr = 0, highest
		5'b01XXX : sel_ctr <= 3'b001;  // priority 2, selctr = 1 
		5'b001XX : sel_ctr <= 3'b010;  // priority 3, selctr = 2
		5'b0001X : sel_ctr <= 3'b011;  // priority 4, selctr = 3
		5'b00001 : sel_ctr <= 3'b100;  // priority 5, selctr = 4, lowest
		default  : sel_ctr <= 3'b111;  // priority X, selctr = 7, default case
	endcase 
end 
wire sel_EO = |pri_level;	// ==1 if were any active

assign CTR_BUS = 16'o0034 + sel_ctr;  // Map to registers o34 - o40

// --------------------------------------------------------------------
// PINC mux & MINC mux
// --------------------------------------------------------------------
reg Yp;
always @(sel_ctr or sel_EO or plus_cnt) begin 
	if(sel_EO) 
		case(sel_ctr) 
			3'b000  : Yp <= plus_cnt[0];  // priority 1, selctr = 0
			3'b001  : Yp <= plus_cnt[1];  // priority 2, selctr = 1 
			3'b010  : Yp <= plus_cnt[2];  // priority 3, selctr = 2
			3'b011  : Yp <= plus_cnt[3];  // priority 4, selctr = 3
			3'b100  : Yp <= plus_cnt[4];  // priority 5, selctr = 4
			default : Yp <= 1'b0;  			// priority X, selctr = 7
		endcase 
	else Yp <= 1'b0; 
end

reg Ym;
always @(sel_ctr or sel_EO or min_cnt) begin 
	if(sel_EO) 
		case(sel_ctr) 
			3'b000  : Ym <= min_cnt;  // priority 1, selctr = 0
			default : Ym <= 1'b0;  	  // priority X, selctr = 7
		endcase 
	else Ym <= 1'b0; 
end

assign SB01 = !(!Yp |  Ym);
assign SB02 = !( Yp | !Ym);

// Yp Ym SB1 SB2
// 0  0   0   0 
// 0  1   0   1
// 1  0   1   0 <-
// 1  1   0   0
//

// --------------------------------------------------------------------
// Reset Logic; PINC, MINC demux 
// --------------------------------------------------------------------
reg  [4:0] resetP;	// PINC dmx
always @(posedge CLK2) begin 
	if(!WOVR & Yp) begin 
		case(sel_ctr) 
			3'b000 : resetP <= 5'b11110;		// Priority 1
			3'b001 : resetP <= 5'b11101;		// Priority 2
			3'b010 : resetP <= 5'b11011;		// Priority 3
			3'b011 : resetP <= 5'b10111;		// Priority 4
			3'b100 : resetP <= 5'b01111;		// Priority 5
			default: resetP <= 5'b11111; 		// Priority 7
		endcase 
	end 
	else resetP <= 5'b11111; 
end 

reg  		  resetM;	// MINC dmx
always @(posedge CLK2) begin 
	if(!WOVR & Ym) begin 
		case(sel_ctr) 
			3'b000 : resetM <= 1'b0;		// Priority 1
			default: resetM <= 1'b1; 		// Priority X
		endcase 
	end 
	else resetM <= 1'b1; 
end 

// --------------------------------------------------------------------
// Control pulse Logic: 
// --------------------------------------------------------------------
wire CT_EP = !SIGN & OVER & !WOVR;
reg  [2:0] ctr_ovr;				// Cntr P Overflow
always @(posedge CLK2) begin  
	if(CT_EP) begin 
		case(sel_ctr) 			// selected counter
			3'd2   : ctr_ovr <= 3'b110;
			3'd3   : ctr_ovr <= 3'b101;
			3'd4   : ctr_ovr <= 3'b011;
			default: ctr_ovr <= 3'b111; 
		endcase 
	end 
	else 	ctr_ovr <= 3'b111; 
end 
assign CPO4   = ctr_ovr[1];
assign CPO5   = ctr_ovr[2];
wire   CT_P2P = ctr_ovr[0];

// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------

