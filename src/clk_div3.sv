module clk_div3(in,resetn, out);
   
   input in;
   input resetn;
   output out;
   
   reg [1:0] pos_count = 1'b0, neg_count = 1'b0;
   wire [1:0] r_nxt;
   
   always @(posedge in)
     if (!resetn)
       pos_count <=0;
     else if (pos_count ==2) pos_count <= 0;
     else pos_count<= pos_count + 2'd1;
   
   always @(negedge in)
     if (!resetn)
       neg_count <=0;
     else  if (neg_count ==2) neg_count <= 0;
     else neg_count<= neg_count + 2'd1;
   
   assign out = ((pos_count == 2) | (neg_count == 2));
endmodule // clk_div3
