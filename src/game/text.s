;; game/text.s
;; Texte : police (banque 9), fenetre et affichage des chaines (banques 32/33 en EN).
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $06415
;; classement : chargement de la police (banque 9)
	.area _B01_6415
sub_6415::
	ld de,#VDP_VRAM_WRITE|0x23e0    ; 6415
	ld hl,#data_b23_B14F            ; 6418
	ld a,#0x09                      ; 641B
	ld (bank_slot2_shadow),a        ; 641D
	ld (MAPPER_SLOT2),a             ; 6420  mapper : banque du slot 2 ($8000-$BFFF)
	call sub_46A1                   ; 6423
	ret                             ; 6426

;; ---------------------------------------------------------------- $068B7
;; classement : fenetre de texte (banque 32, $C904/$CBB1)
	.area _B01_68B7
sub_68B7::
	ld a,(text_CBB3)                 ; 68B7
	or a                            ; 68BA
	ret z                           ; 68BB
	dec a                           ; 68BC
	ld (text_CBB3),a                 ; 68BD
	ret nz                          ; 68C0
	ld a,(text_CBB4)                 ; 68C1
	ld (text_CBB3),a                 ; 68C4
.if VERSION_SMS_EN
	ld a,#0x20                      ; 68C7
.else ; VERSION_GG_JP
	ld a,#0x1c                      ; 68C7
.endif
	ld (bank_slot2_shadow),a        ; 68C9
	ld (MAPPER_SLOT2),a             ; 68CC  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(text_ptr)                ; 68CF
loc_68D2:
	ld a,(hl)                       ; 68D2
	or a                            ; 68D3
	jr nz,loc_68DD                  ; 68D4
	ld (text_CBB3),a                 ; 68D6
	ld (text_CBB4),a                 ; 68D9
	ret                             ; 68DC
loc_68DD:
	ld de,(text_CBB1)                ; 68DD
	inc hl                          ; 68E1
	ld (text_ptr),hl                ; 68E2
	cp #0x0d                        ; 68E5
	jr nz,loc_68F2                  ; 68E7
.if VERSION_SMS_EN
	call sub_68FF                   ; 68E9
.else ; VERSION_GG_JP
	ld de,#sub_7BCE                 ; 68E9
.endif
	ld (text_CBB1),de                ; 68EC
	jr loc_68D2                     ; 68F0
loc_68F2:
	inc de                          ; 68F2
	inc de                          ; 68F3
	ld (text_CBB1),de                ; 68F4
	cp #0x1f                        ; 68F8
	jr z,loc_68D2                   ; 68FA
.if VERSION_SMS_EN
	jp sub_6910                     ; 68FC
.else ; VERSION_GG_JP
	call sub_6910                   ; 68FC
.endif

;; ---------------------------------------------------------------- $068FF
;; classement : fenetre de texte (banque 32, $C904/$CBB1)
	.area _B01_68FF
.if VERSION_SMS_EN
sub_68FF:
	ld a,#0x8c                      ; 68FF
	cp e                            ; 6901
	jr c,loc_6906                   ; 6902
loc_6904:
	ld e,a                          ; 6904
	ret                             ; 6905
loc_6906:
	ld a,#0xcc                      ; 6906
	cp e                            ; 6908
	jr nc,loc_6904                  ; 6909
	ld de,#data_7C0C                ; 690B
	ret                             ; 690E
	.db 0xeb                        ; 690F
.else ; VERSION_GG_JP
sub_68FF:
	ld a,(hl)                       ; 68FF
	cp #0xbe                        ; 6900
	jr z,loc_6907                   ; 6902
loc_6904:
	cp #0xbf                        ; 6904
loc_6906:
	ret nz                          ; 6906
loc_6907:
	inc hl                          ; 6907
	ld (text_ptr),hl                ; 6908
	ld hl,#text_FFC0                 ; 690B
	add hl,de                       ; 690E
	ex de,hl                        ; 690F
.endif

;; ---------------------------------------------------------------- $06910
;; classement : fenetre de texte (banque 32, $C904/$CBB1)
	.area _B01_6910
sub_6910::
	push af                         ; 6910
	di                              ; 6911
	rst 0x10                        ; 6912  VDP : adresse/commande = de
	push ix                         ; 6913
	pop ix                          ; 6915
	pop af                          ; 6917
	out (VDP_DATA),a                ; 6918  VDP : donnee VRAM/CRAM
	push ix                         ; 691A
	pop ix                          ; 691C
	ld a,#0x11                      ; 691E
	out (VDP_DATA),a                ; 6920  VDP : donnee VRAM/CRAM
	ei                              ; 6922
	ret                             ; 6923
loc_6924::
	pop hl                          ; 6924
	ld e,(hl)                       ; 6925
	inc hl                          ; 6926
	ld d,(hl)                       ; 6927
	inc hl                          ; 6928
	ld a,(hl)                       ; 6929
	inc hl                          ; 692A
	ld (scene_script_ptr),hl        ; 692B
	push de                         ; 692E
	pop iy                          ; 692F
	ld 9(iy),#0x00                  ; 6931
	ld 8(iy),#0x00                  ; 6935
	ld 10(iy),#0x00                 ; 6939
	call sub_6998                   ; 693D
	ld 7(iy),a                      ; 6940
	ld 0(iy),a                      ; 6943
	ld 34(iy),b                     ; 6946
	or a                            ; 6949
	call z,sub_44BC                 ; 694A
	xor a                           ; 694D
	ld 15(iy),a                     ; 694E
	ld 21(iy),a                     ; 6951
	ret                             ; 6954
loc_6955::
	pop hl                          ; 6955
	ld e,(hl)                       ; 6956
	inc hl                          ; 6957
	ld d,(hl)                       ; 6958
	inc hl                          ; 6959
	push de                         ; 695A
	pop iy                          ; 695B
	ld 9(iy),#0x00                  ; 695D
	ld 8(iy),#0x00                  ; 6961
	ld 10(iy),#0x00                 ; 6965
	ld a,(hl)                       ; 6969
	inc hl                          ; 696A
	ld 2(iy),a                      ; 696B
	ld a,(hl)                       ; 696E
	inc hl                          ; 696F
	ld 5(iy),a                      ; 6970
	ld a,(hl)                       ; 6973
	inc hl                          ; 6974
	call sub_6998                   ; 6975
	ld 7(iy),a                      ; 6978
	ld 0(iy),a                      ; 697B
	ld 34(iy),b                     ; 697E
	xor a                           ; 6981
	ld 16(iy),a                     ; 6982
	ld 17(iy),a                     ; 6985
	ld 18(iy),a                     ; 6988
	ld 19(iy),a                     ; 698B
	ld 15(iy),a                     ; 698E
	ld 21(iy),a                     ; 6991
	ld (scene_script_ptr),hl        ; 6994
	ret                             ; 6997
