#!/usr/bin/env python3
"""Scripts d'acteurs (banque 25, $8000-$BDAB) : extraction en texte lisible et recompilation.

Usage :
  python tools/assets/actors.py extract VERSION=sms_en [FORCE=1]  # -> assets/<ver>/actors/bank25.as
  python tools/assets/actors.py build   VERSION=sms_en            # -> build/<ver>/generated/data_actor_scripts.s
  python tools/assets/actors.py check   VERSION=sms_en

Syntaxe du .as : comme les scripts de scenes (voir docs/actor_scripts.md) :
  label: / instruction args / .dw a, b / .db x, y
  move n, a, b, c, d      deplacement pendant n trames (n < $CA)
Les labels `actors_XXXX` sont GLOBAUX : le code du jeu y fait reference par leur nom
(ex. `ld de,#actors_B8B8`), ils peuvent donc se deplacer si les scripts changent de taille.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, ".."))
from toolchain import ROOT  # noqa: E402
from ascript import CMDS, decode_at  # noqa: E402

ROMS = {"sms_en": "original/Kishin_Douji_Zenki_GG2SMS_v0_3__EN_.sms",
        "gg_jp": "original/Kishin Douji Zenki (J).gg"}
BANK, BASE, END = 25, 0x8000, 0xBDAC        # $BDAC : debut du code banque (src/game/actors.s)
# adresses utilisees par le code (detectees par le traceur) -> labels globaux
EXPORTED = [0x8000, 0xB8B8, 0xBD21, 0xBD35]   # ($A617 dans $61BF = bornes d un test d intervalle, pas un pointeur)
NAMES = {name: code for code, (name, _, _, _) in CMDS.items()}


def as_path(ver):
    return os.path.join(ROOT, "assets", ver, "actors", "bank25.as")


def entries(data):
    w = lambda a: data[a - BASE] | (data[a - BASE + 1] << 8)
    tbl = w(0x8000)
    ent = {}
    for i in range(253):
        ent.setdefault(w(tbl + 2 * i), f"actor_{i:02X}")
    for i in range(15):
        ent.setdefault(w(0xB8B8 + 2 * i), f"sub_b8b8_{i:02d}")
    for i in range(5):
        ent.setdefault(w(0xBD35 + 2 * i), f"sub_bd35_{i}")
        ent.setdefault(w(0xBD21 + 4 * i), f"sub_bd21_{i}")
    return ent


def extract(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    data = rom[BANK * 0x4000:BANK * 0x4000 + (END - BASE)]
    w = lambda a: data[a - BASE] | (data[a - BASE + 1] << 8)
    labels = dict(entries(data))
    starts, todo = {}, list(labels)
    while todo:
        a = todo.pop()
        while a not in starts and BASE <= a < END:
            c, name, args, size, flow = decode_at(data, BASE, a)
            starts[a] = (c, name, args, size)
            for t, v in args:
                if t == "p":
                    labels.setdefault(v, f"L_{v:04X}")
                    todo.append(v)
            if flow == "end":
                break
            a += size
    # tables de pointeurs (rendues avec des labels)
    tables = {w(0x8000): 253, 0xB8B8: 15, 0xBD35: 5}
    records = {0xBD21: 5}
    labels.setdefault(w(0x8000), "actor_types")
    for a in EXPORTED:
        labels.setdefault(a, f"actors_{a:04X}")
    out = [f"; Scripts d'acteurs - banque 25 ($8000-$BDAB) - version {ver}",
           "; GENERE par tools/assets/actors.py extract, puis edite a la main. Voir docs/actor_scripts.md.",
           "; Les labels actors_XXXX sont utilises par le code : ne pas les renommer.", ""]
    a, pending = BASE, []

    def flush():
        while pending:
            chunk = pending[:16]
            del pending[:16]
            out.append("\t.db " + ", ".join("0x%02x" % b for b in chunk))

    while a < END:
        if a in labels or a in EXPORTED:
            flush()
            out.append("")
            if a in EXPORTED:
                out.append(f"actors_{a:04X}::")
            if a in labels and labels[a] != f"actors_{a:04X}":
                out.append(f"{labels[a]}:")
        if a == BASE:
            out.append("\t.dw " + labels.get(w(BASE), "0x%04x" % w(BASE)) + "            ; table des types d'acteurs")
            a += 2
            continue
        if a in tables:
            flush()
            for i in range(tables[a]):
                p = w(a + 2 * i)
                out.append(f"\t.dw {labels.get(p, '0x%04x' % p)}" + (f"            ; type {i:02X}" if a == w(BASE) else ""))
            a += 2 * tables[a]
            continue
        if a in records:
            flush()
            for i in range(records[a]):
                p = w(a + 4 * i)
                out.append(f"\t.dw {labels.get(p, '0x%04x' % p)}, 0x{w(a + 4 * i + 2):04x}")
            a += 4 * records[a]
            continue
        if a in starts:
            flush()
            c, name, args, size = starts[a]
            parts = [labels[v] if t == "p" else (f"0x{v:02x}" if t == "b" else f"0x{v:04x}") for t, v in args]
            out.append(f"\t{name}" + (" " + ", ".join(parts) if parts else ""))
            a += size
        else:
            pending.append(data[a - BASE])
            a += 1
    flush()
    path = as_path(ver)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")
    print(f"[{ver}] {len(starts)} instructions, {len(labels)} labels -> {os.path.relpath(path, ROOT)}")


def parse_num(tok, labels):
    if re.fullmatch(r"-?(0x[0-9a-fA-F]+|\d+)", tok):
        return int(tok, 0)
    if tok in labels:
        return labels[tok]
    raise KeyError(tok)


def assemble(text):
    lines = [(n, raw.split(";", 1)[0].strip()) for n, raw in enumerate(text.splitlines(), 1)]
    lines = [(n, s) for n, s in lines if s]
    labels = {}
    for pass_ in (1, 2):
        out = bytearray()
        for n, s in lines:
            pc = BASE + len(out)
            try:
                if s.endswith(":"):
                    name = s.rstrip(":")
                    if pass_ == 1:
                        if name in labels:
                            raise ValueError(f"label en double : {name}")
                        labels[name] = pc
                    continue
                word, _, rest = s.partition(" ")
                args = [x.strip() for x in rest.split(",") if x.strip()]
                val = (lambda t: parse_num(t, labels)) if pass_ == 2 else (lambda t: 0)
                if word == ".db":
                    out += bytes(val(x) & 0xFF for x in args)
                elif word == ".dw":
                    for x in args:
                        v = val(x)
                        out += bytes([v & 0xFF, (v >> 8) & 0xFF])
                elif word == "jump":
                    v = val(args[0])
                    out += bytes([0, v & 0xFF, v >> 8])
                elif word == "move":
                    vals = [val(x) for x in args]
                    if len(vals) != 5 or (pass_ == 2 and not 1 <= vals[0] < 0xCA):
                        raise ValueError("move attend 5 octets et une duree de 1 a $C9")
                    out += bytes(v & 0xFF for v in vals)
                elif word in NAMES:
                    code = NAMES[word]
                    types = CMDS[code][1]
                    if len(args) != len(types):
                        raise ValueError(f"{word} attend {len(types)} argument(s)")
                    out.append(code)
                    for t, x in zip(types, args):
                        v = val(x)
                        if t == "b":
                            if pass_ == 2 and not 0 <= v <= 0xFF:
                                raise ValueError(f"octet hors limites : {x}")
                            out.append(v & 0xFF)
                        else:
                            out += bytes([v & 0xFF, (v >> 8) & 0xFF])
                else:
                    raise ValueError(f"instruction inconnue : {word}")
            except KeyError as e:
                raise SystemExit(f"bank25.as ligne {n} : label inconnu {e}")
            except ValueError as e:
                raise SystemExit(f"bank25.as ligne {n} : {e}")
    return bytes(out), labels


def build(ver, quiet=False):
    data, labels = assemble(open(as_path(ver), encoding="utf-8").read())
    limit = 0x4000 - 0x80          # garder de la place pour le code banque qui suit
    if len(data) > limit:
        raise SystemExit(f"scripts d'acteurs trop longs : {len(data)} octets")
    exported = {a: n for n, a in labels.items() if n.startswith("actors_")}
    gen = os.path.join(ROOT, "build", ver, "generated")
    os.makedirs(gen, exist_ok=True)
    # octets par lignes de 16, coupes aux labels exportes
    cut = sorted(set([0] + [a - BASE for a in exported] + [len(data)]))
    with open(os.path.join(gen, "data_actor_scripts.s"), "w", encoding="utf-8", newline="\n") as f:
        f.write(f";; GENERE par tools/assets/actors.py depuis assets/{ver}/actors/bank25.as - ne pas modifier\n")
        f.write("\t.area _B25_8000\n")
        for s, e in zip(cut, cut[1:]):
            if BASE + s in exported:
                f.write(f"{exported[BASE + s]}::\n")
            for i in range(s, e, 16):
                f.write("\t.db " + ", ".join("0x%02x" % b for b in data[i:min(i + 16, e)]) + "\n")
    if not quiet:
        print(f"[{ver}] scripts d'acteurs : {len(data)} octets")
    return data


def check(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    orig = rom[BANK * 0x4000:BANK * 0x4000 + (END - BASE)]
    data = build(ver, quiet=True)
    ok = data == orig
    print(f"[{ver}] scripts d'acteurs : {'IDENTIQUES a la ROM d origine' if ok else 'DIFFERENTS'}")
    if not ok:
        d = next((i for i in range(min(len(data), len(orig))) if data[i] != orig[i]), min(len(data), len(orig)))
        print(f"   premier ecart a ${BASE + d:04X} (taille {len(data)} vs {len(orig)})")
    return ok


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    opts = dict(a.split("=", 1) for a in sys.argv[2:])
    ver = opts.get("VERSION", "sms_en")
    if cmd == "extract":
        if os.path.exists(as_path(ver)) and opts.get("FORCE") != "1":
            sys.exit("REFUS : " + os.path.relpath(as_path(ver), ROOT) + " existe deja (FORCE=1 pour l'ecraser).")
        extract(ver)
    elif cmd == "build":
        build(ver)
    elif cmd == "check":
        sys.exit(0 if check(ver) else 1)
    else:
        sys.exit(__doc__)
