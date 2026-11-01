/***************************************************************************
* Copyright (c) 2022 Hariesh Anbalagan
* SPDX-License-Identifier: GPL-3.0-only
* 
* Module: RegisterFile.sv
*
* Description:
*
* This holds the architectural register file, which contains the registers
* associated with processor to store data
***************************************************************************/

// meu maior desafio aqui vai ser descobrir onde isso aqui é implementado

module RegisterFile #(parameter XLEN = 32, parameter REG_ADDR_WIDTH = 5)
(
    output logic [XLEN-1:0]             read_data_1_o, // transporte de valores lidos
    output logic [XLEN-1:0]             read_data_2_o, 
    input  logic                        clk_i,
    input  logic                        write_enable_i, // permissao de escrita
    input  logic [XLEN-1:0]             write_data_i, // valor que vai ser armezenado
    input  logic [REG_ADDR_WIDTH-1:0]   write_address_i, // registrador de destino
    input  logic [REG_ADDR_WIDTH-1:0]   read_address_1_i, // operando de entrada 1
    input  logic [REG_ADDR_WIDTH-1:0]   read_address_2_i,  // operando de entrada 2
    // adicionadas
    input logic [REG_ADDR_WIDTH-1:0]   read_address_3_i, // operando de entrada 3 (para o MAC)
    output logic [XLEN-1:0]             read_data_3_o,  // transporte de valores lidos do registrador 3
    // portas do acelerador (segundo elemento dos pares da instrução mac2)
    input logic [REG_ADDR_WIDTH-1:0]   read_address_4_i, // rs1 + 1
    output logic [XLEN-1:0]             read_data_4_o,
    input logic [REG_ADDR_WIDTH-1:0]   read_address_5_i, // rs2 + 1
    output logic [XLEN-1:0]             read_data_5_o
);

    logic [XLEN-1:0]register [XLEN-1:0]; 

    always_comb
    begin
        assign read_data_1_o = (read_address_1_i == 0) ? 0 : register[read_address_1_i];
        assign read_data_2_o = (read_address_2_i == 0) ? 0 : register[read_address_2_i];
        assign read_data_3_o = (read_address_3_i == 0) ? 0 : register[read_address_3_i]; // pro terceiro registrador dnv (ryab tb mexeu aq)
        assign read_data_4_o = (read_address_4_i == 0) ? 0 : register[read_address_4_i];
        assign read_data_5_o = (read_address_5_i == 0) ? 0 : register[read_address_5_i];
    end

    always_ff @(negedge clk_i)
    begin
        if (write_enable_i == 1 && write_address_i != 0)
        begin
            register[write_address_i] <= write_data_i;
        end
    end

endmodule
