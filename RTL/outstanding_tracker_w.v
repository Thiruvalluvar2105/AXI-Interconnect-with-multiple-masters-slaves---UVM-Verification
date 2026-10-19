


   module outstanding_tracker_w #(parameter ID_WIDTH = 8,
                                  parameter NUM_MASTERS = 2,
                                  parameter BUSER_WIDTH = 1,
                                  parameter OUTSTANDING_REQS = 4
                                 )
                                 (
                                  input                           clk,
                                  input                           rst,
                                  input                           push_valid,
                                  input   [ID_WIDTH-1:0]          push_id,
                                  input   [$clog2(NUM_MASTERS)-1:0] push_master,

                                  // slave B inputs
                                  input                           s_bvalid,
                                  input   [ID_WIDTH-1:0]          s_bid,


                                  // matched output to router
                                  output reg                          matched_valid,
                                  output reg  [$clog2(NUM_MASTERS)-1:0] matched_master,
  
                                  // ack when master accepted B -> free entry
                                  input    [NUM_MASTERS-1:0]                       matched_ack,

                                  // status
                                  output reg  [NUM_MASTERS-1:0]       master_busy,
                                  output                              full
                                 );

    integer i;
    integer temp_free_idx;
    integer temp_match_idx;
    reg [ID_WIDTH-1:0]                 tbl_id [OUTSTANDING_REQS-1:0];
    reg [$clog2(NUM_MASTERS)-1:0]      tbl_master [OUTSTANDING_REQS-1:0];
    reg                                tbl_valid [OUTSTANDING_REQS-1:0];

    reg                                matched_pending;
    reg [$clog2(OUTSTANDING_REQS):0] matched_idx;
    reg [$clog2(OUTSTANDING_REQS):0] outstanding_count;
    wire [$clog2(OUTSTANDING_REQS):0] outstanding_pending;
    //wire full;
    reg pushed,matched;
    reg [$clog2(NUM_MASTERS)-1:0]master;
    localparam OUTSTANDING_COUNT = ($clog2(OUTSTANDING_REQS)+1);

    assign full = (outstanding_count == OUTSTANDING_REQS);

    assign outstanding_pending = outstanding_count;

  
    always @(posedge clk) 
      begin
        if (rst) 
          begin
            outstanding_count <= 0;
            matched_valid     <= 1'b0;
            matched_master    <= 'b0;
            matched_pending   <= 1'b0;
            for (i=0;i<OUTSTANDING_REQS;i=i+1) 
              begin
                tbl_valid[i]  <= 1'b0;
                tbl_id[i]     <= 'd0;
                tbl_master[i] <= 'b0;
              end
          end

        else 
          begin
        
            // --- Initialize helper variables ---
            temp_free_idx  = 0;
            temp_match_idx = 0;

            // CASE 1: PUSH is happening (highest priority for count logic)
            if(push_valid && !full) 
              begin
                // --- Push logic ---
                // 1. Find the free slot *first*
                pushed = 1'b0;
                for (i=0;i<OUTSTANDING_REQS && !pushed;i=i+1) 
                  begin
                    if(!tbl_valid[i] && !pushed) 
                      begin
                        temp_free_idx = i; // Store the index
                        pushed = 1'b1;     // Set the "found" flag
                      end
                  end
                
                // 2. Assign to state registers *after* the loop
                if (pushed) // Only assign if we found a slot
                  begin
                    tbl_valid[temp_free_idx]  <= 1'b1;
                    tbl_id[temp_free_idx]     <= push_id;
                    tbl_master[temp_free_idx] <= push_master;
                    master <= push_master; 
                  end
                
                if (|matched_ack) 
                  begin
                    // --- CASE 1a: BOTH PUSH and ACK ---
                    outstanding_count <= outstanding_count; 

                    // Ack logic (freeing entry)
                    tbl_valid[matched_idx]  <= 1'b0;
                    tbl_id[matched_idx]     <= 'd0;
                    tbl_master[matched_idx] <= 'b0;
                    matched_master          <= 'b0;
                    matched_pending <= 1'b0;
                    matched_valid <= 1'b0;
                  end

                else 
                  begin
                    // --- CASE 1b: PUSH ONLY ---
                    // Only increment count if the push was successful
                    if (pushed) 
                      begin
                        outstanding_count <= outstanding_count + 1;
                      end
                  end
              end
            
            // CASE 2: NO PUSH, but ACK is happening
            else if (|matched_ack) 
              begin
                // Ack logic (freeing entry)
                tbl_valid[matched_idx]  <= 1'b0;
                tbl_id[matched_idx]     <= 'd0;
                tbl_master[matched_idx] <= 'b0;
                matched_master          <= 'b0;
                matched_pending <= 1'b0;
                matched_valid <= 1'b0;
                
                // Decrement count
                if (outstanding_pending > 0)
                    outstanding_count <= outstanding_count - 1;
              end
            
            // CASE 3: NO PUSH, NO ACK, but SEARCH is happening
            else if(!matched_pending && s_bvalid) 
              begin
                // --- Search logic ---
                // 1. Find the matching slot *first*
                matched = 1'b0;
                for (i=0;i<OUTSTANDING_REQS && !matched;i=i+1) 
                  begin
                    // Check 'tbl_valid' first and only if 'matched' is not set
                    if (tbl_valid[i] && (tbl_id[i] == s_bid) && !matched) 
                      begin
                        temp_match_idx = i; // Store the index
                        matched = 1'b1;     // Set the "found" flag
                      end
                  end
                
                // 2. Assign to state registers *after* the loop
                if (matched) // If we found a match
                  begin
                    matched_pending <= 1'b1;
                    matched_idx     <= temp_match_idx;
                    matched_master  <= tbl_master[temp_match_idx];
                    matched_valid   <= 1'b1;
                  end
              end

            // --- Independent Logic (runs every cycle) ---
            // master_busy logic
            if (push_valid && !full) 
              begin
                master_busy[push_master] <= 1'b1;
              end
            // This 'else if' will only trigger when count *hits* zero,
            // but the master that *caused* it to be zero is 'master'.
            // This logic seems correct.
            else if (outstanding_count == 0) 
              begin
                master_busy[master] <= 1'b0;
              end
          end
      end
   endmodule
