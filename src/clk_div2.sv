module clk_div2( in ,resetn,out );
   output reg out = 1'b0;
   input      in ;
   input      resetn;
   always @(posedge in)
     begin
	if (~resetn)
	  out <= 1'b0;
	else
	  out <= ~out;	
     end
endmodule
