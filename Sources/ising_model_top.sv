//==============================================================================
// Ising Model Top Module
//==============================================================================
module ising_model_top #(
    parameter GRID_SIZE = 8,
    parameter TEMP_WIDTH = 8,
    parameter UPDATE_RATE = 1000000 // Clock cycles between updates
)(
    input  logic clk,
    input  logic rst_n,
    input  logic enable,
    input  logic [TEMP_WIDTH-1:0] temperature,
    input  logic [15:0] random_seed,
    
    // Outputs for analysis and visualization
    output logic [GRID_SIZE-1:0][GRID_SIZE-1:0] spin_states,
    output logic signed [15:0] system_energy,
    output logic signed [15:0] system_magnetization,
    output logic update_tick,
    
    // Debug and monitoring
    output logic [31:0] update_counter,
    output logic [7:0] avg_energy,
    output logic [7:0] avg_magnetization
);

    // Update rate control
    logic [31:0] cycle_counter;
    logic lattice_update_enable;
    
    // Moving average calculations
    logic signed [23:0] energy_accumulator;
    logic signed [23:0] mag_accumulator;
    logic [7:0] sample_count;
    
    // Lattice grid instantiation
    lattice_grid #(
        .GRID_SIZE(GRID_SIZE),
        .TEMP_WIDTH(TEMP_WIDTH)
    ) lattice_inst (
        .clk(clk),
        .rst_n(rst_n),
        .update_enable(lattice_update_enable),
        .temperature(temperature),
        .random_seed(random_seed),
        .spins(spin_states),
        .total_energy(system_energy),
        .magnetization(system_magnetization)
    );
    
    // Update rate controller
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle_counter <= 0;
            lattice_update_enable <= 1'b0;
            update_counter <= 0;
        end else if (enable) begin
            if (cycle_counter >= UPDATE_RATE - 1) begin
                cycle_counter <= 0;
                lattice_update_enable <= 1'b1;
                update_counter <= update_counter + 1;
            end else begin
                cycle_counter <= cycle_counter + 1;
                lattice_update_enable <= 1'b0;
            end
        end else begin
            lattice_update_enable <= 1'b0;
        end
    end
    
    // Moving average calculation for system monitoring
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            energy_accumulator <= 0;
            mag_accumulator <= 0;
            sample_count <= 0;
        end else if (lattice_update_enable) begin
            if (sample_count < 255) begin
                energy_accumulator <= energy_accumulator + system_energy;
                mag_accumulator <= mag_accumulator + system_magnetization;
                sample_count <= sample_count + 1;
            end else begin
                // Reset accumulator when full
                energy_accumulator <= system_energy;
                mag_accumulator <= system_magnetization;
                sample_count <= 1;
            end
        end
    end
    
    // Calculate averages
    assign avg_energy = (sample_count > 0) ? 
                       (energy_accumulator / sample_count) : 8'h80;
    assign avg_magnetization = (sample_count > 0) ? 
                              (mag_accumulator / sample_count) : 8'h00;
    
    assign update_tick = lattice_update_enable;
    
endmodule