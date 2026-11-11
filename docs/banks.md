# Carte des banques ROM

Une banque fait 16 Ko. « Source » indique d'où la banque est construite au build (SMS EN).
✅ confirmé · 🔶 supposé · ❓ non décodé (reste dans `assets/sms_en/raw/bankNN.bin`).

| Banque | Contenu | Source (SMS EN) |
|---|---|---|
| 0 | code : boot, IRQ, tâches, joueur, collisions, acteurs, menu de pause ✅ | `src/core`, `src/game`, `src/screens` |
| 1 | code : VDP, palette, niveau, scripts, texte, sprites, interpréteur d'acteurs ✅ ; tables de niveau (`$4C14`, `$4C88`, `$4CFC`) ; en-tête `$7FF0` | `src/` |
| 2 | code banqué (états du joueur `$8000`) ✅, palettes de niveau (`$9DF1`, `$9E65`) et animations de palette (`$ADEC`) ✅, en-têtes de niveau | `src/` (palettes en lecture seule) |
| 3 | ❓ | brut |
| 4 | **placement des ennemis** ✅ (`$8006`) ; tables par type d'acteur (`$B461`) et effets raster par niveau (`$B55E`) 🔶 | composée : [enemies](enemies_sprites.md) |
| 5 | **scripts de scènes** ✅ (différents JP/EN) | `assets/<ver>/scripts/bank05.zs` → [scripts.md](scripts.md) |
| 6 | tuiles de niveau ✅ (2 blocs, 389 tuiles) | composée : PNG |
| 7 | tuiles ✅ (10 blocs) | composée : PNG |
| 8 | tuiles de niveau ✅ (4 blocs, 664 tuiles) | composée : PNG |
| 9 | **police** + tuiles de scènes ✅ (11 blocs) ; tilemaps (12) | composée : PNG, CSV |
| 10 | **métatuiles** (14 jeux) et **attributs** des niveaux ✅ | composée : [levels.md](levels.md) |
| 11 | ❓ | brut |
| 12 | tuiles de niveau ✅ (24 blocs) | composée : PNG |
| 13 | tuiles de niveau ✅ (10 blocs, 582 tuiles) | composée : PNG |
| 14 | tuiles de scènes ✅ (8 blocs) ; tilemaps (6) | composée : PNG, CSV |
| 15 | tuiles ✅ (5 blocs, 623 tuiles) | composée : PNG |
| 16 | tuiles + palettes (28) + tilemaps (5) de scènes ✅ | composée |
| 17 | palettes (112) + tuiles (15 blocs) + tilemaps (7) de scènes ✅ | composée |
| 18 | tuiles ✅ (10 blocs dont le menu de pause `$B468`) ; tables par niveau (`$B07A`, `$B332`) 🔶 | composée : PNG |
| 19, 20 | **cartes des niveaux** ✅ (28 cartes) ; banque 20 : 1 tilemap | composée : [levels.md](levels.md) |
| 21 | ❓ | brut |
| 22 | tuiles (10 blocs) + tilemaps (11) de scènes ✅ | composée |
| 23 | **code du menu caché** ✅ + listes de tuiles animées (`$5A52`) + table de types (`$B06B`), 6 blocs de tuiles, 4 tilemaps | `src/` (PNG en lecture seule) |
| 24 | **méta-sprites** ✅ (animations et dispositions) | composée : [enemies_sprites.md](enemies_sprites.md) |
| 25 | **scripts des acteurs** ✅ (`$8000-$BDAB`) + code banqué (`$BDAC`) | `assets/<ver>/actors/bank25.as` + `src/` → [actor_scripts.md](actor_scripts.md) |
| 26 | **driver son** ✅ (code, `$4000-$4B14`, exécuté en slot 1) + **données musicales** (`$4B15-$7FFF`) | `src/audio` + `assets/<ver>/music/music.smps` → [music.md](music.md) |
| 27 | **données musicales** ✅ | `assets/<ver>/music/music.smps` |
| 28 | palettes de scènes (196) + tilemaps (20) ✅ ; **texte japonais** (inutilisé en EN) | composée |
| 29 | ❓ | brut |
| 30, 31 | tuiles de niveau ✅ (2 et 8 blocs) | composée : PNG |
| 32 | **dialogues anglais** ✅ (SMS EN) | `assets/sms_en/text/strings.txt` → [text.md](text.md) |
| 33 | écrans de texte EN + tuiles (4 blocs, 799 tuiles) ✅ (SMS EN) | composée : `text/screens.txt` + PNG |
| 34-63 | vide (`$FF`), SMS EN ; utilisées pour les graphismes modifiés trop grands | — |

En GG JP, les banques de données restent générées dans `src/version/gg_jp/` (lecture seule),
sauf les scripts de scènes, les scripts d'acteurs et la musique, compilés depuis `assets/gg_jp/`.

Banques encore entièrement brutes : 3, 11, 21, 29 (et les parties non décodées des autres).
Elles ne sont référencées ni par les scripts, ni par les listes de niveau, ni par une
constante du code : leur usage passe par des tables non encore identifiées 🔶.
