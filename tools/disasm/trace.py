"""Traceur de code Z80 pour ROM SMS/GG avec mapper Sega.

Suit le flot d'execution depuis des points d'entree en propageant :
  - l'etat du mapper : banque du slot 1 ($FFFE) et du slot 2 ($FFFF) ;
  - la valeur de A quand elle est constante (pour `ld a,#n / ld ($FFFF),a`)
    et le registre miroir de banque ($DCBE dans ce jeu, configurable).

Le slot 0 ($0000-$3FFF) est toujours la banque 0.
Une localisation de code est un offset ROM ; l'adresse CPU sous laquelle il
est execute (« vue ») est memorisee pour l'emission.
"""
from collections import defaultdict, deque

from z80 import decode

BANK = 0x4000

# Instructions qui ne modifient pas A (prefixes de texte). Tout le reste rend A inconnu.
_A_SAFE_PREFIX = ("ld (", "ld b", "ld c", "ld d", "ld e", "ld h", "ld l", "ld sp", "ld i",
                  "push", "pop bc", "pop de", "pop hl", "pop ix", "pop iy", "inc b", "inc c",
                  "inc d", "inc e", "inc h", "inc l", "inc (", "inc s", "inc i", "dec b", "dec c",
                  "dec d", "dec e", "dec h", "dec l", "dec (", "dec s", "dec i", "add hl", "add ix",
                  "add iy", "adc hl", "sbc hl", "ex de", "ex (sp)", "exx", "di", "ei", "nop",
                  "out", "jp", "jr", "djnz", "ret", "bit", "set", "res", "ldi", "ldd", "ldir",
                  "lddr", "otir", "outi", "outd", "otdr", "im ", "scf", "ccf", "halt", "cp ",
                  "in b", "in c", "in d", "in e", "in h", "in l", "cpi", "cpd", "cpir", "cpdr")
_A_SAFE_EXACT = {"ld (hl),a"}


def modifies_a(text):
    t = text
    if t in _A_SAFE_EXACT:
        return False
    for p in ("ld (", "ld 0", "ld 1", "ld 2", "ld 3", "ld 4", "ld 5", "ld 6", "ld 7", "ld 8", "ld 9", "ld -"):
        if t.startswith(p):
            return False   # ecriture memoire
    # rotations / bit / set / res sur registre autre que a
    for r in ("rlc ", "rrc ", "rl ", "rr ", "sla ", "sra ", "srl ", "sll "):
        if t.startswith(r):
            return t.endswith(" a")
    if t.startswith(("set ", "res ")):
        return t.endswith(",a")
    return not t.startswith(_A_SAFE_PREFIX)


class Ctx(tuple):
    """(s1, s2, a) ; None = inconnu."""
    __slots__ = ()

    def __new__(cls, s1, s2, a=None):
        return tuple.__new__(cls, (s1, s2, a))

    def __getnewargs__(self):      # pour le cache (pickle)
        return tuple(self)

    s1 = property(lambda s: s[0])
    s2 = property(lambda s: s[1])
    a = property(lambda s: s[2])


class Tracer:
    def __init__(self, rom, bank_shadow=None, max_ctx=6):
        self.rom = rom
        self.nbanks = len(rom) // BANK
        self.bank_shadow = bank_shadow     # adresse RAM miroir du slot 2
        self.max_ctx = max_ctx
        self.code = {}                     # off -> Ins
        self.owner = {}                    # off de chaque octet d'instruction -> off de debut
        self.views = defaultdict(set)      # off -> {adresses CPU d'execution}
        self.entries = set()               # offsets cibles de call/rst/entree
        self.jumps = set()                 # offsets cibles de jp/jr
        self.refs = defaultdict(set)       # off cible -> {off instruction source}
        self.ins_target = {}               # off instruction -> off cible (flot)
        self.ins_word = {}                 # off instruction -> off designe par l'operande 16 bits
        self.problems = []                 # (off, cpu, message)
        self.seen_ctx = defaultdict(set)   # off -> {ctx}
        self.queue = deque()
        self.jpind_sites = []
        self.data_bytes = set()            # octets connus comme donnees (tables, indications)
        self.table_targets = {}            # off table -> [(mot, off cible)]
        self.tables = {}                   # off table -> (adresse cpu, nb entrees, off du jp)
        self.auto_tables = True
        self.spec_mode = False
        self.spec_code = set()             # instructions atteintes uniquement via le passage speculatif
        self.rejected = []                 # entrees speculatives rejetees (off, cpu, raison)
        self.speculate_banks = []          # banques >= 2 ou chercher du code par pointeur (slot 2)
        self.probable = set()              # entrees ajoutees par le passage speculatif
        self._imm_words = set()
        self.forced_counts = {}            # off table -> nb d'entrees (indications)
        self.dispatch_helpers = {}         # off helper -> registre portant la table

    # ---------- adressage ----------
    def bank_of(self, cpu, ctx):
        if cpu < 0x4000:
            return 0
        if cpu < 0x8000:
            return ctx.s1
        if cpu < 0xC000:
            return ctx.s2
        return "ram"

    def off_of(self, cpu, ctx):
        b = self.bank_of(cpu, ctx)
        if b is None or b == "ram":
            return None
        if b >= self.nbanks:
            return None
        return b * BANK + (cpu & 0x3FFF)

    # ---------- file ----------
    def add_entry(self, cpu, ctx, kind="call", src=None):
        off = self.off_of(cpu, ctx)
        if off is None:
            where = "RAM" if cpu >= 0xC000 else "banque inconnue"
            self.problems.append((src, cpu, f"cible {kind} ${cpu:04X} en {where}"))
            return None
        (self.entries if kind == "call" else self.jumps).add(off)
        if src is not None:
            self.refs[off].add(src)
        self.queue.append((cpu, ctx))
        return off

    def run(self):
        while self.queue:
            cpu, ctx = self.queue.popleft()
            self._trace_block(cpu, ctx)

    # ---------- coeur ----------
    def _auto_table(self, off, cpu, ctx, history):
        """Detecte `ld de|hl,#T ... add hl,de ... ld e,(hl) inc hl ld d,(hl) ex de,hl ... jp (hl)`."""
        if self.auto_tables is False:
            return
        texts = [i.text for _, i, _ in history]
        # 1. lecture du pointeur : ld e|c|a,(hl)
        k_read = max((k for k, t in enumerate(texts) if t in ("ld e,(hl)", "ld a,(hl)", "ld c,(hl)")), default=None)
        if k_read is None:
            return
        # 2. le add hl,rr qui precede cette lecture
        k_add = max((k for k, t in enumerate(texts[:k_read]) if t.startswith("add hl,")), default=None)
        if k_add is None:
            return
        # 3. la base : le dernier ld rr,#T avant ce add
        base = None
        for o, i, c in reversed(history[:k_add]):
            if i.text in ("ld de,#{W}", "ld hl,#{W}", "ld bc,#{W}") and i.word is not None and i.word < 0xC000:
                base = (i.word, c)
                break
        if base is None:
            return
        self._add_table(base[0], base[1], ctx, off)

    def call_dispatch_helper(self, off, ctx, history, reg="de"):
        """Site d'appel/saut vers un helper de dispatch : la table est le dernier `ld <reg>,#T`."""
        for o, i, c in reversed(history):
            if i.text == f"ld {reg},#{{W}}" and i.word is not None and i.word < 0xC000:
                self._add_table(i.word, c, ctx, off)
                return
        self.problems.append((off, None, "dispatch helper sans table identifiee"))

    def _add_table(self, taddr, tctx, ctx, off, count=None, kind="jump"):
        toff = self.off_of(taddr, tctx)
        if toff is None:
            return
        if toff in self.tables:
            return  # table deja traitee (indication ou detection anterieure)
        if count is None and toff in self.forced_counts:
            count = self.forced_counts[toff]
        targets = []
        limit = None
        for k in range(count if count is not None else 128):
            p = toff + 2 * k
            if count is None:
                if limit is not None and p >= limit:
                    break
                if p in self.owner:
                    break
            w = self.rom[p] | (self.rom[p + 1] << 8)
            o = self.off_of(w, ctx)
            if count is None:
                if o is None or w < 0x0040:
                    break
                if toff <= o < toff + 2 * k + 2:
                    break
            targets.append(w)
            if o is not None and toff < o and (limit is None or o < limit):
                limit = o
        if not targets:
            return
        self.tables[toff] = (taddr, len(targets), off, count is not None)
        for k in range(2 * len(targets)):
            self.data_bytes.add(toff + k)
        tctx = Ctx(ctx.s1, ctx.s2, None)
        self.table_targets[toff] = [(w, self.off_of(w, tctx)) for w in targets]
        for w in targets:
            self.add_entry(w, tctx, kind, toff)

    def _trace_block(self, cpu, ctx):
        history = []
        while True:
            off = self.off_of(cpu, ctx)
            if off is None:
                return
            # contexte deja vu a cet endroit ?
            key = ctx
            seen = self.seen_ctx[off]
            if key in seen:
                return
            if len(seen) >= self.max_ctx:
                # on generalise : A inconnu, slots conserves
                key = Ctx(ctx.s1, ctx.s2, None)
                if key in seen:
                    return
                ctx = key
            seen.add(key)

            if any((off + k) in self.data_bytes for k in range(4)) and off in self.data_bytes:
                self.problems.append((off, cpu, f"code sur une zone de donnees connue"))
                return
            if off in self.owner and self.owner[off] != off:
                self.problems.append((off, cpu, f"saut au milieu de l'instruction ${self.owner[off]:05X}"))
                return

            bank = off // BANK
            base_cpu = cpu - (off & 0x3FFF)

            def rd(a, bank=bank, base=base_cpu):
                rel = a - base
                if 0 <= rel < BANK:
                    return self.rom[bank * BANK + rel]
                # debordement de slot : lecture via le contexte
                o = self.off_of(a & 0xFFFF, ctx)
                return self.rom[o] if o is not None else 0xFF

            ins = decode(rd, cpu)
            if not ins.valid and ins.text in ("?", "nop") and ins.raw[0] in (0xDD, 0xFD, 0xED):
                self.problems.append((off, cpu, f"opcode invalide {ins.raw.hex(' ')}"))
                return
            for i in range(ins.size):
                o2 = off + i
                if o2 in self.owner and self.owner[o2] != off:
                    self.problems.append((off, cpu, f"chevauchement avec l'instruction ${self.owner[o2]:05X}"))
                    return
            if any((off + i) in self.data_bytes for i in range(ins.size)):
                self.problems.append((off, cpu, "instruction chevauchant des donnees connues"))
                return
            for i in range(ins.size):
                self.owner[off + i] = off
            self.code[off] = ins
            self.views[off].add(cpu)
            if self.spec_mode:
                self.spec_code.add(off)

            nxt = (cpu + ins.size) & 0xFFFF
            ctx = self._apply(ins, ctx, off)

            # operande 16 bits : reference eventuelle vers la ROM
            if ins.word is not None and ins.word < 0xC000:
                o = self.off_of(ins.word, ctx)
                if o is not None:
                    self.ins_word[off] = o
                    self.refs[o].add(off)

            f = ins.flow
            if f in ("call", "ccall", "jump", "cjump") and ins.target is not None:
                tgo = self.off_of(ins.target, ctx)
                if tgo in self.dispatch_helpers:
                    self.call_dispatch_helper(off, ctx, history, self.dispatch_helpers[tgo])
            if f in ("call", "ccall"):
                t = self.add_entry(ins.target, ctx, "call", off)
                if t is not None:
                    self.ins_target[off] = t
                ctx = Ctx(ctx.s1, ctx.s2, None)
            elif f in ("jump", "cjump"):
                t = self.add_entry(ins.target, ctx, "jump", off)
                if t is not None:
                    self.ins_target[off] = t
                if f == "jump":
                    return
            elif f in ("ret", "halt"):
                return
            elif f == "jpind":
                self.jpind_sites.append((off, cpu, ctx))
                self._auto_table(off, cpu, ctx, history)
                return
            history.append((off, ins, ctx))
            if len(history) > 12:
                history.pop(0)
            cpu = nxt

    def _apply(self, ins, ctx, off):
        """Met a jour l'etat (A, slots) apres `ins`."""
        s1, s2, a = ctx
        t = ins.text
        if t.startswith("ld a,#"):
            a = ins.byte_imm
        elif t == "ld a,({W})":
            if self.bank_shadow is not None and ins.word == self.bank_shadow:
                a = "S2"   # A == banque courante du slot 2 (relue depuis le miroir)
            else:
                a = None
        elif t == "ld ({W}),a":
            if ins.word == 0xFFFF:
                if a != "S2":
                    s2 = a
                if a is None:
                    self.problems.append((off, ins.pc, "ecriture $FFFF avec A inconnu"))
            elif ins.word == 0xFFFE:
                s1 = a
                if a is None:
                    self.problems.append((off, ins.pc, "ecriture $FFFE avec A inconnu"))
            elif ins.word == 0xFFFD and a not in (0, None):
                self.problems.append((off, ins.pc, f"slot 0 bascule en banque {a}"))
        elif t == "ld ({W}),hl" and ins.word in (0xFFFC, 0xFFFE):
            pass  # init du mapper : traite par les points d'entree
        elif modifies_a(t):
            a = None
        return Ctx(s1, s2, a)

    # ---------- passage speculatif ----------
    def plausible_code(self, off, cpu, max_ins=300):
        """Desassemblage lineaire depuis `off` : True si cela ressemble a du code."""
        bank = off // BANK
        base = cpu - (off & 0x3FFF)
        rd = lambda a: self.rom[bank * BANK + ((a - base) & 0x3FFF)]
        pc, n, weird, nops = cpu, 0, 0, 0
        for _ in range(max_ins):
            o = bank * BANK + ((pc - base) & 0x3FFF)
            if o in self.owner:
                # on rejoint du code connu : OK seulement si c'est un debut d'instruction
                return self.owner[o] == o and n >= 2
            ins = decode(rd, pc)
            if not ins.valid:
                return False
            t = ins.text
            if t in ("halt", "rst 0x38", "ld b,b", "ld c,c", "ld d,d", "ld e,e", "ld h,h", "ld l,l",
                     "ld a,a", "ex af,af'", "di", "rrd", "rld", "ld i,a", "ld r,a", "ld a,i", "ld a,r"):
                weird += 1
            nops = nops + 1 if t == "nop" else 0
            if nops >= 2 or weird >= 2:
                return False
            n += 1
            if ins.flow in ("ret", "jump", "jpind"):
                return n >= 2 or ins.flow == "jump"
            if (pc & 0xC000) != ((pc + ins.size) & 0xC000):
                return False
            pc = (pc + ins.size) & 0xFFFF
        return False

    def speculate(self, regions=((0, 0x0040, 0x4000), (1, 0x4000, 0x8000))):
        """Ajoute comme entrees probables les adresses pointees par un mot de la ROM."""
        added = 0
        for bank, lo, hi in regions:
            for cpu in range(lo, hi):
                off = bank * BANK + (cpu & 0x3FFF)
                if off in self.owner or off in self.probable or off in self.data_bytes:
                    continue
                pat = bytes([cpu & 0xFF, cpu >> 8])
                # reference : immediate dans le code trace, ou mot dans une zone non code
                refd = cpu in self._imm_words
                if not refd:
                    refd = any(i not in self.owner for i in self._word_pos.get(cpu, ()))
                if not refd:
                    continue
                if self.plausible_code(off, cpu):
                    snap = self._snapshot()
                    self.add_entry(cpu, Ctx(1, bank if cpu >= 0x8000 else None), "call")
                    self.run()
                    bad = [m for _, _, m in self.problems[snap["problems"]:] if not m.startswith("ecriture")]
                    if bad:
                        self._rollback(snap)
                        self.rejected.append((off, cpu, bad[0]))
                    else:
                        self.probable.add(off)
                        added += 1
        return added

    _SNAP_DICTS = ("code", "owner", "ins_target", "ins_word", "tables", "table_targets")
    _SNAP_SETS = ("entries", "jumps", "spec_code", "data_bytes")

    def _snapshot(self):
        s = {k: set(getattr(self, k).keys()) for k in self._SNAP_DICTS}
        s.update({k: set(getattr(self, k)) for k in self._SNAP_SETS})
        s["views"] = {k: set(v) for k, v in self.views.items()}
        s["refs"] = {k: set(v) for k, v in self.refs.items()}
        s["seen_ctx"] = {k: set(v) for k, v in self.seen_ctx.items()}
        s["problems"] = len(self.problems)
        s["jpind"] = len(self.jpind_sites)
        return s

    def _rollback(self, s):
        for k in self._SNAP_DICTS:
            d = getattr(self, k)
            for key in list(d.keys()):
                if key not in s[k]:
                    del d[key]
        for k in self._SNAP_SETS:
            getattr(self, k).intersection_update(s[k])
        for k in ("views", "refs", "seen_ctx"):
            d = getattr(self, k)
            d.clear()
            d.update({kk: set(v) for kk, v in s[k].items()})
        del self.problems[s["problems"]:]
        del self.jpind_sites[s["jpind"]:]

    def _index_words(self):
        """Index mot 16 bits -> offsets ou il apparait (une seule passe sur la ROM)."""
        idx = {}
        r = self.rom
        for i in range(len(r) - 1):
            idx.setdefault(r[i] | (r[i + 1] << 8), []).append(i)
        self._word_pos = idx

    def run_speculative(self, rounds=6):
        self._index_words()
        self.spec_mode = True
        total = 0
        for _ in range(rounds):
            self._imm_words = {i.word for i in self.code.values() if i.word_kind == "imm" and i.word is not None}
            regs = [(0, 0x0040, 0x4000), (1, 0x4000, 0x8000)] +                 [(b, 0x8000, 0xC000) for b in self.speculate_banks]
            n = self.speculate(regs)
            total += n
            if not n:
                break
        self.spec_mode = False
        return total

    # ---------- resultats ----------
    def coverage(self):
        per_bank = defaultdict(int)
        for off, ins in self.code.items():
            per_bank[off // BANK] += ins.size
        return per_bank
