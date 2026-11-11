#!/usr/bin/env python3
"""Classement automatique des fonctions dans les modules.

Usage : python tools/disasm/classify.py

Lit roots.json (racines + module de chaque racine + regles) et ecrit
tools/disasm/modules.json : { "banque:adresse": {"module": ..., "why": ...} }
que emit.py utilise quand symbols.json ne fixe pas le module.

Ordre de decision pour une fonction :
  1. regle de region (roots.json "regions") : plage d'adresses -> module
  2. une seule famille de racines l'atteint -> module de cette racine
  3. plusieurs racines : regles "shared" (ports VDP, RAM ecrite) sinon core/util
  4. non atteinte : module de la fonction classee precedente dans la meme banque
     (proximite ; marque "suppose")
"""
import json
import os
import sys
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import run_trace  # noqa: E402
import analyze  # noqa: E402
from trace import BANK  # noqa: E402

ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))


def key_of(off, base):
    b = off // BANK
    return f"{b}:{base.get(b, 0x8000) + (off & 0x3FFF):04X}"


def parse_key(k):
    b, a = k.split(":")
    return int(b) * BANK + (int(a, 16) & 0x3FFF)


def main():
    rom = open(os.path.join(ROOT, analyze.ROMS["sms_en"]), "rb").read()
    hints = run_trace.load_hints(os.path.join(HERE, "hints.json"))
    cfg = json.load(open(os.path.join(HERE, "roots.json"), encoding="utf-8"))
    tr = run_trace.build_tracer(rom, hints)
    tab_targets = {x for lst in tr.table_targets.values() for _, x in lst if x is not None}
    root_offs = {parse_key(k): v for k, v in cfg["roots"].items()}
    funcs = analyze.build(tr, tab_targets | set(root_offs))
    roots = dict(root_offs)
    for t in cfg.get("tables", []):
        for i, (_, x) in enumerate(tr.table_targets.get(parse_key(t["table"]), [])):
            if x is not None:
                roots.setdefault(x, t["name"])
    reached = analyze.reach(funcs, roots)
    rmod = cfg["root_modules"]
    sym0 = json.load(open(os.path.join(HERE, "symbols.json"), encoding="utf-8"))
    # plages fixees a la main dans symbols.json : prioritaires (comme dans emit.py)
    regions = [(parse_key(r["from"]), parse_key(r["to"]), r["module"], "plage fixee dans symbols.json")
               for r in sym0.get("ranges", [])]
    regions += [(parse_key(r["from"]), parse_key(r["to"]), r["module"], r.get("why", "region"))
                for r in cfg.get("regions", [])]
    base = {0: 0x0000, 1: 0x4000, 26: 0x4000}

    out = {}
    for e in sorted(funcs):
        f = funcs[e]
        fam = sorted({r.split("[")[0] for r in reached.get(e, [])})
        mod = why = None
        for lo, hi, m, w in regions:
            if lo <= e < hi:
                mod, why = m, w
                break
        if mod is None and len(fam) == 1:
            mod, why = rmod.get(fam[0]), f"atteinte uniquement par {fam[0]}"
        if mod is None and fam:
            mods = {rmod.get(x) for x in fam}
            rr = None
            for rule in cfg.get("ram_rules", []):
                lo_, hi_ = int(rule["from"], 16), int(rule["to"], 16)
                if any(lo_ <= a < hi_ for a in f["ram_w"]):
                    rr = (rule["module"], rule["why"])
                    break
            if rr:
                mod, why = rr
            elif "vdp" in f["ports"] or "out_c" in f["ports"]:
                mod, why = "video/vdp", "acces VDP, partagee"
            elif any(0xC240 <= a <= 0xC24F for a in f["ram_w"]):
                mod, why = "video/sprites", "ecrit le tampon de sprites $C240-$C24F"
            elif any(a in (0xC0B6, 0xC0B8, 0xC0BE, 0xC0C0) for a in f["ram_w"]):
                mod, why = "game/scroll", "ecrit les variables de defilement"
            elif len(mods) == 1 and None not in mods:
                mod, why = mods.pop(), "racines du meme module : " + "+".join(fam)
            else:
                mod, why = "core/util", "utilitaire partage par " + "+".join(fam)
        out[e] = (mod, why)
    # proximite pour les non atteintes
    prev = {}
    for e in sorted(out):
        mod, why = out[e]
        b = e // BANK
        if mod is None:
            if b in prev:
                out[e] = (prev[b], "SUPPOSE : non atteinte, rangee avec la fonction precedente")
            else:
                fb = cfg.get("bank_fallback", {}).get(str(b))
                out[e] = (fb or f"unsorted/bank{b:02d}", "non atteinte : routine banquee, role a identifier")
        prev[b] = out[e][0]
    res = {key_of(e, base): {"module": m, "why": w} for e, (m, w) in out.items()}
    json.dump(res, open(os.path.join(HERE, "modules.json"), "w", encoding="utf-8"), indent=1, sort_keys=True)
    # documentation
    sym = json.load(open(os.path.join(HERE, "symbols.json"), encoding="utf-8"))
    os.makedirs(os.path.join(ROOT, "docs"), exist_ok=True)
    bymod = {}
    for e, (m, w) in out.items():
        bymod.setdefault(m, []).append((e, w))
    NL = "\n"
    with open(os.path.join(ROOT, "docs", "modules.md"), "w", encoding="utf-8", newline=NL) as d:
        d.write("# Classement des routines par module" + NL + NL)
        d.write("GENERE par `tools/disasm/classify.py` (regles dans `tools/disasm/roots.json`)." + NL + NL)
        d.write("Une routine *supposee* n'est atteinte par aucune racine connue (code probable trouve par "
                "pointeur) : elle est rangee avec sa voisine. A confirmer par la couverture Emulicious." + NL + NL)
        d.write("| Module | Role | Fonctions | dont supposees |" + NL + "|---|---|---|---|" + NL)
        for m in sorted(bymod):
            lst = bymod[m]
            sup = sum(1 for _, w in lst if w.startswith("SUPPOSE"))
            role = sym.get("modules", {}).get(m, "")
            d.write(f"| `{m}` | {role} | {len(lst)} | {sup} |" + NL)
        for m in sorted(bymod):
            d.write(NL + "## " + m + NL + NL)
            for e, w in sorted(bymod[m]):
                d.write(f"- `{key_of(e, base)}` : {w}" + NL)
    c = Counter(m for m, _ in out.values())
    for m, n in sorted(c.items()):
        sup = sum(1 for mm, w in out.values() if mm == m and w.startswith("SUPPOSE"))
        print(f"  {n:4d}  {m}{'  (dont %d supposees)' % sup if sup else ''}")


if __name__ == "__main__":
    main()
