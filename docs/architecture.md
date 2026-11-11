# Comment le jeu fonctionne

Légende : ✅ confirmé (lu dans le code) · 🔶 supposé (déduit, à vérifier en émulateur).
Les adresses sont celles de la ROM SMS EN (identiques en GG JP sauf mention).

## 1. Vue d'ensemble

Le jeu n'a **pas de boucle principale classique** ✅ : après l'initialisation, le boot fait
`ei / jr $` et tout se déroule dans l'interruption. L'IRQ de trame appelle un
**ordonnanceur coopératif** qui fait tourner jusqu'à 8 **tâches**, chacune avec sa propre pile.
Une tâche rend la main avec `task_yield` (attente d'une ou plusieurs trames).

```
reset ($0000) -> boot_init ($0074) -> task_start(0) -> ei ; jr $
                                                         |
IRQ ($0038 -> irq_handler $00B0) <-----------------------+  (chaque ligne / trame)
   |- ligne (HBlank) : effets raster (registre 8 par ligne, table $04D4)
   '- trame (VBlank) : transferts VDP, défilement, son (banques 26/27),
                       lecture manette, puis task_scheduler ($0364)
                                                         |
         tâche 0 : séquenceur      tâche 3 : niveau
         tâche 1 : joueur          tâche 4 : événements de niveau
         tâche 2 : acteurs         tâche 5 : scènes / scripts
```

## 2. Démarrage ✅

`boot_init` ($0074) :
1. efface la RAM `$C000-$DFF0` ;
2. mapper : slot 0 = banque 0, slot 1 = banque 1, slot 2 = banque 2 ;
3. pile en `$DE00` ;
4. initialise le VDP (`$400C`, `$404E`) et la VRAM (`$44C7`) ;
5. `task_current = $FF`, `task_start(0)`, initialise le son (`sound_init` $05DD) et l'écran ($0A6B) ;
6. `ei` puis boucle infinie.

Vecteurs : `rst $08` = `rst $10` sous `di` ; `rst $10` = envoie `de` (e puis d) sur le port de
commande VDP. `$0031`, `$0034`, `$003B`, `$003E`, `$004D`, `$005B`, `$005E`, `$0061` sont des
`jp` vers des routines des banques 0/1 (table de vecteurs). En GG, `$0068/$006B/$006E` en
faisaient aussi partie (écrasés par la NMI du hack SMS).

## 3. Mapper et banques ✅

- Slot 0 : toujours la banque 0. Slot 1 : banque 1, sauf pendant le son (banque 26).
- Slot 2 : changé partout par le motif `ld a,#N / ld ($DCBE),a / ld ($FFFF),a`.
  **`$DCBE` (`bank_slot2_shadow`) est la copie de la banque courante** ; l'IRQ la restaure
  en sortie (`$03F3`).
- Le son s'exécute avec la **banque 26 en slot 1** (code) et la **banque 27 en slot 2**
  (données), puis le slot 1 revient à la banque 1 (`$0237-$0250`).
- Beaucoup de données sont chargées via des **descripteurs (banque, pointeur)** stockés dans
  les données elles-mêmes (scripts, tables de niveau) : `$5A7C`, `$56F8`, `$6520`, `$6820`...

## 4. Interruptions ✅

`irq_handler` ($00B0) lit le statut VDP (`$DCBD`) :
- **interruption de ligne** : selon le mode (`$C013 = 6` ou non), écrit le registre VDP 8
  (défilement horizontal) ligne par ligne depuis une table (`$04D4`, `$C1C4`) → effets raster.
- **interruption de trame** : marque `$C001` bit 7, puis selon les drapeaux de `$C002` :
  bit 0 transfert du tampon de sprites, bit 4 transfert en VRAM (`$C189`), bit 6/7 VDP,
  bit 5 défilement vertical (`$C09B` → registre 9) ; `$C0AE` → `$C1BE` → registre 8.
  Appelle le son, la manette, puis l'ordonnanceur.

`nmi_vector` ($0066) : en SMS, le bouton Pause met `$40` dans `$DFF0`, lu par `joypad_read`
comme le bouton Start de la GG. En GG : simple `retn`.

## 5. Ordonnanceur de tâches ✅ (module `core/tasks`)

| Routine | Rôle |
|---|---|
| `task_start` ($0273) | `a` = n° : prépare la pile (`task_stack_table` $041B) avec le point d'entrée (`task_entry_table` $040B) et active la tâche |
| `task_kill` ($02C6) | arrête la tâche `a` |
| `task_suspend` ($02F8) / `task_resume` ($030E) | met en attente / réveille |
| `task_yield` ($0330) | sauve SP dans `task_sp_table` ($DCA5), attend `a` trames (`$DCB5`) |
| `task_scheduler` ($0364) | choisit la tâche prête suivante (masques `$DCA1/$DCA2/$DCA4`) et restaure sa pile |

| Tâche | Entrée | Rôle |
|---|---|---|
| 0 | `$06B3` | **séquenceur** : titre, démo, lancement de partie ✅ |
| 1 | `$1A2D` | **joueur** et monde (structure `$CEEF`, défilement) 🔶 |
| 2 | `$3476` | **acteurs** : 13 emplacements à partir de `$C8FF` ✅ |
| 3 | `$4767` | **niveau** : chargement (`$5011`), métatuiles 🔶 |
| 4 | `$0FA9` | **événements de niveau** : déclencheurs `$C1E1`, handlers `$0B3D` 🔶 |
| 5 | `$6337` | **scènes** : exécute un script de la banque 5 ✅ |
| 6, 7 | `$042B` | non utilisées (`jp task_start`) |

## 6. Déroulement du jeu (tâche 0) ✅

- `$C014` = **numéro de scène** (ex. `$80`, `$81`, `$82` : titre / démo) ; `$C013` = mode.
- La tâche 0 lance la scène (`$6337`), attend Start (`joypad_state` bit 7), alterne titre et
  démo, puis démarre la partie.
- **Menu caché** ✅ : si les boutons valent `$B4` au titre, le jeu appelle `$967C` en banque 23
  (module `screens/debug_menu`). Il règle `$C006` (niveau de départ → `$C012`), `$C007`
  (niveau de pouvoir via la table `$097B`) et `$C008` (mode spécial via la table `$093A`).
  🔶 contenu exact du menu à voir en émulateur.
- `$C011` ≠ 0 = **mode démo** : les entrées manette sont effacées (`$30A9`).

## 7. Sous-systèmes

### Scènes et scripts (`game/script`) ✅ → [scripts.md](scripts.md)
- `$6337` initialise une scène ; `$6427`/`$653B` lisent le script en **banque 5**
  (pointeur courant `$C8FF`).
- Interpréteur en `$6574` : lit un octet d'opcode et saute via la table **`$6595`
  (45 opcodes)**. Les opcodes chargent des graphismes, palettes, textes via des
  descripteurs (banque, pointeur).
- 🔶 les scripts décrivent les cinématiques, le titre et l'enchaînement des niveaux.

### Texte (`game/text`) ✅
- Police chargée depuis la **banque 9** (`$6415`).
- Fenêtre de texte (`$687F`, `$68B7`, `$68E0`), variables `$C904`, `$CBB1-$CBB4`.
- En EN, les chaînes sont dans les **banques 32-33** ; le hack a élargi les bornes de la
  fenêtre (`$68FF`).

### Acteurs (`game/actors`, `game/actor_script`) ✅ → [actor_scripts.md](actor_scripts.md)
- 13 emplacements d'acteurs (iy) à partir de `$C8FF` ; champs connus : 0 = type,
  13 = drapeaux, 27-28 = pointeur de script, 33 = délai, 34-35.
- Chaque acteur exécute un **script en banque 25** : `$72B2`. Octet ≥ `$CA` = commande
  (table **`$72EB`, 54 commandes**), sinon instruction de base (`$7A8D`).
- Table de types d'acteurs en banque 23 (`$B06B`, lue par `$7292`/`$481F`).
- **Apparition des ennemis** : liste du niveau (banque 4, copiée en `$C7FB` par `$3606`),
  parcourue par `$3A9E` selon le défilement → voir [enemies_sprites.md](enemies_sprites.md).

### Menu de pause (`screens/pause_menu`) ✅
- `$1616` : bouton Pause (SMS) / Start (GG) ; charge `$B468` (banque 18) en VRAM `$0000`
  et anime un curseur avec les scripts d'acteurs `actors_BD21` / `actors_BD35`.

### Animations de décor ✅
- Palettes animées : listes `[délai][pointeur de palette]…$FF[bouclage]` en banque 2 (`$59C1` fond,
  `$5A0F` sprites, pointeurs `$C0C7` / `$C0C9`, table par niveau `$ADEC`).
- Tuiles animées : listes en banque 23 (`$5A52`, `$C186`) décompressées en `$D981` puis envoyées en VRAM.

### Joueur (`game/player`) 🔶
- Structure en `$CEEF` (le premier octet est l'état : `$FF`, `$FE`, `$FD` = états spéciaux).
- Tables d'états indexées par `~état` : `$2E2D`, `$2CEE`, `$3CC3`, et en banque 2 `$8000`.
- Contrôle : `joypad_pressed` → `$1380` (conversion en direction).

### Collisions (`game/collision`) 🔶
- `$29C5`/`$2A03` : métatuile sous une position (banque 10).
- Handlers par type de tuile : table `$2539` (32 types, `and $1F`).
- Handlers d'interaction : table `$1D9E` (35 entrées).

### Niveau (`game/level`) ✅ → [levels.md](levels.md)
- `$5011` : charge un niveau : en-tête (banque 2), palettes (banque 18, table `$B07A`
  indexée par `$C014`), efface `$CF27-$D4D1` (RAM des entités), tuiles (banque 12).
- Métatuiles de 8 octets en **banque 10** (`$4A0C`, `$4A24`).
- Table de préparation par scène `$4F01` (58 entrées, 8 handlers distincts).

### Défilement (`game/scroll`) ✅
- `$C09B` → registre VDP 9 (vertical), `$C0AE` → registre VDP 8 (horizontal), envoyés par l'IRQ.
- `$0A33` remet le défilement et le raster à zéro.

### Vidéo (`video/*`) ✅
- `vdp` : `rst $10` (adresse/commande), affichage on/off (`$0042`/`$0050`, copie du
  registre 1 en `$C0B4`), copies VRAM (`$44D0`, `$44E4`), décodeur à compteurs de type RLE
  (`$4667`), chargeur de tuiles (`$46A1`), transferts déroulés (table `$048B`).
- `sprites` : méta-sprites (`$6C26-$723D`, `$6D4E`), tampon en `$C200` (pointeurs `$C244`/`$C246`),
  animations et dispositions en banque 24 → [enemies_sprites.md](enemies_sprites.md).
- `palette` : 32 effets par couleur (`$C0E4`, `$574C`) ; fondus `$58A5` (entrée),
  `$58AE` (sortie), `$58C0` (`$C0D3` = 1 ou 2). En SMS, conversion GG→SMS en `$7FA3`.

### Son (`audio/*`) ✅ → [music.md](music.md)
- Driver en **banque 26** (exécuté en slot 1), données en **banque 27**.
- `sound_init` ($05DD → `$44A9`), `sound_update` (`$4000`, chaque trame depuis l'IRQ).
- Commandes : écrire en `$DE04-$DE0B` (ex. `$DE05` = musique 🔶, `$DE06` = effet 🔶).
- Le driver interprète des commandes `$DB-$E1` (table `$4164`) et `$E1-$FF` (table `$47D1`).

### Manette (`input/joypad`) ✅
- `joypad_read` ($042E) : `joypad_state` ($C016) = boutons appuyés, `joypad_pressed`
  ($C017) = nouveaux appuis. Bit 7 = Start (GG) / Pause (SMS).
