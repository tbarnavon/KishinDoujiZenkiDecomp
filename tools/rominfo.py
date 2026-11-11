#!/usr/bin/env python3
"""Identification d'une ROM SMS / Game Gear.

Usage : python tools/rominfo.py <rom> [<rom> ...]

Affiche : taille, hashes (CRC32/MD5/SHA1), en-tete "TMR SEGA" (code produit,
version, region, taille declaree, checksum declare vs recalcule), en-tete
SDSC eventuel, et nombre de banques de 16 Ko.
"""
import hashlib
import sys
import zlib

HEADER_OFFSETS = (0x7FF0, 0x3FF0, 0x1FF0)

REGIONS = {
    0x3: "SMS Japon",
    0x4: "SMS Export",
    0x5: "GG Japon",
    0x6: "GG Export",
    0x7: "GG International",
}

# Code taille (quartet bas de l'octet $7FFF) -> (taille couverte par le checksum, libelle)
SIZES = {
    0xA: (0x2000, "8 Ko"),
    0xB: (0x4000, "16 Ko"),
    0xC: (0x8000, "32 Ko"),
    0xD: (0xC000, "48 Ko"),
    0xE: (0x10000, "64 Ko"),
    0xF: (0x20000, "128 Ko"),
    0x0: (0x40000, "256 Ko"),
    0x1: (0x80000, "512 Ko"),
    0x2: (0x100000, "1 Mo"),
}


def sega_checksum(rom: bytes, size: int) -> int:
    """Somme 16 bits des octets [0, size) en excluant l'en-tete $7FF0-$7FFF."""
    total = 0
    for start, end in ((0, min(size, 0x7FF0)), (0x8000, size)):
        if end > start:
            total += sum(rom[start:end])
    return total & 0xFFFF


def find_header(rom: bytes):
    for off in HEADER_OFFSETS:
        if rom[off:off + 8] == b"TMR SEGA":
            return off
    return None


def read_sdsc(rom: bytes):
    off = 0x7FE0
    if rom[off:off + 4] != b"SDSC":
        return None

    def bcd(b):
        return f"{b >> 4}{b & 0xF}"

    def cstr(ptr):
        if ptr in (0xFFFF, 0x0000) or ptr >= len(rom):
            return None
        end = rom.find(b"\0", ptr)
        return rom[ptr:end].decode("latin-1", "replace")

    w = lambda o: rom[o] | (rom[o + 1] << 8)
    return {
        "version": f"{rom[off + 4]}.{bcd(rom[off + 5])}",
        "date": f"{bcd(rom[off + 6])}/{bcd(rom[off + 7])}/{bcd(rom[off + 9])}{bcd(rom[off + 8])}",
        "author": cstr(w(off + 10)),
        "name": cstr(w(off + 12)),
        "description": cstr(w(off + 14)),
    }


def info(path: str) -> None:
    rom = open(path, "rb").read()
    print(f"=== {path}")
    print(f"  taille        : {len(rom)} octets ({len(rom) // 1024} Ko, {len(rom) // 0x4000} banques de 16 Ko)")
    print(f"  CRC32         : {zlib.crc32(rom) & 0xFFFFFFFF:08X}")
    print(f"  MD5           : {hashlib.md5(rom).hexdigest()}")
    print(f"  SHA1          : {hashlib.sha1(rom).hexdigest()}")
    off = find_header(rom)
    if off is None:
        print("  en-tete       : AUCUN 'TMR SEGA'")
    else:
        h = rom[off:off + 16]
        declared = h[10] | (h[11] << 8)
        product = (h[12] | (h[13] << 8) | ((h[14] >> 4) << 16))
        version = h[14] & 0xF
        region = h[15] >> 4
        size_code = h[15] & 0xF
        csize, clabel = SIZES.get(size_code, (None, f"code invalide {size_code:X}"))
        print(f"  en-tete       : 'TMR SEGA' a ${off:04X} : {h.hex(' ')}")
        print(f"  code produit  : {product:X} (BCD)  version : {version}")
        print(f"  region        : {region:X} = {REGIONS.get(region, 'inconnue')}")
        print(f"  taille decl.  : {clabel}")
        if csize:
            calc = sega_checksum(rom, min(csize, len(rom)))
            status = "OK" if calc == declared else "DIFFERENT"
            print(f"  checksum      : declare ${declared:04X}  recalcule ${calc:04X}  -> {status}")
    sd = read_sdsc(rom)
    if sd:
        print(f"  en-tete SDSC  : {sd}")
    print()


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    for p in sys.argv[1:]:
        info(p)
