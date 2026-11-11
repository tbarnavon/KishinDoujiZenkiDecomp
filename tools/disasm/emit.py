#!/usr/bin/env python3
"""Generation des sources assembleur modulaires a partir des ROMs.

Usage : python tools/disasm/emit.py [--out src] [--config config]

Entrees :
  tools/disasm/hints.json    indications de tracage (points d'entree, tables)
  tools/disasm/symbols.json  noms, modules, commentaires, carte RAM
Sorties :
  src/**.s                   un fichier par module (fragments dans des areas)
  src/include/ram.inc        equates RAM (carte memoire)
  config/layout_<ver>.cfg    ordre des areas par banque (placement en banques)

Principe : chaque fragment (une fonction + ses donnees) est place dans une
area `_Bbb_AAAA`. Le fichier de layout, lie en premier, fixe l'ordre des areas
=> on peut ranger les fragments par module sans changer l'image ROM.
Les differences entre versions sont emises en blocs `.if VERSION_xx` ou, si
elles couvrent la majeure partie d'un fragment, dans src/version/<ver>/.
"""
import argparse
import json
import os
import re
import sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import run_trace  # noqa: E402
from trace import BANK  # noqa: E402

ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))

VERSIONS = {
    "sms_en": {"rom": "original/Kishin_Douji_Zenki_GG2SMS_v0_3__EN_.sms", "banks": 34,
               "desc": "Portage SMS (hack GG2SMS v0.3) traduit en anglais"},
    "gg_jp": {"rom": "original/Kishin Douji Zenki (J).gg", "banks": 32,
              "desc": "Game Gear japonaise d'origine"},
}
BASE = "sms_en"

# ---------------------------------------------------------------- materiel
PORTS_OUT = {0xBE: "VDP_DATA", 0xBF: "VDP_CTRL", 0x7E: "PSG_PORT_ALT", 0x7F: "PSG_PORT",
             0x3E: "MEM_CTRL", 0x3F: "IO_CTRL", 0x06: "GG_STEREO", 0x00: "GG_PORT_00"}
PORTS_IN = {0xBE: "VDP_DATA", 0xBF: "VDP_STATUS", 0x7E: "VDP_VCOUNTER", 0x7F: "VDP_HCOUNTER",
            0xDC: "IO_PORT_A", 0xDD: "IO_PORT_B", 0x00: "GG_START"}
PORT_COMMENTS = {"VDP_DATA": "VDP : donnee VRAM/CRAM", "VDP_CTRL": "VDP : commande (adresse / registre)",
                 "VDP_STATUS": "VDP : statut (acquitte l'IRQ)", "VDP_VCOUNTER": "VDP : compteur de ligne",
                 "VDP_HCOUNTER": "VDP : compteur horizontal", "PSG_PORT": "PSG (son)",
                 "PSG_PORT_ALT": "PSG (son, miroir)", "IO_PORT_A": "manette 1 (+ haut/bas manette 2)",
                 "IO_PORT_B": "manette 2 / reset", "GG_START": "GG : bouton Start (bit 7)",
                 "GG_STEREO": "GG : stereo PSG", "MEM_CTRL": "controle memoire", "IO_CTRL": "controle E/S"}
MAPPER = {0xFFFC: "MAPPER_CTRL", 0xFFFD: "MAPPER_SLOT0", 0xFFFE: "MAPPER_SLOT1", 0xFFFF: "MAPPER_SLOT2"}


def hexw(v):
    return "0x%04x" % v


class Version:
    """Resultat du tracage d'une version + rendu des elements."""

    def __init__(self, name, cfg, hints):
        self.name = name
        self.rom = open(os.path.join(ROOT, cfg["rom"]), "rb").read()
        self.nbanks = cfg["banks"]
        print(f"[{name}] tracage...", flush=True)
        self.tr = run_trace.build_tracer(self.rom, hints)
        tr = self.tr
        self.order = sorted(tr.code)
        self.idx = {o: i for i, o in enumerate(self.order)}
        self.opclass = {}     # off -> ('ptr', off_cible) | ('vdp', expression)
        self.table_items = {}  # off -> (index, toff)
        for toff, lst in tr.table_targets.items():
            for i, (w, o) in enumerate(lst):
                self.table_items[toff + 2 * i] = (w, o)

    def is_boundary(self, off):
        """Un label peut-il etre place a `off` dans cette version ?"""
        own = self.tr.owner.get(off)
        return own is None or own == off


# ---------------------------------------------------------------- noms
class Names:
    def __init__(self, versions, symbols):
        self.sym = {}  # off -> dict
        self.views = {}
        for key, v in symbols.get("labels", {}).items():
            b, a = key.split(":")
            b, a = int(b), int(a, 16)
            self.sym[b * BANK + (a & 0x3FFF)] = v
        # vue canonique par banque (adresse CPU de base du lien)
        self.base = {}
        cnt = defaultdict(lambda: defaultdict(int))
        for ver in versions.values():
            for off, vs in ver.tr.views.items():
                for c in vs:
                    cnt[off // BANK][c & 0xC000] += 1
        for b in range(max(v.nbanks for v in versions.values())):
            if b == 0:
                self.base[b] = 0x0000
            elif b == 1:
                self.base[b] = 0x4000
            elif cnt[b]:
                self.base[b] = max(cnt[b].items(), key=lambda kv: kv[1])[0]
            else:
                self.base[b] = 0x8000
        for key, v in symbols.get("bank_base", {}).items():
            self.base[int(key)] = int(v, 16)
        # prefixes : sub (entree) > jt (table) > loc (saut)
        self.kind = {}
        for ver in versions.values():
            tr = ver.tr
            for o in tr.jumps:
                self.kind.setdefault(o, "loc")
            for o in tr.tables:
                if self.kind.get(o) != "sub":
                    self.kind[o] = "jt"
            for o in tr.entries | tr.probable:
                self.kind[o] = "sub"
        for o in self.sym:
            self.kind.setdefault(o, "sub")

    def cpu(self, off):
        b = off // BANK
        return self.base[b] + (off & 0x3FFF)

    def area(self, off):
        return "_B%02d_%04X" % (off // BANK, self.cpu(off))

    def name(self, off):
        if off in self.sym and self.sym[off].get("name"):
            return self.sym[off]["name"]
        b = off // BANK
        k = self.kind.get(off, "data")
        if b < 2:
            return "%s_%04X" % (k, self.cpu(off))
        return "%s_b%02d_%04X" % (k, b, self.cpu(off))

    def ref(self, off, view_cpu):
        """Reference a `off` vue depuis l'adresse CPU `view_cpu` (multi-vues)."""
        n = self.name(off)
        d = (view_cpu & 0xC000) - (self.cpu(off) & 0xC000)
        if d > 0:
            return f"{n}+0x{d:04x}"
        if d < 0:
            return f"{n}-0x{-d:04x}"
        return n


# ---------------------------------------------------------------- rendu
class Renderer:
    def __init__(self, names, ram_names):
        self.names = names
        self.ram_names = ram_names
        self.ram_used = set()
        self.operand_symbols = {}     # off ROM -> nom (donnees produites par les assets)
        self.equates = {}             # nom -> adresse (donnees des banques composees, position fixe)

    def ram(self, addr):
        self.ram_used.add(addr)
        return self.ram_names.get(addr, {}).get("name") or "ram_%04X" % addr

    def word(self, ins, mnem_reg):
        w = ins.word
        if ins.word_kind == "mem":
            if w in MAPPER:
                return MAPPER[w]
            if w >= 0xC000:
                return self.ram(w)
            return hexw(w)
        # immediate : symbole RAM seulement pour des registres pointeurs, hors commandes CRAM (de = $C0xx)
        if w >= 0xC000 and mnem_reg in ("hl", "ix", "iy", "bc") and w not in MAPPER:
            return self.ram(w)
        if w >= 0xC040 and mnem_reg == "de" and w not in MAPPER:
            return self.ram(w)
        if w in MAPPER and mnem_reg in ("hl", "de", "bc"):
            return MAPPER[w]
        return hexw(w)

    def code(self, ver, off, ins):
        """Retourne (texte, commentaire)."""
        tr = ver.tr
        t = ins.text
        comment = ""
        if not ins.valid:
            return ".db " + ", ".join("0x%02x" % b for b in ins.raw), f"{t.replace('{W}', '').replace('{J}', '')} (encodage non canonique)"
        if "{W}" in t:
            reg = t.split()[1].split(",")[0] if " " in t else ""
            tgt_off = tr.ins_word.get(off)
            oc = ver.opclass.get(off)
            if tgt_off is not None and tgt_off in self.operand_symbols:
                # donnee deplacable produite par un compilateur d'assets : reference par son nom
                t = t.replace("{W}", self.operand_symbols[tgt_off])
            elif oc and oc[0] == "ptr":
                t = t.replace("{W}", self.names.ref(oc[1], ins.word))
            elif oc and oc[0] == "vdp":
                t = t.replace("{W}", oc[1])
            elif oc and oc[0] == "eq":
                nm = "data_b%02d_%04X" % (oc[1] // BANK, ins.word)
                self.equates[nm] = ins.word
                t = t.replace("{W}", nm)
            else:
                t = t.replace("{W}", self.word(ins, reg))
        if "{J}" in t:
            tgt = tr.ins_target.get(off)
            if tgt is not None and ver.is_boundary(tgt):
                if t.startswith(("jr", "djnz")):
                    # relatif : decalage de vue de la cible moins celui de l'instruction
                    d_pc = (ins.pc & 0xC000) - (self.names.cpu(off) & 0xC000)
                    t = t.replace("{J}", self.names.ref(tgt, ins.target - d_pc))
                else:
                    t = t.replace("{J}", self.names.ref(tgt, ins.target))
            elif ins.target >= 0xC000:
                t = t.replace("{J}", self.ram(ins.target))
            elif t.startswith(("jr", "djnz")):
                return ".db " + ", ".join("0x%02x" % b for b in ins.raw), t.replace("{J}", hexw(ins.target)) + " (cible non resolue)"
            else:
                t = t.replace("{J}", hexw(ins.target))
                comment = "cible non resolue (banque inconnue)"
        # ports
        if t.startswith("out (0x") and t.endswith("),a"):
            p = int(t[5:9], 16)
            if p in PORTS_OUT:
                t = f"out ({PORTS_OUT[p]}),a"
                comment = PORT_COMMENTS.get(PORTS_OUT[p], "")
        elif t.startswith("in a,(0x"):
            p = int(t[6:10], 16)
            if p in PORTS_IN:
                t = f"in a,({PORTS_IN[p]})"
                comment = PORT_COMMENTS.get(PORTS_IN[p], "")
        if "MAPPER_SLOT2" in t and t.startswith("ld (MAPPER"):
            comment = "mapper : banque du slot 2 ($8000-$BFFF)"
        elif "MAPPER_SLOT1" in t and t.startswith("ld (MAPPER"):
            comment = "mapper : banque du slot 1 ($4000-$7FFF)"
        elif t == "rst 0x10":
            comment = "VDP : adresse/commande = de"
        elif t == "rst 0x08":
            comment = "VDP : adresse/commande = de (sous di)"
        if off in tr.spec_code and not comment:
            pass
        return t, comment


def data_items(ver, names, start, end, labels):
    """Elements de donnees entre start et end (exclu) : lignes de 16 octets alignees."""
    rom = ver.rom
    out = []
    o = start
    while o < end:
        if o in ver.table_items:
            w, to = ver.table_items[o]
            out.append((o, 2, "dw", (w, to)))
            o += 2
            continue
        # fin de la ligne : grille de 16, label, table, ou fin
        e = min(end, (o | 0xF) + 1)
        for k in range(o + 1, e):
            if k in labels or k in ver.table_items:
                e = k
                break
        out.append((o, e - o, "db", rom[o:e]))
        o = e
    return out


def build_items(ver, names, labels, lo, hi):
    """Liste ordonnee d'elements (off, size, kind, payload) pour [lo, hi)."""
    tr = ver.tr
    items = []
    o = lo
    while o < hi:
        if o in tr.code and tr.owner.get(o) == o:
            ins = tr.code[o]
            if o + ins.size > hi:
                # instruction a cheval sur une frontiere : en donnees
                items.extend(data_items(ver, names, o, hi, labels))
                break
            items.append((o, ins.size, "code", ins))
            o += ins.size
        else:
            e = o + 1
            while e < hi and not (e in tr.code and tr.owner.get(e) == e):
                e += 1
            items.extend(data_items(ver, names, o, e, labels))
            o = e
    return items


def render_item(ver, item, rnd, names):
    off, size, kind, p = item
    if kind == "code":
        t, c = rnd.code(ver, off, p)
        return t, c
    if kind == "dw":
        w, to = p
        if to is not None and ver.is_boundary(to):
            return ".dw " + names.ref(to, w), ""
        return ".dw " + hexw(w), ""
    data = p
    if len(data) >= 8 and data.count(0xFF) == len(data):
        return f".ds {len(data)}", "rempli par $FF au build"
    return ".db " + ", ".join("0x%02x" % b for b in data), ""


# ---------------------------------------------------------------- principal
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=os.path.join(ROOT, "src"))
    ap.add_argument("--config", default=os.path.join(ROOT, "config"))
    ap.add_argument("--force", action="store_true", help="ecraser src/ meme gele")
    args = ap.parse_args()
    if os.path.exists(os.path.join(args.out, "FROZEN")) and not args.force:
        sys.exit("REFUS : src/ est gele (fichier src/FROZEN) : les .s sont edites a la main et seraient "
                 "ecrases. Relancer avec --force uniquement pour repartir de la ROM d'origine.")
    hints = run_trace.load_hints(os.path.join(HERE, "hints.json"))
    symbols = json.load(open(os.path.join(HERE, "symbols.json"), encoding="utf-8"))
    vers = {n: Version(n, c, hints) for n, c in VERSIONS.items()}
    names = Names(vers, symbols)
    ram_names = {int(k, 16): v for k, v in symbols.get("ram", {}).items()}
    rnd = Renderer(names, ram_names)
    for key, nm_ in symbols.get("operand_symbols", {}).items():
        b_, a_ = key.split(":")
        rnd.operand_symbols[int(b_) * BANK + (int(a_, 16) & 0x3FFF)] = nm_

    # labels par version : tous les labels connus places sur une frontiere de la version
    # etape 5 : operandes 16 bits -> pointeurs (labels) / commandes VDP (constantes nommees)
    import operands
    aranges = []
    for a, b in symbols.get("asset_ranges", []):
        (b0, a0), (b1, a1) = a.split(":"), b.split(":")
        aranges.append((int(b0) * BANK + (int(a0, 16) & 0x3FFF), int(b1) * BANK + (int(a1, 16) & 0x3FFF)))
    for ver in vers.values():
        for off, ins in ver.tr.code.items():
            c = operands.classify(ver, off, ins, aranges)
            if c:
                ver.opclass[off] = c
                if c[0] == "ptr":
                    names.kind.setdefault(c[1], "data")
    # tables de pointeurs declarees (donnees des banques 0/1) : mots rendus en `.dw label`
    for pt in symbols.get("pointer_tables", []):
        b0, a0 = pt["at"].split(":")
        base = int(b0) * BANK + (int(a0, 16) & 0x3FFF)
        for ver in vers.values():
            rom_ = ver.rom
            for k in range(pt["count"]):
                o = base + k * pt.get("stride", 2) + pt.get("offset", 0)
                w = rom_[o] | (rom_[o + 1] << 8)
                if w < 0x4000:
                    t = w
                elif w < 0x8000:
                    t = BANK + (w & 0x3FFF)
                else:
                    t = pt["bank"] * BANK + (w & 0x3FFF) if "bank" in pt else None
                if t is None or not ver.is_boundary(t):
                    continue
                ver.table_items[o] = (w, t)
                names.kind.setdefault(t, "data")
    all_labels = set(names.kind) | set(names.sym)
    labels = {n: {o for o in all_labels if o < v.nbanks * BANK and v.is_boundary(o)} for n, v in vers.items()}

    # fragments : frontieres = entrees de fonctions de la version de base + debuts de banque
    base = vers[BASE]
    max_banks = max(v.nbanks for v in vers.values())
    starts = set(b * BANK for b in range(max_banks))
    for o in base.tr.entries | base.tr.probable | set(names.sym):
        if all(o >= v.nbanks * BANK or v.is_boundary(o) for v in vers.values()):
            starts.add(o)
    for o, s in names.sym.items():
        if s.get("fragment") is False:
            starts.discard(o)
    starts = sorted(starts)

    ranges = []
    for r in symbols.get("ranges", []):
        b0, a0 = r["from"].split(":")
        b1, a1 = r["to"].split(":")
        ranges.append((int(b0) * BANK + (int(a0, 16) & 0x3FFF), int(b1) * BANK + (int(a1, 16) & 0x3FFF), r["module"]))

    data_ranges = []
    for r in symbols.get("data_ranges", []):
        b0, a0 = r["from"].split(":")
        b1, a1 = r["to"].split(":")
        data_ranges.append((int(b0) * BANK + (int(a0, 16) & 0x3FFF), int(b1) * BANK + (int(a1, 16) & 0x3FFF), r["module"]))
    auto = {}
    mpath = os.path.join(HERE, "modules.json")
    if os.path.exists(mpath):
        for k, v in json.load(open(mpath, encoding="utf-8")).items():
            b, a = k.split(":")
            auto[int(b) * BANK + (int(a, 16) & 0x3FFF)] = (v["module"], v["why"])

    def module_of(off):
        """(module, raison). Priorite : symbols.labels > ranges > classify > data_ranges."""
        s = names.sym.get(off)
        if s and s.get("module"):
            return s["module"], "fixe dans symbols.json"
        for lo, hi, m in ranges:
            if lo <= off < hi:
                return m, "plage symbols.json"
        if off in auto:
            return auto[off]
        for lo, hi, m in data_ranges:
            if lo <= off < hi:
                return m, "banque de donnees"
        return "unsorted/bank%02d" % (off // BANK), "non classe"

    files = defaultdict(list)        # chemin relatif -> [(off, lignes)]
    frag_why = {}                    # off fragment -> raison du classement
    layout = {n: [] for n in vers}   # version -> [(off, area)]
    defined_in = defaultdict(set)     # label -> {fichiers}
    used_in = defaultdict(set)        # label -> {fichiers}
    stats = defaultdict(int)

    for i, fs in enumerate(starts):
        fe = starts[i + 1] if i + 1 < len(starts) else max_banks * BANK
        fe = min(fe, (fs // BANK + 1) * BANK)
        present = [n for n, v in vers.items() if fs < v.nbanks * BANK]
        area = names.area(fs)
        mod, why = module_of(fs)
        frag_why[fs] = why
        its = {n: build_items(vers[n], names, labels[n], fs, fe) for n in present}
        # rendu
        rend = {}
        for n in present:
            lst = []
            for it in its[n]:
                t, c = render_item(vers[n], it, rnd, names)
                lab = names.name(it[0]) if it[0] in labels[n] else None
                lst.append((it[0], it[1], lab, t, c))
            rend[n] = lst
        # differences
        same_bytes = len(present) > 1 and all(vers[n].rom[fs:fe] == vers[BASE].rom[fs:fe] for n in present)
        if len(present) == 1:
            targets = {f"version/{present[0]}/{mod.replace('/', '_')}.s": present}
            stats["version_only"] += 1
        else:
            nd = sum(1 for k in range(fs, fe) if len({vers[n].rom[k] for n in present}) > 1)
            if not same_bytes and nd > (fe - fs) // 2 and (fe - fs) > 64:
                targets = {f"version/{n}/{mod.replace('/', '_')}.s": [n] for n in present}
                stats["version_split"] += 1
            else:
                targets = {f"{mod}.s": present}
                stats["common" if same_bytes else "common_with_if"] += 1
        ab = symbols.get("asset_banks", {}).get(str(fs // BANK)) or symbols.get("asset_areas", {}).get(area)
        if ab is not None:
            # banque produite par un compilateur d'assets (pour les versions listees) :
            # seulement dans le layout ; les autres versions gardent le .s genere
            ab_vers = ab.get("versions", list(VERSIONS)) if isinstance(ab, dict) else list(VERSIONS)
            for n in present:
                if n in ab_vers:
                    layout[n].append((fs, area))
            stats["asset"] += 1
            rest = [n for n in present if n not in ab_vers]
            if not rest:
                continue
            mod_v = mod.replace("/", "_")
            targets = {f"version/{n}/{mod_v}.s": [n] for n in rest}
        for path, vlist in targets.items():
            lines = merge_render(rend, vlist, fs)
            files[path].append((fs, area, lines))
            for n in vlist:
                layout[n].append((fs, area))
            for ln in lines:
                if ln[0] == "label":
                    defined_in[ln[1]].add(path)

    # ---- references entre fichiers (pour les .globl)
    for path, frags in files.items():
        for _, _, lines in frags:
            for ln in lines:
                if ln[0] == "ins":
                    for tok in refs_in(ln[1]):
                        if tok in defined_in:
                            used_in[tok].add(path)

    # ---- ecriture des fichiers
    exported = {lab for lab, users in used_in.items() if lab in defined_in and users - defined_in[lab]}
    os.makedirs(args.out, exist_ok=True)
    # nettoyage : les .s generes precedemment (sauf src/include, ecrit a la main) sont supprimes,
    # sinon un fichier qui n'est plus produit resterait assemble (definitions en double)
    for dp, dn, fn in os.walk(args.out):
        if os.path.relpath(dp, args.out).replace("\\", "/").split("/")[0] == "include":
            continue
        for x in fn:
            if x.endswith(".s"):
                os.remove(os.path.join(dp, x))
    for dp, dn, fn in sorted(os.walk(args.out), reverse=True):
        if dp != args.out and not os.listdir(dp):
            os.rmdir(dp)
    mod_desc = symbols.get("modules", {})
    for path, frags in files.items():
        full = os.path.join(args.out, path)
        os.makedirs(os.path.dirname(full), exist_ok=True)
        frags.sort()
        defs = sorted({ln[1] for _, _, lines in frags for ln in lines if ln[0] == "label"} & exported)
        key = path[:-2]
        with open(full, "w", encoding="utf-8", newline="\n") as f:
            f.write(f";; {path}\n")
            f.write(f";; {mod_desc.get(key, 'Module non encore identifie (provisoire).')}\n")
            f.write(";; GENERE par tools/disasm/emit.py (phase de rebuild identique).\n\n")
            f.write('\t.include "hardware.inc"\n\t.include "ram.inc"\n\t.include "data_banks.inc"\n\t.include "version.inc"\n\n')
            if defs:
                f.write(";; Les labels utilises par d'autres modules sont definis avec '::' (globaux).\n")
            for fs, area, lines in frags:
                f.write(f"\n;; ---------------------------------------------------------------- ${fs:05X}\n")
                if frag_why.get(fs):
                    f.write(f";; classement : {frag_why[fs]}\n")
                f.write(f"\t.area {area}\n")
                for ln in lines:
                    f.write(fmt_line(ln, names, exported))
    # ---- ram.inc
    inc = os.path.join(args.out, "include")
    os.makedirs(inc, exist_ok=True)
    with open(os.path.join(inc, "ram.inc"), "w", encoding="utf-8", newline="\n") as f:
        f.write(";; ram.inc - carte memoire RAM ($C000-$DFFF)\n;; GENERE par tools/disasm/emit.py.\n")
        f.write(";; Les noms ram_XXXX sont generiques (role non identifie). Voir docs/memory_map.md.\n\n")
        for a in sorted(rnd.ram_used | set(ram_names)):
            nm = ram_names.get(a, {}).get("name") or "ram_%04X" % a
            cm = ram_names.get(a, {}).get("comment", "")
            f.write(f"{nm:<28s} = 0x{a:04X}{'   ; ' + cm if cm else ''}\n")
    # ---- data_banks.inc : adresses (fixes) des donnees des banques composees depuis assets/
    NL = chr(10)
    with open(os.path.join(inc, "data_banks.inc"), "w", encoding="utf-8", newline=NL) as f:
        f.write(";; data_banks.inc - donnees des banques de donnees (reconstruites a position fixe depuis" + NL)
        f.write(";; assets/ par tools/assets/banks.py), referencees par le code. GENERE par emit.py." + NL)
        f.write(";; Nom : data_bNN_AAAA = banque NN, adresse CPU AAAA (slot 2)." + NL + NL)
        for nm, a in sorted(rnd.equates.items()):
            f.write(f"{nm:<24s} = 0x{a:04X}" + NL)
    # ---- layouts
    os.makedirs(args.config, exist_ok=True)
    for n, lst in layout.items():
        with open(os.path.join(args.config, f"layout_{n}.cfg"), "w", encoding="utf-8", newline="\n") as f:
            f.write(f"# Layout des banques - version {n} ({VERSIONS[n]['desc']})\n")
            f.write("# GENERE par tools/disasm/emit.py. Format :\n")
            f.write("#   bank <numero> <adresse CPU de base>   puis la liste ordonnee des areas\n")
            f.write(f"rom_size 0x{len(vers[n].rom):X}\n")
            cur = None
            for fs, area in sorted(lst):
                b = fs // BANK
                if b != cur:
                    f.write(f"\nbank {b} 0x{names.base[b]:04X}\n")
                    cur = b
                f.write(f"  {area}\n")
    import postprocess
    n_ram = postprocess.run(args.out, ROOT, ram_names)
    print("variables RAM renommees par module :", n_ram)
    print("fragments :", dict(stats))
    print("fichiers  :", len(files))


_IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")


def refs_in(text):
    return _IDENT.findall(text)


def merge_render(rend, vlist, fs):
    """Fusionne les rendus des versions de vlist en lignes, avec blocs .if."""
    if len(vlist) == 1:
        return [ln for r in rend[vlist[0]] for ln in expand(r)]
    a, b = rend[vlist[0]], rend[vlist[1]]
    out = []
    i = j = 0
    bounds_a = {r[0]: k for k, r in enumerate(a)}
    bounds_b = {r[0]: k for k, r in enumerate(b)}
    while i < len(a) or j < len(b):
        if i < len(a) and j < len(b) and a[i] == b[j]:
            out.extend(expand(a[i]))
            i += 1
            j += 1
            continue
        # chercher la prochaine resynchronisation
        si, sj = i, j
        k = i + 1
        while k <= len(a):
            if k == len(a):
                if len(b) >= j:
                    i, j = len(a), len(b)
                break
            off = a[k][0]
            if off in bounds_b and bounds_b[off] >= j and a[k] == b[bounds_b[off]]:
                i, j = k, bounds_b[off]
                break
            k += 1
        out.append(("if", vlist[0]))
        for r in a[si:i]:
            out.extend(expand(r))
        out.append(("else", vlist[1]))
        for r in b[sj:j]:
            out.extend(expand(r))
        out.append(("endif", None))
    return out


def expand(r):
    off, size, lab, t, c = r
    res = []
    if lab:
        res.append(("label", lab, off))
    res.append(("ins", t, c, off))
    return res


def fmt_line(ln, names, exported=()):
    k = ln[0]
    if k == "label":
        return f"{ln[1]}{'::' if ln[1] in exported else ':'}\n"
    if k == "if":
        return f".if VERSION_{ln[1].upper()}\n"
    if k == "else":
        return f".else ; VERSION_{ln[1].upper()}\n"
    if k == "endif":
        return ".endif\n"
    _, t, c, off = ln
    cpu = names.cpu(off)
    s = f"\t{t}"
    pad = 40 - len(s.expandtabs(8))
    s += " " * max(pad, 1) + f"; {cpu:04X}"
    if c:
        s += f"  {c}"
    return s + "\n"


if __name__ == "__main__":
    main()
