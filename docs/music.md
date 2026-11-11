# Musique et effets sonores

✅ Format confirmé : les 26 musiques et 39 effets se décodent et se recompilent **octet pour
octet** (SMS EN et GG JP). Le driver est de type **SMPS 8 bits** (format musical de Sega).

## Fichiers

| Fichier | Rôle |
|---|---|
| `assets/<ver>/music/music.smps` | toutes les musiques et tous les effets (**à éditer**) |
| `tools/assets/music.py` | `extract` (refuse d'écraser sans `FORCE=1`), `build`, `check` |

Le build produit l'area `_B26_4B15` (banque 26, de `$4B15` à la fin) et la banque 27. Les
tables utilisées par le code du driver portent des labels globaux (`music_priorities`,
`music_envelopes`, `music_table_5692`, `music_song_table`, `music_sfx_table`) : les
données peuvent changer de taille.

## Jouer un son

Le jeu écrit un identifiant dans une file que le driver lit à chaque trame (`$408A`) :
`$DE04`, `$DE05` (opcode de script `music`) ou `$DE06` (opcode `sfx`).

| Identifiants | Contenu |
|---|---|
| `$81`-`$9A` | musiques (`song_81` … `song_9A`) |
| `$A0`-`$C6` | effets sonores (`sfx_A0` … `sfx_C6`) |
| `$DB`-`$E1` | commandes : fondu, arrêt, pause… (table `$4164`) |

## Format ✅

- En-tête de musique : `[enveloppes][voies][00][multiplicateur][tempo]` puis, pour chaque
  voie, `[piste][transposition][volume]`.
- En-tête d'effet : `[enveloppes][priorité][voies]` puis, pour chaque voie,
  `[80][canal A0/C0/E0][piste][transposition][volume]`.
- Pistes (RAM `$DE40`, `$DE70`, `$DEA0` = voies PSG, `$DED0` = bruit, `$DF00-$DF60` = effets) :
  - octet `< $80` : durée de la note suivante / précédente ;
  - `$80` : silence ; `$81`-`$E0` : hauteur de note ;
  - `$E1`-`$FF` : drapeaux de coordination.

| Drapeau | Nom | Arguments | Effet |
|---|---|---|---|
| `E1` | `detune` | 1 | désaccord |
| `E2` | `pan_e2` | 1 | 🔶 |
| `E3` | `volume_add` | 1 | volume relatif |
| `E4` | `flag_e4` | 1 | 🔶 |
| `E5` | `volume_set` | 1 | volume absolu |
| `E6` | `tempo` | 1 | tempo |
| `E7` | `hold` | 0 | lie la note suivante |
| `E8` | `modulation` | 4 | vibrato |
| `E9` | `psg_noise` | 1 | mode du canal de bruit |
| `EA` | `envelope` | 1 | enveloppe de volume (table `music_envelopes`) |
| `EB` | `note_fill` | 1 | 🔶 |
| `EC`, `ED` | `flag_ec`, `flag_ed` | 1 | 🔶 |
| `EE` | `transpose` | 1 | transposition relative |
| `EF` | `jump` | label | saut (fin de flot) |
| `F0` | `return` | 0 | retour de sous-piste |
| `F1` | `call` | label | appel de sous-piste |
| `F2` | `stop` | 0 | fin de piste |
| `F3` | `loop_n` | n°, compte, label | boucle sur le compteur n |
| `F4`-`F7` | `loop0`-`loop3` | compte, label | boucle sur les compteurs 0 à 3 |
| `F8` | `break_n` | n°, label | sortie de boucle au dernier tour |
| `F9`-`FC` | `break0`-`break3` | label | idem pour les compteurs 0 à 3 |
| `FD`-`FF` | `flag_fd`-`flag_ff` | 1 | sans effet |

🔶 Les noms marqués sont provisoires : leurs arguments sont confirmés, pas l'effet audible.
Les hauteurs de note (fréquences PSG) sont dans `music_table_5692` 🔶.

## Syntaxe du `.smps`

```
.section 26 0x4B15        ; section = banque + adresse CPU de départ
song_81_ch0:
	envelope 0x04
	modulation 0x14, 0x01, 0x01, 0x04
	notes 0xbd, 0x0c, 0xbc, 0xbd
	jump L_7EF1
```
`notes` et `.db` produisent des octets bruts ; les sections ne doivent pas dépasser leur banque.
