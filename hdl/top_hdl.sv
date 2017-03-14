// Module: top_hdl.sv
// Author: Rehan Iqbal
// Date: March 8, 2017
// Company: Portland State University
//
// Description:
// ------------
//
// clk - global clock signal
// resetH - active high global async reset
//
////////////////////////////////////////////////////////////////////////////////

`include "definitions.sv"

module top_hdl(); // pragma attribute top_hdl partition_module_xrtl

	timeunit 1ns;
	timeprecision 100ps;
	
	/************************************************************************/
	/* Local parameters and variables										*/
	/************************************************************************/

	ulogic1		clk		= 1'b0;
	ulogic1		resetH	= 1'b0;

	/************************************************************************/
	/* Module instantiations												*/
	/************************************************************************/

	KeyBus_if		i_KeyBus_if 	(.clk		(clk), 
									.resetH		(resetH));

	CipherBus_if	i_CipherBus_if	(.clk		(clk), 
									.resetH		(resetH));

	Testbench_if	i_Testbench_if 	(.Key_M		(i_KeyBus_if.master), 
									.Cipher_M	(i_CipherBus_if.master));

	aes				i_aes			(.clk		(clk),
									.reset		(resetH),
									.Key_S		(i_KeyBus_if.slave),
									.Cipher_S	(i_CipherBus_if.slave));

	/************************************************************************/
	/* initial block : clk													*/
	/************************************************************************/

	// tbx clkgen
	initial begin
		clk = 1'b0;
		forever #0.5 clk = !clk;
	end

	/************************************************************************/
	/* initial block : reset												*/
	/************************************************************************/

	// tbx clkgen
	initial begin
		resetH = 1'b0;
		#2 resetH = 1'b1;
		#2 resetH = 1'b0;
	end

endmodule // top