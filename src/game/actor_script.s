;; game/actor_script.s
;; Interpreteur des scripts d'acteurs (banque 25) : 54 commandes ($CA-$FF), table $72EB.
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $03036
;; classement : atteinte uniquement par entcmd_72EB
	.area _B00_3036
sub_3036::
	ld de,(tmp_d5)                  ; 3036
	ld hl,(scroll_x)                ; 303A
	or a                            ; 303D
	sbc hl,de                       ; 303E
	ld de,#0x0030                   ; 3040
	add hl,de                       ; 3043
	ld (tmp_d5),hl                  ; 3044
	ld a,(dbg_C0D4)                 ; 3047
	ld de,#0x00e0                   ; 304A
	call sub_3075                   ; 304D
	ld de,(tmp_d3)                  ; 3050
	ld d,#0x00                      ; 3054
	add hl,de                       ; 3056
	push hl                         ; 3057
	ld a,(ascript_C09C)                 ; 3058
	ld de,#0x00e0                   ; 305B
	call sub_3075                   ; 305E
	ld de,(scroll_y)                ; 3061
	ld d,#0x00                      ; 3065
	add hl,de                       ; 3067
	pop de                          ; 3068
	ex de,hl                        ; 3069
	or a                            ; 306A
	sbc hl,de                       ; 306B
	ld de,#0x0017                   ; 306D
	add hl,de                       ; 3070
	ld (tmp_d3),hl                  ; 3071
	ret                             ; 3074

;; ---------------------------------------------------------------- $03075
;; classement : atteinte uniquement par entcmd_72EB
	.area _B00_3075
sub_3075:
	push bc                         ; 3075
	ld b,#0x08                      ; 3076
	ld hl,#0x0000                   ; 3078
loc_307B:
	add hl,hl                       ; 307B
	add a,a                         ; 307C
	jp nc,loc_3081                  ; 307D
	add hl,de                       ; 3080
loc_3081:
	djnz loc_307B                   ; 3081
	pop bc                          ; 3083
	ret                             ; 3084

;; ---------------------------------------------------------------- $05B03
;; classement : atteinte uniquement par entcmd_72EB
	.area _B01_5B03
sub_5B03:
	ld a,(scene_id)                 ; 5B03
	cp #0x08                        ; 5B06
	ret c                           ; 5B08
	cp #0x0d                        ; 5B09
	ret nc                          ; 5B0B
	ld hl,#sub_5AFC                 ; 5B0C
	ld b,(hl)                       ; 5B0F
	inc hl                          ; 5B10
	ld c,(hl)                       ; 5B11
	inc hl                          ; 5B12
	push hl                         ; 5B13
	ld hl,#ascript_FF11                 ; 5B14
	call sub_29C5                   ; 5B17
	pop hl                          ; 5B1A
	ret nz                          ; 5B1B
loc_5B1C:
	ld a,(hl)                       ; 5B1C
	cp #0xff                        ; 5B1D
	ret z                           ; 5B1F
	inc hl                          ; 5B20
	ld c,a                          ; 5B21
	ld b,(hl)                       ; 5B22
	inc hl                          ; 5B23
	push hl                         ; 5B24
	push iy                         ; 5B25
	push ix                         ; 5B27
	call sub_5B33                   ; 5B29
	pop ix                          ; 5B2C
	pop iy                          ; 5B2E
	pop hl                          ; 5B30
	jr loc_5B1C                     ; 5B31

;; ---------------------------------------------------------------- $05B33
;; classement : atteinte uniquement par entcmd_72EB
	.area _B01_5B33
sub_5B33:
	ld (coll_C18C),bc                ; 5B33
	call sub_2A03                   ; 5B37
	and #0x40                       ; 5B3A
	ret z                           ; 5B3C
	ld a,#0x12                      ; 5B3D
	ld (bank_slot2_shadow),a        ; 5B3F
	ld (MAPPER_SLOT2),a             ; 5B42  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b18_B669            ; 5B45
	ld hl,(player_C196)                ; 5B48
	ld a,(hl)                       ; 5B4B
	ex de,hl                        ; 5B4C
	jp loc_5C52                     ; 5B4D

;; ---------------------------------------------------------------- $061A3
;; classement : atteinte uniquement par entcmd_72EB
	.area _B01_61A3
sub_61A3:
	ld c,1(ix)                      ; 61A3
	push ix                         ; 61A6
	pop de                          ; 61A8
	ld hl,#0x0007                   ; 61A9
	add hl,de                       ; 61AC
	ld ACTOR_SCRIPT_LO(iy),l                     ; 61AD
	ld ACTOR_SCRIPT_HI(iy),h                     ; 61B0
	ld a,ACTOR_X_HI(iy)                      ; 61B3
	or ACTOR_Y_HI(iy)                        ; 61B6
	jp nz,loc_6255                  ; 61B9
	ld a,ACTOR_X(iy)                      ; 61BC
	ld hl,#0xa617                   ; 61BF
	call sub_35D7                   ; 61C2
	jp nz,loc_6255                  ; 61C5
	ld a,ACTOR_Y(iy)                      ; 61C8
	ld hl,#ascript_CF30                 ; 61CB
	call sub_35D7                   ; 61CE
	jp nz,loc_6255                  ; 61D1
	add a,#0x0c                     ; 61D4
	ld de,(ascript_C8B1)                ; 61D6
	sub e                           ; 61DA
	cp #0x04                        ; 61DB
	jp c,loc_6255                   ; 61DD
	ld a,(ascript_C8B4)                 ; 61E0
	add a,#0x0c                     ; 61E3
	sub ACTOR_Y(iy)                       ; 61E5
	cp #0x04                        ; 61E8
	jp c,loc_6255                   ; 61EA
	ld a,1(ix)                      ; 61ED
	inc a                           ; 61F0
	inc a                           ; 61F1
	ld (util_C0D9),a                 ; 61F2
	call sub_6256                   ; 61F5
	ld hl,#actor_CB07                 ; 61F8
	ld b,#0x04                      ; 61FB
	call sub_3BCD                   ; 61FD
	jr nz,loc_6255                  ; 6200
	push ix                         ; 6202
	pop de                          ; 6204
	inc de                          ; 6205
	inc de                          ; 6206
	push hl                         ; 6207
	pop ix                          ; 6208
	call sub_3BD8                   ; 620A
	ld a,(de)                       ; 620D
	ld 0(ix),a                      ; 620E
	push iy                         ; 6211
	push ix                         ; 6213
	pop iy                          ; 6215
	call sub_3B28                   ; 6217
	pop iy                          ; 621A
	ld hl,(tmp_d3)                  ; 621C
	ld 18(ix),l                     ; 621F
	ld 19(ix),h                     ; 6222
	ld de,(map_bank)                ; 6225
	ld 16(ix),e                     ; 6229
	ld 17(ix),d                     ; 622C
	ld l,ACTOR_X_FRAC(iy)                      ; 622F
	ld h,ACTOR_X(iy)                      ; 6232
	ld de,(actor_C0DA)                ; 6235
	ld e,#0x00                      ; 6239
	add hl,de                       ; 623B
	ld 1(ix),l                      ; 623C
	ld 2(ix),h                      ; 623F
	ld l,ACTOR_Y_FRAC(iy)                      ; 6242
	ld h,ACTOR_Y(iy)                      ; 6245
	ld de,(flow_C0DB)                ; 6248
	ld e,#0x00                      ; 624C
	add hl,de                       ; 624E
	ld 4(ix),l                      ; 624F
	ld 5(ix),h                      ; 6252
loc_6255:
	ret                             ; 6255

;; ---------------------------------------------------------------- $06256
;; classement : atteinte uniquement par entcmd_72EB
	.area _B01_6256
sub_6256:
	ld c,#0x00                      ; 6256
	ld a,(ascript_C8B1)                 ; 6258
	sub ACTOR_X(iy)                       ; 625B
	jr nc,loc_6263                  ; 625E
	neg                             ; 6260
	inc c                           ; 6262
loc_6263:
	srl a                           ; 6263
	ld (tmp_d5),a                   ; 6265
	call sub_62DD                   ; 6268
	ld (map_bank),hl                ; 626B
	ld a,(ascript_C8B4)                 ; 626E
	sub ACTOR_Y(iy)                       ; 6271
	jr nc,loc_627A                  ; 6274
	neg                             ; 6276
	set 1,c                         ; 6278
loc_627A:
	push bc                         ; 627A
	srl a                           ; 627B
	ld (pal_C0D6),a                 ; 627D
	call sub_62DD                   ; 6280
	ld de,(map_bank)                ; 6283
	add hl,de                       ; 6287
	call sub_62F0                   ; 6288
	ld hl,(dbg_C0D4)                ; 628B
	ld l,#0x00                      ; 628E
	call sub_6326                   ; 6290
	ld d,h                          ; 6293
	ld e,l                          ; 6294
	srl d                           ; 6295
	rr e                            ; 6297
	ld a,(util_C0D9)                 ; 6299
loc_629C:
	dec a                           ; 629C
	jp m,loc_62A3                   ; 629D
	add hl,de                       ; 62A0
	jr loc_629C                     ; 62A1
loc_62A3:
	ld a,c                          ; 62A3
	pop bc                          ; 62A4
	bit 0,c                         ; 62A5
	jr z,loc_62B0                   ; 62A7
	ex de,hl                        ; 62A9
	ld hl,#0x0000                   ; 62AA
	or a                            ; 62AD
	sbc hl,de                       ; 62AE
loc_62B0:
	ld (map_bank),hl                ; 62B0
	push bc                         ; 62B3
	ld c,a                          ; 62B4
	ld hl,(tmp_d5)                  ; 62B5
	ld l,#0x00                      ; 62B8
	call sub_6326                   ; 62BA
	ld d,h                          ; 62BD
	ld e,l                          ; 62BE
	srl d                           ; 62BF
	rr e                            ; 62C1
	ld a,(util_C0D9)                 ; 62C3
loc_62C6:
	dec a                           ; 62C6
	jp m,loc_62CD                   ; 62C7
	add hl,de                       ; 62CA
	jr loc_62C6                     ; 62CB
loc_62CD:
	pop bc                          ; 62CD
	bit 1,c                         ; 62CE
	jr z,loc_62D9                   ; 62D0
	ex de,hl                        ; 62D2
	ld hl,#0x0000                   ; 62D3
	or a                            ; 62D6
	sbc hl,de                       ; 62D7
loc_62D9:
	ld (tmp_d3),hl                  ; 62D9
	ret                             ; 62DC

;; ---------------------------------------------------------------- $062DD
;; classement : atteinte uniquement par entcmd_72EB
	.area _B01_62DD
sub_62DD:
	ld e,a                          ; 62DD
	ld d,#0x00                      ; 62DE
	ld b,#0x08                      ; 62E0
	ld hl,#0x0000                   ; 62E2
loc_62E5:
	rra                             ; 62E5
	jr nc,loc_62E9                  ; 62E6
	add hl,de                       ; 62E8
loc_62E9:
	sla e                           ; 62E9
	rl d                            ; 62EB
	djnz loc_62E5                   ; 62ED
	ret                             ; 62EF

;; ---------------------------------------------------------------- $062F0
;; classement : atteinte uniquement par entcmd_72EB
	.area _B01_62F0
sub_62F0:
	ld de,#0x0000                   ; 62F0
	ld bc,#0x0001                   ; 62F3
	ld a,#0x08                      ; 62F6
loc_62F8:
	push af                         ; 62F8
	add hl,hl                       ; 62F9
	rl e                            ; 62FA
	rl d                            ; 62FC
	add hl,hl                       ; 62FE
	rl e                            ; 62FF
	rl d                            ; 6301
	push hl                         ; 6303
	ld a,#0x02                      ; 6304
	ld h,d                          ; 6306
	ld l,e                          ; 6307
	or a                            ; 6308
	sbc hl,bc                       ; 6309
	jr c,loc_6311                   ; 630B
	ld d,h                          ; 630D
	ld e,l                          ; 630E
	set 2,a                         ; 630F
loc_6311:
	scf                             ; 6311
	rl c                            ; 6312
	rl b                            ; 6314
	xor c                           ; 6316
	ld c,a                          ; 6317
	pop hl                          ; 6318
	pop af                          ; 6319
	dec a                           ; 631A
	jr nz,loc_62F8                  ; 631B
	srl b                           ; 631D
data_631F::
	rr c                            ; 631F
	srl b                           ; 6321
	rr c                            ; 6323
	ret                             ; 6325

;; ---------------------------------------------------------------- $06326
;; classement : atteinte uniquement par entcmd_72EB
	.area _B01_6326
sub_6326:
	ld b,#0x11                      ; 6326
	xor a                           ; 6328
	jr loc_6331                     ; 6329
loc_632B:
	ld d,a                          ; 632B
	sub c                           ; 632C
	jr nc,loc_6330                  ; 632D
	ld a,d                          ; 632F
loc_6330:
	ccf                             ; 6330
loc_6331:
	adc hl,hl                       ; 6331
	rla                             ; 6333
	djnz loc_632B                   ; 6334
	ret                             ; 6336

;; ---------------------------------------------------------------- $07292
;; classement : interpreteur de scripts d'acteurs (banque 25) et ses commandes
	.area _B01_7292
sub_7292::
	ld a,#0x17                      ; 7292
	ld (bank_slot2_shadow),a        ; 7294
	ld (MAPPER_SLOT2),a             ; 7297  mapper : banque du slot 2 ($8000-$BFFF)
	ld a,ACTOR_TYPE(iy)                      ; 729A
	ld hl,#data_b23_B06B            ; 729D
	call sub_481F                   ; 72A0
	jr z,loc_72AD                   ; 72A3
	ld a,ACTOR_STATE(iy)                     ; 72A5
	and #0x84                       ; 72A8
	ret nz                          ; 72AA
	jr sub_72B2                     ; 72AB
loc_72AD:
	ld a,ACTOR_STATE(iy)                     ; 72AD
	or a                            ; 72B0
	ret nz                          ; 72B1

;; ---------------------------------------------------------------- $072B2
;; classement : interpreteur de scripts d'acteurs (banque 25) et ses commandes
	.area _B01_72B2
sub_72B2::
	push bc                         ; 72B2
	ld a,ACTOR_DELAY(iy)                     ; 72B3
	or a                            ; 72B6
	jr z,loc_72C0                   ; 72B7
	dec a                           ; 72B9
	ld ACTOR_DELAY(iy),a                     ; 72BA
	jp nz,loc_7AB6                  ; 72BD
loc_72C0:
	ld a,#0x19                      ; 72C0
	ld (bank_slot2_shadow),a        ; 72C2
	ld (MAPPER_SLOT2),a             ; 72C5  mapper : banque du slot 2 ($8000-$BFFF)
	ld e,ACTOR_SCRIPT_LO(iy)                     ; 72C8
	ld d,ACTOR_SCRIPT_HI(iy)                     ; 72CB
	push de                         ; 72CE
	pop ix                          ; 72CF
	ld a,0(ix)                      ; 72D1
	or a                            ; 72D4
	jp z,loc_774D                   ; 72D5
	cp #0xca                        ; 72D8
	jp c,loc_7A8D                   ; 72DA
	cpl                             ; 72DD
	ld de,#jt_72EB                  ; 72DE
loc_72E1::
	ld l,a                          ; 72E1
	ld h,#0x00                      ; 72E2
	add hl,hl                       ; 72E4
	add hl,de                       ; 72E5
	ld e,(hl)                       ; 72E6
	inc hl                          ; 72E7
	ld d,(hl)                       ; 72E8
	ex de,hl                        ; 72E9
	jp (hl)                         ; 72EA
jt_72EB:
	.dw loc_775C                    ; 72EB
	.dw loc_7778                    ; 72ED
	.dw loc_778F                    ; 72EF
	.dw loc_77DB                    ; 72F1
	.dw loc_7828                    ; 72F3
	.dw loc_785C                    ; 72F5
	.dw loc_7876                    ; 72F7
	.dw loc_7891                    ; 72F9
	.dw loc_78A3                    ; 72FB
	.dw loc_78AD                    ; 72FD
	.dw loc_78B4                    ; 72FF
	.dw loc_7923                    ; 7301
	.dw loc_7945                    ; 7303
	.dw loc_793B                    ; 7305
	.dw loc_795F                    ; 7307
	.dw loc_797A                    ; 7309
	.dw loc_77F3                    ; 730B
	.dw loc_7994                    ; 730D
	.dw loc_79D5                    ; 730F
	.dw loc_79DE                    ; 7311
	.dw loc_7888                    ; 7313
	.dw loc_78E9                    ; 7315
	.dw loc_79CC                    ; 7317
	.dw loc_7A1E                    ; 7319
	.dw loc_77D3                    ; 731B
	.dw loc_7A0E                    ; 731D
	.dw loc_7708                    ; 731F
	.dw loc_75E7                    ; 7321
	.dw loc_7741                    ; 7323
	.dw loc_757D                    ; 7325
	.dw loc_7534                    ; 7327
	.dw loc_7A41                    ; 7329
	.dw loc_7A59                    ; 732B
	.dw loc_76B1                    ; 732D
	.dw loc_7694                    ; 732F
	.dw loc_76C8                    ; 7331
	.dw loc_76F8                    ; 7333
	.dw loc_74EC                    ; 7335
	.dw loc_74BD                    ; 7337
	.dw loc_749C                    ; 7339
	.dw loc_789A                    ; 733B
	.dw loc_76DB                    ; 733D
	.dw loc_765D                    ; 733F
	.dw loc_7910                    ; 7341
	.dw loc_7483                    ; 7343
	.dw loc_7449                    ; 7345
	.dw loc_743C                    ; 7347
	.dw loc_740F                    ; 7349
	.dw loc_73FE                    ; 734B
	.dw loc_73B3                    ; 734D
	.dw loc_7393                    ; 734F
	.dw loc_7386                    ; 7351
	.dw loc_7360                    ; 7353
	.dw loc_7357                    ; 7355
loc_7357:
	call sub_7AC3                   ; 7357
	ld de,#0x0004                   ; 735A
	jp loc_7951                     ; 735D
loc_7360:
	ld l,1(ix)                      ; 7360
	ld h,2(ix)                      ; 7363
	ld a,(hl)                       ; 7366
	cp 3(ix)                        ; 7367
	jr z,loc_737D                   ; 736A
	jr c,loc_7374                   ; 736C
	ld de,#0x0008                   ; 736E
	jp loc_7951                     ; 7371
loc_7374:
	ld l,6(ix)                      ; 7374
	ld h,7(ix)                      ; 7377
	jp loc_76BF                     ; 737A
loc_737D:
	ld l,4(ix)                      ; 737D
	ld h,5(ix)                      ; 7380
	jp loc_76BF                     ; 7383
loc_7386:
	push ix                         ; 7386
	call sub_5B03                   ; 7388
	pop ix                          ; 738B
	ld de,#0x0001                   ; 738D
	jp loc_7951                     ; 7390
loc_7393:
	ld a,1(ix)                      ; 7393
	or a                            ; 7396
	jr z,loc_73A4                   ; 7397
	ld e,3(ix)                      ; 7399
	ld d,2(ix)                      ; 739C
	call sub_7BEF                   ; 739F
	jr nz,loc_73AD                  ; 73A2
loc_73A4:
	ld l,4(ix)                      ; 73A4
	ld h,5(ix)                      ; 73A7
	jp loc_76BF                     ; 73AA
loc_73AD:
	ld de,#0x0006                   ; 73AD
	jp loc_7951                     ; 73B0
loc_73B3:
	xor a                           ; 73B3
	ld ACTOR_VY_LO(iy),a                     ; 73B4
	ld ACTOR_VY_HI(iy),a                     ; 73B7
	ld a,1(ix)                      ; 73BA
	ld ACTOR_VX_HI(iy),a                     ; 73BD
	ld a,2(ix)                      ; 73C0
	or a                            ; 73C3
	jr z,loc_73D1                   ; 73C4
	ld e,5(ix)                      ; 73C6
	ld d,4(ix)                      ; 73C9
	call sub_7BEF                   ; 73CC
	jr nz,loc_73E2                  ; 73CF
loc_73D1:
	ld a,3(ix)                      ; 73D1
	or a                            ; 73D4
	jr z,loc_73F5                   ; 73D5
	ld e,5(ix)                      ; 73D7
	ld d,4(ix)                      ; 73DA
	call sub_7BEF                   ; 73DD
	jr z,loc_73F5                   ; 73E0
loc_73E2:
	ld de,#0x0012                   ; 73E2
	add hl,de                       ; 73E5
	ld a,(hl)                       ; 73E6
	ld ACTOR_VY_LO(iy),a                     ; 73E7
	inc hl                          ; 73EA
	ld a,(hl)                       ; 73EB
	ld ACTOR_VY_HI(iy),a                     ; 73EC
	ld de,#0x0008                   ; 73EF
	jp loc_7951                     ; 73F2
loc_73F5:
	ld l,6(ix)                      ; 73F5
	ld h,7(ix)                      ; 73F8
	jp loc_76BF                     ; 73FB
loc_73FE:
	ld l,1(ix)                      ; 73FE
	ld h,2(ix)                      ; 7401
	ld a,3(ix)                      ; 7404
	or (hl)                         ; 7407
	ld (hl),a                       ; 7408
	ld de,#0x0004                   ; 7409
	jp loc_7951                     ; 740C
loc_740F:
	push iy                         ; 740F
	ld e,1(ix)                      ; 7411
	ld d,#0x00                      ; 7414
	add iy,de                       ; 7416
	ld a,ACTOR_TYPE(iy)                      ; 7418
	pop iy                          ; 741B
	cp 2(ix)                        ; 741D
	jr z,loc_7433                   ; 7420
	jr c,loc_742A                   ; 7422
	ld de,#0x0007                   ; 7424
	jp loc_7951                     ; 7427
loc_742A:
	ld l,5(ix)                      ; 742A
	ld h,6(ix)                      ; 742D
	jp loc_76BF                     ; 7430
loc_7433:
	ld l,3(ix)                      ; 7433
	ld h,4(ix)                      ; 7436
	jp loc_76BF                     ; 7439
loc_743C:
	ld hl,#game_flags               ; 743C
	set 4,(hl)                      ; 743F
	set 2,(hl)                      ; 7441
	ld de,#0x0001                   ; 7443
	jp loc_7951                     ; 7446
loc_7449:
	ld a,ACTOR_X_HI(iy)                      ; 7449
	or ACTOR_Y_HI(iy)                        ; 744C
	jr nz,loc_747A                  ; 744F
	ld a,ACTOR_X(iy)                      ; 7451
	add a,1(ix)                     ; 7454
	ld (tmp_d3),a                   ; 7457
	ld a,ACTOR_Y(iy)                      ; 745A
	add a,2(ix)                     ; 745D
	ld (tmp_d5),a                   ; 7460
	call sub_2AD8                   ; 7463
	call sub_2AA8                   ; 7466
	and 5(ix)                       ; 7469
	ld a,#0x19                      ; 746C
	ld (bank_slot2_shadow),a        ; 746E
	ld (MAPPER_SLOT2),a             ; 7471  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#0x0006                   ; 7474
	jp z,loc_7951                   ; 7477
loc_747A:
	ld l,3(ix)                      ; 747A
	ld h,4(ix)                      ; 747D
	jp loc_76BF                     ; 7480
loc_7483:
	push iy                         ; 7483
	pop hl                          ; 7485
	ld de,(player_C1DF)                ; 7486
	or a                            ; 748A
	sbc hl,de                       ; 748B
	ld de,#0x0003                   ; 748D
	jp nz,loc_7951                  ; 7490
	ld l,1(ix)                      ; 7493
	ld h,2(ix)                      ; 7496
	jp loc_76BF                     ; 7499
loc_749C:
	ld l,1(ix)                      ; 749C
	ld h,2(ix)                      ; 749F
	ld ACTOR_PARENT_LO(iy),l                     ; 74A2
	ld ACTOR_PARENT_HI(iy),h                     ; 74A5
	ld l,3(ix)                      ; 74A8
	ld h,4(ix)                      ; 74AB
	ld ACTOR_OSC_X(iy),l                     ; 74AE
	ld ACTOR_OSC_Y(iy),h                     ; 74B1
	call sub_3B78                   ; 74B4
	ld de,#0x0005                   ; 74B7
	jp loc_7951                     ; 74BA
loc_74BD:
	ld a,(game_mode)                ; 74BD
	cp #0x00                        ; 74C0
	jr nz,loc_74CB                  ; 74C2
	ld hl,#game_flags               ; 74C4
	bit 1,(hl)                      ; 74C7
	jr nz,loc_74E6                  ; 74C9
loc_74CB:
	ld l,1(ix)                      ; 74CB
	ld h,2(ix)                      ; 74CE
	ld a,3(ix)                      ; 74D1
	ld e,4(ix)                      ; 74D4
	ld d,5(ix)                      ; 74D7
	and (hl)                        ; 74DA
	jr nz,loc_74E6                  ; 74DB
	ld ACTOR_SCRIPT_LO(iy),e                     ; 74DD
	ld ACTOR_SCRIPT_HI(iy),d                     ; 74E0
	jp loc_72C0                     ; 74E3
loc_74E6:
	ld de,#0x0006                   ; 74E6
	jp loc_7951                     ; 74E9
loc_74EC:
	ld l,1(ix)                      ; 74EC
	ld h,2(ix)                      ; 74EF
	ld e,(hl)                       ; 74F2
	ld d,#0x00                      ; 74F3
	ld hl,#jt_7500                  ; 74F5
	ex de,hl                        ; 74F8
	add hl,hl                       ; 74F9
	add hl,de                       ; 74FA
	ld e,(hl)                       ; 74FB
	inc hl                          ; 74FC
	ld d,(hl)                       ; 74FD
	ex de,hl                        ; 74FE
	jp (hl)                         ; 74FF
jt_7500:
	.dw loc_750A                    ; 7500
	.dw loc_7510                    ; 7502
	.dw loc_7519                    ; 7504
	.dw loc_7522                    ; 7506
	.dw loc_752B                    ; 7508
loc_750A:
	ld de,#0x000b                   ; 750A
	jp loc_7951                     ; 750D
loc_7510:
	ld l,3(ix)                      ; 7510
	ld h,4(ix)                      ; 7513
	jp loc_76BF                     ; 7516
loc_7519:
	ld l,5(ix)                      ; 7519
	ld h,6(ix)                      ; 751C
	jp loc_76BF                     ; 751F
loc_7522:
	ld l,7(ix)                      ; 7522
	ld h,8(ix)                      ; 7525
	jp loc_76BF                     ; 7528
loc_752B:
	ld l,9(ix)                      ; 752B
	ld h,10(ix)                     ; 752E
	jp loc_76BF                     ; 7531
loc_7534:
	ld hl,#actor_CDD7                 ; 7534
	ld b,#0x07                      ; 7537
loc_7539:
	ld a,(hl)                       ; 7539
	cp 1(ix)                        ; 753A
	jr z,loc_7574                   ; 753D
	push hl                         ; 753F
	ld de,#0x0023                   ; 7540
	add hl,de                       ; 7543
	ld a,(hl)                       ; 7544
	pop hl                          ; 7545
	cp 1(ix)                        ; 7546
	jr z,loc_7574                   ; 7549
	ld de,#0x0028                   ; 754B
	add hl,de                       ; 754E
	djnz loc_7539                   ; 754F
	ld hl,#actor_CB07                 ; 7551
	ld b,#0x04                      ; 7554
loc_7556:
	ld a,(hl)                       ; 7556
	cp 1(ix)                        ; 7557
	jr z,loc_7574                   ; 755A
	push hl                         ; 755C
	ld de,#0x0023                   ; 755D
	add hl,de                       ; 7560
	ld a,(hl)                       ; 7561
	pop hl                          ; 7562
	cp 1(ix)                        ; 7563
	jr z,loc_7574                   ; 7566
	ld de,#0x0028                   ; 7568
	add hl,de                       ; 756B
	djnz loc_7556                   ; 756C
	ld de,#0x0004                   ; 756E
	jp loc_7951                     ; 7571
loc_7574:
	ld l,2(ix)                      ; 7574
	ld h,3(ix)                      ; 7577
	jp loc_76BF                     ; 757A
loc_757D:
	ld a,ACTOR_X_HI(iy)                      ; 757D
	or ACTOR_Y_HI(iy)                        ; 7580
	ld de,#0x000d                   ; 7583
	jp nz,loc_7951                  ; 7586
	ld a,(player_CEF4)                 ; 7589
	add a,12(ix)                    ; 758C
	sub ACTOR_Y(iy)                       ; 758F
	jp p,loc_7597                   ; 7592
	neg                             ; 7595
loc_7597:
	cp 2(ix)                        ; 7597
	jp nc,loc_7951                  ; 759A
	ld a,(player_CEF1)                 ; 759D
	add a,11(ix)                    ; 75A0
	sub ACTOR_X(iy)                       ; 75A3
	jp p,loc_75AB                   ; 75A6
	neg                             ; 75A9
loc_75AB:
	cp 1(ix)                        ; 75AB
	jp nc,loc_7951                  ; 75AE
	ld a,(player_CEF4)                 ; 75B1
	cp ACTOR_Y(iy)                        ; 75B4
	ld a,(player_CEF1)                 ; 75B7
	jr nc,loc_75D1                  ; 75BA
	cp ACTOR_X(iy)                        ; 75BC
	jr nc,loc_75C9                  ; 75BF
	ld l,3(ix)                      ; 75C1
	ld h,4(ix)                      ; 75C4
	jr loc_75E4                     ; 75C7
loc_75C9:
	ld l,5(ix)                      ; 75C9
	ld h,6(ix)                      ; 75CC
	jr loc_75E4                     ; 75CF
loc_75D1:
	cp ACTOR_X(iy)                        ; 75D1
	jr nc,loc_75DE                  ; 75D4
	ld l,7(ix)                      ; 75D6
	ld h,8(ix)                      ; 75D9
	jr loc_75E4                     ; 75DC
loc_75DE:
	ld l,9(ix)                      ; 75DE
	ld h,10(ix)                     ; 75E1
loc_75E4:
	jp loc_76BF                     ; 75E4
loc_75E7:
	ld a,ACTOR_X_HI(iy)                      ; 75E7
	or ACTOR_Y_HI(iy)                        ; 75EA
	ld de,#0x0006                   ; 75ED
	jp nz,loc_7951                  ; 75F0
	ld a,ACTOR_X(iy)                      ; 75F3
	ld (tmp_d3),a                   ; 75F6
	ld a,ACTOR_Y(iy)                      ; 75F9
	ld (tmp_d5),a                   ; 75FC
	call sub_2A7A                   ; 75FF
	ld l,1(ix)                      ; 7602
	ld de,#jt_760B                  ; 7605
	jp util_jump_table              ; 7608
jt_760B:
	.dw loc_7613                    ; 760B
	.dw loc_7632                    ; 760D
	.dw loc_7645                    ; 760F
	.dw loc_7651                    ; 7611
loc_7613:
	ld hl,(tmp_d3)                  ; 7613
loc_7616:
	ld e,2(ix)                      ; 7616
	ld d,3(ix)                      ; 7619
	or a                            ; 761C
	sbc hl,de                       ; 761D
	jr c,loc_7629                   ; 761F
	jr z,loc_7629                   ; 7621
loc_7623:
	ld de,#0x0006                   ; 7623
	jp loc_7951                     ; 7626
loc_7629:
	ld l,4(ix)                      ; 7629
	ld h,5(ix)                      ; 762C
	jp loc_76BF                     ; 762F
loc_7632:
	ld hl,(tmp_d3)                  ; 7632
loc_7635:
	ld e,2(ix)                      ; 7635
	ld d,3(ix)                      ; 7638
	or a                            ; 763B
	sbc hl,de                       ; 763C
	ld de,#0x0006                   ; 763E
	jr nc,loc_7629                  ; 7641
	jr loc_7623                     ; 7643
loc_7645:
	ld de,(tmp_d5)                  ; 7645
	ld hl,#0x0000                   ; 7649
	or a                            ; 764C
	sbc hl,de                       ; 764D
	jr loc_7616                     ; 764F
loc_7651:
	ld de,(tmp_d5)                  ; 7651
	ld hl,#0x0000                   ; 7655
	or a                            ; 7658
	sbc hl,de                       ; 7659
	jr loc_7635                     ; 765B
loc_765D:
	ld l,2(ix)                      ; 765D
	ld h,3(ix)                      ; 7660
	ld de,#0x0000                   ; 7663
	ld a,1(ix)                      ; 7666
	or a                            ; 7669
	jr z,loc_767E                   ; 766A
	ld (tmp_d3),de                  ; 766C
	ld (tmp_d5),hl                  ; 7670
	call sub_3036                   ; 7673
	ld a,(tmp_d5)                   ; 7676
	ld ACTOR_Y(iy),a                      ; 7679
	jr loc_768E                     ; 767C
loc_767E:
	ld (tmp_d3),hl                  ; 767E
	ld (tmp_d5),de                  ; 7681
	call sub_3036                   ; 7685
	ld a,(tmp_d3)                   ; 7688
	ld ACTOR_X(iy),a                      ; 768B
loc_768E:
	ld de,#0x0004                   ; 768E
	jp loc_7951                     ; 7691
loc_7694:
	ld a,ACTOR_LOOP(iy)                     ; 7694
	dec a                           ; 7697
	ld ACTOR_LOOP(iy),a                     ; 7698
	jr nz,loc_76A9                  ; 769B
	ld de,#0x0003                   ; 769D
	ld l,ACTOR_SCRIPT_LO(iy)                     ; 76A0
	ld h,ACTOR_SCRIPT_HI(iy)                     ; 76A3
	add hl,de                       ; 76A6
	jr loc_76BF                     ; 76A7
loc_76A9:
	ld l,1(ix)                      ; 76A9
	ld h,2(ix)                      ; 76AC
	jr loc_76BF                     ; 76AF
loc_76B1:
	ld a,1(ix)                      ; 76B1
	ld ACTOR_LOOP(iy),a                     ; 76B4
	ld l,ACTOR_SCRIPT_LO(iy)                     ; 76B7
	ld h,ACTOR_SCRIPT_HI(iy)                     ; 76BA
	inc hl                          ; 76BD
	inc hl                          ; 76BE
loc_76BF:
	ld ACTOR_SCRIPT_LO(iy),l                     ; 76BF
	ld ACTOR_SCRIPT_HI(iy),h                     ; 76C2
	jp loc_72C0                     ; 76C5
loc_76C8:
	ld e,1(ix)                      ; 76C8
	ld d,#0x00                      ; 76CB
	push iy                         ; 76CD
	pop hl                          ; 76CF
	add hl,de                       ; 76D0
	ld a,2(ix)                      ; 76D1
	ld (hl),a                       ; 76D4
	ld de,#0x0003                   ; 76D5
	jp loc_7951                     ; 76D8
loc_76DB:
	ld e,1(ix)                      ; 76DB
	ld d,#0x00                      ; 76DE
	push iy                         ; 76E0
	pop hl                          ; 76E2
	add hl,de                       ; 76E3
	ld a,2(ix)                      ; 76E4
	cp (hl)                         ; 76E7
	jr nz,loc_76F2                  ; 76E8
	ld l,3(ix)                      ; 76EA
	ld h,4(ix)                      ; 76ED
	jr loc_76BF                     ; 76F0
loc_76F2:
	ld de,#0x0005                   ; 76F2
	jp loc_7951                     ; 76F5
loc_76F8:
	ld l,1(ix)                      ; 76F8
	ld h,2(ix)                      ; 76FB
	ld a,3(ix)                      ; 76FE
	ld (hl),a                       ; 7701
	ld de,#0x0004                   ; 7702
	jp loc_7951                     ; 7705
loc_7708:
	ld a,ACTOR_TYPE(iy)                      ; 7708
	or a                            ; 770B
	jr z,loc_7731                   ; 770C
	ld ACTOR_SAVED_TYPE(iy),a                     ; 770E
	ld ACTOR_TYPE(iy),#0x00                  ; 7711
	ld a,1(ix)                      ; 7715
	ld ACTOR_DELAY(iy),a                     ; 7718
	ld ACTOR_VX_LO(iy),#0x00                 ; 771B
	ld ACTOR_VX_HI(iy),#0x00                 ; 771F
	ld ACTOR_VY_LO(iy),#0x00                 ; 7723
	ld ACTOR_VY_HI(iy),#0x00                 ; 7727
	ld de,#0x0000                   ; 772B
	jp loc_7AAB                     ; 772E
loc_7731:
	ld a,ACTOR_SAVED_TYPE(iy)                     ; 7731
	ld ACTOR_SAVED_TYPE(iy),#0x00                 ; 7734
	ld ACTOR_TYPE(iy),a                      ; 7738
	ld de,#0x0002                   ; 773B
	jp loc_7951                     ; 773E
loc_7741:
	ld a,1(ix)                      ; 7741
	ld ACTOR_DELAY(iy),a                     ; 7744
	ld de,#0x0002                   ; 7747
	jp loc_7AAB                     ; 774A
loc_774D:
	ld a,1(ix)                      ; 774D
	ld ACTOR_SCRIPT_LO(iy),a                     ; 7750
	ld a,2(ix)                      ; 7753
	ld ACTOR_SCRIPT_HI(iy),a                     ; 7756
	jp loc_72C0                     ; 7759
loc_775C:
	push ix                         ; 775C
	pop de                          ; 775E
	ld hl,#0x0003                   ; 775F
	add hl,de                       ; 7762
	ld ACTOR_RET_LO(iy),l                     ; 7763
	ld ACTOR_RET_HI(iy),h                     ; 7766
	ld a,1(ix)                      ; 7769
	ld ACTOR_SCRIPT_LO(iy),a                     ; 776C
	ld a,2(ix)                      ; 776F
	ld ACTOR_SCRIPT_HI(iy),a                     ; 7772
	jp loc_72C0                     ; 7775
loc_7778:
	ld a,ACTOR_RET_LO(iy)                     ; 7778
	ld ACTOR_SCRIPT_LO(iy),a                     ; 777B
	ld a,ACTOR_RET_HI(iy)                     ; 777E
	ld ACTOR_SCRIPT_HI(iy),a                     ; 7781
	ld ACTOR_RET_LO(iy),#0x00                 ; 7784
	ld ACTOR_RET_HI(iy),#0x00                 ; 7788
	jp loc_72C0                     ; 778C
loc_778F:
	ld a,1(ix)                      ; 778F
	ld ACTOR_DELAY(iy),a                     ; 7792
	ld a,2(ix)                      ; 7795
	push af                         ; 7798
	and #0x0f                       ; 7799
	bit 3,a                         ; 779B
	jr z,loc_77A1                   ; 779D
	or #0xf0                        ; 779F
loc_77A1:
	ld ACTOR_VY_LO(iy),#0x00                 ; 77A1
	ld ACTOR_VY_HI(iy),a                     ; 77A5
	pop af                          ; 77A8
	and #0xf0                       ; 77A9
	rra                             ; 77AB
	rra                             ; 77AC
	rra                             ; 77AD
	rra                             ; 77AE
	bit 3,a                         ; 77AF
	jr z,loc_77B5                   ; 77B1
	or #0xf0                        ; 77B3
loc_77B5:
	ld ACTOR_VX_LO(iy),#0x00                 ; 77B5
	ld ACTOR_VX_HI(iy),a                     ; 77B9
	push iy                         ; 77BC
	pop de                          ; 77BE
	or a                            ; 77BF
	ld hl,#player_state             ; 77C0
	sbc hl,de                       ; 77C3
	jr nz,loc_77CD                  ; 77C5
	ld hl,(player_CF01)                ; 77C7
	ld (player_CF11),hl                ; 77CA
loc_77CD:
	ld de,#0x0003                   ; 77CD
	jp loc_7AAB                     ; 77D0
loc_77D3:
	ld a,1(ix)                      ; 77D3
	ld ACTOR_DIR(iy),a                     ; 77D6
	jr loc_77ED                     ; 77D9
loc_77DB:
	ld a,1(ix)                      ; 77DB
	ld ACTOR_ANIM(iy),a                      ; 77DE
	ld ACTOR_ANIM_FRAME(iy),#0x00                  ; 77E1
	ld ACTOR_ANIM_TIMER(iy),#0x00                  ; 77E5
	ld ACTOR_ANIM_END(iy),#0x00                 ; 77E9
loc_77ED:
	ld de,#0x0002                   ; 77ED
	jp loc_7951                     ; 77F0
loc_77F3:
	push ix                         ; 77F3
	ld d,1(ix)                      ; 77F5
	ld e,2(ix)                      ; 77F8
	ld ix,#player_state             ; 77FB
	ld h,2(ix)                      ; 77FF
	ld l,5(ix)                      ; 7802
	push hl                         ; 7805
	ld a,h                          ; 7806
	add a,d                         ; 7807
	ld 2(ix),a                      ; 7808
	ld a,l                          ; 780B
data_780C::
	add a,e                         ; 780C
	ld 5(ix),a                      ; 780D
	call sub_7B86                   ; 7810
	call sub_7BCE                   ; 7813
data_7816::
	ld ACTOR_DIR(iy),a                     ; 7816
	pop hl                          ; 7819
	ld 2(ix),h                      ; 781A
	ld 5(ix),l                      ; 781D
	pop ix                          ; 7820
	ld de,#0x0003                   ; 7822
	jp loc_7951                     ; 7825
loc_7828:
	push ix                         ; 7828
	ld d,1(ix)                      ; 782A
	ld e,2(ix)                      ; 782D
	ld ix,#player_state             ; 7830
	ld h,2(ix)                      ; 7834
	ld l,5(ix)                      ; 7837
	push hl                         ; 783A
	ld a,h                          ; 783B
	add a,d                         ; 783C
	ld 2(ix),a                      ; 783D
	ld a,l                          ; 7840
	add a,e                         ; 7841
	ld 5(ix),a                      ; 7842
	call sub_7B86                   ; 7845
	srl a                           ; 7848
	ld ACTOR_DIR(iy),a                     ; 784A
	pop hl                          ; 784D
	ld 2(ix),h                      ; 784E
	ld 5(ix),l                      ; 7851
	pop ix                          ; 7854
	ld de,#0x0003                   ; 7856
	jp loc_7951                     ; 7859
loc_785C:
	ld a,ACTOR_DIR(iy)                     ; 785C
	and #0x07                       ; 785F
	add a,a                         ; 7861
	ld l,a                          ; 7862
	ld h,#0x00                      ; 7863
	push ix                         ; 7865
	pop de                          ; 7867
	inc de                          ; 7868
	add hl,de                       ; 7869
	ld e,(hl)                       ; 786A
	inc hl                          ; 786B
	ld d,(hl)                       ; 786C
	ld ACTOR_SCRIPT_LO(iy),e                     ; 786D
	ld ACTOR_SCRIPT_HI(iy),d                     ; 7870
	jp loc_72C0                     ; 7873
loc_7876:
	ld a,ACTOR_DIR(iy)                     ; 7876
	inc a                           ; 7879
	cp #0x08                        ; 787A
	jr c,loc_787F                   ; 787C
	xor a                           ; 787E
loc_787F:
	ld ACTOR_DIR(iy),a                     ; 787F
	ld de,#0x0001                   ; 7882
	jp loc_7951                     ; 7885
loc_7888:
	call sub_7B0D                   ; 7888
	ld de,#0x0004                   ; 788B
	jp loc_7951                     ; 788E
loc_7891:
	call sub_7B19                   ; 7891
	ld de,#0x0004                   ; 7894
	jp loc_7951                     ; 7897
loc_789A:
	call sub_7B14                   ; 789A
	ld de,#0x0004                   ; 789D
	jp loc_7951                     ; 78A0
loc_78A3:
	set 0,ACTOR_FLAGS(iy)                    ; 78A3
	ld de,#0x0001                   ; 78A7
	jp loc_7AAB                     ; 78AA
loc_78AD:
	ld ACTOR_DELAY(iy),#0xff                 ; 78AD
	jp loc_7AB6                     ; 78B1
loc_78B4:
	ld hl,#player_state             ; 78B4
	ld de,#sprite_C8AF                 ; 78B7
	push bc                         ; 78BA
	ld bc,#0x0028                   ; 78BB
	ldir                            ; 78BE
data_78C0::
	ld a,(ascript_C8B1)                 ; 78C0
	add a,3(ix)                     ; 78C3
	ld (ascript_C8B1),a                 ; 78C6
	ld a,(ascript_C8B4)                 ; 78C9
data_78CC::
	add a,4(ix)                     ; 78CC
	ld (ascript_C8B4),a                 ; 78CF
	ld a,5(ix)                      ; 78D2
	ld (flow_C0DB),a                 ; 78D5
	ld a,6(ix)                      ; 78D8
	ld (ascript_C0DC),a                 ; 78DB
	pop bc                          ; 78DE
	call sub_61A3                   ; 78DF
	xor a                           ; 78E2
	ld (sprite_C8AF),a                 ; 78E3
	jp loc_72C0                     ; 78E6
loc_78E9:
	inc ix                          ; 78E9
	ld l,0(ix)                      ; 78EB
	inc ix                          ; 78EE
	ld h,0(ix)                      ; 78F0
	ld a,(hl)                       ; 78F3
	or #0x00                        ; 78F4
	jr nz,loc_78FD                  ; 78F6
	ld hl,#0x0003                   ; 78F8
	jr loc_7900                     ; 78FB
loc_78FD:
	ld hl,#0x0001                   ; 78FD
loc_7900:
	push ix                         ; 7900
	pop de                          ; 7902
	add hl,de                       ; 7903
	ld e,(hl)                       ; 7904
	inc hl                          ; 7905
	ld d,(hl)                       ; 7906
	ld ACTOR_SCRIPT_LO(iy),e                     ; 7907
	ld ACTOR_SCRIPT_HI(iy),d                     ; 790A
	jp loc_72C0                     ; 790D
loc_7910:
	ld l,ACTOR_PARENT_LO(iy)                     ; 7910
	ld h,ACTOR_PARENT_HI(iy)                     ; 7913
	ld de,#0x0005                   ; 7916
	add hl,de                       ; 7919
	ld (hl),#0x40                   ; 791A
	ld ACTOR_TYPE(iy),#0x00                  ; 791C
	jp loc_7AB6                     ; 7920
loc_7923:
	ld ACTOR_TYPE(iy),#0x00                  ; 7923
	ld l,ACTOR_PARENT_LO(iy)                     ; 7927
	ld h,ACTOR_PARENT_HI(iy)                     ; 792A
	ld a,l                          ; 792D
	or h                            ; 792E
	jp z,loc_7AB6                   ; 792F
	ld de,#0x0005                   ; 7932
	add hl,de                       ; 7935
	ld (hl),#0x00                   ; 7936
	jp loc_7AB6                     ; 7938
loc_793B:
	ld a,1(ix)                      ; 793B
	xor #0xff                       ; 793E
data_7940::
	and ACTOR_FLAGS(iy)                      ; 7940
	jr loc_794B                     ; 7943
loc_7945:
	ld a,1(ix)                      ; 7945
	or ACTOR_FLAGS(iy)                       ; 7948
loc_794B:
	ld ACTOR_FLAGS(iy),a                     ; 794B
data_794E::
	ld de,#0x0002                   ; 794E
loc_7951:
	add ix,de                       ; 7951
	push ix                         ; 7953
	pop hl                          ; 7955
	ld ACTOR_SCRIPT_LO(iy),l                     ; 7956
	ld ACTOR_SCRIPT_HI(iy),h                     ; 7959
	jp loc_72C0                     ; 795C
loc_795F:
	ld de,#0x0004                   ; 795F
	ld a,1(ix)                      ; 7962
	cp ACTOR_COUNTER(iy)                       ; 7965
	jp c,loc_7AAB                   ; 7968
	ld l,2(ix)                      ; 796B
	ld h,3(ix)                      ; 796E
	ld ACTOR_SCRIPT_LO(iy),l                     ; 7971
	ld ACTOR_SCRIPT_HI(iy),h                     ; 7974
	jp loc_72C0                     ; 7977
loc_797A:
	ld l,1(ix)                      ; 797A
	ld h,2(ix)                      ; 797D
	xor a                           ; 7980
	or (hl)                         ; 7981
	jp nz,loc_7994                  ; 7982
	ld a,4(ix)                      ; 7985
	ld ACTOR_SCRIPT_LO(iy),a                     ; 7988
	ld a,5(ix)                      ; 798B
	ld ACTOR_SCRIPT_HI(iy),a                     ; 798E
	jp loc_72C0                     ; 7991
loc_7994:
	ld hl,#0x0000                   ; 7994
	push hl                         ; 7997
	ld a,(player_CEF1)                 ; 7998
	ld b,a                          ; 799B
data_799C::
	ld a,ACTOR_X(iy)                      ; 799C
	sub b                           ; 799F
	jr c,loc_79AE                   ; 79A0
	cp #0x0c                        ; 79A2
	ld hl,#0x0003                   ; 79A4
	jr nc,loc_79BA                  ; 79A7
	ld hl,#0x0001                   ; 79A9
	jr loc_79BA                     ; 79AC
loc_79AE:
	neg                             ; 79AE
	cp #0x0c                        ; 79B0
	ld hl,#0x0005                   ; 79B2
	jr nc,loc_79BA                  ; 79B5
	ld hl,#0x0001                   ; 79B7
loc_79BA:
	push ix                         ; 79BA
	pop de                          ; 79BC
	add hl,de                       ; 79BD
	pop de                          ; 79BE
	add hl,de                       ; 79BF
	ld e,(hl)                       ; 79C0
	inc hl                          ; 79C1
	ld d,(hl)                       ; 79C2
	ld ACTOR_SCRIPT_LO(iy),e                     ; 79C3
	ld ACTOR_SCRIPT_HI(iy),d                     ; 79C6
	jp loc_72C0                     ; 79C9
loc_79CC:
	call sub_7AB8                   ; 79CC
	ld de,#0x0007                   ; 79CF
	jp loc_7951                     ; 79D2
loc_79D5:
	call sub_7B02                   ; 79D5
	ld de,#0x0004                   ; 79D8
	jp loc_7951                     ; 79DB
loc_79DE:
	ld b,#0x6c                      ; 79DE
	ld a,ACTOR_X(iy)                      ; 79E0
	sub b                           ; 79E3
	jr c,loc_79F2                   ; 79E4
	cp #0x24                        ; 79E6
	ld hl,#0x0003                   ; 79E8
	jr nc,loc_79FE                  ; 79EB
	ld hl,#0x0001                   ; 79ED
	jr loc_79FE                     ; 79F0
loc_79F2:
	neg                             ; 79F2
	cp #0x24                        ; 79F4
	ld hl,#0x0005                   ; 79F6
	jr nc,loc_79FE                  ; 79F9
	ld hl,#0x0001                   ; 79FB
loc_79FE:
	push ix                         ; 79FE
	pop de                          ; 7A00
	add hl,de                       ; 7A01
	ld e,(hl)                       ; 7A02
	inc hl                          ; 7A03
	ld d,(hl)                       ; 7A04
	ld ACTOR_SCRIPT_LO(iy),e                     ; 7A05
	ld ACTOR_SCRIPT_HI(iy),d                     ; 7A08
	jp loc_72C0                     ; 7A0B
loc_7A0E:
	ld a,ACTOR_HIT(iy)                     ; 7A0E
	cp #0xfd                        ; 7A11
	ld de,#0x0003                   ; 7A13
	jp c,loc_7951                   ; 7A16
	ld hl,#0x0001                   ; 7A19
data_7A1C::
	jr loc_7A31                     ; 7A1C
loc_7A1E:
	inc ix                          ; 7A1E
	ld b,0(ix)                      ; 7A20
	ld a,ACTOR_Y(iy)                      ; 7A23
	cp b                            ; 7A26
	jr c,loc_7A2E                   ; 7A27
	ld hl,#0x0003                   ; 7A29
	jr loc_7A31                     ; 7A2C
loc_7A2E:
	ld hl,#0x0001                   ; 7A2E
loc_7A31:
	push ix                         ; 7A31
	pop de                          ; 7A33
	add hl,de                       ; 7A34
	ld e,(hl)                       ; 7A35
	inc hl                          ; 7A36
	ld d,(hl)                       ; 7A37
	ld ACTOR_SCRIPT_LO(iy),e                     ; 7A38
	ld ACTOR_SCRIPT_HI(iy),d                     ; 7A3B
	jp loc_72C0                     ; 7A3E
loc_7A41:
	ld a,1(ix)                      ; 7A41
	ld ACTOR_LOOP(iy),a                     ; 7A44
	ld a,2(ix)                      ; 7A47
	ld ACTOR_OSC_X(iy),a                     ; 7A4A
	ld a,3(ix)                      ; 7A4D
	ld ACTOR_OSC_Y(iy),a                     ; 7A50
	ld de,#0x0004                   ; 7A53
	jp loc_7951                     ; 7A56
loc_7A59:
	push ix                         ; 7A59
	ld a,ACTOR_LOOP(iy)                     ; 7A5B
	ld ACTOR_DELAY(iy),a                     ; 7A5E
	inc ix                          ; 7A61
	ld e,ACTOR_OSC_X(iy)                     ; 7A63
	ld d,#0x00                      ; 7A66
	push ix                         ; 7A68
	pop hl                          ; 7A6A
	call sub_7B63                   ; 7A6B
	ld ACTOR_VX_LO(iy),e                     ; 7A6E
	ld ACTOR_VX_HI(iy),d                     ; 7A71
data_7A74::
	inc ix                          ; 7A74
	inc ix                          ; 7A76
	ld e,ACTOR_OSC_Y(iy)                     ; 7A78
	ld d,#0x00                      ; 7A7B
	push ix                         ; 7A7D
	pop hl                          ; 7A7F
	call sub_7B63                   ; 7A80
	ld ACTOR_VY_LO(iy),e                     ; 7A83
	ld ACTOR_VY_HI(iy),d                     ; 7A86
	pop ix                          ; 7A89
	jr loc_7AA8                     ; 7A8B
loc_7A8D:
	ld ACTOR_DELAY(iy),a                     ; 7A8D
	ld a,1(ix)                      ; 7A90
	ld ACTOR_VX_LO(iy),a                     ; 7A93
	ld a,2(ix)                      ; 7A96
	ld ACTOR_VX_HI(iy),a                     ; 7A99
data_7A9C::
	ld a,3(ix)                      ; 7A9C
	ld ACTOR_VY_LO(iy),a                     ; 7A9F
	ld a,4(ix)                      ; 7AA2
	ld ACTOR_VY_HI(iy),a                     ; 7AA5
loc_7AA8:
	ld de,#0x0005                   ; 7AA8
loc_7AAB:
	add ix,de                       ; 7AAB
	push ix                         ; 7AAD
	pop hl                          ; 7AAF
	ld ACTOR_SCRIPT_LO(iy),l                     ; 7AB0
	ld ACTOR_SCRIPT_HI(iy),h                     ; 7AB3
loc_7AB6:
	pop bc                          ; 7AB6
	ret                             ; 7AB7

;; ---------------------------------------------------------------- $07AB8
;; classement : interpreteur de scripts d'acteurs (banque 25) et ses commandes
	.area _B01_7AB8
sub_7AB8:
	ld b,#0x0a                      ; 7AB8
	ld hl,#ascript_CCE7                 ; 7ABA
	call sub_3BCD                   ; 7ABD
	ret nz                          ; 7AC0
	jr loc_7B29                     ; 7AC1

;; ---------------------------------------------------------------- $07AC3
;; classement : interpreteur de scripts d'acteurs (banque 25) et ses commandes
	.area _B01_7AC3
sub_7AC3:
	ld b,#0x0d                      ; 7AC3
	ld hl,#scene_script_ptr         ; 7AC5
	call sub_3BCD                   ; 7AC8
	ret nz                          ; 7ACB
	push iy                         ; 7ACC
	push hl                         ; 7ACE
	call sub_3BD8                   ; 7ACF
	ld a,ACTOR_X(iy)                      ; 7AD2
	add a,2(ix)                     ; 7AD5
	ld l,a                          ; 7AD8
	ld a,ACTOR_Y(iy)                      ; 7AD9
	add a,3(ix)                     ; 7ADC
	ld h,a                          ; 7ADF
	pop iy                          ; 7AE0
	ld ACTOR_X(iy),l                      ; 7AE2
	ld ACTOR_Y(iy),h                      ; 7AE5
	ld l,1(ix)                      ; 7AE8
	ld h,#0x00                      ; 7AEB
	add hl,hl                       ; 7AED
	ld de,#data_7C54                ; 7AEE
	add hl,de                       ; 7AF1
	ld a,(hl)                       ; 7AF2
	ld ACTOR_SCRIPT_LO(iy),a                     ; 7AF3
	inc hl                          ; 7AF6
	ld a,(hl)                       ; 7AF7
	ld ACTOR_SCRIPT_HI(iy),a                     ; 7AF8
	ld ACTOR_TYPE(iy),#0xbf                  ; 7AFB
	pop iy                          ; 7AFF
	ret                             ; 7B01

;; ---------------------------------------------------------------- $07B02
;; classement : interpreteur de scripts d'acteurs (banque 25) et ses commandes
	.area _B01_7B02
sub_7B02:
	ld b,#0x0d                      ; 7B02
	ld hl,#scene_script_ptr         ; 7B04
	call sub_3BCD                   ; 7B07
	ret nz                          ; 7B0A
	jr loc_7B29                     ; 7B0B

;; ---------------------------------------------------------------- $07B0D
;; classement : interpreteur de scripts d'acteurs (banque 25) et ses commandes
	.area _B01_7B0D
sub_7B0D:
	ld b,#0x04                      ; 7B0D
	ld hl,#actor_CB07                 ; 7B0F
	jr loc_7B1E                     ; 7B12

;; ---------------------------------------------------------------- $07B14
;; classement : interpreteur de scripts d'acteurs (banque 25) et ses commandes
	.area _B01_7B14
sub_7B14:
	ld hl,#player_CDAF                 ; 7B14
	jr loc_7B29                     ; 7B17

;; ---------------------------------------------------------------- $07B19
;; classement : interpreteur de scripts d'acteurs (banque 25) et ses commandes
	.area _B01_7B19
sub_7B19:
	ld b,#0x07                      ; 7B19
	ld hl,#actor_CDD7                 ; 7B1B
loc_7B1E:
	ld a,ACTOR_X_HI(iy)                      ; 7B1E
	or ACTOR_Y_HI(iy)                        ; 7B21
	ret nz                          ; 7B24
	call sub_3BB5                   ; 7B25
	ret nz                          ; 7B28
loc_7B29:
	push hl                         ; 7B29
	call sub_3BD8                   ; 7B2A
	pop hl                          ; 7B2D
	ld a,1(ix)                      ; 7B2E
	ld c,ACTOR_X_FRAC(iy)                      ; 7B31
	ld b,ACTOR_X(iy)                      ; 7B34
	ld e,ACTOR_Y_FRAC(iy)                      ; 7B37
	ld d,ACTOR_Y(iy)                      ; 7B3A
	push iy                         ; 7B3D
	push hl                         ; 7B3F
	pop iy                          ; 7B40
	ld ACTOR_TYPE(iy),a                      ; 7B42
	ld l,#0x00                      ; 7B45
	ld h,2(ix)                      ; 7B47
	add hl,bc                       ; 7B4A
	ld ACTOR_X_FRAC(iy),l                      ; 7B4B
data_7B4E::
	ld ACTOR_X(iy),h                      ; 7B4E
	ld l,#0x00                      ; 7B51
	ld h,3(ix)                      ; 7B53
	add hl,de                       ; 7B56
	ld ACTOR_Y_FRAC(iy),l                      ; 7B57
	ld ACTOR_Y(iy),h                      ; 7B5A
	call sub_3B28                   ; 7B5D
	pop iy                          ; 7B60
	ret                             ; 7B62

;; ---------------------------------------------------------------- $07B63
;; classement : interpreteur de scripts d'acteurs (banque 25) et ses commandes
	.area _B01_7B63
sub_7B63:
	ld bc,#0x0000                   ; 7B63
	push hl                         ; 7B66
	ld h,#0x10                      ; 7B67
loc_7B69:
	ex (sp),hl                      ; 7B69
	rr d                            ; 7B6A
	rr e                            ; 7B6C
	jr nc,loc_7B78                  ; 7B6E
	ld a,c                          ; 7B70
	add a,(hl)                      ; 7B71
	ld c,a                          ; 7B72
	inc hl                          ; 7B73
	ld a,b                          ; 7B74
	adc a,(hl)                      ; 7B75
	ld b,a                          ; 7B76
	dec hl                          ; 7B77
loc_7B78:
	rr b                            ; 7B78
	rr c                            ; 7B7A
	ex (sp),hl                      ; 7B7C
	dec h                           ; 7B7D
	jr nz,loc_7B69                  ; 7B7E
	rr d                            ; 7B80
	rr e                            ; 7B82
	pop hl                          ; 7B84
	ret                             ; 7B85

;; ---------------------------------------------------------------- $07B86
;; classement : interpreteur de scripts d'acteurs (banque 25) et ses commandes
	.area _B01_7B86
sub_7B86:
	ld bc,#0x0004                   ; 7B86
	ld de,#0x0008                   ; 7B89
	ld hl,#sub_7BBD                 ; 7B8C
	ld a,ACTOR_X(iy)                      ; 7B8F
	sub 2(ix)                       ; 7B92
	jr z,loc_7B9E                   ; 7B95
	jr nc,loc_7B9F                  ; 7B97
	neg                             ; 7B99
	add hl,bc                       ; 7B9B
data_7B9C::
	jr loc_7B9F                     ; 7B9C
loc_7B9E:
	add hl,de                       ; 7B9E
loc_7B9F:
	ld b,a                          ; 7B9F
	ld a,ACTOR_Y(iy)                      ; 7BA0
	sub 5(ix)                       ; 7BA3
	jr nc,loc_7BAB                  ; 7BA6
	neg                             ; 7BA8
	add hl,de                       ; 7BAA
loc_7BAB:
	or a                            ; 7BAB
	jr z,loc_7BBB                   ; 7BAC
	ld c,a                          ; 7BAE
	xor a                           ; 7BAF
	or b                            ; 7BB0
	jr z,loc_7BBB                   ; 7BB1
	inc hl                          ; 7BB3
	cp c                            ; 7BB4
	jr c,loc_7BBB                   ; 7BB5
	inc hl                          ; 7BB7
	jr z,loc_7BBB                   ; 7BB8
	inc hl                          ; 7BBA
loc_7BBB:
	ld a,(hl)                       ; 7BBB
	ret                             ; 7BBC

;; ---------------------------------------------------------------- $07BBD
;; classement : interpreteur de scripts d'acteurs (banque 25) et ses commandes
	.area _B01_7BBD
sub_7BBD:
	nop                             ; 7BBD
	inc bc                          ; 7BBE
	ld (bc),a                       ; 7BBF
	ld bc,#0x0508                   ; 7BC0
	ld b,#0x07                      ; 7BC3
	inc b                           ; 7BC5
	dec c                           ; 7BC6
	ld c,#0x0f                      ; 7BC7
	nop                             ; 7BC9
	dec bc                          ; 7BCA
	ld a,(bc)                       ; 7BCB
	add hl,bc                       ; 7BCC
	inc c                           ; 7BCD

;; ---------------------------------------------------------------- $07BCE
;; classement : interpreteur de scripts d'acteurs (banque 25) et ses commandes
	.area _B01_7BCE
sub_7BCE::
	srl a                           ; 7BCE
	cp ACTOR_DIR(iy)                       ; 7BD0
	jr z,loc_7BEE                   ; 7BD3
	sub ACTOR_DIR(iy)                      ; 7BD5
	jr nc,loc_7BDC                  ; 7BD8
	add a,#0x08                     ; 7BDA
loc_7BDC:
	cp #0x05                        ; 7BDC
	ld a,ACTOR_DIR(iy)                     ; 7BDE
	jr nc,loc_7BE8                  ; 7BE1
	inc a                           ; 7BE3
	and #0x07                       ; 7BE4
	jr loc_7BEE                     ; 7BE6
loc_7BE8:
	dec a                           ; 7BE8
	jp p,loc_7BEE                   ; 7BE9
	ld a,#0x07                      ; 7BEC
loc_7BEE:
	ret                             ; 7BEE

;; ---------------------------------------------------------------- $07BEF
;; classement : interpreteur de scripts d'acteurs (banque 25) et ses commandes
	.area _B01_7BEF
sub_7BEF:
	push ix                         ; 7BEF
	ld (tmp_d3),a                   ; 7BF1
	ld ix,#actor_CDD7                 ; 7BF4
	ld b,#0x07                      ; 7BF8
loc_7BFA:
	push bc                         ; 7BFA
	ld a,(tmp_d3)                   ; 7BFB
	cp 0(ix)                        ; 7BFE
	jr nz,loc_7C47                  ; 7C01
	ld a,11(ix)                     ; 7C03
	or 12(ix)                       ; 7C06
	jp z,loc_7C47                   ; 7C09
data_7C0C::
	ld a,ACTOR_Y(iy)                      ; 7C0C
	sub 5(ix)                       ; 7C0F
	jp p,loc_7C17                   ; 7C12
	neg                             ; 7C15
loc_7C17:
	cp #0x80                        ; 7C17
	jp nc,loc_7C47                  ; 7C19
	ld c,a                          ; 7C1C
	ld a,ACTOR_X(iy)                      ; 7C1D
	sub 2(ix)                       ; 7C20
	jp p,loc_7C28                   ; 7C23
	neg                             ; 7C26
loc_7C28:
	cp #0x80                        ; 7C28
	jp nc,loc_7C47                  ; 7C2A
	ld b,a                          ; 7C2D
	ld a,d                          ; 7C2E
	add a,11(ix)                    ; 7C2F
	cp b                            ; 7C32
	jp c,loc_7C47                   ; 7C33
	inc hl                          ; 7C36
	ld a,e                          ; 7C37
	add a,12(ix)                    ; 7C38
	cp c                            ; 7C3B
	jp c,loc_7C47                   ; 7C3C
	push ix                         ; 7C3F
	pop hl                          ; 7C41
	pop bc                          ; 7C42
	or #0xff                        ; 7C43
	jr loc_7C51                     ; 7C45
loc_7C47:
	ld bc,#0x0028                   ; 7C47
	add ix,bc                       ; 7C4A
	pop bc                          ; 7C4C
	dec b                           ; 7C4D
	jp nz,loc_7BFA                  ; 7C4E
loc_7C51:
	pop ix                          ; 7C51
	ret                             ; 7C53
data_7C54:
	.db 0xd4, 0x7c, 0xde, 0x7c, 0xe8, 0x7c, 0xf2, 0x7c, 0xfc, 0x7c, 0x06, 0x7d ; 7C54
	.db 0x10, 0x7d, 0x1a, 0x7d, 0x24, 0x7d, 0x30, 0x7d, 0x3c, 0x7d, 0x48, 0x7d, 0x54, 0x7d, 0x60, 0x7d ; 7C60
	.db 0x6c, 0x7d, 0x78, 0x7d, 0x84, 0x7d, 0x8e, 0x7d, 0x98, 0x7d, 0xa2, 0x7d, 0xac, 0x7d, 0xb6, 0x7d ; 7C70
	.db 0xc0, 0x7d, 0xca, 0x7d, 0xd4, 0x7d, 0xe0, 0x7d, 0xec, 0x7d, 0xf8, 0x7d, 0x04, 0x7e, 0x10, 0x7e ; 7C80
	.db 0x1c, 0x7e, 0x28, 0x7e, 0x34, 0x7e, 0x3e, 0x7e, 0x48, 0x7e, 0x52, 0x7e, 0x5c, 0x7e, 0x66, 0x7e ; 7C90
	.db 0x70, 0x7e, 0x7a, 0x7e, 0x84, 0x7e, 0x90, 0x7e, 0x9c, 0x7e, 0xa8, 0x7e, 0xb4, 0x7e, 0xc0, 0x7e ; 7CA0
	.db 0xcc, 0x7e, 0xd8, 0x7e, 0xe4, 0x7e, 0xee, 0x7e, 0xf8, 0x7e, 0x02, 0x7f, 0x0c, 0x7f, 0x16, 0x7f ; 7CB0
	.db 0x20, 0x7f, 0x2a, 0x7f, 0x34, 0x7f, 0x40, 0x7f, 0x4c, 0x7f, 0x58, 0x7f, 0x64, 0x7f, 0x70, 0x7f ; 7CC0
	.db 0x7c, 0x7f, 0x88, 0x7f, 0xfc, 0x90, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0xee, 0xf4, 0xfc, 0x90 ; 7CD0
	.db 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0x2e, 0xf4, 0xfc, 0x90, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a ; 7CE0
	.db 0xe2, 0xf4, 0xfc, 0x90, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0x22, 0xf4, 0xfc, 0x90, 0xdb, 0x06 ; 7CF0
	.db 0xde, 0xb5, 0xfd, 0x0a, 0xe0, 0xf4, 0xfc, 0x90, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0x20, 0xf4 ; 7D00
	.db 0xfc, 0x90, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0x0e, 0xf4, 0xfc, 0x90, 0xdb, 0x06, 0xde, 0xb5 ; 7D10
	.db 0xfd, 0x0a, 0x02, 0xf4, 0xf3, 0x80, 0xfc, 0x25, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0xee, 0xf4 ; 7D20
	.db 0xf3, 0x80, 0xfc, 0x25, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0x2e, 0xf4, 0xf3, 0x80, 0xfc, 0x25 ; 7D30
	.db 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0xe2, 0xf4, 0xf3, 0x80, 0xfc, 0x25, 0xdb, 0x06, 0xde, 0xb5 ; 7D40
	.db 0xfd, 0x0a, 0x22, 0xf4, 0xf3, 0x80, 0xfc, 0x25, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0xe0, 0xf4 ; 7D50
	.db 0xf3, 0x80, 0xfc, 0x25, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0x20, 0xf4, 0xf3, 0x80, 0xfc, 0x25 ; 7D60
	.db 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0x0e, 0xf4, 0xf3, 0x80, 0xfc, 0x25, 0xdb, 0x06, 0xde, 0xb5 ; 7D70
	.db 0xfd, 0x0a, 0x02, 0xf4, 0xfc, 0x91, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0xee, 0xf4, 0xfc, 0x91 ; 7D80
	.db 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0x2e, 0xf4, 0xfc, 0x91, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a ; 7D90
	.db 0xe2, 0xf4, 0xfc, 0x91, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0x22, 0xf4, 0xfc, 0x91, 0xdb, 0x06 ; 7DA0
	.db 0xde, 0xa6, 0xfd, 0x0a, 0xe0, 0xf4, 0xfc, 0x91, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0x20, 0xf4 ; 7DB0
	.db 0xfc, 0x91, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0x0e, 0xf4, 0xfc, 0x91, 0xdb, 0x06, 0xde, 0xa6 ; 7DC0
	.db 0xfd, 0x0a, 0x02, 0xf4, 0xf3, 0x80, 0xfc, 0x26, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0xee, 0xf4 ; 7DD0
	.db 0xf3, 0x80, 0xfc, 0x26, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0x2e, 0xf4, 0xf3, 0x80, 0xfc, 0x26 ; 7DE0
	.db 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0xe2, 0xf4, 0xf3, 0x80, 0xfc, 0x26, 0xdb, 0x06, 0xde, 0xa6 ; 7DF0
	.db 0xfd, 0x0a, 0x22, 0xf4, 0xf3, 0x80, 0xfc, 0x26, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0xe0, 0xf4 ; 7E00
	.db 0xf3, 0x80, 0xfc, 0x26, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0x20, 0xf4, 0xf3, 0x80, 0xfc, 0x26 ; 7E10
	.db 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0x0e, 0xf4, 0xf3, 0x80, 0xfc, 0x26, 0xdb, 0x06, 0xde, 0xa6 ; 7E20
	.db 0xfd, 0x0a, 0x02, 0xf4, 0xfc, 0x90, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0xff, 0xf4, 0xfc, 0x90 ; 7E30
	.db 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0x1f, 0xf4, 0xfc, 0x90, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a ; 7E40
	.db 0xf1, 0xf4, 0xfc, 0x90, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0x11, 0xf4, 0xfc, 0x90, 0xdb, 0x06 ; 7E50
	.db 0xde, 0xb5, 0xfd, 0x0a, 0xf0, 0xf4, 0xfc, 0x90, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0x10, 0xf4 ; 7E60
	.db 0xfc, 0x90, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0x0f, 0xf4, 0xfc, 0x90, 0xdb, 0x06, 0xde, 0xb5 ; 7E70
	.db 0xfd, 0x0a, 0x01, 0xf4, 0xf3, 0x80, 0xfc, 0x25, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0xff, 0xf4 ; 7E80
	.db 0xf3, 0x80, 0xfc, 0x25, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0x1f, 0xf4, 0xf3, 0x80, 0xfc, 0x25 ; 7E90
	.db 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0xf1, 0xf4, 0xf3, 0x80, 0xfc, 0x25, 0xdb, 0x06, 0xde, 0xb5 ; 7EA0
	.db 0xfd, 0x0a, 0x11, 0xf4, 0xf3, 0x80, 0xfc, 0x25, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0xf0, 0xf4 ; 7EB0
	.db 0xf3, 0x80, 0xfc, 0x25, 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0x10, 0xf4, 0xf3, 0x80, 0xfc, 0x25 ; 7EC0
	.db 0xdb, 0x06, 0xde, 0xb5, 0xfd, 0x0a, 0x0f, 0xf4, 0xf3, 0x80, 0xfc, 0x25, 0xdb, 0x06, 0xde, 0xb5 ; 7ED0
	.db 0xfd, 0x0a, 0x01, 0xf4, 0xfc, 0x91, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0xff, 0xf4, 0xfc, 0x91 ; 7EE0
	.db 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0x1f, 0xf4, 0xfc, 0x91, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a ; 7EF0
	.db 0xf1, 0xf4, 0xfc, 0x91, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0x11, 0xf4, 0xfc, 0x91, 0xdb, 0x06 ; 7F00
	.db 0xde, 0xa6, 0xfd, 0x0a, 0x0f, 0xf4, 0xfc, 0x91, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0x10, 0xf4 ; 7F10
	.db 0xfc, 0x91, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0x0f, 0xf4, 0xfc, 0x91, 0xdb, 0x06, 0xde, 0xa6 ; 7F20
	.db 0xfd, 0x0a, 0x01, 0xf4, 0xf3, 0x80, 0xfc, 0x26, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0xff, 0xf4 ; 7F30
	.db 0xf3, 0x80, 0xfc, 0x26, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0x1f, 0xf4, 0xf3, 0x80, 0xfc, 0x26 ; 7F40
	.db 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0xf1, 0xf4, 0xf3, 0x80, 0xfc, 0x26, 0xdb, 0x06, 0xde, 0xa6 ; 7F50
	.db 0xfd, 0x0a, 0x11, 0xf4, 0xf3, 0x80, 0xfc, 0x26, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0xf0, 0xf4 ; 7F60
	.db 0xf3, 0x80, 0xfc, 0x26, 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0x10, 0xf4, 0xf3, 0x80, 0xfc, 0x26 ; 7F70
	.db 0xdb, 0x06, 0xde, 0xa6, 0xfd, 0x0a, 0x0f, 0xf4, 0xf3, 0x80, 0xfc, 0x26, 0xdb, 0x06, 0xde, 0xa6 ; 7F80
	.db 0xfd, 0x0a, 0x01, 0xf4      ; 7F90
