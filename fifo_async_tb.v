//****************************************************
// Function	: Testbench for Asynchronous FIFO
//****************************************************

//Testbench Definition
module fifo_async_tb ();

//Inputs
reg read_en, read_clk, write_en, write_clk, reset; 
reg [7:0] data_in;

//Outputs
wire [7:0] data_out;
wire empty, full;

//Variables
integer i;
integer j = 0;

// Instantiate the DUT
fifo_async dut(
.data_out(data_out),	
.empty(empty),		
.read_en(read_en),
.read_clk(read_clk),	
.data_in(data_in),
.full(full),
.write_en(write_en),
.write_clk(write_clk),	
.reset(reset)		
);

//initial Conditions
initial
begin
 reset  = 1'b0;
 write_en    = 1'b0;
 read_en     = 1'b0;
 data_in     = 8'd0;
 $dumpfile("fifo_async_tb.vcd");
 $dumpvars(0,fifo_async_tb);
end

//generate write clock
always     // no sensitivity list, so it always executes
begin
write_clk = 1; #5; write_clk = 0; #5; // 10ns period
end

//generate read clock
always
begin
read_clk=1; #5; read_clk=0; #5; // 20ns period
end

//reset sequence
initial
begin
 #(10*2)
 reset = 1'b1;
 #10;
 reset = 1'b0;
 #10;
 reset = 1'b1;
end

//Simulation begins
initial begin
$monitor("At time%t \tdata_in = %b, wr_en = %b, rd_en = %b, data_out = %b,",$time,data_in,write_en,read_en,data_out);
end

initial
begin
	main;
end

task main;
	begin
         
	  for (i = 0; i < 17; i = i + 1) begin: WRE
                #(10*5)
                write_en = 1'b1;
                data_in = data_in + 8'd1;
                #(10*2)
                write_en = 1'b0;
           end
        
	   #10;
        
	   for (i = 0; i < 17; i = i + 1) begin: RDE
                #(10*2)
                read_en = 1'b1;
                #(10*2)
                read_en = 1'b0;
        	j = 1;
	   end
	if(j) begin
		$display("---- COMPLETE ----");
		$finish;
		end
	end

endtask
endmodule
