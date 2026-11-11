#!/usr/bin/env python3
"""Tilemaps chargees par l'opcode `load_vram` des scripts : CSV editables.

Usage :
  python tools/assets/tilemaps.py extract VERSION=sms_en [FORCE=1]
  python tools/assets/tilemaps.py check   VERSION=sms_en

`load_vram src, vram, taille, drapeaux, banque` : taille = lignes * 256 + colonnes.
  drapeaux bit 7 = 1 : 2 octets par case (mot VDP : bits 0-8 tuile, 9 miroir H, 10 miroir V,
                       11 palette sprites, 12 priorite)  -> valeurs "0123" dans le CSV
  drapeaux bit 7 = 0 : 1 octet par case (numero de tuile ; l'octet de poids fort = drapeaux)
                       -> valeurs "7A" dans le CSV
Fichiers : assets/<ver>/tilemaps/bankNN_AAAA.csv (une ligne de CSV = une rangee de cases)
           + tilemaps.json (manifeste). Taille fixe : reecrites a leur place.
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


def tdir(ver):
    return os.path.join(ROOT, "assets", ver, "tilemaps")


def discover(ver):
    import text
    screens = {(text.SCREEN_BANK, a) for a, _, _, _ in text.SCREENS}
    refs = {}
    scene = "?"
    for line in open(os.path.join(ROOT, "assets", ver, "scripts", "bank05.zs"), encoding="utf-8"):
        s = line.split(";")[0].strip()
        if s.endswith(":") and s.startswith("scene_"):
            scene = s[:-1]
        w = s.split()
        if not w or w[0] != "load_vram":
            continue
        a = [int(x.strip(","), 0) for x in w[1:]]
        src, vram, size, flags, bank = a
        if (bank, src) in screens:
            continue
        rows, cols = size >> 8, size & 0xFF
        word = bool(flags & 0x80)
        key = (bank, src)
        e = refs.get(key)
        if e is None or rows * cols > e["rows"] * e["cols"]:
            refs[key] = {"rows": rows, "cols": cols, "word": word, "flags": flags,
                         "vram": vram & 0x3FFF, "scenes": set(e["scenes"]) if e else set()}
        refs[key]["scenes"].add(scene)
    return refs


def extract(ver):
    import banks
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    composed = set(banks.COMPOSED.get(ver, []))
    os.makedirs(tdir(ver), exist_ok=True)
    manifest = []
    for (bank, src), e in sorted(discover(ver).items()):
        o = bank * 0x4000 + src - 0x8000
        w = 2 if e["word"] else 1
        name = f"bank{bank:02d}_{src:04X}.csv"
        lines = [f"# tilemap banque {bank} ${src:04X} : {e['rows']} lignes x {e['cols']} colonnes, "
                 f"{'2 octets par case (mot VDP)' if e['word'] else '1 octet par case (attribut %02X)' % e['flags']}"]
        for r in range(e["rows"]):
            vals = []
            for c in range(e["cols"]):
                p = o + (r * e["cols"] + c) * w
                vals.append("%04X" % (rom[p] | (rom[p + 1] << 8)) if w == 2 else "%02X" % rom[p])
            lines.append(",".join(vals))
        open(os.path.join(tdir(ver), name), "w", encoding="utf-8", newline="\n").write("\n".join(lines) + "\n")
        manifest.append({"bank": bank, "addr": f"0x{src:04X}", "file": name, "rows": e["rows"], "cols": e["cols"],
                         "bytes_per_cell": w, "vram": f"0x{e['vram']:04X}", "scenes": sorted(e["scenes"])[:8],
                         "editable": bank in composed})
    with open(os.path.join(tdir(ver), "tilemaps.json"), "w", encoding="utf-8", newline="\n") as f:
        json.dump({"_doc": "GENERE par tools/assets/tilemaps.py. Voir docs/tilemaps.md.", "tilemaps": manifest},
                  f, indent=1, ensure_ascii=False)
    print(f"[{ver}] {len(manifest)} tilemaps -> {os.path.relpath(tdir(ver), ROOT)}")


def load(ver):
    p = os.path.join(tdir(ver), "tilemaps.json")
    return json.load(open(p, encoding="utf-8"))["tilemaps"] if os.path.exists(p) else []


def read_csv(ver, m):
    path = os.path.join(tdir(ver), m["file"])
    rows = [l.strip() for l in open(path, encoding="utf-8") if l.strip() and not l.startswith("#")]
    if len(rows) != m["rows"]:
        raise SystemExit(f"{m['file']} : {len(rows)} lignes au lieu de {m['rows']}")
    out = bytearray()
    for n, r in enumerate(rows, 1):
        vals = [v.strip() for v in r.split(",")]
        if len(vals) != m["cols"]:
            raise SystemExit(f"{m['file']} ligne {n} : {len(vals)} cases au lieu de {m['cols']}")
        for v in vals:
            x = int(v, 16)
            if m["bytes_per_cell"] == 2:
                if x > 0xFFFF:
                    raise SystemExit(f"{m['file']} : valeur trop grande {v}")
                out += bytes([x & 0xFF, x >> 8])
            else:
                if x > 0xFF:
                    raise SystemExit(f"{m['file']} : valeur trop grande {v}")
                out.append(x)
    return bytes(out)


def apply_overlays(ver, bank, data, relocate=None):
    """Fournisseur pour banks.py : reecrit les tilemaps de cette banque (taille fixe)."""
    data = bytearray(data)
    changed = 0
    for m in load(ver):
        if m["bank"] != bank or not m.get("editable"):
            continue
        o = int(m["addr"], 16) - 0x8000
        new = read_csv(ver, m)
        if bytes(data[o:o + len(new)]) != new:
            changed += 1
            if len(data) < o + len(new):
                data += b"\xff" * (o + len(new) - len(data))
            data[o:o + len(new)] = new
    return bytes(data), changed


def check(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    ms = load(ver)
    bad = [m for m in ms if read_csv(ver, m) != rom[m["bank"] * 0x4000 + int(m["addr"], 16) - 0x8000:][:m["rows"] * m["cols"] * m["bytes_per_cell"]]]
    print(f"[{ver}] tilemaps : {len(ms) - len(bad)}/{len(ms)} identiques")
    return not bad


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    opts = dict(a.split("=", 1) for a in sys.argv[2:])
    ver = opts.get("VERSION", "sms_en")
    if cmd == "extract":
        if os.path.exists(os.path.join(tdir(ver), "tilemaps.json")) and opts.get("FORCE") != "1":
            sys.exit("REFUS : tilemaps.json existe deja (relancer avec FORCE=1).")
        extract(ver)
    elif cmd == "check":
        sys.exit(0 if check(ver) else 1)
    else:
        sys.exit(__doc__)
