#!/usr/bin/env python3
"""Scripts de scenes (banque 5) : extraction en texte lisible et recompilation.

Usage :
  python tools/assets/scripts.py extract VERSION=sms_en   # ROM -> assets/<ver>/scripts/bank05.zs
  python tools/assets/scripts.py build   VERSION=sms_en   # .zs -> build/<ver>/generated/data_script.s
  python tools/assets/scripts.py check   VERSION=sms_en   # recompile et compare a la ROM d'origine

Syntaxe du .zs (une instruction par ligne, ';' = commentaire) :
  label:                    definit un label (adresse courante)
  music 0x12                opcode et arguments (nombres ou labels pour les sauts)
  .scenes s0, s1, 0, ...    table des scenes (mots ; 0 = scene vide)
  .dw 0x0106, label         mots bruts
  .db 0x80, 0x7d, ...       octets bruts (donnees non decodees)
Les opcodes et leurs arguments sont decrits dans tools/assets/zscript.py et docs/scripts.md.
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, ".."))
from zscript import OPS, END_FLOW, SIZES, decode_at  # noqa: E402
from toolchain import ROOT  # noqa: E402
import textcodec  # noqa: E402

BANK, BASE, NSCENES = 5, 0x8000, 43
ROMS = {"sms_en": "original/Kishin_Douji_Zenki_GG2SMS_v0_3__EN_.sms",
        "gg_jp": "original/Kishin Douji Zenki (J).gg"}
NAMES = {name: code for code, (name, _, _) in OPS.items()}


def zs_path(ver):
    return os.path.join(ROOT, "assets", ver, "scripts", "bank05.zs")


# ------------------------------------------------------------------ extraction
def extract(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    data = rom[BANK * 0x4000:(BANK + 1) * 0x4000]
    texts = textcodec.load_strings(rom, ver)
    w = lambda o: data[o] | (data[o + 1] << 8)
    scenes = [w(2 * i) for i in range(NSCENES)]
    starts, owner, labels = {}, {}, {}
    for i, p in enumerate(scenes):
        if p >= BASE:
            labels.setdefault(p, f"scene_{i:02X}")
    todo = [p for p in scenes if p >= BASE]
    while todo:
        a = todo.pop()
        while a not in starts:
            op, args, n = decode_at(data, BASE, a)
            starts[a] = (op, args, n)
            for k in range(n):
                owner[a + k] = a
            for t, v in zip(OPS[op][1], args):
                if t == "p":
                    labels.setdefault(v, f"L_{v:04X}")
                    todo.append(v)
            if op in END_FLOW:
                break
            a += n
    out = [f"; Scripts de scenes - banque 5 - version {ver}",
           "; GENERE par tools/assets/scripts.py extract, puis edite a la main.",
           "; Recompile au build (tools/assets/scripts.py build). Voir docs/scripts.md.", ""]
    out.append("; Table des scenes (index = numero de scene, 0 = aucune)")
    out.append(".scenes " + ", ".join(labels[p] if p >= BASE else "0" for p in scenes))
    a = BASE + 2 * NSCENES
    pending = []

    def flush():
        while pending:
            chunk = pending[:16]
            del pending[:16]
            out.append("\t.db " + ", ".join("0x%02x" % b for b in chunk))

    end = BASE + 0x4000
    while a < end:
        if a in labels:
            flush()
            out.append("")
            out.append(f"{labels[a]}:")
        if a in starts:
            flush()
            op, args, n = starts[a]
            name, types, _ = OPS[op]
            parts = []
            for t, v in zip(types, args):
                parts.append(labels[v] if t == "p" else (f"0x{v:02x}" if t == "b" else f"0x{v:04x}"))
            line = f"\t{name}" + (" " + ", ".join(parts) if parts else "")
            if op == 0x0A and args[1] < len(texts):
                line = f"{line:<28s}; \"{texts[args[1]]}\""
            out.append(line)
            a += n
        else:
            pending.append(data[a - BASE])
            a += 1
    flush()
    path = zs_path(ver)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")
    print(f"[{ver}] {len(starts)} instructions, {len(labels)} labels -> {os.path.relpath(path, ROOT)}")


# ------------------------------------------------------------------ compilation
def parse_num(tok, labels):
    tok = tok.strip()
    if re.fullmatch(r"-?(0x[0-9a-fA-F]+|\d+)", tok):
        return int(tok, 0)
    if tok in labels:
        return labels[tok]
    raise KeyError(tok)


def assemble(text, reloc=None):
    """Deux passes. Retourne (octets, labels).

    reloc : {"banque:0xADDR": [banque, adresse]} des blocs graphiques deplaces par gfx.py
    (les arguments des load_tiles concernes sont corriges a la compilation).
    """
    lines = []
    for n, raw in enumerate(text.splitlines(), 1):
        s = raw.split(";", 1)[0].strip()
        if s:
            lines.append((n, s))
    labels = {}
    for pass_ in (1, 2):
        out = bytearray()
        for n, s in lines:
            pc = BASE + len(out)
            try:
                if s.endswith(":"):
                    if pass_ == 1:
                        if s[:-1] in labels:
                            raise ValueError(f"label en double : {s[:-1]}")
                        labels[s[:-1]] = pc
                    continue
                word, _, rest = s.partition(" ")
                args = [x for x in (a.strip() for a in rest.split(",")) if x] if rest.strip() else []
                val = (lambda t: parse_num(t, labels)) if pass_ == 2 else (lambda t: 0)
                if word == ".db":
                    out += bytes(val(x) & 0xFF for x in args)
                elif word in (".dw", ".scenes"):
                    for x in args:
                        v = val(x)
                        out += bytes([v & 0xFF, (v >> 8) & 0xFF])
                elif word in NAMES:
                    op = NAMES[word]
                    types = OPS[op][1]
                    if len(args) != len(types):
                        raise ValueError(f"{word} attend {len(types)} argument(s), {len(args)} donne(s)")
                    out.append(op)
                    vals = [val(x) for x in args]
                    if op == 0x12 and pass_ == 2 and reloc:
                        # load_tiles vram, src, banque : bloc graphique deplace par gfx.py ?
                        moved = reloc.get(f"{vals[2]}:0x{vals[1]:04X}")
                        if moved:
                            vals[1], vals[2] = moved[1], moved[0]
                    if op == 0x01 and pass_ == 2 and reloc:
                        # load_vram src, vram, longueur, drapeaux, banque : bloc deplace (ROM512) ?
                        moved = reloc.get(f"{vals[4]}:0x{vals[0]:04X}")
                        if moved:
                            vals[0], vals[4] = moved[1], moved[0]
                    for t, x, v in zip(types, args, vals):
                        if t == "b":
                            if pass_ == 2 and not 0 <= v <= 0xFF:
                                raise ValueError(f"octet hors limites : {x}")
                            out.append(v & 0xFF)
                        else:
                            out += bytes([v & 0xFF, (v >> 8) & 0xFF])
                else:
                    raise ValueError(f"instruction inconnue : {word}")
            except KeyError as e:
                raise SystemExit(f"ligne {n} : label inconnu {e}")
            except ValueError as e:
                raise SystemExit(f"ligne {n} : {e}")
    if len(out) > 0x4000:
        raise SystemExit(f"la banque 5 deborde : {len(out)} octets (max 16384)")
    return bytes(out), labels


def build(ver, quiet=False):
    src = zs_path(ver)
    gen = os.path.join(ROOT, "build", ver, "generated")
    rpath = os.path.join(gen, "gfx_reloc.json")
    reloc = json.load(open(rpath, encoding="utf-8")) if os.path.exists(rpath) else {}
    data, _ = assemble(open(src, encoding="utf-8").read(), reloc)
    os.makedirs(gen, exist_ok=True)
    dst = os.path.join(gen, "data_script.s")
    with open(dst, "w", encoding="utf-8", newline="\n") as f:
        f.write(f";; GENERE par tools/assets/scripts.py depuis {os.path.relpath(src, ROOT)} - ne pas modifier\n")
        f.write("\t.area _B05_8000\n")
        f.write("scripts_bank05::\n")
        for i in range(0, len(data), 16):
            f.write("\t.db " + ", ".join("0x%02x" % b for b in data[i:i + 16]) + "\n")
    if not quiet:
        print(f"[{ver}] {len(data)} octets -> {os.path.relpath(dst, ROOT)}")
    return data


def check(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    orig = rom[BANK * 0x4000:(BANK + 1) * 0x4000]
    data = build(ver, quiet=True)
    data = data + b"\xff" * (len(orig) - len(data))
    if data == orig:
        print(f"[{ver}] scripts : IDENTIQUES a la ROM d'origine")
        return True
    d = next(i for i in range(len(orig)) if data[i] != orig[i])
    print(f"[{ver}] scripts : DIFFERENCE a ${BASE + d:04X} (attendu {orig[d]:02X}, obtenu {data[d]:02X})")
    return False


def GUARDED(ver):
    """Fichiers edites a la main que extract ecraserait."""
    return [zs_path(ver)]


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    opts = dict(a.split("=", 1) for a in sys.argv[2:])
    ver = opts.get("VERSION", "sms_en")
    if cmd == "extract":
        _targets = [p for p in GUARDED(ver) if os.path.exists(p)]
        if _targets and opts.get("FORCE") != "1":
            print("REFUS : ces fichiers existent deja et seraient ecrases (modifications perdues) :")
            for p in _targets:
                print("  " + os.path.relpath(p, ROOT))
            sys.exit("Relancer avec FORCE=1 pour repartir de la ROM d'origine.")
        extract(ver)
    elif cmd == "build":
        build(ver)
    elif cmd == "check":
        sys.exit(0 if check(ver) else 1)
    else:
        sys.exit(__doc__)
