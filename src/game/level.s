;; game/level.s
;; Chargement de niveau/scene (tache 3) : $5011, metatuiles (banque 10), preparation par scene ($4F01).
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $005AD
;; classement : atteinte uniquement par task3
	.area _B00_05AD
sub_05AD:
	ld a,(scene_id)                 ; 05AD
	cp #0x34                        ; 05B0
	jr nz,loc_05BE                  ; 05B2
	ld a,(level_C1F3)                 ; 05B4
	or a                            ; 05B7
	ret nz                          ; 05B8
	ld a,#0x8a                      ; 05B9
	jp sub_062D                     ; 05BB
loc_05BE:
	cp #0x35                        ; 05BE
	jr nz,loc_05CC                  ; 05C0
	ld a,(level_C1F3)                 ; 05C2
	or a                            ; 05C5
	ret nz                          ; 05C6
	ld a,#0x8c                      ; 05C7
	jp sub_062D                     ; 05C9
loc_05CC:
	cp #0x36                        ; 05CC
	ret z                           ; 05CE
	cp #0x33                        ; 05CF
	jr nz,sound_init                ; 05D1
	ld a,(level_C1F3)                 ; 05D3
	or a                            ; 05D6
	ret nz                          ; 05D7
	ld a,#0x8b                      ; 05D8
	jp sub_062D                     ; 05DA

;; ---------------------------------------------------------------- $00639
;; classement : atteinte uniquement par task3
	.area _B00_0639
sub_0639:
	ld a,#0x17                      ; 0639
	ld (bank_slot2_shadow),a        ; 063B
	ld (MAPPER_SLOT2),a             ; 063E  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b23_B099            ; 0641
	ld hl,(scene_id)                ; 0644
	ld h,#0x00                      ; 0647
	add hl,de                       ; 0649
	ld a,(hl)                       ; 064A
	or a                            ; 064B
	ret z                           ; 064C
	jr sub_062D                     ; 064D

;; ---------------------------------------------------------------- $04767
;; classement : atteinte uniquement par task3
	.area _B01_4767
sub_4767::
	call sub_05AD                   ; 4767
	call sub_5011                   ; 476A
	call sub_0639                   ; 476D
	call sub_47E7                   ; 4770
	ld hl,#vdp_requests2            ; 4773
	set 5,(hl)                      ; 4776
	ld a,#0x02                      ; 4778
	ld (bank_slot2_shadow),a        ; 477A
	ld (MAPPER_SLOT2),a             ; 477D  mapper : banque du slot 2 ($8000-$BFFF)
	call sub_b02_AD79               ; 4780
	jr z,loc_478C                   ; 4783
	ld a,#0x01                      ; 4785
	call sub_58C0                   ; 4787
	jr loc_4791                     ; 478A
loc_478C:
	ld a,#0x01                      ; 478C
	call sub_58A5                   ; 478E
loc_4791:
	ld hl,#vdp_requests2            ; 4791
	set 6,(hl)                      ; 4794
	call task_yield                 ; 4796
	call sub_0050                   ; 4799
	call sub_480A                   ; 479C
	call nz,sub_4835                ; 479F
loc_47A2:
	call task_yield                 ; 47A2
	ld a,(game_flags)               ; 47A5
	bit 6,a                         ; 47A8
	jr nz,loc_47B8                  ; 47AA
	call sub_574C                   ; 47AC
	call sub_59C1                   ; 47AF
	call sub_5A52                   ; 47B2
	call sub_47BD                   ; 47B5
loc_47B8:
	call sub_6C26                   ; 47B8
	jr loc_47A2                     ; 47BB

;; ---------------------------------------------------------------- $047BD
;; classement : atteinte uniquement par task3
	.area _B01_47BD
sub_47BD:
	ld iy,#actor_CBA7                 ; 47BD
	ld b,#0x0a                      ; 47C1
loc_47C3:
	push bc                         ; 47C3
	ld a,0(iy)                      ; 47C4
	or 35(iy)                       ; 47C7
	jr z,loc_47CF                   ; 47CA
	call sub_601C                   ; 47CC
loc_47CF:
	pop bc                          ; 47CF
	ld de,#0x0028                   ; 47D0
	add iy,de                       ; 47D3
	djnz loc_47C3                   ; 47D5
	ret                             ; 47D7

;; ---------------------------------------------------------------- $047D8
;; classement : atteinte uniquement par task3
	.area _B01_47D8
sub_47D8:
	ld hl,(scene_id)                ; 47D8
	ld h,#0x00                      ; 47DB
	add hl,hl                       ; 47DD
	ld de,#jt_4F01                  ; 47DE
	add hl,de                       ; 47E1
	ld e,(hl)                       ; 47E2
	inc hl                          ; 47E3
	ld d,(hl)                       ; 47E4
	ex de,hl                        ; 47E5
	jp (hl)                         ; 47E6

;; ---------------------------------------------------------------- $047E7
;; classement : atteinte uniquement par task3
	.area _B01_47E7
sub_47E7:
	di                              ; 47E7
	ld a,#0x04                      ; 47E8
	ld (bank_slot2_shadow),a        ; 47EA
	ld (MAPPER_SLOT2),a             ; 47ED  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(scene_id)                ; 47F0
	ld h,#0x00                      ; 47F3
	inc l                           ; 47F5
	add hl,hl                       ; 47F6
	ld de,#data_b04_B55E            ; 47F7
	add hl,de                       ; 47FA
	ld e,(hl)                       ; 47FB
	inc hl                          ; 47FC
	ld d,(hl)                       ; 47FD
	ex de,hl                        ; 47FE
	ld c,(hl)                       ; 47FF
	inc hl                          ; 4800
	ld b,(hl)                       ; 4801
	inc hl                          ; 4802
	ld de,#irq_C1C1                 ; 4803
	ldir                            ; 4806
	ei                              ; 4808
	ret                             ; 4809

;; ---------------------------------------------------------------- $0480A
;; classement : atteinte uniquement par task3
	.area _B01_480A
sub_480A:
	ld a,(game_mode)                ; 480A
	cp #0x03                        ; 480D
	jr c,loc_481B                   ; 480F
	ld a,(scene_id)                 ; 4811
	ld hl,#sub_481D                 ; 4814
	call sub_481F                   ; 4817
	ret                             ; 481A
loc_481B:
	xor a                           ; 481B
	ret                             ; 481C

;; ---------------------------------------------------------------- $0481D
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_481D
sub_481D:
	rlca                            ; 481D
	rst 0x38                        ; 481E

;; ---------------------------------------------------------------- $04835
;; classement : atteinte uniquement par task3
	.area _B01_4835
sub_4835:
	ld hl,#scene_script_ptr         ; 4835
	ld de,#util_C900                 ; 4838
	ld bc,#0x0027                   ; 483B
	ldir                            ; 483E
	ld a,#0x49                      ; 4840
	ld (scene_script_ptr),a         ; 4842
	ld (scene_C906),a                 ; 4845
	ld hl,#data_485D                ; 4848
	ld (level_C91A),hl                ; 484B
	ld a,(player_CEF1)                 ; 484E
	sub #0x10                       ; 4851
	ld (scene_wait),a               ; 4853
	ld a,(player_CEF4)                 ; 4856
	ld (text_ptr),a                 ; 4859
	ret                             ; 485C
data_485D:
	.db 0xf4                        ; 485D

;; ---------------------------------------------------------------- $04984
;; classement : metatuiles (banque 10, 8 octets par metatuile)
	.area _B01_4984
sub_4984::
	ld a,h                          ; 4984
	add hl,de                       ; 4985
	cp h                            ; 4986
	jr nz,loc_4992                  ; 4987
	ld a,l                          ; 4989
	sub #0xe0                       ; 498A
	jr c,loc_499E                   ; 498C
	ld l,a                          ; 498E
	inc h                           ; 498F
	jr loc_499E                     ; 4990
loc_4992:
	bit 7,d                         ; 4992
	jr nz,loc_499A                  ; 4994
	ld a,#0x20                      ; 4996
	jr loc_499C                     ; 4998
loc_499A:
	ld a,#0xe0                      ; 499A
loc_499C:
	add a,l                         ; 499C
	ld l,a                          ; 499D
loc_499E:
	ret                             ; 499E

;; ---------------------------------------------------------------- $0499F
;; classement : metatuiles (banque 10, 8 octets par metatuile)
	.area _B01_499F
sub_499F::
	call sub_4A0C                   ; 499F
loc_49A2:
	push bc                         ; 49A2
	ld b,c                          ; 49A3
	srl b                           ; 49A4
loc_49A6:
	push hl                         ; 49A6
	ld a,(map_bank)                 ; 49A7
	ld (bank_slot2_shadow),a        ; 49AA
	ld (MAPPER_SLOT2),a             ; 49AD  mapper : banque du slot 2 ($8000-$BFFF)
	call sub_4A24                   ; 49B0
	ld (tmp_d3),de                  ; 49B3
	push hl                         ; 49B7
	ld hl,#MAPPER_CTRL              ; 49B8
	add hl,de                       ; 49BB
	ex de,hl                        ; 49BC
	ld l,c                          ; 49BD
	ld h,#0x00                      ; 49BE
	add hl,hl                       ; 49C0
	add hl,de                       ; 49C1
	ex de,hl                        ; 49C2
	pop hl                          ; 49C3
	call sub_4A4D                   ; 49C4
	pop hl                          ; 49C7
	inc hl                          ; 49C8
	djnz loc_49A6                   ; 49C9
	inc de                          ; 49CB
	ld (tmp_d3),de                  ; 49CC
	pop bc                          ; 49D0
	djnz loc_49A2                   ; 49D1
	ret                             ; 49D3

;; ---------------------------------------------------------------- $049D4
;; classement : metatuiles (banque 10, 8 octets par metatuile)
	.area _B01_49D4
sub_49D4::
	call sub_4A0C                   ; 49D4
	ld b,#0x0b                      ; 49D7
loc_49D9:
	push hl                         ; 49D9
	call sub_4A24                   ; 49DA
	call sub_4A4D                   ; 49DD
	inc de                          ; 49E0
	ld (tmp_d3),de                  ; 49E1
	pop hl                          ; 49E5
	ld de,(level_CF18)                ; 49E6
	ld d,#0x00                      ; 49EA
	add hl,de                       ; 49EC
	djnz loc_49D9                   ; 49ED
	ret                             ; 49EF

;; ---------------------------------------------------------------- $049F0
;; classement : metatuiles (banque 10, 8 octets par metatuile)
	.area _B01_49F0
sub_49F0::
	call sub_4A0C                   ; 49F0
	ld b,#0x0c                      ; 49F3
loc_49F5:
	push hl                         ; 49F5
	call sub_4A24                   ; 49F6
	ld (tmp_d3),de                  ; 49F9
	push hl                         ; 49FD
	ld hl,#0x002c                   ; 49FE
	add hl,de                       ; 4A01
	ex de,hl                        ; 4A02
	pop hl                          ; 4A03
	call sub_4A4D                   ; 4A04
	pop hl                          ; 4A07
	inc hl                          ; 4A08
	djnz loc_49F5                   ; 4A09
	ret                             ; 4A0B

;; ---------------------------------------------------------------- $04A0C
;; classement : metatuiles (banque 10, 8 octets par metatuile)
	.area _B01_4A0C
sub_4A0C:
	ld a,#0x0a                      ; 4A0C
	ld (bank_slot2_shadow),a        ; 4A0E
	ld (MAPPER_SLOT2),a             ; 4A11  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,(level_metatile_ptr)      ; 4A14
	ld (tmp_d5),de                  ; 4A18
	ld de,#util_D4D1                 ; 4A1C
	ld (tmp_d3),de                  ; 4A1F
	ret                             ; 4A23

;; ---------------------------------------------------------------- $04A24
;; classement : metatuiles (banque 10, 8 octets par metatuile)
	.area _B01_4A24
sub_4A24:
	ld a,(hl)                       ; 4A24
	ld l,a                          ; 4A25
	ld h,#0x00                      ; 4A26
	add hl,hl                       ; 4A28
	add hl,hl                       ; 4A29
	add hl,hl                       ; 4A2A
	ld de,(tmp_d5)                  ; 4A2B
	add hl,de                       ; 4A2F
	ld de,(tmp_d3)                  ; 4A30
	ld a,#0x0a                      ; 4A34
	ld (bank_slot2_shadow),a        ; 4A36
	ld (MAPPER_SLOT2),a             ; 4A39  mapper : banque du slot 2 ($8000-$BFFF)
	ld a,(hl)                       ; 4A3C
	ld (de),a                       ; 4A3D
	inc hl                          ; 4A3E
	inc de                          ; 4A3F
	ld a,(hl)                       ; 4A40
	ld (de),a                       ; 4A41
	inc hl                          ; 4A42
	inc de                          ; 4A43
	ld a,(hl)                       ; 4A44
	ld (de),a                       ; 4A45
	inc hl                          ; 4A46
	inc de                          ; 4A47
	ld a,(hl)                       ; 4A48
	ld (de),a                       ; 4A49
	inc hl                          ; 4A4A
	inc de                          ; 4A4B
	ret                             ; 4A4C

;; ---------------------------------------------------------------- $04A4D
;; classement : metatuiles (banque 10, 8 octets par metatuile)
	.area _B01_4A4D
sub_4A4D:
	ld a,(hl)                       ; 4A4D
	ld (de),a                       ; 4A4E
	inc hl                          ; 4A4F
	inc de                          ; 4A50
	ld a,(hl)                       ; 4A51
	ld (de),a                       ; 4A52
	inc de                          ; 4A53
	inc hl                          ; 4A54
	ld a,(hl)                       ; 4A55
	ld (de),a                       ; 4A56
	inc de                          ; 4A57
	inc hl                          ; 4A58
	ld a,(hl)                       ; 4A59
	ld (de),a                       ; 4A5A
	ret                             ; 4A5B

;; ---------------------------------------------------------------- $04A5C
;; classement : metatuiles (banque 10, 8 octets par metatuile)
	.area _B01_4A5C
sub_4A5C::
	push bc                         ; 4A5C
	push de                         ; 4A5D
	ld hl,#dbg_C0D4                 ; 4A5E
	ld b,(hl)                       ; 4A61
	bit 7,b                         ; 4A62
	jr z,loc_4A70                   ; 4A64
	ld a,(level_CF18)                 ; 4A66
	neg                             ; 4A69
	ld l,a                          ; 4A6B
	ld h,#0xff                      ; 4A6C
	jr loc_4A9C                     ; 4A6E
loc_4A70:
	inc b                           ; 4A70
	ld hl,#level_FF20                 ; 4A71
	ld de,#0x00e0                   ; 4A74
loc_4A77:
	add hl,de                       ; 4A77
	djnz loc_4A77                   ; 4A78
	ex de,hl                        ; 4A7A
	ld hl,(tmp_d3)                  ; 4A7B
	ld h,#0x00                      ; 4A7E
	add hl,de                       ; 4A80
	ld a,l                          ; 4A81
	and #0xf0                       ; 4A82
	ld l,a                          ; 4A84
	srl h                           ; 4A85
	rr l                            ; 4A87
	srl h                           ; 4A89
	rr l                            ; 4A8B
	srl h                           ; 4A8D
	rr l                            ; 4A8F
	srl h                           ; 4A91
	rr l                            ; 4A93
	ex de,hl                        ; 4A95
	ld a,(level_CF18)                 ; 4A96
	call sub_4B32                   ; 4A99
loc_4A9C:
	push hl                         ; 4A9C
	ld de,(tmp_d5)                  ; 4A9D
	ld hl,#0x0000                   ; 4AA1
	or a                            ; 4AA4
	sbc hl,de                       ; 4AA5
	ld a,l                          ; 4AA7
	and #0xf0                       ; 4AA8
	ld l,a                          ; 4AAA
	ld a,h                          ; 4AAB
	and #0x0f                       ; 4AAC
	or l                            ; 4AAE
	rrca                            ; 4AAF
	rrca                            ; 4AB0
	rrca                            ; 4AB1
	rrca                            ; 4AB2
	pop de                          ; 4AB3
	ld l,a                          ; 4AB4
	ld h,#0x00                      ; 4AB5
	add hl,de                       ; 4AB7
	ld de,#level_map                ; 4AB8
	add hl,de                       ; 4ABB
	pop de                          ; 4ABC
	pop bc                          ; 4ABD
	ret                             ; 4ABE

;; ---------------------------------------------------------------- $04ABF
;; classement : metatuiles (banque 10, 8 octets par metatuile)
	.area _B01_4ABF
sub_4ABF::
	push bc                         ; 4ABF
	push hl                         ; 4AC0
	ld a,(tmp_d3)                   ; 4AC1
	srl a                           ; 4AC4
	srl a                           ; 4AC6
	srl a                           ; 4AC8
	srl a                           ; 4ACA
	ld l,a                          ; 4ACC
	ld h,#0x00                      ; 4ACD
	add hl,hl                       ; 4ACF
	add hl,hl                       ; 4AD0
	ld de,#data_4B40                ; 4AD1
	add hl,de                       ; 4AD4
	ld e,(hl)                       ; 4AD5
	inc hl                          ; 4AD6
	ld d,(hl)                       ; 4AD7
	push de                         ; 4AD8
	ld a,(dbg_C0D4)                 ; 4AD9
	neg                             ; 4ADC
	srl a                           ; 4ADE
	srl a                           ; 4AE0
	srl a                           ; 4AE2
	srl a                           ; 4AE4
	ld l,a                          ; 4AE6
	ld h,#0x00                      ; 4AE7
	add hl,hl                       ; 4AE9
	ld de,#data_4B80                ; 4AEA
	add hl,de                       ; 4AED
	ld l,(hl)                       ; 4AEE
	ld h,#0x00                      ; 4AEF
	pop de                          ; 4AF1
	add hl,de                       ; 4AF2
	ex de,hl                        ; 4AF3
	pop hl                          ; 4AF4
	pop bc                          ; 4AF5
	ret                             ; 4AF6
	.db 0xc5, 0xe5                  ; 4AF7

;; ---------------------------------------------------------------- $04AF9
;; classement : metatuiles (banque 10, 8 octets par metatuile)
	.area _B01_4AF9
sub_4AF9:
	ld a,(tmp_d3)                   ; 4AF9
	srl a                           ; 4AFC
	srl a                           ; 4AFE
	srl a                           ; 4B00
	ld l,a                          ; 4B02
	ld h,#0x00                      ; 4B03
	add hl,hl                       ; 4B05
	ld de,#data_4B40                ; 4B06
	add hl,de                       ; 4B09
	ld e,(hl)                       ; 4B0A
	inc hl                          ; 4B0B
	ld d,(hl)                       ; 4B0C
	push de                         ; 4B0D
	ld a,(dbg_C0D4)                 ; 4B0E
	neg                             ; 4B11
	srl a                           ; 4B13
	srl a                           ; 4B15
	srl a                           ; 4B17
	ld l,a                          ; 4B19
	ld h,#0x00                      ; 4B1A
	ld de,#data_4B80                ; 4B1C
	add hl,de                       ; 4B1F
	ld l,(hl)                       ; 4B20
	ld h,#0x00                      ; 4B21
	pop de                          ; 4B23
	add hl,de                       ; 4B24
	ex de,hl                        ; 4B25
	pop hl                          ; 4B26
	pop bc                          ; 4B27
	ret                             ; 4B28

;; ---------------------------------------------------------------- $04B29
;; classement : metatuiles (banque 10, 8 octets par metatuile)
	.area _B01_4B29
sub_4B29:
	call sub_2AA8                   ; 4B29
	and #0x01                       ; 4B2C
	ret z                           ; 4B2E
	ld a,#0x08                      ; 4B2F
	ret                             ; 4B31

;; ---------------------------------------------------------------- $04B32
;; classement : metatuiles (banque 10, 8 octets par metatuile)
	.area _B01_4B32
sub_4B32:
	ld b,#0x08                      ; 4B32
	ld hl,#0x0000                   ; 4B34
loc_4B37:
	add hl,hl                       ; 4B37
	add a,a                         ; 4B38
	jp nc,loc_4B3D                  ; 4B39
	add hl,de                       ; 4B3C
loc_4B3D:
	djnz loc_4B37                   ; 4B3D
	ret                             ; 4B3F
data_4B40:
	.db 0xc0, 0x78, 0x00, 0x79, 0x40, 0x79, 0x80, 0x79, 0xc0, 0x79, 0x00, 0x7a, 0x40, 0x7a, 0x80, 0x7a ; 4B40
	.db 0xc0, 0x7a, 0x00, 0x7b, 0x40, 0x7b, 0x80, 0x7b, 0xc0, 0x7b, 0x00, 0x7c, 0x40, 0x7c, 0x80, 0x7c ; 4B50
	.db 0xc0, 0x7c, 0x00, 0x7d, 0x40, 0x7d, 0x80, 0x7d, 0xc0, 0x7d, 0x00, 0x7e, 0x40, 0x7e, 0x80, 0x7e ; 4B60
	.db 0xc0, 0x7e, 0x00, 0x78, 0x40, 0x78, 0x80, 0x78, 0xc0, 0x78, 0x00, 0x79, 0x40, 0x79, 0x80, 0x79 ; 4B70
data_4B80:
	.db 0x0c, 0x0e, 0x10, 0x12, 0x14, 0x16, 0x18, 0x1a, 0x1c, 0x1e, 0x20, 0x22, 0x24, 0x26, 0x28, 0x2a ; 4B80
	.db 0x2c, 0x2e, 0x30, 0x32, 0x34, 0x36, 0x38, 0x3a, 0x3c, 0x3e, 0x00, 0x02, 0x04, 0x06, 0x08, 0x0a ; 4B90
data_4BA0:
	.db 0xd7, 0x4d, 0xd7, 0x4d, 0xd7, 0x4d, 0xd7, 0x4d, 0xaa, 0x4d, 0xaa, 0x4d, 0xaa, 0x4d, 0x00, 0x00 ; 4BA0
	.db 0xe8, 0x4d, 0xe8, 0x4d, 0xe8, 0x4d, 0xe8, 0x4d, 0xe8, 0x4d, 0x00, 0x00, 0x00, 0x00, 0x93, 0x4e ; 4BB0
	.db 0x93, 0x4e, 0x93, 0x4e, 0xdf, 0x4e, 0xdf, 0x4e, 0xb2, 0x4e, 0xb2, 0x4e, 0xb2, 0x4e, 0xb2, 0x4e ; 4BC0
	.db 0xb2, 0x4e, 0xb2, 0x4e, 0xb2, 0x4e, 0xdf, 0x4e, 0xdf, 0x4e, 0xdf, 0x4e, 0xf0, 0x4e, 0xf0, 0x4e ; 4BD0
	.db 0xf0, 0x4e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 4BE0
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 4BF0
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 4C00
	.db 0x00, 0x00, 0x00, 0x00      ; 4C10
data_4C14:
	.dw data_535A                   ; 4C14
	.dw data_535A                   ; 4C16
	.dw data_535A                   ; 4C18
	.dw data_535A                   ; 4C1A
	.dw data_538C                   ; 4C1C
	.dw data_538C                   ; 4C1E
	.dw data_538C                   ; 4C20
	.dw data_532E                   ; 4C22
	.dw data_5538                   ; 4C24
	.dw data_5538                   ; 4C26
	.dw data_5576                   ; 4C28
	.dw data_5576                   ; 4C2A
	.dw data_5538                   ; 4C2C
	.dw data_5504                   ; 4C2E
	.dw data_550C                   ; 4C30
	.dw data_54C6                   ; 4C32
	.dw data_54C6                   ; 4C34
	.dw data_54C6                   ; 4C36
	.dw data_54C6                   ; 4C38
	.dw data_54C6                   ; 4C3A
	.dw data_542C                   ; 4C3C
	.dw data_542C                   ; 4C3E
	.dw data_542C                   ; 4C40
	.dw data_542C                   ; 4C42
	.dw data_542C                   ; 4C44
	.dw data_542C                   ; 4C46
	.dw data_542C                   ; 4C48
	.dw data_54C6                   ; 4C4A
	.dw data_54C6                   ; 4C4C
	.dw data_54C6                   ; 4C4E
	.dw data_542C                   ; 4C50
	.dw data_542C                   ; 4C52
	.dw data_53EE                   ; 4C54
	.dw data_538C                   ; 4C56
	.dw data_53E6                   ; 4C58
	.dw data_53B8                   ; 4C5A
	.dw data_53C6                   ; 4C5C
	.dw data_5308                   ; 4C5E
	.dw data_53EE                   ; 4C60
	.dw data_53EE                   ; 4C62
	.dw data_53B8                   ; 4C64
	.dw data_53C6                   ; 4C66
	.dw data_523A                   ; 4C68
	.dw data_5248                   ; 4C6A
	.dw data_5276                   ; 4C6C
	.dw data_53F4                   ; 4C6E
	.dw data_53F4                   ; 4C70
	.dw data_53B8                   ; 4C72
	.dw data_53C6                   ; 4C74
	.dw data_546A                   ; 4C76
	.dw data_547E                   ; 4C78
	.dw data_54A4                   ; 4C7A
	.dw data_52BC                   ; 4C7C
	.dw data_52E2                   ; 4C7E
	.dw data_52E2                   ; 4C80
	.dw data_529C                   ; 4C82
	.dw data_547E                   ; 4C84
	.dw data_52E2                   ; 4C86
data_4C88:
	.dw data_51D2                   ; 4C88
	.dw data_51D2                   ; 4C8A
	.dw data_51D2                   ; 4C8C
	.dw data_51D2                   ; 4C8E
	.dw data_5222                   ; 4C90
	.dw data_5222                   ; 4C92
	.dw data_5222                   ; 4C94
	.dw data_51CA                   ; 4C96
	.dw data_51EA                   ; 4C98
	.dw data_51EA                   ; 4C9A
	.dw data_51EA                   ; 4C9C
	.dw data_51EA                   ; 4C9E
	.dw data_51EA                   ; 4CA0
	.dw data_51E2                   ; 4CA2
	.dw data_51E2                   ; 4CA4
	.dw data_51DA                   ; 4CA6
	.dw data_51DA                   ; 4CA8
	.dw data_51DA                   ; 4CAA
	.dw data_5212                   ; 4CAC
	.dw data_5212                   ; 4CAE
	.dw data_51FA                   ; 4CB0
	.dw data_51FA                   ; 4CB2
	.dw data_51FA                   ; 4CB4
	.dw data_51FA                   ; 4CB6
	.dw data_51FA                   ; 4CB8
	.dw data_51FA                   ; 4CBA
	.dw data_51FA                   ; 4CBC
	.dw data_5212                   ; 4CBE
	.dw data_5212                   ; 4CC0
	.dw data_5212                   ; 4CC2
	.dw data_521A                   ; 4CC4
	.dw data_521A                   ; 4CC6
	.dw data_521A                   ; 4CC8
	.dw data_5222                   ; 4CCA
	.dw data_521A                   ; 4CCC
	.dw data_521A                   ; 4CCE
	.dw data_521A                   ; 4CD0
	.dw data_51F2                   ; 4CD2
	.dw data_521A                   ; 4CD4
	.dw data_521A                   ; 4CD6
	.dw data_521A                   ; 4CD8
	.dw data_521A                   ; 4CDA
	.dw data_5202                   ; 4CDC
	.dw data_5202                   ; 4CDE
	.dw data_5202                   ; 4CE0
	.dw data_521A                   ; 4CE2
	.dw data_521A                   ; 4CE4
	.dw data_521A                   ; 4CE6
	.dw data_521A                   ; 4CE8
	.dw data_521A                   ; 4CEA
	.dw data_522A                   ; 4CEC
	.dw data_5232                   ; 4CEE
	.dw data_520A                   ; 4CF0
	.dw data_520A                   ; 4CF2
	.dw data_520A                   ; 4CF4
	.dw data_5202                   ; 4CF6
	.dw data_522A                   ; 4CF8
	.dw data_520A                   ; 4CFA
data_4CFC:
	.db 0x14, 0x00, 0x80, 0x14      ; 4CFC
	.db 0x00, 0x80, 0x14, 0x00, 0x80, 0x14, 0x00, 0x80, 0x13, 0xd5, 0x83, 0x13, 0xd5, 0x83, 0x13, 0xd5 ; 4D00
	.db 0x83, 0x13, 0x77, 0x82, 0x13, 0x79, 0x89, 0x13, 0x79, 0x89, 0x13, 0x1d, 0x8f, 0x13, 0x1d, 0x8f ; 4D10
	.db 0x13, 0xb3, 0x93, 0x13, 0x57, 0x99, 0x13, 0x57, 0x99, 0x13, 0xeb, 0x9a, 0x13, 0xeb, 0x9a, 0x13 ; 4D20
	.db 0x8f, 0xa0, 0x13, 0x63, 0xa3, 0x13, 0x63, 0xa3, 0x13, 0xad, 0xa8, 0x13, 0xad, 0xa8, 0x13, 0x51 ; 4D30
	.db 0xae, 0x13, 0x51, 0xae, 0x13, 0xf5, 0xb3, 0x13, 0xf5, 0xb3, 0x13, 0xf5, 0xb3, 0x13, 0x99, 0xb9 ; 4D40
	.db 0x13, 0x99, 0xb9, 0x13, 0x99, 0xb9, 0x14, 0x6e, 0x87, 0x14, 0x6e, 0x87, 0x14, 0xb8, 0x8c, 0x14 ; 4D50
	.db 0x5c, 0x92, 0x14, 0xa4, 0x85, 0x14, 0xb6, 0x86, 0x14, 0xb6, 0x86, 0x14, 0x94, 0xa4, 0x14, 0x00 ; 4D60
	.db 0x98, 0x14, 0x00, 0x98, 0x14, 0xdc, 0xa3, 0x14, 0xdc, 0xa3, 0x14, 0xa4, 0x9d, 0x14, 0xa4, 0x9d ; 4D70
	.db 0x14, 0xa4, 0x9d, 0x14, 0x38, 0x9e, 0x14, 0x38, 0x9e, 0x14, 0xdc, 0xa3, 0x14, 0xdc, 0xa3, 0x14 ; 4D80
	.db 0x28, 0xa5, 0x14, 0x4c, 0xa7, 0x14, 0xe0, 0xa7, 0x14, 0xee, 0xa6, 0x14, 0xee, 0xa6, 0x14, 0xee ; 4D90
	.db 0xa6, 0x14, 0xa4, 0x9d, 0x14, 0x4c, 0xa7, 0x14, 0xee, 0xa6, 0x03, 0x03, 0x1e, 0xd7, 0xb0, 0x80 ; 4DA0
	.db 0x72, 0x03, 0x04, 0x1e, 0x1d, 0xb1, 0x00, 0x72, 0x03, 0x03, 0x1e, 0xa0, 0xb0, 0x80, 0x72, 0x03 ; 4DB0
	.db 0x04, 0x1e, 0xa6, 0xb1, 0x00, 0x72, 0x03, 0x03, 0x1e, 0xd7, 0xb0, 0x80, 0x72, 0x03, 0x04, 0x1e ; 4DC0
	.db 0x2f, 0xb2, 0x00, 0x72, 0xff, 0xaa, 0x4d, 0x06, 0x03, 0x07, 0xa0, 0xb9, 0x40, 0x76, 0x06, 0x03 ; 4DD0
	.db 0x07, 0xd9, 0xb9, 0x40, 0x76, 0xff, 0xd7, 0x4d, 0x02, 0x03, 0x1e, 0xd7, 0xb0, 0x40, 0x76, 0x02 ; 4DE0
	.db 0x00, 0x0c, 0x00, 0xae, 0xe0, 0x74, 0x01, 0x04, 0x0c, 0xcd, 0xac, 0xc0, 0x75, 0x01, 0x00, 0x0c ; 4DF0
	.db 0x64, 0xac, 0xa0, 0x75, 0x02, 0x03, 0x1e, 0xa0, 0xb0, 0x40, 0x76, 0x02, 0x00, 0x0c, 0x22, 0xae ; 4E00
	.db 0xe0, 0x74, 0x01, 0x04, 0x0c, 0x32, 0xad, 0xc0, 0x75, 0x01, 0x00, 0x0c, 0x87, 0xac, 0xa0, 0x75 ; 4E10
	.db 0x02, 0x03, 0x1e, 0xd7, 0xb0, 0x40, 0x76, 0x02, 0x00, 0x0c, 0x00, 0xae, 0xe0, 0x74, 0x01, 0x04 ; 4E20
	.db 0x0c, 0x9a, 0xad, 0xc0, 0x75, 0x01, 0x00, 0x0c, 0xaa, 0xac, 0xa0, 0x75, 0x02, 0x03, 0x1e, 0xa0 ; 4E30
	.db 0xb0, 0x40, 0x76, 0x02, 0x00, 0x0c, 0x22, 0xae, 0xe0, 0x74, 0x01, 0x04, 0x0c, 0xcd, 0xac, 0xc0 ; 4E40
	.db 0x75, 0x01, 0x00, 0x0c, 0x64, 0xac, 0xa0, 0x75, 0x02, 0x03, 0x1e, 0xd7, 0xb0, 0x40, 0x76, 0x02 ; 4E50
	.db 0x00, 0x0c, 0x00, 0xae, 0xe0, 0x74, 0x01, 0x04, 0x0c, 0x32, 0xad, 0xc0, 0x75, 0x01, 0x00, 0x0c ; 4E60
	.db 0x87, 0xac, 0xa0, 0x75, 0x02, 0x03, 0x1e, 0xa0, 0xb0, 0x40, 0x76, 0x02, 0x00, 0x0c, 0x22, 0xae ; 4E70
	.db 0xe0, 0x74, 0x01, 0x04, 0x0c, 0x9a, 0xad, 0xc0, 0x75, 0x01, 0x00, 0x0c, 0xaa, 0xac, 0xa0, 0x75 ; 4E80
	.db 0xff, 0xe8, 0x4d, 0x03, 0x01, 0x0d, 0x54, 0x9b, 0xc0, 0x75, 0x03, 0x03, 0x1e, 0xa0, 0xb0, 0x60 ; 4E90
	.db 0x76, 0x03, 0x01, 0x0d, 0xe6, 0x9b, 0xc0, 0x75, 0x03, 0x03, 0x1e, 0xd7, 0xb0, 0x60, 0x76, 0xff ; 4EA0
	.db 0x93, 0x4e, 0x02, 0x05, 0x0d, 0x67, 0x9c, 0x60, 0x76, 0x02, 0x05, 0x0d, 0x1b, 0x9d, 0x60, 0x76 ; 4EB0
	.db 0x02, 0x03, 0x1e, 0xd7, 0xb0, 0xe0, 0x73, 0x02, 0x05, 0x0d, 0xbe, 0x9d, 0x60, 0x76, 0x02, 0x05 ; 4EC0
	.db 0x0d, 0x1b, 0x9d, 0x60, 0x76, 0x02, 0x03, 0x1e, 0xa0, 0xb0, 0xe0, 0x73, 0xff, 0xb2, 0x4e, 0x06 ; 4ED0
	.db 0x03, 0x1e, 0xa0, 0xb0, 0xe0, 0x75, 0x06, 0x03, 0x1e, 0xd7, 0xb0, 0xe0, 0x75, 0xff, 0xdf, 0x4e ; 4EE0
	.db 0x06, 0x03, 0x1e, 0xa0, 0xb0, 0x20, 0x76, 0x06, 0x03, 0x1e, 0xd7, 0xb0, 0x20, 0x76, 0xff, 0xf0 ; 4EF0
	.db 0x4e                        ; 4F00
jt_4F01:
	.dw loc_5008                    ; 4F01
	.dw loc_5008                    ; 4F03
	.dw loc_5008                    ; 4F05
	.dw loc_5008                    ; 4F07
	.dw loc_5008                    ; 4F09
	.dw loc_5008                    ; 4F0B
	.dw loc_5008                    ; 4F0D
	.dw loc_4FBF                    ; 4F0F
	.dw loc_5008                    ; 4F11
	.dw loc_5008                    ; 4F13
	.dw loc_5008                    ; 4F15
	.dw loc_5008                    ; 4F17
	.dw loc_5008                    ; 4F19
	.dw loc_4FE4                    ; 4F1B
	.dw loc_4FE4                    ; 4F1D
	.dw loc_5008                    ; 4F1F
	.dw loc_5008                    ; 4F21
	.dw loc_5008                    ; 4F23
	.dw loc_5008                    ; 4F25
	.dw loc_5008                    ; 4F27
	.dw loc_5008                    ; 4F29
	.dw loc_5008                    ; 4F2B
	.dw loc_5008                    ; 4F2D
	.dw loc_5008                    ; 4F2F
	.dw loc_5008                    ; 4F31
	.dw loc_5008                    ; 4F33
	.dw loc_5008                    ; 4F35
	.dw loc_5008                    ; 4F37
	.dw loc_5008                    ; 4F39
	.dw loc_5008                    ; 4F3B
	.dw loc_5008                    ; 4F3D
	.dw loc_5008                    ; 4F3F
	.dw loc_5008                    ; 4F41
	.dw loc_5008                    ; 4F43
	.dw loc_5008                    ; 4F45
	.dw loc_5008                    ; 4F47
	.dw loc_5008                    ; 4F49
	.dw loc_4FA8                    ; 4F4B
	.dw loc_5008                    ; 4F4D
	.dw loc_5008                    ; 4F4F
	.dw loc_5008                    ; 4F51
	.dw loc_5008                    ; 4F53
	.dw loc_4F91                    ; 4F55
	.dw loc_4F91                    ; 4F57
	.dw loc_4F91                    ; 4F59
	.dw loc_5008                    ; 4F5B
	.dw loc_5008                    ; 4F5D
	.dw loc_5008                    ; 4F5F
	.dw loc_5008                    ; 4F61
	.dw loc_5008                    ; 4F63
	.dw loc_4F75                    ; 4F65
	.dw loc_5008                    ; 4F67
	.dw loc_5008                    ; 4F69
	.dw loc_5008                    ; 4F6B
	.dw loc_5008                    ; 4F6D
	.dw loc_4F8C                    ; 4F6F
	.dw loc_4F75                    ; 4F71
	.dw loc_5008                    ; 4F73
loc_4F75:
	ld a,#0x14                      ; 4F75
	ld (bank_slot2_shadow),a        ; 4F77
	ld (MAPPER_SLOT2),a             ; 4F7A  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b20_B13E            ; 4F7D
	ld de,#data_78C0                ; 4F80
	ld bc,#0x1240                   ; 4F83
	di                              ; 4F86
	call sub_45CA                   ; 4F87
	ei                              ; 4F8A
	ret                             ; 4F8B
loc_4F8C:
	ld a,#0xff                      ; 4F8C
	ld (event_C1B2),a                 ; 4F8E
loc_4F91:
	ld a,#0x14                      ; 4F91
	ld (bank_slot2_shadow),a        ; 4F93
	ld (MAPPER_SLOT2),a             ; 4F96  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b20_A83E            ; 4F99
	ld de,#data_78C0                ; 4F9C
	ld bc,#0x1240                   ; 4F9F
	di                              ; 4FA2
	call sub_45CA                   ; 4FA3
	ei                              ; 4FA6
	ret                             ; 4FA7
loc_4FA8:
	ld a,#0x14                      ; 4FA8
	ld (bank_slot2_shadow),a        ; 4FAA
	ld (MAPPER_SLOT2),a             ; 4FAD  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b20_ACBE            ; 4FB0
	ld de,#data_78C0                ; 4FB3
	ld bc,#0x1240                   ; 4FB6
	di                              ; 4FB9
	call sub_45CA                   ; 4FBA
	ei                              ; 4FBD
	ret                             ; 4FBE
loc_4FBF:
	ld a,#0x13                      ; 4FBF
	ld (bank_slot2_shadow),a        ; 4FC1
	ld (MAPPER_SLOT2),a             ; 4FC4  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b19_82D5            ; 4FC7
	ld de,#data_7940                ; 4FCA
	ld bc,#0x0440                   ; 4FCD
	di                              ; 4FD0
	call sub_45CA                   ; 4FD1
	ei                              ; 4FD4
	ld hl,#sub_5009                 ; 4FD5
	ld de,#data_7A74                ; 4FD8
	ld bc,#0x0108                   ; 4FDB
	di                              ; 4FDE
	call sub_45CA                   ; 4FDF
	ei                              ; 4FE2
	ret                             ; 4FE3
loc_4FE4:
	ld a,#0x13                      ; 4FE4
	ld (bank_slot2_shadow),a        ; 4FE6
	ld (MAPPER_SLOT2),a             ; 4FE9  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b19_9ABB            ; 4FEC
	ld de,#data_78C0                ; 4FEF
	ld bc,#0x040c                   ; 4FF2
	di                              ; 4FF5
	call sub_45CA                   ; 4FF6
	ei                              ; 4FF9
	ld hl,#data_b19_99EB            ; 4FFA
	ld de,#data_78CC                ; 4FFD
data_5000::
	ld bc,#0x0434                   ; 5000
	di                              ; 5003
	call sub_45CA                   ; 5004
	ei                              ; 5007
loc_5008:
	ret                             ; 5008

;; ---------------------------------------------------------------- $05009
;; classement : preparation par scene (table $4F01 indexee par $C014)
	.area _B01_5009
sub_5009:
	nop                             ; 5009
	ld bc,#0x0100                   ; 500A
	nop                             ; 500D
	ld bc,#0x0100                   ; 500E

;; ---------------------------------------------------------------- $05011
;; classement : atteinte uniquement par task3
	.area _B01_5011
sub_5011:
	ld a,#0x02                      ; 5011
	ld (bank_slot2_shadow),a        ; 5013
	ld (MAPPER_SLOT2),a             ; 5016  mapper : banque du slot 2 ($8000-$BFFF)
	call sub_b02_AD79               ; 5019
	jr nz,loc_5023                  ; 501C
	call sub_170C                   ; 501E
	jr loc_5026                     ; 5021
loc_5023:
	call sub_1725                   ; 5023
loc_5026:
	ld a,#0x12                      ; 5026
	ld (bank_slot2_shadow),a        ; 5028
	ld (MAPPER_SLOT2),a             ; 502B  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(scene_id)                ; 502E
	ld h,#0x00                      ; 5031
	add hl,hl                       ; 5033
	ld de,#data_b18_B07A            ; 5034
	add hl,de                       ; 5037
	ld e,(hl)                       ; 5038
	inc hl                          ; 5039
	ld d,(hl)                       ; 503A
	ex de,hl                        ; 503B
	call sub_44CA                   ; 503C
	ld hl,#level_map                ; 503F
	ld de,#flow_CF28                 ; 5042
	ld (hl),#0x00                   ; 5045
	ld bc,#0x05aa                   ; 5047
	ldir                            ; 504A
	call sub_56E8                   ; 504C
	call sub_5714                   ; 504F
	call sub_5730                   ; 5052
	call sub_5ABE                   ; 5055
	ld a,#0x0c                      ; 5058
	ld (bank_slot2_shadow),a        ; 505A
	ld (MAPPER_SLOT2),a             ; 505D  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b12_AE7D            ; 5060
	ld de,#VDP_VRAM_WRITE|0x0540    ; 5063
	call sub_46A1                   ; 5066
	ld de,#data_4C88                ; 5069
	ld hl,(scene_id)                ; 506C
	call sub_5190                   ; 506F
	call sub_513F                   ; 5072
	call sub_518A                   ; 5075
	call sub_5101                   ; 5078
	call sub_5124                   ; 507B
	call sub_48DA                   ; 507E
	call sub_47D8                   ; 5081
	xor a                           ; 5084
	ld (level_C0C5),a                 ; 5085
	ld a,#0x02                      ; 5088
	ld (bank_slot2_shadow),a        ; 508A
	ld (MAPPER_SLOT2),a             ; 508D  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(scene_id)                ; 5090
	ld h,#0x00                      ; 5093
	ld de,#data_b02_ADEC            ; 5095
	add hl,hl                       ; 5098
	add hl,de                       ; 5099
	ld e,(hl)                       ; 509A
	inc hl                          ; 509B
	ld d,(hl)                       ; 509C
	ld (pal_anim_bg_ptr),de         ; 509D
	xor a                           ; 50A1
	ld (level_C0C6),a                 ; 50A2
	ld hl,#0x0000                   ; 50A5
	ld (pal_anim_spr_ptr),hl        ; 50A8
	xor a                           ; 50AB
	ld (level_C188),a                 ; 50AC
	ld a,#0x17                      ; 50AF
	ld (bank_slot2_shadow),a        ; 50B1
	ld (MAPPER_SLOT2),a             ; 50B4  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(scene_id)                ; 50B7
	ld h,#0x00                      ; 50BA
	ld de,#data_4BA0                ; 50BC
	add hl,hl                       ; 50BF
	add hl,de                       ; 50C0
	ld e,(hl)                       ; 50C1
	inc hl                          ; 50C2
	ld d,(hl)                       ; 50C3
	ld (tile_anim_ptr),de           ; 50C4
	ld a,(player_state)             ; 50C8
	cp #0xfd                        ; 50CB
	jr nz,loc_50D4                  ; 50CD
	call sub_19B7                   ; 50CF
	jr loc_50DE                     ; 50D2
loc_50D4:
	call sub_512D                   ; 50D4
	ld a,(player_C1F2)                 ; 50D7
	or a                            ; 50DA
	call nz,sub_1F2B                ; 50DB
loc_50DE:
	ld a,#0x0c                      ; 50DE
	ld (bank_slot2_shadow),a        ; 50E0
	ld (MAPPER_SLOT2),a             ; 50E3  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b12_9220            ; 50E6
	ld de,#VDP_VRAM_WRITE|0x0960    ; 50E9
	call sub_46A1                   ; 50EC
	ld a,#0x07                      ; 50EF
	ld (bank_slot2_shadow),a        ; 50F1
	ld (MAPPER_SLOT2),a             ; 50F4  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b07_BA1F            ; 50F7
	ld de,#VDP_VRAM_WRITE|0x0240    ; 50FA
	call sub_46A1                   ; 50FD
	ret                             ; 5100

;; ---------------------------------------------------------------- $05101
;; classement : atteinte uniquement par task3
	.area _B01_5101
sub_5101:
	ld a,#0x12                      ; 5101
	ld (bank_slot2_shadow),a        ; 5103
	ld (MAPPER_SLOT2),a             ; 5106  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(scene_id)                ; 5109
	ld h,#0x00                      ; 510C
	add hl,hl                       ; 510E
	add hl,hl                       ; 510F
	ld de,#data_b18_B332            ; 5110
	add hl,de                       ; 5113
	ld e,(hl)                       ; 5114
	inc hl                          ; 5115
	ld d,(hl)                       ; 5116
	inc hl                          ; 5117
	ld c,(hl)                       ; 5118
	inc hl                          ; 5119
	ld b,(hl)                       ; 511A
	ld (util_C19A),de                ; 511B
	ld (level_C19C),bc                ; 511F
	ret                             ; 5123

;; ---------------------------------------------------------------- $05124
;; classement : atteinte uniquement par task3
	.area _B01_5124
sub_5124:
	ld a,#0x03                      ; 5124
	ld (vdp_requests2),a            ; 5126
	call task_yield                 ; 5129
	ret                             ; 512C

;; ---------------------------------------------------------------- $0512D
;; classement : atteinte uniquement par task3
	.area _B01_512D
sub_512D:
	ld a,#0x07                      ; 512D
	ld (bank_slot2_shadow),a        ; 512F
	ld (MAPPER_SLOT2),a             ; 5132  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b07_B84E            ; 5135
	ld de,#VDP_VRAM_WRITE|0x0280    ; 5138
	call sub_46A1                   ; 513B
	ret                             ; 513E

;; ---------------------------------------------------------------- $0513F
;; classement : atteinte uniquement par task3
	.area _B01_513F
sub_513F:
	ld de,#data_b12_9E65            ; 513F
	ld hl,#data_b12_9DF1            ; 5142
	ld a,#0x02                      ; 5145
	ld (bank_slot2_shadow),a        ; 5147
	ld (MAPPER_SLOT2),a             ; 514A  mapper : banque du slot 2 ($8000-$BFFF)
	push hl                         ; 514D
	ld hl,(scene_id)                ; 514E
	ld h,#0x00                      ; 5151
	add hl,hl                       ; 5153
	add hl,de                       ; 5154
	ld e,(hl)                       ; 5155
	inc hl                          ; 5156
	ld d,(hl)                       ; 5157
	ex de,hl                        ; 5158
	push hl                         ; 5159
	ld de,#pal_C05A                 ; 515A
	ld bc,#0x0020                   ; 515D
	ldir                            ; 5160
	pop hl                          ; 5162
	ld de,#0xc01a                   ; 5163
	ld bc,#0x0020                   ; 5166
	ldir                            ; 5169
	ld hl,(scene_id)                ; 516B
	ld h,#0x00                      ; 516E
	add hl,hl                       ; 5170
	pop de                          ; 5171
	add hl,de                       ; 5172
	ld e,(hl)                       ; 5173
	inc hl                          ; 5174
	ld d,(hl)                       ; 5175
	ex de,hl                        ; 5176
	push hl                         ; 5177
	ld de,#event_C07A                 ; 5178
	ld bc,#0x0020                   ; 517B
	ldir                            ; 517E
	pop hl                          ; 5180
	ld de,#0xc03a                   ; 5181
	ld bc,#0x0020                   ; 5184
	ldir                            ; 5187
	ret                             ; 5189

;; ---------------------------------------------------------------- $0518A
;; classement : atteinte uniquement par task3
	.area _B01_518A
sub_518A:
	ld de,#data_4C14                ; 518A
	ld hl,(scene_id)                ; 518D

;; ---------------------------------------------------------------- $05190
;; classement : atteinte uniquement par task3
	.area _B01_5190
sub_5190:
	ld h,#0x00                      ; 5190
	add hl,hl                       ; 5192
	add hl,de                       ; 5193
	ld e,(hl)                       ; 5194
	inc hl                          ; 5195
	ld d,(hl)                       ; 5196
	ex de,hl                        ; 5197

;; ---------------------------------------------------------------- $05198
;; classement : chargement de donnees de niveau
	.area _B01_5198
sub_5198::
	ld e,(hl)                       ; 5198
	inc hl                          ; 5199
	ld d,(hl)                       ; 519A
	inc hl                          ; 519B
	ld a,e                          ; 519C
	and d                           ; 519D
	cp #0xff                        ; 519E
	ret z                           ; 51A0
	push de                         ; 51A1
	ld c,(hl)                       ; 51A2
	inc hl                          ; 51A3
	ld b,(hl)                       ; 51A4
	inc hl                          ; 51A5
	ld a,(hl)                       ; 51A6
	inc hl                          ; 51A7
	ex de,hl                        ; 51A8
	pop hl                          ; 51A9
	push de                         ; 51AA
	push bc                         ; 51AB
	pop de                          ; 51AC
	ld a,a                          ; 51AD
	ld (bank_slot2_shadow),a        ; 51AE
	ld (MAPPER_SLOT2),a             ; 51B1  mapper : banque du slot 2 ($8000-$BFFF)
	push hl                         ; 51B4
	pop bc                          ; 51B5
	pop hl                          ; 51B6
	ld a,(hl)                       ; 51B7
	inc hl                          ; 51B8
	push hl                         ; 51B9
	push bc                         ; 51BA
	pop hl                          ; 51BB
	or a                            ; 51BC
	jr nz,loc_51C4                  ; 51BD
	call sub_46A1                   ; 51BF
	jr loc_51C7                     ; 51C2
loc_51C4:
	call sub_46E3                   ; 51C4
loc_51C7:
	pop hl                          ; 51C7
	jr sub_5198                     ; 51C8
data_51CA:
	.db 0xf7, 0x9e, 0x00, 0x60, 0x08, 0x00 ; 51CA
	.db 0xff, 0xff                  ; 51D0
data_51D2:
	.db 0x00, 0x80, 0x00, 0x5f, 0x08, 0x00, 0xff, 0xff ; 51D2
data_51DA:
	.db 0xba, 0x94, 0xc0, 0x5f, 0x06, 0x00 ; 51DA
	.db 0xff, 0xff                  ; 51E0
data_51E2:
	.db 0x0d, 0x95, 0x00, 0x60, 0x0f, 0x00, 0xff, 0xff ; 51E2
data_51EA:
	.db 0x00, 0x80, 0x00, 0x60, 0x0f, 0x00 ; 51EA
	.db 0xff, 0xff                  ; 51F0
data_51F2:
	.db 0xe1, 0x94, 0x00, 0x60, 0x0d, 0x00, 0xff, 0xff ; 51F2
data_51FA:
	.db 0x4f, 0xa4, 0x60, 0x5d, 0x0f, 0x00 ; 51FA
	.db 0xff, 0xff                  ; 5200
data_5202:
	.db 0xbc, 0x9d, 0x00, 0x60, 0x0f, 0x00, 0xff, 0xff ; 5202
data_520A:
	.db 0xdf, 0xb2, 0x00, 0x60, 0x08, 0x00 ; 520A
	.db 0xff, 0xff                  ; 5210
data_5212:
	.db 0x74, 0xa6, 0x80, 0x5f, 0x06, 0x00, 0xff, 0xff ; 5212
data_521A:
	.db 0x00, 0x80, 0x60, 0x5e, 0x0d, 0x00 ; 521A
	.db 0xff, 0xff                  ; 5220
data_5222:
	.db 0xbd, 0x8f, 0x00, 0x60, 0x08, 0x00, 0xff, 0xff ; 5222
data_522A:
	.db 0x2e, 0xb6, 0x00, 0x60, 0x0d, 0x00 ; 522A
	.db 0xff, 0xff                  ; 5230
data_5232:
	.db 0xc6, 0xab, 0x00, 0x60, 0x0d, 0x00, 0xff, 0xff ; 5232
data_523A:
	.db 0x5b, 0x9e, 0x00, 0x4e, 0x0d, 0x00 ; 523A
	.db 0x84, 0xa9, 0x00, 0x54, 0x0d, 0x00, 0xff, 0xff ; 5240
data_5248:
	.db 0xb8, 0xb2, 0x80, 0x45, 0x1e, 0x00, 0x20, 0xbf ; 5248
	.db 0x00, 0x4c, 0x0c, 0x00, 0x5b, 0x9e, 0x00, 0x4e, 0x0d, 0x00, 0x3f, 0xa5, 0xc0, 0x54, 0x0d, 0x00 ; 5250
	.db 0x22, 0xab, 0x20, 0x5e, 0x0c, 0x00, 0x75, 0x93, 0xe0, 0x48, 0x0c, 0x00, 0xdf, 0x93, 0x60, 0x4d ; 5260
	.db 0x0c, 0x00, 0xff, 0xff, 0xff, 0xff ; 5270
data_5276:
	.db 0xb8, 0xb2, 0x80, 0x45, 0x1e, 0x00, 0x20, 0xbf, 0x00, 0x4c ; 5276
	.db 0x0c, 0x00, 0x5b, 0x9e, 0x00, 0x4e, 0x0d, 0x00, 0x6c, 0xa4, 0xc0, 0x54, 0x0d, 0x00, 0x77, 0xae ; 5280
	.db 0x20, 0x56, 0x17, 0x00, 0x08, 0xaf, 0x80, 0x57, 0x17, 0x00, 0xff, 0xff ; 5290
data_529C:
	.db 0x22, 0xab, 0x20, 0x5e      ; 529C
	.db 0x0c, 0x00, 0x9b, 0xa8, 0x00, 0x4e, 0x12, 0x00, 0x6c, 0xa4, 0xc0, 0x54, 0x0d, 0x00, 0x77, 0xae ; 52A0
	.db 0x20, 0x56, 0x17, 0x00, 0x08, 0xaf, 0x80, 0x57, 0x17, 0x00, 0xff, 0xff ; 52B0
data_52BC:
	.db 0xb8, 0xb2, 0x80, 0x45      ; 52BC
	.db 0x1e, 0x00, 0x44, 0xae, 0x00, 0x4c, 0x0c, 0x00, 0x15, 0x8e, 0x00, 0x4e, 0x12, 0x00, 0x77, 0x96 ; 52C0
	.db 0x20, 0x59, 0x12, 0x00, 0x22, 0xab, 0x20, 0x5e, 0x0c, 0x00, 0xdf, 0x93, 0x60, 0x4d, 0x0c, 0x00 ; 52D0
	.db 0xff, 0xff                  ; 52E0
data_52E2:
	.db 0xb8, 0xb2, 0x80, 0x45, 0x1e, 0x00, 0x44, 0xae, 0x00, 0x4c, 0x0c, 0x00, 0x8f, 0x97 ; 52E2
	.db 0x00, 0x4e, 0x12, 0x00, 0x3d, 0xa8, 0x20, 0x4b, 0x12, 0x00, 0x7f, 0xa8, 0xe0, 0x48, 0x12, 0x00 ; 52F0
	.db 0x22, 0xab, 0x20, 0x5e, 0x0c, 0x00, 0xff, 0xff ; 5300
data_5308:
	.db 0xb8, 0xb2, 0x80, 0x45, 0x1e, 0x00, 0xf3, 0xbe ; 5308
	.db 0x00, 0x4c, 0x0c, 0x00, 0xd8, 0x82, 0x00, 0x4e, 0x12, 0x00, 0x22, 0xab, 0x20, 0x5e, 0x0c, 0x00 ; 5310
	.db 0x75, 0x93, 0xe0, 0x48, 0x0c, 0x00, 0xdf, 0x93, 0x60, 0x4d, 0x0c, 0x00, 0xff, 0xff ; 5320
data_532E:
	.db 0xb8, 0xb2                  ; 532E
	.db 0x80, 0x45, 0x1e, 0x00, 0x44, 0xae, 0x00, 0x4c, 0x0c, 0x00, 0xdf, 0x93, 0x60, 0x4d, 0x0c, 0x00 ; 5330
	.db 0x0c, 0x94, 0x00, 0x4e, 0x0c, 0x00, 0xf6, 0x9e, 0x00, 0x5a, 0x0c, 0x00, 0x22, 0xab, 0x20, 0x5e ; 5340
	.db 0x0c, 0x00, 0x75, 0x93, 0xe0, 0x48, 0x0c, 0x00, 0xff, 0xff ; 5350
data_535A:
	.db 0xf4, 0xba, 0x20, 0x4b, 0x1e, 0x00 ; 535A
	.db 0x7e, 0xa7, 0x20, 0x4d, 0x0c, 0x00, 0xa8, 0xa4, 0xc0, 0x51, 0x0c, 0x00, 0x76, 0x9f, 0x00, 0x56 ; 5360
	.db 0x0c, 0x00, 0xb6, 0xb1, 0x60, 0x55, 0x0c, 0x00, 0xf8, 0xba, 0x80, 0x5a, 0x07, 0x00, 0x55, 0xba ; 5370
	.db 0x00, 0x5c, 0x07, 0x00, 0x37, 0xbc, 0xe0, 0x54, 0x07, 0x00, 0xff, 0xff ; 5380
data_538C:
	.db 0xf4, 0xba, 0x20, 0x4b      ; 538C
	.db 0x1e, 0x00, 0xbe, 0xa8, 0xa0, 0x4c, 0x07, 0x00, 0x7e, 0xa7, 0x20, 0x4d, 0x0c, 0x00, 0xa8, 0xa4 ; 5390
	.db 0xc0, 0x51, 0x0c, 0x00, 0x06, 0xa3, 0x00, 0x5d, 0x0c, 0x00, 0xeb, 0xa8, 0x20, 0x4f, 0x0c, 0x00 ; 53A0
	.db 0x37, 0xbc, 0xe0, 0x54, 0x07, 0x00, 0xff, 0xff ; 53B0
data_53B8:
	.db 0x75, 0x93, 0x20, 0x4d, 0x0c, 0x00, 0xb6, 0xa2 ; 53B8
	.db 0x00, 0x4e, 0x12, 0x00, 0xff, 0xff ; 53C0
data_53C6:
	.db 0xb8, 0xb2, 0x80, 0x45, 0x1e, 0x00, 0x44, 0xae, 0x00, 0x4c ; 53C6
	.db 0x0c, 0x00, 0xdf, 0x93, 0x60, 0x4d, 0x0c, 0x00, 0x75, 0x93, 0xe0, 0x48, 0x0c, 0x00, 0xb6, 0xa2 ; 53D0
	.db 0x00, 0x4e, 0x12, 0x00, 0xff, 0xff ; 53E0
data_53E6:
	.db 0xf1, 0xbd, 0x80, 0x57, 0x0c, 0x00, 0xff, 0xff ; 53E6
data_53EE:
	.db 0x56, 0xa8                  ; 53EE
	.db 0xa0, 0x4c, 0x07, 0x00      ; 53F0
data_53F4:
	.db 0xf4, 0xba, 0x20, 0x4b, 0x1e, 0x00, 0x7e, 0xa7, 0x20, 0x4d, 0x0c, 0x00 ; 53F4
	.db 0x5a, 0xbb, 0x20, 0x4f, 0x1f, 0x00, 0xa8, 0xa4, 0xc0, 0x51, 0x0c, 0x00, 0x2b, 0xbd, 0xe0, 0x54 ; 5400
	.db 0x1f, 0x00, 0xf1, 0xbd, 0x80, 0x57, 0x0c, 0x00, 0xa7, 0xba, 0x80, 0x58, 0x1f, 0x00, 0x4b, 0xb7 ; 5410
	.db 0x80, 0x59, 0x0d, 0x00, 0xef, 0xad, 0x00, 0x5a, 0x1f, 0x00, 0xff, 0xff ; 5420
data_542C:
	.db 0xec, 0xa7, 0xa0, 0x4c      ; 542C
	.db 0x07, 0x00, 0xf4, 0xba, 0x20, 0x4b, 0x1e, 0x00, 0x7e, 0xa7, 0x20, 0x4d, 0x0c, 0x00, 0x5a, 0xbb ; 5430
	.db 0x20, 0x4f, 0x1f, 0x00, 0xa8, 0xa4, 0xc0, 0x51, 0x0c, 0x00, 0x2b, 0xbd, 0xe0, 0x54, 0x1f, 0x00 ; 5440
	.db 0xf1, 0xbd, 0x80, 0x57, 0x0c, 0x00, 0xa7, 0xba, 0x80, 0x58, 0x1f, 0x00, 0xe7, 0xba, 0x80, 0x59 ; 5450
	.db 0x1f, 0x00, 0xef, 0xad, 0x00, 0x5a, 0x1f, 0x00, 0xff, 0xff ; 5460
data_546A:
	.db 0x5a, 0xbb, 0x20, 0x4f, 0x1f, 0x00 ; 546A
	.db 0x2b, 0xbd, 0xe0, 0x54, 0x1f, 0x00, 0xdd, 0x8d, 0x00, 0x5a, 0x12, 0x00, 0xff, 0xff ; 5470
data_547E:
	.db 0xb8, 0xb2                  ; 547E
	.db 0x80, 0x45, 0x1e, 0x00, 0x44, 0xae, 0x00, 0x4c, 0x0c, 0x00, 0xb1, 0xb7, 0x00, 0x4e, 0x0d, 0x00 ; 5480
	.db 0x22, 0xab, 0x20, 0x5e, 0x0c, 0x00, 0x75, 0x93, 0xe0, 0x48, 0x0c, 0x00, 0xdf, 0x93, 0x60, 0x4d ; 5490
	.db 0x0c, 0x00, 0xff, 0xff      ; 54A0
data_54A4:
	.db 0xb8, 0xb2, 0x80, 0x45, 0x1e, 0x00, 0x44, 0xae, 0x00, 0x4c, 0x0c, 0x00 ; 54A4
	.db 0xaa, 0xb9, 0x00, 0x4e, 0x0f, 0x00, 0x22, 0xab, 0x20, 0x5e, 0x0c, 0x00, 0x75, 0x93, 0xe0, 0x48 ; 54B0
	.db 0x0c, 0x00, 0xff, 0xff, 0xff, 0xff ; 54C0
data_54C6:
	.db 0x92, 0xa9, 0xa0, 0x4c, 0x07, 0x00, 0xf4, 0xba, 0x20, 0x4b ; 54C6
	.db 0x1e, 0x00, 0x7e, 0xa7, 0x20, 0x4d, 0x0c, 0x00, 0x20, 0xb2, 0x00, 0x50, 0x0c, 0x00, 0xa8, 0xa4 ; 54D0
	.db 0xc0, 0x51, 0x0c, 0x00, 0x37, 0xbc, 0xe0, 0x54, 0x07, 0x00, 0x19, 0xbd, 0x60, 0x55, 0x0c, 0x00 ; 54E0
	.db 0xef, 0xad, 0x20, 0x57, 0x1f, 0x00, 0x09, 0xb3, 0x80, 0x5a, 0x0c, 0x00, 0x06, 0xa3, 0x00, 0x5d ; 54F0
	.db 0x0c, 0x00, 0xff, 0xff      ; 5500
data_5504:
	.db 0xf9, 0xb0, 0x00, 0x4e, 0x1f, 0x00, 0xff, 0xff ; 5504
data_550C:
	.db 0xb8, 0xb2, 0x80, 0x45      ; 550C
	.db 0x1e, 0x00, 0xae, 0xbe, 0x00, 0x4c, 0x0c, 0x00, 0xdf, 0x93, 0x60, 0x4d, 0x0c, 0x00, 0xf9, 0xb0 ; 5510
	.db 0x00, 0x4e, 0x1f, 0x00, 0xae, 0xb7, 0x40, 0x57, 0x1f, 0x00, 0x22, 0xab, 0x20, 0x5e, 0x0c, 0x00 ; 5520
	.db 0x75, 0x93, 0xe0, 0x48, 0x0c, 0x00, 0xff, 0xff ; 5530
data_5538:
	.db 0x28, 0xa9, 0xa0, 0x4c, 0x07, 0x00, 0xf4, 0xba ; 5538
	.db 0x20, 0x4b, 0x1e, 0x00, 0x7e, 0xa7, 0x20, 0x4d, 0x0c, 0x00, 0xeb, 0xa8, 0x20, 0x4f, 0x0c, 0x00 ; 5540
	.db 0x55, 0xba, 0xc0, 0x51, 0x07, 0x00, 0x1b, 0xb5, 0xc0, 0x53, 0x0c, 0x00, 0x76, 0x9f, 0x00, 0x56 ; 5550
	.db 0x0c, 0x00, 0x09, 0xb3, 0x80, 0x5a, 0x0c, 0x00, 0x20, 0xb2, 0xc0, 0x5c, 0x0c, 0x00, 0xb6, 0xb1 ; 5560
	.db 0xc0, 0x5d, 0x0c, 0x00, 0xff, 0xff ; 5570
data_5576:
	.db 0xf4, 0xba, 0x20, 0x4b, 0x1e, 0x00, 0x60, 0xb7, 0xa0, 0x4c ; 5576
	.db 0x0c, 0x00, 0x5c, 0xba, 0xa0, 0x4f, 0x0c, 0x00, 0x1b, 0xb5, 0xc0, 0x53, 0x0c, 0x00, 0x80, 0xa9 ; 5580
	.db 0x00, 0x56, 0x1f, 0x00, 0x09, 0xb3, 0x80, 0x5a, 0x0c, 0x00, 0x20, 0xb2, 0xc0, 0x5c, 0x0c, 0x00 ; 5590
	.db 0xb6, 0xb1, 0xc0, 0x5d, 0x0c, 0x00, 0xff, 0xff ; 55A0

;; ---------------------------------------------------------------- $056E8
;; classement : atteinte uniquement par task3
	.area _B01_56E8
sub_56E8:
	ld hl,(scene_id)                ; 56E8
	ld e,l                          ; 56EB
	ld h,#0x00                      ; 56EC
	add hl,hl                       ; 56EE
	ld d,#0x00                      ; 56EF
	add hl,de                       ; 56F1
	ld de,#data_4CFC                ; 56F2
	add hl,de                       ; 56F5
	ld a,(hl)                       ; 56F6
	inc hl                          ; 56F7
	ld a,a                          ; 56F8
	ld (bank_slot2_shadow),a        ; 56F9
	ld (MAPPER_SLOT2),a             ; 56FC  mapper : banque du slot 2 ($8000-$BFFF)
	ld e,(hl)                       ; 56FF
	inc hl                          ; 5700
	ld d,(hl)                       ; 5701
	ex de,hl                        ; 5702
	ld de,#level_map                ; 5703
	ld a,(hl)                       ; 5706
	ld (level_CF18),a                 ; 5707
	inc hl                          ; 570A
	ld a,(hl)                       ; 570B
	inc hl                          ; 570C
	ld c,(hl)                       ; 570D
	inc hl                          ; 570E
	ld b,(hl)                       ; 570F
	inc hl                          ; 5710
	ldir                            ; 5711
	ret                             ; 5713

;; ---------------------------------------------------------------- $05714
;; classement : atteinte uniquement par task3
	.area _B01_5714
sub_5714:
	ld a,#0x0a                      ; 5714
	ld (bank_slot2_shadow),a        ; 5716
	ld (MAPPER_SLOT2),a             ; 5719  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(scene_id)                ; 571C
	ld h,#0x00                      ; 571F
	add hl,hl                       ; 5721
	ld de,#data_b10_BC46            ; 5722
	add hl,de                       ; 5725
	ld e,(hl)                       ; 5726
	inc hl                          ; 5727
	ld d,(hl)                       ; 5728
	inc de                          ; 5729
	inc de                          ; 572A
	ld (level_attr_ptr),de          ; 572B
	ret                             ; 572F

;; ---------------------------------------------------------------- $05730
;; classement : atteinte uniquement par task3
	.area _B01_5730
sub_5730:
	ld a,#0x0a                      ; 5730
	ld (bank_slot2_shadow),a        ; 5732
	ld (MAPPER_SLOT2),a             ; 5735  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(scene_id)                ; 5738
	ld h,#0x00                      ; 573B
	add hl,hl                       ; 573D
	ld de,#data_b10_BBD2            ; 573E
	add hl,de                       ; 5741
	ld e,(hl)                       ; 5742
	inc hl                          ; 5743
	ld d,(hl)                       ; 5744
	inc de                          ; 5745
	inc de                          ; 5746
	ld (level_metatile_ptr),de      ; 5747
	ret                             ; 574B

;; ---------------------------------------------------------------- $059C1
;; classement : chargeurs banques 2/23 pilotes par $C014
	.area _B01_59C1
sub_59C1::
	ld a,#0x02                      ; 59C1
	ld (bank_slot2_shadow),a        ; 59C3
	ld (MAPPER_SLOT2),a             ; 59C6  mapper : banque du slot 2 ($8000-$BFFF)
	ld b,#0x1f                      ; 59C9
	xor a                           ; 59CB
	ld hl,#pal_fx_table             ; 59CC
loc_59CF:
	or (hl)                         ; 59CF
	ret nz                          ; 59D0
	inc hl                          ; 59D1
	djnz loc_59CF                   ; 59D2
	ld hl,(pal_anim_bg_ptr)         ; 59D4
	ld a,h                          ; 59D7
	or l                            ; 59D8
	jr z,sub_5A0F                   ; 59D9
	ld a,(level_C0C5)                 ; 59DB
	inc a                           ; 59DE
	ld (level_C0C5),a                 ; 59DF
	cp (hl)                         ; 59E2
	jr nz,sub_5A0F                  ; 59E3
	xor a                           ; 59E5
	ld (level_C0C5),a                 ; 59E6
	inc hl                          ; 59E9
	ld e,(hl)                       ; 59EA
	inc hl                          ; 59EB
	ld d,(hl)                       ; 59EC
	inc hl                          ; 59ED
	ld (pal_anim_bg_ptr),hl         ; 59EE
	ex de,hl                        ; 59F1
	ld de,#0xc01a                   ; 59F2
	ld bc,#0x0020                   ; 59F5
	ldir                            ; 59F8
	ld hl,#vdp_requests2            ; 59FA
	set 6,(hl)                      ; 59FD
	ld hl,(pal_anim_bg_ptr)         ; 59FF
	ld a,(hl)                       ; 5A02
	cp #0xff                        ; 5A03
	jr nz,sub_5A0F                  ; 5A05
	inc hl                          ; 5A07
	ld e,(hl)                       ; 5A08
	inc hl                          ; 5A09
	ld d,(hl)                       ; 5A0A
	ld (pal_anim_bg_ptr),de         ; 5A0B

;; ---------------------------------------------------------------- $05A0F
;; classement : chargeurs banques 2/23 pilotes par $C014
	.area _B01_5A0F
sub_5A0F::
	ld a,#0x02                      ; 5A0F
	ld (bank_slot2_shadow),a        ; 5A11
	ld (MAPPER_SLOT2),a             ; 5A14  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(pal_anim_spr_ptr)        ; 5A17
	ld a,h                          ; 5A1A
	or l                            ; 5A1B
	ret z                           ; 5A1C
	ld a,(level_C0C6)                 ; 5A1D
	inc a                           ; 5A20
	ld (level_C0C6),a                 ; 5A21
	cp (hl)                         ; 5A24
	jr nz,loc_5A51                  ; 5A25
	xor a                           ; 5A27
	ld (level_C0C6),a                 ; 5A28
	inc hl                          ; 5A2B
	ld e,(hl)                       ; 5A2C
	inc hl                          ; 5A2D
	ld d,(hl)                       ; 5A2E
	inc hl                          ; 5A2F
	ld (pal_anim_spr_ptr),hl        ; 5A30
	ex de,hl                        ; 5A33
	ld de,#0xc03a                   ; 5A34
	ld bc,#0x0020                   ; 5A37
	ldir                            ; 5A3A
	ld hl,#vdp_requests2            ; 5A3C
	set 6,(hl)                      ; 5A3F
	ld hl,(pal_anim_spr_ptr)        ; 5A41
	ld a,(hl)                       ; 5A44
	cp #0xff                        ; 5A45
	jr nz,loc_5A51                  ; 5A47
	inc hl                          ; 5A49
	ld e,(hl)                       ; 5A4A
	inc hl                          ; 5A4B
	ld d,(hl)                       ; 5A4C
	ld (pal_anim_spr_ptr),de        ; 5A4D
loc_5A51:
	ret                             ; 5A51

;; ---------------------------------------------------------------- $05A52
;; classement : chargeurs banques 2/23 pilotes par $C014
	.area _B01_5A52
sub_5A52::
	ld hl,(tile_anim_ptr)           ; 5A52
	ld a,h                          ; 5A55
	or l                            ; 5A56
	ret z                           ; 5A57
	ld hl,#vdp_requests             ; 5A58
	ld a,(vdp_requests2)            ; 5A5B
	or (hl)                         ; 5A5E
	bit 4,a                         ; 5A5F
	ret nz                          ; 5A61
	ld a,#0x17                      ; 5A62
	ld (bank_slot2_shadow),a        ; 5A64
	ld (MAPPER_SLOT2),a             ; 5A67  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(tile_anim_ptr)           ; 5A6A
	ld a,(level_C188)                 ; 5A6D
	inc a                           ; 5A70
	ld (level_C188),a                 ; 5A71
	cp (hl)                         ; 5A74
	ret nz                          ; 5A75
	xor a                           ; 5A76
	ld (level_C188),a                 ; 5A77
	inc hl                          ; 5A7A
	ld a,(hl)                       ; 5A7B
	ld (irq_C18B),a                 ; 5A7C
	inc hl                          ; 5A7F
	ld a,(hl)                       ; 5A80
	inc hl                          ; 5A81
	ld e,(hl)                       ; 5A82
	inc hl                          ; 5A83
	ld d,(hl)                       ; 5A84
	ld a,a                          ; 5A85
	ld (bank_slot2_shadow),a        ; 5A86
	ld (MAPPER_SLOT2),a             ; 5A89  mapper : banque du slot 2 ($8000-$BFFF)
	push hl                         ; 5A8C
	ex de,hl                        ; 5A8D
	ld de,#decomp_buffer            ; 5A8E
	call sub_4667                   ; 5A91
	pop hl                          ; 5A94
	ld a,#0x17                      ; 5A95
	ld (bank_slot2_shadow),a        ; 5A97
	ld (MAPPER_SLOT2),a             ; 5A9A  mapper : banque du slot 2 ($8000-$BFFF)
	inc hl                          ; 5A9D
	ld e,(hl)                       ; 5A9E
	inc hl                          ; 5A9F
	ld d,(hl)                       ; 5AA0
	inc hl                          ; 5AA1
	ld (tile_anim_ptr),hl           ; 5AA2
	ld (irq_C189),de                ; 5AA5
	ld hl,#vdp_requests2            ; 5AA9
	set 4,(hl)                      ; 5AAC
	ld hl,(tile_anim_ptr)           ; 5AAE
	ld a,(hl)                       ; 5AB1
	cp #0xff                        ; 5AB2
	ret nz                          ; 5AB4
	inc hl                          ; 5AB5
	ld e,(hl)                       ; 5AB6
	inc hl                          ; 5AB7
	ld d,(hl)                       ; 5AB8
	ld (tile_anim_ptr),de           ; 5AB9
	ret                             ; 5ABD

;; ---------------------------------------------------------------- $05ABE
;; classement : chargeurs banques 2/23 pilotes par $C014
	.area _B01_5ABE
sub_5ABE:
	ld hl,(scene_id)                ; 5ABE
	ld h,#0x00                      ; 5AC1
	add hl,hl                       ; 5AC3
	ld a,#0x19                      ; 5AC4
	ld (bank_slot2_shadow),a        ; 5AC6
	ld (MAPPER_SLOT2),a             ; 5AC9  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b25_BE0B            ; 5ACC
	add hl,de                       ; 5ACF
	ld e,(hl)                       ; 5AD0
	inc hl                          ; 5AD1
	ld d,(hl)                       ; 5AD2
	ld a,e                          ; 5AD3
	or d                            ; 5AD4
	ret z                           ; 5AD5
	push de                         ; 5AD6
	pop ix                          ; 5AD7
loc_5AD9:
	ld a,0(ix)                      ; 5AD9
	cp #0xff                        ; 5ADC
	ret z                           ; 5ADE
	ld hl,#coll_C0D0                 ; 5ADF
	and (hl)                        ; 5AE2
	jr z,loc_5AF5                   ; 5AE3
	ld l,3(ix)                      ; 5AE5
	ld h,4(ix)                      ; 5AE8
	ld a,(hl)                       ; 5AEB
	cp 1(ix)                        ; 5AEC
	jr nz,loc_5AF5                  ; 5AEF
	ld a,2(ix)                      ; 5AF1
	ld (hl),a                       ; 5AF4
loc_5AF5:
	ld de,#0x0005                   ; 5AF5
	add ix,de                       ; 5AF8
	jr loc_5AD9                     ; 5AFA

;; ---------------------------------------------------------------- $05AFC
;; classement : chargeurs banques 2/23 pilotes par $C014
	.area _B01_5AFC
sub_5AFC::
	ret m                           ; 5AFC
	ret m                           ; 5AFD
	ld bc,#0x0f14                   ; 5AFE
	inc d                           ; 5B01
	rst 0x38                        ; 5B02

;; ---------------------------------------------------------------- $0601C
;; classement : atteinte uniquement par task3
	.area _B01_601C
sub_601C:
	ld a,14(iy)                     ; 601C
	or a                            ; 601F
	jr z,loc_6027                   ; 6020
	dec 14(iy)                      ; 6022
	jr loc_602C                     ; 6025
loc_6027:
	ld a,10(iy)                     ; 6027
	or a                            ; 602A
	ret nz                          ; 602B
loc_602C:
	ld a,7(iy)                      ; 602C
	or 22(iy)                       ; 602F
	ret z                           ; 6032
	ld a,22(iy)                     ; 6033
	or a                            ; 6036
	jr z,loc_6065                   ; 6037
	ld 9(iy),#0x00                  ; 6039
	ld 8(iy),#0x00                  ; 603D
	ld 10(iy),#0x00                 ; 6041
	bit 1,14(iy)                    ; 6045
	ld l,22(iy)                     ; 6049
	jr z,loc_6068                   ; 604C
	ld a,0(iy)                      ; 604E
	sub #0x88                       ; 6051
	ld l,a                          ; 6053
	ld h,#0x00                      ; 6054
	ld de,#0x82cf                   ; 6056
	ld a,#0x12                      ; 6059
	ld (bank_slot2_shadow),a        ; 605B
	ld (MAPPER_SLOT2),a             ; 605E  mapper : banque du slot 2 ($8000-$BFFF)
	add hl,de                       ; 6061
	ld l,(hl)                       ; 6062
	jr loc_6068                     ; 6063
loc_6065:
	ld l,7(iy)                      ; 6065
loc_6068:
	ld h,#0x00                      ; 6068
	add hl,hl                       ; 606A
	ld de,#data_b18_8000            ; 606B
	ld a,#0x12                      ; 606E
	ld (bank_slot2_shadow),a        ; 6070
	ld (MAPPER_SLOT2),a             ; 6073  mapper : banque du slot 2 ($8000-$BFFF)
	add hl,de                       ; 6076
	ld e,(hl)                       ; 6077
	inc hl                          ; 6078
	ld d,(hl)                       ; 6079
	push de                         ; 607A
	pop ix                          ; 607B
	ld a,8(iy)                      ; 607D
	or a                            ; 6080
	jr z,loc_608B                   ; 6081
	inc a                           ; 6083
	ld 8(iy),a                      ; 6084
	cp 0(ix)                        ; 6087
	ret c                           ; 608A
loc_608B:
	ld 8(iy),#0x01                  ; 608B
	ld a,9(iy)                      ; 608F
	ld b,a                          ; 6092
	ld a,1(ix)                      ; 6093
	or a                            ; 6096
	jr z,loc_609C                   ; 6097
	cp b                            ; 6099
	jr nc,loc_60B0                  ; 609A
loc_609C:
	ld a,#0x01                      ; 609C
	ld 10(iy),a                     ; 609E
	ld a,2(ix)                      ; 60A1
	ld 9(iy),a                      ; 60A4
	cp 1(ix)                        ; 60A7
	jr z,loc_60B0                   ; 60AA
	xor a                           ; 60AC
	ld 10(iy),a                     ; 60AD
loc_60B0:
	push ix                         ; 60B0
	pop hl                          ; 60B2
	ld de,#0x0004                   ; 60B3
	add hl,de                       ; 60B6
	ld e,3(ix)                      ; 60B7
	ld b,e                          ; 60BA
	ld d,#0x00                      ; 60BB
	ld a,9(iy)                      ; 60BD
loc_60C0:
	or a                            ; 60C0
	jr z,loc_60C7                   ; 60C1
	add hl,de                       ; 60C3
	dec a                           ; 60C4
	jr loc_60C0                     ; 60C5
loc_60C7:
	push bc                         ; 60C7
	push hl                         ; 60C8
	ld l,(hl)                       ; 60C9
	call sub_60D6                   ; 60CA
	pop hl                          ; 60CD
	pop bc                          ; 60CE
	inc hl                          ; 60CF
	djnz loc_60C7                   ; 60D0
	inc 9(iy)                       ; 60D2
	ret                             ; 60D5

;; ---------------------------------------------------------------- $060D6
;; classement : atteinte uniquement par task3
	.area _B01_60D6
sub_60D6:
	ld a,#0x12                      ; 60D6
	ld (bank_slot2_shadow),a        ; 60D8
	ld (MAPPER_SLOT2),a             ; 60DB  mapper : banque du slot 2 ($8000-$BFFF)
	ld h,#0x00                      ; 60DE
	add hl,hl                       ; 60E0
	ld de,#data_b18_803C            ; 60E1
	add hl,de                       ; 60E4
	ld e,(hl)                       ; 60E5
	inc hl                          ; 60E6
	ld d,(hl)                       ; 60E7
	ex de,hl                        ; 60E8
	ld c,(hl)                       ; 60E9
	inc hl                          ; 60EA
	ld b,(hl)                       ; 60EB
	inc hl                          ; 60EC
	push bc                         ; 60ED
	push hl                         ; 60EE
	call sub_6140                   ; 60EF
	pop hl                          ; 60F2
	push hl                         ; 60F3
	ld a,(level_CF18)                 ; 60F4
	call sub_618B                   ; 60F7
	pop hl                          ; 60FA
	pop bc                          ; 60FB
	ld a,3(iy)                      ; 60FC
	or 6(iy)                        ; 60FF
	ret nz                          ; 6102
	push bc                         ; 6103
	ld c,(hl)                       ; 6104
	inc hl                          ; 6105
	ld b,(hl)                       ; 6106
	inc hl                          ; 6107
	push bc                         ; 6108
	ld a,#0x12                      ; 6109
	ld (map_bank),a                 ; 610B
	call sub_499F                   ; 610E
	pop bc                          ; 6111
	pop hl                          ; 6112
	push bc                         ; 6113
	ld a,h                          ; 6114
	call sub_6186                   ; 6115
	ld b,a                          ; 6118
	ld a,31(iy)                     ; 6119
	sub b                           ; 611C
	jr nc,loc_6121                  ; 611D
	sub #0x20                       ; 611F
loc_6121:
	ld (tmp_d3),a                   ; 6121
	ld a,l                          ; 6124
	call sub_6186                   ; 6125
	ld b,a                          ; 6128
	ld a,36(iy)                     ; 6129
	sub b                           ; 612C
	neg                             ; 612D
	ld (dbg_C0D4),a                 ; 612F
	call sub_4ABF                   ; 6132
	ld hl,#util_D4D1                 ; 6135
	pop bc                          ; 6138
	ld a,b                          ; 6139
	add a,a                         ; 613A
	ld b,a                          ; 613B
	call sub_44E4                   ; 613C
	ret                             ; 613F

;; ---------------------------------------------------------------- $06140
;; classement : atteinte uniquement par task3
	.area _B01_6140
sub_6140:
	push bc                         ; 6140
	ld h,#0x00                      ; 6141
	ld l,31(iy)                     ; 6143
	xor a                           ; 6146
	or 32(iy)                       ; 6147
	jr z,loc_6155                   ; 614A
	ld b,32(iy)                     ; 614C
	ld de,#0x00e0                   ; 614F
loc_6152:
	add hl,de                       ; 6152
	djnz loc_6152                   ; 6153
loc_6155:
	ex de,hl                        ; 6155
	call sub_617C                   ; 6156
	pop bc                          ; 6159
	push bc                         ; 615A
	sub b                           ; 615B
	ld e,a                          ; 615C
	ld d,#0x00                      ; 615D
	ld a,(level_CF18)                 ; 615F
	call sub_4B32                   ; 6162
	push hl                         ; 6165
	ld e,36(iy)                     ; 6166
	ld d,37(iy)                     ; 6169
	call sub_617C                   ; 616C
	pop de                          ; 616F
	pop bc                          ; 6170
	sub c                           ; 6171
	ld l,a                          ; 6172
	ld h,#0x00                      ; 6173
	add hl,de                       ; 6175
	ld de,#level_map                ; 6176
	add hl,de                       ; 6179
	ex de,hl                        ; 617A
	ret                             ; 617B

;; ---------------------------------------------------------------- $0617C
;; classement : atteinte uniquement par task3
	.area _B01_617C
sub_617C:
	ld a,e                          ; 617C
	ld hl,#tmp_d3                   ; 617D
	ld (hl),a                       ; 6180
	ld a,d                          ; 6181
	rrd                             ; 6182
	ld a,(hl)                       ; 6184
	ret                             ; 6185

;; ---------------------------------------------------------------- $06186
;; classement : atteinte uniquement par task3
	.area _B01_6186
sub_6186:
	add a,a                         ; 6186
	add a,a                         ; 6187
	add a,a                         ; 6188
	add a,a                         ; 6189
	ret                             ; 618A

;; ---------------------------------------------------------------- $0618B
;; classement : atteinte uniquement par task3
	.area _B01_618B
sub_618B:
	ld c,(hl)                       ; 618B
	srl c                           ; 618C
	inc hl                          ; 618E
	ld b,(hl)                       ; 618F
	inc hl                          ; 6190
loc_6191:
	push bc                         ; 6191
	push de                         ; 6192
	ld b,#0x00                      ; 6193
	ldir                            ; 6195
	pop de                          ; 6197
	pop bc                          ; 6198
	push hl                         ; 6199
	ld l,a                          ; 619A
	ld h,#0x00                      ; 619B
	add hl,de                       ; 619D
	ex de,hl                        ; 619E
	pop hl                          ; 619F
	djnz loc_6191                   ; 61A0
	ret                             ; 61A2

;; ---------------------------------------------------------------- $0AD79
;; classement : atteinte uniquement par task3
	.area _B02_AD79
sub_b02_AD79:
	ld a,(scene_id)                 ; AD79
	ld hl,#sub_b02_AD86             ; AD7C
	call sub_b02_AD90               ; AD7F
	jr nz,loc_b02_ADD4              ; AD82
	jr loc_b02_ADD2                 ; AD84

;; ---------------------------------------------------------------- $0AD86
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_AD86
sub_b02_AD86:
	inc sp                          ; AD86
	add hl,sp                       ; AD87
	scf                             ; AD88
	ld c,#0x24                      ; AD89
	dec h                           ; AD8B
	jr nc,loc_b02_ADC0              ; AD8C
	dec hl                          ; AD8E
	rst 0x38                        ; AD8F

;; ---------------------------------------------------------------- $0AD90
;; classement : atteinte uniquement par task3
	.area _B02_AD90
sub_b02_AD90:
	push bc                         ; AD90
loc_b02_AD91:
	ld b,a                          ; AD91
	ld a,#0xff                      ; AD92
	cp (hl)                         ; AD94
	jr z,loc_b02_ADA3               ; AD95
	ld a,b                          ; AD97
	cp (hl)                         ; AD98
	jr z,loc_b02_AD9E               ; AD99
	inc hl                          ; AD9B
	jr loc_b02_AD91                 ; AD9C
loc_b02_AD9E:
	ld a,#0x01                      ; AD9E
	or a                            ; ADA0
	pop bc                          ; ADA1
	ret                             ; ADA2
loc_b02_ADA3:
	xor a                           ; ADA3
	pop bc                          ; ADA4
	ret                             ; ADA5
