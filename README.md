# RV32I Single-Cycle Core

A small SystemVerilog RV32I single-cycle processor intended for Intel FPGA development with Quartus and Questa/ModelSim.

## Project layout

```text
rtl/
  core/       CPU datapath and control modules
  mem/        instruction and data memories
  top/        single-cycle system wrapper
tb/           unit and integration testbenches
quartus/      Quartus project files
.github/      GitHub Actions workflow
Makefile      Local Questa/ModelSim test commands
```

## Current implementation

The core currently includes:

- RV32I ALU operations: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
- Immediate formats: I, S, B, U, and J
- Loads and stores: LB, LH, LW, LBU, LHU, SB, SH, and SW
- Conditional branches and JAL/JALR jumps
- LUI and AUIPC
- 32 x 32-bit register file with a hardwired zero register
- Byte-enable data memory interface

The current design is single-cycle. Pipeline-specific modules are not part of this branch.

## Local simulation

The Makefile uses Questa/ModelSim:

```bash
make compile
make test
make test-top
```

`make test` runs the ALU, LSU, register-file, and full top-level integration tests. The top-level test uses `tb/program.hex` as the initial ROM image and performs additional instruction-level checks.

## Continuous integration

GitHub Actions runs the testbenches on `ubuntu-latest` with Icarus Verilog. The workflow is located at `.github/workflows/rtl-ci.yml` and does not require Quartus or Questa to be installed on the GitHub runner.

## Quartus

The Quartus project is in `quartus/riskv_rv32i.qpf`. The configured top-level entity is `rv32i_single_top`.
