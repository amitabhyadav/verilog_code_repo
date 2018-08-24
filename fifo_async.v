//*******************************************************************
// Module	: Asynchronous FIFO (with 2 asynchronous clocks)
// Input 	: read_en, write_en, data_in, read_clk, write_clk,reset
// Output	: data_out, full, empty
//*******************************************************************

module fifo_async
  #(parameter    DATA_WIDTH    = 8,
                 ADDRESS_WIDTH = 4,
                 FIFO_DEPTH    = (1 << ADDRESS_WIDTH))
    (output reg  [DATA_WIDTH-1:0]        data_out, 
     output reg                          empty,
     input wire                          read_en,
     input wire                          read_clk,        
     	 
     input wire  [DATA_WIDTH-1:0]        data_in,  
     output reg                          full,
     input wire                          write_en,
     input wire                          write_clk,

     input wire                          reset);

    	// Internal Connections
    	reg   [DATA_WIDTH-1:0]              Mem [FIFO_DEPTH-1:0];			
    	wire  [ADDRESS_WIDTH-1:0]           pNextWordToWrite, pNextWordToRead;
    	wire                                EqualAddresses;
    	wire                                NextWriteAddressEn, NextReadAddressEn;
    	wire                                Set_Status, Rst_Status;
    	reg                                 Status;
    	wire                                PresetFull, PresetEmpty;

     
	//data_out
	always @ (posedge read_clk)
		if (read_en & !empty)
            		data_out <= Mem[pNextWordToRead];
            
    	//data_in
    	always @ (posedge write_clk)
        	if (write_en & !full)
            		Mem[pNextWordToWrite] <= data_in;

    	//Next Addresses enable
   	assign NextWriteAddressEn = write_en & ~full;
    	assign NextReadAddressEn  = read_en  & ~empty;
           
    	//Addreses Gray counter
    	GrayCounter GrayCounter_pWr
		(.grayCount_out(pNextWordToWrite),
       		 .enable_in(NextWriteAddressEn),
        	 .reset(reset),
       	         .clk(write_clk)
		);
       
    	GrayCounter GrayCounter_pRd
       		(.grayCount_out(pNextWordToRead),
        	 .enable_in(NextReadAddressEn),
        	 .reset(reset),
        	 .clk(read_clk)
       		);
     

    	//Equal Addresses
    	assign EqualAddresses = (pNextWordToWrite == pNextWordToRead);

    	//'Quadrant selectors' logic:
    	assign Set_Status = (pNextWordToWrite[ADDRESS_WIDTH-2] ~^ pNextWordToRead[ADDRESS_WIDTH-1]) &
                         (pNextWordToWrite[ADDRESS_WIDTH-1] ^  pNextWordToRead[ADDRESS_WIDTH-2]);
                            
    	assign Rst_Status = (pNextWordToWrite[ADDRESS_WIDTH-2] ^  pNextWordToRead[ADDRESS_WIDTH-1]) &
                         (pNextWordToWrite[ADDRESS_WIDTH-1] ~^ pNextWordToRead[ADDRESS_WIDTH-2]);
                         
    	//'Status' latch logic:
    	always @ (Set_Status, Rst_Status, reset) //D Latch w/ Asynchronous Clear & Preset.
        if (Rst_Status | reset)
            Status = 0;  //Going 'Empty'.
        else if (Set_Status)
            Status = 1;  //Going 'Full'.
            
    	//'Full_out' logic for the writing port:
    	assign PresetFull = Status & EqualAddresses;  //'Full' Fifo.
    
    	always @ (posedge write_clk, posedge PresetFull) //D Flip-Flop w/ Asynchronous Preset.
        if (PresetFull)
            full <= 1;
        else
            full <= 0;
            
    	//'Empty_out' logic for the reading port:
    	assign PresetEmpty = ~Status & EqualAddresses;  //'Empty' Fifo.
    
   	always @ (posedge read_clk, posedge PresetEmpty)  //D Flip-Flop w/ Asynchronous Preset.
        if (PresetEmpty)
            empty <= 1;
        else
            empty <= 0;

endmodule

//**************************************************************
// Module: Gray Counter
//**************************************************************

module GrayCounter
   #(parameter   COUNTER_WIDTH = 4)
   
    (output reg  [COUNTER_WIDTH-1:0]    grayCount_out,  //'Gray' code count output.
    
     input wire                         enable_in,  //Count enable.
     input wire                         reset,   //Count reset.
    
     input wire                         clk);

    //****Internal Connections****
    reg    [COUNTER_WIDTH-1:0]         binaryCount;

    always @ (posedge clk)
        if (reset) begin
            binaryCount   <= {COUNTER_WIDTH{1'b 0}} + 1;  //Gray count begins @ '1' with
            grayCount_out <= {COUNTER_WIDTH{1'b 0}};      // first 'Enable_in'.
        end
        else if (enable_in) begin
            binaryCount   <= binaryCount + 1;
            grayCount_out <= {binaryCount[COUNTER_WIDTH-1],
                              binaryCount[COUNTER_WIDTH-2:0] ^ binaryCount[COUNTER_WIDTH-1:1]};
        end
    
endmodule
