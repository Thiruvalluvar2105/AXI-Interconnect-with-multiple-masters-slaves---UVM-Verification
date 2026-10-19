


   module write_data_channel #(parameter NUM_MASTERS = 2,
                  parameter DATA_WIDTH  = 32,
                  parameter NUM_SLAVES  = 3,
                  parameter STRB_WIDTH  = (DATA_WIDTH/8),
                  parameter WUSER_WIDTH = 1
                 )
                 (
                  input       [NUM_MASTERS*DATA_WIDTH-1:0]   m_wdata,
                  input       [NUM_MASTERS*STRB_WIDTH-1:0]   m_wstrb,
                  input       [NUM_MASTERS-1:0]              m_wlast,
                  input       [NUM_MASTERS-1:0]              m_wvalid,
                  input       [(NUM_MASTERS*WUSER_WIDTH)-1:0]m_wuser,
                  output reg  [NUM_MASTERS-1:0]              m_wready,

                  input       [NUM_MASTERS-1:0]              grant,
                  input       [NUM_MASTERS-1:0]              active_valid,
                  input       [(NUM_MASTERS*$clog2(NUM_SLAVES))-1:0] active_slave,
                  input       [$clog2(NUM_SLAVES)-1:0]       slave_index,
                  output reg  [NUM_MASTERS-1:0]              mem_pop,

                  output reg  [DATA_WIDTH-1:0]    s_wdata,
                  output reg  [STRB_WIDTH-1:0]    s_wstrb,
                  output reg                      s_wlast,
                  output reg                      s_wvalid,
                  output reg  [WUSER_WIDTH-1:0]   s_wuser,
                  input                           s_wready
                 );
 
     integer i;
     reg     found_one;
     integer granted_master_idx;
 
     reg [$clog2(NUM_SLAVES)-1:0] slave_mem [NUM_MASTERS-1:0];
     reg [DATA_WIDTH-1:0] wdata_mem [NUM_MASTERS-1:0];
     reg [STRB_WIDTH-1:0] wstrb_mem [NUM_MASTERS-1:0];
     reg [0:0] wlast_mem [NUM_MASTERS-1:0];
     reg [0:0] wvalid_mem [NUM_MASTERS-1:0];
     reg [WUSER_WIDTH-1:0] wuser_mem [NUM_MASTERS-1:0];

     localparam SLAVE_ID = $clog2(NUM_SLAVES);
     // -------------------------------------------------
     // Generate block: slice inputs into per-master arrays
     // -------------------------------------------------
     genvar j;
     generate
       for (j = 0; j < NUM_MASTERS; j = j + 1) 
         begin : SLICE_EXTRACT
           always @(*)
             begin
               slave_mem[j]  = active_slave[j*SLAVE_ID +: SLAVE_ID];
               wvalid_mem[j] = m_wvalid[j];
               wdata_mem[j]  = m_wdata[(j*DATA_WIDTH) +: DATA_WIDTH];
               wstrb_mem[j]  = m_wstrb[(j*STRB_WIDTH) +: STRB_WIDTH];
               wlast_mem[j]  = m_wlast[j];
               wuser_mem[j]  = m_wuser[(j*WUSER_WIDTH) +: WUSER_WIDTH];
             end
         end
     endgenerate

    always @(*) 
      begin
        // Defaults for SHARED signals (stay here)
        s_wdata  = {DATA_WIDTH{1'b0}};
        s_wstrb  = {STRB_WIDTH{1'b0}};
        s_wlast  = 1'b0;
        s_wvalid = 1'b0;
        s_wuser  = {WUSER_WIDTH{1'b0}}; 

        // 1. Initialize helper variables
        found_one          = 1'b0;
        granted_master_idx = 0;

        // 2. Loop to find index and set INDEXED signals
        for (i=0;i<NUM_MASTERS && !found_one;i=i+1) 
          begin
            if(grant[i] && active_valid[i] && (slave_mem[i] == slave_index)) 
              begin
                // --- This is the 'if' branch ---
                // Drive the INDEXED signals
                m_wready[i] = s_wready;
                
                if(m_wvalid[i] && s_wready && m_wlast[i])
                    mem_pop[i] = 1'b1;
                else
                    mem_pop[i] = 1'b0;

                // --- Find-first logic ---
                if (found_one == 1'b0)
                  begin
                    found_one = 1'b1;
                    granted_master_idx = i; // Store index
                  end
              end

            else 
              begin
                // --- This is the 'else' branch ---
                // Drive the INDEXED signals
                m_wready[i] = 1'b0; 
              end
          end
        
        // 3. Assign SHARED signals *after* the loop
        if (found_one)
          begin
            s_wdata  = wdata_mem[granted_master_idx];
            s_wstrb  = wstrb_mem[granted_master_idx];
            s_wuser  = wuser_mem[granted_master_idx];
            s_wlast  = wlast_mem[granted_master_idx];
            s_wvalid = wvalid_mem[granted_master_idx];
          end
      end
   endmodule
