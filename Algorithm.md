# Real-time Monitoring

Energy Calculation: Total system Hamiltonian
Magnetization: Net spin alignment
Moving Averages: Statistical analysis over time
Update Control: Configurable simulation speed

# Implementation Details
- Energy Calculation:

Uses Hamiltonian H = -J∑(si·sj) for nearest neighbors
Efficient parallel computation

- Spin Dynamics:

Metropolis acceptance: Accept if ΔE ≤ 0, else probability exp(-ΔE/T)
Simplified Boltzmann probability using temperature scaling

# Boundary Conditions:

- Periodic boundaries for finite-size effects
- Modulo arithmetic for neighbor addressing
