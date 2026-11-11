"""Format des scripts de scenes (banque 5), interpretes par game/script ($6574).

Chaque opcode = 1 octet, suivi de ses arguments. Types d'arguments :
  b  octet            w  mot (16 bits, petit-boutiste)
  p  pointeur vers une autre instruction du script (banque 5) -> label
Fin de flot : 00 (fin de scene), 0B (saut), 18 (retour).
Source de verite : les handlers de la table $6595 (voir docs/scripts.md).
"""

# code: (mnemonique, types d'arguments, description)
OPS = {
    0x00: ("end", "", "fin de la scene (retour a la tache)"),
    0x01: ("load_vram", "wwwbb", "copie src -> VRAM : src, adresse VRAM, longueur, drapeaux ($C0B1), banque"),
    0x02: ("obj_init", "wbbb", "initialise l'objet de scene (adresse RAM), x, y, type"),
    0x03: ("obj_set", "bbwbbbb", "regle les champs 15/21 puis 16-19 d'un objet de scene"),
    0x04: ("clear", "w", "met 0 a l'adresse"),
    0x05: ("vram_fill", "www", "remplit la VRAM : valeur, adresse VRAM, nombre"),
    0x06: ("wait", "b", "attend n trames (fin de trame)"),
    0x07: ("music", "b", "joue une musique ($DE05)"),
    0x08: ("sfx", "b", "joue un effet sonore ($DE04)"),
    0x09: ("yield", "", "fin de trame"),
    0x0A: ("text", "bb", "affiche le texte n (vitesse, numero de chaine)"),
    0x0B: ("jump", "p", "saut"),
    0x0C: ("poke", "wb", "ecrit un octet en RAM"),
    0x0D: ("pokew", "ww", "ecrit un mot en RAM"),
    0x0E: ("scroll", "bb", "position de defilement x, y"),
    0x0F: ("scroll_move", "bbb", "vitesse de defilement dx, dy, pendant n trames"),
    0x10: ("fade_in", "b", "fondu d'entree"),
    0x11: ("fade_out", "b", "fondu de sortie"),
    0x12: ("load_tiles", "wwb", "charge des tuiles : adresse VRAM, source, banque"),
    0x13: ("load_palette", "bbw", "charge une palette : banque, choix (0=fond, 1=sprites), source"),
    0x14: ("set_color", "bbw", "change une couleur : palette, index, couleur"),
    0x15: ("fade_15", "b", "effet de palette $58C0"),
    0x16: ("fade_16", "b", "effet de palette $58C9"),
    0x17: ("call", "p", "appel de sous-script"),
    0x18: ("return", "", "retour de sous-script"),
    0x19: ("loop_init", "b", "compteur de boucle"),
    0x1A: ("loop", "p", "reboucle tant que le compteur n'est pas nul"),
    0x1B: ("set_c907", "bb", "ecrit $C908 puis $C907"),
    0x1C: ("anim_a", "wb", "lance l'animation A : pointeur, banque"),
    0x1D: ("wait_button", "", "attend un bouton"),
    0x1E: ("anim_b", "wb", "lance l'animation B : pointeur, banque"),
    0x1F: ("raster", "ww", "parametres raster ($C1BC, $C1B8)"),
    0x20: ("obj_type", "wb", "change le type d'un objet de scene"),
    0x21: ("flag_c000_2", "", "met le bit 2 de $C000"),
    0x22: ("if_bits", "wbp", "saute si (adresse & masque) == masque"),
    0x23: ("and", "wb", "adresse &= valeur"),
    0x24: ("or", "wb", "adresse |= valeur"),
    0x25: ("menu", "", "gestion d'un menu (haut/bas)"),
    0x26: ("fade_26", "b", "effet de palette + remise a zero"),
    0x27: ("raster_mode", "", "mode raster ($C013 = 6)"),
    0x28: ("special", "b", "sequence speciale ($C013 = 5, table banque 4 $B55E)"),
    0x29: ("vram_write", "wwbb", "ecriture VRAM (2 mots, 1 octet, 1 octet ignore)"),
    0x2A: ("wait_objects", "", "attend la fin des objets de scene"),
    0x2B: ("sound_init", "", "reinitialise le son"),
    0x2C: ("sound_stop", "", "coupe le son"),
}
END_FLOW = {0x00, 0x0B, 0x18}
SIZES = {"b": 1, "w": 2, "p": 2}


def ins_size(op):
    return 1 + sum(SIZES[t] for t in OPS[op][1])


def decode_at(data, base, addr):
    """Decode une instruction a l'adresse CPU `addr` (data = banque, base = $8000)."""
    o = addr - base
    op = data[o]
    if op not in OPS:
        raise ValueError(f"opcode inconnu ${op:02X} a ${addr:04X}")
    args, p = [], o + 1
    for t in OPS[op][1]:
        if t == "b":
            args.append(data[p])
            p += 1
        else:
            args.append(data[p] | (data[p + 1] << 8))
            p += 2
    return op, args, p - o
