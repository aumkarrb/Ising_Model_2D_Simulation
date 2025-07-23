//==============================================================================
// Testbench for Simulation
//==============================================================================
module ising_model_tb;
    parameter GRID_SIZE = 4;
    parameter TEMP_WIDTH = 8;
    parameter UPDATE_RATE = 100; // Faster for simulation
    
    logic clk, rst_n, enable;
    logic [TEMP_WIDTH-1:0] temperature;
    logic [15:0] random_seed;
    
    logic [GRID_SIZE-1:0][GRID_SIZE-1:0] spin_states;
    logic signed [15:0] system_energy;
    logic signed [15:0] system_magnetization;
    logic update_tick;
    logic [31:0] update_counter;
    logic [7:0] avg_energy, avg_magnetization;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // DUT instantiation
    ising_model_top #(
        .GRID_SIZE(GRID_SIZE),
        .TEMP_WIDTH(TEMP_WIDTH),
        .UPDATE_RATE(UPDATE_RATE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .temperature(temperature),
        .random_seed(random_seed),
        .spin_states(spin_states),
        .system_energy(system_energy),
        .system_magnetization(system_magnetization),
        .update_tick(update_tick),
        .update_counter(update_counter),
        .avg_energy(avg_energy),
        .avg_magnetization(avg_magnetization)
    );
    
    // Test sequence
    initial begin
        // Initialize
        rst_n = 0;
        enable = 0;
        temperature = 8'h20; // Medium temperature
        random_seed = 16'h1234;
        
        // Reset
        #20 rst_n = 1;
        #10 enable = 1;
        
        // Run simulation
        $display("Starting Ising Model Simulation...");
        $display("Grid Size: %0d x %0d", GRID_SIZE, GRID_SIZE);
        $display("Temperature: %0d", temperature);
        
        // Monitor for several updates
        repeat (10) begin
            @(posedge update_tick);
            $display("Update %0d: Energy=%0d, Magnetization=%0d", 
                    update_counter, system_energy, system_magnetization);
        end
        
        // Test temperature change
        $display("Changing temperature to high...");
        temperature = 8'h80;
        
        repeat (10) begin
            @(posedge update_tick);
            $display("Update %0d: Energy=%0d, Magnetization=%0d", 
                    update_counter, system_energy, system_magnetization);
        end
        
        // Test low temperature
        $display("Changing temperature to low...");
        temperature = 8'h08;
        
        repeat (10) begin
            @(posedge update_tick);
            $display("Update %0d: Energy=%0d, Magnetization=%0d", 
                    update_counter, system_energy, system_magnetization);
        end
        
        $display("Simulation completed.");
        $finish;
    end
    
    // Monitor spin states
    always @(posedge update_tick) begin
        $display("Spin Configuration:");
        for (int i = 0; i < GRID_SIZE; i++) begin
            $write("  ");
            for (int j = 0; j < GRID_SIZE; j++) begin
                $write("%s ", spin_states[i][j] ? "↑" : "↓");
            end
            $write("\n");
        end
    end
    
endmodule