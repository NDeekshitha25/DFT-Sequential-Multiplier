module ICG (
    input  clk,
    input  enable,       // Functional clock enable (e.g., count_en)
    input  test_enable,  // Test mode: bypass clock gating
    output gated_clk
);

    // Latch-based clock gate to avoid glitches
    reg en_latch;

    always @(clk or enable or test_enable) begin
        if (!clk)
            en_latch <= enable | test_enable;
    end

    // Gate the clock
    assign gated_clk = clk & en_latch;

endmodule
