;; core/tasks.s
;; Ordonnanceur cooperatif a 7 taches (piles separees) et API des taches.
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $00273
;; classement : plage symbols.json
	.area _B00_0273
task_start::
	push af                         ; 0273
	push bc                         ; 0274
	push de                         ; 0275
	push hl                         ; 0276
	and #0x07                       ; 0277
	ld b,a                          ; 0279
	ld l,a                          ; 027A
	ld h,#0x00                      ; 027B
	ld de,#task_bit_table           ; 027D
	add hl,de                       ; 0280
	ld a,(hl)                       ; 0281
	ld c,a                          ; 0282
	ld hl,#task_active_mask         ; 0283
	or (hl)                         ; 0286
	ld (hl),a                       ; 0287
	ld a,c                          ; 0288
	cpl                             ; 0289
	ld hl,#task_suspended_mask      ; 028A
	and (hl)                        ; 028D
	ld (hl),a                       ; 028E
	ld l,b                          ; 028F
	ld h,#0x00                      ; 0290
	push hl                         ; 0292
	ld de,#task_wait_table          ; 0293
	add hl,de                       ; 0296
	ld (hl),#0x01                   ; 0297
	pop hl                          ; 0299
	add hl,hl                       ; 029A
	push hl                         ; 029B
	ld de,#task_stack_table         ; 029C
	add hl,de                       ; 029F
	ld e,(hl)                       ; 02A0
	inc hl                          ; 02A1
	ld d,(hl)                       ; 02A2
	pop hl                          ; 02A3
	push de                         ; 02A4
	ld de,#task_entry_table         ; 02A5
data_02A8::
	add hl,de                       ; 02A8
	ld e,(hl)                       ; 02A9
	inc hl                          ; 02AA
	ld d,(hl)                       ; 02AB
	pop hl                          ; 02AC
	ld (hl),d                       ; 02AD
	dec hl                          ; 02AE
	ld (hl),e                       ; 02AF
	ld de,#0x000c                   ; 02B0
	xor a                           ; 02B3
	sbc hl,de                       ; 02B4
	push hl                         ; 02B6
	ld l,b                          ; 02B7
	ld h,#0x00                      ; 02B8
	add hl,hl                       ; 02BA
	ld de,#task_sp_table            ; 02BB
	add hl,de                       ; 02BE
	pop de                          ; 02BF
	ld (hl),e                       ; 02C0
	inc hl                          ; 02C1
	ld (hl),d                       ; 02C2
	jp loc_03E4                     ; 02C3

;; ---------------------------------------------------------------- $002C6
;; classement : plage symbols.json
	.area _B00_02C6
task_kill::
	push af                         ; 02C6
	push bc                         ; 02C7
	push de                         ; 02C8
	push hl                         ; 02C9
	and #0x07                       ; 02CA
	ld b,a                          ; 02CC
	ld l,a                          ; 02CD
	ld h,#0x00                      ; 02CE
	ld de,#task_bit_table           ; 02D0
	add hl,de                       ; 02D3
	ld a,(hl)                       ; 02D4
	ld c,a                          ; 02D5
	cpl                             ; 02D6
	ld hl,#task_active_mask         ; 02D7
	and (hl)                        ; 02DA
	ld (hl),a                       ; 02DB
	ld a,c                          ; 02DC
	cpl                             ; 02DD
	ld hl,#task_ready_mask          ; 02DE
	and (hl)                        ; 02E1
	ld (hl),a                       ; 02E2
	ld a,(task_current)             ; 02E3
	ld l,a                          ; 02E6
	ld h,#0x00                      ; 02E7
	ld de,#task_bit_table           ; 02E9
	add hl,de                       ; 02EC
	ld a,(hl)                       ; 02ED
	ld hl,#task_active_mask         ; 02EE
	and (hl)                        ; 02F1
	jp z,task_scheduler             ; 02F2
	jp loc_03E4                     ; 02F5

;; ---------------------------------------------------------------- $002F8
;; classement : plage symbols.json
	.area _B00_02F8
task_suspend::
	push af                         ; 02F8
	push bc                         ; 02F9
	push de                         ; 02FA
	push hl                         ; 02FB
	and #0x07                       ; 02FC
	ld l,a                          ; 02FE
	ld h,#0x00                      ; 02FF
	ld de,#task_bit_table           ; 0301
	add hl,de                       ; 0304
	ld a,(hl)                       ; 0305
	ld hl,#task_suspended_mask      ; 0306
	or (hl)                         ; 0309
	ld (hl),a                       ; 030A
	jp loc_03E4                     ; 030B

;; ---------------------------------------------------------------- $0030E
;; classement : plage symbols.json
	.area _B00_030E
task_resume::
	push af                         ; 030E
	push bc                         ; 030F
	push de                         ; 0310
	push hl                         ; 0311
	and #0x07                       ; 0312
	ld b,a                          ; 0314
	ld l,a                          ; 0315
	ld h,#0x00                      ; 0316
	ld de,#task_bit_table           ; 0318
	add hl,de                       ; 031B
	ld a,(hl)                       ; 031C
	xor #0xff                       ; 031D
	ld hl,#task_suspended_mask      ; 031F
	and (hl)                        ; 0322
	ld (hl),a                       ; 0323
	ld l,b                          ; 0324
	ld h,#0x00                      ; 0325
	ld de,#task_wait_table          ; 0327
	add hl,de                       ; 032A
	ld (hl),#0x01                   ; 032B
	jp loc_03E4                     ; 032D

;; ---------------------------------------------------------------- $00330
;; classement : plage symbols.json
	.area _B00_0330
task_yield::
	ld a,#0x01                      ; 0330

;; ---------------------------------------------------------------- $00332
;; classement : plage symbols.json
	.area _B00_0332
sub_0332::
	push af                         ; 0332
	push bc                         ; 0333
	push de                         ; 0334
	push hl                         ; 0335
	push ix                         ; 0336
	push iy                         ; 0338
	ld hl,(task_current)            ; 033A
	ld h,#0x00                      ; 033D
	push hl                         ; 033F
	ld de,#task_wait_table          ; 0340
	add hl,de                       ; 0343
	ld (hl),a                       ; 0344
	pop hl                          ; 0345
	add hl,hl                       ; 0346
	ld de,#task_sp_table            ; 0347
	add hl,de                       ; 034A
	ex de,hl                        ; 034B
	ld hl,#0x0000                   ; 034C
	add hl,sp                       ; 034F
	ex de,hl                        ; 0350
	ld (hl),e                       ; 0351
	inc hl                          ; 0352
	ld (hl),d                       ; 0353
	ld hl,(task_current)            ; 0354
	ld h,#0x00                      ; 0357
	ld de,#task_bit_table           ; 0359
	add hl,de                       ; 035C
	ld a,(hl)                       ; 035D
	cpl                             ; 035E
	ld hl,#task_ready_mask          ; 035F
	and (hl)                        ; 0362
	ld (hl),a                       ; 0363

;; ---------------------------------------------------------------- $00364
;; classement : plage symbols.json
	.area _B00_0364
task_scheduler::
	ld sp,#0xde00                   ; 0364
	ld c,#0xff                      ; 0367
	ld a,(task_ready_mask)          ; 0369
	or a                            ; 036C
	jp z,loc_0374                   ; 036D
	ld a,(task_current)             ; 0370
	ld c,a                          ; 0373
loc_0374:
	inc c                           ; 0374
	ld a,c                          ; 0375
	cp #0x07                        ; 0376
	jp nc,loc_03C3                  ; 0378
	ld l,c                          ; 037B
	ld h,#0x00                      ; 037C
	ld de,#task_bit_table           ; 037E
	add hl,de                       ; 0381
	ld a,(hl)                       ; 0382
loc_0383::
	ld b,a                          ; 0383
	ld hl,#task_ready_mask          ; 0384
	and (hl)                        ; 0387
	jp z,loc_03B9                   ; 0388
	ld a,b                          ; 038B
	ld hl,#task_suspended_mask      ; 038C
	and (hl)                        ; 038F
	jp nz,loc_03B9                  ; 0390
	ld l,c                          ; 0393
	ld h,#0x00                      ; 0394
	ld de,#task_wait_table          ; 0396
	add hl,de                       ; 0399
	ld a,(hl)                       ; 039A
	or a                            ; 039B
	jp z,loc_03A5                   ; 039C
	dec a                           ; 039F
	ld (hl),a                       ; 03A0
	or a                            ; 03A1
	jp nz,loc_03B9                  ; 03A2
loc_03A5:
	ld hl,#task_current             ; 03A5
	ld (hl),c                       ; 03A8
	ld l,c                          ; 03A9
	ld h,#0x00                      ; 03AA
	add hl,hl                       ; 03AC
	ld de,#task_sp_table            ; 03AD
	add hl,de                       ; 03B0
	ld e,(hl)                       ; 03B1
	inc hl                          ; 03B2
	ld d,(hl)                       ; 03B3
	ex de,hl                        ; 03B4
	ld sp,hl                        ; 03B5
	jp loc_03D8                     ; 03B6
loc_03B9:
	ld a,b                          ; 03B9
	cpl                             ; 03BA
	ld hl,#task_ready_mask          ; 03BB
	and (hl)                        ; 03BE
	ld (hl),a                       ; 03BF
	jp loc_0374                     ; 03C0
loc_03C3:
	ld hl,#irq_flags                ; 03C3
	bit 7,(hl)                      ; 03C6
	jr nz,loc_03D4                  ; 03C8
	di                              ; 03CA
	ld hl,#vdp_requests2            ; 03CB
	ld a,(hl)                       ; 03CE
	ld (hl),#0x00                   ; 03CF
	dec hl                          ; 03D1
	or (hl)                         ; 03D2
	ld (hl),a                       ; 03D3
loc_03D4:
	ei                              ; 03D4
	jp loc_03D4                     ; 03D5
loc_03D8::
	ld hl,#irq_flags                ; 03D8
	bit 7,(hl)                      ; 03DB
	jp nz,loc_03E9                  ; 03DD
	pop iy                          ; 03E0
	pop ix                          ; 03E2
loc_03E4:
	pop hl                          ; 03E4
	pop de                          ; 03E5
	pop bc                          ; 03E6
	pop af                          ; 03E7
	ret                             ; 03E8
loc_03E9:
	res 7,(hl)                      ; 03E9
	ld a,(vdp_requests)             ; 03EB
	and #0x1f                       ; 03EE
	ld (vdp_requests),a             ; 03F0
	ld a,(bank_slot2_shadow)        ; 03F3
	ld (MAPPER_SLOT2),a             ; 03F6  mapper : banque du slot 2 ($8000-$BFFF)
	pop iy                          ; 03F9
	pop ix                          ; 03FB
loc_03FD::
	pop hl                          ; 03FD
	pop de                          ; 03FE
	pop bc                          ; 03FF
data_0400::
	pop af                          ; 0400
	ei                              ; 0401
	ret                             ; 0402

;; ---------------------------------------------------------------- $00403
;; classement : plage symbols.json
	.area _B00_0403
task_bit_table:
	.db 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80 ; 0403

;; ---------------------------------------------------------------- $0040B
;; classement : plage symbols.json
	.area _B00_040B
task_entry_table:
	.dw sub_06B3                    ; 040B
	.dw sub_1A2D                    ; 040D
	.dw sub_3476                    ; 040F
	.dw sub_4767                    ; 0411
	.dw sub_0FA9                    ; 0413
	.dw sub_6337                    ; 0415
	.dw sub_042B                    ; 0417
	.dw sub_042B                    ; 0419

;; ---------------------------------------------------------------- $0041B
;; classement : plage symbols.json
	.area _B00_041B
task_stack_table:
	.db 0x00, 0xdd, 0x40, 0xdd, 0x80 ; 041B
	.db 0xdd, 0xc0, 0xdd, 0xc0, 0xdd, 0xc0, 0xdd, 0xc0, 0xdd, 0xc0, 0xdd ; 0420

;; ---------------------------------------------------------------- $0042B
;; classement : plage symbols.json
	.area _B00_042B
sub_042B:
	jp task_start                   ; 042B
