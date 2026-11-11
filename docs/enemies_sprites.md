# Ennemis (placement) et méta-sprites

## Placement des ennemis ✅ (banque 4)

✅ 43 listes, 249 ennemis ; recompilation identique.

- Le mot en `$8006` (banque 4) pointe vers une table indexée par le niveau (`$C014`) ;
  chaque entrée pointe vers `[longueur]` + enregistrements de 6 octets + `$FF` :
  `[type d'acteur][x sur 16 bits][y sur 16 bits][drapeaux]`.
- Au début du niveau, `$3606` copie la liste en RAM `$C7FB`. À chaque trame, `$3A9E`
  fait apparaître l'acteur quand sa position entre dans l'écran (défilement `$C0AE`), puis
  met le bit 7 des drapeaux (« déjà apparu »). Le type indexe la table `actor_types` des
  scripts d'acteurs ([actor_scripts.md](actor_scripts.md)).
- 🔶 Repère des coordonnées à confirmer en jeu (certaines valeurs dépassent la taille de la carte).

Fichiers : `assets/sms_en/enemies/list_AAAA.csv` (une ligne = `type,x,y,drapeaux`, type et
drapeaux en hexadécimal, x et y en décimal) + `enemies.json`. **Nombre d'ennemis fixe** par
liste ; outil `tools/assets/enemies.py`.

## Méta-sprites ✅ (banque 24)

✅ 383 entrées, 355 animations, 140 dispositions ; recompilation identique.

- Moteur `$6D4E` (`video/sprites`). Le numéro d'animation est le champ 7 de l'acteur
  (instruction `set_anim` des scripts d'acteurs).
- Tables `$81FA` (255 entrées) et `$9ECF` (128 entrées, utilisée si le bit 7 du champ 34 est
  mis) : `[animation][disposition]`.
- Animation : `[délai][dernière image][image de reprise][morceaux]` puis, pour chaque image,
  un numéro de tuile par morceau (`255` = morceau absent).
- Disposition : un couple `[dx, dy]` (signés) par morceau, ajouté à la position de l'acteur.

Fichier : `assets/sms_en/sprites/sprites.json` (`tables`, `animations`, `layouts`).
**Nombres d'images et de morceaux fixes** ; outil `tools/assets/sprites.py`.
🔶 Pas encore d'aperçu PNG (les tuiles de sprites dépendent du niveau chargé).
