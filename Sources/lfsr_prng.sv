// 2D Ising Model FPGA Implementation
// SystemVerilog implementation for Vivado/Blackboard FPGA

//==============================================================================
// Linear Feedback Shift Register (LFSR) for Pseudo-Random Number Generation
//==============================================================================
module lfsr_prng #(
    parameter WIDTH = 16,
    parameter POLY = 16'hB400  // Primitive polynomial for 16-bit LFSR
)(
    input  logic clk,
    input  logic rst_n,
    input  logic enable,
    output logic [WIDTH-1:0] random_out
);

    logic [WIDTH-1:0] lfsr_reg;
    logic feedback;
    
    // Calculate feedback bit using XOR of taps
    assign feedback = ^(lfsr_reg & POLY);
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr_reg <= 16'h1234; // Non-zero seed value
        end else if (enable) begin
            lfsr_reg <= {lfsr_reg[WIDTH-2:0], feedback};
        end
    end
    
    assign random_out = lfsr_reg;
    
endmodule