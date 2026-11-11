#!/usr/bin/env python3
"""Lance le traceur sur une ROM avec un fichier d'indications JSON.

Usage : python tools/disasm/run_trace.py <rom> <hints.json> [--report]

Format des indications (hints.json) :
{
  "bank_shadow": "0xDCBE",
  "entries":   [ {"addr": "0x0000", "s1": 1, "s2": 2, "name": "reset"} ],
  "jumptables": [ {"addr": "0x1234", "count": 5, "s1": 1, "s2": 2, "kind": "call"} ]
}
"""
import json
import os
import sys
from collections import Counter

sys.path.insert(0, os.path.dirname(__file__))
from trace import Tracer, Ctx, BANK  # noqa: E402


def num(v):
    return int(v, 0) if isinstance(v, str) else v


def load_hints(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def build_tracer(rom, hints):
    """Trace (avec cache disque : le resultat est deterministe)."""
    return _cached(rom, hints)


def _build_tracer(rom, hints):
    tr = Tracer(rom, bank_shadow=num(hints.get("bank_shadow")) if hints.get("bank_shadow") else None)
    for d in hints.get("data", []):
        b = d.get("bank", 0)
        lo, hi = num(d["from"]), num(d["to"])
        for a in range(lo, hi):
            tr.data_bytes.add(b * BANK + (a & 0x3FFF))
    for d in hints.get("dispatch_helpers", []):
        tr.dispatch_helpers[num(d["addr"])] = d.get("reg", "de")   # helpers en banque 0/1 : off == cpu
    for t in hints.get("table_counts", []):
        c = Ctx(t.get("s1", 1), t.get("s2", 2))
        tr.forced_counts[tr.off_of(num(t["addr"]), c)] = t["count"]
    for e in hints.get("entries", []):
        ctx = Ctx(e.get("s1", 1), e.get("s2", 2))
        tr.add_entry(num(e["addr"]), ctx, "call")
    for jt in hints.get("jumptables", []):
        ctx = Ctx(jt.get("s1", 1), jt.get("s2", 2))
        base = num(jt["addr"])
        o = tr.off_of(base, ctx)
        tr.forced_counts[o] = jt["count"]
        tr._add_table(base, ctx, ctx, None, jt["count"], jt.get("kind", "call"))
    tr.run()
    tr.speculate_banks = hints.get("speculate_banks", [])
    if hints.get("speculate", True):
        tr.run_speculative()
    return tr


def report(tr):
    cov = tr.coverage()
    print("Couverture code par banque (octets) :")
    for b in sorted(cov):
        print(f"  banque {b:2d} : {cov[b]:6d} o ({100 * cov[b] / BANK:5.1f} %)")
    print(f"Total : {sum(cov.values())} octets, {len(tr.code)} instructions")
    spec = sum(tr.code[o].size for o in tr.spec_code)
    print(f"  dont {spec} octets / {len(tr.probable)} entrees PROBABLES (passage speculatif)")
    print(f"\n{len(tr.problems)} problemes :")
    c = Counter(m.split(" $")[0] for _, _, m in tr.problems)
    for k, v in c.most_common():
        print(f"  {v:4d} x {k}")
    print(f"\n{len(tr.tables)} tables de saut detectees automatiquement :")
    for toff, (cpu, n, site, forced) in sorted(tr.tables.items()):
        print(f"  table ${toff:05X} (cpu ${cpu:04X}) {n:3d} entrees, utilisee par {"indication" if site is None else "$%05X" % site}")
    print(f"\n{len(tr.jpind_sites)} sauts indirects (jp (hl)/(ix)/(iy)) :")
    seen = set()
    for off, cpu, ctx in tr.jpind_sites:
        if off in seen:
            continue
        seen.add(off)
        print(f"  ${off:05X} (cpu ${cpu:04X}) ctx s1={ctx.s1} s2={ctx.s2}")


if __name__ == "__main__":
    rom = open(sys.argv[1], "rb").read()
    hints = load_hints(sys.argv[2])
    tr = build_tracer(rom, hints)
    report(tr)
    if "--problems" in sys.argv:
        for off, cpu, m in tr.problems:
            print(f"  {'' if off is None else '$%05X' % off} cpu ${cpu:04X} : {m}")


def _cached(rom, hints):
    """Cache dans build/cache/ : cle = ROM + indications + sources du traceur."""
    import hashlib
    import pickle
    here = os.path.dirname(os.path.abspath(__file__))
    h = hashlib.sha1(rom)
    h.update(json.dumps(hints, sort_keys=True).encode())
    for f in ("z80.py", "trace.py", "run_trace.py"):
        h.update(open(os.path.join(here, f), "rb").read())
    cdir = os.path.join(here, "..", "..", "build", "cache")
    path = os.path.join(cdir, f"trace_{h.hexdigest()[:16]}.pkl")
    if os.path.exists(path):
        with open(path, "rb") as f:
            return pickle.load(f)
    tr = _build_tracer(rom, hints)
    os.makedirs(cdir, exist_ok=True)
    tr._word_pos = None   # index volumineux, inutile apres le tracage
    with open(path, "wb") as f:
        pickle.dump(tr, f, protocol=pickle.HIGHEST_PROTOCOL)
    return tr
