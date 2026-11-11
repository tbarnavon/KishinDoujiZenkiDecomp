# Documentation du projet Kishin Douji Zenki

Tout ce qui a été découvert sur le jeu et sur le projet est ici. Chaque document distingue
ce qui est **confirmé** (lu dans le code, vérifié) de ce qui est **supposé** (déduit, à vérifier).

| Document | Contenu |
|---|---|
| [decisions.md](decisions.md) | Choix faits avec l'utilisateur (cible, version de base, outils, conventions) |
| [toolchain.md](toolchain.md) | Outils installés, versions, compatibilités, commandes de build et de vérification |
| [roms.md](roms.md) | Identification des deux ROMs, diff binaire, patchs du portage GG2SMS |
| [architecture.md](architecture.md) | **Comment le jeu fonctionne** : boot, mapper, IRQ, tâches, flux de jeu, sous-systèmes |
| [memory_map.md](memory_map.md) | Carte de la RAM ($C000-$DFFF) : variables identifiées |
| [banks.md](banks.md) | Carte des banques ROM : contenu et routines qui les lisent |
| [disassembly.md](disassembly.md) | Méthode de désassemblage, outils `tools/disasm/`, régénération des sources, limites |
| [modules.md](modules.md) | Classement de chaque routine dans son module, avec la raison (GÉNÉRÉ) |
| [scripts.md](scripts.md) | Format des scripts de scènes (banque 5), opcodes, édition |
| [text.md](text.md) | Textes : dialogues (banque 32), écrans de texte (banque 33), table de caractères, édition |
| [graphics.md](graphics.md) | Graphismes : format RLE, PNG, édition, déplacement automatique |
| [actor_scripts.md](actor_scripts.md) | Scripts d'acteurs (ennemis, objets) : banque 25, 54 commandes |
| [palettes_tilemaps.md](palettes_tilemaps.md) | Palettes (JSON) et tilemaps (CSV), compositeur de banques |
| [levels.md](levels.md) | Niveaux : cartes, métatuiles, attributs, aperçus PNG |
| [music.md](music.md) | Musique et effets sonores (driver SMPS, banques 26-27) |
| [ram_by_module.md](ram_by_module.md) | Variables RAM groupées par module (GÉNÉRÉ) |
| [enemies_sprites.md](enemies_sprites.md) | Placement des ennemis (banque 4) et méta-sprites (banque 24) |

## État d'avancement (2026-11-11)

| Étape | État |
|---|---|
| 0. Outils | ✅ fait |
| 1. Analyse des ROMs | ✅ fait |
| 2. Désassemblage | ✅ fait (≈ 40,5 Ko de code tracé dans les banques 0, 1, 2, 23, 25, 26, dont ≈ 19,5 Ko « probables ») |
| 3. Rebuild identique | ✅ **SMS EN et GG JP identiques octet pour octet** |
| Classement des routines | ✅ plus de `src/unsorted/` ; 73 routines « supposées » |
| 4. Extraction des ressources | ✅ scripts de scènes, dialogues + écrans de texte EN, tuiles (133 blocs / 6 814 tuiles, PNG), palettes (336), tilemaps (82), scripts d'acteurs, niveaux (58 + aperçus), musique et effets (26 + 39), ennemis (249), méta-sprites (355) ; restent bruts : quelques tables (voir banks.md) |
| 5. Rendre modifiable | ✅ adresses en dur → labels/constantes nommées ; ✅ RAM nommée par module + structure acteur ; ✅ `src/` gelé (édité à la main). Réécriture en C : **abandonnée** (le jeu est modifiable via `assets/` et `src/`) |

## Démarrage rapide

```sh
python tools/build.py                  # ROM SMS EN -> build/sms_en/zenki_sms_en.sms
python tools/build.py VERSION=gg_jp    # ROM GG JP  -> build/gg_jp/zenki_gg_jp.gg
python tools/verify.py VERSION=all     # comparaison octet pour octet avec original/
```
