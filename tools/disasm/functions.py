"""Decoupage en fonctions et classification grossiere par usage materiel.

Une fonction = une entree (cible de call/rst/table/indication) et toutes les
instructions atteignables sans suivre les call, jusqu'aux ret/jp vers une
autre fonction.
"""
from collections import defaultdict

PORT_CLASSES = {
    0xBE: "vdp", 0xBF: "vdp", 0x7E: "vdp", 0x7F: "psg",
    0xDC: "input", 0xDD: "input", 0x00: "gg_start", 0x06: "gg_stereo",
}


def build_functions(tr):
    """Retourne {off_entree: {'body': set(off), 'callees': set, 'ports': set, 'ram': set}}."""
    funcs = {}
    entries = sorted(tr.entries | set(tr.probable))
    entry_set = set(entries)
    for e in entries:
        if e not in tr.code:
            continue
        body, stack = set(), [e]
        callees, ports, ram = set(), set(), set()
        while stack:
            o = stack.pop()
            if o in body or o not in tr.code:
                continue
            if o != e and o in entry_set:
                continue  # entree d'une autre fonction (tail call)
            body.add(o)
            ins = tr.code[o]
            t = ins.text
            for p, cls in PORT_CLASSES.items():
                if t.endswith(f"(0x{p:02x}),a") or t.startswith(f"in a,(0x{p:02x})"):
                    ports.add(cls)
            if t.startswith(("out (c)", "in ", "otir", "outi", "inir", "ini")) and "0x" not in t:
                ports.add("port_c")
            if t.startswith("rst 0x08") or t.startswith("rst 0x10"):
                ports.add("vdp")
            if ins.word_kind == "mem" and ins.word is not None and ins.word >= 0xC000:
                ram.add(ins.word)
            if ins.word == 0xFFFF or ins.word == 0xFFFE:
                ports.add("mapper")
            tgt = tr.ins_target.get(o)
            if ins.flow in ("call", "ccall") and tgt is not None:
                callees.add(tgt)
            nxt = o + ins.size
            if ins.flow in ("seq", "call", "ccall", "cjump", "cret"):
                stack.append(nxt)
            if ins.flow in ("jump", "cjump") and tgt is not None:
                if tgt in entry_set and tgt != e:
                    callees.add(tgt)
                else:
                    stack.append(tgt)
        funcs[e] = {"body": body, "callees": callees, "ports": ports, "ram": ram,
                    "size": sum(tr.code[o].size for o in body)}
    callers = defaultdict(set)
    for e, f in funcs.items():
        for c in f["callees"]:
            callers[c].add(e)
    for e, f in funcs.items():
        f["callers"] = callers[e]
    return funcs
