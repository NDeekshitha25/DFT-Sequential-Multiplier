module mult_regs (
    input clk,
    input rst,

    // Functional control signals
    input load,
    input add_en,
    input shift,

    // Functional inputs
    input [7:0] a_in,
    input [7:0] b_in,

    // DFT signals
    input scan_enable,
    input [8:0] scan_in_A,
    input [7:0] scan_in_M,
    input [7:0] scan_in_Q,

    // Registers
    output reg [8:0] A,
    output reg [7:0] M,
    output reg [7:0] Q
);

    // Functional next-state logic
    wire [8:0] A_next_func;
    wire [7:0] M_next_func;
    wire [7:0] Q_next_func;

    // Multiplicand register
    assign M_next_func =
        load ? a_in : M;

    // Multiplier register
    assign Q_next_func =
        load  ? b_in :
        shift ? {A[0], Q[7:1]} :
                Q;

    // Accumulator register
    assign A_next_func =
        load   ? 9'b0 :
        add_en ? (A + {1'b0, M}) :
        shift  ? {1'b0, A[8:1]} :
                 A;

    // Registers with scan mux
    always @(posedge clk) begin
        if (rst) begin
            A <= 9'b0;
            M <= 8'b0;
            Q <= 8'b0;
        end
        else begin
            A <= scan_enable ? scan_in_A : A_next_func;
            M <= scan_enable ? scan_in_M : M_next_func;
            Q <= scan_enable ? scan_in_Q : Q_next_func;
        end
    end

endmodule
