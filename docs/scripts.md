# Scripts de scènes (banque 5)

Les cinématiques, l'écran titre, les dialogues et l'enchaînement des scènes sont décrits par
un **bytecode** stocké en banque 5 et exécuté par le moteur `game/script` (tâche 5).
✅ format confirmé : les 43 scènes des deux versions se décodent sans erreur et se
recompilent **octet pour octet**.

## Fichiers

| Fichier | Rôle |
|---|---|
| `assets/sms_en/scripts/bank05.zs` | scripts de la version SMS EN (**à éditer**) |
| `assets/gg_jp/scripts/bank05.zs` | scripts de la version GG JP |
| `tools/assets/zscript.py` | définition des opcodes (source de vérité) |
| `tools/assets/scripts.py` | `extract` (ROM → .zs), `build` (.zs → `build/<ver>/generated/data_script.s`), `check` |

Le build (`tools/build.py`) recompile automatiquement le `.zs` : modifier un script puis
relancer le build suffit. ⚠️ `scripts.py extract` **écrase** le `.zs` (à n'utiliser que pour repartir de la ROM).

## Fonctionnement du moteur ✅

- `$8000` (banque 5) : table de **43 pointeurs**, un par scène (index = numéro de scène, 0 = aucune).
  Elle est suivie d'une petite table de couples (valeur, pointeur) vers des listes terminées par `$FF`.
- `$6337` lance la scène ; à chaque trame `$653B` met à jour les animations (`$6469`, `$64DC`),
  le texte (`$68B7`) et le défilement automatique (`$C902/$C903`), décompte l'attente (`$C901`),
  puis l'interpréteur (`$6574`) exécute des instructions jusqu'à une instruction de fin de trame
  (`wait`, `yield`...).
- Pointeur courant : `$C8FF`. Pile d'appels de sous-scripts : `$CBB5`. Compteur de boucle : `$C906`.
- Un handler reçoit sur la pile le pointeur suivant l'opcode ; s'il retourne normalement,
  l'instruction suivante s'exécute dans la même trame.

## Syntaxe du `.zs`

```
scene_04:                     ; label (les scènes s'appellent scene_NN)
	music 0x0b
	text 0x02, 0x05            ; "What was that
sound?!"
	wait 0x3c
	jump L_9A3C
	.db 0x80, 0x7d             ; octets non décodés (données)
```

- Nombres en `0x..` ou décimal ; les arguments de type *label* acceptent un nom de label.
- `.scenes a, b, 0, ...` : la table des scènes ; `.dw` / `.db` : données brutes.
- La banque fait 16 Ko au maximum (erreur de compilation sinon).

## Opcodes

| Code | Nom | Arguments | Effet |
|---|---|---|---|
| `00` | `end` | — | fin de la scene (retour a la tache) |
| `01` | `load_vram` | mot, mot, mot, octet, octet | copie src -> VRAM : src, adresse VRAM, longueur, drapeaux ($C0B1), banque |
| `02` | `obj_init` | mot, octet, octet, octet | initialise l'objet de scene (adresse RAM), x, y, type |
| `03` | `obj_set` | octet, octet, mot, octet, octet, octet, octet | regle les champs 15/21 puis 16-19 d'un objet de scene |
| `04` | `clear` | mot | met 0 a l'adresse |
| `05` | `vram_fill` | mot, mot, mot | remplit la VRAM : valeur, adresse VRAM, nombre |
| `06` | `wait` | octet | attend n trames (fin de trame) |
| `07` | `music` | octet | joue une musique ($DE05) |
| `08` | `sfx` | octet | joue un effet sonore ($DE04) |
| `09` | `yield` | — | fin de trame |
| `0A` | `text` | octet, octet | affiche le texte n (vitesse, numero de chaine) |
| `0B` | `jump` | label | saut |
| `0C` | `poke` | mot, octet | ecrit un octet en RAM |
| `0D` | `pokew` | mot, mot | ecrit un mot en RAM |
| `0E` | `scroll` | octet, octet | position de defilement x, y |
| `0F` | `scroll_move` | octet, octet, octet | vitesse de defilement dx, dy, pendant n trames |
| `10` | `fade_in` | octet | fondu d'entree |
| `11` | `fade_out` | octet | fondu de sortie |
| `12` | `load_tiles` | mot, mot, octet | charge des tuiles : adresse VRAM, source, banque |
| `13` | `load_palette` | octet, octet, mot | charge une palette : banque, choix (0=fond, 1=sprites), source |
| `14` | `set_color` | octet, octet, mot | change une couleur : palette, index, couleur |
| `15` | `fade_15` | octet | effet de palette $58C0 |
| `16` | `fade_16` | octet | effet de palette $58C9 |
| `17` | `call` | label | appel de sous-script |
| `18` | `return` | — | retour de sous-script |
| `19` | `loop_init` | octet | compteur de boucle |
| `1A` | `loop` | label | reboucle tant que le compteur n'est pas nul |
| `1B` | `set_c907` | octet, octet | ecrit $C908 puis $C907 |
| `1C` | `anim_a` | mot, octet | lance l'animation A : pointeur, banque |
| `1D` | `wait_button` | — | attend un bouton |
| `1E` | `anim_b` | mot, octet | lance l'animation B : pointeur, banque |
| `1F` | `raster` | mot, mot | parametres raster ($C1BC, $C1B8) |
| `20` | `obj_type` | mot, octet | change le type d'un objet de scene |
| `21` | `flag_c000_2` | — | met le bit 2 de $C000 |
| `22` | `if_bits` | mot, octet, label | saute si (adresse & masque) == masque |
| `23` | `and` | mot, octet | adresse &= valeur |
| `24` | `or` | mot, octet | adresse |= valeur |
| `25` | `menu` | — | gestion d'un menu (haut/bas) |
| `26` | `fade_26` | octet | effet de palette + remise a zero |
| `27` | `raster_mode` | — | mode raster ($C013 = 6) |
| `28` | `special` | octet | sequence speciale ($C013 = 5, table banque 4 $B55E) |
| `29` | `vram_write` | mot, mot, octet, octet | ecriture VRAM (2 mots, 1 octet, 1 octet ignore) |
| `2A` | `wait_objects` | — | attend la fin des objets de scene |
| `2B` | `sound_init` | — | reinitialise le son |
| `2C` | `sound_stop` | — | coupe le son |

🔶 Les noms de certains opcodes (`fade_15`, `fade_16`, `set_c907`, `obj_set`...) décrivent
seulement ce qu'ils écrivent : leur effet visible reste à confirmer en émulateur.

## Texte

`text vitesse, n` affiche la chaîne n de la banque de texte : **banque 32** en SMS EN,
**banque 28** en GG JP (table de pointeurs en `$8000`). Codes : `$00` fin, `$0D` nouvelle
ligne, `$1F` espace ; EN : `A-Z = $70-$89`, `a-z = $8A-$A3`, ponctuation
`! , . ? ( ) - '` = `$A4-$AB`, guillemets `$B3`/`$AC` (voir `tools/assets/textcodec.py`).
L'extraction éditable des textes est la prochaine étape.
