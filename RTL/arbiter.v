

  module arbiter #(parameter NUM_MASTERS = 2)
                 (
                 input clk,
                 input rst,
                 input [NUM_MASTERS-1:0]   request,      // request vector from masters
                 input [NUM_MASTERS-1:0]   master_busy,  // per-master busy flags
                 input [NUM_MASTERS-1:0]   rready,
                 output wire               axi_ready,   // Changed to 'output wire'
                 output reg [NUM_MASTERS-1:0] grant         // one-hot grant
                 );

    // State registers
    reg [$clog2(NUM_MASTERS):0] last_ptr;
    reg granted;

    // Next-state logic registers
    reg [NUM_MASTERS-1:0] grant_next;
    reg [$clog2(NUM_MASTERS):0] last_ptr_next;
    reg granted_next;

    // Local variables for combinational logic
    integer i;
    integer gidx;
    integer idx;
    reg found;
    reg grant_processed; // Add guard flag for the 'grant' loop

    integer granted_gidx;
    integer granted_idx;


    // Correct axi_rready logic
    //assign axi_rready = grant ? rready[grant-1] : 1'b0;
    assign axi_ready = |(rready & grant);

    // COMBINATIONAL LOGIC: Calculate next state
    always@(*)
      begin
    
        // Initialize loop helper variables
        //found           = 1'b0;
        grant_processed = 1'b0;
        granted_gidx    = 0; // Default index
        granted_idx     = 0; // Default index

        if(granted)
        begin
            // --- DEFAULTS for 'granted' branch ---
            // Hold the current state by default
            grant_next      = grant;
            granted_next    = 1'b1;
            last_ptr_next   = last_ptr;

            // LOOP 1: Find the *one* active grant
            // This loop *only* finds the index
            for(gidx = 0; gidx < NUM_MASTERS && !grant_processed; gidx = gidx + 1)
            begin

                if(grant[gidx] && !grant_processed)
                begin
                    grant_processed = 1'b1; // Set the found flag
                    granted_gidx    = gidx; // Store the index
                end
            end

            // ASSIGNMENTS: Outside the loop
            if (grant_processed) // If we found the active grant
              begin
                if(!master_busy[granted_gidx])
                  begin
                    // Master is done, release the grant
                    grant_next   = {NUM_MASTERS{1'b0}};
                    granted_next = 1'b0;
                  end
              end
          end

        else // not granted
          begin
            // --- DEFAULTS for 'not granted' branch ---
            // Default to no grant
            grant_next    = {NUM_MASTERS{1'b0}};
            granted_next  = 1'b0;
            last_ptr_next = last_ptr;
            found = 1'b0;

            // LOOP 2: Find the *first* new request
            // This loop *only* finds the index
            for(i = 0 ; i < NUM_MASTERS && !found; i = i + 1)
            begin

                idx = last_ptr + i;
                if (idx >= NUM_MASTERS)
                    idx = idx - NUM_MASTERS;

                if(request[idx] && !found)
                begin
                    found       = 1'b1; // Set the found flag
                    granted_idx = idx;  // Store the index
                end
            end

            // ASSIGNMENTS: Outside the loop
            if (found) // If we found a valid request
            begin
                // Assign the *entire* vector at once to avoid
                // the "whole vs. part" assignment warning.
                grant_next    = (1'b1 << granted_idx); 
                last_ptr_next = (granted_idx + 1'b1) % NUM_MASTERS;
                granted_next  = 1'b1;
            end
            // If !found, the defaults (all-zeros) are kept.
        end
      end

    // SEQUENTIAL LOGIC: Update state on clock edge
    always@(posedge clk)
      begin
        if(rst)
          begin
            grant    <= {NUM_MASTERS{1'b0}};
            last_ptr <= 0;
            granted  <= 1'b0;
          end
        else
          begin
            grant    <= grant_next;
            last_ptr <= last_ptr_next;
            granted  <= granted_next;
          end
      end

endmodule
