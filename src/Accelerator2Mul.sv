/***************************************************************************
* Module: Accelerator2Mul.sv
*
* Description:
* Acelerador de produto escalar com 2 multiplicadores em paralelo.
***************************************************************************/

// ==============================================================================
// MÓDULO: Accelerator2Mul
// ==============================================================================
// Calcula, em um ciclo por par de amostras, a soma acumulada:
//
//     acc = acc + (a0 * b0) + (a1 * b1)
//
// É o mesmo cálculo da instrução 'mac', mas com dois multiplicadores trabalhando
// ao mesmo tempo: um produto escalar de N elementos leva N/2 ciclos, em vez dos
// N ciclos que uma sequência de 'mac' levaria no core monociclo.
//
// ESPECIFICAÇÃO:
//   - Operandos com sinal, em complemento de dois, de XLEN bits.
//   - Acumulador de 2*XLEN bits, para reduzir o risco de overflow. Em caso de
//     overflow, o valor dá a volta (wrap-around): não há saturação.
//   - Resultado disponível no ciclo seguinte ao da entrada (latência de 1 ciclo).
//   - Aceita um novo par de amostras a cada ciclo (vazão de 2 produtos/ciclo).
//   - O valor truncado para XLEN bits sai em 'result_o', para caber em um
//     registrador do RV32I. O valor completo sai em 'acc_o'.
//
// CONTROLE (prioridade: reset_i > clear_i > valid_i):
//   - reset_i : assíncrono, zera o acumulador e 'done_o'.
//   - clear_i : síncrono, zera o acumulador. Se 'valid_i' estiver ativo no mesmo
//               ciclo, as amostras daquele ciclo são descartadas.
//   - valid_i : indica amostras válidas. Sem ele, o acumulador mantém o valor.
//   - done_o  : vale 1 no ciclo seguinte a uma acumulação.
//   - pair_i  : 1 = usa os dois multiplicadores; 0 = usa só (a0 * b0). Serve para
//               o último elemento de um vetor com tamanho ímpar.
// ==============================================================================

module Accelerator2Mul #(parameter XLEN = 32)
(
    input  logic                clk_i,
    input  logic                reset_i,
    input  logic                clear_i,
    input  logic                valid_i,
    input  logic                pair_i,
    input  logic [XLEN-1:0]     a0_i,
    input  logic [XLEN-1:0]     b0_i,
    input  logic [XLEN-1:0]     a1_i,
    input  logic [XLEN-1:0]     b1_i,
    output logic [2*XLEN-1:0]   acc_o,
    output logic [XLEN-1:0]     result_o,
    output logic                done_o
);

    logic signed [2*XLEN-1:0] product_0;
    logic signed [2*XLEN-1:0] product_1;
    logic signed [2*XLEN-1:0] acc;

    // Os dois multiplicadores. A extensão de sinal explícita garante que a
    // multiplicação seja feita em 2*XLEN bits, sem perder a parte alta.
    assign product_0 = $signed({{XLEN{a0_i[XLEN-1]}}, a0_i}) * $signed({{XLEN{b0_i[XLEN-1]}}, b0_i});
    assign product_1 = pair_i
                     ? $signed({{XLEN{a1_i[XLEN-1]}}, a1_i}) * $signed({{XLEN{b1_i[XLEN-1]}}, b1_i})
                     : '0;

    always_ff @(posedge clk_i, posedge reset_i)
    begin
        if (reset_i)
        begin
            acc    <= '0;
            done_o <= 1'b0;
        end
        else if (clear_i)
        begin
            acc    <= '0;
            done_o <= 1'b0;
        end
        else
        begin
            done_o <= valid_i;
            if (valid_i)
            begin
                acc <= acc + product_0 + product_1;
            end
        end
    end

    assign acc_o    = acc;
    assign result_o = acc[XLEN-1:0];

endmodule
