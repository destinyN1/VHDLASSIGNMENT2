# JTAG_FSM

## Overview

The `JTAG_FSM` project implements a JTAG (Joint Test Action Group) Finite State Machine (FSM) using VHDL. This FSM adheres to the IEEE standard for JTAG operations, facilitating the testing and debugging of digital circuits through the Test Access Port (TAP). The project includes both the FSM design and a comprehensive testbench for simulation and verification purposes.

## Features

- **JTAG FSM Implementation:** Complete implementation of the 16-state JTAG TAP controller as per the IEEE standard.
- **Data Handling:** 32-bit internal registers for data shifting and capture.
- **State Transition Logic:** Comprehensive state transition logic based on TMS (Test Mode Select) input.
- **Data Shifting Mechanism:** Shifts data serially through TDI (Test Data In) and TDO (Test Data Out).
- **Testbench:** An extensive testbench to simulate and verify the FSM's functionality under various scenarios.
- **Counter Logic:** Implements a 32-bit counter to track data shifts during the ShiftDR state.

## Requirements

- **VHDL Simulator:** Any VHDL simulation tool such as ModelSim, GHDL, Vivado, or similar.
- **Text Editor/IDE:** For viewing and editing the VHDL code (e.g., Visual Studio Code, Sublime Text, Vivado IDE).
- **Version Control (Optional):** Git, for cloning the repository.

## Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/destinyN1/JTAG_FSM.git
