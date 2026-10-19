


  module outstanding_tracker_r #(parameter ID_WIDTH = 8,
                                 parameter NUM_MASTERS = 2,
                                 parameter DATA_WIDTH = 32,
                                 parameter RUSER_WIDTH = 1,
                                 parameter OUTSTANDING_REQS = 4
                                )
                                (
                                 input                           clk,
                                 input                           rst,

                                 // push when AR accepted
                                 input                           push_valid,
                                 input   [ID_WIDTH-1:0]          push_id,
                                 input   [$clog2(NUM_MASTERS)-1:0] push_master,

                                 // slave R inputs
                                 input                           s_rvalid,
                                 input   [ID_WIDTH-1:0]          s_rid,
                                 input                           s_rlast,

                                 // matched output to router
                                 output reg                          matched_valid,
                                 output reg  [$clog2(NUM_MASTERS)-1:0] matched_master,

                                 // ack when master accepted R beat
                                 input       [NUM_MASTERS-1:0]                    matched_ack,

                                 // status
                                 output reg  [NUM_MASTERS-1:0]       master_busy,
                                 output                              full
                                );

     integer i;
     integer temp_free_idx;
     integer temp_match_idx;

     // outstanding tables
     reg [ID_WIDTH-1:0]   tbl_id [OUTSTANDING_REQS-1:0];
     reg [$clog2(NUM_MASTERS)-1:0] tbl_master [OUTSTANDING_REQS-1:0];
     reg                  tbl_valid [OUTSTANDING_REQS-1:0];

     reg matched_pending,allocated;
     reg [$clog2(OUTSTANDING_REQS)-1:0] matched_idx;
     reg [$clog2(OUTSTANDING_REQS+1)-1:0] outstanding_count;
     wire [$clog2(OUTSTANDING_REQS+1)-1:0] outstanding_pending;
     //wire full;
     reg pushed,matched;
     reg [$clog2(NUM_MASTERS)-1:0] master;
     localparam OUTSTANDING_COUNT = ($clog2(OUTSTANDING_REQS)+1);
 
     assign full = (outstanding_count == OUTSTANDING_REQS);

    always@(*)
      begin
        if(push_valid)
          master_busy[push_master] = 1'b1;
        else if(outstanding_count == 3'b0 && s_rlast)
          master_busy[master] = 1'b0;
      end
 
     assign outstanding_pending = outstanding_count;

    always @(posedge clk) 
      begin
        if (rst) 
          begin
            outstanding_count <= 0;
            matched_valid <= 1'b0;
            matched_master <= 'b0;
            matched_pending <= 1'b0;
            for (i = 0; i < OUTSTANDING_REQS; i = i + 1) 
              begin
                tbl_valid[i] <= 1'b0;
                tbl_id[i] <= 'd0;
                tbl_master[i] <= 'b0;
              end
          end 

        else 
          begin 
            // --- Initialize helper variables ---
            temp_free_idx  = 0;
            temp_match_idx = 0;

            // CASE 1: PUSH is happening (highest priority for count logic)
            if (push_valid && !full) 
              begin
                // --- Push logic ---
                // 1. Find the free slot *first*
                pushed = 1'b0;
                for (i = 0; i < OUTSTANDING_REQS && !pushed; i = i + 1) 
                  begin
                    if (!tbl_valid[i] && !pushed) 
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
                    master                    <= push_master;
                  end

                if (|matched_ack && s_rlast) begin
                    // --- CASE 1a: BOTH PUSH and ACK ---
                    outstanding_count <= outstanding_count; 
                    
                    // Ack logic (freeing entry)
                    tbl_valid[matched_idx] <= 1'b0;
                    tbl_id[matched_idx] <= 'd0;
                    tbl_master[matched_idx] <= 'b0;
                    matched_master          <= 'b0;
                    matched_pending <= 1'b0;
                    matched_valid <= 1'b0;
                  end
                else begin
                    // --- CASE 1b: PUSH ONLY ---
                    // --- FIX: Only increment if push was successful ---
                    if (pushed) begin
                        outstanding_count <= outstanding_count + 1; 
                      end
                  end
              end
            
            // CASE 2: NO PUSH, but ACK is happening
            else if (|matched_ack && s_rlast) 
              begin
                // Ack logic (freeing entry)
                tbl_valid[matched_idx] <= 1'b0;
                tbl_id[matched_idx] <= 'd0;
                tbl_master[matched_idx] <= 'b0;
                matched_master          <= 'b0;
                matched_pending <= 1'b0;
                matched_valid <= 1'b0;
                
                // Decrement count
                if (outstanding_pending > 0)
                    outstanding_count <= outstanding_count - 1;
              end
            
            // CASE 3: NO PUSH, NO ACK, but SEARCH is happening
            else if (!matched_pending && s_rvalid) 
              begin
                // --- FIX: Search logic ---
                // 1. Find the matching slot *first*
                matched = 1'b0;
                for (i = 0; i < OUTSTANDING_REQS && !matched; i = i + 1) 
                  begin
                    if (!matched_pending && tbl_valid[i] && tbl_id[i] == s_rid && !matched) 
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
                // --- END FIX ---
              end 
          end
      end
   endmodule
