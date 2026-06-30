module bit_counter (
    input clk,
    input rst,
    input clear,
    input count_en,

    // DFT signals
    input test_mode,
    input scan_enable,
    input [3:0] scan_in,

    output reg [3:0] count,
    output last
);

    // Clock gate output
    wire gated_clk;

    // Integrated Clock Gate
    ICG u_icg (
        .clk(clk),
        .enable(count_en),
        .test_enable(test_mode),
        .gated_clk(gated_clk)
    );

    // Functional next-state logic
    wire [3:0] count_next_func;
    assign count_next_func = clear ? 4'd0 : (count + 4'd1);

    // Counter register with scan mux
    always @(posedge gated_clk) begin
        if (rst)
            count <= 4'd0;
        else if (scan_enable)
            count <= scan_in;          // Scan Shift Mode
        else
            count <= count_next_func;  // Functional/Capture Mode
    end

    // Assert after 8 shift cycles (count = 7)
    assign last = (count == 4'd7);

endmodule
