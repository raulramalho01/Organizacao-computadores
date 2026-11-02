#!/usr/bin/env python3
"""Gera R_type.txt: o programa original do kit mais os testes de max, sign e mac.

Uso: python3 gen_programa.py   (dentro da pasta sim/)

A codificacao de max, sign e mac segue a tabela do relatorio:
opcode 0110011, funct7 0100000 e funct3 110 (max), 100 (sign), 001 (mac).
"""


def r_type(funct7, rs2, rs1, funct3, rd):
    return funct7 << 25 | rs2 << 20 | rs1 << 15 | funct3 << 12 | rd << 7 | 0b0110011


def i_type(imm, rs1, funct3, rd, opcode):
    return (imm & 0xFFF) << 20 | rs1 << 15 | funct3 << 12 | rd << 7 | opcode


def s_type(imm, rs2, rs1, funct3):
    return ((imm >> 5) & 0x7F) << 25 | rs2 << 20 | rs1 << 15 | funct3 << 12 | (imm & 0x1F) << 7 | 0b0100011


def lw(rd, imm, rs1=0):
    return i_type(imm, rs1, 0b010, rd, 0b0000011)


def sw(rs2, imm, rs1=0):
    return s_type(imm, rs2, rs1, 0b010)


def addi(rd, rs1, imm):
    return i_type(imm, rs1, 0b000, rd, 0b0010011)


def max_(rd, rs1, rs2):
    return r_type(0b0100000, rs2, rs1, 0b110, rd)


def sign(rd, rs1):
    return r_type(0b0100000, 0, rs1, 0b100, rd)


def mac(rd, rs1, rs2):
    return r_type(0b0100000, rs2, rs1, 0b001, rd)


def or_(rd, rs1, rs2):
    return r_type(0, rs2, rs1, 0b110, rd)


def xor(rd, rs1, rs2):
    return r_type(0, rs2, rs1, 0b100, rd)


def sll(rd, rs1, rs2):
    return r_type(0, rs2, rs1, 0b001, rd)


HALT = 0x0000006F  # jal x0, 0

# Programa original da disciplina (R_type.txt do kit), mantido sem alteracao.
ORIGINAL = """00500093 00c00113 002081b3 40208233 002092b3 0020a333
0020b3b3 0020c433 0020d4b3 4020d533 0020e5b3 0020f633""".split()

# Testes novos. O original deixa x1 = 5. Cada 'add' depois de um 'mac' guarda o
# valor intermediario, porque o top.sv so confere o estado final.
# Na DataMemory o endereco e o proprio indice da palavra.
NOVOS = [
    (addi(13, 0, 7), "addi x13, x0, 7"),
    (addi(14, 0, -3), "addi x14, x0, -3"),
    (addi(16, 0, -10), "addi x16, x0, -10"),
    (max_(17, 13, 14), "max  x17, x13, x14   positivo x negativo: 7 (sem sinal daria -3)"),
    (max_(18, 14, 13), "max  x18, x14, x13   ordem invertida: 7"),
    (max_(19, 14, 16), "max  x19, x14, x16   dois negativos: -3"),
    (max_(20, 13, 13), "max  x20, x13, x13   iguais: 7"),
    (sign(21, 13), "sign x21, x13        positivo: 1"),
    (sign(22, 14), "sign x22, x14        negativo: -1"),
    (sign(23, 0), "sign x23, x0         zero: 0"),
    (addi(24, 0, 10), "addi x24, x0, 10"),
    (mac(24, 13, 1), "mac  x24, x13, x1    10 + 7*5 = 45"),
    (r_type(0, 0, 24, 0, 25), "add  x25, x24, x0    guarda 45"),
    (mac(24, 14, 1), "mac  x24, x14, x1    45 + (-3)*5 = 30"),
    (r_type(0, 0, 24, 0, 26), "add  x26, x24, x0    guarda 30"),
    (mac(24, 14, 14), "mac  x24, x14, x14   30 + (-3)*(-3) = 39"),
    (addi(27, 0, 3), "addi x27, x0, 3"),
    (mac(27, 27, 27), "mac  x27, x27, x27   rd = rs1 = rs2: 3 + 3*3 = 12"),
    (mac(0, 13, 13), "mac  x0, x13, x13    x0 continua 0"),
    (or_(28, 13, 1), "or   x28, x13, x1    mesmo funct3 do max: 7"),
    (xor(29, 13, 1), "xor  x29, x13, x1    mesmo funct3 do sign: 2"),
    (sll(30, 1, 1), "sll  x30, x1, x1     mesmo funct3 do mac: 160"),
    (lw(31, 63), "lw   x31, 63(x0)     ultima palavra da memoria: ffffffff"),
    (sw(24, 40), "sw   x24, 40(x0)     fim do teste (COMPLETE do expected)"),
    (HALT, "jal  x0, 0           fim do programa"),
]

with open("R_type.txt", "w", encoding="ascii") as saida:
    for palavra in ORIGINAL:
        saida.write(f"{palavra} // programa original\n")
    for palavra, comentario in NOVOS:
        saida.write(f"{palavra:08x} // {comentario}\n")
