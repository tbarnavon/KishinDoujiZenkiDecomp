;; structs.inc - structures de donnees en RAM (offsets des champs). Ecrit a la main.
;; Utilisation : ld a,ACTOR_TYPE(iy)   ld ACTOR_SCRIPT_LO(iy),e
;; Confirme = lu dans le code (game/actor_script, video/sprites) ; (?) = role suppose.

;; ---- Acteur (ennemi, objet, projectile...) : 40 octets
;; Tableaux d'acteurs : $C8FF (13, tache 2), $CB07 (4), $CBA7 (10), $CDD7 (7), $C8D7 (menu de pause)
ACTOR_SIZE          = 40
ACTOR_TYPE          = 0     ; type d'acteur (index de actor_types), 0 = libre
ACTOR_X_FRAC        = 1     ; (?) partie fractionnaire de x
ACTOR_X             = 2     ; position x (pixels)
ACTOR_X_HI          = 3     ; (?) poids fort de x (non nul = hors ecran)
ACTOR_Y_FRAC        = 4     ; (?) partie fractionnaire de y
ACTOR_Y             = 5     ; position y (pixels)
ACTOR_Y_HI          = 6     ; (?) poids fort de y
ACTOR_ANIM          = 7     ; numero d'animation (meta-sprites, banque 24)
ACTOR_ANIM_TIMER    = 8     ; compteur de trames de l'image courante
ACTOR_ANIM_FRAME    = 9     ; image courante
ACTOR_ANIM_END      = 10    ; 1 = animation terminee
ACTOR_STATE         = 13    ; drapeaux d'etat (bit 6, bit 7, $84)
ACTOR_VX_LO         = 16    ; vitesse x (8.8)
ACTOR_VX_HI         = 17
ACTOR_VY_LO         = 18    ; vitesse y (8.8)
ACTOR_VY_HI         = 19
ACTOR_ANIM_ALT      = 22    ; animation alternative (etat bit 6)
ACTOR_HIT           = 23    ; etat de collision ($FD+ = touche)
ACTOR_LOOP          = 25    ; compteur de boucle du script
ACTOR_DIR           = 26    ; direction 0-7
ACTOR_SCRIPT_LO     = 27    ; pointeur de script (banque 25)
ACTOR_SCRIPT_HI     = 28
ACTOR_RET_LO        = 29    ; adresse de retour (call/return du script)
ACTOR_RET_HI        = 30
ACTOR_OSC_X         = 31    ; parametres d'oscillation
ACTOR_OSC_Y         = 32
ACTOR_DELAY         = 33    ; trames restantes avant l'instruction suivante
ACTOR_FLAGS         = 34    ; drapeaux du script (set_flags / clear_flags)
ACTOR_SAVED_TYPE    = 35    ; type sauvegarde (hide_wait)
ACTOR_PARENT_LO     = 36    ; enregistrement d'apparition / parent
ACTOR_PARENT_HI     = 37
ACTOR_COUNTER       = 38    ; compteur (if_lt_38)
