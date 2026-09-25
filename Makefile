VLOG := vlog
VSIM := vsim

RTL_CORE := rtl/core/*.sv
RTL_MEM := rtl/mem/*.sv
RTL_TOP := rtl/top/*.sv
TB_UNIT := tb/tb_alu.sv tb/tb_lsu.sv tb/tb_regfile.sv
TB_TOP := tb/tb_rv32i_single_top.sv

.PHONY: compile test test-alu test-lsu test-regfile test-top clean

compile:
	$(VLOG) -sv $(RTL_CORE) $(RTL_MEM) $(RTL_TOP) $(TB_UNIT) $(TB_TOP)

test: test-alu test-lsu test-regfile test-top

test-alu: compile
	$(VSIM) -c tb_alu -do "run -all; quit -f"

test-lsu: compile
	$(VSIM) -c tb_lsu -do "run -all; quit -f"

test-regfile: compile
	$(VSIM) -c tb_regfile -do "run -all; quit -f"

test-top:
	cd quartus/simulation/questa && $(VLOG) -sv ../../../rtl/core/*.sv ../../../rtl/mem/*.sv ../../../rtl/top/*.sv ../../../tb/tb_rv32i_single_top.sv
	cd quartus/simulation/questa && $(VSIM) -c tb_rv32i_single_top -do "run -all; quit -f"

clean:
	-vdel -lib work -all
	-vdel -lib quartus/simulation/questa/rtl_work -all