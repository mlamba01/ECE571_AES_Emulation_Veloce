module aes_testbench;

logic	clk,reset,i_start,i_enable,i_ende,i_data_valid; 
logic  [255:0] i_key;
logic  [1:0]   i_key_mode; 
logic  [127:0] i_data;
logic  o_ready,o_data_valid,o_key_ready; 
logic  [127:0] o_data;

aes dut(
   .clk(clk),
   .reset(reset),
   .i_start(i_start),
   .i_enable(i_enable), 
   .i_ende(i_ende),
   .i_key(i_key),
   .i_key_mode(i_key_mode),
   .i_data(i_data),
   .i_data_valid(i_data_valid),
   .o_ready(o_ready),
   .o_data(o_data),
   .o_data_valid(o_data_valid),
   .o_key_ready(o_key_ready)
);

initial begin 
clk= '0;
forever begin 
#5 clk=~clk; 
end
end

initial begin
reset = '1;
repeat(1) @(negedge clk);
reset = '0;
i_start = '1;
i_enable = '1;
i_key_mode = 2'b00;

//Encryption
i_ende = 1'b0;
i_data = 128'h63da_49b0;
i_data_valid = '1;
@ (negedge clk)
$display ($time,"Encrypted Data = %h",o_data);


//Decryption
i_ende = 1'b1;
i_data = 128'h4368_1570;
i_data_valid = '1;
@ (negedge clk)
$display ($time,"Decrypted Data = %h",o_data);

$finish;
end
endmodule
