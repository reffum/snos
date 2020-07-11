//
// NOS DAC receiver. For simulation only.
//

module nos_dac_receiver
  (
   input bck, data_r, data_l, le
   );

   default clocking ck @(posedge bck);
   default input #1step;
   input data_r, data_l, le;
endclocking // ck

   logic [31:0] Data_r[$];
   logic [31:0] Data_l[$];

   // Input shift registers
   logic [31:0] reg_r;
   logic [31:0] reg_l;

   initial 
     forever begin
	@(posedge bck);

	// This value must be equal to clocking block skew
	#1step;
	
	reg_r = {reg_r[30:0], ck.data_r};
	reg_l = {reg_l[30:0], ck.data_l};

	if(ck.le) begin
	   Data_r.push_back(reg_r);
	   Data_l.push_back(reg_l);
	   reg_r = 0;
	   reg_l = 0;
	end
     end

   task Clear;
      Data_r = {};
      Data_l = {};
   endtask // Clear
endmodule // nos_dac_receiver

