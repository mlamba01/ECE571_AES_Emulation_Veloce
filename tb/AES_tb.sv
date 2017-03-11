// Module: AES_tb.sv
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

module AES_tb (

	/************************************************************************/
	/* Top-level port declarations											*/
	/************************************************************************/

	Testbench_if.SendRcv	TB_If,

	input	ulogic1		clk,
	output	ulogic1		resetH

	);

	/************************************************************************/
	/* Local parameters and variables										*/
	/************************************************************************/

	int					fhandle;
	ulogic256			key_in;

	ulogic128			text_in;
	ulogic128			cipher_out;	

	ulogic128			cipher_in;
	ulogic128			text_out;

	/************************************************************************/
	/* initial block : send stimulus to Testbench_if						*/
	/************************************************************************/

	initial begin

		resetH = 1'b0;

		$timeformat(-9, 0, "ns", 8);
		fhandle = $fopen("C:/Users/riqbal/Desktop/AES_tb_results.txt");

		// print header at top of read log
		$fwrite(fhandle,"AES Testbench Results:\n\n");

		repeat (2) @(posedge clk);
		resetH = 1'b1;
		repeat (2) @(posedge clk);
		resetH = 1'b0;

		repeat (16) @(posedge clk);

		for (int i = 0; i < 64; i++) begin

			key_in = {8{$urandom_range(32'hFFFFFFFF, 32'h0)}};
			// text_in = {4{$urandom_range(32'hFFFFFFFF, 32'h0)}};
			text_in = i;

			TB_If.CreateKey(key_in);

			TB_If.EncryptData(text_in, cipher_out);
			cipher_in = cipher_out;
			TB_If.DecryptData(cipher_in, text_out);

			// write results to log file
			$fwrite(fhandle, 	"key = %64x\n", key_in,
								"text_in = %32x\n", text_in,
								"cipher_out = %32x\n", cipher_out,
								"cipher_in = %32x\n", cipher_in,
								"text_out = %32x\n\n", text_out);

		end

		// wrap up file writing
		$fwrite(fhandle, "\nEND OF FILE");
		$fclose(fhandle);

		// simulation over... review results
		$stop;

	end

endmodule // AES_tb