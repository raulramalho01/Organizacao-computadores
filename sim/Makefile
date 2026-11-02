SIM_COMPILER ?= iverilog
SIM_RUNNER   ?= vvp
SIM_FLAGS    := -g2012

OUT_DIR := sim_build

SRC_DIR := ../src

CORE_SRCS := $(SRC_DIR)/risc_v_32_i_pkg.sv \
            $(SRC_DIR)/ArithmeticLogicUnit.sv \
            $(SRC_DIR)/ComparatorUnit.sv \
            $(SRC_DIR)/CoreControlUnit.sv \
            $(SRC_DIR)/DataMemory.sv \
            $(SRC_DIR)/ImmediateSignExtend.sv \
            $(SRC_DIR)/InstructionMemory.sv \
            $(SRC_DIR)/LoadStoreUnit.sv \
            $(SRC_DIR)/ProcessorCore.sv \
            $(SRC_DIR)/RegisterFile.sv

.PHONY: all build build-core test test-core run-tests run-core clean

all: test

build: build-core

build-core:  $(OUT_DIR)/sim_core.out

test: test-core

test-core:  $(OUT_DIR)/sim_core.log

run-tests: run-core

run-core:
	$(SIM_RUNNER) $(OUT_DIR)/sim_core.out +TEST=R_type | tee $(OUT_DIR)/sim_core.log
	grep -q 'R_type TEST: PASS' $(OUT_DIR)/sim_core.log

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

R_type.txt: gen_programa.py
	python3 gen_programa.py

$(OUT_DIR)/sim_core.out: top.sv $(CORE_SRCS) | $(OUT_DIR)
	$(SIM_COMPILER) $(SIM_FLAGS) -s top -o $@ $(CORE_SRCS) top.sv

$(OUT_DIR)/sim_core.log: $(OUT_DIR)/sim_core.out R_type.txt Data_Memory_Load.txt expected/R_type_expected.txt
	@$(MAKE) run-core

clean:
	rm -rf $(OUT_DIR) R_type.txt *.vcd
