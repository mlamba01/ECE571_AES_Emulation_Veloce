//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Ram module                                                  ////
////                                                              ////
////  Description:                                                ////
////  this is 16x64, we can use a 16x128 to replace two of this   ////
////    module, also, can use specific foundry libs instead       ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Luo Dongjun,   dongjun_luo@hotmail.com                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
module ram_16x64 (
	input logic		clk, wr, rd,
	input logic [3:0]	wr_addr, rd_addr,
	output logic [63:0]	wr_data, rd_data
	);
 
logic [63:0] mem[15:0];
//wire [63:0] rd_data;
 
// behavioral code for 16x64 mem
always_ff @ (posedge clk)
begin
   if (wr)
      mem[wr_addr] <= wr_data;
end
 
logic [3:0] srd_addr;

always_ff @ (posedge clk)
begin
	if (rd) 
		srd_addr <= rd_addr;
end 

assign rd_data = mem[srd_addr];

endmodule