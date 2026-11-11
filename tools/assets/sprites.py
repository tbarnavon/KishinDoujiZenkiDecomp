#!/usr/bin/env python3
"""Meta-sprites (animations des acteurs, banque 24) : JSON editable.

Usage :
  python tools/assets/sprites.py extract VERSION=sms_en [FORCE=1]
  python tools/assets/sprites.py check   VERSION=sms_en

Moteur : $6D4E (video/sprites). Numero d'animation = champ 7 de l'acteur (set_anim).
  table $81FA (255 entrees) ou $9ECF (128 entrees, si champ 34 bit 7) : [animation mot][disposition mot]
  animation : [delai][derniere image][image de reprise][morceaux] + (derniere+1) images,
              chacune = 1 numero de tuile par morceau ($FF = morceau absent)
  disposition : 1 couple [dx][dy] (signes) par morceau, ajoute a la position de l'acteur
Fichier : assets/<ver>/sprites/sprites.json (tailles fixes : nombre d'images et de morceaux).
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, ".."))
from toolchain import ROOT  # noqa: E402

ROMS = {"sms_en": "original/Kishin_Douji_Zenki_GG2SMS_v0_3__EN_.sms",
        "gg_jp": "original/Kishin Douji Zenki (J).gg"}
BANK = 24
TABLES = {"0x81FA": 255, "0x9ECF": 128}


def spath(ver):
    return os.path.join(ROOT, "assets", ver, "sprites", "sprites.json")


def extract(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    B = BANK * 0x4000
    rd = lambda a: rom[B + a - 0x8000]
    w = lambda a: rd(a) | (rd(a + 1) << 8)
    tables, anims, layouts = {}, {}, {}
    for t, n in TABLES.items():
        rows = []
        for i in range(n):
            a, l = w(int(t, 16) + 4 * i), w(int(t, 16) + 4 * i + 2)
            rows.append([f"0x{a:04X}", f"0x{l:04X}"])
            if a not in anims:
                last, pieces = rd(a + 1), rd(a + 3)
                frames = [[rd(a + 4 + f * pieces + k) for k in range(pieces)] for f in range(last + 1)]
                anims[a] = {"delay": rd(a), "loop_frame": rd(a + 2), "frames": frames}
            layouts[l] = max(layouts.get(l, 0), rd(a + 3))
        tables[t] = rows
    lay = {}
    for l, pieces in layouts.items():
        lay[f"0x{l:04X}"] = [[(rd(l + 2 * k) ^ 0x80) - 0x80, (rd(l + 2 * k + 1) ^ 0x80) - 0x80] for k in range(pieces)]
    os.makedirs(os.path.dirname(spath(ver)), exist_ok=True)
    doc = {"_doc": "GENERE par tools/assets/sprites.py extract puis EDITABLE (voir docs/sprites.md). "
                   "Nombres de morceaux et d'images FIXES ; tuiles en decimal, 255 = morceau absent.",
           "tables": tables,
           "animations": {f"0x{a:04X}": v for a, v in sorted(anims.items())},
           "layouts": dict(sorted(lay.items()))}
    with open(spath(ver), "w", encoding="utf-8", newline="\n") as f:
        # une ligne par entree pour rester lisible
        f.write("{\n" + f' "_doc": {json.dumps(doc["_doc"], ensure_ascii=False)},\n')
        f.write(' "tables": {\n' + ",\n".join(
            f'  "{t}": [\n' + ",\n".join("   " + json.dumps(r) for r in rows) + "\n  ]" for t, rows in tables.items()) + "\n },\n")
        f.write(' "animations": {\n' + ",\n".join(f'  "{k}": {json.dumps(v)}' for k, v in doc["animations"].items()) + "\n },\n")
        f.write(' "layouts": {\n' + ",\n".join(f'  "{k}": {json.dumps(v)}' for k, v in doc["layouts"].items()) + "\n }\n}\n")
    print(f"[{ver}] {sum(TABLES.values())} entrees, {len(anims)} animations, {len(lay)} dispositions -> "
          f"{os.path.relpath(spath(ver), ROOT)}")


def apply_overlays(ver, bank, data, relocate=None):
    """Fournisseur pour banks.py (banque 24)."""
    if bank != BANK or not os.path.exists(spath(ver)):
        return data, 0
    doc = json.load(open(spath(ver), encoding="utf-8"))
    data = bytearray(data)
    before = bytes(data)

    def put(a, bs):
        o = a - 0x8000
        data[o:o + len(bs)] = bs

    for t, rows in doc["tables"].items():
        for i, (a, l) in enumerate(rows):
            a, l = int(a, 16), int(l, 16)
            put(int(t, 16) + 4 * i, bytes([a & 0xFF, a >> 8, l & 0xFF, l >> 8]))
    for k, v in doc["animations"].items():
        a = int(k, 16)
        o = a - 0x8000
        pieces, last = before[o + 3], before[o + 1]
        fr = v["frames"]
        if len(fr) != last + 1 or any(len(x) != pieces for x in fr):
            raise SystemExit(f"sprites.json animation {k} : {last + 1} images de {pieces} morceaux attendues")
        put(a, bytes([v["delay"], last, v["loop_frame"], pieces] + [t for x in fr for t in x]))
    for k, pcs in doc["layouts"].items():
        put(int(k, 16), bytes(b & 0xFF for p in pcs for b in p))
    return bytes(data), int(bytes(data) != before)


def check(ver):
    import banks
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    raw = open(banks.raw_path(ver, BANK), "rb").read()
    data, _ = apply_overlays(ver, BANK, raw)
    orig = rom[BANK * 0x4000:(BANK + 1) * 0x4000]
    ok = data + b"\xff" * (len(orig) - len(data)) == orig
    print(f"[{ver}] sprites : banque 24 {'IDENTIQUE' if ok else 'DIFFERENTE'}")
    return ok


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    opts = dict(a.split("=", 1) for a in sys.argv[2:])
    ver = opts.get("VERSION", "sms_en")
    if cmd == "extract":
        if os.path.exists(spath(ver)) and opts.get("FORCE") != "1":
            sys.exit("REFUS : sprites.json existe deja (FORCE=1 pour l'ecraser).")
        extract(ver)
    elif cmd == "check":
        sys.exit(0 if check(ver) else 1)
    else:
        sys.exit(__doc__)
