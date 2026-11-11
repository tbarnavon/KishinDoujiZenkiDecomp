# Graphismes

✅ Extraction et réinjection vérifiées : les 72 blocs se reconvertissent exactement, la ROM
reconstruite est identique, et une modification (PNG ou texte) a été testée de bout en bout.

## Format dans la ROM ✅

- Tuiles SMS/GG : 8×8 pixels, 4 bits par pixel, **planaires** (32 octets par tuile : pour
  chaque ligne, 4 octets = plans 0 à 3, bit 7 = pixel de gauche).
- Les tuiles sont **compressées** en RLE planaire (décompresseurs `$46A1` → VRAM et
  `$4667` → RAM) :
  - octet 0 : N = nombre de flux entrelacés (4 pour des tuiles) ;
  - puis N flux ; le flux k remplit les octets k, k+N, k+2N… ;
  - contrôle `$00` = fin du flux, bit 7 = 1 → copier n octets bruts, sinon répéter n fois l'octet suivant.
  - Outil : `tools/assets/rle.py`. Notre compresseur redonne exactement le flux d'origine
    pour 63 blocs sur 68 (même taille totale).
- Palettes : 16 couleurs GG de 2 octets (`----BBBBGGGGRRRR`), 32 octets ; copiées en
  `$C01A` (fond) / `$C03A` (sprites). En SMS, converties à l'exécution (`$7FA3`).
- Tilemaps (opcode `load_vram`, drapeau bit 7 = 1) : **non compressées**, 2 octets par case.

## Fichiers

| Fichier | Rôle |
|---|---|
| `assets/sms_en/gfx/bankNN/AAAA.png` | un bloc de tuiles (banque NN, adresse AAAA), PNG **indexé 16 couleurs**, 16 tuiles par ligne |
| `assets/sms_en/gfx/bankNN/AAAA.rle` | flux compressé d'origine (réutilisé tel quel si le PNG n'a pas changé) |
| `assets/sms_en/gfx/gfx.json` | manifeste : tuiles, adresse VRAM, palette utilisée pour l'aperçu, qui l'utilise, éditable ou non |
| `assets/sms_en/raw/bankNN.bin` | reste non décodé des banques graphiques (palettes, tilemaps...) |
| `tools/assets/gfx.py` | `extract` (refuse d'écraser sans `FORCE=1`), `build`, `check` |

72 blocs, 3 735 tuiles. La couleur des aperçus vient de la palette chargée par la même scène
(67 blocs) ; sinon niveaux de gris. Elle ne sert qu'à l'affichage : **seuls les indices
0-15 comptent**.

Exemples : `bank09/B14F.png` = **police** (chiffres, A-Z, a-z, ponctuation ; chargée en VRAM
`$23E0`, c'est elle qui a permis de confirmer la table de caractères, voir [text.md](text.md)).

## Modifier un graphisme

1. Ouvrir le PNG dans un éditeur qui **conserve le mode indexé** (Aseprite, GraphicsGale,
   GIMP en mode « Indexé »...). Ne pas changer la taille ni utiliser d'indice > 15.
2. `python tools/build.py`.

Au build :
- PNG inchangé → octets d'origine (ROM identique) ;
- PNG modifié → recompression. Si le flux tient dans la place d'origine, il y est écrit ;
  **sinon le bloc est déplacé automatiquement dans une banque libre (34 à 63)** et les
  `load_tiles` des scripts qui le chargent sont corrigés à la compilation (fichier
  `build/sms_en/generated/gfx_reloc.json`). Les `.zs` ne sont pas modifiés.
- Un bloc référencé par le **code** (et non par un script) ne peut pas être déplacé : il doit
  tenir dans sa place d'origine (message d'erreur sinon).

## Éditable ou non

| Banques | État |
|---|---|
| 9, 14, 15, 16, 17, 22 | ✅ **éditables** (reconstruites depuis `assets/`) |
| 33 | ✅ éditable (reconstruite par `text.py` : graphismes + écrans de texte) |
| 7, 12, 18, 23 | 🔶 PNG exportés en **lecture seule** : ces banques contiennent aussi du code ou des données non décodées, et 5 de ces blocs sont référencés par le code |
| GG JP | non éditable (référence) |

## Pas encore extrait

Tilemaps, palettes en fichiers éditables, méta-sprites (banques 23-24), graphismes de
niveau chargés via les tables de niveau, police japonaise.

## Test d'exécution

Une ROM de test (dialogue 0 modifié + police modifiée, donc déplacée en banque 34) a été
produite ; son lancement dans Emulicious attend la première configuration de l'émulateur
(choix de la politique de mise à jour, laissé à l'utilisateur).
