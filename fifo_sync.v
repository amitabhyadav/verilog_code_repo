// **********************************************
// Single Clock FIFO Design
// Inputs: 	clk, rst, rd_en, wr_en, data_in
// Outputs: 	data_out, empty, full
// Date:	23-08-2018
// **********************************************
module fifo_sync (
clk,		//clock
rst,		//reset
rd_en,		//read enable
wr_en,		//write enable
data_in,	//Data In
data_out,	//Data Out
empty,		//FIFO Empty Signal
full		//FIFO Full Signal
);

parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 8;
parameter RAM_DEPTH = (1 << ADDR_WIDTH);	//times 2 i.e. 8*2 = 16bits

input clk;
input rst;
input wr_en;
input rd_en;
input [DATA_WIDTH-1:0] data_in;

output full;
output empty;
output [DATA_WIDTH-1:0] data_out;

reg [ADDR_WIDTH-1:0] wr_pointer;
reg [ADDR_WIDTH-1:0] rd_pointer;
reg [ADDR_WIDTH:0] status_cnt;
reg [DATA_WIDTH-1:0] data_out;
wire [DATA_WIDTH-1:0] data_ram;

assign full = (status_cnt == (RAM_DEPTH-1));
assign empty = (status_cnt == 0);

always@(posedge clk or posedge rst)
begin:WRITE_POINTER
	if (rst) begin
	 wr_pointer <= 0;
	end else if (wr_en) begin
	 wr_pointer <=wr_pointer + 1;
	end
end

always@(posedge clk or posedge rst)
begin: READ_POINTER
	if(rst) begin
	 rd_pointer = 0;
	end else if(rd_en) begin
	 rd_pointer = rd_pointer + 1;
	end
end

always@(posedge clk or posedge rst)
begin:READ_DATA
	if(rst)begin
	 data_out <= 0;
	end else if (rd_en)begin
	 data_out <= data_ram;
	end
end

always@(posedge clk or posedge rst)
begin: STATUS_COUNTER
	if(rst) begin
	 status_cnt <= 0;
	//Read but no write
	end else if((rd_en) && !(wr_en) && (status_cnt != 0)) begin
	 status_cnt <= status_cnt -1;
	// Write but no read
	end else if ((wr_en) && !(rd_en) && (status_cnt != RAM_DEPTH)) begin
	 status_cnt <= status_cnt+1;
	end
end

ram_dp_async #(DATA_WIDTH,ADDR_WIDTH)
DPRAM (
.address_0 (wr_pointer) ,
.data_0    (data_in)    , 
.we_0      (wr_en)      , 
.oe_0      (1'b0)       , 
.address_1 (rd_pointer) , 
.data_1    (data_ram)   , 
.we_1      (1'b0)       , 
.oe_1      (rd_en)        
);

endmodule	// fifo_sync

module ram_dp_async (
address_0 , 	// address_0 Input
data_0    , 	// data_0 bi-directional
we_0      , 	// Write Enable/Read Enable
oe_0      , 	// Output Enable
address_1 , 	// address_1 Input
data_1    , 	// data_1 bi-directional
we_1      , 	// Write Enable/Read Enable
oe_1        	// Output Enable
); 

parameter DATA_WIDTH = 8 ;
parameter ADDR_WIDTH = 8 ;
parameter RAM_DEPTH = 1 << ADDR_WIDTH;

input [ADDR_WIDTH-1:0] address_0 ;
input cs_0 ;
input we_0 ;
input oe_0 ; 
input [ADDR_WIDTH-1:0] address_1 ;
input cs_1 ;
input we_1 ;
input oe_1 ; 

inout [DATA_WIDTH-1:0] data_0 ; 
inout [DATA_WIDTH-1:0] data_1 ;


reg [DATA_WIDTH-1:0] data_0_out ; 
reg [DATA_WIDTH-1:0] data_1_out ;
reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1];

// Memory Write Block 
// Write Operation : When we_0 = 1
always @ (address_0 or we_0 or data_0
or address_1 or we_1 or data_1)
begin : MEM_WRITE
  if (we_0) begin
     mem[address_0] <= data_0;
  end else if  (we_1) begin
     mem[address_1] <= data_1;
  end
end

// Tri-State Buffer control 
// output : When we_0 = 0, oe_0 = 1
assign data_0 = (oe_0 && !we_0) ? data_0_out : 8'bz; 

// Memory Read Block 
// Read Operation : When we_0 = 0, oe_0 = 1
always @ (address_0 or we_1 or oe_0)
begin : MEM_READ_0
  if (!we_0 && oe_0) begin
    data_0_out <= mem[address_0]; 
  end else begin
    data_0_out <= 0; 
  end
end 

//Second Port of RAM
// Tri-State Buffer control 
// output : When we_0 = 0, oe_0 = 1
assign data_1 = (oe_1 && !we_1) ? data_1_out : 8'bz;

// Memory Read Block 1 
// Read Operation : When we_1 = 0, oe_1 = 1
always @ (address_1 or we_1 or oe_1)
begin : MEM_READ_1
  if (!we_1 && oe_1) begin
    data_1_out <= mem[address_1]; 
  end else begin
    data_1_out <= 0; 
  end
end

endmodule // ram_dp_async
