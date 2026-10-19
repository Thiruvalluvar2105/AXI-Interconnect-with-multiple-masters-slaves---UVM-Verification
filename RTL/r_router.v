


module r_router #(parameter NUM_MASTERS = 2,
                       parameter NUM_SLAVES  = 3,
                       parameter ID_WIDTH    = 8,
                       parameter DATA_WIDTH  = 32,
                       parameter RUSER_WIDTH = 1
                      )
                      (
                       input                           clk,
                       input                           rst,

                       // Master R outputs (flattened)
                       output                          m_axi_rvalid,
                       output reg  [ID_WIDTH-1:0]        m_rid,
                       output reg  [DATA_WIDTH-1:0]      m_rdata,
                       output reg  [1:0]                 m_rresp,
                       output reg                        m_rlast,
                       output reg  [RUSER_WIDTH-1:0]     m_ruser,
                       input                           m_rready,
                       input   [$clog2(NUM_MASTERS)-1:0] master_id,

                       // Matched info from tracker
                       input   [NUM_SLAVES-1:0]                      matched_valid,
                       input   [NUM_SLAVES-1:0]                      m_rvalid,
                       input   [(NUM_SLAVES*$clog2(NUM_MASTERS))-1:0]  matched_master,
                       input   [(NUM_SLAVES*ID_WIDTH)-1:0]           matched_id,
                       input   [(NUM_SLAVES*2)-1:0]                  matched_resp,
                       input   [(NUM_SLAVES*DATA_WIDTH)-1:0]         matched_data,
                       input   [NUM_SLAVES-1:0]                      matched_last,
                       input   [(NUM_SLAVES*RUSER_WIDTH)-1:0]        matched_user,

                       // Ack to tracker when beat accepted
                       output reg  [NUM_SLAVES-1:0]                  matched_ack,
                       output reg  [NUM_SLAVES-1:0]                  matched_ready
                      );

    localparam SLAVE_ID_WIDTH = $clog2(NUM_SLAVES);
    localparam MASTER_ID_WIDTH = $clog2(NUM_MASTERS);

    // ---------- STATE REGISTERS ----------
    reg [$clog2(NUM_SLAVES)-1:0] sel_slave;
    reg                          sel_valid;
    
    // ---------- NEXT-STATE LOGIC SIGNALS ----------
    reg [$clog2(NUM_SLAVES)-1:0] sel_slave_next;
    reg                          sel_valid_next;
    // Loop variable
    integer s;
    integer found_slave_idx;
    // Guard flag for find-first logic
    reg found;

    assign m_axi_rvalid = (matched_ready[sel_slave]) ? m_rvalid[sel_slave] : 1'b0;

    // ---------- SEQUENTIAL BLOCK (State Holding) ----------
    // This block ONLY registers the next state.
    always @(posedge clk) 
      begin
        if(rst)
          begin
            sel_valid <= 1'b0;
            sel_slave <= 'd0;
          end
        else
          begin
            sel_valid <= sel_valid_next;
            sel_slave <= sel_slave_next;
          end
      end

// ---------- COMBINATORIAL BLOCK (Next-State Logic) ----------
    // All logic for 'sel_valid' and 'sel_slave' is now combinatorial.
    always@(*)
    begin

        // Default: hold current state
        sel_valid_next = sel_valid;
        sel_slave_next = sel_slave;

        // --- FIX: Initialize loop vars ---
        found = 1'b0;
        found_slave_idx = 0; // Default index

        if (sel_valid) begin
            // --- We are currently valid ---
            // Check for deselect condition (last beat is accepted)
            if (matched_last[sel_slave] && m_rready) begin
                sel_valid_next = 1'b0;
                sel_slave_next = 'd0;
            end
        end 
        else begin
            // --- We are not valid ---
            // --- FIX: Loop *only* to find index ---
            // Search for a new slave to select
            for (s = 0; s < NUM_SLAVES && !found; s = s + 1) 
            begin
                if(matched_valid[s] && master_id == matched_master[MASTER_ID_WIDTH*s +: MASTER_ID_WIDTH] && m_rready && !found) 
                begin
                    found_slave_idx = s; // Store index
                    found = 1'b1;        // Set flag
                end
            end
            
            // --- Assign *after* loop ---
            if (found)
            begin
                sel_valid_next = 1'b1;
                sel_slave_next = found_slave_idx;
            end
        end
    end

    // ---------- COMBINATORIAL BLOCK (Output Logic) ----------
    // This logic was already correct.
    always@(*)
      begin
        // drive this beat to active master
        matched_ready = 0;
        m_rid         = 0;
        m_rdata       = 0;
        m_rresp       = 0;
        m_rlast       = 0;
        m_ruser       = 0;
        matched_ack   = 1'b0;

        if (m_rready && sel_valid) 
          begin
            // drive this beat to active master
            matched_ready[sel_slave] = m_rready;
            m_rid                    = matched_id[sel_slave*ID_WIDTH +: ID_WIDTH];//active_id;
            m_rdata                  = matched_data[sel_slave*DATA_WIDTH +: DATA_WIDTH];//active_data;
            m_rresp                  = matched_resp[sel_slave*2 +: 2];
            m_rlast                  = matched_last[sel_slave];//active_last;
            m_ruser                  = matched_user[sel_slave*RUSER_WIDTH +: RUSER_WIDTH];

            // if master accepts
            matched_ack[sel_slave] = 1'b1;
          end
      end
endmodule

