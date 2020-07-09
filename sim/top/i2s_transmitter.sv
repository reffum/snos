//
// I2S transmitter
//
timeunit 1ns;
timeprecision 100ps;

import pack::*;

module i2s_transmitter
  (
   output logic data, lrck, bck
   );
   
   realtime bitTime = 0;
   int 		Bits;
   int 		hStream;

   initial hStream = $create_transaction_stream("stream", "transaction");
   
   initial begin
      lrck = 1'b0;
      bck = 1'b0;
      data = 1'b0;
   end
   
   //
   // Set Bitrate and bits number
   // First you need to call SetBits, then SetBitRate.
   //
   task SetBitRate(int bitrate);
	  bitTime = 1.0 / bitrate / Bits / 2 * 1s;
   endtask // SetBitrate

   task SetBits(int bits);
	  Bits = bits;
   endtask // SetBits
   
   //
   // Send arrays of samples
   //

   task Send(logic [31:0] D[][CHAN_NUM]);
      // Generate BCK and LRCK
      fork
	 forever begin : BCK
	    #(bitTime/2) bck = ~bck;
	 end

	 begin : LRCK
	    // LRCK must be 0
	    assert(lrck == 1'b0) else $stop;
	    
	    // One word Bits - 1.
	    repeat(Bits - 1) @(negedge bck);
	    lrck = 1'b1;

	    forever begin
	       repeat(Bits) @(negedge bck);
	       lrck = ~lrck;
	    end
	 end // block: LRCK
	 
	 begin : DATA
	    static int hTrans;

	    for(int sample = 0; sample < $size(D); sample++)
	      for(int chan = 0; chan < CHAN_NUM; chan++) begin
		 hTrans = $begin_transaction(hStream, "SENDWORD");
		 $add_attribute(hTrans, sample, "Sample");
		 $add_attribute(hTrans, chan, "Channel");
		 $add_attribute(hTrans, D[sample][chan], "Word");
		 
		 for(int bitNum = Bits - 1; bitNum >= 0; bitNum--) begin
		    data = D[sample][chan][bitNum];
		    @(negedge bck);
		 end
		 
		 $end_transaction(hTrans);
	      end
	 end
	       
      join_any
      disable fork;

      
      // Add one simulation step to enable the
      // receiver to process LRCK falling.
      #1step;
   endtask

   // Make BCK cycles. LRCK and Data not chaned
   task DoBck(int cycles);
      repeat(cycles * 2)
	 #(bitTime/2) bck = ~bck;
   endtask // DoBck
   
endmodule 
