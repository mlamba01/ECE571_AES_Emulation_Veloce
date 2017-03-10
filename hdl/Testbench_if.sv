// Module: Testbench_if.sv
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

interface Testbench_if (KeyBus_if.master Key_M, CipherBus_if.master Cipher_M);

	modport SendRcv (import CreateKey, import EncryptData, import DecryptData);

	/************************************************************************/
	/* Local parameters and variables										*/
	/************************************************************************/
	

	/************************************************************************/
	/* Task : CreateKey														*/
	/************************************************************************/

	task CreateKey (input ulogic256 key_input);

		begin

			Key_M.i_key <= key_input;
			Key_M.i_key_mode <= 2'b10;
			Key_M.i_start <= 1'b1;

			@(posedge Key_M.clk);

			Key_M.i_start <= 1'b0;

			@(posedge Key_M.clk);

			while (!Key_M.o_key_ready) begin
				@(posedge Key_M.clk);
			end

		end

	endtask : CreateKey

	/************************************************************************/
	/* Task : EncryptData													*/
	/************************************************************************/

	task EncryptData (input	ulogic128 text_in, output ulogic128 cipher_out);
		
		begin

			while (!Cipher_M.o_ready) begin
				@(posedge Cipher_M.clk);
			end

			Cipher_M.i_data <= text_in;
			Cipher_M.i_data_valid <= 1'b1;
			Cipher_M.i_ende <= 1'b0;
			Cipher_M.i_enable <= 1'b1;

			@(posedge Cipher_M.clk);

			Cipher_M.i_data_valid <= 1'b0;

			@(posedge Cipher_M.clk);

			while (!Cipher_M.o_data_valid) begin
				@(posedge Cipher_M.clk);
			end

			cipher_out = Cipher_M.o_data;

		end

	endtask : EncryptData

	/************************************************************************/
	/* Task : DecryptData													*/
	/************************************************************************/

	task DecryptData (input ulogic128 cipher_in, output ulogic128 text_out);

		begin

			while (!Cipher_M.o_ready) begin
				@(posedge Cipher_M.clk);
			end

			Cipher_M.i_data <= cipher_in;
			Cipher_M.i_data_valid <= 1'b1;
			Cipher_M.i_ende <= 1'b1;
			Cipher_M.i_enable <= 1'b1;

			@(posedge Cipher_M.clk);

			Cipher_M.i_data_valid <= 1'b0;

			@(posedge Cipher_M.clk);

			while (!Cipher_M.o_data_valid) begin
				@(posedge Cipher_M.clk);
			end

			text_out = Cipher_M.o_data;

		end

	endtask : DecryptData

endinterface : Testbench_if