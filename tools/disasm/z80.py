"""Decodeur Z80 complet produisant de la syntaxe sdasz80.

decode(rd, pc) -> Ins
  rd(addr) : lit un octet a l'adresse CPU `addr`
  Ins.text : texte avec des marqueurs a remplacer a l'emission :
      {W}  operande 16 bits (immediate ou adresse memoire)
      {J}  cible de saut/appel (absolu ou relatif deja calcule)
  Ins.word : valeur de {W} (ou None)
  Ins.target : cible de flot (jp/jr/call/djnz/rst) ou None
  Ins.flow : 'seq' | 'jump' | 'cjump' | 'call' | 'ccall' | 'ret' | 'cret'
             | 'jpind' (jp (hl)/(ix)/(iy)) | 'halt' | 'retn'
  Ins.valid : False si opcode non documente / encodage non canonique
              (a emettre en .db pour garantir un reassemblage identique)
"""
from dataclasses import dataclass, field

R8 = ["b", "c", "d", "e", "h", "l", "(hl)", "a"]
R16 = ["bc", "de", "hl", "sp"]
R16AF = ["bc", "de", "hl", "af"]
CC = ["nz", "z", "nc", "c", "po", "pe", "p", "m"]
ALU = ["add a,", "adc a,", "sub ", "sbc a,", "and ", "xor ", "or ", "cp "]
ROT = ["rlc", "rrc", "rl", "rr", "sla", "sra", "sll", "srl"]


@dataclass
class Ins:
    pc: int
    size: int = 1
    text: str = ""
    word: int = None          # valeur 16 bits de l'operande {W}
    word_kind: str = None     # 'imm' (ld rr,#nn) ou 'mem' ((nn))
    target: int = None
    flow: str = "seq"
    valid: bool = True
    byte_imm: int = None      # immediate 8 bits (pour la propagation de A)
    raw: bytes = b""
    tags: set = field(default_factory=set)


def h8(v):
    return "#0x%02x" % (v & 0xFF)


def disp(d):
    d = d - 256 if d > 127 else d
    return "%d" % d


def decode(rd, pc):
    ins = Ins(pc)
    p = pc

    def nb():
        nonlocal p
        v = rd(p)
        p = (p + 1) & 0xFFFF
        return v

    def nw():
        lo = nb()
        hi = nb()
        return lo | (hi << 8)

    op = nb()

    # ---------- prefixes ----------
    if op == 0xCB:
        _cb(ins, nb())
    elif op == 0xED:
        _ed(ins, nb(), nb, nw)
    elif op in (0xDD, 0xFD):
        _index(ins, "ix" if op == 0xDD else "iy", nb, nw, rd)
    else:
        _main(ins, op, nb, nw, p, lambda: p)

    ins.size = (p - pc) & 0xFFFF
    if ins.flow == "_rel":
        ins.flow = ins._relflow
    ins.raw = bytes(rd((pc + i) & 0xFFFF) for i in range(ins.size))
    return ins


def _main(ins, op, nb, nw, p0, getp):
    x, y, z = op >> 6, (op >> 3) & 7, op & 7
    q, pp = y & 1, y >> 1

    def rel(cond=None, mnem="jr"):
        d = nb()
        d = d - 256 if d > 127 else d
        tgt = (getp() + d) & 0xFFFF
        ins.target = tgt
        ins.text = f"{mnem} {cond + ',' if cond else ''}{{J}}"
        return tgt

    if x == 0:
        if z == 0:
            if y == 0:
                ins.text = "nop"
            elif y == 1:
                ins.text = "ex af,af'"
            elif y == 2:
                rel(None, "djnz")
                ins.flow = "cjump"
            elif y == 3:
                rel()
                ins.flow = "jump"
            else:
                rel(CC[y - 4])
                ins.flow = "cjump"
        elif z == 1:
            if q == 0:
                ins.word = nw()
                ins.word_kind = "imm"
                ins.text = f"ld {R16[pp]},#{{W}}"
            else:
                ins.text = f"add hl,{R16[pp]}"
        elif z == 2:
            if q == 0:
                if pp == 0:
                    ins.text = "ld (bc),a"
                elif pp == 1:
                    ins.text = "ld (de),a"
                elif pp == 2:
                    ins.word = nw(); ins.word_kind = "mem"
                    ins.text = "ld ({W}),hl"
                else:
                    ins.word = nw(); ins.word_kind = "mem"
                    ins.text = "ld ({W}),a"
            else:
                if pp == 0:
                    ins.text = "ld a,(bc)"
                elif pp == 1:
                    ins.text = "ld a,(de)"
                elif pp == 2:
                    ins.word = nw(); ins.word_kind = "mem"
                    ins.text = "ld hl,({W})"
                else:
                    ins.word = nw(); ins.word_kind = "mem"
                    ins.text = "ld a,({W})"
        elif z == 3:
            ins.text = ("inc " if q == 0 else "dec ") + R16[pp]
        elif z == 4:
            ins.text = "inc " + R8[y]
        elif z == 5:
            ins.text = "dec " + R8[y]
        elif z == 6:
            v = nb()
            ins.byte_imm = v
            ins.text = f"ld {R8[y]},{h8(v)}"
        else:
            ins.text = ["rlca", "rrca", "rla", "rra", "daa", "cpl", "scf", "ccf"][y]
    elif x == 1:
        if op == 0x76:
            ins.text = "halt"
            ins.flow = "halt"
        else:
            ins.text = f"ld {R8[y]},{R8[z]}"
    elif x == 2:
        ins.text = ALU[y] + R8[z]
    else:
        if z == 0:
            ins.text = "ret " + CC[y]
            ins.flow = "cret"
        elif z == 1:
            if q == 0:
                ins.text = "pop " + R16AF[pp]
            else:
                if pp == 0:
                    ins.text = "ret"; ins.flow = "ret"
                elif pp == 1:
                    ins.text = "exx"
                elif pp == 2:
                    ins.text = "jp (hl)"; ins.flow = "jpind"
                else:
                    ins.text = "ld sp,hl"
        elif z == 2:
            ins.target = nw()
            ins.text = f"jp {CC[y]},{{J}}"
            ins.flow = "cjump"
        elif z == 3:
            if y == 0:
                ins.target = nw()
                ins.text = "jp {J}"
                ins.flow = "jump"
            elif y == 1:
                pass  # CB gere ailleurs
            elif y == 2:
                v = nb(); ins.text = f"out ({'0x%02x' % v}),a"
            elif y == 3:
                v = nb(); ins.text = f"in a,({'0x%02x' % v})"
            elif y == 4:
                ins.text = "ex (sp),hl"
            elif y == 5:
                ins.text = "ex de,hl"
            elif y == 6:
                ins.text = "di"
            else:
                ins.text = "ei"
        elif z == 4:
            ins.target = nw()
            ins.text = f"call {CC[y]},{{J}}"
            ins.flow = "ccall"
        elif z == 5:
            if q == 0:
                ins.text = "push " + R16AF[pp]
            elif pp == 0:
                ins.target = nw()
                ins.text = "call {J}"
                ins.flow = "call"
        elif z == 6:
            v = nb()
            ins.byte_imm = v
            ins.text = ALU[y] + h8(v)
        else:
            ins.target = y * 8
            ins.text = "rst " + "0x%02x" % (y * 8)
            ins.flow = "call"


def _cb(ins, op):
    x, y, z = op >> 6, (op >> 3) & 7, op & 7
    if x == 0:
        if y == 6:  # sll : non documente
            ins.valid = False
        ins.text = f"{ROT[y]} {R8[z]}"
    else:
        ins.text = f"{['', 'bit', 'res', 'set'][x]} {y},{R8[z]}"


def _ed(ins, op, nb, nw):
    x, y, z = op >> 6, (op >> 3) & 7, op & 7
    q, pp = y & 1, y >> 1
    if x == 1:
        if z == 0:
            if y == 6:
                ins.text = "in f,(c)"; ins.valid = False
            else:
                ins.text = f"in {R8[y]},(c)"
        elif z == 1:
            if y == 6:
                ins.text = "out (c),0"; ins.valid = False
            else:
                ins.text = f"out (c),{R8[y]}"
        elif z == 2:
            ins.text = ("sbc hl," if q == 0 else "adc hl,") + R16[pp]
        elif z == 3:
            ins.word = nw(); ins.word_kind = "mem"
            if q == 0:
                ins.text = f"ld ({{W}}),{R16[pp]}"
            else:
                ins.text = f"ld {R16[pp]},({{W}})"
            if pp == 2:  # ED 63 / ED 6B : doublon non canonique de 22/2A
                ins.valid = False
        elif z == 4:
            ins.text = "neg"
            if y != 0:
                ins.valid = False
        elif z == 5:
            if y == 1:
                ins.text = "reti"; ins.flow = "ret"
            else:
                ins.text = "retn"; ins.flow = "ret"
                if y != 0:
                    ins.valid = False
        elif z == 6:
            ins.text = "im " + ["0", "0", "1", "2", "0", "0", "1", "2"][y]
            if y not in (0, 2, 3):
                ins.valid = False
        else:
            t = ["ld i,a", "ld r,a", "ld a,i", "ld a,r", "rrd", "rld", None, None][y]
            if t is None:
                ins.text = "nop"; ins.valid = False
            else:
                ins.text = t
    elif x == 2 and z <= 3 and y >= 4:
        ins.text = [["ldi", "cpi", "ini", "outi"],
                    ["ldd", "cpd", "ind", "outd"],
                    ["ldir", "cpir", "inir", "otir"],
                    ["lddr", "cpdr", "indr", "otdr"]][y - 4][z]
    else:
        ins.text = "nop"; ins.valid = False


def _index(ins, ir, nb, nw, rd):
    op = nb()
    if op in (0xDD, 0xFD, 0xED):
        ins.text = "nop"; ins.valid = False   # prefixe orphelin
        return
    if op == 0xCB:
        d = nb()
        op2 = nb()
        x, y, z = op2 >> 6, (op2 >> 3) & 7, op2 & 7
        m = f"{disp(d)}({ir})"
        if z != 6 or (x == 0 and y == 6):
            ins.valid = False
        if x == 0:
            ins.text = f"{ROT[y]} {m}"
        else:
            ins.text = f"{['', 'bit', 'res', 'set'][x]} {y},{m}"
        return
    x, y, z = op >> 6, (op >> 3) & 7, op & 7
    q, pp = y & 1, y >> 1
    if op == 0x21:
        ins.word = nw(); ins.word_kind = "imm"; ins.text = f"ld {ir},#{{W}}"
    elif op == 0x22:
        ins.word = nw(); ins.word_kind = "mem"; ins.text = f"ld ({{W}}),{ir}"
    elif op == 0x2A:
        ins.word = nw(); ins.word_kind = "mem"; ins.text = f"ld {ir},({{W}})"
    elif op in (0x09, 0x19, 0x29, 0x39):
        ins.text = f"add {ir},{['bc', 'de', ir, 'sp'][pp]}"
    elif op == 0x23:
        ins.text = f"inc {ir}"
    elif op == 0x2B:
        ins.text = f"dec {ir}"
    elif op in (0x34, 0x35):
        d = nb(); ins.text = f"{'inc' if op == 0x34 else 'dec'} {disp(d)}({ir})"
    elif op == 0x36:
        d = nb(); v = nb(); ins.text = f"ld {disp(d)}({ir}),{h8(v)}"
    elif x == 1 and op != 0x76 and (y == 6 or z == 6):
        d = nb()
        m = f"{disp(d)}({ir})"
        if y == 6:
            ins.text = f"ld {m},{R8[z]}"
        else:
            ins.text = f"ld {R8[y]},{m}"
    elif x == 2 and z == 6:
        d = nb(); ins.text = ALU[y] + f"{disp(d)}({ir})"
    elif op == 0xE1:
        ins.text = f"pop {ir}"
    elif op == 0xE5:
        ins.text = f"push {ir}"
    elif op == 0xE3:
        ins.text = f"ex (sp),{ir}"
    elif op == 0xE9:
        ins.text = f"jp ({ir})"; ins.flow = "jpind"
    elif op == 0xF9:
        ins.text = f"ld sp,{ir}"
    else:
        # ixh/ixl et autres formes non documentees, ou prefixe sans effet
        ins.text = "?"
        ins.valid = False
        # consommer les octets eventuels pour avoir la bonne taille
        if (x == 0 and z == 6) or (x == 3 and z == 6):
            nb()
