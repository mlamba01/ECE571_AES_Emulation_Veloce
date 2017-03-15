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

interface Testbench_if (KeyBus_if.master Key_M, CipherBus_if.master Cipher_M);	// pragma attribute Testbench_if partition_interface_xif

	/************************************************************************/
	/* Local parameters and variables										*/
	/************************************************************************/
	
	/************************************************************************/
	/* Task : WaitForReset													*/
	/************************************************************************/

	task WaitForReset(); //pragma tbx xtf

		@(posedge Key_M.clk);

		while(Key_M.resetH == 1'b0) begin
			@(posedge Key_M.clk);
		end

		while(Key_M.resetH == 1'b1) begin
			@(posedge Key_M.clk);
		end

		@(posedge Key_M.clk);

	endtask : WaitForReset

	/************************************************************************/
	/* Task : CreateKey														*/
	/************************************************************************/

	task CreateKey (input ulogic256 key_input); // pragma tbx xtf

		@(posedge Key_M.clk);

		Key_M.i_key <= key_input;
		Key_M.i_key_mode <= 2'b10;
		Key_M.i_start <= 1'b1;

		@(posedge Key_M.clk);

		Key_M.i_start <= 1'b0;

		@(posedge Key_M.clk);

		while (!Key_M.o_key_ready) begin
			@(posedge Key_M.clk);
		end

	endtask : CreateKey

	/************************************************************************/
	/* Task : EncryptData													*/
	/************************************************************************/

	task EncryptData (input	ulogic128 text_in, output ulogic128 cipher_out); // pragma tbx xtf
		
		@(posedge Cipher_M.clk);

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

		cipher_out <= Cipher_M.o_data;

		@(posedge Cipher_M.clk);

	endtask : EncryptData

	/************************************************************************/
	/* Task : DecryptData													*/
	/************************************************************************/

	task DecryptData (input ulogic128 cipher_in, output ulogic128 text_out); // pragma tbx xtf

		@(posedge Cipher_M.clk);

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

		text_out <= Cipher_M.o_data;

		@(posedge Cipher_M.clk);

	endtask : DecryptData

	/************************************************************************/
	/* Protocol Assertions													*/
	/************************************************************************/

	// make sure Key_M.i_start applies for exactly one cycle
	// then stays low for the rest of transaction, until output key is ready

	property Key_M_i_start_one_cycle;
		@(posedge Key_M.clk) Key_M.i_start |=> !Key_M.i_start throughout ##[1:$] (Key_M.o_key_ready & !Key_M.i_start);
	endproperty

	assert property (Key_M_i_start_one_cycle) else $error("Start flag 'i_start' on bus 'Key_M' went high at time %t!", $time);

	// make sure Key_M.i_key values are not 'x' or 'z' logic values
	// at the time when AES core is sampling inputs

	property Key_M_i_key_known_logic;
		@(posedge Key_M.clk) Key_M.i_start |-> !$isunknown(Key_M.i_key);
	endproperty

	assert property (Key_M_i_key_known_logic) else $error("Input data 'i_key' on bus 'Key_M' is unknown at time %t!", $time);

	// make sure Cipher_M.i_data_valid applies for exactly one cycle
	// then stays low for the rest of transaction, until output data is ready

	property Cipher_M_i_data_valid_one_cycle;
		@(posedge Cipher_M.clk) Cipher_M.i_data_valid |=> !Cipher_M.i_data_valid throughout ##[1:$] (Cipher_M.o_data_valid & !Cipher_M.i_data_valid);
	endproperty

	assert property (Cipher_M_i_data_valid_one_cycle) else $error("Start flag 'i_data_valid' on bus 'Cipher_M' went high at time %t!", $time);

	//  make sure Cipher_M.i_data values are not 'x' or 'z' logic values
	// at the time when AES core is sampling inputs

	property Cipher_M_i_data_known_logic;
		@(posedge Cipher_M.clk) Cipher_M.i_data_valid |-> !$isunknown(Cipher_M.i_data);
	endproperty

	assert property (Cipher_M_i_data_known_logic) else $error("Input data 'i_data' on bus 'Cipher_M' is unknown at time %t!", $time);

endinterface : Testbench_if