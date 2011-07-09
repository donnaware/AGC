// --------------------------------------------------------------------
// ng_AGC CPM Micro code ROM decoder
//
// altera message_off 10030
// above commands gets rid of the warning about not initializing the ROM
//
// --------------------------------------------------------------------
`include "ControlPulses.h"
// --------------------------------------------------------------------
module ng_CPM(
	input  					CLK2,				// Clock Pulse 2
	input		[  3:0]		TPG,				// Time Pulses
	input						SNI,				// Select Next instruction
	input						STB0,				// Stage 0
	input						STB1,				// Stage 1
	input						BR1,				// Branch 1
	input						BR2,				// Branch 2
	input		[  3:0]		SQ,				// Sequence Pulses
	input						LOOP6,			// Loop Instruction
	input						SB01,				// Sub-Select 1
	input						SB02,				// Sub-Select 2
	input						IRQ,				// Interrupt Request
	input   [ 13:0]		Address,			// Address Input
	input   [  5:0]		Select,			// Select Input
	output  [100:0]		CP,				// Control Pulse
	output  [  7:0]		SUBSEQ,			// Sub-Sequence output
	output  [ 15:0]		PROBE_SEQ		// JTAG Probe output
);
// --------------------------------------------------------------------
// Debugging Output assignments:
// --------------------------------------------------------------------
assign SUBSEQ    = {SB02, SB01, SQ, STB1, STB0};  
assign PROBE_SEQ = {IRQ, LOOP6, SUBSEQ, TPG, BR1, BR2};	

// --------------------------------------------------------------------
// TPG Cycle Detection (Negative Logic)
// --------------------------------------------------------------------
wire		NSTBY		= !(TPG == `TP_Standby);	// Standby mode
wire		NPWRON	= !(TPG == `TP_PowerOn);	// Power on reset, Put the starting address on the read bus
wire		NTP1		= !(TPG == `TP_1      );	// Time pulse = TP1
wire		NTP5		= !(TPG == `TP_5      );	// Time pulse = TP5
wire		NTP6		= !(TPG == `TP_6      );	// Time pulse = TP6
wire		NTP11		= !(TPG == `TP_11     );	// Time pulse = TP11
wire		NTP12		= !(TPG == `TP_12     );	// Time pulse = TP12

// --------------------------------------------------------------------
// Address Selection Wires Detection (Negative Logic)
// --------------------------------------------------------------------
wire		GTR_1777	= Select[`SLX(`GTR_1777)];	// Wire from select bus
wire		GTR_27	= Select[`SLX(`GTR_27)];	// Wire from select bus
wire		GTR_17	= Select[`SLX(`GTR_17)];	// Wire from select bus
wire		EQU_17	= Select[`SLX(`EQU_17)];	// Wire from select bus
wire		EQU_16	= Select[`SLX(`EQU_16)];	// Wire from select bus

// --------------------------------------------------------------------
// CPM-A: This section decodes CP lines 0 - 55
// In the pultorac AGC replica, the CPM-A subsequences are implemented in 
// EPROM (they were implemented as a diode matrix in the original). The 
// address into the EPROM is constructed as follows (bit 1 is the LSB):
// bits
// 13..12   SB2, SB1    CTR subsequence 
// 11.. 8   SQ[3..0]    register 
//  7.. 6   STB1, STB0  registers 
//  5.. 2   SG[3..0]    register 
//  1.. 0   BR1, BR2    registers
//
// Bits 7-14 (STB, SQ, and CTR) select the instruction subsequence. Bits 1-6 select the control
// pulses (control logic signals) that are asserted from that subsequence
// --------------------------------------------------------------------
wire   [55:0]	Q;						// Micro Decoder output
wire   [13:0]	CodeAddr;			// Decoder address

assign 	CodeAddr[13  ] = SB02;		// Form up the decoder address 10 1111 1110 1100
assign 	CodeAddr[12  ] = SB01;		// Form up the decoder address
assign	CodeAddr[11:8] = SQ[3:0];	// Form up the decoder address
assign 	CodeAddr[   7] = STB1;		// Form up the decoder address
assign	CodeAddr[   6] = STB0;		// Form up the decoder address
assign 	CodeAddr[ 5:2] = TPG[3:0];	// Form up the decoder address
assign 	CodeAddr[   1] = BR1;		// Form up the decoder address
assign 	CodeAddr[   0] = BR2;		// Form up the decoder address

initial $readmemb("CPM_binary.dat", rom);	// Initialize 
reg [55:0] rom[0:16383]; 						// ROM Registers
assign Q = rom[CodeAddr];		  				// Micro Code address

assign	CP[ 1: 0] = Q[ 1: 0];
assign	CP[    2] = Q[ 2   ] & LOOP6; 					 // CLCTR
assign	CP[ 7: 3] = Q[ 7: 3];
assign	CP[    8] = Q[ 8   ] & !(IRQ & SNI & !NTP12); // RB
assign	CP[25: 9] = Q[25: 9];
assign	CP[   26] = Q[26   ] & LOOP6; 					 // ST2
assign	CP[34:27] = Q[34:27];
assign	CP[   35] = Q[35   ] & NPWRON; 			 		 // WB 
assign	CP[55:36] = Q[55:36];

// --------------------------------------------------------------------
// CPM-B: This section decodes CP lines 56 - 84, which has to do with
// reading and writting to the special registers and handling in low
// memory address space.
// --------------------------------------------------------------------
wire		RSC		= CP[`CPX(`RSC)];		// Read special and central (output to B only, not outside CPM) 
wire		WSC		= CP[`CPX(`WSC)];		// Write special and central (output to B only, not outside CPM)
wire		WG			= CP[`CPX(`WG)];		// Write G (output to B only, not outside CPM)

// --------------------------------------------------------------------
// Decodes addresses 0 to 16, just use simple look up table
// These are special registers
// --------------------------------------------------------------------
wire [3:0] addr_16 = Address[3:0]; // Addresses 0 to 16

reg  [13:0] N_RCP;	// read register pulses 
always @(addr_16 or GTR_17 or RSC) begin 
	if(GTR_17 & !RSC)       // addr_16 <= o17 remeber our negative logic !
		case(addr_16)   
			4'd0   : N_RCP <= 14'b11111111111110;
			4'd1   : N_RCP <= 14'b11111111111101;
			4'd2   : N_RCP <= 14'b11111111111011;
			4'd3   : N_RCP <= 14'b11111111110111;
			4'd4   : N_RCP <= 14'b11111111101111;
			4'd5   : N_RCP <= 14'b11111111011111;
			4'd6   : N_RCP <= 14'b11111110111111;
			4'd7   : N_RCP <= 14'b11111101111111;
			4'd8   : N_RCP <= 14'b11111011111111;
			4'd9   : N_RCP <= 14'b11110111111111;
			4'd10  : N_RCP <= 14'b11101111111111;
			4'd11  : N_RCP <= 14'b11011111111111;
			4'd12  : N_RCP <= 14'b10111111111111;
			4'd13  : N_RCP <= 14'b01111111111111;
			default: N_RCP <= 14'b11111111111111; 			
		endcase 
	else           N_RCP <= 14'b11111111111111; 
end 
assign CP[69:56] = N_RCP[13:0];	// Make next 14 output assignments

reg  [9:0] N_WCP;		// write register pulses
always @(addr_16 or GTR_17 or WSC) begin 
	if(GTR_17 & !WSC)       // addr <= o17 remeber our negative logic !
		case(addr_16)        
			4'd0   : N_WCP <= 10'b1111111110;
			4'd1   : N_WCP <= 10'b1111111101;
			4'd2   : N_WCP <= 10'b1111111011;
			4'd3   : N_WCP <= 10'b1111110111;
			4'd8   : N_WCP <= 10'b1111101111;
			4'd9   : N_WCP <= 10'b1111011111;
			4'd10  : N_WCP <= 10'b1110111111;
			4'd11  : N_WCP <= 10'b1101111111;
			4'd12  : N_WCP <= 10'b1011111111;
			4'd13  : N_WCP <= 10'b0111111111;
			default: N_WCP <= 10'b1111111111; 			
		endcase 
	else           N_WCP <= 10'b1111111111; 
end 
assign CP[79:70] = N_WCP[9:0];	// Make next 10 output assignments

// --------------------------------------------------------------------
// Decodes addresses 20 to 23, just use simple look up table
// These are special memory locations that do bit wise rotations
// --------------------------------------------------------------------
wire [2:0] addr_8 = Address[2:0]; // Addresses 0 to 8
reg  [3:0] N_GCP;					    // addresses 20 to 23 special memory locations
always @(addr_8 or GTR_17 or GTR_27 or WG) begin 
	if(!GTR_17 & GTR_27 & !WG) // o17 < addr < o27
		case(addr_8)         // 4321
			3'd0   : N_GCP <= 4'b1110;
			3'd1   : N_GCP <= 4'b1101;
			3'd2   : N_GCP <= 4'b1011;
			3'd3   : N_GCP <= 4'b0111;
			default: N_GCP <= 4'b1111; 			
		endcase 
	else           N_GCP <= 4'b1111; 
end 
assign	CP[84:81] = N_GCP;	// Make next  4 output assignments

// --------------------------------------------------------------------
// WGN (Write G (normal gates) Logic
// --------------------------------------------------------------------
wire WGN = WG | GTR_17 | !(&N_GCP);  	// Special CP=80	
assign	CP[`CPX(`WGN)] = WGN;			// Make WGN output assignment	

// --------------------------------------------------------------------
// CPM-C: This section decodes CP lines 85 - 100
// --------------------------------------------------------------------
wire		SDV1		= CP[`CPX(`SDV1)];			// Subsequence DV1 is currently active
wire		SMP1		= CP[`CPX(`SMP1)];			// Subsequence MP1 is currently active
wire		SRSM3		= CP[`CPX(`SRSM3)];			// Subsequence RSM3 is currently active

wire		LT1777 	= !(SMP1 & SDV1 & !GTR_1777);
wire		GTLT17 	= !(SMP1 & SDV1 &  GTR_1777 & !GTR_17);

wire		GENRST	= NSTBY; 											// General Reset
wire		CLINH 	= NTP5 | EQU_16;									// Clear INHINT*
wire		CLINH1 	= !(!NTP12 & SNI);								// Clear INHINT1
wire		CLSTA 	= WSQ & WSTB;										// Clear state counter A (STA)
wire		CLSTB 	= !(SNI & !NTP12 & IRQ);						// Clear state counter B (STB)
wire		CLISQ 	= NTP1;												// Clear SNI
wire		CLRP 		= NTP11 | SRSM3;									// Clear RPCELL
wire		INH 		= NTP5 | EQU_17;									// Set INHINT
wire		RPT 		= SETSTB;											// Read RUPT opcode
wire		SBWG 		= !(!(NTP6 | LT1777) | !(NTP5 | GTLT17));	// Write G from memory
wire		SETSTB	= !(SNI & !IRQ & !NTP12);						// Set the ST1 bit of STB
wire		WE 		= NTP11 | GTLT17;									// Write E-MEM from G
wire		WPCTR 	= NTP12;												// Write PCTR (latch priority counter sequence)
wire		WSQ 		= NTP12 | !SNI;									// Write SQ
wire		WSTB     = !(!(NTP12 | SNI) & !(SB01 | SB02));		// Write stage counter B (STB)
wire		R2000 	= NPWRON; 											// Read 2000

assign	CP[`CPX(`GENRST)] = GENRST;	// General Reset
assign	CP[`CPX(`CLINH) ] = CLINH;		// Clear INHINT
assign	CP[`CPX(`CLINH1)] = CLINH1;	// Clear INHINT1
assign	CP[`CPX(`CLSTA) ] = CLSTA;		// Clear state counter A (STA)
assign	CP[`CPX(`CLSTB) ] = CLSTB;		// Clear state counter B (STB)
assign	CP[`CPX(`CLISQ) ] = CLISQ;		// Clear SNI
assign	CP[`CPX(`CLRP)  ] = CLRP;		// Clear RPCELL
assign	CP[`CPX(`INH)   ] = INH;		// Set INHINT
assign	CP[`CPX(`RPT)   ] = RPT;		// Read RUPT opcode
assign	CP[`CPX(`SBWG)  ] = SBWG;		// Write G from memory
assign	CP[`CPX(`SETSTB)] = SETSTB;	// Set the ST1 bit of STB
assign	CP[`CPX(`WE)    ] = WE;			// Write to Eraseable MEM from G
assign	CP[`CPX(`WPCTR) ] = WPCTR;		// Write PCTR (latch priority counter sequence)
assign	CP[`CPX(`WSQ)   ] = WSQ;		// Write SQ
assign	CP[`CPX(`WSTB)  ] = WSTB;		// Write stage counter B (STB)
assign	CP[`CPX(`R2000) ] = R2000;		// Read 2000, Put the starting address on the read bus
	
// --------------------------------------------------------------------
endmodule
// --------------------------------------------------------------------

