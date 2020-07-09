//
// Common package with types and functions for simulations.
//

package pack;
   // Number of channels(left and right)
   localparam CHAN_NUM = 2;

class SampleData;
   rand logic [31:0] 		left, right;
   int 				left_bits, right_bits;
endclass // SampleData

   typedef SampleData SampleDataQueue[$];
   
endpackage // pack
