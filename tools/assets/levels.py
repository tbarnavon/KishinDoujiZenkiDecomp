#!/usr/bin/env python3
"""Niveaux : cartes (grilles de metatuiles), metatuiles, attributs, apercus PNG.

Usage :
  python tools/assets/levels.py extract VERSION=sms_en [FORCE=1]
  python tools/assets/levels.py check   VERSION=sms_en
  python tools/assets/levels.py preview VERSION=sms_en   # regenere les apercus depuis assets/

Donnees (indexees par le numero de niveau $C014, 58 entrees) :
  banque 1  $4CFC : [banque, pointeur] de la carte -> en-tete [largeur][hauteur][taille mot]
                    puis largeur x hauteur octets = indices de metatuiles (copies en $CF27)
  banque 10 $BBD2 : pointeur du jeu de metatuiles -> [taille mot] + metatuiles de 8 octets
                    (4 mots VDP : haut-gauche, haut-droite, bas-gauche, bas-droite)
  banque 10 $BC46 : pointeur des attributs -> [taille mot] + 1 octet par metatuile (collisions)
  banque 1  $4C88 / $4C14 : listes de tuiles a charger (voir gfx.py)
  banque 2  $9E65 : palette de fond du niveau (lecture seule : banque avec du code)
Fichiers : assets/<ver>/levels/ : levels.json, maps/*.csv, metatiles/*.csv, attributes/*.csv,
           preview/level_NN.png (apercus generes). Tailles fixes (valeurs editables).
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
LEVELS = 58
MAP_TABLE, MT_TABLE, ATTR_TABLE = 0x4CFC, 0xBBD2, 0xBC46
GFX_TABLES = (0x4C88, 0x4C14)
PAL_TABLE = 0x9E65


def ldir(ver):
    return os.path.join(ROOT, "assets", ver, "levels")


def read_rom(ver):
    return open(os.path.join(ROOT, ROMS[ver]), "rb").read()


def info(rom):
    """Liste des niveaux et des ressources distinctes."""
    w = lambda a: rom[a] | (rom[a + 1] << 8)
    wb = lambda b, a: w(b * 0x4000 + a - 0x8000)
    levels = []
    for i in range(LEVELS):
        mb, mp = rom[MAP_TABLE + 3 * i], w(MAP_TABLE + 3 * i + 1)
        o = mb * 0x4000 + mp - 0x8000
        gfx = []
        for t in GFX_TABLES:
            p = w(t + 2 * i)
            while 0x4000 <= p < 0x8000 and w(p) != 0xFFFF:
                gfx.append({"bank": rom[p + 4], "src": w(p), "vram": w(p + 2) & 0x3FFF})
                p += 6
        levels.append({"level": i, "map": (mb, mp), "width": rom[o], "height": rom[o + 1],
                       "metatiles": wb(10, MT_TABLE + 2 * i), "attributes": wb(10, ATTR_TABLE + 2 * i),
                       "palette": wb(2, PAL_TABLE + 2 * i), "gfx": gfx})
    return levels


def name_map(b, p):
    return f"map_b{b:02d}_{p:04X}.csv"


def extract(ver):
    rom = read_rom(ver)
    lv = info(rom)
    d = ldir(ver)
    for sub in ("maps", "metatiles", "attributes", "preview"):
        os.makedirs(os.path.join(d, sub), exist_ok=True)
    done = set()
    for L in lv:
        b, p = L["map"]
        if (b, p) in done:
            continue
        done.add((b, p))
        o = b * 0x4000 + p - 0x8000 + 4
        W, H = L["width"], L["height"]
        lines = [f"# carte banque {b} ${p:04X} : {W} x {H} metatuiles (indices hexadecimaux) ; "
                 f"niveaux {', '.join('%02X' % x['level'] for x in lv if x['map'] == (b, p))}"]
        for r in range(H):
            lines.append(",".join("%02X" % rom[o + r * W + c] for c in range(W)))
        open(os.path.join(d, "maps", name_map(b, p)), "w", encoding="utf-8", newline="\n").write("\n".join(lines) + "\n")
    for key, sub in (("metatiles", "metatiles"), ("attributes", "attributes")):
        for ptr in sorted({L[key] for L in lv}):
            o = 10 * 0x4000 + ptr - 0x8000
            size = rom[o] | (rom[o + 1] << 8)
            data = rom[o + 2:o + 2 + size]
            if key == "metatiles":
                lines = [f"# metatuiles banque 10 ${ptr:04X} : {size // 8} metatuiles ; "
                         "une ligne = haut-gauche, haut-droite, bas-gauche, bas-droite (mots VDP)"]
                for m in range(size // 8):
                    lines.append(",".join("%04X" % (data[m * 8 + 2 * k] | (data[m * 8 + 2 * k + 1] << 8)) for k in range(4)))
            else:
                lines = [f"# attributs banque 10 ${ptr:04X} : {size} octets (1 par metatuile, 16 par ligne)"]
                for r in range(0, size, 16):
                    lines.append(",".join("%02X" % x for x in data[r:r + 16]))
            open(os.path.join(d, sub, f"{sub[:-1] if sub != 'metatiles' else 'set'}_{ptr:04X}.csv"
                              .replace("attribute_", "attr_")), "w", encoding="utf-8", newline="\n").write("\n".join(lines) + "\n")
    manifest = [{"level": f"{L['level']:02X}", "map": "maps/" + name_map(*L["map"]),
                 "width": L["width"], "height": L["height"],
                 "metatiles": f"metatiles/set_{L['metatiles']:04X}.csv",
                 "attributes": f"attributes/attr_{L['attributes']:04X}.csv",
                 "palette_bank2": f"0x{L['palette']:04X}",
                 "gfx": [f"banque {g['bank']} ${g['src']:04X} -> VRAM ${g['vram']:04X}" for g in L["gfx"]]}
                for L in lv]
    with open(os.path.join(d, "levels.json"), "w", encoding="utf-8", newline="\n") as f:
        json.dump({"_doc": "GENERE par tools/assets/levels.py. Voir docs/levels.md.", "levels": manifest},
                  f, indent=1, ensure_ascii=False)
    print(f"[{ver}] {len(lv)} niveaux, {len(done)} cartes, "
          f"{len({L['metatiles'] for L in lv})} jeux de metatuiles -> {os.path.relpath(d, ROOT)}")
    preview(ver)


# ---------------------------------------------------------------- relecture des CSV
def _csv(path):
    return [[int(v, 16) for v in l.strip().split(",")] for l in open(path, encoding="utf-8")
            if l.strip() and not l.startswith("#")]


def load_map(ver, b, p, W, H):
    rows = _csv(os.path.join(ldir(ver), "maps", name_map(b, p)))
    if len(rows) != H or any(len(r) != W for r in rows):
        raise SystemExit(f"{name_map(b, p)} : la carte doit garder {W} x {H} cases")
    if any(v > 0xFF for r in rows for v in r):
        raise SystemExit(f"{name_map(b, p)} : indice de metatuile > FF")
    return bytes(v for r in rows for v in r)


def load_set(ver, ptr, size):
    rows = _csv(os.path.join(ldir(ver), "metatiles", f"set_{ptr:04X}.csv"))
    # (si la taille n'est pas multiple de 8, le reliquat reste tel quel dans raw/bank10.bin)
    if len(rows) != size // 8 or any(len(r) != 4 for r in rows):
        raise SystemExit(f"set_{ptr:04X}.csv : {size // 8} lignes de 4 mots attendues")
    return bytes(b for r in rows for v in r for b in (v & 0xFF, v >> 8))


def load_attr(ver, ptr, size):
    vals = [v for r in _csv(os.path.join(ldir(ver), "attributes", f"attr_{ptr:04X}.csv")) for v in r]
    if len(vals) != size:
        raise SystemExit(f"attr_{ptr:04X}.csv : {size} valeurs attendues")
    return bytes(vals)


def apply_overlays(ver, bank, data, relocate=None):
    """Fournisseur pour banks.py : cartes (banques 19/20), metatuiles et attributs (banque 10)."""
    if not os.path.exists(os.path.join(ldir(ver), "levels.json")):
        return data, 0
    rom = read_rom(ver)
    lv = info(rom)
    data = bytearray(data)
    changed = 0

    def put(off, new):
        nonlocal changed
        if bytes(data[off:off + len(new)]) != new:
            changed += 1
            data[off:off + len(new)] = new

    for (b, p) in sorted({L["map"] for L in lv}):
        if b == bank:
            L = next(x for x in lv if x["map"] == (b, p))
            put(p - 0x8000 + 4, load_map(ver, b, p, L["width"], L["height"]))
    if bank == 10:
        for ptr in sorted({L["metatiles"] for L in lv}):
            o = ptr - 0x8000
            put(o + 2, load_set(ver, ptr, data[o] | (data[o + 1] << 8)))
        for ptr in sorted({L["attributes"] for L in lv}):
            o = ptr - 0x8000
            put(o + 2, load_attr(ver, ptr, data[o] | (data[o + 1] << 8)))
    return bytes(data), changed


def check(ver):
    import banks
    rom = read_rom(ver)
    bad = []
    for b in (10, 19, 20):
        raw = open(banks.raw_path(ver, b), "rb").read()
        data, _ = apply_overlays(ver, b, raw)
        orig = rom[b * 0x4000:(b + 1) * 0x4000]
        if data + b"\xff" * (len(orig) - len(data)) != orig:
            bad.append(b)
    print(f"[{ver}] niveaux : banques 10/19/20 {'IDENTIQUES' if not bad else 'DIFFERENTES ' + str(bad)}")
    return not bad


# ---------------------------------------------------------------- apercus
def preview(ver):
    """Rend chaque niveau en PNG : VRAM reconstituee depuis les listes de tuiles du niveau."""
    from PIL import Image
    import rle
    rom = read_rom(ver)
    n = 0
    for L in info(rom):
        vram = bytearray(0x4000)
        for g in L["gfx"]:
            try:
                tiles, _ = rle.decompress(rom, g["bank"] * 0x4000 + g["src"] - 0x8000)
            except (ValueError, IndexError):
                continue
            end = min(0x4000, g["vram"] + len(tiles))
            vram[g["vram"]:end] = tiles[:end - g["vram"]]
        po = 2 * 0x4000 + L["palette"] - 0x8000
        pal = []
        for i in range(16):
            v = rom[po + 2 * i] | (rom[po + 2 * i + 1] << 8)
            pal += [(v & 15) * 17, ((v >> 4) & 15) * 17, ((v >> 8) & 15) * 17]
        b, p = L["map"]
        W, H = L["width"], L["height"]
        try:
            cells = load_map(ver, b, p, W, H)
            mo = 10 * 0x4000 + L["metatiles"] - 0x8000
            mset = load_set(ver, L["metatiles"], rom[mo] | (rom[mo + 1] << 8))
        except SystemExit:
            continue
        img = Image.new("P", (W * 16, H * 16), 0)
        img.putpalette(pal + [0] * (768 - len(pal)))
        px = img.load()
        for cy in range(H):
            for cx in range(W):
                m = cells[cy * W + cx]
                for k in range(4):
                    if m * 8 + 2 * k + 1 >= len(mset):
                        continue
                    word = mset[m * 8 + 2 * k] | (mset[m * 8 + 2 * k + 1] << 8)
                    t, hf, vf = word & 0x1FF, word & 0x200, word & 0x400
                    base = t * 32
                    ox, oy = cx * 16 + (k & 1) * 8, cy * 16 + (k >> 1) * 8
                    for y in range(8):
                        row = vram[base + y * 4: base + y * 4 + 4] if base + y * 4 + 4 <= 0x4000 else b"\0\0\0\0"
                        for x in range(8):
                            bit = 7 - x
                            v = sum(((row[q] >> bit) & 1) << q for q in range(4))
                            px[ox + (7 - x if hf else x), oy + (7 - y if vf else y)] = v
        img.save(os.path.join(ldir(ver), "preview", f"level_{L['level']:02X}.png"))
        n += 1
    print(f"[{ver}] {n} apercus -> {os.path.relpath(os.path.join(ldir(ver), 'preview'), ROOT)}")


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    opts = dict(a.split("=", 1) for a in sys.argv[2:])
    ver = opts.get("VERSION", "sms_en")
    if cmd == "extract":
        if os.path.exists(os.path.join(ldir(ver), "levels.json")) and opts.get("FORCE") != "1":
            sys.exit("REFUS : assets/" + ver + "/levels existe deja (FORCE=1 pour l'ecraser).")
        extract(ver)
    elif cmd == "check":
        sys.exit(0 if check(ver) else 1)
    elif cmd == "preview":
        preview(ver)
    else:
        sys.exit(__doc__)
