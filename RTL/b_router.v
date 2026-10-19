

module b_router #(
    parameter NUM_MASTERS = 2,
    parameter NUM_SLAVES  = 3,
    parameter ID_WIDTH    = 8,
    parameter BUSER_WIDTH = 1
)(
    input   clk,
    input   rst,

    // Masters' B channel outputs
    output                          m_axi_bvalid,
    output reg  [ID_WIDTH-1:0]        m_bid,
    output reg  [1:0]                 m_bresp,
    output reg  [BUSER_WIDTH-1:0]     m_buser,
    input                           m_bready,
    input   [$clog2(NUM_MASTERS)-1:0] master_id,

    // Tracker inputs (one set per slave)
    input   [NUM_SLAVES-1:0]                      matched_valid,
    input   [NUM_SLAVES-1:0]                      m_bvalid,
    input   [NUM_SLAVES*$clog2(NUM_MASTERS)-1:0]  matched_master,
    input   [NUM_SLAVES*ID_WIDTH-1:0]           matched_id,
    input   [NUM_SLAVES*2-1:0]                  matched_resp,
    input   [NUM_SLAVES*BUSER_WIDTH-1:0]        matched_user,
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


    assign m_axi_bvalid = (matched_ready[sel_slave]) ? m_bvalid[sel_slave] : 1'b0;

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
    // FIX: All logic for 'sel_valid' and 'sel_slave' is now combinatorial.
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
            // Deselect when the handshake is done (BVALID and BREADY are high)
            if (m_bvalid[sel_slave] && m_bready) begin
                sel_valid_next = 1'b0;
                sel_slave_next = 'd0;
            end
        end 
        else begin
            // --- We are not valid ---
            // --- FIX: Loop *only* to find index ---
            // Search for a new slave to select (priority encoder)
            for (s = 0; s < NUM_SLAVES && !found; s = s + 1) 
            begin
                // Original logic included m_bready in select, so we keep it
                if (matched_valid[s] && master_id == matched_master[MASTER_ID_WIDTH*s +: MASTER_ID_WIDTH] && m_bready && !found) 
                begin
                    found_slave_idx = s; // Store index
                    found = 1'b1;        // Set flag
                end
            end
            
            // --- FIX: Assign *after* loop ---
            if (found)
            begin
                sel_valid_next = 1'b1;
                sel_slave_next = found_slave_idx;
            end
        end
    end

    // ---------- COMBINATORIAL BLOCK (Output Logic) ----------
    always @(*) 
      begin
        m_bid   = 0;
        m_bresp = 0;
        m_buser = 0;

        matched_ack = 1'b0;
        matched_ready = 0;
        
        // drive outputs for the active master
        if (m_bready && sel_valid) 
          begin
            m_bid   = matched_id[sel_slave*ID_WIDTH +: ID_WIDTH];
            m_bresp = matched_resp[sel_slave*2 +: 2];
            m_buser = matched_user[sel_slave*BUSER_WIDTH +: BUSER_WIDTH];

            matched_ack[sel_slave] = 1'b1;
            matched_ready[sel_slave] = m_bready;
          end
      end

endmodule

