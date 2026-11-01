# Simulacao com Icarus Verilog. Uso, dentro de sim/: make
IVERILOG ?= iverilog
VVP      ?= vvp
FLAGS    := -g2012

CORE := ../src/risc_v_32_i_pkg.sv ../src/ArithmeticLogicUnit.sv ../src/ComparatorUnit.sv \
        ../src/CoreControlUnit.sv ../src/DataMemory.sv ../src/ImmediateSignExtend.sv \
        ../src/InstructionMemory.sv ../src/LoadStoreUnit.sv ../src/ProcessorCore.sv \
        ../src/RegisterFile.sv

.PHONY: all clean
all: top.log tb_Accelerator2Mul.log

R_type.txt: gen_programa.py
	python3 gen_programa.py

top.vvp: top.sv $(CORE)
	$(IVERILOG) $(FLAGS) -s top -o $@ $(CORE) top.sv

tb_Accelerator2Mul.vvp: tb_Accelerator2Mul.sv ../src/Accelerator2Mul.sv
	$(IVERILOG) $(FLAGS) -s tb_Accelerator2Mul -o $@ ../src/Accelerator2Mul.sv tb_Accelerator2Mul.sv

top.log: top.vvp R_type.txt Data_Memory_Load.txt expected/R_type_expected.txt
	$(VVP) top.vvp +TEST=R_type | tee $@
	grep -q 'R_type TEST: PASS' $@

tb_Accelerator2Mul.log: tb_Accelerator2Mul.vvp
	$(VVP) tb_Accelerator2Mul.vvp | tee $@
	grep -q 'RESULTADO: PASS' $@

clean:
	rm -f *.vvp *.vcd *.log
