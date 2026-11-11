;; game/collision.s
;; Collisions avec le decor : lecture de metatuile, handlers par type de tuile ($2539) et d'interaction ($1D9E).
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $0050A
;; classement : atteinte uniquement par tbl_1D9E
	.area _B00_050A
sub_050A::
	ld a,#0x94                      ; 050A
	jp sub_062D                     ; 050C

;; ---------------------------------------------------------------- $0050F
;; classement : atteinte uniquement par tbl_1D9E
	.area _B00_050F
sub_050F::
	ld a,#0xaf                      ; 050F
	jp loc_060D                     ; 0511

;; ---------------------------------------------------------------- $00514
;; classement : atteinte uniquement par tbl_1D9E
	.area _B00_0514
sub_0514::
	ld a,#0xae                      ; 0514
	jp loc_060D                     ; 0516

;; ---------------------------------------------------------------- $00519
;; classement : atteinte uniquement par tbl_1D9E
	.area _B00_0519
sub_0519::
	ld a,#0xad                      ; 0519
	jp loc_060D                     ; 051B

;; ---------------------------------------------------------------- $00523
;; classement : atteinte uniquement par tbl_1D9E
	.area _B00_0523
sub_0523::
	ld a,#0xbb                      ; 0523
	jp loc_060D                     ; 0525

;; ---------------------------------------------------------------- $00528
;; classement : atteinte uniquement par tbl_1D9E
	.area _B00_0528
sub_0528::
	ld a,#0x98                      ; 0528
	jp loc_0627                     ; 052A

;; ---------------------------------------------------------------- $0052D
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_052D
sub_052D::
	ld a,#0xab                      ; 052D
	jp loc_060D                     ; 052F

;; ---------------------------------------------------------------- $00532
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0532
sub_0532::
	ld a,#0xa3                      ; 0532
	jp loc_060D                     ; 0534

;; ---------------------------------------------------------------- $0053C
;; classement : atteinte uniquement par tbl_1D9E
	.area _B00_053C
sub_053C::
	ld a,#0xad                      ; 053C
	jp loc_0627                     ; 053E

;; ---------------------------------------------------------------- $0064F
;; classement : atteinte uniquement par tbl_2539
	.area _B00_064F
sub_064F::
	ld a,#0xa3                      ; 064F
	jr loc_0627                     ; 0651

;; ---------------------------------------------------------------- $01EDD
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_1EDD
sub_1EDD:
	pop bc                          ; 1EDD
	ex (sp),hl                      ; 1EDE
	pop bc                          ; 1EDF
	out (0xc0),a                    ; 1EE0
	push hl                         ; 1EE2
	pop bc                          ; 1EE3
	and #0xc1                       ; 1EE4
	out (0xc0),a                    ; 1EE6
	ret pe                          ; 1EE8
	pop bc                          ; 1EE9
	out (0xc0),a                    ; 1EEA
	out (0xc0),a                    ; 1EEC
	out (0xc0),a                    ; 1EEE
	out (0xc0),a                    ; 1EF0
	out (0xc0),a                    ; 1EF2
	out (0xc0),a                    ; 1EF4
	out (0xc0),a                    ; 1EF6
loc_1EF8::
	ld a,(player_CEFE)                 ; 1EF8
	inc a                           ; 1EFB
	jr loc_1F03                     ; 1EFC
loc_1EFE::
	ld a,(player_CEFE)                 ; 1EFE
	add a,#0x02                     ; 1F01
loc_1F03:
	push af                         ; 1F03
	call sub_0519                   ; 1F04
	pop af                          ; 1F07
	ld 0(ix),#0x00                  ; 1F08
	ld (player_CEFE),a                 ; 1F0C
	cp #0x04                        ; 1F0F
	ret c                           ; 1F11
	ld a,#0x03                      ; 1F12
	ld (player_CEFE),a                 ; 1F14
	ret                             ; 1F17
loc_1F18::
	ld 0(ix),#0x00                  ; 1F18
	ld a,21(ix)                     ; 1F1C
data_1F1F::
	sub #0x14                       ; 1F1F
data_1F21::
	ld (player_C1F2),a                 ; 1F21
data_1F24::
	call sub_1F2B                   ; 1F24
	call sub_0519                   ; 1F27
	ret                             ; 1F2A

;; ---------------------------------------------------------------- $027CC
;; classement : atteinte uniquement par tbl_1D9E
	.area _B00_27CC
sub_27CC::
	add a,#0x01                     ; 27CC
	daa                             ; 27CE
	ret nc                          ; 27CF
	ld a,#0x99                      ; 27D0
	ret                             ; 27D2

;; ---------------------------------------------------------------- $027D3
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_27D3
sub_27D3::
	ld a,(player_C0CC)                 ; 27D3
	call sub_1B47                   ; 27D6
	jr z,loc_27E2                   ; 27D9
	ld a,(player_C0CD)                 ; 27DB
	call sub_1B47                   ; 27DE
	ret nz                          ; 27E1
loc_27E2:
	ld a,(scroll_y)                 ; 27E2
	and #0x07                       ; 27E5
	ld l,a                          ; 27E7
	ld h,#0x00                      ; 27E8
	ld de,#sub_2807                 ; 27EA
	add hl,de                       ; 27ED
	ld a,(hl)                       ; 27EE
	ld e,a                          ; 27EF
	ld a,(player_CEF1)                 ; 27F0
	ld d,a                          ; 27F3
	and #0xf8                       ; 27F4
	or e                            ; 27F6
	cp d                            ; 27F7
	jr c,loc_27FE                   ; 27F8
	jr z,loc_27FE                   ; 27FA
	sub #0x08                       ; 27FC
loc_27FE:
	sub d                           ; 27FE
	ld (player_CF00),a                 ; 27FF
	xor a                           ; 2802
	ld (player_CEFF),a                 ; 2803
	ret                             ; 2806

;; ---------------------------------------------------------------- $02807
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_2807
sub_2807:
	ld b,#0x05                      ; 2807
	inc b                           ; 2809
	inc bc                          ; 280A
	ld (bc),a                       ; 280B
	ld bc,#0x0700                   ; 280C

;; ---------------------------------------------------------------- $029C5
;; classement : lecture de la tuile/metatuile sous une position (banque 10)
	.area _B00_29C5
sub_29C5::
	ld a,2(iy)                      ; 29C5
	add a,b                         ; 29C8
	ld (tmp_d3),a                   ; 29C9
	ld (coll_C199),a                 ; 29CC
	cp l                            ; 29CF
	jr nc,loc_29D4                  ; 29D0
	jr loc_29D7                     ; 29D2
loc_29D4:
	cp h                            ; 29D4
	jr c,loc_29DA                   ; 29D5
loc_29D7::
	or #0xff                        ; 29D7
	ret                             ; 29D9
loc_29DA:
	ld a,5(iy)                      ; 29DA
	add a,c                         ; 29DD
	ld (tmp_d5),a                   ; 29DE
	ld (coll_C198),a                 ; 29E1
	cp #0x30                        ; 29E4
	jr c,loc_29D7                   ; 29E6
	cp #0xc7                        ; 29E8
	jr nc,loc_29D7                  ; 29EA
	call sub_2A7A                   ; 29EC
	ld hl,(tmp_d3)                  ; 29EF
	ld (flow_C0DB),hl                ; 29F2
	ld hl,(tmp_d5)                  ; 29F5
	ld (flow_C0DD),hl                ; 29F8
	call sub_4A5C                   ; 29FB
	ld (flow_C0DF),hl                ; 29FE
	xor a                           ; 2A01
	ret                             ; 2A02

;; ---------------------------------------------------------------- $02A03
;; classement : lecture de la tuile/metatuile sous une position (banque 10)
	.area _B00_2A03
sub_2A03::
	ld hl,#0x0000                   ; 2A03
	ld (coll_C0E1),hl                ; 2A06
	ld a,(flow_C0DB)                 ; 2A09
	ld d,a                          ; 2A0C
	and #0xf0                       ; 2A0D
	ld e,a                          ; 2A0F
	ld a,d                          ; 2A10
	add a,b                         ; 2A11
	and #0xf0                       ; 2A12
	sub e                           ; 2A14
	jr z,loc_2A2F                   ; 2A15
	srl a                           ; 2A17
	srl a                           ; 2A19
	srl a                           ; 2A1B
	srl a                           ; 2A1D
	ld b,a                          ; 2A1F
	ld de,(level_CF18)                ; 2A20
	ld d,#0x00                      ; 2A24
	ld hl,#0x0000                   ; 2A26
loc_2A29:
	add hl,de                       ; 2A29
	djnz loc_2A29                   ; 2A2A
	ld (coll_C0E1),hl                ; 2A2C
loc_2A2F:
	ld a,(flow_C0DD)                 ; 2A2F
	neg                             ; 2A32
	ld d,a                          ; 2A34
	and #0xf0                       ; 2A35
	ld e,a                          ; 2A37
	ld a,d                          ; 2A38
	add a,c                         ; 2A39
	and #0xf0                       ; 2A3A
	sub e                           ; 2A3C
	jr z,loc_2A51                   ; 2A3D
	srl a                           ; 2A3F
	srl a                           ; 2A41
	srl a                           ; 2A43
	srl a                           ; 2A45
	ld e,a                          ; 2A47
	ld d,#0x00                      ; 2A48
	ld hl,(coll_C0E1)                ; 2A4A
	add hl,de                       ; 2A4D
	ld (coll_C0E1),hl                ; 2A4E
loc_2A51:
	ld hl,(coll_C0E1)                ; 2A51
	ld de,(flow_C0DF)                ; 2A54
	add hl,de                       ; 2A58
	push hl                         ; 2A59
	ld de,#level_map                ; 2A5A
	xor a                           ; 2A5D
	sbc hl,de                       ; 2A5E
	pop hl                          ; 2A60
	ret c                           ; 2A61
	ld a,(hl)                       ; 2A62
	ld (player_C196),hl                ; 2A63
	call sub_2AA8                   ; 2A66
	ret                             ; 2A69

;; ---------------------------------------------------------------- $02A6A
;; classement : lecture de la tuile/metatuile sous une position (banque 10)
	.area _B00_2A6A
sub_2A6A::
	xor a                           ; 2A6A
	ld (player_CEFF),a                 ; 2A6B
	ld (player_CF00),a                 ; 2A6E
	ret                             ; 2A71

;; ---------------------------------------------------------------- $02A72
;; classement : lecture de la tuile/metatuile sous une position (banque 10)
	.area _B00_2A72
sub_2A72::
	xor a                           ; 2A72
	ld (player_CF01),a                 ; 2A73
	ld (coll_CF02),a                 ; 2A76
	ret                             ; 2A79

;; ---------------------------------------------------------------- $02A7A
;; classement : lecture de la tuile/metatuile sous une position (banque 10)
	.area _B00_2A7A
sub_2A7A::
	ld a,(tmp_d3)                   ; 2A7A
	sub #0x17                       ; 2A7D
	ld e,a                          ; 2A7F
	ld d,#0x00                      ; 2A80
	jr nc,loc_2A86                  ; 2A82
	ld d,#0xff                      ; 2A84
loc_2A86:
	ld hl,(scroll_y)                ; 2A86
	call sub_4984                   ; 2A89
	ld (tmp_d3),hl                  ; 2A8C
	ld a,(tmp_d5)                   ; 2A8F
	ld h,#0xff                      ; 2A92
	sub #0x30                       ; 2A94
	jr z,loc_2A9A                   ; 2A96
	jr nc,loc_2A9C                  ; 2A98
loc_2A9A:
	ld h,#0x00                      ; 2A9A
loc_2A9C:
	neg                             ; 2A9C
	ld l,a                          ; 2A9E
	ld de,(scroll_x)                ; 2A9F
	add hl,de                       ; 2AA3
	ld (tmp_d5),hl                  ; 2AA4
	ret                             ; 2AA7

;; ---------------------------------------------------------------- $02AA8
;; classement : lecture de la tuile/metatuile sous une position (banque 10)
	.area _B00_2AA8
sub_2AA8::
	push hl                         ; 2AA8
	push de                         ; 2AA9
	push bc                         ; 2AAA
	ld bc,(bank_slot2_shadow)       ; 2AAB
	ld de,(level_attr_ptr)          ; 2AAF
	ld l,a                          ; 2AB3
	ld h,#0x00                      ; 2AB4
	ld a,#0x0a                      ; 2AB6
	ld (bank_slot2_shadow),a        ; 2AB8
	ld (MAPPER_SLOT2),a             ; 2ABB  mapper : banque du slot 2 ($8000-$BFFF)
	add hl,de                       ; 2ABE
	ld b,(hl)                       ; 2ABF
	ld a,c                          ; 2AC0
	ld (bank_slot2_shadow),a        ; 2AC1
	ld (MAPPER_SLOT2),a             ; 2AC4  mapper : banque du slot 2 ($8000-$BFFF)
	ld a,b                          ; 2AC7
	pop bc                          ; 2AC8
	pop de                          ; 2AC9
	pop hl                          ; 2ACA
	ret                             ; 2ACB

;; ---------------------------------------------------------------- $02ACC
;; classement : lecture de la tuile/metatuile sous une position (banque 10)
	.area _B00_2ACC
.if VERSION_SMS_EN
sub_2ACC:
	ld a,2(iy)                      ; 2ACC
.else ; VERSION_GG_JP
sub_2ACC:
	.db 0xfd, 0x7e                  ; 2ACC
sub_2ACE:
	ld (bc),a                       ; 2ACE
.endif
	ld (tmp_d3),a                   ; 2ACF
	ld a,5(iy)                      ; 2AD2
	ld (tmp_d5),a                   ; 2AD5

;; ---------------------------------------------------------------- $02AD8
;; classement : lecture de la tuile/metatuile sous une position (banque 10)
	.area _B00_2AD8
sub_2AD8::
	call sub_2A7A                   ; 2AD8
	call sub_4A5C                   ; 2ADB
	ld a,(hl)                       ; 2ADE
	ret                             ; 2ADF

;; ---------------------------------------------------------------- $02AE0
;; classement : lecture de la tuile/metatuile sous une position (banque 10)
	.area _B00_2AE0
sub_2AE0:
	ld a,2(iy)                      ; 2AE0
	ld (tmp_d3),a                   ; 2AE3
	cp #0x17                        ; 2AE6
	jr nc,loc_2AED                  ; 2AE8
	cp #0x7e                        ; 2AEA
	ret c                           ; 2AEC
loc_2AED:
	or #0xff                        ; 2AED
	ret                             ; 2AEF

;; ---------------------------------------------------------------- $03190
;; classement : atteinte uniquement par tbl_1D9E
	.area _B00_3190
sub_3190::
	push af                         ; 3190
	call task_yield                 ; 3191
	call sub_2249                   ; 3194
	ld a,(player_CEF6)                 ; 3197
	cp #0xff                        ; 319A
	jr z,loc_31CB                   ; 319C
	ld a,(freeze_timer)             ; 319E
	or a                            ; 31A1
	jr nz,loc_31CB                  ; 31A2
	ld a,(demo_mode)                ; 31A4
	or a                            ; 31A7
	jr z,loc_31B0                   ; 31A8
	ld hl,#0x0000                   ; 31AA
	ld (joypad_state),hl            ; 31AD
loc_31B0:
	call sub_2EFD                   ; 31B0
	ld a,(demo_mode)                ; 31B3
	or a                            ; 31B6
	jr z,loc_31BF                   ; 31B7
	ld hl,#0x0000                   ; 31B9
	ld (player_CF01),hl                ; 31BC
loc_31BF:
	call sub_3123                   ; 31BF
	call sub_2EDC                   ; 31C2
	call sub_3994                   ; 31C5
	call sub_23FC                   ; 31C8
loc_31CB:
	pop af                          ; 31CB
	dec a                           ; 31CC
	jr nz,sub_3190                  ; 31CD
	ret                             ; 31CF

;; ---------------------------------------------------------------- $031D0
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_31D0
sub_31D0::
	ld a,#0x03                      ; 31D0
	call task_suspend               ; 31D2
	ld a,#0x02                      ; 31D5
	call task_suspend               ; 31D7
	ld hl,#coll_CA67                 ; 31DA
	ld de,#coll_CA68                 ; 31DD
	ld (hl),#0x00                   ; 31E0
	ld bc,#0x009f                   ; 31E2
	ldir                            ; 31E5
	ld iy,#coll_CA67                 ; 31E7
	ld a,(player_C1F2)                 ; 31EB
	cp #0x01                        ; 31EE
	ld ix,#data_3371                ; 31F0
	jr z,loc_31FA                   ; 31F4
	ld ix,#data_3386                ; 31F6
loc_31FA:
	ld a,0(ix)                      ; 31FA
	ld 27(iy),a                     ; 31FD
	ld a,1(ix)                      ; 3200
	ld 28(iy),a                     ; 3203
	ld a,2(ix)                      ; 3206
	ld 7(iy),a                      ; 3209
	ld 0(iy),a                      ; 320C
	ld a,(player_CEF1)                 ; 320F
	add a,3(ix)                     ; 3212
	ld 2(iy),a                      ; 3215
	ld a,(player_CEF4)                 ; 3218
	add a,4(ix)                     ; 321B
	ld 5(iy),a                      ; 321E
	ld de,#0x0005                   ; 3221
	add ix,de                       ; 3224
	ld de,#0x0028                   ; 3226
	add iy,de                       ; 3229
	ld a,0(ix)                      ; 322B
	cp #0xff                        ; 322E
	jr nz,loc_31FA                  ; 3230
loc_3232:
	ld a,#0x01                      ; 3232
	call sub_0332                   ; 3234
	ld iy,#coll_CA67                 ; 3237
	ld b,#0x04                      ; 323B
loc_323D:
	ld a,0(iy)                      ; 323D
	or a                            ; 3240
	jr z,loc_3246                   ; 3241
	call sub_72B2                   ; 3243
loc_3246:
	ld de,#0x0028                   ; 3246
	add iy,de                       ; 3249
	djnz loc_323D                   ; 324B
	call sub_3320                   ; 324D
	call sub_3329                   ; 3250
	call sub_59C1                   ; 3253
	call sub_5A52                   ; 3256
	ld a,(coll_CA67)                 ; 3259
	ld b,a                          ; 325C
	ld a,(coll_CA8F)                 ; 325D
	ld l,a                          ; 3260
	ld a,(coll_CAB7)                 ; 3261
	ld h,a                          ; 3264
	ld a,(coll_CADF)                 ; 3265
	or h                            ; 3268
	or l                            ; 3269
	or b                            ; 326A
	jr nz,loc_3232                  ; 326B
	call sub_3287                   ; 326D
	ld a,#0x03                      ; 3270
	call task_resume                ; 3272
	ld a,#0x02                      ; 3275
	call task_resume                ; 3277
	ld iy,#player_state             ; 327A
	ld a,#0x02                      ; 327E
	ld (bank_slot2_shadow),a        ; 3280
	ld (MAPPER_SLOT2),a             ; 3283  mapper : banque du slot 2 ($8000-$BFFF)
	ret                             ; 3286

;; ---------------------------------------------------------------- $03287
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_3287
sub_3287:
	ld a,(player_C1F2)                 ; 3287
	cp #0x01                        ; 328A
	ld a,#0x01                      ; 328C
	jr z,loc_3292                   ; 328E
	ld a,#0x02                      ; 3290
loc_3292:
	ld (tmp_d3),a                   ; 3292
	ld iy,#actor_CDD7                 ; 3295
	ld b,#0x07                      ; 3299
	call sub_32B1                   ; 329B
	ld iy,#actor_CB07                 ; 329E
	ld b,#0x04                      ; 32A2
	call sub_32B1                   ; 32A4
	ld iy,#actor_CBA7                 ; 32A7
	ld b,#0x0a                      ; 32AB
	call sub_32B1                   ; 32AD
	ret                             ; 32B0

;; ---------------------------------------------------------------- $032B1
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_32B1
sub_32B1:
	ld a,0(iy)                      ; 32B1
	or a                            ; 32B4
	jr z,loc_32E4                   ; 32B5
	cp #0x92                        ; 32B7
	jr nc,loc_32E4                  ; 32B9
	ld a,3(iy)                      ; 32BB
	or 6(iy)                        ; 32BE
	jr nz,loc_32E4                  ; 32C1
	ld a,(tmp_d3)                   ; 32C3
	and 39(iy)                      ; 32C6
	jr nz,loc_32E4                  ; 32C9
	call sub_32EC                   ; 32CB
	jr nz,loc_32E4                  ; 32CE
	ld a,15(iy)                     ; 32D0
	sub #0x02                       ; 32D3
	ld 15(iy),a                     ; 32D5
	jr z,loc_32DC                   ; 32D8
	jr nc,loc_32E4                  ; 32DA
loc_32DC:
	ld 15(iy),#0x00                 ; 32DC
	ld 13(iy),#0x01                 ; 32E0
loc_32E4:
	ld de,#0x0028                   ; 32E4
	add iy,de                       ; 32E7
	djnz sub_32B1                   ; 32E9
	ret                             ; 32EB

;; ---------------------------------------------------------------- $032EC
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_32EC
sub_32EC:
	ld a,(tmp_d3)                   ; 32EC
	cp #0x02                        ; 32EF
	jr nz,loc_331E                  ; 32F1
	ld a,0(iy)                      ; 32F3
	sub #0x40                       ; 32F6
	jr c,loc_331E                   ; 32F8
	cp #0x04                        ; 32FA
	jr nc,loc_331E                  ; 32FC
	add a,#0xb3                     ; 32FE
	ld 0(iy),a                      ; 3300
	ld 9(iy),#0x00                  ; 3303
	ld 8(iy),#0x00                  ; 3307
	ld 10(iy),#0x00                 ; 330B
	ld a,7(iy)                      ; 330F
	add a,#0x02                     ; 3312
	ld 7(iy),a                      ; 3314
	ld 8(iy),#0x00                  ; 3317
	or #0xff                        ; 331B
	ret                             ; 331D
loc_331E:
	xor a                           ; 331E
	ret                             ; 331F

;; ---------------------------------------------------------------- $03320
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_3320
sub_3320:
	ld iy,#coll_CA67                 ; 3320
	ld b,#0x04                      ; 3324
	jp loc_3655                     ; 3326

;; ---------------------------------------------------------------- $03329
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_3329
sub_3329:
	ld hl,#game_flags               ; 3329
	res 3,(hl)                      ; 332C
	ld iy,#coll_CA67                 ; 332E
	ld b,#0x04                      ; 3332
loc_3334:
	ld a,0(iy)                      ; 3334
	or a                            ; 3337
	jr z,loc_333D                   ; 3338
	call sub_6D4E                   ; 333A
loc_333D:
	ld de,#0x0028                   ; 333D
	add iy,de                       ; 3340
	djnz loc_3334                   ; 3342
	call sub_71BE                   ; 3344
	call sub_6D1E                   ; 3347
	ld hl,#game_flags               ; 334A
	set 3,(hl)                      ; 334D
	call sub_6CC9                   ; 334F
	call sub_6CB2                   ; 3352
	call sub_6C9B                   ; 3355
	ld hl,#sprite_C185                 ; 3358
	bit 0,(hl)                      ; 335B
	jr z,loc_3361                   ; 335D
	res 0,(hl)                      ; 335F
loc_3361:
	ld hl,#vdp_requests2            ; 3361
	set 0,(hl)                      ; 3364
	ld hl,#vdp_requests2            ; 3366
	set 7,(hl)                      ; 3369
	ld hl,#game_flags               ; 336B
	res 3,(hl)                      ; 336E
	ret                             ; 3370
data_3371:
	.dw data_33FB                   ; 3371
	.db 0x2e, 0xc0, 0x00            ; 3373
	.dw data_33BB                   ; 3376
	.db 0x2e, 0xec, 0xd4            ; 3378
	.dw data_33DB                   ; 337B
	.db 0x2e, 0x18, 0x00            ; 337D
	.dw data_339B                   ; 3380
	.db 0x2e, 0xec, 0x2c, 0xff      ; 3382
data_3386:
	.dw data_3423                   ; 3386
	.db 0x6c, 0xe0, 0x00            ; 3388
	.dw data_341D                   ; 338B
	.db 0x6c, 0xe0, 0x00            ; 338D
	.dw data_3419                   ; 3390
	.db 0x6c, 0xe0, 0x00            ; 3392
	.dw data_3415                   ; 3395
	.db 0x6c, 0xe0, 0x00, 0xff      ; 3397
data_339B:
	.db 0xfc, 0x00, 0xe3, 0x19, 0xe3 ; 339B
	.db 0x19, 0xe3, 0x19, 0xfc, 0x2e, 0xff, 0x71, 0x34, 0xe3, 0x19, 0xe0, 0x02, 0x0f, 0x0f, 0xff, 0xc2 ; 33A0
	.db 0x82, 0xff, 0xeb, 0x82, 0xff, 0x14, 0x83, 0xfd, 0x14, 0x40, 0xf4 ; 33B0
data_33BB:
	.db 0xfc, 0x00, 0xe3, 0x19, 0xfc ; 33BB
	.db 0x2e, 0xff, 0x71, 0x34, 0xe3, 0x19, 0xe3, 0x19, 0xe3, 0x19, 0xe0, 0x02, 0x0f, 0x0f, 0xff, 0x14 ; 33C0
	.db 0x83, 0xff, 0x3d, 0x83, 0xff, 0xc2, 0x82, 0xfd, 0x14, 0xc0, 0xf4 ; 33D0
data_33DB:
	.db 0xfc, 0x00, 0xe3, 0x19, 0xe3 ; 33DB
	.db 0x19, 0xfc, 0x2e, 0xff, 0x71, 0x34, 0xe3, 0x19, 0xe3, 0x19, 0xe0, 0x02, 0x0f, 0x0f, 0xff, 0x3d ; 33E0
	.db 0x83, 0xff, 0xc2, 0x82, 0xff, 0xeb, 0x82, 0xfd, 0x14, 0x0c, 0xf4 ; 33F0
data_33FB:
	.db 0xff, 0x71, 0x34, 0xe3, 0x64 ; 33FB
	.db 0xe0, 0x02, 0x0f, 0x0f, 0xdb, 0x05, 0xde, 0xb8, 0xff, 0xeb, 0x82, 0xff, 0x14, 0x83, 0xff, 0x3d ; 3400
	.db 0x83, 0xfd, 0x14, 0x04, 0xf4 ; 3410
data_3415:
	.db 0xfc, 0x00, 0xe3, 0x28      ; 3415
data_3419:
	.db 0xfc, 0x00, 0xe3, 0x28      ; 3419
data_341D:
	.db 0xfc, 0x00, 0xe3            ; 341D
	.db 0x28, 0xfc, 0x6c            ; 3420
data_3423:
	.db 0xdb, 0x05, 0xde, 0xb7, 0xe0, 0x02, 0x0a, 0x0a, 0xff, 0xc2, 0x82, 0xff, 0xeb ; 3423
	.db 0x82, 0xe0, 0x02, 0x19, 0x19, 0xff, 0x14, 0x83, 0xff, 0x3d, 0x83, 0xe3, 0x1e, 0xf4, 0xe0, 0x02 ; 3430
	.db 0x0a, 0x0a, 0xff, 0x14, 0x83, 0xff, 0x3d, 0x83, 0xe0, 0x02, 0x0f, 0x0f, 0xff, 0xc2, 0x82, 0xff ; 3440
	.db 0xeb, 0x82, 0xe0, 0x02, 0x14, 0x14, 0xff, 0x14, 0x83, 0xff, 0x3d, 0x83, 0xe0, 0x02, 0x19, 0x19 ; 3450
	.db 0xff, 0xc2, 0x82, 0xff, 0xeb, 0x82, 0xe0, 0x02, 0x1e, 0x1e, 0xff, 0x14, 0x83, 0xff, 0x3d, 0x83 ; 3460
	.db 0xf4, 0xdb, 0x05, 0xde, 0xa5, 0xfe ; 3470

;; ---------------------------------------------------------------- $05C25
;; classement : atteinte uniquement par tbl_2539
	.area _B01_5C25
sub_5C25::
	push af                         ; 5C25
	ld a,(player_state)             ; 5C26
	cpl                             ; 5C29
	add a,a                         ; 5C2A
	ld l,a                          ; 5C2B
	ld h,#0x00                      ; 5C2C
	ld a,#0x12                      ; 5C2E
	ld (bank_slot2_shadow),a        ; 5C30
	ld (MAPPER_SLOT2),a             ; 5C33  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b18_B702            ; 5C36
	add hl,de                       ; 5C39
	ld e,(hl)                       ; 5C3A
	inc hl                          ; 5C3B
	ld d,(hl)                       ; 5C3C
	ld hl,(player_CEF6)                ; 5C3D
	ld h,#0x00                      ; 5C40
	add hl,de                       ; 5C42
	ld e,(hl)                       ; 5C43
	inc hl                          ; 5C44
	ld d,(hl)                       ; 5C45
	ld hl,(scene_id)                ; 5C46
	ld h,#0x00                      ; 5C49
	add hl,hl                       ; 5C4B
	add hl,de                       ; 5C4C
	ld e,(hl)                       ; 5C4D
	inc hl                          ; 5C4E
	ld d,(hl)                       ; 5C4F
	ex de,hl                        ; 5C50
	pop af                          ; 5C51
loc_5C52::
	cp (hl)                         ; 5C52
	jp nz,loc_5CDD                  ; 5C53
	inc hl                          ; 5C56
	ld e,(hl)                       ; 5C57
	inc hl                          ; 5C58
	ld d,(hl)                       ; 5C59
	push de                         ; 5C5A
	pop ix                          ; 5C5B
	ld de,(player_C196)                ; 5C5D
	ld l,0(ix)                      ; 5C61
	ld h,1(ix)                      ; 5C64
	add hl,de                       ; 5C67
	ex de,hl                        ; 5C68
	ld l,2(ix)                      ; 5C69
	ld h,3(ix)                      ; 5C6C
	push iy                         ; 5C6F
	push hl                         ; 5C71
	pop iy                          ; 5C72
	ld c,0(iy)                      ; 5C74
	ld b,1(iy)                      ; 5C77
	srl b                           ; 5C7A
	srl c                           ; 5C7C
	inc hl                          ; 5C7E
	inc hl                          ; 5C7F
	ld a,(level_CF18)                 ; 5C80
	push hl                         ; 5C83
	call sub_16F8                   ; 5C84
	pop hl                          ; 5C87
	ld c,0(iy)                      ; 5C88
	ld b,1(iy)                      ; 5C8B
	srl b                           ; 5C8E
	ld a,#0x12                      ; 5C90
	ld (map_bank),a                 ; 5C92
	call sub_499F                   ; 5C95
	ld a,#0x12                      ; 5C98
	ld (bank_slot2_shadow),a        ; 5C9A
	ld (MAPPER_SLOT2),a             ; 5C9D  mapper : banque du slot 2 ($8000-$BFFF)
	ld bc,(coll_C18C)                ; 5CA0
	ld a,(coll_C199)                 ; 5CA4
	add a,b                         ; 5CA7
	add a,4(ix)                     ; 5CA8
	ld (tmp_d3),a                   ; 5CAB
	ld a,(coll_C198)                 ; 5CAE
	add a,c                         ; 5CB1
	add a,5(ix)                     ; 5CB2
	ld (tmp_d5),a                   ; 5CB5
	call sub_2A7A                   ; 5CB8
	ld a,(tmp_d5)                   ; 5CBB
	ld (dbg_C0D4),a                 ; 5CBE
	call sub_4ABF                   ; 5CC1
	ld hl,#util_D4D1                 ; 5CC4
	ld c,0(iy)                      ; 5CC7
	ld b,1(iy)                      ; 5CCA
	call sub_44E4                   ; 5CCD
	pop iy                          ; 5CD0
	ld l,6(ix)                      ; 5CD2
	ld h,7(ix)                      ; 5CD5
	ld e,(hl)                       ; 5CD8
	inc hl                          ; 5CD9
	ld d,(hl)                       ; 5CDA
	push de                         ; 5CDB
	ret                             ; 5CDC
loc_5CDD:
	ld e,a                          ; 5CDD
	ld a,(hl)                       ; 5CDE
	cp #0xff                        ; 5CDF
	ret z                           ; 5CE1
	ld a,e                          ; 5CE2
	ld de,#0x0003                   ; 5CE3
	add hl,de                       ; 5CE6
	jp loc_5C52                     ; 5CE7

;; ---------------------------------------------------------------- $05CEA
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5CEA
sub_5CEA::
	ld a,#0x01                      ; 5CEA
	jr loc_5CFC                     ; 5CEC

;; ---------------------------------------------------------------- $05CEE
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5CEE
sub_5CEE::
	ld a,#0x02                      ; 5CEE
	jr loc_5CFC                     ; 5CF0

;; ---------------------------------------------------------------- $05CF2
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5CF2
sub_5CF2::
	ld a,#0x04                      ; 5CF2
	jr loc_5CFC                     ; 5CF4

;; ---------------------------------------------------------------- $05CF6
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5CF6
sub_5CF6::
	ld a,#0x08                      ; 5CF6
	jr loc_5CFC                     ; 5CF8
	.db 0x3e, 0x10                  ; 5CFA
loc_5CFC:
	ld hl,#coll_C0D0                 ; 5CFC
	ld b,(hl)                       ; 5CFF
	or (hl)                         ; 5D00
	ld (hl),a                       ; 5D01
	cp b                            ; 5D02
	ret z                           ; 5D03
	cp #0x1f                        ; 5D04
	jp z,loc_5D0D                   ; 5D06
	call sub_0519                   ; 5D09
	ret                             ; 5D0C
loc_5D0D:
	push iy                         ; 5D0D
	pop ix                          ; 5D0F
	jp loc_1F53                     ; 5D11
data_5D14::
	.db 0xc9                        ; 5D14

;; ---------------------------------------------------------------- $05D15
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5D15
sub_5D15::
	ld a,#0xc9                      ; 5D15
	call sub_5D89                   ; 5D17
	jr loc_5D52                     ; 5D1A

;; ---------------------------------------------------------------- $05D1C
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5D1C
sub_5D1C::
	ld a,#0xcb                      ; 5D1C
	call sub_5D89                   ; 5D1E
	jr loc_5D52                     ; 5D21

;; ---------------------------------------------------------------- $05D23
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5D23
sub_5D23::
	ld a,#0xca                      ; 5D23
	call sub_5D89                   ; 5D25
	jr loc_5D52                     ; 5D28

;; ---------------------------------------------------------------- $05D2A
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5D2A
sub_5D2A::
	ld a,#0xcd                      ; 5D2A
	call sub_5D89                   ; 5D2C
	jr loc_5D52                     ; 5D2F

;; ---------------------------------------------------------------- $05D31
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5D31
sub_5D31::
	ld a,#0xcc                      ; 5D31
	call sub_5D89                   ; 5D33
	jr loc_5D52                     ; 5D36

;; ---------------------------------------------------------------- $05D38
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5D38
sub_5D38::
	ld a,#0xcf                      ; 5D38
	call sub_5D89                   ; 5D3A
	jr loc_5D52                     ; 5D3D

;; ---------------------------------------------------------------- $05D3F
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5D3F
sub_5D3F::
	ld a,#0xd0                      ; 5D3F
	call sub_5D89                   ; 5D41
	jr loc_5D52                     ; 5D44

;; ---------------------------------------------------------------- $05D46
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5D46
sub_5D46::
	ld a,#0xc8                      ; 5D46
	call sub_5D89                   ; 5D48
	jr loc_5D52                     ; 5D4B

;; ---------------------------------------------------------------- $05D4D
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5D4D
sub_5D4D::
	ld a,#0xda                      ; 5D4D
	call sub_5D90                   ; 5D4F
loc_5D52:
	call z,sub_3B28                 ; 5D52
	call sub_0653                   ; 5D55
	ld a,r                          ; 5D58
	bit 0,a                         ; 5D5A
	ld a,#0xdb                      ; 5D5C
	jr z,loc_5D62                   ; 5D5E
	add a,#0x03                     ; 5D60
loc_5D62:
	call sub_5D90                   ; 5D62
	call z,sub_3B28                 ; 5D65
	ld a,r                          ; 5D68
	bit 0,a                         ; 5D6A
	ld a,#0xdc                      ; 5D6C
	jr z,loc_5D72                   ; 5D6E
	add a,#0x03                     ; 5D70
loc_5D72:
	call sub_5D90                   ; 5D72
	call z,sub_3B28                 ; 5D75
	ld a,r                          ; 5D78
	bit 0,a                         ; 5D7A
	ld a,#0xdd                      ; 5D7C
	jr z,loc_5D82                   ; 5D7E
	add a,#0x03                     ; 5D80
loc_5D82:
	call sub_5D90                   ; 5D82
	call z,sub_3B28                 ; 5D85
	ret                             ; 5D88

;; ---------------------------------------------------------------- $05D89
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5D89
sub_5D89:
	ld hl,#actor_CDD7                 ; 5D89
	ld b,#0x07                      ; 5D8C
	jr loc_5D95                     ; 5D8E

;; ---------------------------------------------------------------- $05D90
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5D90
sub_5D90:
	ld hl,#scene_script_ptr         ; 5D90
	ld b,#0x0d                      ; 5D93
loc_5D95:
	push af                         ; 5D95
	call sub_3BB5                   ; 5D96
	pop bc                          ; 5D99
	ret nz                          ; 5D9A
	push bc                         ; 5D9B
	call sub_3BD8                   ; 5D9C
	push hl                         ; 5D9F
	pop iy                          ; 5DA0
	pop bc                          ; 5DA2
	ld 0(iy),b                      ; 5DA3
	ld bc,(coll_C18C)                ; 5DA6
	ld a,(coll_C199)                 ; 5DAA
	add a,b                         ; 5DAD
	ld 2(iy),a                      ; 5DAE
	ld (tmp_d3),a                   ; 5DB1
	ld a,(coll_C198)                 ; 5DB4
	add a,c                         ; 5DB7
	ld 5(iy),a                      ; 5DB8
	ld (tmp_d5),a                   ; 5DBB
	call sub_2A7A                   ; 5DBE
	ld a,(tmp_d3)                   ; 5DC1
	and #0xf0                       ; 5DC4
	or #0x08                        ; 5DC6
	ld (tmp_d3),a                   ; 5DC8
	ld a,(tmp_d5)                   ; 5DCB
	and #0x0f                       ; 5DCE
	ld a,(tmp_d5)                   ; 5DD0
	jr z,loc_5DD9                   ; 5DD3
	and #0xf0                       ; 5DD5
	jr loc_5DDD                     ; 5DD7
loc_5DD9:
	and #0xf0                       ; 5DD9
	sub #0x10                       ; 5DDB
loc_5DDD:
	or #0x08                        ; 5DDD
	ld (tmp_d5),a                   ; 5DDF
	call sub_3036                   ; 5DE2
	ld a,(tmp_d3)                   ; 5DE5
	ld 2(iy),a                      ; 5DE8
	ld a,(tmp_d5)                   ; 5DEB
	ld 5(iy),a                      ; 5DEE
	xor a                           ; 5DF1
	ret                             ; 5DF2
