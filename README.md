# Kishin Douji Zenki — décompilation et projet modifiable (Master System / Game Gear)

Projet assembleur (chaîne SDCC : sdasz80 / sdldz80) reconstruisant **à l'octet près** les deux ROMs du jeu
Kishin Douji Zenki, à partir de sources modulaires et de ressources éditables.

| Version | ROM d'origine | Build |
|---|---|---|
| **SMS EN** (cible principale) : portage GG2SMS v0.3 traduit en anglais | `original/…GG2SMS_v0_3__EN_.sms` | `python tools/build.py` |
| GG JP : Game Gear japonaise | `original/Kishin Douji Zenki (J).gg` | `python tools/build.py VERSION=gg_jp` |

Les fichiers de `original/` ne sont jamais modifiés.

## Prérequis

Tout est fourni dans `tools/` (voir [docs/toolchain.md](docs/toolchain.md)) :
- SDCC **4.1.0** (`tools/sdcc-4.1.0` : assembleur `sdasz80` et éditeur de liens `sdldz80`) ;
- devkitSMS 1.2 (`tools/devkitSMS`, non utilisé par le build actuel) ;
- Python 3 + Pillow (système) ; Emulicious (`tools/emulicious`, Java inclus).

## Compiler et vérifier

```sh
python tools/build.py [VERSION=sms_en|gg_jp] [TRIM=1]
python tools/build.py WIDE=1            # vue élargie 256×192 -> build/sms_en_wide/ (docs/widescreen.md)
python tools/build.py ROM512=1          # ROM de 512 Ko au lieu de 1 Mo (docs/rom512.md), combinable
python tools/verify.py VERSION=all      # comparaison octet pour octet avec original/
```

- Sortie : `build/<version>/zenki_<version>.sms|.gg` (+ `.map`).

## Organisation

```
original/   ROMs de référence (intactes)
src/        code (édité à la main, gelé depuis la génération) : core/ video/ audio/ input/
            game/ screens/ data/ version/<ver>/ include/ (hardware.inc, ram.inc, structs.inc,
            data_banks.inc)
assets/     ressources éditables par version : scripts, texte, gfx (PNG), palettes, tilemaps,
            niveaux, ennemis, sprites, scripts d'acteurs, musique, raw/ (non décodé)
config/     placement des areas par banque (layout_<ver>.cfg)
tools/      build.py, verify.py, rominfo.py, romdiff.py, emu/ (émulateur de test), disasm/ (désassembleur),
            assets/ (extraction / réinjection de chaque format)
build/      sorties ; build/<ver>/generated/ = fichiers générés (jamais édités)
docs/       toute la documentation
```

## Documentation

Commencer par [docs/README.md](docs/README.md). Principaux documents :
[architecture](docs/architecture.md) (comment le jeu fonctionne) ·
[mémoire](docs/memory_map.md) / [RAM par module](docs/ram_by_module.md) ·
[banques](docs/banks.md) · [modules](docs/modules.md) · [ROMs et différences](docs/roms.md) ·
[désassemblage](docs/disassembly.md) · [vue élargie](docs/widescreen.md) · [ROM 512 Ko](docs/rom512.md) ·
[décisions](docs/decisions.md).

## Modifier le jeu

| Quoi | Où | Guide |
|---|---|---|
| Dialogues anglais | `assets/sms_en/text/strings.txt` | [text.md](docs/text.md) |
| Cinématiques, enchaînement des scènes | `assets/<ver>/scripts/bank05.zs` | [scripts.md](docs/scripts.md) |
| Graphismes | `assets/sms_en/gfx/bankNN/*.png` (PNG indexé 16 couleurs) | [graphics.md](docs/graphics.md) |
| Palettes, tilemaps | `assets/sms_en/palettes/`, `assets/sms_en/tilemaps/` | [palettes_tilemaps.md](docs/palettes_tilemaps.md) |
| Niveaux (cartes, métatuiles) | `assets/sms_en/levels/` (+ aperçus PNG) | [levels.md](docs/levels.md) |
| Placement des ennemis, animations | `assets/sms_en/enemies/`, `assets/sms_en/sprites/` | [enemies_sprites.md](docs/enemies_sprites.md) |
| Comportement des ennemis | `assets/<ver>/actors/bank25.as` | [actor_scripts.md](docs/actor_scripts.md) |
| Musique, effets sonores | `assets/<ver>/music/music.smps` | [music.md](docs/music.md) |
| Code | `src/` (assembleur, édité à la main) | [disassembly.md](docs/disassembly.md) |

Puis `python tools/build.py` et tester `build/sms_en/zenki_sms_en.sms` dans Emulicious.
