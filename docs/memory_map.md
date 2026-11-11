# Carte de la RAM ($C000-$DFFF)

Les noms définis sont dans `tools/disasm/symbols.json` (section `ram`) et générés dans
[`src/include/ram.inc`](../src/include/ram.inc). Les autres adresses utilisées y figurent sous
le nom générique `ram_XXXX`. ✅ confirmé · 🔶 supposé.

| Zone | Adresse | Nom | Rôle |
|---|---|---|---|
| Système | `$C000` | — | drapeaux d'état (bit 6 = jeu en pause/attente 🔶, bit 5 testé par `joypad_read`) |
| | `$C001` | — | bit 7 = trame en cours (IRQ) ✅ |
| | `$C002` | — | demandes de transferts VDP pour l'IRQ (bits 0, 4, 5, 6, 7) ✅ |
| | `$C003` | — | drapeaux (bits 5, 6 posés par les tâches 3/4) 🔶 |
| | `$C005` | — | initialisé à 3 au boot 🔶 |
| | `$C006-$C008` | — | options de départ réglées par le menu caché ✅ |
| | `$C010-$C012` | — | pouvoirs, mode de démo (`$C011`), niveau courant (`$C012`) 🔶 |
| | `$C013` | — | mode de jeu ✅ |
| | `$C014` | — | numéro de scène / niveau ✅ |
| Entrées | `$C016` | `joypad_state` | boutons appuyés ✅ |
| | `$C017` | `joypad_pressed` | nouveaux appuis ✅ |
| Vidéo | `$C09B` | — | défilement vertical (→ registre 9) ✅ |
| | `$C0AE` | — | défilement horizontal (→ `$C1BE` → registre 8) ✅ |
| | `$C0B4` | — | copie du registre VDP 1 (affichage on/off) ✅ |
| | `$C0B6-$C0C0` | — | variables de défilement / caméra ✅ |
| | `$C0D3-$C0D9` | — | paramètres temporaires (fondus, pointeurs) ✅ |
| | `$C0E0-$C0FF` | — | palette et effets de couleur (`$C0E4` : 32 entrées) ✅ |
| | `$C189-$C18B` | — | transfert VRAM demandé à l'IRQ ✅ |
| | `$C18F` | — | compte à rebours bloquant le jeu (ex. 50 trames) ✅ |
| | `$C1C4` | — | pointeur de table raster (IRQ de ligne) ✅ |
| | `$C200-$C24F` | — | tampon de sprites et pointeurs (`$C244`, `$C246`) ✅ |
| Scripts | `$C8FF` | — | pointeur de script courant / base des acteurs 🔶 (double usage à éclaircir) |
| | `$C901-$C904` | — | état de l'interpréteur de scènes / texte ✅ |
| | `$CB9F-$CBB4` | — | contexte de l'interpréteur (banques, pointeurs, texte) ✅ |
| Jeu | `$CEEF-$CF1F` | — | structure du joueur (`$CEEF` = état) 🔶 |
| | `$CF27-$D4D1` | — | RAM des entités, effacée au chargement de niveau ✅ |
| | `$D981` | — | tampon de décompression 🔶 |
| Son | `$DE00-$DE0F` | — | commandes et état du driver son ✅ |
| Pile | `$DE00` | — | sommet de pile au boot ✅ |
| Tâches | `$DCA1` | `task_active_mask` | tâches existantes ✅ |
| | `$DCA2` | `task_ready_mask` | tâches prêtes ✅ |
| | `$DCA3` | `task_current` | tâche courante (`$FF` = aucune) ✅ |
| | `$DCA4` | `task_suspended_mask` | tâches suspendues ✅ |
| | `$DCA5-$DCB4` | `task_sp_table` | SP de chaque tâche ✅ |
| | `$DCB5-$DCBC` | `task_wait_table` | trames d'attente ✅ |
| | `$DCBD` | `vdp_status_copy` | statut VDP lu par l'IRQ ✅ |
| Mapper | `$DCBE` | `bank_slot2_shadow` | banque du slot 2 ✅ |
| SMS | `$DFF0` | `sms_pause_flag` | Pause (NMI), SMS uniquement ✅ |

Les accès en `$E0E0` (miroir de `$C0E0`) existent dans le code d'origine.
