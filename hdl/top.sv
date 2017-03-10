// Module: top.sv
// Author: Rehan Iqbal
// Date: March 8, 2017
// Company: Portland State University
//
// Description:
// ------------
//
// clk - global clock signal
// reset - active high global async reset
//
////////////////////////////////////////////////////////////////////////////////

`include "definitions.sv"

module top();

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


	AES_tb 			i_AES_tb 		(.clk		(clk), 
									.resetH		(resetH),
									.TB_If		(i_Testbench_if.SendRcv));



	/************************************************************************/
	/* always block : clk													*/
	/************************************************************************/

	always begin
		#0.5 clk <= !clk;
	end

endmodule // top