
 `timescale 1ns / 1ps
 module top();
   bit clock;
   bit ARESETn;

   import pkg::*;
   import uvm_pkg::*;

   // Interface Instantiation
   axi_master_interface a_mif_0(clock);
   axi_master_interface a_mif_1(clock);

   axi_slave_interface a_sif_0(clock);
   axi_slave_interface a_sif_1(clock);
   axi_slave_interface a_sif_2(clock);

   axi_callback_interface call_if(clock);

   reset_interface rst_if(clock);

	axi_interconnect_wrapper AXI_INC(
					.clk(a_mif_0.clock),
					.rst(rst_if.reset),

					.s00_axi_awid(a_mif_0.AWID),
					.s00_axi_awaddr(a_mif_0.AWADDR),
					.s00_axi_awlen(a_mif_0.AWLEN),
					.s00_axi_awsize(a_mif_0.AWSIZE),
					.s00_axi_awburst(a_mif_0.AWBURST),
					.s00_axi_awlock(a_mif_0.AWLOCK),
					.s00_axi_awcache(a_mif_0.AWCACHE),
					.s00_axi_awprot(a_mif_0.AWPROT),
					.s00_axi_awqos(a_mif_0.AWQOS),
					.s00_axi_awuser(a_mif_0.AWUSER),
					.s00_axi_awvalid(a_mif_0.AWVALID),
					.s00_axi_awready(a_mif_0.AWREADY),
					
					.s00_axi_wdata(a_mif_0.WDATA),
					.s00_axi_wstrb(a_mif_0.WSTRB),
					.s00_axi_wlast(a_mif_0.WLAST),
					.s00_axi_wuser(a_mif_0.WUSER),
					.s00_axi_wvalid(a_mif_0.WVALID),
					.s00_axi_wready(a_mif_0.WREADY),

					.s00_axi_bid(a_mif_0.BID),
					.s00_axi_bresp(a_mif_0.BRESP),
					.s00_axi_buser(a_mif_0.BUSER),
					.s00_axi_bvalid(a_mif_0.BVALID),
					.s00_axi_bready(a_mif_0.BREADY),

					.s00_axi_arid(a_mif_0.ARID),
					.s00_axi_araddr(a_mif_0.ARADDR),
					.s00_axi_arlen(a_mif_0.ARLEN),
					.s00_axi_arsize(a_mif_0.ARSIZE),
					.s00_axi_arburst(a_mif_0.ARBURST),
					.s00_axi_arlock(a_mif_0.ARLOCK),
					.s00_axi_arcache(a_mif_0.ARCACHE),
					.s00_axi_arprot(a_mif_0.ARPROT),
					.s00_axi_arqos(a_mif_0.ARQOS),
					.s00_axi_aruser(a_mif_0.ARUSER),
					.s00_axi_arvalid(a_mif_0.ARVALID),
					.s00_axi_arready(a_mif_0.ARREADY),

					.s00_axi_rid(a_mif_0.RID),
					.s00_axi_rdata(a_mif_0.RDATA),
					.s00_axi_rresp(a_mif_0.RRESP),
					.s00_axi_rlast(a_mif_0.RLAST),
					.s00_axi_ruser(a_mif_0.RUSER),
					.s00_axi_rvalid(a_mif_0.RVALID),
					.s00_axi_rready(a_mif_0.RREADY),

					.s01_axi_awid(a_mif_1.AWID),
					.s01_axi_awaddr(a_mif_1.AWADDR),
					.s01_axi_awlen(a_mif_1.AWLEN),
					.s01_axi_awsize(a_mif_1.AWSIZE),
					.s01_axi_awburst(a_mif_1.AWBURST),
					.s01_axi_awlock(a_mif_1.AWLOCK),
					.s01_axi_awcache(a_mif_1.AWCACHE),
					.s01_axi_awprot(a_mif_1.AWPROT),
					.s01_axi_awqos(a_mif_1.AWQOS),
					.s01_axi_awuser(a_mif_1.AWUSER),
					.s01_axi_awvalid(a_mif_1.AWVALID),
					.s01_axi_awready(a_mif_1.AWREADY),
					
					.s01_axi_wdata(a_mif_1.WDATA),
					.s01_axi_wstrb(a_mif_1.WSTRB),
					.s01_axi_wlast(a_mif_1.WLAST),
					.s01_axi_wuser(a_mif_1.WUSER),
					.s01_axi_wvalid(a_mif_1.WVALID),
					.s01_axi_wready(a_mif_1.WREADY),

					.s01_axi_bid(a_mif_1.BID),
					.s01_axi_bresp(a_mif_1.BRESP),
					.s01_axi_buser(a_mif_1.BUSER),
					.s01_axi_bvalid(a_mif_1.BVALID),
					.s01_axi_bready(a_mif_1.BREADY),

					.s01_axi_arid(a_mif_1.ARID),
					.s01_axi_araddr(a_mif_1.ARADDR),
					.s01_axi_arlen(a_mif_1.ARLEN),
					.s01_axi_arsize(a_mif_1.ARSIZE),
					.s01_axi_arburst(a_mif_1.ARBURST),
					.s01_axi_arlock(a_mif_1.ARLOCK),
					.s01_axi_arcache(a_mif_1.ARCACHE),
					.s01_axi_arprot(a_mif_1.ARPROT),
					.s01_axi_arqos(a_mif_1.ARQOS),
					.s01_axi_aruser(a_mif_1.ARUSER),
					.s01_axi_arvalid(a_mif_1.ARVALID),
					.s01_axi_arready(a_mif_1.ARREADY),

					.s01_axi_rid(a_mif_1.RID),
					.s01_axi_rdata(a_mif_1.RDATA),
					.s01_axi_rresp(a_mif_1.RRESP),
					.s01_axi_rlast(a_mif_1.RLAST),
					.s01_axi_ruser(a_mif_1.RUSER),
					.s01_axi_rvalid(a_mif_1.RVALID),
					.s01_axi_rready(a_mif_1.RREADY),


					.m00_axi_awid(a_sif_0.AWID),
					.m00_axi_awaddr(a_sif_0.AWADDR),
					.m00_axi_awlen(a_sif_0.AWLEN),
					.m00_axi_awsize(a_sif_0.AWSIZE),
					.m00_axi_awburst(a_sif_0.AWBURST),
					.m00_axi_awlock(a_sif_0.AWLOCK),
					.m00_axi_awcache(a_sif_0.AWCACHE),
					.m00_axi_awprot(a_sif_0.AWPROT),
					.m00_axi_awqos(a_sif_0.AWQOS),
				       	.m00_axi_awregion(a_sif_0.AWREGION),
					.m00_axi_awuser(a_sif_0.AWUSER),
					.m00_axi_awvalid(a_sif_0.AWVALID),
					.m00_axi_awready(a_sif_0.AWREADY),					

					.m00_axi_wdata(a_sif_0.WDATA),
					.m00_axi_wstrb(a_sif_0.WSTRB),
					.m00_axi_wlast(a_sif_0.WLAST),
					.m00_axi_wuser(a_sif_0.WUSER),
					.m00_axi_wvalid(a_sif_0.WVALID),
					.m00_axi_wready(a_sif_0.WREADY),

					.m00_axi_bid(a_sif_0.BID),
					.m00_axi_bresp(a_sif_0.BRESP),
					.m00_axi_buser(a_sif_0.BUSER),
					.m00_axi_bvalid(a_sif_0.BVALID),
					.m00_axi_bready(a_sif_0.BREADY),

					.m00_axi_arid(a_sif_0.ARID),
					.m00_axi_araddr(a_sif_0.ARADDR),
					.m00_axi_arlen(a_sif_0.ARLEN),
					.m00_axi_arsize(a_sif_0.ARSIZE),
					.m00_axi_arburst(a_sif_0.ARBURST),
					.m00_axi_arlock(a_sif_0.ARLOCK),
					.m00_axi_arcache(a_sif_0.ARCACHE),
					.m00_axi_arprot(a_sif_0.ARPROT),
					.m00_axi_arqos(a_sif_0.ARQOS),
				       	.m00_axi_arregion(a_sif_0.ARREGION),
					.m00_axi_aruser(a_sif_0.ARUSER),
					.m00_axi_arvalid(a_sif_0.ARVALID),
					.m00_axi_arready(a_sif_0.ARREADY),

					.m00_axi_rid(a_sif_0.RID),
					.m00_axi_rdata(a_sif_0.RDATA),
					.m00_axi_rresp(a_sif_0.RRESP),
					.m00_axi_rlast(a_sif_0.RLAST),
					.m00_axi_ruser(a_sif_0.RUSER),
					.m00_axi_rvalid(a_sif_0.RVALID),
					.m00_axi_rready(a_sif_0.RREADY),

					.m01_axi_awid(a_sif_1.AWID),
					.m01_axi_awaddr(a_sif_1.AWADDR),
					.m01_axi_awlen(a_sif_1.AWLEN),
					.m01_axi_awsize(a_sif_1.AWSIZE),
					.m01_axi_awburst(a_sif_1.AWBURST),
					.m01_axi_awlock(a_sif_1.AWLOCK),
					.m01_axi_awcache(a_sif_1.AWCACHE),
					.m01_axi_awprot(a_sif_1.AWPROT),
					.m01_axi_awqos(a_sif_1.AWQOS),
				       	.m01_axi_awregion(a_sif_1.AWREGION),
					.m01_axi_awuser(a_sif_1.AWUSER),
					.m01_axi_awvalid(a_sif_1.AWVALID),
					.m01_axi_awready(a_sif_1.AWREADY),
					
					.m01_axi_wdata(a_sif_1.WDATA),
					.m01_axi_wstrb(a_sif_1.WSTRB),
					.m01_axi_wlast(a_sif_1.WLAST),
					.m01_axi_wuser(a_sif_1.WUSER),
					.m01_axi_wvalid(a_sif_1.WVALID),
					.m01_axi_wready(a_sif_1.WREADY),

					.m01_axi_bid(a_sif_1.BID),
					.m01_axi_bresp(a_sif_1.BRESP),
					.m01_axi_buser(a_sif_1.BUSER),
					.m01_axi_bvalid(a_sif_1.BVALID),
					.m01_axi_bready(a_sif_1.BREADY),

					.m01_axi_arid(a_sif_1.ARID),
					.m01_axi_araddr(a_sif_1.ARADDR),
					.m01_axi_arlen(a_sif_1.ARLEN),
					.m01_axi_arsize(a_sif_1.ARSIZE),
					.m01_axi_arburst(a_sif_1.ARBURST),
					.m01_axi_arlock(a_sif_1.ARLOCK),
					.m01_axi_arcache(a_sif_1.ARCACHE),
					.m01_axi_arprot(a_sif_1.ARPROT),
					.m01_axi_arqos(a_sif_1.ARQOS),
				       	.m01_axi_arregion(a_sif_1.ARREGION),
					.m01_axi_aruser(a_sif_1.ARUSER),
					.m01_axi_arvalid(a_sif_1.ARVALID),
					.m01_axi_arready(a_sif_1.ARREADY),

					.m01_axi_rid(a_sif_1.RID),
					.m01_axi_rdata(a_sif_1.RDATA),
					.m01_axi_rresp(a_sif_1.RRESP),
					.m01_axi_rlast(a_sif_1.RLAST),
					.m01_axi_ruser(a_sif_1.RUSER),
					.m01_axi_rvalid(a_sif_1.RVALID),
					.m01_axi_rready(a_sif_1.RREADY),

					.m02_axi_awid(a_sif_2.AWID),
					.m02_axi_awaddr(a_sif_2.AWADDR),
					.m02_axi_awlen(a_sif_2.AWLEN),
					.m02_axi_awsize(a_sif_2.AWSIZE),
					.m02_axi_awburst(a_sif_2.AWBURST),
					.m02_axi_awlock(a_sif_2.AWLOCK),
					.m02_axi_awcache(a_sif_2.AWCACHE),
					.m02_axi_awprot(a_sif_2.AWPROT),
					.m02_axi_awqos(a_sif_2.AWQOS),
				       	.m02_axi_awregion(a_sif_2.AWREGION),
					.m02_axi_awuser(a_sif_2.AWUSER),
					.m02_axi_awvalid(a_sif_2.AWVALID),
					.m02_axi_awready(a_sif_2.AWREADY),
					
					.m02_axi_wdata(a_sif_2.WDATA),
					.m02_axi_wstrb(a_sif_2.WSTRB),
					.m02_axi_wlast(a_sif_2.WLAST),
					.m02_axi_wuser(a_sif_2.WUSER),
					.m02_axi_wvalid(a_sif_2.WVALID),
					.m02_axi_wready(a_sif_2.WREADY),

					.m02_axi_bid(a_sif_2.BID),
					.m02_axi_bresp(a_sif_2.BRESP),
					.m02_axi_buser(a_sif_2.BUSER),
					.m02_axi_bvalid(a_sif_2.BVALID),
					.m02_axi_bready(a_sif_2.BREADY),

					.m02_axi_arid(a_sif_2.ARID),
					.m02_axi_araddr(a_sif_2.ARADDR),
					.m02_axi_arlen(a_sif_2.ARLEN),
					.m02_axi_arsize(a_sif_2.ARSIZE),
					.m02_axi_arburst(a_sif_2.ARBURST),
					.m02_axi_arlock(a_sif_2.ARLOCK),
					.m02_axi_arcache(a_sif_2.ARCACHE),
					.m02_axi_arprot(a_sif_2.ARPROT),
					.m02_axi_arqos(a_sif_2.ARQOS),
				       	.m02_axi_arregion(a_sif_2.ARREGION),
					.m02_axi_aruser(a_sif_2.ARUSER),
					.m02_axi_arvalid(a_sif_2.ARVALID),
					.m02_axi_arready(a_sif_2.ARREADY),

					.m02_axi_rid(a_sif_2.RID),
					.m02_axi_rdata(a_sif_2.RDATA),
					.m02_axi_rresp(a_sif_2.RRESP),
					.m02_axi_rlast(a_sif_2.RLAST),
					.m02_axi_ruser(a_sif_2.RUSER),
					.m02_axi_rvalid(a_sif_2.RVALID),
					.m02_axi_rready(a_sif_2.RREADY)
                                        );


   initial
     begin
       clock =1'b0;
       forever
	 #5 clock =~clock;
     end
   
   initial
     begin
       `ifdef VCS
         $fsdbDumpvars(0, top);
         $fsdbDumpSVA(0, top);
       `endif
		
       // Set Virtual Interface
       uvm_config_db #(virtual axi_master_interface) :: set(null, "*", "axi_mif_0", a_mif_0);
       uvm_config_db #(virtual axi_master_interface) :: set(null, "*", "axi_mif_1", a_mif_1);

       uvm_config_db #(virtual axi_slave_interface) :: set(null, "*", "axi_sif_0", a_sif_0);
       uvm_config_db #(virtual axi_slave_interface) :: set(null, "*", "axi_sif_1", a_sif_1);
       uvm_config_db #(virtual axi_slave_interface) :: set(null, "*", "axi_sif_2", a_sif_2);
       
       uvm_config_db #(virtual reset_interface) :: set(null, "*", "reset_interface", rst_if);

       uvm_config_db #(virtual axi_callback_interface) :: set(null, "*", "axi_callback_interface", call_if);

       //Call Run Test
       run_test();
     end
 endmodule



