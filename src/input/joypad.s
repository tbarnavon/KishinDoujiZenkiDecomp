;; input/joypad.s
;; Lecture des manettes et detection des fronts (appuis).
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $0047C
;; classement : plage symbols.json
	.area _B00_047C
sub_047C::
	ret                             ; 047C

;; ---------------------------------------------------------------- $01380
;; classement : conversion manette -> direction
	.area _B00_1380
sub_1380::
	and #0x0f                       ; 1380
	ld l,a                          ; 1382
	ld h,#0x00                      ; 1383
	ld de,#data_138B                ; 1385
	add hl,de                       ; 1388
	ld a,(hl)                       ; 1389
	ret                             ; 138A
data_138B:
	.db 0x00, 0x01, 0x02, 0x00, 0x03 ; 138B
	.db 0x01, 0x02, 0x00, 0x04, 0x01, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00 ; 1390
