#!/usr/bin/env python3
"""Build du projet en une commande.

Usage :
  python tools/build.py [VERSION=sms_en|gg_jp] [WIDE=1] [ROM512=1] [TRIM=1] [FIX_CHECKSUM=0|1] [VERBOSE=1]

  VERSION       version a produire (defaut : sms_en)
  WIDE=1        vue elargie : decor sur tout l'ecran SMS 256x192, sans logo SEGA (sms_en ;
                sortie build/sms_en_wide/zenki_sms_en_wide.sms, voir docs/widescreen.md)
  ROM512=1      ROM de 512 Ko au lieu de 1 Mo (sms_en) : textes de la traduction et musique
                replaces dans la place libre des banques 0-31 (voir docs/rom512.md) ;
                sortie build/sms_en[_wide]_512/zenki_sms_en[_wide]_512.sms
  TRIM=1        tronque la ROM a la plus petite puissance de 2 contenant les
                donnees (le hack SMS fait 1 Mo dont 544 Ko utiles)
  FIX_CHECKSUM  recalcule le checksum de l'en-tete TMR SEGA (defaut : 1 pour
                sms_en, 0 pour gg_jp dont le checksum d'origine vaut $0000)

Etapes :
  1. genere build/<ver>/generated/version.inc et layout.s (depuis config/layout_<ver>.cfg)
  2. assemble chaque module de src/ (sauf src/version/<autre version>/)
  3. lie avec sdldz80 (layout.rel en premier : il fixe l'ordre des areas)
  4. convertit l'IHX en ROM (banque N liee a (N << 16) | base), remplit en $FF
Sortie : build/<ver>/zenki_<ver>.(sms|gg) + .map/.noi du linker
"""
import os
import subprocess
import sys

sys.dont_write_bytecode = True   # pas de __pycache__ dans tools/

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from toolchain import ROOT, SDAS, SDLD  # noqa: E402
from ihx import read_ihx  # noqa: E402

BANK = 0x4000
VERSIONS = ("sms_en", "gg_jp")
EXT = {"sms_en": "sms", "gg_jp": "gg"}


def variant(wide=False, small=False):
    """Suffixe des builds optionnels : _wide (vue elargie), _512 (ROM de 512 Ko)."""
    return ("_wide" if wide else "") + ("_512" if small else "")


def rom_name(ver, suffix=""):
    return f"zenki_{ver}{suffix}.{EXT[ver]}"


def build_dir(ver, suffix=""):
    return os.path.join(ROOT, "build", ver + suffix)


def remove_stale_rom(ver, suffix=""):
    """Une ROM perimee ne doit jamais etre verifiee a la place d'un build rate :
    on la supprime avant toute autre etape (meme si le build echoue ensuite)."""
    p = os.path.join(build_dir(ver, suffix), rom_name(ver, suffix))
    if os.path.exists(p):
        os.remove(p)


def parse_args(argv):
    opts = {"VERSION": "sms_en", "WIDE": "0", "ROM512": "0", "TRIM": "0", "FIX_CHECKSUM": None,
            "VERBOSE": "0"}
    for a in argv:
        if "=" not in a:
            sys.exit(f"argument invalide : {a} (attendu CLE=valeur)\n{__doc__}")
        k, v = a.split("=", 1)
        if k.upper() not in opts:
            sys.exit(f"option inconnue : {k}\n{__doc__}")
        opts[k.upper()] = v
    if opts["VERSION"] not in VERSIONS:
        sys.exit(f"VERSION doit etre parmi {VERSIONS}")
    if opts["WIDE"] == "1" and opts["VERSION"] != "sms_en":
        sys.exit("WIDE=1 n'existe que pour VERSION=sms_en")
    if opts["ROM512"] == "1" and opts["VERSION"] != "sms_en":
        sys.exit("ROM512=1 n'existe que pour VERSION=sms_en (la GG JP fait deja 512 Ko)")
    if opts["FIX_CHECKSUM"] is None:
        opts["FIX_CHECKSUM"] = "1" if opts["VERSION"] == "sms_en" else "0"
    return opts


def parse_layout(path):
    """Retourne (rom_size, [(bank, base, [areas])])."""
    rom_size, banks = None, []
    for line in open(path, encoding="utf-8"):
        line = line.split("#", 1)[0].strip()
        if not line:
            continue
        w = line.split()
        if w[0] == "rom_size":
            rom_size = int(w[1], 0)
        elif w[0] == "bank":
            banks.append((int(w[1]), int(w[2], 0), []))
        else:
            banks[-1][2].append(w[0])
    return rom_size, banks


def link_addr(bank, base):
    return base if bank < 2 else (bank << 16) | base


def run(cmd, verbose):
    if verbose:
        print("  $", " ".join(cmd))
    r = subprocess.run(cmd, capture_output=True, text=True)
    out = (r.stdout + r.stderr).strip()
    if r.returncode or "error" in out.lower():
        print(out)
        sys.exit(f"ECHEC : {os.path.basename(cmd[0])} (code {r.returncode})")
    return out


def sega_checksum(rom, size):
    total = sum(rom[0:min(size, 0x7FF0)])
    if size > 0x8000:
        total += sum(rom[0x8000:size])
    return total & 0xFFFF


CHECKSUM_SIZES = {0xA: 0x2000, 0xB: 0x4000, 0xC: 0x8000, 0xD: 0xC000, 0xE: 0x10000,
                  0xF: 0x20000, 0x0: 0x40000, 0x1: 0x80000, 0x2: 0x100000}


def main():
    # tout premier geste : supprimer la ROM de sortie (avant meme l'analyse des options)
    ver0 = next((a.split("=", 1)[1] for a in sys.argv[1:] if a.upper().startswith("VERSION=")), "sms_en")
    wide0 = any(a.upper() == "WIDE=1" for a in sys.argv[1:])
    small0 = any(a.upper() == "ROM512=1" for a in sys.argv[1:])
    if ver0 in VERSIONS:
        remove_stale_rom(ver0, variant(wide0, small0))
    o = parse_args(sys.argv[1:])
    ver, verbose, wide = o["VERSION"], o["VERBOSE"] == "1", o["WIDE"] == "1"
    small = o["ROM512"] == "1"
    suffix = variant(wide, small)
    bdir = build_dir(ver, suffix)   # builds optionnels : dossier separe (objets, generes, ROM)
    gen = os.path.join(bdir, "generated")
    obj = os.path.join(bdir, "obj")
    os.makedirs(gen, exist_ok=True)
    os.makedirs(obj, exist_ok=True)

    # 0. les outils d'assets ecrivent toujours dans build/<ver>/generated (asset_gen) ;
    #    pour le build large, leur production est ensuite copiee dans gen.
    asset_gen = os.path.join(ROOT, "build", ver, "generated")
    os.makedirs(asset_gen, exist_ok=True)
    for d in {gen, asset_gen}:
        for x in os.listdir(d):
            if x.endswith(".s") or x in ("gfx_reloc.json", "rom512_areas.json"):
                os.remove(os.path.join(d, x))   # regeneres a chaque build

    # 1. fichiers generes
    with open(os.path.join(gen, "version.inc"), "w", newline="\n") as f:
        f.write(";; GENERE par tools/build.py - ne pas modifier\n")
        for v in VERSIONS:
            f.write(f"VERSION_{v.upper()} = {1 if v == ver else 0}\n")
        f.write(f"WIDESCREEN = {1 if wide else 0}\n")
        f.write(f"NO_SEGA_LOGO = {1 if wide else 0}\n")   # logo SEGA du demarrage retire avec WIDE=1
        f.write(f"ROM512 = {1 if small else 0}\n")
    rom_size, banks = parse_layout(os.path.join(ROOT, "config", f"layout_{ver}.cfg"))
    if small:
        # 512 Ko : plus de banques 32-63 ; leurs contenus sont replaces (tools/assets/rom512.py)
        rom_size = 0x80000
        banks = [x for x in banks if x[0] < 32]

    # 1b. compilation des assets (fichiers editables -> build/<ver>/generated/*.s)
    #     ordre : graphismes d'abord (ils peuvent deplacer des blocs), puis scripts (qui
    #     corrigent leurs references), puis textes.
    sys.path.insert(0, os.path.join(ROOT, "tools", "assets"))
    import banks as asset_banks  # noqa: E402
    extra_banks = asset_banks.build(ver, quiet=False, rom512={"wide": wide} if small else None)
    r512 = None
    if small:
        import json
        r512 = json.load(open(os.path.join(asset_gen, "rom512_areas.json"), encoding="utf-8"))
        for name, b, addr in r512["areas"]:
            banks.append((b, addr, [name]))   # area placee a une adresse explicite
    if extra_banks is not None:
        known = {b for b, _, _ in banks}
        for b in extra_banks:
            if b not in known:
                banks.append((b, 0x8000, [f"_B{b:02d}_8000"]))
                print(f"[{ver}]   banque {b} utilisee pour des graphismes modifies trop grands")
    import scripts as asset_scripts  # noqa: E402
    print(f"[{ver}] assets : scripts de scenes")
    asset_scripts.build(ver, quiet=not verbose)
    import music as asset_music  # noqa: E402
    asset_music.build(ver, quiet=not verbose,
                      remap={27: tuple(r512["music"])} if r512 else None)
    print(f"[{ver}] assets : musique")
    import actors as asset_actors  # noqa: E402
    asset_actors.build(ver, quiet=not verbose)
    print(f"[{ver}] assets : scripts d'acteurs")
    import text as asset_text  # noqa: E402
    if asset_text.build(ver, quiet=not verbose, bank=r512["text_bank"] if r512 else 32) is not None:
        print(f"[{ver}] assets : textes des dialogues")
    if gen != asset_gen:
        import shutil
        for x in os.listdir(asset_gen):
            if x.endswith(".s"):
                shutil.copyfile(os.path.join(asset_gen, x), os.path.join(gen, x))

    with open(os.path.join(gen, "layout.s"), "w", newline="\n") as f:
        f.write(";; GENERE par tools/build.py depuis config/layout_%s.cfg\n" % ver)
        f.write(";; Declare les areas dans l'ordre de la ROM : lie en premier, il fixe le placement.\n")
        for b, base, areas in banks:
            f.write(f"\n;; banque {b} @ ${base:04X}\n")
            for a in areas:
                f.write(f"\t.area {a}\n")

    # 2. assemblage
    srcs = [os.path.join(gen, x) for x in sorted(os.listdir(gen)) if x.endswith(".s") and x != "layout.s"]
    for dp, dn, fn in os.walk(os.path.join(ROOT, "src")):
        rel = os.path.relpath(dp, os.path.join(ROOT, "src")).replace("\\", "/")
        if rel.startswith("version/") and rel.split("/")[1] != ver:
            continue
        srcs += sorted(os.path.join(dp, x) for x in fn if x.endswith(".s"))
    rels = []
    inc = ["-I" + os.path.join(ROOT, "src", "include"), "-I" + gen]
    print(f"[{ver}] assemblage de {len(srcs)} modules")
    for s in [os.path.join(gen, "layout.s")] + srcs:
        r = os.path.join(obj, os.path.relpath(s, ROOT).replace("\\", "_").replace("/", "_")[:-2] + ".rel")
        run([SDAS, "-g", "-o", *inc, r, s], verbose)
        rels.append(r)

    # 3. edition de liens
    lnk = os.path.join(bdir, "link.lnk")
    ihx = os.path.join(bdir, rom_name(ver, suffix)[:-len(EXT[ver])] + "ihx")
    with open(lnk, "w", newline="\n") as f:
        f.write("-m\n-w\n-i\n")
        for b, base, areas in banks:
            if areas:
                f.write(f"-b {areas[0]}=0x{link_addr(b, base):X}\n")
        f.write(ihx + "\n")
        for r in rels:
            f.write(r + "\n")
        f.write("-e\n")
    print(f"[{ver}] edition de liens")
    run([SDLD, "-f", lnk], verbose)

    # 4. IHX -> ROM
    mem = read_ihx(ihx)
    # base du slot de chaque banque (une banque peut avoir plusieurs areas a adresses explicites)
    base_of = {b: (base & 0xC000 if b >= 2 else base) for b, base, _ in banks}
    rom = bytearray(b"\xFF" * rom_size)
    written = bytearray(rom_size)
    used = 0
    for a, v in mem.items():
        if a < 0x10000:
            bank = (a >> 14) if a < 0x8000 else None
            cpu = a
        else:
            bank, cpu = a >> 16, a & 0xFFFF
        if bank is None or bank not in base_of:
            sys.exit(f"octet a l'adresse de lien ${a:X} hors de toute banque")
        rel_ = cpu - base_of[bank] if bank >= 2 else cpu - bank * BANK
        if not 0 <= rel_ < BANK:
            sys.exit(f"DEBORDEMENT de la banque {bank} (adresse ${cpu:04X})")
        off = bank * BANK + rel_
        if off >= rom_size:
            sys.exit(f"banque {bank} hors de la ROM ({rom_size // 1024} Ko)")
        if written[off]:
            sys.exit(f"CHEVAUCHEMENT : banque {bank} ${cpu:04X} ecrite deux fois (areas superposees)")
        written[off] = 1
        rom[off] = v
        used = max(used, off + 1)
    if o["TRIM"] == "1":
        size = 0x8000
        while size < used:
            size *= 2
        rom = rom[:size]
    if o["FIX_CHECKSUM"] == "1" and rom[0x7FF0:0x7FF8] == b"TMR SEGA":
        csize = CHECKSUM_SIZES.get(rom[0x7FFF] & 0xF)
        if csize:
            c = sega_checksum(rom, min(csize, len(rom)))
            rom[0x7FFA], rom[0x7FFB] = c & 0xFF, c >> 8
    out = os.path.join(bdir, rom_name(ver, suffix))
    open(out, "wb").write(rom)
    print(f"[{ver}] ROM : {os.path.relpath(out, ROOT)} ({len(rom) // 1024} Ko, {used} octets utiles)")


if __name__ == "__main__":
    main()
