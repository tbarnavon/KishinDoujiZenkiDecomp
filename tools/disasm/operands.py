"""Classement semantique des operandes 16 bits (etape 5 : plus d'adresses en dur).

Pour chaque instruction avec un operande 16 bits < $C000, on regarde comment la valeur est
utilisee dans les instructions qui suivent (meme bloc lineaire) :
  ('vdp', expr)  : commande VDP chargee dans de puis envoyee (rst $08/$10, routines VDP)
                   -> VDP_VRAM_WRITE|adr, VDP_REG_n|val, VDP_CRAM_WRITE|idx
  ('ptr', off)   : pointeur vers la ROM (base de table, source de copie, adresse de retour...)
                   dans une banque dont le contenu est dans src/ -> label
  None           : constante (comparaison, compteur, taille, valeur de remplissage...)
"""
BANK = 0x4000
SRC_BANKS = {0, 1, 2, 23, 25, 26}            # banques generees dans src/ (pas composees)
VDP_ROUTINES = {0x0008, 0x0010, 0x44D0, 0x44E4, 0x454E, 0x46A1, 0x44CA}


def _next_texts(ver, off, n=6):
    order, idx = ver.order, ver.idx
    out = []
    k = idx.get(off)
    if k is None:
        return out
    for j in range(k + 1, min(k + 1 + n, len(order))):
        ins = ver.tr.code[order[j]]
        out.append(ins)
        if ins.flow in ("jump", "ret", "jpind", "halt"):
            break
    return out


def classify(ver, off, ins, asset_ranges):
    w = ins.word
    if w is None or w >= 0xC000 and not (0xC000 <= w < 0xC040):
        return None
    text = ins.text
    reg = text.split()[1].split(",")[0] if " " in text else ""
    nxt = _next_texts(ver, off)
    if ins.word_kind == "imm" and reg == "de":
        vdp_use = any(i.text in ("rst 0x10", "rst 0x08") or
                      (i.flow in ("call", "jump") and i.target in VDP_ROUTINES) for i in nxt[:5])
        if vdp_use:
            if 0x4000 <= w < 0x8000:
                return ("vdp", f"VDP_VRAM_WRITE|0x{w & 0x3FFF:04x}")
            if 0x8000 <= w < 0x8B00:
                return ("vdp", f"VDP_REG_{(w >> 8) & 0xF}|0x{w & 0xFF:02x}")
            if 0xC000 <= w < 0xC040:
                return ("vdp", f"VDP_CRAM_WRITE|0x{w & 0x3F:02x}")
    if w >= 0xC000 or w < 0x100:
        return None
    if ins.word_kind == "imm" and reg not in ("hl", "de", "ix", "iy"):
        return None
    tgt = ver.tr.ins_word.get(off)
    if tgt is None:
        return None
    in_asset = any(lo <= tgt < hi for lo, hi in asset_ranges)
    fixed = tgt // BANK not in SRC_BANKS or in_asset
    # comparaison / arithmetique : pas un pointeur
    for i in nxt[:2]:
        if i.text.startswith(("sbc hl", "cp ")) or (i.text == "or a" and len(nxt) > 1 and nxt[1].text.startswith("sbc")):
            return None
    if fixed:
        # donnee d'une banque composee depuis assets/ (position fixe) : constante nommee
        if in_asset or tgt // BANK in SRC_BANKS:
            return None          # deja geree par les labels exportes des compilateurs d'assets
        return ("eq", tgt)
    if not ver.is_boundary(tgt):
        return None
    return ("ptr", tgt)
