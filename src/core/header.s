;; core/header.s
;; En-tete ROM 'TMR SEGA' ($7FF0).
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"


;; ---------------------------------------------------------------- $07FF0
;; classement : plage symbols.json
	.area _B01_7FF0
.if VERSION_SMS_EN
rom_header:
	.db 0x54, 0x4d, 0x52, 0x20, 0x53, 0x45, 0x47, 0x41, 0x00, 0x00, 0x07, 0xbd, 0x73, 0x33, 0x00, 0x4c ; 7FF0
.else ; VERSION_GG_JP
rom_header:
	.db 0x54, 0x4d, 0x52, 0x20, 0x53, 0x45, 0x47, 0x41, 0x00, 0x00, 0x00, 0x00, 0x73, 0x33, 0x00, 0x50 ; 7FF0
.endif
