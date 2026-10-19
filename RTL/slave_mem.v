

module slave_mem #(
    parameter DEPTH       = 4,   // OUT_PER_MASTER
    parameter NUM_SLAVES  = 3,
    parameter NUM_MASTERS = 2,
    parameter WIDTH       = 2    // log2(NUM_SLAVES)
)(
    input                       clk,
    input                       rst,

    // Flattened push inputs from all write_address_channels
    input  [NUM_SLAVES-1:0]                     push_valids,    // per slave
    input  [NUM_SLAVES*WIDTH-1:0]               push_slave_ids, // per slave
    input  [NUM_SLAVES*$clog2(NUM_MASTERS)-1:0] push_masters,   // per slave

    // Identity of this FIFO’s master
    input  [$clog2(NUM_MASTERS)-1:0] master_id,

    // Pop control from w_mux
    input  [NUM_SLAVES-1:0] pop,
    input  [NUM_SLAVES-1:0] wready,

    // FIFO outputs
    output [WIDTH-1:0]      active_slave, // Changed from reg to wire (implicit)
    output                  empty,
    output                  axi_wready
);

    // --------------------------------------------------------
    // Internal Signals & Parameters
    // --------------------------------------------------------
    localparam POINTER_WIDTH = $clog2(DEPTH);
    localparam COUNT_WIDTH   = $clog2(DEPTH) + 1; // Needs to hold value 'DEPTH'
    localparam MASTER_ID_WIDTH = $clog2(NUM_MASTERS);

    reg [WIDTH-1:0] mem [DEPTH-1:0];
    
    // Pointers and Counters
    reg [POINTER_WIDTH-1:0] wr_ptr, rd_ptr;
    reg [COUNT_WIDTH-1:0]   count;
    reg [COUNT_WIDTH-1:0]   next_count; // Combinational count variable

    wire full;
    
    // Push Logic Helpers
    reg             found_one;
    integer         found_slave_idx;
    reg             push_detected;
    reg [WIDTH-1:0] push_data_sel;

    // Operation Enables
    wire push_en;
    wire pop_en;
    
    integer s;

    // --------------------------------------------------------
    // 1. Status Flags
    // --------------------------------------------------------
    assign empty        = (count == 0);
    assign full         = (count == DEPTH);
    
    // Output Logic: Read directly from memory (Zero Latency Read)
    assign active_slave = mem[rd_ptr];
    
    // Ready Logic: Pass through the ready signal of the active slave
    assign axi_wready   = wready[active_slave];

    // --------------------------------------------------------
    // 2. Input Arbitration (Priority Encoder)
    // --------------------------------------------------------
    always @(*) begin
        // Initialize
        found_one       = 1'b0;
        found_slave_idx = 0;
        push_detected   = 1'b0;
        push_data_sel   = {WIDTH{1'b0}};

        // Loop from highest to lowest to preserve priority
        for (s = 0; s < NUM_SLAVES && !found_one; s = s + 1) begin
            if (push_valids[s] && 
               (push_masters[s*MASTER_ID_WIDTH +: MASTER_ID_WIDTH] == master_id) && 
               !found_one) 
            begin
                found_one       = 1'b1; 
                found_slave_idx = s;   
            end
        end
        
        if (found_one) begin
            push_detected = 1'b1;
            push_data_sel = push_slave_ids[found_slave_idx*WIDTH +: WIDTH];
        end
    end

    // --------------------------------------------------------
    // 3. Combinational Count Logic
    // --------------------------------------------------------
    // Define write and read enables based on state
    assign push_en = push_detected && !full;
    assign pop_en  = pop[active_slave] && !empty;

    always @(*) begin
        // Default: Hold current count
        next_count = count;

        case ({push_en, pop_en})
            2'b10 : next_count = count + 1; // Push only
            2'b01 : next_count = count - 1; // Pop only
            2'b11 : next_count = count;     // Both (Push cancels Pop)
            default : next_count = count;
        endcase
    end

    // --------------------------------------------------------
    // 4. Sequential FIFO Update
    // --------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
        end 
        else begin
            // Update Count with the combinational calculation
            count <= next_count;

            // --- Push Operation ---
            if (push_en) begin
                mem[wr_ptr] <= push_data_sel;
                // Handle pointer wrapping
                if (wr_ptr == DEPTH - 1)
                    wr_ptr <= 0;
                else
                    wr_ptr <= wr_ptr + 1;
            end

            // --- Pop Operation ---
            // Note: Independent 'if' allows simultaneous Push & Pop
            if (pop_en) begin
                // Handle pointer wrapping
                if (rd_ptr == DEPTH - 1)
                    rd_ptr <= 0;
                else
                    rd_ptr <= rd_ptr + 1;
            end
        end
    end

endmodule
*/


  module slave_mem #(
    parameter DEPTH       = 4,   // OUT_PER_MASTER
    parameter NUM_SLAVES  = 3,
    parameter NUM_MASTERS = 2,
    parameter WIDTH       = 2    // log2(NUM_SLAVES)
    )(
    input                   clk,
    input                   rst,

    // Flattened push inputs from all write_address_channels
    input  [NUM_SLAVES-1:0]                     push_valids,   // per slave
    input  [NUM_SLAVES*WIDTH-1:0]               push_slave_ids, // per slave
    input  [NUM_SLAVES*$clog2(NUM_MASTERS)-1:0] push_masters,   // per slave

    // Identity of this FIFO’s master
    input  [$clog2(NUM_MASTERS)-1:0] master_id,

    // Pop control from w_mux
    input  [NUM_SLAVES-1:0]pop,
    input  [NUM_SLAVES-1:0]wready,
    // FIFO outputs
    output reg [WIDTH-1:0]      active_slave,
    output                  empty,
    output                  axi_wready
);

    // FIFO storage
    reg [WIDTH-1:0] mem [DEPTH-1:0];
    reg [$clog2(DEPTH):0] wr_ptr, rd_ptr, count;
    wire full;
    reg     found_one;
    integer found_slave_idx;

    assign empty        = (count == 0);
    assign full         = (count == DEPTH);
    //assign active_slave = mem[rd_ptr];
    assign axi_wready   = wready[active_slave];

    // Push selection logic
    reg push_detected;
    reg [WIDTH-1:0] push_data_sel;
    localparam MASTER_ID_WIDTH = $clog2(NUM_MASTERS);

    integer s;

  always @(*) 
    begin
        // 1. Initialize helper variables
        found_one       = 1'b0;
        found_slave_idx = 0; // Default index

        // 2. Loop from highest to lowest to preserve original priority
        for (s = 0; s < NUM_SLAVES; s = s + 1) 
        begin
            if (push_valids[s] && (push_masters[s*MASTER_ID_WIDTH +: MASTER_ID_WIDTH] == master_id) && !found_one) 
            begin
                found_one       = 1'b1; // Set "found" flag
                found_slave_idx = s;    // Store *highest* 's'
            end
        end
        
        // 3. Assign outputs *after* the loop
        if (found_one)
        begin
            push_detected = 1'b1;
            push_data_sel = push_slave_ids[found_slave_idx*WIDTH +: WIDTH];
        end
        else
        begin
            // Default assignments
            push_detected = 1'b0;
            push_data_sel = 'd0;
        end
    end

    // FIFO update
    always @(posedge clk) 
      begin
        if (rst) 
          begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
          end 
        else 
          begin
            // Push
            if (push_detected && !full) 
              begin
                mem[wr_ptr] <= push_data_sel;
                wr_ptr <= wr_ptr + 1;
                count  <= count + 1;
              end

            // Pop
            else if (pop[active_slave] && !empty) 
              begin
                rd_ptr <= rd_ptr + 1;
                count  <= count - 1;
              end
          end
        active_slave <= mem[rd_ptr];
      end

  endmodule
