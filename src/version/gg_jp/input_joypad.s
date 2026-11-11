;; version/gg_jp/input_joypad.s
;; Module non encore identifie (provisoire).
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $0042E
;; classement : plage symbols.json
	.area _B00_042E
joypad_read::
	ld a,(game_flags)               ; 042E
	bit 5,a                         ; 0431
	ret nz                          ; 0433
	ld hl,#joypad_state             ; 0434
	in a,(IO_PORT_A)                ; 0437  manette 1 (+ haut/bas manette 2)
	and #0x3f                       ; 0439
	or #0x40                        ; 043B
	ld c,a                          ; 043D
	in a,(GG_START)                 ; 043E  GG : bouton Start (bit 7)
	and #0x80                       ; 0440
	or c                            ; 0442
	cpl                             ; 0443
	ld c,a                          ; 0444
	xor (hl)                        ; 0445
	ld (hl),c                       ; 0446
	inc hl                          ; 0447
	and c                           ; 0448
	ld (hl),a                       ; 0449
	ld a,(freeze_timer)             ; 044A
	or a                            ; 044D
	jr z,loc_0456                   ; 044E
	ld hl,#0x0000                   ; 0450
	ld (joypad_state),hl            ; 0453
loc_0456:
	ld a,(joypad_state)             ; 0456
	and #0x0f                       ; 0459
	ld l,a                          ; 045B
	ld h,#0x00                      ; 045C
	ld de,#data_046C                ; 045E
	add hl,de                       ; 0461
	ld a,(joypad_state)             ; 0462
	and #0xf0                       ; 0465
	or (hl)                         ; 0467
	ld (joypad_state),a             ; 0468
	ret                             ; 046B
data_046C:
	.db 0x00, 0x01, 0x02, 0x01      ; 046C
	.db 0x04, 0x05, 0x06, 0x04, 0x08, 0x09, 0x0a, 0x08, 0x08, 0x08, 0x08, 0x08 ; 0470
