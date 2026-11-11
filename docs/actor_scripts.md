# Scripts d'acteurs (banque 25)

Le comportement des ennemis, objets et projectiles est un **bytecode** exécuté par
`game/actor_script` (`$72B2`) pour chacun des 13 acteurs (tâche 2).
✅ Format confirmé : 4 789 instructions décodées sans conflit, recompilées **octet pour octet**
(SMS EN et GG JP, banque identique).

## Fichiers

| Fichier | Rôle |
|---|---|
| `assets/<ver>/actors/bank25.as` | scripts d'acteurs (**à éditer**) |
| `tools/assets/ascript.py` | définition des instructions (source de vérité) |
| `tools/assets/actors.py` | `extract` (refuse d'écraser sans `FORCE=1`), `build`, `check` |

Le build recompile le `.as` dans l'area `_B25_8000` ($8000-$BDAB) ; le code banqué de la
banque 25 (`$BDAC`, `src/game/actors.s`) suit.

## Fonctionnement ✅

- `$8000` : pointeur vers la **table des types** (`actor_types`, 253 entrées) : le script de
  départ d'un acteur est `actor_types[type]` (type = champ 0 de l'acteur), lu par `$3B28`.
- Autres tables utilisées par le code : `$B8B8` (15 pointeurs, `$13D7`), `$BD21`
  (5 × [pointeur, mot], `$1667`), `$BD35` (5 pointeurs, `$1698`). Elles portent des labels
  **globaux** `actors_XXXX` que le code référence par leur nom : les scripts peuvent donc
  changer de taille sans casser le code.
- Champs de l'acteur utilisés : 0 type, 7 animation, 16-19 vitesse x/y, 23 état de collision,
  25 compteur de boucle, 26 direction (0-7), 27-28 pointeur de script, 29-30 adresse de retour,
  31-32 oscillation, 33 délai, 34 drapeaux, 36-37 parent, 38 compteur.
- Un acteur avance d'instruction en instruction dans la même trame jusqu'à une instruction
  qui consomme du temps (`move`, `wait`, `move_packed`, `osc_move`, `flag_yield`...).

## Instructions

| Code | Nom | Arguments | Flot | Effet |
|---|---|---|---|---|
| `00` | `jump` | label | end | saut |
| `01`-`C9` | `move n, a, b, c, d` | durée + 4 octets | cont | pendant n trames, champs 16-19 = a, b, c, d (vitesses), fin de trame |
| `FF` | `call` | label | cont | appel de sous-script (retour par return) |
| `FE` | `return` | — | end | retour de sous-script |
| `FD` | `move_packed` | octet, octet | cont | pendant n trames, vitesse x/y en 2 quartets signes (fin de trame) |
| `FC` | `set_anim` | octet | cont | champ 7 = animation |
| `FB` | `aim_player` | octet, octet | cont | direction vers le joueur (+ decalage x, y) -> champ 26 |
| `FA` | `switch_dir` | label, label, label, label, label, label, label, label | end | saut selon la direction (champ 26 & 7) |
| `F9` | `next_dir` | — | cont | direction suivante (0-7) |
| `F8` | `cmd_f8` | octet, octet, octet | cont | appelle $7B19 |
| `F7` | `flag_yield` | — | cont | met le bit 0 du champ 34, fin de trame |
| `F6` | `halt` | — | end | arret definitif du script |
| `F5` | `spawn` | octet, octet, octet, octet, octet, octet | cont | fait apparaitre un acteur (copie du joueur, $61A3) |
| `F4` | `kill` | — | end | supprime l'acteur |
| `F3` | `set_flags` | octet | cont | champ 34 |= valeur |
| `F2` | `clear_flags` | octet | cont | champ 34 &= ~valeur |
| `F1` | `if_lt_38` | octet, label | cont | saute si valeur >= champ 38 |
| `F0` | `if_zero` | mot, octet, label | end | saute si [adresse] == 0 (sinon aiguillage $7994) |
| `EF` | `aim_player2` | octet, octet | cont | direction vers le joueur (variante $7BCE) |
| `EE` | `switch_player_x` | label, label, label | end | saut selon la position x par rapport au joueur |
| `ED` | `cmd_ed` | octet, octet, octet | cont | appelle $7B02 |
| `EC` | `switch_x` | label, label, label | end | saut selon la position x par rapport a $6C |
| `EB` | `cmd_eb` | octet, octet, octet | cont | appelle $7B0D |
| `EA` | `if_set` | mot, label, label | end | si [adresse] != 0 saut A sinon saut B |
| `E9` | `cmd_e9` | octet, octet, octet, octet, octet, octet | cont | appelle $7AB8 |
| `E8` | `switch_y` | octet, label, label | end | saut A si y < valeur, sinon B |
| `E7` | `set_dir` | octet | cont | champ 26 = direction |
| `E6` | `if_hit` | label | cont | saute si champ 23 >= $FD |
| `E5` | `hide_wait` | octet | cont | disparait pendant n trames |
| `E4` | `if_pos` | octet, mot, label | cont | compare la position (x/y selon le mode, table $760B) a un seuil ; saute |
| `E3` | `wait` | octet | cont | attend n trames (fin de trame) |
| `E2` | `if_near` | octet, octet, label, label, label, label, octet, octet | cont | selon la position du joueur (4 sauts) |
| `E1` | `if_actor` | octet, label | cont | saute si un acteur de ce type existe |
| `E0` | `set_osc` | octet, octet, octet | cont | champs 25, 31, 32 |
| `DF` | `osc_move` | octet, octet, octet, octet | cont | deplacement oscillant (fin de trame) |
| `DE` | `loop_init` | octet | cont | compteur de boucle (champ 25) |
| `DD` | `loop` | label | cont | reboucle tant que le compteur n'est pas nul |
| `DC` | `set_field` | octet, octet | cont | champ[n] = valeur |
| `DB` | `poke` | mot, octet | cont | [adresse] = valeur |
| `DA` | `switch_mem` | mot, label, label, label, label | cont | selon [adresse] (0 = continuer, 1-4 = sauts) |
| `D9` | `if_flag` | mot, octet, label | cont | saute si ([adresse] & masque) == 0 |
| `D8` | `cmd_d8` | mot, mot | cont | champs 36-37, 31-32 puis $3B78 |
| `D7` | `cmd_d7` | octet, octet, octet | cont | appelle $7B14 |
| `D6` | `if_field_eq` | octet, octet, label | cont | saute si champ[n] == valeur |
| `D5` | `snap` | octet, mot | cont | alignement ($3036) |
| `D4` | `kill_mark` | — | end | supprime l'acteur et marque son parent |
| `D3` | `if_leader` | label | cont | saute si cet acteur est $C1DF |
| `D2` | `if_tile` | octet, octet, label, octet | cont | saute selon la tuile a (x+a, y+b) |
| `D1` | `set_c000` | — | cont | met les bits 2 et 4 de $C000 |
| `D0` | `cmp_field` | octet, octet, label, label | cont | champ[n] == v -> A, < v -> B, sinon continue |
| `CF` | `or_mem` | mot, octet | cont | [adresse] |= valeur |
| `CE` | `cmd_ce` | octet, octet, octet, octet, octet, label | cont | test ($7BEF) puis saut |
| `CD` | `cmd_cd` | octet, octet, octet, label | cont | test ($7BEF) puis saut |
| `CC` | `cmd_cc` | — | cont | appelle $5B03 |
| `CB` | `cmp_mem` | mot, octet, label, label | cont | [adresse] == v -> A, < v -> B, sinon continue |
| `CA` | `cmd_ca` | octet, octet, octet | cont | appelle $7AC3 |

🔶 Les noms `cmd_xx` désignent des commandes dont l'effet visible reste à observer en
émulateur ; les arguments et le flot sont, eux, confirmés par le code.

## Exemple

```
actor_B0:
	move_packed 0x01, 0x00      ; immobile 1 trame
	if_hit L_8213              ; touché ? -> L_8213
	wait 0x01
	jump actor_B0
```
