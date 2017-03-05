//---------------------------------------------------------------------------------------
//	Project:			High Throughput / Low Area AES Core 
//
//	File name:			aes_top_example.v 		(March 30, 2012)
//
//	Writer:				Moti Litochevski 
//
//	Description:
//		This file contains a very simple and not very area efficient implementation of 
//		instance instantiate ting the AES core. This file is also used to estimate the 
//		core synthesis results. 
//		The AES core includes direct interfaces to the key and data vectors which are 
//		fairly wide (256 & 128 bits). This file includes a simple wrapper to enable 32 
//		bit data bus and 4 bit address to select the input and output word portion. 
//
//	Revision History:
//
//	Rev <revnumber>			<Date>			<owner> 
//		<comment>
// 
// EXTRA LINE TO DELETE
// REHAN ADDED A LINE
//---------------------------------------------------------------------------------------

// test_comment_poonam

module aes_top_example 
(
	input logic		clk, reset, i_enable, i_enc_dec, i_data_valid,
	input logic [1:0]	i_key_mode, o_data_sel,
	input logic [31:0]	i_data, 
	input logic [3:0]	i_data_sel,  
	output logic		o_key_ready, o_ready, o_data_valid, 
	output logic [31:0]	o_data
);

// internal signals and registers 
logic [255:0] int_key;
logic [127:0] int_data;
logic int_key_start, int_data_valid;
logic [127:0] int_o_data;

//---------------------------------------------------------------------------------------
// module implementation 
// internal key and data vectors write process 
always_ff @ (posedge reset or posedge clk) 
begin 
	if (reset) 
	begin 
		int_key <= 256'b0;
		int_data <= 128'b0;
		int_key_start <= 1'b0;
		int_data_valid <= 1'b0;
	end 
	else 
	begin 
		// input key and data write control 
		if (i_data_valid)
		begin 
			case (i_data_sel) 
				4'h0:	int_key[31:0] <= i_data;
				4'h1:	int_key[63:32] <= i_data;
				4'h2:	int_key[95:64] <= i_data;
				4'h3:	int_key[127:96] <= i_data;
				4'h4:	int_key[159:128] <= i_data;
				4'h5:	int_key[191:160] <= i_data;
				4'h6:	int_key[223:192] <= i_data;
				4'h7:	int_key[255:224] <= i_data;
				4'h8:	int_data[31:0] <= i_data;
				4'h9:	int_data[63:32] <= i_data;
				4'ha:	int_data[95:64] <= i_data;
				4'hb:	int_data[127:96] <= i_data;
			endcase 
		end 
			
		// key expansion start control 
		if ((i_data_sel == 4'h7) && i_data_valid)
			int_key_start <= 1'b1;
		else 
			int_key_start <= 1'b0;
		
		// encryption / decryption start control 
		if ((i_data_sel == 4'hb) && i_data_valid)
			int_data_valid <= 1'b1;
		else 
			int_data_valid <= 1'b0;
	end 
end 

// output data read control process 
always_ff @ (posedge reset or posedge clk) 
begin 
	if (reset) 
		o_data <= 32'b0;
	else 
	begin 
		case (o_data_sel) 
			2'h0:	o_data <= int_o_data[31:0];
			2'h1:	o_data <= int_o_data[63:32];
			2'h2:	o_data <= int_o_data[95:64];
			2'h3:	o_data <= int_o_data[127:96];
		endcase 
	end 
end 

// AES core instance 
aes u_aes 
(
   .clk(clk),
   .reset(reset),
   .i_start(int_key_start),
   .i_enable(i_enable),
   .i_ende(i_enc_dec),
   .i_key(int_key),
   .i_key_mode(i_key_mode),
   .i_data(int_data),
   .i_data_valid(int_data_valid),
   .o_ready(o_ready),
   .o_data(int_o_data),
   .o_data_valid(o_data_valid),
   .o_key_ready(o_key_ready)
);

endmodule
//---------------------------------------------------------------------------------------
//						Th.. Th.. Th.. Thats all folks !!!
//---------------------------------------------------------------------------------------