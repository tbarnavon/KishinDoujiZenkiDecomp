#!/usr/bin/env python3
"""Graphismes : blocs de tuiles compresses (RLE planaire) <-> PNG indexes 16 couleurs.

Usage :
  python tools/assets/gfx.py extract VERSION=sms_en [FORCE=1]  # ROM -> assets/<ver>/gfx/ (PNG + .rle + manifest)
  python tools/assets/gfx.py check   VERSION=sms_en            # PNG -> banques, compare a la ROM

Decouverte des blocs : opcodes `load_tiles` des scripts de scenes + appels du code au
decompresseur ($46A1 vers la VRAM, $4667 vers la RAM) avec banque et pointeur constants.

Edition : modifier le PNG en gardant le MODE INDEXE (indices de couleur 0-15) et la taille.
Au build : PNG inchange -> flux compresse d'origine (.rle) ; PNG modifie -> recompression.
Le nouveau flux ne doit pas depasser la taille de l'ancien (place fixe dans la banque),
sinon le build s'arrete avec un message (le deplacement libre viendra avec l'etape 5).
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, ".."))
sys.path.insert(0, os.path.join(HERE, "..", "disasm"))
from toolchain import ROOT  # noqa: E402
import rle  # noqa: E402

ROMS = {"sms_en": "original/Kishin_Douji_Zenki_GG2SMS_v0_3__EN_.sms",
        "gg_jp": "original/Kishin Douji Zenki (J).gg"}
EDITABLE = {"sms_en"}
# banques ne contenant que des donnees graphiques/palettes : reconstruites depuis assets/
from banks import COMPOSED as ASSET_BANKS  # noqa: E402  (banques reconstruites depuis assets/)
TILES_PER_ROW = 16
LEVEL_GFX_TABLES = (0x4C88, 0x4C14)   # listes de graphismes par niveau (banque 1)
LEVEL_COUNT = 58


def gdir(ver):
    return os.path.join(ROOT, "assets", ver, "gfx")


# ------------------------------------------------------------------ conversions
def gg_color_to_rgb(w):
    r, g, b = w & 0xF, (w >> 4) & 0xF, (w >> 8) & 0xF
    return (r * 17, g * 17, b * 17)


def tiles_to_indices(data):
    """Tuiles 4 bits planaires (32 octets) -> liste de tuiles de 64 indices."""
    tiles = []
    for t in range(len(data) // 32):
        px = []
        for row in range(8):
            p = [data[t * 32 + row * 4 + k] for k in range(4)]
            for x in range(8):
                bit = 7 - x
                px.append(sum(((p[k] >> bit) & 1) << k for k in range(4)))
        tiles.append(px)
    return tiles


def indices_to_tiles(tiles):
    out = bytearray()
    for px in tiles:
        for row in range(8):
            planes = [0, 0, 0, 0]
            for x in range(8):
                v = px[row * 8 + x]
                for k in range(4):
                    planes[k] |= ((v >> k) & 1) << (7 - x)
            out += bytes(planes)
    return bytes(out)


def write_png(path, data, palette):
    from PIL import Image
    tiles = tiles_to_indices(data)
    n = len(tiles)
    cols = min(TILES_PER_ROW, n) or 1
    rows = (n + cols - 1) // cols
    img = Image.new("P", (cols * 8, rows * 8), 0)
    pal = []
    for c in palette:
        pal += list(c)
    img.putpalette(pal + [0] * (768 - len(pal)))
    pixels = img.load()
    for t, px in enumerate(tiles):
        tx, ty = (t % cols) * 8, (t // cols) * 8
        for i, v in enumerate(px):
            pixels[tx + i % 8, ty + i // 8] = v
    img.save(path, optimize=False)


def read_png(path, ntiles):
    from PIL import Image
    img = Image.open(path)
    if img.mode != "P":
        raise SystemExit(f"{path} : le PNG doit rester en mode indexe (palette), mode actuel {img.mode}")
    cols = img.width // 8
    pixels = img.load()
    tiles = []
    for t in range(ntiles):
        tx, ty = (t % cols) * 8, (t // cols) * 8
        px = []
        for i in range(64):
            v = pixels[tx + i % 8, ty + i // 8]
            if v > 15:
                raise SystemExit(f"{path} : indice de couleur {v} > 15 (tuile {t})")
            px.append(v)
        tiles.append(px)
    return indices_to_tiles(tiles)


# ------------------------------------------------------------------ decouverte
def discover(ver, rom):
    """Retourne {(banque, adresse): {"from": [...], "vram": int|None}}."""
    blocks = {}

    def add(bank, addr, origin, vram=None):
        e = blocks.setdefault((bank, addr), {"from": [], "vram": vram})
        e["from"].append(origin)
        if vram is not None and e["vram"] is None:
            e["vram"] = vram

    # scripts de scenes
    zs = os.path.join(ROOT, "assets", ver, "scripts", "bank05.zs")
    scene = "?"
    pal_by_scene = {}
    for line in open(zs, encoding="utf-8"):
        s = line.split(";")[0].strip()
        if s.endswith(":") and s.startswith("scene_"):
            scene = s[:-1]
        w = s.split()
        if not w:
            continue
        args = [a.strip(",") for a in w[1:]]
        if w[0] == "load_tiles":
            add(int(args[2], 0), int(args[1], 0), f"script {scene}", int(args[0], 0) & 0x3FFF)
            blocks[(int(args[2], 0), int(args[1], 0))].setdefault("scene", scene)
        elif w[0] == "load_palette":
            pal_by_scene.setdefault(scene, {}).setdefault(int(args[1], 0), (int(args[0], 0), int(args[2], 0)))
    # listes de chargement des niveaux (banque 1, tables $4C88 et $4C14 indexees par $C014) :
    # enregistrements [source][adresse VRAM][banque][00], fin = $FFFF (routine $5198)
    w = lambda a: rom[a] | (rom[a + 1] << 8)
    for table in LEVEL_GFX_TABLES:
        for lvl in range(LEVEL_COUNT):
            p = w(table + 2 * lvl)
            for _ in range(32):
                if not 0x4000 <= p < 0x8000 or w(p) == 0xFFFF:
                    break
                src, vram, bank = w(p), w(p + 2), rom[p + 4]
                if 0x8000 <= src < 0xC000 and bank * 0x4000 < len(rom):
                    add(bank, src, f"niveau {lvl:02X} (${table:04X})", vram & 0x3FFF)
                    blocks[(bank, src)].setdefault("level", lvl)
                p += 6
    # code : appels a $46A1 / $4667 avec hl et banque constants
    import run_trace
    hints = run_trace.load_hints(os.path.join(ROOT, "tools", "disasm", "hints.json"))
    tr = run_trace.build_tracer(rom, hints)
    order = sorted(tr.code)
    for i, o in enumerate(order):
        ins = tr.code[o]
        if ins.flow != "call" or ins.target not in (0x46A1, 0x4667):
            continue
        hl = bank = vram = None
        for o2 in reversed(order[max(0, i - 12):i]):
            t = tr.code[o2]
            if t.text == "ld hl,#{W}" and hl is None:
                hl = t.word
            elif t.text == "ld de,#{W}" and vram is None:
                vram = t.word
            elif t.text.startswith("ld a,#") and bank is None and hl is not None:
                bank = t.byte_imm
        if hl is not None and 0x8000 <= hl < 0xC000 and bank is not None and bank * 0x4000 < len(rom):
            add(bank, hl, f"code ${o:05X}", (vram & 0x3FFF) if ins.target == 0x46A1 and vram else None)
    return blocks, pal_by_scene


def palette_for(rom, block, pal_by_scene):
    """Palette (16 RGB) : celle chargee par la scene (fond ou sprites selon l'adresse VRAM)."""
    which = 1 if (block.get("vram") or 0) >= 0x2000 else 0
    p = pal_by_scene.get(block.get("scene"), {})
    ref = p.get(which) or p.get(1 - which)
    if ref:
        bank, src = ref
        o = bank * 0x4000 + src - 0x8000
        return [gg_color_to_rgb(rom[o + 2 * i] | (rom[o + 2 * i + 1] << 8)) for i in range(16)], f"banque {bank} ${src:04X}"
    return [(i * 17, i * 17, i * 17) for i in range(16)], "gris (palette inconnue)"


# ------------------------------------------------------------------ extraction
def extract(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    blocks, pal_by_scene = discover(ver, rom)
    manifest = []
    for (bank, addr), info in sorted(blocks.items()):
        off = bank * 0x4000 + addr - 0x8000
        try:
            data, clen = rle.decompress(rom, off)
        except (ValueError, IndexError) as e:
            print(f"  ignore banque {bank} ${addr:04X} : {e}")
            continue
        if not data or len(data) % 32:
            print(f"  ignore banque {bank} ${addr:04X} : {len(data)} octets (pas des tuiles)")
            continue
        d = os.path.join(gdir(ver), f"bank{bank:02d}")
        os.makedirs(d, exist_ok=True)
        name = f"bank{bank:02d}/{addr:04X}"
        pal, palsrc = palette_for(rom, info, pal_by_scene)
        write_png(os.path.join(gdir(ver), name + ".png"), data, pal)
        open(os.path.join(gdir(ver), name + ".rle"), "wb").write(rom[off:off + clen])
        manifest.append({"bank": bank, "addr": f"0x{addr:04X}", "file": name + ".png",
                         "tiles": len(data) // 32, "streams": rom[off], "compressed_size": clen,
                         "vram": None if info.get("vram") is None else f"0x{info['vram']:04X}",
                         "palette": palsrc, "used_by": sorted(set(info["from"]))[:6],
                         "editable": bank in ASSET_BANKS.get(ver, [])})
    os.makedirs(gdir(ver), exist_ok=True)
    with open(os.path.join(gdir(ver), "gfx.json"), "w", encoding="utf-8", newline="\n") as f:
        json.dump({"_doc": "GENERE par tools/assets/gfx.py extract. Voir docs/graphics.md.",
                   "blocks": manifest}, f, indent=1, ensure_ascii=False)
    # banques d'assets : reste brut (le build y superpose les blocs)
    for b in ASSET_BANKS.get(ver, []):
        raw = rom[b * 0x4000:(b + 1) * 0x4000]
        p = os.path.join(ROOT, "assets", ver, "raw", f"bank{b:02d}.bin")
        os.makedirs(os.path.dirname(p), exist_ok=True)
        open(p, "wb").write(raw[:len(raw.rstrip(b"\xff"))])
    tiles = sum(m["tiles"] for m in manifest)
    print(f"[{ver}] {len(manifest)} blocs, {tiles} tuiles -> {os.path.relpath(gdir(ver), ROOT)}")


# ------------------------------------------------------------------ reconstruction
def load_manifest(ver):
    return json.load(open(os.path.join(gdir(ver), "gfx.json"), encoding="utf-8"))["blocks"]


def apply_overlays(ver, bank, data, relocate=None):
    """Superpose a `data` (contenu de la banque) les blocs graphiques de cette banque.

    Un bloc modifie dont le flux depasse sa place d'origine est confie a `relocate(stream, m)`
    (deplacement dans une banque libre) ; sans `relocate`, c'est une erreur.
    """
    data = bytearray(data)
    changed = 0
    for m in load_manifest(ver):
        if m["bank"] != bank:
            continue
        addr = int(m["addr"], 16) - 0x8000
        orig = open(os.path.join(gdir(ver), m["file"][:-4] + ".rle"), "rb").read()
        old, _ = rle.decompress(orig, 0)
        new = read_png(os.path.join(gdir(ver), m["file"]), m["tiles"])
        if new == old:
            stream = orig
        else:
            stream = rle.compress(new, m["streams"])
            changed += 1
            if len(stream) > len(orig):
                if relocate is None or any(u.startswith(("code", "niveau")) for u in m["used_by"]):
                    raise SystemExit(f"{m['file']} : la version modifiee compresse en {len(stream)} octets, "
                                     f"place disponible {len(orig)}, et le bloc ne peut pas etre deplace "
                                     f"(reference par le code ou une liste de niveau) : simplifier l'image")
                relocate(stream, m)
                continue    # l'ancien emplacement garde les octets d'origine (inutilises)
        if len(data) < addr + len(stream):
            data += b"\xff" * (addr + len(stream) - len(data))
        data[addr:addr + len(stream)] = stream
    return bytes(data), changed


def build_bank(ver, bank, relocate=None):
    raw = open(os.path.join(ROOT, "assets", ver, "raw", f"bank{bank:02d}.bin"), "rb").read()
    return apply_overlays(ver, bank, raw, relocate)


# premiere banque libre (vide dans la ROM d'origine) pour les blocs deplaces
FIRST_FREE_BANK = {"sms_en": 34}
LAST_FREE_BANK = {"sms_en": 63}


def _write_bank_s(path, bank, data, origin):
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(f";; GENERE par tools/assets/gfx.py ({origin}) - ne pas modifier\n")
        f.write(f"\t.area _B{bank:02d}_8000\n")
        for i in range(0, len(data), 16):
            f.write("\t.db " + ", ".join("0x%02x" % x for x in data[i:i + 16]) + "\n")


def build(ver, quiet=False):
    """Construit les banques graphiques. Ecrit generated/gfx_reloc.json (blocs deplaces)
    et retourne la liste des banques supplementaires utilisees (a ajouter au layout)."""
    if ver not in EDITABLE:
        return None
    gen = os.path.join(ROOT, "build", ver, "generated")
    os.makedirs(gen, exist_ok=True)
    total = 0
    reloc = {}                       # "banque:adresse" d'origine -> [banque, adresse]
    extra = {}                       # banque libre -> bytearray
    cur = [FIRST_FREE_BANK[ver]]

    def relocate(stream, m):
        b = cur[0]
        while len(extra.get(b, b"")) + len(stream) > 0x4000:
            b += 1
            if b > LAST_FREE_BANK[ver]:
                raise SystemExit("plus de banque libre pour deplacer les graphismes modifies")
        cur[0] = b
        buf = extra.setdefault(b, bytearray())
        reloc[f"{m['bank']}:{m['addr']}"] = [b, 0x8000 + len(buf)]
        buf += stream

    for b in ASSET_BANKS.get(ver, []):
        data, changed = build_bank(ver, b, relocate)
        total += changed
        _write_bank_s(os.path.join(gen, f"data_gfx_bank{b:02d}.s"), b, data, f"assets/{ver}/gfx + raw/bank{b:02d}.bin")
    for b, data in extra.items():
        _write_bank_s(os.path.join(gen, f"data_gfx_moved_bank{b:02d}.s"), b, data, "blocs deplaces")
    with open(os.path.join(gen, "gfx_reloc.json"), "w", encoding="utf-8", newline="\n") as f:
        json.dump(reloc, f, indent=1)
    if not quiet:
        print(f"[{ver}] graphismes : {total} bloc(s) modifie(s), {len(reloc)} deplace(s)"
              + (f" vers les banques {sorted(extra)}" if extra else ""))
    return sorted(extra)


def check(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    ok = True
    for b in ASSET_BANKS.get(ver, []):
        data, _ = build_bank(ver, b)
        orig = rom[b * 0x4000:(b + 1) * 0x4000]
        data = data + b"\xff" * (len(orig) - len(data))
        if data != orig:
            ok = False
            d = next(i for i in range(len(orig)) if data[i] != orig[i])
            print(f"[{ver}] banque {b} : DIFFERENCE a ${0x8000 + d:04X}")
    # tous les PNG (meme hors banques d'assets) doivent redonner leur flux
    bad = 0
    for m in load_manifest(ver):
        orig = open(os.path.join(gdir(ver), m["file"][:-4] + ".rle"), "rb").read()
        if read_png(os.path.join(gdir(ver), m["file"]), m["tiles"]) != rle.decompress(orig, 0)[0]:
            bad += 1
    print(f"[{ver}] graphismes : banques {'IDENTIQUES' if ok else 'DIFFERENTES'} ; PNG <-> tuiles : "
          f"{len(load_manifest(ver)) - bad}/{len(load_manifest(ver))} exacts")
    return ok and not bad


def GUARDED(ver):
    p = os.path.join(gdir(ver), "gfx.json")
    return [p] if os.path.exists(p) else []


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    opts = dict(a.split("=", 1) for a in sys.argv[2:])
    ver = opts.get("VERSION", "sms_en")
    if cmd == "extract":
        if GUARDED(ver) and opts.get("FORCE") != "1":
            print("REFUS : assets/" + ver + "/gfx existe deja (PNG modifies perdus).")
            sys.exit("Relancer avec FORCE=1 pour repartir de la ROM d'origine.")
        extract(ver)
    elif cmd == "build":
        build(ver)
    elif cmd == "check":
        sys.exit(0 if check(ver) else 1)
    else:
        sys.exit(__doc__)
