
`timescale 1ps/1ps
module kernel_system_tb;


reg clock;
reg clock2x;
reg resetn;

wire [31:0] address;
wire read;
wire write;
wire [511:0] data_out;
wire enable;
wire [63:0] byte_enable;
wire [4:0] burst_count;


wire kernel_irq;
wire avs_cra_readdatavalid;
wire [63:0] avs_cra_readdata;
reg avs_cra_write;
wire avs_cra_waitrequest;
reg [29:0] avs_cra_address;
reg [63:0] avs_cra_writedata;

reg [30:0] cc_snoop_data;
reg cc_snoop_valid;
wire cc_snoop_ready;

kernel_system kernel_system_inst (
		.cc_snoop_data(0),             //          cc_snoop.data
		.cc_snoop_valid(0),            //                  .valid
		.cc_snoop_ready(),            //                  .ready
		.cc_snoop_clk_clk(clock),          //      cc_snoop_clk.clk
		.clock_reset_clk(clock),           //       clock_reset.clk
		.clock_reset2x_clk(clock2x),         //     clock_reset2x.clk
		.clock_reset_reset_reset_n(resetn), // clock_reset_reset.reset_n
		.kernel_cra_waitrequest(avs_cra_waitrequest),    //        kernel_cra.waitrequest
		.kernel_cra_readdata(avs_cra_readdata),       //                  .readdata
		.kernel_cra_readdatavalid(avs_cra_readdatavalid),  //                  .readdatavalid
		.kernel_cra_burstcount(0),     //                  .burstcount
		.kernel_cra_writedata(avs_cra_writedata),      //                  .writedata
		.kernel_cra_address(avs_cra_address),        //                  .address
		.kernel_cra_write(avs_cra_write),          //                  .write
		.kernel_cra_read(1'b0),           //                  .read
		.kernel_cra_byteenable(8'hFF),     //                  .byteenable
		.kernel_cra_debugaccess(0),    //                  .debugaccess
		.kernel_irq_irq(kernel_irq),            //        kernel_irq.irq
		.kernel_mem0_waitrequest(1'b0),   //       kernel_mem0.waitrequest
		.kernel_mem0_readdata(512'h40000000_40000000_40000000_40000000_40000000_40000000_40000000_40000000_40000000_40000000_40000000_40000000_40000000_40000000_40000000_40000000),      //                  .readdata
		.kernel_mem0_readdatavalid(1'b1), //                  .readdatavalid
		.kernel_mem0_burstcount(burst_count),    //                  .burstcount
		.kernel_mem0_writedata(data_out),     //                  .writedata
		.kernel_mem0_address(address),       //                  .address
		.kernel_mem0_write(write),         //                  .write
		.kernel_mem0_read(read),          //                  .read
		.kernel_mem0_byteenable(byte_enable),    //                  .byteenable
		.kernel_mem0_debugaccess()    //                  .debugaccess
	);


always #10 clock = ~clock;
always #5 clock2x = ~clock2x;


initial begin
clock = 0;
clock2x = 1;
resetn = 0;
avs_cra_write = 0;
avs_cra_address = 0;
avs_cra_write = 0;
cc_snoop_data = 0;
cc_snoop_valid = 0;


#100;
resetn = 1;
avs_cra_write = 1;
avs_cra_address = 30'h5 << 3;
avs_cra_writedata = 64'h00000001_00000001; // workgroup_size , work_dim
#20;
avs_cra_write = 1;
avs_cra_address = 30'h6 << 3;
avs_cra_writedata = 64'h00000001_00000001; // global_size[1] , global_size[0]
#20;
avs_cra_write = 1;
avs_cra_address = 30'h7 << 3;
avs_cra_writedata = 64'h00000001_00000001; // num_groups[0] , global_size[2]
#20;
avs_cra_write = 1;
avs_cra_address = 30'h8 << 3;
avs_cra_writedata = 64'h00000001_00000001; // num_groups[2] , num_groups[1]
#20;
avs_cra_write = 1;
avs_cra_address = 30'h9 << 3;
avs_cra_writedata = 64'h00000001_00000001; // local_size[1] , local_size[0]
#20;
avs_cra_write = 1;
avs_cra_address = 30'hA << 3;
avs_cra_writedata = 64'h00000000_00000001; // global_offset[0] , local_size[2]
#20;
avs_cra_write = 1;
avs_cra_address = 30'hB << 3;
avs_cra_writedata = 64'h00000000_00000000; // global_offset[2] , global_offset[1]
#20;
avs_cra_write = 1;
avs_cra_address = 30'hC << 3;
avs_cra_writedata = 64'h00000000_40000000; //  kernel_argument_address: A   
#20;
avs_cra_write = 1;
avs_cra_address = 30'hD << 3;
avs_cra_writedata = 64'h00000000_80000000; // kernel_argument_address: B    
#20;
avs_cra_write = 1;
avs_cra_address = 30'hE << 3;
avs_cra_writedata = 64'h00000000_C0000000; // kernel_argument_address: C  
#20;
avs_cra_write = 1;
avs_cra_address = 30'h0 << 3;
avs_cra_writedata = 64'h00000000_00000001; // start
#20;
avs_cra_write = 0;
avs_cra_address = 30'h0 << 3;
avs_cra_writedata = 64'h00000000_00000000; // idle


end

endmodule
