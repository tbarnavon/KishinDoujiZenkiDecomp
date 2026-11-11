# Niveaux

✅ Format confirmé : les 58 niveaux se rendent correctement en image (aperçus) et les
banques 10, 19 et 20 se recomposent à l'identique.

## Format ✅

Tout est indexé par le numéro de niveau (`$C014`, 58 entrées) :

| Table | Contenu |
|---|---|
| banque 1 `$4CFC` (3 octets par niveau) | `[banque, pointeur]` de la **carte** : en-tête `[largeur][hauteur][taille sur 16 bits]` puis largeur × hauteur octets = indices de métatuiles (copiés en RAM `$CF27`, `$5011` → `$56E8`) |
| banque 10 `$BBD2` | **jeu de métatuiles** : `[taille]` + métatuiles de 8 octets = 4 mots VDP (haut-gauche, haut-droite, bas-gauche, bas-droite), lus par `$4A0C`/`$4A24` |
| banque 10 `$BC46` | **attributs** : `[taille]` + 1 octet par métatuile (collisions 🔶 : `$80` = solide ?) |
| banque 1 `$4C88` et `$4C14` | **listes de tuiles** à charger : `[source][adresse VRAM][banque][00]`… `$FFFF` (`$5198`) |
| banque 2 `$9E65` / `$9DF1` | palettes de fond / de sprites du niveau (`$513F`) |
| banque 18 `$B332` | 4 octets par niveau → `$C19A`/`$C19C` 🔶 (position de départ ?) |

Cartes : 28 distinctes (métatuiles de 16 × 16 pixels) dans les banques 19 et 20. Tailles
(largeur × hauteur) : 10×9, 16×9, 20×9, 30×9, 50×9, 130×9 (défilement horizontal seul ou salle
fixe), 80×18, 50×27, 40×36, 20×72, 10×72 (défilement vertical). **L'écran GG fait 10 × 9
métatuiles** (160×144) : les salles 10×9 tiennent exactement dans l'écran GG, et aucune carte
de 9 de haut ne peut remplir les 12 métatuiles (192 px) de hauteur de l'écran SMS.
Le moteur dessine par blocs de 12 métatuiles en ligne (`$49F0`) et 11 en colonne (`$49D4`).
Jeux de métatuiles : 14. La caméra et le dessin des colonnes/lignes au défilement sont dans
`game/level` (`$499F`, `$49F0`).

## Fichiers (`assets/sms_en/levels/`)

| Fichier | Rôle |
|---|---|
| `levels.json` | pour chaque niveau : carte, métatuiles, attributs, palette, tuiles chargées |
| `maps/map_bNN_AAAA.csv` | une carte : une ligne = une rangée de métatuiles (indices hexadécimaux) |
| `metatiles/set_AAAA.csv` | un jeu de métatuiles : une ligne = 4 mots VDP (bits 0-8 tuile, 9 miroir H, 10 miroir V, 11 palette sprites, 12 priorité) |
| `attributes/attr_AAAA.csv` | attributs des métatuiles (16 par ligne) |
| `preview/level_NN.png` | **aperçu** de chaque niveau (généré) |

Outil : `tools/assets/levels.py` (`extract`, `check`, `preview`). Les cartes, métatuiles et
attributs sont réécrits à leur place au build (banques composées) : **les dimensions sont
fixes**, on modifie les valeurs. `python tools/assets/levels.py preview` regénère les aperçus
après modification pour visualiser le résultat.

## Pas encore fait

- Palettes de niveau en édition (banque 2 contient du code : lecture seule pour l'instant).
- Placement des ennemis/objets dans les niveaux (banque 7, `$1616`).
- Changer les dimensions d'une carte (nécessite de recalculer les pointeurs de `$4CFC`).
