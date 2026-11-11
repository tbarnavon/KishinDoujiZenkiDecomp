;; game/player.s
;; Joueur (taches 1 et 4) : structure $CEEF, etats ($CEEF = etat), controle, tables d'etats.
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $004EC
;; classement : atteinte uniquement par tbl_b02_8000
	.area _B00_04EC
sub_04EC:
	ld a,#0xc3                      ; 04EC
	jp loc_060D                     ; 04EE

;; ---------------------------------------------------------------- $0051E
;; classement : atteinte uniquement par task1
	.area _B00_051E
sub_051E:
	ld a,#0xac                      ; 051E
	jp loc_060D                     ; 0520

;; ---------------------------------------------------------------- $00541
;; classement : atteinte uniquement par task1
	.area _B00_0541
sub_0541::
	ld a,#0x91                      ; 0541
	jp sub_062D                     ; 0543

;; ---------------------------------------------------------------- $0055B
;; classement : atteinte uniquement par task1
	.area _B00_055B
sub_055B:
	ld a,#0xa9                      ; 055B
	jp loc_060D                     ; 055D

;; ---------------------------------------------------------------- $00560
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0560
sub_0560:
	ld a,#0xa6                      ; 0560
	jp loc_0627                     ; 0562

;; ---------------------------------------------------------------- $005FE
;; classement : atteinte uniquement par task1
	.area _B00_05FE
sub_05FE::
	ld a,#0xb1                      ; 05FE
	jp loc_060D                     ; 0600

;; ---------------------------------------------------------------- $00603
;; classement : atteinte uniquement par task1
	.area _B00_0603
sub_0603::
	ld a,#0xa2                      ; 0603
	jp loc_060D                     ; 0605

;; ---------------------------------------------------------------- $018EE
;; classement : atteinte uniquement par task1
	.area _B00_18EE
sub_18EE::
	ld a,0(ix)                      ; 18EE
	ld 27(iy),a                     ; 18F1
	ld a,1(ix)                      ; 18F4
	ld 28(iy),a                     ; 18F7
	ld a,2(ix)                      ; 18FA
	ld 2(iy),a                      ; 18FD
	ld a,3(ix)                      ; 1900
	ld 5(iy),a                      ; 1903
	ld 0(iy),#0x01                  ; 1906
	ld 33(iy),#0x00                 ; 190A
	ld de,#0x0004                   ; 190E
	add ix,de                       ; 1911
	ld de,#0x0028                   ; 1913
	add iy,de                       ; 1916
	djnz sub_18EE                   ; 1918
	ret                             ; 191A

;; ---------------------------------------------------------------- $0191B
;; classement : atteinte uniquement par task1
	.area _B00_191B
sub_191B::
	ld a,0(ix)                      ; 191B
	ld 27(iy),a                     ; 191E
	ld a,1(ix)                      ; 1921
	ld 28(iy),a                     ; 1924
	ld 0(iy),#0x01                  ; 1927
	ld 33(iy),#0x00                 ; 192B
	ld de,#0x0002                   ; 192F
	add ix,de                       ; 1932
	ld de,#0x0028                   ; 1934
	add iy,de                       ; 1937
	djnz sub_191B                   ; 1939
	ret                             ; 193B

;; ---------------------------------------------------------------- $0193C
;; classement : atteinte uniquement par task1
	.area _B00_193C
sub_193C::
	and #0x03                       ; 193C
	add a,a                         ; 193E
	ld l,a                          ; 193F
	ld h,#0x00                      ; 1940
	ld de,#data_179B                ; 1942
	add hl,de                       ; 1945
	ld a,(hl)                       ; 1946
	ld (player_CA41),a                 ; 1947
	inc hl                          ; 194A
	ld a,(hl)                       ; 194B
	ld (player_CA44),a                 ; 194C
	ld hl,#pause_CA3F                 ; 194F
	ld de,#player_CA17                 ; 1952
	ld bc,#0x0028                   ; 1955
	ldir                            ; 1958
	ld a,(player_CA19)                 ; 195A
	add a,#0x20                     ; 195D
	ld (player_CA19),a                 ; 195F
	ret                             ; 1962

;; ---------------------------------------------------------------- $01963
;; classement : atteinte uniquement par task1
	.area _B00_1963
sub_1963::
	call task_yield                 ; 1963
	ld b,#0x06                      ; 1966
	ld iy,#player_CA17                 ; 1968
loc_196C:
	push bc                         ; 196C
	call sub_72B2                   ; 196D
	ld l,1(iy)                      ; 1970
	ld h,2(iy)                      ; 1973
	ld e,16(iy)                     ; 1976
	ld d,17(iy)                     ; 1979
	add hl,de                       ; 197C
	ld 1(iy),l                      ; 197D
	ld 2(iy),h                      ; 1980
	ld l,4(iy)                      ; 1983
	ld h,5(iy)                      ; 1986
	ld e,18(iy)                     ; 1989
	ld d,19(iy)                     ; 198C
	add hl,de                       ; 198F
	ld 4(iy),l                      ; 1990
	ld 5(iy),h                      ; 1993
	ld de,#0x0028                   ; 1996
	add iy,de                       ; 1999
	pop bc                          ; 199B
	djnz loc_196C                   ; 199C
	ld iy,#pause_C8D7                 ; 199E
	call sub_72B2                   ; 19A2
	ld hl,(player_C8D8)                ; 19A5
	ld de,(player_C8E7)                ; 19A8
	add hl,de                       ; 19AC
	ld (player_C8D8),hl                ; 19AD
	ld a,(pause_C8D7)                 ; 19B0
	or a                            ; 19B3
	jr nz,sub_1963                  ; 19B4
	ret                             ; 19B6

;; ---------------------------------------------------------------- $01A2D
;; classement : atteinte uniquement par task1
	.area _B00_1A2D
sub_1A2D::
	call sub_212C                   ; 1A2D
	call sub_2F16                   ; 1A30
	call sub_5ED5                   ; 1A33
	ld hl,#player_CF20                 ; 1A36
	set 1,(hl)                      ; 1A39
	ld a,(game_mode)                ; 1A3B
	cp #0x03                        ; 1A3E
	jr c,loc_1A5C                   ; 1A40
	ld hl,#0x0000                   ; 1A42
	ld a,(scene_id)                 ; 1A45
	cp #0x2a                        ; 1A48
	jr z,loc_1A56                   ; 1A4A
	ld hl,#0x0100                   ; 1A4C
	cp #0x25                        ; 1A4F
	jr z,loc_1A56                   ; 1A51
	jp loc_3090                     ; 1A53
loc_1A56:
	ld (player_C0CE),hl                ; 1A56
	jp loc_3090                     ; 1A59
loc_1A5C:
	call task_yield                 ; 1A5C
	call sub_2249                   ; 1A5F
	ld a,(freeze_timer)             ; 1A62
	or a                            ; 1A65
	jr nz,loc_1A5C                  ; 1A66
	ld a,(demo_mode)                ; 1A68
	or a                            ; 1A6B
	jr z,loc_1A74                   ; 1A6C
	ld hl,#0x0000                   ; 1A6E
	ld (joypad_state),hl            ; 1A71
loc_1A74:
	call sub_1616                   ; 1A74
	ld a,(game_flags)               ; 1A77
	bit 6,a                         ; 1A7A
	jr nz,loc_1A5C                  ; 1A7C
	call sub_280F                   ; 1A7E
	ld a,(player_CF06)                 ; 1A81
	or a                            ; 1A84
	jr z,loc_1A8C                   ; 1A85
	ld hl,#player_CF20                 ; 1A87
	set 1,(hl)                      ; 1A8A
loc_1A8C:
	call sub_1B12                   ; 1A8C
	call sub_2EFD                   ; 1A8F
	call sub_1B2C                   ; 1A92
	ld a,(demo_mode)                ; 1A95
	or a                            ; 1A98
	jr z,loc_1AA1                   ; 1A99
	ld hl,#0x0000                   ; 1A9B
	ld (player_CF01),hl                ; 1A9E
loc_1AA1:
	call sub_2EDC                   ; 1AA1
	ld hl,(player_C1DF)                ; 1AA4
	ld a,l                          ; 1AA7
	or h                            ; 1AA8
	jr z,loc_1AB4                   ; 1AA9
	push hl                         ; 1AAB
	pop iy                          ; 1AAC
	ld a,17(iy)                     ; 1AAE
	ld (player_CF00),a                 ; 1AB1
loc_1AB4:
	ld a,(player_CF21)                 ; 1AB4
	ld hl,(player_CEFF)                ; 1AB7
	push hl                         ; 1ABA
	push af                         ; 1ABB
	call sub_2C7B                   ; 1ABC
	pop af                          ; 1ABF
	ld (player_CF21),a                 ; 1AC0
	call sub_2E1C                   ; 1AC3
	pop hl                          ; 1AC6
	ld a,(player_CF06)                 ; 1AC7
	or a                            ; 1ACA
	jr z,loc_1AD0                   ; 1ACB
	ld (player_CEFF),hl                ; 1ACD
loc_1AD0:
	call sub_225F                   ; 1AD0
	call sub_3994                   ; 1AD3
	call sub_23FC                   ; 1AD6
	call sub_5B50                   ; 1AD9
	call sub_3C30                   ; 1ADC
	call sub_3C1D                   ; 1ADF
	ld a,(player_state)             ; 1AE2
	cp #0xff                        ; 1AE5
	jr z,loc_1AEC                   ; 1AE7
	call sub_1FA7                   ; 1AE9
loc_1AEC:
	ld iy,#player_state             ; 1AEC
	call sub_1C8A                   ; 1AF0
	call sub_1C60                   ; 1AF3
	call sub_1B57                   ; 1AF6
	call sub_2AF9                   ; 1AF9
	ld hl,(scroll_x)                ; 1AFC
	push hl                         ; 1AFF
	ld hl,(scroll_y)                ; 1B00
	push hl                         ; 1B03
	call sub_5606                   ; 1B04
	call sub_55A8                   ; 1B07
	pop hl                          ; 1B0A
	pop de                          ; 1B0B
	call sub_1BC9                   ; 1B0C
	jp loc_1A5C                     ; 1B0F

;; ---------------------------------------------------------------- $01B12
;; classement : atteinte uniquement par task1
	.area _B00_1B12
sub_1B12:
	ld a,(player_CF00)                 ; 1B12
	bit 7,a                         ; 1B15
	ret nz                          ; 1B17
	ld a,(player_C0CC)                 ; 1B18
	call sub_1B47                   ; 1B1B
	ret z                           ; 1B1E
	ld a,(player_C0CD)                 ; 1B1F
	call sub_1B47                   ; 1B22
	ret z                           ; 1B25
	ld hl,#player_CF20                 ; 1B26
	set 1,(hl)                      ; 1B29
	ret                             ; 1B2B

;; ---------------------------------------------------------------- $01B2C
;; classement : atteinte uniquement par task1
	.area _B00_1B2C
sub_1B2C:
	ld a,(player_CF00)                 ; 1B2C
	bit 7,a                         ; 1B2F
	ret nz                          ; 1B31
	ld a,(player_C0CC)                 ; 1B32
	call sub_1B47                   ; 1B35
	ret z                           ; 1B38
	ld a,(player_C0CD)                 ; 1B39
	call sub_1B47                   ; 1B3C
	ret z                           ; 1B3F
	ld hl,#0x0100                   ; 1B40
	ld (player_CEFF),hl                ; 1B43
	ret                             ; 1B46

;; ---------------------------------------------------------------- $01B47
;; classement : atteinte uniquement par task1
	.area _B00_1B47
sub_1B47::
	and #0x0f                       ; 1B47
	cp #0x05                        ; 1B49
	jr z,loc_1B4F                   ; 1B4B
	xor a                           ; 1B4D
	ret                             ; 1B4E
loc_1B4F:
	or a                            ; 1B4F
	ret                             ; 1B50
data_1B51:
	.db 0x1d, 0x1c, 0x1f, 0x1e, 0x11, 0x10 ; 1B51

;; ---------------------------------------------------------------- $01B57
;; classement : atteinte uniquement par task1
	.area _B00_1B57
sub_1B57::
	ld iy,#player_state             ; 1B57
	ld a,(player_state)             ; 1B5B
	cpl                             ; 1B5E
	add a,a                         ; 1B5F
	ld l,a                          ; 1B60
	ld h,#0x00                      ; 1B61
	ld de,#data_1B51                ; 1B63
	add hl,de                       ; 1B66
	ex de,hl                        ; 1B67
	ld a,#0x10                      ; 1B68
	ld (tmp_d3),a                   ; 1B6A
	ld l,#0x00                      ; 1B6D
	call sub_3569                   ; 1B6F
	ld a,(player_CEFD)                 ; 1B72
	cp #0x10                        ; 1B75
	jr nz,loc_1BC8                  ; 1B77
	ld a,(player_CF05)                 ; 1B79
	and #0x01                       ; 1B7C
	ld (player_CF21),a                 ; 1B7E
	ld a,(player_CF05)                 ; 1B81
	and #0xfe                       ; 1B84
	ld (player_CEF6),a                 ; 1B86
	ld iy,#player_state             ; 1B89
	ld 9(iy),#0x00                  ; 1B8D
	ld 8(iy),#0x00                  ; 1B91
	ld 10(iy),#0x00                 ; 1B95
	ld a,#0x02                      ; 1B99
	ld (bank_slot2_shadow),a        ; 1B9B
	ld (MAPPER_SLOT2),a             ; 1B9E  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b02_8188            ; 1BA1
	ld (player_CF11),hl                ; 1BA4
	ld hl,#data_b02_818C            ; 1BA7
	ld (player_CF13),hl                ; 1BAA
	ld a,#0x40                      ; 1BAD
	ld (player_CF09),a                 ; 1BAF
	call sub_051E                   ; 1BB2
	ld a,(player_state)             ; 1BB5
	cp #0xfd                        ; 1BB8
	jr nz,loc_1BBC                  ; 1BBA
loc_1BBC:
	ld hl,(player_C1DF)                ; 1BBC
	ld a,l                          ; 1BBF
	or h                            ; 1BC0
	ret z                           ; 1BC1
	ld hl,#0x0000                   ; 1BC2
	ld (player_C1DF),hl                ; 1BC5
loc_1BC8:
	ret                             ; 1BC8

;; ---------------------------------------------------------------- $01C60
;; classement : atteinte uniquement par task1
	.area _B00_1C60
sub_1C60::
	call sub_3085                   ; 1C60
	ret nz                          ; 1C63
	call sub_20D8                   ; 1C64
	ld a,(hl)                       ; 1C67
	inc hl                          ; 1C68
	ld c,(hl)                       ; 1C69
	dec hl                          ; 1C6A
	or c                            ; 1C6B
	ret z                           ; 1C6C
	ld ix,#actor_CB07                 ; 1C6D
	ld b,#0x04                      ; 1C71
	jr loc_1C9D                     ; 1C73

;; ---------------------------------------------------------------- $01C75
;; classement : atteinte uniquement par task1
	.area _B00_1C75
sub_1C75::
	call sub_3085                   ; 1C75
	ret nz                          ; 1C78
	call sub_20D8                   ; 1C79
	ld a,(hl)                       ; 1C7C
	inc hl                          ; 1C7D
	ld c,(hl)                       ; 1C7E
	dec hl                          ; 1C7F
	or c                            ; 1C80
	ret z                           ; 1C81
	ld ix,#actor_CBA7                 ; 1C82
	ld b,#0x0a                      ; 1C86
	jr loc_1C9D                     ; 1C88

;; ---------------------------------------------------------------- $01C8A
;; classement : atteinte uniquement par task1
	.area _B00_1C8A
sub_1C8A::
	call sub_3085                   ; 1C8A
	ret nz                          ; 1C8D
	call sub_20D8                   ; 1C8E
	ld a,(hl)                       ; 1C91
	inc hl                          ; 1C92
	ld c,(hl)                       ; 1C93
	dec hl                          ; 1C94
	or c                            ; 1C95
	ret z                           ; 1C96
	ld ix,#player_CDAF                 ; 1C97
	ld b,#0x08                      ; 1C9B
loc_1C9D:
	push bc                         ; 1C9D
	push hl                         ; 1C9E
	ld a,13(ix)                     ; 1C9F
	or 6(ix)                        ; 1CA2
	or 3(ix)                        ; 1CA5
	jp nz,loc_1D7B                  ; 1CA8
	ld a,0(ix)                      ; 1CAB
	or a                            ; 1CAE
	jp z,loc_1D7B                   ; 1CAF
	cp #0xb0                        ; 1CB2
	jp nc,loc_1D7B                  ; 1CB4
	ld a,11(ix)                     ; 1CB7
	or 12(ix)                       ; 1CBA
	jp z,loc_1D7B                   ; 1CBD
	ld a,20(ix)                     ; 1CC0
	or a                            ; 1CC3
	jp nz,loc_1CCF                  ; 1CC4
	ld a,(player_state)             ; 1CC7
	cp #0xfd                        ; 1CCA
	jp z,loc_1D7B                   ; 1CCC
loc_1CCF:
	ld a,e                          ; 1CCF
	sub 5(ix)                       ; 1CD0
	jp p,loc_1CD8                   ; 1CD3
	neg                             ; 1CD6
loc_1CD8:
	cp #0x40                        ; 1CD8
	jp nc,loc_1D7B                  ; 1CDA
	ld c,a                          ; 1CDD
	ld a,d                          ; 1CDE
	sub 2(ix)                       ; 1CDF
	jp p,loc_1CE7                   ; 1CE2
	neg                             ; 1CE5
loc_1CE7:
	cp #0x40                        ; 1CE7
	jp nc,loc_1D7B                  ; 1CE9
	ld b,a                          ; 1CEC
	ld a,(hl)                       ; 1CED
	add a,11(ix)                    ; 1CEE
	cp b                            ; 1CF1
	jp c,loc_1D7B                   ; 1CF2
	inc hl                          ; 1CF5
	ld a,(hl)                       ; 1CF6
	add a,12(ix)                    ; 1CF7
	cp c                            ; 1CFA
	jp c,loc_1D7B                   ; 1CFB
	ld a,0(ix)                      ; 1CFE
	cp #0x92                        ; 1D01
	jr c,loc_1D0B                   ; 1D03
	call sub_1D87                   ; 1D05
	jp loc_1D7B                     ; 1D08
loc_1D0B:
	ld a,(game_flags)               ; 1D0B
	bit 1,a                         ; 1D0E
	jr z,loc_1D57                   ; 1D10
	ld a,#0xfe                      ; 1D12
	ld (player_CF03),a                 ; 1D14
	bit 1,34(ix)                    ; 1D17
	jp nz,loc_1D78                  ; 1D1B
	call sub_2082                   ; 1D1E
	ld a,e                          ; 1D21
	cp 5(ix)                        ; 1D22
	jr c,loc_1D3F                   ; 1D25
	set 0,13(ix)                    ; 1D27
	ld a,(game_flags)               ; 1D2B
	bit 1,a                         ; 1D2E
	jr nz,loc_1D78                  ; 1D30
	ld a,#0x02                      ; 1D32
	cp 15(ix)                       ; 1D34
	jr nc,loc_1D78                  ; 1D37
	set 1,13(iy)                    ; 1D39
	jr loc_1D78                     ; 1D3D
loc_1D3F:
	set 1,13(ix)                    ; 1D3F
	ld a,(game_flags)               ; 1D43
	bit 1,a                         ; 1D46
	jr nz,loc_1D78                  ; 1D48
	ld a,#0x02                      ; 1D4A
	cp 15(ix)                       ; 1D4C
	jr nc,loc_1D78                  ; 1D4F
	set 0,13(iy)                    ; 1D51
	jr loc_1D78                     ; 1D55
loc_1D57:
	ld a,(player_state)             ; 1D57
	cp #0xfd                        ; 1D5A
	jr nz,loc_1D65                  ; 1D5C
	ld a,(player_CEF6)                 ; 1D5E
	cp #0x30                        ; 1D61
	jr nc,loc_1D78                  ; 1D63
loc_1D65:
	call sub_2074                   ; 1D65
	ld a,e                          ; 1D68
	cp 5(ix)                        ; 1D69
	jr c,loc_1D74                   ; 1D6C
	set 1,13(iy)                    ; 1D6E
	jr loc_1D78                     ; 1D72
loc_1D74:
	set 0,13(iy)                    ; 1D74
loc_1D78:
	pop hl                          ; 1D78
	pop bc                          ; 1D79
	ret                             ; 1D7A
loc_1D7B:
	ld bc,#0x0028                   ; 1D7B
	add ix,bc                       ; 1D7E
	pop hl                          ; 1D80
	pop bc                          ; 1D81
	dec b                           ; 1D82
	jp nz,loc_1C9D                  ; 1D83
	ret                             ; 1D86

;; ---------------------------------------------------------------- $01D87
;; classement : atteinte uniquement par task1
	.area _B00_1D87
sub_1D87:
	ld a,21(ix)                     ; 1D87
	or a                            ; 1D8A
	ret z                           ; 1D8B
	bit 1,34(ix)                    ; 1D8C
	ret nz                          ; 1D90
	add a,a                         ; 1D91
	ld l,a                          ; 1D92
	ld h,#0x00                      ; 1D93
	ld de,#jt_1D9E                  ; 1D95
	add hl,de                       ; 1D98
	ld e,(hl)                       ; 1D99
	inc hl                          ; 1D9A
	ld d,(hl)                       ; 1D9B
	ex de,hl                        ; 1D9C
	jp (hl)                         ; 1D9D
jt_1D9E:
	.dw loc_1E27                    ; 1D9E
	.dw loc_1E03                    ; 1DA0
	.dw loc_1E07                    ; 1DA2
	.dw loc_1E0B                    ; 1DA4
	.dw loc_1E0F                    ; 1DA6
	.dw loc_1E13                    ; 1DA8
	.dw loc_1E27                    ; 1DAA
	.dw loc_1E27                    ; 1DAC
	.dw loc_1E27                    ; 1DAE
	.dw loc_1E27                    ; 1DB0
	.dw loc_1E27                    ; 1DB2
	.dw loc_1E27                    ; 1DB4
	.dw loc_1E27                    ; 1DB6
	.dw loc_1EA0                    ; 1DB8
	.dw loc_1EA7                    ; 1DBA
	.dw loc_1EAE                    ; 1DBC
	.dw loc_1EB5                    ; 1DBE
	.dw loc_1E4E                    ; 1DC0
	.dw loc_1EF8                    ; 1DC2
	.dw loc_1EFE                    ; 1DC4
	.dw loc_1E27                    ; 1DC6
	.dw loc_1F18                    ; 1DC8
	.dw loc_1F18                    ; 1DCA
	.dw loc_1F18                    ; 1DCC
	.dw loc_1F4F                    ; 1DCE
	.dw loc_1E55                    ; 1DD0
	.dw loc_1DE4                    ; 1DD2
	.dw loc_1DE8                    ; 1DD4
	.dw loc_1DED                    ; 1DD6
	.dw loc_1DF1                    ; 1DD8
	.dw loc_1DF5                    ; 1DDA
	.dw loc_1E36                    ; 1DDC
	.dw loc_1E42                    ; 1DDE
	.dw loc_1E2F                    ; 1DE0
	.dw loc_1E28                    ; 1DE2
loc_1DE4:
	ld a,#0x01                      ; 1DE4
	jr loc_1DF9                     ; 1DE6
loc_1DE8:
	ld a,#0x02                      ; 1DE8
	jr loc_1DF9                     ; 1DEA
	.db 0xc9                        ; 1DEC
loc_1DED:
	ld a,#0x04                      ; 1DED
	jr loc_1DF9                     ; 1DEF
loc_1DF1:
	ld a,#0x08                      ; 1DF1
	jr loc_1DF9                     ; 1DF3
loc_1DF5:
	ld a,#0x10                      ; 1DF5
	jr loc_1DF9                     ; 1DF7
loc_1DF9:
	ld hl,#event_C010                 ; 1DF9
	or (hl)                         ; 1DFC
	ld (hl),a                       ; 1DFD
	call sub_053C                   ; 1DFE
	jr loc_1E1B                     ; 1E01
loc_1E03:
	ld a,#0x07                      ; 1E03
	jr loc_1E15                     ; 1E05
loc_1E07:
	ld a,#0x0a                      ; 1E07
	jr loc_1E15                     ; 1E09
loc_1E0B:
	ld a,#0x03                      ; 1E0B
	jr loc_1E15                     ; 1E0D
loc_1E0F:
	ld a,#0x04                      ; 1E0F
	jr loc_1E15                     ; 1E11
loc_1E13:
	ld a,#0x05                      ; 1E13
loc_1E15:
	ld (flow_C1B1),a                 ; 1E15
	call sub_0514                   ; 1E18
loc_1E1B:
	ld 0(ix),#0x00                  ; 1E1B
	ld l,36(ix)                     ; 1E1F
	ld h,37(ix)                     ; 1E22
	ld (hl),#0x00                   ; 1E25
loc_1E27:
	ret                             ; 1E27
loc_1E28:
	ld a,#0x0c                      ; 1E28
	ld (player_C1B3),a                 ; 1E2A
	jr loc_1E5A                     ; 1E2D
loc_1E2F:
	ld a,#0x06                      ; 1E2F
	ld (player_C1B3),a                 ; 1E31
	jr loc_1E5A                     ; 1E34
loc_1E36:
	ld a,#0x08                      ; 1E36
	ld (player_C1B3),a                 ; 1E38
	ld hl,#game_flags               ; 1E3B
	set 2,(hl)                      ; 1E3E
	jr loc_1E5A                     ; 1E40
loc_1E42:
	ld a,#0x09                      ; 1E42
	ld (player_C1B3),a                 ; 1E44
	ld hl,#game_flags               ; 1E47
	set 2,(hl)                      ; 1E4A
	jr loc_1E5A                     ; 1E4C
loc_1E4E:
	ld a,#0x02                      ; 1E4E
	ld (player_C1B3),a                 ; 1E50
	jr loc_1E5A                     ; 1E53
loc_1E55:
	ld a,#0x07                      ; 1E55
	ld (player_C1B3),a                 ; 1E57
loc_1E5A:
	ld 0(ix),#0x00                  ; 1E5A
	ld a,#0x01                      ; 1E5E
	ld (demo_mode),a                ; 1E60
	call sub_0519                   ; 1E63
	ld a,#0x1e                      ; 1E66
	call sub_3190                   ; 1E68
	ld a,(flow_C1B7)                 ; 1E6B
	inc a                           ; 1E6E
	ld (flow_C1B7),a                 ; 1E6F
	add a,#0x06                     ; 1E72
	ld c,a                          ; 1E74
loc_1E75:
	ld a,(player_CEFE)                 ; 1E75
	inc a                           ; 1E78
	cp c                            ; 1E79
	jr z,loc_1E7E                   ; 1E7A
	jr nc,loc_1E8D                  ; 1E7C
loc_1E7E:
	ld (player_CEFE),a                 ; 1E7E
	call sub_0523                   ; 1E81
	ld a,#0x05                      ; 1E84
	push bc                         ; 1E86
	call sub_3190                   ; 1E87
	pop bc                          ; 1E8A
	jr loc_1E75                     ; 1E8B
loc_1E8D:
	ld a,#0x14                      ; 1E8D
	call sub_3190                   ; 1E8F
	call sub_0528                   ; 1E92
	ld a,#0xaa                      ; 1E95
	call sub_3190                   ; 1E97
	ld hl,#game_flags               ; 1E9A
	set 4,(hl)                      ; 1E9D
	ret                             ; 1E9F
loc_1EA0:
	ld hl,#player_C1E9                 ; 1EA0
	set 7,(hl)                      ; 1EA3
	jr loc_1EC5                     ; 1EA5
loc_1EA7:
	ld hl,#player_C1F1                 ; 1EA7
	set 7,(hl)                      ; 1EAA
	jr loc_1EC5                     ; 1EAC
loc_1EAE:
	ld hl,#player_C1F0                 ; 1EAE
	set 7,(hl)                      ; 1EB1
	jr loc_1EC5                     ; 1EB3
loc_1EB5:
	ld hl,(flow_C1A0)                ; 1EB5
	ld h,#0x00                      ; 1EB8
	add hl,hl                       ; 1EBA
	ld de,#data_1EDA                ; 1EBB
	add hl,de                       ; 1EBE
	ld e,(hl)                       ; 1EBF
	inc hl                          ; 1EC0
	ld d,(hl)                       ; 1EC1
	ex de,hl                        ; 1EC2
	set 7,(hl)                      ; 1EC3
loc_1EC5:
	call sub_050A                   ; 1EC5
	ld a,#0x32                      ; 1EC8
	call sub_0332                   ; 1ECA
	ld hl,#game_flags               ; 1ECD
	set 4,(hl)                      ; 1ED0
	set 2,(hl)                      ; 1ED2
	ld a,#0x10                      ; 1ED4
	ld (player_C1B3),a                 ; 1ED6
	ret                             ; 1ED9
data_1EDA:
	.db 0xe1, 0xc1, 0xe2            ; 1EDA

;; ---------------------------------------------------------------- $01F87
;; classement : atteinte uniquement par task1
	.area _B00_1F87
sub_1F87::
	ld ix,#actor_CBA7                 ; 1F87
	ld b,#0x0a                      ; 1F8B
	jr loc_1FB1                     ; 1F8D

;; ---------------------------------------------------------------- $01F8F
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_1F8F
sub_1F8F:
	ld iy,#player_state             ; 1F8F
	ld ix,#player_CDAF                 ; 1F93
	ld b,#0x08                      ; 1F97
	jr loc_1FB1                     ; 1F99

;; ---------------------------------------------------------------- $01F9B
;; classement : atteinte uniquement par task1
	.area _B00_1F9B
sub_1F9B::
	ld iy,#player_state             ; 1F9B
	ld ix,#actor_CB07                 ; 1F9F
	ld b,#0x07                      ; 1FA3
	jr loc_1FB1                     ; 1FA5

;; ---------------------------------------------------------------- $01FA7
;; classement : atteinte uniquement par task1
	.area _B00_1FA7
sub_1FA7::
	ld iy,#player_state             ; 1FA7
	ld ix,#actor_CDD7                 ; 1FAB
	ld b,#0x07                      ; 1FAF
loc_1FB1:
	ld a,(player_CF03)                 ; 1FB1
data_1FB4::
	or a                            ; 1FB4
	ret z                           ; 1FB5
	call sub_20B4                   ; 1FB6
	ld a,(hl)                       ; 1FB9
	inc hl                          ; 1FBA
	ld c,(hl)                       ; 1FBB
	dec hl                          ; 1FBC
loc_1FBD::
	or c                            ; 1FBD
	ret z                           ; 1FBE
loc_1FBF:
	push bc                         ; 1FBF
	push hl                         ; 1FC0
	ld a,0(ix)                      ; 1FC1
	or a                            ; 1FC4
	jp z,loc_204D                   ; 1FC5
	cp #0x92                        ; 1FC8
	jp nc,loc_204D                  ; 1FCA
	ld a,11(ix)                     ; 1FCD
	or 12(ix)                       ; 1FD0
	jr z,loc_204D                   ; 1FD3
	ld a,13(ix)                     ; 1FD5
	or 14(ix)                       ; 1FD8
	or 3(ix)                        ; 1FDB
	or 6(ix)                        ; 1FDE
	jr nz,loc_204D                  ; 1FE1
	ld a,e                          ; 1FE3
	sub 5(ix)                       ; 1FE4
	jp p,loc_1FEC                   ; 1FE7
	neg                             ; 1FEA
loc_1FEC:
	cp #0x80                        ; 1FEC
	jr nc,loc_204D                  ; 1FEE
	ld c,a                          ; 1FF0
	ld a,d                          ; 1FF1
	sub 2(ix)                       ; 1FF2
	jp p,loc_1FFA                   ; 1FF5
	neg                             ; 1FF8
loc_1FFA:
	cp #0x80                        ; 1FFA
	jp nc,loc_204D                  ; 1FFC
	ld b,a                          ; 1FFF
	ld a,(hl)                       ; 2000
	add a,11(ix)                    ; 2001
	cp b                            ; 2004
	jr c,loc_204D                   ; 2005
	inc hl                          ; 2007
	ld a,(hl)                       ; 2008
	add a,12(ix)                    ; 2009
	cp c                            ; 200C
	jr c,loc_204D                   ; 200D
	ld a,0(ix)                      ; 200F
	cp #0x50                        ; 2012
	jr nz,loc_202F                  ; 2014
	bit 2,39(ix)                    ; 2016
	jr z,loc_202F                   ; 201A
	call sub_2059                   ; 201C
	jr nz,loc_202F                  ; 201F
	ld 27(ix),#0x5d                 ; 2021
	ld 28(ix),#0xa4                 ; 2025
	ld 33(ix),#0x00                 ; 2029
	jr loc_2035                     ; 202D
loc_202F:
	bit 1,34(ix)                    ; 202F
	jr nz,loc_204D                  ; 2033
loc_2035:
	call sub_2082                   ; 2035
	ld a,(player_CEF4)                 ; 2038
	cp 5(ix)                        ; 203B
	jr c,loc_2046                   ; 203E
	set 0,13(ix)                    ; 2040
	jr loc_204A                     ; 2044
loc_2046:
	set 1,13(ix)                    ; 2046
loc_204A:
	pop hl                          ; 204A
	pop bc                          ; 204B
	ret                             ; 204C
loc_204D:
	ld bc,#0x0028                   ; 204D
	add ix,bc                       ; 2050
	pop hl                          ; 2052
	pop bc                          ; 2053
	dec b                           ; 2054
	jp nz,loc_1FBF                  ; 2055
	ret                             ; 2058

;; ---------------------------------------------------------------- $02059
;; classement : atteinte uniquement par task1
	.area _B00_2059
sub_2059:
	ld a,(player_state)             ; 2059
	cp #0xfd                        ; 205C
	jr nz,loc_2071                  ; 205E
	ld a,(player_CEF6)                 ; 2060
	cp #0x30                        ; 2063
	jr z,loc_206F                   ; 2065
	cp #0x32                        ; 2067
	jr z,loc_206F                   ; 2069
	cp #0x34                        ; 206B
	jr nz,loc_2071                  ; 206D
loc_206F:
	xor a                           ; 206F
	ret                             ; 2070
loc_2071:
	or #0xff                        ; 2071
	ret                             ; 2073

;; ---------------------------------------------------------------- $02074
;; classement : atteinte uniquement par task1
	.area _B00_2074
sub_2074:
	ld a,20(ix)                     ; 2074
	add a,15(iy)                    ; 2077
	jp p,loc_207E                   ; 207A
	xor a                           ; 207D
loc_207E:
	ld 15(iy),a                     ; 207E
	ret                             ; 2081

;; ---------------------------------------------------------------- $02082
;; classement : racines du meme module : task1+tbl_3CC3
	.area _B00_2082
sub_2082:
	ld a,20(iy)                     ; 2082
	add a,15(ix)                    ; 2085
	jp p,loc_208C                   ; 2088
	xor a                           ; 208B
loc_208C:
	ld 15(ix),a                     ; 208C
	ret                             ; 208F

;; ---------------------------------------------------------------- $02090
;; classement : atteinte uniquement par task1
	.area _B00_2090
sub_2090:
	ld a,(player_state)             ; 2090
	cpl                             ; 2093
	add a,a                         ; 2094
	ld l,a                          ; 2095
	ld h,#0x00                      ; 2096
	ld a,#0x04                      ; 2098
	ld (bank_slot2_shadow),a        ; 209A
	ld (MAPPER_SLOT2),a             ; 209D  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b04_B6DC            ; 20A0
	add hl,de                       ; 20A3
	ld e,(hl)                       ; 20A4
	inc hl                          ; 20A5
	ld d,(hl)                       ; 20A6
	ld iy,#player_state             ; 20A7
	ld a,(player_CEF6)                 ; 20AB
	ld hl,#player_CF21                 ; 20AE
	add a,(hl)                      ; 20B1
	jr loc_20FA                     ; 20B2

;; ---------------------------------------------------------------- $020B4
;; classement : atteinte uniquement par task1
	.area _B00_20B4
sub_20B4:
	ld a,(player_state)             ; 20B4
	cpl                             ; 20B7
	add a,a                         ; 20B8
	ld l,a                          ; 20B9
	ld h,#0x00                      ; 20BA
	ld a,#0x04                      ; 20BC
	ld (bank_slot2_shadow),a        ; 20BE
	ld (MAPPER_SLOT2),a             ; 20C1  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b04_B6E2            ; 20C4
	add hl,de                       ; 20C7
	ld e,(hl)                       ; 20C8
	inc hl                          ; 20C9
	ld d,(hl)                       ; 20CA
	ld iy,#player_state             ; 20CB
	ld a,(player_CEF6)                 ; 20CF
	ld hl,#player_CF21                 ; 20D2
	add a,(hl)                      ; 20D5
	jr loc_20FA                     ; 20D6

;; ---------------------------------------------------------------- $020D8
;; classement : atteinte uniquement par task1
	.area _B00_20D8
sub_20D8:
	ld a,(player_state)             ; 20D8
	cpl                             ; 20DB
	add a,a                         ; 20DC
	ld l,a                          ; 20DD
	ld h,#0x00                      ; 20DE
	ld a,#0x04                      ; 20E0
	ld (bank_slot2_shadow),a        ; 20E2
	ld (MAPPER_SLOT2),a             ; 20E5  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b04_B6E8            ; 20E8
	add hl,de                       ; 20EB
	ld e,(hl)                       ; 20EC
	inc hl                          ; 20ED
	ld d,(hl)                       ; 20EE
	ld iy,#player_state             ; 20EF
	ld a,(player_CEF6)                 ; 20F3
	ld hl,#player_CF21                 ; 20F6
	add a,(hl)                      ; 20F9
loc_20FA:
	add a,a                         ; 20FA
	ld l,a                          ; 20FB
	ld h,#0x00                      ; 20FC
	add hl,de                       ; 20FE
	ld e,(hl)                       ; 20FF
	inc hl                          ; 2100
	ld d,(hl)                       ; 2101
	ld a,9(iy)                      ; 2102
	add a,a                         ; 2105
	add a,a                         ; 2106
	ld l,a                          ; 2107
	ld h,#0x00                      ; 2108
	add hl,de                       ; 210A
	ld a,2(iy)                      ; 210B
	add a,(hl)                      ; 210E
	ld d,a                          ; 210F
	inc hl                          ; 2110
	ld a,5(iy)                      ; 2111
	add a,(hl)                      ; 2114
	ld e,a                          ; 2115
	inc hl                          ; 2116
	ret                             ; 2117

;; ---------------------------------------------------------------- $0212C
;; classement : atteinte uniquement par task1
	.area _B00_212C
sub_212C:
	call sub_2118                   ; 212C
	call sub_221E                   ; 212F
	call sub_21E9                   ; 2132
	ld a,(event_C1B2)                 ; 2135
	ld (player_state),a             ; 2138
	ld a,(game_mode)                ; 213B
	cp #0x03                        ; 213E
	jr c,loc_2168                   ; 2140
	ld a,(scene_id)                 ; 2142
	cp #0x2a                        ; 2145
	jr z,loc_2168                   ; 2147
	cp #0x2c                        ; 2149
	jr z,loc_2161                   ; 214B
	cp #0x33                        ; 214D
	jr z,loc_2161                   ; 214F
	cp #0x35                        ; 2151
	jr z,loc_2161                   ; 2153
	cp #0x36                        ; 2155
	jr z,loc_2161                   ; 2157
	ld a,(flow_C1B7)                 ; 2159
	add a,#0x06                     ; 215C
	ld (player_CEFE),a                 ; 215E
loc_2161:
	ld a,#0xfd                      ; 2161
	ld (player_state),a             ; 2163
	jr loc_2174                     ; 2166
loc_2168:
	ld a,(player_CEFE)                 ; 2168
	sub #0x04                       ; 216B
	jr c,loc_2174                   ; 216D
	ld a,#0x03                      ; 216F
	ld (player_CEFE),a                 ; 2171
loc_2174:
	call sub_0A33                   ; 2174
	ld a,(player_state)             ; 2177
	cpl                             ; 217A
	ld l,a                          ; 217B
	ld h,#0x00                      ; 217C
	add hl,hl                       ; 217E
	ld de,#data_2126                ; 217F
	add hl,de                       ; 2182
	ld e,(hl)                       ; 2183
	inc hl                          ; 2184
	ld d,(hl)                       ; 2185
	ld (player_C435),de                ; 2186
	ld a,#0x12                      ; 218A
	ld (bank_slot2_shadow),a        ; 218C
	ld (MAPPER_SLOT2),a             ; 218F  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(scene_id)                ; 2192
	ld h,#0x00                      ; 2195
	add hl,hl                       ; 2197
	add hl,hl                       ; 2198
	ld de,#data_b18_B128            ; 2199
	add hl,de                       ; 219C
	ld e,(hl)                       ; 219D
	inc hl                          ; 219E
	ld d,(hl)                       ; 219F
	inc hl                          ; 21A0
	ld (scroll_y),de                ; 21A1
	ld a,e                          ; 21A5
	ld (scroll_C1B5),a                 ; 21A6
	ld e,(hl)                       ; 21A9
	inc hl                          ; 21AA
	ld d,(hl)                       ; 21AB
	ld (scroll_x),de                ; 21AC
	ld a,e                          ; 21B0
	ld (scroll_C1B4),a                 ; 21B1
	xor a                           ; 21B4
	ld (scroll_C19E),a                 ; 21B5
	ld (player_C19F),a                 ; 21B8
	ld (demo_mode),a                ; 21BB
	ld hl,#0x0000                   ; 21BE
	ld (player_C1DF),hl                ; 21C1
	ld (player_C0CE),hl                ; 21C4
	ld a,(player_state)             ; 21C7
	cp #0xfd                        ; 21CA
	ret nz                          ; 21CC

;; ---------------------------------------------------------------- $021CD
;; classement : atteinte uniquement par task1
	.area _B00_21CD
sub_21CD:
	ld a,#0xff                      ; 21CD
	ld (player_CF03),a                 ; 21CF
	ld hl,#flow_C1B6                 ; 21D2
	bit 7,(hl)                      ; 21D5
	jr z,loc_21DE                   ; 21D7
	ld a,#0xfe                      ; 21D9
	ld (player_CF03),a                 ; 21DB
loc_21DE:
	ld a,(scene_id)                 ; 21DE
	cp #0x35                        ; 21E1
	ret c                           ; 21E3
	xor a                           ; 21E4
	ld (player_CF03),a                 ; 21E5
	ret                             ; 21E8

;; ---------------------------------------------------------------- $021E9
;; classement : atteinte uniquement par task1
	.area _B00_21E9
sub_21E9:
	ld a,#0x12                      ; 21E9
	ld (bank_slot2_shadow),a        ; 21EB
	ld (MAPPER_SLOT2),a             ; 21EE  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(scene_id)                ; 21F1
	ld h,#0x00                      ; 21F4
	add hl,hl                       ; 21F6
	add hl,hl                       ; 21F7
	ld de,#data_b18_B210            ; 21F8
	add hl,de                       ; 21FB
	ld e,(hl)                       ; 21FC
	inc hl                          ; 21FD
	ld d,(hl)                       ; 21FE
	inc hl                          ; 21FF
	ld (player_CEF0),de                ; 2200
	ld e,(hl)                       ; 2204
	inc hl                          ; 2205
	ld d,(hl)                       ; 2206
	ld (player_CEF3),de                ; 2207
	ld hl,(scene_id)                ; 220B
	ld h,#0x00                      ; 220E
	ld de,#data_b18_B2F8            ; 2210
	add hl,de                       ; 2213
	ld a,(hl)                       ; 2214
	ld (player_CF21),a                 ; 2215
	ld a,#0xff                      ; 2218
	ld (player_CF03),a                 ; 221A
	ret                             ; 221D

;; ---------------------------------------------------------------- $0221E
;; classement : ecrit la structure du joueur ($CEEF)
	.area _B00_221E
sub_221E::
	ld a,(player_CEFE)                 ; 221E
	push af                         ; 2221
	ld a,(player_CF04)                 ; 2222
	push af                         ; 2225
	ld hl,#player_state             ; 2226
	ld de,#player_CEF0                 ; 2229
	ld (hl),#0x00                   ; 222C
	ld bc,#0x0027                   ; 222E
	ldir                            ; 2231
	pop af                          ; 2233
	ld (player_CF04),a                 ; 2234
	pop af                          ; 2237
	ld (player_CEFE),a                 ; 2238

;; ---------------------------------------------------------------- $0225F
;; classement : ecrit la structure du joueur ($CEEF)
	.area _B00_225F
sub_225F::
	ld hl,(player_CEFF)                ; 225F
	ld de,(player_CEF0)                ; 2262
	add hl,de                       ; 2266
	ld (player_CEF0),hl                ; 2267
	ld hl,(player_CF01)                ; 226A
	ld de,(player_CEF3)                ; 226D
	add hl,de                       ; 2271
	ld (player_CEF3),hl                ; 2272
	ld hl,(player_CEF3)                ; 2275
	ld de,#player_C500                 ; 2278
	or a                            ; 227B
	sbc hl,de                       ; 227C
	jr c,loc_2286                   ; 227E
	ld (player_CEF3),de                ; 2280
	jr loc_2295                     ; 2284
loc_2286:
	ld hl,(player_CEF3)                ; 2286
	ld de,#0x3c00                   ; 2289
	or a                            ; 228C
	sbc hl,de                       ; 228D
	jr nc,loc_2295                  ; 228F
	ld (player_CEF3),de                ; 2291
loc_2295:
	ld hl,(player_CEF0)                ; 2295
	ld de,#player_E600                 ; 2298
	or a                            ; 229B
	sbc hl,de                       ; 229C
	jr c,loc_22AF                   ; 229E
	xor a                           ; 22A0
	ld (player_CEFE),a                 ; 22A1
	ld hl,#player_CEFC                 ; 22A4
	set 2,(hl)                      ; 22A7
	ld (player_CEF0),de                ; 22A9
	jr loc_22BE                     ; 22AD
loc_22AF:
	ld hl,(player_CEF0)                ; 22AF
	ld de,#0x0100                   ; 22B2
	or a                            ; 22B5
	sbc hl,de                       ; 22B6
	jr nc,loc_22BE                  ; 22B8
	ld (player_CEF0),de                ; 22BA
loc_22BE:
	ret                             ; 22BE

;; ---------------------------------------------------------------- $022BF
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_22BF
sub_22BF:
	ld ix,#player_state             ; 22BF
	ld a,(player_CEFC)                 ; 22C3
	or a                            ; 22C6
	ret nz                          ; 22C7
	ld hl,#player_CD37                 ; 22C8
	or (hl)                         ; 22CB
	jr z,loc_22D3                   ; 22CC
	ld hl,#player_CD5F                 ; 22CE
	or (hl)                         ; 22D1
	ret nz                          ; 22D2
loc_22D3:
	push hl                         ; 22D3
	pop iy                          ; 22D4
	call sub_3BD8                   ; 22D6
	ld a,(player_CF25)                 ; 22D9
	or a                            ; 22DC
	jr z,loc_2339                   ; 22DD
	dec a                           ; 22DF
	ld l,a                          ; 22E0
	ld h,#0x00                      ; 22E1
	add hl,hl                       ; 22E3
	add hl,hl                       ; 22E4
	ld a,(player_CF21)                 ; 22E5
	add a,a                         ; 22E8
	ld e,a                          ; 22E9
	ld d,#0x00                      ; 22EA
	add hl,de                       ; 22EC
	ld a,#0x12                      ; 22ED
	ld (bank_slot2_shadow),a        ; 22EF
	ld (MAPPER_SLOT2),a             ; 22F2  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b18_B41A            ; 22F5
	add hl,de                       ; 22F8
	ld e,(hl)                       ; 22F9
	inc hl                          ; 22FA
	ld d,(hl)                       ; 22FB
	push de                         ; 22FC
	pop ix                          ; 22FD
	ld a,0(ix)                      ; 22FF
	ld 0(iy),a                      ; 2302
	ld a,(player_CEF1)                 ; 2305
	add a,1(ix)                     ; 2308
	ld 2(iy),a                      ; 230B
	ld a,(player_CEF4)                 ; 230E
	add a,2(ix)                     ; 2311
	ld 5(iy),a                      ; 2314
	call sub_3B28                   ; 2317
	ld a,(player_CF25)                 ; 231A
	sub #0x04                       ; 231D
	jr c,loc_2336                   ; 231F
	ld hl,(scene_id)                ; 2321
	ld h,#0x00                      ; 2324
	add hl,hl                       ; 2326
	ld de,#data_2346                ; 2327
	add hl,de                       ; 232A
	ld e,(hl)                       ; 232B
	inc hl                          ; 232C
	ld d,(hl)                       ; 232D
	ld l,a                          ; 232E
	ld h,#0x00                      ; 232F
	add hl,de                       ; 2331
	ld a,(hl)                       ; 2332
	ld 20(iy),a                     ; 2333
loc_2336:
	call sub_0611                   ; 2336
loc_2339:
	ld iy,#player_state             ; 2339
	ld a,#0x02                      ; 233D
	ld (bank_slot2_shadow),a        ; 233F
	ld (MAPPER_SLOT2),a             ; 2342  mapper : banque du slot 2 ($8000-$BFFF)
	ret                             ; 2345
data_2346:
	.db 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23 ; 2346
	.db 0xba, 0x23, 0xba, 0x23, 0xc0, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23 ; 2350
.if VERSION_SMS_EN
	.db 0xba, 0x23, 0xba, 0x23, 0xc0, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23 ; 2360
	.db 0xba, 0x23, 0xba, 0x23, 0xc0, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23 ; 2370
.else ; VERSION_GG_JP
	.db 0xba, 0x23, 0xc6, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23 ; 2360
	.db 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23 ; 2370
.endif
	.db 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xcc, 0x23 ; 2380
	.db 0xd8, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xcc, 0x23, 0xba, 0x23, 0xde, 0x23, 0xba, 0x23 ; 2390
	.db 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0xd2, 0x23, 0xba, 0x23, 0xe4, 0x23, 0xea, 0x23, 0xf0, 0x23 ; 23A0
	.db 0xf6, 0x23, 0xf6, 0x23, 0xba, 0x23, 0xba, 0x23, 0xba, 0x23, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 23B0
	.db 0xfe, 0xfd, 0xfe, 0xfc, 0xfd, 0xfd, 0xff, 0xfe, 0xff, 0xfd, 0xfe, 0xfe, 0xfe, 0xfd, 0xfe, 0xfc ; 23C0
	.db 0xfd, 0xfd, 0x00, 0xfd, 0xfe, 0xff, 0x00, 0xfd, 0xfd, 0xfe, 0xff, 0xfe, 0xfc, 0xfe, 0xff, 0xff ; 23D0
	.db 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfd, 0xfe, 0xfe, 0x00, 0x00, 0x00, 0xfe, 0x00, 0x00 ; 23E0
	.db 0xff, 0xff, 0xff, 0xfe, 0xff, 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00 ; 23F0

;; ---------------------------------------------------------------- $024F1
;; classement : atteinte uniquement par task1
	.area _B00_24F1
sub_24F1:
	ld a,(player_state)             ; 24F1
	cpl                             ; 24F4
	add a,a                         ; 24F5
	ld l,a                          ; 24F6
	ld h,#0x00                      ; 24F7
	ld a,#0x12                      ; 24F9
	ld (bank_slot2_shadow),a        ; 24FB
	ld (MAPPER_SLOT2),a             ; 24FE  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b18_BF25            ; 2501
	add hl,de                       ; 2504
	ld e,(hl)                       ; 2505
	inc hl                          ; 2506
	ld d,(hl)                       ; 2507
	ld hl,(player_CEF6)                ; 2508
	ld h,#0x00                      ; 250B
	add hl,de                       ; 250D
	ld e,(hl)                       ; 250E
	inc hl                          ; 250F
	ld d,(hl)                       ; 2510
	ex de,hl                        ; 2511
loc_2512:
	ld a,#0x12                      ; 2512
	ld (bank_slot2_shadow),a        ; 2514
	ld (MAPPER_SLOT2),a             ; 2517  mapper : banque du slot 2 ($8000-$BFFF)
	ld a,(hl)                       ; 251A
	cp #0xff                        ; 251B
	ret z                           ; 251D
	inc hl                          ; 251E
	ld c,a                          ; 251F
	ld b,(hl)                       ; 2520
	inc hl                          ; 2521
	push hl                         ; 2522
	call sub_2529                   ; 2523
	pop hl                          ; 2526
	jr loc_2512                     ; 2527

;; ---------------------------------------------------------------- $02529
;; classement : atteinte uniquement par task1
	.area _B00_2529
sub_2529:
	ld (coll_C18C),bc                ; 2529
	call sub_2A03                   ; 252D
	and #0x1f                       ; 2530
	ld l,a                          ; 2532
	ld de,#jt_2539                  ; 2533
	jp util_jump_table              ; 2536
jt_2539:
	.dw loc_2579                    ; 2539
	.dw loc_257A                    ; 253B
	.dw loc_2582                    ; 253D
	.dw loc_276F                    ; 253F
	.dw loc_27BF                    ; 2541
	.dw loc_2579                    ; 2543
	.dw loc_2579                    ; 2545
	.dw loc_2792                    ; 2547
	.dw loc_2579                    ; 2549
	.dw loc_2579                    ; 254B
	.dw loc_2579                    ; 254D
	.dw loc_2579                    ; 254F
	.dw loc_2579                    ; 2551
	.dw loc_2579                    ; 2553
	.dw loc_2579                    ; 2555
	.dw loc_2579                    ; 2557
	.dw loc_2595                    ; 2559
	.dw loc_2595                    ; 255B
	.dw loc_2595                    ; 255D
	.dw loc_2595                    ; 255F
	.dw loc_2595                    ; 2561
	.dw loc_2595                    ; 2563
	.dw loc_2595                    ; 2565
	.dw loc_2595                    ; 2567
	.dw loc_2595                    ; 2569
	.dw loc_2595                    ; 256B
	.dw loc_2595                    ; 256D
	.dw loc_2595                    ; 256F
	.dw loc_2595                    ; 2571
	.dw loc_2595                    ; 2573
	.dw loc_2595                    ; 2575
	.dw loc_2595                    ; 2577
loc_2579:
	ret                             ; 2579
loc_257A:
	ld hl,(player_C196)                ; 257A
	ld a,(hl)                       ; 257D
	call sub_5C25                   ; 257E
	ret                             ; 2581
loc_2582:
	ld hl,#game_flags               ; 2582
	set 2,(hl)                      ; 2585
	ld hl,#game_flags               ; 2587
	set 4,(hl)                      ; 258A
	ld a,#0x10                      ; 258C
	ld (player_C1B3),a                 ; 258E
	call sub_059F                   ; 2591
	ret                             ; 2594
loc_2595:
	and #0x0f                       ; 2595
	push af                         ; 2597
	ld hl,(scene_id)                ; 2598
	ld h,#0x00                      ; 259B
	ld de,#data_25C1                ; 259D
	add hl,hl                       ; 25A0
	add hl,de                       ; 25A1
	ld e,(hl)                       ; 25A2
	inc hl                          ; 25A3
	ld d,(hl)                       ; 25A4
	pop af                          ; 25A5
	ld l,a                          ; 25A6
	ld h,#0x00                      ; 25A7
	add hl,hl                       ; 25A9
	add hl,de                       ; 25AA
	ld d,(hl)                       ; 25AB
	inc hl                          ; 25AC
	ld a,(hl)                       ; 25AD
	or a                            ; 25AE
	ld a,d                          ; 25AF
	jr z,loc_25B8                   ; 25B0
	ld hl,#joypad_state             ; 25B2
	bit 0,(hl)                      ; 25B5
	ret z                           ; 25B7
loc_25B8:
	ld (player_C1B3),a                 ; 25B8
	ld hl,#game_flags               ; 25BB
	set 4,(hl)                      ; 25BE
	ret                             ; 25C0
data_25C1:
	.db 0x2f, 0x26, 0x2f, 0x26, 0x2f, 0x26, 0x2f, 0x26, 0xaf, 0x26, 0xaf, 0x26, 0xaf, 0x26, 0x4f ; 25C1
	.db 0x27, 0x4f, 0x26, 0x4f, 0x26, 0x4f, 0x26, 0x4f, 0x26, 0x4f, 0x26, 0x6f, 0x26, 0x4f, 0x27, 0x8f ; 25D0
	.db 0x26, 0x8f, 0x26, 0x8f, 0x26, 0xcf, 0x26, 0xcf, 0x26, 0xef, 0x26, 0xef, 0x26, 0xef, 0x26, 0xef ; 25E0
	.db 0x26, 0xef, 0x26, 0xef, 0x26, 0xef, 0x26, 0xcf, 0x26, 0xcf, 0x26, 0xcf, 0x26, 0x0f, 0x27, 0x0f ; 25F0
	.db 0x27, 0x0f, 0x27, 0xaf, 0x26, 0x0f, 0x27, 0x0f, 0x27, 0x0f, 0x27, 0x4f, 0x27, 0x2f, 0x27, 0x2f ; 2600
	.db 0x27, 0x2f, 0x27, 0x2f, 0x27, 0x4f, 0x27, 0x4f, 0x27, 0x4f, 0x27, 0x2f, 0x27, 0x2f, 0x27, 0x2f ; 2610
	.db 0x27, 0x2f, 0x27, 0x4f, 0x27, 0x4f, 0x27, 0x4f, 0x27, 0x4f, 0x27, 0x4f, 0x27, 0x4f, 0x27, 0x06 ; 2620
	.db 0x01, 0x08, 0x01, 0x09, 0x01, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 2630
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f ; 2640
	.db 0x00, 0x03, 0x00, 0x02, 0x00, 0x06, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 2650
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02 ; 2660
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 2670
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f ; 2680
	.db 0x00, 0x05, 0x01, 0x06, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 2690
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02 ; 26A0
	.db 0x01, 0x03, 0x01, 0x04, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 26B0
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02 ; 26C0
	.db 0x01, 0x03, 0x01, 0x06, 0x01, 0x07, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 26D0
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f ; 26E0
	.db 0x00, 0x03, 0x00, 0x02, 0x00, 0x05, 0x00, 0x04, 0x00, 0x08, 0x01, 0x09, 0x01, 0x00, 0x00, 0x00 ; 26F0
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f ; 2700
	.db 0x00, 0x04, 0x00, 0x02, 0x00, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 2710
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f ; 2720
	.db 0x00, 0x03, 0x00, 0x02, 0x00, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 2730
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 2740
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 2750
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 2760
loc_276F:
	call sub_3085                   ; 276F
	ret nz                          ; 2772
	ld a,(game_flags)               ; 2773
	bit 1,a                         ; 2776
	ret nz                          ; 2778
	ld a,(player_CEFE)                 ; 2779
	dec a                           ; 277C
	ld (player_CEFE),a                 ; 277D
	or a                            ; 2780
	jr nz,loc_2789                  ; 2781
	ld hl,#player_CEFC                 ; 2783
	set 2,(hl)                      ; 2786
	ret                             ; 2788
loc_2789:
	ld a,#0x50                      ; 2789
	ld (player_CF09),a                 ; 278B
	call sub_064F                   ; 278E
	ret                             ; 2791
loc_2792:
	call sub_3085                   ; 2792
	ret nz                          ; 2795
	ld a,(game_flags)               ; 2796
	bit 1,a                         ; 2799
	ret nz                          ; 279B
	ld a,(player_CEFE)                 ; 279C
	dec a                           ; 279F
	ld (player_CEFE),a                 ; 27A0
	or a                            ; 27A3
	jr nz,loc_27AC                  ; 27A4
	ld hl,#player_CEFC                 ; 27A6
	set 2,(hl)                      ; 27A9
	ret                             ; 27AB
loc_27AC:
	ld a,(player_CF21)                 ; 27AC
	or a                            ; 27AF
	ld a,(player_CEFC)                 ; 27B0
	jr z,loc_27B9                   ; 27B3
	set 1,a                         ; 27B5
	jr loc_27BB                     ; 27B7
loc_27B9:
	set 0,a                         ; 27B9
loc_27BB:
	ld (player_CEFC),a                 ; 27BB
	ret                             ; 27BE
loc_27BF:
	xor a                           ; 27BF
	ld (player_CEFE),a                 ; 27C0
	ld hl,#player_CEFC                 ; 27C3
	set 2,(hl)                      ; 27C6
	ret                             ; 27C8
	.db 0x80, 0x18, 0x02            ; 27C9

;; ---------------------------------------------------------------- $0280F
;; classement : atteinte uniquement par task1
	.area _B00_280F
sub_280F:
	ld iy,#player_state             ; 280F
	xor a                           ; 2813
	ld (player_CF20),a                 ; 2814
	ld hl,#0x0000                   ; 2817
	call sub_2A6A                   ; 281A
	call sub_2A72                   ; 281D
	ld a,(player_state)             ; 2820
	or a                            ; 2823
	ret z                           ; 2824
	ld a,(player_state)             ; 2825
	cpl                             ; 2828
	ld l,a                          ; 2829
	ld h,#0x00                      ; 282A
	add hl,hl                       ; 282C
	ld a,#0x12                      ; 282D
	ld (bank_slot2_shadow),a        ; 282F
	ld (MAPPER_SLOT2),a             ; 2832  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b18_BDDF            ; 2835
	add hl,de                       ; 2838
	ld e,(hl)                       ; 2839
	inc hl                          ; 283A
data_283B::
	ld d,(hl)                       ; 283B
	ex de,hl                        ; 283C
	ld de,(player_CEF6)                ; 283D
	ld d,#0x00                      ; 2841
	add hl,de                       ; 2843
	ld e,(hl)                       ; 2844
	inc hl                          ; 2845
	ld d,(hl)                       ; 2846
	push de                         ; 2847
	pop ix                          ; 2848
	ld iy,#player_state             ; 284A
	ld b,0(ix)                      ; 284E
	ld c,1(ix)                      ; 2851
	ld hl,(player_C435)                ; 2854
	call sub_29C5                   ; 2857
	jr z,loc_2861                   ; 285A
	xor a                           ; 285C
	ld (actor_CF07),a                 ; 285D
	ret                             ; 2860
loc_2861:
	push ix                         ; 2861
	push iy                         ; 2863
	call sub_24F1                   ; 2865
	pop iy                          ; 2868
	pop ix                          ; 286A
	ld l,2(ix)                      ; 286C
	ld h,3(ix)                      ; 286F
	ld bc,#0x0180                   ; 2872
	ld (player_C0B1),bc                ; 2875
loc_2879:
	ld b,(hl)                       ; 2879
	inc hl                          ; 287A
	ld c,(hl)                       ; 287B
	inc hl                          ; 287C
	ld a,b                          ; 287D
	and c                           ; 287E
	cp #0xff                        ; 287F
	ld a,#0x00                      ; 2881
	jr z,loc_2894                   ; 2883
	push hl                         ; 2885
	call sub_2A03                   ; 2886
	ld bc,(player_C0B1)                ; 2889
	and c                           ; 288D
	pop hl                          ; 288E
	jr z,loc_2879                   ; 288F
	ld a,(player_C0B2)                 ; 2891
loc_2894:
	ld hl,#player_CF20                 ; 2894
	or (hl)                         ; 2897
	ld (hl),a                       ; 2898
	ld l,4(ix)                      ; 2899
	ld h,5(ix)                      ; 289C
	ld bc,#0x02a0                   ; 289F
	ld (player_C0B1),bc                ; 28A2
loc_28A6:
	ld b,(hl)                       ; 28A6
	inc hl                          ; 28A7
	ld c,(hl)                       ; 28A8
	inc hl                          ; 28A9
	ld a,b                          ; 28AA
	and c                           ; 28AB
	cp #0xff                        ; 28AC
	ld a,#0x00                      ; 28AE
	jr z,loc_2900                   ; 28B0
	push hl                         ; 28B2
	call sub_2A03                   ; 28B3
	ld bc,(player_C0B1)                ; 28B6
	ld b,a                          ; 28BA
	and c                           ; 28BB
	pop hl                          ; 28BC
	jr z,loc_28A6                   ; 28BD
	bit 5,b                         ; 28BF
	jr z,loc_28F1                   ; 28C1
	call sub_2982                   ; 28C3
	jr z,loc_28F1                   ; 28C6
	push hl                         ; 28C8
	ld de,(player_C194)                ; 28C9
	ld hl,(level_CF18)                ; 28CD
	add hl,de                       ; 28D0
	ex de,hl                        ; 28D1
	ld hl,(player_C196)                ; 28D2
	or a                            ; 28D5
	sbc hl,de                       ; 28D6
	ld a,l                          ; 28D8
	pop hl                          ; 28D9
	jr z,loc_28E4                   ; 28DA
	cp #0x01                        ; 28DC
	jr z,loc_28E4                   ; 28DE
	cp #0xff                        ; 28E0
	jr nz,loc_28A6                  ; 28E2
loc_28E4:
	push hl                         ; 28E4
	ld hl,(player_C194)                ; 28E5
	ld a,(hl)                       ; 28E8
	call sub_2AA8                   ; 28E9
	and #0x80                       ; 28EC
	pop hl                          ; 28EE
	jr nz,loc_28A6                  ; 28EF
loc_28F1:
	ld hl,(player_C196)                ; 28F1
	ld (player_C194),hl                ; 28F4
	ld hl,#player_CF20                 ; 28F7
	set 1,(hl)                      ; 28FA
	or #0xff                        ; 28FC
	jr loc_290C                     ; 28FE
loc_2900:
	ld hl,(player_C196)                ; 2900
data_2903::
	ld (player_C194),hl                ; 2903
	ld hl,#player_CF20                 ; 2906
	res 1,(hl)                      ; 2909
	xor a                           ; 290B
loc_290C:
	ld l,4(ix)                      ; 290C
	ld h,5(ix)                      ; 290F
	ld b,(hl)                       ; 2912
	inc hl                          ; 2913
	ld c,(hl)                       ; 2914
	push hl                         ; 2915
	call sub_2A03                   ; 2916
	ld (player_C0CC),a                 ; 2919
	pop hl                          ; 291C
	inc hl                          ; 291D
	ld b,(hl)                       ; 291E
	inc hl                          ; 291F
	ld c,(hl)                       ; 2920
	call sub_2A03                   ; 2921
	ld (player_C0CD),a                 ; 2924
	ld l,6(ix)                      ; 2927
	ld h,7(ix)                      ; 292A
	ld bc,#0x0480                   ; 292D
	ld (player_C0B1),bc                ; 2930
loc_2934:
	ld b,(hl)                       ; 2934
	inc hl                          ; 2935
	ld c,(hl)                       ; 2936
	inc hl                          ; 2937
	ld a,b                          ; 2938
	and c                           ; 2939
	cp #0xff                        ; 293A
	ld a,#0x00                      ; 293C
	jr z,loc_294F                   ; 293E
	push hl                         ; 2940
	call sub_2A03                   ; 2941
	ld bc,(player_C0B1)                ; 2944
	and c                           ; 2948
	pop hl                          ; 2949
	jr z,loc_2934                   ; 294A
	ld a,(player_C0B2)                 ; 294C
loc_294F:
	ld hl,#player_CF20                 ; 294F
	or (hl)                         ; 2952
	ld (hl),a                       ; 2953
	ld l,8(ix)                      ; 2954
	ld h,9(ix)                      ; 2957
	ld bc,#0x0880                   ; 295A
	ld (player_C0B1),bc                ; 295D
loc_2961:
	ld b,(hl)                       ; 2961
	inc hl                          ; 2962
	ld c,(hl)                       ; 2963
	inc hl                          ; 2964
	ld a,b                          ; 2965
	and c                           ; 2966
	cp #0xff                        ; 2967
	ld a,#0x00                      ; 2969
	jr z,loc_297C                   ; 296B
	push hl                         ; 296D
	call sub_2A03                   ; 296E
	ld bc,(player_C0B1)                ; 2971
	and c                           ; 2975
	pop hl                          ; 2976
	jr z,loc_2961                   ; 2977
	ld a,(player_C0B2)                 ; 2979
loc_297C:
	ld hl,#player_CF20                 ; 297C
	or (hl)                         ; 297F
	ld (hl),a                       ; 2980
	ret                             ; 2981

;; ---------------------------------------------------------------- $02982
;; classement : atteinte uniquement par task1
	.area _B00_2982
sub_2982:
	push hl                         ; 2982
	push de                         ; 2983
	push bc                         ; 2984
	ld a,(player_state)             ; 2985
	cpl                             ; 2988
	add a,a                         ; 2989
	ld l,a                          ; 298A
	ld h,#0x00                      ; 298B
	ld de,#sub_29AC                 ; 298D
	add hl,de                       ; 2990
	ld e,(hl)                       ; 2991
	inc hl                          ; 2992
	ld d,(hl)                       ; 2993
	ex de,hl                        ; 2994
	ld bc,(player_CEF6)                ; 2995
loc_2999:
	ld a,(hl)                       ; 2999
	cp #0xff                        ; 299A
	jr z,loc_29A8                   ; 299C
	cp c                            ; 299E
	jr nz,loc_29A5                  ; 299F
	or #0xff                        ; 29A1
	jr loc_29A8                     ; 29A3
loc_29A5:
	inc hl                          ; 29A5
	jr loc_2999                     ; 29A6
loc_29A8:
	pop bc                          ; 29A8
	pop de                          ; 29A9
	pop hl                          ; 29AA
	ret                             ; 29AB

;; ---------------------------------------------------------------- $029AC
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_29AC
sub_29AC:
	or d                            ; 29AC
	add hl,hl                       ; 29AD
	or a                            ; 29AE
	add hl,hl                       ; 29AF
	cp e                            ; 29B0
	add hl,hl                       ; 29B1
	ld c,#0x12                      ; 29B2
	inc e                           ; 29B4
	inc l                           ; 29B5
	rst 0x38                        ; 29B6

;; ---------------------------------------------------------------- $029B7
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_29B7
sub_29B7:
	ld a,(de)                       ; 29B7
	inc c                           ; 29B8
	ld e,#0xff                      ; 29B9
	inc c                           ; 29BB
	ld (de),a                       ; 29BC
	djnz loc_29D7                   ; 29BD
	inc e                           ; 29BF
	ld (0x2e28),hl                  ; 29C0
	inc (hl)                        ; 29C3
	rst 0x38                        ; 29C4

;; ---------------------------------------------------------------- $02BE4
;; classement : atteinte uniquement par task1
	.area _B00_2BE4
sub_2BE4::
	ld ix,#actor_CB07                 ; 2BE4
	ld b,#0x04                      ; 2BE8
	jr loc_2BEC                     ; 2BEA
loc_2BEC:
	ld a,(player_CEFC)                 ; 2BEC
	and #0x84                       ; 2BEF
	ret nz                          ; 2BF1
	call sub_2090                   ; 2BF2
	ld a,(hl)                       ; 2BF5
	inc hl                          ; 2BF6
	ld c,(hl)                       ; 2BF7
	dec hl                          ; 2BF8
	or c                            ; 2BF9
	ret z                           ; 2BFA
loc_2BFB:
	push bc                         ; 2BFB
	push hl                         ; 2BFC
	ld a,0(ix)                      ; 2BFD
	or a                            ; 2C00
	jr z,loc_2C6B                   ; 2C01
	bit 1,34(ix)                    ; 2C03
	jr nz,loc_2C6B                  ; 2C07
	ld a,13(ix)                     ; 2C09
	or 14(ix)                       ; 2C0C
	jr nz,loc_2C6B                  ; 2C0F
	ld a,e                          ; 2C11
	sub 5(ix)                       ; 2C12
	jp p,loc_2C1A                   ; 2C15
	neg                             ; 2C18
loc_2C1A:
	cp #0x80                        ; 2C1A
	jr nc,loc_2C6B                  ; 2C1C
	ld c,a                          ; 2C1E
	ld a,d                          ; 2C1F
	sub 2(ix)                       ; 2C20
	jp p,loc_2C28                   ; 2C23
	neg                             ; 2C26
loc_2C28:
	cp #0x80                        ; 2C28
	jp nc,loc_2C6B                  ; 2C2A
	ld b,a                          ; 2C2D
	ld a,(hl)                       ; 2C2E
	add a,11(ix)                    ; 2C2F
	cp b                            ; 2C32
	jr c,loc_2C6B                   ; 2C33
	inc hl                          ; 2C35
	ld a,(hl)                       ; 2C36
	add a,12(ix)                    ; 2C37
	cp c                            ; 2C3A
	jr c,loc_2C6B                   ; 2C3B
	ld a,0(ix)                      ; 2C3D
	ld hl,#sub_2C75                 ; 2C40
	call sub_481F                   ; 2C43
	jr z,loc_2C4F                   ; 2C46
	ld a,(player_CEF6)                 ; 2C48
	cp #0x04                        ; 2C4B
	jr nz,loc_2C6B                  ; 2C4D
loc_2C4F:
	ld a,(player_CEF4)                 ; 2C4F
	cp 5(ix)                        ; 2C52
	jr c,loc_2C5D                   ; 2C55
	set 0,13(ix)                    ; 2C57
	jr loc_2C61                     ; 2C5B
loc_2C5D:
	set 1,13(ix)                    ; 2C5D
loc_2C61:
	ld 15(ix),#0x00                 ; 2C61
	call sub_055B                   ; 2C65
	pop hl                          ; 2C68
	pop bc                          ; 2C69
	ret                             ; 2C6A
loc_2C6B:
	ld bc,#0x0028                   ; 2C6B
	add ix,bc                       ; 2C6E
	pop hl                          ; 2C70
	pop bc                          ; 2C71
	djnz loc_2BFB                   ; 2C72
	ret                             ; 2C74

;; ---------------------------------------------------------------- $02C75
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_2C75
sub_2C75:
	inc l                           ; 2C75
	dec l                           ; 2C76
	ld l,#0x72                      ; 2C77
	ld (hl),e                       ; 2C79
	rst 0x38                        ; 2C7A

;; ---------------------------------------------------------------- $02E1C
;; classement : atteinte uniquement par task1
	.area _B00_2E1C
sub_2E1C:
	ld hl,#data_5000                ; 2E1C
	ld (tmp_d3),hl                  ; 2E1F
	ld a,(player_state)             ; 2E22
	cpl                             ; 2E25
	ld l,a                          ; 2E26
	ld de,#jt_2E2D                  ; 2E27
	jp util_jump_table              ; 2E2A
jt_2E2D:
	.dw loc_2E33                    ; 2E2D
	.dw loc_2E3C                    ; 2E2F
	.dw loc_2EDB                    ; 2E31
loc_2E33:
	ld a,(player_CEF6)                 ; 2E33
	cp #0x14                        ; 2E36
	jr nz,loc_2E49                  ; 2E38
	jr loc_2E43                     ; 2E3A
loc_2E3C:
	ld a,(player_CEF6)                 ; 2E3C
	cp #0x0e                        ; 2E3F
	jr nz,loc_2E49                  ; 2E41
loc_2E43:
	ld hl,#data_6800                ; 2E43
	ld (tmp_d3),hl                  ; 2E46
loc_2E49:
	ld hl,#0x0000                   ; 2E49
	ld (player_C0B6),hl                ; 2E4C
	ld hl,(player_CEFF)                ; 2E4F
	bit 7,h                         ; 2E52
	jr nz,loc_2EBA                  ; 2E54
	ld a,l                          ; 2E56
	or h                            ; 2E57
	jr nz,loc_2E99                  ; 2E58
	ld a,(player_CF06)                 ; 2E5A
	or a                            ; 2E5D
	jr nz,loc_2E99                  ; 2E5E
	ld a,(player_C19F)                 ; 2E60
	or a                            ; 2E63
	jr nz,loc_2E75                  ; 2E64
	ld hl,(player_CEF0)                ; 2E66
	ld de,#0x6000                   ; 2E69
	or a                            ; 2E6C
	sbc hl,de                       ; 2E6D
	ret nc                          ; 2E6F
	ld a,#0x01                      ; 2E70
	ld (player_C19F),a                 ; 2E72
loc_2E75:
	ld a,(scroll_C0B0)                 ; 2E75
	bit 0,a                         ; 2E78
	jr z,loc_2E81                   ; 2E7A
loc_2E7C:
	xor a                           ; 2E7C
	ld (player_C19F),a                 ; 2E7D
	ret                             ; 2E80
loc_2E81:
	ld hl,(player_CEF0)                ; 2E81
	ld de,#0x7000                   ; 2E84
	or a                            ; 2E87
	sbc hl,de                       ; 2E88
	jr nc,loc_2E7C                  ; 2E8A
	ld hl,#scroll_FC00                 ; 2E8C
	ld (player_C0B6),hl                ; 2E8F
	ld hl,#data_0400                ; 2E92
	ld (player_CEFF),hl                ; 2E95
	ret                             ; 2E98
loc_2E99:
	xor a                           ; 2E99
	ld (player_C19F),a                 ; 2E9A
	ld a,(scroll_C0B0)                 ; 2E9D
	bit 1,a                         ; 2EA0
	ret nz                          ; 2EA2
	ld hl,(player_CEF0)                ; 2EA3
	ld de,#0x7000                   ; 2EA6
	or a                            ; 2EA9
	sbc hl,de                       ; 2EAA
	ret c                           ; 2EAC
	ld hl,(player_CEFF)                ; 2EAD
	ld (player_C0B6),hl                ; 2EB0
	ld hl,#0x0000                   ; 2EB3
	ld (player_CEFF),hl                ; 2EB6
	ret                             ; 2EB9
loc_2EBA:
	xor a                           ; 2EBA
	ld (player_C19F),a                 ; 2EBB
	ld a,(scroll_C0B0)                 ; 2EBE
	bit 0,a                         ; 2EC1
	ret nz                          ; 2EC3
	ld hl,(player_CEF0)                ; 2EC4
	ld de,(tmp_d3)                  ; 2EC7
	or a                            ; 2ECB
	sbc hl,de                       ; 2ECC
	ret nc                          ; 2ECE
	ld hl,(player_CEFF)                ; 2ECF
	ld (player_C0B6),hl                ; 2ED2
	ld hl,#0x0000                   ; 2ED5
	ld (player_CEFF),hl                ; 2ED8
loc_2EDB:
	ret                             ; 2EDB

;; ---------------------------------------------------------------- $02EDC
;; classement : ecrit la structure du joueur ($CEEF)
	.area _B00_2EDC
sub_2EDC::
	ld hl,(player_CF01)                ; 2EDC
	ld a,l                          ; 2EDF
	or h                            ; 2EE0
	ret z                           ; 2EE1
	bit 7,h                         ; 2EE2
	ld a,(player_CF20)                 ; 2EE4
	jr nz,loc_2EF3                  ; 2EE7
	bit 3,a                         ; 2EE9
	ret z                           ; 2EEB
	ld hl,#0x0000                   ; 2EEC
	ld (player_CF01),hl                ; 2EEF
	ret                             ; 2EF2
loc_2EF3:
	bit 2,a                         ; 2EF3
	ret z                           ; 2EF5
	ld hl,#0x0000                   ; 2EF6
	ld (player_CF01),hl                ; 2EF9
	ret                             ; 2EFC

;; ---------------------------------------------------------------- $02F16
;; classement : atteinte uniquement par task1
	.area _B00_2F16
sub_2F16:
	ld a,(flow_C1B1)                 ; 2F16
	or a                            ; 2F19
	ret nz                          ; 2F1A
	ld a,#0x12                      ; 2F1B
	ld (bank_slot2_shadow),a        ; 2F1D
	ld (MAPPER_SLOT2),a             ; 2F20  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(scene_id)                ; 2F23
	ld h,#0x00                      ; 2F26
	ld de,#data_b18_B0EE            ; 2F28
	add hl,de                       ; 2F2B
	ld a,(hl)                       ; 2F2C
	ld (flow_C1B1),a                 ; 2F2D
	ret                             ; 2F30

;; ---------------------------------------------------------------- $03123
;; classement : ecrit la structure du joueur ($CEEF)
	.area _B00_3123
sub_3123::
	ld a,#0x98                      ; 3123
	ld (tmp_d3),a                   ; 3125
	ld a,(scene_id)                 ; 3128
	cp #0x32                        ; 312B
	jr z,loc_3138                   ; 312D
	cp #0x38                        ; 312F
	jr z,loc_3138                   ; 3131
	ld a,#0x96                      ; 3133
	ld (tmp_d3),a                   ; 3135
loc_3138:
	ld hl,(player_CEFF)                ; 3138
	ld de,(player_CEF0)                ; 313B
	add hl,de                       ; 313F
	ld (player_CEF0),hl                ; 3140
	ld hl,(player_CF01)                ; 3143
	ld de,(player_CEF3)                ; 3146
	add hl,de                       ; 314A
	ld de,(player_C0CE)                ; 314B
	add hl,de                       ; 314F
	ld (player_CEF3),hl                ; 3150
	ld hl,#player_CF20                 ; 3153
	ld (hl),#0x00                   ; 3156
	ld a,(player_CF06)                 ; 3158
	or a                            ; 315B
	jr z,loc_3162                   ; 315C
	set 1,(hl)                      ; 315E
	jr loc_3176                     ; 3160
loc_3162:
	ld a,(player_CEF1)                 ; 3162
	ld hl,(tmp_d3)                  ; 3165
	cp l                            ; 3168
	jr c,loc_3176                   ; 3169
	ld hl,#player_CF20                 ; 316B
	set 1,(hl)                      ; 316E
	ld a,(tmp_d3)                   ; 3170
	ld (player_CEF1),a                 ; 3173
loc_3176:
	ld a,(player_CEF4)                 ; 3176
	cp #0xc5                        ; 3179
	jr c,loc_3185                   ; 317B
	set 3,(hl)                      ; 317D
	ld a,#0xc5                      ; 317F
	ld (player_CEF4),a                 ; 3181
	ret                             ; 3184
loc_3185:
	cp #0x3a                        ; 3185
	ret nc                          ; 3187
	set 2,(hl)                      ; 3188
	ld a,#0x3a                      ; 318A
	ld (player_CEF4),a                 ; 318C
	ret                             ; 318F

;; ---------------------------------------------------------------- $03C1D
;; classement : atteinte uniquement par task1
	.area _B00_3C1D
sub_3C1D::
	ld iy,#player_CD37                 ; 3C1D
	ld b,#0x02                      ; 3C21
	ld hl,#actor_CBA7                 ; 3C23
	ld (tmp_d3),hl                  ; 3C26
	ld a,#0x0a                      ; 3C29
	ld (tmp_d5),a                   ; 3C2B
	jr loc_3C41                     ; 3C2E

;; ---------------------------------------------------------------- $03C30
;; classement : atteinte uniquement par task1
	.area _B00_3C30
sub_3C30::
	ld iy,#player_CD37                 ; 3C30
	ld b,#0x02                      ; 3C34
	ld hl,#actor_CDD7                 ; 3C36
	ld (tmp_d3),hl                  ; 3C39
	ld a,#0x07                      ; 3C3C
	ld (tmp_d5),a                   ; 3C3E
loc_3C41:
	push bc                         ; 3C41
	ld hl,(tmp_d3)                  ; 3C42
	push hl                         ; 3C45
	pop ix                          ; 3C46
	ld a,(tmp_d5)                   ; 3C48
	ld b,a                          ; 3C4B
	ld a,0(iy)                      ; 3C4C
	or a                            ; 3C4F
	jp z,loc_3DAF                   ; 3C50
	ld a,20(iy)                     ; 3C53
	or a                            ; 3C56
	jp z,loc_3DAF                   ; 3C57
	ld a,7(iy)                      ; 3C5A
	sub #0x23                       ; 3C5D
	ld de,#data_3BE9                ; 3C5F
	call sub_3DBA                   ; 3C62
loc_3C65:
	push bc                         ; 3C65
	push hl                         ; 3C66
	ld a,0(ix)                      ; 3C67
	or a                            ; 3C6A
	jp z,loc_3DA4                   ; 3C6B
	cp #0x92                        ; 3C6E
	jp nc,loc_3DA4                  ; 3C70
	ld a,13(ix)                     ; 3C73
	or 14(ix)                       ; 3C76
	jp nz,loc_3DA4                  ; 3C79
	ld a,12(ix)                     ; 3C7C
	or 11(ix)                       ; 3C7F
	jp z,loc_3DA4                   ; 3C82
	ld a,e                          ; 3C85
	sub 5(ix)                       ; 3C86
	jp p,loc_3C8E                   ; 3C89
	neg                             ; 3C8C
loc_3C8E:
	cp #0x80                        ; 3C8E
	jp nc,loc_3DA4                  ; 3C90
	ld c,a                          ; 3C93
	ld a,d                          ; 3C94
	sub 2(ix)                       ; 3C95
	jp p,loc_3C9D                   ; 3C98
	neg                             ; 3C9B
loc_3C9D:
	cp #0x80                        ; 3C9D
	jp nc,loc_3DA4                  ; 3C9F
	ld b,a                          ; 3CA2
	ld a,(hl)                       ; 3CA3
	add a,11(ix)                    ; 3CA4
	cp b                            ; 3CA7
	jp c,loc_3DA4                   ; 3CA8
	inc hl                          ; 3CAB
	ld a,(hl)                       ; 3CAC
	add a,12(ix)                    ; 3CAD
	cp c                            ; 3CB0
	jp c,loc_3DA4                   ; 3CB1
	push de                         ; 3CB4
	ld a,0(iy)                      ; 3CB5
	sub #0xf1                       ; 3CB8
	ld l,a                          ; 3CBA
	ld h,#0x00                      ; 3CBB
	ld de,#jt_3CC3                  ; 3CBD
	jp util_jump_table              ; 3CC0
jt_3CC3:
	.dw loc_3D6C                    ; 3CC3
	.dw loc_3D6C                    ; 3CC5
	.dw loc_3CDB                    ; 3CC7
	.dw loc_3CDB                    ; 3CC9
	.dw loc_3D6C                    ; 3CCB
	.dw loc_3D6C                    ; 3CCD
	.dw loc_3D6C                    ; 3CCF
	.dw loc_3D6C                    ; 3CD1
	.dw loc_3D47                    ; 3CD3
	.dw loc_3D47                    ; 3CD5
	.dw loc_3D6C                    ; 3CD7
	.dw loc_3D6C                    ; 3CD9
loc_3CDB:
	pop de                          ; 3CDB
	bit 1,34(ix)                    ; 3CDC
	jr z,loc_3D2F                   ; 3CE0
	ld a,0(ix)                      ; 3CE2
	cp #0x76                        ; 3CE5
	jp nz,loc_3D93                  ; 3CE7
	res 1,34(ix)                    ; 3CEA
	ld a,7(ix)                      ; 3CEE
	sub #0x04                       ; 3CF1
	ld 7(ix),a                      ; 3CF3
	ld 8(ix),#0x00                  ; 3CF6
	ld 9(ix),#0x00                  ; 3CFA
	ld de,#data_0193                ; 3CFE
	ld l,29(ix)                     ; 3D01
	ld h,30(ix)                     ; 3D04
	ld a,l                          ; 3D07
	or h                            ; 3D08
	jr z,loc_3D16                   ; 3D09
	or a                            ; 3D0B
	sbc hl,de                       ; 3D0C
	ld 29(ix),l                     ; 3D0E
	ld 30(ix),h                     ; 3D11
	jr loc_3D25                     ; 3D14
loc_3D16:
	ld l,27(ix)                     ; 3D16
	ld h,28(ix)                     ; 3D19
	or a                            ; 3D1C
	sbc hl,de                       ; 3D1D
	ld 27(ix),l                     ; 3D1F
	ld 28(ix),h                     ; 3D22
loc_3D25:
	ld 0(ix),#0x74                  ; 3D25
	ld hl,#0x0100                   ; 3D29
	ld (actor_C0D1),hl                ; 3D2C
loc_3D2F:
	call sub_2082                   ; 3D2F
	ld a,5(iy)                      ; 3D32
	cp 5(ix)                        ; 3D35
	jr c,loc_3D40                   ; 3D38
	set 0,13(ix)                    ; 3D3A
	jr loc_3D44                     ; 3D3E
loc_3D40:
	set 1,13(ix)                    ; 3D40
loc_3D44:
	jp loc_3D88                     ; 3D44
loc_3D47:
	pop de                          ; 3D47
	bit 1,34(ix)                    ; 3D48
	jr z,loc_3D54                   ; 3D4C
	bit 2,34(ix)                    ; 3D4E
	jr nz,loc_3D93                  ; 3D52
loc_3D54:
	call sub_2082                   ; 3D54
	ld a,5(iy)                      ; 3D57
	cp 5(ix)                        ; 3D5A
	jr c,loc_3D65                   ; 3D5D
	set 0,13(ix)                    ; 3D5F
	jr loc_3D69                     ; 3D63
loc_3D65:
	set 1,13(ix)                    ; 3D65
loc_3D69:
	jp loc_3D88                     ; 3D69
loc_3D6C:
	pop de                          ; 3D6C
	bit 1,34(ix)                    ; 3D6D
	jr nz,loc_3D93                  ; 3D71
	call sub_2082                   ; 3D73
	ld a,5(iy)                      ; 3D76
	cp 5(ix)                        ; 3D79
	jr c,loc_3D84                   ; 3D7C
	set 0,13(ix)                    ; 3D7E
	jr loc_3D88                     ; 3D82
loc_3D84:
	set 1,13(ix)                    ; 3D84
loc_3D88:
	ld a,0(iy)                      ; 3D88
	cp #0xfb                        ; 3D8B
	jr z,loc_3D93                   ; 3D8D
	cp #0xfc                        ; 3D8F
	jr nz,loc_3DA0                  ; 3D91
loc_3D93:
	bit 1,34(iy)                    ; 3D93
	jr nz,loc_3DA4                  ; 3D97
	xor a                           ; 3D99
	ld 0(iy),a                      ; 3D9A
	ld (player_CF17),a                 ; 3D9D
loc_3DA0:
	pop hl                          ; 3DA0
	pop bc                          ; 3DA1
	jr loc_3DAF                     ; 3DA2
loc_3DA4:
	ld bc,#0x0028                   ; 3DA4
	add ix,bc                       ; 3DA7
	pop hl                          ; 3DA9
	pop bc                          ; 3DAA
	dec b                           ; 3DAB
	jp nz,loc_3C65                  ; 3DAC
loc_3DAF:
	ld bc,#0x0028                   ; 3DAF
	add iy,bc                       ; 3DB2
	pop bc                          ; 3DB4
	dec b                           ; 3DB5
	jp nz,loc_3C41                  ; 3DB6
	ret                             ; 3DB9

;; ---------------------------------------------------------------- $03DBA
;; classement : racines du meme module : task1+tbl_3CC3
	.area _B00_3DBA
sub_3DBA:
	add a,a                         ; 3DBA
	ld l,a                          ; 3DBB
	ld h,#0x00                      ; 3DBC
	add hl,de                       ; 3DBE
	ld e,(hl)                       ; 3DBF
	inc hl                          ; 3DC0
	ld d,(hl)                       ; 3DC1
	ex de,hl                        ; 3DC2
	ld a,2(iy)                      ; 3DC3
	add a,(hl)                      ; 3DC6
	ld d,a                          ; 3DC7
	inc hl                          ; 3DC8
	ld a,5(iy)                      ; 3DC9
	add a,(hl)                      ; 3DCC
	ld e,a                          ; 3DCD
	inc hl                          ; 3DCE
	ret                             ; 3DCF

;; ---------------------------------------------------------------- $0569A
;; classement : ecrit la structure du joueur ($CEEF)
	.area _B01_569A
sub_569A::
	add hl,de                       ; 569A
	bit 7,d                         ; 569B
	jr nz,loc_56A8                  ; 569D
	ld a,l                          ; 569F
	sub #0xe0                       ; 56A0
	jr c,loc_56C9                   ; 56A2
	ld l,a                          ; 56A4
	inc h                           ; 56A5
	jr loc_56C9                     ; 56A6
loc_56A8:
	bit 7,h                         ; 56A8
	jr z,loc_56B6                   ; 56AA
	ld de,(player_CEF1)                ; 56AC
	add hl,de                       ; 56B0
	ld (player_CEF1),hl                ; 56B1
	jr loc_56C1                     ; 56B4
loc_56B6:
	ld a,l                          ; 56B6
	cp #0xe0                        ; 56B7
	jr c,loc_56C9                   ; 56B9
	ld l,#0xe0                      ; 56BB
	add a,l                         ; 56BD
	ld l,a                          ; 56BE
	jr loc_56C9                     ; 56BF
loc_56C1:
	ld hl,#0x0000                   ; 56C1
	jr loc_56C9                     ; 56C4
	.db 0x21, 0xd0, 0x01            ; 56C6
loc_56C9:
	ret                             ; 56C9

;; ---------------------------------------------------------------- $05B50
;; classement : atteinte uniquement par task1
	.area _B01_5B50
sub_5B50:
	ld iy,#player_CD37                 ; 5B50
	ld b,#0x02                      ; 5B54
loc_5B56:
	push bc                         ; 5B56
	ld a,0(iy)                      ; 5B57
	or a                            ; 5B5A
	jp z,loc_5BAD                   ; 5B5B
	ld a,7(iy)                      ; 5B5E
	sub #0x23                       ; 5B61
	add a,a                         ; 5B63
	ld l,a                          ; 5B64
	ld h,#0x00                      ; 5B65
	ld a,#0x12                      ; 5B67
	ld (bank_slot2_shadow),a        ; 5B69
	ld (MAPPER_SLOT2),a             ; 5B6C  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b18_BEFD            ; 5B6F
	add hl,de                       ; 5B72
	ld e,(hl)                       ; 5B73
	inc hl                          ; 5B74
	ld d,(hl)                       ; 5B75
	ex de,hl                        ; 5B76
	ld a,(hl)                       ; 5B77
	cp #0xff                        ; 5B78
	jr z,loc_5BAD                   ; 5B7A
	ld b,(hl)                       ; 5B7C
	inc hl                          ; 5B7D
	ld c,(hl)                       ; 5B7E
	inc hl                          ; 5B7F
	push hl                         ; 5B80
	ld hl,(player_C435)                ; 5B81
	call sub_29C5                   ; 5B84
	pop hl                          ; 5B87
	jr nz,loc_5BAD                  ; 5B88
	xor a                           ; 5B8A
	ld (player_C1C0),a                 ; 5B8B
loc_5B8E:
	ld a,#0x12                      ; 5B8E
	ld (bank_slot2_shadow),a        ; 5B90
	ld (MAPPER_SLOT2),a             ; 5B93  mapper : banque du slot 2 ($8000-$BFFF)
	ld a,(hl)                       ; 5B96
	cp #0xff                        ; 5B97
	jr z,loc_5BAD                   ; 5B99
	inc hl                          ; 5B9B
	ld c,a                          ; 5B9C
	ld b,(hl)                       ; 5B9D
	inc hl                          ; 5B9E
	push hl                         ; 5B9F
	push iy                         ; 5BA0
	call sub_5BDE                   ; 5BA2
	pop iy                          ; 5BA5
	call sub_5BB8                   ; 5BA7
	pop hl                          ; 5BAA
	jr z,loc_5B8E                   ; 5BAB
loc_5BAD:
	pop bc                          ; 5BAD
	ld de,#0x0028                   ; 5BAE
	add iy,de                       ; 5BB1
	dec b                           ; 5BB3
	jp nz,loc_5B56                  ; 5BB4
	ret                             ; 5BB7

;; ---------------------------------------------------------------- $05BB8
;; classement : atteinte uniquement par task1
	.area _B01_5BB8
sub_5BB8:
	ld a,(player_C1C0)                 ; 5BB8
	or a                            ; 5BBB
	ret z                           ; 5BBC
	ld b,a                          ; 5BBD
	ld a,0(iy)                      ; 5BBE
	and #0xfe                       ; 5BC1
	sub #0xf1                       ; 5BC3
	ld l,a                          ; 5BC5
	ld h,#0x00                      ; 5BC6
	ld a,#0x12                      ; 5BC8
	ld (bank_slot2_shadow),a        ; 5BCA
	ld (MAPPER_SLOT2),a             ; 5BCD  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b18_BDD3            ; 5BD0
	add hl,de                       ; 5BD3
	ld a,(hl)                       ; 5BD4
	and b                           ; 5BD5
	ret z                           ; 5BD6
	ld 0(iy),#0x00                  ; 5BD7
	or #0xff                        ; 5BDB
	ret                             ; 5BDD

;; ---------------------------------------------------------------- $05BDE
;; classement : atteinte uniquement par task1
	.area _B01_5BDE
sub_5BDE:
	ld (coll_C18C),bc                ; 5BDE
	call sub_2A03                   ; 5BE2
	ld b,a                          ; 5BE5
	ld a,#0xa0                      ; 5BE6
	and b                           ; 5BE8
	ld (player_C1C0),a                 ; 5BE9
	ld a,b                          ; 5BEC
	and #0x1f                       ; 5BED
	cp #0x01                        ; 5BEF
	ret nz                          ; 5BF1
	ld a,(player_C1C0)                 ; 5BF2
	set 0,a                         ; 5BF5
	ld (player_C1C0),a                 ; 5BF7
	ld a,0(iy)                      ; 5BFA
	sub #0xf1                       ; 5BFD
	and #0xfe                       ; 5BFF
	ld l,a                          ; 5C01
	ld h,#0x00                      ; 5C02
	ld a,#0x12                      ; 5C04
	ld (bank_slot2_shadow),a        ; 5C06
	ld (MAPPER_SLOT2),a             ; 5C09  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b18_B682            ; 5C0C
	add hl,de                       ; 5C0F
	ld e,(hl)                       ; 5C10
	inc hl                          ; 5C11
	ld d,(hl)                       ; 5C12
	ld hl,(scene_id)                ; 5C13
	ld h,#0x00                      ; 5C16
	add hl,hl                       ; 5C18
	add hl,de                       ; 5C19
	ld e,(hl)                       ; 5C1A
	inc hl                          ; 5C1B
	ld d,(hl)                       ; 5C1C
	ld hl,(player_C196)                ; 5C1D
	ld a,(hl)                       ; 5C20
	ex de,hl                        ; 5C21
	jp loc_5C52                     ; 5C22

;; ---------------------------------------------------------------- $081A0
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_81A0
sub_b02_81A0:
	nop                             ; 81A0
	add a,b                         ; 81A1
data_b02_81A2:
	add a,b                         ; 81A2
	ld bc,#0x0280                   ; 81A3
	nop                             ; 81A6
	inc bc                          ; 81A7
	nop                             ; 81A8
	inc bc                          ; 81A9
	nop                             ; 81AA
	inc bc                          ; 81AB
	nop                             ; 81AC
	inc bc                          ; 81AD
	nop                             ; 81AE
	add a,b                         ; 81AF
	ld hl,#joypad_state             ; 81B0
	ld a,(hl)                       ; 81B3
	and #0x0e                       ; 81B4
	jr z,loc_b02_822C               ; 81B6
	ld a,(joypad_pressed)           ; 81B8
	bit 5,a                         ; 81BB
	jr nz,loc_b02_8204              ; 81BD
	bit 4,a                         ; 81BF
	jr z,loc_b02_81CE               ; 81C1
	ld a,(joypad_state)             ; 81C3
	bit 1,a                         ; 81C6
	jp z,loc_b02_84E9               ; 81C8
	jp loc_b02_885A                 ; 81CB
loc_b02_81CE:
	ld hl,#joypad_state             ; 81CE
	bit 1,(hl)                      ; 81D1
	jr nz,loc_b02_81DD              ; 81D3
	bit 4,(hl)                      ; 81D5
	jp nz,loc_b02_86A1              ; 81D7
	jp loc_b02_87CC                 ; 81DA
loc_b02_81DD:
	ld 7(iy),#0x10                  ; 81DD
	ld 9(iy),#0x00                  ; 81E1
	ld 8(iy),#0x00                  ; 81E5
	ld 10(iy),#0x00                 ; 81E9
	ld 9(iy),#0x01                  ; 81ED
	ld hl,#data_b02_810E            ; 81F1
	ld (player_CF11),hl                ; 81F4
	ld (player_CF13),hl                ; 81F7
	ld hl,#0x0000                   ; 81FA
	ld (player_CF01),hl                ; 81FD
	ld (player_CEFF),hl                ; 8200
	ret                             ; 8203
loc_b02_8204:
	bit 4,(hl)                      ; 8204
	jr nz,loc_b02_821A              ; 8206
	ld hl,#data_b02_8126            ; 8208
	ld (player_CF13),hl                ; 820B
	ld hl,#data_b02_8156            ; 820E
	ld (player_CF11),hl                ; 8211
	call sub_0556                   ; 8214
	jp loc_b02_882B                 ; 8217
loc_b02_821A:
	ld hl,#data_b02_813C            ; 821A
	ld (player_CF13),hl                ; 821D
	ld hl,#data_b02_815A            ; 8220
	ld (player_CF11),hl                ; 8223
	call sub_0551                   ; 8226
	jp loc_b02_882B                 ; 8229
loc_b02_822C:
	ld a,(joypad_pressed)           ; 822C
	bit 5,a                         ; 822F
	jr z,loc_b02_8245               ; 8231
	ld hl,#data_b02_8126            ; 8233
	ld (player_CF13),hl                ; 8236
	ld hl,#data_b02_810E            ; 8239
	ld (player_CF11),hl                ; 823C
	call sub_0556                   ; 823F
	jp loc_b02_882B                 ; 8242
loc_b02_8245:
	ld a,(joypad_pressed)           ; 8245
	bit 4,a                         ; 8248
	jr z,loc_b02_8257               ; 824A
	ld a,(joypad_state)             ; 824C
	bit 1,a                         ; 824F
	jp z,loc_b02_84E9               ; 8251
	jp loc_b02_885A                 ; 8254
loc_b02_8257:
	ld a,(player_CEF9)                 ; 8257
	or a                            ; 825A
	ret z                           ; 825B
	ld a,(joypad_state)             ; 825C
	bit 1,a                         ; 825F
	jp nz,loc_b02_81DD              ; 8261
	jp loc_b02_89CC                 ; 8264

;; ---------------------------------------------------------------- $08267
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8267
sub_b02_8267:
	ld hl,(player_CF11)                ; 8267
	ld de,#0x8110                   ; 826A
	or a                            ; 826D
	sbc hl,de                       ; 826E
	jr nz,loc_b02_8282              ; 8270
	ld a,(joypad_state)             ; 8272
	and #0x0c                       ; 8275
	jr z,loc_b02_829A               ; 8277
	ld de,#data_b02_80F6            ; 8279
	ld (player_CF11),de                ; 827C
	jr loc_b02_829A                 ; 8280
loc_b02_8282:
	ld a,(joypad_state)             ; 8282
	and #0x0c                       ; 8285
	jr z,loc_b02_8293               ; 8287
	ld a,(player_CF21)                 ; 8289
	ld bc,(tmp_d3)                  ; 828C
	cp c                            ; 8290
	jr z,loc_b02_829A               ; 8291
loc_b02_8293:
	ld de,#data_b02_817C            ; 8293
	ld (player_CF11),de                ; 8296
loc_b02_829A:
	call sub_b02_86C7               ; 829A
	ld hl,(player_CF13)                ; 829D
	ld e,(hl)                       ; 82A0
	inc hl                          ; 82A1
	ld d,(hl)                       ; 82A2
	inc hl                          ; 82A3
	push hl                         ; 82A4
	ld hl,#0x8000                   ; 82A5
	or a                            ; 82A8
	sbc hl,de                       ; 82A9
	pop hl                          ; 82AB
	jr nz,loc_b02_82B7              ; 82AC
	ld de,#MAPPER_CTRL              ; 82AE
	add hl,de                       ; 82B1
	ld e,(hl)                       ; 82B2
	inc hl                          ; 82B3
	ld d,(hl)                       ; 82B4
	inc hl                          ; 82B5
	xor a                           ; 82B6
loc_b02_82B7:
	ld (player_CF13),hl                ; 82B7
	ld (player_CEFF),de                ; 82BA
	ld a,(player_CF20)                 ; 82BE
	bit 1,a                         ; 82C1
	jr nz,loc_b02_82FF              ; 82C3
	ld a,(player_CEF6)                 ; 82C5
	cp #0x2c                        ; 82C8
	ret z                           ; 82CA
	ld a,(joypad_pressed)           ; 82CB
	bit 4,a                         ; 82CE
	jr z,loc_b02_8316               ; 82D0
	ld a,#0x01                      ; 82D2
	ld (player_CF25),a                 ; 82D4
	ld a,(joypad_state)             ; 82D7
	bit 0,a                         ; 82DA
	jp z,loc_b02_8768               ; 82DC
	ld a,(player_C1F2)                 ; 82DF
	or a                            ; 82E2
	jp z,loc_b02_8768               ; 82E3
	cp #0x03                        ; 82E6
	jp nz,loc_b02_8843              ; 82E8
	ld a,#0x03                      ; 82EB
	ld (player_CF25),a                 ; 82ED
	ld hl,#game_flags               ; 82F0
	bit 1,(hl)                      ; 82F3
	jp nz,loc_b02_8768              ; 82F5
	xor a                           ; 82F8
	ld (player_C1F2),a                 ; 82F9
	jp loc_b02_8768                 ; 82FC
loc_b02_82FF:
	ld a,(player_CF06)                 ; 82FF
	or a                            ; 8302
	call z,sub_27D3                 ; 8303
	ld a,(joypad_state)             ; 8306
	ld b,a                          ; 8309
	and #0x0c                       ; 830A
	jp nz,loc_b02_87CC              ; 830C
	bit 1,b                         ; 830F
	jp nz,loc_b02_89DC              ; 8311
	jr loc_b02_8317                 ; 8314
loc_b02_8316:
	ret                             ; 8316
loc_b02_8317:
	ld a,(player_CEF6)                 ; 8317
	cp #0x2c                        ; 831A
	jr nz,loc_b02_832F              ; 831C
	ld a,(player_CF25)                 ; 831E
	ld 7(iy),#0x20                  ; 8321
	cp #0x03                        ; 8325
	jr z,loc_b02_8342               ; 8327
	ld 7(iy),#0x26                  ; 8329
	jr loc_b02_8342                 ; 832D
loc_b02_832F:
	ld 7(iy),#0x16                  ; 832F
	ld 9(iy),#0x00                  ; 8333
	ld 8(iy),#0x00                  ; 8337
	ld 10(iy),#0x00                 ; 833B
	call sub_0532                   ; 833F
loc_b02_8342:
	ld hl,#0x0000                   ; 8342
	ld (player_CF11),hl                ; 8345
	ld (player_CF13),hl                ; 8348
	ret                             ; 834B

;; ---------------------------------------------------------------- $0834C
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_834C
sub_b02_834C:
	ld a,(tmp_d3)                   ; 834C
	ld (player_CF21),a                 ; 834F
	ld a,(player_CEF9)                 ; 8352
	or a                            ; 8355
	jp z,loc_b02_836E               ; 8356
	ld a,#0x0e                      ; 8359
	ld (player_CEF6),a                 ; 835B
	ld 9(iy),#0x00                  ; 835E
	ld 8(iy),#0x00                  ; 8362
	ld 10(iy),#0x00                 ; 8366
	ld (player_CEF8),a                 ; 836A
	ret                             ; 836D
loc_b02_836E:
	ld a,(player_CEF7)                 ; 836E
	cp #0x01                        ; 8371
	jp nz,sub_b02_8267              ; 8373
	ld a,(player_CEF8)                 ; 8376
	cp #0x02                        ; 8379
	jp nz,sub_b02_8267              ; 837B
	xor a                           ; 837E
	ld (player_CF04),a                 ; 837F
	call sub_22BF                   ; 8382
	jp sub_b02_8267                 ; 8385

;; ---------------------------------------------------------------- $08388
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8388
sub_b02_8388:
	ld a,(tmp_d3)                   ; 8388
	ld (player_CF21),a                 ; 838B
	ld a,(player_CEF9)                 ; 838E
	or a                            ; 8391
	jr z,loc_b02_83AC               ; 8392
	ld a,#0x0c                      ; 8394
	ld (player_CEF6),a                 ; 8396
	ld 9(iy),#0x00                  ; 8399
	ld 8(iy),#0x00                  ; 839D
	ld 10(iy),#0x00                 ; 83A1
	ld a,#0x01                      ; 83A5
	ld (player_CEF8),a                 ; 83A7
	jr loc_b02_83C3                 ; 83AA
loc_b02_83AC:
	ld a,(player_CEF7)                 ; 83AC
	cp #0x01                        ; 83AF
	jr nz,loc_b02_83C3              ; 83B1
	ld a,(player_CEF8)                 ; 83B3
	cp #0x02                        ; 83B6
	jr nz,loc_b02_83C3              ; 83B8
	xor a                           ; 83BA
	ld (player_CF04),a                 ; 83BB
	call sub_22BF                   ; 83BE
	jr loc_b02_83C3                 ; 83C1
loc_b02_83C3:
	ld hl,(player_CF11)                ; 83C3
	ld de,#0x8110                   ; 83C6
	or a                            ; 83C9
	sbc hl,de                       ; 83CA
	jr nz,loc_b02_83DE              ; 83CC
	ld a,(joypad_state)             ; 83CE
	and #0x0c                       ; 83D1
	jr z,loc_b02_83F6               ; 83D3
	ld de,#data_b02_80F6            ; 83D5
	ld (player_CF11),de                ; 83D8
	jr loc_b02_83F6                 ; 83DC
loc_b02_83DE:
	ld a,(joypad_state)             ; 83DE
	and #0x0c                       ; 83E1
	jr z,loc_b02_83EF               ; 83E3
	ld a,(player_CF21)                 ; 83E5
	ld bc,(tmp_d3)                  ; 83E8
	cp c                            ; 83EC
	jr z,loc_b02_83F6               ; 83ED
loc_b02_83EF:
	ld de,#data_b02_817C            ; 83EF
	ld (player_CF11),de                ; 83F2
loc_b02_83F6:
	call sub_b02_86C7               ; 83F6
	ld a,(player_CEF6)                 ; 83F9
	cp #0x2a                        ; 83FC
	jr z,loc_b02_8434               ; 83FE
	ld a,(joypad_pressed)           ; 8400
	bit 4,a                         ; 8403
	jr z,loc_b02_8434               ; 8405
	ld a,#0x01                      ; 8407
	ld (player_CF25),a                 ; 8409
	ld a,(joypad_state)             ; 840C
	bit 0,a                         ; 840F
	jp z,loc_b02_8779               ; 8411
	ld a,(player_C1F2)                 ; 8414
	or a                            ; 8417
	jp z,loc_b02_8779               ; 8418
	cp #0x03                        ; 841B
	jp nz,loc_b02_8843              ; 841D
	ld a,#0x03                      ; 8420
	ld (player_CF25),a                 ; 8422
	ld hl,#game_flags               ; 8425
	bit 1,(hl)                      ; 8428
	jp nz,loc_b02_8779              ; 842A
	xor a                           ; 842D
	ld (player_C1F2),a                 ; 842E
	jp loc_b02_8779                 ; 8431
loc_b02_8434:
	ld hl,(player_CF13)                ; 8434
	ld e,(hl)                       ; 8437
	inc hl                          ; 8438
	ld d,(hl)                       ; 8439
	inc hl                          ; 843A
	push hl                         ; 843B
	ld hl,#0x8000                   ; 843C
	or a                            ; 843F
	sbc hl,de                       ; 8440
	pop hl                          ; 8442
	jr nz,loc_b02_844E              ; 8443
	ld de,#MAPPER_CTRL              ; 8445
	add hl,de                       ; 8448
	ld e,(hl)                       ; 8449
	inc hl                          ; 844A
	ld d,(hl)                       ; 844B
	inc hl                          ; 844C
	xor a                           ; 844D
loc_b02_844E:
	ld (player_CF13),hl                ; 844E
	ld (player_CEFF),de                ; 8451
	jr z,loc_b02_8482               ; 8455
	ld a,(player_C425)                 ; 8457
	inc a                           ; 845A
	ld (player_C425),a                 ; 845B
	cp #0x00                        ; 845E
	jr c,loc_b02_8476               ; 8460
	dec a                           ; 8462
	ld (player_C425),a                 ; 8463
	ld a,(joypad_state)             ; 8466
	bit 5,a                         ; 8469
	jr nz,loc_b02_8476              ; 846B
	ld hl,#data_b02_8160            ; 846D
	ld (player_CF13),hl                ; 8470
	jp loc_b02_880D                 ; 8473
loc_b02_8476:
	ld a,(player_CF20)                 ; 8476
	bit 0,a                         ; 8479
	ret z                           ; 847B
	ld hl,#0x0000                   ; 847C
	ld (player_CEFF),hl                ; 847F
loc_b02_8482:
	ld a,(player_CEF6)                 ; 8482
	cp #0x2a                        ; 8485
	jp nz,loc_b02_8806              ; 8487
	ld 7(iy),#0x2c                  ; 848A
	ld de,#data_b02_8160            ; 848E
	ld (player_CF13),de                ; 8491
	ret                             ; 8495

;; ---------------------------------------------------------------- $08496
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8496
sub_b02_8496:
	ld a,(player_CF21)                 ; 8496
	ld bc,(tmp_d3)                  ; 8499
	cp c                            ; 849D
	jr z,loc_b02_84A7               ; 849E
	ld de,#data_b02_80C8            ; 84A0
	ld (player_CF11),de                ; 84A3
loc_b02_84A7:
	ld a,(joypad_pressed)           ; 84A7
	bit 5,a                         ; 84AA
	jr z,loc_b02_84C0               ; 84AC
	ld hl,#data_b02_813C            ; 84AE
	ld (player_CF13),hl                ; 84B1
	ld hl,#data_b02_815A            ; 84B4
	ld (player_CF11),hl                ; 84B7
	call sub_0551                   ; 84BA
	jp loc_b02_882B                 ; 84BD
loc_b02_84C0:
	ld a,(joypad_state)             ; 84C0
	bit 1,a                         ; 84C3
	jp nz,loc_b02_8B88              ; 84C5
	call sub_b02_86C7               ; 84C8
	push af                         ; 84CB
	pop bc                          ; 84CC
	ld (tmp_d3),bc                  ; 84CD
	ld bc,(player_CF20)                ; 84D1
	bit 1,c                         ; 84D5
	jr nz,loc_b02_84E2              ; 84D7
	ld hl,#data_b02_8184            ; 84D9
	ld (player_CF11),hl                ; 84DC
	jp loc_b02_8806                 ; 84DF
loc_b02_84E2:
	ld a,(joypad_pressed)           ; 84E2
	bit 4,a                         ; 84E5
	jr z,loc_b02_850C               ; 84E7
loc_b02_84E9:
	ld a,(joypad_state)             ; 84E9
	bit 0,a                         ; 84EC
	jp z,loc_b02_886E               ; 84EE
	ld a,(player_C1F2)                 ; 84F1
	or a                            ; 84F4
	jp z,loc_b02_886E               ; 84F5
	cp #0x03                        ; 84F8
	jp nz,loc_b02_8843              ; 84FA
	ld hl,#game_flags               ; 84FD
	bit 1,(hl)                      ; 8500
	jp nz,loc_b02_884F              ; 8502
	xor a                           ; 8505
	ld (player_C1F2),a                 ; 8506
	jp loc_b02_884F                 ; 8509
loc_b02_850C:
	ld a,(joypad_state)             ; 850C
	and #0x0f                       ; 850F
	cp #0x04                        ; 8511
	jp nc,loc_b02_8522              ; 8513
	ld bc,(tmp_d3)                  ; 8516
	push bc                         ; 851A
	pop af                          ; 851B
	jp z,loc_b02_87C0               ; 851C
	jp loc_b02_87B4                 ; 851F
loc_b02_8522:
	ld a,(joypad_state)             ; 8522
	bit 4,a                         ; 8525
	jp z,loc_b02_87CC               ; 8527
	ret                             ; 852A

;; ---------------------------------------------------------------- $0852B
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_852B
sub_b02_852B:
	ld a,(player_CF21)                 ; 852B
	ld bc,(tmp_d3)                  ; 852E
	cp c                            ; 8532
	jp nz,loc_b02_878A              ; 8533
	call sub_b02_86C7               ; 8536
	jp z,loc_b02_89CC               ; 8539
	ld bc,(player_CF20)                ; 853C
	bit 1,c                         ; 8540
	jr nz,loc_b02_854D              ; 8542
	ld hl,#data_b02_8180            ; 8544
	ld (player_CF11),hl                ; 8547
	jp loc_b02_8806                 ; 854A
loc_b02_854D:
	ld a,(joypad_pressed)           ; 854D
	bit 5,a                         ; 8550
	jr z,loc_b02_8566               ; 8552
	ld hl,#data_b02_8126            ; 8554
	ld (player_CF13),hl                ; 8557
	ld hl,#data_b02_8156            ; 855A
	ld (player_CF11),hl                ; 855D
	call sub_0556                   ; 8560
	jp loc_b02_882B                 ; 8563
loc_b02_8566:
	ld a,(joypad_pressed)           ; 8566
	bit 4,a                         ; 8569
	jp nz,loc_b02_84E9              ; 856B
	ret                             ; 856E

;; ---------------------------------------------------------------- $0856F
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_856F
sub_b02_856F:
	ld a,(tmp_d3)                   ; 856F
	ld (player_CF21),a                 ; 8572
	call sub_b02_86C7               ; 8575
	jp nz,loc_b02_85A9              ; 8578
	ld a,(joypad_state)             ; 857B
	and #0x0c                       ; 857E
	jp z,loc_b02_89CC               ; 8580
	ld 7(iy),#0x04                  ; 8583
	ld de,#data_b02_8102            ; 8587
	ld (player_CF11),de                ; 858A
	call sub_b02_86C7               ; 858E
	ret                             ; 8591

;; ---------------------------------------------------------------- $08592
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8592
sub_b02_8592:
	ld a,(tmp_d3)                   ; 8592
	ld (player_CF21),a                 ; 8595
	call sub_b02_86C7               ; 8598
	jp nz,loc_b02_85A9              ; 859B
	ld a,(joypad_state)             ; 859E
	and #0x0c                       ; 85A1
	jp nz,loc_b02_86A1              ; 85A3
	jp loc_b02_89CC                 ; 85A6
loc_b02_85A9:
	ld bc,(player_CF20)                ; 85A9
	bit 1,c                         ; 85AD
	jr nz,loc_b02_85BA              ; 85AF
	ld hl,#data_b02_8180            ; 85B1
	ld (player_CF11),hl                ; 85B4
	jp loc_b02_8806                 ; 85B7
loc_b02_85BA:
	ld a,(joypad_pressed)           ; 85BA
	bit 5,a                         ; 85BD
	jr z,loc_b02_85D3               ; 85BF
	ld hl,#data_b02_8126            ; 85C1
	ld (player_CF13),hl                ; 85C4
	ld hl,#data_b02_8156            ; 85C7
	ld (player_CF11),hl                ; 85CA
	call sub_0556                   ; 85CD
	jp loc_b02_882B                 ; 85D0
loc_b02_85D3:
	ld a,(joypad_pressed)           ; 85D3
	bit 4,a                         ; 85D6
	jp nz,loc_b02_84E9              ; 85D8
	ld a,(player_CF20)                 ; 85DB
	and #0x0c                       ; 85DE
	ret z                           ; 85E0
	jp loc_b02_87CC                 ; 85E1

;; ---------------------------------------------------------------- $085E4
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_85E4
sub_b02_85E4:
	ld a,(player_CF21)                 ; 85E4
	ld bc,(tmp_d3)                  ; 85E7
	cp c                            ; 85EB
	jp nz,loc_b02_87CC              ; 85EC
	call sub_b02_86C7               ; 85EF
	jp z,loc_b02_89CC               ; 85F2
	ld bc,(player_CF20)                ; 85F5
	bit 1,c                         ; 85F9
	jr nz,loc_b02_8606              ; 85FB
	ld hl,#data_b02_8178            ; 85FD
	ld (player_CF11),hl                ; 8600
	jp loc_b02_8806                 ; 8603
loc_b02_8606:
	ld a,(joypad_pressed)           ; 8606
	bit 5,a                         ; 8609
	jr z,loc_b02_861F               ; 860B
	ld hl,#data_b02_8126            ; 860D
	ld (player_CF13),hl                ; 8610
	ld hl,#data_b02_8156            ; 8613
	ld (player_CF11),hl                ; 8616
	call sub_0556                   ; 8619
	jp loc_b02_882B                 ; 861C
loc_b02_861F:
	ld a,(joypad_state)             ; 861F
	bit 1,a                         ; 8622
	jp nz,loc_b02_89DC              ; 8624
	ld a,(joypad_pressed)           ; 8627
	bit 4,a                         ; 862A
	jp nz,loc_b02_84E9              ; 862C
	ret                             ; 862F

;; ---------------------------------------------------------------- $08630
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8630
sub_b02_8630:
	ld bc,(player_CF20)                ; 8630
	bit 1,c                         ; 8634
	jr nz,loc_b02_8641              ; 8636
	ld hl,#data_b02_8180            ; 8638
	ld (player_CF11),hl                ; 863B
	jp loc_b02_8806                 ; 863E
loc_b02_8641:
	ld a,(joypad_pressed)           ; 8641
	bit 5,a                         ; 8644
	jr z,loc_b02_865A               ; 8646
	ld hl,#data_b02_8126            ; 8648
	ld (player_CF13),hl                ; 864B
	ld hl,#data_b02_8156            ; 864E
	ld (player_CF11),hl                ; 8651
	call sub_0556                   ; 8654
	jp loc_b02_882B                 ; 8657
loc_b02_865A:
	ld a,(player_CF21)                 ; 865A
	ld bc,(tmp_d3)                  ; 865D
	cp c                            ; 8661
	jp nz,loc_b02_87CC              ; 8662
	ld a,(joypad_state)             ; 8665
	bit 1,a                         ; 8668
	jp nz,loc_b02_89DC              ; 866A
	ld a,(joypad_pressed)           ; 866D
	bit 4,a                         ; 8670
	jr z,loc_b02_8697               ; 8672
	ld a,(joypad_state)             ; 8674
	bit 0,a                         ; 8677
	jp z,loc_b02_886E               ; 8679
	ld a,(player_C1F2)                 ; 867C
	or a                            ; 867F
	jp z,loc_b02_886E               ; 8680
	cp #0x03                        ; 8683
	jp nz,loc_b02_8843              ; 8685
	ld hl,#game_flags               ; 8688
	bit 1,(hl)                      ; 868B
	jp nz,loc_b02_884F              ; 868D
	xor a                           ; 8690
	ld (player_C1F2),a                 ; 8691
	jp loc_b02_884F                 ; 8694
loc_b02_8697:
	call sub_b02_86C7               ; 8697
	ld a,(joypad_state)             ; 869A
	bit 4,a                         ; 869D
	jr z,loc_b02_86BC               ; 869F
loc_b02_86A1:
	ld hl,#data_b02_80C8            ; 86A1
	ld (player_CF11),hl                ; 86A4
	ld a,#0x02                      ; 86A7
	ld (player_CEF6),a                 ; 86A9
	call sub_b02_86C7               ; 86AC
	ld 9(iy),#0x00                  ; 86AF
	ld 8(iy),#0x00                  ; 86B3
	ld 10(iy),#0x00                 ; 86B7
	ret                             ; 86BB
loc_b02_86BC:
	ld a,(joypad_state)             ; 86BC
	and #0x0f                       ; 86BF
	cp #0x03                        ; 86C1
	jp c,loc_b02_87B4               ; 86C3
	ret                             ; 86C6

;; ---------------------------------------------------------------- $086C7
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_86C7
sub_b02_86C7:
	ld hl,(player_CF11)                ; 86C7
	ld e,(hl)                       ; 86CA
	inc hl                          ; 86CB
	ld d,(hl)                       ; 86CC
	inc hl                          ; 86CD
	push hl                         ; 86CE
	ld hl,#0x8000                   ; 86CF
	or a                            ; 86D2
	sbc hl,de                       ; 86D3
	pop hl                          ; 86D5
	jr nz,loc_b02_86E1              ; 86D6
	ld de,#MAPPER_CTRL              ; 86D8
	add hl,de                       ; 86DB
	ld e,(hl)                       ; 86DC
	inc hl                          ; 86DD
	ld d,(hl)                       ; 86DE
	inc hl                          ; 86DF
	xor a                           ; 86E0
loc_b02_86E1:
	push af                         ; 86E1
	ld (player_CF11),hl                ; 86E2
	ld a,(player_CF21)                 ; 86E5
	or a                            ; 86E8
	jr z,loc_b02_86F1               ; 86E9
	ld hl,#0x0000                   ; 86EB
	sbc hl,de                       ; 86EE
	ex de,hl                        ; 86F0
loc_b02_86F1:
	ld (player_CF01),de                ; 86F1
	pop af                          ; 86F5
	ret                             ; 86F6

;; ---------------------------------------------------------------- $086F7
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_86F7
sub_b02_86F7:
	ld bc,(player_CF20)                ; 86F7
	bit 1,c                         ; 86FB
	jr nz,loc_b02_8708              ; 86FD
	ld hl,#data_b02_8178            ; 86FF
	ld (player_CF11),hl                ; 8702
	jp loc_b02_8806                 ; 8705
loc_b02_8708:
	ld a,(joypad_pressed)           ; 8708
	bit 5,a                         ; 870B
	jr z,loc_b02_8721               ; 870D
	ld hl,#data_b02_810E            ; 870F
	ld (player_CF11),hl                ; 8712
	ld hl,#data_b02_8126            ; 8715
	ld (player_CF13),hl                ; 8718
	call sub_0556                   ; 871B
	jp loc_b02_882B                 ; 871E
loc_b02_8721:
	ld a,(joypad_pressed)           ; 8721
	bit 4,a                         ; 8724
	jp nz,loc_b02_84E9              ; 8726
	ld a,(joypad_state)             ; 8729
	bit 4,a                         ; 872C
	jr z,loc_b02_8735               ; 872E
	and #0x0c                       ; 8730
	jp nz,loc_b02_86A1              ; 8732
loc_b02_8735:
	ld a,(joypad_state)             ; 8735
	and #0x0f                       ; 8738
	ld de,#jt_b02_8747              ; 873A
	ld l,a                          ; 873D
	ld h,#0x00                      ; 873E
	add hl,hl                       ; 8740
	add hl,de                       ; 8741
	ld e,(hl)                       ; 8742
	inc hl                          ; 8743
	ld d,(hl)                       ; 8744
	ex de,hl                        ; 8745
	jp (hl)                         ; 8746
jt_b02_8747:
	.dw loc_b02_87E7                ; 8747
	.dw loc_b02_8767                ; 8749
	.dw loc_b02_89DC                ; 874B
	.dw loc_b02_89DC                ; 874D
	.dw loc_b02_87CC                ; 874F
	.dw loc_b02_87CC                ; 8751
	.dw loc_b02_89DC                ; 8753
	.dw loc_b02_89DC                ; 8755
	.dw loc_b02_87CC                ; 8757
	.dw loc_b02_87CC                ; 8759
	.dw loc_b02_89DC                ; 875B
	.dw loc_b02_89DC                ; 875D
	.dw loc_b02_87CC                ; 875F
	.dw loc_b02_87CC                ; 8761
	.dw loc_b02_89DC                ; 8763
	.dw loc_b02_89DC                ; 8765
loc_b02_8767:
	ret                             ; 8767
loc_b02_8768:
	ld 7(iy),#0x2c                  ; 8768
	ld 9(iy),#0x00                  ; 876C
	ld 8(iy),#0x00                  ; 8770
	ld 10(iy),#0x00                 ; 8774
	ret                             ; 8778
loc_b02_8779:
	ld 7(iy),#0x2a                  ; 8779
	ld 9(iy),#0x00                  ; 877D
	ld 8(iy),#0x00                  ; 8781
	ld 10(iy),#0x00                 ; 8785
	ret                             ; 8789
loc_b02_878A:
	ld 7(iy),#0x08                  ; 878A
	ld de,#data_b02_808E            ; 878E
	ld (player_CF11),de                ; 8791
	ld 9(iy),#0x00                  ; 8795
	ld 8(iy),#0x00                  ; 8799
	ld 10(iy),#0x00                 ; 879D
	ret                             ; 87A1

;; ---------------------------------------------------------------- $087A2
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_87A2
sub_b02_87A2:
	ld a,(tmp_d3)                   ; 87A2
	ld (player_CF21),a                 ; 87A5
	ld 7(iy),#0x0a                  ; 87A8
	ld de,#data_b02_80AC            ; 87AC
	ld (player_CF11),de                ; 87AF
	ret                             ; 87B3
loc_b02_87B4:
	ld 7(iy),#0x18                  ; 87B4
	ld de,#data_b02_80BC            ; 87B8
	ld (player_CF11),de                ; 87BB
	ret                             ; 87BF
loc_b02_87C0:
	ld 7(iy),#0x1a                  ; 87C0
	ld de,#data_b02_80DE            ; 87C4
	ld (player_CF11),de                ; 87C7
	ret                             ; 87CB
loc_b02_87CC:
	ld 7(iy),#0x04                  ; 87CC
	ld de,#data_b02_8102            ; 87D0
	ld (player_CF11),de                ; 87D3
	call sub_b02_86C7               ; 87D7
	ld 9(iy),#0x00                  ; 87DA
	ld 8(iy),#0x00                  ; 87DE
	ld 10(iy),#0x00                 ; 87E2
	ret                             ; 87E6
loc_b02_87E7:
	ld a,(demo_mode)                ; 87E7
	or a                            ; 87EA
	jr nz,loc_b02_87F3              ; 87EB
	ld a,(joypad_state)             ; 87ED
	or a                            ; 87F0
	jr z,loc_b02_87F7               ; 87F1
loc_b02_87F3:
	ld 34(iy),#0x00                 ; 87F3
loc_b02_87F7:
	inc 34(iy)                      ; 87F7
	ld a,(player_CF11)                 ; 87FA
	cp #0x64                        ; 87FD
	ret c                           ; 87FF
	ld 7(iy),#0x06                  ; 8800
	jr loc_b02_8877                 ; 8804
loc_b02_8806:
	ld de,#data_b02_8160            ; 8806
	ld (player_CF13),de                ; 8809
loc_b02_880D:
	ld 9(iy),#0x00                  ; 880D
	ld 8(iy),#0x00                  ; 8811
	ld 10(iy),#0x00                 ; 8815
	call sub_b02_86C7               ; 8819
	ld a,(player_CEF6)                 ; 881C
	cp #0x2a                        ; 881F
	ld 7(iy),#0x0e                  ; 8821
	ret nz                          ; 8825
	ld 7(iy),#0x2c                  ; 8826
	ret                             ; 882A
loc_b02_882B:
	ld 7(iy),#0x0c                  ; 882B
	ld 9(iy),#0x00                  ; 882F
	ld 8(iy),#0x00                  ; 8833
	ld 10(iy),#0x00                 ; 8837
	call sub_b02_86C7               ; 883B
	xor a                           ; 883E
	ld (player_C425),a                 ; 883F
	ret                             ; 8842
loc_b02_8843:
	ld a,(player_CF20)                 ; 8843
	ld (player_C1F4),a                 ; 8846
	ld 7(iy),#0x22                  ; 8849
	jr loc_b02_8877                 ; 884D
loc_b02_884F:
	ld a,#0x03                      ; 884F
	ld (player_CF25),a                 ; 8851
	ld 7(iy),#0x20                  ; 8854
	jr loc_b02_8877                 ; 8858
loc_b02_885A:
	ld a,#0x02                      ; 885A
	ld (player_CF25),a                 ; 885C
	ld 7(iy),#0x28                  ; 885F
	ld hl,#data_b02_810E            ; 8863
	ld (player_CF11),hl                ; 8866
	ld (player_CF13),hl                ; 8869
	jr loc_b02_8880                 ; 886C
loc_b02_886E:
	ld a,#0x01                      ; 886E
	ld (player_CF25),a                 ; 8870
	ld 7(iy),#0x26                  ; 8873
loc_b02_8877:
	ld hl,#0x0000                   ; 8877
	ld (player_CF11),hl                ; 887A
	ld (player_CF13),hl                ; 887D
loc_b02_8880:
	ld hl,#0x0000                   ; 8880
	ld 9(iy),#0x00                  ; 8883
	ld 8(iy),#0x00                  ; 8887
	ld 10(iy),#0x00                 ; 888B
	ld (player_CF01),hl                ; 888F
	ld (player_CEFF),hl                ; 8892
	ret                             ; 8895

;; ---------------------------------------------------------------- $08896
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8896
sub_b02_8896:
	ld 34(iy),#0x00                 ; 8896
	ld a,(joypad_state)             ; 889A
	and #0x3f                       ; 889D
	jr z,loc_b02_88B1               ; 889F
	ld 7(iy),#0x00                  ; 88A1
	ld 9(iy),#0x00                  ; 88A5
	ld 8(iy),#0x00                  ; 88A9
	ld 10(iy),#0x00                 ; 88AD
loc_b02_88B1:
	jp sub_b02_86F7                 ; 88B1

;; ---------------------------------------------------------------- $088B4
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_88B4
sub_b02_88B4:
	ld a,(tmp_d3)                   ; 88B4
	ld (player_CF21),a                 ; 88B7
	ld a,(player_CEF9)                 ; 88BA
	or a                            ; 88BD
	jp nz,loc_b02_89CC              ; 88BE
	ld a,(joypad_pressed)           ; 88C1
	bit 5,a                         ; 88C4
	jr z,loc_b02_88DA               ; 88C6
	ld hl,#data_b02_810E            ; 88C8
	ld (player_CF11),hl                ; 88CB
	ld hl,#data_b02_8126            ; 88CE
	ld (player_CF13),hl                ; 88D1
	call sub_0556                   ; 88D4
	jp loc_b02_882B                 ; 88D7
loc_b02_88DA:
	ld a,(player_CEF7)                 ; 88DA
	cp #0x01                        ; 88DD
	ret nz                          ; 88DF
	ld a,(player_CEF8)                 ; 88E0
	cp #0x02                        ; 88E3
	call z,sub_22BF                 ; 88E5
	xor a                           ; 88E8
	ld (player_CF04),a                 ; 88E9
	ret                             ; 88EC

;; ---------------------------------------------------------------- $088ED
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_88ED
sub_b02_88ED:
	ld a,(tmp_d3)                   ; 88ED
	ld (player_CF21),a                 ; 88F0
	ld a,(player_CEF9)                 ; 88F3
	or a                            ; 88F6
	jp nz,loc_b02_89CC              ; 88F7
	ld a,(joypad_pressed)           ; 88FA
	bit 5,a                         ; 88FD
	jr z,loc_b02_8913               ; 88FF
	ld hl,#data_b02_810E            ; 8901
	ld (player_CF11),hl                ; 8904
	ld hl,#data_b02_8126            ; 8907
	ld (player_CF13),hl                ; 890A
	call sub_0556                   ; 890D
	jp loc_b02_882B                 ; 8910
loc_b02_8913:
	ld a,(player_CEF7)                 ; 8913
	cp #0x01                        ; 8916
	ret nz                          ; 8918
	ld a,(player_CEF8)                 ; 8919
	cp #0x02                        ; 891C
	call z,sub_22BF                 ; 891E
	ret                             ; 8921

;; ---------------------------------------------------------------- $08922
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8922
sub_b02_8922:
	ld a,(player_CEF9)                 ; 8922
	or a                            ; 8925
	jp nz,loc_b02_81DD              ; 8926
	ld a,(joypad_pressed)           ; 8929
	bit 5,a                         ; 892C
	jr z,loc_b02_8942               ; 892E
	ld hl,#data_b02_810E            ; 8930
	ld (player_CF11),hl                ; 8933
	ld hl,#data_b02_8126            ; 8936
	ld (player_CF13),hl                ; 8939
	call sub_0556                   ; 893C
	jp loc_b02_882B                 ; 893F
loc_b02_8942:
	ld a,(player_CEF7)                 ; 8942
	cp #0x01                        ; 8945
	ret nz                          ; 8947
	ld a,(player_CEF8)                 ; 8948
	cp #0x02                        ; 894B
	call z,sub_22BF                 ; 894D
	ret                             ; 8950

;; ---------------------------------------------------------------- $08951
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8951
sub_b02_8951:
	ld a,(tmp_d3)                   ; 8951
	ld (player_CF21),a                 ; 8954
	ld a,(player_CEF9)                 ; 8957
	or a                            ; 895A
	ret z                           ; 895B
	call sub_31D0                   ; 895C
	ld 7(iy),#0x24                  ; 895F
	ld 9(iy),#0x00                  ; 8963
	ld 8(iy),#0x00                  ; 8967
	ld 10(iy),#0x00                 ; 896B
	ld hl,#game_flags               ; 896F
	bit 1,(hl)                      ; 8972
	ret nz                          ; 8974
	xor a                           ; 8975
	ld (player_C1F2),a                 ; 8976
	ret                             ; 8979

;; ---------------------------------------------------------------- $0897A
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_897A
sub_b02_897A:
	ld a,(tmp_d3)                   ; 897A
	ld (player_CF21),a                 ; 897D
	ld a,(player_CEF9)                 ; 8980
	or a                            ; 8983
	ret z                           ; 8984
	ld a,(player_C1F4)                 ; 8985
	bit 1,a                         ; 8988
	jp nz,loc_b02_89CC              ; 898A
	ld hl,#data_b02_8178            ; 898D
	ld (player_CF11),hl                ; 8990
	jp loc_b02_8806                 ; 8993

;; ---------------------------------------------------------------- $08996
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8996
sub_b02_8996:
	ld a,(player_CF20)                 ; 8996
	bit 1,a                         ; 8999
	jp z,loc_b02_8806               ; 899B
	ld a,(joypad_pressed)           ; 899E
	bit 5,a                         ; 89A1
	jr z,loc_b02_89B7               ; 89A3
	ld hl,#data_b02_810E            ; 89A5
	ld (player_CF11),hl                ; 89A8
	ld hl,#data_b02_8126            ; 89AB
	ld (player_CF13),hl                ; 89AE
	call sub_0556                   ; 89B1
	jp loc_b02_882B                 ; 89B4
loc_b02_89B7:
	ld a,(joypad_pressed)           ; 89B7
	bit 4,a                         ; 89BA
	jp nz,loc_b02_885A              ; 89BC
	ld a,(joypad_state)             ; 89BF
	bit 1,a                         ; 89C2
	ret nz                          ; 89C4
	and #0x0c                       ; 89C5
	jp nz,loc_b02_87CC              ; 89C7
	jr loc_b02_89CC                 ; 89CA
loc_b02_89CC:
	ld 7(iy),#0x00                  ; 89CC
	ld hl,#0x0000                   ; 89D0
	ld (player_CF01),hl                ; 89D3
	ld (player_CEFF),hl                ; 89D6
	jp loc_b02_8877                 ; 89D9
loc_b02_89DC:
	ld 7(iy),#0x10                  ; 89DC
	ld 9(iy),#0x00                  ; 89E0
	ld 8(iy),#0x00                  ; 89E4
	ld 10(iy),#0x00                 ; 89E8
	ld hl,#data_b02_810E            ; 89EC
	ld (player_CF13),hl                ; 89EF
	ld (player_CF11),hl                ; 89F2
	ret                             ; 89F5

;; ---------------------------------------------------------------- $089F6
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_89F6
sub_b02_89F6:
	ld a,(tmp_d3)                   ; 89F6
	ld (player_CF21),a                 ; 89F9
	ld a,(player_CEFD)                 ; 89FC
	or a                            ; 89FF
	jr nz,loc_b02_8A45              ; 8A00
	ld 22(iy),#0x00                 ; 8A02
	ld hl,#player_CF20                 ; 8A06
	bit 1,(hl)                      ; 8A09
	jr nz,loc_b02_89CC              ; 8A0B
	ld a,#0x0e                      ; 8A0D
	ld (player_CEF6),a                 ; 8A0F
	ld 9(iy),#0x00                  ; 8A12
	ld 8(iy),#0x00                  ; 8A16
	ld 10(iy),#0x00                 ; 8A1A
	ld de,#data_b02_8176            ; 8A1E
	ld (player_CF13),de                ; 8A21
	ex de,hl                        ; 8A25
	ld e,(hl)                       ; 8A26
	inc hl                          ; 8A27
	ld d,(hl)                       ; 8A28
	inc hl                          ; 8A29
	push hl                         ; 8A2A
	ld hl,#0x8000                   ; 8A2B
	or a                            ; 8A2E
	sbc hl,de                       ; 8A2F
	pop hl                          ; 8A31
	jr nz,loc_b02_8A3D              ; 8A32
	ld de,#MAPPER_CTRL              ; 8A34
	add hl,de                       ; 8A37
	ld e,(hl)                       ; 8A38
	inc hl                          ; 8A39
	ld d,(hl)                       ; 8A3A
	inc hl                          ; 8A3B
	xor a                           ; 8A3C
loc_b02_8A3D:
	ld (player_CF13),hl                ; 8A3D
	ld (player_CEFF),de                ; 8A40
	ret                             ; 8A44
loc_b02_8A45:
	call sub_b02_86C7               ; 8A45
	ld hl,(player_CF13)                ; 8A48
	ld e,(hl)                       ; 8A4B
	inc hl                          ; 8A4C
	ld d,(hl)                       ; 8A4D
	inc hl                          ; 8A4E
	push hl                         ; 8A4F
	ld hl,#0x8000                   ; 8A50
	or a                            ; 8A53
	sbc hl,de                       ; 8A54
	pop hl                          ; 8A56
	jr nz,loc_b02_8A62              ; 8A57
	ld de,#MAPPER_CTRL              ; 8A59
	add hl,de                       ; 8A5C
	ld e,(hl)                       ; 8A5D
	inc hl                          ; 8A5E
	ld d,(hl)                       ; 8A5F
	inc hl                          ; 8A60
	xor a                           ; 8A61
loc_b02_8A62:
	ld (player_CF13),hl                ; 8A62
	ld (player_CEFF),de                ; 8A65
	ld a,(player_CF20)                 ; 8A69
	jr nz,loc_b02_8A97              ; 8A6C
	ld de,#0x819e                   ; 8A6E
	or a                            ; 8A71
	sbc hl,de                       ; 8A72
	ld a,(player_CF20)                 ; 8A74
	jr nz,loc_b02_8A80              ; 8A77
	ld de,#data_b02_81A2            ; 8A79
	ld (player_CF13),de                ; 8A7C
loc_b02_8A80:
	bit 1,a                         ; 8A80
	ret z                           ; 8A82
	ld a,(player_CF06)                 ; 8A83
	or a                            ; 8A86
	call z,sub_27D3                 ; 8A87
	ld hl,#0x0000                   ; 8A8A
	ld (player_CEFF),hl                ; 8A8D
	ld hl,#data_b02_819E            ; 8A90
	ld (player_CF13),hl                ; 8A93
	ret                             ; 8A96
loc_b02_8A97:
	and #0x03                       ; 8A97
	ret z                           ; 8A99
	bit 0,a                         ; 8A9A
	jr z,loc_b02_8AB4               ; 8A9C
	bit 7,17(iy)                    ; 8A9E
	ret z                           ; 8AA2
	ld hl,#0x0000                   ; 8AA3
	ld (player_CEFF),hl                ; 8AA6
	bit 1,a                         ; 8AA9
	jr nz,loc_b02_8AB9              ; 8AAB
	ld hl,#data_b02_81A2            ; 8AAD
	ld (player_CF13),hl                ; 8AB0
	ret                             ; 8AB3
loc_b02_8AB4:
	bit 7,17(iy)                    ; 8AB4
	ret nz                          ; 8AB8
loc_b02_8AB9:
	ld hl,#0x0000                   ; 8AB9
	ld (player_CEFF),hl                ; 8ABC
	ld a,(player_CF06)                 ; 8ABF
	or a                            ; 8AC2
	call z,sub_27D3                 ; 8AC3
	ld hl,#data_b02_819E            ; 8AC6
	ld (player_CF13),hl                ; 8AC9
	ret                             ; 8ACC

;; ---------------------------------------------------------------- $08ACD
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8ACD
sub_b02_8ACD:
	ld a,(tmp_d3)                   ; 8ACD
	ld (player_CF21),a                 ; 8AD0
	ld hl,#player_CF11                 ; 8AD3
	dec (hl)                        ; 8AD6
	jr nz,loc_b02_8ADF              ; 8AD7
	ld hl,#irq_flags                ; 8AD9
	set 6,(hl)                      ; 8ADC
	ret                             ; 8ADE
loc_b02_8ADF:
	ld hl,(player_CF13)                ; 8ADF
	ld e,(hl)                       ; 8AE2
	inc hl                          ; 8AE3
	ld d,(hl)                       ; 8AE4
	inc hl                          ; 8AE5
	push hl                         ; 8AE6
	ld hl,#0x8000                   ; 8AE7
	or a                            ; 8AEA
	sbc hl,de                       ; 8AEB
	pop hl                          ; 8AED
	jr nz,loc_b02_8AF9              ; 8AEE
	ld de,#MAPPER_CTRL              ; 8AF0
	add hl,de                       ; 8AF3
	ld e,(hl)                       ; 8AF4
	inc hl                          ; 8AF5
	ld d,(hl)                       ; 8AF6
	inc hl                          ; 8AF7
	xor a                           ; 8AF8
loc_b02_8AF9:
	ld (player_CF13),hl                ; 8AF9
	ld (player_CEFF),de                ; 8AFC
	ld a,(player_CF20)                 ; 8B00
	bit 1,a                         ; 8B03
	ret z                           ; 8B05
	ld a,(player_CF06)                 ; 8B06
	or a                            ; 8B09
	call z,sub_27D3                 ; 8B0A
	ld hl,#0x0000                   ; 8B0D
	ld (player_CEFF),hl                ; 8B10
	ld hl,#data_b02_819E            ; 8B13
	ld (player_CF13),hl                ; 8B16
	ret                             ; 8B19

;; ---------------------------------------------------------------- $08B1A
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8B1A
sub_b02_8B1A:
	ld a,(tmp_d3)                   ; 8B1A
	ld (player_CF21),a                 ; 8B1D
	call sub_b02_86C7               ; 8B20
	jp nz,loc_b02_8B3E              ; 8B23
	ld a,(joypad_state)             ; 8B26
	bit 1,a                         ; 8B29
	jp nz,loc_b02_81DD              ; 8B2B
	and #0x0c                       ; 8B2E
	jp z,loc_b02_89CC               ; 8B30
	ld a,(joypad_pressed)           ; 8B33
	bit 4,a                         ; 8B36
	jp nz,loc_b02_86A1              ; 8B38
	jp loc_b02_87CC                 ; 8B3B
loc_b02_8B3E:
	ld bc,(player_CF20)                ; 8B3E
	bit 1,c                         ; 8B42
	jr nz,loc_b02_8B4F              ; 8B44
	ld hl,#data_b02_8180            ; 8B46
	ld (player_CF11),hl                ; 8B49
	jp loc_b02_8806                 ; 8B4C
loc_b02_8B4F:
	ld a,(joypad_pressed)           ; 8B4F
	bit 5,a                         ; 8B52
	jr z,loc_b02_8B68               ; 8B54
	ld hl,#data_b02_8156            ; 8B56
	ld (player_CF11),hl                ; 8B59
	ld hl,#data_b02_8126            ; 8B5C
	ld (player_CF13),hl                ; 8B5F
	call sub_0556                   ; 8B62
	jp loc_b02_882B                 ; 8B65
loc_b02_8B68:
	ld a,(joypad_state)             ; 8B68
	and #0x02                       ; 8B6B
	jr nz,loc_b02_8B7F              ; 8B6D
	and #0x0c                       ; 8B6F
	jp z,loc_b02_87C0               ; 8B71
	ld a,(joypad_pressed)           ; 8B74
	bit 4,a                         ; 8B77
	jp nz,loc_b02_86A1              ; 8B79
	jp loc_b02_87CC                 ; 8B7C
loc_b02_8B7F:
	ld a,(joypad_pressed)           ; 8B7F
	bit 4,a                         ; 8B82
	ret z                           ; 8B84
	jp loc_b02_885A                 ; 8B85
loc_b02_8B88:
	ld 7(iy),#0x1e                  ; 8B88
	ld 9(iy),#0x00                  ; 8B8C
	ld 8(iy),#0x00                  ; 8B90
	ld 10(iy),#0x00                 ; 8B94
	call sub_b02_86C7               ; 8B98
	ld hl,#data_b02_8070            ; 8B9B
	ld (player_CF11),hl                ; 8B9E
	ret                             ; 8BA1

;; ---------------------------------------------------------------- $08BA2
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8BA2
sub_b02_8BA2:
	ld a,(joypad_pressed)           ; 8BA2
	bit 5,a                         ; 8BA5
	ret z                           ; 8BA7
	ld hl,#joypad_state             ; 8BA8
	ld a,(hl)                       ; 8BAB
	and #0x0c                       ; 8BAC
	jr nz,loc_b02_8BC2              ; 8BAE
	ld hl,#data_b02_8130            ; 8BB0
	ld (player_CF13),hl                ; 8BB3
	ld hl,#data_b02_810E            ; 8BB6
	ld (player_CF11),hl                ; 8BB9
	call sub_0556                   ; 8BBC
	jp loc_b02_8BE7                 ; 8BBF
loc_b02_8BC2:
	bit 4,(hl)                      ; 8BC2
	jr nz,loc_b02_8BD8              ; 8BC4
	ld hl,#data_b02_8130            ; 8BC6
	ld (player_CF13),hl                ; 8BC9
	ld hl,#data_b02_8156            ; 8BCC
	ld (player_CF11),hl                ; 8BCF
	call sub_0556                   ; 8BD2
	jp loc_b02_8BE7                 ; 8BD5
loc_b02_8BD8:
	ld hl,#data_b02_8130            ; 8BD8
	ld (player_CF13),hl                ; 8BDB
	ld hl,#data_b02_815A            ; 8BDE
	ld (player_CF11),hl                ; 8BE1
	call sub_0551                   ; 8BE4
loc_b02_8BE7:
	push iy                         ; 8BE7
	ld de,(player_C1DF)                ; 8BE9
	ld iy,#0x0000                   ; 8BED
	add iy,de                       ; 8BF1
	ld 38(iy),#0x14                 ; 8BF3
	pop iy                          ; 8BF7
	ld hl,#0x0000                   ; 8BF9
	ld (player_C1DF),hl                ; 8BFC
	jp loc_b02_882B                 ; 8BFF

;; ---------------------------------------------------------------- $08C02
;; classement : atteinte uniquement par tbl_b02_8000
	.area _B02_8C02
sub_b02_8C02::
	ld a,(player_CF21)                 ; 8C02
	ld (tmp_d3),a                   ; 8C05
	ld a,(joypad_state)             ; 8C08
	and #0x0c                       ; 8C0B
	jr z,loc_b02_8C1A               ; 8C0D
	bit 3,a                         ; 8C0F
	ld a,#0x00                      ; 8C11
	jr nz,loc_b02_8C17              ; 8C13
	ld a,#0x01                      ; 8C15
loc_b02_8C17:
	ld (player_CF21),a                 ; 8C17
loc_b02_8C1A:
	ret                             ; 8C1A
loc_b02_8C1B::
	ld iy,#player_state             ; 8C1B
	call sub_b02_8C02               ; 8C1F
	ld a,(player_CF21)                 ; 8C22
	ld hl,#tmp_d3                   ; 8C25
	cp (hl)                         ; 8C28
	jr z,loc_b02_8C41               ; 8C29
	ld a,(player_CEF6)                 ; 8C2B
	cp #0x02                        ; 8C2E
	jr z,loc_b02_8C36               ; 8C30
	xor a                           ; 8C32
	ld (scroll_C19E),a                 ; 8C33
loc_b02_8C36:
	ld a,(player_CEF6)                 ; 8C36
	cp #0x08                        ; 8C39
	jr z,loc_b02_8C41               ; 8C3B
	xor a                           ; 8C3D
	ld (player_CEF7),a                 ; 8C3E
loc_b02_8C41:
	ld de,#data_b02_8C47            ; 8C41
	jp loc_b02_8037                 ; 8C44
data_b02_8C47:
	.db 0xaa, 0x8f, 0x16, 0x8e, 0x48, 0x8f, 0x8f, 0x90, 0xba ; 8C47
	.db 0x8e, 0x3e, 0x90, 0x1d, 0x92, 0x6a, 0x92, 0x67, 0x8c, 0x04, 0x8f, 0x81, 0x8e, 0x13, 0x90, 0x8f ; 8C50
	.db 0x8d, 0xfc                  ; 8C60

;; ---------------------------------------------------------------- $08C62
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8C62
sub_b02_8C62:
	adc a,h                         ; 8C62
	jp z,loc_4692                   ; 8C63
	sub c                           ; 8C66
	ld hl,#joypad_state             ; 8C67
	ld a,(hl)                       ; 8C6A
	and #0x0e                       ; 8C6B
	jr z,loc_b02_8CD4               ; 8C6D
	ld a,(joypad_pressed)           ; 8C6F
	bit 5,a                         ; 8C72
	jr nz,loc_b02_8CAC              ; 8C74
	ld hl,#joypad_state             ; 8C76
	bit 1,(hl)                      ; 8C79
	jr nz,loc_b02_8C85              ; 8C7B
	bit 4,(hl)                      ; 8C7D
	jp nz,loc_b02_8F84              ; 8C7F
	jp loc_b02_9361                 ; 8C82
loc_b02_8C85:
	ld 7(iy),#0x0a                  ; 8C85
	ld 9(iy),#0x00                  ; 8C89
	ld 8(iy),#0x00                  ; 8C8D
	ld 10(iy),#0x00                 ; 8C91
	ld 9(iy),#0x01                  ; 8C95
	ld hl,#data_b02_810E            ; 8C99
	ld (player_CF11),hl                ; 8C9C
	ld (player_CF13),hl                ; 8C9F
	ld hl,#0x0000                   ; 8CA2
	ld (player_CF01),hl                ; 8CA5
	ld (player_CEFF),hl                ; 8CA8
	ret                             ; 8CAB
loc_b02_8CAC:
	bit 4,(hl)                      ; 8CAC
	jr nz,loc_b02_8CC2              ; 8CAE
	ld hl,#data_b02_8126            ; 8CB0
	ld (player_CF13),hl                ; 8CB3
	ld hl,#data_b02_8156            ; 8CB6
	ld (player_CF11),hl                ; 8CB9
	call sub_0556                   ; 8CBC
	jp loc_b02_9104                 ; 8CBF
loc_b02_8CC2:
	ld hl,#data_b02_813C            ; 8CC2
	ld (player_CF13),hl                ; 8CC5
	ld hl,#data_b02_815A            ; 8CC8
	ld (player_CF11),hl                ; 8CCB
	call sub_0551                   ; 8CCE
	jp loc_b02_9104                 ; 8CD1
loc_b02_8CD4:
	ld a,(joypad_pressed)           ; 8CD4
	bit 5,a                         ; 8CD7
	jr z,loc_b02_8CED               ; 8CD9
	ld hl,#data_b02_8126            ; 8CDB
	ld (player_CF13),hl                ; 8CDE
	ld hl,#data_b02_810E            ; 8CE1
	ld (player_CF11),hl                ; 8CE4
	call sub_0556                   ; 8CE7
	jp loc_b02_9104                 ; 8CEA
loc_b02_8CED:
	ld a,(player_CEF9)                 ; 8CED
	or a                            ; 8CF0
	ret z                           ; 8CF1
	ld a,(joypad_state)             ; 8CF2
	bit 1,a                         ; 8CF5
	jr nz,loc_b02_8C85              ; 8CF7
	jp loc_b02_911C                 ; 8CF9

;; ---------------------------------------------------------------- $08CFC
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8CFC
sub_b02_8CFC:
	ld hl,(player_CF11)                ; 8CFC
	ld de,#0x8110                   ; 8CFF
	or a                            ; 8D02
	sbc hl,de                       ; 8D03
	jr nz,loc_b02_8D17              ; 8D05
	ld a,(joypad_state)             ; 8D07
	and #0x0c                       ; 8D0A
	jr z,loc_b02_8D2F               ; 8D0C
	ld de,#data_b02_80F6            ; 8D0E
	ld (player_CF11),de                ; 8D11
	jr loc_b02_8D2F                 ; 8D15
loc_b02_8D17:
	ld a,(joypad_state)             ; 8D17
	and #0x0c                       ; 8D1A
	jr z,loc_b02_8D28               ; 8D1C
	ld a,(player_CF21)                 ; 8D1E
	ld bc,(tmp_d3)                  ; 8D21
	cp c                            ; 8D25
	jr z,loc_b02_8D2F               ; 8D26
loc_b02_8D28:
	ld de,#data_b02_817C            ; 8D28
	ld (player_CF11),de                ; 8D2B
loc_b02_8D2F:
	call sub_b02_86C7               ; 8D2F
	ld hl,(player_CF13)                ; 8D32
	ld e,(hl)                       ; 8D35
	inc hl                          ; 8D36
	ld d,(hl)                       ; 8D37
	inc hl                          ; 8D38
	push hl                         ; 8D39
	ld hl,#0x8000                   ; 8D3A
	or a                            ; 8D3D
	sbc hl,de                       ; 8D3E
	pop hl                          ; 8D40
	jr nz,loc_b02_8D4C              ; 8D41
	ld de,#MAPPER_CTRL              ; 8D43
	add hl,de                       ; 8D46
	ld e,(hl)                       ; 8D47
	inc hl                          ; 8D48
	ld d,(hl)                       ; 8D49
	inc hl                          ; 8D4A
	xor a                           ; 8D4B
loc_b02_8D4C:
	ld (player_CF13),hl                ; 8D4C
	ld (player_CEFF),de                ; 8D4F
	ld a,(player_CF20)                 ; 8D53
	bit 1,a                         ; 8D56
	jr z,loc_b02_8D71               ; 8D58
	ld a,(player_CF06)                 ; 8D5A
	or a                            ; 8D5D
	call z,sub_27D3                 ; 8D5E
	ld a,(joypad_state)             ; 8D61
	ld b,a                          ; 8D64
	and #0x0c                       ; 8D65
	jp nz,loc_b02_87CC              ; 8D67
	bit 1,b                         ; 8D6A
	jp nz,loc_b02_912C              ; 8D6C
	jr loc_b02_8D72                 ; 8D6F
loc_b02_8D71:
	ret                             ; 8D71
loc_b02_8D72:
	ld 7(iy),#0x10                  ; 8D72
	ld 9(iy),#0x00                  ; 8D76
	ld 8(iy),#0x00                  ; 8D7A
	ld 10(iy),#0x00                 ; 8D7E
	call sub_0532                   ; 8D82
	ld hl,#0x0000                   ; 8D85
	ld (player_CF11),hl                ; 8D88
	ld (player_CF13),hl                ; 8D8B
	ret                             ; 8D8E

;; ---------------------------------------------------------------- $08D8F
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8D8F
sub_b02_8D8F:
	ld hl,(player_CF11)                ; 8D8F
	ld de,#0x8110                   ; 8D92
	or a                            ; 8D95
	sbc hl,de                       ; 8D96
	jr nz,loc_b02_8DAA              ; 8D98
	ld a,(joypad_state)             ; 8D9A
	and #0x0c                       ; 8D9D
	jr z,loc_b02_8DC2               ; 8D9F
	ld de,#data_b02_80F6            ; 8DA1
	ld (player_CF11),de                ; 8DA4
	jr loc_b02_8DC2                 ; 8DA8
loc_b02_8DAA:
	ld a,(joypad_state)             ; 8DAA
	and #0x0c                       ; 8DAD
	jr z,loc_b02_8DBB               ; 8DAF
	ld a,(player_CF21)                 ; 8DB1
	ld bc,(tmp_d3)                  ; 8DB4
	cp c                            ; 8DB8
	jr z,loc_b02_8DC2               ; 8DB9
loc_b02_8DBB:
	ld de,#data_b02_817C            ; 8DBB
	ld (player_CF11),de                ; 8DBE
loc_b02_8DC2:
	call sub_b02_86C7               ; 8DC2
	ld hl,(player_CF13)                ; 8DC5
	ld e,(hl)                       ; 8DC8
	inc hl                          ; 8DC9
	ld d,(hl)                       ; 8DCA
	inc hl                          ; 8DCB
	push hl                         ; 8DCC
	ld hl,#0x8000                   ; 8DCD
	or a                            ; 8DD0
	sbc hl,de                       ; 8DD1
	pop hl                          ; 8DD3
	jr nz,loc_b02_8DDF              ; 8DD4
	ld de,#MAPPER_CTRL              ; 8DD6
	add hl,de                       ; 8DD9
	ld e,(hl)                       ; 8DDA
	inc hl                          ; 8DDB
	ld d,(hl)                       ; 8DDC
	inc hl                          ; 8DDD
	xor a                           ; 8DDE
loc_b02_8DDF:
	ld (player_CF13),hl                ; 8DDF
	ld (player_CEFF),de                ; 8DE2
	jr z,loc_b02_8E13               ; 8DE6
	ld a,(player_C425)                 ; 8DE8
	inc a                           ; 8DEB
	ld (player_C425),a                 ; 8DEC
	cp #0x00                        ; 8DEF
	jr c,loc_b02_8E07               ; 8DF1
	dec a                           ; 8DF3
	ld (player_C425),a                 ; 8DF4
	ld a,(joypad_state)             ; 8DF7
	bit 5,a                         ; 8DFA
	jr nz,loc_b02_8E07              ; 8DFC
	ld hl,#data_b02_8160            ; 8DFE
	ld (player_CF13),hl                ; 8E01
	jp loc_b02_90F0                 ; 8E04
loc_b02_8E07:
	ld a,(player_CF20)                 ; 8E07
	bit 0,a                         ; 8E0A
	ret z                           ; 8E0C
	ld hl,#0x0000                   ; 8E0D
	ld (player_CEFF),hl                ; 8E10
loc_b02_8E13:
	jp loc_b02_90E9                 ; 8E13

;; ---------------------------------------------------------------- $08E16
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8E16
sub_b02_8E16:
	ld a,(player_CF21)                 ; 8E16
	ld bc,(tmp_d3)                  ; 8E19
	cp c                            ; 8E1D
	jr z,loc_b02_8E27               ; 8E1E
	ld de,#data_b02_80C8            ; 8E20
	ld (player_CF11),de                ; 8E23
loc_b02_8E27:
	ld a,(joypad_state)             ; 8E27
	bit 1,a                         ; 8E2A
	jp nz,loc_b02_9317              ; 8E2C
	call sub_b02_86C7               ; 8E2F
	push af                         ; 8E32
	pop bc                          ; 8E33
	ld (tmp_d3),bc                  ; 8E34
	ld bc,(player_CF20)                ; 8E38
	bit 1,c                         ; 8E3C
	jr nz,loc_b02_8E49              ; 8E3E
	ld hl,#data_b02_8184            ; 8E40
	ld (player_CF11),hl                ; 8E43
	jp loc_b02_90E9                 ; 8E46
loc_b02_8E49:
	ld a,(joypad_pressed)           ; 8E49
	bit 5,a                         ; 8E4C
	jr z,loc_b02_8E62               ; 8E4E
	ld hl,#data_b02_813C            ; 8E50
	ld (player_CF13),hl                ; 8E53
	ld hl,#data_b02_815A            ; 8E56
	ld (player_CF11),hl                ; 8E59
	call sub_0551                   ; 8E5C
	jp loc_b02_9104                 ; 8E5F
loc_b02_8E62:
	ld a,(joypad_state)             ; 8E62
	and #0x0f                       ; 8E65
	cp #0x04                        ; 8E67
	jp nc,loc_b02_8E78              ; 8E69
	ld bc,(tmp_d3)                  ; 8E6C
	push bc                         ; 8E70
	pop af                          ; 8E71
	jp z,loc_b02_9355               ; 8E72
	jp loc_b02_9349                 ; 8E75
loc_b02_8E78:
	ld a,(joypad_state)             ; 8E78
	bit 4,a                         ; 8E7B
	jp z,loc_b02_9361               ; 8E7D
	ret                             ; 8E80

;; ---------------------------------------------------------------- $08E81
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8E81
sub_b02_8E81:
	ld a,(player_CF21)                 ; 8E81
	ld bc,(tmp_d3)                  ; 8E84
	cp c                            ; 8E88
	jp nz,loc_b02_9331              ; 8E89
	call sub_b02_86C7               ; 8E8C
	jp z,loc_b02_911C               ; 8E8F
	ld bc,(player_CF20)                ; 8E92
	bit 1,c                         ; 8E96
	jr nz,loc_b02_8EA3              ; 8E98
	ld hl,#data_b02_8180            ; 8E9A
	ld (player_CF11),hl                ; 8E9D
	jp loc_b02_90E9                 ; 8EA0
loc_b02_8EA3:
	bit 5,a                         ; 8EA3
	jr z,loc_b02_8EB9               ; 8EA5
	ld hl,#data_b02_8126            ; 8EA7
	ld (player_CF13),hl                ; 8EAA
	ld hl,#data_b02_8156            ; 8EAD
	ld (player_CF11),hl                ; 8EB0
	call sub_0556                   ; 8EB3
	jp loc_b02_9104                 ; 8EB6
loc_b02_8EB9:
	ret                             ; 8EB9

;; ---------------------------------------------------------------- $08EBA
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8EBA
sub_b02_8EBA:
	ld a,(tmp_d3)                   ; 8EBA
	ld (player_CF21),a                 ; 8EBD
	call sub_b02_86C7               ; 8EC0
	jp nz,loc_b02_8ED1              ; 8EC3
	ld a,(joypad_state)             ; 8EC6
	and #0x0c                       ; 8EC9
	jp nz,loc_b02_8F84              ; 8ECB
	jp loc_b02_911C                 ; 8ECE
loc_b02_8ED1:
	ld bc,(player_CF20)                ; 8ED1
	bit 1,c                         ; 8ED5
	jr nz,loc_b02_8EE2              ; 8ED7
	ld hl,#data_b02_8180            ; 8ED9
	ld (player_CF11),hl                ; 8EDC
	jp loc_b02_90E9                 ; 8EDF
loc_b02_8EE2:
	ld a,(joypad_pressed)           ; 8EE2
	bit 5,a                         ; 8EE5
	jr z,loc_b02_8EFB               ; 8EE7
	ld hl,#data_b02_8126            ; 8EE9
	ld (player_CF13),hl                ; 8EEC
	ld hl,#data_b02_8156            ; 8EEF
	ld (player_CF11),hl                ; 8EF2
	call sub_0556                   ; 8EF5
	jp loc_b02_9104                 ; 8EF8
loc_b02_8EFB:
	ld a,(player_CF20)                 ; 8EFB
	and #0x0c                       ; 8EFE
	ret z                           ; 8F00
	jp loc_b02_9361                 ; 8F01

;; ---------------------------------------------------------------- $08F04
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8F04
sub_b02_8F04:
	ld a,(player_CF21)                 ; 8F04
	ld bc,(tmp_d3)                  ; 8F07
	cp c                            ; 8F0B
	jp nz,loc_b02_9361              ; 8F0C
	call sub_b02_86C7               ; 8F0F
	jp z,loc_b02_911C               ; 8F12
	ld bc,(player_CF20)                ; 8F15
	bit 1,c                         ; 8F19
	jr nz,loc_b02_8F26              ; 8F1B
	ld hl,#data_b02_8178            ; 8F1D
	ld (player_CF11),hl                ; 8F20
	jp loc_b02_90E9                 ; 8F23
loc_b02_8F26:
	ld a,(joypad_state)             ; 8F26
	bit 1,a                         ; 8F29
	jp nz,loc_b02_912C              ; 8F2B
	ld a,(joypad_pressed)           ; 8F2E
	bit 5,a                         ; 8F31
	jr z,loc_b02_8F47               ; 8F33
	ld hl,#data_b02_8126            ; 8F35
	ld (player_CF13),hl                ; 8F38
	ld hl,#data_b02_8156            ; 8F3B
	ld (player_CF11),hl                ; 8F3E
	call sub_0556                   ; 8F41
	jp loc_b02_9104                 ; 8F44
loc_b02_8F47:
	ret                             ; 8F47

;; ---------------------------------------------------------------- $08F48
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8F48
sub_b02_8F48:
	ld bc,(player_CF20)                ; 8F48
	bit 1,c                         ; 8F4C
	jr nz,loc_b02_8F59              ; 8F4E
	ld hl,#data_b02_8180            ; 8F50
	ld (player_CF11),hl                ; 8F53
	jp loc_b02_90E9                 ; 8F56
loc_b02_8F59:
	ld a,(joypad_state)             ; 8F59
	bit 1,a                         ; 8F5C
	jp nz,loc_b02_912C              ; 8F5E
	call sub_b02_86C7               ; 8F61
	ld a,(joypad_pressed)           ; 8F64
	bit 5,a                         ; 8F67
	jr z,loc_b02_8F7D               ; 8F69
	ld hl,#data_b02_8126            ; 8F6B
	ld (player_CF13),hl                ; 8F6E
	ld hl,#data_b02_8156            ; 8F71
	ld (player_CF11),hl                ; 8F74
	call sub_0556                   ; 8F77
	jp loc_b02_9104                 ; 8F7A
loc_b02_8F7D:
	ld a,(joypad_state)             ; 8F7D
	bit 4,a                         ; 8F80
	jr z,loc_b02_8F9F               ; 8F82
loc_b02_8F84:
	ld hl,#data_b02_80C8            ; 8F84
	ld (player_CF11),hl                ; 8F87
	ld a,#0x02                      ; 8F8A
	ld (player_CEF6),a                 ; 8F8C
	call sub_b02_86C7               ; 8F8F
	ld 9(iy),#0x00                  ; 8F92
	ld 8(iy),#0x00                  ; 8F96
	ld 10(iy),#0x00                 ; 8F9A
	ret                             ; 8F9E
loc_b02_8F9F:
	ld a,(joypad_state)             ; 8F9F
	and #0x0f                       ; 8FA2
	cp #0x03                        ; 8FA4
	jp c,loc_b02_9349               ; 8FA6
	ret                             ; 8FA9

;; ---------------------------------------------------------------- $08FAA
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_8FAA
sub_b02_8FAA:
	ld bc,(player_CF20)                ; 8FAA
	bit 1,c                         ; 8FAE
	jr nz,loc_b02_8FBB              ; 8FB0
	ld hl,#data_b02_8178            ; 8FB2
	ld (player_CF11),hl                ; 8FB5
	jp loc_b02_90E9                 ; 8FB8
loc_b02_8FBB:
	ld a,(joypad_pressed)           ; 8FBB
	bit 5,a                         ; 8FBE
	jr z,loc_b02_8FD4               ; 8FC0
	ld hl,#data_b02_810E            ; 8FC2
	ld (player_CF11),hl                ; 8FC5
	ld hl,#data_b02_8126            ; 8FC8
	ld (player_CF13),hl                ; 8FCB
	call sub_0556                   ; 8FCE
	jp loc_b02_9104                 ; 8FD1
loc_b02_8FD4:
	ld a,(joypad_state)             ; 8FD4
	bit 4,a                         ; 8FD7
	jr z,loc_b02_8FE0               ; 8FD9
	and #0x0c                       ; 8FDB
	jp nz,loc_b02_8F84              ; 8FDD
loc_b02_8FE0:
	ld a,(joypad_state)             ; 8FE0
	and #0x0f                       ; 8FE3
	ld de,#jt_b02_8FF2              ; 8FE5
	ld l,a                          ; 8FE8
	ld h,#0x00                      ; 8FE9
	add hl,hl                       ; 8FEB
	add hl,de                       ; 8FEC
	ld e,(hl)                       ; 8FED
	inc hl                          ; 8FEE
	ld d,(hl)                       ; 8FEF
	ex de,hl                        ; 8FF0
	jp (hl)                         ; 8FF1
jt_b02_8FF2:
	.dw loc_b02_90AD                ; 8FF2
	.dw loc_b02_9012                ; 8FF4
	.dw loc_b02_912C                ; 8FF6
	.dw loc_b02_912C                ; 8FF8
	.dw loc_b02_9361                ; 8FFA
	.dw loc_b02_9361                ; 8FFC
	.dw loc_b02_912C                ; 8FFE
	.dw loc_b02_912C                ; 9000
	.dw loc_b02_9361                ; 9002
	.dw loc_b02_9361                ; 9004
	.dw loc_b02_912C                ; 9006
	.dw loc_b02_912C                ; 9008
	.dw loc_b02_9361                ; 900A
	.dw loc_b02_9361                ; 900C
	.dw loc_b02_912C                ; 900E
	.dw loc_b02_912C                ; 9010
loc_b02_9012:
	ret                             ; 9012

;; ---------------------------------------------------------------- $09013
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_9013
sub_b02_9013:
	ld a,(player_CF20)                 ; 9013
	bit 1,a                         ; 9016
	jp nz,loc_b02_9024              ; 9018
	ld hl,#data_b02_80DA            ; 901B
	ld (player_CF11),hl                ; 901E
	jp loc_b02_90E9                 ; 9021
loc_b02_9024:
	call sub_b02_86C7               ; 9024
	ret nz                          ; 9027
	ld hl,#data_b02_80DA            ; 9028
	ld (player_CF11),hl                ; 902B
	ld a,(joypad_state)             ; 902E
	bit 1,a                         ; 9031
	jp nz,loc_b02_912C              ; 9033
	and #0x0c                       ; 9036
	jp nz,loc_b02_9361              ; 9038
	jp loc_b02_911C                 ; 903B

;; ---------------------------------------------------------------- $0903E
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_903E
sub_b02_903E:
	ld a,(player_CF20)                 ; 903E
	bit 1,a                         ; 9041
	jp z,loc_b02_90E9               ; 9043
	ld a,(joypad_state)             ; 9046
	bit 1,a                         ; 9049
	jr nz,loc_b02_9055              ; 904B
	and #0x0c                       ; 904D
	jp nz,loc_b02_9361              ; 904F
	jp loc_b02_911C                 ; 9052
loc_b02_9055:
	ld a,(joypad_pressed)           ; 9055
	and #0x30                       ; 9058
	ret z                           ; 905A
	ld a,#0x16                      ; 905B
	ld (player_CEF6),a                 ; 905D
	ld 9(iy),#0x00                  ; 9060
	ld 8(iy),#0x00                  ; 9064
	ld 10(iy),#0x00                 ; 9068
	ld hl,#data_b02_9073            ; 906C
	ld (player_CF11),hl                ; 906F
	ret                             ; 9072
data_b02_9073:
	.db 0x00, 0x05, 0x00, 0x05, 0x00, 0x05, 0x00, 0x05, 0x00, 0x05, 0x00, 0x05, 0x00 ; 9073
	.db 0x05, 0x00, 0x05, 0x00, 0x05, 0x00, 0x05, 0x00, 0x05, 0x00, 0x05, 0x00, 0x00, 0x00 ; 9080

;; ---------------------------------------------------------------- $0908E
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_908E
sub_b02_908E:
	add a,b                         ; 908E
	ld 34(iy),#0x00                 ; 908F
	ld a,(joypad_state)             ; 9093
	and #0x3f                       ; 9096
	jr z,loc_b02_90AA               ; 9098
	ld 7(iy),#0x00                  ; 909A
	ld 9(iy),#0x00                  ; 909E
	ld 8(iy),#0x00                  ; 90A2
	ld 10(iy),#0x00                 ; 90A6
loc_b02_90AA:
	jp sub_b02_8FAA                 ; 90AA
loc_b02_90AD:
	ld a,(demo_mode)                ; 90AD
	or a                            ; 90B0
	jr nz,loc_b02_90B9              ; 90B1
	ld a,(joypad_state)             ; 90B3
	or a                            ; 90B6
	jr z,loc_b02_90BD               ; 90B7
loc_b02_90B9:
	ld 34(iy),#0x00                 ; 90B9
loc_b02_90BD:
	inc 34(iy)                      ; 90BD
	ld a,(player_CF11)                 ; 90C0
	cp #0x64                        ; 90C3
	ret c                           ; 90C5
	ld 7(iy),#0x06                  ; 90C6
loc_b02_90CA:
	ld hl,#0x0000                   ; 90CA
	ld (player_CF11),hl                ; 90CD
	ld (player_CF13),hl                ; 90D0
	ld hl,#0x0000                   ; 90D3
	ld 9(iy),#0x00                  ; 90D6
	ld 8(iy),#0x00                  ; 90DA
	ld 10(iy),#0x00                 ; 90DE
	ld (player_CF01),hl                ; 90E2
	ld (player_CEFF),hl                ; 90E5
	ret                             ; 90E8
loc_b02_90E9:
	ld de,#data_b02_8160            ; 90E9
	ld (player_CF13),de                ; 90EC
loc_b02_90F0:
	ld 9(iy),#0x00                  ; 90F0
	ld 8(iy),#0x00                  ; 90F4
	ld 10(iy),#0x00                 ; 90F8
	call sub_b02_86C7               ; 90FC
	ld 7(iy),#0x1a                  ; 90FF
	ret                             ; 9103
loc_b02_9104:
	ld 7(iy),#0x18                  ; 9104
	ld 9(iy),#0x00                  ; 9108
	ld 8(iy),#0x00                  ; 910C
	ld 10(iy),#0x00                 ; 9110
	call sub_b02_86C7               ; 9114
	xor a                           ; 9117
	ld (player_C425),a                 ; 9118
	ret                             ; 911B
loc_b02_911C:
	ld 7(iy),#0x00                  ; 911C
	ld hl,#0x0000                   ; 9120
	ld (player_CF01),hl                ; 9123
	ld (player_CEFF),hl                ; 9126
	jp loc_b02_90CA                 ; 9129
loc_b02_912C:
	ld 7(iy),#0x0a                  ; 912C
	ld 9(iy),#0x00                  ; 9130
	ld 8(iy),#0x00                  ; 9134
	ld 10(iy),#0x00                 ; 9138
	ld hl,#data_b02_810E            ; 913C
	ld (player_CF11),hl                ; 913F
	ld (player_CF13),hl                ; 9142
	ret                             ; 9145
	.db 0x3a                        ; 9146

;; ---------------------------------------------------------------- $09147
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_9147
sub_b02_9147:
	out (0xc0),a                    ; 9147
	ld (player_CF21),a                 ; 9149
	ld a,(player_CEFD)                 ; 914C
	or a                            ; 914F
	jr nz,loc_b02_9195              ; 9150
	ld 22(iy),#0x00                 ; 9152
	ld hl,#player_CF20                 ; 9156
	bit 1,(hl)                      ; 9159
	jr nz,loc_b02_911C              ; 915B
	ld a,#0x1a                      ; 915D
	ld (player_CEF6),a                 ; 915F
	ld 9(iy),#0x00                  ; 9162
	ld 8(iy),#0x00                  ; 9166
	ld 10(iy),#0x00                 ; 916A
	ld de,#data_b02_8176            ; 916E
	ld (player_CF13),de                ; 9171
	ex de,hl                        ; 9175
	ld e,(hl)                       ; 9176
	inc hl                          ; 9177
	ld d,(hl)                       ; 9178
	inc hl                          ; 9179
	push hl                         ; 917A
	ld hl,#0x8000                   ; 917B
	or a                            ; 917E
	sbc hl,de                       ; 917F
	pop hl                          ; 9181
	jr nz,loc_b02_918D              ; 9182
	ld de,#MAPPER_CTRL              ; 9184
	add hl,de                       ; 9187
	ld e,(hl)                       ; 9188
	inc hl                          ; 9189
	ld d,(hl)                       ; 918A
	inc hl                          ; 918B
	xor a                           ; 918C
loc_b02_918D:
	ld (player_CF13),hl                ; 918D
	ld (player_CEFF),de                ; 9190
	ret                             ; 9194
loc_b02_9195:
	call sub_b02_86C7               ; 9195
	ld hl,(player_CF13)                ; 9198
	ld e,(hl)                       ; 919B
	inc hl                          ; 919C
	ld d,(hl)                       ; 919D
	inc hl                          ; 919E
	push hl                         ; 919F
	ld hl,#0x8000                   ; 91A0
	or a                            ; 91A3
	sbc hl,de                       ; 91A4
	pop hl                          ; 91A6
	jr nz,loc_b02_91B2              ; 91A7
	ld de,#MAPPER_CTRL              ; 91A9
	add hl,de                       ; 91AC
	ld e,(hl)                       ; 91AD
	inc hl                          ; 91AE
	ld d,(hl)                       ; 91AF
	inc hl                          ; 91B0
	xor a                           ; 91B1
loc_b02_91B2:
	ld (player_CF13),hl                ; 91B2
	ld (player_CEFF),de                ; 91B5
	ld a,(player_CF20)                 ; 91B9
	jr nz,loc_b02_91E7              ; 91BC
	ld de,#0x819e                   ; 91BE
	or a                            ; 91C1
	sbc hl,de                       ; 91C2
	ld a,(player_CF20)                 ; 91C4
	jr nz,loc_b02_91D0              ; 91C7
	ld de,#data_b02_81A2            ; 91C9
	ld (player_CF13),de                ; 91CC
loc_b02_91D0:
	bit 1,a                         ; 91D0
	ret z                           ; 91D2
	ld a,(player_CF06)                 ; 91D3
	or a                            ; 91D6
	call z,sub_27D3                 ; 91D7
	ld hl,#0x0000                   ; 91DA
	ld (player_CEFF),hl                ; 91DD
	ld hl,#data_b02_819E            ; 91E0
	ld (player_CF13),hl                ; 91E3
	ret                             ; 91E6
loc_b02_91E7:
	and #0x03                       ; 91E7
	ret z                           ; 91E9
	bit 0,a                         ; 91EA
	jr z,loc_b02_9204               ; 91EC
	bit 7,17(iy)                    ; 91EE
	ret z                           ; 91F2
	ld hl,#0x0000                   ; 91F3
	ld (player_CEFF),hl                ; 91F6
	bit 1,a                         ; 91F9
	jr nz,loc_b02_9209              ; 91FB
	ld hl,#data_b02_81A2            ; 91FD
	ld (player_CF13),hl                ; 9200
	ret                             ; 9203
loc_b02_9204:
	bit 7,17(iy)                    ; 9204
	ret nz                          ; 9208
loc_b02_9209:
	ld hl,#0x0000                   ; 9209
	ld (player_CEFF),hl                ; 920C
	ld a,(player_CF06)                 ; 920F
	or a                            ; 9212
	call z,sub_27D3                 ; 9213
	ld hl,#data_b02_819E            ; 9216
	ld (player_CF13),hl                ; 9219
	ret                             ; 921C

;; ---------------------------------------------------------------- $0921D
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_921D
sub_b02_921D:
	ld a,(tmp_d3)                   ; 921D
	ld (player_CF21),a                 ; 9220
	ld hl,#player_CF11                 ; 9223
	dec (hl)                        ; 9226
	jr nz,loc_b02_922F              ; 9227
	ld hl,#irq_flags                ; 9229
	set 6,(hl)                      ; 922C
	ret                             ; 922E
loc_b02_922F:
	ld hl,(player_CF13)                ; 922F
	ld e,(hl)                       ; 9232
	inc hl                          ; 9233
	ld d,(hl)                       ; 9234
	inc hl                          ; 9235
	push hl                         ; 9236
	ld hl,#0x8000                   ; 9237
	or a                            ; 923A
	sbc hl,de                       ; 923B
	pop hl                          ; 923D
	jr nz,loc_b02_9249              ; 923E
	ld de,#MAPPER_CTRL              ; 9240
	add hl,de                       ; 9243
	ld e,(hl)                       ; 9244
	inc hl                          ; 9245
	ld d,(hl)                       ; 9246
	inc hl                          ; 9247
	xor a                           ; 9248
loc_b02_9249:
	ld (player_CF13),hl                ; 9249
	ld (player_CEFF),de                ; 924C
	ld a,(player_CF20)                 ; 9250
	bit 1,a                         ; 9253
	ret z                           ; 9255
	ld a,(player_CF06)                 ; 9256
	or a                            ; 9259
	call z,sub_27D3                 ; 925A
	ld hl,#0x0000                   ; 925D
	ld (player_CEFF),hl                ; 9260
	ld hl,#data_b02_819E            ; 9263
	ld (player_CF13),hl                ; 9266
	ret                             ; 9269

;; ---------------------------------------------------------------- $0926A
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_926A
sub_b02_926A:
	ld a,(joypad_pressed)           ; 926A
	bit 5,a                         ; 926D
	ret z                           ; 926F
	ld hl,#joypad_state             ; 9270
	ld a,(hl)                       ; 9273
	and #0x0c                       ; 9274
	jr nz,loc_b02_928A              ; 9276
	ld hl,#data_b02_8130            ; 9278
	ld (player_CF13),hl                ; 927B
	ld hl,#data_b02_810E            ; 927E
	ld (player_CF11),hl                ; 9281
	call sub_0556                   ; 9284
	jp loc_b02_92AF                 ; 9287
loc_b02_928A:
	bit 4,(hl)                      ; 928A
	jr nz,loc_b02_92A0              ; 928C
	ld hl,#data_b02_8130            ; 928E
	ld (player_CF13),hl                ; 9291
	ld hl,#data_b02_8156            ; 9294
	ld (player_CF11),hl                ; 9297
	call sub_0556                   ; 929A
	jp loc_b02_92AF                 ; 929D
loc_b02_92A0:
	ld hl,#data_b02_8130            ; 92A0
	ld (player_CF13),hl                ; 92A3
	ld hl,#data_b02_815A            ; 92A6
	ld (player_CF11),hl                ; 92A9
	call sub_0551                   ; 92AC
loc_b02_92AF:
	push iy                         ; 92AF
	ld de,(player_C1DF)                ; 92B1
	ld iy,#0x0000                   ; 92B5
	add iy,de                       ; 92B9
	ld 38(iy),#0x14                 ; 92BB
	pop iy                          ; 92BF
	ld hl,#0x0000                   ; 92C1
	ld (player_C1DF),hl                ; 92C4
	jp loc_b02_9104                 ; 92C7
	.db 0x3a, 0xd3                  ; 92CA

;; ---------------------------------------------------------------- $092CC
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_92CC
sub_b02_92CC:
	ret nz                          ; 92CC
	ld (player_CF21),a                 ; 92CD
	call sub_b02_86C7               ; 92D0
	jp nz,loc_b02_92EE              ; 92D3
	ld a,(joypad_state)             ; 92D6
	bit 1,a                         ; 92D9
	jp nz,loc_b02_8C85              ; 92DB
	and #0x0c                       ; 92DE
	jp z,loc_b02_911C               ; 92E0
	ld a,(joypad_pressed)           ; 92E3
	bit 4,a                         ; 92E6
	jp nz,loc_b02_8F84              ; 92E8
	jp loc_b02_9361                 ; 92EB
loc_b02_92EE:
	ld bc,(player_CF20)                ; 92EE
	bit 1,c                         ; 92F2
	jr nz,loc_b02_92FF              ; 92F4
	ld hl,#data_b02_8180            ; 92F6
	ld (player_CF11),hl                ; 92F9
	jp loc_b02_90E9                 ; 92FC
loc_b02_92FF:
	ld a,(joypad_state)             ; 92FF
	and #0x02                       ; 9302
	jr nz,loc_b02_9316              ; 9304
	and #0x0c                       ; 9306
	jp z,loc_b02_9355               ; 9308
	ld a,(joypad_pressed)           ; 930B
	bit 4,a                         ; 930E
	jp nz,loc_b02_8F84              ; 9310
	jp loc_b02_9361                 ; 9313
loc_b02_9316:
	ret                             ; 9316
loc_b02_9317:
	ld 7(iy),#0x1c                  ; 9317
	ld 9(iy),#0x00                  ; 931B
	ld 8(iy),#0x00                  ; 931F
	ld 10(iy),#0x00                 ; 9323
	call sub_b02_86C7               ; 9327
	ld hl,#data_b02_8070            ; 932A
	ld (player_CF11),hl                ; 932D
	ret                             ; 9330
loc_b02_9331:
	ld 7(iy),#0x08                  ; 9331
	ld de,#data_b02_808E            ; 9335
	ld (player_CF11),de                ; 9338
	ld 9(iy),#0x00                  ; 933C
	ld 8(iy),#0x00                  ; 9340
	ld 10(iy),#0x00                 ; 9344
	ret                             ; 9348
loc_b02_9349:
	ld 7(iy),#0x12                  ; 9349
	ld de,#data_b02_80BC            ; 934D
	ld (player_CF11),de                ; 9350
	ret                             ; 9354
loc_b02_9355:
	ld 7(iy),#0x14                  ; 9355
	ld de,#data_b02_80DE            ; 9359
	ld (player_CF11),de                ; 935C
	ret                             ; 9360
loc_b02_9361:
	ld 7(iy),#0x04                  ; 9361
	ld de,#data_b02_8102            ; 9365
	ld (player_CF11),de                ; 9368
	call sub_b02_86C7               ; 936C
	ld 9(iy),#0x00                  ; 936F
	ld 8(iy),#0x00                  ; 9373
	ld 10(iy),#0x00                 ; 9377
	ret                             ; 937B
data_b02_937C:
	.db 0xd6, 0x99, 0x9c, 0x9b      ; 937C
	.db 0x05, 0x9b, 0xab, 0x9a, 0x4d, 0x9a, 0xdc, 0x98, 0xd1, 0x97, 0x52, 0x97, 0x7a, 0x96, 0x1b, 0x96 ; 9380
	.db 0x46, 0x9b, 0xdc, 0x98, 0xd1, 0x97, 0xdc, 0x98, 0xd1, 0x97, 0x46, 0x9b, 0xd1, 0x98, 0xc6, 0x97 ; 9390
	.db 0x46, 0x9b, 0xd1, 0x98, 0xc6, 0x97, 0x46, 0x9b, 0xd1, 0x98, 0xc6, 0x97, 0x85, 0x9b, 0x85, 0x9b ; 93A0
	.db 0x85, 0x9b                  ; 93B0
data_b02_93B2:
	.db 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94 ; 93B2
	.db 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x6b, 0x94 ; 93C0
	.db 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94 ; 93D0
	.db 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94 ; 93E0
	.db 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0xf5, 0x94, 0x26, 0x94 ; 93F0
	.db 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x3a, 0x95, 0x3a, 0x95, 0x26, 0x94, 0x26, 0x94 ; 9400
	.db 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x26, 0x94, 0x7f, 0x95, 0xb0, 0x94, 0xb0, 0x94, 0xb0, 0x94 ; 9410
	.db 0x26, 0x94, 0x26, 0x94, 0xb0, 0x94, 0x02, 0x99, 0x9f, 0x02, 0xb9, 0x9f, 0x02, 0xd9, 0x9f, 0x02 ; 9420
	.db 0xf9, 0x9f, 0x02, 0x19, 0xa0, 0x02, 0x39, 0xa0, 0x02, 0x19, 0xa0, 0x02, 0xf9, 0x9f, 0x02, 0xd9 ; 9430
	.db 0x9f, 0x02, 0xb9, 0x9f, 0x02, 0x99, 0x9f, 0x01, 0x99, 0x9f, 0x01, 0xb9, 0x9f, 0x01, 0xd9, 0x9f ; 9440
	.db 0x01, 0xf9, 0x9f, 0x01, 0x19, 0xa0, 0x01, 0x39, 0xa0, 0x01, 0x19, 0xa0, 0x01, 0xf9, 0x9f, 0x01 ; 9450
	.db 0xd9, 0x9f, 0x01, 0xb9, 0x9f, 0x01, 0x99, 0x9f, 0xff ; 9460

;; ---------------------------------------------------------------- $09469
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_9469
sub_b02_9469:
	ld b,a                          ; 9469
	sub h                           ; 946A
	ld (bc),a                       ; 946B
	ld e,c                          ; 946C
	and b                           ; 946D
	ld (bc),a                       ; 946E
	ld a,c                          ; 946F
	and b                           ; 9470
	ld (bc),a                       ; 9471
	sbc a,c                         ; 9472
	and b                           ; 9473
	ld (bc),a                       ; 9474
	cp c                            ; 9475
	and b                           ; 9476
	ld (bc),a                       ; 9477
	exx                             ; 9478
	and b                           ; 9479
	ld (bc),a                       ; 947A
	ld sp,hl                        ; 947B
	and b                           ; 947C
	ld (bc),a                       ; 947D
	exx                             ; 947E
	and b                           ; 947F
	ld (bc),a                       ; 9480
	cp c                            ; 9481
	and b                           ; 9482
	ld (bc),a                       ; 9483
	sbc a,c                         ; 9484
	and b                           ; 9485
	ld (bc),a                       ; 9486
	ld a,c                          ; 9487
	and b                           ; 9488
	ld (bc),a                       ; 9489
	ld e,c                          ; 948A
	and b                           ; 948B
	ld bc,#0xa059                   ; 948C
	ld bc,#0xa079                   ; 948F
	ld bc,#0xa099                   ; 9492
	ld bc,#0xa0b9                   ; 9495
	ld bc,#0xa0d9                   ; 9498
	ld bc,#0xa0f9                   ; 949B
	ld bc,#0xa0d9                   ; 949E
	ld bc,#0xa0b9                   ; 94A1
	ld bc,#0xa099                   ; 94A4
	ld bc,#0xa079                   ; 94A7
	ld bc,#0xa059                   ; 94AA
	rst 0x38                        ; 94AD
	adc a,h                         ; 94AE

;; ---------------------------------------------------------------- $094AF
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_94AF
sub_b02_94AF:
	sub h                           ; 94AF
	ld (bc),a                       ; 94B0
	exx                             ; 94B1
	sbc a,(hl)                      ; 94B2
	ld (bc),a                       ; 94B3
	ld sp,hl                        ; 94B4
	sbc a,(hl)                      ; 94B5
	ld (bc),a                       ; 94B6
	add hl,de                       ; 94B7
	sbc a,a                         ; 94B8
	ld (bc),a                       ; 94B9
	add hl,sp                       ; 94BA
	sbc a,a                         ; 94BB
	ld (bc),a                       ; 94BC
	ld e,c                          ; 94BD
	sbc a,a                         ; 94BE
	ld (bc),a                       ; 94BF
	ld a,c                          ; 94C0
	sbc a,a                         ; 94C1
	ld (bc),a                       ; 94C2
	ld e,c                          ; 94C3
	sbc a,a                         ; 94C4
	ld (bc),a                       ; 94C5
	add hl,sp                       ; 94C6
	sbc a,a                         ; 94C7
	ld (bc),a                       ; 94C8
	add hl,de                       ; 94C9
	sbc a,a                         ; 94CA
	ld (bc),a                       ; 94CB
	ld sp,hl                        ; 94CC
	sbc a,(hl)                      ; 94CD
	ld (bc),a                       ; 94CE
	exx                             ; 94CF
	sbc a,(hl)                      ; 94D0
	ld bc,#0x9ed9                   ; 94D1
	ld bc,#0x9ef9                   ; 94D4
	ld bc,#0x9f19                   ; 94D7
	ld bc,#0x9f39                   ; 94DA
	ld bc,#0x9f59                   ; 94DD
	ld bc,#0x9f79                   ; 94E0
	ld bc,#0x9f59                   ; 94E3
	ld bc,#0x9f39                   ; 94E6
	ld bc,#0x9f19                   ; 94E9
	ld bc,#0x9ef9                   ; 94EC
	ld bc,#0x9ed9                   ; 94EF
	rst 0x38                        ; 94F2
	pop de                          ; 94F3

;; ---------------------------------------------------------------- $094F4
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_94F4
sub_b02_94F4:
	sub h                           ; 94F4
	ld (bc),a                       ; 94F5
	add hl,de                       ; 94F6
	and c                           ; 94F7
	ld (bc),a                       ; 94F8
	add hl,sp                       ; 94F9
	and c                           ; 94FA
	ld (bc),a                       ; 94FB
	ld e,c                          ; 94FC
	and c                           ; 94FD
	ld (bc),a                       ; 94FE
	ld a,c                          ; 94FF
	and c                           ; 9500
	ld (bc),a                       ; 9501
	sbc a,c                         ; 9502
	and c                           ; 9503
	ld (bc),a                       ; 9504
	cp c                            ; 9505
	and c                           ; 9506
	ld (bc),a                       ; 9507
	sbc a,c                         ; 9508
	and c                           ; 9509
	ld (bc),a                       ; 950A
	ld a,c                          ; 950B
	and c                           ; 950C
	ld (bc),a                       ; 950D
	ld e,c                          ; 950E
	and c                           ; 950F
	ld (bc),a                       ; 9510
	add hl,sp                       ; 9511
	and c                           ; 9512
	ld (bc),a                       ; 9513
	add hl,de                       ; 9514
	and c                           ; 9515
	ld bc,#0xa119                   ; 9516
	ld bc,#0xa139                   ; 9519
	ld bc,#0xa159                   ; 951C
	ld bc,#0xa179                   ; 951F
	ld bc,#0xa199                   ; 9522
	ld bc,#0xa1b9                   ; 9525
	ld bc,#0xa199                   ; 9528
	ld bc,#0xa179                   ; 952B
	ld bc,#0xa159                   ; 952E
	ld bc,#0xa139                   ; 9531
	ld bc,#0xa119                   ; 9534
	rst 0x38                        ; 9537

;; ---------------------------------------------------------------- $09538
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_9538
sub_b02_9538:
	ld d,#0x95                      ; 9538
	ld (bc),a                       ; 953A
	sbc a,c                         ; 953B
	and d                           ; 953C
	ld (bc),a                       ; 953D
	cp c                            ; 953E
	and d                           ; 953F
	ld (bc),a                       ; 9540
	exx                             ; 9541
	and d                           ; 9542
	ld (bc),a                       ; 9543
	ld sp,hl                        ; 9544
	and d                           ; 9545
	ld (bc),a                       ; 9546
	add hl,de                       ; 9547
	and e                           ; 9548
	ld (bc),a                       ; 9549
	add hl,sp                       ; 954A
	and e                           ; 954B
	ld (bc),a                       ; 954C
	add hl,de                       ; 954D
	and e                           ; 954E
	ld (bc),a                       ; 954F
	ld sp,hl                        ; 9550
	and d                           ; 9551
	ld (bc),a                       ; 9552
	exx                             ; 9553
	and d                           ; 9554
	ld (bc),a                       ; 9555
	cp c                            ; 9556
	and d                           ; 9557
	ld (bc),a                       ; 9558
	sbc a,c                         ; 9559
	and d                           ; 955A
	ld bc,#0xa299                   ; 955B
	ld bc,#0xa2b9                   ; 955E
	ld bc,#0xa2d9                   ; 9561
	ld bc,#0xa2f9                   ; 9564
	ld bc,#0xa319                   ; 9567
	ld bc,#0xa339                   ; 956A
	ld bc,#0xa319                   ; 956D
	ld bc,#0xa2f9                   ; 9570
	ld bc,#0xa2d9                   ; 9573
	ld bc,#0xa2b9                   ; 9576
	ld bc,#0xa299                   ; 9579
	rst 0x38                        ; 957C

;; ---------------------------------------------------------------- $0957D
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_957D
sub_b02_957D:
	ld e,e                          ; 957D
	sub l                           ; 957E

;; ---------------------------------------------------------------- $0957F
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_957F
sub_b02_957F:
	ld (bc),a                       ; 957F
	exx                             ; 9580
	and c                           ; 9581
	ld (bc),a                       ; 9582
	ld sp,hl                        ; 9583
	and c                           ; 9584
	ld (bc),a                       ; 9585
	add hl,de                       ; 9586
	and d                           ; 9587
	ld (bc),a                       ; 9588
	add hl,sp                       ; 9589
	and d                           ; 958A
	ld (bc),a                       ; 958B
	ld e,c                          ; 958C
	and d                           ; 958D
	ld (bc),a                       ; 958E
	ld a,c                          ; 958F
	and d                           ; 9590
	ld (bc),a                       ; 9591
	ld e,c                          ; 9592
	and d                           ; 9593
	ld (bc),a                       ; 9594
	add hl,sp                       ; 9595
	and d                           ; 9596
	ld (bc),a                       ; 9597
	add hl,de                       ; 9598
	and d                           ; 9599
	ld (bc),a                       ; 959A
	ld sp,hl                        ; 959B
	and c                           ; 959C
	ld (bc),a                       ; 959D
	exx                             ; 959E
	and c                           ; 959F
	ld bc,#0xa1d9                   ; 95A0
	ld bc,#0xa1f9                   ; 95A3
	ld bc,#0xa219                   ; 95A6
	ld bc,#0xa239                   ; 95A9
	ld bc,#0xa259                   ; 95AC
	ld bc,#0xa279                   ; 95AF
	ld bc,#0xa259                   ; 95B2
	ld bc,#0xa239                   ; 95B5
	ld bc,#0xa219                   ; 95B8
	ld bc,#0xa1f9                   ; 95BB
	ld bc,#0xa1d9                   ; 95BE
	rst 0x38                        ; 95C1
	and b                           ; 95C2
	sub l                           ; 95C3
loc_b02_95C4::
	ld iy,#player_state             ; 95C4
	ld a,(joypad_state)             ; 95C8
	and #0x10                       ; 95CB
	ld a,(player_CF08)                 ; 95CD
	jr z,loc_b02_95F8               ; 95D0
	cp #0x2d                        ; 95D2
	jr nc,loc_b02_9602              ; 95D4
	inc a                           ; 95D6
	ld (player_CF08),a                 ; 95D7
	cp #0x23                        ; 95DA
	jr nz,loc_b02_9602              ; 95DC
	call sub_04EC                   ; 95DE
	xor a                           ; 95E1
	ld (level_C0C6),a                 ; 95E2
	ld hl,(scene_id)                ; 95E5
	ld h,#0x00                      ; 95E8
	add hl,hl                       ; 95EA
	ld de,#data_b02_93B2            ; 95EB
	add hl,de                       ; 95EE
	ld e,(hl)                       ; 95EF
	inc hl                          ; 95F0
	ld d,(hl)                       ; 95F1
	ld (pal_anim_spr_ptr),de        ; 95F2
	jr loc_b02_9602                 ; 95F6
loc_b02_95F8:
	or a                            ; 95F8
	jr z,loc_b02_9602               ; 95F9
	cp #0x2d                        ; 95FB
	jr nc,loc_b02_9602              ; 95FD
	call sub_b02_9D47               ; 95FF
loc_b02_9602:
	call sub_b02_8C02               ; 9602
	ld a,(player_CF21)                 ; 9605
	ld hl,#tmp_d3                   ; 9608
	cp (hl)                         ; 960B
	jr z,loc_b02_9615               ; 960C
	xor a                           ; 960E
	ld (scroll_C19E),a                 ; 960F
	ld (player_CEF7),a                 ; 9612
loc_b02_9615:
	ld de,#data_b02_937C            ; 9615
	jp loc_b02_8037                 ; 9618

;; ---------------------------------------------------------------- $0961B
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_961B
sub_b02_961B:
	ld a,(tmp_d3)                   ; 961B
	ld (player_CF21),a                 ; 961E
	ld hl,#player_CF11                 ; 9621
	dec (hl)                        ; 9624
	jr nz,loc_b02_963F              ; 9625
	ld a,(scene_id)                 ; 9627
	cp #0x2c                        ; 962A
	jr nz,loc_b02_9639              ; 962C
	ld hl,#game_flags               ; 962E
	set 4,(hl)                      ; 9631
	ld a,#0x09                      ; 9633
	ld (player_C1B3),a                 ; 9635
	ret                             ; 9638
loc_b02_9639:
	ld hl,#irq_flags                ; 9639
	set 6,(hl)                      ; 963C
	ret                             ; 963E
loc_b02_963F:
	ld hl,(player_CF13)                ; 963F
	ld e,(hl)                       ; 9642
	inc hl                          ; 9643
	ld d,(hl)                       ; 9644
	inc hl                          ; 9645
	push hl                         ; 9646
	ld hl,#0x8000                   ; 9647
	or a                            ; 964A
	sbc hl,de                       ; 964B
	pop hl                          ; 964D
	jr nz,loc_b02_9659              ; 964E
	ld de,#MAPPER_CTRL              ; 9650
	add hl,de                       ; 9653
	ld e,(hl)                       ; 9654
	inc hl                          ; 9655
	ld d,(hl)                       ; 9656
	inc hl                          ; 9657
	xor a                           ; 9658
loc_b02_9659:
	ld (player_CF13),hl                ; 9659
	ld (player_CEFF),de                ; 965C
	ld a,(player_CF20)                 ; 9660
	bit 1,a                         ; 9663
	ret z                           ; 9665
	ld a,(player_CF06)                 ; 9666
	or a                            ; 9669
	call z,sub_27D3                 ; 966A
	ld hl,#0x0000                   ; 966D
	ld (player_CEFF),hl                ; 9670
	ld hl,#data_b02_819E            ; 9673
	ld (player_CF13),hl                ; 9676
	ret                             ; 9679

;; ---------------------------------------------------------------- $0967A
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_967A
sub_b02_967A:
	ld a,(tmp_d3)                   ; 967A
	ld (player_CF21),a                 ; 967D
	ld a,(player_CEFD)                 ; 9680
	or a                            ; 9683
	jr nz,loc_b02_96CA              ; 9684
	ld 22(iy),#0x00                 ; 9686
	ld hl,#player_CF20                 ; 968A
	bit 1,(hl)                      ; 968D
	jp nz,loc_b02_9CC3              ; 968F
	ld a,#0x0c                      ; 9692
	ld (player_CEF6),a                 ; 9694
	ld 9(iy),#0x00                  ; 9697
	ld 8(iy),#0x00                  ; 969B
	ld 10(iy),#0x00                 ; 969F
	ld de,#data_b02_8176            ; 96A3
	ld (player_CF13),de                ; 96A6
	ex de,hl                        ; 96AA
	ld e,(hl)                       ; 96AB
	inc hl                          ; 96AC
	ld d,(hl)                       ; 96AD
	inc hl                          ; 96AE
	push hl                         ; 96AF
	ld hl,#0x8000                   ; 96B0
	or a                            ; 96B3
	sbc hl,de                       ; 96B4
	pop hl                          ; 96B6
	jr nz,loc_b02_96C2              ; 96B7
	ld de,#MAPPER_CTRL              ; 96B9
	add hl,de                       ; 96BC
	ld e,(hl)                       ; 96BD
	inc hl                          ; 96BE
	ld d,(hl)                       ; 96BF
	inc hl                          ; 96C0
	xor a                           ; 96C1
loc_b02_96C2:
	ld (player_CF13),hl                ; 96C2
	ld (player_CEFF),de                ; 96C5
	ret                             ; 96C9
loc_b02_96CA:
	call sub_b02_86C7               ; 96CA
	ld hl,(player_CF13)                ; 96CD
	ld e,(hl)                       ; 96D0
	inc hl                          ; 96D1
	ld d,(hl)                       ; 96D2
	inc hl                          ; 96D3
	push hl                         ; 96D4
	ld hl,#0x8000                   ; 96D5
	or a                            ; 96D8
	sbc hl,de                       ; 96D9
	pop hl                          ; 96DB
	jr nz,loc_b02_96E7              ; 96DC
	ld de,#MAPPER_CTRL              ; 96DE
	add hl,de                       ; 96E1
	ld e,(hl)                       ; 96E2
	inc hl                          ; 96E3
	ld d,(hl)                       ; 96E4
	inc hl                          ; 96E5
	xor a                           ; 96E6
loc_b02_96E7:
	ld (player_CF13),hl                ; 96E7
	ld (player_CEFF),de                ; 96EA
	ld a,(player_CF20)                 ; 96EE
	jr nz,loc_b02_971C              ; 96F1
	ld de,#0x819e                   ; 96F3
	or a                            ; 96F6
	sbc hl,de                       ; 96F7
	ld a,(player_CF20)                 ; 96F9
	jr nz,loc_b02_9705              ; 96FC
	ld de,#data_b02_81A2            ; 96FE
	ld (player_CF13),de                ; 9701
loc_b02_9705:
	bit 1,a                         ; 9705
	ret z                           ; 9707
	ld a,(player_CF06)                 ; 9708
	or a                            ; 970B
	call z,sub_27D3                 ; 970C
	ld hl,#0x0000                   ; 970F
	ld (player_CEFF),hl                ; 9712
	ld hl,#data_b02_819E            ; 9715
	ld (player_CF13),hl                ; 9718
	ret                             ; 971B
loc_b02_971C:
	and #0x03                       ; 971C
	ret z                           ; 971E
	bit 0,a                         ; 971F
	jr z,loc_b02_9739               ; 9721
	bit 7,17(iy)                    ; 9723
	ret z                           ; 9727
	ld hl,#0x0000                   ; 9728
	ld (player_CEFF),hl                ; 972B
	bit 1,a                         ; 972E
	jr nz,loc_b02_973E              ; 9730
	ld hl,#data_b02_81A2            ; 9732
	ld (player_CF13),hl                ; 9735
	ret                             ; 9738
loc_b02_9739:
	bit 7,17(iy)                    ; 9739
	ret nz                          ; 973D
loc_b02_973E:
	ld hl,#0x0000                   ; 973E
	ld (player_CEFF),hl                ; 9741
	ld a,(player_CF06)                 ; 9744
	or a                            ; 9747
	call z,sub_27D3                 ; 9748
	ld hl,#data_b02_819E            ; 974B
	ld (player_CF13),hl                ; 974E
	ret                             ; 9751

;; ---------------------------------------------------------------- $09752
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_9752
sub_b02_9752:
	ld hl,#joypad_state             ; 9752
	ld a,(hl)                       ; 9755
	and #0x0e                       ; 9756
	jr z,loc_b02_97A1               ; 9758
	ld a,(joypad_pressed)           ; 975A
	bit 5,a                         ; 975D
	jr nz,loc_b02_9792              ; 975F
	ld hl,#joypad_state             ; 9761
	bit 1,(hl)                      ; 9764
	jr nz,loc_b02_976B              ; 9766
	jp loc_b02_9C68                 ; 9768
loc_b02_976B:
	ld 7(iy),#0x02                  ; 976B
	ld 9(iy),#0x00                  ; 976F
	ld 8(iy),#0x00                  ; 9773
	ld 10(iy),#0x00                 ; 9777
	ld 9(iy),#0x01                  ; 977B
	ld hl,#data_b02_810E            ; 977F
	ld (player_CF11),hl                ; 9782
	ld (player_CF13),hl                ; 9785
	ld hl,#0x0000                   ; 9788
	ld (player_CF01),hl                ; 978B
	ld (player_CEFF),hl                ; 978E
	ret                             ; 9791
loc_b02_9792:
	ld hl,#data_b02_8112            ; 9792
	ld (player_CF13),hl                ; 9795
	ld hl,#data_b02_8156            ; 9798
	ld (player_CF11),hl                ; 979B
	jp loc_b02_882B                 ; 979E
loc_b02_97A1:
	ld a,(joypad_pressed)           ; 97A1
	bit 5,a                         ; 97A4
	jr z,loc_b02_97B7               ; 97A6
	ld hl,#data_b02_8112            ; 97A8
	ld (player_CF13),hl                ; 97AB
	ld hl,#data_b02_810E            ; 97AE
	ld (player_CF11),hl                ; 97B1
	jp loc_b02_9C33                 ; 97B4
loc_b02_97B7:
	ld a,(player_CEF9)                 ; 97B7
	or a                            ; 97BA
	ret z                           ; 97BB
	ld a,(joypad_state)             ; 97BC
	bit 1,a                         ; 97BF
	jr nz,loc_b02_976B              ; 97C1
	jp loc_b02_9CC3                 ; 97C3

;; ---------------------------------------------------------------- $097C6
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_97C6
sub_b02_97C6:
	ld a,(player_CEF9)                 ; 97C6
	or a                            ; 97C9
	jr z,loc_b02_97D1               ; 97CA
	ld a,#0x0c                      ; 97CC
	ld (player_CEF6),a                 ; 97CE
loc_b02_97D1:
	ld hl,(player_CF11)                ; 97D1
	ld de,#0x8110                   ; 97D4
	or a                            ; 97D7
	sbc hl,de                       ; 97D8
	jr nz,loc_b02_97F1              ; 97DA
	ld a,(joypad_state)             ; 97DC
	and #0x0c                       ; 97DF
	jr z,loc_b02_9809               ; 97E1
	ld de,#data_b02_80F6            ; 97E3
	ld (player_CF11),de                ; 97E6
	ld a,#0x0c                      ; 97EA
	ld (player_CEF6),a                 ; 97EC
	jr loc_b02_9809                 ; 97EF
loc_b02_97F1:
	ld a,(joypad_state)             ; 97F1
	and #0x0c                       ; 97F4
	jr z,loc_b02_9802               ; 97F6
	ld a,(player_CF21)                 ; 97F8
	ld bc,(tmp_d3)                  ; 97FB
	cp c                            ; 97FF
	jr z,loc_b02_9809               ; 9800
loc_b02_9802:
	ld de,#data_b02_817C            ; 9802
	ld (player_CF11),de                ; 9805
loc_b02_9809:
	call sub_b02_86C7               ; 9809
	ld a,(player_CF20)                 ; 980C
	bit 1,a                         ; 980F
	jp nz,loc_b02_98A1              ; 9811
	ld hl,(player_CF13)                ; 9814
	ld e,(hl)                       ; 9817
	inc hl                          ; 9818
	ld d,(hl)                       ; 9819
	inc hl                          ; 981A
	push hl                         ; 981B
	ld hl,#0x8000                   ; 981C
	or a                            ; 981F
	sbc hl,de                       ; 9820
	pop hl                          ; 9822
	jr nz,loc_b02_982E              ; 9823
	ld de,#MAPPER_CTRL              ; 9825
	add hl,de                       ; 9828
	ld e,(hl)                       ; 9829
	inc hl                          ; 982A
	ld d,(hl)                       ; 982B
	inc hl                          ; 982C
	xor a                           ; 982D
loc_b02_982E:
	ld (player_CF13),hl                ; 982E
	ld (player_CEFF),de                ; 9831
	ld a,(player_CEF6)                 ; 9835
	cp #0x22                        ; 9838
	ret nc                          ; 983A
	ld a,(joypad_pressed)           ; 983B
	bit 4,a                         ; 983E
	jr z,loc_b02_9857               ; 9840
	ld a,#0x22                      ; 9842
	ld (player_CEF6),a                 ; 9844
	ld 9(iy),#0x00                  ; 9847
	ld 8(iy),#0x00                  ; 984B
	ld 10(iy),#0x00                 ; 984F
	call sub_052D                   ; 9853
	ret                             ; 9856
loc_b02_9857:
	ld a,(joypad_state)             ; 9857
	bit 4,a                         ; 985A
	jr nz,loc_b02_987B              ; 985C
	ld a,(joypad_state)             ; 985E
	bit 4,a                         ; 9861
	jr nz,loc_b02_987B              ; 9863
	ld a,(player_CF08)                 ; 9865
	cp #0x2d                        ; 9868
	jr nz,loc_b02_987B              ; 986A
	call sub_b02_9D47               ; 986C
	call sub_b02_9D70               ; 986F
	ld a,(player_CEF6)                 ; 9872
	add a,#0x04                     ; 9875
	ld (player_CEF6),a                 ; 9877
	ret                             ; 987A
loc_b02_987B:
	ld a,(joypad_state)             ; 987B
	bit 1,a                         ; 987E
	ld b,#0x0c                      ; 9880
	jr z,loc_b02_9886               ; 9882
	ld b,#0x1c                      ; 9884
loc_b02_9886:
	ld a,(player_CEF6)                 ; 9886
	cp b                            ; 9889
	ret z                           ; 988A
	ld a,b                          ; 988B
	ld (player_CEF6),a                 ; 988C
	ld 9(iy),#0x00                  ; 988F
	ld 8(iy),#0x00                  ; 9893
	ld 10(iy),#0x00                 ; 9897
	cp #0x1c                        ; 989B
	call z,sub_052D                 ; 989D
	ret                             ; 98A0
loc_b02_98A1:
	ld a,(player_CF06)                 ; 98A1
	or a                            ; 98A4
	call z,sub_27D3                 ; 98A5
	ld a,(player_CEF6)                 ; 98A8
	cp #0x22                        ; 98AB
	jr c,loc_b02_98BB               ; 98AD
	sub #0x04                       ; 98AF
	ld (player_CEF6),a                 ; 98B1
	ld hl,#0x0000                   ; 98B4
	ld (player_CF01),hl                ; 98B7
	ret                             ; 98BA
loc_b02_98BB:
	ld a,(joypad_state)             ; 98BB
	ld b,a                          ; 98BE
	and #0x0c                       ; 98BF
	jp nz,loc_b02_9C68              ; 98C1
	bit 0,b                         ; 98C4
	jp nz,loc_b02_9C8F              ; 98C6
	bit 1,b                         ; 98C9
	jp nz,loc_b02_9CA9              ; 98CB
	jp loc_b02_9C4B                 ; 98CE

;; ---------------------------------------------------------------- $098D1
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_98D1
sub_b02_98D1:
	ld a,(player_CEF9)                 ; 98D1
	or a                            ; 98D4
	jr z,loc_b02_98DC               ; 98D5
	ld a,#0x0a                      ; 98D7
	ld (player_CEF6),a                 ; 98D9
loc_b02_98DC:
	ld hl,(player_CF11)                ; 98DC
	ld de,#0x8110                   ; 98DF
	or a                            ; 98E2
	sbc hl,de                       ; 98E3
	jr nz,loc_b02_98FC              ; 98E5
	ld a,(joypad_state)             ; 98E7
	and #0x0c                       ; 98EA
	jr z,loc_b02_9914               ; 98EC
	ld de,#data_b02_80F6            ; 98EE
	ld (player_CF11),de                ; 98F1
	ld a,#0x0a                      ; 98F5
	ld (player_CEF6),a                 ; 98F7
	jr loc_b02_9914                 ; 98FA
loc_b02_98FC:
	ld a,(joypad_state)             ; 98FC
	and #0x0c                       ; 98FF
	jr z,loc_b02_990D               ; 9901
	ld a,(player_CF21)                 ; 9903
	ld bc,(tmp_d3)                  ; 9906
	cp c                            ; 990A
	jr z,loc_b02_9914               ; 990B
loc_b02_990D:
	ld de,#data_b02_817C            ; 990D
	ld (player_CF11),de                ; 9910
loc_b02_9914:
	call sub_b02_86C7               ; 9914
	ld hl,(player_CF13)                ; 9917
	ld e,(hl)                       ; 991A
	inc hl                          ; 991B
	ld d,(hl)                       ; 991C
	inc hl                          ; 991D
	push hl                         ; 991E
	ld hl,#0x8000                   ; 991F
	or a                            ; 9922
	sbc hl,de                       ; 9923
	pop hl                          ; 9925
	jr nz,loc_b02_9931              ; 9926
	ld de,#MAPPER_CTRL              ; 9928
	add hl,de                       ; 992B
	ld e,(hl)                       ; 992C
	inc hl                          ; 992D
	ld d,(hl)                       ; 992E
	inc hl                          ; 992F
	xor a                           ; 9930
loc_b02_9931:
	ld (player_CF13),hl                ; 9931
	ld (player_CEFF),de                ; 9934
	jp z,loc_b02_9C0C               ; 9938
	ld a,(player_C425)                 ; 993B
	inc a                           ; 993E
	ld (player_C425),a                 ; 993F
	cp #0x00                        ; 9942
	jr c,loc_b02_995A               ; 9944
	dec a                           ; 9946
	ld (player_C425),a                 ; 9947
	ld a,(joypad_state)             ; 994A
	bit 5,a                         ; 994D
	jr nz,loc_b02_995A              ; 994F
	ld hl,#data_b02_8160            ; 9951
	ld (player_CF13),hl                ; 9954
	jp loc_b02_9C13                 ; 9957
loc_b02_995A:
	ld a,(player_CF20)                 ; 995A
	bit 0,a                         ; 995D
	jr z,loc_b02_996A               ; 995F
	ld hl,#0x0000                   ; 9961
	ld (player_CEFF),hl                ; 9964
	jp loc_b02_9C0C                 ; 9967
loc_b02_996A:
	ld a,(player_CEF6)                 ; 996A
	cp #0x20                        ; 996D
	ret nc                          ; 996F
	ld a,(joypad_pressed)           ; 9970
	bit 4,a                         ; 9973
	jr z,loc_b02_998C               ; 9975
	ld a,#0x20                      ; 9977
	ld (player_CEF6),a                 ; 9979
	ld 9(iy),#0x00                  ; 997C
	ld 8(iy),#0x00                  ; 9980
	ld 10(iy),#0x00                 ; 9984
	call sub_052D                   ; 9988
	ret                             ; 998B
loc_b02_998C:
	ld a,(joypad_state)             ; 998C
	bit 4,a                         ; 998F
	jr nz,loc_b02_99B0              ; 9991
	ld a,(joypad_state)             ; 9993
	bit 4,a                         ; 9996
	jr nz,loc_b02_99B0              ; 9998
	ld a,(player_CF08)                 ; 999A
	cp #0x2d                        ; 999D
	jr nz,loc_b02_99B0              ; 999F
	call sub_b02_9D47               ; 99A1
	call sub_b02_9D70               ; 99A4
	ld a,(player_CEF6)                 ; 99A7
	add a,#0x02                     ; 99AA
	ld (player_CEF6),a                 ; 99AC
	ret                             ; 99AF
loc_b02_99B0:
	ld a,(joypad_state)             ; 99B0
	bit 1,a                         ; 99B3
	ld b,#0x0a                      ; 99B5
	jr z,loc_b02_99BB               ; 99B7
	ld b,#0x1a                      ; 99B9
loc_b02_99BB:
	ld a,(player_CEF6)                 ; 99BB
	cp b                            ; 99BE
	ret z                           ; 99BF
	ld a,b                          ; 99C0
	ld (player_CEF6),a                 ; 99C1
	ld 9(iy),#0x00                  ; 99C4
	ld 8(iy),#0x00                  ; 99C8
	ld 10(iy),#0x00                 ; 99CC
	cp #0x1a                        ; 99D0
	call z,sub_052D                 ; 99D2
	ret                             ; 99D5

;; ---------------------------------------------------------------- $099D6
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_99D6
sub_b02_99D6:
	ld bc,(player_CF20)                ; 99D6
	bit 1,c                         ; 99DA
	jr nz,loc_b02_99E7              ; 99DC
	ld hl,#data_b02_8178            ; 99DE
	ld (player_CF11),hl                ; 99E1
	jp loc_b02_9C0C                 ; 99E4
loc_b02_99E7:
	ld a,(joypad_pressed)           ; 99E7
	bit 5,a                         ; 99EA
	jr z,loc_b02_99FD               ; 99EC
loc_b02_99EE:
	ld hl,#data_b02_810E            ; 99EE
	ld (player_CF11),hl                ; 99F1
	ld hl,#data_b02_8112            ; 99F4
	ld (player_CF13),hl                ; 99F7
	jp loc_b02_9C33                 ; 99FA
loc_b02_99FD:
	ld a,(joypad_pressed)           ; 99FD
	bit 4,a                         ; 9A00
	jp nz,loc_b02_9BE4              ; 9A02
	ld a,(joypad_state)             ; 9A05
	bit 4,a                         ; 9A08
	jr nz,loc_b02_9A1A              ; 9A0A
	ld a,(player_CF08)                 ; 9A0C
	cp #0x2d                        ; 9A0F
	jr nz,loc_b02_9A1A              ; 9A11
	call sub_b02_9D47               ; 9A13
	call sub_b02_9D70               ; 9A16
	ret                             ; 9A19
loc_b02_9A1A:
	ld a,(joypad_state)             ; 9A1A
	and #0x0f                       ; 9A1D
	ld de,#jt_b02_9A2C              ; 9A1F
	ld l,a                          ; 9A22
	ld h,#0x00                      ; 9A23
	add hl,hl                       ; 9A25
	add hl,de                       ; 9A26
	ld e,(hl)                       ; 9A27
	inc hl                          ; 9A28
	ld d,(hl)                       ; 9A29
	ex de,hl                        ; 9A2A
	jp (hl)                         ; 9A2B
jt_b02_9A2C:
	.dw loc_b02_9A4C                ; 9A2C
	.dw loc_b02_9C8F                ; 9A2E
	.dw loc_b02_9CA9                ; 9A30
	.dw loc_b02_9CA9                ; 9A32
	.dw loc_b02_9C68                ; 9A34
	.dw loc_b02_9C68                ; 9A36
	.dw loc_b02_9CA9                ; 9A38
	.dw loc_b02_9CA9                ; 9A3A
	.dw loc_b02_9C68                ; 9A3C
	.dw loc_b02_9C68                ; 9A3E
	.dw loc_b02_9CA9                ; 9A40
	.dw loc_b02_9CA9                ; 9A42
	.dw loc_b02_9C68                ; 9A44
	.dw loc_b02_9C68                ; 9A46
	.dw loc_b02_9CA9                ; 9A48
	.dw loc_b02_9CA9                ; 9A4A
loc_b02_9A4C:
	ret                             ; 9A4C

;; ---------------------------------------------------------------- $09A4D
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_9A4D
sub_b02_9A4D:
	ld a,(player_CF21)                 ; 9A4D
	ld bc,(tmp_d3)                  ; 9A50
	cp c                            ; 9A54
	jp nz,loc_b02_9C68              ; 9A55
	call sub_b02_86C7               ; 9A58
	jp z,loc_b02_9CC3               ; 9A5B
	ld bc,(player_CF20)                ; 9A5E
	bit 1,c                         ; 9A62
	jr nz,loc_b02_9A6F              ; 9A64
	ld hl,#data_b02_8178            ; 9A66
	ld (player_CF11),hl                ; 9A69
	jp loc_b02_9C0C                 ; 9A6C
loc_b02_9A6F:
	ld a,(joypad_pressed)           ; 9A6F
	bit 5,a                         ; 9A72
	jr z,loc_b02_9A85               ; 9A74
	ld hl,#data_b02_8112            ; 9A76
	ld (player_CF13),hl                ; 9A79
	ld hl,#data_b02_8156            ; 9A7C
	ld (player_CF11),hl                ; 9A7F
	jp loc_b02_9C33                 ; 9A82
loc_b02_9A85:
	ld a,(joypad_state)             ; 9A85
	bit 1,a                         ; 9A88
	jp nz,loc_b02_89DC              ; 9A8A
	ld a,(joypad_pressed)           ; 9A8D
	bit 4,a                         ; 9A90
	jp nz,loc_b02_9BE4              ; 9A92
	ld a,(joypad_state)             ; 9A95
	bit 4,a                         ; 9A98
	jr nz,loc_b02_9AAA              ; 9A9A
	ld a,(player_CF08)                 ; 9A9C
	cp #0x2d                        ; 9A9F
	jr nz,loc_b02_9AAA              ; 9AA1
	call sub_b02_9D47               ; 9AA3
	call sub_b02_9D70               ; 9AA6
	ret                             ; 9AA9
loc_b02_9AAA:
	ret                             ; 9AAA

;; ---------------------------------------------------------------- $09AAB
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_9AAB
sub_b02_9AAB:
	ld bc,(player_CF20)                ; 9AAB
	bit 1,c                         ; 9AAF
	jr nz,loc_b02_9ABC              ; 9AB1
	ld hl,#data_b02_8180            ; 9AB3
	ld (player_CF11),hl                ; 9AB6
	jp loc_b02_9C0C                 ; 9AB9
loc_b02_9ABC:
	ld a,(joypad_pressed)           ; 9ABC
	bit 5,a                         ; 9ABF
	jr z,loc_b02_9AD2               ; 9AC1
	ld hl,#data_b02_8112            ; 9AC3
	ld (player_CF13),hl                ; 9AC6
	ld hl,#data_b02_8156            ; 9AC9
	ld (player_CF11),hl                ; 9ACC
	jp loc_b02_9C33                 ; 9ACF
loc_b02_9AD2:
	ld a,(joypad_state)             ; 9AD2
	bit 1,a                         ; 9AD5
	jp nz,loc_b02_9CA9              ; 9AD7
	ld a,(joypad_pressed)           ; 9ADA
	bit 4,a                         ; 9ADD
	jp nz,loc_b02_9BE4              ; 9ADF
	ld a,(joypad_state)             ; 9AE2
	bit 4,a                         ; 9AE5
	jr nz,loc_b02_9AF7              ; 9AE7
	ld a,(player_CF08)                 ; 9AE9
	cp #0x2d                        ; 9AEC
	jr nz,loc_b02_9AF7              ; 9AEE
	call sub_b02_9D47               ; 9AF0
	call sub_b02_9D70               ; 9AF3
	ret                             ; 9AF6
loc_b02_9AF7:
	call sub_b02_86C7               ; 9AF7
	ld a,(joypad_state)             ; 9AFA
	and #0x0f                       ; 9AFD
	cp #0x03                        ; 9AFF
	jp c,loc_b02_9C83               ; 9B01
	ret                             ; 9B04

;; ---------------------------------------------------------------- $09B05
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_9B05
sub_b02_9B05:
	ld a,(player_CF20)                 ; 9B05
	bit 1,a                         ; 9B08
	jp z,loc_b02_8806               ; 9B0A
	ld a,(joypad_pressed)           ; 9B0D
	bit 5,a                         ; 9B10
	jr z,loc_b02_9B23               ; 9B12
	ld hl,#data_b02_8112            ; 9B14
	ld (player_CF13),hl                ; 9B17
	ld hl,#data_b02_810E            ; 9B1A
	ld (player_CF11),hl                ; 9B1D
	jp loc_b02_9C33                 ; 9B20
loc_b02_9B23:
	ld a,(joypad_state)             ; 9B23
	bit 4,a                         ; 9B26
	jr nz,loc_b02_9B38              ; 9B28
	ld a,(player_CF08)                 ; 9B2A
	cp #0x2d                        ; 9B2D
	jr nz,loc_b02_9B38              ; 9B2F
	call sub_b02_9D47               ; 9B31
	call sub_b02_9D70               ; 9B34
	ret                             ; 9B37
loc_b02_9B38:
	ld a,(joypad_state)             ; 9B38
	bit 0,a                         ; 9B3B
	ret nz                          ; 9B3D
	and #0x0c                       ; 9B3E
	jp nz,loc_b02_9C68              ; 9B40
	jp loc_b02_9CC3                 ; 9B43

;; ---------------------------------------------------------------- $09B46
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_9B46
sub_b02_9B46:
	ld a,(player_CF20)                 ; 9B46
	bit 1,a                         ; 9B49
	jp z,loc_b02_9C0C               ; 9B4B
	ld a,(joypad_pressed)           ; 9B4E
	bit 5,a                         ; 9B51
	jp nz,loc_b02_99EE              ; 9B53
	ld a,(player_CEF9)                 ; 9B56
	or a                            ; 9B59
	jr z,loc_b02_9B6C               ; 9B5A
	ld a,(joypad_state)             ; 9B5C
	bit 1,a                         ; 9B5F
	jp nz,loc_b02_9CA9              ; 9B61
	and #0x0c                       ; 9B64
	jp nz,loc_b02_9C68              ; 9B66
	jp loc_b02_9CC3                 ; 9B69
loc_b02_9B6C:
	ld a,(player_CEF6)                 ; 9B6C
	cp #0x14                        ; 9B6F
	ret z                           ; 9B71
	cp #0x2a                        ; 9B72
	jr z,loc_b02_9B7C               ; 9B74
	ld a,(player_CEF8)                 ; 9B76
	cp #0x02                        ; 9B79
	ret c                           ; 9B7B
loc_b02_9B7C:
	ld a,(joypad_state)             ; 9B7C
	and #0x0c                       ; 9B7F
	jp nz,loc_b02_9C68              ; 9B81
	ret                             ; 9B84

;; ---------------------------------------------------------------- $09B85
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_9B85
sub_b02_9B85:
	call sub_b02_86C7               ; 9B85
	ret nz                          ; 9B88
	call sub_21CD                   ; 9B89
	ld a,(joypad_state)             ; 9B8C
	bit 1,a                         ; 9B8F
	jp nz,loc_b02_9CA9              ; 9B91
	and #0x0c                       ; 9B94
	jp nz,loc_b02_9C68              ; 9B96
	jp loc_b02_9CC3                 ; 9B99

;; ---------------------------------------------------------------- $09B9C
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_9B9C
sub_b02_9B9C:
	ld a,(player_CF20)                 ; 9B9C
	bit 1,a                         ; 9B9F
	jp z,loc_b02_9C0C               ; 9BA1
	ld a,(joypad_pressed)           ; 9BA4
	bit 5,a                         ; 9BA7
	jr z,loc_b02_9BB9               ; 9BA9
	ld hl,#data_b02_8112            ; 9BAB
	ld (player_CF13),hl                ; 9BAE
	ld hl,#data_b02_810E            ; 9BB1
	ld (player_CF11),hl                ; 9BB4
	jr loc_b02_9C33                 ; 9BB7
loc_b02_9BB9:
	ld a,(joypad_pressed)           ; 9BB9
	bit 4,a                         ; 9BBC
	jp nz,loc_b02_9BF8              ; 9BBE
	ld a,(joypad_state)             ; 9BC1
	bit 4,a                         ; 9BC4
	jr nz,loc_b02_9BD6              ; 9BC6
	ld a,(player_CF08)                 ; 9BC8
	cp #0x2d                        ; 9BCB
	jr nz,loc_b02_9BD6              ; 9BCD
	call sub_b02_9D47               ; 9BCF
	call sub_b02_9D70               ; 9BD2
	ret                             ; 9BD5
loc_b02_9BD6:
	ld a,(joypad_state)             ; 9BD6
	bit 1,a                         ; 9BD9
	ret nz                          ; 9BDB
	and #0x0c                       ; 9BDC
	jp nz,loc_b02_9C68              ; 9BDE
	jp loc_b02_9CC3                 ; 9BE1
loc_b02_9BE4:
	ld 7(iy),#0x1e                  ; 9BE4
	ld 9(iy),#0x00                  ; 9BE8
	ld 8(iy),#0x00                  ; 9BEC
	ld 10(iy),#0x00                 ; 9BF0
	call sub_052D                   ; 9BF4
	ret                             ; 9BF7
loc_b02_9BF8:
	ld 7(iy),#0x14                  ; 9BF8
	ld 9(iy),#0x00                  ; 9BFC
	ld 8(iy),#0x00                  ; 9C00
	ld 10(iy),#0x00                 ; 9C04
	call sub_052D                   ; 9C08
	ret                             ; 9C0B
loc_b02_9C0C:
	ld de,#data_b02_8160            ; 9C0C
	ld (player_CF13),de                ; 9C0F
loc_b02_9C13:
	call sub_b02_86C7               ; 9C13
	ld a,7(iy)                      ; 9C16
	cp #0x16                        ; 9C19
	jr c,loc_b02_9C21               ; 9C1B
	add a,#0x02                     ; 9C1D
	jr loc_b02_9C2F                 ; 9C1F
loc_b02_9C21:
	ld 9(iy),#0x00                  ; 9C21
	ld 8(iy),#0x00                  ; 9C25
	ld 10(iy),#0x00                 ; 9C29
	ld a,#0x0c                      ; 9C2D
loc_b02_9C2F:
	ld 7(iy),a                      ; 9C2F
	ret                             ; 9C32
loc_b02_9C33:
	ld 7(iy),#0x0a                  ; 9C33
	ld 9(iy),#0x00                  ; 9C37
	ld 8(iy),#0x00                  ; 9C3B
	ld 10(iy),#0x00                 ; 9C3F
	call sub_b02_86C7               ; 9C43
	xor a                           ; 9C46
	ld (player_C425),a                 ; 9C47
	ret                             ; 9C4A
loc_b02_9C4B:
	ld 7(iy),#0x0e                  ; 9C4B
	ld 9(iy),#0x00                  ; 9C4F
	ld 8(iy),#0x00                  ; 9C53
	ld 10(iy),#0x00                 ; 9C57
	call sub_0532                   ; 9C5B
	ld hl,#0x0000                   ; 9C5E
	ld (player_CF11),hl                ; 9C61
	ld (player_CF13),hl                ; 9C64
	ret                             ; 9C67
loc_b02_9C68:
	ld 7(iy),#0x06                  ; 9C68
	ld de,#data_b02_8102            ; 9C6C
	ld (player_CF11),de                ; 9C6F
	call sub_b02_86C7               ; 9C73
	ld 9(iy),#0x00                  ; 9C76
	ld 8(iy),#0x00                  ; 9C7A
	ld 10(iy),#0x00                 ; 9C7E
	ret                             ; 9C82
loc_b02_9C83:
	ld 7(iy),#0x08                  ; 9C83
	ld de,#data_b02_80BC            ; 9C87
	ld (player_CF11),de                ; 9C8A
	ret                             ; 9C8E
loc_b02_9C8F:
	ld 7(iy),#0x04                  ; 9C8F
	ld 9(iy),#0x00                  ; 9C93
	ld 8(iy),#0x00                  ; 9C97
	ld 10(iy),#0x00                 ; 9C9B
	ld hl,#0x0000                   ; 9C9F
	ld (player_CF11),hl                ; 9CA2
	ld (player_CF13),hl                ; 9CA5
	ret                             ; 9CA8
loc_b02_9CA9:
	ld 7(iy),#0x02                  ; 9CA9
	ld 9(iy),#0x00                  ; 9CAD
	ld 8(iy),#0x00                  ; 9CB1
	ld 10(iy),#0x00                 ; 9CB5
	ld hl,#data_b02_810E            ; 9CB9
	ld (player_CF11),hl                ; 9CBC
	ld (player_CF13),hl                ; 9CBF
	ret                             ; 9CC2
loc_b02_9CC3:
	ld 7(iy),#0x00                  ; 9CC3
	ld hl,#0x0000                   ; 9CC7
	ld (player_CF01),hl                ; 9CCA
	ld (player_CEFF),hl                ; 9CCD
	ld hl,#0x0000                   ; 9CD0
	ld (player_CF11),hl                ; 9CD3
	ld (player_CF13),hl                ; 9CD6
	ld hl,#0x0000                   ; 9CD9
	ld 9(iy),#0x00                  ; 9CDC
	ld 8(iy),#0x00                  ; 9CE0
	ld 10(iy),#0x00                 ; 9CE4
	ld (player_CF01),hl                ; 9CE8
	ld (player_CEFF),hl                ; 9CEB
	ret                             ; 9CEE

;; ---------------------------------------------------------------- $09CEF
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_9CEF
sub_b02_9CEF:
	ld hl,(player_CF11)                ; 9CEF
	ld de,#0x8110                   ; 9CF2
	or a                            ; 9CF5
	sbc hl,de                       ; 9CF6
	jr nz,loc_b02_9D0A              ; 9CF8
	ld a,(joypad_state)             ; 9CFA
	and #0x0c                       ; 9CFD
	jr z,loc_b02_9D22               ; 9CFF
	ld de,#data_b02_817C            ; 9D01
	ld (player_CF11),de                ; 9D04
	jr loc_b02_9D22                 ; 9D08
loc_b02_9D0A:
	ld a,(joypad_state)             ; 9D0A
	and #0x0c                       ; 9D0D
	jr z,loc_b02_9D1B               ; 9D0F
	ld a,(player_CF21)                 ; 9D11
	ld bc,(tmp_d3)                  ; 9D14
	cp c                            ; 9D18
	jr z,loc_b02_9D22               ; 9D19
loc_b02_9D1B:
	ld de,#data_b02_817C            ; 9D1B
	ld (player_CF11),de                ; 9D1E
loc_b02_9D22:
	call sub_b02_86C7               ; 9D22
	ld hl,(player_CF13)                ; 9D25
	ld e,(hl)                       ; 9D28
	inc hl                          ; 9D29
	ld d,(hl)                       ; 9D2A
	inc hl                          ; 9D2B
	push hl                         ; 9D2C
	ld hl,#0x8000                   ; 9D2D
	or a                            ; 9D30
	sbc hl,de                       ; 9D31
	pop hl                          ; 9D33
	jr nz,loc_b02_9D3F              ; 9D34
	ld de,#MAPPER_CTRL              ; 9D36
	add hl,de                       ; 9D39
	ld e,(hl)                       ; 9D3A
	inc hl                          ; 9D3B
	ld d,(hl)                       ; 9D3C
	inc hl                          ; 9D3D
	xor a                           ; 9D3E
loc_b02_9D3F:
	ld (player_CF13),hl                ; 9D3F
	ld (player_CEFF),de                ; 9D42
	ret                             ; 9D46

;; ---------------------------------------------------------------- $09D47
;; classement : atteinte uniquement par tbl_b02_8000
	.area _B02_9D47
sub_b02_9D47:
	ld de,#data_b02_9DF1            ; 9D47
	ld hl,(scene_id)                ; 9D4A
	ld h,#0x00                      ; 9D4D
	add hl,hl                       ; 9D4F
	add hl,de                       ; 9D50
	ld e,(hl)                       ; 9D51
	inc hl                          ; 9D52
	ld d,(hl)                       ; 9D53
	ex de,hl                        ; 9D54
	ld de,#0xc03a                   ; 9D55
	ld bc,#0x0020                   ; 9D58
	ldir                            ; 9D5B
	ld hl,#0x0000                   ; 9D5D
	ld (pal_anim_spr_ptr),hl        ; 9D60
	xor a                           ; 9D63
	ld (player_CF08),a                 ; 9D64
	ld (level_C0C6),a                 ; 9D67
	ld hl,#vdp_requests2            ; 9D6A
	set 6,(hl)                      ; 9D6D
	ret                             ; 9D6F

;; ---------------------------------------------------------------- $09D70
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_9D70
sub_b02_9D70:
	ld a,(flow_C1B6)                 ; 9D70
	ld l,a                          ; 9D73
	res 7,l                         ; 9D74
	bit 7,a                         ; 9D76
	ld a,#0x00                      ; 9D78
	jr z,loc_b02_9D7E               ; 9D7A
	ld a,#0x04                      ; 9D7C
loc_b02_9D7E:
	add a,l                         ; 9D7E
	add a,a                         ; 9D7F
	ld l,a                          ; 9D80
	ld h,#0x00                      ; 9D81
	ld de,#data_b02_9DBD            ; 9D83
	add hl,de                       ; 9D86
	ld a,(hl)                       ; 9D87
	ld (player_CF25),a                 ; 9D88
	inc hl                          ; 9D8B
	ld a,(hl)                       ; 9D8C
	ld (player_CEF6),a                 ; 9D8D
	ld 9(iy),#0x00                  ; 9D90
	ld 8(iy),#0x00                  ; 9D94
	ld 10(iy),#0x00                 ; 9D98
	cp #0x30                        ; 9D9C
	jr nz,loc_b02_9DB9              ; 9D9E
	call sub_b02_B842               ; 9DA0
	ld hl,#data_b02_9DCD            ; 9DA3
	ld a,(flow_C1B6)                 ; 9DA6
	bit 7,a                         ; 9DA9
	jr z,loc_b02_9DB0               ; 9DAB
	ld hl,#data_b02_9DDF            ; 9DAD
loc_b02_9DB0:
	ld (player_CF11),hl                ; 9DB0
	ld a,#0xa6                      ; 9DB3
	ld (snd_queue_music),a          ; 9DB5
	ret                             ; 9DB8
loc_b02_9DB9:
	call sub_22BF                   ; 9DB9
	ret                             ; 9DBC
data_b02_9DBD:
	.db 0x04, 0x1e, 0x06            ; 9DBD
	.db 0x2a, 0x00, 0x30, 0x05, 0x1e, 0x08, 0x1e, 0x09, 0x2a, 0x00, 0x30, 0x07, 0x24 ; 9DC0
data_b02_9DCD:
	.db 0x00, 0x05, 0x00            ; 9DCD
	.db 0x05, 0x00, 0x05, 0x00, 0x05, 0x00, 0x05, 0x00, 0x05, 0x00, 0x05, 0x00, 0x05, 0x00, 0x80 ; 9DD0
data_b02_9DDF:
	.db 0x00                        ; 9DDF
	.db 0x06, 0x00, 0x06, 0x00, 0x06, 0x00, 0x06, 0x00, 0x06, 0x00, 0x06, 0x00, 0x06, 0x00, 0x06, 0x00 ; 9DE0
	.db 0x80                        ; 9DF0
data_b02_9DF1:
	.db 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0xd9 ; 9DF1
	.db 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x59, 0xa0, 0x99 ; 9E00
	.db 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99 ; 9E10
	.db 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99 ; 9E20
	.db 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0xa5, 0x99, 0x9f, 0x19, 0xa1, 0x99, 0xa5, 0x99 ; 9E30
	.db 0xa5, 0x99, 0xa5, 0x99, 0x9f, 0x59, 0xa3, 0x99, 0xa2, 0x99, 0xa2, 0x99, 0xa5, 0x99, 0xa5, 0x99 ; 9E40
	.db 0xa5, 0x99, 0x9f, 0x99, 0xa5, 0xd9, 0xa1, 0xd9, 0xa1, 0xd9, 0x9e, 0xd9, 0x9e, 0xd9, 0x9e, 0x99 ; 9E50
	.db 0xa2, 0xd9, 0xa1, 0xd9, 0x9e, 0x99, 0xa4, 0x99, 0xa4, 0x99, 0xa4, 0x99, 0xa4, 0x19, 0xa5, 0x19 ; 9E60
	.db 0xa5, 0x19, 0xa5, 0x39, 0xa5, 0xf9, 0xa5, 0xf9, 0xa5, 0xf9, 0xa5, 0xf9, 0xa5, 0xf9, 0xa5, 0x19 ; 9E70
	.db 0xa6, 0x19, 0xa6, 0xd9, 0xa6, 0xd9, 0xa6, 0xd9, 0xa6, 0xf9, 0xa6, 0xf9, 0xa6, 0x59, 0xa6, 0x59 ; 9E80
	.db 0xa6, 0x59, 0xa6, 0x59, 0xa6, 0x59, 0xa6, 0x59, 0xa6, 0x59, 0xa6, 0x39, 0xa7, 0x39, 0xa7, 0x39 ; 9E90
	.db 0xa7, 0x79, 0xa7, 0x79, 0xa7, 0x79, 0xa7, 0x19, 0xa5, 0x79, 0xa7, 0x79, 0xa7, 0x79, 0xa7, 0xd9 ; 9EA0
	.db 0xa8, 0x79, 0xa7, 0x79, 0xa7, 0x79, 0xa7, 0x79, 0xa7, 0x39, 0xa6, 0x39, 0xa6, 0x39, 0xa6, 0x79 ; 9EB0
	.db 0xa7, 0x79, 0xa7, 0x79, 0xa7, 0x79, 0xa7, 0x79, 0xa7, 0x79, 0xa5, 0xa2, 0xb1, 0xf9, 0xa9, 0x79 ; 9EC0
.if VERSION_SMS_EN
	.db 0xaa, 0xf9, 0xab, 0x39, 0xa6, 0x79, 0xa5, 0xa2, 0xb1, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9ED0
.else ; VERSION_GG_JP
	.db 0xaa, 0xf9, 0xab, 0x39, 0xa6, 0x79, 0xa5, 0xa2, 0xb1, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9ED0
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; 9EE0
.if VERSION_SMS_EN
	.db 0x0f, 0x9a, 0x09, 0x45, 0x04, 0x0f, 0x05, 0xff, 0x09, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9EF0
.else ; VERSION_GG_JP
	.db 0x0f, 0x9a, 0x09, 0x45, 0x04, 0x0f, 0x05, 0xff, 0x09, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9EF0
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; 9F00
.if VERSION_SMS_EN
	.db 0x0f, 0x9a, 0x09, 0x45, 0x04, 0x5f, 0x06, 0xcf, 0x07, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9F10
.else ; VERSION_GG_JP
	.db 0x0f, 0x9a, 0x09, 0x45, 0x04, 0x5f, 0x06, 0xcf, 0x07, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9F10
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; 9F20
.if VERSION_SMS_EN
	.db 0x0f, 0x9a, 0x09, 0x45, 0x04, 0x8f, 0x06, 0x9f, 0x07, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9F30
.else ; VERSION_GG_JP
	.db 0x0f, 0x9a, 0x09, 0x45, 0x04, 0x8f, 0x06, 0x9f, 0x07, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9F30
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; 9F40
.if VERSION_SMS_EN
	.db 0x0f, 0x9a, 0x09, 0x45, 0x04, 0xbf, 0x07, 0x6f, 0x06, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9F50
.else ; VERSION_GG_JP
	.db 0x0f, 0x9a, 0x09, 0x45, 0x04, 0xbf, 0x07, 0x6f, 0x06, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9F50
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; 9F60
.if VERSION_SMS_EN
	.db 0x0f, 0x9a, 0x09, 0x45, 0x04, 0xdf, 0x0b, 0x3f, 0x05, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9F70
.else ; VERSION_GG_JP
	.db 0x0f, 0x9a, 0x09, 0x45, 0x04, 0xdf, 0x0b, 0x3f, 0x05, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9F70
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; 9F80
.if VERSION_SMS_EN
	.db 0x0f, 0x9a, 0x09, 0x45, 0x04, 0xff, 0x09, 0x0f, 0x05, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9F90
.else ; VERSION_GG_JP
	.db 0x0f, 0x9a, 0x09, 0x45, 0x04, 0xff, 0x09, 0x0f, 0x05, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9F90
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; 9FA0
.if VERSION_SMS_EN
	.db 0x0f, 0x75, 0x09, 0x00, 0x00, 0x0f, 0x05, 0xff, 0x09, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9FB0
.else ; VERSION_GG_JP
	.db 0x0f, 0x75, 0x09, 0x00, 0x00, 0x0f, 0x05, 0xff, 0x09, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9FB0
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; 9FC0
.if VERSION_SMS_EN
	.db 0x0f, 0x75, 0x09, 0x00, 0x00, 0x5f, 0x06, 0xcf, 0x07, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9FD0
.else ; VERSION_GG_JP
	.db 0x0f, 0x75, 0x09, 0x00, 0x00, 0x5f, 0x06, 0xcf, 0x07, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9FD0
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; 9FE0
.if VERSION_SMS_EN
	.db 0x0f, 0x75, 0x09, 0x00, 0x00, 0x8f, 0x06, 0x9f, 0x07, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9FF0
.else ; VERSION_GG_JP
	.db 0x0f, 0x75, 0x09, 0x00, 0x00, 0x8f, 0x06, 0x9f, 0x07, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; 9FF0
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A000
.if VERSION_SMS_EN
	.db 0x0f, 0x75, 0x09, 0x00, 0x00, 0xbf, 0x07, 0x6f, 0x06, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A010
.else ; VERSION_GG_JP
	.db 0x0f, 0x75, 0x09, 0x00, 0x00, 0xbf, 0x07, 0x6f, 0x06, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A010
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A020
.if VERSION_SMS_EN
	.db 0x0f, 0x75, 0x09, 0x00, 0x00, 0xdf, 0x0b, 0x3f, 0x05, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A030
.else ; VERSION_GG_JP
	.db 0x0f, 0x75, 0x09, 0x00, 0x00, 0xdf, 0x0b, 0x3f, 0x05, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A030
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A040
.if VERSION_SMS_EN
	.db 0x0f, 0x75, 0x09, 0x00, 0x00, 0xff, 0x09, 0x0f, 0x05, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A050
.else ; VERSION_GG_JP
	.db 0x0f, 0x75, 0x09, 0x00, 0x00, 0xff, 0x09, 0x0f, 0x05, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A050
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A060
.if VERSION_SMS_EN
	.db 0x0f, 0x2f, 0x00, 0x01, 0x02, 0x0f, 0x05, 0xff, 0x09, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A070
.else ; VERSION_GG_JP
	.db 0x0f, 0x2f, 0x00, 0x01, 0x02, 0x0f, 0x05, 0xff, 0x09, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A070
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A080
.if VERSION_SMS_EN
	.db 0x0f, 0x2f, 0x00, 0x01, 0x02, 0x5f, 0x06, 0xcf, 0x07, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A090
.else ; VERSION_GG_JP
	.db 0x0f, 0x2f, 0x00, 0x01, 0x02, 0x5f, 0x06, 0xcf, 0x07, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A090
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A0A0
.if VERSION_SMS_EN
	.db 0x0f, 0x2f, 0x00, 0x01, 0x02, 0x8f, 0x06, 0x9f, 0x07, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A0B0
.else ; VERSION_GG_JP
	.db 0x0f, 0x2f, 0x00, 0x01, 0x02, 0x8f, 0x06, 0x9f, 0x07, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A0B0
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A0C0
.if VERSION_SMS_EN
	.db 0x0f, 0x2f, 0x00, 0x01, 0x02, 0xbf, 0x07, 0x6f, 0x06, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A0D0
.else ; VERSION_GG_JP
	.db 0x0f, 0x2f, 0x00, 0x01, 0x02, 0xbf, 0x07, 0x6f, 0x06, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A0D0
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A0E0
.if VERSION_SMS_EN
	.db 0x0f, 0x2f, 0x00, 0x01, 0x02, 0xdf, 0x0b, 0x3f, 0x05, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A0F0
.else ; VERSION_GG_JP
	.db 0x0f, 0x2f, 0x00, 0x01, 0x02, 0xdf, 0x0b, 0x3f, 0x05, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A0F0
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A100
.if VERSION_SMS_EN
	.db 0x0f, 0x2f, 0x00, 0x01, 0x02, 0xff, 0x09, 0x0f, 0x05, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A110
.else ; VERSION_GG_JP
	.db 0x0f, 0x2f, 0x00, 0x01, 0x02, 0xff, 0x09, 0x0f, 0x05, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A110
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A120
.if VERSION_SMS_EN
	.db 0x0f, 0x31, 0x0d, 0xaa, 0x0a, 0x0f, 0x05, 0xff, 0x09, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A130
.else ; VERSION_GG_JP
	.db 0x0f, 0x31, 0x0d, 0xaa, 0x0a, 0x0f, 0x05, 0xff, 0x09, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A130
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A140
.if VERSION_SMS_EN
	.db 0x0f, 0x31, 0x0d, 0xaa, 0x0a, 0x5f, 0x06, 0xcf, 0x07, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A150
.else ; VERSION_GG_JP
	.db 0x0f, 0x31, 0x0d, 0xaa, 0x0a, 0x5f, 0x06, 0xcf, 0x07, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A150
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A160
.if VERSION_SMS_EN
	.db 0x0f, 0x31, 0x0d, 0xaa, 0x0a, 0x8f, 0x06, 0x9f, 0x07, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A170
.else ; VERSION_GG_JP
	.db 0x0f, 0x31, 0x0d, 0xaa, 0x0a, 0x8f, 0x06, 0x9f, 0x07, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A170
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A180
.if VERSION_SMS_EN
	.db 0x0f, 0x31, 0x0d, 0xaa, 0x0a, 0xbf, 0x07, 0x6f, 0x06, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A190
.else ; VERSION_GG_JP
	.db 0x0f, 0x31, 0x0d, 0xaa, 0x0a, 0xbf, 0x07, 0x6f, 0x06, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A190
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A1A0
.if VERSION_SMS_EN
	.db 0x0f, 0x31, 0x0d, 0xaa, 0x0a, 0xdf, 0x0b, 0x3f, 0x05, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A1B0
.else ; VERSION_GG_JP
	.db 0x0f, 0x31, 0x0d, 0xaa, 0x0a, 0xdf, 0x0b, 0x3f, 0x05, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A1B0
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A1C0
.if VERSION_SMS_EN
	.db 0x0f, 0x31, 0x0d, 0xaa, 0x0a, 0xff, 0x09, 0x0f, 0x05, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A1D0
.else ; VERSION_GG_JP
	.db 0x0f, 0x31, 0x0d, 0xaa, 0x0a, 0xff, 0x09, 0x0f, 0x05, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A1D0
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A1E0
.if VERSION_SMS_EN
	.db 0x0f, 0xb2, 0x04, 0x51, 0x01, 0x0f, 0x05, 0xff, 0x09, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A1F0
.else ; VERSION_GG_JP
	.db 0x0f, 0xb2, 0x04, 0x51, 0x01, 0x0f, 0x05, 0xff, 0x09, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A1F0
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A200
.if VERSION_SMS_EN
	.db 0x0f, 0xb2, 0x04, 0x51, 0x01, 0x5f, 0x06, 0xcf, 0x07, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A210
.else ; VERSION_GG_JP
	.db 0x0f, 0xb2, 0x04, 0x51, 0x01, 0x5f, 0x06, 0xcf, 0x07, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A210
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A220
.if VERSION_SMS_EN
	.db 0x0f, 0xb2, 0x04, 0x51, 0x01, 0x8f, 0x06, 0x9f, 0x07, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A230
.else ; VERSION_GG_JP
	.db 0x0f, 0xb2, 0x04, 0x51, 0x01, 0x8f, 0x06, 0x9f, 0x07, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A230
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A240
.if VERSION_SMS_EN
	.db 0x0f, 0xb2, 0x04, 0x51, 0x01, 0xbf, 0x07, 0x6f, 0x06, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A250
.else ; VERSION_GG_JP
	.db 0x0f, 0xb2, 0x04, 0x51, 0x01, 0xbf, 0x07, 0x6f, 0x06, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A250
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A260
.if VERSION_SMS_EN
	.db 0x0f, 0xb2, 0x04, 0x51, 0x01, 0xdf, 0x0b, 0x3f, 0x05, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A270
.else ; VERSION_GG_JP
	.db 0x0f, 0xb2, 0x04, 0x51, 0x01, 0xdf, 0x0b, 0x3f, 0x05, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A270
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A280
.if VERSION_SMS_EN
	.db 0x0f, 0xb2, 0x04, 0x51, 0x01, 0xff, 0x09, 0x0f, 0x05, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A290
.else ; VERSION_GG_JP
	.db 0x0f, 0xb2, 0x04, 0x51, 0x01, 0xff, 0x09, 0x0f, 0x05, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A290
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A2A0
.if VERSION_SMS_EN
	.db 0x0f, 0x90, 0x03, 0x00, 0x00, 0x0f, 0x05, 0xff, 0x09, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A2B0
.else ; VERSION_GG_JP
	.db 0x0f, 0x90, 0x03, 0x00, 0x00, 0x0f, 0x05, 0xff, 0x09, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A2B0
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A2C0
.if VERSION_SMS_EN
	.db 0x0f, 0x90, 0x03, 0x00, 0x00, 0x5f, 0x06, 0xcf, 0x07, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A2D0
.else ; VERSION_GG_JP
	.db 0x0f, 0x90, 0x03, 0x00, 0x00, 0x5f, 0x06, 0xcf, 0x07, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A2D0
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A2E0
.if VERSION_SMS_EN
	.db 0x0f, 0x90, 0x03, 0x00, 0x00, 0x8f, 0x06, 0x9f, 0x07, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A2F0
.else ; VERSION_GG_JP
	.db 0x0f, 0x90, 0x03, 0x00, 0x00, 0x8f, 0x06, 0x9f, 0x07, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A2F0
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A300
.if VERSION_SMS_EN
	.db 0x0f, 0x90, 0x03, 0x00, 0x00, 0xbf, 0x07, 0x6f, 0x06, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A310
.else ; VERSION_GG_JP
	.db 0x0f, 0x90, 0x03, 0x00, 0x00, 0xbf, 0x07, 0x6f, 0x06, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A310
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A320
.if VERSION_SMS_EN
	.db 0x0f, 0x90, 0x03, 0x00, 0x00, 0xdf, 0x0b, 0x3f, 0x05, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A330
.else ; VERSION_GG_JP
	.db 0x0f, 0x90, 0x03, 0x00, 0x00, 0xdf, 0x0b, 0x3f, 0x05, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A330
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A340
	.db 0x0f, 0x90, 0x03, 0x00, 0x00, 0xff, 0x09, 0x0f, 0x05, 0x88, 0x08, 0xff, 0x07, 0x00, 0x00, 0xcf ; A350
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A360
	.db 0x0f, 0x90, 0x03, 0x30, 0x00, 0x62, 0x0e, 0xef, 0x0c ; A370
data_b02_A379::
	.db 0x66, 0x02, 0xee, 0x0e, 0x00, 0x00, 0x8c ; A379
	.db 0x00, 0x4a, 0x00, 0x28, 0x00, 0xa2, 0x04, 0x60, 0x02, 0x40, 0x00, 0xa8, 0x0c, 0x64, 0x08, 0x20 ; A380
	.db 0x04, 0x62, 0x0c, 0x2e, 0x00, 0xce, 0x00, 0x1b, 0x00, 0x66, 0x02, 0xee, 0x0e, 0x00, 0x00, 0x8c ; A390
	.db 0x00, 0x4a, 0x00, 0x28, 0x00, 0xa2, 0x04, 0x60, 0x02, 0x40, 0x00, 0xa8, 0x0c, 0x64, 0x08, 0x20 ; A3A0
	.db 0x04, 0x62, 0x0c, 0x2e, 0x00, 0xce, 0x00, 0x3d, 0x00, 0x66, 0x02, 0xee, 0x0e, 0x00, 0x00, 0x8c ; A3B0
	.db 0x00, 0x4a, 0x00, 0x28, 0x00, 0xa2, 0x04, 0x60, 0x02, 0x40, 0x00, 0xa8, 0x0c, 0x64, 0x08, 0x20 ; A3C0
	.db 0x04, 0x62, 0x0c, 0x2e, 0x00, 0xce, 0x00, 0x5f, 0x00, 0x66, 0x02, 0xee, 0x0e, 0x00, 0x00, 0x8c ; A3D0
	.db 0x00, 0x4a, 0x00, 0x28, 0x00, 0xa2, 0x04, 0x60, 0x02, 0x40, 0x00, 0xa8, 0x0c, 0x64, 0x08, 0x20 ; A3E0
	.db 0x04, 0x62, 0x0c, 0x2e, 0x00, 0xce, 0x00, 0x7f, 0x02, 0x66, 0x02, 0xee, 0x0e, 0x00, 0x00, 0x8c ; A3F0
	.db 0x00, 0x4a, 0x00, 0x28, 0x00, 0xa2, 0x04, 0x60, 0x02, 0x40, 0x00, 0xa8, 0x0c, 0x64, 0x08, 0x20 ; A400
	.db 0x04, 0x62, 0x0c, 0x2e, 0x00, 0xce, 0x00, 0x9f, 0x04, 0x66, 0x02, 0xee, 0x0e, 0x00, 0x00, 0x8c ; A410
	.db 0x00, 0x4a, 0x00, 0x28, 0x00, 0xa2, 0x04, 0x60, 0x02, 0x40, 0x00, 0xa8, 0x0c, 0x64, 0x08, 0x20 ; A420
	.db 0x04, 0x62, 0x0c, 0x2e, 0x00, 0xce, 0x00, 0xbf, 0x06 ; A430
data_b02_A439::
	.db 0xcf, 0x00, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A439
	.db 0x00, 0xcf, 0x08, 0x7d, 0x03, 0x38, 0x01, 0x0f, 0x00, 0x6b, 0x01, 0x15, 0x0a, 0x63, 0x0f, 0xb7 ; A440
	.db 0x0f, 0x31, 0x0c, 0x06, 0x00, 0x26, 0x00, 0x26, 0x00 ; A450
data_b02_A459::
	.db 0xcf, 0x00, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A459
	.db 0x00, 0xcf, 0x08, 0x7d, 0x03, 0x38, 0x01, 0x0f, 0x00, 0x6b, 0x01, 0x15, 0x0a, 0x63, 0x0f, 0xb7 ; A460
	.db 0x0f, 0x31, 0x0c, 0x06, 0x00, 0x26, 0x00, 0xff, 0x0b ; A470
data_b02_A479::
	.db 0xcf, 0x00, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A479
	.db 0x00, 0xcf, 0x08, 0x7d, 0x03, 0x38, 0x01, 0x0f, 0x00, 0x6b, 0x01, 0x15, 0x0a, 0x63, 0x0f, 0xb7 ; A480
	.db 0x0f, 0x31, 0x0c, 0x06, 0x00, 0xff, 0x0b, 0x26, 0x00, 0xe7, 0x0f, 0xff, 0x0f, 0x11, 0x01, 0xc3 ; A490
	.db 0x0e, 0xaf, 0x06, 0x6c, 0x02, 0x38, 0x00, 0x34, 0x01, 0x77, 0x04, 0xba, 0x07, 0x00, 0x00, 0x6f ; A4A0
	.db 0x0d, 0xeb, 0x0e, 0xd7, 0x0e, 0xa5, 0x0c, 0x72, 0x0a, 0xe7, 0x0f, 0xff, 0x0f, 0x11, 0x01, 0xc3 ; A4B0
	.db 0x0e, 0xaf, 0x06, 0x6c, 0x02, 0x38, 0x00, 0x34, 0x01, 0x77, 0x04, 0xba, 0x07, 0x00, 0x00, 0x6f ; A4C0
	.db 0x0d, 0xd7, 0x0e, 0xa5, 0x0c, 0x72, 0x0a, 0xeb, 0x0e, 0xe7, 0x0f, 0xff, 0x0f, 0x11, 0x01, 0xc3 ; A4D0
	.db 0x0e, 0xaf, 0x06, 0x6c, 0x02, 0x38, 0x00, 0x34, 0x01, 0x77, 0x04, 0xba, 0x07, 0x00, 0x00, 0x6f ; A4E0
	.db 0x0d, 0xa5, 0x0c, 0x72, 0x0a, 0xeb, 0x0e, 0xd7, 0x0e, 0xe7, 0x0f, 0xff, 0x0f, 0x11, 0x01, 0xc3 ; A4F0
	.db 0x0e, 0xaf, 0x06, 0x6c, 0x02, 0x38, 0x00, 0x34, 0x01, 0x77, 0x04, 0xba, 0x07, 0x00, 0x00, 0x6f ; A500
	.db 0x0d, 0x72, 0x0a, 0xeb, 0x0e, 0xd7, 0x0e, 0xa5, 0x0c, 0x20, 0x04, 0xee, 0x0e, 0x00, 0x00, 0x24 ; A510
	.db 0x08, 0x46, 0x0a, 0x8a, 0x0e, 0xc8, 0x0e, 0x84, 0x0a, 0x40, 0x06, 0xce, 0x00, 0x6e, 0x00, 0xae ; A520
	.db 0x02, 0x8c, 0x0a, 0x4a, 0x08, 0x26, 0x04, 0x6e, 0x0c, 0x62, 0x0e, 0xee, 0x0e, 0x00, 0x00, 0xae ; A530
	.db 0x00, 0x6e, 0x04, 0x2a, 0x02, 0x04, 0x00, 0x4e, 0x0a, 0xc1, 0x08, 0x02, 0x04, 0x20, 0x0c, 0x0e ; A540
	.db 0x00, 0x36, 0x02, 0x42, 0x04, 0x64, 0x0a, 0x86, 0x0e, 0xab, 0x09, 0x25, 0x00, 0x21, 0x02, 0xff ; A550
	.db 0x0b, 0x85, 0x00, 0x42, 0x00, 0x0d, 0x00, 0x92, 0x03, 0x40, 0x01, 0x68, 0x03, 0x36, 0x0f, 0xef ; A560
	.db 0x0d, 0xef, 0x0d, 0xef, 0x0d, 0x87, 0x08, 0x63, 0x07, 0xbb, 0x0b, 0xef ; A570

;; ---------------------------------------------------------------- $0A57C
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_A57C
sub_b02_A57C:
	ld c,#0x00                      ; A57C
	nop                             ; A57E
	xor (hl)                        ; A57F
	dec b                           ; A580
	ld a,h                          ; A581
	inc bc                          ; A582
	ld e,c                          ; A583
	nop                             ; A584
	dec h                           ; A585
	nop                             ; A586
	and #0x02                       ; A587
	and e                           ; A589
	nop                             ; A58A
	ld d,d                          ; A58B
	nop                             ; A58C
	ld l,c                          ; A58D
	inc bc                          ; A58E
	ld b,l                          ; A58F
	ld (bc),a                       ; A590
	ret                             ; A591
	.db 0x08, 0xa6, 0x07, 0x84, 0x05, 0x6f, 0x0d, 0x88, 0x08, 0xff, 0x07, 0x00, 0x00, 0xcf ; A592
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A5A0
	.db 0x0f, 0x90, 0x03, 0x23, 0x02, 0x0d, 0x00, 0x03, 0x07, 0x62, 0x0e, 0xee, 0x0e, 0x00, 0x00, 0xae ; A5B0
	.db 0x00, 0x6e, 0x04, 0x2a, 0x02, 0x04, 0x00, 0x4e, 0x0a, 0x36, 0x02, 0x02, 0x04, 0x20, 0x0c, 0x0e ; A5C0
.if VERSION_SMS_EN
	.db 0x00, 0xc1, 0x08, 0x42, 0x04, 0x64, 0x0a, 0x86, 0x0e, 0x50, 0x0f, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A5D0
.else ; VERSION_GG_JP
	.db 0x00, 0xc1, 0x08, 0x42, 0x04, 0x64, 0x0a, 0x86, 0x0e, 0x88, 0x08, 0xff, 0x0f, 0x00, 0x00, 0xcf ; A5D0
.endif
	.db 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09, 0x63, 0x0f, 0xb7 ; A5E0
	.db 0x0f, 0x75, 0x09, 0x00, 0x00, 0x0f, 0x05, 0xff, 0x09, 0xa6, 0x0e, 0xee, 0x0e, 0x00, 0x00, 0xae ; A5F0
	.db 0x02, 0x6c, 0x00, 0x26, 0x00, 0xac, 0x0a, 0x8a, 0x06, 0x46, 0x04, 0xe4, 0x06, 0xa0, 0x04, 0x60 ; A600
	.db 0x00, 0xe8, 0x0e, 0x62, 0x0c, 0x40, 0x08, 0x6e, 0x0c, 0x64, 0x0c, 0xee, 0x0e, 0x00, 0x00, 0x20 ; A610
	.db 0x04, 0x48, 0x02, 0x42, 0x06, 0x6a, 0x04, 0x86, 0x0c, 0x44, 0x06, 0x02, 0x00, 0x22, 0x04, 0x20 ; A620
	.db 0x00, 0x8e, 0x04, 0x0e, 0x00, 0x44, 0x06, 0x00, 0x00, 0x20, 0x0e, 0xc8, 0x0e, 0x00, 0x00, 0x00 ; A630
	.db 0x06, 0x22, 0x06, 0x60, 0x00, 0x20, 0x00, 0x8e, 0x02, 0x0e, 0x00, 0xc0, 0x04, 0x00, 0x00, 0x4e ; A640
	.db 0x06, 0x22, 0x02, 0x64, 0x0e, 0x4e, 0x00, 0x8e, 0x04, 0xca, 0x0e, 0xee, 0x0e, 0x24, 0x02, 0xce ; A650
	.db 0x06, 0xce, 0x00, 0x8c, 0x00, 0x6a, 0x00, 0x48, 0x00, 0x46, 0x00, 0x0e, 0x00, 0xaa, 0x0e, 0xef ; A660
	.db 0x09, 0xcd, 0x07, 0xab, 0x05, 0x89, 0x03, 0x6e, 0x0c, 0xca, 0x0e, 0xee, 0x0e, 0x24, 0x02, 0xce ; A670
	.db 0x06, 0xce, 0x00, 0x8c, 0x00, 0x6a, 0x00, 0x48, 0x00, 0x46, 0x00, 0x0e, 0x00, 0xaa, 0x0e, 0xcd ; A680
	.db 0x07, 0xab, 0x05, 0x89, 0x03, 0xef, 0x09, 0x6e, 0x0c, 0xca, 0x0e, 0xee, 0x0e, 0x24, 0x02, 0xce ; A690
	.db 0x06, 0xce, 0x00, 0x8c, 0x00, 0x6a, 0x00, 0x48, 0x00, 0x46, 0x00, 0x0e, 0x00, 0xaa, 0x0e, 0xab ; A6A0
	.db 0x05, 0x89, 0x03, 0xef, 0x09, 0xcd, 0x07, 0x6e, 0x0c, 0xca, 0x0e, 0xee, 0x0e, 0x24, 0x02, 0xce ; A6B0
	.db 0x06, 0xce, 0x00, 0x8c, 0x00, 0x6a, 0x00, 0x48, 0x00, 0x46, 0x00, 0x0e, 0x00, 0xaa, 0x0e, 0x89 ; A6C0
	.db 0x03, 0xef, 0x09, 0xcd, 0x07, 0xab, 0x05, 0x6e, 0x0c, 0x24, 0x00, 0xee, 0x0e, 0x00, 0x00, 0x46 ; A6D0
	.db 0x00, 0x8a, 0x04, 0xac, 0x06, 0x60, 0x00, 0x82, 0x04, 0xc4, 0x06, 0x8e, 0x02, 0x4a, 0x00, 0x06 ; A6E0
	.db 0x00, 0xc8, 0x0e, 0x84, 0x0a, 0x62, 0x06, 0x6e, 0x0c, 0x32, 0x01, 0xee, 0x0e, 0x11, 0x01, 0x40 ; A6F0
	.db 0x03, 0x71, 0x06, 0xa4, 0x09, 0xd7, 0x0c, 0x24, 0x00, 0x57, 0x01, 0x8a, 0x04, 0xbd, 0x06, 0x42 ; A700
	.db 0x03, 0x64, 0x05, 0x86, 0x07, 0xcf, 0x01, 0x6f, 0x0d, 0x32, 0x01, 0xee, 0x0e, 0x11, 0x01, 0x40 ; A710
	.db 0x03, 0x71, 0x06, 0xa4, 0x09, 0xd7, 0x0c, 0x24, 0x00, 0x57, 0x01, 0x8a, 0x04, 0xbd, 0x06, 0x42 ; A720
	.db 0x03, 0x64, 0x05, 0x86, 0x07, 0xa7, 0x09, 0x6f, 0x0d, 0x02, 0x01, 0xee, 0x0e, 0x11, 0x01, 0x53 ; A730
	.db 0x00, 0x86, 0x02, 0xb9, 0x05, 0xec, 0x08, 0x35, 0x00, 0x68, 0x01, 0x9b, 0x04, 0xce, 0x06, 0x23 ; A740
	.db 0x00, 0x45, 0x00, 0x67, 0x00, 0xcf, 0x01, 0x6f, 0x0d, 0x02, 0x01, 0xee, 0x0e, 0x11, 0x01, 0x53 ; A750
	.db 0x00, 0x86, 0x02, 0xb9, 0x05, 0xec, 0x08, 0x35, 0x00, 0x68, 0x01, 0x9b, 0x04, 0xce, 0x06, 0x23 ; A760
	.db 0x00, 0x45, 0x00, 0x67, 0x00, 0xa7, 0x09, 0x6f, 0x0d, 0x60, 0x04, 0xee, 0x0e, 0x00, 0x00, 0xae ; A770
	.db 0x04, 0x8c, 0x02, 0x48, 0x00, 0x24, 0x00, 0xe6, 0x02, 0xa2, 0x00, 0x42, 0x00, 0x68, 0x02, 0x44 ; A780
	.db 0x02, 0xc8, 0x08, 0xa6, 0x06, 0x84, 0x04, 0x6e, 0x0c, 0x62, 0x04, 0xee, 0x0e, 0x00, 0x00, 0xae ; A790
	.db 0x04, 0x8c, 0x02, 0x48, 0x00, 0x24, 0x00, 0xe6, 0x02, 0xa2, 0x00, 0x42, 0x00, 0x68, 0x02, 0x44 ; A7A0
	.db 0x02, 0xc8, 0x08, 0xb6, 0x07, 0x84, 0x05, 0x6e, 0x0c, 0x62, 0x04, 0xee, 0x0e, 0x00, 0x00, 0xae ; A7B0
	.db 0x04, 0x8c, 0x02, 0x48, 0x00, 0x24, 0x00, 0xe6, 0x02, 0xa2, 0x00, 0x42, 0x00, 0x68, 0x02, 0x44 ; A7C0
	.db 0x02, 0xb8, 0x08, 0xc8, 0x08, 0x73, 0x04, 0x6e, 0x0c, 0x62, 0x04, 0xee, 0x0e, 0x00, 0x00, 0xae ; A7D0
	.db 0x04, 0x8c, 0x02, 0x48, 0x00, 0x24, 0x00, 0xe6, 0x02, 0xa2, 0x00, 0x42, 0x00, 0x68, 0x02, 0x44 ; A7E0
	.db 0x02, 0xa6, 0x07, 0xc8, 0x08, 0x94, 0x05, 0x6e, 0x0c, 0x62, 0x04, 0xee, 0x0e, 0x00, 0x00, 0xae ; A7F0
	.db 0x04, 0x8c, 0x02, 0x48, 0x00, 0x24, 0x00, 0xe6, 0x02, 0xa2, 0x00, 0x42, 0x00, 0x68, 0x02, 0x44 ; A800
	.db 0x02, 0x95, 0x06, 0xb8, 0x08, 0xa5, 0x06, 0x6e, 0x0c, 0x62, 0x04, 0xee, 0x0e, 0x00, 0x00, 0xae ; A810
	.db 0x04, 0x8c, 0x02, 0x48, 0x00, 0x24, 0x00, 0xe6, 0x02, 0xa2, 0x00, 0x42, 0x00, 0x68, 0x02, 0x44 ; A820
	.db 0x02, 0x84, 0x05, 0xa6, 0x07, 0xb6, 0x07, 0x6e, 0x0c, 0x62, 0x04, 0xee, 0x0e, 0x00, 0x00, 0xae ; A830
	.db 0x04, 0x8c, 0x02, 0x48, 0x00, 0x24, 0x00, 0xe6, 0x02, 0xa2, 0x00, 0x42, 0x00, 0x68, 0x02, 0x44 ; A840
	.db 0x02, 0x73, 0x04, 0x95, 0x06, 0xc8, 0x08, 0x6e, 0x0c, 0x62, 0x04, 0xee, 0x0e, 0x00, 0x00, 0xae ; A850
	.db 0x04, 0x8c, 0x02, 0x48, 0x00, 0x24, 0x00, 0xe6, 0x02, 0xa2, 0x00, 0x42, 0x00, 0x68, 0x02, 0x44 ; A860
	.db 0x02, 0x94, 0x05, 0x84, 0x05, 0xc8, 0x08, 0x6e, 0x0c, 0x62, 0x04, 0xee, 0x0e, 0x00, 0x00, 0xae ; A870
	.db 0x04, 0x8c, 0x02, 0x48, 0x00, 0x24, 0x00, 0xe6, 0x02, 0xa2, 0x00, 0x42, 0x00, 0x68, 0x02, 0x44 ; A880
	.db 0x02, 0xa5, 0x06, 0x73, 0x04, 0xb8, 0x08, 0x6e, 0x0c, 0x62, 0x04, 0xee, 0x0e, 0x00, 0x00, 0xae ; A890
	.db 0x04, 0x8c, 0x02, 0x48, 0x00, 0x24, 0x00, 0xe6, 0x02, 0xa2, 0x00, 0x42, 0x00, 0x68, 0x02, 0x44 ; A8A0
	.db 0x02, 0xb6, 0x07, 0x94, 0x05, 0xa6, 0x07, 0x6e, 0x0c, 0x62, 0x04, 0xee, 0x0e, 0x00, 0x00, 0xae ; A8B0
	.db 0x04, 0x8c, 0x02, 0x48, 0x00, 0x24, 0x00, 0xe6, 0x02, 0xa2, 0x00, 0x42, 0x00, 0x68, 0x02, 0x44 ; A8C0
	.db 0x02, 0xc8, 0x08, 0xa5, 0x06, 0x95, 0x06, 0x6e, 0x0c, 0x12, 0x00, 0x01, 0x00, 0x24, 0x01, 0x78 ; A8D0
	.db 0x01, 0x48, 0x01, 0x09, 0x00, 0x06, 0x00, 0x03, 0x00, 0x20, 0x03, 0x41, 0x04, 0x46, 0x03, 0x68 ; A8E0
	.db 0x05, 0xbf, 0x01, 0x6f, 0x00, 0x41, 0x04, 0x41, 0x04, 0x12, 0x00, 0x01, 0x00, 0x24, 0x01, 0x78 ; A8F0
	.db 0x01, 0x48, 0x01, 0x09, 0x00, 0x06, 0x00, 0x03, 0x00, 0x20, 0x03, 0x41, 0x04, 0x46, 0x03, 0x68 ; A900
	.db 0x05, 0x9f, 0x01, 0x4e, 0x00, 0x41, 0x04, 0x41, 0x04, 0x12, 0x00, 0x01, 0x00, 0x24, 0x01, 0x78 ; A910
	.db 0x01, 0x48, 0x01, 0x09, 0x00, 0x06, 0x00, 0x03, 0x00, 0x40, 0x04, 0x61, 0x06, 0x46, 0x03, 0x68 ; A920
	.db 0x05, 0x7e, 0x02, 0x2d, 0x01, 0x61, 0x06, 0x89, 0x09, 0x12, 0x00, 0x01, 0x00, 0x35, 0x02, 0x8c ; A930
	.db 0x03, 0x59, 0x03, 0x2b, 0x02, 0x18, 0x01, 0x05, 0x00, 0x60, 0x06, 0x82, 0x08, 0x56, 0x03, 0x78 ; A940
	.db 0x05, 0x5c, 0x04, 0x1b, 0x02, 0xab, 0x0d, 0x82, 0x08, 0x23, 0x01, 0x12, 0x01, 0x46, 0x04, 0x9d ; A950
	.db 0x05, 0x6a, 0x05, 0x3c, 0x04, 0x29, 0x03, 0x16, 0x02, 0x52, 0x05, 0x83, 0x08, 0x67, 0x05, 0x89 ; A960
	.db 0x07, 0x7e, 0x02, 0x2d, 0x01, 0x83, 0x08, 0xdb, 0x0d, 0x12, 0x00, 0x01, 0x00, 0x35, 0x02, 0x8c ; A970
	.db 0x03, 0x59, 0x03, 0x2b, 0x02, 0x18, 0x01, 0x05, 0x00, 0x20, 0x03, 0x41, 0x04, 0x56, 0x03, 0x78 ; A980
	.db 0x05, 0x9f, 0x01, 0x4e, 0x00, 0x41, 0x04, 0x41, 0x04, 0x12, 0x00, 0x01, 0x00, 0x24, 0x01, 0x78 ; A990
	.db 0x01, 0x48, 0x01, 0x09, 0x00, 0x06, 0x00, 0x03, 0x00, 0x20, 0x03, 0x41, 0x04, 0x46, 0x03, 0x68 ; A9A0
	.db 0x05, 0x7e, 0x02, 0x2d, 0x01, 0x41, 0x04, 0x41, 0x04, 0x23, 0x01, 0x12, 0x01, 0x46, 0x04, 0x9d ; A9B0
	.db 0x05, 0x6a, 0x05, 0x3c, 0x04, 0x29, 0x03, 0x16, 0x02, 0x20, 0x03, 0x41, 0x04, 0x67, 0x05, 0x89 ; A9C0
	.db 0x07, 0x5c, 0x04, 0x1b, 0x02, 0x41, 0x04, 0x41, 0x04, 0x12, 0x00, 0x01, 0x00, 0x24, 0x01, 0x78 ; A9D0
	.db 0x01, 0x48, 0x01, 0x09, 0x00, 0x06, 0x00, 0x03, 0x00, 0x52, 0x05, 0x83, 0x08, 0x46, 0x03, 0x68 ; A9E0
	.db 0x05, 0x9f, 0x01, 0x4e, 0x00, 0x83, 0x08, 0xbb, 0x0d, 0x12, 0x03, 0x34, 0x02, 0x12, 0x03, 0x07 ; A9F0
	.db 0x02, 0x39, 0x07, 0x68, 0x0a, 0x13, 0x03, 0x14, 0x03, 0x13, 0x03, 0x13, 0x03, 0x13, 0x03, 0x13 ; AA00
	.db 0x03, 0x13, 0x03, 0x12, 0x03, 0x11, 0x03, 0x11, 0x02, 0x13, 0x03, 0x44, 0x02, 0x13, 0x03, 0x06 ; AA10
	.db 0x02, 0x38, 0x07, 0x67, 0x0a, 0x14, 0x03, 0x15, 0x03, 0x14, 0x03, 0x14, 0x03, 0x14, 0x03, 0x13 ; AA20
	.db 0x03, 0x14, 0x03, 0x13, 0x03, 0x12, 0x03, 0x11, 0x03, 0x14, 0x03, 0x45, 0x02, 0x14, 0x03, 0x05 ; AA30
	.db 0x02, 0x37, 0x07, 0x66, 0x0a, 0x15, 0x03, 0x16, 0x03, 0x15, 0x03, 0x15, 0x03, 0x14, 0x03, 0x13 ; AA40
	.db 0x03, 0x15, 0x03, 0x14, 0x03, 0x13, 0x03, 0x12, 0x03, 0x15, 0x03, 0x55, 0x02, 0x15, 0x03, 0x04 ; AA50
	.db 0x02, 0x36, 0x07, 0x65, 0x0a, 0x16, 0x03, 0x17, 0x03, 0x16, 0x03, 0x15, 0x03, 0x14, 0x03, 0x13 ; AA60
	.db 0x03, 0x16, 0x03, 0x15, 0x03, 0x14, 0x03, 0x13, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07 ; AA70
	.db 0x02, 0x39, 0x07, 0x68, 0x0a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; AA80
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00, 0x01, 0x00, 0x07 ; AA90
	.db 0x02, 0x39, 0x07, 0x68, 0x0a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; AAA0
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x12, 0x00, 0x11, 0x00, 0x07 ; AAB0
	.db 0x02, 0x39, 0x07, 0x68, 0x0a, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; AAC0
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x34, 0x00, 0x22, 0x00, 0x07 ; AAD0
	.db 0x02, 0x39, 0x07, 0x68, 0x0a, 0x00, 0x00, 0x02, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; AAE0
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x45, 0x00, 0x34, 0x01, 0x07 ; AAF0
	.db 0x02, 0x39, 0x07, 0x68, 0x0a, 0x00, 0x00, 0x04, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00 ; AB00
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x03, 0x00, 0x00, 0x56, 0x00, 0x45, 0x02, 0x07 ; AB10
	.db 0x02, 0x39, 0x07, 0x68, 0x0a, 0x00, 0x00, 0x15, 0x02, 0x05, 0x00, 0x03, 0x00, 0x01, 0x00, 0x00 ; AB20
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x12, 0x04, 0x00, 0x00, 0x67, 0x00, 0x56, 0x03, 0x07 ; AB30
	.db 0x02, 0x39, 0x07, 0x68, 0x0a, 0x00, 0x00, 0x26, 0x03, 0x07, 0x01, 0x04, 0x00, 0x02, 0x00, 0x00 ; AB40
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x23, 0x05, 0x00, 0x00, 0x78, 0x01, 0x67, 0x04, 0x07 ; AB50
	.db 0x02, 0x39, 0x07, 0x68, 0x0a, 0x11, 0x01, 0x37, 0x04, 0x08, 0x02, 0x06, 0x01, 0x04, 0x00, 0x01 ; AB60
	.db 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x03, 0x34, 0x06, 0x00, 0x00, 0x9a, 0x02, 0x78, 0x05, 0x07 ; AB70
	.db 0x02, 0x39, 0x07, 0x68, 0x0a, 0x22, 0x02, 0x48, 0x05, 0x1a, 0x03, 0x08, 0x02, 0x06, 0x00, 0x02 ; AB80
	.db 0x00, 0x00, 0x00, 0x00, 0x02, 0x12, 0x04, 0x45, 0x07, 0x00, 0x00, 0xac, 0x03, 0x89, 0x06, 0x07 ; AB90
	.db 0x02, 0x39, 0x07, 0x68, 0x0a, 0x34, 0x03, 0x59, 0x06, 0x2b, 0x04, 0x0a, 0x03, 0x07, 0x00, 0x03 ; ABA0
	.db 0x00, 0x00, 0x00, 0x01, 0x03, 0x23, 0x05, 0x56, 0x08, 0x00, 0x01, 0xcd, 0x04, 0x9a, 0x07, 0x07 ; ABB0
	.db 0x02, 0x39, 0x07, 0x68, 0x0a, 0x45, 0x04, 0x6b, 0x07, 0x3d, 0x05, 0x0c, 0x04, 0x09, 0x00, 0x05 ; ABC0
	.db 0x00, 0x01, 0x01, 0x02, 0x04, 0x34, 0x06, 0x67, 0x09, 0x01, 0x01, 0xde, 0x05, 0xab, 0x08, 0x07 ; ABD0
	.db 0x02, 0x39, 0x07, 0x68, 0x0a, 0x56, 0x05, 0x7d, 0x08, 0x4e, 0x06, 0x1e, 0x05, 0x0a, 0x00, 0x06 ; ABE0
	.db 0x00, 0x02, 0x02, 0x13, 0x05, 0x45, 0x07, 0x78, 0x0a, 0x02, 0x01, 0xff, 0x05, 0xbc, 0x09, 0x07 ; ABF0
	.db 0x02, 0x39, 0x07, 0x68, 0x0a, 0x68, 0x06, 0x8f, 0x09, 0x5f, 0x07, 0x2f, 0x06, 0x0c, 0x01, 0x07 ; AC00
	.db 0x00, 0x03, 0x03, 0x24, 0x06, 0x56, 0x08, 0x89, 0x0b, 0x02, 0x01, 0xef, 0x03, 0xbc, 0x09, 0x07 ; AC10
	.db 0x03, 0x39, 0x08, 0x68, 0x0b, 0x78, 0x06, 0x9f, 0x09, 0x6f, 0x07, 0x3f, 0x06, 0x0c, 0x01, 0x07 ; AC20
	.db 0x00, 0x13, 0x03, 0x34, 0x06, 0x66, 0x08, 0x99, 0x0b, 0x02, 0x01, 0xef, 0x01, 0xbc, 0x09, 0x07 ; AC30
	.db 0x04, 0x39, 0x09, 0x68, 0x0c, 0x78, 0x07, 0xaf, 0x09, 0x7f, 0x07, 0x4f, 0x06, 0x1c, 0x01, 0x07 ; AC40
	.db 0x01, 0x13, 0x03, 0x34, 0x07, 0x66, 0x09, 0x99, 0x0c, 0x02, 0x01, 0xdf, 0x00, 0xbc, 0x09, 0x07 ; AC50
	.db 0x03, 0x39, 0x08, 0x68, 0x0b, 0x88, 0x07, 0xaf, 0x0a, 0x7f, 0x08, 0x4f, 0x06, 0x1c, 0x01, 0x07 ; AC60
	.db 0x01, 0x13, 0x03, 0x34, 0x07, 0x66, 0x09, 0x99, 0x0c, 0x02, 0x01, 0xbf, 0x00, 0xbc, 0x09, 0x07 ; AC70
	.db 0x02, 0x39, 0x07, 0x68, 0x0a, 0x99, 0x07, 0xaf, 0x09, 0x7f, 0x07, 0x4f, 0x06, 0x1c, 0x01, 0x07 ; AC80
	.db 0x01, 0x13, 0x03, 0x34, 0x07, 0x66, 0x09, 0x99, 0x0c, 0x02, 0x01, 0x9f, 0x00, 0xbc, 0x09, 0x07 ; AC90
	.db 0x01, 0x39, 0x06, 0x68, 0x09, 0x9a, 0x08, 0x9f, 0x09, 0x6f, 0x07, 0x3f, 0x06, 0x0c, 0x01, 0x07 ; ACA0
	.db 0x00, 0x13, 0x03, 0x34, 0x06, 0x66, 0x08, 0x99, 0x0b, 0x09, 0x00, 0xff, 0x05, 0xcf, 0x00, 0x3f ; ACB0
	.db 0x00, 0x8f, 0x00, 0xef, 0x02, 0x6f, 0x00, 0xcf, 0x00, 0x8f, 0x00, 0x5f, 0x00, 0x2f, 0x00, 0x0f ; ACC0
	.db 0x00, 0x1f, 0x00, 0x3f, 0x00, 0x6f, 0x00, 0xaf, 0x00, 0x0a, 0x00, 0x9f, 0x00, 0xef, 0x02, 0x4f ; ACD0
	.db 0x00, 0x9f, 0x00, 0xff, 0x03, 0x8f, 0x00, 0x0f, 0x00, 0xcf, 0x00, 0x8f, 0x00, 0x5f, 0x00, 0x2f ; ACE0
	.db 0x00, 0x2f, 0x00, 0x4f, 0x00, 0x7f, 0x00, 0xbf, 0x00, 0x0b, 0x00, 0x6f, 0x00, 0xff, 0x04, 0x4f ; ACF0
	.db 0x00, 0xbf, 0x00, 0xff, 0x05, 0xaf, 0x00, 0x2f, 0x00, 0x0f, 0x00, 0xcf, 0x00, 0x8f, 0x00, 0x5f ; AD00
	.db 0x00, 0x3f, 0x00, 0x5f, 0x00, 0x8f, 0x00, 0xdf, 0x00, 0x0c, 0x00, 0x4f, 0x00, 0xff, 0x06, 0x5f ; AD10
	.db 0x00, 0xcf, 0x00, 0xff, 0x07, 0xcf, 0x00, 0x5f, 0x00, 0x2f, 0x00, 0x0f, 0x00, 0xcf, 0x00, 0x8f ; AD20
	.db 0x00, 0x3f, 0x00, 0x6f, 0x00, 0x9f, 0x00, 0xef, 0x00, 0x0b, 0x00, 0x6f, 0x00, 0xff, 0x04, 0x4f ; AD30
	.db 0x00, 0xbf, 0x00, 0xff, 0x05, 0xaf, 0x00, 0x8f, 0x00, 0x5f, 0x00, 0x2f, 0x00, 0x0f, 0x00, 0xcf ; AD40
	.db 0x00, 0x3f, 0x00, 0x5f, 0x00, 0x8f, 0x00, 0xdf, 0x00, 0x0a, 0x00, 0x9f, 0x00, 0xef ; AD50

;; ---------------------------------------------------------------- $0AD5E
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_AD5E
sub_b02_AD5E:
	ld (bc),a                       ; AD5E
	ld c,a                          ; AD5F
	nop                             ; AD60
	sbc a,a                         ; AD61
	nop                             ; AD62
	rst 0x38                        ; AD63
	inc bc                          ; AD64
	adc a,a                         ; AD65

;; ---------------------------------------------------------------- $0AD66
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_AD66
sub_b02_AD66:
	nop                             ; AD66
	xor a                           ; AD67
	nop                             ; AD68
	ld a,a                          ; AD69
	nop                             ; AD6A

;; ---------------------------------------------------------------- $0AD6B
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_AD6B
sub_b02_AD6B:
	ccf                             ; AD6B
	nop                             ; AD6C
	rra                             ; AD6D
	nop                             ; AD6E
	ld c,a                          ; AD6F
	nop                             ; AD70
	cpl                             ; AD71
	nop                             ; AD72
	ld c,a                          ; AD73
	nop                             ; AD74
	ld a,a                          ; AD75
	nop                             ; AD76
	cp a                            ; AD77
	nop                             ; AD78
