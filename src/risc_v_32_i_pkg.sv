/***************************************************************************
* Copyright (c) 2022 Hariesh Anbalagan
* SPDX-License-Identifier: GPL-3.0-only
* 
* Package: risc_v_32_i_pkg.sv
*
* Description:
* Contains the parameters and enums required.
***************************************************************************/

// ==============================================================================
// PACOTE GLOBAL: risc_v_32_i_pkg
// ==============================================================================
// Este pacote funciona como o "dicionário" de todo o processador. Em vez de usar
// códigos binários fixos (números mágicos) espalhados pelos módulos, usamos
// constantes e enums com nomes legíveis.
//
// Para adicionar uma nova instrução:
// 1. Se a instrução fizer uma operação aritmética/lógica inédita, declare um
//    novo identificador em 'alu_select_e' (ex: OP_NOT, OP_MUL, etc.).
// 2. Se ela exigir uma nova forma de comparação ou desvio, adicione em 'comp_select_e'.
// 3. Se ela escrever no registrador 'rd' a partir de uma fonte nova (não prevista),
//    adicione uma opção em 'write_data_select_e'.
// ==============================================================================

package risc_v_32_i_pkg;

// ------------------------------------------------------------------------------
// Parâmetros Básicos da Arquitetura RISC-V 32-bit (RV32I)
// ------------------------------------------------------------------------------
parameter XLEN = 32;            // Tamanho da palavra em bits (dados e endereços = 32 bits)
parameter REG_ADDR_WIDTH = 5;   // Largura do endereço do banco de registradores (2^5 = 32 registradores: x0-x31)

// ------------------------------------------------------------------------------
// Formatos de Imediato (imm_select_e)
// Indica para o ImmediateSignExtend como decodificar e reorganizar os bits do imediato.
// ------------------------------------------------------------------------------
parameter IMM_SEL_LEN = 3;

typedef enum logic[IMM_SEL_LEN-1:0] {
    IMM_B_TYPE,         // Formato B: Desvios condicionais (beq, bne, blt, etc.)
    IMM_S_TYPE,         // Formato S: Armazenamento em memória (sw, sh, sb)
    IMM_U_TYPE,         // Formato U: Imediatos superiores de 20 bits (lui, auipc)
    IMM_I_TYPE,         // Formato I: Operações imediatas e loads (addi, lw, jalr, etc.)
    IMM_J_TYPE,         // Formato J: Salto incondicional longo (jal)
    IMM_UNKNOWN_TYPE    // Nenhum imediato (usado em instruções Tipo R)
} imm_select_e;

// ------------------------------------------------------------------------------
// Operações da ALU (alu_select_e)
// Informa à ArithmeticLogicUnit qual operação matemática/lógica executar.
// ---> SE CRIAR UMA NOVA OPERAÇÃO NA ALU, ADICIONE SEU ENUM AQUI! <---
// ------------------------------------------------------------------------------
parameter ALU_SEL_LEN = 4;

typedef enum logic [ALU_SEL_LEN-1:0] {
    OP_ADD,             // Soma: A + B
    OP_SUB,             // Subtração: A - B
    OP_AND,             // E lógico bit a bit: A & B
    OP_OR,              // OU lógico bit a bit: A | B
    OP_XOR,             // OU exclusivo bit a bit: A ^ B
    OP_SLL,             // Deslocamento para esquerda lógico: A << B[4:0]
    OP_SRL,             // Deslocamento para direita lógico: A >> B[4:0]
    OP_SRA,             // Deslocamento para direita aritmético (com sinal): A >>> B[4:0]
    OP_MAX,             // Operação de máximo: retorna o maior entre A e B
    OP_SIGN,            // Operação de sinal
    OP_MAC,              // Acumulador de multiplicação: A + (B * C) 
    OP_UNKNOWN         // Operação desconhecida  -- > ryan esteve aqui muahahaha
} alu_select_e;

// ------------------------------------------------------------------------------
// Operações do Comparador (comp_select_e)
// Informa ao ComparatorUnit qual comparação efetuar para branch ou instruções slt.
// ------------------------------------------------------------------------------
parameter BRANCH_SEL_LEN = 3;

typedef enum logic [BRANCH_SEL_LEN-1:0] {
    OP_BEQ,             // Branch se igual: A == B
    OP_BNE,             // Branch se diferente: A != B
    OP_BLT,             // Branch se menor com sinal: $signed(A) < $signed(B)
    OP_BGE,             // Branch se maior ou igual com sinal: $signed(A) >= $signed(B)
    OP_BLTU,            // Branch se menor sem sinal: A < B
    OP_BGEU,            // Branch se maior ou igual sem sinal: A >= B
    OP_BUNKNOWN         // Nenhuma comparação
} comp_select_e;

// ------------------------------------------------------------------------------
// Seletor de Escrita no Banco de Registradores (write_data_select_e)
// Controla o multiplexador final que escolhe qual dado será gravado em rd.
// ------------------------------------------------------------------------------
parameter RD_MUX_SEL_LEN = 3;

typedef enum logic [RD_MUX_SEL_LEN-1:0] {
    RD_MUX_DMEM,        // Escreve o dado lido da memória RAM (instruções de Load: lw, lh, etc.)
    RD_MUX_ALU,         // Escreve o resultado da ALU (add, sub, addi, and, etc.)
    RD_MUX_BCU,         // Escreve o resultado do comparador (slt, slti, etc. gerando 0 ou 1)
    RD_MUX_IMM,         // Escreve diretamente o valor imediato (instrução lui)
    RD_MUX_PC_N,        // Escreve PC + 4 (instruções de salto com link: jal, jalr)
    RD_MUX_ACC,         // Escreve o resultado do acelerador (instrução macr)
    RD_MUX_N_A          // Não aplicável / instrução não grava em registrador (ex: sw, beq)
} write_data_select_e;

// ------------------------------------------------------------------------------
// Tipo de Operação de Memória (load_store_type_e)
// Informa ao LoadStoreUnit a largura e sinalização do dado acessado na memória.
// ------------------------------------------------------------------------------
parameter LOAD_STORE_TYPE_LEN = 4;

typedef enum logic [LOAD_STORE_TYPE_LEN-1:0]
{
    L_W,                // Load Word (32 bits)
    L_H,                // Load Halfword com sinal (16 bits)
    L_HU,               // Load Halfword sem sinal (16 bits)
    L_B,                // Load Byte com sinal (8 bits)
    L_BU,               // Load Byte sem sinal (8 bits)
    S_W,                // Store Word (32 bits)
    S_H,                // Store Halfword (16 bits)
    S_B,                // Store Byte (8 bits)
    LS_N_A              // Não é operação de Load nem Store
} load_store_type_e;

endpackage
