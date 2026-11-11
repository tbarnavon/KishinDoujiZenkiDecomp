#!/usr/bin/env python3
"""ROM de 512 Ko (option de build ROM512=1, SMS EN) : plan de placement.

La ROM SMS EN fait 1 Mo mais n'utilise que les banques 0-33 (+ 63 pour la vue elargie).
Les banques 32 (dialogues anglais) et 33 (ecrans de texte, tuiles et tilemaps ajoutes par la
traduction) sont replacees dans la place libre des banques 0-31 :

  - musique (banque 27, 2 405 octets) -> fin de la banque 24 ; le pilote son selectionne la
    banque 24 au lieu de 27 (src/core/irq.s $023C, src/audio/sound_api.s $05E3) ;
  - dialogues (banque 32) -> debut de la banque 27 (la table des pointeurs doit rester en
    $8000) ; le moteur de texte selectionne la banque 27 ($68A7, $68C7) ;
  - banque 33 : decoupee en blocs (un bloc commence a chaque adresse referencee par les
    scripts de scenes, seuls a y acceder : load_vram / load_tiles avec la banque $21) ;
    chaque bloc va dans la place libre en fin d'une banque (le plus grand d'abord, dans le
    plus petit trou qui le contient) ; les references des scripts sont corrigees a la
    compilation (table gfx_reloc.json, comme pour les graphismes deplaces) ;
  - code des contours noirs de boss (vue elargie, banque 63) -> banque 17 en $BF00.

Les trous sont calcules a chaque build depuis la taille des banques composees : si un asset
grossit, le plan s'adapte (et le build signale tout chevauchement).
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

MUSIC_BANK = 24           # nouvelle banque de la musique (ex-banque 27)
TEXT_BANK = 27            # nouvelle banque des dialogues (ex-banque 32)
WIDE_BANK, WIDE_ADDR = 17, 0xBF00   # code des contours noirs de boss (ex-banque 63)
OLD_SCREEN_BANK = 33


def single_area_banks(ver):
    """Banques de donnees dont le layout ne contient qu'une area : on peut y ajouter des blocs."""
    cur, areas = None, {}
    for line in open(os.path.join(ROOT, "config", f"layout_{ver}.cfg"), encoding="utf-8"):
        w = line.split("#", 1)[0].split()
        if not w:
            continue
        if w[0] == "bank":
            cur = int(w[1])
            areas.setdefault(cur, [])
        elif w[0] != "rom_size" and cur is not None:
            areas[cur].append(w[0])
    return {b for b, a in areas.items() if len(a) == 1 and 2 <= b < 32}


def screen_refs(ver):
    """Adresses de la banque 33 referencees par les scripts de scenes."""
    refs = set()
    txt = open(os.path.join(ROOT, "assets", ver, "scripts", "bank05.zs"), encoding="utf-8").read()
    for line in txt.splitlines():
        s = line.split(";", 1)[0].strip()
        word, _, rest = s.partition(" ")
        args = [a.strip() for a in rest.split(",") if a.strip()]
        if word == "load_vram" and len(args) == 5 and int(args[4], 0) == OLD_SCREEN_BANK:
            refs.add(int(args[0], 0))
        elif word == "load_tiles" and len(args) == 3 and int(args[2], 0) == OLD_SCREEN_BANK:
            refs.add(int(args[1], 0))
    return refs


def plan(ver, composed, bank33, dialogs_len, music_len, wide):
    """composed : {banque: octets} des banques composees ; bank33 : octets de la banque 33.
    Retourne (areas [(nom, banque, adresse, octets)], reloc {"33:0xADDR": [banque, adresse]},
    music_base)."""
    holes = {}
    for b in single_area_banks(ver) & set(composed):
        if b != OLD_SCREEN_BANK:
            holes[b] = [0x8000 + len(composed[b]), 0xC000]
    holes[TEXT_BANK] = [0x8000 + dialogs_len, 0xC000]
    if MUSIC_BANK not in holes:
        raise SystemExit(f"ROM512 : banque {MUSIC_BANK} indisponible pour la musique")
    music_base = 0xC000 - music_len
    if music_base < holes[MUSIC_BANK][0]:
        raise SystemExit(f"ROM512 : la musique ({music_len} o) ne tient pas en banque {MUSIC_BANK}")
    holes[MUSIC_BANK][1] = music_base
    if wide:
        if holes.get(WIDE_BANK, [0xC000])[0] > WIDE_ADDR:
            raise SystemExit(f"ROM512 : pas de place en banque {WIDE_BANK} pour le code de la vue elargie")
        holes[WIDE_BANK][1] = WIDE_ADDR

    data = bytes(bank33).rstrip(b"\xff")
    starts = sorted(a - 0x8000 for a in screen_refs(ver) if 0x8000 <= a < 0x8000 + len(data))
    if not starts or starts[0] != 0:
        starts = [0] + starts
    blocks = [(starts[i], (starts[i + 1] if i + 1 < len(starts) else len(data))) for i in range(len(starts))]
    areas, reloc = [], {}
    for s, e in sorted(blocks, key=lambda x: x[1] - x[0], reverse=True):
        size = e - s
        fit = [(h[1] - h[0], b) for b, h in holes.items() if h[1] - h[0] >= size]
        if not fit:
            raise SystemExit(f"ROM512 : plus de place pour le bloc ${0x8000 + s:04X} de la banque 33 "
                             f"({size} octets)")
        _, b = min(fit)
        addr = holes[b][1] - size
        holes[b][1] = addr
        areas.append((f"_B{b:02d}_{addr:04X}", b, addr, data[s:e]))
        reloc[f"{OLD_SCREEN_BANK}:0x{0x8000 + s:04X}"] = [b, addr]
    return areas, reloc, music_base

