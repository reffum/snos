//
// Output 1 on out if is signal on in.
//

module signal_indicator
  (
   input clk,
   input resetn,
   input in,
   output out
   );

   parameter C_MAX = 10_000;
   
   logic  in_d1, in_d2;
   logic [7:0] cnt_cs, cnt_ns;

   always_ff @(posedge clk) begin
      in_d1 <= in;
      in_d2 <= in_d1;
   end

   always_ff @(posedge clk, negedge resetn)
     if(!resetn)
       cnt_cs <= 0;
     else
       cnt_cs <= cnt_ns;

   always_comb begin
      if(in_d1 != in_d2)
	cnt_ns <= C_MAX;
      else if(cnt_cs > 0)
	cnt_ns = cnt_cs - 1;
      else
	cnt_ns = cnt_cs;
   end

   assign out = cnt_cs > 0 ? 1'b1 : 1'b0;

endmodule // signal_indicator
