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

	int					fhandle1		= 1;
	int					fhandle2		= 2;

	int					errors			= 0;
	ulogic256			key_in			= 256'd0;

	ulogic128			text_in			= 128'd0;
	ulogic128			cipher_text		= 128'd0;
	ulogic128			text_out		= 128'd0;

	/************************************************************************/
	/* initial block : send stimulus to Testbench_if						*/
	/************************************************************************/

	initial begin

		$timeformat(-9, 0, "ns", 8);

		assert ((fhandle1 = $fopen("top_hvl_results.txt")) != 0) else $error("%m can't open file top_hvl_results.txt!");
		assert ((fhandle2 = $fopen("trace.txt")) != 0) else $error("%m can't open file trace.txt!");

		// print header at top of read log
		$fwrite(fhandle1,"AES Testbench Results:\n\n");

		// wait for resetH to be applied
		// so that AES-FSM is ready to function
		top_hdl.i_Testbench_if.WaitForReset();


		for (int i = 0; i < 4; i++) begin

			key_in[255:224] 	=  $urandom_range(32'hFFFFFFFF, 32'h0);
			key_in[223:192] 	=  $urandom_range(32'hFFFFFFFF, 32'h0);
			key_in[191:160] 	=  $urandom_range(32'hFFFFFFFF, 32'h0);
			key_in[159:128] 	=  $urandom_range(32'hFFFFFFFF, 32'h0);
			key_in[127:96] 		=  $urandom_range(32'hFFFFFFFF, 32'h0);
			key_in[95:64] 		=  $urandom_range(32'hFFFFFFFF, 32'h0);
			key_in[63:32] 		=  $urandom_range(32'hFFFFFFFF, 32'h0);
			key_in[31:0] 		=  $urandom_range(32'hFFFFFFFF, 32'h0);

			text_in[127:96] 	=  $urandom_range(32'hFFFFFFFF, 32'h0);
			text_in[95:64] 		=  $urandom_range(32'hFFFFFFFF, 32'h0);
			text_in[63:32] 		=  $urandom_range(32'hFFFFFFFF, 32'h0);
			text_in[31:0] 		=  $urandom_range(32'hFFFFFFFF, 32'h0);

			// hierarchical calls to the tasks inside bus-functional model
			top_hdl.i_Testbench_if.CreateKey(key_in);
			top_hdl.i_Testbench_if.EncryptData(text_in, cipher_text);
			top_hdl.i_Testbench_if.DecryptData(cipher_text, text_out);

			// write results to log file
			$fwrite(fhandle1, 	"key = %64x\n", key_in,
								"text_in = %32x\n", text_in,
								"cipher_text = %32x\n", cipher_text,
								"text_out = %32x\n\n", text_out);

			if (text_out != text_in) begin
				$fwrite(fhandle1, "Error: output text does not match input text!\n\n");
				errors += 1;
			end
			
			$fwrite(fhandle2,	"k %64x\n", key_in,
								"t %32x\n", text_in,
								"e %32x\n", cipher_text,
								"r\n\n");
		end

		// wrap up file writing
		$fwrite(fhandle1, "There were %4d errors found between input & output text.\n\n", errors);
		$fwrite(fhandle1, "END OF FILE");
		$fclose(fhandle1);

		$fclose(fhandle2);

		// end simulation
		$finish;

	end

endprogram