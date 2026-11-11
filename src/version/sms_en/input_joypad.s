;; version/sms_en/input_joypad.s
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
	in a,(IO_PORT_A)                ; 0434  manette 1 (+ haut/bas manette 2)
	cpl                             ; 0436
	and #0x3f                       ; 0437
	ld c,a                          ; 0439
	and #0x10                       ; 043A
	add a,a                         ; 043C
	add a,a                         ; 043D
	add a,a                         ; 043E
	or c                            ; 043F
	ld hl,#sms_pause_flag           ; 0440
	or (hl)                         ; 0443
	ld (hl),#0x00                   ; 0444
	ld c,a                          ; 0446
	ld a,(freeze_timer)             ; 0447
	or a                            ; 044A
	jr z,loc_044F                   ; 044B
	ld c,#0x00                      ; 044D
loc_044F:
	ld hl,#joypad_state             ; 044F
	ld a,(hl)                       ; 0452
	xor c                           ; 0453
	and c                           ; 0454
	inc hl                          ; 0455
loc_0456:
	ld (hl),a                       ; 0456
	dec hl                          ; 0457
	ld a,c                          ; 0458
	and #0x0f                       ; 0459
	add a,#0x6c                     ; 045B
	ld e,a                          ; 045D
	ld d,#0x04                      ; 045E
	ld a,(de)                       ; 0460
	ld e,a                          ; 0461
	ld a,c                          ; 0462
	and #0xf0                       ; 0463
	or e                            ; 0465
	ld (hl),a                       ; 0466
	ret                             ; 0467
	.db 0x00, 0x00, 0x00, 0x00      ; 0468
data_046C:
	.db 0x00, 0x01, 0x02, 0x01      ; 046C
	.db 0x04, 0x05, 0x06, 0x04, 0x08, 0x09, 0x0a, 0x08, 0x08, 0x08, 0x08, 0x08 ; 0470
