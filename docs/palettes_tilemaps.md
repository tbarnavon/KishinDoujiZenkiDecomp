# Palettes, tilemaps et compositeur de banques

✅ Extraction vérifiée : 336 palettes et 82 tilemaps identiques ; les 26 banques de données
recomposées sont identiques à la ROM.

## Compositeur de banques (`tools/assets/banks.py`)

En version SMS EN, toutes les banques **sans code** (3, 4, 6-22, 24, 27-31, 33) sont
reconstruites au build à partir de :

1. `assets/sms_en/raw/bankNN.bin` : contenu brut (tout ce qui n'est pas encore décodé) ;
2. puis, superposés dans cet ordre : tuiles (`gfx`), palettes, tilemaps, écrans de texte.

Les banques avec du code (0, 1, 2, 23, 25, 26) restent dans `src/` ; la banque 5 (scripts
de scènes), la banque 32 (dialogues) et l'area `_B25_8000` (scripts d'acteurs) sont produites
par leurs compilateurs. GG JP : banques de données toujours générées dans `src/version/gg_jp/`.

`python tools/assets/banks.py check` compose toutes les banques et les compare à la ROM.

## Palettes

- Fichier : `assets/sms_en/palettes/palettes.json` (aperçu : `palettes/preview.png`).
- Une entrée = `bank`, `addr`, `use` (fond / sprites), `scenes`, `colors` : 16 couleurs
  **`BGR` en hexadécimal** (3 chiffres de 0 à F ; format Game Gear `----BBBBGGGGRRRR`).
  Exemple : `"F00"` = bleu, `"0F0"` = vert, `"00F"` = rouge.
- La version SMS convertit à l'exécution (`$7FA3`) en 2 bits par composante : seules
  4 intensités sont visibles (0-3, 4-7, 8-B, C-F).
- Découverte : opcodes `load_palette` des scripts. Taille fixe : réécrite à sa place.
- 🔶 Les palettes des niveaux chargées directement par le code ne sont pas encore listées.

## Tilemaps

- Fichiers : `assets/sms_en/tilemaps/bankNN_AAAA.csv` + `tilemaps.json`.
- Une ligne du CSV = une rangée de cases :
  - 2 octets par case (`load_vram` avec drapeau bit 7 = 1) : mot VDP en hexadécimal
    (bits 0-8 tuile, 9 miroir horizontal, 10 miroir vertical, 11 palette sprites, 12 priorité) ;
  - 1 octet par case : numéro de tuile ; l'octet de poids fort (attribut) est l'argument
    « drapeaux » du `load_vram` dans le script.
- Taille fixe (lignes × colonnes) : modifier les valeurs, pas les dimensions.
- Les écrans de texte de la banque 33 sont dans `text/screens.txt` (pas en CSV).
