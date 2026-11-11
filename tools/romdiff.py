#!/usr/bin/env python3
"""Diff binaire entre deux ROMs SMS/GG.

Usage : python tools/romdiff.py <romA> <romB> [--runs N] [--bank B]

1. Resume par banque de 16 Ko : % d'octets identiques a la meme adresse.
2. Liste des plages differentes (fusionnees si separees de < 4 octets).
3. Pour chaque banque de B absente ou tres differente de A, recherche de
   blocs de A presents ailleurs (blocs identiques mais decales).
"""
import argparse

BANK = 0x4000


def diff_runs(a: bytes, b: bytes, gap: int = 4):
    n = min(len(a), len(b))
    runs, start, last = [], None, None
    for i in range(n):
        if a[i] != b[i]:
            if start is None:
                start = i
            elif i - last > gap:
                runs.append((start, last + 1))
                start = i
            last = i
    if start is not None:
        runs.append((start, last + 1))
    return runs


def locate_blocks(a: bytes, chunk: bytes, block: int = 256):
    """Pour chaque bloc de `chunk`, cherche son offset dans `a` (premiere occurrence)."""
    out = []
    for o in range(0, len(chunk), block):
        piece = chunk[o:o + block]
        if piece.count(piece[0]) == len(piece):  # bloc uniforme (FF/00) : non significatif
            out.append((o, "uniforme %02X" % piece[0]))
            continue
        pos = a.find(piece)
        out.append((o, None if pos < 0 else pos))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("a")
    ap.add_argument("b")
    ap.add_argument("--runs", type=int, default=60, help="nb max de plages affichees")
    ap.add_argument("--bank", type=int, default=None, help="details d'une banque")
    args = ap.parse_args()
    a = open(args.a, "rb").read()
    b = open(args.b, "rb").read()

    print(f"A = {args.a} ({len(a)} octets)\nB = {args.b} ({len(b)} octets)\n")
    print("banque | identique a la meme adresse | octets differents")
    nb = max(len(a), len(b)) // BANK
    for k in range(nb):
        sa, sb = a[k * BANK:(k + 1) * BANK], b[k * BANK:(k + 1) * BANK]
        if not sa or not sb:
            uni = ""
            if sb and sb.count(sb[0]) == len(sb):
                uni = f" (B uniforme {sb[0]:02X})"
            print(f"  {k:2d}   | absente de {'A' if not sa else 'B'}{uni}")
            continue
        same = sum(x == y for x, y in zip(sa, sb))
        print(f"  {k:2d}   | {100 * same / BANK:6.2f} %                     | {BANK - same}")

    runs = diff_runs(a, b)
    print(f"\n{len(runs)} plages differentes dans la zone commune :")
    for s, e in runs[:args.runs]:
        print(f"  ${s:05X}-${e - 1:05X} ({e - s} o)  A: {a[s:min(e, s + 12)].hex(' ')}  B: {b[s:min(e, s + 12)].hex(' ')}")
    if len(runs) > args.runs:
        print(f"  ... {len(runs) - args.runs} autres")

    if args.bank is not None:
        k = args.bank
        chunk = b[k * BANK:(k + 1) * BANK]
        print(f"\nBanque {k} de B : origine des blocs de 256 o dans A")
        for o, pos in locate_blocks(a, chunk):
            where = "introuvable" if pos is None else (pos if isinstance(pos, str) else f"A ${pos:05X}")
            print(f"  B ${k * BANK + o:05X} -> {where}")


if __name__ == "__main__":
    main()
