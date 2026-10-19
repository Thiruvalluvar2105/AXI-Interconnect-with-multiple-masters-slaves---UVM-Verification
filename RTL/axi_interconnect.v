


   module axi_interconnect #(
                             // Number of AXI master inputs (slave interfaces)
                             parameter NUM_MASTERS = 2,
                             // Number of AXI slave outputs (master interfaces)
                             parameter NUM_SLAVES = 3,
                             // Width of data bus in bits
                             parameter DATA_WIDTH = 32,
                             // Width of address bus in bits
                             parameter ADDR_WIDTH = 32,
                             // Width of wstrb (width of data bus in words)
                             parameter STRB_WIDTH = (DATA_WIDTH/8),
                             // Width of ID signal
                             parameter ID_WIDTH = 8,
                             // Width of awuser signal
                             parameter AWUSER_WIDTH = 1,
                             // Width of wuser signal
                             parameter WUSER_WIDTH = 1,
                             // Width of buser signal
                             parameter BUSER_WIDTH = 1,
                             // Width of aruser signal
                             parameter ARUSER_WIDTH = 1,
                             // Width of ruser signal
                             parameter RUSER_WIDTH = 1,
                             // Priority LSB/MSB
                             parameter ARB_LSB_HIGH_PRIORITY = 1,
                             // Number of Outstanding request supported
                             parameter OUTSTANDING_REQUEST = 4
                            )
                            (
                             input                              clk,
                             input                              rst,
                         
                             /*
                              * AXI slave interfaces
                              */
                             input   [NUM_MASTERS*ID_WIDTH-1:0]     s_axi_awid,
                             input   [NUM_MASTERS*ADDR_WIDTH-1:0]   s_axi_awaddr,
                             input   [NUM_MASTERS*8-1:0]            s_axi_awlen,
                             input   [NUM_MASTERS*3-1:0]            s_axi_awsize,
                             input   [NUM_MASTERS*2-1:0]            s_axi_awburst,
                             input   [NUM_MASTERS-1:0]              s_axi_awlock,
                             input   [NUM_MASTERS*4-1:0]            s_axi_awcache,
                             input   [NUM_MASTERS*3-1:0]            s_axi_awprot,
                             input   [NUM_MASTERS*4-1:0]            s_axi_awqos,
                             input   [NUM_MASTERS*AWUSER_WIDTH-1:0] s_axi_awuser,
                             input   [NUM_MASTERS-1:0]              s_axi_awvalid,
                             output  reg [NUM_MASTERS-1:0]              s_axi_awready,

                             input   [NUM_MASTERS*DATA_WIDTH-1:0]   s_axi_wdata,
                             input   [NUM_MASTERS*STRB_WIDTH-1:0]   s_axi_wstrb,
                             input   [NUM_MASTERS-1:0]              s_axi_wlast,
                             input   [NUM_MASTERS*WUSER_WIDTH-1:0]  s_axi_wuser,
                             input   [NUM_MASTERS-1:0]              s_axi_wvalid,
                             output  [NUM_MASTERS-1:0]              s_axi_wready,

                             output  [NUM_MASTERS*ID_WIDTH-1:0]     s_axi_bid,
                             output  [NUM_MASTERS*2-1:0]            s_axi_bresp,
                             output  [NUM_MASTERS*BUSER_WIDTH-1:0]  s_axi_buser,
                             output  [NUM_MASTERS-1:0]              s_axi_bvalid,
                             input   [NUM_MASTERS-1:0]              s_axi_bready,

                             input   [NUM_MASTERS*ID_WIDTH-1:0]     s_axi_arid,
                             input   [NUM_MASTERS*ADDR_WIDTH-1:0]   s_axi_araddr,
                             input   [NUM_MASTERS*8-1:0]            s_axi_arlen,
                             input   [NUM_MASTERS*3-1:0]            s_axi_arsize,
                             input   [NUM_MASTERS*2-1:0]            s_axi_arburst,
                             input   [NUM_MASTERS-1:0]              s_axi_arlock,
                             input   [NUM_MASTERS*4-1:0]            s_axi_arcache,
                             input   [NUM_MASTERS*3-1:0]            s_axi_arprot,
                             input   [NUM_MASTERS*4-1:0]            s_axi_arqos,
                             input   [NUM_MASTERS*ARUSER_WIDTH-1:0] s_axi_aruser,
                             input   [NUM_MASTERS-1:0]              s_axi_arvalid,
                             output  reg [NUM_MASTERS-1:0]              s_axi_arready,

                             output  [NUM_MASTERS*ID_WIDTH-1:0]     s_axi_rid,
                             output  [NUM_MASTERS*DATA_WIDTH-1:0]   s_axi_rdata,
                             output  [NUM_MASTERS*2-1:0]            s_axi_rresp,
                             output  [NUM_MASTERS-1:0]              s_axi_rlast,
                             output  [NUM_MASTERS*RUSER_WIDTH-1:0]  s_axi_ruser,
                             output  [NUM_MASTERS-1:0]              s_axi_rvalid,
                             input   [NUM_MASTERS-1:0]              s_axi_rready,
                         
                             /*
                              * AXI master interfaces
                              */
                             output  [NUM_SLAVES*ID_WIDTH-1:0]     m_axi_awid,
                             output  [NUM_SLAVES*ADDR_WIDTH-1:0]   m_axi_awaddr,
                             output  [NUM_SLAVES*8-1:0]            m_axi_awlen,
                             output  [NUM_SLAVES*3-1:0]            m_axi_awsize,
                             output  [NUM_SLAVES*2-1:0]            m_axi_awburst,
                             output  [NUM_SLAVES-1:0]              m_axi_awlock,
                             output  [NUM_SLAVES*4-1:0]            m_axi_awcache,
                             output  [NUM_SLAVES*3-1:0]            m_axi_awprot,
                             output  [NUM_SLAVES*4-1:0]            m_axi_awqos,
                             output  [NUM_SLAVES*4-1:0]            m_axi_awregion,
                             output  [NUM_SLAVES*AWUSER_WIDTH-1:0] m_axi_awuser,
                             output  [NUM_SLAVES-1:0]              m_axi_awvalid,
                             input   [NUM_SLAVES-1:0]              m_axi_awready,

                             output  [NUM_SLAVES*DATA_WIDTH-1:0]   m_axi_wdata,
                             output  [NUM_SLAVES*STRB_WIDTH-1:0]   m_axi_wstrb,
                             output  [NUM_SLAVES-1:0]              m_axi_wlast,
                             output  [NUM_SLAVES*WUSER_WIDTH-1:0]  m_axi_wuser,
                             output  [NUM_SLAVES-1:0]              m_axi_wvalid,
                             input   [NUM_SLAVES-1:0]              m_axi_wready,

                             input   [NUM_SLAVES*ID_WIDTH-1:0]     m_axi_bid,
                             input   [NUM_SLAVES*2-1:0]            m_axi_bresp,
                             input   [NUM_SLAVES*BUSER_WIDTH-1:0]  m_axi_buser,
                             input   [NUM_SLAVES-1:0]              m_axi_bvalid,
                             output  [NUM_SLAVES-1:0]              m_axi_bready,

                             output  [NUM_SLAVES*ID_WIDTH-1:0]     m_axi_arid,
                             output  [NUM_SLAVES*ADDR_WIDTH-1:0]   m_axi_araddr,
                             output  [NUM_SLAVES*8-1:0]            m_axi_arlen,
                             output  [NUM_SLAVES*3-1:0]            m_axi_arsize,
                             output  [NUM_SLAVES*2-1:0]            m_axi_arburst,
                             output  [NUM_SLAVES-1:0]              m_axi_arlock,
                             output  [NUM_SLAVES*4-1:0]            m_axi_arcache,
                             output  [NUM_SLAVES*3-1:0]            m_axi_arprot,
                             output  [NUM_SLAVES*4-1:0]            m_axi_arqos,
                             output  [NUM_SLAVES*4-1:0]            m_axi_arregion,
                             output  [NUM_SLAVES*ARUSER_WIDTH-1:0] m_axi_aruser,
                             output  [NUM_SLAVES-1:0]              m_axi_arvalid,
                             input   [NUM_SLAVES-1:0]              m_axi_arready,

                             input   [NUM_SLAVES*ID_WIDTH-1:0]     m_axi_rid,
                             input   [NUM_SLAVES*DATA_WIDTH-1:0]   m_axi_rdata,
                             input   [NUM_SLAVES*2-1:0]            m_axi_rresp,
                             input   [NUM_SLAVES-1:0]              m_axi_rlast,
                             input   [NUM_SLAVES*RUSER_WIDTH-1:0]  m_axi_ruser,
                             input   [NUM_SLAVES-1:0]              m_axi_rvalid,
                             output  [NUM_SLAVES-1:0]              m_axi_rready
                            );

     localparam SLAVE_ID_WIDTH = $clog2(NUM_SLAVES);
     localparam MASTER_ID_WIDTH = $clog2(NUM_MASTERS);

    // AW mux outputs (per slave)
    wire aw_s_valid  [NUM_SLAVES-1:0];
    wire [ID_WIDTH-1:0]   aw_s_id   [NUM_SLAVES-1:0];
    wire [ADDR_WIDTH-1:0] aw_s_addr [NUM_SLAVES-1:0];
    wire [7:0]            aw_s_len  [NUM_SLAVES-1:0];
    wire [2:0]            aw_s_size [NUM_SLAVES-1:0];
    wire [1:0]            aw_s_burst[NUM_SLAVES-1:0];
    wire [NUM_MASTERS-1:0] aw_m_ready [NUM_SLAVES-1:0];
    wire [NUM_SLAVES-1:0]  aw_s_ready [NUM_MASTERS-1:0];
    wire aw_s_lock [NUM_SLAVES-1:0];
    wire [3:0] aw_s_cache[NUM_SLAVES-1:0];
    wire [2:0] aw_s_prot[NUM_SLAVES-1:0];
    wire [3:0] aw_s_qos[NUM_SLAVES-1:0];
    wire [AWUSER_WIDTH-1:0] aw_s_user[NUM_SLAVES-1:0];

    wire [DATA_WIDTH-1:0] w_s_wdata[NUM_SLAVES-1:0];
    wire [STRB_WIDTH-1:0] w_s_wstrb[NUM_SLAVES-1:0];
    wire w_s_wlast[NUM_SLAVES-1:0];
    wire w_s_wvalid[NUM_SLAVES-1:0];
    wire [WUSER_WIDTH-1:0] w_s_wuser[NUM_SLAVES-1:0];
    wire [NUM_MASTERS-1:0] w_m_ready [NUM_SLAVES-1:0];
    wire [NUM_SLAVES-1:0] w_s_ready [NUM_MASTERS-1:0];


    // AW push outputs for tracker/fifo
    wire aw_push_valid [NUM_SLAVES-1:0];
    wire [ID_WIDTH-1:0] aw_push_id [NUM_SLAVES-1:0];
    wire [$clog2(NUM_MASTERS)-1:0] aw_push_master [NUM_SLAVES-1:0];
    wire [7:0] aw_push_awlen [NUM_SLAVES-1:0];

    wire [NUM_SLAVES-1:0] aw_push_valids;
    wire [NUM_SLAVES*$clog2(NUM_SLAVES)-1:0] aw_push_slave_ids;
    wire [NUM_SLAVES*$clog2(NUM_MASTERS)-1:0] aw_push_masters;

    // AR mux outputs (per slave)
    wire ar_s_valid  [0:NUM_SLAVES-1];
    wire [NUM_SLAVES-1:0] outstanding_write_full;
    wire [NUM_SLAVES-1:0] outstanding_read_full;
    wire [ID_WIDTH-1:0]   ar_s_id   [NUM_SLAVES-1:0];
    wire [ADDR_WIDTH-1:0] ar_s_addr [NUM_SLAVES-1:0];
    wire [7:0]            ar_s_len  [NUM_SLAVES-1:0];
    wire [2:0]            ar_s_size [NUM_SLAVES-1:0];
    wire [1:0]            ar_s_burst[NUM_SLAVES-1:0];
    wire [NUM_MASTERS-1:0] ar_m_ready [NUM_SLAVES-1:0];
    wire [NUM_SLAVES-1:0] ar_s_ready [NUM_MASTERS-1:0];
    wire ar_s_lock [NUM_SLAVES-1:0];
    wire [3:0] ar_s_cache[NUM_SLAVES-1:0];
    wire [2:0] ar_s_prot[NUM_SLAVES-1:0];
    wire [3:0] ar_s_qos[NUM_SLAVES-1:0];
    wire [ARUSER_WIDTH-1:0] ar_s_user[NUM_SLAVES-1:0];

    // AR push outputs
    wire ar_push_valid [NUM_SLAVES-1:0];
    wire [ID_WIDTH-1:0] ar_push_id [NUM_SLAVES-1:0];
    wire [$clog2(NUM_MASTERS)-1:0] ar_push_master [NUM_SLAVES-1:0];
    wire [7:0] ar_push_arlen [NUM_SLAVES-1:0];

    wire [NUM_SLAVES*$clog2(NUM_SLAVES)-1:0] ar_push_masters;

    wire [NUM_MASTERS-1:0]slave_mem_pop[NUM_SLAVES-1:0];
    wire [NUM_SLAVES-1:0] mem_pop [NUM_SLAVES-1:0];

    wire [NUM_SLAVES-1:0] matched_bready [NUM_MASTERS-1:0];
    wire [NUM_MASTERS-1:0] tracker_bready [NUM_SLAVES-1:0];
    wire [NUM_SLAVES-1:0] matched_rready [NUM_MASTERS-1:0];
    wire [NUM_MASTERS-1:0] tracker_rready [NUM_SLAVES-1:0];

    wire [NUM_SLAVES-1:0]write_matched_ack [NUM_MASTERS-1:0];
    wire [NUM_SLAVES-1:0]read_matched_ack [NUM_MASTERS-1:0];

    wire [NUM_MASTERS-1:0]w_matched_ack [NUM_SLAVES-1:0];
    wire [NUM_MASTERS-1:0]r_matched_ack [NUM_SLAVES-1:0];
    genvar p,q,o,l;
    generate 
      for(p=0;p<NUM_MASTERS;p=p+1)
        begin : READY_ROUTER
          for(q=0;q<NUM_SLAVES;q=q+1)
            begin : ROUTER 
              assign mem_pop[p][q] = slave_mem_pop[q][p];
              assign aw_s_ready[p][q] = aw_m_ready[q][p];
              assign w_s_ready[p][q]  = w_m_ready[q][p];
              assign ar_s_ready[p][q] = ar_m_ready[q][p];
            end
        end
    endgenerate

    generate
      for(o=0;o<NUM_MASTERS;o=o+1)
        begin : TACKER_READY
          for(l=0;l<NUM_SLAVES;l=l+1)
            begin : ACK
              assign tracker_bready[l][o] = matched_bready[o][l];
              assign tracker_rready[l][o] = matched_rready[o][l]; 
              assign r_matched_ack[l][o] = read_matched_ack[o][l];
              assign w_matched_ack[l][o] = write_matched_ack[o][l];
            end
         end
    endgenerate

// Write address ready and Read address ready routing
genvar t;
generate
  for (t = 0; t < NUM_MASTERS; t = t + 1) 
    begin : READY_ROUTE_DECODE

      // Combinatorial logic for s_axi_awready
      always @(*) 
        begin
          // Default assignment to prevent latches and handle "no match"
          s_axi_awready[t] = 1'b0; 
          
          if (s_axi_awaddr[t*ADDR_WIDTH +: ADDR_WIDTH] >= 'h40000000 && s_axi_awaddr[t*ADDR_WIDTH +: ADDR_WIDTH] <= 'h40000FFF)
            s_axi_awready[t] = aw_s_ready[t][0];
          else if (s_axi_awaddr[t*ADDR_WIDTH +: ADDR_WIDTH] >= 'h40001000 && s_axi_awaddr[t*ADDR_WIDTH +: ADDR_WIDTH] <= 'h40001FFF)
            s_axi_awready[t] = aw_s_ready[t][1];
          else if (s_axi_awaddr[t*ADDR_WIDTH +: ADDR_WIDTH] >= 'h40002000 && s_axi_awaddr[t*ADDR_WIDTH +: ADDR_WIDTH] <= 'h40002FFF)
            s_axi_awready[t] = aw_s_ready[t][2];
          
          // You would add more 'else if' blocks here for slaves 3 to 15
        end

      // Combinatorial logic for s_axi_arready
      always @(*) 
        begin
          // Default assignment to prevent latches and handle "no match"
          s_axi_arready[t] = 1'b0; 

          if (s_axi_araddr[t*ADDR_WIDTH +: ADDR_WIDTH] >= 'h40000000 && s_axi_araddr[t*ADDR_WIDTH +: ADDR_WIDTH] <= 'h40000FFF)
            s_axi_arready[t] = ar_s_ready[t][0];
          else if (s_axi_araddr[t*ADDR_WIDTH +: ADDR_WIDTH] >= 'h40001000 && s_axi_araddr[t*ADDR_WIDTH +: ADDR_WIDTH] <= 'h40001FFF)
            s_axi_arready[t] = ar_s_ready[t][1];
          else if (s_axi_araddr[t*ADDR_WIDTH +: ADDR_WIDTH] >= 'h40002000 && s_axi_araddr[t*ADDR_WIDTH +: ADDR_WIDTH] <= 'h40002FFF)
            s_axi_arready[t] = ar_s_ready[t][2];
            
          // You would add more 'else if' blocks here for slaves 3 to 15
        end
        
    end
endgenerate    
    
    // From AW mux for each slave
    wire [$clog2(NUM_SLAVES)-1:0]  aw_push_slave_id [NUM_SLAVES-1:0];

    // From AR mux for each slave
    wire [$clog2(NUM_SLAVES)-1:0]  ar_push_slave_id [NUM_SLAVES-1:0];

    assign m_axi_awregion = 'd0;
    assign m_axi_arregion = 'd0;


     wire [(NUM_MASTERS*SLAVE_ID_WIDTH)-1:0] active_slave;
     wire [NUM_MASTERS-1:0] active_valid;
     wire [NUM_MASTERS-1:0]fifo_empty;

     wire [NUM_SLAVES-1:0] matched_bvalid;
     wire [(NUM_SLAVES*ID_WIDTH)-1:0] matched_bid;
     wire [(NUM_SLAVES*2)-1:0] matched_bresp;
     wire [(NUM_SLAVES*BUSER_WIDTH)-1:0] matched_buser;
     wire [(NUM_SLAVES*MASTER_ID_WIDTH)-1:0] matched_bmaster;

     wire [NUM_SLAVES-1:0] matched_rvalid;
     wire [(NUM_SLAVES*ID_WIDTH)-1:0] matched_rid;
     wire [(NUM_SLAVES*2)-1:0] matched_rresp;
     wire [(NUM_SLAVES*BUSER_WIDTH)-1:0] matched_ruser;
     wire [(NUM_SLAVES*MASTER_ID_WIDTH)-1:0] matched_rmaster;
     wire [(NUM_SLAVES*DATA_WIDTH)-1:0] matched_rdata;
     wire [NUM_SLAVES-1:0] matched_rlast;

     wire [NUM_MASTERS-1:0] tracker_master_busy_w[NUM_SLAVES-1:0];
     wire [NUM_MASTERS-1:0] tracker_master_busy_r[NUM_SLAVES-1:0];

     wire [NUM_MASTERS-1:0] grant_aw [NUM_SLAVES-1:0];
     wire [NUM_MASTERS-1:0] grant_ar [NUM_SLAVES-1:0];
 
     // ---------------------------------------------------------------------------------------
     // 1) Build req_aw and req_ar (address decode) for each slave
     //    set req_aw[slave][master] = 1 if master has awvalid and address decodes to this slave
     // ---------------------------------------------------------------------------------------
     
wire [NUM_SLAVES*NUM_MASTERS-1:0] req_aw;
wire [NUM_SLAVES*NUM_MASTERS-1:0] req_ar;


genvar m;
generate
  for (m = 0; m < NUM_MASTERS; m = m + 1) 
    begin : GEN_DECODE

    wire [ADDR_WIDTH-1:0] awaddr;
    wire [ADDR_WIDTH-1:0] araddr;
      assign awaddr = s_axi_awaddr[m*ADDR_WIDTH +: ADDR_WIDTH];
      assign araddr = s_axi_araddr[m*ADDR_WIDTH +: ADDR_WIDTH];

    // Slave 0 decode
    assign req_aw[0*NUM_MASTERS + m] = (!m_axi_wlast[m] &&
                                       (awaddr >= 32'h4000_0000 && awaddr <= 32'h4000_0FFF));
    assign req_ar[0*NUM_MASTERS + m] = (!s_axi_rlast[m] &&
                                       (araddr >= 32'h4000_0000 && araddr <= 32'h4000_0FFF));

    // Slave 1 decode
    assign req_aw[1*NUM_MASTERS + m] = (!m_axi_wlast[m] &&
                                       (awaddr >= 32'h4000_1000 && awaddr <= 32'h4000_1FFF));
    assign req_ar[1*NUM_MASTERS + m] = (!s_axi_rlast[m] &&
                                       (araddr >= 32'h4000_1000 && araddr <= 32'h4000_1FFF));

    // Slave 2 decode
    assign req_aw[2*NUM_MASTERS + m] = (!m_axi_wlast[m] &&
                                       (awaddr >= 32'h4000_2000 && awaddr <= 32'h4000_2FFF));
    assign req_ar[2*NUM_MASTERS + m] = (!s_axi_rlast[m] &&
                                       (araddr >= 32'h4000_2000 && araddr <= 32'h4000_2FFF));

  end
endgenerate

     // ---------------------------------------------------------------------------------------
     // 2) Per-slave arbiter instances (AW and AR)
     //    Each arbiter uses the per-slave tracker.master_busy to know when to hold
     // ---------------------------------------------------------------------------------------
     genvar s;
     generate
       for(s = 0; s < NUM_SLAVES; s = s + 1) 
         begin : GEN_ARB
           // AW arbiter for slave si
           arbiter #(.NUM_MASTERS(NUM_MASTERS)) 
                    arb_aw 
                    (
                     .clk(clk),
                     .rst(rst),
                     .request(req_aw[s*NUM_MASTERS +: NUM_MASTERS]),
                     .master_busy(tracker_master_busy_w[s]),  // hold until master is not busy for this slave
                     .rready(tracker_bready[s]),
                     .axi_ready(m_axi_bready[s]),
                     .grant(grant_aw[s])
                    );

            // AR arbiter for slave si
            arbiter #(.NUM_MASTERS(NUM_MASTERS)) 
                     arb_ar 
                     (
                      .clk(clk),
                      .rst(rst),
                      .request(req_ar[s*NUM_MASTERS +: NUM_MASTERS]),
                      .master_busy(tracker_master_busy_r[s]),
                      .rready(tracker_rready[s]),
                      .axi_ready(m_axi_rready[s]),
                      .grant(grant_ar[s])
                     );
         end
     endgenerate

     // ---------------------------------------------------------------------------------------
     // 3) Per-slave AW mux (write_address_channel) and AR mux (read_address_channel)
     //    These muxes select the granted master's AW/AR fields and present slave-side AW/AR.
     //    They also export push_valid/push_id/push_master/push_len used by trackers and FIFOs.
     // ---------------------------------------------------------------------------------------
     genvar si;
     generate
       for (si = 0; si < NUM_SLAVES; si = si + 1) 
         begin : GEN_AW_W_AR_MUX
           // write AW mux instance (write_address_channel has the interface we used earlier)
           write_address_channel #(.NUM_MASTERS(NUM_MASTERS),
                             .NUM_SLAVES(NUM_SLAVES),
                             .ADDR_WIDTH(ADDR_WIDTH),
                             .ID_WIDTH(ID_WIDTH),
                             .USER_WIDTH(AWUSER_WIDTH)
                            ) 
                             aw_mux 
                            (
                             .m_addr(s_axi_awaddr),
                             .m_id(s_axi_awid),
                             .m_len(s_axi_awlen),
                             .m_size(s_axi_awsize),
                             .m_burst(s_axi_awburst),
                             .m_lock(s_axi_awlock),
                             .m_cache(s_axi_awcache),
                             .m_prot(s_axi_awprot),
                             .m_qos(s_axi_awqos),
                             .m_user(s_axi_awuser),
                             .m_valid(s_axi_awvalid),
                             .s_ready(m_axi_awready[si]),
                             .master_grant(grant_aw[si]),
                             .full(outstanding_write_full[si]),
                             .s_addr(aw_s_addr[si]),
                             .s_id(aw_s_id[si]),
                             .s_len(aw_s_len[si]),
                             .s_size(aw_s_size[si]),
                             .s_burst(aw_s_burst[si]),
                             .s_lock(aw_s_lock[si]),
                             .s_cache(aw_s_cache[si]),
                             .s_prot(aw_s_prot[si]),
                             .s_qos(aw_s_qos[si]),
                             .s_user(aw_s_user[si]),
                             .m_ready(aw_m_ready[si]),
                             .s_valid(aw_s_valid[si]),
                             .push_valid(aw_push_valid[si]),
                             .push_id(aw_push_id[si]),
                             .push_master(aw_push_master[si]),
                             .push_slave_id(aw_push_slave_id[si]),
                             .slave_index(si[SLAVE_ID_WIDTH-1:0])
                            );

            // wire selected AW fields into flattened m_axi_aw* outputs
            assign m_axi_awvalid[si] = aw_s_valid[si];
            assign m_axi_awaddr[si*ADDR_WIDTH +: ADDR_WIDTH] = aw_s_addr[si];
            assign m_axi_awid  [si*ID_WIDTH +: ID_WIDTH] = aw_s_id[si];
            assign m_axi_awlen [si*8 +: 8] = aw_s_len[si];
            assign m_axi_awsize[si*3 +: 3] = aw_s_size[si];
            assign m_axi_awburst[si*2 +: 2] = aw_s_burst[si];
            // leave other AW fields (AWCACHE, AWPROT, AWQOS) as zeros for simplicity
            assign m_axi_awcache[si*4 +: 4] = aw_s_cache[si];
            assign m_axi_awprot [si*3 +: 3] = aw_s_prot[si];
            assign m_axi_awqos  [si*4 +: 4] = aw_s_qos[si];
            assign m_axi_awuser [si*AWUSER_WIDTH +: AWUSER_WIDTH] = aw_s_user[si];
            assign m_axi_awlock[si] = aw_s_lock[si];

            // AR mux instance (read_address_channel)
            read_address_channel #(
                .NUM_MASTERS(NUM_MASTERS),
                .NUM_SLAVES(NUM_SLAVES),
                .ADDR_WIDTH(ADDR_WIDTH),
                .ID_WIDTH(ID_WIDTH),
                .USER_WIDTH(ARUSER_WIDTH)
                ) 
                 ar_mux 
                (
                .m_addr(s_axi_araddr),
                .m_id(s_axi_arid),
                .m_len(s_axi_arlen),
                .m_size(s_axi_arsize),
                .m_burst(s_axi_arburst),
                .m_lock(s_axi_arlock),
                .m_cache(s_axi_arcache),
                .m_prot(s_axi_arprot),
                .m_qos(s_axi_arqos),
                .m_user(s_axi_aruser),
                .m_valid(s_axi_arvalid),
                .s_ready(m_axi_arready[si]),
                .master_grant(grant_ar[si]),
                .full(outstanding_read_full[si]),
                .s_addr(ar_s_addr[si]),
                .s_id(ar_s_id[si]),
                .s_len(ar_s_len[si]),
                .s_size(ar_s_size[si]),
                .s_burst(ar_s_burst[si]),
                .s_lock(ar_s_lock[si]),
                .s_cache(ar_s_cache[si]),
                .s_prot(ar_s_prot[si]),
                .s_qos(ar_s_qos[si]),
                .s_user(ar_s_user[si]),
                .m_ready(ar_m_ready[si]),
                .s_valid(ar_s_valid[si]),
                .push_valid(ar_push_valid[si]),
                .push_id(ar_push_id[si]),
                .push_master(ar_push_master[si])
            );

            assign m_axi_arvalid[si] = ar_s_valid[si];
            assign m_axi_araddr[si*ADDR_WIDTH +: ADDR_WIDTH] = ar_s_addr[si];
            assign m_axi_arid  [si*ID_WIDTH +: ID_WIDTH] = ar_s_id[si];
            assign m_axi_arlen [si*8 +: 8] = ar_s_len[si];
            assign m_axi_arsize[si*3 +: 3] = ar_s_size[si];
            assign m_axi_arburst[si*2 +: 2] = ar_s_burst[si];
            assign m_axi_arlock[si] = ar_s_lock[si];
            assign m_axi_arcache[si*4 +: 4] = ar_s_cache[si];
            assign m_axi_arprot[si*3 +: 3] = ar_s_prot[si];
            assign m_axi_arqos[si*4 +: 4] = ar_s_qos[si];
            assign m_axi_aruser [si*ARUSER_WIDTH +: ARUSER_WIDTH] = ar_s_user[si];
  
                     
            write_data_channel#(.NUM_MASTERS(NUM_MASTERS),
                    .DATA_WIDTH(DATA_WIDTH),
                    .NUM_SLAVES(NUM_SLAVES),
                    .STRB_WIDTH(STRB_WIDTH),
                    .WUSER_WIDTH(WUSER_WIDTH)
                    )
                     w_mux
                    (
                     .m_wdata(s_axi_wdata),
                     .m_wstrb(s_axi_wstrb),
                     .m_wlast(s_axi_wlast),
                     .m_wvalid(s_axi_wvalid),
                     .m_wuser(s_axi_wuser),
                     .m_wready(w_m_ready[si]),
                     .grant(grant_aw[si]),
                     .active_valid(active_valid),
                     .active_slave(active_slave),
                     .slave_index(si[SLAVE_ID_WIDTH-1:0]),
                     .mem_pop(slave_mem_pop[si]),
                     .s_wdata(w_s_wdata[si]),
                     .s_wstrb(w_s_wstrb[si]),
                     .s_wlast(w_s_wlast[si]),
                     .s_wvalid(w_s_wvalid[si]),
                     .s_wuser(w_s_wuser[si]),
                     .s_wready(m_axi_wready[si])
                    );
              assign m_axi_wdata[si*DATA_WIDTH +: DATA_WIDTH] = w_s_wdata[si];
              assign m_axi_wstrb[si*STRB_WIDTH +: STRB_WIDTH] = w_s_wstrb[si];
              assign m_axi_wlast[si] = w_s_wlast[si];              
              assign m_axi_wvalid[si] = w_s_wvalid[si];
              assign m_axi_wuser[si*WUSER_WIDTH +: WUSER_WIDTH] = w_s_wuser[si];
             

           outstanding_tracker_w#(.ID_WIDTH(ID_WIDTH),
                                  .NUM_MASTERS(NUM_MASTERS),
                                  .BUSER_WIDTH(BUSER_WIDTH),
                                  .OUTSTANDING_REQS(OUTSTANDING_REQUEST)
                                 )
                                  tracker_w 
                                 (
                                  .clk(clk),
                                  .rst(rst),
                                  .push_valid(aw_push_valid[si]),
                                  .push_id(aw_push_id[si]),
                                  .push_master(aw_push_master[si]),
                                  .s_bvalid(m_axi_bvalid[si]),
                                  .s_bid(m_axi_bid[si*ID_WIDTH +: ID_WIDTH]),
                                  .matched_valid(matched_bvalid[si]),
                                  .matched_master(matched_bmaster[si*MASTER_ID_WIDTH +: MASTER_ID_WIDTH]),
                                  .matched_ack(w_matched_ack[si]),
                                  .master_busy(tracker_master_busy_w[si]),
                                  .full(outstanding_write_full[si])
                                );

           outstanding_tracker_r#(.ID_WIDTH(ID_WIDTH),
                                  .NUM_MASTERS(NUM_MASTERS),
                                  .DATA_WIDTH(DATA_WIDTH),
                                  .RUSER_WIDTH(RUSER_WIDTH),
                                  .OUTSTANDING_REQS(OUTSTANDING_REQUEST)
                                 )
                                  tracker_r
                                 (
                                  .clk(clk),
                                  .rst(rst),
                                  .push_valid(ar_push_valid[si]),
                                  .push_id(ar_push_id[si]),
                                  .push_master(ar_push_master[si]),
                                  .s_rvalid(m_axi_rvalid[si]),
                                  .s_rid(m_axi_rid[si*ID_WIDTH +: ID_WIDTH]),
                                  .s_rlast(m_axi_rlast[si]),
                                  .matched_valid(matched_rvalid[si]),
                                  .matched_master(matched_rmaster[si*MASTER_ID_WIDTH +: MASTER_ID_WIDTH]),
                                  .matched_ack(r_matched_ack[si]),
                                  .master_busy(tracker_master_busy_r[si]),
                                  .full(outstanding_read_full[si])
                                );
        end
    endgenerate

    genvar a;
    generate
      for (a=0; a<NUM_SLAVES; a=a+1) 
        begin : PUSH_GEN
          assign aw_push_valids[a] = aw_push_valid[a];
          assign aw_push_slave_ids[a*SLAVE_ID_WIDTH +: SLAVE_ID_WIDTH] = aw_push_slave_id[a];
          assign aw_push_masters[a*MASTER_ID_WIDTH +: MASTER_ID_WIDTH] = aw_push_master[a];
        end
    endgenerate

    genvar mi;
    generate
      for(mi=0; mi<NUM_MASTERS; mi=mi+1)
        begin : SLV_MEM
          // Slave memory to store slave id of write tansfer
          slave_mem #(OUTSTANDING_REQUEST,
                      NUM_SLAVES,
                      NUM_MASTERS,
                      SLAVE_ID_WIDTH
                     )
                      write_slv_mem
                     (
                      .clk(clk),
                      .rst(rst),
                      .push_valids(aw_push_valids),
                      .push_slave_ids(aw_push_slave_ids),
                      .push_masters(aw_push_masters),
                      .master_id(mi[MASTER_ID_WIDTH-1:0]),
                      .pop(mem_pop[mi]),
                      .wready(w_s_ready[mi]),
                      .active_slave(active_slave[((mi+1)*SLAVE_ID_WIDTH)-1:(mi*SLAVE_ID_WIDTH)]),
                      .empty(fifo_empty[mi]),
                      .axi_wready(s_axi_wready[mi])
                     );

          assign active_valid[mi] = ~fifo_empty[mi];

    b_router #(NUM_MASTERS,
               NUM_SLAVES,
               ID_WIDTH,
               BUSER_WIDTH
              )
               write_resp
              (
               .clk(clk),
               .rst(rst),
               .m_axi_bvalid(s_axi_bvalid[mi]),
               .m_bid(s_axi_bid[mi*ID_WIDTH +: ID_WIDTH]),
               .m_bresp(s_axi_bresp[mi*2 +: 2]),
               .m_buser(s_axi_buser[mi*BUSER_WIDTH +: BUSER_WIDTH]),
               .m_bready(s_axi_bready[mi]),
               .master_id(mi[MASTER_ID_WIDTH-1:0]),
               .matched_valid(matched_bvalid),
               .m_bvalid(m_axi_bvalid),
               .matched_master(matched_bmaster),
               .matched_id(m_axi_bid),
               .matched_resp(m_axi_bresp),
               .matched_user(m_axi_buser),
               .matched_ack(write_matched_ack[mi]),
               .matched_ready(matched_bready[mi])
              ); 


     r_router #(NUM_MASTERS,
                NUM_SLAVES,
                ID_WIDTH,
                DATA_WIDTH,
                RUSER_WIDTH
               )
                read_resp
               (
                .clk(clk),
                .rst(rst),
                .m_axi_rvalid(s_axi_rvalid[mi]),
                .m_rid(s_axi_rid[mi*ID_WIDTH +: ID_WIDTH]),
                .m_rdata(s_axi_rdata[mi*DATA_WIDTH +: DATA_WIDTH]),
                .m_rresp(s_axi_rresp[mi*2 +: 2]),
                .m_rlast(s_axi_rlast[mi]),
                .m_ruser(s_axi_ruser[mi*RUSER_WIDTH +: RUSER_WIDTH]),
                .m_rready(s_axi_rready[mi]),
                .master_id(mi[MASTER_ID_WIDTH-1:0]),
                .matched_valid(matched_rvalid),
                .m_rvalid(m_axi_rvalid),
                .matched_master(matched_rmaster),
                .matched_id(m_axi_rid),
                .matched_resp(m_axi_rresp),
                .matched_data(m_axi_rdata),
                .matched_last(m_axi_rlast),
                .matched_user(m_axi_ruser),
                .matched_ack(read_matched_ack[mi]),
                .matched_ready(matched_rready[mi])
               );

        end
    endgenerate

   endmodule
