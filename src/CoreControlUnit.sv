/***************************************************************************
* Copyright (c) 2022 Hariesh Anbalagan
* SPDX-License-Identifier: GPL-3.0-only
* 
* Module: CoreControlUnit.sv
*
* Description:
* This does control of the processor core datapath
***************************************************************************/

// ==============================================================================
// MÓDULO: CoreControlUnit (Unidade de Controle Principal)
// ==============================================================================
// Este módulo é o "cérebro" do processador. Ele é um bloco puramente combinacional
// que decodifica os campos da instrução de 32 bits e ativa todos os sinais de controle
// do Datapath para aquele ciclo de clock.
//
// ENTRADAS DE DECODIFICAÇÃO:
//   - op_code_i     : instruction[6:0]   -> Identifica o formato/família da instrução
//   - funct3_i      : instruction[14:12] -> Suboperação de 3 bits
//   - funct7_bit5_i : instruction[30]    -> Bit 5 do funct7 (diferencia ADD/SUB, SRL/SRA)
//   - branch_enable_i: Vem do ComparatorUnit -> Flag que indica se a condição de salto foi atendida
//
// SAÍDAS DE CONTROLE:
//   - pc_mux_sel_o               : 0 = PC+4 (próxima seq.), 1 = ALU (salto/desvio)
//   - reg_write_enable_o         : 1 = Grava resultado no banco de registradores (rd)
//   - imm_select_o               : Informa ao ImmediateSignExtend qual formato de imediato decodificar
//   - execute_port_a_sel_o       : Seletor entrada A da ALU: 1 = rs1, 0 = PC
//   - execute_port_b_sel_o       : Seletor entrada B da ALU/Comp: 1 = rs2, 0 = imediato
//   - alu_op_sel_o               : Operação que a ALU executará (OP_ADD, OP_SUB, etc.)
//   - comp_op_sel_o              : Operação do comparador (OP_BEQ, OP_BLT, etc.)
//   - load_store_type_o          : Tipo de acesso à memória (byte, half, word)
//   - data_memory_write_enable_o : 1 = Grava na memória RAM de dados (store)
//   - reg_write_data_sel_o       : MUX de write-back para rd (ALU, memória, PC+4, etc.)
// ==============================================================================

import risc_v_32_i_pkg::*;

module CoreControlUnit #(parameter XLEN = 32)
(
    output logic                    pc_mux_sel_o,
    output logic                    reg_write_enable_o,
    output imm_select_e             imm_select_o,
    output logic                    execute_port_a_sel_o,
    output logic                    execute_port_b_sel_o,
    output alu_select_e             alu_op_sel_o,
    output comp_select_e            comp_op_sel_o,
    output load_store_type_e        load_store_type_o,
    output logic                    data_memory_write_enable_o,
    output write_data_select_e      reg_write_data_sel_o,
    input logic [6:0]               op_code_i,
    input logic [2:0]               funct3_i,
    input logic                     funct7_bit5_i,
    input logic                     branch_enable_i
);

    // Constantes dos OPCODES (bits [6:0] da instrução RISC-V)
    localparam OP_R_TYPE        = 7'b0110011;  // Operações registradores (add, sub, and, or, sll...)
    localparam OP_B_TYPE        = 7'b1100011;  // Desvios condicionais (beq, bne, blt, bge...)
    localparam OP_S_TYPE        = 7'b0100011;  // Escrita em memória (sb, sh, sw)
    localparam OP_I_JALR_TYPE   = 7'b1100111;  // Salto indireto registrador (jalr)
    localparam OP_I_LOAD_TYPE   = 7'b0000011;  // Leitura de memória (lb, lh, lw...)
    localparam OP_I_ALU_TYPE    = 7'b0010011;  // Operações imediatas (addi, andi, ori, slli...)
    localparam OP_I_FENCE_TYPE  = 7'b0001111;  // Sincronização de memória (fence)
    localparam OP_I_ECALL_TYPE  = 7'b1110011;  // Chamada de sistema / debug (ecall, ebreak)
    localparam OP_U_LUI_TYPE    = 7'b0110111;  // Carrega imediato superior (lui)
    localparam OP_U_AUIPC_TYPE  = 7'b0010111;  // Adiciona imediato superior ao PC (auipc)
    localparam OP_J_TYPE        = 7'b1101111;  // Salto incondicional e link (jal)

    always_comb
    begin

        unique case(op_code_i)
            // ==================================================================
            // INSTRUÇÕES TIPO R (Registrador - Registrador: opcode 0110011)
            // rd = rs1 OP rs2
            // ==================================================================
            OP_R_TYPE:
            begin
                pc_mux_sel_o = 1'b0;                 // Próximo PC = PC + 4
                reg_write_enable_o = 1'b1;           // Escreve resultado em rd
                imm_select_o = IMM_UNKNOWN_TYPE;     // Sem imediato
                execute_port_a_sel_o = 1'b1;         // Porta A da ALU = registrador rs1

                // Decodificação pelo bit 30 (funct7[5]) e funct3: {funct7[5], funct3}
                unique case({funct7_bit5_i,funct3_i})
                    4'b0000: // ADD (funct7_bit5 = 0, funct3 = 000)
                            begin
                            alu_op_sel_o = OP_ADD;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1; // Porta B = registrador rs2
                            reg_write_data_sel_o = RD_MUX_ALU; // rd recebe resultado da ALU
                            end
                    4'b1000:
                            begin
                            alu_op_sel_o = OP_SUB;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                    4'b0001:
                            begin
                            alu_op_sel_o = OP_SLL;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                    4'b0010:
                            begin
                            alu_op_sel_o = OP_UNKNOWN;
                            comp_op_sel_o = OP_BLT;
                            execute_port_b_sel_o = 1'b0;
                            reg_write_data_sel_o = RD_MUX_BCU;
                            end
                    4'b0011:
                            begin
                            alu_op_sel_o = OP_UNKNOWN;
                            comp_op_sel_o = OP_BLTU;
                            execute_port_b_sel_o = 1'b0;
                            reg_write_data_sel_o = RD_MUX_BCU;
                            end
                    4'b0100:
                            begin
                            alu_op_sel_o = OP_XOR;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                    4'b0101:
                            begin
                            alu_op_sel_o = OP_SRL;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                    4'b1101:
                            begin
                            alu_op_sel_o = OP_SRA;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                    4'b0110:
                            begin
                            alu_op_sel_o = OP_OR;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                    4'b0111:
                            begin
                            alu_op_sel_o = OP_AND;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                    // inserção das novas instruções eu vou é deixar aqui msm
                    4'b1110: // esse aqui vai ser do max
                            begin
                            alu_op_sel_o = OP_MAX;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end                                
                    4'b1100: // esse aqui vai ser do home sign
                            begin
                            alu_op_sel_o = OP_SIGN;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                    4'b1001: // esse vai ser do meq
                            begin
                            alu_op_sel_o = OP_MAC;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                    default: // importante: eu me liguei dps que esse tal de op_unknown é meio q um comportamento default mesmo, tem em boa parte dos cantos. não é erro não.
                            begin
                            alu_op_sel_o = OP_UNKNOWN;
                            comp_op_sel_o = OP_BUNKNOWN;
                            execute_port_b_sel_o = 1'b1;
                            reg_write_data_sel_o = RD_MUX_ALU;
                            end
                endcase

                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
            end
            OP_B_TYPE:
            begin
                pc_mux_sel_o = branch_enable_i;
                reg_write_enable_o = 1'b0;
                imm_select_o = IMM_B_TYPE;
                execute_port_a_sel_o = 1'b0;
                execute_port_b_sel_o = 1'b0;
                alu_op_sel_o = OP_ADD;

                unique case(funct3_i)
                    3'b000: comp_op_sel_o = OP_BEQ;
                    3'b001: comp_op_sel_o = OP_BNE;
                    3'b100: comp_op_sel_o = OP_BLT;
                    3'b101: comp_op_sel_o = OP_BGE;
                    3'b110: comp_op_sel_o = OP_BLTU;
                    3'b111: comp_op_sel_o = OP_BGEU;
                   default: comp_op_sel_o = OP_BUNKNOWN;
                endcase

                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
                reg_write_data_sel_o = RD_MUX_N_A;
            end
            OP_S_TYPE:
            begin
                pc_mux_sel_o = 1'b0;
                reg_write_enable_o = 1'b0;
                imm_select_o = IMM_S_TYPE;
                execute_port_a_sel_o = 1'b1;
                execute_port_b_sel_o = 1'b0;
                alu_op_sel_o = OP_ADD;
                comp_op_sel_o = OP_BUNKNOWN;

                unique case(funct3_i)
                    3'b000:  load_store_type_o = S_B;
                    3'b001:  load_store_type_o = S_H;
                    3'b010:  load_store_type_o = S_W;
                endcase

                data_memory_write_enable_o = 1'b1;
                reg_write_data_sel_o = RD_MUX_N_A;
            end
            OP_I_JALR_TYPE:
            begin
                pc_mux_sel_o = 1'b1;
                reg_write_enable_o = 1'b1;
                imm_select_o = IMM_I_TYPE;
                execute_port_a_sel_o = 1'b1;
                execute_port_b_sel_o = 1'b0;
                alu_op_sel_o = OP_ADD;
                comp_op_sel_o = OP_BUNKNOWN;
                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
                reg_write_data_sel_o = RD_MUX_PC_N;
            end
            OP_I_LOAD_TYPE:
            begin
                pc_mux_sel_o = 1'b0;
                reg_write_enable_o = 1'b1;
                imm_select_o = IMM_I_TYPE;
                execute_port_a_sel_o = 1'b1;
                execute_port_b_sel_o = 1'b0;
                alu_op_sel_o = OP_ADD;
                comp_op_sel_o = OP_BUNKNOWN;

                unique case(funct3_i)
                    3'b000:  load_store_type_o = L_B;
                    3'b001:  load_store_type_o = L_H;
                    3'b010:  load_store_type_o = L_W;
                    3'b100:  load_store_type_o = L_BU;
                    3'b101:  load_store_type_o = L_HU;
                    default: load_store_type_o = L_W;
                endcase

                data_memory_write_enable_o = 1'b0;
                reg_write_data_sel_o = RD_MUX_DMEM;
            end
            // ==================================================================
            // INSTRUÇÕES TIPO I - ALU (Aritmética/Lógica com Imediato: opcode 0010011)
            // rd = rs1 OP imm (ex: addi, andi, ori, slli, srli, srai)
            // ==================================================================
            OP_I_ALU_TYPE:
            begin
                pc_mux_sel_o = 1'b0;                 // Próximo PC = PC + 4
                reg_write_enable_o = 1'b1;           // Escreve resultado em rd
                imm_select_o = IMM_I_TYPE;           // Decodifica imediato de 12 bits do Tipo I
                execute_port_a_sel_o = 1'b1;         // Porta A da ALU = registrador rs1

                unique case(funct3_i)
                    3'b000: // ADDI (funct3 = 000) -> rd = rs1 + imm
                           begin
                           alu_op_sel_o = OP_ADD;
                           comp_op_sel_o = OP_BUNKNOWN;
                           execute_port_b_sel_o = 1'b0; // Porta B da ALU = imediato estendido
                           reg_write_data_sel_o = RD_MUX_ALU; // rd recebe resultado da ALU
                           end
                    3'b010:
                           begin
                           alu_op_sel_o = OP_UNKNOWN;
                           comp_op_sel_o = OP_BLT;
                           execute_port_b_sel_o = 1'b1;
                           reg_write_data_sel_o = RD_MUX_BCU;
                           end
                    3'b011:
                           begin
                           alu_op_sel_o = OP_UNKNOWN;
                           comp_op_sel_o = OP_BLTU;
                           execute_port_b_sel_o = 1'b1;
                           reg_write_data_sel_o = RD_MUX_BCU;
                           end
                    3'b100:
                           begin
                           alu_op_sel_o = OP_XOR;
                           comp_op_sel_o = OP_BUNKNOWN;
                           execute_port_b_sel_o = 1'b0;
                           reg_write_data_sel_o = RD_MUX_ALU;
                           end
                    3'b110:
                           begin
                           alu_op_sel_o = OP_OR;
                           comp_op_sel_o = OP_BUNKNOWN;
                           execute_port_b_sel_o = 1'b0;
                           reg_write_data_sel_o = RD_MUX_ALU;
                           end
                    3'b111:
                           begin
                           alu_op_sel_o = OP_AND;
                           comp_op_sel_o = OP_BUNKNOWN;
                           execute_port_b_sel_o = 1'b0;
                           reg_write_data_sel_o = RD_MUX_ALU;
                           end
                    3'b001:
                           begin
                           alu_op_sel_o = OP_SLL;
                           comp_op_sel_o = OP_BUNKNOWN;
                           execute_port_b_sel_o = 1'b0;
                           reg_write_data_sel_o = RD_MUX_ALU;
                           end
                    3'b101:
                           begin
                           alu_op_sel_o = alu_select_e'((funct7_bit5_i)? OP_SRA : OP_SRL);
                           comp_op_sel_o = OP_BUNKNOWN;
                           execute_port_b_sel_o = 1'b0;
                           reg_write_data_sel_o = RD_MUX_ALU;
                           end
                   default:
                           begin
                           alu_op_sel_o = OP_UNKNOWN;
                           comp_op_sel_o = OP_BUNKNOWN;
                           execute_port_b_sel_o = 1'b0;
                           reg_write_data_sel_o = RD_MUX_ALU;
                           end
                endcase

                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
            end
            OP_I_FENCE_TYPE:
            begin
                pc_mux_sel_o = 1'b0;
                reg_write_enable_o = 1'b0;
                imm_select_o = IMM_I_TYPE;
                execute_port_a_sel_o = 1'b1;
                execute_port_b_sel_o = 1'b0;
                alu_op_sel_o = OP_UNKNOWN;
                comp_op_sel_o = OP_BUNKNOWN;
                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
                reg_write_data_sel_o = RD_MUX_N_A;
            end
            OP_I_ECALL_TYPE:
            begin
                pc_mux_sel_o = 1'b0;
                reg_write_enable_o = 1'b0;
                imm_select_o = IMM_I_TYPE;
                execute_port_a_sel_o = 1'b1;
                execute_port_b_sel_o = 1'b0;
                alu_op_sel_o = OP_UNKNOWN;
                comp_op_sel_o = OP_BUNKNOWN;
                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
                reg_write_data_sel_o = RD_MUX_N_A;
            end
            OP_U_LUI_TYPE:
            begin
                pc_mux_sel_o = 1'b0;
                reg_write_enable_o = 1'b1;
                imm_select_o = IMM_U_TYPE;
                execute_port_a_sel_o = 1'b0;
                execute_port_b_sel_o = 1'b0;
                alu_op_sel_o = OP_UNKNOWN;
                comp_op_sel_o = OP_BUNKNOWN;
                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
                reg_write_data_sel_o = RD_MUX_IMM;
            end
            OP_U_AUIPC_TYPE:
            begin
                pc_mux_sel_o = 1'b0;
                reg_write_enable_o = 1'b1;
                imm_select_o = IMM_U_TYPE;
                execute_port_a_sel_o = 1'b0;
                execute_port_b_sel_o = 1'b0;
                alu_op_sel_o = OP_ADD;
                comp_op_sel_o = OP_BUNKNOWN;
                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
                reg_write_data_sel_o = RD_MUX_ALU;
            end
            OP_J_TYPE:
            begin
                pc_mux_sel_o = 1'b1;
                reg_write_enable_o = 1'b1;
                imm_select_o = IMM_J_TYPE;
                execute_port_a_sel_o = 1'b0;
                execute_port_b_sel_o = 1'b0;
                alu_op_sel_o = OP_ADD;
                comp_op_sel_o = OP_BUNKNOWN;
                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
                reg_write_data_sel_o = RD_MUX_PC_N;
            end
            default:
            begin
                pc_mux_sel_o = 1'b0;
                reg_write_enable_o = 1'b0;
                imm_select_o = IMM_UNKNOWN_TYPE;
                execute_port_a_sel_o = 1'b0;
                execute_port_b_sel_o = 1'b0;
                alu_op_sel_o = OP_UNKNOWN;
                comp_op_sel_o = OP_BUNKNOWN;
                load_store_type_o = LS_N_A;
                data_memory_write_enable_o = 1'b0;
                reg_write_data_sel_o = RD_MUX_N_A;
            end
        endcase

    end
endmodule
