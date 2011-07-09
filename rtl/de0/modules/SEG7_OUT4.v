// --------------------------------------------------------------------
// Seven Segment readout, 4 digits
// --------------------------------------------------------------------
module SEG7_OUT_4(
	input		[15:0]	iDIG,
	output	[ 6:0]	oSEG0,
	output	[ 6:0]	oSEG1,
	output	[ 6:0]	oSEG2,
	output	[ 6:0]	oSEG3
);

SEG7_OUT1 u0(iDIG[ 3: 0], oSEG0);
SEG7_OUT1 u1(iDIG[ 7: 4], oSEG1);
SEG7_OUT1 u2(iDIG[11: 8], oSEG2);
SEG7_OUT1 u3(iDIG[15:12], oSEG3);

endmodule

// --------------------------------------------------------------------
// Seven Segment readout, 1 digit
// --------------------------------------------------------------------
module SEG7_OUT1(
	input			[3:0]	iDIG,
	output reg	[6:0]	oSEG
);
always @(iDIG) begin
	case(iDIG)
		4'h0: oSEG = 7'b1000000;
		4'h1: oSEG = 7'b1111001;	// ---t---
		4'h2: oSEG = 7'b0100100; 	// |	   |
		4'h3: oSEG = 7'b0110000; 	// lt	  rt
		4'h4: oSEG = 7'b0011001; 	// |	   |
		4'h5: oSEG = 7'b0010010; 	// ---m---
		4'h6: oSEG = 7'b0000010; 	// |	   |
		4'h7: oSEG = 7'b1111000; 	// lb	  rb
		4'h8: oSEG = 7'b0000000; 	// |	   |
		4'h9: oSEG = 7'b0011000; 	// ---b---
		4'ha: oSEG = 7'b0001000;
		4'hb: oSEG = 7'b0000011;
		4'hc: oSEG = 7'b1000110;
		4'hd: oSEG = 7'b0100001;
		4'he: oSEG = 7'b0000110;
		4'hf: oSEG = 7'b0001110;
	endcase
end

endmodule

// --------------------------------------------------------------------
