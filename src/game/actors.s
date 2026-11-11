;; game/actors.s
;; Gestion des acteurs (tache 2) : 13 emplacements, apparition des ennemis depuis la liste du niveau ($C7FB, $3A9E).
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $00505
;; classement : atteinte uniquement par task2
	.area _B00_0505
sub_0505:
	ld a,#0xb5                      ; 0505
	jp loc_0627                     ; 0507

;; ---------------------------------------------------------------- $0066B
;; classement : atteinte uniquement par task2
	.area _B00_066B
sub_066B:
	ld a,ACTOR_TYPE(iy)                      ; 066B
	ld hl,#data_06A3                ; 066E
	call sub_481F                   ; 0671
	jr z,loc_067B                   ; 0674
	ld a,#0xb6                      ; 0676
	jp loc_0627                     ; 0678
loc_067B:
	ld a,ACTOR_TYPE(iy)                      ; 067B
	ld hl,#data_06A9                ; 067E
	call sub_481F                   ; 0681
	ret z                           ; 0684
	ld a,#0xb5                      ; 0685
	jp loc_0627                     ; 0687

;; ---------------------------------------------------------------- $0068A
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_068A
sub_068A:
	ld a,#0x93                      ; 068A
	jp loc_0627                     ; 068C

;; ---------------------------------------------------------------- $0068F
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_068F
sub_068F:
	ld a,#0x9b                      ; 068F
	jp loc_0627                     ; 0691

;; ---------------------------------------------------------------- $00694
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0694
sub_0694:
	ld a,#0x9f                      ; 0694
	jp loc_0627                     ; 0696

;; ---------------------------------------------------------------- $00699
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0699
sub_0699:
	ld a,#0xa1                      ; 0699
	jp loc_0627                     ; 069B

;; ---------------------------------------------------------------- $0069E
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_069E
sub_069E:
	ld a,#0x9d                      ; 069E
	jp loc_0627                     ; 06A0
data_06A3:
	.db 0x88, 0x89, 0x74, 0x76, 0x8a, 0xff ; 06A3
data_06A9:
	.db 0x28                        ; 06A9

;; ---------------------------------------------------------------- $006AA
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_06AA
sub_06AA:
	ld e,a                          ; 06AA
	ld h,b                          ; 06AB
	ld d,b                          ; 06AC
	add a,h                         ; 06AD
	ld d,l                          ; 06AE
	ld h,e                          ; 06AF
	ld h,(hl)                       ; 06B0
	add a,c                         ; 06B1
	rst 0x38                        ; 06B2

;; ---------------------------------------------------------------- $02F31
;; classement : atteinte uniquement par task2
	.area _B00_2F31
sub_2F31:
	call sub_3006                   ; 2F31
	ld a,(player_state)             ; 2F34
	ld d,#0x1e                      ; 2F37
	cp #0xfd                        ; 2F39
	ret z                           ; 2F3B
	ld a,(player_CEFC)                 ; 2F3C
	or a                            ; 2F3F
	ret nz                          ; 2F40
	ld hl,(player_C1DF)                ; 2F41
	ld a,l                          ; 2F44
	or h                            ; 2F45
	jr z,loc_2F6C                   ; 2F46
	push hl                         ; 2F48
	pop ix                          ; 2F49
	ld a,(player_state)             ; 2F4B
	ld d,#0x26                      ; 2F4E
	cp #0xff                        ; 2F50
	jr z,loc_2F56                   ; 2F52
	ld d,#0x1c                      ; 2F54
loc_2F56:
	ld l,1(ix)                      ; 2F56
	ld h,2(ix)                      ; 2F59
	ld e,#0x00                      ; 2F5C
	add hl,de                       ; 2F5E
	ld (player_CEF0),hl                ; 2F5F
	ld l,4(ix)                      ; 2F62
	ld h,5(ix)                      ; 2F65
	ld (player_CEF3),hl                ; 2F68
	ret                             ; 2F6B
loc_2F6C:
	ld a,(player_state)             ; 2F6C
	cp #0xff                        ; 2F6F
	ld a,(player_CEF6)                 ; 2F71
	jr z,loc_2F82                   ; 2F74
	ld d,#0x14                      ; 2F76
	cp #0x1a                        ; 2F78
	ret nz                          ; 2F7A
	ld a,#0x0e                      ; 2F7B
	ld (tmp_d5),a                   ; 2F7D
	jr loc_2F8A                     ; 2F80
loc_2F82:
	cp #0x0e                        ; 2F82
	ret nz                          ; 2F84
	ld a,#0x14                      ; 2F85
	ld (tmp_d5),a                   ; 2F87
loc_2F8A:
	ld a,(player_CEF1)                 ; 2F8A
	sub d                           ; 2F8D
	ret c                           ; 2F8E
	cp #0x97                        ; 2F8F
	ret nc                          ; 2F91
	ld (tmp_d3),a                   ; 2F92
	ld a,(player_CEF4)                 ; 2F95
	ld (dbg_C0D4),a                 ; 2F98
	ld iy,#actor_CDD7                 ; 2F9B
	ld b,#0x07                      ; 2F9F
loc_2FA1:
	push bc                         ; 2FA1
	call sub_3023                   ; 2FA2
	jr z,loc_2FFD                   ; 2FA5
	ld a,ACTOR_COUNTER(iy)                     ; 2FA7
	or ACTOR_X_HI(iy)                        ; 2FAA
	or ACTOR_Y_HI(iy)                        ; 2FAD
	jr nz,loc_2FFD                  ; 2FB0
	ld a,(dbg_C0D4)                 ; 2FB2
	sub ACTOR_Y(iy)                       ; 2FB5
	jp p,loc_2FBD                   ; 2FB8
	neg                             ; 2FBB
loc_2FBD:
	cp #0x80                        ; 2FBD
	jp nc,loc_2FFD                  ; 2FBF
	ld c,a                          ; 2FC2
	ld a,(tmp_d3)                   ; 2FC3
	sub ACTOR_X(iy)                       ; 2FC6
	jp p,loc_2FCE                   ; 2FC9
	neg                             ; 2FCC
loc_2FCE:
	cp #0x80                        ; 2FCE
	jp nc,loc_2FFD                  ; 2FD0
	ld b,a                          ; 2FD3
	ld a,#0x03                      ; 2FD4
	add a,#0x02                     ; 2FD6
	cp b                            ; 2FD8
	jp c,loc_2FFD                   ; 2FD9
	inc hl                          ; 2FDC
	ld a,#0x04                      ; 2FDD
	add a,#0x08                     ; 2FDF
	cp c                            ; 2FE1
	jp c,loc_2FFD                   ; 2FE2
	push iy                         ; 2FE5
	pop hl                          ; 2FE7
	ld (player_C1DF),hl                ; 2FE8
	ld a,(tmp_d5)                   ; 2FEB
	ld (player_CEF6),a                 ; 2FEE
	xor a                           ; 2FF1
	ld (player_CEF7),a                 ; 2FF2
	ld (player_CEF8),a                 ; 2FF5
	ld (player_CEF9),a                 ; 2FF8
	pop bc                          ; 2FFB
	ret                             ; 2FFC
loc_2FFD:
	pop bc                          ; 2FFD
	ld de,#0x0028                   ; 2FFE
	add iy,de                       ; 3001
	djnz loc_2FA1                   ; 3003
	ret                             ; 3005

;; ---------------------------------------------------------------- $03006
;; classement : atteinte uniquement par task2
	.area _B00_3006
sub_3006:
	ld iy,#actor_CDD7                 ; 3006
	ld b,#0x07                      ; 300A
loc_300C:
	call sub_3023                   ; 300C
	jr z,loc_301B                   ; 300F
	ld a,ACTOR_COUNTER(iy)                     ; 3011
	or a                            ; 3014
	jr z,loc_301B                   ; 3015
	dec a                           ; 3017
	ld ACTOR_COUNTER(iy),a                     ; 3018
loc_301B:
	ld de,#0x0028                   ; 301B
	add iy,de                       ; 301E
	djnz loc_300C                   ; 3020
	ret                             ; 3022

;; ---------------------------------------------------------------- $03023
;; classement : atteinte uniquement par task2
	.area _B00_3023
sub_3023:
	ld a,ACTOR_TYPE(iy)                      ; 3023
	or a                            ; 3026
	jr z,loc_3034                   ; 3027
	cp #0x1f                        ; 3029
	jr z,loc_3031                   ; 302B
	cp #0x20                        ; 302D
	jr nz,loc_3034                  ; 302F
loc_3031:
	or #0xff                        ; 3031
	ret                             ; 3033
loc_3034:
	xor a                           ; 3034
	ret                             ; 3035

;; ---------------------------------------------------------------- $03476
;; classement : atteinte uniquement par task2
	.area _B00_3476
sub_3476::
	call sub_3606                   ; 3476
	call sub_5E7A                   ; 3479
loc_347C:
	call task_yield                 ; 347C
	ld a,(game_flags)               ; 347F
	bit 6,a                         ; 3482
	jr nz,loc_347C                  ; 3484
	ld a,(freeze_timer)             ; 3486
	or a                            ; 3489
	jr nz,loc_34CD                  ; 348A
	call sub_3A66                   ; 348C
	call sub_3A5E                   ; 348F
	call sub_3A56                   ; 3492
	call sub_3A1F                   ; 3495
	call sub_3A17                   ; 3498
	call sub_39F0                   ; 349B
	call sub_398C                   ; 349E
	call sub_39D7                   ; 34A1
	call sub_3984                   ; 34A4
	call sub_39BE                   ; 34A7
	call sub_38B2                   ; 34AA
	call sub_5F0F                   ; 34AD
	call sub_5F57                   ; 34B0
	call sub_36EC                   ; 34B3
	call sub_37B5                   ; 34B6
	call sub_5DF3                   ; 34B9
	call sub_364F                   ; 34BC
	call sub_2F31                   ; 34BF
	ld a,#0x19                      ; 34C2
	ld (bank_slot2_shadow),a        ; 34C4
	ld (MAPPER_SLOT2),a             ; 34C7  mapper : banque du slot 2 ($8000-$BFFF)
	call sub_b25_BDAC               ; 34CA
loc_34CD:
	call sub_3A9E                   ; 34CD
	jr loc_347C                     ; 34D0

;; ---------------------------------------------------------------- $034D2
;; classement : atteinte uniquement par task2
	.area _B00_34D2
sub_34D2:
	ld a,ACTOR_STATE(iy)                     ; 34D2
	and #0x84                       ; 34D5
	ret z                           ; 34D7
	jp m,loc_3558                   ; 34D8
	ld ACTOR_STATE(iy),#0x00                 ; 34DB
	set 7,ACTOR_STATE(iy)                    ; 34DF
	ld h,#0x00                      ; 34E3
	add hl,de                       ; 34E5
	ld a,(hl)                       ; 34E6
	ld ACTOR_ANIM(iy),a                      ; 34E7
	ld ACTOR_ANIM_FRAME(iy),#0x00                  ; 34EA
	ld ACTOR_ANIM_TIMER(iy),#0x00                  ; 34EE
	ld ACTOR_ANIM_END(iy),#0x00                 ; 34F2
	ld a,ACTOR_TYPE(iy)                      ; 34F6
	cp #0x8a                        ; 34F9
	jr nz,loc_3507                  ; 34FB
	xor a                           ; 34FD
	ld (level_C0C5),a                 ; 34FE
	ld hl,#data_b04_AEDE            ; 3501
	ld (pal_anim_bg_ptr),hl         ; 3504
loc_3507:
	ld a,#0x04                      ; 3507
	ld (bank_slot2_shadow),a        ; 3509
	ld (MAPPER_SLOT2),a             ; 350C  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b04_B364            ; 350F
	ld l,ACTOR_TYPE(iy)                      ; 3512
	ld h,#0x00                      ; 3515
	add hl,de                       ; 3517
	ld a,(hl)                       ; 3518
	or a                            ; 3519
	jr z,loc_3553                   ; 351A
	ld (actor_C9EF),a                 ; 351C
	ld hl,#actor_C9F0                 ; 351F
	ld de,#actor_C9F1                 ; 3522
	ld bc,#0x0026                   ; 3525
	ld (hl),#0x00                   ; 3528
	ldir                            ; 352A
	push iy                         ; 352C
	pop ix                          ; 352E
	ld iy,#actor_C9EF                 ; 3530
	ld a,2(ix)                      ; 3534
	ld ACTOR_X(iy),a                      ; 3537
	ld a,3(ix)                      ; 353A
	ld ACTOR_X_HI(iy),a                      ; 353D
	ld a,5(ix)                      ; 3540
	ld ACTOR_Y(iy),a                      ; 3543
	ld a,6(ix)                      ; 3546
	ld ACTOR_Y_HI(iy),a                      ; 3549
	call sub_3B28                   ; 354C
	push ix                         ; 354F
	pop iy                          ; 3551
loc_3553:
	call sub_0505                   ; 3553
	xor a                           ; 3556
	ret                             ; 3557
loc_3558:
	ld a,ACTOR_ANIM_END(iy)                     ; 3558
	or a                            ; 355B
	ret z                           ; 355C
	ld a,ACTOR_TYPE(iy)                      ; 355D
	ld ACTOR_TYPE(iy),#0x00                  ; 3560
	ld ACTOR_STATE(iy),#0x00                 ; 3564
	ret                             ; 3568

;; ---------------------------------------------------------------- $03606
;; classement : atteinte uniquement par task2
	.area _B00_3606
sub_3606:
	ld hl,#0x0000                   ; 3606
	ld (actor_C0D1),hl                ; 3609
	call sub_363E                   ; 360C
	ld a,#0x04                      ; 360F
	ld (bank_slot2_shadow),a        ; 3611
	ld (MAPPER_SLOT2),a             ; 3614  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(scene_id)                ; 3617
	ld h,#0x00                      ; 361A
	add hl,hl                       ; 361C
	ld de,(data_b04_8006)           ; 361D
	add hl,de                       ; 3621
	ld e,(hl)                       ; 3622
	inc hl                          ; 3623
	ld d,(hl)                       ; 3624
	ex de,hl                        ; 3625
	ld c,(hl)                       ; 3626
	inc hl                          ; 3627
	ld b,(hl)                       ; 3628
	inc hl                          ; 3629
	ld de,#spawn_list               ; 362A
	ldir                            ; 362D
	ret                             ; 362F

;; ---------------------------------------------------------------- $0364F
;; classement : atteinte uniquement par task2
	.area _B00_364F
sub_364F:
	ld iy,#actor_CB07                 ; 364F
	ld b,#0x04                      ; 3653
loc_3655::
	push bc                         ; 3655
	ld a,ACTOR_TYPE(iy)                      ; 3656
	or ACTOR_SAVED_TYPE(iy)                       ; 3659
	jp z,loc_36E1                   ; 365C
	ld a,ACTOR_STATE(iy)                     ; 365F
	or a                            ; 3662
	jp z,loc_366B                   ; 3663
	call sub_35E2                   ; 3666
	jr loc_36D5                     ; 3669
loc_366B:
	call sub_35E2                   ; 366B
	ld e,ACTOR_VX_LO(iy)                     ; 366E
	ld d,ACTOR_VX_HI(iy)                     ; 3671
	ld a,ACTOR_FLAGS(iy)                     ; 3674
	bit 3,a                         ; 3677
	jr z,loc_3682                   ; 3679
	ld hl,#0x0000                   ; 367B
	or a                            ; 367E
	sbc hl,de                       ; 367F
	ex de,hl                        ; 3681
loc_3682:
	xor a                           ; 3682
	bit 7,d                         ; 3683
	jr z,loc_3688                   ; 3685
	cpl                             ; 3687
loc_3688:
	ld c,d                          ; 3688
	ld b,a                          ; 3689
	ld a,ACTOR_X_FRAC(iy)                      ; 368A
	add a,e                         ; 368D
	ld ACTOR_X_FRAC(iy),a                      ; 368E
	ld a,#0x00                      ; 3691
	adc a,c                         ; 3693
	ld e,a                          ; 3694
	ld a,#0x00                      ; 3695
	adc a,b                         ; 3697
	ld d,a                          ; 3698
	ld l,ACTOR_X(iy)                      ; 3699
	ld h,ACTOR_X_HI(iy)                      ; 369C
	call sub_4984                   ; 369F
	ld ACTOR_X(iy),l                      ; 36A2
	ld ACTOR_X_HI(iy),h                      ; 36A5
	ld e,ACTOR_VY_LO(iy)                     ; 36A8
	ld d,ACTOR_VY_HI(iy)                     ; 36AB
	ld a,ACTOR_FLAGS(iy)                     ; 36AE
	bit 4,a                         ; 36B1
	jr z,loc_36BC                   ; 36B3
	ld hl,#0x0000                   ; 36B5
	or a                            ; 36B8
	sbc hl,de                       ; 36B9
	ex de,hl                        ; 36BB
loc_36BC:
	xor a                           ; 36BC
	bit 7,d                         ; 36BD
	jr z,loc_36C2                   ; 36BF
	cpl                             ; 36C1
loc_36C2:
	ld l,ACTOR_Y_FRAC(iy)                      ; 36C2
	ld h,ACTOR_Y(iy)                      ; 36C5
	add hl,de                       ; 36C8
	ld ACTOR_Y_FRAC(iy),l                      ; 36C9
	ld ACTOR_Y(iy),h                      ; 36CC
	adc a,ACTOR_Y_HI(iy)                     ; 36CF
	ld ACTOR_Y_HI(iy),a                      ; 36D2
loc_36D5:
	ld a,ACTOR_Y_HI(iy)                      ; 36D5
	or ACTOR_X_HI(iy)                        ; 36D8
	jr z,loc_36E1                   ; 36DB
	xor a                           ; 36DD
	ld ACTOR_TYPE(iy),a                      ; 36DE
loc_36E1:
	pop bc                          ; 36E1
	ld de,#0x0028                   ; 36E2
	add iy,de                       ; 36E5
	dec b                           ; 36E7
	jp nz,loc_3655                  ; 36E8
	ret                             ; 36EB

;; ---------------------------------------------------------------- $036EC
;; classement : atteinte uniquement par task2
	.area _B00_36EC
sub_36EC:
	ld iy,#scene_script_ptr         ; 36EC
	ld b,#0x0d                      ; 36F0
loc_36F2:
	push bc                         ; 36F2
	ld a,ACTOR_TYPE(iy)                      ; 36F3
	or ACTOR_SAVED_TYPE(iy)                       ; 36F6
	jp z,loc_37AA                   ; 36F9
	ld a,ACTOR_STATE(iy)                     ; 36FC
	or a                            ; 36FF
	jp z,loc_3708                   ; 3700
	call sub_35E2                   ; 3703
	jr loc_3772                     ; 3706
loc_3708:
	call sub_35E2                   ; 3708
	ld e,ACTOR_VX_LO(iy)                     ; 370B
	ld d,ACTOR_VX_HI(iy)                     ; 370E
	ld a,ACTOR_FLAGS(iy)                     ; 3711
	bit 3,a                         ; 3714
	jr z,loc_371F                   ; 3716
	ld hl,#0x0000                   ; 3718
	or a                            ; 371B
	sbc hl,de                       ; 371C
	ex de,hl                        ; 371E
loc_371F:
	xor a                           ; 371F
	bit 7,d                         ; 3720
	jr z,loc_3725                   ; 3722
	cpl                             ; 3724
loc_3725:
	ld c,d                          ; 3725
	ld b,a                          ; 3726
	ld a,ACTOR_X_FRAC(iy)                      ; 3727
	add a,e                         ; 372A
	ld ACTOR_X_FRAC(iy),a                      ; 372B
	ld a,#0x00                      ; 372E
	adc a,c                         ; 3730
	ld e,a                          ; 3731
	ld a,#0x00                      ; 3732
	adc a,b                         ; 3734
	ld d,a                          ; 3735
	ld l,ACTOR_X(iy)                      ; 3736
	ld h,ACTOR_X_HI(iy)                      ; 3739
	call sub_4984                   ; 373C
	ld ACTOR_X(iy),l                      ; 373F
	ld ACTOR_X_HI(iy),h                      ; 3742
	ld e,ACTOR_VY_LO(iy)                     ; 3745
	ld d,ACTOR_VY_HI(iy)                     ; 3748
	ld a,ACTOR_FLAGS(iy)                     ; 374B
	bit 4,a                         ; 374E
	jr z,loc_3759                   ; 3750
	ld hl,#0x0000                   ; 3752
	or a                            ; 3755
	sbc hl,de                       ; 3756
	ex de,hl                        ; 3758
loc_3759:
	xor a                           ; 3759
	bit 7,d                         ; 375A
	jr z,loc_375F                   ; 375C
	cpl                             ; 375E
loc_375F:
	ld l,ACTOR_Y_FRAC(iy)                      ; 375F
	ld h,ACTOR_Y(iy)                      ; 3762
	add hl,de                       ; 3765
	ld ACTOR_Y_FRAC(iy),l                      ; 3766
	ld ACTOR_Y(iy),h                      ; 3769
	adc a,ACTOR_Y_HI(iy)                     ; 376C
	ld ACTOR_Y_HI(iy),a                      ; 376F
loc_3772:
	bit 5,ACTOR_FLAGS(iy)                    ; 3772
	jr nz,loc_378A                  ; 3776
	ld a,ACTOR_X_HI(iy)                      ; 3778
	or a                            ; 377B
	jr nz,loc_37A2                  ; 377C
	ld a,ACTOR_X(iy)                      ; 377E
	ld h,#0xc7                      ; 3781
	ld l,#0x01                      ; 3783
	call sub_35D7                   ; 3785
	jr nz,loc_37A2                  ; 3788
loc_378A:
	bit 2,ACTOR_FLAGS(iy)                    ; 378A
	jr nz,loc_37AA                  ; 378E
	ld a,ACTOR_Y_HI(iy)                      ; 3790
	or a                            ; 3793
	jr nz,loc_37A2                  ; 3794
	ld a,ACTOR_Y(iy)                      ; 3796
	ld h,#0xfe                      ; 3799
	ld l,#0x01                      ; 379B
	call sub_35D7                   ; 379D
	jr z,loc_37AA                   ; 37A0
loc_37A2:
	ld ACTOR_TYPE(iy),#0x00                  ; 37A2
	ld ACTOR_SAVED_TYPE(iy),#0x00                 ; 37A6
loc_37AA:
	pop bc                          ; 37AA
	ld de,#0x0028                   ; 37AB
	add iy,de                       ; 37AE
	dec b                           ; 37B0
	jp nz,loc_36F2                  ; 37B1
	ret                             ; 37B4

;; ---------------------------------------------------------------- $037B5
;; classement : atteinte uniquement par task2
	.area _B00_37B5
sub_37B5:
	ld iy,#actor_CDD7                 ; 37B5
	ld b,#0x07                      ; 37B9
loc_37BB:
	push bc                         ; 37BB
	ld a,ACTOR_TYPE(iy)                      ; 37BC
	or ACTOR_SAVED_TYPE(iy)                       ; 37BF
	jp z,loc_38A7                   ; 37C2
	cp #0xb0                        ; 37C5
	jp c,loc_37CD                   ; 37C7
	jp loc_38A7                     ; 37CA
loc_37CD:
	ld a,#0x17                      ; 37CD
	ld (bank_slot2_shadow),a        ; 37CF
	ld (MAPPER_SLOT2),a             ; 37D2  mapper : banque du slot 2 ($8000-$BFFF)
	ld a,ACTOR_TYPE(iy)                      ; 37D5
	ld hl,#data_b23_B06B            ; 37D8
	call sub_481F                   ; 37DB
	jr z,loc_37E9                   ; 37DE
	ld a,ACTOR_STATE(iy)                     ; 37E0
	and #0x84                       ; 37E3
	jr nz,loc_37F0                  ; 37E5
	jr loc_37F5                     ; 37E7
loc_37E9:
	ld a,ACTOR_STATE(iy)                     ; 37E9
	or a                            ; 37EC
	jp z,loc_37F5                   ; 37ED
loc_37F0:
	call sub_35E2                   ; 37F0
	jr loc_385F                     ; 37F3
loc_37F5:
	call sub_35E2                   ; 37F5
	ld e,ACTOR_VX_LO(iy)                     ; 37F8
	ld d,ACTOR_VX_HI(iy)                     ; 37FB
	ld a,ACTOR_FLAGS(iy)                     ; 37FE
	bit 3,a                         ; 3801
	jr z,loc_380C                   ; 3803
	ld hl,#0x0000                   ; 3805
	or a                            ; 3808
	sbc hl,de                       ; 3809
	ex de,hl                        ; 380B
loc_380C:
	xor a                           ; 380C
	bit 7,d                         ; 380D
	jr z,loc_3812                   ; 380F
	cpl                             ; 3811
loc_3812:
	ld c,d                          ; 3812
	ld b,a                          ; 3813
	ld a,ACTOR_X_FRAC(iy)                      ; 3814
	add a,e                         ; 3817
	ld ACTOR_X_FRAC(iy),a                      ; 3818
	ld a,#0x00                      ; 381B
	adc a,c                         ; 381D
	ld e,a                          ; 381E
	ld a,#0x00                      ; 381F
	adc a,b                         ; 3821
	ld d,a                          ; 3822
	ld l,ACTOR_X(iy)                      ; 3823
	ld h,ACTOR_X_HI(iy)                      ; 3826
	call sub_4984                   ; 3829
	ld ACTOR_X(iy),l                      ; 382C
	ld ACTOR_X_HI(iy),h                      ; 382F
	ld e,ACTOR_VY_LO(iy)                     ; 3832
	ld d,ACTOR_VY_HI(iy)                     ; 3835
	ld a,ACTOR_FLAGS(iy)                     ; 3838
	bit 4,a                         ; 383B
	jr z,loc_3846                   ; 383D
	ld hl,#0x0000                   ; 383F
	or a                            ; 3842
	sbc hl,de                       ; 3843
	ex de,hl                        ; 3845
loc_3846:
	xor a                           ; 3846
	bit 7,d                         ; 3847
	jr z,loc_384C                   ; 3849
	cpl                             ; 384B
loc_384C:
	ld l,ACTOR_Y_FRAC(iy)                      ; 384C
	ld h,ACTOR_Y(iy)                      ; 384F
	add hl,de                       ; 3852
	ld ACTOR_Y_FRAC(iy),l                      ; 3853
	ld ACTOR_Y(iy),h                      ; 3856
	adc a,ACTOR_Y_HI(iy)                     ; 3859
	ld ACTOR_Y_HI(iy),a                      ; 385C
loc_385F:
	bit 5,ACTOR_FLAGS(iy)                    ; 385F
	jr nz,loc_3877                  ; 3863
	ld a,ACTOR_X_HI(iy)                      ; 3865
	or a                            ; 3868
	jr nz,loc_388F                  ; 3869
	ld a,ACTOR_X(iy)                      ; 386B
	ld h,#0xc7                      ; 386E
	ld l,#0x01                      ; 3870
	call sub_35D7                   ; 3872
	jr nz,loc_388F                  ; 3875
loc_3877:
	bit 2,ACTOR_FLAGS(iy)                    ; 3877
	jr nz,loc_38A7                  ; 387B
	ld a,ACTOR_Y_HI(iy)                      ; 387D
	or a                            ; 3880
	jr nz,loc_388F                  ; 3881
	ld a,ACTOR_Y(iy)                      ; 3883
	ld h,#0xfe                      ; 3886
	ld l,#0x01                      ; 3888
	call sub_35D7                   ; 388A
	jr z,loc_38A7                   ; 388D
loc_388F:
	ld ACTOR_TYPE(iy),#0x00                  ; 388F
	ld ACTOR_SAVED_TYPE(iy),#0x00                 ; 3893
	ld l,ACTOR_PARENT_LO(iy)                     ; 3897
	ld h,ACTOR_PARENT_HI(iy)                     ; 389A
	ld a,l                          ; 389D
	or h                            ; 389E
	jr z,loc_38A7                   ; 389F
	ld de,#0x0005                   ; 38A1
	add hl,de                       ; 38A4
	res 7,(hl)                      ; 38A5
loc_38A7:
	pop bc                          ; 38A7
	ld de,#0x0028                   ; 38A8
	add iy,de                       ; 38AB
	dec b                           ; 38AD
	jp nz,loc_37BB                  ; 38AE
	ret                             ; 38B1

;; ---------------------------------------------------------------- $038B2
;; classement : atteinte uniquement par task2
	.area _B00_38B2
sub_38B2:
	ld iy,#actor_CDD7                 ; 38B2
	ld b,#0x07                      ; 38B6
loc_38B8:
	push bc                         ; 38B8
	ld a,ACTOR_TYPE(iy)                      ; 38B9
	or ACTOR_SAVED_TYPE(iy)                       ; 38BC
	jp z,loc_3979                   ; 38BF
	cp #0xb0                        ; 38C2
	jp c,loc_3979                   ; 38C4
	call sub_35E2                   ; 38C7
	ld e,ACTOR_VX_LO(iy)                     ; 38CA
	ld d,ACTOR_VX_HI(iy)                     ; 38CD
	ld a,ACTOR_FLAGS(iy)                     ; 38D0
	bit 3,a                         ; 38D3
	jr z,loc_38DE                   ; 38D5
	ld hl,#0x0000                   ; 38D7
	or a                            ; 38DA
	sbc hl,de                       ; 38DB
	ex de,hl                        ; 38DD
loc_38DE:
	xor a                           ; 38DE
	bit 7,d                         ; 38DF
	jr z,loc_38E4                   ; 38E1
	cpl                             ; 38E3
loc_38E4:
	ld c,d                          ; 38E4
	ld b,a                          ; 38E5
	ld a,ACTOR_X_FRAC(iy)                      ; 38E6
	add a,e                         ; 38E9
	ld ACTOR_X_FRAC(iy),a                      ; 38EA
	ld a,#0x00                      ; 38ED
	adc a,c                         ; 38EF
	ld e,a                          ; 38F0
	ld a,#0x00                      ; 38F1
	adc a,b                         ; 38F3
	ld d,a                          ; 38F4
	ld l,ACTOR_X(iy)                      ; 38F5
	ld h,ACTOR_X_HI(iy)                      ; 38F8
	call sub_4984                   ; 38FB
	ld ACTOR_X(iy),l                      ; 38FE
	ld ACTOR_X_HI(iy),h                      ; 3901
	ld e,ACTOR_VY_LO(iy)                     ; 3904
	ld d,ACTOR_VY_HI(iy)                     ; 3907
	ld a,ACTOR_FLAGS(iy)                     ; 390A
	bit 4,a                         ; 390D
	jr z,loc_3918                   ; 390F
	ld hl,#0x0000                   ; 3911
	or a                            ; 3914
	sbc hl,de                       ; 3915
	ex de,hl                        ; 3917
loc_3918:
	xor a                           ; 3918
	bit 7,d                         ; 3919
	jr z,loc_391E                   ; 391B
	cpl                             ; 391D
loc_391E:
	ld l,ACTOR_Y_FRAC(iy)                      ; 391E
	ld h,ACTOR_Y(iy)                      ; 3921
	add hl,de                       ; 3924
	ld ACTOR_Y_FRAC(iy),l                      ; 3925
	ld ACTOR_Y(iy),h                      ; 3928
	adc a,ACTOR_Y_HI(iy)                     ; 392B
	ld ACTOR_Y_HI(iy),a                      ; 392E
	bit 5,ACTOR_FLAGS(iy)                    ; 3931
	jr nz,loc_3949                  ; 3935
	ld a,ACTOR_X_HI(iy)                      ; 3937
	or a                            ; 393A
	jr nz,loc_3961                  ; 393B
	ld a,ACTOR_X(iy)                      ; 393D
	ld h,#0xc7                      ; 3940
	ld l,#0x01                      ; 3942
	call sub_35D7                   ; 3944
	jr nz,loc_3961                  ; 3947
loc_3949:
	bit 2,ACTOR_FLAGS(iy)                    ; 3949
	jr nz,loc_3979                  ; 394D
	ld a,ACTOR_Y_HI(iy)                      ; 394F
	or a                            ; 3952
	jr nz,loc_3961                  ; 3953
	ld a,ACTOR_Y(iy)                      ; 3955
	ld h,#0xfe                      ; 3958
	ld l,#0x01                      ; 395A
	call sub_35D7                   ; 395C
	jr z,loc_3979                   ; 395F
loc_3961:
	ld ACTOR_TYPE(iy),#0x00                  ; 3961
	ld ACTOR_SAVED_TYPE(iy),#0x00                 ; 3965
	ld l,ACTOR_PARENT_LO(iy)                     ; 3969
	ld h,ACTOR_PARENT_HI(iy)                     ; 396C
	ld a,l                          ; 396F
	or h                            ; 3970
	jr z,loc_3979                   ; 3971
	ld de,#0x0005                   ; 3973
	add hl,de                       ; 3976
	res 7,(hl)                      ; 3977
loc_3979:
	pop bc                          ; 3979
	ld de,#0x0028                   ; 397A
	add iy,de                       ; 397D
	dec b                           ; 397F
	jp nz,loc_38B8                  ; 3980
	ret                             ; 3983

;; ---------------------------------------------------------------- $03984
;; classement : atteinte uniquement par task2
	.area _B00_3984
sub_3984:
	ld iy,#actor_CBA7                 ; 3984
	ld b,#0x0a                      ; 3988
	jr loc_39AB                     ; 398A

;; ---------------------------------------------------------------- $0398C
;; classement : atteinte uniquement par task2
	.area _B00_398C
sub_398C:
	ld iy,#scene_script_ptr         ; 398C
	ld b,#0x0d                      ; 3990
	jr loc_39AB                     ; 3992

;; ---------------------------------------------------------------- $039BE
;; classement : atteinte uniquement par task2
	.area _B00_39BE
sub_39BE:
	ld iy,#actor_CB07                 ; 39BE
	ld b,#0x04                      ; 39C2
loc_39C4:
	ld a,ACTOR_TYPE(iy)                      ; 39C4
	or ACTOR_SAVED_TYPE(iy)                       ; 39C7
	jr z,loc_39CF                   ; 39CA
	call sub_7292                   ; 39CC
loc_39CF:
	ld de,#0x0028                   ; 39CF
	add iy,de                       ; 39D2
	djnz loc_39C4                   ; 39D4
	ret                             ; 39D6

;; ---------------------------------------------------------------- $039D7
;; classement : atteinte uniquement par task2
	.area _B00_39D7
sub_39D7:
	ld iy,#player_CDAF                 ; 39D7
	ld b,#0x08                      ; 39DB
loc_39DD:
	ld a,ACTOR_TYPE(iy)                      ; 39DD
	or ACTOR_SAVED_TYPE(iy)                       ; 39E0
	jr z,loc_39E8                   ; 39E3
	call sub_7292                   ; 39E5
loc_39E8:
	ld de,#0x0028                   ; 39E8
	add iy,de                       ; 39EB
	djnz loc_39DD                   ; 39ED
	ret                             ; 39EF

;; ---------------------------------------------------------------- $039F0
;; classement : atteinte uniquement par task2
	.area _B00_39F0
sub_39F0:
	ld iy,#actor_CBA7                 ; 39F0
	ld b,#0x0a                      ; 39F4
loc_39F6:
	push bc                         ; 39F6
	ld a,ACTOR_TYPE(iy)                      ; 39F7
	or a                            ; 39FA
	jr z,loc_3A0E                   ; 39FB
	ld l,a                          ; 39FD
	ld a,#0x04                      ; 39FE
	ld (bank_slot2_shadow),a        ; 3A00
	ld (MAPPER_SLOT2),a             ; 3A03  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b04_B461            ; 3A06
	call sub_34D2                   ; 3A09
	jr z,loc_3A0E                   ; 3A0C
loc_3A0E:
	pop bc                          ; 3A0E
	ld de,#0x0028                   ; 3A0F
	add iy,de                       ; 3A12
	djnz loc_39F6                   ; 3A14
	ret                             ; 3A16

;; ---------------------------------------------------------------- $03A17
;; classement : atteinte uniquement par task2
	.area _B00_3A17
sub_3A17:
	ld iy,#actor_CB07                 ; 3A17
	ld b,#0x04                      ; 3A1B
	jr loc_3A25                     ; 3A1D

;; ---------------------------------------------------------------- $03A1F
;; classement : atteinte uniquement par task2
	.area _B00_3A1F
sub_3A1F:
	ld iy,#actor_CDD7                 ; 3A1F
	ld b,#0x07                      ; 3A23
loc_3A25:
	push bc                         ; 3A25
	ld a,ACTOR_TYPE(iy)                      ; 3A26
	or a                            ; 3A29
	jr z,loc_3A4D                   ; 3A2A
	ld l,a                          ; 3A2C
	ld a,#0x04                      ; 3A2D
	ld (bank_slot2_shadow),a        ; 3A2F
	ld (MAPPER_SLOT2),a             ; 3A32  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b04_B461            ; 3A35
	call sub_34D2                   ; 3A38
	jr z,loc_3A4D                   ; 3A3B
	ld l,ACTOR_PARENT_LO(iy)                     ; 3A3D
	ld a,ACTOR_PARENT_HI(iy)                     ; 3A40
	ld h,a                          ; 3A43
	or l                            ; 3A44
	jr z,loc_3A4D                   ; 3A45
	ld de,#0x0005                   ; 3A47
	add hl,de                       ; 3A4A
	ld (hl),#0x40                   ; 3A4B
loc_3A4D:
	pop bc                          ; 3A4D
	ld de,#0x0028                   ; 3A4E
	add iy,de                       ; 3A51
	djnz loc_3A25                   ; 3A53
	ret                             ; 3A55

;; ---------------------------------------------------------------- $03A56
;; classement : atteinte uniquement par task2
	.area _B00_3A56
sub_3A56:
	ld iy,#actor_CBA7                 ; 3A56
	ld b,#0x0a                      ; 3A5A
	jr loc_3A6C                     ; 3A5C

;; ---------------------------------------------------------------- $03A5E
;; classement : atteinte uniquement par task2
	.area _B00_3A5E
sub_3A5E:
	ld iy,#actor_CB07                 ; 3A5E
	ld b,#0x04                      ; 3A62
	jr loc_3A6C                     ; 3A64

;; ---------------------------------------------------------------- $03A66
;; classement : atteinte uniquement par task2
	.area _B00_3A66
sub_3A66:
	ld iy,#actor_CDD7                 ; 3A66
	ld b,#0x07                      ; 3A6A
loc_3A6C:
	ld a,ACTOR_TYPE(iy)                      ; 3A6C
	cp #0xb0                        ; 3A6F
	jr c,loc_3A76                   ; 3A71
	jp loc_3A96                     ; 3A73
loc_3A76:
	ld a,#0x18                      ; 3A76
	ld (bank_slot2_shadow),a        ; 3A78
	ld (MAPPER_SLOT2),a             ; 3A7B  mapper : banque du slot 2 ($8000-$BFFF)
	ld l,ACTOR_TYPE(iy)                      ; 3A7E
	ld de,#data_b24_8000            ; 3A81
	ld a,#0x1e                      ; 3A84
	ld (tmp_d3),a                   ; 3A86
	call sub_3569                   ; 3A89
	jr nz,loc_3A96                  ; 3A8C
	ld a,14(iy)                     ; 3A8E
	cp #0x1e                        ; 3A91
	call z,sub_066B                 ; 3A93
loc_3A96:
	ld de,#0x0028                   ; 3A96
	add iy,de                       ; 3A99
	djnz loc_3A6C                   ; 3A9B
	ret                             ; 3A9D

;; ---------------------------------------------------------------- $03A9E
;; classement : atteinte uniquement par task2
	.area _B00_3A9E
sub_3A9E:
	ld ix,#spawn_list               ; 3A9E
	ld hl,#0x0000                   ; 3AA2
	ld de,(scroll_x)                ; 3AA5
	or a                            ; 3AA9
	sbc hl,de                       ; 3AAA
	ld (flow_C0DB),hl                ; 3AAC
loc_3AAF:
	ld a,0(ix)                      ; 3AAF
	cp #0xff                        ; 3AB2
	ret z                           ; 3AB4
	ld a,#0xc0                      ; 3AB5
	and 5(ix)                       ; 3AB7
	jr nz,loc_3B20                  ; 3ABA
	ld hl,(flow_C0DB)                ; 3ABC
	ld e,1(ix)                      ; 3ABF
	ld d,2(ix)                      ; 3AC2
	or a                            ; 3AC5
	sbc hl,de                       ; 3AC6
	jr nc,loc_3ADA                  ; 3AC8
	ld de,#0x0000                   ; 3ACA
	ex de,hl                        ; 3ACD
	or a                            ; 3ACE
	sbc hl,de                       ; 3ACF
	ld a,h                          ; 3AD1
	or a                            ; 3AD2
	ret nz                          ; 3AD3
	ld a,l                          ; 3AD4
.if WIDESCREEN
	cp #0xce                        ; 3AD5  vue elargie : apparition au bord droit de l'ecran SMS
.else
	cp #0xc8                        ; 3AD5
.endif
	ret nc                          ; 3AD7
	jr loc_3AE3                     ; 3AD8
loc_3ADA:
	ld a,h                          ; 3ADA
	or a                            ; 3ADB
	jr nz,loc_3B20                  ; 3ADC
	ld a,l                          ; 3ADE
.if WIDESCREEN
	cp #0x2f                        ; 3ADF  vue elargie : apparition au bord gauche de l'ecran SMS
.else
	cp #0x20                        ; 3ADF
.endif
	jr nc,loc_3B20                  ; 3AE1
loc_3AE3:
	ld hl,#actor_CDD7                 ; 3AE3
	ld b,#0x07                      ; 3AE6
	call sub_3BB5                   ; 3AE8
	ret nz                          ; 3AEB
	call sub_3BD8                   ; 3AEC
	push hl                         ; 3AEF
	pop iy                          ; 3AF0
	call sub_3B78                   ; 3AF2
	ld a,ACTOR_X_HI(iy)                      ; 3AF5
	or ACTOR_Y_HI(iy)                        ; 3AF8
	jr nz,loc_3B20                  ; 3AFB
	ld a,ACTOR_X(iy)                      ; 3AFD
	ld h,#0xc7                      ; 3B00
	ld l,#0x01                      ; 3B02
	call sub_35D7                   ; 3B04
	jr nz,loc_3B20                  ; 3B07
	ld a,0(ix)                      ; 3B09
	set 7,5(ix)                     ; 3B0C
	ld ACTOR_TYPE(iy),a                      ; 3B10
	push ix                         ; 3B13
	pop hl                          ; 3B15
	ld ACTOR_PARENT_LO(iy),l                     ; 3B16
	ld ACTOR_PARENT_HI(iy),h                     ; 3B19
	call sub_3B28                   ; 3B1C
	ret                             ; 3B1F
loc_3B20:
	ld de,#0x0006                   ; 3B20
	add ix,de                       ; 3B23
	jp loc_3AAF                     ; 3B25

;; ---------------------------------------------------------------- $03B28
;; classement : routines d'acteurs partagees (banques 4/25)
	.area _B00_3B28
sub_3B28::
	ld a,#0x19                      ; 3B28
	ld (bank_slot2_shadow),a        ; 3B2A
	ld (MAPPER_SLOT2),a             ; 3B2D  mapper : banque du slot 2 ($8000-$BFFF)
	ld l,ACTOR_TYPE(iy)                      ; 3B30
	ld h,#0x00                      ; 3B33
	ld de,(actors_8000)             ; 3B35
	add hl,hl                       ; 3B39
	add hl,de                       ; 3B3A
	ld a,(hl)                       ; 3B3B
	inc hl                          ; 3B3C
	ld ACTOR_SCRIPT_LO(iy),a                     ; 3B3D
	ld a,(hl)                       ; 3B40
	ld ACTOR_SCRIPT_HI(iy),a                     ; 3B41
	ld a,#0x04                      ; 3B44
	ld (bank_slot2_shadow),a        ; 3B46
	ld (MAPPER_SLOT2),a             ; 3B49  mapper : banque du slot 2 ($8000-$BFFF)
	ld l,ACTOR_TYPE(iy)                      ; 3B4C
	ld h,#0x00                      ; 3B4F
	add hl,hl                       ; 3B51
	ld de,#data_b04_A682            ; 3B52
	add hl,de                       ; 3B55
	ld e,(hl)                       ; 3B56
	inc hl                          ; 3B57
	ld d,(hl)                       ; 3B58
	ex de,hl                        ; 3B59
	ld a,(hl)                       ; 3B5A
	ld 20(iy),a                     ; 3B5B
	inc hl                          ; 3B5E
	ld a,(hl)                       ; 3B5F
	ld 15(iy),a                     ; 3B60
	inc hl                          ; 3B63
	ld a,(hl)                       ; 3B64
	ld 12(iy),a                     ; 3B65
	inc hl                          ; 3B68
	ld a,(hl)                       ; 3B69
	ld 11(iy),a                     ; 3B6A
	inc hl                          ; 3B6D
	ld a,(hl)                       ; 3B6E
	ld ACTOR_ANIM(iy),a                      ; 3B6F
	inc hl                          ; 3B72
	ld a,(hl)                       ; 3B73
	ld ACTOR_FLAGS(iy),a                     ; 3B74
	ret                             ; 3B77

;; ---------------------------------------------------------------- $03B78
;; classement : routines d'acteurs partagees (banques 4/25)
	.area _B00_3B78
sub_3B78::
	ld l,3(ix)                      ; 3B78
	ld h,4(ix)                      ; 3B7B
	ld de,(scroll_y)                ; 3B7E
	call sub_3BA6                   ; 3B82
	ld de,#0x0017                   ; 3B85
	call sub_4984                   ; 3B88
	ld ACTOR_X(iy),l                      ; 3B8B
	ld ACTOR_X_HI(iy),h                      ; 3B8E
	ld hl,(scroll_x)                ; 3B91
	ld e,1(ix)                      ; 3B94
	ld d,2(ix)                      ; 3B97
	add hl,de                       ; 3B9A
	ld de,#0x0030                   ; 3B9B
	add hl,de                       ; 3B9E
	ld ACTOR_Y(iy),l                      ; 3B9F
	ld ACTOR_Y_HI(iy),h                      ; 3BA2
	ret                             ; 3BA5

;; ---------------------------------------------------------------- $03BA6
;; classement : routines d'acteurs partagees (banques 4/25)
	.area _B00_3BA6
sub_3BA6:
	ld a,l                          ; 3BA6
	sub e                           ; 3BA7
	ld l,a                          ; 3BA8
	push af                         ; 3BA9
	jr nc,loc_3BB0                  ; 3BAA
	ld a,#0xe0                      ; 3BAC
	add a,l                         ; 3BAE
	ld l,a                          ; 3BAF
loc_3BB0:
	pop af                          ; 3BB0
	ld a,h                          ; 3BB1
	sbc a,d                         ; 3BB2
	ld h,a                          ; 3BB3
	ret                             ; 3BB4

;; ---------------------------------------------------------------- $03BB5
;; classement : routines d'acteurs partagees (banques 4/25)
	.area _B00_3BB5
sub_3BB5::
	push iy                         ; 3BB5
	ld de,#0x0028                   ; 3BB7
	xor a                           ; 3BBA
loc_3BBB:
	push hl                         ; 3BBB
	pop iy                          ; 3BBC
	ld a,ACTOR_TYPE(iy)                      ; 3BBE
	or ACTOR_SAVED_TYPE(iy)                       ; 3BC1
	jr z,loc_3BCA                   ; 3BC4
	add hl,de                       ; 3BC6
	djnz loc_3BBB                   ; 3BC7
	dec b                           ; 3BC9
loc_3BCA:
	pop iy                          ; 3BCA
	ret                             ; 3BCC

;; ---------------------------------------------------------------- $03BCD
;; classement : routines d'acteurs partagees (banques 4/25)
	.area _B00_3BCD
sub_3BCD::
	ld de,#0x0028                   ; 3BCD
	xor a                           ; 3BD0
loc_3BD1:
	cp (hl)                         ; 3BD1
	ret z                           ; 3BD2
	add hl,de                       ; 3BD3
	djnz loc_3BD1                   ; 3BD4
	dec b                           ; 3BD6
	ret                             ; 3BD7

;; ---------------------------------------------------------------- $03BD8
;; classement : routines d'acteurs partagees (banques 4/25)
	.area _B00_3BD8
sub_3BD8::
	push hl                         ; 3BD8
	push de                         ; 3BD9
	push bc                         ; 3BDA
	push hl                         ; 3BDB
	pop de                          ; 3BDC
	inc de                          ; 3BDD
	ld bc,#0x0027                   ; 3BDE
	ld (hl),#0x00                   ; 3BE1
	ldir                            ; 3BE3
	pop bc                          ; 3BE5
	pop de                          ; 3BE6
	pop hl                          ; 3BE7
	ret                             ; 3BE8
data_3BE9::
	.db 0x05, 0x3c, 0x05, 0x3c, 0x09, 0x3c, 0x0d ; 3BE9
	.db 0x3c, 0x11, 0x3c, 0x15, 0x3c, 0x15, 0x3c, 0x15, 0x3c, 0x15, 0x3c, 0x15, 0x3c, 0x19, 0x3c, 0x15 ; 3BF0
	.db 0x3c, 0x15, 0x3c, 0x15, 0x3c, 0x00, 0x00, 0x08, 0x04, 0x00, 0x00, 0x0c, 0x08, 0xfc, 0x00, 0x10 ; 3C00
	.db 0x08, 0xf4                  ; 3C10

;; ---------------------------------------------------------------- $03C12
;; classement : routines d'acteurs partagees (banques 4/25)
	.area _B00_3C12
sub_3C12:
	nop                             ; 3C12
	jr sub_3C1D                     ; 3C13
	.db 0x00                        ; 3C15

;; ---------------------------------------------------------------- $03C16
;; classement : routines d'acteurs partagees (banques 4/25)
	.area _B00_3C16
sub_3C16:
	nop                             ; 3C16
	ex af,af'                       ; 3C17

;; ---------------------------------------------------------------- $03C18
;; classement : routines d'acteurs partagees (banques 4/25)
	.area _B00_3C18
sub_3C18:
	ex af,af'                       ; 3C18
	nop                             ; 3C19

;; ---------------------------------------------------------------- $03C1A
;; classement : routines d'acteurs partagees (banques 4/25)
	.area _B00_3C1A
sub_3C1A:
	nop                             ; 3C1A
	ex af,af'                       ; 3C1B
	inc b                           ; 3C1C

;; ---------------------------------------------------------------- $05DF3
;; classement : atteinte uniquement par task2
	.area _B01_5DF3
sub_5DF3:
	ld iy,#actor_CBA7                 ; 5DF3
	ld b,#0x0a                      ; 5DF7
	jr loc_5DFB                     ; 5DF9
loc_5DFB:
	push bc                         ; 5DFB
	ld a,ACTOR_TYPE(iy)                      ; 5DFC
	or ACTOR_SAVED_TYPE(iy)                       ; 5DFF
	jp z,loc_5E6F                   ; 5E02
	call sub_35E2                   ; 5E05
	ld e,ACTOR_VX_LO(iy)                     ; 5E08
	ld d,ACTOR_VX_HI(iy)                     ; 5E0B
	ld a,ACTOR_FLAGS(iy)                     ; 5E0E
	bit 3,a                         ; 5E11
	jr z,loc_5E1C                   ; 5E13
	ld hl,#0x0000                   ; 5E15
	or a                            ; 5E18
	sbc hl,de                       ; 5E19
	ex de,hl                        ; 5E1B
loc_5E1C:
	xor a                           ; 5E1C
	bit 7,d                         ; 5E1D
	jr z,loc_5E22                   ; 5E1F
	cpl                             ; 5E21
loc_5E22:
	ld c,d                          ; 5E22
	ld b,a                          ; 5E23
	ld a,ACTOR_X_FRAC(iy)                      ; 5E24
	add a,e                         ; 5E27
	ld ACTOR_X_FRAC(iy),a                      ; 5E28
	ld a,#0x00                      ; 5E2B
	adc a,c                         ; 5E2D
	ld e,a                          ; 5E2E
	ld a,#0x00                      ; 5E2F
	adc a,b                         ; 5E31
	ld d,a                          ; 5E32
	ld l,ACTOR_X(iy)                      ; 5E33
	ld h,ACTOR_X_HI(iy)                      ; 5E36
	call sub_4984                   ; 5E39
	ld ACTOR_X(iy),l                      ; 5E3C
	ld ACTOR_X_HI(iy),h                      ; 5E3F
	ld e,ACTOR_VY_LO(iy)                     ; 5E42
	ld d,ACTOR_VY_HI(iy)                     ; 5E45
	ld a,ACTOR_FLAGS(iy)                     ; 5E48
	bit 4,a                         ; 5E4B
	jr z,loc_5E56                   ; 5E4D
	ld hl,#0x0000                   ; 5E4F
	or a                            ; 5E52
	sbc hl,de                       ; 5E53
	ex de,hl                        ; 5E55
loc_5E56:
	xor a                           ; 5E56
	bit 7,d                         ; 5E57
	jr z,loc_5E5C                   ; 5E59
	cpl                             ; 5E5B
loc_5E5C:
	ld l,ACTOR_Y_FRAC(iy)                      ; 5E5C
	ld h,ACTOR_Y(iy)                      ; 5E5F
	add hl,de                       ; 5E62
	ld ACTOR_Y_FRAC(iy),l                      ; 5E63
	ld ACTOR_Y(iy),h                      ; 5E66
	adc a,ACTOR_Y_HI(iy)                     ; 5E69
	ld ACTOR_Y_HI(iy),a                      ; 5E6C
loc_5E6F:
	pop bc                          ; 5E6F
	ld de,#0x0028                   ; 5E70
	add iy,de                       ; 5E73
	dec b                           ; 5E75
	jp nz,loc_5DFB                  ; 5E76
	ret                             ; 5E79

;; ---------------------------------------------------------------- $05E7A
;; classement : atteinte uniquement par task2
	.area _B01_5E7A
sub_5E7A:
	call sub_5ECA                   ; 5E7A
	call sub_5EE5                   ; 5E7D
	ld iy,#actor_CBA7                 ; 5E80
	ld b,#0x0a                      ; 5E84
loc_5E86:
	ld a,0(ix)                      ; 5E86
	cp #0xff                        ; 5E89
	ret z                           ; 5E8B
	ld ACTOR_TYPE(iy),a                      ; 5E8C
	call sub_3B78                   ; 5E8F
	ld l,1(ix)                      ; 5E92
	ld h,2(ix)                      ; 5E95
	ld ACTOR_PARENT_LO(iy),l                     ; 5E98
	ld ACTOR_PARENT_HI(iy),h                     ; 5E9B
	ld l,3(ix)                      ; 5E9E
	ld h,4(ix)                      ; 5EA1
	ld ACTOR_OSC_X(iy),l                     ; 5EA4
	ld ACTOR_OSC_Y(iy),h                     ; 5EA7
	ld a,ACTOR_TYPE(iy)                      ; 5EAA
	call sub_3B28                   ; 5EAD
	ld de,#0x0028                   ; 5EB0
	add iy,de                       ; 5EB3
	ld de,#0x0005                   ; 5EB5
	add ix,de                       ; 5EB8
	djnz loc_5E86                   ; 5EBA
	ret                             ; 5EBC

;; ---------------------------------------------------------------- $05EE5
;; classement : atteinte uniquement par task2
	.area _B01_5EE5
sub_5EE5:
	ld a,#0x04                      ; 5EE5
	ld (bank_slot2_shadow),a        ; 5EE7
	ld (MAPPER_SLOT2),a             ; 5EEA  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,(data_b04_8008)           ; 5EED
	ld hl,(scene_id)                ; 5EF1
	ld h,#0x00                      ; 5EF4
	add hl,hl                       ; 5EF6
	add hl,de                       ; 5EF7
	ld e,(hl)                       ; 5EF8
	inc hl                          ; 5EF9
	ld d,(hl)                       ; 5EFA
	push de                         ; 5EFB
	pop ix                          ; 5EFC
	ret                             ; 5EFE
data_5EFF::
	.db 0x00                        ; 5EFF
	.db 0x00, 0xc7, 0xce, 0x9f, 0xce, 0x77, 0xce, 0x4f, 0xce, 0x27, 0xce, 0xff, 0xcd, 0xd7, 0xcd ; 5F00

;; ---------------------------------------------------------------- $05F0F
;; classement : atteinte uniquement par task2
	.area _B01_5F0F
sub_5F0F:
	ld iy,#player_state             ; 5F0F
	call sub_5F28                   ; 5F13
	ld iy,#actor_CDD7                 ; 5F16
	ld b,#0x07                      ; 5F1A
	ld de,#0x0028                   ; 5F1C
loc_5F1F:
	ld ACTOR_HIT(iy),#0x00                 ; 5F1F
	add iy,de                       ; 5F23
	djnz loc_5F1F                   ; 5F25
	ret                             ; 5F27

;; ---------------------------------------------------------------- $05F28
;; classement : atteinte uniquement par task2
	.area _B01_5F28
sub_5F28:
	ld a,(actor_CF07)                 ; 5F28
	or a                            ; 5F2B
	ret z                           ; 5F2C
	ld l,a                          ; 5F2D
	ld h,#0x00                      ; 5F2E
	add hl,hl                       ; 5F30
	ld de,#data_5EFF                ; 5F31
	add hl,de                       ; 5F34
	ld e,(hl)                       ; 5F35
	inc hl                          ; 5F36
	ld d,(hl)                       ; 5F37
	push de                         ; 5F38
	pop ix                          ; 5F39
	ld a,0(ix)                      ; 5F3B
	or a                            ; 5F3E
	jr nz,loc_5F46                  ; 5F3F
	ld 24(iy),#0x00                 ; 5F41
	ret                             ; 5F45
loc_5F46:
	ld l,1(ix)                      ; 5F46
	ld h,2(ix)                      ; 5F49
	ld d,11(ix)                     ; 5F4C
	ld e,#0x00                      ; 5F4F
	sbc hl,de                       ; 5F51
	ld (player_CEF0),hl                ; 5F53
	ret                             ; 5F56

;; ---------------------------------------------------------------- $05F57
;; classement : atteinte uniquement par task2
	.area _B01_5F57
sub_5F57:
	ld iy,#player_state             ; 5F57
	ld a,(player_state)             ; 5F5B
	or a                            ; 5F5E
	ret z                           ; 5F5F
	ld a,(actor_CEF2)                 ; 5F60
	or ACTOR_Y_HI(iy)                        ; 5F63
	ret nz                          ; 5F66
	ld (player_CF06),a                 ; 5F67
	ld (actor_CF07),a                 ; 5F6A
	ld a,(player_CF00)                 ; 5F6D
	bit 7,a                         ; 5F70
	ret nz                          ; 5F72
	ld b,#0xf8                      ; 5F73
	ld c,#0xfd                      ; 5F75
	call sub_5FB0                   ; 5F77
	ret nz                          ; 5F7A
	ld b,#0xf8                      ; 5F7B
	ld c,#0x03                      ; 5F7D
	call sub_5FB0                   ; 5F7F
	ret nz                          ; 5F82
	ld b,#0x01                      ; 5F83
	ld c,#0xfd                      ; 5F85
	call sub_5FB0                   ; 5F87
	jr z,loc_5F9A                   ; 5F8A
	ld 24(iy),b                     ; 5F8C
	set 4,ACTOR_HIT(iy)                    ; 5F8F
	ld a,(player_state)             ; 5F93
	ld 23(ix),a                     ; 5F96
	ret                             ; 5F99
loc_5F9A:
	ld bc,#0x0103                   ; 5F9A
	call sub_5FB0                   ; 5F9D
	jr z,loc_5FAF                   ; 5FA0
	ld 24(iy),b                     ; 5FA2
	ld c,ACTOR_TYPE(iy)                      ; 5FA5
	ld 23(ix),c                     ; 5FA8
	set 3,ACTOR_HIT(iy)                    ; 5FAB
loc_5FAF:
	ret                             ; 5FAF

;; ---------------------------------------------------------------- $05FB0
;; classement : atteinte uniquement par task2
	.area _B01_5FB0
sub_5FB0:
	ld a,(player_CEF1)                 ; 5FB0
	add a,b                         ; 5FB3
	ld (util_C0D9),a                 ; 5FB4
	ld a,(player_CEF4)                 ; 5FB7
	add a,c                         ; 5FBA
	ld (actor_C0DA),a                 ; 5FBB
	ld ix,#actor_CDD7                 ; 5FBE
	ld b,#0x07                      ; 5FC2
loc_5FC4:
	push bc                         ; 5FC4
	ld a,0(ix)                      ; 5FC5
	or a                            ; 5FC8
	jr z,loc_6012                   ; 5FC9
	cp #0xb0                        ; 5FCB
	jr c,loc_6012                   ; 5FCD
	ld a,3(ix)                      ; 5FCF
	or 6(ix)                        ; 5FD2
	or 14(ix)                       ; 5FD5
	jr nz,loc_6012                  ; 5FD8
	ld a,2(ix)                      ; 5FDA
	sub 11(ix)                      ; 5FDD
	ld l,a                          ; 5FE0
	ld a,2(ix)                      ; 5FE1
	add a,11(ix)                    ; 5FE4
	ld h,a                          ; 5FE7
	ld a,(util_C0D9)                 ; 5FE8
	call sub_35D7                   ; 5FEB
	jr nz,loc_6012                  ; 5FEE
	ld a,5(ix)                      ; 5FF0
	sub 12(ix)                      ; 5FF3
	ld l,a                          ; 5FF6
	ld a,5(ix)                      ; 5FF7
	add a,12(ix)                    ; 5FFA
	ld h,a                          ; 5FFD
	ld a,(actor_C0DA)                 ; 5FFE
	call sub_35D7                   ; 6001
	jr nz,loc_6012                  ; 6004
	ld a,2(ix)                      ; 6006
	sub 11(ix)                      ; 6009
	ld b,a                          ; 600C
	or #0xff                        ; 600D
	ld a,b                          ; 600F
	pop bc                          ; 6010
	ret                             ; 6011
loc_6012:
	ld bc,#0x0028                   ; 6012
	add ix,bc                       ; 6015
	pop bc                          ; 6017
	djnz loc_5FC4                   ; 6018
	xor a                           ; 601A
	ret                             ; 601B

;; ---------------------------------------------------------------- $67DAC
;; classement : atteinte uniquement par task2
	.area _B25_BDAC
sub_b25_BDAC:
	ld a,(scene_id)                 ; BDAC
	cp #0x29                        ; BDAF
	jr z,loc_b25_BDB6               ; BDB1
	cp #0x30                        ; BDB3
	ret nz                          ; BDB5
loc_b25_BDB6:
	ld a,(actor_CDD7)                 ; BDB6
	cp #0x74                        ; BDB9
	ret nz                          ; BDBB
	ld a,(actor_CDE4)                 ; BDBC
	and #0x84                       ; BDBF
	ret nz                          ; BDC1
	ld hl,(actor_C0D1)                ; BDC2
	ld a,l                          ; BDC5
	or h                            ; BDC6
	ret z                           ; BDC7
	dec hl                          ; BDC8
	ld (actor_C0D1),hl                ; BDC9
	ld a,l                          ; BDCC
	or h                            ; BDCD
	ret nz                          ; BDCE
	ld ix,#actor_CDD7                 ; BDCF
	set 1,34(ix)                    ; BDD3
	ld a,7(ix)                      ; BDD7
	add a,#0x04                     ; BDDA
	ld 7(ix),a                      ; BDDC
	ld 8(ix),#0x00                  ; BDDF
	ld de,#data_0193                ; BDE3
	ld l,29(ix)                     ; BDE6
	ld h,30(ix)                     ; BDE9
	ld a,l                          ; BDEC
	or h                            ; BDED
	jr z,loc_b25_BDF9               ; BDEE
	add hl,de                       ; BDF0
	ld 29(ix),l                     ; BDF1
	ld 30(ix),h                     ; BDF4
	jr loc_b25_BE06                 ; BDF7
loc_b25_BDF9:
	ld l,27(ix)                     ; BDF9
	ld h,28(ix)                     ; BDFC
	add hl,de                       ; BDFF
	ld 27(ix),l                     ; BE00
	ld 28(ix),h                     ; BE03
loc_b25_BE06:
	ld 0(ix),#0x76                  ; BE06
	ret                             ; BE0A
data_b25_BE0B::
	.db 0x7f, 0xbe, 0x7f, 0xbe, 0x7f ; BE0B
	.db 0xbe, 0x7f, 0xbe, 0x94, 0xbe, 0x94, 0xbe, 0x94, 0xbe, 0x00, 0x00, 0x9a, 0xbe, 0x9a, 0xbe, 0x9a ; BE10
	.db 0xbe, 0x9a, 0xbe, 0x9a, 0xbe, 0x00, 0x00, 0x00, 0x00, 0xb4, 0xbe, 0xb4, 0xbe, 0xb4, 0xbe, 0xc9 ; BE20
	.db 0xbe, 0xc9, 0xbe, 0xcf, 0xbe, 0xcf, 0xbe, 0xcf, 0xbe, 0xcf, 0xbe, 0xcf, 0xbe, 0xcf, 0xbe, 0xcf ; BE30
	.db 0xbe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe9, 0xbe, 0xe9, 0xbe, 0xe9, 0xbe, 0x00, 0x00, 0x00 ; BE40
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; BE50
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; BE60
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01 ; BE70
	.db 0x6b, 0x20, 0x4d, 0xd2, 0x02, 0x6c, 0x20, 0xd0, 0xcf, 0x04, 0x7c, 0x20, 0x2e, 0xd2, 0x08, 0x7d ; BE80
	.db 0x20, 0x03, 0xd1, 0xff, 0x10, 0x68, 0x00, 0xf8, 0xcf, 0xff, 0x01, 0x6f, 0x00, 0x1b, 0xd1, 0x02 ; BE90
	.db 0x70, 0x00, 0x1f, 0xd4, 0x04, 0x8c, 0x00, 0xb8, 0xd1, 0x08, 0x8d, 0x00, 0x8a, 0xd0, 0x10, 0x8e ; BEA0
	.db 0x00, 0x1a, 0xd1, 0xff, 0x01, 0x71, 0x00, 0xe4, 0xd2, 0x02, 0x72, 0x00, 0x59, 0xd1, 0x04, 0x7d ; BEB0
	.db 0x00, 0x81, 0xd1, 0x08, 0x7e, 0x00, 0xc4, 0xcf, 0xff, 0x10, 0x6c, 0x50, 0x9b, 0xd1, 0xff, 0x01 ; BEC0
	.db 0x73, 0x00, 0x2c, 0xd0, 0x02, 0x74, 0x00, 0xec, 0xcf, 0x04, 0x97, 0x00, 0x23, 0xd0, 0x08, 0x98 ; BED0
	.db 0x00, 0x34, 0xcf, 0x10, 0x99, 0x00, 0x9a, 0xd0, 0xff, 0x01, 0x8a, 0x60, 0x5d, 0xcf, 0x02, 0x6c ; BEE0
	.db 0x60, 0xbf, 0xd2, 0x04, 0x87, 0x60, 0x4d, 0xcf, 0x08, 0x88, 0x60, 0xba, 0xd1, 0x10, 0x89, 0x60 ; BEF0
	.db 0x33, 0xd3, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ; BF00
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
