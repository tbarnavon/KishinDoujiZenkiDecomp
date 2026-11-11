;; audio/sound_api.s
;; Interface avec le driver son : commandes $DE04-$DE0B, initialisation.
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $004FB
;; classement : ecrit les commandes du driver son ($DE04-$DE0B)
	.area _B00_04FB
sub_04FB::
	ld a,#0xbb                      ; 04FB
	jp loc_060D                     ; 04FD

;; ---------------------------------------------------------------- $00546
;; classement : ecrit les commandes du driver son ($DE04-$DE0B)
	.area _B00_0546
sub_0546::
	ld a,(player_CEFC)                 ; 0546
	and #0x84                       ; 0549
	ret nz                          ; 054B
	ld a,#0xa3                      ; 054C
	jp loc_0627                     ; 054E

;; ---------------------------------------------------------------- $00551
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0551
sub_0551::
	ld a,#0xa0                      ; 0551
	jp loc_060D                     ; 0553

;; ---------------------------------------------------------------- $00556
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0556
sub_0556::
	ld a,#0xa1                      ; 0556
	jp loc_060D                     ; 0558

;; ---------------------------------------------------------------- $0059F
;; classement : ecrit les commandes du driver son ($DE04-$DE0B)
	.area _B00_059F
sub_059F::
	ld a,#0x0c                      ; 059F
	ld (snd_DE09),a                 ; 05A1
	ld a,#0x03                      ; 05A4
	ld (snd_DE0A),a                 ; 05A6
	ld (snd_DE0B),a                 ; 05A9
	ret                             ; 05AC

;; ---------------------------------------------------------------- $005DD
;; classement : plage symbols.json
	.area _B00_05DD
sound_init::
	di                              ; 05DD
	ld a,#0x1a                      ; 05DE
	ld (MAPPER_SLOT1),a             ; 05E0  mapper : banque du slot 1 ($4000-$7FFF)
.if ROM512
	ld a,#0x18                      ; 05E3  ROM512 : musique en banque 24 (ex-banque 27)
.else
	ld a,#0x1b                      ; 05E3
.endif
	ld (MAPPER_SLOT2),a             ; 05E5  mapper : banque du slot 2 ($8000-$BFFF)
	call sub_b26_44A9               ; 05E8
	ld a,#0x01                      ; 05EB
	ld (MAPPER_SLOT1),a             ; 05ED  mapper : banque du slot 1 ($4000-$7FFF)
	ld a,(bank_slot2_shadow)        ; 05F0
	ld (MAPPER_SLOT2),a             ; 05F3  mapper : banque du slot 2 ($8000-$BFFF)
	ei                              ; 05F6
	ret                             ; 05F7

;; ---------------------------------------------------------------- $005F8
;; classement : ecrit les commandes du driver son ($DE04-$DE0B)
	.area _B00_05F8
sub_05F8::
	ld a,#0x01                      ; 05F8
	ld (snd_DE08),a                 ; 05FA
	ret                             ; 05FD

;; ---------------------------------------------------------------- $00608
;; classement : ecrit les commandes du driver son ($DE04-$DE0B)
	.area _B00_0608
sub_0608::
	xor a                           ; 0608
	ld (snd_DE08),a                 ; 0609
	ret                             ; 060C
loc_060D::
	ld (snd_queue_music),a          ; 060D
	ret                             ; 0610

;; ---------------------------------------------------------------- $00611
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0611
sub_0611::
	ld hl,(player_CF25)                ; 0611
	ld h,#0x00                      ; 0614
	ld de,#sub_061D                 ; 0616
	add hl,de                       ; 0619
	ld a,(hl)                       ; 061A
	jr loc_060D                     ; 061B

;; ---------------------------------------------------------------- $0061D
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_061D
sub_061D:
	and d                           ; 061D
	and h                           ; 061E
	and h                           ; 061F
	cp c                            ; 0620
	and h                           ; 0621
	cp c                            ; 0622
	and d                           ; 0623
	and d                           ; 0624
	and h                           ; 0625
	and d                           ; 0626
loc_0627::
	ld (snd_queue_sfx),a            ; 0627
	ret                             ; 062A
	.db 0x3e, 0x97                  ; 062B

;; ---------------------------------------------------------------- $0062D
;; classement : ecrit les commandes du driver son ($DE04-$DE0B)
	.area _B00_062D
sub_062D::
	push af                         ; 062D
	call sound_init                 ; 062E
	pop af                          ; 0631
	ld (level_C1F3),a                 ; 0632
	ld (snd_queue_0),a              ; 0635
	ret                             ; 0638
