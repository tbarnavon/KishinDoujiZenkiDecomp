# Désassemblage : méthode et outils

## Principe

> **Depuis le 2026-11-11, `src/` est GELÉ** (fichier `src/FROZEN`) : les `.s` sont la référence
> éditée à la main ; `emit.py` refuse de les régénérer (sauf `--force`, qui écraserait tout).
> Ce qui suit décrit comment ils ont été produits ; `classify.py` / `analyze.py` restent utiles
> pour l'analyse. Étape 5 : opérandes classés par `operands.py` (pointeurs → labels, commandes
> VDP → `VDP_REG_n|val`, données des banques composées → `data_banks.inc`), RAM renommée par
> module et champs d'acteur (`structs.inc`) par `postprocess.py`.


Les sources de `src/` (sauf `src/include/hardware.inc`, écrit à la main) sont **générées**
à partir des ROMs par `tools/disasm/`. Pendant la phase actuelle, on améliore les sources en
modifiant la **configuration** (fichiers JSON), puis on régénère et on revérifie :

```sh
python tools/disasm/classify.py      # classement des routines -> modules.json + docs/modules.md
python tools/disasm/emit.py          # génère src/ et config/layout_*.cfg
python tools/build.py VERSION=sms_en && python tools/build.py VERSION=gg_jp
python tools/verify.py VERSION=all   # doit afficher IDENTIQUE pour les deux
```

⚠️ Toute modification faite **à la main** dans les `.s` générés est écrasée par `emit.py`.
Le « gel » de `src/` (les `.s` deviennent la référence éditée à la main) est prévu une fois
le désassemblage jugé suffisant.

## Outils (`tools/disasm/`)

| Fichier | Rôle |
|---|---|
| `z80.py` | décodeur Z80 complet, sortie sdasz80. Testé par `roundtrip_test.py` : les 696 instructions documentées se réassemblent à l'identique ; les encodages non canoniques (doublons ED, `sll`, ixh/ixl...) sont émis en `.db` |
| `trace.py` | traceur : suit le flot depuis les points d'entrée en propageant l'état du mapper (slots 1 et 2) et la valeur de A ; détecte les tables de saut ; passage spéculatif transactionnel |
| `run_trace.py` | lance le traceur avec `hints.json`, affiche couverture, problèmes, tables |
| `hints.json` | points d'entrée, tables de saut forcées, helpers de dispatch (`$2AF0`), zones de données interdites au code, registre miroir de banque (`$DCBE`) |
| `functions.py`, `analyze.py` | découpage en fonctions, graphe d'appels, racines (`roots.json`), rapports dans `build/analysis/` |
| `roots.json` | racines (tâches, IRQ, tables), module de chaque racine, régions, règles RAM |
| `classify.py` | affecte un module à chaque fonction (voir [modules.md](modules.md)) |
| `symbols.json` | noms et commentaires (labels, RAM), descriptions des modules, plages fixées à la main, typage des banques de données |
| `emit.py` | génère les sources modulaires, les blocs `.if VERSION_*`, `ram.inc`, les layouts |
| `inspect_rom.py` | désassemblage / dump rapide d'une adresse (banque + adresse CPU) |

## Détails du traceur

- Contexte suivi : `(banque slot 1, banque slot 2, A)`. `ld a,#n / ld ($FFFF),a` change le
  slot 2 ; `ld a,($DCBE)` = « A vaut la banque courante » (restauration sans changement).
- Une localisation de code = un offset ROM ; on mémorise aussi la **vue** CPU (le même code de la
  banque 1 est exécuté en `$7FCD` et en `$BFCD` dans le hack). L'émetteur produit alors
  `label+0x4000`, et pour les `jr` il tient compte de la vue de l'instruction.
- Tables de saut : motif `ld rr,#T ... add hl,rr ... ld e|a|c,(hl) ... jp (hl)` ; le nombre
  d'entrées est borné par la première cible (code qui suit la table) ou une entrée invalide,
  puis **vérifié à la main** sur les bornes du code (`cp`, `and`, `sub`...). 19 tables.
- **Passage spéculatif** : une adresse non tracée pointée par un mot de la ROM, dont le
  désassemblage linéaire est plausible, est essayée ; si elle crée un conflit (chevauchement,
  saut au milieu d'une instruction, cible en RAM, code sur des données connues), tout est annulé.
  Deux faux positifs ont été corrigés (`$0030` dans une table de pointeurs, `$4F64` dans la table
  `$4F01`). Ces routines restent **« probables »**.

## Organisation des sources générées

- Un **fragment** = une fonction et ses données, dans une area `_Bbb_AAAA`
  (banque, adresse). Le fichier `build/<ver>/generated/layout.s`, produit depuis
  `config/layout_<ver>.cfg` et lié en premier, fixe l'ordre des areas : on range les
  fragments par module sans changer l'image ROM.
- Différences de versions : blocs `.if VERSION_SMS_EN / .else / .endif` quand la différence
  est locale ; fichiers `src/version/<ver>/` quand elle couvre l'essentiel d'un fragment
  (script banque 5, manette, textes EN).
- Labels : `sub_XXXX` (appelée), `loc_XXXX` (sautée), `jt_XXXX` (table), préfixe `bNN_`
  pour les banques ≥ 2 ; les labels utilisés par d'autres modules sont définis avec `::`.
- Constantes : ports et mapper via `hardware.inc`, adresses RAM via `ram.inc`.

## Limites connues

- Étape 5 : pointeurs vers le code et les données des banques de code → labels ; restent
  numériques les constantes (comparaisons, tailles) et quelques adresses calculées à la main
  (ex. `ld d,#0x04` / `add a,#0x6c` dans `joypad_read`).
- **Modifier le code** : sans changer la taille d'une routine, aucun risque. Pour **ajouter**
  du code, le placer dans une banque libre (SMS EN : 34-63) et y sauter depuis la routine
  d'origine ; éviter d'agrandir une routine des banques 0/1 (pleines, et quelques adresses
  calculées à la main ou pointeurs dans des données non décodées pourraient casser).
- Code dans les banques 2 à 31 : seul ce qui est atteint par le traçage est désassemblé
  (banques 2, 23, 25) ; le reste est en `.db`.
- 73 routines sont **supposées** (non atteintes par les racines connues, rangées avec leur
  voisine). À confirmer avec le log de couverture d'Emulicious.

## Prochaine amélioration prévue : couverture Emulicious

Jouer quelques minutes (titre, démo, menu caché, plusieurs niveaux) avec le débogueur
d'Emulicious en enregistrant la couverture code/données, puis importer ce log dans
`hints.json` pour confirmer ou rejeter les routines probables.
