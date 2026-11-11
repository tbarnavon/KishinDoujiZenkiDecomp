;; core/util.s
;; Utilitaires partages (recherche en table, arithmetique, helpers generiques).
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $019B7
;; classement : utilitaire partage par task1+task3
	.area _B00_19B7
sub_19B7::
	ld a,(flow_C1B6)                 ; 19B7
	ld l,a                          ; 19BA
	res 7,l                         ; 19BB
	bit 7,a                         ; 19BD
	ld a,#0x00                      ; 19BF
	jr z,loc_19C5                   ; 19C1
	ld a,#0x04                      ; 19C3
loc_19C5:
	add a,l                         ; 19C5
	add a,a                         ; 19C6
	ld l,a                          ; 19C7
	ld h,#0x00                      ; 19C8
	ld de,#data_19D6                ; 19CA
	add hl,de                       ; 19CD
	ld e,(hl)                       ; 19CE
	inc hl                          ; 19CF
	ld d,(hl)                       ; 19D0
	ex de,hl                        ; 19D1
	call sub_5198                   ; 19D2
	ret                             ; 19D5
data_19D6:
	.db 0xe6, 0x19, 0xee, 0x19, 0xf6, 0x19, 0x00, 0x1a, 0xe6, 0x19 ; 19D6
	.db 0xee, 0x19, 0xf6, 0x19, 0xf8, 0x19, 0xf5, 0xb4, 0x80, 0x42, 0x1e, 0x00, 0xff, 0xff, 0xed, 0xb8 ; 19E0
	.db 0x80, 0x42, 0x1e, 0x00, 0xff, 0xff, 0xff, 0xff, 0x7b, 0xb6, 0x80, 0x42, 0x1e, 0x00, 0xff, 0xff ; 19F0
	.db 0xc5, 0xb7, 0x80, 0x42, 0x07, 0x00, 0x9a, 0xb7, 0x80, 0x43, 0x07, 0x00, 0xff, 0xff ; 1A00
data_1A0E::
	.db 0xfc, 0x22                  ; 1A0E
	.db 0xe0, 0x01, 0x0c, 0x0c, 0x00, 0x23, 0x1a ; 1A10
data_1A17::
	.db 0xfc, 0x22, 0xe0, 0x01, 0x0c, 0x0c, 0xff, 0xeb, 0x82 ; 1A17
	.db 0xff, 0x14, 0x83, 0xff, 0x3d, 0x83, 0xff, 0xc2, 0x82, 0x00, 0x1d, 0x1a ; 1A20
data_1A2C::
	.db 0xf4                        ; 1A2C

;; ---------------------------------------------------------------- $01BE7
;; classement : utilitaire partage par task1+task4
	.area _B00_1BE7
sub_1BE7::
	ld b,h                          ; 1BE7
	xor a                           ; 1BE8
	ld h,a                          ; 1BE9
	ld de,#0x00e0                   ; 1BEA
	or b                            ; 1BED
	jr z,loc_1BF3                   ; 1BEE
loc_1BF0:
	add hl,de                       ; 1BF0
	djnz loc_1BF0                   ; 1BF1
loc_1BF3:
	ret                             ; 1BF3

;; ---------------------------------------------------------------- $01BF4
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_1BF4
sub_1BF4:
	ld a,(dbg_C0D4)                 ; 1BF4
	bit 7,a                         ; 1BF7
	ld a,(util_C0A2)                 ; 1BF9
	jr z,loc_1C0B                   ; 1BFC
	bit 0,a                         ; 1BFE
	jr z,loc_1C09                   ; 1C00
	ld a,(scroll_C0B0)                 ; 1C02
	bit 0,a                         ; 1C05
	jr z,loc_1C22                   ; 1C07
loc_1C09:
	jr loc_1C16                     ; 1C09
loc_1C0B:
	bit 1,a                         ; 1C0B
	jr z,loc_1C16                   ; 1C0D
	ld a,(scroll_C0B0)                 ; 1C0F
	bit 1,a                         ; 1C12
	jr z,loc_1C22                   ; 1C14
loc_1C16:
	ld hl,(tmp_d3)                  ; 1C16
	ld (player_CEFF),hl                ; 1C19
	ld hl,#0x0000                   ; 1C1C
	ld (tmp_d3),hl                  ; 1C1F
loc_1C22:
	ld a,(pal_C0D6)                 ; 1C22
	bit 7,a                         ; 1C25
	ld a,(util_C0A2)                 ; 1C27
	jr z,loc_1C39                   ; 1C2A
	bit 2,a                         ; 1C2C
	jr z,loc_1C37                   ; 1C2E
	ld a,(scroll_C0B0)                 ; 1C30
	bit 2,a                         ; 1C33
	jr z,loc_1C52                   ; 1C35
loc_1C37:
	jr loc_1C44                     ; 1C37
loc_1C39:
	bit 3,a                         ; 1C39
	jr z,loc_1C44                   ; 1C3B
	ld a,(scroll_C0B0)                 ; 1C3D
	bit 3,a                         ; 1C40
	jr z,loc_1C52                   ; 1C42
loc_1C44:
	ld hl,(tmp_d5)                  ; 1C44
	ld (player_CF01),hl                ; 1C47
	ld hl,#0x0000                   ; 1C4A
	ld (tmp_d5),hl                  ; 1C4D
	jr loc_1C5F                     ; 1C50
loc_1C52:
	ld de,(tmp_d5)                  ; 1C52
	ld hl,#0x0000                   ; 1C56
	or a                            ; 1C59
	sbc hl,de                       ; 1C5A
	ld (tmp_d5),hl                  ; 1C5C
loc_1C5F:
	ret                             ; 1C5F

;; ---------------------------------------------------------------- $01F2B
;; classement : utilitaire partage par task3+tbl_1D9E
	.area _B00_1F2B
sub_1F2B::
	dec a                           ; 1F2B
	add a,a                         ; 1F2C
	ld l,a                          ; 1F2D
	ld h,#0x00                      ; 1F2E
	ld de,#sub_1F49                 ; 1F30
	add hl,de                       ; 1F33
	ld e,(hl)                       ; 1F34
	inc hl                          ; 1F35
	ld d,(hl)                       ; 1F36
	ex de,hl                        ; 1F37
	ld de,#VDP_VRAM_WRITE|0x0440    ; 1F38
	ld a,#0x07                      ; 1F3B
	ld (bank_slot2_shadow),a        ; 1F3D
	ld (MAPPER_SLOT2),a             ; 1F40  mapper : banque du slot 2 ($8000-$BFFF)
	di                              ; 1F43
	call sub_46A1                   ; 1F44
	ei                              ; 1F47
	ret                             ; 1F48

;; ---------------------------------------------------------------- $01F49
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_1F49
sub_1F49:
	ld (hl),h                       ; 1F49
	cp h                            ; 1F4A
	push bc                         ; 1F4B
	or a                            ; 1F4C
	push bc                         ; 1F4D
	or a                            ; 1F4E
loc_1F4F::
	ld 0(ix),#0x00                  ; 1F4F
loc_1F53::
	ld a,(flow_C015)                 ; 1F53
	call sub_27CC                   ; 1F56
	ld (flow_C015),a                 ; 1F59
	push iy                         ; 1F5C
	ld b,#0x0d                      ; 1F5E
	ld hl,#scene_script_ptr         ; 1F60
	call sub_3BCD                   ; 1F63
	jr nz,loc_1F81                  ; 1F66
	push hl                         ; 1F68
	call sub_3BD8                   ; 1F69
	pop iy                          ; 1F6C
	ld 0(iy),#0xce                  ; 1F6E
	ld a,2(ix)                      ; 1F72
	ld 2(iy),a                      ; 1F75
	ld a,5(ix)                      ; 1F78
	ld 5(iy),a                      ; 1F7B
	call sub_3B28                   ; 1F7E
loc_1F81::
	call sub_050F                   ; 1F81
	pop iy                          ; 1F84
	ret                             ; 1F86

;; ---------------------------------------------------------------- $02118
;; classement : utilitaire partage par task1+task5_scene
	.area _B00_2118
sub_2118::
	ld hl,#util_CD87                 ; 2118
	ld (hl),#0x00                   ; 211B
	ld de,#util_CD88                 ; 211D
	ld bc,#0x0028                   ; 2120
	ldir                            ; 2123
	ret                             ; 2125
data_2126::
	.db 0x11                        ; 2126

;; ---------------------------------------------------------------- $02127
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_2127
sub_2127:
	ld a,(hl)                       ; 2127
	ld de,#0x1190                   ; 2128
	add a,(hl)                      ; 212B

;; ---------------------------------------------------------------- $0223B
;; classement : utilitaire partage par task0_main+task1+task4+task5_scene
	.area _B00_223B
sub_223B::
	ld hl,#player_CD37                 ; 223B
	ld de,#util_CD38                 ; 223E
	ld (hl),#0x00                   ; 2241
	ld bc,#0x004f                   ; 2243
	ldir                            ; 2246
	ret                             ; 2248

;; ---------------------------------------------------------------- $023FC
;; classement : utilitaire partage par task1+tbl_1D9E
	.area _B00_23FC
sub_23FC::
	ld iy,#player_CD37                 ; 23FC
	ld b,#0x02                      ; 2400
loc_2402:
	push bc                         ; 2402
	ld a,0(iy)                      ; 2403
	or a                            ; 2406
	jp z,loc_2487                   ; 2407
	ld a,13(iy)                     ; 240A
	or a                            ; 240D
	jr z,loc_2416                   ; 240E
	call sub_35E2                   ; 2410
	jp loc_2457                     ; 2413
loc_2416:
	xor a                           ; 2416
	ld e,16(iy)                     ; 2417
	ld d,17(iy)                     ; 241A
	bit 7,d                         ; 241D
	jr z,loc_2422                   ; 241F
	cpl                             ; 2421
loc_2422:
	ld l,1(iy)                      ; 2422
	ld h,2(iy)                      ; 2425
	add hl,de                       ; 2428
	ld 1(iy),l                      ; 2429
	ld 2(iy),h                      ; 242C
	adc a,3(iy)                     ; 242F
	ld 3(iy),a                      ; 2432
	xor a                           ; 2435
	ld e,18(iy)                     ; 2436
	ld d,19(iy)                     ; 2439
	bit 7,d                         ; 243C
	jr z,loc_2441                   ; 243E
	cpl                             ; 2440
loc_2441:
	ld l,4(iy)                      ; 2441
	ld h,5(iy)                      ; 2444
	add hl,de                       ; 2447
	ld 4(iy),l                      ; 2448
	ld 5(iy),h                      ; 244B
	adc a,6(iy)                     ; 244E
	ld 6(iy),a                      ; 2451
	call sub_35E2                   ; 2454
loc_2457:
	ld a,3(iy)                      ; 2457
	or 6(iy)                        ; 245A
	jr nz,loc_2483                  ; 245D
	bit 5,34(iy)                    ; 245F
	jr nz,loc_2471                  ; 2463
	ld a,2(iy)                      ; 2465
	ld h,#0xb7                      ; 2468
	ld l,#0x07                      ; 246A
	call sub_35D7                   ; 246C
	jr nz,loc_2483                  ; 246F
loc_2471:
	bit 2,34(iy)                    ; 2471
	jr nz,loc_2487                  ; 2475
	ld a,5(iy)                      ; 2477
	ld h,#0xe0                      ; 247A
	ld l,#0x20                      ; 247C
	call sub_35D7                   ; 247E
	jr z,loc_2487                   ; 2481
loc_2483:
	ld 0(iy),#0x00                  ; 2483
loc_2487:
	pop bc                          ; 2487
	ld de,#0x0028                   ; 2488
	add iy,de                       ; 248B
	dec b                           ; 248D
	jp nz,loc_2402                  ; 248E
	ret                             ; 2491
	.db 0xae, 0x24, 0xb7, 0x24, 0xc0, 0x24, 0xc5, 0x24, 0xca, 0x24, 0xcf, 0x24, 0xca, 0x24 ; 2492
	.db 0xcf, 0x24, 0xd4, 0x24, 0xd9, 0x24, 0xde, 0x24, 0xde, 0x24, 0xe3, 0x24, 0xea, 0x24, 0xf0, 0xfc ; 24A0
	.db 0x08, 0x08, 0x10, 0x08, 0x20, 0x08, 0xff, 0xf0, 0xfc, 0x08, 0x00, 0x10, 0x00, 0x20, 0x00, 0xff ; 24B0
	.db 0xf8, 0xf4, 0x00, 0x18, 0xff, 0xf8, 0xf4, 0x00, 0x00, 0xff, 0xfc, 0xfc, 0x04, 0x08, 0xff, 0xfc ; 24C0
	.db 0xfc, 0x04, 0x00, 0xff, 0xf4, 0xf8, 0x0c, 0x06, 0xff, 0xfc, 0xfc, 0x0c, 0x00, 0xff, 0xfc, 0xfc ; 24D0
	.db 0x04, 0x04, 0xff, 0xf4, 0x08, 0x04, 0x0c, 0x14, 0x0c, 0xff, 0xf4, 0x08, 0x04, 0x04, 0x14, 0x04 ; 24E0
	.db 0xff                        ; 24F0

;; ---------------------------------------------------------------- $02AF0
;; classement : plage symbols.json
	.area _B00_2AF0
util_jump_table::
	ld h,#0x00                      ; 2AF0
	add hl,hl                       ; 2AF2
	add hl,de                       ; 2AF3
	ld e,(hl)                       ; 2AF4
	inc hl                          ; 2AF5
	ld d,(hl)                       ; 2AF6
	ex de,hl                        ; 2AF7
	jp (hl)                         ; 2AF8

;; ---------------------------------------------------------------- $02AF9
;; classement : plage symbols.json
	.area _B00_2AF9
sub_2AF9::
	ld a,(player_CEFC)                 ; 2AF9
	and #0x84                       ; 2AFC
	ret z                           ; 2AFE
	ld a,(player_state)             ; 2AFF
	or a                            ; 2B02
	ret z                           ; 2B03
	ld a,(player_CEFC)                 ; 2B04
	bit 7,a                         ; 2B07
	ret nz                          ; 2B09
	push af                         ; 2B0A
	ld a,(scene_id)                 ; 2B0B
	cp #0x2c                        ; 2B0E
	jr z,loc_2B18                   ; 2B10
	call sound_init                 ; 2B12
	call sub_0541                   ; 2B15
loc_2B18:
	pop af                          ; 2B18
	res 2,a                         ; 2B19
	set 7,a                         ; 2B1B
	ld (player_CEFC),a                 ; 2B1D
	ld a,(player_state)             ; 2B20
	cpl                             ; 2B23
	ld l,a                          ; 2B24
	ld h,#0x00                      ; 2B25
	ld de,#sub_2B54                 ; 2B27
	add hl,de                       ; 2B2A
	ld a,(hl)                       ; 2B2B
	ld (player_CEF6),a                 ; 2B2C
	ld 9(iy),#0x00                  ; 2B2F
	ld 8(iy),#0x00                  ; 2B33
	ld 10(iy),#0x00                 ; 2B37
	ld a,#0x02                      ; 2B3B
	ld (bank_slot2_shadow),a        ; 2B3D
	ld (MAPPER_SLOT2),a             ; 2B40  mapper : banque du slot 2 ($8000-$BFFF)
	ld 34(iy),#0x32                 ; 2B43
	ld hl,#data_b02_815E            ; 2B47
	ld (player_CF13),hl                ; 2B4A
	ld hl,#0x0000                   ; 2B4D
	ld (player_C1DF),hl                ; 2B50
	ret                             ; 2B53

;; ---------------------------------------------------------------- $02B54
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_2B54
sub_2B54:
	ld (de),a                       ; 2B54
	inc c                           ; 2B55
	ld (de),a                       ; 2B56
	ld a,(scene_id)                 ; 2B57
	cp #0x09                        ; 2B5A
	ret nz                          ; 2B5C
	ld hl,#0x7800                   ; 2B5D
	ld bc,#0x0380                   ; 2B60
	di                              ; 2B63
loc_2B64:
	ld a,h                          ; 2B64
	and #0x3f                       ; 2B65
	ld h,a                          ; 2B67
	ld a,l                          ; 2B68
	out (VDP_CTRL),a                ; 2B69  VDP : commande (adresse / registre)
	ld a,h                          ; 2B6B
	out (VDP_CTRL),a                ; 2B6C  VDP : commande (adresse / registre)
	push ix                         ; 2B6E
	pop ix                          ; 2B70
	in a,(VDP_DATA)                 ; 2B72  VDP : donnee VRAM/CRAM
	ld e,a                          ; 2B74
	push ix                         ; 2B75
	pop ix                          ; 2B77
	in a,(VDP_DATA)                 ; 2B79  VDP : donnee VRAM/CRAM
	and #0xef                       ; 2B7B
	ld d,a                          ; 2B7D
	ld a,h                          ; 2B7E
	or #0x40                        ; 2B7F
	ld h,a                          ; 2B81
	ld a,l                          ; 2B82
	out (VDP_CTRL),a                ; 2B83  VDP : commande (adresse / registre)
	ld a,h                          ; 2B85
	out (VDP_CTRL),a                ; 2B86  VDP : commande (adresse / registre)
	push ix                         ; 2B88
	pop ix                          ; 2B8A
	ld a,e                          ; 2B8C
	out (VDP_DATA),a                ; 2B8D  VDP : donnee VRAM/CRAM
	push ix                         ; 2B8F
	pop ix                          ; 2B91
	ld a,d                          ; 2B93
	out (VDP_DATA),a                ; 2B94  VDP : donnee VRAM/CRAM
	inc hl                          ; 2B96
	inc hl                          ; 2B97
	dec bc                          ; 2B98
	ld a,c                          ; 2B99
	or b                            ; 2B9A
	jr nz,loc_2B64                  ; 2B9B
	ei                              ; 2B9D
	ret                             ; 2B9E

;; ---------------------------------------------------------------- $02B9F
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_2B9F
.if VERSION_SMS_EN
sub_2B9F:
	xor a                           ; 2B9F
.else ; VERSION_GG_JP
sub_2B9F:
	.db 0xaf                        ; 2B9F
.endif
sub_2BA0:
	or 0(ix)                        ; 2BA0
	ret z                           ; 2BA3
	ld a,5(ix)                      ; 2BA4
	sub 5(iy)                       ; 2BA7
	jp p,loc_2BAF                   ; 2BAA
	neg                             ; 2BAD
loc_2BAF:
	cp #0x80                        ; 2BAF
	jr nc,loc_2BE2                  ; 2BB1
	ld (tmp_d5),a                   ; 2BB3
	ld a,2(ix)                      ; 2BB6
	sub 2(iy)                       ; 2BB9
	jp p,loc_2BC1                   ; 2BBC
	neg                             ; 2BBF
loc_2BC1:
	cp #0x80                        ; 2BC1
	jp nc,loc_2BE2                  ; 2BC3
	ld (dbg_C0D4),a                 ; 2BC6
	ld hl,#dbg_C0D4                 ; 2BC9
	ld a,11(ix)                     ; 2BCC
	add a,11(iy)                    ; 2BCF
	cp (hl)                         ; 2BD2
	jr c,loc_2BE2                   ; 2BD3
	inc hl                          ; 2BD5
	ld a,12(ix)                     ; 2BD6
	add a,12(iy)                    ; 2BD9
	cp (hl)                         ; 2BDC
	jr c,loc_2BE2                   ; 2BDD
	or #0xff                        ; 2BDF
	ret                             ; 2BE1
loc_2BE2:
	xor a                           ; 2BE2
	ret                             ; 2BE3

;; ---------------------------------------------------------------- $02EFD
;; classement : utilitaire partage par task1+tbl_1D9E
	.area _B00_2EFD
sub_2EFD::
	ld a,(player_state)             ; 2EFD
	cpl                             ; 2F00
	add a,a                         ; 2F01
	ld l,a                          ; 2F02
	ld h,#0x00                      ; 2F03
	ld de,#jt_b02_8000              ; 2F05
	add hl,de                       ; 2F08
	ld a,#0x02                      ; 2F09
	ld (bank_slot2_shadow),a        ; 2F0B
	ld (MAPPER_SLOT2),a             ; 2F0E  mapper : banque du slot 2 ($8000-$BFFF)
	ld e,(hl)                       ; 2F11
	inc hl                          ; 2F12
	ld d,(hl)                       ; 2F13
	ex de,hl                        ; 2F14
	jp (hl)                         ; 2F15

;; ---------------------------------------------------------------- $03085
;; classement : utilitaire partage par task1+tbl_2539
	.area _B00_3085
sub_3085::
	push bc                         ; 3085
	ld a,(player_CEFC)                 ; 3086
	ld b,a                          ; 3089
	ld a,(player_CF09)                 ; 308A
	or b                            ; 308D
	pop bc                          ; 308E
	ret                             ; 308F
loc_3090::
	call task_yield                 ; 3090
	call sub_2249                   ; 3093
	ld a,(player_CEF6)                 ; 3096
	cp #0xff                        ; 3099
	jr z,loc_3090                   ; 309B
	ld a,(freeze_timer)             ; 309D
	or a                            ; 30A0
	jr nz,loc_3090                  ; 30A1
	ld a,(demo_mode)                ; 30A3
	or a                            ; 30A6
	jr z,loc_30AF                   ; 30A7
	ld hl,#0x0000                   ; 30A9
	ld (joypad_state),hl            ; 30AC
loc_30AF:
	call sub_1616                   ; 30AF
	ld a,(game_flags)               ; 30B2
	bit 6,a                         ; 30B5
	jr nz,loc_3090                  ; 30B7
	call sub_2EFD                   ; 30B9
	ld a,(demo_mode)                ; 30BC
	or a                            ; 30BF
	jr z,loc_30C8                   ; 30C0
	ld hl,#0x0000                   ; 30C2
	ld (player_CF01),hl                ; 30C5
loc_30C8:
	call sub_3123                   ; 30C8
	call sub_2EDC                   ; 30CB
	call sub_3994                   ; 30CE
	call sub_23FC                   ; 30D1
	call sub_3C30                   ; 30D4
	call sub_3C1D                   ; 30D7
	ld a,(player_state)             ; 30DA
	cp #0xff                        ; 30DD
	jr z,loc_30E7                   ; 30DF
	call sub_1FA7                   ; 30E1
	call sub_1F87                   ; 30E4
loc_30E7:
	ld a,(player_state)             ; 30E7
	cp #0xfd                        ; 30EA
	jr nz,loc_30F4                  ; 30EC
	call sub_2BE4                   ; 30EE
	call sub_1F9B                   ; 30F1
loc_30F4:
	ld iy,#player_state             ; 30F4
	call sub_1C8A                   ; 30F8
	call sub_1C60                   ; 30FB
	call sub_1C75                   ; 30FE
	call sub_1B57                   ; 3101
	call sub_2AF9                   ; 3104
	ld hl,(util_C0AD)                ; 3107
	ld de,(player_C0CE)                ; 310A
	add hl,de                       ; 310E
	ld (util_C0AD),hl                ; 310F
	ld hl,#vdp_requests2            ; 3112
	set 5,(hl)                      ; 3115
	ld hl,#0x0000                   ; 3117
	ld (util_C0BE),hl                ; 311A
	ld (util_C0C0),hl                ; 311D
	jp loc_3090                     ; 3120

;; ---------------------------------------------------------------- $03569
;; classement : utilitaire partage par task1+task2
	.area _B00_3569
sub_3569::
	push bc                         ; 3569
	ld a,0(iy)                      ; 356A
	or a                            ; 356D
	jp z,loc_35D4                   ; 356E
	ld a,13(iy)                     ; 3571
	and #0x84                       ; 3574
	jp nz,loc_35D4                  ; 3576
	ld a,13(iy)                     ; 3579
	and #0x43                       ; 357C
	jr z,loc_35D4                   ; 357E
	bit 6,a                         ; 3580
	jr z,loc_359C                   ; 3582
	ld a,14(iy)                     ; 3584
	or a                            ; 3587
	jr nz,loc_35D4                  ; 3588
	res 6,13(iy)                    ; 358A
	ld 22(iy),#0x00                 ; 358E
	ld 8(iy),#0x00                  ; 3592
	ld 10(iy),#0x00                 ; 3596
	jr loc_35D4                     ; 359A
loc_359C:
	ld a,13(iy)                     ; 359C
	and #0x01                       ; 359F
	ld h,a                          ; 35A1
	res 0,13(iy)                    ; 35A2
data_35A6::
	res 1,13(iy)                    ; 35A6
	ld a,15(iy)                     ; 35AA
	or a                            ; 35AD
	jr z,loc_35CC                   ; 35AE
	set 6,13(iy)                    ; 35B0
	ld a,h                          ; 35B4
	ld h,#0x00                      ; 35B5
	add hl,hl                       ; 35B7
	or a                            ; 35B8
	jr z,loc_35BC                   ; 35B9
	inc hl                          ; 35BB
loc_35BC:
	add hl,de                       ; 35BC
	ld a,(hl)                       ; 35BD
	ld 22(iy),a                     ; 35BE
	call sub_0546                   ; 35C1
	ld a,(tmp_d3)                   ; 35C4
	ld 14(iy),a                     ; 35C7
	jr loc_35D4                     ; 35CA
loc_35CC:
	set 2,13(iy)                    ; 35CC
	pop bc                          ; 35D0
	or #0xff                        ; 35D1
	ret                             ; 35D3
loc_35D4:
	pop bc                          ; 35D4
	xor a                           ; 35D5
	ret                             ; 35D6

;; ---------------------------------------------------------------- $035D7
;; classement : utilitaire partage par entcmd_72EB+task1+task2+tbl_1D9E
	.area _B00_35D7
sub_35D7::
	cp l                            ; 35D7
	jr c,loc_35DF                   ; 35D8
	cp h                            ; 35DA
	jr nc,loc_35DF                  ; 35DB
	xor a                           ; 35DD
	ret                             ; 35DE
loc_35DF:
	or #0xff                        ; 35DF
	ret                             ; 35E1

;; ---------------------------------------------------------------- $035E2
;; classement : utilitaire partage par task1+task2+task4+tbl_1D9E
	.area _B00_35E2
sub_35E2::
	ld l,2(iy)                      ; 35E2
	ld h,3(iy)                      ; 35E5
	ld de,(util_C0BE)                ; 35E8
	call sub_4984                   ; 35EC
	ld 2(iy),l                      ; 35EF
	ld 3(iy),h                      ; 35F2
	ld e,5(iy)                      ; 35F5
	ld d,6(iy)                      ; 35F8
	ld hl,(util_C0C0)                ; 35FB
	add hl,de                       ; 35FE
	ld 5(iy),l                      ; 35FF
	ld 6(iy),h                      ; 3602
	ret                             ; 3605

;; ---------------------------------------------------------------- $03630
;; classement : utilitaire partage par task0_main+task2
	.area _B00_3630
sub_3630:
	ld hl,#actor_CB07                 ; 3630
	ld de,#util_CB08                 ; 3633
	ld (hl),#0x00                   ; 3636
	ld bc,#0x009f                   ; 3638
	ldir                            ; 363B
	ret                             ; 363D

;; ---------------------------------------------------------------- $0363E
;; classement : utilitaire partage par task0_main+task2
	.area _B00_363E
sub_363E::
	ld hl,#player_CDAF                 ; 363E
	ld de,#util_CDB0                 ; 3641
	ld (hl),#0x00                   ; 3644
	ld bc,#0x013f                   ; 3646
	ldir                            ; 3649
	call sub_3630                   ; 364B
	ret                             ; 364E

;; ---------------------------------------------------------------- $03994
;; classement : utilitaire partage par task1+tbl_1D9E
	.area _B00_3994
sub_3994::
	ld iy,#player_CD37                 ; 3994
	ld b,#0x02                      ; 3998
loc_399A:
	ld a,0(iy)                      ; 399A
	or a                            ; 399D
	jr z,loc_39A3                   ; 399E
	call sub_7292                   ; 39A0
loc_39A3:
	ld de,#0x0028                   ; 39A3
	add iy,de                       ; 39A6
	djnz loc_399A                   ; 39A8
	ret                             ; 39AA
loc_39AB::
	ld a,0(iy)                      ; 39AB
	or 35(iy)                       ; 39AE
	jr z,loc_39B6                   ; 39B1
	call sub_7292                   ; 39B3
loc_39B6:
	ld de,#0x0028                   ; 39B6
	add iy,de                       ; 39B9
	djnz loc_39AB                   ; 39BB
	ret                             ; 39BD

;; ---------------------------------------------------------------- $0474E
;; classement : utilitaire partage par task1+task3+task4
	.area _B01_474E
sub_474E::
	rrc b                           ; 474E
	rla                             ; 4750
	rrc b                           ; 4751
	rla                             ; 4753
	rrc b                           ; 4754
	rla                             ; 4756
	rrc b                           ; 4757
	rla                             ; 4759
	rrc b                           ; 475A
	rla                             ; 475C
	rrc b                           ; 475D
	rla                             ; 475F
	rrc b                           ; 4760
	rla                             ; 4762
	rrc b                           ; 4763
	rla                             ; 4765
	ret                             ; 4766

;; ---------------------------------------------------------------- $0481F
;; classement : utilitaire partage par script_op_6595+task0_main+task1+task2+task3+task4+task5_scene+tbl_1D9E
	.area _B01_481F
sub_481F::
	push bc                         ; 481F
loc_4820:
	ld b,a                          ; 4820
	ld a,#0xff                      ; 4821
	cp (hl)                         ; 4823
	jr z,loc_4832                   ; 4824
	ld a,b                          ; 4826
	cp (hl)                         ; 4827
	jr z,loc_482D                   ; 4828
	inc hl                          ; 482A
	jr loc_4820                     ; 482B
loc_482D:
	ld a,#0x01                      ; 482D
	or a                            ; 482F
	pop bc                          ; 4830
	ret                             ; 4831
loc_4832:
	xor a                           ; 4832
	pop bc                          ; 4833
	ret                             ; 4834

;; ---------------------------------------------------------------- $0485E
;; classement : utilitaire partage par task1+task4
	.area _B01_485E
sub_485E::
	ld de,#util_FFF0                 ; 485E
	jr loc_4866                     ; 4861

;; ---------------------------------------------------------------- $04863
;; classement : utilitaire partage par task1+task4
	.area _B01_4863
sub_4863::
	ld de,#0x0090                   ; 4863
loc_4866:
	call sub_4984                   ; 4866
	ld (tmp_d3),hl                  ; 4869
	ld (map_bank),hl                ; 486C
	ld hl,(scroll_x)                ; 486F
	ld de,#0x0010                   ; 4872
	call sub_56CA                   ; 4875
	ld (tmp_d5),hl                  ; 4878
	ld (util_C0D9),hl                ; 487B
	call sub_4A5C                   ; 487E
	call sub_49F0                   ; 4881
	ld a,(map_bank)                 ; 4884
	ld (tmp_d3),a                   ; 4887
	ld a,(util_C0D9)                 ; 488A
	ld (dbg_C0D4),a                 ; 488D
	call sub_4ABF                   ; 4890
	ld hl,#util_D4D1                 ; 4893
	ld bc,#0x0218                   ; 4896
	call sub_44E4                   ; 4899
	ret                             ; 489C

;; ---------------------------------------------------------------- $0489D
;; classement : utilitaire partage par task1+task4
	.area _B01_489D
sub_489D::
	ld de,#util_FF60                 ; 489D
	jr loc_48A5                     ; 48A0

;; ---------------------------------------------------------------- $048A2
;; classement : utilitaire partage par task1+task4
	.area _B01_48A2
sub_48A2::
	ld de,#0x0006                   ; 48A2
loc_48A5:
	add hl,de                       ; 48A5
	ld (tmp_d5),hl                  ; 48A6
	ld (util_C0D9),hl                ; 48A9
	ld hl,(scroll_y)                ; 48AC
	ld de,#util_FFF0                 ; 48AF
	call sub_4984                   ; 48B2
	ld (tmp_d3),hl                  ; 48B5
	ld (map_bank),hl                ; 48B8
	call sub_4A5C                   ; 48BB
	call sub_49D4                   ; 48BE
	ld a,(map_bank)                 ; 48C1
	ld (tmp_d3),a                   ; 48C4
	ld a,(util_C0D9)                 ; 48C7
	ld (dbg_C0D4),a                 ; 48CA
	call sub_4ABF                   ; 48CD
	ld hl,#util_D4D1                 ; 48D0
	ld bc,#0x1602                   ; 48D3
	call sub_44E4                   ; 48D6
	ret                             ; 48D9

;; ---------------------------------------------------------------- $048DA
;; classement : utilitaire partage par task3+task4+tbl_0B3D
	.area _B01_48DA
sub_48DA::
.if WIDESCREEN
	ld a,#0x0a                      ; 48DA  vue elargie : redessin de tout le tilemap
	ld (bank_slot2_shadow),a        ; 48DC
	ld (MAPPER_SLOT2),a             ; 48DF
	jp wide_full                    ; 48E2
;; Masquage des sprites de la vue elargie (appele par sub_6F03, banque 1 toujours visible).
;; Entree : sprite_C249 = Y, sprite_C24A = X d'un morceau de meta-sprite (8 bits).
;; Sortie : Z = visible, NZ = a masquer. Conserve bc, de, hl.
;; Un morceau qui deborde d'un bord de l'ecran reviendrait de l'autre cote (calcul sur
;; 8 bits) : on compare son X a celui de l'objet (acteur : ACTOR_Y(iy), qui porte le X
;; ecran ; joueur : player_CEF4) pour detecter ce bouclage.
wide_cull::
	ld a,(sprite_C249)              ; 48E5
	cp #0xc0                        ;       sous l'ecran (et jamais $D0, fin de liste)
	jr nc,wcu_out
	ld a,(sprite_C24A)
	cp #0x08                        ;       colonne 0 masquee par le VDP
	jr c,wcu_out
	sub #0x30                       ;       chemin rapide : X dans [48, 208) (fenetre GG),
	cp #0xa0                        ;       un bouclage y est impossible (comme sur GG)
	jr c,wcu_in
	push hl
	push bc
	ld hl,#4
	add hl,sp
	ld a,(hl)                       ;       adresse de retour : quel appelant ?
	ld b,ACTOR_Y(iy)
	cp #<wide_ret_actor
	jr z,wcu_base
	ld a,(player_CEF4)
	ld b,a
wcu_base:
	ld a,(sprite_C24A)
	sub b                           ;       d = X - base ; retenue si X < base
	jr c,wcu_c
	and #0x80                       ;       X >= base mais d < 0 : bouclage
	jr wcu_res
wcu_c:
	cpl                             ;       X < base mais d >= 0 : bouclage
	and #0x80
wcu_res:
	pop bc
	pop hl
	jr nz,wcu_out
wcu_in:
	xor a
	ret
wcu_out:
	or #0xff
	ret
	.ds 99                        ;       (place libre, jusqu'a $4983)
.else
	push ix                         ; 48DA
	ld ix,#0x0000                   ; 48DC
	add ix,sp                       ; 48E0
	ld hl,#util_FFF7                 ; 48E2
	add hl,sp                       ; 48E5
	ld sp,hl                        ; 48E6
	ld -1(ix),#0x0b                 ; 48E7
	ld hl,(scroll_y)                ; 48EB
	ld de,#util_FFF0                 ; 48EE
	call sub_4984                   ; 48F1
	ld -7(ix),l                     ; 48F4
	ld -6(ix),h                     ; 48F7
	ld hl,(scroll_x)                ; 48FA
	ld de,#0x0010                   ; 48FD
	add hl,de                       ; 4900
	bit 7,h                         ; 4901
	jr nz,loc_4908                  ; 4903
	ld hl,#0x0000                   ; 4905
loc_4908:
	ld -9(ix),l                     ; 4908
	ld -8(ix),h                     ; 490B
loc_490E:
	ld l,-7(ix)                     ; 490E
	ld h,-6(ix)                     ; 4911
	ld (tmp_d3),hl                  ; 4914
	ld l,-9(ix)                     ; 4917
	ld h,-8(ix)                     ; 491A
	ld (tmp_d5),hl                  ; 491D
	call sub_4A5C                   ; 4920
	ld -3(ix),l                     ; 4923
	ld -2(ix),h                     ; 4926
	ld a,-7(ix)                     ; 4929
	ld (tmp_d3),a                   ; 492C
	ld a,-9(ix)                     ; 492F
	ld (dbg_C0D4),a                 ; 4932
	call sub_4ABF                   ; 4935
	ld -5(ix),e                     ; 4938
	ld -4(ix),d                     ; 493B
	ld l,-3(ix)                     ; 493E
	ld h,-2(ix)                     ; 4941
	call sub_49F0                   ; 4944
	ld e,-5(ix)                     ; 4947
	ld d,-4(ix)                     ; 494A
	ld hl,#util_D4D1                 ; 494D
	ld bc,#0x0218                   ; 4950
	call sub_44E4                   ; 4953
	ld l,-7(ix)                     ; 4956
	ld h,-6(ix)                     ; 4959
	ld de,#0x0010                   ; 495C
	call sub_4984                   ; 495F
	ld -7(ix),l                     ; 4962
	ld -6(ix),h                     ; 4965
	ld l,-9(ix)                     ; 4968
	ld h,-8(ix)                     ; 496B
	ld de,#0x0000                   ; 496E
	call sub_56CA                   ; 4971
	ld -9(ix),l                     ; 4974
	ld -8(ix),h                     ; 4977
	dec -1(ix)                      ; 497A
	jr nz,loc_490E                  ; 497D
	ld sp,ix                        ; 497F
	pop ix                          ; 4981
	ret                             ; 4983
.endif

;; ---------------------------------------------------------------- $056CA
;; classement : utilitaire partage par task1+task3+task4+tbl_0B3D
	.area _B01_56CA
sub_56CA::
	add hl,de                       ; 56CA
	bit 7,d                         ; 56CB
	jr z,loc_56E0                   ; 56CD
	push hl                         ; 56CF
	ld de,(util_C19A)                ; 56D0
	or a                            ; 56D4
	sbc hl,de                       ; 56D5
	jr nc,loc_56DD                  ; 56D7
	pop hl                          ; 56D9
	ex de,hl                        ; 56DA
	jr loc_56E7                     ; 56DB
loc_56DD:
	pop hl                          ; 56DD
	jr loc_56E7                     ; 56DE
loc_56E0:
	bit 7,h                         ; 56E0
	jr nz,loc_56E7                  ; 56E2
	ld hl,#MAPPER_SLOT2             ; 56E4
loc_56E7:
	ret                             ; 56E7

;; ---------------------------------------------------------------- $05ECA
;; classement : utilitaire partage par task0_main+task2
	.area _B01_5ECA
sub_5ECA::
	ld hl,#actor_CBA7                 ; 5ECA
	ld de,#scene_CBA8                 ; 5ECD
	ld bc,#0x018f                   ; 5ED0
	jr loc_5EE0                     ; 5ED3

;; ---------------------------------------------------------------- $05ED5
;; classement : utilitaire partage par task0_main+task1
	.area _B01_5ED5
sub_5ED5::
	ld hl,#scene_script_ptr         ; 5ED5
	ld de,#util_C900                 ; 5ED8
	ld bc,#0x0207                   ; 5EDB
	jr loc_5EE0                     ; 5EDE
loc_5EE0:
	ld (hl),#0x00                   ; 5EE0
	ldir                            ; 5EE2
	ret                             ; 5EE4

;; ---------------------------------------------------------------- $5EC09
;; classement : utilitaire partage par task0_main+tbl_b23_970D
	.area _B23_AC09
sub_b23_AC09::
	ld hl,#tmp_d5                   ; AC09
	ld (hl),a                       ; AC0C
	xor a                           ; AC0D
	rrd                             ; AC0E
	ld b,a                          ; AC10
	add a,#0x20                     ; AC11
	ld c,a                          ; AC13
	ld a,b                          ; AC14
	rrd                             ; AC15
	or a                            ; AC17
	jr nz,loc_b23_AC1E              ; AC18
	ld a,#0x1f                      ; AC1A
	jr loc_b23_AC20                 ; AC1C
loc_b23_AC1E:
	add a,#0x20                     ; AC1E
loc_b23_AC20:
	push bc                         ; AC20
	call sub_b23_AC2A               ; AC21
	pop bc                          ; AC24
	ld a,c                          ; AC25
	call sub_b23_AC2A               ; AC26
	ret                             ; AC29

;; ---------------------------------------------------------------- $5EC2A
;; classement : utilitaire partage par task0_main+tbl_b23_970D
	.area _B23_AC2A
sub_b23_AC2A:
	ld h,#0x11                      ; AC2A
	ld l,a                          ; AC2C
	ld (de),a                       ; AC2D
	inc de                          ; AC2E
	ld a,h                          ; AC2F
	ld (de),a                       ; AC30
	inc de                          ; AC31
	ret                             ; AC32
data_b23_AC33::
	.db 0x59, 0xac, 0x79, 0xac, 0x9b, 0xac, 0xbd, 0xac, 0xdf, 0xac, 0x01, 0xad, 0x23 ; AC33
	.db 0xad, 0x45, 0xad, 0x67, 0xad, 0x89, 0xad, 0xab, 0xad, 0xcd, 0xad, 0xef, 0xad, 0x11, 0xae, 0x33 ; AC40
	.db 0xae, 0x55, 0xae, 0x55, 0xac, 0x01, 0x00, 0x01, 0xff, 0x00, 0x00, 0x00, 0x01, 0x00, 0x02, 0x00 ; AC50
	.db 0x03, 0x00, 0x04, 0x00, 0x05, 0x00, 0x06, 0x00, 0x07, 0x00, 0x08, 0x00, 0x09, 0x00, 0x0a, 0x00 ; AC60
	.db 0x0b, 0x00, 0x0c, 0x00, 0x0d, 0x00, 0x0e, 0x00, 0x0f, 0x01, 0x00, 0x03, 0x07, 0x01, 0x01, 0xff ; AC70
	.ds 16                          ; AC80  rempli par $FF au build
	.db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01, 0x15, 0x02, 0x00, 0x02 ; AC90
	.db 0x01, 0x02, 0x02, 0x02, 0x03, 0x01, 0x15, 0x02, 0x04, 0x01, 0x15, 0x02, 0x05, 0x02, 0x06, 0xff ; ACA0
	.db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01, 0x16, 0x02 ; ACB0
	.db 0x0f, 0x02, 0x10, 0x02, 0x11, 0x01, 0x16, 0x02, 0x12, 0x02, 0x13, 0xff, 0xff, 0xff, 0xff, 0xff ; ACC0
	.db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01 ; ACD0
	.db 0x17, 0x02, 0x22, 0x02, 0x23, 0x01, 0x11, 0x01, 0x13, 0x03, 0x24, 0x01, 0x17, 0x03, 0x24, 0xff ; ACE0
	.ds 16                          ; ACF0  rempli par $FF au build
	.db 0xff, 0x01, 0x18, 0x02, 0x0d, 0x01, 0x02, 0x01, 0x13, 0x03, 0x0e, 0x01, 0x18, 0x03, 0x0e, 0x01 ; AD00
	.db 0x03, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; AD10
	.db 0xff, 0xff, 0xff, 0x01, 0x19, 0x02, 0x08, 0x02, 0x09, 0x02, 0x0a, 0x02, 0x0b, 0x01, 0x19, 0x02 ; AD20
	.db 0x0c, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; AD30
	.db 0xff, 0xff, 0xff, 0xff, 0xff, 0x01, 0x1a, 0x01, 0x04, 0x01, 0x13, 0x03, 0x25, 0x01, 0x1a, 0x03 ; AD40
	.db 0x25, 0x01, 0x05, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; AD50
	.db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01, 0x1b, 0x02, 0x14, 0x02, 0x15, 0x02, 0x16, 0x02 ; AD60
	.db 0x17, 0x02, 0x18, 0x02, 0x19, 0x02, 0x1a, 0x02, 0x1b, 0x02, 0x1c, 0x01, 0x1b, 0x02, 0x1d, 0xff ; AD70
	.db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01, 0x1c, 0x02, 0x1e, 0x02, 0x1f, 0x01 ; AD80
	.db 0x1c, 0x02, 0x20, 0x01, 0x1c, 0x02, 0x21, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; AD90
	.db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01, 0x1d, 0x02, 0x26, 0x02 ; ADA0
	.db 0x27, 0x02, 0x28, 0x01, 0x11, 0x01, 0x13, 0x03, 0x29, 0x01, 0x1d, 0x03, 0x29, 0xff, 0xff, 0xff ; ADB0
	.db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01, 0x1e, 0x04 ; ADC0
	.db 0x2a, 0x01, 0x06, 0x01, 0x13, 0x03, 0x2b, 0x01, 0x1e, 0x03, 0x2b, 0x01, 0x07, 0x03, 0x2c, 0x01 ; ADD0
	.db 0x08, 0x03, 0x37, 0x01, 0x09, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x01 ; ADE0
	.db 0x1f, 0x01, 0x0a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; ADF0
	.ds 16                          ; AE00  rempli par $FF au build
	.db 0xff, 0x01, 0x20, 0x02, 0x2d, 0x02, 0x2e, 0x02, 0x2f, 0x01, 0x11, 0x01, 0x13, 0x03, 0x30, 0x01 ; AE10
	.db 0x20, 0x03, 0x30, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; AE20
	.db 0xff, 0xff, 0xff, 0x01, 0x21, 0x02, 0x31, 0x01, 0x0b, 0x01, 0x13, 0x03, 0x32, 0x01, 0x0c, 0x03 ; AE30
	.db 0x33, 0x01, 0x21, 0x03, 0x32, 0x01, 0x0c, 0x03, 0x33, 0x03, 0x38, 0x01, 0x0d, 0xff, 0xff, 0xff ; AE40
	.db 0xff, 0xff, 0xff, 0xff, 0xff, 0x01, 0x22, 0x01, 0x0e, 0x03, 0x34, 0x01, 0x0f, 0x03, 0x35, 0x01 ; AE50
	.db 0x10, 0x03, 0x36, 0x01, 0x22, 0x03, 0x34, 0x01, 0x0f, 0x03, 0x35, 0x01, 0x10, 0x03, 0x36, 0x01 ; AE60
	.db 0x12, 0x03, 0x39, 0xff, 0xff, 0xff, 0xff, 0x04, 0x89, 0x00, 0x03, 0x07, 0x0f, 0x3f, 0x3f, 0x7f ; AE70
	.db 0xff, 0x7e, 0x07, 0xff, 0x8c, 0x00, 0xc0, 0xe0, 0xf0, 0xfc, 0xfc, 0xfe, 0xff, 0x0f, 0x0f, 0x1f ; AE80
	.db 0x1f, 0x04, 0x3f, 0x08, 0xff, 0x02, 0xf0, 0x02, 0xf8, 0x04, 0xfc, 0x04, 0x3f, 0x02, 0x1f, 0x02 ; AE90
	.db 0x0f, 0x04, 0xfc, 0x02, 0xf8, 0x02, 0xf0, 0x88, 0xff, 0x7f, 0x3f, 0x3f, 0x0f, 0x07, 0x03, 0x00 ; AEA0
	.db 0x07, 0xff, 0x89, 0x7e, 0xff, 0xfe, 0xfc, 0xfc, 0xf0, 0xe0, 0xc0, 0x00, 0x00, 0x89, 0x00, 0x03 ; AEB0
	.db 0x07, 0x0f, 0x3f, 0x3f, 0x7f, 0xff, 0x7e, 0x07, 0xff, 0x8c, 0x00, 0xc0, 0xe0, 0xf0, 0xfc, 0xfc ; AEC0
	.db 0xfe, 0xff, 0x0f, 0x0f, 0x1f, 0x1f, 0x04, 0x3f, 0x08, 0xff, 0x02, 0xf0, 0x02, 0xf8, 0x04, 0xfc ; AED0
	.db 0x04, 0x3f, 0x02, 0x1f, 0x02, 0x0f, 0x04, 0xfc, 0x02, 0xf8, 0x02, 0xf0, 0x88, 0xff, 0x7f, 0x3f ; AEE0
	.db 0x3f, 0x0f, 0x07, 0x03, 0x00, 0x07, 0xff, 0x89, 0x7e, 0xff, 0xfe, 0xfc, 0xfc, 0xf0, 0xe0, 0xc0 ; AEF0
	.db 0x00, 0x00, 0x58, 0x00, 0x00, 0x58, 0x00, 0x00, 0x04, 0x8a, 0x44, 0x8f, 0x9f, 0x9f, 0x5f, 0x3d ; AF00
	.db 0x7d, 0x7b, 0x38, 0x7d, 0x06, 0xff, 0x96, 0xf8, 0x38, 0x7c, 0xc6, 0x23, 0xf1, 0xe7, 0xfe, 0xee ; AF10
	.db 0xee, 0xea, 0xda, 0xd3, 0xf1, 0xf0, 0xf8, 0xfd, 0xcf, 0xfb, 0x63, 0x07, 0x8f, 0x03, 0xff, 0x91 ; AF20
	.db 0xf7, 0xb7, 0xdb, 0xcb, 0xcf, 0x8f, 0x9f, 0xfc, 0xfc, 0xbd, 0xdd, 0x79, 0x03, 0x06, 0x0d, 0x5b ; AF30
	.db 0xfe, 0x03, 0xff, 0x88, 0x3f, 0xff, 0xe7, 0xff, 0x7f, 0xfd, 0xfb, 0xde, 0x03, 0xc0, 0x82, 0x0b ; AF40
	.db 0x1f, 0x05, 0x3f, 0x83, 0x1c, 0xc7, 0xe3, 0x04, 0xf3, 0x83, 0x73, 0xe3, 0xc0, 0x04, 0x80, 0x83 ; AF50
	.db 0x60, 0x90, 0xf8, 0x00, 0xb9, 0x00, 0x0f, 0x1f, 0x18, 0x10, 0x32, 0x72, 0x46, 0x38, 0x4c, 0x87 ; AF60
	.db 0x87, 0xa7, 0xf7, 0xf7, 0x8f, 0x38, 0x28, 0x6c, 0xc6, 0x23, 0x51, 0x27, 0x0e, 0xdf, 0x9f, 0x9b ; AF70
	.db 0xbb, 0xb3, 0xf1, 0xf0, 0xd8, 0xff, 0x4f, 0xbf, 0xff, 0xff, 0xfd, 0xff, 0xff, 0x9b, 0xf9, 0xf9 ; AF80
	.db 0xdd, 0xcd, 0xcf, 0x8f, 0x9b, 0x8c, 0xd4, 0xf5, 0xfd, 0x79, 0x03, 0x07, 0x0e, 0x7f, 0x03, 0xff ; AF90
	.db 0x89, 0x7f, 0xdf, 0xff, 0xe7, 0xf1, 0xeb, 0x6f, 0xff, 0xde, 0x03, 0xc0, 0x83, 0x0d, 0x13, 0x37 ; AFA0
	.db 0x04, 0x3f, 0x83, 0x1c, 0xc7, 0xe3, 0x04, 0xf3, 0x83, 0x73, 0xe3, 0xc0, 0x04, 0x80, 0x83, 0xe0 ; AFB0
	.db 0x60, 0xf8, 0x00, 0x94, 0x00, 0x0f, 0x19, 0x10, 0x10, 0x30, 0x60, 0x42, 0x38, 0x44, 0x83, 0x83 ; AFC0
	.db 0xa3, 0xf3, 0xf3, 0x83, 0x38, 0x38, 0x7c, 0xfe, 0x03, 0xff, 0xae, 0xfe, 0xce, 0x8e, 0x8a, 0x9a ; AFD0
	.db 0x93, 0xf1, 0xf0, 0xd8, 0xf5, 0x7f, 0x3b, 0x03, 0x07, 0x8d, 0xff, 0xff ; AFE0

;; ---------------------------------------------------------------- $5EFEC
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B23_AFEC
sub_b23_AFEC:
	ei                              ; AFEC
	pop af                          ; AFED
	or c                            ; AFEE
	exx                             ; AFEF
	ret                             ; AFF0
	.db 0xcf, 0x8f, 0x9b, 0x8c, 0x94, 0x95, 0xcd, 0x79, 0x03, 0x06, 0x0c, 0x43, 0xfe, 0xe7, 0xff ; AFF1
	.db 0x7f, 0x1f, 0xff, 0xe7, 0xf1, 0x69, 0x69, 0xf3, 0xde, 0x03, 0xc0, 0x83, 0x09, 0x13, 0x37, 0x04 ; B000
	.db 0x3f, 0x83, 0x1c, 0xc7, 0xe3, 0x04, 0xf3, 0x83, 0x73, 0xe3, 0xc0, 0x04, 0x80, 0x83, 0x60, 0x00 ; B010
	.db 0xf8, 0x00, 0x02, 0x00, 0x88, 0x06, 0x08, 0x00, 0x02, 0x12, 0x04, 0x00, 0x08, 0x05, 0x04, 0x81 ; B020
	.db 0x0c, 0x08, 0x00, 0x03, 0x11, 0x82, 0x21, 0x20, 0x03, 0x00, 0x86, 0x0a, 0x00, 0x84, 0xfc, 0xf8 ; B030
	.db 0x70, 0x03, 0x00, 0x84, 0x08, 0x48, 0x04, 0x04, 0x04, 0x00, 0x8d, 0x40, 0x60, 0x30, 0x00, 0x00 ; B040
	.db 0x01, 0x03, 0x3c, 0x01, 0x00, 0x00, 0x80, 0xe0, 0x03, 0x00, 0x83, 0x82, 0x86, 0x0c, 0x04, 0x00 ; B050
	.db 0x83, 0x06, 0x0c, 0x08, 0x12, 0x00, 0x83, 0x80, 0xf0, 0x00, 0x00 ; B060
data_b23_B06B::
	.db 0x66, 0x81, 0xff, 0x04, 0x08 ; B06B
	.db 0x00, 0x00, 0x08, 0x00, 0x00, 0x08, 0x00, 0x00, 0x08, 0x00, 0x00 ; B070
data_b23_B07B::
	.db 0xe1, 0xc1, 0xd3, 0xc0, 0xd3 ; B07B
	.db 0xc0, 0xe4, 0xc1, 0xe5, 0xc1, 0xd3, 0xc0, 0xe7, 0xc1, 0xd3, 0xc0, 0xd3, 0xc0, 0xea, 0xc1, 0xeb ; B080
	.db 0xc1, 0xec, 0xc1, 0xed, 0xc1, 0xee, 0xc1, 0xd3, 0xc0 ; B090
data_b23_B099::
	.db 0x81, 0x81, 0x81, 0x81, 0x97, 0x97, 0x97 ; B099
	.db 0x86, 0x85, 0x85, 0x85, 0x85, 0x85, 0x87, 0x87, 0x84, 0x84, 0x84, 0x97, 0x97, 0x84, 0x84, 0x84 ; B0A0
	.db 0x84, 0x84, 0x84, 0x84, 0x97, 0x97, 0x97, 0x83, 0x83, 0x83, 0x97, 0x81, 0x81, 0x86, 0x88, 0x81 ; B0B0
	.db 0x81, 0x81, 0x86, 0x00, 0x89, 0x89, 0x81, 0x81, 0x81, 0x86, 0x83, 0x8a, 0x00, 0x00, 0x00, 0x00 ; B0C0
	.db 0x00, 0x83, 0x8c, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; B0D0
	.ds 16                          ; B0E0  rempli par $FF au build
	.ds 16                          ; B0F0  rempli par $FF au build
	.ds 16                          ; B100  rempli par $FF au build
	.ds 16                          ; B110  rempli par $FF au build
	.ds 16                          ; B120  rempli par $FF au build
	.ds 16                          ; B130  rempli par $FF au build
	.ds 15                          ; B140  rempli par $FF au build
data_b23_B14F::
	.db 0xff                        ; B14F
	.ds 16                          ; B150  rempli par $FF au build
	.ds 16                          ; B160  rempli par $FF au build
	.ds 16                          ; B170  rempli par $FF au build
	.ds 16                          ; B180  rempli par $FF au build
	.ds 16                          ; B190  rempli par $FF au build
	.ds 16                          ; B1A0  rempli par $FF au build
	.ds 16                          ; B1B0  rempli par $FF au build
	.ds 16                          ; B1C0  rempli par $FF au build
	.ds 16                          ; B1D0  rempli par $FF au build
	.ds 16                          ; B1E0  rempli par $FF au build
	.ds 16                          ; B1F0  rempli par $FF au build
	.ds 16                          ; B200  rempli par $FF au build
	.ds 16                          ; B210  rempli par $FF au build
	.ds 16                          ; B220  rempli par $FF au build
	.ds 16                          ; B230  rempli par $FF au build
	.ds 16                          ; B240  rempli par $FF au build
	.ds 16                          ; B250  rempli par $FF au build
	.ds 16                          ; B260  rempli par $FF au build
	.ds 16                          ; B270  rempli par $FF au build
	.ds 16                          ; B280  rempli par $FF au build
	.ds 16                          ; B290  rempli par $FF au build
	.ds 16                          ; B2A0  rempli par $FF au build
	.ds 16                          ; B2B0  rempli par $FF au build
	.ds 16                          ; B2C0  rempli par $FF au build
	.ds 16                          ; B2D0  rempli par $FF au build
	.ds 16                          ; B2E0  rempli par $FF au build
	.ds 16                          ; B2F0  rempli par $FF au build
	.ds 16                          ; B300  rempli par $FF au build
	.ds 16                          ; B310  rempli par $FF au build
	.ds 16                          ; B320  rempli par $FF au build
	.ds 16                          ; B330  rempli par $FF au build
	.ds 16                          ; B340  rempli par $FF au build
	.ds 16                          ; B350  rempli par $FF au build
	.ds 16                          ; B360  rempli par $FF au build
	.ds 16                          ; B370  rempli par $FF au build
	.ds 16                          ; B380  rempli par $FF au build
	.ds 16                          ; B390  rempli par $FF au build
	.ds 16                          ; B3A0  rempli par $FF au build
	.ds 16                          ; B3B0  rempli par $FF au build
	.ds 16                          ; B3C0  rempli par $FF au build
	.ds 16                          ; B3D0  rempli par $FF au build
	.ds 16                          ; B3E0  rempli par $FF au build
	.ds 16                          ; B3F0  rempli par $FF au build
	.ds 16                          ; B400  rempli par $FF au build
	.ds 16                          ; B410  rempli par $FF au build
	.ds 16                          ; B420  rempli par $FF au build
	.ds 16                          ; B430  rempli par $FF au build
	.ds 16                          ; B440  rempli par $FF au build
	.ds 16                          ; B450  rempli par $FF au build
	.ds 16                          ; B460  rempli par $FF au build
	.ds 16                          ; B470  rempli par $FF au build
	.ds 16                          ; B480  rempli par $FF au build
	.ds 16                          ; B490  rempli par $FF au build
	.ds 16                          ; B4A0  rempli par $FF au build
	.ds 16                          ; B4B0  rempli par $FF au build
	.ds 16                          ; B4C0  rempli par $FF au build
	.ds 16                          ; B4D0  rempli par $FF au build
	.ds 16                          ; B4E0  rempli par $FF au build
	.ds 16                          ; B4F0  rempli par $FF au build
	.ds 16                          ; B500  rempli par $FF au build
	.ds 16                          ; B510  rempli par $FF au build
	.ds 16                          ; B520  rempli par $FF au build
	.ds 16                          ; B530  rempli par $FF au build
	.ds 16                          ; B540  rempli par $FF au build
	.ds 16                          ; B550  rempli par $FF au build
	.ds 16                          ; B560  rempli par $FF au build
	.ds 16                          ; B570  rempli par $FF au build
	.ds 16                          ; B580  rempli par $FF au build
	.ds 16                          ; B590  rempli par $FF au build
	.ds 16                          ; B5A0  rempli par $FF au build
	.ds 16                          ; B5B0  rempli par $FF au build
	.ds 16                          ; B5C0  rempli par $FF au build
	.ds 16                          ; B5D0  rempli par $FF au build
	.ds 16                          ; B5E0  rempli par $FF au build
	.ds 16                          ; B5F0  rempli par $FF au build
	.ds 16                          ; B600  rempli par $FF au build
	.ds 16                          ; B610  rempli par $FF au build
	.ds 16                          ; B620  rempli par $FF au build
	.ds 16                          ; B630  rempli par $FF au build
	.ds 16                          ; B640  rempli par $FF au build
	.ds 16                          ; B650  rempli par $FF au build
	.ds 16                          ; B660  rempli par $FF au build
	.ds 16                          ; B670  rempli par $FF au build
	.ds 16                          ; B680  rempli par $FF au build
	.ds 16                          ; B690  rempli par $FF au build
	.ds 16                          ; B6A0  rempli par $FF au build
	.ds 16                          ; B6B0  rempli par $FF au build
	.ds 16                          ; B6C0  rempli par $FF au build
	.ds 16                          ; B6D0  rempli par $FF au build
	.ds 16                          ; B6E0  rempli par $FF au build
	.ds 16                          ; B6F0  rempli par $FF au build
	.ds 16                          ; B700  rempli par $FF au build
	.ds 16                          ; B710  rempli par $FF au build
	.ds 16                          ; B720  rempli par $FF au build
	.ds 16                          ; B730  rempli par $FF au build
	.ds 16                          ; B740  rempli par $FF au build
	.ds 16                          ; B750  rempli par $FF au build
	.ds 16                          ; B760  rempli par $FF au build
	.ds 16                          ; B770  rempli par $FF au build
	.ds 16                          ; B780  rempli par $FF au build
	.ds 16                          ; B790  rempli par $FF au build
	.ds 16                          ; B7A0  rempli par $FF au build
	.ds 16                          ; B7B0  rempli par $FF au build
	.ds 16                          ; B7C0  rempli par $FF au build
	.ds 16                          ; B7D0  rempli par $FF au build
	.ds 16                          ; B7E0  rempli par $FF au build
	.ds 16                          ; B7F0  rempli par $FF au build
	.ds 16                          ; B800  rempli par $FF au build
	.ds 16                          ; B810  rempli par $FF au build
	.ds 16                          ; B820  rempli par $FF au build
	.ds 16                          ; B830  rempli par $FF au build
	.ds 16                          ; B840  rempli par $FF au build
	.ds 16                          ; B850  rempli par $FF au build
	.ds 16                          ; B860  rempli par $FF au build
	.ds 16                          ; B870  rempli par $FF au build
	.ds 16                          ; B880  rempli par $FF au build
	.ds 16                          ; B890  rempli par $FF au build
	.ds 16                          ; B8A0  rempli par $FF au build
	.ds 16                          ; B8B0  rempli par $FF au build
	.ds 16                          ; B8C0  rempli par $FF au build
	.ds 16                          ; B8D0  rempli par $FF au build
	.ds 16                          ; B8E0  rempli par $FF au build
	.ds 16                          ; B8F0  rempli par $FF au build
	.ds 16                          ; B900  rempli par $FF au build
	.ds 16                          ; B910  rempli par $FF au build
	.ds 16                          ; B920  rempli par $FF au build
	.ds 16                          ; B930  rempli par $FF au build
	.ds 16                          ; B940  rempli par $FF au build
	.ds 16                          ; B950  rempli par $FF au build
	.ds 16                          ; B960  rempli par $FF au build
	.ds 16                          ; B970  rempli par $FF au build
	.ds 16                          ; B980  rempli par $FF au build
	.ds 16                          ; B990  rempli par $FF au build
	.ds 16                          ; B9A0  rempli par $FF au build
	.ds 16                          ; B9B0  rempli par $FF au build
	.ds 16                          ; B9C0  rempli par $FF au build
	.ds 16                          ; B9D0  rempli par $FF au build
	.ds 16                          ; B9E0  rempli par $FF au build
	.ds 16                          ; B9F0  rempli par $FF au build
	.ds 16                          ; BA00  rempli par $FF au build
	.ds 16                          ; BA10  rempli par $FF au build
	.ds 16                          ; BA20  rempli par $FF au build
	.ds 16                          ; BA30  rempli par $FF au build
	.ds 16                          ; BA40  rempli par $FF au build
	.ds 16                          ; BA50  rempli par $FF au build
	.ds 16                          ; BA60  rempli par $FF au build
	.ds 16                          ; BA70  rempli par $FF au build
	.ds 16                          ; BA80  rempli par $FF au build
	.ds 16                          ; BA90  rempli par $FF au build
	.ds 16                          ; BAA0  rempli par $FF au build
	.ds 16                          ; BAB0  rempli par $FF au build
	.ds 16                          ; BAC0  rempli par $FF au build
	.ds 16                          ; BAD0  rempli par $FF au build
	.ds 16                          ; BAE0  rempli par $FF au build
	.ds 16                          ; BAF0  rempli par $FF au build
	.ds 16                          ; BB00  rempli par $FF au build
	.ds 16                          ; BB10  rempli par $FF au build
	.ds 16                          ; BB20  rempli par $FF au build
	.ds 16                          ; BB30  rempli par $FF au build
	.ds 16                          ; BB40  rempli par $FF au build
	.ds 16                          ; BB50  rempli par $FF au build
	.ds 16                          ; BB60  rempli par $FF au build
	.ds 16                          ; BB70  rempli par $FF au build
	.ds 16                          ; BB80  rempli par $FF au build
	.ds 16                          ; BB90  rempli par $FF au build
	.ds 16                          ; BBA0  rempli par $FF au build
	.ds 16                          ; BBB0  rempli par $FF au build
	.ds 16                          ; BBC0  rempli par $FF au build
	.ds 16                          ; BBD0  rempli par $FF au build
	.ds 16                          ; BBE0  rempli par $FF au build
	.ds 16                          ; BBF0  rempli par $FF au build
	.ds 16                          ; BC00  rempli par $FF au build
	.ds 16                          ; BC10  rempli par $FF au build
	.ds 16                          ; BC20  rempli par $FF au build
	.ds 16                          ; BC30  rempli par $FF au build
	.ds 16                          ; BC40  rempli par $FF au build
	.ds 16                          ; BC50  rempli par $FF au build
	.ds 16                          ; BC60  rempli par $FF au build
	.ds 16                          ; BC70  rempli par $FF au build
	.ds 16                          ; BC80  rempli par $FF au build
	.ds 16                          ; BC90  rempli par $FF au build
	.ds 16                          ; BCA0  rempli par $FF au build
	.ds 16                          ; BCB0  rempli par $FF au build
	.ds 16                          ; BCC0  rempli par $FF au build
	.ds 16                          ; BCD0  rempli par $FF au build
	.ds 16                          ; BCE0  rempli par $FF au build
	.ds 16                          ; BCF0  rempli par $FF au build
	.ds 16                          ; BD00  rempli par $FF au build
	.ds 16                          ; BD10  rempli par $FF au build
	.ds 16                          ; BD20  rempli par $FF au build
	.ds 16                          ; BD30  rempli par $FF au build
	.ds 16                          ; BD40  rempli par $FF au build
	.ds 16                          ; BD50  rempli par $FF au build
	.ds 16                          ; BD60  rempli par $FF au build
	.ds 16                          ; BD70  rempli par $FF au build
	.ds 16                          ; BD80  rempli par $FF au build
	.ds 16                          ; BD90  rempli par $FF au build
	.ds 16                          ; BDA0  rempli par $FF au build
	.ds 16                          ; BDB0  rempli par $FF au build
	.ds 16                          ; BDC0  rempli par $FF au build
	.ds 16                          ; BDD0  rempli par $FF au build
	.ds 16                          ; BDE0  rempli par $FF au build
	.ds 16                          ; BDF0  rempli par $FF au build
	.ds 16                          ; BE00  rempli par $FF au build
	.ds 16                          ; BE10  rempli par $FF au build
	.ds 16                          ; BE20  rempli par $FF au build
	.ds 16                          ; BE30  rempli par $FF au build
	.ds 16                          ; BE40  rempli par $FF au build
	.ds 16                          ; BE50  rempli par $FF au build
	.ds 16                          ; BE60  rempli par $FF au build
	.ds 16                          ; BE70  rempli par $FF au build
	.ds 16                          ; BE80  rempli par $FF au build
	.ds 16                          ; BE90  rempli par $FF au build
	.ds 16                          ; BEA0  rempli par $FF au build
	.ds 16                          ; BEB0  rempli par $FF au build
	.ds 16                          ; BEC0  rempli par $FF au build
	.ds 16                          ; BED0  rempli par $FF au build
	.ds 16                          ; BEE0  rempli par $FF au build
	.ds 16                          ; BEF0  rempli par $FF au build
	.ds 16                          ; BF00  rempli par $FF au build
	.ds 16                          ; BF10  rempli par $FF au build
	.ds 16                          ; BF20  rempli par $FF au build
	.ds 16                          ; BF30  rempli par $FF au build
	.ds 16                          ; BF40  rempli par $FF au build
	.ds 16                          ; BF50  rempli par $FF au build
	.ds 16                          ; BF60  rempli par $FF au build
	.ds 16                          ; BF70  rempli par $FF au build
	.ds 16                          ; BF80  rempli par $FF au build
	.ds 16                          ; BF90  rempli par $FF au build
	.ds 16                          ; BFA0  rempli par $FF au build
	.ds 16                          ; BFB0  rempli par $FF au build
	.ds 16                          ; BFC0  rempli par $FF au build
	.ds 16                          ; BFD0  rempli par $FF au build
	.ds 16                          ; BFE0  rempli par $FF au build
	.ds 16                          ; BFF0  rempli par $FF au build
