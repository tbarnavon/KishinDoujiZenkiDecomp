;; game/scroll.s
;; Defilement : $C09B (registre VDP 9) et $C0AE (registre VDP 8).
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $01BC9
;; classement : ecrit les variables de defilement
	.area _B00_1BC9
sub_1BC9::
	push de                         ; 1BC9
	call sub_1BE7                   ; 1BCA
	push hl                         ; 1BCD
	ld hl,(scroll_y)                ; 1BCE
	call sub_1BE7                   ; 1BD1
	pop de                          ; 1BD4
	ex de,hl                        ; 1BD5
	or a                            ; 1BD6
	sbc hl,de                       ; 1BD7
	ld (util_C0BE),hl                ; 1BD9
	pop de                          ; 1BDC
	ld hl,(scroll_x)                ; 1BDD
	or a                            ; 1BE0
	sbc hl,de                       ; 1BE1
	ld (util_C0C0),hl                ; 1BE3
	ret                             ; 1BE6

;; ---------------------------------------------------------------- $02249
;; classement : ecrit les variables de defilement
	.area _B00_2249
sub_2249::
	ld hl,#0x0000                   ; 2249
	ld (player_CEFF),hl                ; 224C
	ld (player_CF01),hl                ; 224F
	ld (scroll_C0B8),hl                ; 2252
	ld (player_C0B6),hl                ; 2255
	ld (util_C0C0),hl                ; 2258
	ld (util_C0BE),hl                ; 225B
	ret                             ; 225E

;; ---------------------------------------------------------------- $02C7B
;; classement : ecrit les variables de defilement
	.area _B00_2C7B
sub_2C7B::
	ld a,(player_CF06)                 ; 2C7B
	or a                            ; 2C7E
	jr z,loc_2CD0                   ; 2C7F
	ld a,(actor_CF07)                 ; 2C81
	or a                            ; 2C84
	jr z,loc_2CD0                   ; 2C85
	ld l,a                          ; 2C87
	ld h,#0x00                      ; 2C88
	add hl,hl                       ; 2C8A
	ld de,#data_5EFF                ; 2C8B
	add hl,de                       ; 2C8E
	ld e,(hl)                       ; 2C8F
	inc hl                          ; 2C90
	ld d,(hl)                       ; 2C91
	push de                         ; 2C92
	pop ix                          ; 2C93
	bit 7,17(iy)                    ; 2C95
	jr nz,loc_2CA5                  ; 2C99
	ld e,16(ix)                     ; 2C9B
	ld d,17(ix)                     ; 2C9E
	ld (player_CEFF),de                ; 2CA1
loc_2CA5:
	bit 7,19(ix)                    ; 2CA5
	ld a,(player_CF20)                 ; 2CA9
	jr z,loc_2CB4                   ; 2CAC
	bit 2,a                         ; 2CAE
	jr nz,loc_2CD0                  ; 2CB0
	jr loc_2CB8                     ; 2CB2
loc_2CB4:
	bit 3,a                         ; 2CB4
	jr nz,loc_2CD0                  ; 2CB6
loc_2CB8:
	ld hl,(player_CF01)                ; 2CB8
	ld e,18(ix)                     ; 2CBB
	ld d,19(ix)                     ; 2CBE
	add hl,de                       ; 2CC1
	ld (player_CF01),hl                ; 2CC2
	ld a,#0x00                      ; 2CC5
	bit 7,h                         ; 2CC7
	jr z,loc_2CCD                   ; 2CC9
	ld a,#0x01                      ; 2CCB
loc_2CCD:
	ld (player_CF21),a                 ; 2CCD
loc_2CD0:
	ld hl,#0x0000                   ; 2CD0
	ld (scroll_C0B8),hl                ; 2CD3
	ld a,(scroll_C19E)                 ; 2CD6
	and #0x03                       ; 2CD9
	add a,a                         ; 2CDB
	ld l,a                          ; 2CDC
	ld a,(player_CF21)                 ; 2CDD
	add a,l                         ; 2CE0
	ld l,a                          ; 2CE1
	ld h,#0x00                      ; 2CE2
	add hl,hl                       ; 2CE4
	ld de,#jt_2CEE                  ; 2CE5
	add hl,de                       ; 2CE8
	ld e,(hl)                       ; 2CE9
	inc hl                          ; 2CEA
	ld d,(hl)                       ; 2CEB
	ex de,hl                        ; 2CEC
	jp (hl)                         ; 2CED
jt_2CEE:
	.dw loc_2CFA                    ; 2CEE
	.dw loc_2D26                    ; 2CF0
	.dw loc_2D52                    ; 2CF2
	.dw loc_2D9A                    ; 2CF4
	.dw loc_2DFF                    ; 2CF6
	.dw loc_2DE2                    ; 2CF8
loc_2CFA:
	ld a,(scroll_C0B0)                 ; 2CFA
	bit 3,a                         ; 2CFD
	ret nz                          ; 2CFF
	ld hl,(player_CEF3)                ; 2D00
	ld de,#0x7800                   ; 2D03
	or a                            ; 2D06
	sbc hl,de                       ; 2D07
	ret c                           ; 2D09
	ld hl,(player_CEF3)                ; 2D0A
	ld de,#0x8800                   ; 2D0D
	or a                            ; 2D10
	sbc hl,de                       ; 2D11
	jr c,loc_2D1F                   ; 2D13
	ld hl,(player_CEF3)                ; 2D15
	ld de,#0xa800                   ; 2D18
	or a                            ; 2D1B
	sbc hl,de                       ; 2D1C
	ret c                           ; 2D1E
loc_2D1F:
	ld a,#0x01                      ; 2D1F
	ld (scroll_C19E),a                 ; 2D21
	jr loc_2D69                     ; 2D24
loc_2D26:
	ld a,(scroll_C0B0)                 ; 2D26
	bit 2,a                         ; 2D29
	ret nz                          ; 2D2B
	ld hl,(player_CEF3)                ; 2D2C
	ld de,#0x8800                   ; 2D2F
	or a                            ; 2D32
	sbc hl,de                       ; 2D33
	ret nc                          ; 2D35
	ld hl,(player_CEF3)                ; 2D36
	ld de,#0x7800                   ; 2D39
	or a                            ; 2D3C
	sbc hl,de                       ; 2D3D
	jr nc,loc_2D4B                  ; 2D3F
	ld hl,(player_CEF3)                ; 2D41
	ld de,#0x5800                   ; 2D44
	or a                            ; 2D47
	sbc hl,de                       ; 2D48
	ret nc                          ; 2D4A
loc_2D4B:
	ld a,#0x01                      ; 2D4B
	ld (scroll_C19E),a                 ; 2D4D
	jr loc_2DB1                     ; 2D50
loc_2D52:
	ld a,(scroll_C0B0)                 ; 2D52
	bit 3,a                         ; 2D55
	jr z,loc_2D5E                   ; 2D57
	xor a                           ; 2D59
	ld (scroll_C19E),a                 ; 2D5A
	ret                             ; 2D5D
loc_2D5E:
	ld hl,(player_CEF3)                ; 2D5E
	ld de,#0x7800                   ; 2D61
	or a                            ; 2D64
	sbc hl,de                       ; 2D65
	jr c,loc_2D93                   ; 2D67
loc_2D69:
	ld de,#data_0400                ; 2D69
	ld a,(current_stage)            ; 2D6C
	or a                            ; 2D6F
	jr nz,loc_2D75                  ; 2D70
	ld de,#0x0200                   ; 2D72
loc_2D75:
	ld hl,(player_CF01)                ; 2D75
	add hl,de                       ; 2D78
	ex de,hl                        ; 2D79
	ld hl,#0x0000                   ; 2D7A
	or a                            ; 2D7D
	sbc hl,de                       ; 2D7E
	ld (scroll_C0B8),hl                ; 2D80
	ld hl,#scroll_FC00                 ; 2D83
	ld a,(current_stage)            ; 2D86
	or a                            ; 2D89
	jr nz,loc_2D8F                  ; 2D8A
	ld hl,#scroll_FE00                 ; 2D8C
loc_2D8F:
	ld (player_CF01),hl                ; 2D8F
	ret                             ; 2D92
loc_2D93:
	ld a,#0x02                      ; 2D93
	ld (scroll_C19E),a                 ; 2D95
	jr loc_2E0B                     ; 2D98
loc_2D9A:
	ld a,(scroll_C0B0)                 ; 2D9A
	bit 2,a                         ; 2D9D
	jr z,loc_2DA6                   ; 2D9F
	xor a                           ; 2DA1
	ld (scroll_C19E),a                 ; 2DA2
	ret                             ; 2DA5
loc_2DA6:
	ld hl,(player_CEF3)                ; 2DA6
	ld de,#0x8800                   ; 2DA9
	or a                            ; 2DAC
	sbc hl,de                       ; 2DAD
	jr nc,loc_2DDB                  ; 2DAF
loc_2DB1:
	ld de,#scroll_FC00                 ; 2DB1
	ld a,(current_stage)            ; 2DB4
	or a                            ; 2DB7
	jr nz,loc_2DBD                  ; 2DB8
	ld de,#scroll_FE00                 ; 2DBA
loc_2DBD:
	ld hl,(player_CF01)                ; 2DBD
	add hl,de                       ; 2DC0
	ex de,hl                        ; 2DC1
	ld hl,#0x0000                   ; 2DC2
	or a                            ; 2DC5
	sbc hl,de                       ; 2DC6
	ld (scroll_C0B8),hl                ; 2DC8
	ld hl,#data_0400                ; 2DCB
	ld a,(current_stage)            ; 2DCE
	or a                            ; 2DD1
	jr nz,loc_2DD7                  ; 2DD2
	ld hl,#0x0200                   ; 2DD4
loc_2DD7:
	ld (player_CF01),hl                ; 2DD7
	ret                             ; 2DDA
loc_2DDB:
	ld a,#0x02                      ; 2DDB
	ld (scroll_C19E),a                 ; 2DDD
	jr loc_2DEE                     ; 2DE0
loc_2DE2:
	ld a,(scroll_C0B0)                 ; 2DE2
	bit 2,a                         ; 2DE5
	jr z,loc_2DEE                   ; 2DE7
	xor a                           ; 2DE9
	ld (scroll_C19E),a                 ; 2DEA
	ret                             ; 2DED
loc_2DEE:
	ld hl,#0x0000                   ; 2DEE
	ld de,(player_CF01)                ; 2DF1
	ld (player_CF01),hl                ; 2DF5
	or a                            ; 2DF8
	sbc hl,de                       ; 2DF9
	ld (scroll_C0B8),hl                ; 2DFB
	ret                             ; 2DFE
loc_2DFF:
	ld a,(scroll_C0B0)                 ; 2DFF
	bit 3,a                         ; 2E02
	jr z,loc_2E0B                   ; 2E04
	xor a                           ; 2E06
	ld (scroll_C19E),a                 ; 2E07
	ret                             ; 2E0A
loc_2E0B:
	ld hl,#0x0000                   ; 2E0B
	ld de,(player_CF01)                ; 2E0E
	ld (player_CF01),hl                ; 2E12
	or a                            ; 2E15
	sbc hl,de                       ; 2E16
	ld (scroll_C0B8),hl                ; 2E18
	ret                             ; 2E1B

;; ---------------------------------------------------------------- $055A8
;; classement : ecrit le defilement (C09B -> reg VDP 9, C0AE -> reg 8)
	.area _B01_55A8
sub_55A8::
	ld a,(scroll_C0B0)                 ; 55A8
	and #0xf0                       ; 55AB
	ld (scroll_C0B0),a                 ; 55AD
	ld hl,(scroll_x)                ; 55B0
	ld a,l                          ; 55B3
	and h                           ; 55B4
	cp #0xff                        ; 55B5
	jr nz,loc_55C2                  ; 55B7
	ld b,#0x04                      ; 55B9
	ld a,(scroll_C0B0)                 ; 55BB
	or b                            ; 55BE
	ld (scroll_C0B0),a                 ; 55BF
loc_55C2:
	ld de,(util_C19A)                ; 55C2
	or a                            ; 55C6
	sbc hl,de                       ; 55C7
	jr nz,loc_55D8                  ; 55C9
	ld b,#0x08                      ; 55CB
	ld a,(scroll_C0B0)                 ; 55CD
	or b                            ; 55D0
	ld (scroll_C0B0),a                 ; 55D1
	ld (scroll_x),de                ; 55D4
loc_55D8:
	ld de,#0x0000                   ; 55D8
	ld hl,(scroll_y)                ; 55DB
	ld a,l                          ; 55DE
	or h                            ; 55DF
	jr nz,loc_55EF                  ; 55E0
	ld b,#0x01                      ; 55E2
	ld a,(scroll_C0B0)                 ; 55E4
	or b                            ; 55E7
	ld (scroll_C0B0),a                 ; 55E8
	ld (scroll_y),de                ; 55EB
loc_55EF:
	ld de,(level_C19C)                ; 55EF
	or a                            ; 55F3
	sbc hl,de                       ; 55F4
	jr c,loc_5605                   ; 55F6
	ld b,#0x02                      ; 55F8
	ld a,(scroll_C0B0)                 ; 55FA
	or b                            ; 55FD
	ld (scroll_C0B0),a                 ; 55FE
	ld (scroll_y),de                ; 5601
loc_5605:
	ret                             ; 5605

;; ---------------------------------------------------------------- $05606
;; classement : ecrit le defilement (C09B -> reg VDP 9, C0AE -> reg 8)
	.area _B01_5606
sub_5606::
	ld de,(scroll_C0B8)                ; 5606
	ld a,#0x00                      ; 560A
	bit 7,d                         ; 560C
	jr z,loc_5612                   ; 560E
	ld a,#0xff                      ; 5610
loc_5612:
	ld hl,(util_C0AD)                ; 5612
	ld h,#0x00                      ; 5615
	add hl,de                       ; 5617
	adc a,#0x00                     ; 5618
	ld e,l                          ; 561A
	ld l,h                          ; 561B
	ld h,a                          ; 561C
	ld a,e                          ; 561D
	ld (util_C0AD),a                 ; 561E
	ex de,hl                        ; 5621
	ld hl,(scroll_x)                ; 5622
	call sub_56CA                   ; 5625
	ld (scroll_x),hl                ; 5628
	ld a,l                          ; 562B
	and #0xf0                       ; 562C
	ld b,a                          ; 562E
	ld a,(scroll_C1B4)                 ; 562F
	and #0xf0                       ; 5632
	cp b                            ; 5634
	jr z,loc_564D                   ; 5635
	ld a,l                          ; 5637
	ld (scroll_C1B4),a                 ; 5638
	ld hl,(scroll_x)                ; 563B
	ld a,(scroll_C0B9)                 ; 563E
	bit 7,a                         ; 5641
	jr nz,loc_564A                  ; 5643
	call sub_48A2                   ; 5645
	jr loc_564D                     ; 5648
loc_564A:
	call sub_489D                   ; 564A
loc_564D:
	ld de,(player_C0B6)                ; 564D
	ld a,#0x00                      ; 5651
	bit 7,d                         ; 5653
	jr z,loc_5659                   ; 5655
	ld a,#0xff                      ; 5657
loc_5659:
	ld hl,(scroll_C09A)                ; 5659
	ld h,#0x00                      ; 565C
	add hl,de                       ; 565E
	adc a,#0x00                     ; 565F
	ld e,l                          ; 5661
	ld l,h                          ; 5662
	ld h,a                          ; 5663
	ld a,e                          ; 5664
	ld (scroll_C09A),a                 ; 5665
	ex de,hl                        ; 5668
	ld hl,(scroll_y)                ; 5669
	call sub_569A                   ; 566C
	ld (scroll_y),hl                ; 566F
	ld a,l                          ; 5672
	and #0xf0                       ; 5673
	ld b,a                          ; 5675
	ld a,(scroll_C1B5)                 ; 5676
	and #0xf0                       ; 5679
	cp b                            ; 567B
	jr z,loc_5694                   ; 567C
	ld a,l                          ; 567E
	ld (scroll_C1B5),a                 ; 567F
	ld hl,(scroll_y)                ; 5682
	ld a,(scroll_C0B7)                 ; 5685
	bit 7,a                         ; 5688
	jr nz,loc_5691                  ; 568A
	call sub_4863                   ; 568C
	jr loc_5694                     ; 568F
loc_5691:
	call sub_485E                   ; 5691
loc_5694:
	ld hl,#vdp_requests2            ; 5694
	set 5,(hl)                      ; 5697
	ret                             ; 5699
