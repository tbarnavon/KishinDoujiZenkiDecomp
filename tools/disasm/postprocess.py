"""Post-traitement des sources generees (etape 5) : noms de champs et RAM par module.

1. Dans les modules qui manipulent des acteurs (iy = acteur), `N(iy)` -> `ACTOR_xxx(iy)`
   (offsets definis dans src/include/structs.inc).
2. Chaque variable RAM encore anonyme (`ram_XXXX`) recoit le prefixe du module qui y
   accede le plus (ex. player_CEF1) ; ram.inc est reecrit groupe par module et
   docs/ram_by_module.md est genere (carte memoire detaillee).
Le resultat assemble a l'identique (memes valeurs).
"""
import os
import re
from collections import Counter, defaultdict

ACTOR_MODULES = {"game/actor_script", "game/actors", "video/sprites"}
PREFIX = {"actors": "actor", "actor_script": "ascript", "player": "player", "level": "level",
          "script": "scene", "text": "text", "sprites": "sprite", "palette": "pal", "vdp": "vdp",
          "irq": "irq", "tasks": "task", "game_flow": "flow", "util": "util", "collision": "coll",
          "stage_events": "event", "scroll": "scroll", "joypad": "joy", "sound_api": "snd",
          "sound_driver": "snd", "debug_menu": "dbg", "pause_menu": "pause", "boot": "boot",
          "sms_port": "port", "header": "hdr"}


def _module_of(rel):
    rel = rel.replace("\\", "/")[:-2]
    if rel.startswith("version/"):
        base = rel.split("/", 2)[2]           # ex. input_joypad
        return base.replace("_", "/", 1)
    return rel


def actor_fields(structs_inc):
    fields = {}
    for line in open(structs_inc, encoding="utf-8"):
        m = re.match(r"(ACTOR_[A-Z_]+)\s*=\s*(\d+)", line)
        if m and m.group(1) != "ACTOR_SIZE":
            fields.setdefault(int(m.group(2)), m.group(1))
    return fields


def run(src_dir, root, ram_named):
    """ram_named : {adresse: nom} deja nommes dans symbols.json (inchanges)."""
    files = []
    for dp, _, fn in os.walk(src_dir):
        for x in fn:
            if x.endswith(".s"):
                files.append(os.path.join(dp, x))
    fields = actor_fields(os.path.join(src_dir, "include", "structs.inc"))
    rx_iy = re.compile(r"(?<![\w-])(\d+)\(iy\)")
    rx_ram = re.compile(r"\bram_([0-9A-F]{4})\b")
    usage = defaultdict(Counter)
    texts = {}
    for f in files:
        rel = os.path.relpath(f, src_dir)
        mod = _module_of(rel)
        t = open(f, encoding="utf-8").read()
        if mod in ACTOR_MODULES:
            t = rx_iy.sub(lambda m: f"{fields[int(m.group(1))]}(iy)" if int(m.group(1)) in fields else m.group(0), t)
        for m in rx_ram.finditer(t):
            usage[int(m.group(1), 16)][mod] += 1
        texts[f] = (mod, t)
    # nouveaux noms
    newname = {}
    for a, cnt in usage.items():
        if a in ram_named:
            continue
        mod = cnt.most_common(1)[0][0]
        pre = PREFIX.get(mod.split("/")[-1], mod.split("/")[-1])
        newname[a] = f"{pre}_{a:04X}"
    rep = lambda m: newname.get(int(m.group(1), 16), m.group(0))
    for f, (mod, t) in texts.items():
        t = rx_ram.sub(rep, t)
        if '.include "structs.inc"' not in t:
            t = t.replace('\t.include "ram.inc"\n', '\t.include "ram.inc"\n\t.include "structs.inc"\n', 1)
        open(f, "w", encoding="utf-8", newline="\n").write(t)
    # ram.inc groupe par module
    inc = os.path.join(src_dir, "include", "ram.inc")
    old = {}
    for line in open(inc, encoding="utf-8"):
        m = re.match(r"(\w+)\s*=\s*0x([0-9A-F]{4})(.*)$", line.rstrip("\n"))
        if m:
            old[int(m.group(2), 16)] = (m.group(1), m.group(3))
    groups = defaultdict(list)
    for a, (nm, cm) in old.items():
        mod = usage[a].most_common(1)[0][0] if usage.get(a) else "(non reference)"
        groups[mod].append((a, newname.get(a, nm), cm, usage.get(a, Counter())))
    with open(inc, "w", encoding="utf-8", newline="\n") as f:
        f.write(";; ram.inc - carte memoire RAM ($C000-$DFFF), groupee par module proprietaire\n")
        f.write(";; (= module qui accede le plus a la variable). GENERE par tools/disasm/emit.py.\n")
        f.write(";; Nom prefixe_XXXX = role non identifie. Voir docs/memory_map.md et docs/ram_by_module.md.\n")
        for mod in sorted(groups):
            f.write(f"\n;; ---- {mod}\n")
            for a, nm, cm, _ in sorted(groups[mod]):
                f.write(f"{nm:<28s} = 0x{a:04X}{cm}\n")
    # documentation
    with open(os.path.join(root, "docs", "ram_by_module.md"), "w", encoding="utf-8", newline="\n") as f:
        f.write("# RAM par module (GÉNÉRÉ)\n\nGénéré par `tools/disasm/emit.py` (post-traitement). "
                "Module propriétaire = celui qui accède le plus à la variable ; « aussi » = autres modules.\n"
                "Les noms `prefixe_XXXX` désignent des variables dont le rôle n'est pas encore identifié.\n")
        for mod in sorted(groups):
            f.write(f"\n## {mod}\n\n| Adresse | Nom | Accès | Aussi utilisée par |\n|---|---|---|---|\n")
            for a, nm, cm, cnt in sorted(groups[mod]):
                others = ", ".join(f"{m} ({n})" for m, n in cnt.most_common()[1:4])
                f.write(f"| `${a:04X}` | `{nm}` | {sum(cnt.values())} | {others} |\n")
    return len(newname)
