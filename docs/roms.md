# Les deux ROMs

Les fichiers de `original/` ne sont jamais modifiés.

## Identification

| | `Kishin Douji Zenki (J).gg` | `Kishin_Douji_Zenki_GG2SMS_v0_3__EN_.sms` |
|---|---|---|
| Nature | Game Gear japonaise d'origine | hack de fans : portage GG→SMS + traduction anglaise |
| Taille | 512 Ko (32 banques) | 1 Mo (64 banques, 34 utiles, le reste en `$FF`) |
| CRC32 | `7D622BDD` | `8F85E39A` |
| MD5 | `ac6ed281ac8e9d71af186602951cfd7a` | `cd9e970efe7ca49d79f1b64079c7d16d` |
| SHA1 | `0fb3530633070551f3d5a04839fc42babc092fbd` | `e27e8dbdfda92bb1aa257b92053d1d9c19c25611` |
| En-tête `$7FF0` | code produit 3373, v0, région 5 (GG Japon) | code produit 3373, v0, région 4 (SMS Export) |
| Taille déclarée | 256 Ko (le fichier fait 512 Ko) | 32 Ko |
| Checksum | `$0000` (non vérifié par le BIOS GG japonais) | `$BD07`, valide (calculé sur 32 Ko) |

Mapper : Sega standard (registres `$FFFC-$FFFF`).

## Diff binaire

**Le hack est la ROM GG patchée sur place** : aucun bloc décalé, toutes les adresses sont
identiques. C'est ce qui permet de produire les deux versions depuis les mêmes sources.

| Banque | Identique | Nature de la différence |
|---|---|---|
| 0 | 99,5 % | patchs de portage (voir ci-dessous) |
| 1 | 99,3 % | code ajouté en `$7F94-$7FEF`, en-tête |
| 2 | 99,5 % | ~30 mots `$0888` → `$0F50` (rôle supposé : positions écran ou couleurs) |
| 5 | 8 % | **script entièrement réécrit** (texte anglais + pointeurs) |
| 9 | 92 % | police modifiée (`$27150-$27673`) |
| 16 | 96,6 % | tilemap modifiée (`$41E15-$4234D`) |
| 17, 23, 28 | > 97 % | mots `$0888` → `$0F50`, vecteurs (banque 23), crédits (banque 28) |
| 26 | 99,95 % | driver son : écritures sur le port stéréo GG `$06` supprimées |
| 32, 33 | absentes en GG | **nouvelles banques de texte anglais** (table de pointeurs à `$8000`) |
| 34-63 | absentes en GG | remplissage `$FF` |

## Patchs du portage GG2SMS (confirmés)

| Adresse | GG | SMS | Rôle |
|---|---|---|---|
| `$0066` (NMI) | `retn` + vecteurs `jp` en `$0068/$006B/$006E` | `push af / ld a,$40 / ld ($DFF0),a / pop af / retn` | le bouton Pause SMS lève un drapeau qui remplace le Start GG |
| `$007A` | efface la RAM jusqu'à `$DFEF` | jusqu'à `$DFF0` | inclut le drapeau de pause |
| `$0434` (`joypad_read`) | lit Start sur le port GG `$00` | lit `$DFF0` (Pause SMS) | entrée |
| `$0111`, `$0223`, `$0A4A`, `$4028` | registre VDP 0 = `$06`, registre 10 = `$16` | `$26` / `$36` | masque la colonne de gauche (bit 5 du registre 0) |
| `$0405A` | `jp $443B` | `jp $7FA3` | envoi de palette via le convertisseur |
| `$7FA3` (nouveau) | — | convertit les couleurs GG 12 bits (`----BBBBGGGGRRRR`) en SMS 6 bits | palette |
| `$7F94/$7FCD` (nouveau) | — | code exécuté via la banque 1 en slot 2 (`$BFCD`) | démarrage d'une séquence |
| `$68E9-$690E` | — | bornes de la fenêtre de texte | texte anglais plus long |
| banque 23 `$5D686...` | appels aux vecteurs `$006E/$006B/$0068` | appels directs `$05DD/$0A33/$2AF0` | les vecteurs ont été écrasés par la nouvelle NMI |
| banque 26 | `out ($06),a` (stéréo GG) | `nop nop` | le port n'existe pas sur SMS |

## Encodage du texte des crédits (banque 28)

`$1F` = espace, `$30` = A … (majuscules) ; la version EN ajoute des minuscules à partir de
`$70` = a. Exemple : « PRODUCER » = `3F 41 3E 33 44 32 34 41`.
