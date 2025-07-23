//==============================================================================
// Single Spin Cell Module
//==============================================================================
module spin_cell #(
    parameter TEMP_WIDTH = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic update_enable,
    input  logic spin_up,        // Current spin state (1=up, 0=down)
    input  logic [3:0] neighbors, // 4 nearest neighbors
    input  logic [TEMP_WIDTH-1:0] temperature,
    input  logic [15:0] random_val,
    output logic new_spin
);

    // Calculate energy difference for spin flip
    logic signed [3:0] neighbor_sum;
    logic signed [3:0] energy_diff;
    logic [7:0] probability_threshold;
    logic flip_decision;
    
    // Sum of neighbors (each neighbor contributes +1 or -1)
    always_comb begin
        neighbor_sum = 0;
        for (int i = 0; i < 4; i++) begin
            neighbor_sum += neighbors[i] ? 1 : -1;
        end
    end
    
    // Energy difference calculation: ΔE = 2J * spin * sum(neighbors)
    // For ferromagnetic coupling (J > 0), energy is lower when aligned
    assign energy_diff = spin_up ? (2 * neighbor_sum) : (-2 * neighbor_sum);
    
    // Metropolis algorithm implementation
    // Accept if ΔE <= 0, or with probability exp(-ΔE/T) if ΔE > 0
    always_comb begin
        if (energy_diff <= 0) begin
            flip_decision = 1'b1; // Always accept energy-lowering moves
        end else begin
            // Simplified Boltzmann probability using lookup table approach
            // Higher temperature = higher threshold = more likely to flip
            case (energy_diff)
                1: probability_threshold = (temperature << 4); // Scale by 16
                2: probability_threshold = (temperature << 3); // Scale by 8
                3: probability_threshold = (temperature << 2); // Scale by 4
                4: probability_threshold = (temperature << 1); // Scale by 2
                default: probability_threshold = temperature;
            endcase
            
            flip_decision = (random_val[7:0] < probability_threshold);
        end
    end
    
    // Output new spin state
    assign new_spin = update_enable ? (flip_decision ? ~spin_up : spin_up) : spin_up;
    
endmodule