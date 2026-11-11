;; core/boot.s
;; Demarrage : vecteurs RST, reset, initialisation RAM/mapper/VDP.
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $00000
;; classement : plage symbols.json
	.area _B00_0000
reset:
	di                              ; 0000
	im 1                            ; 0001
	jp boot_init                    ; 0003
	.db 0xff, 0xff                  ; 0006

;; ---------------------------------------------------------------- $00008
;; classement : plage symbols.json
	.area _B00_0008
rst08_vdp_set_addr_di::
	di                              ; 0008
	rst 0x10                        ; 0009  VDP : adresse/commande = de
	ei                              ; 000A
	ret                             ; 000B
	.dw sub_5D4D                    ; 000C
	.dw data_5D14                   ; 000E

;; ---------------------------------------------------------------- $00010
;; classement : plage symbols.json
	.area _B00_0010
rst10_vdp_set_addr:
	ld a,e                          ; 0010
	out (VDP_CTRL),a                ; 0011  VDP : commande (adresse / registre)
	ld a,d                          ; 0013
	out (VDP_CTRL),a                ; 0014  VDP : commande (adresse / registre)
	ret                             ; 0016
	.dw sub_5D2A                    ; 0017
	.dw sub_5D31                    ; 0019
	.dw sub_5D46                    ; 001B
	.dw sub_5D15                    ; 001D
	.dw sub_5D1C                    ; 001F
	.dw sub_5D23                    ; 0021
	.dw sub_5D38                    ; 0023
	.dw sub_5D3F                    ; 0025
	.dw sub_5CEA                    ; 0027
	.dw sub_5CEE                    ; 0029
	.dw sub_5CF2                    ; 002B
	.dw sub_5CF6                    ; 002D
	.db 0xfa                        ; 002F
	.db 0x5c                        ; 0030

;; ---------------------------------------------------------------- $00031
;; classement : plage symbols.json
	.area _B00_0031
sub_0031::
	jp sub_58A5                     ; 0031

;; ---------------------------------------------------------------- $00034
;; classement : plage symbols.json
	.area _B00_0034
sub_0034::
	jp sub_58AE                     ; 0034
	.db 0xff                        ; 0037

;; ---------------------------------------------------------------- $00074
;; classement : plage symbols.json
	.area _B00_0074
boot_init:
	ld hl,#game_flags               ; 0074
	ld de,#0xc001                   ; 0077
.if VERSION_SMS_EN
	ld bc,#0x1ff0                   ; 007A
.else ; VERSION_GG_JP
	ld bc,#0x1fef                   ; 007A
.endif
	ld (hl),l                       ; 007D
	ldir                            ; 007E
	ld a,#0x03                      ; 0080
	ld (lives_or_c005),a            ; 0082
	ld hl,#0x0000                   ; 0085
	ld (MAPPER_CTRL),hl             ; 0088
	ld hl,#0x0201                   ; 008B
	ld (MAPPER_SLOT1),hl            ; 008E  mapper : banque du slot 1 ($4000-$7FFF)
	ld sp,#0xde00                   ; 0091
	call sub_400C                   ; 0094
	call sub_404E                   ; 0097
	call sub_44C7                   ; 009A
	ld a,#0xff                      ; 009D
	ld (task_current),a             ; 009F
	ld a,#0x00                      ; 00A2
	call task_start                 ; 00A4
	call sound_init                 ; 00A7
	call sub_0A6B                   ; 00AA
loc_00AD:
	ei                              ; 00AD
	jr loc_00AD                     ; 00AE
