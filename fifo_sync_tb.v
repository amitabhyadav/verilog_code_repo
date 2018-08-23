module fifo_sync_tb ();
reg clk = 0;
reg rst, rd_en, wr_en;
reg [7:0] data_in;
wire [7:0] data_out;
wire empty, full;

// instantiate the DUT
fifo_sync dut(
.clk(clk),		//clock
.rst(rst),		//reset
.rd_en(rd_en),		//read enable
.wr_en(wr_en),		//write enable
.data_in(data_in),	//Data In
.data_out(data_out),	//Data Out
.empty(empty),		//FIFO Empty Signal
.full(full)		//FIFO Full Signal
);

//generate clock
always     // no sensitivity list, so it always executes
begin
clk = 1; #5; clk = 0; #5; // 10ns period
end

//apply inputs one at a time

initial
begin
$dumpfile("fifo_sync_tb.vcd");
$dumpvars(0,fifo_sync_tb);
end

initial begin
$monitor("At time%t \tdata_in = %b, wr_en = %b, rd_en = %b, data_out = %b,",$time,data_in,wr_en,rd_en,data_out);
end

initial
begin
rst = 0; #10;
rst = 1; #10;
wr_en = 1; #10;
data_in = 8'b11111111; #10;
data_in = 8'b10010110; #10;
data_in = 8'b00000001; #10;
data_in = 8'b11011011; #10;
data_in = 8'b10000000; #10;
data_in = 8'b00011100; #10;
data_in = 8'b11011010; #10;
data_in = 8'b00000000; #10;
data_in = 8'b11010100; #10;
data_in = 8'b11011111; #10;
data_in = 8'b10110111; #10;
data_in = 8'b00110011; #10;
data_in = 8'b10101011; #10;
data_in = 8'b01010101; #10;
data_in = 8'b10101000; #10;
rd_en = 1;
data_in = 8'b00001111; #10;
data_in = 8'b11100011; #10;
wr_en=0;
data_in = 8'b11111111; #10;
data_in = 8'b10010110; #10;
data_in = 8'b00000001; #10;
data_in = 8'b11011011; #10;
data_in = 8'b10000000; #10;
data_in = 8'b00011100; #10;
data_in = 8'b11011010; #10;
data_in = 8'b00000000; #10;
data_in = 8'b11010100; #10;
data_in = 8'b11011111; #10;
data_in = 8'b10110111; #10;
data_in = 8'b00110011; #10;
data_in = 8'b10101011; #10;
data_in = 8'b01010101; #10;
data_in = 8'b10101000; #10;
#100;
$display("----COMPLETE----");
end

endmodule

