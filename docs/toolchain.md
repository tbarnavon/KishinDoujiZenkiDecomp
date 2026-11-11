# Chaîne d'outils

## Outils

| Outil | Rôle | Emplacement | Version | Remarque |
|---|---|---|---|---|
| SDCC (sdcc, sdasz80, sdldz80) | compilateur, assembleur, éditeur de liens | `tools/sdcc-4.1.0/bin` | 4.1.0 #12072 | extrait de l'installeur avec 7z (rien d'installé dans Windows) |
| SDCC global | — | `C:\Program Files\SDCC` | 4.6.0 | **ne pas utiliser** : incompatible avec devkitSMS 1.2 |
| devkitSMS | SMSlib, crt0, ihx2sms, makesms, folder2c, assets2banks | `tools/devkitSMS/devkitSMS-1.2` | 1.2 | testé : hello world GG et SMS OK avec SDCC 4.1.0 |
| Python | build, outils | système | 3.14.7 | Pillow 12.3.0, numpy 2.5.3 |
| z80dasm | désassembleur (second avis) | WSL Ubuntu (`wsl z80dasm`) | 1.1.6 | |
| Emulicious | émulateur / débogueur | `tools/emulicious/` | Java 8 embarqué | voir ci-dessous |

Les chemins sont centralisés dans [`tools/toolchain.py`](../tools/toolchain.py)
(surchargeables par les variables d'environnement `SDCC_BIN` et `DEVKITSMS`).

## Pourquoi SDCC 4.1.0 et pas 4.6

Le README de devkitSMS 1.2 exige « SDCC 4.0.4 ou plus récent, **jusqu'à 4.1.11 au maximum** ».
À partir de 4.2, SDCC utilise la convention d'appel `sdcccall(1)` ; les `SMSlib.lib`
précompilées utilisent l'ancienne, et 6 fonctions `__naked` de SMSlib lisent leurs
paramètres selon l'ancienne convention (recompiler SMSlib en 4.6 la casserait silencieusement).

## sdasz80 : particularités utiles

- `-I<dir>` : chemin d'include (utilisé pour `version.inc` généré par version).
- `.if / .else / .endif` : utilisés pour les différences entre versions.
- `label::` : label global (exporté) — préféré à `.globl`, car il respecte les `.if`.
- **Pas de `.incbin`** : les ressources binaires devront être converties en `.s` ou en C
  (folder2c / assets2banks) dans `build/generated/` à l'étape 4.
- Les areas sont placées par l'éditeur de liens **dans l'ordre de leur première apparition** :
  le fichier `layout.s` généré, lié en premier, fixe donc l'ordre exact de la ROM.
- Banques : la banque N est liée à l'adresse `(N << 16) | base` ; sdldz80 tronque les
  pointeurs à 16 bits (comme devkitSMS).

## Commandes

```sh
python tools/build.py [VERSION=sms_en|gg_jp] [TRIM=1] [FIX_CHECKSUM=0|1] [VERBOSE=1]
python tools/verify.py [VERSION=sms_en|gg_jp|all] [MAX=20]
python tools/rominfo.py <rom>...          # en-tête, région, checksum, hashes
python tools/romdiff.py <romA> <romB>     # diff par banque, plages différentes
```

Le build vérifie qu'aucune banque ne déborde, remplit le vide en `$FF` et recalcule le
checksum de l'en-tête pour la version SMS (pas pour la GG JP, dont le checksum vaut `$0000`).

## Emulicious

Lancement : `tools/emulicious/java/bin/javaw.exe -jar tools/emulicious/Emulicious.jar -muted <rom>`

- Options en ligne de commande : `-muted`, `-scale n`, `-fullscreen`, `-turbo`, `-throttle n`,
  `-set clé=valeur`, `-disassemble <fichier>`.
- Le débogueur (couverture code/données, traceur, visualiseurs de tuiles/VRAM) s'utilise via
  l'interface graphique : prévu pour confirmer les routines « supposées » (voir
  [disassembly.md](disassembly.md)).
- Au premier lancement, il demande la politique de mise à jour : choix laissé à l'utilisateur.
- Emulicious n'accepte qu'une instance et n'a pas de mode sans fenêtre : il ne sert pas aux
  tests automatiques (voir ci-dessous).

## Émulateur de test sans fenêtre (`tools/emu/`)

Petit émulateur Master System en Node.js, écrit pour ce projet : Z80 complet (`z80.js`),
mapper Sega, VDP mode 4 rendu ligne par ligne (effets raster), manette, Pause (NMI). Le son
est ignoré. Environ 1 000 trames par seconde.

```sh
node tools/emu/sms.js <rom> <script.txt> [dossier_de_sortie]
```

Le script contient une commande par ligne : `run N`, `hold TOUCHES N` (UP, DOWN, LEFT,
RIGHT, B1, B2), `pause`, `shot NOM` (PNG 256×192 de l'écran complet), `save`/`load NOM`
(état), `peek`/`poke`, `regs`, `trace ADR NOM`, `prof LO HI BANQUE` / `prof off` (cycles),
`check on|gg|off` et `checkbg` (vérification du décor de la vue élargie, voir
[widescreen.md](widescreen.md)). Détails en tête de `tools/emu/sms.js`.

Astuces : le bouton 1 sert aussi de Start ; `poke C006 N` au titre choisit le niveau de
départ (`start_stage`).
