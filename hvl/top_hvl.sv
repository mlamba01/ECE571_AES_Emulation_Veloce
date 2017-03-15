// Module: top_hvl.sv
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
//
////////////////////////////////////////////////////////////////////////////////

`include "definitions.sv"

program top_hvl;

	/************************************************************************/
	/* Local parameters and variables										*/
	/************************************************************************/

	int					fhandle;
	ulogic256			key_in			= 256'd0;

	ulogic128			text_in			= 128'd0;
	ulogic128			cipher_text		= 128'd0;
	ulogic128			text_out		= 128'd0;

	/************************************************************************/
	/* initial block : send stimulus to Testbench_if						*/
	/************************************************************************/

	initial begin

		$timeformat(-9, 0, "ns", 8);

		assert ((fhandle = $fopen("top_hvl_results.txt")) != 0) else $error("%m can't open file top_hvl_results.txt!");

		// print header at top of read log
		$fwrite(fhandle,"AES Testbench Results:\n\n");

		// wait for resetH to be applied
		// so that AES-FSM is ready to function
		top_hdl.i_Testbench_if.WaitForReset();


		for (int i = 0; i < 64; i++) begin

			key_in = {8{$urandom_range(32'hFFFFFFFF, 32'h0)}};
			text_in = {4{$urandom_range(32'hFFFFFFFF, 32'h0)}};

			// hierarchical calls to the tasks inside bus-functional model
			
			top_hdl.i_Testbench_if.CreateKey(key_in);
			top_hdl.i_Testbench_if.EncryptData(text_in, cipher_text);
			top_hdl.i_Testbench_if.DecryptData(cipher_text, text_out);

			// write results to log file
			$fwrite(fhandle, 	"key = %64x\n", key_in,
								"text_in = %32x\n", text_in,
								"cipher_text = %32x\n", cipher_text,
								"text_out = %32x\n\n", text_out);

		end

		// wrap up file writing
		$fwrite(fhandle, "\nEND OF FILE");
		$fclose(fhandle);

		// end simulation
		$stop;

	end

endprogram