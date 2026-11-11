"""Format des scripts d'acteurs (banque 25), interpretes par game/actor_script ($72B2).

Instruction = 1 octet de code puis ses arguments. Types : b octet, w mot, p pointeur de script.
  $00 p                  saut
  n<$CA b b b b          deplacement : pendant n trames, champs 16-19 = 4 octets (vitesses)
  $CA-$FF                commandes (table $72EB, index = $FF - code)
Flot : 'cont' (l'instruction suivante est executee ensuite, eventuellement a la trame
suivante), 'end' (pas de suite : saut, fin, aiguillage).
Source de verite : handlers de la table $72EB (voir docs/actor_scripts.md).
"""

# code: (nom, types, flot, description)
CMDS = {
    0xFF: ("call", "p", "cont", "appel de sous-script (retour par return)"),
    0xFE: ("return", "", "end", "retour de sous-script"),
    0xFD: ("move_packed", "bb", "cont", "pendant n trames, vitesse x/y en 2 quartets signes (fin de trame)"),
    0xFC: ("set_anim", "b", "cont", "champ 7 = animation"),
    0xFB: ("aim_player", "bb", "cont", "direction vers le joueur (+ decalage x, y) -> champ 26"),
    0xFA: ("switch_dir", "pppppppp", "end", "saut selon la direction (champ 26 & 7)"),
    0xF9: ("next_dir", "", "cont", "direction suivante (0-7)"),
    0xF8: ("cmd_f8", "bbb", "cont", "appelle $7B19"),
    0xF7: ("flag_yield", "", "cont", "met le bit 0 du champ 34, fin de trame"),
    0xF6: ("halt", "", "end", "arret definitif du script"),
    0xF5: ("spawn", "bbbbbb", "cont", "fait apparaitre un acteur (copie du joueur, $61A3)"),
    0xF4: ("kill", "", "end", "supprime l'acteur"),
    0xF3: ("set_flags", "b", "cont", "champ 34 |= valeur"),
    0xF2: ("clear_flags", "b", "cont", "champ 34 &= ~valeur"),
    0xF1: ("if_lt_38", "bp", "cont", "saute si valeur >= champ 38"),
    0xF0: ("if_zero", "wbp", "end", "saute si [adresse] == 0 (sinon aiguillage $7994)"),
    0xEF: ("aim_player2", "bb", "cont", "direction vers le joueur (variante $7BCE)"),
    0xEE: ("switch_player_x", "ppp", "end", "saut selon la position x par rapport au joueur"),
    0xED: ("cmd_ed", "bbb", "cont", "appelle $7B02"),
    0xEC: ("switch_x", "ppp", "end", "saut selon la position x par rapport a $6C"),
    0xEB: ("cmd_eb", "bbb", "cont", "appelle $7B0D"),
    0xEA: ("if_set", "wpp", "end", "si [adresse] != 0 saut A sinon saut B"),
    0xE9: ("cmd_e9", "bbbbbb", "cont", "appelle $7AB8"),
    0xE8: ("switch_y", "bpp", "end", "saut A si y < valeur, sinon B"),
    0xE7: ("set_dir", "b", "cont", "champ 26 = direction"),
    0xE6: ("if_hit", "p", "cont", "saute si champ 23 >= $FD"),
    0xE5: ("hide_wait", "b", "cont", "disparait pendant n trames"),
    0xE4: ("if_pos", "bwp", "cont", "compare la position (x/y selon le mode, table $760B) a un seuil ; saute"),
    0xE3: ("wait", "b", "cont", "attend n trames (fin de trame)"),
    0xE2: ("if_near", "bbppppbb", "cont", "selon la position du joueur (4 sauts)"),
    0xE1: ("if_actor", "bp", "cont", "saute si un acteur de ce type existe"),
    0xE0: ("set_osc", "bbb", "cont", "champs 25, 31, 32"),
    0xDF: ("osc_move", "bbbb", "cont", "deplacement oscillant (fin de trame)"),
    0xDE: ("loop_init", "b", "cont", "compteur de boucle (champ 25)"),
    0xDD: ("loop", "p", "cont", "reboucle tant que le compteur n'est pas nul"),
    0xDC: ("set_field", "bb", "cont", "champ[n] = valeur"),
    0xDB: ("poke", "wb", "cont", "[adresse] = valeur"),
    0xDA: ("switch_mem", "wpppp", "cont", "selon [adresse] (0 = continuer, 1-4 = sauts)"),
    0xD9: ("if_flag", "wbp", "cont", "saute si ([adresse] & masque) == 0"),
    0xD8: ("cmd_d8", "ww", "cont", "champs 36-37, 31-32 puis $3B78"),
    0xD7: ("cmd_d7", "bbb", "cont", "appelle $7B14"),
    0xD6: ("if_field_eq", "bbp", "cont", "saute si champ[n] == valeur"),
    0xD5: ("snap", "bw", "cont", "alignement ($3036)"),
    0xD4: ("kill_mark", "", "end", "supprime l'acteur et marque son parent"),
    0xD3: ("if_leader", "p", "cont", "saute si cet acteur est $C1DF"),
    0xD2: ("if_tile", "bbpb", "cont", "saute selon la tuile a (x+a, y+b)"),
    0xD1: ("set_c000", "", "cont", "met les bits 2 et 4 de $C000"),
    0xD0: ("cmp_field", "bbpp", "cont", "champ[n] == v -> A, < v -> B, sinon continue"),
    0xCF: ("or_mem", "wb", "cont", "[adresse] |= valeur"),
    0xCE: ("cmd_ce", "bbbbbp", "cont", "test ($7BEF) puis saut"),
    0xCD: ("cmd_cd", "bbbp", "cont", "test ($7BEF) puis saut"),
    0xCC: ("cmd_cc", "", "cont", "appelle $5B03"),
    0xCB: ("cmp_mem", "wbpp", "cont", "[adresse] == v -> A, < v -> B, sinon continue"),
    0xCA: ("cmd_ca", "bbb", "cont", "appelle $7AC3"),
}
SIZES = {"b": 1, "w": 2, "p": 2}


def size_of(code):
    if code == 0x00:
        return 3
    if code < 0xCA:
        return 5
    return 1 + sum(SIZES[t] for t in CMDS[code][1])


def decode_at(data, base, addr):
    """Retourne (code, nom, [(type, valeur)], taille, flot)."""
    o = addr - base
    c = data[o]
    if c == 0x00:
        return c, "jump", [("p", data[o + 1] | (data[o + 2] << 8))], 3, "end"
    if c < 0xCA:
        return c, "move", [("b", c)] + [("b", data[o + k]) for k in range(1, 5)], 5, "cont"
    name, types, flow, _ = CMDS[c]
    args, p = [], o + 1
    for t in types:
        if t == "b":
            args.append(("b", data[p]))
            p += 1
        else:
            args.append((t, data[p] | (data[p + 1] << 8)))
            p += 2
    return c, name, args, p - o, flow
