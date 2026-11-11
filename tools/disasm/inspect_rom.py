#!/usr/bin/env python3
"""Inspection rapide : desassemblage lineaire autour d'une adresse, ou dump de table.

Usage :
  python tools/disasm/inspect_rom.py <rom> dis  <bank> <cpu_addr> [n_lignes]
  python tools/disasm/inspect_rom.py <rom> words <bank> <cpu_addr> [n_mots]
  python tools/disasm/inspect_rom.py <rom> hex  <bank> <cpu_addr> [n_octets]
"""
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from z80 import decode  # noqa: E402


def main():
    rom = open(sys.argv[1], "rb").read()
    mode, bank, cpu = sys.argv[2], int(sys.argv[3], 0), int(sys.argv[4], 0)
    n = int(sys.argv[5], 0) if len(sys.argv) > 5 else 32
    base = bank * 0x4000 - (cpu & 0xC000)

    def rd(a):
        return rom[(base + a) % len(rom)]

    if mode == "dis":
        pc = cpu
        for _ in range(n):
            ins = decode(rd, pc)
            t = ins.text
            if ins.word is not None:
                t = t.replace("{W}", "0x%04x" % ins.word)
            if ins.target is not None:
                t = t.replace("{J}", "0x%04x" % ins.target)
            flag = "" if ins.valid else "   ; NON CANONIQUE"
            print(f"  {pc:04X}  {ins.raw.hex(' '):14s} {t}{flag}")
            pc = (pc + ins.size) & 0xFFFF
    elif mode == "words":
        for i in range(n):
            a = cpu + 2 * i
            print(f"  {a:04X}  ${rd(a) | (rd(a + 1) << 8):04X}")
    else:
        for i in range(0, n, 16):
            print(f"  {cpu + i:04X}  " + " ".join("%02x" % rd(cpu + i + j) for j in range(min(16, n - i))))


if __name__ == "__main__":
    main()
