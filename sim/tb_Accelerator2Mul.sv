// ==============================================================================
// TESTBENCH: tb_Accelerator2Mul
// ==============================================================================
// Testa o Accelerator2Mul sozinho: casos dirigidos (sinais, limites, controle) e
// casos aleatórios comparados com um modelo de referência em 64 bits.
// Termina com "RESULTADO: PASS" ou "RESULTADO: FAIL".
// ==============================================================================

`timescale 1ns/1ps

module tb_Accelerator2Mul;

    localparam int XLEN = 32;
    localparam int N_RANDOM = 1000;

    logic               clk = 1'b0;
    logic               reset = 1'b0;
    logic               clear = 1'b0;
    logic               valid = 1'b0;
    logic               pair = 1'b1;
    logic [XLEN-1:0]    a0 = '0, b0 = '0, a1 = '0, b1 = '0;
    logic [2*XLEN-1:0]  acc;
    logic [XLEN-1:0]    result;
    logic               done;

    longint model = 0;   // modelo de referência do acumulador
    int checks = 0;
    int errors = 0;

    Accelerator2Mul #(.XLEN(XLEN)) dut
    (
        .clk_i(clk), .reset_i(reset), .clear_i(clear), .valid_i(valid), .pair_i(pair),
        .a0_i(a0), .b0_i(b0), .a1_i(a1), .b1_i(b1),
        .acc_o(acc), .result_o(result), .done_o(done)
    );

    always #5 clk = ~clk;

    function automatic longint sx(input logic [XLEN-1:0] v);
        return longint'($signed(v));
    endfunction

    task automatic check(input string name, input logic expected_done);
        checks++;
        if (acc !== 64'(model) || result !== model[31:0] || done !== expected_done)
        begin
            errors++;
            $display("  ERRO %s: acc=%0d esperado=%0d result=%h done=%b esperado=%b",
                     name, $signed(acc), model, result, done, expected_done);
        end
    endtask

    // Aplica uma entrada por um ciclo e confere a saída logo após a borda.
    task automatic step(input string name, input logic v, input logic p, input logic c,
                        input logic [XLEN-1:0] x0, input logic [XLEN-1:0] y0,
                        input logic [XLEN-1:0] x1, input logic [XLEN-1:0] y1);
        @(negedge clk);
        valid = v; pair = p; clear = c; a0 = x0; b0 = y0; a1 = x1; b1 = y1;
        if (c)      model = 0;
        else if (v) model = model + sx(x0) * sx(y0) + (p ? sx(x1) * sx(y1) : 64'd0);
        @(posedge clk);
        #1;
        check(name, v && !c);
    endtask

    task automatic sample(input string name, input logic [XLEN-1:0] x0, input logic [XLEN-1:0] y0,
                          input logic [XLEN-1:0] x1, input logic [XLEN-1:0] y1);
        step(name, 1'b1, 1'b1, 1'b0, x0, y0, x1, y1);
    endtask

    initial
    begin
        // Reset assíncrono: precisa zerar antes da primeira borda do clock.
        #1;
        reset = 1'b1;
        #1;
        check("reset", 1'b0);
        @(negedge clk);
        reset = 1'b0;

        // Casos dirigidos
        sample("positivos",     32'd3,  32'd4,  32'd5,  32'd6);             // 12 + 30
        sample("negativos",    -32'd3,  32'd4,  32'd5, -32'd6);
        sample("neg x neg",    -32'd7, -32'd8, -32'd1, -32'd1);
        sample("por zero",      32'd0,  32'd9,  32'd9,  32'd0);
        sample("INT_MIN^2",  32'h8000_0000, 32'h8000_0000, 32'd0, 32'd0);   // estoura 32 bits
        sample("INT_MAX^2",  32'h7FFF_FFFF, 32'h7FFF_FFFF, 32'h7FFF_FFFF, 32'h7FFF_FFFF);

        // Controle
        step("sem valid",    1'b0, 1'b1, 1'b0, 32'd9, 32'd9, 32'd9, 32'd9); // mantém
        step("pair=0",       1'b1, 1'b0, 1'b0, 32'd2, 32'd3, 32'd100, 32'd100); // ignora a1*b1
        step("clear",        1'b0, 1'b1, 1'b1, 32'd0, 32'd0, 32'd0, 32'd0);
        sample("apos clear",    32'd2,  32'd2,  32'd2,  32'd2);
        step("clear+valid",  1'b1, 1'b1, 1'b1, 32'd9, 32'd9, 32'd9, 32'd9); // clear vence

        // Produto escalar de 4 elementos: [1,2,3,4] . [5,6,7,8] = 70, em 2 ciclos
        sample("dot p1",        32'd1,  32'd5,  32'd2,  32'd6);
        sample("dot p2",        32'd3,  32'd7,  32'd4,  32'd8);
        checks++;
        if (result !== 32'd70)
        begin
            errors++;
            $display("  ERRO dot: result=%0d esperado=70", result);
        end
        step("limpa",        1'b0, 1'b1, 1'b1, 32'd0, 32'd0, 32'd0, 32'd0);

        // Reset no meio de uma acumulação
        sample("pre reset",     32'd10, 32'd10, 32'd10, 32'd10);
        reset = 1'b1;
        model = 0;
        #1;
        check("reset assincrono", 1'b0);
        @(negedge clk);
        valid = 1'b0;
        reset = 1'b0;

        // Casos aleatórios
        repeat (N_RANDOM)
        begin
            step("aleatorio", $urandom_range(0, 9) != 0, $urandom_range(0, 3) != 0,
                 $urandom_range(0, 49) == 0, $urandom, $urandom, $urandom, $urandom);
        end

        $display("tb_Accelerator2Mul: %0d verificacoes, %0d erros", checks, errors);
        if (errors == 0) $display("RESULTADO: PASS");
        else             $display("RESULTADO: FAIL");
        $finish;
    end

    initial
    begin
        $dumpfile("tb_Accelerator2Mul.vcd");
        $dumpvars(0, tb_Accelerator2Mul);
    end

endmodule
