FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    make \
    git \
    iverilog \
    gtkwave \
    verilator \
    python3 \
    python3-pip \
    gcc-riscv64-unknown-elf \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
