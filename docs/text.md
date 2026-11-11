# Textes

✅ Format confirmé : les textes anglais se recompilent **octet pour octet**.

## Fichiers

| Fichier | Contenu | Éditable |
|---|---|---|
| `assets/sms_en/text/strings.txt` | les **218 dialogues** (banque 32), une ligne `[NNN] texte` par chaîne | ✅ |
| `assets/sms_en/text/screens.txt` | **écrans de texte** de la banque 33 (crédits de la traduction, lignes de copyright), dessinés en grille de 20 colonnes | ✅ |
| `assets/sms_en/text/charset.tbl` | table de caractères `XX=c` (octet = caractère) | ✅ |
| `assets/sms_en/raw/bank33.bin` | reste de la banque 33 (tuiles, tilemaps), brut en attendant l'étape graphismes | (binaire) |
| `assets/gg_jp/text/strings_reference.txt` | dialogues japonais (banque 28), **lecture seule**, kana sous forme `{XX}` | ❌ |

Outil : `tools/assets/text.py` (`extract`, `build`, `check`). Le build recompile automatiquement.
`extract` **refuse d'écraser** un fichier existant (modifications perdues) sauf avec `FORCE=1`.

## Modifier un dialogue

1. Ouvrir `assets/sms_en/text/strings.txt`, modifier le texte après `[NNN] `.
2. `python tools/build.py` puis tester la ROM `build/sms_en/zenki_sms_en.sms`.

Règles :
- `\n` = nouvelle ligne. La fenêtre de dialogue fait environ 18 caractères de large et 4 lignes
  (🔶 à confirmer : le hack a élargi les bornes en `$68FF`). Les espaces de début de ligne servent à centrer.
- Tout caractère doit exister dans `charset.tbl` ; sinon écrire le code brut `{XX}`.
- La banque 32 fait 16 Ko : les textes actuels en occupent 8 452 octets, il reste donc ~7,9 Ko.
- Le numéro `[NNN]` est celui utilisé par l'opcode `text vitesse, NNN` des scripts
  (`assets/sms_en/scripts/bank05.zs`), qui affiche la phrase en commentaire.

## Encodage (anglais)

Chaque octet est un **numéro de tuile de la police** (banque 9), affiché avec l'attribut `$11`.

| Octets | Caractères |
|---|---|
| `$00` | fin de chaîne |
| `$0D` | nouvelle ligne |
| `$1F` | espace (case non dessinée) |
| `$60-$69` | `0-9` |
| `$70-$89` | `A-Z` |
| `$8A-$A3` | `a-z` |
| `$A4-$AD` | `! , . ? ( ) - ' ” :` |
| `$B3` | `“` |

✅ lettres et chiffres confirmés par le sens des phrases (ex. « 1,000 years ») ;
🔶 ponctuation déduite du contexte, à confirmer avec la police exportée en PNG.

## Moteur de texte ✅

- Opcode de script `0A text vitesse, n` (`$687F`) : efface la fenêtre (VRAM `$7B40`), prend le
  pointeur n dans la table `$8000` de la banque de texte (32 en EN, 28 en JP), puis
  `$68B7` affiche un caractère toutes les `vitesse` trames (`$CBB3/$CBB4`), position `$CBB1`.
- Écrans de la banque 33 : chargés par l'opcode `load_vram` avec le drapeau bit 7 = 0
  (1 octet par case, routine `$454E`) ; avec bit 7 = 1, la source est une tilemap complète
  (2 octets par case, `$44E4`). La taille s'écrit `lignes × colonnes` (ex. `0x1214` = 18 × 20).

## Japonais (GG JP)

Même table de 218 pointeurs en banque 28, mais chaînes **dans le désordre** et mêlées à
d'autres données (palettes, animations, crédits) : export en lecture seule pour l'instant.
Les kana restent en `{XX}` tant que la police japonaise n'est pas décodée.
