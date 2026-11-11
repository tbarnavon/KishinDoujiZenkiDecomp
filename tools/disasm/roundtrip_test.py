#!/usr/bin/env python3
"""Test aller-retour du decodeur : toutes les instructions -> sdasz80 -> octets.

Usage : python tools/disasm/roundtrip_test.py <dossier_temp>
Affiche les encodages qui ne se reassemblent pas a l'identique alors que le
decodeur les declare `valid`, et inversement.
"""
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(__file__))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from z80 import decode  # noqa: E402
from toolchain import SDAS, SDLD  # noqa: E402
from ihx import read_ihx  # noqa: E402

ORG = 0x1000


def candidates():
    """Toutes les sequences d'opcodes (operandes fixes 0x34 0x12 / disp 0x05)."""
    tail = [0x34, 0x12, 0x56]
    for a in range(256):
        if a in (0xCB, 0xED, 0xDD, 0xFD):
            continue
        yield bytes([a] + tail)
    for b in range(256):
        yield bytes([0xCB, b] + tail)
        yield bytes([0xED, b] + tail)
        for px in (0xDD, 0xFD):
            if b == 0xCB:
                for c in range(256):
                    yield bytes([px, 0xCB, 0x05, c])
            elif b not in (0xDD, 0xFD, 0xED):
                yield bytes([px, b, 0x05, 0x34, 0x12])


def main():
    tmp = sys.argv[1]
    os.makedirs(tmp, exist_ok=True)
    lines = [".area TEST (ABS)", f".org 0x{ORG:04x}"]
    expect = bytearray()
    items = []
    pc = ORG
    for seq in candidates():
        ins = decode(lambda a, s=seq, base=pc: s[a - base] if 0 <= a - base < len(s) else 0, pc)
        if not ins.valid:
            continue
        b = seq[:ins.size]
        t = ins.text.replace("{W}", "0x%04x" % ins.word if ins.word is not None else "")
        if ins.target is not None:
            t = t.replace("{J}", "0x%04x" % ins.target)
        lines.append(f"\t{t}")
        items.append((pc, b, t))
        expect += b
        pc += ins.size
    src = os.path.join(tmp, "rt.s")
    open(src, "w").write("\n".join(lines) + "\n")
    r = subprocess.run([SDAS, "-plosgff", os.path.join(tmp, "rt.rel"), src], capture_output=True, text=True)
    if r.returncode:
        print(r.stdout, r.stderr)
        errs = [l for l in (r.stdout + r.stderr).splitlines() if "rt.s:" in l]
        for e in errs[:40]:
            ln = int(e.split("rt.s:")[1].split(":")[0])
            print(e, "->", lines[ln - 1])
        return 1
    r = subprocess.run([SDLD, "-i", os.path.join(tmp, "rt.ihx"), os.path.join(tmp, "rt.rel")],
                       capture_output=True, text=True)
    mem = read_ihx(os.path.join(tmp, "rt.ihx"))
    bad = 0
    for pc, b, t in items:
        got = bytes(mem.get(pc + i, -1) & 0xFF for i in range(len(b)))
        if got != b:
            bad += 1
            if bad <= 60:
                print(f"DIFF {pc:04x} {b.hex(' '):15s} -> {got.hex(' '):15s} {t}")
    print(f"{len(items)} instructions testees, {bad} differences")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
