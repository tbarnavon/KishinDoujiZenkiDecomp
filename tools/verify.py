#!/usr/bin/env python3
"""Verification du rebuild identique.

Usage : python tools/verify.py [VERSION=sms_en|gg_jp|all] [MAX=20]

Compare build/<ver>/zenki_<ver>.* a la ROM d'origine : taille, CRC32, MD5,
SHA1, et liste des premiers octets differents (offset, banque:adresse, attendu,
obtenu, area du linker concernee). Code retour 0 si identique.
"""
import hashlib
import os
import re
import sys

sys.dont_write_bytecode = True   # pas de __pycache__ dans tools/
import zlib

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from toolchain import ROOT  # noqa: E402

ORIGINALS = {
    "sms_en": "original/Kishin_Douji_Zenki_GG2SMS_v0_3__EN_.sms",
    "gg_jp": "original/Kishin Douji Zenki (J).gg",
}
EXT = {"sms_en": "sms", "gg_jp": "gg"}


def hashes(b):
    return (f"CRC32 {zlib.crc32(b) & 0xFFFFFFFF:08X}  MD5 {hashlib.md5(b).hexdigest()}  "
            f"SHA1 {hashlib.sha1(b).hexdigest()}")


def load_areas(mapfile):
    """[(debut_lien, fin_lien, nom_area)] depuis le .map de sdldz80."""
    areas = []
    if not os.path.exists(mapfile):
        return areas
    rx = re.compile(r"^(_B\d\d_[0-9A-F]{4})\s+([0-9A-F]{8})\s+([0-9A-F]{8})")
    for line in open(mapfile, errors="replace"):
        m = rx.match(line)
        if m:
            s, n = int(m.group(2), 16), int(m.group(3), 16)
            areas.append((s, s + n, m.group(1)))
    return areas


def area_of(areas, off):
    bank, rel = off // 0x4000, off % 0x4000
    for s, e, name in areas:
        b = s >> 16 if s >= 0x10000 else s >> 14
        cpu = s & 0xFFFF
        if b == bank:
            base = cpu & 0xC000
            if s <= ((bank << 16 if bank >= 2 else 0) | (base + rel)) < e:
                return name
    return "?"


def verify(ver, maxd):
    orig = open(os.path.join(ROOT, ORIGINALS[ver]), "rb").read()
    path = os.path.join(ROOT, "build", ver, f"zenki_{ver}.{EXT[ver]}")
    if not os.path.exists(path):
        print(f"[{ver}] ROM absente : lancer d'abord python tools/build.py VERSION={ver}")
        return False
    new = open(path, "rb").read()
    print(f"[{ver}] original : {hashes(orig)}")
    print(f"[{ver}] rebuild  : {hashes(new)}")
    if new == orig:
        print(f"[{ver}] IDENTIQUE octet pour octet ({len(new)} octets)")
        return True
    if len(new) != len(orig):
        print(f"[{ver}] tailles differentes : {len(new)} vs {len(orig)} attendus")
    areas = load_areas(os.path.join(ROOT, "build", ver, f"zenki_{ver}.map"))
    n = min(len(new), len(orig))
    diffs = [i for i in range(n) if new[i] != orig[i]]
    print(f"[{ver}] {len(diffs)} octets differents ; premiers :")
    for i in diffs[:maxd]:
        b = i // 0x4000
        print(f"   ${i:05X}  banque {b:2d} : ${i % 0x4000:04X}  attendu {orig[i]:02X}  obtenu {new[i]:02X}  ({area_of(areas, i)})")
    return False


def main():
    opts = dict(a.split("=", 1) for a in sys.argv[1:])
    ver = opts.get("VERSION", "sms_en")
    maxd = int(opts.get("MAX", "20"))
    vers = list(ORIGINALS) if ver == "all" else [ver]
    ok = all([verify(v, maxd) for v in vers])
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
