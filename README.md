# Organização de Computadores

Projeto da disciplina de Organização de Computadores (DIMAp/UFRN): processador RISC-V (RV32I) monociclo em SystemVerilog, com as instruções `max`, `sign` e `mac` e um acelerador de 2 multiplicadores.

## Relatório

https://docs.google.com/document/d/1qvIvZlo1Wmy7WpcNyDPJ4bAcFfBk92kDYAt1HLVKzis/edit?usp=sharing

## Componentes
Raul Ramalho

Ryan Silvestre

Rômulo Alves

## Simulação



A especificação do acelerador está em `src/Accelerator2Mul.sv`, os resultados registrados estão em `sim/resultados/` e o diagrama de blocos está em `docs/diagrama_blocos.svg`.

O acelerador é usado por três instruções do tipo R (opcode `0110011`, funct7 `0100000`):

| Instrução | funct3 | Operação |
|---|---|---|
| `mac2 rs1, rs2` | `010` | `acc += rs1*rs2 + (rs1+1)*(rs2+1)` |
| `macr rd` | `011` | `rd = acc[31:0]` |
| `macz` | `111` | `acc = 0` |

## O que foi feito:

### Entregáveis

- [x] **1. Código SystemVerilog do acelerador de 2 multiplicadores**
  - [x] Definir a especificação do acelerador
  - [x] Implementar o módulo
- [x] **2. Testbenches e resultados de simulação**
  - [x] Incluir o `top.sv` e os arquivos `R_type.txt` e `Data_Memory_Load.txt`
  - [x] Validar `max`, `sign` e `mac` por simulação
  - [x] Criar o testbench do acelerador
  - [x] Registrar os resultados de simulação
- [x] **3. Diagrama de blocos da arquitetura**
- [x] **4. Código do processador RISC-V com o acelerador integrado**
  - [x] Adicionar `max`, `sign` e `mac` ao processador monociclo
  - [x] Integrar o acelerador ao processador
- [x] **5. Programa de teste demonstrando a execução da operação**
- [ ] **6. Relatório técnico com decisões arquiteturais e resultados**
  - [x] Documentar a codificação e as mudanças no controle e no caminho de dados de `max`, `sign` e `mac`
  - [ ] Documentar o acelerador
  - [ ] Incluir a validação e a avaliação de métricas

### Repositório

- [x] Adicionar o código do processador
- [ ] Adicionar o relatório
