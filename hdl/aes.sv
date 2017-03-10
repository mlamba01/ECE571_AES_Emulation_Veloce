//---------------------------------------------------------------------------------------
// 
//	AES core top module 
// 
//	Description: 
//		AES core top module with direct interface to key and data buses. 
// 
//	To Do: 
//		- done 
//
//	Author(s):
//		- Luo Dongjun,   dongjun_luo@hotmail.com 
//
//---------------------------------------------------------------------------------------

`define XILINX 1
`include "definitions.sv"

module aes (

   /************************************************************************/
   /* Top-level port declarations                                          */ 
   /************************************************************************/

   input    ulogic1     clk,
   input    ulogic1     reset,

   KeyBus_if.slave      Key_S,
   CipherBus_if.slave   Cipher_S

   );

   /************************************************************************/
   /* Local parameters and variables                                       */
   /************************************************************************/

   genvar i;

   logic             final_round;
   logic    [3:0]    max_round;
   logic    [127:0]  en_sb_data,de_sb_data,sr_data,mc_data,imc_data,ark_data;
   logic    [127:0]  sb_data, i_data_L;
   logic             i_data_valid_L;
   logic             round_valid;
   logic    [2:0]    sb_valid;

   logic    [3:0]    round_cnt,sb_round_cnt1,sb_round_cnt2,sb_round_cnt3;
   logic    [127:0]  round_key;
   logic    [63:0]   rd_data0,rd_data1;
   logic             wr;
   logic    [4:0]    wr_addr;
   logic    [63:0]   wr_data;
   logic    [127:0]  imc_round_key,en_ark_data,de_ark_data,ark_data_final,ark_data_init;

   /************************************************************************/
   /* Module implementation                                                */
   /************************************************************************/

   assign final_round = sb_round_cnt3[3:0] == max_round[3:0];
   assign Cipher_S.o_ready = ~sb_valid[0]; // if ready is asserted, user can input data for the next cycle

   // round count is Nr - 1
   always_comb begin

      case (Key_S.i_key_mode)

         2'b00: max_round[3:0] = 4'd10;
         2'b01: max_round[3:0] = 4'd12;
         default: max_round[3:0] = 4'd14;

      endcase
   end
 
   /************************************************************************/
   /* SubBytes                                                             */
   /************************************************************************/
   
   generate

   for (i = 0; i < 16; i = i + 1) begin : sbox_block

      sbox u_sbox (

         .clk        (clk),
         .reset      (reset),
         .enable     (Cipher_S.i_enable),
         .ende       (Cipher_S.i_ende),
         .din        (Cipher_S.o_data[i*8+7:i*8]),
         .en_dout    (en_sb_data[i*8+7:i*8]),
         .de_dout    (de_sb_data[i*8+7:i*8]));

   end

   endgenerate
    
   always_ff @ (posedge clk or posedge reset) begin

      if (reset) begin
         sb_data[127:0] <= 128'b0;
      end

      else if (Cipher_S.i_enable) begin
         sb_data[127:0] <= Cipher_S.i_ende ? de_sb_data[127:0] : en_sb_data[127:0];
      end

   end
 
   /************************************************************************/
   /* ShiftRows & InvShiftRows                                             */
   /************************************************************************/

   logic [127:0] shrows, ishrows;

   shift_rows u_shrows (

      .si   (sb_data[127:0]), 
      .so   (shrows));

   inv_shift_rows u_ishrows (

      .si   (sb_data[127:0]), 
      .so   (ishrows));

   assign sr_data[127:0] = Cipher_S.i_ende ? ishrows : shrows;
 
 
   /************************************************************************/
   /* MixColumns                                                           */
   /************************************************************************/
   
   mix_columns mxc_u (

      .in   (sr_data), 
      .out  (mc_data));
 
   always_ff @ (posedge clk or posedge reset) begin

      if (reset) begin
         i_data_valid_L  <= 1'b0;
         i_data_L[127:0] <= 128'b0;
      end

      else begin
         i_data_valid_L  <= Cipher_S.i_data_valid;
         i_data_L[127:0] <=Cipher_S.i_data[127:0];
      end

   end
 
   /************************************************************************/
   /* InvMixColumns                                                        */
   /************************************************************************/

   inv_mix_columns imxc_u (

      .in   (sr_data),
      .out  (imc_data));

   /************************************************************************/
   /* Add round key for decryption                                         */
   /************************************************************************/

   inv_mix_columns imxk_u (

      .in   (round_key),
      .out  (imc_round_key));

   assign ark_data_final[127:0]  = sr_data[127:0] ^ round_key[127:0];
   assign ark_data_init[127:0]   = i_data_L[127:0] ^ round_key[127:0];
   assign en_ark_data[127:0]     = mc_data[127:0] ^ round_key[127:0];
   assign de_ark_data[127:0]     = imc_data[127:0] ^ imc_round_key[127:0];
   assign ark_data[127:0]        = i_data_valid_L ? ark_data_init[127:0] : 
                                   (final_round ? ark_data_final[127:0] : 
                                   (Cipher_S.i_ende ? de_ark_data[127:0] : en_ark_data[127:0]));
 
   /************************************************************************/
   /* Data outputs after each round                                        */
   /************************************************************************/
   
   always_ff @ (posedge clk or posedge reset) begin

      if (reset) begin
         Cipher_S.o_data[127:0] <= 128'b0;
      end

      else if (Cipher_S.i_enable && (i_data_valid_L || sb_valid[2])) begin
         Cipher_S.o_data[127:0] <= ark_data[127:0];
      end

   end
 
   /************************************************************************/
   /* in sbox, we have 3 stages (sb_valid)                                 */
   /* before the end of each round, we have another stage (round_valid     */
   /************************************************************************/

   always_ff @ (posedge clk or posedge reset) begin

      if (reset) begin
         round_valid    <= 1'b0;
         sb_valid[2:0]  <= 3'b0;
         Cipher_S.o_data_valid   <= 1'b0;
      end

      else if (Cipher_S.i_enable) begin
         Cipher_S.o_data_valid   <= sb_valid[2] && final_round;
         round_valid    <= (sb_valid[2] && !final_round) || i_data_valid_L;
         sb_valid[2:0]  <= {sb_valid[1:0],round_valid};
      end

   end
    
   always_ff @ (posedge clk or posedge reset) begin

      if (reset) begin
         round_cnt[3:0] <= 4'd0;
      end

      else if (i_data_valid_L) begin
         round_cnt[3:0] <= 4'd1;
      end

      else if (Cipher_S.i_enable && sb_valid[2]) begin
         round_cnt[3:0] <= sb_round_cnt3[3:0] + 1'b1;
      end

   end
    
   always_ff @ (posedge clk or posedge reset) begin

      if (reset) begin
         sb_round_cnt1[3:0] <= 4'd0;
         sb_round_cnt2[3:0] <= 4'd0;
         sb_round_cnt3[3:0] <= 4'd0;
      end

      else if (Cipher_S.i_enable) begin
         if (round_valid) sb_round_cnt1[3:0] <= round_cnt[3:0];
         if (sb_valid[0]) sb_round_cnt2[3:0] <= sb_round_cnt1[3:0];
         if (sb_valid[1]) sb_round_cnt3[3:0] <= sb_round_cnt2[3:0];
      end

   end

   /************************************************************************/
   /* round key generation: the expansion keys are stored in 4 16*32 rams  */
   /* or 2 16*64 rams or 1 16*128 rams                                     */
   /************************************************************************/

   assign round_key[127:0] = {rd_data0[63:0],rd_data1[63:0]};

   `ifdef XILINX

      logic [3:0] rd_addr;

      always_ff @ (posedge clk or posedge reset) begin

      	if (reset) begin
      		rd_addr <= 4'b0;
         end

      	else if (sb_valid[1] | Cipher_S.i_data_valid) begin

      		if (Cipher_S.i_ende) begin
      			if (Cipher_S.i_data_valid) rd_addr <= max_round[3:0];
      			else rd_addr <= max_round[3:0] - sb_round_cnt2[3:0];
      		end 

      		else begin
      			if (Cipher_S.i_data_valid) rd_addr <= 4'b0;
      			else rd_addr <= sb_round_cnt2[3:0];
      		end

      	end
      end

      xram_16x64 u_ram_0 (

      	.clk       (clk),
      	.wr        (wr & ~wr_addr[0]),
      	.wr_addr   (wr_addr[4:1]),
      	.wr_data   (wr_data[63:0]),
      	.rd_addr   (rd_addr[3:0]),
      	.rd_data   (rd_data0[63:0]));

      xram_16x64 u_ram_1 (

      	.clk       (clk),
      	.wr        (wr & wr_addr[0]),
      	.wr_addr   (wr_addr[4:1]),
      	.wr_data   (wr_data[63:0]),
      	.rd_addr   (rd_addr[3:0]),
      	.rd_data   (rd_data1[63:0]));

   `else

      logic [3:0] rd_addr;

      assign rd_addr[3:0] = Cipher_S.i_ende ? (Cipher_S.i_data_valid ? max_round[3:0] : (max_round[3:0] - sb_round_cnt2[3:0])) : 
                           (Cipher_S.i_data_valid ? 4'b0 : sb_round_cnt2[3:0]);

      ram_16x64 u_ram_0 (

         .clk       (clk),
      	.wr        (wr & ~wr_addr[0]),
      	.wr_addr   (wr_addr[4:1]),
      	.wr_data   (wr_data[63:0]),
      	.rd_addr   (rd_addr[3:0]),
      	.rd_data   (rd_data0[63:0]),
      	.rd        (sb_valid[1] | Cipher_S.i_data_valid));

      ram_16x64 u_ram_1 (

      	.clk       (clk),
      	.wr        (wr & wr_addr[0]),
      	.wr_addr   (wr_addr[4:1]),
      	.wr_data   (wr_data[63:0]),
      	.rd_addr   (rd_addr[3:0]),
      	.rd_data   (rd_data1[63:0]),
      	.rd        (sb_valid[1] | Cipher_S.i_data_valid));

   `endif 

   /************************************************************************/
   /* Key Exapansion module                                                */
   /************************************************************************/
   
   key_exp u_key_exp (

      .clk           (clk),
      .reset         (reset),
      .key_in        (Key_S.i_key[255:0]),
      .key_mode      (Key_S.i_key_mode[1:0]),
      .key_start     (Key_S.i_start),
      .wr            (wr),
      .wr_addr       (wr_addr[4:0]),
      .wr_data       (wr_data[63:0]),
      .key_ready     (Key_S.o_key_ready));
 
endmodule