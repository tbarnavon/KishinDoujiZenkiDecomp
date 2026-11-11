# Classement des routines par module

GENERE par `tools/disasm/classify.py` (regles dans `tools/disasm/roots.json`).

Une routine *supposee* n'est atteinte par aucune racine connue (code probable trouve par pointeur) : elle est rangee avec sa voisine. A confirmer par la couverture Emulicious.

| Module | Role | Fonctions | dont supposees |
|---|---|---|---|
| `audio/sound_api` | Interface avec le driver son : commandes $DE04-$DE0B, initialisation. | 11 | 4 |
| `audio/sound_driver` | Driver son PSG (banque 26, execute en slot 1). | 57 | 0 |
| `core/boot` | Demarrage : vecteurs RST, reset, initialisation RAM/mapper/VDP. | 5 | 0 |
| `core/game_flow` | Sequenceur du jeu (tache 0) : titre, demo, lancement de partie, options de depart ($C006-$C008). | 36 | 4 |
| `core/irq` | Interruptions : vecteur IRQ ($0038), NMI ($0066), gestionnaire VBlank/HBlank. | 13 | 0 |
| `core/sms_port` | Code ajoute par le portage GG2SMS (conversion de palette, pause...). | 4 | 0 |
| `core/tasks` | Ordonnanceur cooperatif a 7 taches (piles separees) et API des taches. | 7 | 0 |
| `core/util` | Utilitaires partages (recherche en table, arithmetique, helpers generiques). | 33 | 6 |
| `game/actor_script` | Interpreteur des scripts d'acteurs (banque 25) : 54 commandes ($CA-$FF), table $72EB. | 85 | 0 |
| `game/actors` | Gestion des acteurs (tache 2) : 13 emplacements, apparition des ennemis depuis la liste du niveau ($C7FB, $3A9E). | 47 | 6 |
| `game/banked_b23` | Routines de la banque 23 hors menu cache, non encore rattachees a un systeme. | 16 | 15 |
| `game/collision` | Collisions avec le decor : lecture de metatuile, handlers par type de tuile ($2539) et d'interaction ($1D9E). | 78 | 26 |
| `game/level` | Chargement de niveau/scene (tache 3) : $5011, metatuiles (banque 10), preparation par scene ($4F01). | 54 | 2 |
| `game/player` | Joueur (taches 1 et 4) : structure $CEEF, etats ($CEEF = etat), controle, tables d'etats. | 148 | 82 |
| `game/script` | Moteur de scenes (tache 5) : interpreteur de bytecode (banque 5), 45 opcodes ($6595). | 57 | 1 |
| `game/scroll` | Defilement : $C09B (registre VDP 9) et $C0AE (registre VDP 8). | 5 | 0 |
| `game/stage_events` | Evenements de niveau (tache 4) : declencheurs $C1E1, handlers $0B3D. | 48 | 14 |
| `game/text` | Texte : police (banque 9), fenetre et affichage des chaines (banques 32/33 en EN). | 5 | 0 |
| `input/joypad` | Lecture des manettes et detection des fronts (appuis). | 3 | 0 |
| `screens/debug_menu` | Menu cache (banque 23, combinaison $B4) : choix du niveau et des options de depart. | 29 | 9 |
| `screens/pause_menu` | Menu de pause (bouton Pause SMS / Start GG) : $1616. | 12 | 0 |
| `video/palette` | Palette : effets par couleur ($C0E4) et fondus ($C0D3). | 16 | 5 |
| `video/sprites` | Meta-sprites : tampon $C200, definitions en banques 23/24. | 23 | 0 |
| `video/vdp` | Acces VDP : adresse/registres, affichage on/off, transferts VRAM/CRAM. | 58 | 3 |

## audio/sound_api

- `0:04FB` : ecrit les commandes du driver son ($DE04-$DE0B)
- `0:0546` : ecrit les commandes du driver son ($DE04-$DE0B)
- `0:0551` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:0556` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:059F` : ecrit les commandes du driver son ($DE04-$DE0B)
- `0:05DD` : plage fixee dans symbols.json
- `0:05F8` : ecrit les commandes du driver son ($DE04-$DE0B)
- `0:0608` : ecrit les commandes du driver son ($DE04-$DE0B)
- `0:0611` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:061D` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:062D` : ecrit les commandes du driver son ($DE04-$DE0B)

## audio/sound_driver

- `26:4000` : plage fixee dans symbols.json
- `26:4072` : plage fixee dans symbols.json
- `26:408A` : plage fixee dans symbols.json
- `26:40D5` : plage fixee dans symbols.json
- `26:4137` : plage fixee dans symbols.json
- `26:413E` : plage fixee dans symbols.json
- `26:4172` : plage fixee dans symbols.json
- `26:4176` : plage fixee dans symbols.json
- `26:4193` : plage fixee dans symbols.json
- `26:41D4` : plage fixee dans symbols.json
- `26:41E4` : plage fixee dans symbols.json
- `26:4284` : plage fixee dans symbols.json
- `26:42CA` : plage fixee dans symbols.json
- `26:430C` : plage fixee dans symbols.json
- `26:434B` : plage fixee dans symbols.json
- `26:43EC` : plage fixee dans symbols.json
- `26:4485` : plage fixee dans symbols.json
- `26:44A9` : plage fixee dans symbols.json
- `26:44C8` : plage fixee dans symbols.json
- `26:44E2` : plage fixee dans symbols.json
- `26:44FB` : plage fixee dans symbols.json
- `26:4605` : plage fixee dans symbols.json
- `26:462D` : plage fixee dans symbols.json
- `26:4668` : plage fixee dans symbols.json
- `26:46EB` : plage fixee dans symbols.json
- `26:470D` : plage fixee dans symbols.json
- `26:474C` : plage fixee dans symbols.json
- `26:480F` : plage fixee dans symbols.json
- `26:483C` : plage fixee dans symbols.json
- `26:484B` : plage fixee dans symbols.json
- `26:484C` : plage fixee dans symbols.json
- `26:4864` : plage fixee dans symbols.json
- `26:486B` : plage fixee dans symbols.json
- `26:486F` : plage fixee dans symbols.json
- `26:48BD` : plage fixee dans symbols.json
- `26:48E7` : plage fixee dans symbols.json
- `26:48EB` : plage fixee dans symbols.json
- `26:48F1` : plage fixee dans symbols.json
- `26:48FF` : plage fixee dans symbols.json
- `26:496B` : plage fixee dans symbols.json
- `26:4978` : plage fixee dans symbols.json
- `26:497F` : plage fixee dans symbols.json
- `26:4996` : plage fixee dans symbols.json
- `26:49A9` : plage fixee dans symbols.json
- `26:49BC` : plage fixee dans symbols.json
- `26:49CF` : plage fixee dans symbols.json
- `26:49E2` : plage fixee dans symbols.json
- `26:49F8` : plage fixee dans symbols.json
- `26:4A06` : plage fixee dans symbols.json
- `26:4A14` : plage fixee dans symbols.json
- `26:4A22` : plage fixee dans symbols.json
- `26:4A30` : plage fixee dans symbols.json
- `26:4A3A` : plage fixee dans symbols.json
- `26:4A48` : plage fixee dans symbols.json
- `26:4A4E` : plage fixee dans symbols.json
- `26:4A52` : plage fixee dans symbols.json
- `26:4A5A` : plage fixee dans symbols.json

## core/boot

- `0:0000` : plage fixee dans symbols.json
- `0:0008` : plage fixee dans symbols.json
- `0:0010` : plage fixee dans symbols.json
- `0:0031` : plage fixee dans symbols.json
- `0:0034` : plage fixee dans symbols.json

## core/game_flow

- `0:0565` : atteinte uniquement par task0_main
- `0:06B3` : atteinte uniquement par task0_main
- `0:08DF` : atteinte uniquement par task0_main
- `0:094C` : atteinte uniquement par mode_093A
- `0:0952` : atteinte uniquement par mode_093A
- `0:0958` : atteinte uniquement par mode_093A
- `0:0963` : atteinte uniquement par mode_093A
- `0:0967` : atteinte uniquement par mode_093A
- `0:096B` : atteinte uniquement par mode_093A
- `0:0971` : atteinte uniquement par mode_093A
- `0:0975` : atteinte uniquement par mode_093A
- `0:097A` : atteinte uniquement par mode_093A
- `0:0982` : atteinte uniquement par task0_main
- `0:0991` : atteinte uniquement par task0_main
- `0:0994` : atteinte uniquement par task0_main
- `0:0A0C` : atteinte uniquement par submode_0A02
- `0:0A12` : atteinte uniquement par submode_0A02
- `0:0A18` : atteinte uniquement par submode_0A02
- `0:0A28` : atteinte uniquement par task0_main
- `0:0AB2` : atteinte uniquement par task0_main
- `0:0ACC` : atteinte uniquement par task0_main
- `0:0AFB` : atteinte uniquement par task0_main
- `0:3DD0` : atteinte uniquement par task0_main
- `0:3DDD` : atteinte uniquement par task0_main
- `0:3E15` : atteinte uniquement par task0_main
- `0:3E30` : atteinte uniquement par task0_main
- `0:3E38` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:3EA0` : atteinte uniquement par task0_main
- `0:3ECF` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:3ED3` : atteinte uniquement par task0_main
- `0:3FE3` : atteinte uniquement par task0_main
- `0:3FF5` : atteinte uniquement par task0_main
- `1:5EBD` : atteinte uniquement par task0_main
- `2:ADA6` : atteinte uniquement par task0_main
- `2:B59C` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:B842` : SUPPOSE : non atteinte, rangee avec la fonction precedente

## core/irq

- `0:0038` : plage fixee dans symbols.json
- `0:003B` : plage fixee dans symbols.json
- `0:003E` : plage fixee dans symbols.json
- `0:0042` : plage fixee dans symbols.json
- `0:004D` : plage fixee dans symbols.json
- `0:0050` : plage fixee dans symbols.json
- `0:005B` : plage fixee dans symbols.json
- `0:005E` : plage fixee dans symbols.json
- `0:0061` : plage fixee dans symbols.json
- `0:0066` : plage fixee dans symbols.json
- `0:0071` : plage fixee dans symbols.json
- `0:00B0` : plage fixee dans symbols.json
- `0:00E1` : plage fixee dans symbols.json

## core/sms_port

- `1:7F94` : plage fixee dans symbols.json
- `1:7FA7` : plage fixee dans symbols.json
- `1:7FBE` : plage fixee dans symbols.json
- `1:7FCB` : plage fixee dans symbols.json

## core/tasks

- `0:0273` : plage fixee dans symbols.json
- `0:02C6` : plage fixee dans symbols.json
- `0:02F8` : plage fixee dans symbols.json
- `0:030E` : plage fixee dans symbols.json
- `0:0330` : plage fixee dans symbols.json
- `0:0332` : plage fixee dans symbols.json
- `0:042B` : plage fixee dans symbols.json

## core/util

- `0:19B7` : utilitaire partage par task1+task3
- `0:1BE7` : utilitaire partage par task1+task4
- `0:1BF4` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:1F2B` : utilitaire partage par task3+tbl_1D9E
- `0:1F49` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:2118` : utilitaire partage par task1+task5_scene
- `0:2127` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:223B` : utilitaire partage par task0_main+task1+task4+task5_scene
- `0:23FC` : utilitaire partage par task1+tbl_1D9E
- `0:2AF9` : plage fixee dans symbols.json
- `0:2B54` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:2B9F` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:2EFD` : utilitaire partage par task1+tbl_1D9E
- `0:3085` : utilitaire partage par task1+tbl_2539
- `0:3569` : utilitaire partage par task1+task2
- `0:35D7` : utilitaire partage par entcmd_72EB+task1+task2+tbl_1D9E
- `0:35E2` : utilitaire partage par task1+task2+task4+tbl_1D9E
- `0:3630` : utilitaire partage par task0_main+task2
- `0:363E` : utilitaire partage par task0_main+task2
- `0:3994` : utilitaire partage par task1+tbl_1D9E
- `1:474E` : utilitaire partage par task1+task3+task4
- `1:481F` : utilitaire partage par script_op_6595+task0_main+task1+task2+task3+task4+task5_scene+tbl_1D9E
- `1:485E` : utilitaire partage par task1+task4
- `1:4863` : utilitaire partage par task1+task4
- `1:489D` : utilitaire partage par task1+task4
- `1:48A2` : utilitaire partage par task1+task4
- `1:48DA` : utilitaire partage par task3+task4+tbl_0B3D
- `1:56CA` : utilitaire partage par task1+task3+task4+tbl_0B3D
- `1:5ECA` : utilitaire partage par task0_main+task2
- `1:5ED5` : utilitaire partage par task0_main+task1
- `23:AC09` : utilitaire partage par task0_main+tbl_b23_970D
- `23:AC2A` : utilitaire partage par task0_main+tbl_b23_970D
- `23:AFEC` : SUPPOSE : non atteinte, rangee avec la fonction precedente

## game/actor_script

- `0:3036` : atteinte uniquement par entcmd_72EB
- `0:3075` : atteinte uniquement par entcmd_72EB
- `1:5B03` : atteinte uniquement par entcmd_72EB
- `1:5B33` : atteinte uniquement par entcmd_72EB
- `1:61A3` : atteinte uniquement par entcmd_72EB
- `1:6256` : atteinte uniquement par entcmd_72EB
- `1:62DD` : atteinte uniquement par entcmd_72EB
- `1:62F0` : atteinte uniquement par entcmd_72EB
- `1:6326` : atteinte uniquement par entcmd_72EB
- `1:7292` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:72B2` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7357` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7360` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7386` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7393` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:73B3` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:73FE` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:740F` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:743C` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7449` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7483` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:749C` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:74BD` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:74EC` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:750A` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7510` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7519` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7522` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:752B` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7534` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:757D` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:75E7` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7613` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7632` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7645` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7651` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:765D` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7694` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:76B1` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:76C8` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:76DB` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:76F8` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7708` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7741` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:775C` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7778` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:778F` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:77D3` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:77DB` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:77F3` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7828` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:785C` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7876` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7888` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7891` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:789A` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:78A3` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:78AD` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:78B4` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:78E9` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7910` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7923` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:793B` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7945` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:795F` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:797A` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7994` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:79CC` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:79D5` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:79DE` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7A0E` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7A1E` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7A41` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7A59` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7AB8` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7AC3` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7B02` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7B0D` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7B14` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7B19` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7B63` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7B86` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7BBD` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7BCE` : interpreteur de scripts d'acteurs (banque 25) et ses commandes
- `1:7BEF` : interpreteur de scripts d'acteurs (banque 25) et ses commandes

## game/actors

- `0:0505` : atteinte uniquement par task2
- `0:066B` : atteinte uniquement par task2
- `0:068A` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:068F` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:0694` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:0699` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:069E` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:06AA` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:2F31` : atteinte uniquement par task2
- `0:3006` : atteinte uniquement par task2
- `0:3023` : atteinte uniquement par task2
- `0:3476` : atteinte uniquement par task2
- `0:34D2` : atteinte uniquement par task2
- `0:3606` : atteinte uniquement par task2
- `0:364F` : atteinte uniquement par task2
- `0:36EC` : atteinte uniquement par task2
- `0:37B5` : atteinte uniquement par task2
- `0:38B2` : atteinte uniquement par task2
- `0:3984` : atteinte uniquement par task2
- `0:398C` : atteinte uniquement par task2
- `0:39BE` : atteinte uniquement par task2
- `0:39D7` : atteinte uniquement par task2
- `0:39F0` : atteinte uniquement par task2
- `0:3A17` : atteinte uniquement par task2
- `0:3A1F` : atteinte uniquement par task2
- `0:3A56` : atteinte uniquement par task2
- `0:3A5E` : atteinte uniquement par task2
- `0:3A66` : atteinte uniquement par task2
- `0:3A9E` : atteinte uniquement par task2
- `0:3B28` : routines d'acteurs partagees (banques 4/25)
- `0:3B78` : routines d'acteurs partagees (banques 4/25)
- `0:3BA6` : routines d'acteurs partagees (banques 4/25)
- `0:3BB5` : routines d'acteurs partagees (banques 4/25)
- `0:3BCD` : routines d'acteurs partagees (banques 4/25)
- `0:3BD8` : routines d'acteurs partagees (banques 4/25)
- `0:3C12` : routines d'acteurs partagees (banques 4/25)
- `0:3C16` : routines d'acteurs partagees (banques 4/25)
- `0:3C18` : routines d'acteurs partagees (banques 4/25)
- `0:3C1A` : routines d'acteurs partagees (banques 4/25)
- `1:5DF3` : atteinte uniquement par task2
- `1:5E7A` : atteinte uniquement par task2
- `1:5EE5` : atteinte uniquement par task2
- `1:5F0F` : atteinte uniquement par task2
- `1:5F28` : atteinte uniquement par task2
- `1:5F57` : atteinte uniquement par task2
- `1:5FB0` : atteinte uniquement par task2
- `25:BDAC` : atteinte uniquement par task2

## game/banked_b23

- `23:8360` : non atteinte : routine banquee, role a identifier
- `23:8363` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:8368` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:836F` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:8733` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:873C` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:876E` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:87EB` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:893F` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:8A42` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:8A6C` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:8D83` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:8E50` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:8E6E` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:93F7` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:9554` : SUPPOSE : non atteinte, rangee avec la fonction precedente

## game/collision

- `0:050A` : atteinte uniquement par tbl_1D9E
- `0:050F` : atteinte uniquement par tbl_1D9E
- `0:0514` : atteinte uniquement par tbl_1D9E
- `0:0519` : atteinte uniquement par tbl_1D9E
- `0:0523` : atteinte uniquement par tbl_1D9E
- `0:0528` : atteinte uniquement par tbl_1D9E
- `0:052D` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:0532` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:053C` : atteinte uniquement par tbl_1D9E
- `0:064F` : atteinte uniquement par tbl_2539
- `0:1DE4` : atteinte uniquement par tbl_1D9E
- `0:1DE8` : atteinte uniquement par tbl_1D9E
- `0:1DED` : atteinte uniquement par tbl_1D9E
- `0:1DF1` : atteinte uniquement par tbl_1D9E
- `0:1DF5` : atteinte uniquement par tbl_1D9E
- `0:1E03` : atteinte uniquement par tbl_1D9E
- `0:1E07` : atteinte uniquement par tbl_1D9E
- `0:1E0B` : atteinte uniquement par tbl_1D9E
- `0:1E0F` : atteinte uniquement par tbl_1D9E
- `0:1E13` : atteinte uniquement par tbl_1D9E
- `0:1E27` : atteinte uniquement par tbl_1D9E
- `0:1E28` : atteinte uniquement par tbl_1D9E
- `0:1E2F` : atteinte uniquement par tbl_1D9E
- `0:1E36` : atteinte uniquement par tbl_1D9E
- `0:1E42` : atteinte uniquement par tbl_1D9E
- `0:1E4E` : atteinte uniquement par tbl_1D9E
- `0:1E55` : atteinte uniquement par tbl_1D9E
- `0:1EA0` : atteinte uniquement par tbl_1D9E
- `0:1EA7` : atteinte uniquement par tbl_1D9E
- `0:1EAE` : atteinte uniquement par tbl_1D9E
- `0:1EB5` : atteinte uniquement par tbl_1D9E
- `0:1EDD` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:1EF8` : atteinte uniquement par tbl_1D9E
- `0:1EFE` : atteinte uniquement par tbl_1D9E
- `0:1F18` : atteinte uniquement par tbl_1D9E
- `0:1F4F` : atteinte uniquement par tbl_1D9E
- `0:2579` : atteinte uniquement par tbl_2539
- `0:257A` : atteinte uniquement par tbl_2539
- `0:2582` : atteinte uniquement par tbl_2539
- `0:2595` : atteinte uniquement par tbl_2539
- `0:276F` : atteinte uniquement par tbl_2539
- `0:2792` : atteinte uniquement par tbl_2539
- `0:27BF` : atteinte uniquement par tbl_2539
- `0:27CC` : atteinte uniquement par tbl_1D9E
- `0:27D3` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:2807` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:29C5` : lecture de la tuile/metatuile sous une position (banque 10)
- `0:2A03` : lecture de la tuile/metatuile sous une position (banque 10)
- `0:2A6A` : lecture de la tuile/metatuile sous une position (banque 10)
- `0:2A72` : lecture de la tuile/metatuile sous une position (banque 10)
- `0:2A7A` : lecture de la tuile/metatuile sous une position (banque 10)
- `0:2AA8` : lecture de la tuile/metatuile sous une position (banque 10)
- `0:2ACC` : lecture de la tuile/metatuile sous une position (banque 10)
- `0:2AD8` : lecture de la tuile/metatuile sous une position (banque 10)
- `0:2AE0` : lecture de la tuile/metatuile sous une position (banque 10)
- `0:3190` : atteinte uniquement par tbl_1D9E
- `0:31D0` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:3287` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:32B1` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:32EC` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:3320` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:3329` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5C25` : atteinte uniquement par tbl_2539
- `1:5CEA` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5CEE` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5CF2` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5CF6` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5D15` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5D1C` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5D23` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5D2A` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5D31` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5D38` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5D3F` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5D46` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5D4D` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5D89` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5D90` : SUPPOSE : non atteinte, rangee avec la fonction precedente

## game/level

- `0:05AD` : atteinte uniquement par task3
- `0:0639` : atteinte uniquement par task3
- `1:4767` : atteinte uniquement par task3
- `1:47BD` : atteinte uniquement par task3
- `1:47D8` : atteinte uniquement par task3
- `1:47E7` : atteinte uniquement par task3
- `1:480A` : atteinte uniquement par task3
- `1:481D` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:4835` : atteinte uniquement par task3
- `1:4984` : metatuiles (banque 10, 8 octets par metatuile)
- `1:499F` : metatuiles (banque 10, 8 octets par metatuile)
- `1:49D4` : metatuiles (banque 10, 8 octets par metatuile)
- `1:49F0` : metatuiles (banque 10, 8 octets par metatuile)
- `1:4A0C` : metatuiles (banque 10, 8 octets par metatuile)
- `1:4A24` : metatuiles (banque 10, 8 octets par metatuile)
- `1:4A4D` : metatuiles (banque 10, 8 octets par metatuile)
- `1:4A5C` : metatuiles (banque 10, 8 octets par metatuile)
- `1:4ABF` : metatuiles (banque 10, 8 octets par metatuile)
- `1:4AF9` : metatuiles (banque 10, 8 octets par metatuile)
- `1:4B29` : metatuiles (banque 10, 8 octets par metatuile)
- `1:4B32` : metatuiles (banque 10, 8 octets par metatuile)
- `1:4F75` : preparation par scene (table $4F01 indexee par $C014)
- `1:4F8C` : preparation par scene (table $4F01 indexee par $C014)
- `1:4F91` : preparation par scene (table $4F01 indexee par $C014)
- `1:4FA8` : preparation par scene (table $4F01 indexee par $C014)
- `1:4FBF` : preparation par scene (table $4F01 indexee par $C014)
- `1:4FE4` : preparation par scene (table $4F01 indexee par $C014)
- `1:5008` : preparation par scene (table $4F01 indexee par $C014)
- `1:5009` : preparation par scene (table $4F01 indexee par $C014)
- `1:5011` : atteinte uniquement par task3
- `1:5101` : atteinte uniquement par task3
- `1:5124` : atteinte uniquement par task3
- `1:512D` : atteinte uniquement par task3
- `1:513F` : atteinte uniquement par task3
- `1:518A` : atteinte uniquement par task3
- `1:5190` : atteinte uniquement par task3
- `1:5198` : chargement de donnees de niveau
- `1:56E8` : atteinte uniquement par task3
- `1:5714` : atteinte uniquement par task3
- `1:5730` : atteinte uniquement par task3
- `1:59C1` : chargeurs banques 2/23 pilotes par $C014
- `1:5A0F` : chargeurs banques 2/23 pilotes par $C014
- `1:5A52` : chargeurs banques 2/23 pilotes par $C014
- `1:5ABE` : chargeurs banques 2/23 pilotes par $C014
- `1:5AFC` : chargeurs banques 2/23 pilotes par $C014
- `1:601C` : atteinte uniquement par task3
- `1:60D6` : atteinte uniquement par task3
- `1:6140` : atteinte uniquement par task3
- `1:617C` : atteinte uniquement par task3
- `1:6186` : atteinte uniquement par task3
- `1:618B` : atteinte uniquement par task3
- `2:AD79` : atteinte uniquement par task3
- `2:AD86` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:AD90` : atteinte uniquement par task3

## game/player

- `0:04EC` : atteinte uniquement par tbl_b02_8000
- `0:051E` : atteinte uniquement par task1
- `0:0541` : atteinte uniquement par task1
- `0:055B` : atteinte uniquement par task1
- `0:0560` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:05FE` : atteinte uniquement par task1
- `0:0603` : atteinte uniquement par task1
- `0:18EE` : atteinte uniquement par task1
- `0:191B` : atteinte uniquement par task1
- `0:193C` : atteinte uniquement par task1
- `0:1963` : atteinte uniquement par task1
- `0:1A2D` : atteinte uniquement par task1
- `0:1B12` : atteinte uniquement par task1
- `0:1B2C` : atteinte uniquement par task1
- `0:1B47` : atteinte uniquement par task1
- `0:1B57` : atteinte uniquement par task1
- `0:1C60` : atteinte uniquement par task1
- `0:1C75` : atteinte uniquement par task1
- `0:1C8A` : atteinte uniquement par task1
- `0:1D87` : atteinte uniquement par task1
- `0:1F87` : atteinte uniquement par task1
- `0:1F8F` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:1F9B` : atteinte uniquement par task1
- `0:1FA7` : atteinte uniquement par task1
- `0:2059` : atteinte uniquement par task1
- `0:2074` : atteinte uniquement par task1
- `0:2082` : racines du meme module : task1+tbl_3CC3
- `0:2090` : atteinte uniquement par task1
- `0:20B4` : atteinte uniquement par task1
- `0:20D8` : atteinte uniquement par task1
- `0:212C` : atteinte uniquement par task1
- `0:21CD` : atteinte uniquement par task1
- `0:21E9` : atteinte uniquement par task1
- `0:221E` : ecrit la structure du joueur ($CEEF)
- `0:225F` : ecrit la structure du joueur ($CEEF)
- `0:22BF` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:24F1` : atteinte uniquement par task1
- `0:2529` : atteinte uniquement par task1
- `0:280F` : atteinte uniquement par task1
- `0:2982` : atteinte uniquement par task1
- `0:29AC` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:29B7` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:2BE4` : atteinte uniquement par task1
- `0:2C75` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:2CFA` : atteinte uniquement par tbl_2CEE
- `0:2D26` : atteinte uniquement par tbl_2CEE
- `0:2D52` : atteinte uniquement par tbl_2CEE
- `0:2D9A` : atteinte uniquement par tbl_2CEE
- `0:2DE2` : atteinte uniquement par tbl_2CEE
- `0:2DFF` : atteinte uniquement par tbl_2CEE
- `0:2E1C` : atteinte uniquement par task1
- `0:2E33` : atteinte uniquement par tbl_2E2D
- `0:2E3C` : atteinte uniquement par tbl_2E2D
- `0:2EDB` : atteinte uniquement par tbl_2E2D
- `0:2EDC` : ecrit la structure du joueur ($CEEF)
- `0:2F16` : atteinte uniquement par task1
- `0:3123` : ecrit la structure du joueur ($CEEF)
- `0:3C1D` : atteinte uniquement par task1
- `0:3C30` : atteinte uniquement par task1
- `0:3CDB` : atteinte uniquement par tbl_3CC3
- `0:3D47` : atteinte uniquement par tbl_3CC3
- `0:3D6C` : atteinte uniquement par tbl_3CC3
- `0:3DBA` : racines du meme module : task1+tbl_3CC3
- `1:569A` : ecrit la structure du joueur ($CEEF)
- `1:5B50` : atteinte uniquement par task1
- `1:5BB8` : atteinte uniquement par task1
- `1:5BDE` : atteinte uniquement par task1
- `2:8006` : atteinte uniquement par tbl_b02_8000
- `2:81A0` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8267` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:834C` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8388` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8496` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:852B` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:856F` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8592` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:85E4` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8630` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:86C7` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:86F7` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8767` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:87A2` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:87CC` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:87E7` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8896` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:88B4` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:88ED` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8922` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8951` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:897A` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8996` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:89DC` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:89F6` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8ACD` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8B1A` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8BA2` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8C02` : atteinte uniquement par tbl_b02_8000
- `2:8C1B` : atteinte uniquement par tbl_b02_8000
- `2:8C62` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8CFC` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8D8F` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8E16` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8E81` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8EBA` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8F04` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8F48` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:8FAA` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9012` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9013` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:903E` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:908E` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:90AD` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:912C` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9147` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:921D` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:926A` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:92CC` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9361` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9469` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:94AF` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:94F4` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9538` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:957D` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:957F` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:95C4` : atteinte uniquement par tbl_b02_8000
- `2:961B` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:967A` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9752` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:97C6` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:98D1` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:99D6` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9A4C` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9A4D` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9AAB` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9B05` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9B46` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9B85` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9B9C` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9C68` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9C8F` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9CA9` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9CEF` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:9D47` : atteinte uniquement par tbl_b02_8000
- `2:9D70` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:A57C` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:AD5E` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:AD66` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `2:AD6B` : SUPPOSE : non atteinte, rangee avec la fonction precedente

## game/script

- `1:6337` : atteinte uniquement par task5_scene
- `1:6396` : atteinte uniquement par task5_scene
- `1:6427` : atteinte uniquement par task5_scene
- `1:643F` : atteinte uniquement par task5_scene
- `1:6469` : atteinte uniquement par task5_scene
- `1:64DC` : atteinte uniquement par task5_scene
- `1:653B` : atteinte uniquement par task5_scene
- `1:65EF` : atteinte uniquement par script_op_6595
- `1:65F3` : atteinte uniquement par script_op_6595
- `1:65FD` : atteinte uniquement par script_op_6595
- `1:660B` : atteinte uniquement par script_op_6595
- `1:6619` : atteinte uniquement par script_op_6595
- `1:6631` : atteinte uniquement par script_op_6595
- `1:665A` : atteinte uniquement par script_op_6595
- `1:6665` : atteinte uniquement par script_op_6595
- `1:666C` : atteinte uniquement par script_op_6595
- `1:66A7` : atteinte uniquement par script_op_6595
- `1:66C4` : atteinte uniquement par script_op_6595
- `1:66DC` : atteinte uniquement par script_op_6595
- `1:6702` : atteinte uniquement par script_op_6595
- `1:6741` : atteinte uniquement par script_op_6595
- `1:674A` : atteinte uniquement par script_op_6595
- `1:675F` : atteinte uniquement par script_op_6595
- `1:676F` : atteinte uniquement par script_op_6595
- `1:6779` : atteinte uniquement par script_op_6595
- `1:678C` : atteinte uniquement par script_op_6595
- `1:6799` : atteinte uniquement par script_op_6595
- `1:67AA` : atteinte uniquement par script_op_6595
- `1:67B5` : atteinte uniquement par script_op_6595
- `1:67BB` : racines du meme module : script_op_6595+task5_scene
- `1:67C0` : atteinte uniquement par script_op_6595
- `1:67CB` : atteinte uniquement par script_op_6595
- `1:67E0` : atteinte uniquement par script_op_6595
- `1:67FA` : atteinte uniquement par script_op_6595
- `1:681D` : atteinte uniquement par script_op_6595
- `1:683D` : atteinte uniquement par script_op_6595
- `1:6857` : atteinte uniquement par script_op_6595
- `1:686B` : atteinte uniquement par script_op_6595
- `1:6924` : atteinte uniquement par script_op_6595
- `1:6955` : atteinte uniquement par script_op_6595
- `1:6998` : atteinte uniquement par script_op_6595
- `1:69A3` : atteinte uniquement par script_op_6595
- `1:69CD` : atteinte uniquement par script_op_6595
- `1:69D9` : atteinte uniquement par script_op_6595
- `1:69E3` : atteinte uniquement par script_op_6595
- `1:69F0` : atteinte uniquement par script_op_6595
- `1:69FF` : atteinte uniquement par script_op_6595
- `1:6A07` : atteinte uniquement par script_op_6595
- `1:6A11` : atteinte uniquement par script_op_6595
- `1:6A30` : racines du meme module : script_op_6595+task5_scene
- `1:6A40` : atteinte uniquement par script_op_6595
- `1:6A60` : atteinte uniquement par script_op_6595
- `1:6A80` : atteinte uniquement par script_op_6595
- `1:6A94` : atteinte uniquement par script_op_6595
- `1:6ACF` : atteinte uniquement par task5_scene
- `1:6BA5` : atteinte uniquement par task5_scene
- `1:6BC1` : SUPPOSE : non atteinte, rangee avec la fonction precedente

## game/scroll

- `0:1BC9` : ecrit les variables de defilement
- `0:2249` : ecrit les variables de defilement
- `0:2C7B` : ecrit les variables de defilement
- `1:55A8` : ecrit le defilement (C09B -> reg VDP 9, C0AE -> reg 8)
- `1:5606` : ecrit le defilement (C09B -> reg VDP 9, C0AE -> reg 8)

## game/stage_events

- `0:04F1` : atteinte uniquement par task4
- `0:04F6` : atteinte uniquement par task4
- `0:0500` : atteinte uniquement par tbl_0B3D
- `0:0537` : atteinte uniquement par task4
- `0:0653` : atteinte uniquement par tbl_0B3D
- `0:0657` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:065B` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:065F` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:0663` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:0667` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:0B20` : atteinte uniquement par tbl_0B3D
- `0:0B5F` : atteinte uniquement par tbl_0B3D
- `0:0B8E` : atteinte uniquement par tbl_0B3D
- `0:0BAA` : atteinte uniquement par tbl_0B3D
- `0:0BD7` : atteinte uniquement par tbl_0B3D
- `0:0C04` : atteinte uniquement par tbl_0B3D
- `0:0C1B` : atteinte uniquement par tbl_0B3D
- `0:0C77` : atteinte uniquement par tbl_0B3D
- `0:0CA4` : atteinte uniquement par tbl_0B3D
- `0:0CE3` : atteinte uniquement par tbl_0B3D
- `0:0D10` : atteinte uniquement par tbl_0B3D
- `0:0D3D` : atteinte uniquement par tbl_0B3D
- `0:0D6A` : atteinte uniquement par tbl_0B3D
- `0:0D81` : atteinte uniquement par tbl_0B3D
- `0:0DC9` : atteinte uniquement par tbl_0B3D
- `0:0E05` : atteinte uniquement par tbl_0B3D
- `0:0E48` : atteinte uniquement par tbl_0B3D
- `0:0E8A` : atteinte uniquement par tbl_0B3D
- `0:0F4C` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:0F4E` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:0F50` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:0F52` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:0F54` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:0F56` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:0FA9` : atteinte uniquement par task4
- `0:1236` : atteinte uniquement par task4
- `0:1294` : atteinte uniquement par task4
- `0:1315` : atteinte uniquement par task4
- `0:1356` : racines du meme module : task4+tbl_0B3D
- `0:139B` : atteinte uniquement par task4
- `0:148A` : racines du meme module : task4+tbl_0B3D
- `0:1498` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:14AC` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:1573` : racines du meme module : task4+tbl_0B3D
- `0:1592` : atteinte uniquement par task4
- `0:15AA` : atteinte uniquement par task4
- `0:15BB` : atteinte uniquement par task4
- `0:1611` : SUPPOSE : non atteinte, rangee avec la fonction precedente

## game/text

- `1:6415` : chargement de la police (banque 9)
- `1:687F` : fenetre de texte (banque 32, $C904/$CBB1)
- `1:68B7` : fenetre de texte (banque 32, $C904/$CBB1)
- `1:68FF` : fenetre de texte (banque 32, $C904/$CBB1)
- `1:6910` : fenetre de texte (banque 32, $C904/$CBB1)

## input/joypad

- `0:042E` : plage fixee dans symbols.json
- `0:047C` : plage fixee dans symbols.json
- `0:1380` : conversion manette -> direction

## screens/debug_menu

- `23:9637` : menu cache (combinaison $B4), appele par la tache 0
- `23:967C` : menu cache (combinaison $B4), appele par la tache 0
- `23:9702` : menu cache (combinaison $B4), appele par la tache 0
- `23:9719` : menu cache (combinaison $B4), appele par la tache 0
- `23:9752` : menu cache (combinaison $B4), appele par la tache 0
- `23:9772` : menu cache (combinaison $B4), appele par la tache 0
- `23:9788` : menu cache (combinaison $B4), appele par la tache 0
- `23:97B4` : menu cache (combinaison $B4), appele par la tache 0
- `23:97CC` : menu cache (combinaison $B4), appele par la tache 0
- `23:97E5` : menu cache (combinaison $B4), appele par la tache 0
- `23:9814` : menu cache (combinaison $B4), appele par la tache 0
- `23:9852` : menu cache (combinaison $B4), appele par la tache 0
- `23:988B` : menu cache (combinaison $B4), appele par la tache 0
- `23:98B0` : menu cache (combinaison $B4), appele par la tache 0
- `23:98C8` : menu cache (combinaison $B4), appele par la tache 0
- `23:98ED` : menu cache (combinaison $B4), appele par la tache 0
- `23:9905` : menu cache (combinaison $B4), appele par la tache 0
- `23:991D` : menu cache (combinaison $B4), appele par la tache 0
- `23:993C` : menu cache (combinaison $B4), appele par la tache 0
- `23:9951` : menu cache (combinaison $B4), appele par la tache 0
- `23:A339` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:A358` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:A3A8` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:A5D0` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:A6FC` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:A72C` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:A860` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:A994` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `23:AAD9` : SUPPOSE : non atteinte, rangee avec la fonction precedente

## screens/pause_menu

- `0:1616` : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
- `0:16DC` : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
- `0:16F8` : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
- `0:170C` : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
- `0:1725` : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
- `0:173E` : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
- `0:174B` : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
- `0:1767` : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
- `0:176E` : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
- `0:1781` : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
- `0:1790` : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
- `0:17A3` : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)

## video/palette

- `1:574C` : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
- `1:57B5` : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
- `1:57BF` : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
- `1:57CA` : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
- `1:57D5` : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
- `1:5805` : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
- `1:58A5` : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
- `1:58AE` : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
- `1:58B7` : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
- `1:58C0` : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
- `1:58C9` : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
- `1:5922` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:594A` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:596E` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5977` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:5980` : SUPPOSE : non atteinte, rangee avec la fonction precedente

## video/sprites

- `1:6C26` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:6C9B` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:6CB2` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:6CC9` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:6D1E` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:6D4B` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:6D4E` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:6E72` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:6F03` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:6F1E` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:6F28` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:6F36` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:6F53` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:6F6A` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:704B` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:7055` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:708A` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:70CB` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:711C` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:718F` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:71BE` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:7235` : moteur de meta-sprites (tampon $C200, tables banques 23/24)
- `1:723D` : moteur de meta-sprites (tampon $C200, tables banques 23/24)

## video/vdp

- `0:047D` : plage fixee dans symbols.json
- `0:049B` : plage fixee dans symbols.json
- `0:04A3` : plage fixee dans symbols.json
- `0:04AB` : plage fixee dans symbols.json
- `0:04AD` : plage fixee dans symbols.json
- `0:04B5` : plage fixee dans symbols.json
- `0:04BD` : plage fixee dans symbols.json
- `0:04C5` : plage fixee dans symbols.json
- `0:04CD` : plage fixee dans symbols.json
- `0:04E7` : plage fixee dans symbols.json
- `0:0A33` : remise a zero ecran (defilement, raster, tampon sprites)
- `0:0A64` : remise a zero ecran (defilement, raster, tampon sprites)
- `0:0A6B` : remise a zero ecran (defilement, raster, tampon sprites)
- `0:0A84` : remise a zero ecran (defilement, raster, tampon sprites)
- `0:0A92` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `0:0AA2` : SUPPOSE : non atteinte, rangee avec la fonction precedente
- `1:400C` : plage fixee dans symbols.json
- `1:4028` : plage fixee dans symbols.json
- `1:402D` : plage fixee dans symbols.json
- `1:402F` : plage fixee dans symbols.json
- `1:4031` : plage fixee dans symbols.json
- `1:4033` : plage fixee dans symbols.json
- `1:404E` : plage fixee dans symbols.json
- `1:405C` : plage fixee dans symbols.json
- `1:407B` : plage fixee dans symbols.json
- `1:427B` : plage fixee dans symbols.json
- `1:433B` : plage fixee dans symbols.json
- `1:437B` : plage fixee dans symbols.json
- `1:43BB` : plage fixee dans symbols.json
- `1:43FB` : plage fixee dans symbols.json
- `1:443B` : plage fixee dans symbols.json
- `1:447B` : plage fixee dans symbols.json
- `1:44BC` : plage fixee dans symbols.json
- `1:44C7` : plage fixee dans symbols.json
- `1:44CA` : plage fixee dans symbols.json
- `1:44D0` : plage fixee dans symbols.json
- `1:44E4` : plage fixee dans symbols.json
- `1:4514` : plage fixee dans symbols.json
- `1:454E` : plage fixee dans symbols.json
- `1:4581` : plage fixee dans symbols.json
- `1:4584` : plage fixee dans symbols.json
- `1:45A8` : plage fixee dans symbols.json
- `1:45CA` : plage fixee dans symbols.json
- `1:45DE` : plage fixee dans symbols.json
- `1:45F9` : plage fixee dans symbols.json
- `1:4607` : plage fixee dans symbols.json
- `1:460D` : plage fixee dans symbols.json
- `1:4616` : plage fixee dans symbols.json
- `1:4619` : plage fixee dans symbols.json
- `1:4625` : plage fixee dans symbols.json
- `1:463C` : plage fixee dans symbols.json
- `1:4667` : plage fixee dans symbols.json
- `1:467E` : plage fixee dans symbols.json
- `1:46A1` : plage fixee dans symbols.json
- `1:46B8` : plage fixee dans symbols.json
- `1:46E3` : plage fixee dans symbols.json
- `1:46FA` : plage fixee dans symbols.json
- `1:4729` : SUPPOSE : non atteinte, rangee avec la fonction precedente
