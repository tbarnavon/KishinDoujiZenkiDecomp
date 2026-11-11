;; game/script.s
;; Moteur de scenes (tache 5) : interpreteur de bytecode (banque 5), 45 opcodes ($6595).
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $06337
;; classement : atteinte uniquement par task5_scene
	.area _B01_6337
sub_6337::
	call sub_6396                   ; 6337
loc_633A:
	call task_yield                 ; 633A
	call sub_653B                   ; 633D
	jr c,loc_6368                   ; 6340
	ld a,(scene_C90C)                 ; 6342
	or a                            ; 6345
	jr nz,loc_633A                  ; 6346
	ld a,(joypad_pressed)           ; 6348
	bit 7,a                         ; 634B
	jr z,loc_633A                   ; 634D
	ld a,(scene_C90E)                 ; 634F
	or a                            ; 6352
	jr z,loc_6368                   ; 6353
	push af                         ; 6355
	call sound_init                 ; 6356
	pop af                          ; 6359
	ld hl,(scene_C90F)                ; 635A
	ld (scene_script_ptr),hl        ; 635D
	dec a                           ; 6360
	jr z,loc_633A                   ; 6361
data_6363::
	ld a,#0xad                      ; 6363
	ld (snd_queue_music),a          ; 6365
loc_6368:
	xor a                           ; 6368
	ld (scene_C1BF),a                 ; 6369
	ld a,#0x01                      ; 636C
	ld (game_mode),a                ; 636E
	ld a,(scene_id)                 ; 6371
	bit 7,a                         ; 6374
	jr z,loc_638F                   ; 6376
	ld a,(scene_C90D)                 ; 6378
	or a                            ; 637B
	jr nz,loc_638B                  ; 637C
	ld a,(joypad_state)             ; 637E
	push af                         ; 6381
	ld a,#0x01                      ; 6382
	call sub_67BB                   ; 6384
	pop af                          ; 6387
	ld (joypad_state),a             ; 6388
loc_638B:
	ld a,(scene_C90B)                 ; 638B
	ret                             ; 638E
loc_638F:
	ld hl,#game_flags               ; 638F
	set 4,(hl)                      ; 6392
	jr loc_633A                     ; 6394

;; ---------------------------------------------------------------- $06396
;; classement : atteinte uniquement par task5_scene
	.area _B01_6396
sub_6396:
	ld a,(scene_id)                 ; 6396
	cp #0x85                        ; 6399
	jr z,loc_63A0                   ; 639B
	dec a                           ; 639D
	jr nz,loc_63A5                  ; 639E
loc_63A0:
	call sub_1725                   ; 63A0
	jr loc_63A8                     ; 63A3
loc_63A5:
	call sub_170C                   ; 63A5
loc_63A8:
	call sub_0A6B                   ; 63A8
	call sub_0A33                   ; 63AB
	call sub_6BA5                   ; 63AE
	call sub_2118                   ; 63B1
	call sub_6415                   ; 63B4
.if VERSION_SMS_EN
	ld hl,#0x01bf                   ; 63B7
.else ; VERSION_GG_JP
	ld hl,#0x111f                   ; 63B7
.endif
	ld de,#VDP_VRAM_WRITE|0x3800    ; 63BA
	ld bc,#0x0380                   ; 63BD
	call sub_44D0                   ; 63C0
	ld a,(player_CEFE)                 ; 63C3
	push af                         ; 63C6
	call sub_221E                   ; 63C7
	pop af                          ; 63CA
	ld (player_CEFE),a                 ; 63CB
	ld hl,#scene_CBB7                 ; 63CE
	ld (scene_CBB5),hl                ; 63D1
	xor a                           ; 63D4
	ld (scroll_x),a                 ; 63D5
	ld (scene_C908),a                 ; 63D8
	ld (pause_C8D7),a                 ; 63DB
	ld (actor_CBA7),a                 ; 63DE
	ld (text_CBB3),a                 ; 63E1
	ld (scene_C90C),a                 ; 63E4
	ld (scene_C90D),a                 ; 63E7
	ld (scene_CBA4),a                 ; 63EA
	ld (scene_C90E),a                 ; 63ED
	ld (level_C1F3),a                 ; 63F0
	inc a                           ; 63F3
	ld (scene_C90B),a                 ; 63F4
	ld a,#0xc8                      ; 63F7
	ld (scroll_y),a                 ; 63F9
	ld hl,#vdp_requests2            ; 63FC
	set 5,(hl)                      ; 63FF
	ld a,(scene_id)                 ; 6401
	bit 7,a                         ; 6404
	jr z,loc_640C                   ; 6406
	res 7,a                         ; 6408
	jr loc_640E                     ; 640A
loc_640C:
	add a,#0x08                     ; 640C
loc_640E:
	call sub_6427                   ; 640E
	call sub_0050                   ; 6411
	ret                             ; 6414

;; ---------------------------------------------------------------- $06427
;; classement : atteinte uniquement par task5_scene
	.area _B01_6427
sub_6427:
	ld l,a                          ; 6427
	ld h,#0x00                      ; 6428
	add hl,hl                       ; 642A
	ld de,#data_b23_8000            ; 642B
	add hl,de                       ; 642E
	ld a,#0x05                      ; 642F
	ld (bank_slot2_shadow),a        ; 6431
	ld (MAPPER_SLOT2),a             ; 6434  mapper : banque du slot 2 ($8000-$BFFF)
	ld e,(hl)                       ; 6437
	inc hl                          ; 6438
	ld d,(hl)                       ; 6439
	ld (scene_script_ptr),de        ; 643A
	ret                             ; 643E

;; ---------------------------------------------------------------- $0643F
;; classement : atteinte uniquement par task5_scene
	.area _B01_643F
sub_643F:
	ld a,(scene_C908)                 ; 643F
	or a                            ; 6442
	ret z                           ; 6443
	dec a                           ; 6444
	ld (scene_C908),a                 ; 6445
	ret nz                          ; 6448
	ld a,(scene_C907)                 ; 6449
	ld l,a                          ; 644C
	add a,a                         ; 644D
	add a,l                         ; 644E
	ld l,a                          ; 644F
	ld h,#0x80                      ; 6450
	ld a,#0x17                      ; 6452
	ld (bank_slot2_shadow),a        ; 6454
	ld (MAPPER_SLOT2),a             ; 6457  mapper : banque du slot 2 ($8000-$BFFF)
	ld a,(hl)                       ; 645A
	inc hl                          ; 645B
	ld (scene_C908),a                 ; 645C
	ld a,(hl)                       ; 645F
	inc hl                          ; 6460
	ld (scene_C907),a                 ; 6461
	ld a,(hl)                       ; 6464
	ld (snd_queue_music),a          ; 6465
	ret                             ; 6468

;; ---------------------------------------------------------------- $06469
;; classement : atteinte uniquement par task5_scene
	.area _B01_6469
sub_6469:
	ld a,(scene_CBA4)                 ; 6469
	or a                            ; 646C
	ret z                           ; 646D
	dec a                           ; 646E
	ld (scene_CBA4),a                 ; 646F
	ret nz                          ; 6472
	ld hl,#vdp_requests2            ; 6473
	set 6,(hl)                      ; 6476
	ld a,(scene_CBA3)                 ; 6478
	ld (bank_slot2_shadow),a        ; 647B
	ld (MAPPER_SLOT2),a             ; 647E  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(scene_CBA5)                ; 6481
	ld h,#0x00                      ; 6484
	add hl,hl                       ; 6486
	add hl,hl                       ; 6487
	ld de,(scene_CB9F)                ; 6488
	add hl,de                       ; 648C
	ld a,(hl)                       ; 648D
	inc hl                          ; 648E
	ld (scene_CBA4),a                 ; 648F
	ld a,(hl)                       ; 6492
	inc hl                          ; 6493
	ld (scene_CBA5),a                 ; 6494
	ld e,(hl)                       ; 6497
	inc hl                          ; 6498
	ld d,(hl)                       ; 6499
	ex de,hl                        ; 649A
loc_649B:
	ld a,(scene_CBA3)                 ; 649B
	ld (bank_slot2_shadow),a        ; 649E
	ld (MAPPER_SLOT2),a             ; 64A1  mapper : banque du slot 2 ($8000-$BFFF)
	ld a,(hl)                       ; 64A4
	cp #0xff                        ; 64A5
	ret z                           ; 64A7
	ld de,#0xc01a                   ; 64A8
	or a                            ; 64AB
	jr z,loc_64B1                   ; 64AC
	ld de,#0xc03a                   ; 64AE
loc_64B1:
	inc hl                          ; 64B1
	ld a,(hl)                       ; 64B2
	inc hl                          ; 64B3
	ld c,(hl)                       ; 64B4
	inc hl                          ; 64B5
	ld b,(hl)                       ; 64B6
	inc hl                          ; 64B7
	cp #0x80                        ; 64B8
	jr nz,loc_64D0                  ; 64BA
	push af                         ; 64BC
	ld a,(hl)                       ; 64BD
	ld (bank_slot2_shadow),a        ; 64BE
	ld (MAPPER_SLOT2),a             ; 64C1  mapper : banque du slot 2 ($8000-$BFFF)
	inc hl                          ; 64C4
	pop af                          ; 64C5
	push hl                         ; 64C6
	push bc                         ; 64C7
	pop hl                          ; 64C8
	ld bc,#0x0020                   ; 64C9
	ldir                            ; 64CC
	jr loc_64D9                     ; 64CE
loc_64D0:
	push hl                         ; 64D0
	add a,a                         ; 64D1
	ld l,a                          ; 64D2
	ld h,#0x00                      ; 64D3
	add hl,de                       ; 64D5
	ld (hl),c                       ; 64D6
	inc hl                          ; 64D7
	ld (hl),b                       ; 64D8
loc_64D9:
	pop hl                          ; 64D9
	jr loc_649B                     ; 64DA

;; ---------------------------------------------------------------- $064DC
;; classement : atteinte uniquement par task5_scene
	.area _B01_64DC
sub_64DC:
	ld a,(actor_CBA7)                 ; 64DC
	or a                            ; 64DF
	ret z                           ; 64E0
	dec a                           ; 64E1
	ld (actor_CBA7),a                 ; 64E2
	ret nz                          ; 64E5
	ld a,(scene_CBA6)                 ; 64E6
	ld (bank_slot2_shadow),a        ; 64E9
	ld (MAPPER_SLOT2),a             ; 64EC  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(scene_CBA8)                ; 64EF
	ld h,#0x00                      ; 64F2
	add hl,hl                       ; 64F4
	add hl,hl                       ; 64F5
	ld de,(scene_CBA9)                ; 64F6
	add hl,de                       ; 64FA
	ld a,(hl)                       ; 64FB
	inc hl                          ; 64FC
	ld (actor_CBA7),a                 ; 64FD
	ld a,(hl)                       ; 6500
	inc hl                          ; 6501
	ld (scene_CBA8),a                 ; 6502
	ld e,(hl)                       ; 6505
	inc hl                          ; 6506
	ld d,(hl)                       ; 6507
	ex de,hl                        ; 6508
loc_6509:
	ld a,(scene_CBA6)                 ; 6509
	ld (bank_slot2_shadow),a        ; 650C
	ld (MAPPER_SLOT2),a             ; 650F  mapper : banque du slot 2 ($8000-$BFFF)
	ld a,(hl)                       ; 6512
	cp #0xff                        ; 6513
	ret z                           ; 6515
	ld (player_C0B1),a                 ; 6516
	inc hl                          ; 6519
	ld e,(hl)                       ; 651A
	inc hl                          ; 651B
	ld d,(hl)                       ; 651C
	inc hl                          ; 651D
	push de                         ; 651E
	ld e,(hl)                       ; 651F
	inc hl                          ; 6520
	ld d,(hl)                       ; 6521
	inc hl                          ; 6522
	ld c,(hl)                       ; 6523
	inc hl                          ; 6524
	ld b,(hl)                       ; 6525
	inc hl                          ; 6526
	ld a,(hl)                       ; 6527
	ld (bank_slot2_shadow),a        ; 6528
	ld (MAPPER_SLOT2),a             ; 652B  mapper : banque du slot 2 ($8000-$BFFF)
	inc hl                          ; 652E
	ld (scene_CBAB),hl                ; 652F
	pop hl                          ; 6532
	call sub_6A30                   ; 6533
	ld hl,(scene_CBAB)                ; 6536
	jr loc_6509                     ; 6539

;; ---------------------------------------------------------------- $0653B
;; classement : atteinte uniquement par task5_scene
	.area _B01_653B
sub_653B:
	call sub_6469                   ; 653B
	call sub_64DC                   ; 653E
	call sub_0A6B                   ; 6541
	call sub_6ACF                   ; 6544
	call sub_643F                   ; 6547
	call sub_68B7                   ; 654A
	ld hl,#scroll_x                 ; 654D
	ld a,(scene_scroll_dx)          ; 6550
	ld b,a                          ; 6553
	add a,(hl)                      ; 6554
	ld (hl),a                       ; 6555
	ld hl,#scroll_y                 ; 6556
	ld a,(scene_scroll_dy)          ; 6559
	ld c,a                          ; 655C
	add a,(hl)                      ; 655D
	ld (hl),a                       ; 655E
	ld b,a                          ; 655F
	or c                            ; 6560
	jr z,loc_6568                   ; 6561
	ld hl,#vdp_requests2            ; 6563
	set 5,(hl)                      ; 6566
loc_6568:
	ld a,(scene_wait)               ; 6568
	or a                            ; 656B
	jr z,loc_6574                   ; 656C
	dec a                           ; 656E
	ld (scene_wait),a               ; 656F
	or a                            ; 6572
	ret                             ; 6573
loc_6574:
	ld a,#0x05                      ; 6574
	ld (bank_slot2_shadow),a        ; 6576
	ld (MAPPER_SLOT2),a             ; 6579  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(scene_script_ptr)        ; 657C
	ld a,(hl)                       ; 657F
	inc hl                          ; 6580
	ld b,h                          ; 6581
	ld c,l                          ; 6582
	add a,a                         ; 6583
	ld e,a                          ; 6584
	ld d,#0x00                      ; 6585
	ld hl,#jt_6595                  ; 6587
	add hl,de                       ; 658A
	ld e,(hl)                       ; 658B
	inc hl                          ; 658C
	ld d,(hl)                       ; 658D
	ex de,hl                        ; 658E
	ld de,#loc_6574                 ; 658F
	push de                         ; 6592
	push bc                         ; 6593
	jp (hl)                         ; 6594
jt_6595:
	.dw loc_65EF                    ; 6595
	.dw loc_6A11                    ; 6597
	.dw loc_6955                    ; 6599
	.dw loc_69A3                    ; 659B
	.dw loc_69CD                    ; 659D
	.dw loc_66C4                    ; 659F
	.dw loc_665A                    ; 65A1
	.dw loc_69D9                    ; 65A3
	.dw loc_69E3                    ; 65A5
	.dw loc_6665                    ; 65A7
	.dw loc_687F                    ; 65A9
	.dw loc_6741                    ; 65AB
	.dw loc_678C                    ; 65AD
	.dw loc_6799                    ; 65AF
	.dw loc_6857                    ; 65B1
	.dw loc_686B                    ; 65B3
	.dw loc_67AA                    ; 65B5
	.dw loc_67B5                    ; 65B7
	.dw loc_683D                    ; 65B9
	.dw loc_6702                    ; 65BB
	.dw loc_67FA                    ; 65BD
	.dw loc_67C0                    ; 65BF
	.dw loc_67E0                    ; 65C1
	.dw loc_674A                    ; 65C3
	.dw loc_675F                    ; 65C5
	.dw loc_676F                    ; 65C7
	.dw loc_6779                    ; 65C9
	.dw loc_69F0                    ; 65CB
	.dw loc_681D                    ; 65CD
	.dw loc_66A7                    ; 65CF
	.dw loc_6A40                    ; 65D1
	.dw loc_6A60                    ; 65D3
	.dw loc_6924                    ; 65D5
	.dw loc_65F3                    ; 65D7
	.dw loc_6619                    ; 65D9
	.dw loc_65FD                    ; 65DB
	.dw loc_660B                    ; 65DD
	.dw loc_666C                    ; 65DF
	.dw loc_67CB                    ; 65E1
	.dw loc_6A80                    ; 65E3
	.dw loc_6A94                    ; 65E5
	.dw loc_66DC                    ; 65E7
	.dw loc_6631                    ; 65E9
	.dw loc_69FF                    ; 65EB
	.dw loc_6A07                    ; 65ED
loc_65EF:
	pop hl                          ; 65EF
	pop hl                          ; 65F0
	scf                             ; 65F1
	ret                             ; 65F2
loc_65F3:
	pop hl                          ; 65F3
	ld (scene_script_ptr),hl        ; 65F4
	ld hl,#game_flags               ; 65F7
	set 2,(hl)                      ; 65FA
	ret                             ; 65FC
loc_65FD:
	pop hl                          ; 65FD
	ld e,(hl)                       ; 65FE
	inc hl                          ; 65FF
data_6600::
	ld d,(hl)                       ; 6600
	inc hl                          ; 6601
	ld a,(hl)                       ; 6602
	inc hl                          ; 6603
	ld (scene_script_ptr),hl        ; 6604
	ex de,hl                        ; 6607
	and (hl)                        ; 6608
	ld (hl),a                       ; 6609
	ret                             ; 660A
loc_660B:
	pop hl                          ; 660B
	ld e,(hl)                       ; 660C
	inc hl                          ; 660D
	ld d,(hl)                       ; 660E
	inc hl                          ; 660F
	ld a,(hl)                       ; 6610
	inc hl                          ; 6611
	ld (scene_script_ptr),hl        ; 6612
	ex de,hl                        ; 6615
	or (hl)                         ; 6616
	ld (hl),a                       ; 6617
	ret                             ; 6618
loc_6619:
	pop hl                          ; 6619
	ld e,(hl)                       ; 661A
	inc hl                          ; 661B
	ld d,(hl)                       ; 661C
	inc hl                          ; 661D
	ld a,(hl)                       ; 661E
	inc hl                          ; 661F
	ld c,(hl)                       ; 6620
	inc hl                          ; 6621
	ld b,(hl)                       ; 6622
	inc hl                          ; 6623
	ld (scene_script_ptr),hl        ; 6624
	ex de,hl                        ; 6627
	ld e,a                          ; 6628
	and (hl)                        ; 6629
	cp e                            ; 662A
	ret nz                          ; 662B
	ld (scene_script_ptr),bc        ; 662C
	ret                             ; 6630
loc_6631:
	pop hl                          ; 6631
	ld bc,#0x1000                   ; 6632
	ld iy,#scene_C91F                 ; 6635
	ld de,#0x0028                   ; 6639
loc_663C:
	ld a,0(iy)                      ; 663C
	or a                            ; 663F
	jr z,loc_6650                   ; 6640
	ld a,5(iy)                      ; 6642
	cp #0x30                        ; 6645
	jr c,loc_664C                   ; 6647
	inc c                           ; 6649
	jr loc_6650                     ; 664A
loc_664C:
	ld 0(iy),#0x00                  ; 664C
loc_6650:
	add iy,de                       ; 6650
	djnz loc_663C                   ; 6652
	ld a,c                          ; 6654
	or a                            ; 6655
	jr z,loc_6666                   ; 6656
	jr loc_6669                     ; 6658
loc_665A:
	pop hl                          ; 665A
	ld a,(hl)                       ; 665B
	inc hl                          ; 665C
	ld (scene_script_ptr),hl        ; 665D
	ld (scene_wait),a               ; 6660
	jr loc_6669                     ; 6663
loc_6665:
	pop hl                          ; 6665
loc_6666:
	ld (scene_script_ptr),hl        ; 6666
loc_6669:
	pop hl                          ; 6669
	or a                            ; 666A
	ret                             ; 666B
loc_666C:
	pop hl                          ; 666C
	ld a,(joypad_pressed)           ; 666D
	and #0xb0                       ; 6670
	jr nz,loc_6666                  ; 6672
	ld a,(scene_C90B)                 ; 6674
	ld bc,(joypad_state)            ; 6677
	bit 2,b                         ; 667B
	jr z,loc_6683                   ; 667D
	or a                            ; 667F
	jr nz,loc_6683                  ; 6680
	inc a                           ; 6682
loc_6683:
	bit 3,b                         ; 6683
	jr z,loc_668B                   ; 6685
	or a                            ; 6687
	jr z,loc_668B                   ; 6688
	dec a                           ; 668A
loc_668B:
	ld (scene_C90B),a                 ; 668B
.if VERSION_SMS_EN
	ld hl,#data_1FB4                ; 668E
.else ; VERSION_GG_JP
	ld hl,#loc_1F81                 ; 668E
.endif
	or a                            ; 6691
	jr z,loc_6697                   ; 6692
.if VERSION_SMS_EN
	ld hl,#data_b05_B41F            ; 6694
.else ; VERSION_GG_JP
	ld hl,#data_b05_811F            ; 6694
.endif
loc_6697:
	ld de,#0x7bd6                   ; 6697
	ld a,h                          ; 669A
	call sub_6910                   ; 669B
	ld de,#0x7be0                   ; 669E
	ld a,l                          ; 66A1
	call sub_6910                   ; 66A2
	jr loc_6669                     ; 66A5
loc_66A7:
	pop hl                          ; 66A7
loc_66A8:
	ld a,(joypad_state)             ; 66A8
	and #0xb0                       ; 66AB
	jr nz,loc_66B4                  ; 66AD
	call task_yield                 ; 66AF
	jr loc_66A8                     ; 66B2
loc_66B4:
	ld a,(joypad_state)             ; 66B4
	and #0xb0                       ; 66B7
	jr z,loc_66C0                   ; 66B9
	call task_yield                 ; 66BB
	jr loc_66B4                     ; 66BE
loc_66C0:
	ld (scene_script_ptr),hl        ; 66C0
	ret                             ; 66C3
loc_66C4:
	pop hl                          ; 66C4
	ld e,(hl)                       ; 66C5
	inc hl                          ; 66C6
	ld d,(hl)                       ; 66C7
	inc hl                          ; 66C8
	push de                         ; 66C9
	ld e,(hl)                       ; 66CA
	inc hl                          ; 66CB
	ld d,(hl)                       ; 66CC
	inc hl                          ; 66CD
	ld c,(hl)                       ; 66CE
	inc hl                          ; 66CF
	ld b,(hl)                       ; 66D0
	inc hl                          ; 66D1
	ld (scene_script_ptr),hl        ; 66D2
	pop hl                          ; 66D5
	di                              ; 66D6
	call sub_44D0                   ; 66D7
	ei                              ; 66DA
	ret                             ; 66DB
loc_66DC:
	pop hl                          ; 66DC
	ld e,(hl)                       ; 66DD
	inc hl                          ; 66DE
	ld d,(hl)                       ; 66DF
	inc hl                          ; 66E0
	push de                         ; 66E1
	ld e,(hl)                       ; 66E2
	inc hl                          ; 66E3
	ld d,(hl)                       ; 66E4
	inc hl                          ; 66E5
	ld b,(hl)                       ; 66E6
	inc hl                          ; 66E7
	inc hl                          ; 66E8
	ld (scene_script_ptr),hl        ; 66E9
	pop hl                          ; 66EC
	di                              ; 66ED
loc_66EE:
	rst 0x08                        ; 66EE  VDP : adresse/commande = de (sous di)
	ld a,l                          ; 66EF
	out (VDP_DATA),a                ; 66F0  VDP : donnee VRAM/CRAM
	push af                         ; 66F2
	pop af                          ; 66F3
	ld a,h                          ; 66F4
	out (VDP_DATA),a                ; 66F5  VDP : donnee VRAM/CRAM
	push hl                         ; 66F7
	ld hl,#0x0040                   ; 66F8
	add hl,de                       ; 66FB
	ex de,hl                        ; 66FC
	pop hl                          ; 66FD
	djnz loc_66EE                   ; 66FE
	ei                              ; 6700
	ret                             ; 6701
loc_6702:
	pop hl                          ; 6702
	ld c,(hl)                       ; 6703
	inc hl                          ; 6704
	ld b,(hl)                       ; 6705
	inc hl                          ; 6706
	ld e,(hl)                       ; 6707
	inc hl                          ; 6708
	ld d,(hl)                       ; 6709
	inc hl                          ; 670A
	ld (scene_script_ptr),hl        ; 670B
	ld a,c                          ; 670E
	ld (bank_slot2_shadow),a        ; 670F
	ld (MAPPER_SLOT2),a             ; 6712  mapper : banque du slot 2 ($8000-$BFFF)
	ex de,hl                        ; 6715
	ld a,b                          ; 6716
	or a                            ; 6717
	jr nz,loc_6729                  ; 6718
	ld de,#0xc01a                   ; 671A
	ld bc,#0x0020                   ; 671D
	push hl                         ; 6720
	ldir                            ; 6721
	pop hl                          ; 6723
	ld de,#pal_C05A                 ; 6724
	jr loc_6736                     ; 6727
loc_6729:
	ld de,#0xc03a                   ; 6729
	ld bc,#0x0020                   ; 672C
	push hl                         ; 672F
	ldir                            ; 6730
	pop hl                          ; 6732
	ld de,#event_C07A                 ; 6733
loc_6736:
	ld bc,#0x0020                   ; 6736
	ldir                            ; 6739
	ld hl,#vdp_requests2            ; 673B
	set 6,(hl)                      ; 673E
	ret                             ; 6740
loc_6741:
	pop hl                          ; 6741
	ld e,(hl)                       ; 6742
	inc hl                          ; 6743
	ld d,(hl)                       ; 6744
	ex de,hl                        ; 6745
	ld (scene_script_ptr),hl        ; 6746
	ret                             ; 6749
loc_674A:
	pop hl                          ; 674A
	ld e,(hl)                       ; 674B
	inc hl                          ; 674C
	ld d,(hl)                       ; 674D
	inc hl                          ; 674E
	ld (scene_script_ptr),de        ; 674F
	ex de,hl                        ; 6753
	ld hl,(scene_CBB5)                ; 6754
	ld (hl),e                       ; 6757
	inc hl                          ; 6758
	ld (hl),d                       ; 6759
	inc hl                          ; 675A
	ld (scene_CBB5),hl                ; 675B
	ret                             ; 675E
loc_675F:
	pop hl                          ; 675F
	ld hl,(scene_CBB5)                ; 6760
	dec hl                          ; 6763
	ld d,(hl)                       ; 6764
	dec hl                          ; 6765
	ld e,(hl)                       ; 6766
	ld (scene_CBB5),hl                ; 6767
	ld (scene_script_ptr),de        ; 676A
	ret                             ; 676E
loc_676F:
	pop hl                          ; 676F
	ld a,(hl)                       ; 6770
	inc hl                          ; 6771
	ld (scene_script_ptr),hl        ; 6772
	ld (scene_C906),a                 ; 6775
	ret                             ; 6778
loc_6779:
	pop hl                          ; 6779
	ld e,(hl)                       ; 677A
	inc hl                          ; 677B
	ld d,(hl)                       ; 677C
	inc hl                          ; 677D
	ld a,(scene_C906)                 ; 677E
	dec a                           ; 6781
	ld (scene_C906),a                 ; 6782
	jr z,loc_6788                   ; 6785
	ex de,hl                        ; 6787
loc_6788:
	ld (scene_script_ptr),hl        ; 6788
	ret                             ; 678B
loc_678C:
	pop hl                          ; 678C
	ld e,(hl)                       ; 678D
	inc hl                          ; 678E
	ld d,(hl)                       ; 678F
	inc hl                          ; 6790
	ld a,(hl)                       ; 6791
	inc hl                          ; 6792
	ld (scene_script_ptr),hl        ; 6793
	ex de,hl                        ; 6796
	ld (hl),a                       ; 6797
	ret                             ; 6798
loc_6799:
	pop hl                          ; 6799
	ld e,(hl)                       ; 679A
	inc hl                          ; 679B
	ld d,(hl)                       ; 679C
	inc hl                          ; 679D
	ld a,(hl)                       ; 679E
	inc hl                          ; 679F
	ld b,(hl)                       ; 67A0
	inc hl                          ; 67A1
	ld (scene_script_ptr),hl        ; 67A2
	ex de,hl                        ; 67A5
	ld (hl),a                       ; 67A6
	inc hl                          ; 67A7
	ld (hl),b                       ; 67A8
	ret                             ; 67A9
loc_67AA:
	pop hl                          ; 67AA
	ld a,(hl)                       ; 67AB
	inc hl                          ; 67AC
	ld (scene_script_ptr),hl        ; 67AD
	call sub_58A5                   ; 67B0
	jr loc_67E9                     ; 67B3
loc_67B5:
	pop hl                          ; 67B5
	ld a,(hl)                       ; 67B6
	inc hl                          ; 67B7
	ld (scene_script_ptr),hl        ; 67B8

;; ---------------------------------------------------------------- $067BB
;; classement : racines du meme module : script_op_6595+task5_scene
	.area _B01_67BB
sub_67BB:
	call sub_58AE                   ; 67BB
	jr loc_67E9                     ; 67BE
loc_67C0:
	pop hl                          ; 67C0
	ld a,(hl)                       ; 67C1
	inc hl                          ; 67C2
	ld (scene_script_ptr),hl        ; 67C3
	call sub_58C0                   ; 67C6
	jr loc_67E9                     ; 67C9
loc_67CB:
	pop hl                          ; 67CB
	ld a,(hl)                       ; 67CC
	inc hl                          ; 67CD
	ld (scene_script_ptr),hl        ; 67CE
	call sub_58C0                   ; 67D1
	xor a                           ; 67D4
	ld (scene_C0E6),a                 ; 67D5
	ld hl,#0x0000                   ; 67D8
	ld (scene_C01E),hl                ; 67DB
	jr loc_67E9                     ; 67DE
loc_67E0:
	pop hl                          ; 67E0
	ld a,(hl)                       ; 67E1
	inc hl                          ; 67E2
	ld (scene_script_ptr),hl        ; 67E3
	call sub_58C9                   ; 67E6
loc_67E9:
	call sub_574C                   ; 67E9
	ld a,(player_state)             ; 67EC
	or a                            ; 67EF
	jr z,loc_67F6                   ; 67F0
	call sub_176E                   ; 67F2
	ret                             ; 67F5
loc_67F6:
	call sub_174B                   ; 67F6
	ret                             ; 67F9
loc_67FA:
	pop hl                          ; 67FA
	ld a,(hl)                       ; 67FB
	inc hl                          ; 67FC
	ld e,(hl)                       ; 67FD
	inc hl                          ; 67FE
	ld c,(hl)                       ; 67FF
data_6800::
	inc hl                          ; 6800
	ld b,(hl)                       ; 6801
	inc hl                          ; 6802
	ld (scene_script_ptr),hl        ; 6803
	ld l,e                          ; 6806
	ld h,#0x00                      ; 6807
	add hl,hl                       ; 6809
	ld de,#0xc03a                   ; 680A
	or a                            ; 680D
	jr nz,loc_6813                  ; 680E
	ld de,#0xc01a                   ; 6810
loc_6813:
	add hl,de                       ; 6813
	ld (hl),c                       ; 6814
	inc hl                          ; 6815
	ld (hl),b                       ; 6816
	ld hl,#vdp_requests2            ; 6817
	set 6,(hl)                      ; 681A
	ret                             ; 681C
loc_681D:
	pop hl                          ; 681D
	ld e,(hl)                       ; 681E
	inc hl                          ; 681F
	ld d,(hl)                       ; 6820
	inc hl                          ; 6821
	ld (scene_CB9F),de                ; 6822
	ld a,(hl)                       ; 6826
	ld (bank_slot2_shadow),a        ; 6827
	ld (MAPPER_SLOT2),a             ; 682A  mapper : banque du slot 2 ($8000-$BFFF)
	inc hl                          ; 682D
	ld (scene_CBA3),a                 ; 682E
	ld (scene_script_ptr),hl        ; 6831
	xor a                           ; 6834
	ld (scene_CBA5),a                 ; 6835
	inc a                           ; 6838
	ld (scene_CBA4),a                 ; 6839
	ret                             ; 683C
loc_683D:
	pop hl                          ; 683D
	ld e,(hl)                       ; 683E
	inc hl                          ; 683F
	ld d,(hl)                       ; 6840
	inc hl                          ; 6841
	ld c,(hl)                       ; 6842
	inc hl                          ; 6843
	ld b,(hl)                       ; 6844
	inc hl                          ; 6845
	push bc                         ; 6846
	ld a,(hl)                       ; 6847
	ld (bank_slot2_shadow),a        ; 6848
	ld (MAPPER_SLOT2),a             ; 684B  mapper : banque du slot 2 ($8000-$BFFF)
	inc hl                          ; 684E
	ld (scene_script_ptr),hl        ; 684F
	pop hl                          ; 6852
	call sub_46A1                   ; 6853
	ret                             ; 6856
loc_6857:
	pop hl                          ; 6857
	ld a,(hl)                       ; 6858
	inc hl                          ; 6859
	ld (scroll_x),a                 ; 685A
	ld a,(hl)                       ; 685D
	inc hl                          ; 685E
	ld (scroll_y),a                 ; 685F
	ld (scene_script_ptr),hl        ; 6862
	ld hl,#vdp_requests2            ; 6865
	set 5,(hl)                      ; 6868
	ret                             ; 686A
loc_686B:
	pop hl                          ; 686B
	ld a,(hl)                       ; 686C
	inc hl                          ; 686D
	ld (scene_scroll_dx),a          ; 686E
	ld a,(hl)                       ; 6871
	inc hl                          ; 6872
	ld (scene_scroll_dy),a          ; 6873
	ld a,(hl)                       ; 6876
	inc hl                          ; 6877
	ld (scene_wait),a               ; 6878
	ld (scene_script_ptr),hl        ; 687B
	ret                             ; 687E
.if VERSION_SMS_EN
loc_687F:
	ld de,#VDP_VRAM_WRITE|0x3b40    ; 687F
.else ; VERSION_GG_JP
loc_687F:
	ld de,#VDP_VRAM_WRITE|0x3b00    ; 687F
.endif
	ld hl,#0x111f                   ; 6882
	ld bc,#0x0080                   ; 6885
	di                              ; 6888
	call sub_44D0                   ; 6889
	ei                              ; 688C
	pop hl                          ; 688D
	ld a,(hl)                       ; 688E
	ld (text_CBB4),a                 ; 688F
	ld (text_CBB3),a                 ; 6892
	inc hl                          ; 6895
	ld a,(hl)                       ; 6896
	inc hl                          ; 6897
	ld (scene_script_ptr),hl        ; 6898
.if VERSION_SMS_EN
	ld hl,#0x7b4c                   ; 689B
.else ; VERSION_GG_JP
	ld hl,#data_7B4E                ; 689B
.endif
	ld (text_CBB1),hl                ; 689E
	ld l,a                          ; 68A1
	ld h,#0x00                      ; 68A2
	add hl,hl                       ; 68A4
	set 7,h                         ; 68A5
.if VERSION_SMS_EN
.if ROM512
	ld a,#0x1b                      ; 68A7  ROM512 : dialogues en banque 27 (ex-banque 32)
.else
	ld a,#0x20                      ; 68A7
.endif
.else ; VERSION_GG_JP
	ld a,#0x1c                      ; 68A7
.endif
	ld (bank_slot2_shadow),a        ; 68A9
	ld (MAPPER_SLOT2),a             ; 68AC  mapper : banque du slot 2 ($8000-$BFFF)
	ld e,(hl)                       ; 68AF
	inc hl                          ; 68B0
	ld d,(hl)                       ; 68B1
	ld (text_ptr),de                ; 68B2
	ret                             ; 68B6

;; ---------------------------------------------------------------- $06998
;; classement : atteinte uniquement par script_op_6595
	.area _B01_6998
sub_6998::
	ld b,#0x00                      ; 6998
	cp #0x20                        ; 699A
	ret c                           ; 699C
	cp #0x80                        ; 699D
	ret nc                          ; 699F
	ld b,#0x80                      ; 69A0
	ret                             ; 69A2
loc_69A3:
	pop hl                          ; 69A3
	ld b,(hl)                       ; 69A4
	inc hl                          ; 69A5
	ld c,(hl)                       ; 69A6
	inc hl                          ; 69A7
	ld e,(hl)                       ; 69A8
	inc hl                          ; 69A9
	ld d,(hl)                       ; 69AA
	inc hl                          ; 69AB
	push de                         ; 69AC
	pop iy                          ; 69AD
	ld 15(iy),b                     ; 69AF
	ld 21(iy),c                     ; 69B2
	ld a,(hl)                       ; 69B5
	inc hl                          ; 69B6
	ld 16(iy),a                     ; 69B7
	ld a,(hl)                       ; 69BA
	inc hl                          ; 69BB
	ld 17(iy),a                     ; 69BC
	ld a,(hl)                       ; 69BF
	inc hl                          ; 69C0
	ld 18(iy),a                     ; 69C1
	ld a,(hl)                       ; 69C4
	inc hl                          ; 69C5
	ld 19(iy),a                     ; 69C6
	ld (scene_script_ptr),hl        ; 69C9
	ret                             ; 69CC
loc_69CD:
	pop hl                          ; 69CD
	ld e,(hl)                       ; 69CE
	inc hl                          ; 69CF
	ld d,(hl)                       ; 69D0
	inc hl                          ; 69D1
	ld (scene_script_ptr),hl        ; 69D2
	ex de,hl                        ; 69D5
	xor a                           ; 69D6
	ld (hl),a                       ; 69D7
	ret                             ; 69D8
loc_69D9:
	pop hl                          ; 69D9
	ld a,(hl)                       ; 69DA
	inc hl                          ; 69DB
	ld (scene_script_ptr),hl        ; 69DC
	ld (snd_queue_music),a          ; 69DF
	ret                             ; 69E2
loc_69E3:
	pop hl                          ; 69E3
	ld a,(hl)                       ; 69E4
	inc hl                          ; 69E5
	ld (scene_script_ptr),hl        ; 69E6
	ld (level_C1F3),a                 ; 69E9
	ld (snd_queue_0),a              ; 69EC
	ret                             ; 69EF
loc_69F0:
	pop hl                          ; 69F0
	ld a,(hl)                       ; 69F1
	inc hl                          ; 69F2
	ld (scene_C908),a                 ; 69F3
	ld a,(hl)                       ; 69F6
	inc hl                          ; 69F7
	ld (scene_C907),a                 ; 69F8
	ld (scene_script_ptr),hl        ; 69FB
	ret                             ; 69FE
loc_69FF:
	pop hl                          ; 69FF
	ld (scene_script_ptr),hl        ; 6A00
	call sound_init                 ; 6A03
	ret                             ; 6A06
loc_6A07:
	pop hl                          ; 6A07
	ld (scene_script_ptr),hl        ; 6A08
	di                              ; 6A0B
	call sub_059F                   ; 6A0C
	ei                              ; 6A0F
	ret                             ; 6A10
loc_6A11:
	pop hl                          ; 6A11
	ld e,(hl)                       ; 6A12
	inc hl                          ; 6A13
	ld d,(hl)                       ; 6A14
	inc hl                          ; 6A15
	push de                         ; 6A16
	ld e,(hl)                       ; 6A17
	inc hl                          ; 6A18
	ld d,(hl)                       ; 6A19
	inc hl                          ; 6A1A
	ld c,(hl)                       ; 6A1B
	inc hl                          ; 6A1C
	ld b,(hl)                       ; 6A1D
	inc hl                          ; 6A1E
	ld a,(hl)                       ; 6A1F
	inc hl                          ; 6A20
	ld (player_C0B1),a                 ; 6A21
	ld a,(hl)                       ; 6A24
	ld (bank_slot2_shadow),a        ; 6A25
	ld (MAPPER_SLOT2),a             ; 6A28  mapper : banque du slot 2 ($8000-$BFFF)
	inc hl                          ; 6A2B
	ld (scene_script_ptr),hl        ; 6A2C
	pop hl                          ; 6A2F

;; ---------------------------------------------------------------- $06A30
;; classement : racines du meme module : script_op_6595+task5_scene
	.area _B01_6A30
sub_6A30:
	ld a,(player_C0B1)                 ; 6A30
	bit 7,a                         ; 6A33
	jr z,loc_6A3C                   ; 6A35
	call sub_44E4                   ; 6A37
	jr loc_6A3F                     ; 6A3A
loc_6A3C:
	call sub_454E                   ; 6A3C
loc_6A3F:
	ret                             ; 6A3F
loc_6A40:
	pop hl                          ; 6A40
	ld e,(hl)                       ; 6A41
	inc hl                          ; 6A42
	ld d,(hl)                       ; 6A43
	inc hl                          ; 6A44
	ld (scene_CBA9),de                ; 6A45
	ld a,(hl)                       ; 6A49
	ld (bank_slot2_shadow),a        ; 6A4A
	ld (MAPPER_SLOT2),a             ; 6A4D  mapper : banque du slot 2 ($8000-$BFFF)
	inc hl                          ; 6A50
	ld (scene_CBA6),a                 ; 6A51
	ld (scene_script_ptr),hl        ; 6A54
	xor a                           ; 6A57
	ld (scene_CBA8),a                 ; 6A58
	inc a                           ; 6A5B
	ld (actor_CBA7),a                 ; 6A5C
	ret                             ; 6A5F
loc_6A60:
	pop hl                          ; 6A60
	ld e,(hl)                       ; 6A61
	inc hl                          ; 6A62
	ld d,(hl)                       ; 6A63
	inc hl                          ; 6A64
	ld (irq_C1BC),de                ; 6A65
	ld e,(hl)                       ; 6A69
	inc hl                          ; 6A6A
	ld d,(hl)                       ; 6A6B
	inc hl                          ; 6A6C
	ld (irq_C1B8),de                ; 6A6D
	ld (scene_script_ptr),hl        ; 6A71
	ld hl,(util_C0AD)                ; 6A74
	ld (irq_C1BA),hl                ; 6A77
	ld a,#0x01                      ; 6A7A
	ld (scene_C1BF),a                 ; 6A7C
	ret                             ; 6A7F
loc_6A80:
	pop hl                          ; 6A80
	ld (scene_script_ptr),hl        ; 6A81
	xor a                           ; 6A84
	ld (irq_C1C1),a                 ; 6A85
	ld (raster_ptr),a               ; 6A88
	ld (irq_C1C5),a                 ; 6A8B
	ld a,#0x06                      ; 6A8E
	ld (game_mode),a                ; 6A90
	ret                             ; 6A93
loc_6A94:
	pop hl                          ; 6A94
	ld a,(hl)                       ; 6A95
	inc hl                          ; 6A96
	ld (scene_script_ptr),hl        ; 6A97
	add a,a                         ; 6A9A
	ld e,a                          ; 6A9B
	ld d,#0x00                      ; 6A9C
	di                              ; 6A9E
	ld a,#0x05                      ; 6A9F
	ld (game_mode),a                ; 6AA1
	ld a,#0x04                      ; 6AA4
	ld (bank_slot2_shadow),a        ; 6AA6
	ld (MAPPER_SLOT2),a             ; 6AA9  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b04_B55E            ; 6AAC
	add hl,de                       ; 6AAF
	ld e,(hl)                       ; 6AB0
	inc hl                          ; 6AB1
	ld d,(hl)                       ; 6AB2
	ex de,hl                        ; 6AB3
	ld c,(hl)                       ; 6AB4
	inc hl                          ; 6AB5
	ld b,(hl)                       ; 6AB6
	inc hl                          ; 6AB7
	ld a,(hl)                       ; 6AB8
	inc hl                          ; 6AB9
	ld (irq_C1C1),a                 ; 6ABA
	ld e,(hl)                       ; 6ABD
	inc hl                          ; 6ABE
	ld d,(hl)                       ; 6ABF
	inc hl                          ; 6AC0
	ld (raster_ptr),de              ; 6AC1
	ld (irq_C1C2),de                ; 6AC5
	inc hl                          ; 6AC9
	inc hl                          ; 6ACA
	ldir                            ; 6ACB
	ei                              ; 6ACD
	ret                             ; 6ACE

;; ---------------------------------------------------------------- $06ACF
;; classement : atteinte uniquement par task5_scene
	.area _B01_6ACF
sub_6ACF:
	ld a,(pause_C8D7)                 ; 6ACF
	or a                            ; 6AD2
	jr z,loc_6ADD                   ; 6AD3
	ld hl,#vdp_requests2            ; 6AD5
	set 7,(hl)                      ; 6AD8
	jp sub_711C                     ; 6ADA
loc_6ADD:
	ld bc,#0x1000                   ; 6ADD
	ld iy,#scene_C91F                 ; 6AE0
loc_6AE4:
	ld a,0(iy)                      ; 6AE4
	or a                            ; 6AE7
	jp z,loc_6B8E                   ; 6AE8
	ld e,16(iy)                     ; 6AEB
	ld d,17(iy)                     ; 6AEE
	ld l,1(iy)                      ; 6AF1
	ld h,2(iy)                      ; 6AF4
	add hl,de                       ; 6AF7
	ld 1(iy),l                      ; 6AF8
	ld 2(iy),h                      ; 6AFB
	ld e,18(iy)                     ; 6AFE
	ld d,19(iy)                     ; 6B01
	ld l,4(iy)                      ; 6B04
	ld h,5(iy)                      ; 6B07
	add hl,de                       ; 6B0A
	ld 4(iy),l                      ; 6B0B
	ld 5(iy),h                      ; 6B0E
	ld a,15(iy)                     ; 6B11
	or a                            ; 6B14
	jr z,loc_6B78                   ; 6B15
	dec a                           ; 6B17
	ld 15(iy),a                     ; 6B18
	jr nz,loc_6B78                  ; 6B1B
	ld a,21(iy)                     ; 6B1D
	or a                            ; 6B20
	jr z,loc_6B68                   ; 6B21
	cp #0x40                        ; 6B23
	jr nc,loc_6B68                  ; 6B25
	dec a                           ; 6B27
	ld l,a                          ; 6B28
	ld h,#0x00                      ; 6B29
	add hl,hl                       ; 6B2B
	add hl,hl                       ; 6B2C
	add hl,hl                       ; 6B2D
	set 7,h                         ; 6B2E
	ld a,#0x0e                      ; 6B30
	ld (bank_slot2_shadow),a        ; 6B32
	ld (MAPPER_SLOT2),a             ; 6B35  mapper : banque du slot 2 ($8000-$BFFF)
	ld a,(hl)                       ; 6B38
	inc hl                          ; 6B39
	or a                            ; 6B3A
	jr z,loc_6B49                   ; 6B3B
	ld a,(hl)                       ; 6B3D
	ld 2(iy),a                      ; 6B3E
	inc hl                          ; 6B41
	ld a,(hl)                       ; 6B42
	ld 5(iy),a                      ; 6B43
	inc hl                          ; 6B46
	jr loc_6B5D                     ; 6B47
loc_6B49:
	ld a,(hl)                       ; 6B49
	ld 16(iy),a                     ; 6B4A
	inc hl                          ; 6B4D
	ld a,(hl)                       ; 6B4E
	ld 17(iy),a                     ; 6B4F
	inc hl                          ; 6B52
	ld a,(hl)                       ; 6B53
	ld 18(iy),a                     ; 6B54
	inc hl                          ; 6B57
	ld a,(hl)                       ; 6B58
	ld 19(iy),a                     ; 6B59
	inc hl                          ; 6B5C
loc_6B5D:
	ld a,(hl)                       ; 6B5D
	ld 15(iy),a                     ; 6B5E
	inc hl                          ; 6B61
	ld a,(hl)                       ; 6B62
	ld 21(iy),a                     ; 6B63
	jr loc_6B78                     ; 6B66
loc_6B68:
	ld 0(iy),a                      ; 6B68
	xor a                           ; 6B6B
	ld 16(iy),a                     ; 6B6C
	ld 17(iy),a                     ; 6B6F
	ld 18(iy),a                     ; 6B72
	ld 19(iy),a                     ; 6B75
loc_6B78:
	ld a,14(iy)                     ; 6B78
	or a                            ; 6B7B
	jr z,loc_6B86                   ; 6B7C
	dec a                           ; 6B7E
	ld 14(iy),a                     ; 6B7F
	bit 1,a                         ; 6B82
	jr nz,loc_6B8E                  ; 6B84
loc_6B86:
	inc c                           ; 6B86
	set 7,13(iy)                    ; 6B87
	call sub_6D4E                   ; 6B8B
loc_6B8E:
	ld de,#0x0028                   ; 6B8E
	add iy,de                       ; 6B91
	dec b                           ; 6B93
	jp nz,loc_6AE4                  ; 6B94
	ld a,c                          ; 6B97
	or a                            ; 6B98
	jr nz,loc_6B9F                  ; 6B99
	call sub_44BC                   ; 6B9B
	ret                             ; 6B9E
loc_6B9F:
	ld hl,#vdp_requests2            ; 6B9F
	set 7,(hl)                      ; 6BA2
	ret                             ; 6BA4

;; ---------------------------------------------------------------- $06BA5
;; classement : atteinte uniquement par task5_scene
	.area _B01_6BA5
sub_6BA5:
	ld hl,#scene_C91F                 ; 6BA5
	ld de,#scene_C920                 ; 6BA8
	ld bc,#0x027f                   ; 6BAB
	ld (hl),#0x00                   ; 6BAE
	ldir                            ; 6BB0
	xor a                           ; 6BB2
	ld (scene_wait),a               ; 6BB3
	ld (scene_scroll_dx),a          ; 6BB6
	ld (scene_scroll_dy),a          ; 6BB9
	ret                             ; 6BBC
	.db 0x3a, 0x4c, 0xc2            ; 6BBD
	.db 0x3c                        ; 6BC0

;; ---------------------------------------------------------------- $06BC1
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_6BC1
sub_6BC1:
	ld (sprite_C24C),a                 ; 6BC1
	bit 0,a                         ; 6BC4
	jr nz,loc_6BF7                  ; 6BC6
	call sub_718F                   ; 6BC8
	ld hl,#game_flags               ; 6BCB
	bit 6,(hl)                      ; 6BCE
	jr nz,loc_6BD5                  ; 6BD0
	call sub_6D1E                   ; 6BD2
loc_6BD5:
	call sub_6CC9                   ; 6BD5
	call sub_6CB2                   ; 6BD8
	call sub_6C9B                   ; 6BDB
	call sub_7055                   ; 6BDE
	ld hl,#sprite_C185                 ; 6BE1
	bit 0,(hl)                      ; 6BE4
	di                              ; 6BE6
	jr z,loc_6BF0                   ; 6BE7
	res 0,(hl)                      ; 6BE9
	ld hl,#vdp_requests2            ; 6BEB
	set 0,(hl)                      ; 6BEE
loc_6BF0:
	ld hl,#vdp_requests2            ; 6BF0
	set 7,(hl)                      ; 6BF3
	ei                              ; 6BF5
	ret                             ; 6BF6
loc_6BF7:
	call sub_6C9B                   ; 6BF7
	call sub_6CC9                   ; 6BFA
	call sub_6CB2                   ; 6BFD
	call sub_718F                   ; 6C00
	ld hl,#game_flags               ; 6C03
	bit 6,(hl)                      ; 6C06
	jr nz,loc_6C0D                  ; 6C08
	call sub_6D1E                   ; 6C0A
loc_6C0D:
	call sub_7055                   ; 6C0D
	ld hl,#sprite_C185                 ; 6C10
	bit 0,(hl)                      ; 6C13
	di                              ; 6C15
	jr z,loc_6C1F                   ; 6C16
	res 0,(hl)                      ; 6C18
	ld hl,#vdp_requests2            ; 6C1A
	set 0,(hl)                      ; 6C1D
loc_6C1F:
	ld hl,#vdp_requests2            ; 6C1F
	set 7,(hl)                      ; 6C22
	ei                              ; 6C24
	ret                             ; 6C25
