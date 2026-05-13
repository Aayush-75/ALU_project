# ALU_project

This report documents the design and functional verification of a parameterized Arith
metic Logic Unit (ALU) developed as part of the RTL design and verification training
at Mirafra Technologies, Batch 11.
The ALU is a fundamental digital building block capable of performing arithmetic and
logical operations on parameterized-width operands. The default configuration uses 8-bit
operands (width = 8) with a 4-bit command bus (cwidth = 4), yielding a 16-bit result
bus.
The project involved two parallel activities:
• RTL Design (ALU_design_Aayush_6873): Writing a synthesizable Verilog
implementation of the ALU specification.
• Functional Verification (tb_ALU_Aayush_6873): Developing a directed
testbench with an embedded reference model to verify an externally provided DUT
(design_tamil) against the specification.
The design supports 13 arithmetic commands (mode = 1) and 14 logical commands
(mode =0), including multi-cycle multiplication operations, signed arithmetic, bitwise op
erations, shifts, and barrel rotations. All functional blocks were verified using QuestaSim,
and coverage analysis was performed using Questa’s built-in coverage tools.
