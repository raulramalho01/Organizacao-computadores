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


module RegisterFile #(parameter XLEN = 32, parameter REG_ADDR_WIDTH = 5)
(
    output logic [XLEN-1:0]             read_data_1_o, // transporte de valores lidos
    output logic [XLEN-1:0]             read_data_2_o,
    output logic [XLEN-1:0]             read_data_3_o,
    output logic [XLEN-1:0]             read_data_4_o,
    output logic [XLEN-1:0]             read_data_5_o,
    input  logic                        clk_i,
    input  logic                        write_enable_i, // permissao de escrita
    input  logic [XLEN-1:0]             write_data_i, // valor que vai ser armezenado
    input  logic [REG_ADDR_WIDTH-1:0]   write_address_i, // registrador de destino
    input  logic [REG_ADDR_WIDTH-1:0]   read_address_1_i, // operando de entrada 1
    input  logic [REG_ADDR_WIDTH-1:0]   read_address_2_i,  // operando de entrada 2
    input  logic [REG_ADDR_WIDTH-1:0]   read_address_3_i, // operando de entrada 3 (para o MAC)
    input logic [REG_ADDR_WIDTH-1:0]   read_address_4_i, // rs1 + 1
    input logic [REG_ADDR_WIDTH-1:0]   read_address_5_i // rs2 + 1
);

    logic [XLEN-1:0]register [XLEN-1:0]; 

    assign read_data_1_o = (read_address_1_i == 0) ? 0 : register[read_address_1_i];
    assign read_data_2_o = (read_address_2_i == 0) ? 0 : register[read_address_2_i];
    assign read_data_3_o = (read_address_3_i == 0) ? 0 : register[read_address_3_i];
    assign read_data_4_o = (read_address_4_i == 0) ? 0 : register[read_address_4_i];
    assign read_data_5_o = (read_address_5_i == 0) ? 0 : register[read_address_5_i];

    always_ff @(negedge clk_i)
    begin
        if (write_enable_i == 1 && write_address_i != 0)
        begin
            register[write_address_i] <= write_data_i;
        end
    end

endmodule
