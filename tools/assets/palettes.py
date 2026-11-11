#!/usr/bin/env python3
"""Palettes (16 couleurs GG de 2 octets = 32 octets) : JSON editable.

Usage :
  python tools/assets/palettes.py extract VERSION=sms_en [FORCE=1]
  python tools/assets/palettes.py check   VERSION=sms_en

Decouverte : opcodes `load_palette banque, choix, adresse` des scripts de scenes.
Fichier : assets/<ver>/palettes/palettes.json ; une couleur = "BGR" en hexadecimal
(3 chiffres, 0-F par composante, format Game Gear ----BBBBGGGGRRRR ; le portage SMS
convertit a l'execution en 2 bits par composante). Apercu : palettes/preview.png (genere).
Taille fixe : une palette modifiee est reecrite a sa place.
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


def pdir(ver):
    return os.path.join(ROOT, "assets", ver, "palettes")


def discover(ver):
    refs = {}
    scene = "?"
    zs = os.path.join(ROOT, "assets", ver, "scripts", "bank05.zs")
    for line in open(zs, encoding="utf-8"):
        s = line.split(";")[0].strip()
        if s.endswith(":") and s.startswith("scene_"):
            scene = s[:-1]
        w = s.split()
        if w and w[0] == "load_palette":
            a = [x.strip(",") for x in w[1:]]
            key = (int(a[0], 0), int(a[2], 0))
            e = refs.setdefault(key, {"use": set(), "scenes": set()})
            e["use"].add("sprites" if int(a[1], 0) else "fond")
            e["scenes"].add(scene)
    return refs


def extract(ver):
    import banks
    from PIL import Image, ImageDraw
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    refs = discover(ver)
    composed = set(banks.COMPOSED.get(ver, []))
    out = []
    for (bank, addr), info in sorted(refs.items()):
        o = bank * 0x4000 + addr - 0x8000
        cols = ["%03X" % ((rom[o + 2 * i] | (rom[o + 2 * i + 1] << 8)) & 0x0FFF) for i in range(16)]
        raw_hi = [rom[o + 2 * i + 1] >> 4 for i in range(16)]
        out.append({"bank": bank, "addr": f"0x{addr:04X}", "use": sorted(info["use"]),
                    "scenes": sorted(info["scenes"])[:8], "editable": bank in composed,
                    "colors": cols, "_high_bits": raw_hi if any(raw_hi) else None})
    os.makedirs(pdir(ver), exist_ok=True)
    with open(os.path.join(pdir(ver), "palettes.json"), "w", encoding="utf-8", newline="\n") as f:
        f.write('{"_doc": "GENERE par tools/assets/palettes.py extract puis EDITABLE. Couleur = BGR hexadecimal '
                '(Game Gear). Voir docs/palettes.md.",\n "palettes": [\n')
        f.write(",\n".join("  " + json.dumps(p, ensure_ascii=False) for p in out))
        f.write("\n ]}\n")
    # apercu
    img = Image.new("RGB", (16 * 12 + 110, len(out) * 12), (32, 32, 32))
    d = ImageDraw.Draw(img)
    for r, p in enumerate(out):
        d.text((2, r * 12), f"{p['bank']:02d}:{p['addr'][2:]}", fill=(220, 220, 220))
        for i, c in enumerate(p["colors"]):
            v = int(c, 16)
            rgb = ((v & 15) * 17, ((v >> 4) & 15) * 17, ((v >> 8) & 15) * 17)
            d.rectangle([110 + i * 12, r * 12, 110 + i * 12 + 10, r * 12 + 10], fill=rgb)
    img.save(os.path.join(pdir(ver), "preview.png"))
    print(f"[{ver}] {len(out)} palettes -> {os.path.relpath(pdir(ver), ROOT)}")


def load(ver):
    p = os.path.join(pdir(ver), "palettes.json")
    return json.load(open(p, encoding="utf-8"))["palettes"] if os.path.exists(p) else []


def encode(p):
    out = bytearray()
    hi = p.get("_high_bits") or [0] * 16
    for i, c in enumerate(p["colors"]):
        v = int(c, 16)
        if not 0 <= v <= 0xFFF:
            raise SystemExit(f"palette {p['bank']}:{p['addr']} : couleur invalide {c}")
        v |= (hi[i] & 0xF) << 12
        out += bytes([v & 0xFF, v >> 8])
    return bytes(out)


def apply_overlays(ver, bank, data, relocate=None):
    """Fournisseur pour banks.py : reecrit les palettes de cette banque."""
    data = bytearray(data)
    changed = 0
    for p in load(ver):
        if p["bank"] != bank or not p.get("editable"):
            continue
        if len(p["colors"]) != 16:
            raise SystemExit(f"palette {p['bank']}:{p['addr']} : 16 couleurs attendues")
        o = int(p["addr"], 16) - 0x8000
        new = encode(p)
        if bytes(data[o:o + 32]) != new:
            changed += 1
            data[o:o + 32] = new
    return bytes(data), changed


def check(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    bad = [p for p in load(ver) if encode(p) != rom[p["bank"] * 0x4000 + int(p["addr"], 16) - 0x8000:][:32]]
    print(f"[{ver}] palettes : {len(load(ver)) - len(bad)}/{len(load(ver))} identiques")
    return not bad


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    opts = dict(a.split("=", 1) for a in sys.argv[2:])
    ver = opts.get("VERSION", "sms_en")
    if cmd == "extract":
        if os.path.exists(os.path.join(pdir(ver), "palettes.json")) and opts.get("FORCE") != "1":
            sys.exit("REFUS : palettes.json existe deja (relancer avec FORCE=1).")
        extract(ver)
    elif cmd == "check":
        sys.exit(0 if check(ver) else 1)
    else:
        sys.exit(__doc__)
