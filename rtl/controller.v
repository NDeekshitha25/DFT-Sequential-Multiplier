module controller (
    input clk,
    input rst,
    input start,
    input last,
    input q_lsb,

    // DFT signals
    input scan_enable,
    input [2:0] scan_in,

    output reg load,
    output reg add_en,
    output reg shift,
    output reg count_en,
    output reg clear,
    output reg done,

    // Exposed for scan chain
    output reg [2:0] state
);

    // State encoding
    localparam IDLE  = 3'd0,
               LOAD  = 3'd1,
               CHECK = 3'd2,
               ADD   = 3'd3,
               SHIFT = 3'd4,
               DONE  = 3'd5;

    reg [2:0] next;

    //-------------------------------------------------------
    // Next-State Logic
    //-------------------------------------------------------
    always @(*) begin
        case (state)
            IDLE:
                next = start ? LOAD : IDLE;

            LOAD:
                next = CHECK;

            CHECK:
                next = q_lsb ? ADD : SHIFT;

            ADD:
                next = SHIFT;

            SHIFT:
                next = last ? DONE : CHECK;

            DONE:
                next = IDLE;

            default:
                next = IDLE;
        endcase
    end

    //-------------------------------------------------------
    // State Register with Scan Mux
    //-------------------------------------------------------
    always @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= scan_enable ? scan_in : next;
    end

    //-------------------------------------------------------
    // Output Logic
    //-------------------------------------------------------
    always @(*) begin
        load     = 1'b0;
        add_en   = 1'b0;
        shift    = 1'b0;
        count_en = 1'b0;
        clear    = 1'b0;
        done     = 1'b0;

        case (state)

            LOAD: begin
                load  = 1'b1;
                clear = 1'b1;
            end

            ADD:
                add_en = 1'b1;

            SHIFT: begin
                shift    = 1'b1;
                count_en = 1'b1;
            end

            DONE:
                done = 1'b1;

            default: ;
        endcase
    end

endmodule
