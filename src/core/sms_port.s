;; core/sms_port.s
;; Code ajoute par le portage GG2SMS (conversion de palette, pause...).
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $07F94
;; classement : plage symbols.json
	.area _B01_7F94
.if VERSION_SMS_EN
sub_7F94:
	ld a,#0x01                      ; 7F94
	ld (MAPPER_SLOT2),a             ; 7F96  mapper : banque du slot 2 ($8000-$BFFF)
	jp loc_7FCD+0x4000              ; 7F99
loc_7F9C:
	call sub_6337                   ; 7F9C
	call sub_44BC                   ; 7F9F
loc_7FA2:
	ret                             ; 7FA2
loc_7FA3::
	ld bc,#0x20be                   ; 7FA3
loc_7FA6:
	ld a,(hl)                       ; 7FA6
.else ; VERSION_GG_JP
sub_7F94:
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 7F94
loc_7F9C:
	.db 0x00, 0x00, 0x00, 0x00      ; 7F9C
	.db 0x00, 0x00                  ; 7FA0
loc_7FA2:
	.db 0x00                        ; 7FA2
loc_7FA3::
	.db 0x00, 0x00, 0x00            ; 7FA3
loc_7FA6:
	.db 0x00                        ; 7FA6
.endif

;; ---------------------------------------------------------------- $07FA7
;; classement : plage symbols.json
	.area _B01_7FA7
.if VERSION_SMS_EN
sub_7FA7:
	inc hl                          ; 7FA7
	inc de                          ; 7FA8
	srl a                           ; 7FA9
	srl a                           ; 7FAB
	and #0x33                       ; 7FAD
	ld d,a                          ; 7FAF
	srl a                           ; 7FB0
	srl a                           ; 7FB2
	or d                            ; 7FB4
	and #0x0f                       ; 7FB5
	ld d,a                          ; 7FB7
	ld a,(hl)                       ; 7FB8
	inc hl                          ; 7FB9
	inc de                          ; 7FBA
	and #0x0c                       ; 7FBB
	add a,a                         ; 7FBD
.else ; VERSION_GG_JP
sub_7FA7:
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 7FA7
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 7FB0
.endif

;; ---------------------------------------------------------------- $07FBE
;; classement : plage symbols.json
	.area _B01_7FBE
.if VERSION_SMS_EN
sub_7FBE:
	add a,a                         ; 7FBE
	or d                            ; 7FBF
	out (c),a                       ; 7FC0
	djnz loc_7FA6                   ; 7FC2
	ret                             ; 7FC4
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 7FC5
.else ; VERSION_GG_JP
sub_7FBE:
	.db 0x00, 0x00                  ; 7FBE
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 7FC0
.endif

;; ---------------------------------------------------------------- $07FCB
;; classement : plage symbols.json
	.area _B01_7FCB
.if VERSION_SMS_EN
sub_7FCB:
	nop                             ; 7FCB
	ret                             ; 7FCC
loc_7FCD:
	call sub_44BC                   ; 7FCD
	call sub_7FA7+0x4000            ; 7FD0
	or a                            ; 7FD3
	jr z,loc_7FD9                   ; 7FD4
	jp loc_7FA2                     ; 7FD6
loc_7FD9:
	call sub_7FBE+0x4000            ; 7FD9
	call sub_0A6B                   ; 7FDC
	call sub_0A33                   ; 7FDF
	ld a,#0x86                      ; 7FE2
	ld (scene_id),a                 ; 7FE4
	ld a,#0x01                      ; 7FE7
	ld (game_mode),a                ; 7FE9
	jp loc_7F9C                     ; 7FEC
	.db 0xff                        ; 7FEF
.else ; VERSION_GG_JP
sub_7FCB:
	.db 0x00, 0x00                  ; 7FCB
loc_7FCD:
	.db 0x00, 0x00, 0x00            ; 7FCD
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 7FD0
loc_7FD9:
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 7FD9
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 7FE0
.endif
