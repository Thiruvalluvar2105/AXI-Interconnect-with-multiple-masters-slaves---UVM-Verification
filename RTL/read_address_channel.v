
   module read_address_channel #(
                            parameter NUM_MASTERS = 2,
                            parameter NUM_SLAVES = 3,
                            parameter ADDR_WIDTH = 32,
                            parameter ID_WIDTH = 8,
                            parameter USER_WIDTH = 1
                           )
                           (
                            input [(NUM_MASTERS*ADDR_WIDTH)-1:0] m_addr,
                            input [(NUM_MASTERS*ID_WIDTH)-1:0] m_id,
                            input [(NUM_MASTERS*8)-1:0] m_len,
                            input [(NUM_MASTERS*3)-1:0] m_size,
                            input [NUM_MASTERS*2-1:0] m_burst,
                            input [NUM_MASTERS-1:0] m_lock,
                            input [NUM_MASTERS*4-1:0] m_cache,
                            input [NUM_MASTERS*3-1:0] m_prot,
                            input [NUM_MASTERS*4-1:0] m_qos,
                            input [NUM_MASTERS*USER_WIDTH-1:0] m_user,
                            input [NUM_MASTERS-1:0] m_valid,
                            input s_ready,
                            input [NUM_MASTERS-1:0]master_grant,
                            input full,

                            output reg [ADDR_WIDTH-1:0] s_addr,
                            output reg [ID_WIDTH-1:0] s_id,
                            output reg [7:0] s_len,
                            output reg [2:0] s_size,
                            output reg [1:0] s_burst,
                            output reg s_lock,
                            output reg [3:0] s_cache,
                            output reg [2:0] s_prot,
                            output reg [3:0] s_qos,
                            output reg [USER_WIDTH-1:0] s_user,
                            output reg [NUM_MASTERS-1:0] m_ready,
                            output reg s_valid,
                            output reg push_valid,
                            output reg [ID_WIDTH-1:0] push_id,
                            output reg [$clog2(NUM_MASTERS)-1:0] push_master
                           );

     integer i;

     reg [0:0] valid_mem [NUM_MASTERS-1:0];
     reg [ID_WIDTH-1:0] id_mem [NUM_MASTERS-1:0];
     reg [ADDR_WIDTH-1:0] addr_mem [NUM_MASTERS-1:0];
     reg [7:0] len_mem [NUM_MASTERS-1:0];
     reg [2:0] size_mem [NUM_MASTERS-1:0];
     reg [1:0] burst_mem [NUM_MASTERS-1:0];
     reg [0:0] lock_mem [NUM_MASTERS-1:0];
     reg [3:0] cache_mem [NUM_MASTERS-1:0];
     reg [2:0] prot_mem [NUM_MASTERS-1:0];
     reg [3:0] qos_mem [NUM_MASTERS-1:0];
     reg [USER_WIDTH-1:0] user_mem [NUM_MASTERS-1:0];
     reg found_one;
     reg granted_master_idx;

     // -------------------------------------------------
     // Generate block: slice inputs into per-master arrays
     // -------------------------------------------------
     genvar j;
     generate
       for (j = 0; j < NUM_MASTERS; j = j + 1) 
         begin : SLICE_EXTRACT
           always @(*) 
             begin
               valid_mem[j] = m_valid[j];
               id_mem[j]    = m_id   [(j*ID_WIDTH) +: ID_WIDTH];
               addr_mem[j]  = m_addr [(j*ADDR_WIDTH) +: ADDR_WIDTH];
               len_mem[j]   = m_len  [(j*8) +: 8];
               size_mem[j]  = m_size [(j*3) +: 3];
               burst_mem[j] = m_burst[(j*2) +: 2];
               lock_mem[j]  = m_lock [j];
               cache_mem[j] = m_cache[(j*4) +: 4];
               prot_mem[j]  = m_prot [(j*3) +: 3];
               qos_mem[j]   = m_qos  [(j*4) +: 4];
               user_mem[j]  = m_user [(j*USER_WIDTH) +: USER_WIDTH];
             end
         end
     endgenerate

     always @(*)
       begin
         // defaults
         s_valid   = 1'b0;
         s_id      = {ID_WIDTH{1'b0}};
         s_addr    = {ADDR_WIDTH{1'b0}};
         s_len     = 8'd0;
         s_size    = 3'd0;
         s_burst   = 2'd0;
         s_lock    = 1'd0;
         s_cache   = 4'd0;
         s_prot    = 3'd0;
         s_qos     = 4'd0;
         s_user    = {USER_WIDTH{1'd0}};
         push_valid  = 1'b0;
         push_id     = {ID_WIDTH{1'b0}};
         push_master = {($clog2(NUM_MASTERS)){1'd0}};

         found_one = 1'b0;
         granted_master_idx = 1'b0;

         // one-hot grant, so at most one master drives
         for (i = 0; i < NUM_MASTERS && !found_one; i = i + 1)
           begin
             if (master_grant[i] && m_valid[i] && s_ready && !full)
               begin
                 m_ready[i] = s_ready;

                 if (found_one == 1'b0)
                    begin
                      found_one = 1'b1;
                      granted_master_idx = i; // Store the *first* found index
                    end
               end
             else
               m_ready[i] = 1'b0;
            end

          if (found_one) 
            begin
              // drive slave side
              s_valid = valid_mem[granted_master_idx];
              s_id    = id_mem[granted_master_idx];
              s_addr  = addr_mem[granted_master_idx];
              s_len   = len_mem[granted_master_idx];
              s_size  = size_mem[granted_master_idx];
              s_burst = burst_mem[granted_master_idx];
              s_lock  = lock_mem[granted_master_idx];
              s_cache = cache_mem[granted_master_idx];
              s_prot  = prot_mem[granted_master_idx];
              s_qos   = qos_mem[granted_master_idx];
              s_user  = user_mem[granted_master_idx];

              // push when handshake occurs
              push_valid    = 1'b1;
              push_id       = id_mem[granted_master_idx];
              push_master   = granted_master_idx;
            end
       end
   endmodule
 
