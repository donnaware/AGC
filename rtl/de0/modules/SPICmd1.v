//-------------------------------------------------------------------------------------------------
// SPI slave module: The SPI bus is over-sampled using the FPGA clock to allow the SPI logic run 
// in the FPGA clock domain. Note FPGA FPGA clock must be at least 2x the SPI. Clock to synchronize 
// the SPI signals using the FPGA clock and shift registers. 
//
//  SPI Interface structure: 24 bit SPI interface, Bits are sent in most to least significant order
//  KeyPad, then address and finally data bits as follows:
//
//  23  22  21  20  19  18  17  16  15  14  13  12  11  10   9   8   7   6   5   4   3   2   1   0
//+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
//|KP4|KP3|KP2|KP1|KP0|SEL|RST|KEY|IS3|IS2|IS1|IS0|OS3|OS2|OS1|OS0| D7| D6| D5| D4| D3| D2| D1| D0| 
//+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
//   0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23
//
//  KeyPad bits have are defined as KP5 - KP1 
//-------------------------------------------------------------------------------------------------
module SPI_24_slave(
	input       		clk,              // System Clock
	input					SCK, 					// SPI Clock Input pin
	input					SSEL, 				// SPI Select Input pin
	input					MOSI,					// SPI Serial Input pin
	output				MISO,             // SPI output signal
	input					data_ready,			// Signal that data is ready to be sent out
	input			[7:0] DataOut,				// SPI data to send out
	output reg	[7:0] DataIn,				// SPI data received
	output reg	[4:0] KeyPad,				// Wires to register holding KeyPad
	output		[3:0] OutSel,           // Panel 
	output		[3:0] InSel,            // Panel 
	output				KEY,					// Keyboard valid signal. 
	output				RST,              // Panel 
	output				SEL,              // Panel 
	output reg			kbd_received,     // KeyPad bits received
	output reg			pnl_received,     // Panel bits received
	output reg			data_received,    // Data bits received
	output				SPI_Start,        // SPI Message start signal
	output				SPI_Active,       // SPI active Signal 
	output				SPI_End           // SPI message end signal
);

//-----------------------------------------------------------------------------
// Assign outputs
//-----------------------------------------------------------------------------
assign OutSel = Panel[3:0];
assign InSel  = Panel[7:4];
assign KEY 	  = Panel[8  ];
assign RST    = Panel[9  ];
assign SEL    = Panel[10 ];

//-----------------------------------------------------------------------------
// Find Rising edge of data ready line using a 3-bits shift register
//-----------------------------------------------------------------------------
reg [2:0] DRedge;  
always @(posedge clk) DRedge <= {DRedge[1:0], data_ready};
wire DR_risingedge  = (DRedge[2:1] == 2'b01);      // now we can detect DR rising edge

//-----------------------------------------------------------------------------
// Sync SCK to the FPGA clock using a 3-bits shift register
//-----------------------------------------------------------------------------
reg [2:0] SCKr;  
always @(posedge clk) SCKr <= {SCKr[1:0], SCK};
wire SCK_risingedge  = (SCKr[2:1] == 2'b01);      // now we can detect SCK rising edges

//-----------------------------------------------------------------------------
// Sync SSEL to the FPGA clock using a 3-bits shift register
//-----------------------------------------------------------------------------
reg [2:0] SSELr;  
always @(posedge clk) SSELr <= {SSELr[1:0], SSEL};
assign SPI_Active  = ~SSELr[1];              // SSEL is active low
assign SPI_Start   = (SSELr[2:1] == 2'b10);  // Message starts at falling edge
assign SPI_End     = (SSELr[2:1] == 2'b01);  // Message stops at rising edge

//-----------------------------------------------------------------------------
// Debouner for MOSI
//-----------------------------------------------------------------------------
reg [1:0] MOSIr;  
always @(posedge clk) MOSIr <= {MOSIr[0], MOSI};
wire MOSI_data = MOSIr[1];

//-----------------------------------------------------------------------------
// SPI Transceiver:
// This is a 24 8-bit SPI format, 16 bits for Address and 8 Bits data. 
// FPGA is only one slave on the SPI bus so we don't bother with 
// a tri-state buffer for MISO otherwise we would need to tri-state MISO when SSEL is inactive
//-----------------------------------------------------------------------------
reg   [4:0] bitcnt;                         // Count the bits being exchanged up to 32
reg  [10:0] Panel;                          // Wires to register holding Panel
reg   [7:0] databits;                       // Shift register of output data
wire        rcv_addr  = (bitcnt > 5'd4);    // Receiving address
wire        rcv_data  = (bitcnt > 5'd15);   // Sending and receiving data
assign      MISO = rcv_data ? databits[7] : 1'b0;     // send MSB first
always @(posedge clk) begin
    if(DR_risingedge) databits <= DataOut;  // when SPI is selected, load data into shift register
    if(~SPI_Active) begin                   // If SPI is not active
        bitcnt   <=  5'h00;                 // Then reset the bit count and
        databits <=  8'h00;                 // Send 0s
//      Panel    <= 11'h0000;               // Default 
    end
    else begin         
        if(SCK_risingedge) begin
            bitcnt <= bitcnt + 5'd1;        // Increment the Bit Counter
            if(rcv_data) begin
                DataIn   <= {DataIn[6:0], MOSI_data};     // Input shift-left register 
                databits <= {databits[6:0], 1'b0};        // Output shift-left register 
            end
            else begin
                if(rcv_addr) Panel   <= {Panel[9:0], MOSI_data};    // Panel Input shift-left register 
                else         KeyPad  <= {KeyPad[3:0], MOSI_data};   // KeyPad Input shift-left register 
            end
        end
    end
end

always @(posedge clk) begin
    kbd_received  <= SPI_Active && SCK_risingedge && (bitcnt == 5'd4 );
    pnl_received  <= SPI_Active && SCK_risingedge && (bitcnt == 5'd15);
    data_received <= SPI_Active && SCK_risingedge && (bitcnt == 5'd23);
end

//-----------------------------------------------------------------------------
endmodule
//-----------------------------------------------------------------------------



