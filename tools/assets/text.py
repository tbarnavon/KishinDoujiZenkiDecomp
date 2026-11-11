#!/usr/bin/env python3
"""Textes des dialogues : extraction en fichier texte editable et recompilation.

Usage :
  python tools/assets/text.py extract VERSION=sms_en   # ROM -> assets/sms_en/text/strings.txt + charset.tbl
  python tools/assets/text.py build   VERSION=sms_en   # -> build/sms_en/generated/data_text.s
  python tools/assets/text.py check   VERSION=sms_en   # recompile et compare a la ROM
  python tools/assets/text.py extract VERSION=gg_jp    # GG JP : export en LECTURE SEULE (reference)

SMS EN : banque 32 = table de 218 pointeurs en $8000, puis les chaines dans l'ordre, puis $FF.
GG JP  : banque 28 = meme table, mais chaines desordonnees et melangees a d'autres donnees :
         pas de recompilation (la banque reste en .db dans src/).

strings.txt : une ligne par chaine, « [NNN] texte ». Dans le texte :
  \\n = nouvelle ligne ($0D), {XX} = octet brut en hexadecimal, autres caracteres via charset.tbl.
  Les espaces en debut/fin de texte comptent (ils positionnent le texte dans la fenetre).
charset.tbl : lignes « XX=c » (octet hexadecimal = caractere), a completer si besoin.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, ".."))
from toolchain import ROOT  # noqa: E402
import textcodec  # noqa: E402

ROMS = {"sms_en": "original/Kishin_Douji_Zenki_GG2SMS_v0_3__EN_.sms",
        "gg_jp": "original/Kishin Douji Zenki (J).gg"}
COUNT = 218                       # nombre de chaines (numeros 0-217 utilises par les scripts)
EDITABLE = {"sms_en"}


def tdir(ver):
    return os.path.join(ROOT, "assets", ver, "text")


def load_charset(ver):
    """octet -> caractere, depuis charset.tbl (sinon la table integree)."""
    path = os.path.join(tdir(ver), "charset.tbl")
    if not os.path.exists(path):
        return {k: v for k, v in (textcodec.EN if ver == "sms_en" else {}).items() if k not in (0x0D,)}
    cs = {}
    for line in open(path, encoding="utf-8"):
        line = line.rstrip("\n")
        if not line or line.startswith("#"):
            continue
        k, _, v = line.partition("=")
        cs[int(k, 16)] = v
    return cs


def decode(data, cs):
    out = []
    for b in data:
        if b == 0x0D:
            out.append("\\n")
        elif b in cs and cs[b] not in ("{", "}", "\\"):
            out.append(cs[b])
        else:
            out.append("{%02X}" % b)
    return "".join(out)


def encode(text, cs, where=""):
    rev = {}
    for k, v in sorted(cs.items()):
        rev.setdefault(v, k)
    out, i = bytearray(), 0
    while i < len(text):
        if text.startswith("\\n", i):
            out.append(0x0D)
            i += 2
        elif text[i] == "{":
            m = re.match(r"\{([0-9A-Fa-f]{2})\}", text[i:])
            if not m:
                raise SystemExit(f"{where} : code brut invalide pres de '{text[i:i + 6]}'")
            out.append(int(m.group(1), 16))
            i += 4
        elif text[i] in rev:
            out.append(rev[text[i]])
            i += 1
        else:
            raise SystemExit(f"{where} : caractere '{text[i]}' absent de charset.tbl")
    if 0 in out:
        raise SystemExit(f"{where} : l'octet 00 est reserve a la fin de chaine")
    return bytes(out)


def read_bank(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    b = textcodec.TEXT_BANK[ver]
    return rom[b * 0x4000:(b + 1) * 0x4000]


def extract(ver):
    bank = read_bank(ver)
    w = lambda o: bank[o] | (bank[o + 1] << 8)
    os.makedirs(tdir(ver), exist_ok=True)
    cs_path = os.path.join(tdir(ver), "charset.tbl")
    if ver == "sms_en" and not os.path.exists(cs_path):
        with open(cs_path, "w", encoding="utf-8", newline="\n") as f:
            f.write("# Table de caracteres EN : octet (numero de tuile de la police) = caractere\n")
            f.write("# $00 = fin de chaine et $0D = nouvelle ligne sont geres par l'outil.\n")
            f.write("# Ponctuation deduite du contexte : a confirmer avec la police (banque 9).\n")
            for k, v in sorted(textcodec.EN.items()):
                if k != 0x0D:
                    f.write(f"{k:02X}={v}\n")
    cs = load_charset(ver)
    lines = []
    for i in range(COUNT):
        o = w(2 * i) - 0x8000
        e = bank.index(b"\x00", o)
        lines.append(f"[{i:03d}] {decode(bank[o:e], cs)}")
    name = "strings.txt" if ver in EDITABLE else "strings_reference.txt"
    head = [f"# Textes des dialogues - version {ver} - banque {textcodec.TEXT_BANK[ver]}",
            "# [NNN] = numero utilise par l'opcode `text` des scripts (assets/<ver>/scripts/bank05.zs).",
            "# \\n = nouvelle ligne, {XX} = octet brut ; espaces de debut/fin significatifs."]
    if ver not in EDITABLE:
        head.append("# LECTURE SEULE : reference (non recompile). Kana non decodes : codes {XX}.")
    else:
        head.append("# Fichier EDITE A LA MAIN puis recompile au build (tools/assets/text.py build).")
    path = os.path.join(tdir(ver), name)
    open(path, "w", encoding="utf-8", newline="\n").write("\n".join(head + [""] + lines) + "\n")
    print(f"[{ver}] {COUNT} chaines -> {os.path.relpath(path, ROOT)}")


def compile_bank(ver):
    cs = load_charset(ver)
    path = os.path.join(tdir(ver), "strings.txt")
    strings = {}
    for n, line in enumerate(open(path, encoding="utf-8"), 1):
        line = line.rstrip("\n")
        if not line.startswith("["):
            continue
        m = re.match(r"\[(\d+)\] ?(.*)$", line)
        if not m:
            raise SystemExit(f"{path}:{n} : ligne invalide")
        idx = int(m.group(1))
        if idx in strings:
            raise SystemExit(f"{path}:{n} : numero {idx} en double")
        strings[idx] = encode(m.group(2), cs, f"{os.path.basename(path)}:{n}")
    missing = [i for i in range(COUNT) if i not in strings]
    if missing:
        raise SystemExit(f"{path} : chaines manquantes {missing[:10]}")
    count = max(strings) + 1
    table, body = bytearray(), bytearray()
    base = 0x8000 + 2 * count
    for i in range(count):
        p = base + len(body)
        table += bytes([p & 0xFF, p >> 8])
        body += strings.get(i, b"") + b"\x00"
    data = bytes(table + body)
    if len(data) > 0x4000:
        raise SystemExit(f"textes trop longs : {len(data)} octets (max 16384 dans la banque 32)")
    return data


def build(ver, quiet=False, bank=32):
    """bank : banque des dialogues (32 ; 27 en ROM512). La table doit rester en $8000."""
    if ver not in EDITABLE:
        return None
    data = compile_bank(ver)
    gen = os.path.join(ROOT, "build", ver, "generated")
    os.makedirs(gen, exist_ok=True)
    dst = os.path.join(gen, "data_text.s")
    with open(dst, "w", encoding="utf-8", newline="\n") as f:
        f.write(";; GENERE par tools/assets/text.py depuis assets/%s/text/strings.txt - ne pas modifier\n" % ver)
        f.write(f"\t.area _B{bank:02d}_8000\n")
        f.write("text_bank32::\n")
        for i in range(0, len(data), 16):
            f.write("\t.db " + ", ".join("0x%02x" % b for b in data[i:i + 16]) + "\n")
    if not quiet:
        print(f"[{ver}] textes : {len(data)} octets ({0x4000 - len(data)} libres) -> {os.path.relpath(dst, ROOT)}")
    return data


def check(ver):
    orig = read_bank(ver)
    data = build(ver, quiet=True)
    data = data + b"\xff" * (len(orig) - len(data))
    if data == orig:
        print(f"[{ver}] textes : IDENTIQUES a la ROM d'origine")
        return True
    d = next(i for i in range(len(orig)) if data[i] != orig[i])
    print(f"[{ver}] textes : DIFFERENCE a ${0x8000 + d:04X} (attendu {orig[d]:02X}, obtenu {data[d]:02X})")
    return False


# ---------------------------------------------------------------- ecrans de texte (banque 33, EN)
# Blocs de texte « 1 octet par case » charges par l'opcode load_vram (drapeau bit 7 = 0).
SCREEN_BANK = 33
SCREENS = [(0x8000, 20, 18, "credits de la traduction"),
           (0x8168, 20, 1, "copyright 1"), (0x817C, 20, 1, "copyright 2"),
           (0x8190, 20, 1, "copyright 3"), (0x81A4, 20, 1, "copyright 4")]


def screens_paths(ver):
    return (os.path.join(tdir(ver), "screens.txt"),
            os.path.join(ROOT, "assets", ver, "raw", f"bank{SCREEN_BANK}.bin"))


def extract_screens(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    bank = rom[SCREEN_BANK * 0x4000:(SCREEN_BANK + 1) * 0x4000]
    cs = load_charset(ver)
    txt, raw = screens_paths(ver)
    out = ["# Ecrans de texte - banque 33 (SMS EN) : 1 octet par case, 20 colonnes.",
           "# Chaque ligne du bloc est entouree de | ; garder exactement la largeur.",
           "# Le reste de la banque (tuiles, tilemaps) est dans assets/sms_en/raw/bank33.bin."]
    for addr, w, h, name in SCREENS:
        out.append("")
        out.append(f"@screen 0x{addr:04X} {w}x{h} ; {name}")
        for r in range(h):
            o = addr - 0x8000 + r * w
            out.append("|" + decode(bank[o:o + w], cs) + "|")
    open(txt, "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")
    os.makedirs(os.path.dirname(raw), exist_ok=True)
    used = len(bank.rstrip(b"\xff"))
    open(raw, "wb").write(bank[:used])
    print(f"[{ver}] {len(SCREENS)} ecrans -> {os.path.relpath(txt, ROOT)} ; reste brut ({used} o) -> {os.path.relpath(raw, ROOT)}")


def compile_screens(ver):
    """Banque 33 complete (brut + tuiles + ecrans de texte), pour check_screens."""
    txt, raw = screens_paths(ver)
    data = open(raw, "rb").read()
    import gfx   # la banque 33 contient aussi des tuiles (PNG dans assets/<ver>/gfx/bank33)
    if os.path.exists(os.path.join(gfx.gdir(ver), "gfx.json")):
        data, _ = gfx.apply_overlays(ver, SCREEN_BANK, data)
    return apply_screens(ver, SCREEN_BANK, data)[0]


def apply_screens(ver, bank, data, relocate=None):
    """Fournisseur pour banks.py : superpose les ecrans de texte (banque 33, SMS EN)."""
    if ver not in EDITABLE or bank != SCREEN_BANK:
        return data, 0
    cs = load_charset(ver)
    txt, _ = screens_paths(ver)
    before = bytes(data)
    data = bytearray(data)
    cur = None
    for n, line in enumerate(open(txt, encoding="utf-8"), 1):
        line = line.rstrip("\n")
        if line.startswith("@screen"):
            m = re.match(r"@screen\s+(0x[0-9A-Fa-f]+)\s+(\d+)x(\d+)", line)
            if not m:
                raise SystemExit(f"{txt}:{n} : en-tete invalide")
            cur = [int(m.group(1), 16) - 0x8000, int(m.group(2)), int(m.group(3)), 0]
        elif line.startswith("|") and cur:
            if not line.endswith("|"):
                raise SystemExit(f"{txt}:{n} : la ligne doit finir par |")
            enc = encode(line[1:-1], cs, f"screens.txt:{n}")
            if len(enc) != cur[1]:
                raise SystemExit(f"screens.txt:{n} : {len(enc)} cases au lieu de {cur[1]}")
            if cur[3] >= cur[2]:
                raise SystemExit(f"screens.txt:{n} : trop de lignes dans le bloc")
            o = cur[0] + cur[3] * cur[1]
            data[o:o + cur[1]] = enc
            cur[3] += 1
    return bytes(data), int(bytes(data) != before)


def build_screens(ver, quiet=False):
    if ver not in EDITABLE:
        return None
    data = compile_screens(ver)
    dst = os.path.join(ROOT, "build", ver, "generated", "data_text_screens.s")
    with open(dst, "w", encoding="utf-8", newline="\n") as f:
        f.write(";; GENERE par tools/assets/text.py (screens.txt + raw/bank33.bin) - ne pas modifier\n")
        f.write("\t.area _B33_8000\n")
        f.write("text_bank33::\n")
        for i in range(0, len(data), 16):
            f.write("\t.db " + ", ".join("0x%02x" % b for b in data[i:i + 16]) + "\n")
    if not quiet:
        print(f"[{ver}] ecrans de texte : {len(data)} octets -> {os.path.relpath(dst, ROOT)}")
    return data


def check_screens(ver):
    rom = open(os.path.join(ROOT, ROMS[ver]), "rb").read()
    orig = rom[SCREEN_BANK * 0x4000:(SCREEN_BANK + 1) * 0x4000]
    data = compile_screens(ver)
    data = data + b"\xff" * (len(orig) - len(data))
    ok = data == orig
    print(f"[{ver}] ecrans de texte : {'IDENTIQUES a la ROM d origine' if ok else 'DIFFERENTS'}")
    return ok


def GUARDED(ver):
    """Fichiers edites a la main que extract ecraserait."""
    return [os.path.join(tdir(ver), "strings.txt"), screens_paths(ver)[0]] if ver in EDITABLE else []


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    opts = dict(a.split("=", 1) for a in sys.argv[2:])
    ver = opts.get("VERSION", "sms_en")
    if cmd == "extract":
        _targets = [p for p in GUARDED(ver) if os.path.exists(p)]
        if _targets and opts.get("FORCE") != "1":
            print("REFUS : ces fichiers existent deja et seraient ecrases (modifications perdues) :")
            for p in _targets:
                print("  " + os.path.relpath(p, ROOT))
            sys.exit("Relancer avec FORCE=1 pour repartir de la ROM d'origine.")
        extract(ver)
        if ver in EDITABLE:
            extract_screens(ver)
    elif cmd == "build":
        build(ver)
    elif cmd == "check":
        ok = check(ver)
        if ver in EDITABLE:
            ok = check_screens(ver) and ok
        sys.exit(0 if ok else 1)
    else:
        sys.exit(__doc__)
