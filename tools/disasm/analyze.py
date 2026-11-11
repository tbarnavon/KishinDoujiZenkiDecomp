#!/usr/bin/env python3
"""Analyse du graphe d'appels pour classer les routines par module.

Usage : python tools/disasm/analyze.py [--rom sms_en] [--out build/analysis]

Produit :
  functions.txt  une ligne par fonction : adresse, taille, racines qui l'atteignent,
                 appelants, appeles, ports, banques chargees, RAM lue/ecrite
  roots.txt      pour chaque racine : fonctions atteintes exclusivement par elle
  banks.txt      pour chaque banque de donnees : sites qui la paginent et routine appelee ensuite
"""
import argparse
import json
import os
import sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import run_trace  # noqa: E402
from functions import PORT_CLASSES  # noqa: E402
from trace import BANK  # noqa: E402

ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
ROMS = {"sms_en": "original/Kishin_Douji_Zenki_GG2SMS_v0_3__EN_.sms",
        "gg_jp": "original/Kishin Douji Zenki (J).gg"}


def build(tr, extra_entries):
    """Fonctions : entrees + cibles de tables. Corps = flot sans suivre les call."""
    entries = set(tr.entries) | set(tr.probable) | set(extra_entries)
    entries = {e for e in entries if e in tr.code}
    funcs = {}
    for e in entries:
        body, stack = set(), [e]
        callees, ports, ram_r, ram_w, banks = set(), set(), set(), set(), set()
        a_const = None
        while stack:
            o = stack.pop()
            if o in body or o not in tr.code or (o != e and o in entries):
                if o != e and o in entries:
                    callees.add(o)
                continue
            body.add(o)
            ins = tr.code[o]
            t = ins.text
            for p, cls in PORT_CLASSES.items():
                if t.endswith(f"(0x{p:02x}),a") or t.startswith(f"in a,(0x{p:02x})"):
                    ports.add(cls)
            if t in ("rst 0x08", "rst 0x10"):
                ports.add("vdp")
            if t.startswith(("otir", "outi", "out (c)")):
                ports.add("out_c")
            if ins.word_kind == "mem" and ins.word is not None and 0xC000 <= ins.word < 0xFFFC:
                (ram_w if t.startswith("ld (") else ram_r).add(ins.word)
            if t.startswith("ld a,#"):
                a_const = ins.byte_imm
            elif t == "ld ({W}),a" and ins.word == 0xFFFF and a_const is not None:
                banks.add(a_const)
            tgt = tr.ins_target.get(o)
            if ins.flow in ("call", "ccall") and tgt is not None:
                callees.add(tgt)
            if ins.flow in ("seq", "call", "ccall", "cjump", "cret"):
                stack.append(o + ins.size)
            if ins.flow in ("jump", "cjump") and tgt is not None:
                stack.append(tgt)
            if ins.flow == "jpind":
                for toff, lst in tr.table_targets.items():
                    if tr.tables[toff][2] == o:
                        callees.update(x for _, x in lst if x is not None)
        funcs[e] = dict(body=body, callees=callees - {e}, ports=ports, ram_r=ram_r, ram_w=ram_w, banks=banks,
                        size=sum(tr.code[x].size for x in body))
    # helpers de dispatch : la table est passee par l'appelant
    for toff, (cpu, n, site, forced) in tr.tables.items():
        if site is None:
            continue
        owner = [e for e, f in funcs.items() if site in f["body"]]
        for e in owner:
            funcs[e]["callees"].update(x for _, x in tr.table_targets[toff] if x is not None and x in funcs)
    callers = defaultdict(set)
    for e, f in funcs.items():
        for c in f["callees"]:
            if c in funcs:
                callers[c].add(e)
    for e, f in funcs.items():
        f["callers"] = callers[e]
    return funcs


def reach(funcs, roots):
    """Pour chaque fonction, l'ensemble des racines qui l'atteignent (sans traverser les autres racines)."""
    rootset = {o for o in roots}
    reached = defaultdict(set)
    for r, name in roots.items():
        stack, seen = [r], set()
        while stack:
            f = stack.pop()
            if f in seen or f not in funcs:
                continue
            seen.add(f)
            reached[f].add(name)
            for c in funcs[f]["callees"]:
                if c not in rootset:
                    stack.append(c)
    return reached


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rom", default="sms_en")
    ap.add_argument("--out", default=os.path.join(ROOT, "build", "analysis"))
    args = ap.parse_args()
    os.makedirs(args.out, exist_ok=True)
    rom = open(os.path.join(ROOT, ROMS[args.rom]), "rb").read()
    hints = run_trace.load_hints(os.path.join(HERE, "hints.json"))
    tr = run_trace.build_tracer(rom, hints)
    tab_targets = {x for lst in tr.table_targets.values() for _, x in lst if x is not None}
    roots_cfg = json.load(open(os.path.join(HERE, "roots.json"), encoding="utf-8"))
    root_offs = set()
    for key in roots_cfg["roots"]:
        b, a = key.split(":")
        root_offs.add(int(b) * BANK + (int(a, 16) & 0x3FFF))
    funcs = build(tr, tab_targets | root_offs)
    roots = {}
    for key, name in roots_cfg["roots"].items():
        b, a = key.split(":")
        roots[int(b) * BANK + (int(a, 16) & 0x3FFF)] = name
    for t in roots_cfg.get("tables", []):
        b, a = t["table"].split(":")
        toff = int(b) * BANK + (int(a, 16) & 0x3FFF)
        for i, (_, x) in enumerate(tr.table_targets.get(toff, [])):
            if x is not None:
                roots.setdefault(x, f"{t['name']}[{i}]")
    reached = reach(funcs, roots)

    def nm(o):
        return f"{o // BANK:02d}:{o & 0x3FFF | (0x4000 if o // BANK == 1 else 0):04X}" if o < 2 * BANK else f"{o // BANK:02d}:{0x8000 | (o & 0x3FFF):04X}"

    with open(os.path.join(args.out, "functions.txt"), "w", encoding="utf-8") as f:
        for e in sorted(funcs):
            d = funcs[e]
            rs = sorted(reached.get(e, []))
            rshort = ",".join(sorted({r.split("[")[0] for r in rs}))
            f.write(f"{nm(e)} {d['size']:4d}o  roots={rshort or '-'}  "
                    f"callers={len(d['callers'])} callees={' '.join(nm(c) for c in sorted(d['callees']) if c in funcs)[:120]}  "
                    f"ports={','.join(sorted(d['ports']))}  banks={','.join(map(str, sorted(d['banks'])))}  "
                    f"w={' '.join('%04X' % x for x in sorted(d['ram_w']))[:80]}\n")
    by_root = defaultdict(list)
    for e in funcs:
        rs = {r.split("[")[0] for r in reached.get(e, [])}
        key = next(iter(rs)) if len(rs) == 1 else ("(partage) " + "+".join(sorted(rs)) if rs else "(non atteint)")
        by_root[key].append(e)
    with open(os.path.join(args.out, "roots.txt"), "w", encoding="utf-8") as f:
        for k in sorted(by_root):
            lst = sorted(by_root[k])
            f.write(f"== {k} : {len(lst)} fonctions, {sum(funcs[x]['size'] for x in lst)} o\n   ")
            f.write(" ".join(nm(x) for x in lst) + "\n")
    # fonctions non atteintes : ou sont les mots qui pointent vers elles ?
    with open(os.path.join(args.out, "unreached.txt"), "w", encoding="utf-8") as f:
        for e in sorted(by_root.get("(non atteint)", [])):
            cpu = (e & 0x3FFF) | (0x4000 if e // BANK == 1 else 0)
            pat = bytes([cpu & 0xFF, cpu >> 8])
            hits, i = [], rom.find(pat)
            while i >= 0 and len(hits) < 6:
                if i not in tr.owner:
                    hits.append(i)
                i = rom.find(pat, i + 1)
            imm = sorted(o for o, ins in tr.code.items() if ins.word == cpu and ins.word_kind == "imm")[:4]
            f.write(f"{nm(e)} {funcs[e]['size']:4d}o  probable={'oui' if e in tr.probable else 'non'}  "
                    f"mots_donnees={' '.join('%05X' % h for h in hits)}  imm={' '.join('%05X' % x for x in imm)}  "
                    f"callers={' '.join(nm(c) for c in sorted(funcs[e]['callers']))}\n")
    # banques chargees par constante
    bank_users = defaultdict(set)
    for e, d in funcs.items():
        for b in d["banks"]:
            bank_users[b].add(e)
    with open(os.path.join(args.out, "banks.txt"), "w", encoding="utf-8") as f:
        for b in sorted(bank_users):
            f.write(f"banque {b:2d} : paginee par {' '.join(nm(x) for x in sorted(bank_users[b]))}\n")
    print(f"{len(funcs)} fonctions ; rapports dans {os.path.relpath(args.out, ROOT)}")
    for k in sorted(by_root, key=lambda k: -len(by_root[k]))[:40]:
        print(f"  {len(by_root[k]):4d}  {k}")


if __name__ == "__main__":
    main()
