#!/usr/bin/env python3
"""Placement des ennemis/objets dans les niveaux (banque 4) : CSV editables.

Usage :
  python tools/assets/enemies.py extract VERSION=sms_en [FORCE=1]
  python tools/assets/enemies.py check   VERSION=sms_en

Banque 4 : le mot en $8006 pointe vers une table indexee par le niveau ($C014) ; chaque
entree pointe vers [longueur mot] + enregistrements de 6 octets + $FF :
  [type d'acteur][x mot][y mot][drapeaux]   (copies en RAM $C7FB par $3606)
Au jeu, $3A9E fait apparaitre un acteur quand x entre dans l'ecran (defilement $C0AE) ;
le bit 7 des drapeaux marque « deja apparu ». Le type indexe `actor_types` (scripts d'acteurs).
Fichiers : assets/<ver>/enemies/list_AAAA.csv (une ligne par ennemi) + enemies.json.
Le nombre d'ennemis d'une liste est fixe (taille en place).
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
BANK, LEVELS = 4, 58


def edir(ver):
    return os.path.join(ROOT, "assets", ver, "enemies")


def lists(rom):
    B = BANK * 0x4000
    w = lambda a: rom[B + a - 0x8000] | (rom[B + a - 0x8000 + 1] << 8)
    t = w(0x8006)
    out = {}
    for lvl in range(LEVELS):
        p = w(t + 2 * lvl)
        n = w(p)
        out.setdefault(p, {"levels": [], "length": n})["levels"].append(lvl)
    return out


def extract(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    B = BANK * 0x4000
    os.makedirs(edir(ver), exist_ok=True)
    manifest = []
    for p, e in sorted(lists(rom).items()):
        o = B + p - 0x8000 + 2
        n = e["length"]
        recs = n // 6
        lines = [f"# ennemis banque 4 ${p:04X} : {recs} ennemis ; niveaux "
                 + ", ".join("%02X" % x for x in e["levels"]),
                 "# type (hex), x, y (decimal, pixels), drapeaux (hex)"]
        for r in range(recs):
            q = o + 6 * r
            lines.append(f"{rom[q]:02X},{rom[q + 1] | (rom[q + 2] << 8)},{rom[q + 3] | (rom[q + 4] << 8)},{rom[q + 5]:02X}")
        tail = rom[o + 6 * recs:o + n]
        name = f"list_{p:04X}.csv"
        open(os.path.join(edir(ver), name), "w", encoding="utf-8", newline="\n").write("\n".join(lines) + "\n")
        manifest.append({"addr": f"0x{p:04X}", "file": name, "count": recs, "levels": e["levels"],
                         "tail": tail.hex()})
    with open(os.path.join(edir(ver), "enemies.json"), "w", encoding="utf-8", newline="\n") as f:
        json.dump({"_doc": "GENERE par tools/assets/enemies.py. Voir docs/enemies.md.", "lists": manifest},
                  f, indent=1, ensure_ascii=False)
    print(f"[{ver}] {len(manifest)} listes, {sum(m['count'] for m in manifest)} ennemis -> {os.path.relpath(edir(ver), ROOT)}")


def read_list(ver, m):
    path = os.path.join(edir(ver), m["file"])
    rows = [l.strip() for l in open(path, encoding="utf-8") if l.strip() and not l.startswith("#")]
    if len(rows) != m["count"]:
        raise SystemExit(f"{m['file']} : {m['count']} ennemis attendus (nombre fixe), {len(rows)} trouves")
    out = bytearray()
    for n, r in enumerate(rows, 1):
        v = [x.strip() for x in r.split(",")]
        if len(v) != 4:
            raise SystemExit(f"{m['file']} ligne {n} : 4 valeurs attendues (type,x,y,drapeaux)")
        t, x, y, fl = int(v[0], 16), int(v[1], 0), int(v[2], 0), int(v[3], 16)
        if not (0 <= t <= 0xFE and 0 <= x <= 0xFFFF and 0 <= y <= 0xFFFF and 0 <= fl <= 0xFF):
            raise SystemExit(f"{m['file']} ligne {n} : valeur hors limites")
        out += bytes([t, x & 0xFF, x >> 8, y & 0xFF, y >> 8, fl])
    return bytes(out) + bytes.fromhex(m["tail"])


def apply_overlays(ver, bank, data, relocate=None):
    """Fournisseur pour banks.py (banque 4)."""
    p = os.path.join(edir(ver), "enemies.json")
    if bank != BANK or not os.path.exists(p):
        return data, 0
    data = bytearray(data)
    before = bytes(data)
    for m in json.load(open(p, encoding="utf-8"))["lists"]:
        o = int(m["addr"], 16) - 0x8000 + 2
        new = read_list(ver, m)
        data[o:o + len(new)] = new
    return bytes(data), int(bytes(data) != before)


def check(ver):
    import banks
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    data, _ = apply_overlays(ver, BANK, open(banks.raw_path(ver, BANK), "rb").read())
    orig = rom[BANK * 0x4000:(BANK + 1) * 0x4000]
    ok = data + b"\xff" * (len(orig) - len(data)) == orig
    print(f"[{ver}] ennemis : banque 4 {'IDENTIQUE' if ok else 'DIFFERENTE'}")
    return ok


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    opts = dict(a.split("=", 1) for a in sys.argv[2:])
    ver = opts.get("VERSION", "sms_en")
    if cmd == "extract":
        if os.path.exists(os.path.join(edir(ver), "enemies.json")) and opts.get("FORCE") != "1":
            sys.exit("REFUS : enemies.json existe deja (FORCE=1 pour l'ecraser).")
        extract(ver)
    elif cmd == "check":
        sys.exit(0 if check(ver) else 1)
    else:
        sys.exit(__doc__)
