# Vue élargie (option `WIDE=1`)

```sh
python tools/build.py WIDE=1     # -> build/sms_en_wide/zenki_sms_en_wide.sms
```

Sans l'option, la ROM reste **identique à l'original** : tout le code de la vue élargie est sous
`.if WIDESCREEN` et ne prend aucune place. L'option n'existe que pour SMS EN.

Le build `WIDE=1` retire aussi le **logo SEGA animé** du démarrage (option `NO_SEGA_LOGO`
de `version.inc` : l'appel de `sub_3DD0` en `$06BC`, `src/core/game_flow.s`, devient 3 `nop`) ;
la ROM démarre directement sur le texte d'introduction.

## Le problème

Le jeu vient de la Game Gear : son écran LCD ne montre que 160×144 pixels au centre de l'image
256×192 du VDP. Le portage GG2SMS a gardé ce fonctionnement : sur Master System, le jeu occupe
une fenêtre de 160×144 au centre, entourée de restes du tilemap (pas même du noir).

## Le principe ✅

**La caméra du jeu n'est pas modifiée** (physique, collisions, IA, déclencheurs inchangés). La
fenêtre GG reste au centre de l'écran ; on dessine simplement aussi ce qui l'entoure :

| | Fenêtre GG (original) | Écran SMS (vue élargie) |
|---|---|---|
| Monde visible (x) | `[cam, cam+160)` | `[cam-48, cam+208)` (la colonne 0 est masquée par le VDP : 248 px utiles) |
| Monde visible (y) | `[camy, camy+144)` | `[camy-24, camy+168)` |

`cam = -scroll_x` ; `camy = page*224 + octet` avec `scroll_y = page:octet` ([architecture.md](architecture.md)).

Le tilemap de 32 × 28 tuiles sert d'**anneau** (correspondance fixée par le moteur d'origine,
`sub_4ABF`) :
- colonne de tuile du monde `tx` → colonne `(6 + tx) & 31` ;
- rangée de métatuile du monde `m` → rangées `(3 + 2m) mod 28` et suivante.

Comme la vue fait 248 px de large pour un anneau de 256 px, le dessin se fait **par colonne de
tuile (8 px)** et non par colonne de métatuile (16 px) comme sur GG. L'anneau contient les
colonnes `[T0, T0+32)` avec `T0 = floor((cam-40)/8)`, et les rangées de métatuiles `[k, k+14)`
avec `k = floor((camy-24)/16)`.

**Hors de la carte**, il n'existe aucun décor à montrer : `w_col` / `w_row` y dessinent la
**tuile noire** (mot `$09FA`, voir les écrans de boss ci-dessous, mais **sans priorité** pour
laisser voir le HUD et les sprites). Sont concernées : les cartes de 9 métatuiles de haut
(144 px), les bords gauche/droit au début et à la fin des niveaux, les salles de 10 × 9 et la
**carte du monde** (sélection des niveaux). Une première version répétait la rangée ou la
colonne du bord (bâtiments, cascade, bateau… dupliqués).

## Ce qui a été modifié

| Endroit | Original | Vue élargie |
|---|---|---|
| `src/version/sms_en/widescreen.s` (banque 10, area `_B10_WIDE`, après les métatuiles) | — | `wide_full` (redessin de tout l'anneau), `wide_hscroll`, `wide_vscroll`, `w_col`, `w_row` |
| `sub_48DA` (`src/core/util.s`) : redessin complet (chargement, événements) | 11 × 12 métatuiles | `wide_save` (banque 63 : tuile `$1C0` de la carte, voir ci-dessous), `wide_full` (banque 10) puis `wide_boss` (banque 63 : tuile noire, contours des écrans de boss) ; la place libérée accueille `wide_cull` et `wide_vblank` |
| `sub_5606` (`src/game/scroll.s`) : défilement | colonne/rangée de métatuile à chaque changement de case de 16 px | appel de `wide_hscroll`/`wide_vscroll` à chaque changement (`and #0xff`) ; ils calculent combien de colonnes/rangées sont entrées dans l'anneau |
| `sub_6F03` (`src/video/sprites.s`) : masquage des morceaux de sprites | X dans `[$28,$D0)`, Y dans `[$0F,$A7)` (fenêtre GG) | `wide_cull` : X ≥ 8, Y < `$C0` ; détecte les morceaux qui ont « bouclé » sur 8 bits d'un bord à l'autre (comparaison avec le X de l'objet) |
| Appels de `sub_404E` (palette) et `sub_405C` (SAT) dans l'IRQ (`src/core/irq.s`, `$015E-$016D`) | palette puis SAT | `ld a,(vdp_requests)` / `and #0xcc` / `call nz,wide_vblank` : le test reste en banque 0 (comme l'original) car une IRQ de trame peut arriver pendant le pilote son, banque 26 dans le slot 1 (`ei` de `sub_b26_4485`). `wide_vblank` copie la SAT **puis** la palette ; chacune est reportée à la trame suivante si elle commence trop tard (voir ci-dessous) |
| `sub_71BE` / `sub_718F` (`src/video/sprites.s`) : HUD des niveaux (objet et icône) | coin haut gauche de la fenêtre GG | coin haut gauche de l'écran SMS (X −36, Y −20 px ; attention, `ACTOR_Y` est l'axe horizontal) |
| `sub_3A9E` (`src/game/actors.s`) : apparition des ennemis | de 32 px à gauche à 200 px à droite de la caméra | 47 / 205 px : les ennemis apparaissent au ras des bords de l'écran SMS |

Toutes les areas modifiées gardent **exactement leur taille** (`.ds` pour la place libérée) :
aucune adresse ne bouge, seul `_B10_WIDE` (≈ 820 octets) s'ajoute dans l'espace libre de la
banque 10.

Les acteurs vivent déjà en coordonnées écran 0-255 (disparition hors de `[1, 254]`) : ils
existent sur toute la largeur SMS, seule leur apparition était calée sur la fenêtre GG.

Place : `_B10_WIDE` occupe 818 des 838 octets libres de la banque 10 (la fin de
`wide_hscroll` et `wide_vscroll` est commune : `w_span`). **Piles** : les piles des tâches ne
font que 64 octets (`$DD00`, `$DD40`…) : le code appelé par le défilement ne doit pas être plus
profond que l'original. **Taille des areas de la banque 1** : `_B01_48DA` doit faire exactement
170 octets (`.ds` de fin) ; un écart décale tout le reste de la banque 1 et casse les tables à
adresse fixe (plantages, RAM du pilote son écrasée).

## Vérification

Avec l'émulateur de test (`tools/emu/`, voir [toolchain.md](toolchain.md)) :
- `check on` compare **à chaque trame** chaque tuile visible de l'écran SMS avec la carte en RAM
  (hors des trames où le défilement est en cours de traitement) ;
- 6 niveaux × 3 000 trames de jeu aléatoire : aucune erreur due à la vue élargie. Les seules
  trames signalées sont celles du rechargement après une mort (identiques sur la ROM
  d'origine) et les tuiles que le jeu modifie lui-même (étoiles animées, blocs) ;
- coût CPU : sur le niveau vertical $0F, 169 « ticks » de jeu contre 173 en 400 trames (≈ 2 %
  de ralentissement, dû surtout aux sprites supplémentaires visibles) ; < 1 % ailleurs.

## Écrans fixes de boss : contours noirs ✅

Pour les combats de boss sur écran fixe (`game_mode` = 3, carte de 10 × 9 métatuiles au plus,
sans défilement vertical : boss de l'intro, scène $07 ; scènes $33-$36, $39…), il n'y a rien
de caché à montrer : la vue élargie est remplacée par des **contours noirs**.

- `sub_48DA`, après `wide_full`, appelle `wide_boss` (banque 63, area `_B63_WIDE`) qui écrit la
  tuile noire en VRAM (à chaque redessin, pour tous les modes) puis, sur un écran fixe de boss,
  remplit tout le tilemap hors de la carte avec la version **prioritaire** (`$19FA`).
- Tuile noire : tuile `$1FA` (VRAM `$3F40`, trou inutilisé de la table des sprites entre les Y et
  les X/tuiles), entièrement de couleur 2, affichée avec la **palette des sprites** (couleur 18,
  noire dans tous les niveaux et scènes mesurés) et la **priorité** : elle masque aussi les
  sprites qui dépassent de la fenêtre. Mot du tilemap : `$19FA`.
- Limite : les bandes que le jeu redessine lui-même sur toute la largeur parce qu'elles défilent
  en parallaxe (nuages du boss de l'intro, lignes 40-72, registre 8 animé) restent visibles : du
  noir y glisserait dans la fenêtre. Un bloc de 32 × 8 px à droite (rangée 9, colonnes 26-29) est
  aussi redessiné par le jeu.
- Boss de l'intro (scène $07) : le retour au défilement normal sous les nuages (table raster :
  fin demandée ligne 69) n'agit qu'après la **ligne 72**, encore affichée avec le défilement des
  nuages : les tuiles noires des bords de la rangée 9 y glissaient dans la fenêtre (**ligne noire
  d'un pixel**). Pour cette scène, les bords de la rangée 9 reprennent le mot du tilemap au bord
  de la fenêtre (colonnes 6 et C−1, lus en VRAM par `wb_rd`) : du ciel, comme le bloc que le jeu
  redessine à droite. La table raster n'existe pas encore au premier dessin : d'où le test sur
  la scène.
- Les salles de boss plus larges qui défilent (salle $25, 16 × 9) gardent la vue élargie.

La relocalisation automatique des graphismes trop grands (`tools/assets/banks.py`) s'arrête
donc à la banque 62.

## Carte du monde : bout de route ✅ (2026-11-12)

Sur la carte du monde (après le boss de l'intro), le dernier morceau de la route vers un lieu
s'affichait comme une tuile rouge rayée. Cause : la liste de tuiles de la carte charge 204
tuiles à partir de VRAM `$1EA0` (banque 7 `$8B40`) ; la dernière, **`$1C0`**, tombe en VRAM
**`$3800`**, début du tilemap (rangée 0, colonnes 0-15 : cachée sur GG, l'original s'en sert
comme réserve). La métatuile du bout de route (jeu de métatuiles de la carte, banque 10 `$8000`,
non exporté dans `assets/` ; mot en **`$84DA`**) l'utilise. La vue élargie dessine la rangée 0
(tuiles noires) et écrasait ce dessin. C'est le seul mot ≥ `$1C0` de ce jeu de métatuiles ; ceux
des 58 niveaux n'en ont aucun.

- `wide_save` (banque 63, ou 17 avec `ROM512=1`), appelé par `sub_48DA` **avant** `wide_full` :
  si les 32 premiers octets de `$3800` ne sont pas 16 mots `$09FA` (tuile noire), ils viennent
  d'être chargés : copie vers la tuile **`$1FB`** (`$3F60`, trou de la table des sprites juste
  après la tuile noire `$1FA`). Tampon : `util_D4D1 + 24` (32 octets, sous `di`). Dans les autres
  niveaux, la rangée 0 contient des mots du tilemap : la copie est sans effet (`$1FB` n'est
  utilisée que par la carte).
- `tools/build.py` (WIDE seulement) remplace le mot `$01C0` de `$84DA` par `$01FB` (et
  s'arrête si l'octet attendu n'y est pas).
- Vérifié : dessin de `$1FB` identique à celui de `$3800` dans la ROM d'origine ; route en
  pointillés jusqu'au sceau comme dans l'original (WIDE et WIDE + ROM512).

Pour atteindre la carte dans l'émulateur de test : points de vie du joueur en **`$CEFE`**
(remis à 6 à chaque trame pour gagner le boss de l'intro en attaquant), puis cesser de les
forcer pour laisser la cinématique se dérouler ; la carte est la scène 0 (`$C014` = 0,
`$C013` = 0).

## Colonne de gauche noire

Le VDP masque la colonne 0 (nécessaire au défilement) avec la couleur de fond (registre 7).
L'original met 0 (couleur 16 : gris, bleu… selon le niveau) ; la vue élargie met **2**
(couleur 18, noire partout) dans la table d'initialisation du VDP (`$4036`, dans
`src/video/vdp.s`).

## Sprites corrompus : défaut d'origine corrigé ✅

L'IRQ de trame copie d'abord les tuiles du joueur (`sub_407B`, 544 `outi`, ≈ 36 lignes) puis la
table des sprites (`sub_405C`, 192 `outi`). Les deux copies tombent souvent dans le même VBlank
et, certaines trames, la seconde commence vers la ligne 250 : ses dernières écritures arrivent
**pendant l'affichage**, à 16 cycles d'intervalle. Le VDP n'accepte alors qu'une écriture toutes
les ~26 cycles : des octets de la SAT sont perdus et des sprites apparaissent corrompus (X ou
tuile faux). **La ROM d'origine a le même défaut** (mesuré : 64 débordements sur 3 000 trames du
niveau $14, 12 pendant le titre et l'intro) ; la vue élargie le rend plus visible car davantage
de sprites sont affichés.

`wide_vblank` (dans la place libérée de `sub_48DA`) lit le compteur V : si la copie de la SAT
tient encore dans le VBlank, elle appelle la routine d'origine ; sinon elle la **reporte à la
trame suivante** (bit 2 de `vdp_requests`, jamais utilisé par le jeu et conservé par le
`and #0x1f` de fin d'IRQ). Les sprites gardent alors leur position une trame de plus, sans
corruption.

**Ordre SAT puis palette** ✅ (2026-11-12). L'original fait tuiles du joueur (lignes 194-231),
conversion de palette GG→SMS (`sub_404E`, ≈ 20 lignes) puis SAT. Une première version de
`wide_sat` gardait cet ordre : quand les trois copies tombaient dans la même trame (niveaux à
palette animée : grotte rouge du niveau 01, éclairs, cascade), la SAT commençait ligne 250 et
était reportée, **toujours** juste après une copie des tuiles du joueur (mesuré : 182 reports
sur 3 parties, tous dans ce cas). Pendant une trame, les nouvelles tuiles du joueur
s'affichaient avec l'ancien agencement de sprites : **personnage « en bouillie »**.
`wide_vblank` copie maintenant la SAT avant la palette ; l'IRQ commence aux lignes 193-197, la
SAT tient donc toujours après les tuiles (aucun report mesuré). C'est la **palette** qui est
reportée si elle commence après la ligne 235 (bit 3 de `vdp_requests`, lui aussi inutilisé par
le jeu ; le bit 1 est écrit par `$5126` mais jamais lu) : couleurs en retard d'une trame,
invisible. L'IRQ finit au plus tard ligne 246 (251 avant).

Une première version copiait la SAT lentement (41 cycles par octet) au lieu de la reporter :
l'IRQ de trame débordait alors jusqu'à la ligne ~27, et la table raster (remise à zéro en fin
d'IRQ) décalait trop tôt les bandes en parallaxe : **clignotement des nuages** du boss de
l'intro. Le report supprime aussi le petit débordement de l'original (bande décalée dès la
ligne 6, hors de la fenêtre GG).

Vérification : la commande `audit on|off` de l'émulateur de test signale toute écriture VRAM à
moins de 26 cycles de la précédente pendant l'affichage : **aucune** dans la ROM `WIDE=1`
(6 niveaux × 3 000 trames, titre et intro), contre des dizaines dans la ROM d'origine.

## Limites connues

- **Écrans fixes** (titre, cinématiques, menus, textes) : restent en 160×144 au centre.
- **Barres de vie des boss** : restent à leur place dans la fenêtre GG (sur les écrans fixes, les
  contours noirs, prioritaires sur les sprites, les cacheraient).
- 🔶 À tester sur vrai matériel / Emulicious : l'émulateur de test ne simule pas le délai
  d'accès VRAM ; les écritures gardent au moins 26 cycles d'écart comme le code d'origine.
