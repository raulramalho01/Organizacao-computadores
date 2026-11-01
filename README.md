# Organização de Computadores

Projeto da disciplina de Organização de Computadores (DIMAp/UFRN): processador RISC-V (RV32I) monociclo em SystemVerilog, com as instruções `max`, `sign` e `mac` e um acelerador de 2 multiplicadores.

## O que falta fazer

### Entregáveis

- [ ] **1. Código SystemVerilog do acelerador de 2 multiplicadores**
  - [ ] Definir a especificação do acelerador
  - [ ] Implementar o módulo
- [ ] **2. Testbenches e resultados de simulação**
  - [ ] Incluir o `top.sv` e os arquivos `R_type.txt` e `Data_Memory_Load.txt`
  - [ ] Validar `max`, `sign` e `mac` por simulação
  - [ ] Criar o testbench do acelerador
  - [ ] Registrar os resultados de simulação
- [ ] **3. Diagrama de blocos da arquitetura**
- [ ] **4. Código do processador RISC-V com o acelerador integrado**
  - [x] Adicionar `max`, `sign` e `mac` ao processador monociclo
  - [ ] Integrar o acelerador ao processador
- [ ] **5. Programa de teste demonstrando a execução da operação**
- [ ] **6. Relatório técnico com decisões arquiteturais e resultados**
  - [x] Documentar a codificação e as mudanças no controle e no caminho de dados de `max`, `sign` e `mac`
  - [ ] Documentar o acelerador
  - [ ] Incluir a validação e a avaliação de métricas

### Repositório

- [ ] Adicionar o código do processador
- [ ] Adicionar o relatório
