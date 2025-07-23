//==============================================================================
// 2D Lattice Grid Module
//==============================================================================
module lattice_grid #(
    parameter GRID_SIZE = 8,
    parameter TEMP_WIDTH = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic update_enable,
    input  logic [TEMP_WIDTH-1:0] temperature,
    input  logic [15:0] random_seed,
    output logic [GRID_SIZE-1:0][GRID_SIZE-1:0] spins,
    output logic signed [15:0] total_energy,
    output logic signed [15:0] magnetization
);

    // Internal spin arrays
    logic [GRID_SIZE-1:0][GRID_SIZE-1:0] current_spins;
    logic [GRID_SIZE-1:0][GRID_SIZE-1:0] next_spins;
    
    // Random number generation
    logic [15:0] random_vals [GRID_SIZE-1:0][GRID_SIZE-1:0];
    logic prng_enable;
    
    // Generate random numbers for each cell
    genvar i, j;
    generate
        for (i = 0; i < GRID_SIZE; i++) begin : gen_row
            for (j = 0; j < GRID_SIZE; j++) begin : gen_col
                lfsr_prng #(
                    .WIDTH(16),
                    .POLY(16'hB400)
                ) prng_inst (
                    .clk(clk),
                    .rst_n(rst_n),
                    .enable(prng_enable),
                    .random_out(random_vals[i][j])
                );
            end
        end
    endgenerate
    
    // Spin update logic with nearest-neighbor calculation
    generate
        for (i = 0; i < GRID_SIZE; i++) begin : spin_row
            for (j = 0; j < GRID_SIZE; j++) begin : spin_col
                logic [3:0] neighbors;
                
                // Calculate periodic boundary conditions
                always_comb begin
                    neighbors[0] = current_spins[(i-1+GRID_SIZE)%GRID_SIZE][j]; // Top
                    neighbors[1] = current_spins[(i+1)%GRID_SIZE][j];           // Bottom
                    neighbors[2] = current_spins[i][(j-1+GRID_SIZE)%GRID_SIZE]; // Left
                    neighbors[3] = current_spins[i][(j+1)%GRID_SIZE];           // Right
                end
                
                spin_cell #(
                    .TEMP_WIDTH(TEMP_WIDTH)
                ) cell_inst (
                    .clk(clk),
                    .rst_n(rst_n),
                    .update_enable(update_enable),
                    .spin_up(current_spins[i][j]),
                    .neighbors(neighbors),
                    .temperature(temperature),
                    .random_val(random_vals[i][j]),
                    .new_spin(next_spins[i][j])
                );
            end
        end
    endgenerate
    
    // State update register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Initialize with random configuration
            for (int i = 0; i < GRID_SIZE; i++) begin
                for (int j = 0; j < GRID_SIZE; j++) begin
                    current_spins[i][j] <= (i + j) % 2; // Checkerboard pattern
                end
            end
            prng_enable <= 1'b1;
        end else begin
            if (update_enable) begin
                current_spins <= next_spins;
            end
            prng_enable <= update_enable;
        end
    end
    
    // Calculate total energy (Hamiltonian)
    // H = -J * Σ(si * sj) for all nearest neighbor pairs
    logic signed [15:0] energy_sum;
    always_comb begin
        energy_sum = 0;
        for (int i = 0; i < GRID_SIZE; i++) begin
            for (int j = 0; j < GRID_SIZE; j++) begin
                logic signed [1:0] spin_val;
                logic signed [1:0] right_neighbor, bottom_neighbor;
                
                spin_val = current_spins[i][j] ? 1 : -1;
                right_neighbor = current_spins[i][(j+1)%GRID_SIZE] ? 1 : -1;
                bottom_neighbor = current_spins[(i+1)%GRID_SIZE][j] ? 1 : -1;
                
                // Count each pair once (right and bottom neighbors only)
                energy_sum -= (spin_val * right_neighbor + spin_val * bottom_neighbor);
            end
        end
    end
    
    // Calculate magnetization
    logic signed [15:0] mag_sum;
    always_comb begin
        mag_sum = 0;
        for (int i = 0; i < GRID_SIZE; i++) begin
            for (int j = 0; j < GRID_SIZE; j++) begin
                mag_sum += current_spins[i][j] ? 1 : -1;
            end
        end
    end
    
    // Output assignments
    assign spins = current_spins;
    assign total_energy = energy_sum;
    assign magnetization = mag_sum;
    
endmodule
