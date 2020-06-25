//
// Signal divider
//

module divider
  (
   input resetn,
   input  in,
   output out
   );

   parameter COEF;

   integer cnt_ns, cnt_cs;
   logic   out_cs, out_ns;
   
   always_ff @(in, resetn) begin
     if(!resetn) begin
	cnt_cs <= 0;
	out_cs <= 1'b0;
     end else begin
	cnt_cs <= cnt_ns;
	out_cs <= out_ns;
     end
   end
   

   always_comb begin
      out_ns <= out_cs;
      
      if(cnt_cs == COEF-1) begin
	 cnt_ns <= 0;
	 out_ns <= ~out_cs;
      end else begin
	 cnt_ns <= cnt_cs + 1;
      end
   end

   assign out = out_cs;
   
endmodule // divider
