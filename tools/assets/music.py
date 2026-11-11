#!/usr/bin/env python3
"""Musique et effets sonores (driver type SMPS 8 bits, banques 26-27).

Usage :
  python tools/assets/music.py extract VERSION=sms_en [FORCE=1]  # -> assets/<ver>/music/music.smps
  python tools/assets/music.py build   VERSION=sms_en            # -> build/<ver>/generated/data_music.s
  python tools/assets/music.py check   VERSION=sms_en

Zones : banque 26 $4B15-$7FFF (vue CPU slot 1) et banque 27 (vue $8000).
Morceaux : table $56B1 (26 musiques, ids $81-$9A) ; effets : table $56E5 (39, ids $A0-$C6).
En-tete musique : [enveloppes mot][nb voies][00][multiplicateur][tempo] + par voie [piste mot][transposition][volume]
En-tete effet   : [enveloppes mot][priorite][nb voies] + par voie [80][canal][piste mot][transposition][volume]
Piste : octets < $E1 = notes ($80-$E0, $80 = silence) ou durees (< $80) ;
        $E1-$FF = drapeaux de coordination (table $47D1), voir FLAGS.
Syntaxe du .smps : `.section banque adresse`, labels, `.db`, `.dw`, et les drapeaux par leur nom.
Les labels music_* sont globaux (utilises par le code du driver).
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, ".."))
from toolchain import ROOT  # noqa: E402

ROMS = {"sms_en": "original/Kishin_Douji_Zenki_GG2SMS_v0_3__EN_.sms",
        "gg_jp": "original/Kishin Douji Zenki (J).gg"}
SECTIONS = [(26, 0x4B15, 0x8000), (27, 0x8000, 0xC000)]
SONG_TABLE, SONGS = 0x56B1, 26
SFX_TABLE, SFX = 0x56E5, 39
EXPORTED = {0x4B15: "music_priorities", 0x4B74: "music_envelopes", 0x5692: "music_table_5692",
            0x56B1: "music_song_table", 0x56E5: "music_sfx_table"}

# drapeaux : code -> (nom, types des arguments, flot)   b octet, p pointeur de piste
FLAGS = {
    0xE1: ("detune", "b", "cont"), 0xE2: ("pan_e2", "b", "cont"), 0xE3: ("volume_add", "b", "cont"),
    0xE4: ("flag_e4", "b", "cont"), 0xE5: ("volume_set", "b", "cont"), 0xE6: ("tempo", "b", "cont"),
    0xE7: ("hold", "", "cont"), 0xE8: ("modulation", "bbbb", "cont"), 0xE9: ("psg_noise", "b", "cont"),
    0xEA: ("envelope", "b", "cont"), 0xEB: ("note_fill", "b", "cont"), 0xEC: ("flag_ec", "b", "cont"),
    0xED: ("flag_ed", "b", "cont"), 0xEE: ("transpose", "b", "cont"), 0xEF: ("jump", "p", "end"),
    0xF0: ("return", "", "end"), 0xF1: ("call", "p", "cont"), 0xF2: ("stop", "", "end"),
    0xF3: ("loop_n", "bbp", "cont"), 0xF4: ("loop0", "bp", "cont"), 0xF5: ("loop1", "bp", "cont"),
    0xF6: ("loop2", "bp", "cont"), 0xF7: ("loop3", "bp", "cont"), 0xF8: ("break_n", "bp", "cont"),
    0xF9: ("break0", "p", "cont"), 0xFA: ("break1", "p", "cont"), 0xFB: ("break2", "p", "cont"),
    0xFC: ("break3", "p", "cont"), 0xFD: ("flag_fd", "b", "cont"), 0xFE: ("flag_fe", "b", "cont"),
    0xFF: ("flag_ff", "b", "cont"),
}
NAMES = {v[0]: k for k, v in FLAGS.items()}
SIZES = {"b": 1, "p": 2}


def path_of(ver):
    return os.path.join(ROOT, "assets", ver, "music", "music.smps")


class Mem:
    def __init__(self, rom):
        self.rom = rom

    def sec(self, a):
        for b, lo, hi in SECTIONS:
            if lo <= a < hi:
                return b
        return None

    def rd(self, a):
        b = self.sec(a)
        return self.rom[b * 0x4000 + (a & 0x3FFF)]

    def w(self, a):
        return self.rd(a) | (self.rd(a + 1) << 8)


def analyse(rom):
    m = Mem(rom)
    items = {}       # adresse -> (taille, rendu, [pointeurs])
    labels = dict(EXPORTED)
    tracks = []

    def lab(a, name):
        labels.setdefault(a, name)

    items[SONG_TABLE] = (2 * SONGS, "songtable", None)
    items[SFX_TABLE] = (2 * SFX, "sfxtable", None)
    for i in range(SONGS):
        h = m.w(SONG_TABLE + 2 * i)
        lab(h, f"song_{0x81 + i:02X}")
        n = m.rd(h + 2)
        items.setdefault(h, (6 + 4 * n, "song", n))
        for c in range(n):
            t = m.w(h + 6 + 4 * c)
            lab(t, f"song_{0x81 + i:02X}_ch{c}")
            tracks.append(t)
    for i in range(SFX):
        h = m.w(SFX_TABLE + 2 * i)
        lab(h, f"sfx_{0xA0 + i:02X}")
        n = m.rd(h + 3)
        items.setdefault(h, (4 + 6 * n, "sfx", n))
        for c in range(n):
            t = m.w(h + 4 + 6 * c + 2)
            lab(t, f"sfx_{0xA0 + i:02X}_ch{c}")
            tracks.append(t)
    owner = {}
    seen = set()
    while tracks:
        a = tracks.pop()
        while a not in seen and m.sec(a) is not None:
            seen.add(a)
            c = m.rd(a)
            if c < 0xE1:
                items[a] = (1, "byte", c)
                a += 1
                continue
            name, types, flow = FLAGS[c]
            args, p = [], a + 1
            for t in types:
                if t == "b":
                    args.append(("b", m.rd(p)))
                    p += 1
                else:
                    v = m.w(p)
                    args.append(("p", v))
                    lab(v, f"L_{v:04X}")
                    tracks.append(v)
                    p += 2
            items[a] = (p - a, "flag", (c, args))
            if flow == "end":
                break
            a = p
    return m, items, labels


def extract(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    m, items, labels = analyse(rom)
    out = [f"; Musique et effets sonores - version {ver} (driver SMPS 8 bits, banques 26-27)",
           "; GENERE par tools/assets/music.py extract, puis edite a la main. Voir docs/music.md.",
           "; Notes : $80 = silence, $81-$E0 = hauteurs ; octets < $80 = durees.", ""]
    for bank, lo, hi in SECTIONS:
        end = lo + len(rom[bank * 0x4000 + (lo & 0x3FFF):bank * 0x4000 + 0x4000].rstrip(b"\xff"))
        out.append(f".section {bank} 0x{lo:04X}")
        a, pending, notes = lo, [], []

        def flush():
            while pending:
                chunk = pending[:16]
                del pending[:16]
                out.append("\t.db " + ", ".join("0x%02x" % b for b in chunk))
            while notes:
                chunk = notes[:16]
                del notes[:16]
                out.append("\tnotes " + ", ".join("0x%02x" % b for b in chunk))

        while a < end:
            if a in labels:
                flush()
                out.append("")
                out.append(f"{labels[a]}{'::' if a in EXPORTED else ':'}")
            it = items.get(a)
            if it is None:
                if notes:
                    flush()
                pending.append(m.rd(a))
                a += 1
                continue
            size, kind, x = it
            if kind == "byte":
                if pending:
                    flush()
                notes.append(x)
            else:
                flush()
                if kind in ("songtable", "sfxtable"):
                    n = SONGS if kind == "songtable" else SFX
                    for i in range(n):
                        v = m.w(a + 2 * i)
                        out.append(f"\t.dw {labels.get(v, '0x%04x' % v)}")
                elif kind == "song":
                    env = m.w(a)
                    out.append(f"\t.dw {labels.get(env, '0x%04x' % env)}          ; enveloppes")
                    out.append(f"\t.db 0x{m.rd(a + 2):02x}, 0x{m.rd(a + 3):02x}, 0x{m.rd(a + 4):02x}, 0x{m.rd(a + 5):02x}"
                               "   ; voies, 0, multiplicateur, tempo")
                    for c in range(x):
                        o = a + 6 + 4 * c
                        t = m.w(o)
                        out.append(f"\t.dw {labels.get(t, '0x%04x' % t)}\n\t.db 0x{m.rd(o + 2):02x}, 0x{m.rd(o + 3):02x}"
                                   f"   ; voie {c} : transposition, volume")
                elif kind == "sfx":
                    env = m.w(a)
                    out.append(f"\t.dw {labels.get(env, '0x%04x' % env)}          ; enveloppes")
                    out.append(f"\t.db 0x{m.rd(a + 2):02x}, 0x{m.rd(a + 3):02x}   ; priorite, voies")
                    for c in range(x):
                        o = a + 4 + 6 * c
                        t = m.w(o + 2)
                        out.append(f"\t.db 0x{m.rd(o):02x}, 0x{m.rd(o + 1):02x}\n\t.dw {labels.get(t, '0x%04x' % t)}"
                                   f"\n\t.db 0x{m.rd(o + 4):02x}, 0x{m.rd(o + 5):02x}   ; voie {c} : canal, piste, transposition, volume")
                else:
                    code, args = x
                    parts = [labels.get(v, "0x%04x" % v) if t == "p" else "0x%02x" % v for t, v in args]
                    out.append(f"\t{FLAGS[code][0]}" + (" " + ", ".join(parts) if parts else ""))
            a += size
        flush()
        out.append("")
    p = path_of(ver)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    open(p, "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")
    nflags = sum(1 for v in items.values() if v[1] == "flag")
    print(f"[{ver}] {SONGS} musiques, {SFX} effets, {nflags} drapeaux -> {os.path.relpath(p, ROOT)}")


def assemble(text, remap=None):
    """Retourne ({banque: (base, octets)}, labels).

    remap : {banque: (nouvelle_banque, nouvelle_base)} pour deplacer une section (ROM512).
    """
    lines = [(n, raw.split(";", 1)[0].strip()) for n, raw in enumerate(text.splitlines(), 1)]
    lines = [(n, s) for n, s in lines if s]
    labels = {}
    for pass_ in (1, 2):
        secs, cur = {}, None
        for n, s in lines:
            try:
                if s.startswith(".section"):
                    _, b, base = s.split()
                    cur, base = int(b), int(base, 0)
                    if remap and cur in remap:
                        cur, base = remap[cur]
                    secs[cur] = (base, bytearray())
                    continue
                base, buf = secs[cur]
                pc = base + len(buf)
                if s.endswith(":"):
                    if pass_ == 1:
                        labels[s.rstrip(":")] = pc
                    continue
                word, _, rest = s.partition(" ")
                args = [x.strip() for x in rest.split(",") if x.strip()]

                def val(t):
                    if pass_ == 1:
                        return 0
                    if re.fullmatch(r"(0x[0-9a-fA-F]+|\d+)", t):
                        return int(t, 0)
                    return labels[t]
                if word in (".db", "notes"):
                    buf += bytes(val(x) & 0xFF for x in args)
                elif word == ".dw":
                    for x in args:
                        v = val(x)
                        buf += bytes([v & 0xFF, (v >> 8) & 0xFF])
                elif word in NAMES:
                    code = NAMES[word]
                    types = FLAGS[code][1]
                    if len(args) != len(types):
                        raise ValueError(f"{word} attend {len(types)} argument(s)")
                    buf.append(code)
                    for t, x in zip(types, args):
                        v = val(x)
                        buf += bytes([v & 0xFF]) if t == "b" else bytes([v & 0xFF, (v >> 8) & 0xFF])
                else:
                    raise ValueError(f"instruction inconnue : {word}")
            except KeyError as e:
                raise SystemExit(f"music.smps ligne {n} : label inconnu {e}")
            except ValueError as e:
                raise SystemExit(f"music.smps ligne {n} : {e}")
    for b, (base, buf) in secs.items():
        if base + len(buf) > (base & 0xC000) + 0x4000:
            raise SystemExit(f"music.smps : la section banque {b} deborde ({len(buf)} octets)")
    return secs, labels


def section_sizes(ver):
    """{banque: octets} de chaque section (avant tout deplacement)."""
    secs, _ = assemble(open(path_of(ver), encoding="utf-8").read())
    return {b: len(buf) for b, (_, buf) in secs.items()}


def build(ver, quiet=False, remap=None):
    secs, labels = assemble(open(path_of(ver), encoding="utf-8").read(), remap)
    exported = {a: n for n, a in labels.items() if n.startswith("music_")}
    gen = os.path.join(ROOT, "build", ver, "generated")
    os.makedirs(gen, exist_ok=True)
    with open(os.path.join(gen, "data_music.s"), "w", encoding="utf-8", newline="\n") as f:
        f.write(f";; GENERE par tools/assets/music.py depuis assets/{ver}/music/music.smps - ne pas modifier\n")
        for b, (base, buf) in secs.items():
            f.write(f"\n\t.area _B{b:02d}_{base:04X}\n")
            cuts = sorted({0, len(buf)} | {a - base for a in exported if base <= a < base + len(buf)})
            for s, e in zip(cuts, cuts[1:]):
                if base + s in exported:
                    f.write(f"{exported[base + s]}::\n")
                for i in range(s, e, 16):
                    f.write("\t.db " + ", ".join("0x%02x" % x for x in buf[i:min(i + 16, e)]) + "\n")
    if not quiet:
        print(f"[{ver}] musique : " + ", ".join(f"banque {b} {len(buf)} o" for b, (_, buf) in secs.items()))
    return secs


def check(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    secs = build(ver, quiet=True)
    ok = True
    for b, lo, hi in SECTIONS:
        base, buf = secs[b]
        orig = rom[b * 0x4000 + (lo & 0x3FFF):b * 0x4000 + 0x4000]
        if bytes(buf) + b"\xff" * (len(orig) - len(buf)) != orig:
            ok = False
            d = next((i for i in range(min(len(buf), len(orig))) if buf[i] != orig[i]), None)
            print(f"   banque {b} : ecart a ${lo + (d or 0):04X}")
    print(f"[{ver}] musique : {'IDENTIQUE a la ROM d origine' if ok else 'DIFFERENTE'}")
    return ok


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    opts = dict(a.split("=", 1) for a in sys.argv[2:])
    ver = opts.get("VERSION", "sms_en")
    if cmd == "extract":
        if os.path.exists(path_of(ver)) and opts.get("FORCE") != "1":
            sys.exit("REFUS : " + os.path.relpath(path_of(ver), ROOT) + " existe deja (FORCE=1 pour l'ecraser).")
        extract(ver)
    elif cmd == "build":
        build(ver)
    elif cmd == "check":
        sys.exit(0 if check(ver) else 1)
    else:
        sys.exit(__doc__)
