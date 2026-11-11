;; video/sprites.s
;; Meta-sprites : tampon $C200, definitions en banques 23/24.
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $06C26
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_6C26
sub_6C26::
	ld a,(sprite_C24C)                 ; 6C26
	inc a                           ; 6C29
	ld (sprite_C24C),a                 ; 6C2A
	bit 0,a                         ; 6C2D
	jr nz,loc_6C66                  ; 6C2F
	call sub_71BE                   ; 6C31
	call sub_718F                   ; 6C34
	ld hl,#game_flags               ; 6C37
	bit 6,(hl)                      ; 6C3A
	jr nz,loc_6C41                  ; 6C3C
	call sub_6D1E                   ; 6C3E
loc_6C41:
	call sub_70CB                   ; 6C41
	call sub_7055                   ; 6C44
	call sub_6CC9                   ; 6C47
	call sub_6CB2                   ; 6C4A
	call sub_6C9B                   ; 6C4D
	ld hl,#sprite_C185                 ; 6C50
	bit 0,(hl)                      ; 6C53
	di                              ; 6C55
	jr z,loc_6C5F                   ; 6C56
	res 0,(hl)                      ; 6C58
	ld hl,#vdp_requests2            ; 6C5A
	set 0,(hl)                      ; 6C5D
loc_6C5F:
	ld hl,#vdp_requests2            ; 6C5F
	set 7,(hl)                      ; 6C62
	ei                              ; 6C64
	ret                             ; 6C65
loc_6C66:
	call sub_6C9B                   ; 6C66
	call sub_7055                   ; 6C69
	call sub_6CC9                   ; 6C6C
	call sub_70CB                   ; 6C6F
	call sub_6CB2                   ; 6C72
	call sub_71BE                   ; 6C75
	call sub_718F                   ; 6C78
	ld hl,#game_flags               ; 6C7B
	bit 6,(hl)                      ; 6C7E
	jr nz,loc_6C85                  ; 6C80
	call sub_6D1E                   ; 6C82
loc_6C85:
	ld hl,#sprite_C185                 ; 6C85
	bit 0,(hl)                      ; 6C88
	di                              ; 6C8A
	jr z,loc_6C94                   ; 6C8B
	res 0,(hl)                      ; 6C8D
	ld hl,#vdp_requests2            ; 6C8F
	set 0,(hl)                      ; 6C92
loc_6C94:
	ld hl,#vdp_requests2            ; 6C94
	set 7,(hl)                      ; 6C97
	ei                              ; 6C99
	ret                             ; 6C9A

;; ---------------------------------------------------------------- $06C9B
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_6C9B
sub_6C9B::
	ld a,(sprite_C24C)                 ; 6C9B
	bit 0,a                         ; 6C9E
	jr z,loc_6CAA                   ; 6CA0
	ld iy,#player_CD37                 ; 6CA2
	ld b,#0x02                      ; 6CA6
	jr loc_6CE0                     ; 6CA8
loc_6CAA:
	ld iy,#player_CD5F                 ; 6CAA
	ld b,#0x02                      ; 6CAE
	jr loc_6CFF                     ; 6CB0

;; ---------------------------------------------------------------- $06CB2
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_6CB2
sub_6CB2::
	ld a,(sprite_C24C)                 ; 6CB2
	bit 0,a                         ; 6CB5
	jr z,loc_6CC1                   ; 6CB7
	ld iy,#actor_CB07                 ; 6CB9
	ld b,#0x04                      ; 6CBD
	jr loc_6CE0                     ; 6CBF
loc_6CC1:
	ld iy,#sprite_CB7F                 ; 6CC1
	ld b,#0x04                      ; 6CC5
	jr loc_6CFF                     ; 6CC7

;; ---------------------------------------------------------------- $06CC9
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_6CC9
sub_6CC9::
	ld a,(sprite_C24C)                 ; 6CC9
	bit 0,a                         ; 6CCC
	jr z,loc_6CD8                   ; 6CCE
	ld iy,#actor_CDD7                 ; 6CD0
	ld b,#0x07                      ; 6CD4
	jr loc_6CE0                     ; 6CD6
loc_6CD8:
	ld iy,#sprite_CEC7                 ; 6CD8
	ld b,#0x07                      ; 6CDC
	jr loc_6CFF                     ; 6CDE
loc_6CE0:
	ld a,ACTOR_TYPE(iy)                      ; 6CE0
	or a                            ; 6CE3
	jr z,loc_6CF6                   ; 6CE4
	ld a,14(iy)                     ; 6CE6
	or a                            ; 6CE9
	jr z,loc_6CF3                   ; 6CEA
	dec 14(iy)                      ; 6CEC
	bit 1,a                         ; 6CEF
	jr nz,loc_6CF6                  ; 6CF1
loc_6CF3:
	call sub_6D4E                   ; 6CF3
loc_6CF6:
	ld de,#0x0028                   ; 6CF6
	add iy,de                       ; 6CF9
	djnz loc_6CE0                   ; 6CFB
	jr loc_6D1D                     ; 6CFD
loc_6CFF:
	ld a,ACTOR_TYPE(iy)                      ; 6CFF
	or a                            ; 6D02
	jr z,loc_6D16                   ; 6D03
	ld a,14(iy)                     ; 6D05
	or a                            ; 6D08
	jr z,loc_6D13                   ; 6D09
	dec a                           ; 6D0B
	ld 14(iy),a                     ; 6D0C
	bit 1,a                         ; 6D0F
	jr nz,loc_6D16                  ; 6D11
loc_6D13:
	call sub_6D4E                   ; 6D13
loc_6D16:
	ld de,#sprite_FFD8                 ; 6D16
	add iy,de                       ; 6D19
	djnz loc_6CFF                   ; 6D1B
loc_6D1D:
	ret                             ; 6D1D

;; ---------------------------------------------------------------- $06D1E
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_6D1E
sub_6D1E::
	ld iy,#player_state             ; 6D1E
	ld a,(player_CEF6)                 ; 6D22
	cp #0xff                        ; 6D25
	ret z                           ; 6D27
	ld a,#0x01                      ; 6D28
	ld (tmp_d3),a                   ; 6D2A
	di                              ; 6D2D
	ld hl,#vdp_requests2            ; 6D2E
	ld a,#0x81                      ; 6D31
	and (hl)                        ; 6D33
	ei                              ; 6D34
	call z,sub_6F28                 ; 6D35
	ld a,(player_state)             ; 6D38
	cpl                             ; 6D3B
	ld l,a                          ; 6D3C
	ld h,#0x00                      ; 6D3D
	ld de,#sub_6D4B                 ; 6D3F
	add hl,de                       ; 6D42
	ld a,(hl)                       ; 6D43
	ld (dbg_C0D4),a                 ; 6D44
	call sub_6E72                   ; 6D47
	ret                             ; 6D4A

;; ---------------------------------------------------------------- $06D4B
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_6D4B
sub_6D4B:
	inc b                           ; 6D4B
	inc b                           ; 6D4C
	inc b                           ; 6D4D

;; ---------------------------------------------------------------- $06D4E
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_6D4E
sub_6D4E::
	push hl                         ; 6D4E
	push de                         ; 6D4F
	push bc                         ; 6D50
	ld ACTOR_ANIM_END(iy),#0x00                 ; 6D51
	ld a,(sprite_C24B)                 ; 6D55
	cp #0x40                        ; 6D58
	jp nc,loc_6E6E                  ; 6D5A
	ld a,ACTOR_ANIM(iy)                      ; 6D5D
	or a                            ; 6D60
	jp z,loc_6E6E                   ; 6D61
	ld a,#0x17                      ; 6D64
	ld (bank_slot2_shadow),a        ; 6D66
	ld (MAPPER_SLOT2),a             ; 6D69  mapper : banque du slot 2 ($8000-$BFFF)
	ld a,ACTOR_TYPE(iy)                      ; 6D6C
	ld hl,#data_b23_B06B            ; 6D6F
	call sub_481F                   ; 6D72
	jr nz,loc_6D82                  ; 6D75
	bit 6,ACTOR_STATE(iy)                    ; 6D77
	jr z,loc_6D82                   ; 6D7B
	ld a,ACTOR_ANIM_ALT(iy)                     ; 6D7D
	jr loc_6D85                     ; 6D80
loc_6D82:
	ld a,ACTOR_ANIM(iy)                      ; 6D82
loc_6D85:
	bit 7,ACTOR_FLAGS(iy)                    ; 6D85
	ld de,#data_b23_81FA            ; 6D89
	jr z,loc_6D91                   ; 6D8C
	ld de,#data_b23_9ECF            ; 6D8E
loc_6D91:
	push af                         ; 6D91
	ld a,#0x18                      ; 6D92
	ld (bank_slot2_shadow),a        ; 6D94
	ld (MAPPER_SLOT2),a             ; 6D97  mapper : banque du slot 2 ($8000-$BFFF)
	pop af                          ; 6D9A
	ld l,a                          ; 6D9B
	ld h,#0x00                      ; 6D9C
	add hl,hl                       ; 6D9E
	add hl,hl                       ; 6D9F
	add hl,de                       ; 6DA0
	ld e,(hl)                       ; 6DA1
	inc hl                          ; 6DA2
	ld d,(hl)                       ; 6DA3
	ld (sprite_C240),de                ; 6DA4
	inc hl                          ; 6DA8
	ld e,(hl)                       ; 6DA9
	inc hl                          ; 6DAA
	ld d,(hl)                       ; 6DAB
	ld (sprite_C242),de                ; 6DAC
	bit 6,ACTOR_STATE(iy)                    ; 6DB0
	jr z,loc_6DC5                   ; 6DB4
	ld de,(sprite_C242)                ; 6DB6
	ld hl,(sprite_C240)                ; 6DBA
	inc hl                          ; 6DBD
	inc hl                          ; 6DBE
	inc hl                          ; 6DBF
	ld b,(hl)                       ; 6DC0
	inc hl                          ; 6DC1
	ex de,hl                        ; 6DC2
	jr loc_6E26                     ; 6DC3
loc_6DC5:
	ld a,(game_flags)               ; 6DC5
	bit 6,a                         ; 6DC8
	jr nz,loc_6DD3                  ; 6DCA
	bit 3,a                         ; 6DCC
	jr nz,loc_6DD3                  ; 6DCE
	inc ACTOR_ANIM_TIMER(iy)                       ; 6DD0
loc_6DD3:
	ld a,ACTOR_ANIM_TIMER(iy)                      ; 6DD3
	ld de,(sprite_C240)                ; 6DD6
	push de                         ; 6DDA
	pop ix                          ; 6DDB
	cp 0(ix)                        ; 6DDD
	jr c,loc_6E02                   ; 6DE0
	ld ACTOR_ANIM_TIMER(iy),#0x00                  ; 6DE2
	inc ACTOR_ANIM_FRAME(iy)                       ; 6DE6
	ld a,1(ix)                      ; 6DE9
	cp ACTOR_ANIM_FRAME(iy)                        ; 6DEC
	jr nc,loc_6E02                  ; 6DEF
	ld ACTOR_ANIM_FRAME(iy),#0x00                  ; 6DF1
	ld ACTOR_ANIM_END(iy),#0x01                 ; 6DF5
	ld a,2(ix)                      ; 6DF9
	or a                            ; 6DFC
	jr z,loc_6E02                   ; 6DFD
	ld ACTOR_ANIM_FRAME(iy),a                      ; 6DFF
loc_6E02:
	ld a,ACTOR_X_HI(iy)                      ; 6E02
	or ACTOR_Y_HI(iy)                        ; 6E05
	jr nz,loc_6E6E                  ; 6E08
	ld b,3(ix)                      ; 6E0A
	ld e,b                          ; 6E0D
	ld a,ACTOR_ANIM_FRAME(iy)                      ; 6E0E
	ld d,#0x00                      ; 6E11
	ld hl,#0x0004                   ; 6E13
loc_6E16:
	or a                            ; 6E16
	jr z,loc_6E1D                   ; 6E17
	dec a                           ; 6E19
	add hl,de                       ; 6E1A
	jr loc_6E16                     ; 6E1B
loc_6E1D:
	ld de,(sprite_C240)                ; 6E1D
	add hl,de                       ; 6E21
	ex de,hl                        ; 6E22
	ld hl,(sprite_C242)                ; 6E23
loc_6E26:
	ld a,(de)                       ; 6E26
	ld (sprite_C248),a                 ; 6E27
	cp #0xff                        ; 6E2A
	jr nz,loc_6E32                  ; 6E2C
	inc hl                          ; 6E2E
	inc hl                          ; 6E2F
	jr loc_6E6B                     ; 6E30
loc_6E32:
	ld c,ACTOR_X(iy)                      ; 6E32
	ld a,(hl)                       ; 6E35
	inc hl                          ; 6E36
	add a,c                         ; 6E37
	ld (sprite_C249),a                 ; 6E38
	ld c,ACTOR_Y(iy)                      ; 6E3B
	ld a,(hl)                       ; 6E3E
	inc hl                          ; 6E3F
	add a,c                         ; 6E40
	ld (sprite_C24A),a                 ; 6E41
	call sub_6F03                   ; 6E44
wide_ret_actor::
	jr nz,loc_6E6B                  ; 6E47
	push hl                         ; 6E49
	ld hl,(sprite_buf_xn_ptr)       ; 6E4A
	ld a,(sprite_C24A)                 ; 6E4D
	ld (hl),a                       ; 6E50
	inc hl                          ; 6E51
	ld a,(sprite_C248)                 ; 6E52
	ld (hl),a                       ; 6E55
	inc hl                          ; 6E56
	ld (sprite_buf_xn_ptr),hl       ; 6E57
	ld a,(sprite_C249)                 ; 6E5A
	ld hl,(sprite_buf_y_ptr)        ; 6E5D
	ld (hl),a                       ; 6E60
	inc hl                          ; 6E61
	ld (sprite_buf_y_ptr),hl        ; 6E62
	pop hl                          ; 6E65
	call sub_704B                   ; 6E66
	jr nc,loc_6E6E                  ; 6E69
loc_6E6B:
	inc de                          ; 6E6B
	djnz loc_6E26                   ; 6E6C
loc_6E6E:
	pop bc                          ; 6E6E
	pop de                          ; 6E6F
	pop hl                          ; 6E70
	ret                             ; 6E71

;; ---------------------------------------------------------------- $06E72
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_6E72
sub_6E72::
	ld a,(sprite_CF24)                 ; 6E72
	ld b,a                          ; 6E75
	ld hl,(sprite_CF22)                ; 6E76
	ld a,(player_state)             ; 6E79
	or a                            ; 6E7C
	jp z,loc_6F02                   ; 6E7D
	ld a,(game_flags)               ; 6E80
	bit 6,a                         ; 6E83
	jr nz,loc_6EAD                  ; 6E85
	ld a,(freeze_timer)             ; 6E87
	or a                            ; 6E8A
	jr nz,loc_6EAD                  ; 6E8B
	ld a,(player_CEFD)                 ; 6E8D
	or a                            ; 6E90
	jr z,loc_6E9E                   ; 6E91
	dec a                           ; 6E93
	ld (player_CEFD),a                 ; 6E94
	bit 1,a                         ; 6E97
	jp nz,loc_6F02                  ; 6E99
	jr loc_6EAD                     ; 6E9C
loc_6E9E:
	ld a,(player_CF09)                 ; 6E9E
	or a                            ; 6EA1
	jr z,loc_6EAD                   ; 6EA2
	dec a                           ; 6EA4
	ld (player_CF09),a                 ; 6EA5
	bit 1,a                         ; 6EA8
	jp nz,loc_6F02                  ; 6EAA
loc_6EAD:
	ld a,(sprite_C24B)                 ; 6EAD
	cp #0x40                        ; 6EB0
	jp nc,loc_6F02                  ; 6EB2
	xor a                           ; 6EB5
	ld (sprite_C248),a                 ; 6EB6
	ld a,(dbg_C0D4)                 ; 6EB9
	ld (bank_slot2_shadow),a        ; 6EBC
	ld (MAPPER_SLOT2),a             ; 6EBF  mapper : banque du slot 2 ($8000-$BFFF)
loc_6EC2:
	ld a,(player_CEF4)                 ; 6EC2
	add a,(hl)                      ; 6EC5
	inc hl                          ; 6EC6
	ld (sprite_C24A),a                 ; 6EC7
	ld a,(player_CEF1)                 ; 6ECA
	add a,(hl)                      ; 6ECD
	inc hl                          ; 6ECE
	ld (sprite_C249),a                 ; 6ECF
	call sub_6F03                   ; 6ED2
	jr nz,loc_6EF9                  ; 6ED5
	ex de,hl                        ; 6ED7
	ld hl,(sprite_buf_xn_ptr)       ; 6ED8
	ld a,(sprite_C24A)                 ; 6EDB
	ld (hl),a                       ; 6EDE
	inc hl                          ; 6EDF
	ld a,(sprite_C248)                 ; 6EE0
	ld (hl),a                       ; 6EE3
	inc hl                          ; 6EE4
	ld (sprite_buf_xn_ptr),hl       ; 6EE5
	ld a,(sprite_C249)                 ; 6EE8
	ld hl,(sprite_buf_y_ptr)        ; 6EEB
	ld (hl),a                       ; 6EEE
	inc hl                          ; 6EEF
	ld (sprite_buf_y_ptr),hl        ; 6EF0
	ex de,hl                        ; 6EF3
	call sub_704B                   ; 6EF4
	jr nc,loc_6F02                  ; 6EF7
loc_6EF9:
	ld a,(sprite_C248)                 ; 6EF9
	inc a                           ; 6EFC
	ld (sprite_C248),a                 ; 6EFD
	djnz loc_6EC2                   ; 6F00
loc_6F02:
	ret                             ; 6F02

;; ---------------------------------------------------------------- $06F03
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_6F03
sub_6F03:
.if WIDESCREEN
	jp wide_cull                    ; 6F03  vue elargie : masquage a l'ecran SMS complet
	.ds 24                          ; 6F06  (place liberee)
.else
	ld a,(sprite_C249)                 ; 6F03
	cp #0x0f                        ; 6F06
	jr c,loc_6F1B                   ; 6F08
	cp #0xa7                        ; 6F0A
	jr nc,loc_6F1B                  ; 6F0C
	ld a,(sprite_C24A)                 ; 6F0E
	cp #0x28                        ; 6F11
	jr c,loc_6F1B                   ; 6F13
	cp #0xd0                        ; 6F15
	jr nc,loc_6F1B                  ; 6F17
	xor a                           ; 6F19
	ret                             ; 6F1A
loc_6F1B:
	or #0xff                        ; 6F1B
	ret                             ; 6F1D
.endif

;; ---------------------------------------------------------------- $06F1E
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_6F1E
sub_6F1E:
	dec e                           ; 6F1E
	dec e                           ; 6F1F
	ld e,#0x1e                      ; 6F20
	dec bc                          ; 6F22
	dec bc                          ; 6F23
	inc c                           ; 6F24
	inc c                           ; 6F25
	rra                             ; 6F26
	rra                             ; 6F27

;; ---------------------------------------------------------------- $06F28
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_6F28
sub_6F28:
	ld a,(player_state)             ; 6F28
	or a                            ; 6F2B
	ret z                           ; 6F2C
	cpl                             ; 6F2D
	and #0x03                       ; 6F2E
	ld de,#sub_6F36                 ; 6F30
	jp loc_72E1                     ; 6F33

;; ---------------------------------------------------------------- $06F36
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_6F36
sub_6F36:
	ld l,d                          ; 6F36
	ld l,a                          ; 6F37
	inc a                           ; 6F38
	ld l,a                          ; 6F39
	ld d,e                          ; 6F3A
	ld l,a                          ; 6F3B
	ld ACTOR_ANIM_END(iy),#0x00                 ; 6F3C
	ld a,#0x04                      ; 6F40
	ld (bank_slot2_shadow),a        ; 6F42
	ld (MAPPER_SLOT2),a             ; 6F45  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,(data_b04_8004)           ; 6F48
	ld a,#0x04                      ; 6F4C
	ld (dbg_C0D4),a                 ; 6F4E
	jr loc_6F7F                     ; 6F51

;; ---------------------------------------------------------------- $06F53
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_6F53
sub_6F53:
	ld ACTOR_ANIM_END(iy),#0x00                 ; 6F53
	ld a,#0x04                      ; 6F57
	ld (bank_slot2_shadow),a        ; 6F59
	ld (MAPPER_SLOT2),a             ; 6F5C  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,(data_b04_8002)           ; 6F5F
	ld a,#0x04                      ; 6F63
	ld (dbg_C0D4),a                 ; 6F65
	jr loc_6F7F                     ; 6F68

;; ---------------------------------------------------------------- $06F6A
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_6F6A
sub_6F6A:
	ld ACTOR_ANIM_END(iy),#0x00                 ; 6F6A
	ld a,#0x04                      ; 6F6E
	ld (bank_slot2_shadow),a        ; 6F70
	ld (MAPPER_SLOT2),a             ; 6F73  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,(data_b04_8000)           ; 6F76
	ld a,#0x04                      ; 6F7A
	ld (dbg_C0D4),a                 ; 6F7C
loc_6F7F:
	ld hl,(player_CEF6)                ; 6F7F
	ld a,(player_CF21)                 ; 6F82
	add a,l                         ; 6F85
	ld l,a                          ; 6F86
	ld h,#0x00                      ; 6F87
	add hl,hl                       ; 6F89
	add hl,de                       ; 6F8A
	ld e,(hl)                       ; 6F8B
	inc hl                          ; 6F8C
	ld d,(hl)                       ; 6F8D
	ld (sprite_C240),de                ; 6F8E
	push de                         ; 6F92
	pop ix                          ; 6F93
	ld a,(player_CEF7)                 ; 6F95
	or a                            ; 6F98
	jr z,loc_6FB2                   ; 6F99
	ld a,(game_flags)               ; 6F9B
	bit 6,a                         ; 6F9E
	jr nz,loc_6FDA                  ; 6FA0
	ld a,(player_CEF7)                 ; 6FA2
	inc a                           ; 6FA5
	ld (player_CEF7),a                 ; 6FA6
	cp 0(ix)                        ; 6FA9
	jr c,loc_6FDA                   ; 6FAC
	ld hl,#player_CEF8                 ; 6FAE
	inc (hl)                        ; 6FB1
loc_6FB2:
	ld ACTOR_ANIM_TIMER(iy),#0x01                  ; 6FB2
	ld hl,#sprite_C185                 ; 6FB6
	ld a,(tmp_d3)                   ; 6FB9
	or (hl)                         ; 6FBC
	ld (hl),a                       ; 6FBD
	ld a,(player_CEF8)                 ; 6FBE
	ld e,1(ix)                      ; 6FC1
	cp e                            ; 6FC4
	jr c,loc_6FDA                   ; 6FC5
	jr z,loc_6FDA                   ; 6FC7
	ld ACTOR_ANIM_FRAME(iy),#0x00                  ; 6FC9
	ld ACTOR_ANIM_END(iy),#0x01                 ; 6FCD
	ld a,2(ix)                      ; 6FD1
	or a                            ; 6FD4
	jr z,loc_6FDA                   ; 6FD5
	ld (player_CEF8),a                 ; 6FD7
loc_6FDA:
	ld hl,#sprite_C185                 ; 6FDA
	bit 0,(hl)                      ; 6FDD
	jp z,loc_704A                   ; 6FDF
	ld hl,(player_CEF8)                ; 6FE2
	ld h,#0x00                      ; 6FE5
	add hl,hl                       ; 6FE7
	push ix                         ; 6FE8
	pop de                          ; 6FEA
	add hl,de                       ; 6FEB
	ld de,#0x0003                   ; 6FEC
	add hl,de                       ; 6FEF
	ld e,(hl)                       ; 6FF0
	inc hl                          ; 6FF1
	ld d,(hl)                       ; 6FF2
	ex de,hl                        ; 6FF3
	ld de,#irq_D701                 ; 6FF4
	ld b,#0x00                      ; 6FF7
loc_6FF9:
	ld a,(dbg_C0D4)                 ; 6FF9
	ld (bank_slot2_shadow),a        ; 6FFC
	ld (MAPPER_SLOT2),a             ; 6FFF  mapper : banque du slot 2 ($8000-$BFFF)
	push bc                         ; 7002
	ld c,(hl)                       ; 7003
	inc hl                          ; 7004
	ld b,(hl)                       ; 7005
	inc hl                          ; 7006
	ld a,b                          ; 7007
	cp #0xff                        ; 7008
	jr z,loc_7042                   ; 700A
	push hl                         ; 700C
	push de                         ; 700D
	and #0x0f                       ; 700E
	ld l,a                          ; 7010
	ld h,#0x00                      ; 7011
	ld de,#sub_6F1E                 ; 7013
	add hl,de                       ; 7016
	ld a,(hl)                       ; 7017
	ld a,a                          ; 7018
	ld (bank_slot2_shadow),a        ; 7019
	ld (MAPPER_SLOT2),a             ; 701C  mapper : banque du slot 2 ($8000-$BFFF)
	pop de                          ; 701F
	ld a,b                          ; 7020
	and #0x01                       ; 7021
	ld h,a                          ; 7023
	ld l,c                          ; 7024
	add hl,hl                       ; 7025
	add hl,hl                       ; 7026
	add hl,hl                       ; 7027
	add hl,hl                       ; 7028
	add hl,hl                       ; 7029
	push bc                         ; 702A
	ld bc,#0x8000                   ; 702B
	add hl,bc                       ; 702E
	pop bc                          ; 702F
	bit 7,b                         ; 7030
	ld bc,#0x0020                   ; 7032
	jr z,loc_703B                   ; 7035
	ldir                            ; 7037
	jr loc_703D                     ; 7039
loc_703B:
	ldir                            ; 703B
loc_703D:
	pop hl                          ; 703D
	pop bc                          ; 703E
	inc b                           ; 703F
	jr loc_6FF9                     ; 7040
loc_7042:
	pop bc                          ; 7042
	ld (sprite_CF22),hl                ; 7043
	ld a,b                          ; 7046
	ld (sprite_CF24),a                 ; 7047
loc_704A:
	ret                             ; 704A

;; ---------------------------------------------------------------- $0704B
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_704B
sub_704B:
	ld a,(sprite_C24B)                 ; 704B
	inc a                           ; 704E
	ld (sprite_C24B),a                 ; 704F
	cp #0x40                        ; 7052
	ret                             ; 7054

;; ---------------------------------------------------------------- $07055
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_7055
sub_7055::
	ld a,(sprite_C24C)                 ; 7055
	bit 0,a                         ; 7058
	jr z,loc_7073                   ; 705A
	ld iy,#scene_script_ptr         ; 705C
	ld b,#0x0d                      ; 7060
loc_7062:
	ld a,ACTOR_TYPE(iy)                      ; 7062
	or a                            ; 7065
	jr z,loc_706B                   ; 7066
	call sub_6D4E                   ; 7068
loc_706B:
	ld de,#0x0028                   ; 706B
	add iy,de                       ; 706E
	djnz loc_7062                   ; 7070
	ret                             ; 7072
loc_7073:
	ld iy,#coll_CADF                 ; 7073
	ld b,#0x0d                      ; 7077
loc_7079:
	ld a,ACTOR_TYPE(iy)                      ; 7079
	or a                            ; 707C
	jr z,loc_7082                   ; 707D
	call sub_6D4E                   ; 707F
loc_7082:
	ld de,#sprite_FFD8                 ; 7082
	add iy,de                       ; 7085
	djnz loc_7079                   ; 7087
	ret                             ; 7089

;; ---------------------------------------------------------------- $0708A
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_708A
sub_708A:
	ld a,(sprite_C24C)                 ; 708A
	bit 0,a                         ; 708D
	jr z,loc_70AE                   ; 708F
	ld iy,#actor_CBA7                 ; 7091
	ld b,#0x0a                      ; 7095
loc_7097:
	ld a,ACTOR_TYPE(iy)                      ; 7097
	or a                            ; 709A
	jr z,loc_70A6                   ; 709B
	bit 7,ACTOR_STATE(iy)                    ; 709D
	jr z,loc_70A6                   ; 70A1
	call sub_6D4E                   ; 70A3
loc_70A6:
	ld de,#0x0028                   ; 70A6
	add iy,de                       ; 70A9
	djnz loc_7097                   ; 70AB
	ret                             ; 70AD
loc_70AE:
	ld iy,#sprite_CD0F                 ; 70AE
	ld b,#0x0a                      ; 70B2
loc_70B4:
	ld a,ACTOR_TYPE(iy)                      ; 70B4
	or a                            ; 70B7
	jr z,loc_70C3                   ; 70B8
	bit 7,ACTOR_STATE(iy)                    ; 70BA
	jr z,loc_70C3                   ; 70BE
	call sub_6D4E                   ; 70C0
loc_70C3:
	ld de,#sprite_FFD8                 ; 70C3
	add iy,de                       ; 70C6
	djnz loc_70B4                   ; 70C8
	ret                             ; 70CA

;; ---------------------------------------------------------------- $070CB
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_70CB
sub_70CB:
	ld a,(game_flags)               ; 70CB
	bit 6,a                         ; 70CE
	ret z                           ; 70D0
	ld a,(player_state)             ; 70D1
	cp #0xfd                        ; 70D4
	jr z,loc_70FC                   ; 70D6
	ld hl,#sprite_C8AF                 ; 70D8
	ld de,#event_C8B0                 ; 70DB
	ld (hl),#0x00                   ; 70DE
	ld bc,#0x0027                   ; 70E0
	ldir                            ; 70E3
	ld iy,#sprite_C8AF                 ; 70E5
	ld ACTOR_ANIM(iy),#0x0b                  ; 70E9
	ld ACTOR_X(iy),#0x58                  ; 70ED
	ld ACTOR_Y(iy),#0x70                  ; 70F1
	call sub_6D4E                   ; 70F5
	call sub_711C                   ; 70F8
	ret                             ; 70FB
loc_70FC:
	ld iy,#player_CA17                 ; 70FC
	ld b,#0x06                      ; 7100
	ld hl,#game_flags               ; 7102
	res 6,(hl)                      ; 7105
loc_7107:
	push bc                         ; 7107
	call sub_6D4E                   ; 7108
	ld de,#0x0028                   ; 710B
	add iy,de                       ; 710E
	pop bc                          ; 7110
	djnz loc_7107                   ; 7111
	call sub_711C                   ; 7113
	ld hl,#game_flags               ; 7116
	set 6,(hl)                      ; 7119
	ret                             ; 711B

;; ---------------------------------------------------------------- $0711C
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_711C
sub_711C::
	ld iy,#pause_C8D7                 ; 711C
	call sub_6D4E                   ; 7120
	ld hl,#sprite_C8AF                 ; 7123
	ld de,#event_C8B0                 ; 7126
	ld (hl),#0x00                   ; 7129
	ld bc,#0x0027                   ; 712B
	ldir                            ; 712E
	ld iy,#sprite_C8AF                 ; 7130
	ld a,(flow_C015)                 ; 7134
	and #0xf0                       ; 7137
	jr z,loc_7166                   ; 7139
	srl a                           ; 713B
	srl a                           ; 713D
	srl a                           ; 713F
	srl a                           ; 7141
	inc a                           ; 7143
	ld ACTOR_ANIM(iy),a                      ; 7144
	ld ACTOR_ANIM_FRAME(iy),#0x00                  ; 7147
	ld ACTOR_ANIM_TIMER(iy),#0x00                  ; 714B
	ld ACTOR_ANIM_END(iy),#0x00                 ; 714F
	ld a,(sprite_C8D9)                 ; 7153
	add a,#0x08                     ; 7156
	ld ACTOR_X(iy),a                      ; 7158
	ld a,(sprite_C8DC)                 ; 715B
	add a,#0x10                     ; 715E
	ld ACTOR_Y(iy),a                      ; 7160
	call sub_6D4E                   ; 7163
loc_7166:
	ld a,(flow_C015)                 ; 7166
	and #0x0f                       ; 7169
	inc a                           ; 716B
	ld ACTOR_ANIM(iy),a                      ; 716C
	ld ACTOR_ANIM_FRAME(iy),#0x00                  ; 716F
	ld ACTOR_ANIM_TIMER(iy),#0x00                  ; 7173
	ld ACTOR_ANIM_END(iy),#0x00                 ; 7177
	ld a,(sprite_C8D9)                 ; 717B
	add a,#0x08                     ; 717E
	ld ACTOR_X(iy),a                      ; 7180
	ld a,(sprite_C8DC)                 ; 7183
	add a,#0x18                     ; 7186
	ld ACTOR_Y(iy),a                      ; 7188
	call sub_6D4E                   ; 718B
	ret                             ; 718E

;; ---------------------------------------------------------------- $0718F
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_718F
sub_718F::
	ld a,(player_state)             ; 718F
	cp #0xff                        ; 7192
	ret nz                          ; 7194
	ld a,(player_C1F2)                 ; 7195
	or a                            ; 7198
	ret z                           ; 7199
	ld hl,#sprite_C8AF                 ; 719A
	ld de,#event_C8B0                 ; 719D
	ld bc,#0x0027                   ; 71A0
	ldir                            ; 71A3
	ld iy,#sprite_C8AF                 ; 71A5
	ld a,(player_C1F2)                 ; 71A9
	ld b,#0x66                      ; 71AC
	add a,b                         ; 71AE
	ld ACTOR_ANIM(iy),a                      ; 71AF
.if WIDESCREEN
	ld ACTOR_Y(iy),#0x15                  ; 71B2  vue elargie : HUD en haut a gauche de l'ecran SMS
	ld ACTOR_X(iy),#0x1c                  ; 71B6  (X -36 px, Y -20 px ; ACTOR_Y = horizontal)
.else
	ld ACTOR_Y(iy),#0x39                  ; 71B2
	ld ACTOR_X(iy),#0x30                  ; 71B6
.endif
	call sub_6D4E                   ; 71BA
	ret                             ; 71BD

;; ---------------------------------------------------------------- $071BE
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_71BE
sub_71BE::
	ld iy,#util_CD87                 ; 71BE
	ld a,(player_CEFE)                 ; 71C2
	or a                            ; 71C5
	ret z                           ; 71C6
	ld b,a                          ; 71C7
	ld a,(player_state)             ; 71C8
	cp #0xfd                        ; 71CB
	jr z,loc_71EE                   ; 71CD
	ld a,#0x0c                      ; 71CF
	add a,b                         ; 71D1
	ld ACTOR_ANIM(iy),a                      ; 71D2
.if WIDESCREEN
	ld ACTOR_Y(iy),#0x0c                  ; 71D5  vue elargie : objet en haut a gauche de l'ecran SMS
	ld ACTOR_X(iy),#0x03                  ; 71D9  (X -36 px, Y -20 px ; ACTOR_Y = horizontal)
.else
	ld ACTOR_Y(iy),#0x30                  ; 71D5
	ld ACTOR_X(iy),#0x17                  ; 71D9
.endif
	ld a,(game_flags)               ; 71DD
	push af                         ; 71E0
	res 6,a                         ; 71E1
	ld (game_flags),a               ; 71E3
	call sub_6D4E                   ; 71E6
	pop af                          ; 71E9
	ld (game_flags),a               ; 71EA
	ret                             ; 71ED
loc_71EE:
	ld a,(scene_id)                 ; 71EE
	cp #0x37                        ; 71F1
	ret z                           ; 71F3
	cp #0x39                        ; 71F4
	ret z                           ; 71F6
	ld a,#0x06                      ; 71F7
	ld hl,#flow_C1B7                 ; 71F9
	add a,(hl)                      ; 71FC
	cp #0x0f                        ; 71FD
	jr c,loc_7203                   ; 71FF
	ld a,#0x0e                      ; 7201
loc_7203:
	ld c,a                          ; 7203
	ld d,#0x35                      ; 7204
	xor a                           ; 7206
	ld (tmp_d3),a                   ; 7207
	call sub_723D                   ; 720A
	ld hl,(scene_id)                ; 720D
	ld h,#0x00                      ; 7210
	add hl,hl                       ; 7212
	add hl,hl                       ; 7213
	ld a,#0x12                      ; 7214
	ld (bank_slot2_shadow),a        ; 7216
	ld (MAPPER_SLOT2),a             ; 7219  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#data_b18_B581            ; 721C
	add hl,de                       ; 721F
	ld e,(hl)                       ; 7220
	inc hl                          ; 7221
	ld d,(hl)                       ; 7222
	inc hl                          ; 7223
	ld c,(hl)                       ; 7224
	ex de,hl                        ; 7225
	ld a,(hl)                       ; 7226
	or a                            ; 7227
	ret z                           ; 7228
	ld b,a                          ; 7229
	ld a,#0x05                      ; 722A
	ld (tmp_d3),a                   ; 722C
	ld d,#0xcb                      ; 722F
	call sub_723D                   ; 7231
	ret                             ; 7234

;; ---------------------------------------------------------------- $07235
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_7235
sub_7235:
	push af                         ; 7235
	ld a,(tmp_d3)                   ; 7236
	add a,e                         ; 7239
	ld e,a                          ; 723A
	pop af                          ; 723B
	ret                             ; 723C

;; ---------------------------------------------------------------- $0723D
;; classement : moteur de meta-sprites (tampon $C200, tables banques 23/24)
	.area _B01_723D
sub_723D:
	ld ACTOR_Y(iy),d                      ; 723D
	ld ACTOR_X(iy),#0x1b                  ; 7240
	ld a,b                          ; 7244
loc_7245:
	dec c                           ; 7245
	dec a                           ; 7246
	jr nz,loc_7255                  ; 7247
	ld e,#0x33                      ; 7249
	call sub_7235                   ; 724B
	cp c                            ; 724E
	jr z,loc_725C                   ; 724F
	dec c                           ; 7251
	inc e                           ; 7252
	jr loc_725C                     ; 7253
loc_7255:
	ld e,#0x35                      ; 7255
	call sub_7235                   ; 7257
	dec c                           ; 725A
	dec a                           ; 725B
loc_725C:
	ld ACTOR_ANIM(iy),e                      ; 725C
	push af                         ; 725F
	call sub_6D4E                   ; 7260
	ld a,ACTOR_X(iy)                      ; 7263
	add a,#0x08                     ; 7266
	ld ACTOR_X(iy),a                      ; 7268
	pop af                          ; 726B
	or a                            ; 726C
	jr nz,loc_7245                  ; 726D
	ld a,c                          ; 726F
loc_7270:
	or a                            ; 7270
	ret z                           ; 7271
	ld e,#0x31                      ; 7272
	call sub_7235                   ; 7274
	dec a                           ; 7277
	jr z,loc_7280                   ; 7278
	dec a                           ; 727A
	ld e,#0x32                      ; 727B
	call sub_7235                   ; 727D
loc_7280:
	ld ACTOR_ANIM(iy),e                      ; 7280
	push af                         ; 7283
	call sub_6D4E                   ; 7284
	ld a,ACTOR_X(iy)                      ; 7287
	add a,#0x08                     ; 728A
	ld ACTOR_X(iy),a                      ; 728C
	pop af                          ; 728F
	jr loc_7270                     ; 7290
