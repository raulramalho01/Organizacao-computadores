# Organização de Computadores

Projeto da disciplina de Organização de Computadores (DIMAp/UFRN): processador RISC-V (RV32I) monociclo em SystemVerilog, com as instruções `max`, `sign` e `mac`.

## Relatório

https://docs.google.com/document/d/1qvIvZlo1Wmy7WpcNyDPJ4bAcFfBk92kDYAt1HLVKzis/edit?usp=sharing

## Componentes
Raul Ramalho

Ryan Silvestre

Rômulo Alves

## Simulação

As instruções personalizadas do tipo R (opcode `0110011`, funct7 `0100000`) implementadas no processador:

| Instrução | funct3 | Operação |
|---|---|---|
| `max rd, rs1, rs2` | `110` | `rd = (rs1 > rs2) ? rs1 : rs2` (com sinal) |
| `sign rd, rs1` | `100` | `rd = (rs1 > 0) ? 1 : (rs1 < 0) ? -1 : 0` |
| `mac rd, rs1, rs2` | `001` | `rd = rd + (rs1 * rs2)` |

## O que foi feito:

### Entregáveis

- [x] **1. Testbenches e resultados de simulação**
  - [x] Incluir o `top.sv` e os arquivos `R_type.txt` e `Data_Memory_Load.txt`
  - [x] Validar `max`, `sign` e `mac` por simulação
- [x] **2. Código do processador RISC-V com as novas instruções**
  - [x] Adicionar `max`, `sign` e `mac` ao processador monociclo
- [x] **3. Programa de teste demonstrando a execução das operações**
- [x] **4. Relatório técnico com decisões arquiteturais e resultados**
  - [x] Documentar a codificação e as mudanças no controle e no caminho de dados de `max`, `sign` e `mac`

### Repositório

- [x] Adicionar o código do processador
- [ ] Adicionar o relatório
