SIM_COMPILER ?= iverilog
SIM_RUNNER   ?= vvp
SIM_FLAGS    := -g2012

OUT_DIR := sim_build

SRC_DIR := ../src

CORE_SRCS := $(SRC_DIR)/risc_v_32_i_pkg.sv \
            $(SRC_DIR)/Accelerator2Mul.sv \
            $(SRC_DIR)/ArithmeticLogicUnit.sv \
            $(SRC_DIR)/ComparatorUnit.sv \
            $(SRC_DIR)/CoreControlUnit.sv \
            $(SRC_DIR)/DataMemory.sv \
            $(SRC_DIR)/ImmediateSignExtend.sv \
            $(SRC_DIR)/InstructionMemory.sv \
            $(SRC_DIR)/LoadStoreUnit.sv \
            $(SRC_DIR)/ProcessorCore.sv \
            $(SRC_DIR)/RegisterFile.sv

ACCEL_SRCS := $(SRC_DIR)/Accelerator2Mul.sv

.PHONY: all build build-core build-accel test test-core test-accel run-tests run-core run-accel clean

all: test

build: build-core build-accel

build-core:  $(OUT_DIR)/sim_core.out

build-accel: $(OUT_DIR)/sim_accel.out

test: test-core test-accel

test-core:  $(OUT_DIR)/sim_core.log

test-accel: $(OUT_DIR)/sim_accel.log

run-tests: run-core run-accel

run-core:
	$(SIM_RUNNER) $(OUT_DIR)/sim_core.out +TEST=R_type | tee $(OUT_DIR)/sim_core.log
	grep -q 'R_type TEST: PASS' $(OUT_DIR)/sim_core.log

run-accel:
	$(SIM_RUNNER) $(OUT_DIR)/sim_accel.out | tee $(OUT_DIR)/sim_accel.log
	grep -q 'RESULTADO: PASS' $(OUT_DIR)/sim_accel.log

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

R_type.txt: gen_programa.py
	python3 gen_programa.py

$(OUT_DIR)/sim_core.out: top.sv $(CORE_SRCS) | $(OUT_DIR)
	$(SIM_COMPILER) $(SIM_FLAGS) -s top -o $@ $(CORE_SRCS) top.sv

$(OUT_DIR)/sim_accel.out: tb_Accelerator2Mul.sv $(ACCEL_SRCS) | $(OUT_DIR)
	$(SIM_COMPILER) $(SIM_FLAGS) -s tb_Accelerator2Mul -o $@ $(ACCEL_SRCS) tb_Accelerator2Mul.sv

$(OUT_DIR)/sim_core.log: $(OUT_DIR)/sim_core.out R_type.txt Data_Memory_Load.txt expected/R_type_expected.txt
	@$(MAKE) run-core

$(OUT_DIR)/sim_accel.log: $(OUT_DIR)/sim_accel.out
	@$(MAKE) run-accel

clean:
	rm -rf $(OUT_DIR) R_type.txt *.vcd
