# Vue élargie (option `WIDE=1`)

```sh
python tools/build.py WIDE=1     # -> build/sms_en_wide/zenki_sms_en_wide.sms
```

Sans l'option, la ROM reste **identique à l'original** : tout le code de la vue élargie est sous
`.if WIDESCREEN` et ne prend aucune place. L'option n'existe que pour SMS EN.

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

**Hors de la carte**, la rangée ou la colonne du bord est **répétée** (il n'existe aucun décor à
montrer). Les cartes de 9 métatuiles de haut (144 px) et les salles de 10 × 9 (160 px) sont
concernées.

## Ce qui a été modifié

| Endroit | Original | Vue élargie |
|---|---|---|
| `src/version/sms_en/widescreen.s` (banque 10, area `_B10_WIDE`, après les métatuiles) | — | `wide_full` (redessin de tout l'anneau), `wide_hscroll`, `wide_vscroll`, `w_col`, `w_row` |
| `sub_48DA` (`src/core/util.s`) : redessin complet (chargement, événements) | 11 × 12 métatuiles | saut vers `wide_full` (banque 10) ; la place libérée accueille `wide_cull` |
| `sub_5606` (`src/game/scroll.s`) : défilement | colonne/rangée de métatuile à chaque changement de case de 16 px | appel de `wide_hscroll`/`wide_vscroll` à chaque changement (`and #0xff`) ; ils calculent combien de colonnes/rangées sont entrées dans l'anneau |
| `sub_6F03` (`src/video/sprites.s`) : masquage des morceaux de sprites | X dans `[$28,$D0)`, Y dans `[$0F,$A7)` (fenêtre GG) | `wide_cull` : X ≥ 8, Y < `$C0` ; détecte les morceaux qui ont « bouclé » sur 8 bits d'un bord à l'autre (comparaison avec le X de l'objet) |
| Appel de `sub_405C` dans l'IRQ (`src/core/irq.s`, `$016B`) : copie de la table des sprites (SAT) | 192 `outi` (16 cycles/octet) | `wide_sat` : si la copie commence trop tard (compteur V hors de `$C1-$EF`), elle est reportée à la trame suivante (voir ci-dessous) |
| `sub_3A9E` (`src/game/actors.s`) : apparition des ennemis | de 32 px à gauche à 200 px à droite de la caméra | 47 / 205 px : les ennemis apparaissent au ras des bords de l'écran SMS |

Toutes les areas modifiées gardent **exactement leur taille** (`.ds` pour la place libérée) :
aucune adresse ne bouge, seul `_B10_WIDE` (≈ 820 octets) s'ajoute dans l'espace libre de la
banque 10.

Les acteurs vivent déjà en coordonnées écran 0-255 (disparition hors de `[1, 254]`) : ils
existent sur toute la largeur SMS, seule leur apparition était calée sur la fenêtre GG.

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

- `sub_48DA`, après `wide_full`, appelle `wide_boss` (banque 63, area `_B63_WIDE`) qui remplit
  tout le tilemap hors de la carte avec une tuile noire.
- Tuile noire : tuile `$1FA` (VRAM `$3F40`, trou inutilisé de la table des sprites entre les Y et
  les X/tuiles), entièrement de couleur 2, affichée avec la **palette des sprites** (couleur 18,
  noire dans tous les niveaux et scènes mesurés) et la **priorité** : elle masque aussi les
  sprites qui dépassent de la fenêtre. Mot du tilemap : `$19FA`.
- Limite : les bandes que le jeu redessine lui-même sur toute la largeur parce qu'elles défilent
  en parallaxe (nuages du boss de l'intro, lignes 40-72, registre 8 animé) restent visibles : du
  noir y glisserait dans la fenêtre. Un bloc de 32 × 8 px à droite (rangée 9, colonnes 26-29) est
  aussi redessiné par le jeu.
- Les salles de boss plus larges qui défilent (salle $25, 16 × 9) gardent la vue élargie.

La relocalisation automatique des graphismes trop grands (`tools/assets/banks.py`) s'arrête
donc à la banque 62.

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

`wide_sat` (dans la place libérée de `sub_48DA`) lit le compteur V : si la copie tient encore
dans le VBlank, elle appelle la routine d'origine ; sinon elle la **reporte à la trame
suivante** (bit 2 de `vdp_requests`, jamais utilisé par le jeu et conservé par le `and #0x1f`
de fin d'IRQ). Les sprites gardent alors leur position une trame de plus, sans corruption.

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
- **Bords de carte répétés** : hors des écrans fixes de boss, au-delà d'une carte la rangée ou
  la colonne du bord est répétée (plus de ciel, de sol…).
- **HUD** (objet, barres de vie) : reste à sa place dans la fenêtre GG.
- 🔶 À tester sur vrai matériel / Emulicious : l'émulateur de test ne simule pas le délai
  d'accès VRAM ; les écritures gardent au moins 26 cycles d'écart comme le code d'origine.
