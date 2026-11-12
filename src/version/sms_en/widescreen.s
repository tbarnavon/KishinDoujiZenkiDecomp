;; src/version/sms_en/widescreen.s
;; Vue elargie (option de build WIDE=1) : le decor est dessine sur tout l'ecran SMS
;; (256x192) au lieu de la seule fenetre GG (160x144 au centre).
;; Ecrit a la main (ne provient pas du desassemblage). Voir docs/widescreen.md.
;;
;; Principe : la camera du jeu n'est pas modifiee. Le monde visible dans la fenetre GG
;; est [cam, cam+160) x [camy, camy+144), affiche aux pixels (48..207, 24..167).
;; L'ecran SMS montre donc [cam-48, cam+208) x [camy-24, camy+168) ; la colonne 0 est
;; masquee par le VDP (registre 0 bit 5), il reste 248 pixels utiles.
;;
;; Le tilemap (32 x 28 tuiles) sert d'anneau :
;;   - colonne de tuile du monde tx  -> colonne (6 + tx) & 31
;;   - rangee de metatuile du monde m -> rangees (3 + 2m) mod 28 et suivante
;; L'anneau contient les colonnes [T0, T0+32) avec T0 = floor((cam-40)/8)
;; et les rangees de metatuiles [k, k+14) avec k = floor((camy-24)/16).
;; Hors de la carte, une tuile noire est dessinee (tuile $1FA, mot $09FA : sans priorite,
;; pour laisser voir le HUD et les sprites). wide_boss (banque 63) ecrit cette tuile en VRAM.
;;
;; Ce code est en banque 10 (celle des metatuiles) : il est appele avec la banque 10
;; dans le slot 2, et lit la carte en RAM (level_map).

	.include "hardware.inc"
	.include "ram.inc"
	.include "version.inc"

.if WIDESCREEN
	.area _B10_WIDE

;; variables de travail : debut du tampon de dessin du moteur (inutilise ici)
wv_tx   = util_D4D1 + 0     ; colonne de tuile courante (16 bits signe)
wv_m    = util_D4D1 + 2     ; rangee de metatuile courante (16 bits signe)
wv_h    = util_D4D1 + 4     ; hauteur de la carte (metatuiles)
wv_cnt  = util_D4D1 + 5     ; compteur de boucle
wv_ptr  = util_D4D1 + 6     ; debut de rangee dans la carte
wv_hx   = util_D4D1 + 8     ; demi-colonne de la metatuile (0 ou 2 octets)
wv_col2 = util_D4D1 + 9     ; colonne de l'anneau * 2
wv_t0   = util_D4D1 + 10    ; T0 ou k (16 bits signe)
wv_mcol = util_D4D1 + 12    ; colonne de carte bornee (16 bits)
wv_vaddr = util_D4D1 + 14   ; commande d'ecriture VRAM courante (16 bits)
wv_out  = util_D4D1 + 16    ; non nul : colonne (w_col) ou rangee (w_row) hors de la carte

;; mots de la metatuile noire (hors de la carte) : tuile $1FA, palette des sprites
;; (couleur 18 = noir), sans priorite
w_black:
	.dw 0x09FA, 0x09FA, 0x09FA, 0x09FA

;; ------------------------------------------------------------------
;; Redessine tout l'anneau (remplace sub_48DA : chargement de niveau, evenements)
wide_full::
	call w_k                        ; HL = k
	ld b,#14
wf_loop:
	push bc
	push hl
	call w_row
	pop hl
	inc hl
	pop bc
	djnz wf_loop
	ld a,(scroll_x)                 ; derniers defilements traites
	ld (scroll_C1B4),a
	ld a,(scroll_y)
	ld (scroll_C1B5),a
	ret

;; ------------------------------------------------------------------
;; Defilement horizontal : dessine les colonnes de tuiles entrees dans l'anneau.
;; scroll_C1B4 = octet bas de scroll_x lors du dernier appel.
wide_hscroll::
	ld a,(scroll_C1B4)
	ld b,a
	ld a,(scroll_x)
	ld (scroll_C1B4),a
	sub b                           ; scroll_x = -cam : dcam = ancien - nouveau
	neg
	push af                         ; dcam (signe, 8 bits)
	call w_cam
	ld de,#-40
	add hl,de                       ; cam - 40
	push hl
	call w_sra3
	ld (wv_t0),hl                   ; T0 nouveau
	pop hl
	pop af
	ld e,a
	ld d,#0
	bit 7,a
	jr z,wh_pos
	dec d
wh_pos:
	or a
	sbc hl,de                       ; ancien cam - 40
	call w_sra3                     ; T0 ancien
	ex de,hl
	ld hl,(wv_t0)
	or a
	sbc hl,de                       ; n = T0 nouveau - T0 ancien
	ld c,#32
	jr w_span

;; w_span : HL = n = nouveau - ancien debut de l'anneau, (wv_t0) = nouveau debut,
;; C = taille de l'anneau : 32 colonnes (w_col) ou 14 rangees (w_row)
;; -> dessine les colonnes ou rangees entrees dans l'anneau (toutes si |n| >= C)
;; Attention : les piles des taches ne font que 64 octets ; pas de profondeur de pile en plus
;; de l'original (push bc, push hl, call).
w_span:
	ld a,h
	or l
	ret z
	bit 7,h
	jr nz,wsp_neg
	ld a,h                          ; vers la droite / le bas : debut + C - n .. debut + C - 1
	or a
	jr nz,wsp_all
	ld a,l
	cp c
	jr nc,wsp_all
	ld b,a
	ld hl,(wv_t0)
	ld e,c
	ld d,#0
	add hl,de
	ld e,b
	or a
	sbc hl,de
	jr wsp_loop
wsp_neg:                            ; vers la gauche / le haut : debut .. debut + |n| - 1
	ld a,h
	inc a
	jr nz,wsp_all
	sub l                           ; A = 0 - l = |n|
	cp c
	jr nc,wsp_all
	ld b,a
	jr wsp_t0
wsp_all:
	ld b,c
wsp_t0:
	ld hl,(wv_t0)
wsp_loop:
	push bc
	push hl
	ld a,c
	cp #32
	jr z,wsp_col
	call w_row
	jr wsp_next
wsp_col:
	call w_col
wsp_next:
	pop hl
	inc hl
	pop bc
	djnz wsp_loop
	ret

;; ------------------------------------------------------------------
;; Defilement vertical : dessine les rangees de metatuiles entrees dans l'anneau.
;; scroll_y = page:octet (valeur = page*224 + octet) ; scroll_C1B5 = octet du dernier appel.
wide_vscroll::
	ld a,(scroll_C1B5)
	ld e,a
	ld d,#0
	ld a,(scroll_y)
	ld (scroll_C1B5),a
	ld l,a
	ld h,#0
	or a
	sbc hl,de                       ; nouveau - ancien, ramene dans [-112, 112]
	push hl
	ld de,#-113
	add hl,de
	bit 7,h
	pop hl
	jr nz,wv_notbig
	ld de,#-224
	add hl,de
	jr wv_delta
wv_notbig:
	push hl
	ld de,#113
	add hl,de
	bit 7,h
	pop hl
	jr z,wv_delta
	ld de,#224
	add hl,de
wv_delta:
	ld (wv_m),hl                    ; dcamy
	call w_k
	ld (wv_t0),hl                   ; k nouveau
	ld hl,(scroll_y)
	call w_abs224
	ld de,(wv_m)
	or a
	sbc hl,de                       ; ancien camy
	ld de,#-24
	add hl,de
	call w_sra4                     ; k ancien
	ex de,hl
	ld hl,(wv_t0)
	or a
	sbc hl,de                       ; n = k nouveau - k ancien
	ld c,#14
	jp w_span

;; ------------------------------------------------------------------
;; w_col : HL = colonne de tuile du monde (signe) -> dessine ses 14 metatuiles de l'anneau
;; (pointeur de carte et adresse VRAM avances de rangee en rangee)
w_col::
	ld a,l
	and #1
	add a,a
	ld (wv_hx),a                    ; demi-colonne : 0 ou 2 (octets dans la metatuile)
	ld a,l
	add a,#6
	and #31
	add a,a
	ld (wv_col2),a
	sra h
	rr l                            ; colonne de metatuile
	ld a,(level_CF18)
	call w_clamp
	ld (wv_mcol),hl
	sbc a,a                         ; colonne hors de la carte -> $FF
	ld (wv_out),a
	call w_k                        ; HL = k (rangee du haut de l'anneau)
	ld (wv_m),hl
	call w_slot                     ; A = rangee de l'anneau
	ld c,a
	ld a,(wv_col2)
	ld b,a
	ld a,c
	call w_addr
	ld (wv_vaddr),de
	ld hl,(wv_m)
	ld a,(wv_h)
	call w_clamp
	call w_rowptr
	ld de,(wv_mcol)
	add hl,de
	ld (wv_ptr),hl
	ld a,#14
	ld (wv_cnt),a
wc_loop:
	ld a,(wv_out)                   ; hors de la carte (colonne, ou m < 0, ou m >= H) : noir
	or a
	jr nz,wc_blk
	ld hl,(wv_m)
	ld a,(wv_h)
	call w_clamp
	jr nc,wc_map
wc_blk:
	ld hl,#w_black
	jr wc_draw
wc_map:
	ld hl,(wv_ptr)
	ld a,(hl)
	call w_meta2
wc_draw:
	ld de,(wv_vaddr)
	call w_vput                     ; haut
	inc hl
	inc hl
	inc hl
	call w_nextrow
	call w_vput                     ; bas
	call w_nextrow
	ld (wv_vaddr),de
	ld hl,(wv_m)                    ; rangee suivante de la carte si 0 <= m < H-1
	bit 7,h
	jr nz,wc_same
	ld a,(wv_h)
	dec a
	ld e,a
	ld d,#0
	or a
	sbc hl,de
	jr nc,wc_same
	ld hl,(wv_ptr)
	ld a,(level_CF18)
	ld e,a
	ld d,#0
	add hl,de
	ld (wv_ptr),hl
wc_same:
	ld hl,(wv_m)
	inc hl
	ld (wv_m),hl
	ld hl,#wv_cnt
	dec (hl)
	jr nz,wc_loop
	ret

;; w_row : HL = rangee de metatuile du monde (signe) -> dessine ses 32 colonnes de tuiles
w_row::
	ld (wv_m),hl
	call w_slot
	ld b,#0
	call w_addr
	ld (wv_vaddr),de                ; debut de la rangee du haut (colonne 0)
	call w_k                        ; (met a jour wv_h)
	ld hl,(wv_m)
	ld a,(wv_h)
	call w_clamp
	sbc a,a                         ; rangee hors de la carte -> $FF
	ld (wv_out),a
	call w_rowptr
	ld (wv_ptr),hl
	call w_cam
	ld de,#-40
	add hl,de
	call w_sra3                     ; T0
	ld (wv_tx),hl
	ld a,#32
	ld (wv_cnt),a
;; une metatuile par tour : 2 colonnes de tuiles (1 seule si on commence par sa moitie droite
;; ou s'il ne reste qu'une colonne). Une colonne de tuile paire est toujours a une colonne
;; paire de l'anneau : les 2 mots d'une metatuile ne chevauchent jamais le bord de l'anneau.
wr_loop:
	ld hl,(wv_tx)
	ld a,l
	and #1
	add a,a
	ld (wv_hx),a                    ; 0 = moitie gauche, 2 = moitie droite
	ld b,#1
	jr nz,wr_count
	ld a,(wv_cnt)
	cp #2
	jr c,wr_count
	ld b,#2
wr_count:
	push bc
	sra h
	rr l
	ld a,(level_CF18)
	call w_clamp
	jr c,wr_blk                     ; colonne hors de la carte : noir
	ld a,(wv_out)
	or a
	jr nz,wr_blk                    ; rangee hors de la carte : noir
	ld de,(wv_ptr)
	add hl,de
	ld a,(hl)
	call w_meta2                    ; HL -> premier mot (rangee du haut)
	jr wr_draw
wr_blk:
	ld hl,#w_black
wr_draw:
	ld a,(wv_tx)
	add a,#6
	and #31
	add a,a
	ld de,(wv_vaddr)
	or e
	ld e,a
	pop bc
	push bc
	call w_seg
	pop bc
	ld hl,(wv_tx)
	ld e,b
	ld d,#0
	add hl,de
	ld (wv_tx),hl
	ld a,(wv_cnt)
	sub b
	ld (wv_cnt),a
	jr nz,wr_loop
	ret

;; w_seg : HL -> premier mot (rangee du haut de la metatuile), DE = adresse VRAM,
;; B = nombre de mots consecutifs (1 ou 2) ; ecrit aussi les mots du bas (HL+4) a DE+64.
w_seg:
	push hl
	push de
	call w_segrow
	pop de
	pop hl
	inc hl
	inc hl
	inc hl
	inc hl
	call w_nextrow
w_segrow:
	ld c,b
	di
	ld a,e
	out (VDP_CTRL),a
	ld a,d
	out (VDP_CTRL),a
wsr_loop:
	ld a,(hl)
	out (VDP_DATA),a
	inc hl
	ld a,(hl)
	inc hl
	nop                             ; >= 26 cycles entre deux ecritures VRAM
	out (VDP_DATA),a
	dec c
	jr nz,wsr_loop
	ei
	ret

;; w_nextrow : DE = commande d'ecriture VRAM -> meme colonne, rangee suivante de l'anneau
w_nextrow::
	ld a,e
	add a,#0x40
	ld e,a
	ret nc
	inc d
	ld a,d
	cp #0x7f
	ret nz
	ld d,#0x78
	ret

;; w_vput : DE = commande VDP d'ecriture, HL -> mot (2 octets) ; HL avance d'un octet
w_vput:
	di
	ld a,e
	out (VDP_CTRL),a
	ld a,d
	out (VDP_CTRL),a
	ld a,(hl)
	out (VDP_DATA),a
	inc hl
	ld a,(hl)
	push af
	pop af
	out (VDP_DATA),a
	ei
	ret

;; w_addr : A = rangee de l'anneau, B = colonne*2 -> DE = commande d'ecriture VRAM
w_addr:
	push hl
	ld l,a
	ld h,#0
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld a,l
	or b
	ld e,a
	ld a,h
	or #0x78
	ld d,a
	pop hl
	ret

;; w_meta2 : A = indice de metatuile -> HL = mot du haut de la demi-colonne wv_hx
w_meta2:
	ld l,a
	ld h,#0
	add hl,hl
	add hl,hl
	add hl,hl
	ld de,(level_metatile_ptr)
	add hl,de
	ld a,(wv_hx)
	ld e,a
	ld d,#0
	add hl,de
	ret

;; w_rowptr : HL = rangee (bornee) -> HL = level_map + rangee * largeur
w_rowptr::
	ex de,hl
	ld hl,#level_map
	ld a,(level_CF18)
	ld c,a
	ld b,#0
	ld a,e
	or a
	ret z
wrp_loop:
	add hl,bc
	dec a
	jr nz,wrp_loop
	ret

;; w_clamp : HL signe, A = N -> HL borne dans [0, N-1] ; C = 1 si HL etait hors de [0, N)
w_clamp:
	bit 7,h
	jr nz,wcl_zero
	ld e,a
	ld d,#0
	or a
	sbc hl,de
	jr nc,wcl_max
	add hl,de
	or a
	ret
wcl_zero:
	ld hl,#0
	scf
	ret
wcl_max:
	ld l,a
	ld h,#0
	dec hl
	scf
	ret

;; w_slot : HL = rangee de metatuile (signe) -> A = rangee de l'anneau (3 + 2m) mod 28
w_slot:
	ld de,#14
	bit 7,h
	jr z,ws_pos
ws_neg:
	add hl,de
	bit 7,h
	jr nz,ws_neg
ws_pos:
	or a
	sbc hl,de
	jr nc,ws_pos
	add hl,de
	ld a,l
	add a,a
	add a,#3
	cp #28
	ret c
	sub #28
	ret

;; w_k : HL = k = floor((camy - 24) / 16) ; met aussi a jour wv_h (hauteur de la carte)
w_k:
	ld hl,(level_C19C)              ; defilement vertical maximal = hauteur*16 - 144
	call w_abs224
	ld de,#144
	add hl,de
	call w_sra4
	ld a,l
	ld (wv_h),a
	ld hl,(scroll_y)
	call w_abs224
	ld de,#-24
	add hl,de
	; (enchaine sur w_sra4)

w_sra4:
	sra h
	rr l
w_sra3:
	sra h
	rr l
	sra h
	rr l
	sra h
	rr l
	ret

;; w_abs224 : HL = page:octet -> HL = page*224 + octet
w_abs224:
	ld a,h
	ld h,#0
	or a
	ret z
	ld b,a
	ld de,#224
wa_loop:
	add hl,de
	djnz wa_loop
	ret

;; w_cam : HL = cam = -scroll_x
w_cam:
	ld de,(scroll_x)
	xor a
	ld l,a
	ld h,a
	sbc hl,de
	ret

.endif

;; ==================================================================
;; Ecrans fixes de boss (game_mode = 3, carte de 10 x 9 metatuiles au plus) : pas de vue
;; elargie, tout ce qui est hors de la carte est rempli d'une tuile noire.
;; Banque 63 (libre) : appele par sub_48DA avec la banque 63 dans le slot 2.
;;
;; Tuile noire : tuile $1FA (VRAM $3F40, trou inutilise de la table des sprites entre les Y
;; et les X/tuiles), entierement de couleur 2 ; affichee avec la palette des sprites
;; (couleur 18 = noir dans les combats de boss) et la priorite (elle cache aussi les sprites
;; qui depassent de la fenetre). Mot du tilemap : $19FA.
;; Les bandes que le jeu redessine ensuite sur toute la largeur (parallaxe) restent visibles.
.if WIDESCREEN
.if ROM512
	.area _B17_WIDE                 ; ROM512 : banque 17 en $BF00 (tools/assets/rom512.py)
.else
	.area _B63_WIDE
.endif

wide_boss::
	di                              ; adresse VDP : pas d'IRQ pendant le remplissage
	ld de,#0x7f40                   ; VRAM $3F40 en ecriture
	call wb_addr
	ld b,#8
wb_tile:
	xor a                           ; plans 0, 1, 2, 3 = 00 FF 00 00 : couleur 2
	call wb_put
	dec a
	call wb_put
	inc a
	call wb_put
	call wb_put
	djnz wb_tile
	ld a,(game_mode)                ; ecran fixe de boss : mode 3, carte de 10 x 9 au plus
	cp #0x03
	jr nz,wb_end
	ld a,(level_CF18)
	cp #11
	jr nc,wb_end
	ld hl,(level_C19C)
	ld a,h
	or l
	jr nz,wb_end
	ld a,(level_CF18)
	add a,a
	add a,#6
	ld c,a                          ; colonne de l'anneau juste apres la carte
	ld de,#0x7800
	ld b,#28
wb_row:
	push bc
	ld a,#28
	sub b                           ; numero de rangee de l'anneau
	ld hl,#0x19fa                   ; tuile noire prioritaire
	cp #3
	jr c,wb_full
	cp #21                          ; carte : rangees 3 a 20
	jr nc,wb_full
	push hl                         ; mot des colonnes C-31
	cp #9                           ; boss de l'intro (scene $07), rangee 9 (lignes 72-79) :
	jr nz,wb_sides                  ; la ligne 72 est encore affichee avec le defilement des
	ld a,(scene_id)                 ; nuages (retour au defilement normal un peu tard) : du
	cp #0x07                        ; noir y glisserait dans la fenetre. Les bords reprennent
	jr nz,wb_sides                  ; la tuile du bord de la fenetre (ciel).
	pop hl
	ld a,c
	dec a
	add a,a
	call wb_rd                      ; mot de la colonne C-1
	push hl
	ld a,#12
	call wb_rd                      ; mot de la colonne 6
wb_sides:
	call wb_addr                    ; rangee de la carte : colonnes 0-5 ...
	ld b,#6
	call wb_fill
	pop hl
	push de
	ld a,c
	add a,a
	or e
	ld e,a
	call wb_addr                    ; ... et colonnes C-31
	pop de
	ld a,#32
	sub c
	ld b,a
	call wb_fill
	jr wb_next
wb_full:
	call wb_addr
	ld b,#32
	call wb_fill
wb_next:
	ld a,e
	add a,#0x40
	ld e,a
	jr nc,wb_nc
	inc d
wb_nc:
	pop bc
	djnz wb_row
wb_end:
	ei
	ret

wb_fill:                            ; B mots HL
	ld a,l
	call wb_put
	ld a,h
	call wb_put
	djnz wb_fill
	ret

;; wb_rd : DE = commande d'ecriture du debut de la rangee, A = colonne * 2 -> HL = mot du tilemap
wb_rd:
	or e
	out (VDP_CTRL),a
	ld a,d
	and #0x3f                       ; commande de lecture
	out (VDP_CTRL),a
	push af                         ; delais (>= 26 cycles entre deux acces VRAM)
	pop af
	in a,(VDP_DATA)
	ld l,a
	push af
	pop af
	in a,(VDP_DATA)
	ld h,a
	ret

wb_addr:                            ; DE = commande d'ecriture VRAM
	ld a,e
	out (VDP_CTRL),a
	ld a,d
	out (VDP_CTRL),a
	ret

wb_put:                             ; (l'appel espace les ecritures de plus de 26 cycles)
	out (VDP_DATA),a
	ret
.endif
