/***************************************************************************
* Copyright (c) 2022 Hariesh Anbalagan
* SPDX-License-Identifier: GPL-3.0-only
* 
* Module: ArithmeticLogicUnit.sv
*
* Description:
* This does computation over the data related to arithmetic and logic
* instructions. This does not holds the comparison which is done by
* ComparatorUnit.
***************************************************************************/

// ==============================================================================
// MÓDULO: ArithmeticLogicUnit (ALU / ULA)
// ==============================================================================
// Este módulo é o coração aritmético e lógico do caminho de dados (Datapath).
// Ele é puramente combinacional ('always_comb') e executa a operação indicada
// pelo sinal 'alu_op_sel_i' sobre as duas entradas:
//   - alu_port_a_i: primeiro operando (vem de rs1 ou do PC)
//   - alu_port_b_i: segundo operando (vem de rs2 ou do imediato)
//
// NOTA ARQUITETURAL:
// Comparações de branch e instruções 'slt' não são feitas aqui; elas ficam
// separadas no módulo 'ComparatorUnit.sv' para economizar somadores e permitir
// calcular o salto e a comparação simultaneamente.
//
// ---> COMO ADICIONAR UMA NOVA OPERAÇÃO NA ALU: <---
// 1. Declare o nome do identificador em 'risc_v_32_i_pkg.sv' (ex: OP_NOT, OP_ABS).
// 2. Adicione uma nova cláusula no 'unique case' abaixo com a fórmula da operação.
// ==============================================================================

import risc_v_32_i_pkg::*;

module ArithmeticLogicUnit #(parameter XLEN = 32, parameter REG_ADDR_WIDTH = 5)
(
    output logic        [XLEN-1:0]  alu_o,         // Saída: resultado do cálculo (32 bits)
    input  logic        [XLEN-1:0]  alu_port_a_i,  // Entrada A: primeiro operando (32 bits)
    input  logic        [XLEN-1:0]  alu_port_b_i,  // Entrada B: segundo operando (32 bits)
    input  logic        [XLEN-1:0]  alu_port_c_i,  // Entrada C: terceiro operando (32 bits)
    input  alu_select_e             alu_op_sel_i   // Entrada de controle: qual operação realizar
);

    always_comb
    begin
        unique case(alu_op_sel_i)
            // Operações Aritméticas Básicas:
            OP_ADD:     alu_o =         alu_port_a_i  +   alu_port_b_i;  // Soma
            OP_SUB:     alu_o =         alu_port_a_i  -   alu_port_b_i;  // Subtração

            // Operações Lógicas Bit a Bit:
            OP_AND:     alu_o =         alu_port_a_i  &   alu_port_b_i;  // AND
            OP_OR:      alu_o =         alu_port_a_i  |   alu_port_b_i;  // OR
            OP_XOR:     alu_o =         alu_port_a_i  ^   alu_port_b_i;  // XOR

            // Operações de Deslocamento (Shift):
            // Em RV32I, apenas os 5 bits menos significativos de B definem o deslocamento (0 a 31 bits).
            OP_SLL:     alu_o =         alu_port_a_i  <<  alu_port_b_i[REG_ADDR_WIDTH-1:0];  // Shift Left Lógico
            OP_SRL:     alu_o =         alu_port_a_i  >>  alu_port_b_i[REG_ADDR_WIDTH-1:0];  // Shift Right Lógico (preenche com 0)
            OP_SRA:     alu_o = $signed(alu_port_a_i) >>> alu_port_b_i[REG_ADDR_WIDTH-1:0];  // Shift Right Aritmético (mantém o bit de sinal)
    
            // Operações Especiais:
            OP_MAX:  alu_o = ($signed(alu_port_a_i) > $signed(alu_port_b_i)) ? alu_port_a_i : alu_port_b_i;
            OP_SIGN: alu_o = ($signed(alu_port_a_i) > 0) ? 32'sd1 : (($signed(alu_port_a_i) < 0) ? -32'sd1 : 32'sd0);
            OP_MAC:  alu_o = alu_port_c_i + (alu_port_a_i * alu_port_b_i);

            // Caso padrão / Operação não suportada:
            OP_UNKNOWN: alu_o = {XLEN{1'b0}}; // Retorna zero
        endcase
    end

endmodule
