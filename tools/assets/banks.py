#!/usr/bin/env python3
"""Compositeur des banques de donnees (version SMS EN).

Chaque banque de donnees (sans code) est reconstruite a partir de :
  assets/<ver>/raw/bankNN.bin            contenu brut (octets non decodes)
  + les superpositions des formats decodes, dans cet ordre :
      gfx       tuiles compressees (PNG)          tools/assets/gfx.py
      palettes  palettes (JSON)                   tools/assets/palettes.py
      tilemaps  tilemaps (CSV)                    tools/assets/tilemaps.py
      niveaux   cartes, metatuiles, attributs     tools/assets/levels.py
      sprites   meta-sprites (banque 24)          tools/assets/sprites.py
      ennemis   placement des ennemis (banque 4)  tools/assets/enemies.py
      screens   ecrans de texte (banque 33)       tools/assets/text.py
Sortie : build/<ver>/generated/data_bankNN.s (+ banques libres utilisees par les blocs deplaces).

Usage :
  python tools/assets/banks.py extract VERSION=sms_en   # cree les raw/bankNN.bin manquants
  python tools/assets/banks.py check   VERSION=sms_en   # compose et compare a la ROM
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
# banques sans code : entierement reconstruites depuis assets/ (banque 5 = scripts, 32 = dialogues)
COMPOSED = {"sms_en": [3, 4] + list(range(6, 23)) + [24, 28, 29, 30, 31, 33]}   # 27 : musique (music.py)
FIRST_FREE_BANK = {"sms_en": 34}
LAST_FREE_BANK = {"sms_en": 62}   # 63 : code de la vue elargie (WIDE=1)


def raw_path(ver, bank):
    return os.path.join(ROOT, "assets", ver, "raw", f"bank{bank:02d}.bin")


def providers():
    import gfx
    import palettes
    import tilemaps
    import text
    import levels
    import sprites
    import enemies
    return [("gfx", gfx.apply_overlays), ("palettes", palettes.apply_overlays),
            ("ennemis", enemies.apply_overlays),
            ("tilemaps", tilemaps.apply_overlays), ("niveaux", levels.apply_overlays),
            ("sprites", sprites.apply_overlays),
            ("screens", text.apply_screens)]


def extract(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    n = 0
    for b in COMPOSED.get(ver, []):
        p = raw_path(ver, b)
        if os.path.exists(p):
            continue
        raw = rom[b * 0x4000:(b + 1) * 0x4000]
        os.makedirs(os.path.dirname(p), exist_ok=True)
        open(p, "wb").write(raw[:len(raw.rstrip(b"\xff"))])
        n += 1
    print(f"[{ver}] {n} banque(s) brute(s) creee(s) dans assets/{ver}/raw/")


def compose(ver):
    """Retourne ({banque: octets}, {banque_libre: octets}, reloc, stats)."""
    reloc, extra, cur = {}, {}, [FIRST_FREE_BANK[ver]]

    def relocate(stream, m):
        b = cur[0]
        while len(extra.get(b, b"")) + len(stream) > 0x4000:
            b += 1
            if b > LAST_FREE_BANK[ver]:
                raise SystemExit("plus de banque libre pour deplacer les donnees modifiees")
        cur[0] = b
        buf = extra.setdefault(b, bytearray())
        reloc[f"{m['bank']}:{m['addr']}"] = [b, 0x8000 + len(buf)]
        buf += stream

    out, stats = {}, {}
    provs = providers()
    for b in COMPOSED.get(ver, []):
        data = open(raw_path(ver, b), "rb").read()
        for name, fn in provs:
            data, changed = fn(ver, b, data, relocate)
            stats[name] = stats.get(name, 0) + changed
        if len(data) > 0x4000:
            raise SystemExit(f"banque {b} : {len(data)} octets, depasse 16 Ko")
        out[b] = data
    return out, extra, reloc, stats


def write_s(path, bank, data, origin):
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(f";; GENERE par tools/assets/banks.py ({origin}) - ne pas modifier\n")
        f.write(f"\t.area _B{bank:02d}_8000\n")
        for i in range(0, len(data), 16):
            f.write("\t.db " + ", ".join("0x%02x" % x for x in data[i:i + 16]) + "\n")


def build(ver, quiet=False, rom512=None):
    """Ecrit les .s des banques composees ; retourne les banques libres utilisees.

    rom512 : None, ou {"wide": bool} pour une ROM de 512 Ko (voir rom512.py) : la banque 33
    est decoupee dans la place libre des banques 0-31 ; ecrit aussi rom512_areas.json
    (areas a placer par build.py) et ajoute les blocs deplaces a la table de relogement.
    """
    if ver not in COMPOSED:
        return None
    gen = os.path.join(ROOT, "build", ver, "generated")
    os.makedirs(gen, exist_ok=True)
    out, extra, reloc, stats = compose(ver)
    if rom512 is not None:
        import rom512 as r5
        import text
        import music
        if extra:
            raise SystemExit("ROM512 : des graphismes agrandis demandent les banques 34-63 ; "
                             "impossible en 512 Ko")
        dialogs = text.compile_bank(ver)
        msizes = music.section_sizes(ver)
        bank33 = out.pop(r5.OLD_SCREEN_BANK)
        areas, reloc33, music_base = r5.plan(ver, out, bank33, len(dialogs), msizes[27],
                                             rom512.get("wide", False))
        reloc.update(reloc33)
        with open(os.path.join(gen, "data_rom512.s"), "w", encoding="utf-8", newline="\n") as f:
            f.write(";; GENERE par tools/assets/banks.py (ROM512 : blocs de l'ex-banque 33) - ne pas modifier\n")
            for name, b, addr, data in areas:
                f.write(f"\n\t.area {name}\t\t; ex-banque 33 -> banque {b} ${addr:04X}\n")
                for i in range(0, len(data), 16):
                    f.write("\t.db " + ", ".join("0x%02x" % x for x in data[i:i + 16]) + "\n")
        placed = [[name, b, addr] for name, b, addr, _ in areas]
        placed.append([f"_B{r5.MUSIC_BANK:02d}_{music_base:04X}", r5.MUSIC_BANK, music_base])
        if rom512.get("wide"):
            placed.append([f"_B{r5.WIDE_BANK:02d}_WIDE", r5.WIDE_BANK, r5.WIDE_ADDR])
        with open(os.path.join(gen, "rom512_areas.json"), "w", encoding="utf-8", newline="\n") as f:
            json.dump({"areas": placed, "music": [r5.MUSIC_BANK, music_base],
                       "text_bank": r5.TEXT_BANK}, f, indent=1)
        if not quiet:
            print(f"[{ver}] ROM512 : banque 33 en {len(areas)} blocs -> banques "
                  f"{sorted({b for _, b, _, _ in areas})} ; musique -> banque {r5.MUSIC_BANK} ${music_base:04X}")
    for b, data in out.items():
        write_s(os.path.join(gen, f"data_bank{b:02d}.s"), b, data, f"assets/{ver}")
    for b, data in extra.items():
        write_s(os.path.join(gen, f"data_moved_bank{b:02d}.s"), b, data, "blocs deplaces")
    with open(os.path.join(gen, "gfx_reloc.json"), "w", encoding="utf-8", newline="\n") as f:
        json.dump(reloc, f, indent=1)
    if not quiet:
        mods = ", ".join(f"{k} {v}" for k, v in stats.items() if v)
        print(f"[{ver}] banques de donnees : {len(out)} composees"
              + (f" ; modifies : {mods}" if mods else "")
              + (f" ; deplaces vers {sorted(extra)}" if extra else ""))
    return sorted(extra)


def check(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    out, extra, reloc, _ = compose(ver)
    bad = []
    for b, data in out.items():
        orig = rom[b * 0x4000:(b + 1) * 0x4000]
        if data + b"\xff" * (len(orig) - len(data)) != orig:
            bad.append(b)
    print(f"[{ver}] banques composees : {len(out) - len(bad)}/{len(out)} identiques"
          + (f" ; DIFFERENTES : {bad}" if bad else ""))
    return not bad


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    opts = dict(a.split("=", 1) for a in sys.argv[2:])
    ver = opts.get("VERSION", "sms_en")
    if cmd == "extract":
        extract(ver)
    elif cmd == "check":
        sys.exit(0 if check(ver) else 1)
    else:
        sys.exit(__doc__)
