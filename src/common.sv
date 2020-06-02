//
// Common constants, funtions and types for the project
//

package common;
   // Number of bits in I2S word
   localparam I2S_BITS = 32;
   
   // Standart stream parameters(reference, bitrate(x1,x2..), bitnumber
   typedef enum   logic {REF_x48, REF_x44} Reference;
   typedef enum   logic [1:0]  { x1, x2, x4, x8 } BITRATE;
   typedef enum   logic [1:0]  { b16, b24, b32 } BITNUM;

   // NOS interface bitnumber
   typedef enum   logic [1:0] {NOS16, NOS18, NOS20, NOS24} NOS_BITNUM;

   // I2S interface 
   typedef struct packed {
      logic 	  bck;
      logic 	  lrck;
      logic 	  data;
   } I2S;

   // Master clock selection value
   typedef enum   logic [2:0]	  
		  {
		   MCLK_256fs,
		   MCLK_384fs,
		   MCLK_512fs,
		   MCLK_768fs,
		   MCLK_1024fs
		   } MCLK;
endpackage // common
   
