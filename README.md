# Ising_Model_2D_Simulation

### Design of a basic 2D Ising Model simulation using digital logic gates and SystemVerilog, focusing on:
1. Creation a finite lattice grid representation
2. Implementing spin interaction logic
3. Developing state transition mechanisms
4. Generating randomized spin flip decisions
5. Calculating total system energy and magnetization

# Objective
- Demonstration of fundamental magnetic interaction principles
- Providing real-time visualization of spin state changes
- Allowing parametric configuration of lattice size and interaction rules
- Enabling performance analysis of statistical mechanics principles 

# Knowledge
Key Implementation Considerations:
- Usage 1-bit or 2-state logic for spin representation (+1/-1)
- Implementation of nearest-neighbor interaction rules
- Creation of pseudo-random number generator for probabilistic spin flips
- Consideration of temperature parameter simulation
- Management synchronous state updates

# Key Features:

## 1. Modular Architecture

- LFSR PRNG: Linear Feedback Shift Register for pseudo-random number generation
- Spin Cell: Individual spin logic implementing Metropolis algorithm
-  Lattice Grid: 2D array of interconnected spin cells
- Top Module: System integration with control and monitoring

## 2. Core Functionality

- Spin Representation: 1-bit logic (1=up, 0=down) for ±1 spins
- Nearest-Neighbor Interactions: Periodic boundary conditions
- Metropolis Algorithm: Probabilistic spin flips based on energy difference
- Temperature Control: Parameterizable temperature affecting flip probability
