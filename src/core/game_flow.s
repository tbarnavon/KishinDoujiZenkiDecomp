;; core/game_flow.s
;; Sequenceur du jeu (tache 0) : titre, demo, lancement de partie, options de depart ($C006-$C008).
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $00565
;; classement : atteinte uniquement par task0_main
	.area _B00_0565
sub_0565:
	ld a,(current_stage)            ; 0565
	or a                            ; 0568
	jr z,sub_059F                   ; 0569
	ld a,(game_mode)                ; 056B
	cp #0x01                        ; 056E
	jr z,loc_058D                   ; 0570
	cp #0x05                        ; 0572
	jr z,loc_058D                   ; 0574
	ld a,(scene_id)                 ; 0576
	cp #0x2b                        ; 0579
	ret z                           ; 057B
	cp #0x2c                        ; 057C
	ret z                           ; 057E
	cp #0x32                        ; 057F
	ret z                           ; 0581
	cp #0x34                        ; 0582
	ret z                           ; 0584
	cp #0x35                        ; 0585
	ret z                           ; 0587
	cp #0x36                        ; 0588
	ret z                           ; 058A
	jr sub_059F                     ; 058B
loc_058D:
	ld a,(scene_id)                 ; 058D
	cp #0x0c                        ; 0590
	ret z                           ; 0592
	cp #0x0e                        ; 0593
	ret z                           ; 0595
	cp #0x0f                        ; 0596
	ret z                           ; 0598
	cp #0x10                        ; 0599
	ret z                           ; 059B
	cp #0x12                        ; 059C
	ret z                           ; 059E

;; ---------------------------------------------------------------- $006B3
;; classement : atteinte uniquement par task0_main
	.area _B00_06B3
sub_06B3::
	call sub_44BC                   ; 06B3
	call sub_0A6B                   ; 06B6
	call sub_0A33                   ; 06B9
	call sub_3DD0                   ; 06BC
	ld a,#0x80                      ; 06BF
loc_06C1:
	ld (scene_id),a                 ; 06C1
	ld a,#0x01                      ; 06C4
	ld (game_mode),a                ; 06C6
	call sub_6337                   ; 06C9
	ld a,(joypad_state)             ; 06CC
	bit 7,a                         ; 06CF
	jr nz,loc_06E6                  ; 06D1
	ld a,#0x81                      ; 06D3
	ld (scene_id),a                 ; 06D5
	call sub_6337                   ; 06D8
	ld a,(joypad_state)             ; 06DB
	bit 7,a                         ; 06DE
	jr z,sub_06B3                   ; 06E0
	ld a,#0x82                      ; 06E2
	jr loc_06C1                     ; 06E4
loc_06E6:
	ld a,#0x01                      ; 06E6
	call sub_58AE                   ; 06E8
	call sub_174B                   ; 06EB
	ld a,(joypad_state)             ; 06EE
.if VERSION_SMS_EN
	cp #0xb4                        ; 06F1
.else ; VERSION_GG_JP
	cp #0x94                        ; 06F1
.endif
	jr nz,loc_0703                  ; 06F3
	call sub_6415                   ; 06F5
	ld a,#0x17                      ; 06F8
	ld (bank_slot2_shadow),a        ; 06FA
	ld (MAPPER_SLOT2),a             ; 06FD  mapper : banque du slot 2 ($8000-$BFFF)
	call sub_b23_967C               ; 0700
loc_0703:
	ld a,(flow_C1B7)                 ; 0703
	add a,#0x06                     ; 0706
	ld (player_CEFE),a                 ; 0708
	ld a,#0x13                      ; 070B
	ld (bank_slot2_shadow),a        ; 070D
	ld (MAPPER_SLOT2),a             ; 0710  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b19_81C3            ; 0713
	ld de,#event_C2CD                 ; 0716
	ld bc,#0x00b4                   ; 0719
	ldir                            ; 071C
	ld a,#0xff                      ; 071E
	ld (event_C1B2),a                 ; 0720
	xor a                           ; 0723
	ld (level_C1F3),a                 ; 0724
	call sub_08DF                   ; 0727
	ld a,(start_stage)              ; 072A
	inc a                           ; 072D
	cp #0x10                        ; 072E
	jr c,loc_073B                   ; 0730
	ld hl,#game_flags               ; 0732
	set 4,(hl)                      ; 0735
	set 2,(hl)                      ; 0737
	jr loc_073E                     ; 0739
loc_073B:
	call sub_0982                   ; 073B
loc_073E:
	call task_yield                 ; 073E
	call sub_0A64                   ; 0741
	ld a,(freeze_timer)             ; 0744
	or a                            ; 0747
	jr z,loc_0750                   ; 0748
	dec a                           ; 074A
	ld (freeze_timer),a             ; 074B
	jr loc_073E                     ; 074E
loc_0750:
	ld a,(irq_flags)                ; 0750
	bit 6,a                         ; 0753
	jp z,loc_080A                   ; 0755
	ld a,(flow_C015)                 ; 0758
	or a                            ; 075B
	jr z,loc_0785                   ; 075C
	dec a                           ; 075E
	daa                             ; 075F
	ld (flow_C015),a                 ; 0760
loc_0763::
	call sub_0AB2                   ; 0763
	call sound_init                 ; 0766
loc_0769:
	ld a,#0x01                      ; 0769
	call sub_58AE                   ; 076B
	call sub_174B                   ; 076E
	ld a,(flow_C1B1)                 ; 0771
	ld (flow_C1B0),a                 ; 0774
	ld a,(flow_C1B7)                 ; 0777
	add a,#0x06                     ; 077A
	ld (player_CEFE),a                 ; 077C
	call sub_0994                   ; 077F
	jp loc_073E                     ; 0782
loc_0785:
	ld hl,#irq_flags                ; 0785
	res 6,a                         ; 0788
	ld (irq_flags),a                ; 078A
	call sub_0AB2                   ; 078D
	call sound_init                 ; 0790
	ld a,#0x01                      ; 0793
	call sub_58AE                   ; 0795
	call sub_174B                   ; 0798
	ld a,(player_state)             ; 079B
	ld (player_C1B3),a                 ; 079E
	ld a,#0x83                      ; 07A1
	ld (scene_id),a                 ; 07A3
	call sub_6337                   ; 07A6
	or a                            ; 07A9
	jr z,loc_07BB                   ; 07AA
	ld a,(lives_or_c005)            ; 07AC
	ld (flow_C015),a                 ; 07AF
	xor a                           ; 07B2
	ld (flow_C1B1),a                 ; 07B3
	ld (current_stage),a            ; 07B6
	jr loc_0769                     ; 07B9
loc_07BB:
	ld a,#0x01                      ; 07BB
	call sub_58AE                   ; 07BD
	call sub_174B                   ; 07C0
	call sound_init                 ; 07C3
	call sub_5EBD                   ; 07C6
	call sub_44BC                   ; 07C9
	call sub_0A6B                   ; 07CC
	call sub_0A33                   ; 07CF
	xor a                           ; 07D2
	ld (flow_C1B0),a                 ; 07D3
	ld (flow_C1A0),a                 ; 07D6
	ld (flow_C1B1),a                 ; 07D9
	ld (flow_C1B7),a                 ; 07DC
	ld (flow_C1B6),a                 ; 07DF
	ld (player_C1F2),a                 ; 07E2
	ld (event_C010),a                 ; 07E5
	ld a,#0x01                      ; 07E8
	ld (current_stage),a            ; 07EA
	ld hl,#flow_C1A1                 ; 07ED
	ld de,#flow_C1A2                 ; 07F0
	ld bc,#0x000e                   ; 07F3
	ld (hl),#0x00                   ; 07F6
	ldir                            ; 07F8
	ld hl,#flow_C1E1                 ; 07FA
	ld de,#flow_C1E2                 ; 07FD
	ld bc,#0x0010                   ; 0800
	ld (hl),#0x00                   ; 0803
	ldir                            ; 0805
	jp loc_08A9                     ; 0807
loc_080A:
	ld a,(game_flags)               ; 080A
	bit 4,a                         ; 080D
	jp z,loc_073E                   ; 080F
	call sub_0AB2                   ; 0812
	call sub_0565                   ; 0815
	ld a,(current_stage)            ; 0818
	cp #0x0f                        ; 081B
	jp c,loc_0832                   ; 081D
	ld hl,#game_flags               ; 0820
	bit 2,(hl)                      ; 0823
	jr nz,loc_0886                  ; 0825
	ld a,#0x02                      ; 0827
	ld (bank_slot2_shadow),a        ; 0829
	ld (MAPPER_SLOT2),a             ; 082C  mapper : banque du slot 2 ($8000-$BFFF)
	call sub_b02_ADA6               ; 082F
loc_0832:
	ld a,(current_stage)            ; 0832
	or a                            ; 0835
	jr z,loc_085F                   ; 0836
	ld a,#0x02                      ; 0838
	ld (bank_slot2_shadow),a        ; 083A
	ld (MAPPER_SLOT2),a             ; 083D  mapper : banque du slot 2 ($8000-$BFFF)
	call sub_b02_ADA6               ; 0840
	jr z,loc_085F                   ; 0843
	ld a,#0x01                      ; 0845
	call sub_58C9                   ; 0847
	ld a,(game_mode)                ; 084A
	cp #0x01                        ; 084D
	jr z,loc_085A                   ; 084F
	cp #0x05                        ; 0851
	jr z,loc_085A                   ; 0853
	call sub_176E                   ; 0855
	jr loc_087D                     ; 0858
loc_085A:
	call sub_174B                   ; 085A
	jr loc_087D                     ; 085D
loc_085F:
	ld a,#0x01                      ; 085F
	call sub_58AE                   ; 0861
	ld a,(current_stage)            ; 0864
	or a                            ; 0867
	jr z,loc_087A                   ; 0868
	ld a,(game_mode)                ; 086A
	cp #0x01                        ; 086D
	jr z,loc_087A                   ; 086F
	cp #0x05                        ; 0871
	jr z,loc_087A                   ; 0873
	call sub_176E                   ; 0875
	jr loc_087D                     ; 0878
loc_087A:
	call sub_174B                   ; 087A
loc_087D:
	call sub_0ACC                   ; 087D
	call sub_0991                   ; 0880
	jp loc_073E                     ; 0883
loc_0886:
	ld a,#0x01                      ; 0886
	call sub_58C9                   ; 0888
	call sub_176E                   ; 088B
	ld a,#0x3c                      ; 088E
	call sub_0332                   ; 0890
	ld a,#0x85                      ; 0893
	ld (scene_id),a                 ; 0895
	call sub_6337                   ; 0898
	ld a,#0x01                      ; 089B
	call sub_58AE                   ; 089D
	call sub_174B                   ; 08A0
	call sub_08DF                   ; 08A3
	call sub_0A28                   ; 08A6
loc_08A9:
	xor a                           ; 08A9
	ld (flow_C1B6),a                 ; 08AA
	ld (player_C1F2),a                 ; 08AD
	ld (event_C010),a                 ; 08B0
	ld (freeze_timer),a             ; 08B3
	ld (current_stage),a            ; 08B6
	ld (flow_C1A0),a                 ; 08B9
	ld (flow_C1B1),a                 ; 08BC
	ld (flow_C1B7),a                 ; 08BF
	ld hl,#flow_C1A1                 ; 08C2
	ld de,#flow_C1A2                 ; 08C5
	ld (hl),#0x00                   ; 08C8
	ld bc,#0x000e                   ; 08CA
	ldir                            ; 08CD
	ld hl,#flow_C1E1                 ; 08CF
	ld de,#flow_C1E2                 ; 08D2
	ld (hl),#0x00                   ; 08D5
	ld bc,#0x0010                   ; 08D7
	ldir                            ; 08DA
	jp sub_06B3                     ; 08DC

;; ---------------------------------------------------------------- $008DF
;; classement : atteinte uniquement par task0_main
	.area _B00_08DF
sub_08DF:
	ld a,(lives_or_c005)            ; 08DF
	ld (flow_C015),a                 ; 08E2
	cp #0x33                        ; 08E5
	jr nz,loc_08F1                  ; 08E7
	ld a,(game_flags)               ; 08E9
	set 1,a                         ; 08EC
	ld (game_flags),a               ; 08EE
loc_08F1:
	ld a,(flow_C1B6)                 ; 08F1
	and #0x80                       ; 08F4
	ld (flow_C1B6),a                 ; 08F6
	ld a,(start_stage)              ; 08F9
	ld (flow_C1A0),a                 ; 08FC
	inc a                           ; 08FF
	ld (current_stage),a            ; 0900
	ld a,(dbg_C004)                 ; 0903
	ld (flow_C1B0),a                 ; 0906
	ld hl,(start_power)             ; 0909
	ld h,#0x00                      ; 090C
	ld de,#data_097B                ; 090E
	add hl,de                       ; 0911
	ld a,(hl)                       ; 0912
	ld (event_C010),a                 ; 0913
	ld hl,#event_C010                 ; 0916
	res 7,(hl)                      ; 0919
	res 6,(hl)                      ; 091B
	ld hl,#flow_C1B6                 ; 091D
	res 7,(hl)                      ; 0920
	xor a                           ; 0922
	ld (player_C1F2),a                 ; 0923
	ld a,#0xff                      ; 0926
	ld (event_C1B2),a                 ; 0928
	ld hl,(start_mode)              ; 092B
	ld h,#0x00                      ; 092E
	ld de,#jt_093A                  ; 0930
	add hl,hl                       ; 0933
	add hl,de                       ; 0934
	ld e,(hl)                       ; 0935
	inc hl                          ; 0936
	ld d,(hl)                       ; 0937
	ex de,hl                        ; 0938
	jp (hl)                         ; 0939
jt_093A:
	.dw loc_097A                    ; 093A
	.dw loc_0971                    ; 093C
	.dw loc_0975                    ; 093E
	.dw loc_094C                    ; 0940
	.dw loc_0952                    ; 0942
	.dw loc_0958                    ; 0944
	.dw loc_0963                    ; 0946
	.dw loc_096B                    ; 0948
	.dw loc_0967                    ; 094A
loc_094C:
	ld hl,#event_C010                 ; 094C
	set 7,(hl)                      ; 094F
	ret                             ; 0951
loc_0952:
	ld hl,#event_C010                 ; 0952
	set 6,(hl)                      ; 0955
	ret                             ; 0957
loc_0958:
	ld hl,#flow_C1B6                 ; 0958
	set 7,(hl)                      ; 095B
	ld hl,#event_C010                 ; 095D
	res 7,(hl)                      ; 0960
	ret                             ; 0962
loc_0963:
	ld a,#0x01                      ; 0963
	jr loc_096D                     ; 0965
loc_0967:
	ld a,#0x03                      ; 0967
	jr loc_096D                     ; 0969
loc_096B:
	ld a,#0x02                      ; 096B
loc_096D:
	ld (player_C1F2),a                 ; 096D
	ret                             ; 0970
loc_0971:
	ld a,#0xfe                      ; 0971
	jr loc_0977                     ; 0973
loc_0975:
	ld a,#0xff                      ; 0975
loc_0977:
	ld (event_C1B2),a                 ; 0977
loc_097A:
	ret                             ; 097A
data_097B:
	.db 0x00, 0x01, 0x02, 0x04, 0x08 ; 097B
	.db 0x10, 0x1f                  ; 0980

;; ---------------------------------------------------------------- $00982
;; classement : atteinte uniquement par task0_main
	.area _B00_0982
sub_0982:
	call sound_init                 ; 0982
	xor a                           ; 0985
	ld (snd_queue_0),a              ; 0986
	ld (snd_queue_music),a          ; 0989
	ld (snd_queue_sfx),a            ; 098C
	jr sub_0994                     ; 098F

;; ---------------------------------------------------------------- $00991
;; classement : atteinte uniquement par task0_main
	.area _B00_0991
sub_0991:
	call sub_0AB2                   ; 0991

;; ---------------------------------------------------------------- $00994
;; classement : atteinte uniquement par task0_main
	.area _B00_0994
sub_0994:
	call sub_5EBD                   ; 0994
	call sub_44BC                   ; 0997
	call sub_0A6B                   ; 099A
	call sub_0A33                   ; 099D
loc_09A0:
	ld a,#0x17                      ; 09A0
	ld (bank_slot2_shadow),a        ; 09A2
	ld (MAPPER_SLOT2),a             ; 09A5  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(current_stage)           ; 09A8
	ld h,#0x00                      ; 09AB
	add hl,hl                       ; 09AD
	ld de,#data_b23_AC33            ; 09AE
	add hl,de                       ; 09B1
	ld e,(hl)                       ; 09B2
	inc hl                          ; 09B3
	ld d,(hl)                       ; 09B4
	ld a,(flow_C1B0)                 ; 09B5
	add a,a                         ; 09B8
	ld l,a                          ; 09B9
	ld h,#0x00                      ; 09BA
	add hl,de                       ; 09BC
	ld a,(hl)                       ; 09BD
	ld (game_mode),a                ; 09BE
	inc hl                          ; 09C1
	ld a,(hl)                       ; 09C2
	ld (scene_id),a                 ; 09C3
	ld a,(game_mode)                ; 09C6
	cp #0xff                        ; 09C9
	jr nz,loc_09DC                  ; 09CB
	call sub_0AFB                   ; 09CD
	xor a                           ; 09D0
	ld (current_stage),a            ; 09D1
	ld a,(flow_C1A0)                 ; 09D4
	ld (flow_C1B0),a                 ; 09D7
	jr loc_09A0                     ; 09DA
loc_09DC:
	ld hl,(game_mode)               ; 09DC
	ld h,#0x00                      ; 09DF
	ld de,#data_09FD                ; 09E1
	add hl,de                       ; 09E4
	ld a,(hl)                       ; 09E5
	ld a,#0x32                      ; 09E6
	ld (freeze_timer),a             ; 09E8
	call sub_0A28                   ; 09EB
	ld hl,(game_mode)               ; 09EE
	ld h,#0x00                      ; 09F1
	add hl,hl                       ; 09F3
	ld de,#jt_0A02                  ; 09F4
	add hl,de                       ; 09F7
	ld e,(hl)                       ; 09F8
	inc hl                          ; 09F9
	ld d,(hl)                       ; 09FA
	ex de,hl                        ; 09FB
	jp (hl)                         ; 09FC
data_09FD:
	.db 0x32, 0x00, 0x32            ; 09FD
	.db 0x32, 0x32                  ; 0A00
jt_0A02:
	.dw loc_0A12                    ; 0A02
	.dw loc_0A0C                    ; 0A04
	.dw loc_0A18                    ; 0A06
	.dw loc_0A18                    ; 0A08
	.dw loc_0A18                    ; 0A0A
loc_0A0C:
	ld a,#0x05                      ; 0A0C
	call task_start                 ; 0A0E
	ret                             ; 0A11
loc_0A12:
	ld a,#0x04                      ; 0A12
	call task_start                 ; 0A14
	ret                             ; 0A17
loc_0A18:
	ld a,#0x01                      ; 0A18
	call task_start                 ; 0A1A
	ld a,#0x03                      ; 0A1D
	call task_start                 ; 0A1F
	ld a,#0x02                      ; 0A22
	call task_start                 ; 0A24
	ret                             ; 0A27

;; ---------------------------------------------------------------- $00A28
;; classement : atteinte uniquement par task0_main
	.area _B00_0A28
sub_0A28:
	ld a,#0x83                      ; 0A28
	ld hl,#game_flags               ; 0A2A
	and (hl)                        ; 0A2D
	ld (hl),a                       ; 0A2E
	inc hl                          ; 0A2F
	ld (hl),#0x00                   ; 0A30
	ret                             ; 0A32

;; ---------------------------------------------------------------- $00AB2
;; classement : atteinte uniquement par task0_main
	.area _B00_0AB2
sub_0AB2:
	ld a,#0x01                      ; 0AB2
	call task_kill                  ; 0AB4
	ld a,#0x03                      ; 0AB7
	call task_kill                  ; 0AB9
	ld a,#0x02                      ; 0ABC
	call task_kill                  ; 0ABE
	ld a,#0x04                      ; 0AC1
	call task_kill                  ; 0AC3
	ld a,#0x05                      ; 0AC6
	call task_kill                  ; 0AC8
	ret                             ; 0ACB

;; ---------------------------------------------------------------- $00ACC
;; classement : atteinte uniquement par task0_main
	.area _B00_0ACC
sub_0ACC:
	ld a,(current_stage)            ; 0ACC
	or a                            ; 0ACF
	jr nz,loc_0AE1                  ; 0AD0
	ld a,(flow_C1A0)                 ; 0AD2
	inc a                           ; 0AD5
	ld (current_stage),a            ; 0AD6
	xor a                           ; 0AD9
	ld (flow_C1B0),a                 ; 0ADA
	ld (player_C1B3),a                 ; 0ADD
	ret                             ; 0AE0
loc_0AE1:
	ld a,(game_mode)                ; 0AE1
	cp #0x05                        ; 0AE4
	jr z,loc_0AEC                   ; 0AE6
	cp #0x01                        ; 0AE8
	jr nz,loc_0AF4                  ; 0AEA
loc_0AEC:
	ld a,(flow_C1B0)                 ; 0AEC
	inc a                           ; 0AEF
	ld (flow_C1B0),a                 ; 0AF0
	ret                             ; 0AF3
loc_0AF4:
	ld a,(player_C1B3)                 ; 0AF4
	ld (flow_C1B0),a                 ; 0AF7
	ret                             ; 0AFA

;; ---------------------------------------------------------------- $00AFB
;; classement : atteinte uniquement par task0_main
	.area _B00_0AFB
sub_0AFB:
	ld hl,#game_flags               ; 0AFB
	bit 2,(hl)                      ; 0AFE
	ret z                           ; 0B00
	res 2,(hl)                      ; 0B01
	xor a                           ; 0B03
	ld (flow_C1B1),a                 ; 0B04
	ld a,#0x17                      ; 0B07
	ld (bank_slot2_shadow),a        ; 0B09
	ld (MAPPER_SLOT2),a             ; 0B0C  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(flow_C1A0)                ; 0B0F
	ld h,#0x00                      ; 0B12
	add hl,hl                       ; 0B14
	ld de,#data_b23_B07B            ; 0B15
	add hl,de                       ; 0B18
	ld e,(hl)                       ; 0B19
	inc hl                          ; 0B1A
	ld d,(hl)                       ; 0B1B
	ex de,hl                        ; 0B1C
	set 7,(hl)                      ; 0B1D
	ret                             ; 0B1F

;; ---------------------------------------------------------------- $03DD0
;; classement : atteinte uniquement par task0_main
	.area _B00_3DD0
sub_3DD0:
	call sub_0A33                   ; 3DD0
	call sub_3DDD                   ; 3DD3
	call sub_4607                   ; 3DD6
	call sub_3E15                   ; 3DD9
	ret                             ; 3DDC

;; ---------------------------------------------------------------- $03DDD
;; classement : atteinte uniquement par task0_main
	.area _B00_3DDD
sub_3DDD:
	call sub_4616                   ; 3DDD
	ld a,#0x13                      ; 3DE0
	ld (bank_slot2_shadow),a        ; 3DE2
	ld (MAPPER_SLOT2),a             ; 3DE5  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b19_8000            ; 3DE8
	ld de,#0xc01a                   ; 3DEB
	ld bc,#0x0020                   ; 3DEE
	push hl                         ; 3DF1
	push bc                         ; 3DF2
	ldir                            ; 3DF3
	pop bc                          ; 3DF5
	pop hl                          ; 3DF6
	ldir                            ; 3DF7
	ld hl,#level_map                ; 3DF9
	ld de,#flow_CF28                 ; 3DFC
	ld bc,#0x0b3f                   ; 3DFF
	ld (hl),#0x00                   ; 3E02
	ldir                            ; 3E04
	ld hl,#data_b19_8020            ; 3E06
	ld de,#level_map                ; 3E09
	call sub_4667                   ; 3E0C
	ld hl,#vdp_requests2            ; 3E0F
	set 6,(hl)                      ; 3E12
	ret                             ; 3E14

;; ---------------------------------------------------------------- $03E15
;; classement : atteinte uniquement par task0_main
	.area _B00_3E15
sub_3E15:
	call sub_0050                   ; 3E15
	call sub_3ED3                   ; 3E18
	ld b,#0x80                      ; 3E1B
loc_3E1D:
	push bc                         ; 3E1D
	call task_yield                 ; 3E1E
	pop bc                          ; 3E21
	ld a,(joypad_pressed)           ; 3E22
	or a                            ; 3E25
	jr nz,loc_3E2A                  ; 3E26
	djnz loc_3E1D                   ; 3E28
loc_3E2A:
	ld a,#0x80                      ; 3E2A
	call sub_3E30                   ; 3E2C
	ret                             ; 3E2F

;; ---------------------------------------------------------------- $03E30
;; classement : atteinte uniquement par task0_main
	.area _B00_3E30
sub_3E30:
	ld hl,#data_3EB8                ; 3E30
	ld de,#0x6000                   ; 3E33
	jr loc_3E3E                     ; 3E36

;; ---------------------------------------------------------------- $03E38
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_3E38
sub_3E38:
	ld hl,#data_3EC1                ; 3E38
	ld de,#0x6000                   ; 3E3B
loc_3E3E:
	ld (map_bank),hl                ; 3E3E
	ld (tmp_d3),hl                  ; 3E41
	ld bc,#0x0008                   ; 3E44
	add hl,bc                       ; 3E47
	ld (tmp_d5),hl                  ; 3E48
	ld (util_C0D9),de                ; 3E4B
	ld (flow_CF49),a                 ; 3E4F
	ld c,#0x08                      ; 3E52
loc_3E54:
	ld a,(flow_CF49)                 ; 3E54
	ld b,a                          ; 3E57
	ld de,(util_C0D9)                ; 3E58
loc_3E5C:
	push bc                         ; 3E5C
	di                              ; 3E5D
	res 6,d                         ; 3E5E
	rst 0x10                        ; 3E60  VDP : adresse/commande = de
	ld b,#0x20                      ; 3E61
	ld hl,#level_map                ; 3E63
loc_3E66:
	in a,(VDP_DATA)                 ; 3E66  VDP : donnee VRAM/CRAM
	ld (hl),a                       ; 3E68
	inc hl                          ; 3E69
	djnz loc_3E66                   ; 3E6A
	set 6,d                         ; 3E6C
	rst 0x10                        ; 3E6E  VDP : adresse/commande = de
	ld hl,(map_bank)                ; 3E6F
	ld ix,#level_map                ; 3E72
	ld c,#0x04                      ; 3E76
	ld b,#0x20                      ; 3E78
loc_3E7A:
	ld a,0(ix)                      ; 3E7A
	and (hl)                        ; 3E7D
	out (VDP_DATA),a                ; 3E7E  VDP : donnee VRAM/CRAM
	inc ix                          ; 3E80
	dec c                           ; 3E82
	jr nz,loc_3E8A                  ; 3E83
	ld c,#0x04                      ; 3E85
	call sub_3EA0                   ; 3E87
loc_3E8A:
	djnz loc_3E7A                   ; 3E8A
	ei                              ; 3E8C
	ld hl,#0x0020                   ; 3E8D
	add hl,de                       ; 3E90
	ex de,hl                        ; 3E91
	pop bc                          ; 3E92
	djnz loc_3E5C                   ; 3E93
	ld hl,(map_bank)                ; 3E95
	inc hl                          ; 3E98
	ld (map_bank),hl                ; 3E99
	dec c                           ; 3E9C
	jr nz,loc_3E54                  ; 3E9D
	ret                             ; 3E9F

;; ---------------------------------------------------------------- $03EA0
;; classement : atteinte uniquement par task0_main
	.area _B00_3EA0
sub_3EA0:
	push de                         ; 3EA0
	push bc                         ; 3EA1
	inc hl                          ; 3EA2
	ld d,h                          ; 3EA3
	ld e,l                          ; 3EA4
	ld bc,(tmp_d5)                  ; 3EA5
	or a                            ; 3EA9
	sbc hl,bc                       ; 3EAA
	jr c,loc_3EB3                   ; 3EAC
	ld hl,(tmp_d3)                  ; 3EAE
	jr loc_3EB5                     ; 3EB1
loc_3EB3:
	ld h,d                          ; 3EB3
	ld l,e                          ; 3EB4
loc_3EB5:
	pop bc                          ; 3EB5
	pop de                          ; 3EB6
	ret                             ; 3EB7
data_3EB8:
	.db 0x7f, 0xbf, 0xdf, 0xef, 0xf7, 0xfb, 0xfd, 0xfe ; 3EB8
	.db 0xff                        ; 3EC0
data_3EC1:
	.db 0x7f, 0xbf, 0xf7, 0xfb, 0xdf, 0xef, 0xfd, 0xfe, 0xff, 0x7f, 0xfd, 0xef, 0xf7, 0xbf ; 3EC1

;; ---------------------------------------------------------------- $03ECF
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_3ECF
sub_3ECF:
	cp #0xdf                        ; 3ECF
	ei                              ; 3ED1
	rst 0x38                        ; 3ED2

;; ---------------------------------------------------------------- $03ED3
;; classement : atteinte uniquement par task0_main
	.area _B00_3ED3
sub_3ED3:
	ld hl,#flow_D303                 ; 3ED3
	ld (flow_C0DB),hl                ; 3ED6
	ld hl,#data_6800                ; 3ED9
	ld (flow_C0DD),hl                ; 3EDC
	ld a,#0x04                      ; 3EDF
	ld (coll_C0E1),a                 ; 3EE1
	ld de,#VDP_VRAM_WRITE|0x2600    ; 3EE4
	ld bc,#0x00a0                   ; 3EE7
	ld hl,#0x0000                   ; 3EEA
	call sub_44D0                   ; 3EED
	ld de,#data_7816                ; 3EF0
	ld a,#0x0a                      ; 3EF3
loc_3EF5:
	ld l,#0x30                      ; 3EF5
	ld b,#0x0a                      ; 3EF7
	push af                         ; 3EF9
	call sub_3FE3                   ; 3EFA
	pop af                          ; 3EFD
	ld hl,#0x0040                   ; 3EFE
	add hl,de                       ; 3F01
	ld d,h                          ; 3F02
	ld e,l                          ; 3F03
	dec a                           ; 3F04
	jr nz,loc_3EF5                  ; 3F05
loc_3F07:
	ld a,#0x08                      ; 3F07
	ld (flow_C0E3),a                 ; 3F09
	jr loc_3F18                     ; 3F0C
loc_3F0E:
	ld hl,(flow_C0DD)                ; 3F0E
	ld de,#flow_FEC0                 ; 3F11
	add hl,de                       ; 3F14
	ld (flow_C0DD),hl                ; 3F15
loc_3F18:
	ld a,#0x0a                      ; 3F18
	ld (flow_C0E2),a                 ; 3F1A
	ld hl,#data_6600                ; 3F1D
	ld (flow_C0DF),hl                ; 3F20
loc_3F23:
	ld hl,(flow_C0DB)                ; 3F23
	ld de,(flow_C0DD)                ; 3F26
	ld a,(flow_C0E3)                 ; 3F2A
	call sub_3FF5                   ; 3F2D
	ld hl,(flow_C0DD)                ; 3F30
	ld de,#0x0020                   ; 3F33
	add hl,de                       ; 3F36
	ld (flow_C0DD),hl                ; 3F37
	ld hl,(flow_C0DB)                ; 3F3A
	ld de,(flow_C0DF)                ; 3F3D
	ld a,#0x08                      ; 3F41
	call sub_3FF5                   ; 3F43
	ld hl,(flow_C0DF)                ; 3F46
	ld de,#0x0020                   ; 3F49
	add hl,de                       ; 3F4C
	ld (flow_C0DF),hl                ; 3F4D
	ld hl,(flow_C0DB)                ; 3F50
	ld de,#0x0020                   ; 3F53
	add hl,de                       ; 3F56
	ld (flow_C0DB),hl                ; 3F57
	ld a,(flow_C0E2)                 ; 3F5A
	dec a                           ; 3F5D
	ld (flow_C0E2),a                 ; 3F5E
	jr nz,loc_3F23                  ; 3F61
	ld hl,(flow_C0DB)                ; 3F63
	ld de,#flow_FEBC                 ; 3F66
	add hl,de                       ; 3F69
	ld (flow_C0DB),hl                ; 3F6A
	ld bc,(flow_C0E0)                ; 3F6D
	ld hl,#0x0000                   ; 3F71
	ld de,#0x0040                   ; 3F74
	xor a                           ; 3F77
	ld c,#0x0a                      ; 3F78
loc_3F7A:
	add a,c                         ; 3F7A
	add hl,de                       ; 3F7B
	djnz loc_3F7A                   ; 3F7C
	ld de,#0x79d6                   ; 3F7E
	add hl,de                       ; 3F81
	ex de,hl                        ; 3F82
	ld l,a                          ; 3F83
	ld a,#0x68                      ; 3F84
	sub l                           ; 3F86
	ld l,a                          ; 3F87
	ld b,#0x0a                      ; 3F88
	call sub_3FE3                   ; 3F8A
	ld a,#0x01                      ; 3F8D
	call sub_0332                   ; 3F8F
	ld a,(flow_C0E3)                 ; 3F92
	dec a                           ; 3F95
	ld (flow_C0E3),a                 ; 3F96
	jp nz,loc_3F0E                  ; 3F99
	ld hl,(flow_C0DB)                ; 3F9C
	ld de,#flow_FEE0                 ; 3F9F
	add hl,de                       ; 3FA2
	ld (flow_C0DB),hl                ; 3FA3
	ld a,(coll_C0E1)                 ; 3FA6
	dec a                           ; 3FA9
	ld (coll_C0E1),a                 ; 3FAA
	jp nz,loc_3F07                  ; 3FAD
	in a,(IO_PORT_A)                ; 3FB0  manette 1 (+ haut/bas manette 2)
	and #0x32                       ; 3FB2
	jr nz,loc_3FB6                  ; 3FB4
loc_3FB6:
	ld de,#VDP_VRAM_WRITE|0x3800    ; 3FB6
	ld bc,#0x0100                   ; 3FB9
	ld hl,#0x0100                   ; 3FBC
	call sub_44D0                   ; 3FBF
.if VERSION_SMS_EN
	nop                             ; 3FC2
	nop                             ; 3FC3
.else ; VERSION_GG_JP
	in a,(GG_START)                 ; 3FC2  GG : bouton Start (bit 7)
.endif
	bit 6,a                         ; 3FC4
	jr z,loc_3FE2                   ; 3FC6
	ld hl,#0x5656                   ; 3FC8
	ld (vdp_C200),hl                ; 3FCB
	ld hl,#0x00a0                   ; 3FCE
	ld (flow_C24D),hl                ; 3FD1
	ld hl,#data_02A8                ; 3FD4
	ld (flow_C24F),hl                ; 3FD7
	ld hl,#vdp_requests2            ; 3FDA
	set 7,(hl)                      ; 3FDD
	call task_yield                 ; 3FDF
loc_3FE2:
	ret                             ; 3FE2

;; ---------------------------------------------------------------- $03FE3
;; classement : atteinte uniquement par task0_main
	.area _B00_3FE3
sub_3FE3:
	di                              ; 3FE3
	rst 0x10                        ; 3FE4  VDP : adresse/commande = de
	ld h,#0x01                      ; 3FE5
loc_3FE7:
	ld a,l                          ; 3FE7
	out (VDP_DATA),a                ; 3FE8  VDP : donnee VRAM/CRAM
	push af                         ; 3FEA
	pop af                          ; 3FEB
	ld a,h                          ; 3FEC
	out (VDP_DATA),a                ; 3FED  VDP : donnee VRAM/CRAM
	inc l                           ; 3FEF
	nop                             ; 3FF0
	djnz loc_3FE7                   ; 3FF1
	ei                              ; 3FF3
	ret                             ; 3FF4

;; ---------------------------------------------------------------- $03FF5
;; classement : atteinte uniquement par task0_main
	.area _B00_3FF5
sub_3FF5:
	di                              ; 3FF5
	push af                         ; 3FF6
	rst 0x10                        ; 3FF7  VDP : adresse/commande = de
	pop af                          ; 3FF8
	ld c,#0xbe                      ; 3FF9
	ld d,h                          ; 3FFB
	ld e,l                          ; 3FFC
loc_3FFD::
	ld b,#0x04                      ; 3FFD
	ld h,d                          ; 3FFF

;; ---------------------------------------------------------------- $05EBD
;; classement : atteinte uniquement par task0_main
	.area _B01_5EBD
sub_5EBD:
	call sub_223B                   ; 5EBD
	call sub_363E                   ; 5EC0
	call sub_5ECA                   ; 5EC3
	call sub_5ED5                   ; 5EC6
	ret                             ; 5EC9

;; ---------------------------------------------------------------- $0ADA6
;; classement : atteinte uniquement par task0_main
	.area _B02_ADA6
sub_b02_ADA6:
	ld a,(game_mode)                ; ADA6
	cp #0x01                        ; ADA9
	jr z,loc_b02_ADB1               ; ADAB
	cp #0x05                        ; ADAD
	jr nz,loc_b02_ADC7              ; ADAF
loc_b02_ADB1:
	ld a,(scene_id)                 ; ADB1
	cp #0x14                        ; ADB4
	jr nc,loc_b02_ADD2              ; ADB6
	ld de,#data_b02_ADD8            ; ADB8
	ld hl,(scene_id)                ; ADBB
	ld h,#0x00                      ; ADBE
loc_b02_ADC0::
	add hl,de                       ; ADC0
	ld a,(hl)                       ; ADC1
	or a                            ; ADC2
	jr z,loc_b02_ADD2               ; ADC3
	jr loc_b02_ADD4                 ; ADC5
loc_b02_ADC7:
	ld a,(scene_id)                 ; ADC7
	cp #0x07                        ; ADCA
	jr z,loc_b02_ADD4               ; ADCC
	cp #0x33                        ; ADCE
	jr z,loc_b02_ADD4               ; ADD0
loc_b02_ADD2::
	xor a                           ; ADD2
	ret                             ; ADD3
loc_b02_ADD4::
	ld a,#0x01                      ; ADD4
	or a                            ; ADD6
	ret                             ; ADD7
data_b02_ADD8:
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; ADD8
	.db 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01 ; ADE0
data_b02_ADEC::
	.db 0xeb, 0xb0, 0xeb, 0xb0      ; ADEC
	.db 0xeb, 0xb0, 0xeb, 0xb0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfa, 0xb0, 0x00, 0x00, 0x00, 0x00 ; ADF0
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; AE00
	.db 0x5a, 0xb1, 0x5a, 0xb1, 0x4b, 0xb1, 0x4b, 0xb1, 0x4b, 0xb1, 0x4b, 0xb1, 0x4b, 0xb1, 0x4b, 0xb1 ; AE10
	.db 0x4b, 0xb1, 0x7e, 0xb1, 0x7e, 0xb1, 0x7e, 0xb1, 0x2a, 0xb1, 0x2a, 0xb1, 0x2a, 0xb1, 0x00, 0x00 ; AE20
	.db 0x2a, 0xb1, 0x2a, 0xb1, 0x2a, 0xb1, 0x03, 0xb1, 0x2a, 0xb1, 0x2a, 0xb1, 0x2a, 0xb1, 0x2a, 0xb1 ; AE30
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x2a, 0xb1, 0x2a, 0xb1, 0x2a, 0xb1, 0x2a, 0xb1, 0x2a, 0xb1 ; AE40
	.db 0x00, 0x00, 0xdd, 0xaf, 0x28, 0xb0, 0x3d, 0xb0, 0x67, 0xb0, 0x60, 0xae, 0x00, 0x00, 0x88, 0xb0 ; AE50
	.db 0x02, 0xc2, 0xb7, 0x02, 0xe2, 0xb7, 0x02, 0xc2, 0xb7, 0x02, 0xe2, 0xb7, 0x02, 0xc2, 0xb7, 0x02 ; AE60
	.db 0xe2, 0xb7, 0x02, 0xc2, 0xb7, 0x02, 0xe2, 0xb7, 0x02, 0xc2, 0xb7, 0x02, 0xe2, 0xb7, 0x02, 0xc2 ; AE70
	.db 0xb7, 0x02, 0xe2, 0xb7, 0x02, 0xc2, 0xb7, 0x02, 0xe2, 0xb7, 0x02, 0xc2, 0xb7, 0x02, 0xe2, 0xb7 ; AE80
	.db 0x02, 0xc2, 0xb7, 0x02, 0xe2, 0xb7, 0x02, 0xc2, 0xb7, 0x02, 0xe2, 0xb7, 0x02, 0xc2, 0xb7, 0x02 ; AE90
	.db 0xe2, 0xb7, 0x02, 0xc2, 0xb7, 0x02, 0xe2, 0xb7, 0x02, 0xc2, 0xb7, 0x02, 0xe2, 0xb7, 0x02, 0xc2 ; AEA0
	.db 0xb7, 0x02, 0xe2, 0xb7, 0x02, 0xc2, 0xb7, 0x02, 0xe2, 0xb7, 0x02, 0xc2, 0xb7, 0x02, 0xe2, 0xb7 ; AEB0
	.db 0x02, 0xc2, 0xb7, 0x02, 0xe2, 0xb7, 0x02, 0xc2, 0xb7, 0x02, 0xe2, 0xb7, 0x02, 0xc2, 0xb7, 0x02 ; AEC0
	.db 0xe2, 0xb7, 0x02, 0xc2, 0xb7, 0x02, 0xe2, 0xb7, 0x02, 0x39, 0xa6, 0xff, 0xd8, 0xae, 0x02, 0x22 ; AED0
	.db 0xb4, 0x02, 0x42, 0xb4, 0x02, 0x62, 0xb4, 0x02, 0x82, 0xb4, 0x02, 0x22, 0xb4, 0x02, 0x42, 0xb4 ; AEE0
	.db 0x02, 0x62, 0xb4, 0x02, 0x82, 0xb4, 0x02, 0x22, 0xb4, 0x02, 0x42, 0xb4, 0x02, 0x62, 0xb4, 0x02 ; AEF0
	.db 0x82, 0xb4, 0x02, 0xa2, 0xb4, 0x02, 0xc2, 0xb4, 0x02, 0xe2, 0xb4, 0x02, 0x02, 0xb5, 0x02, 0xa2 ; AF00
	.db 0xb4, 0x02, 0xc2, 0xb4, 0x02, 0xe2, 0xb4, 0x02, 0x02, 0xb5, 0x02, 0xa2, 0xb4, 0x02, 0xc2, 0xb4 ; AF10
	.db 0x02, 0xe2, 0xb4, 0x02, 0x02, 0xb5, 0x02, 0x22, 0xb5, 0x02, 0x42, 0xb5, 0x02, 0x62, 0xb5, 0x02 ; AF20
	.db 0x82, 0xb5, 0x02, 0x22, 0xb5, 0x02, 0x42, 0xb5, 0x02, 0x62, 0xb5, 0x02, 0x82, 0xb5, 0x02, 0x22 ; AF30
	.db 0xb5, 0x02, 0x42, 0xb5, 0x02, 0x62, 0xb5, 0x02, 0x82, 0xb5, 0x02, 0xa2, 0xb5, 0x02, 0xc2, 0xb5 ; AF40
	.db 0x02, 0xe2, 0xb5, 0x02, 0x02, 0xb6, 0x02, 0xa2, 0xb5, 0x02, 0xc2, 0xb5, 0x02, 0xe2, 0xb5, 0x02 ; AF50
	.db 0x02, 0xb6, 0x02, 0xa2, 0xb5, 0x02, 0xc2, 0xb5, 0x02, 0xe2, 0xb5, 0x02, 0x02, 0xb6, 0x02, 0x22 ; AF60
	.db 0xb6, 0x02, 0x42, 0xb6, 0x02, 0x62, 0xb6, 0x02, 0x82, 0xb6, 0x02, 0x22, 0xb6, 0x02, 0x42, 0xb6 ; AF70
	.db 0x02, 0x62, 0xb6, 0x02, 0x82, 0xb6, 0x02, 0x22, 0xb6, 0x02, 0x42, 0xb6, 0x02, 0x62, 0xb6, 0x02 ; AF80
	.db 0x82, 0xb6, 0x02, 0xa2, 0xb6, 0x02, 0xc2, 0xb6, 0x02, 0xe2, 0xb6, 0x02, 0x02, 0xb7, 0x02, 0xa2 ; AF90
	.db 0xb6, 0x02, 0xc2, 0xb6, 0x02, 0xe2, 0xb6, 0x02, 0x02, 0xb7, 0x02, 0xa2, 0xb6, 0x02, 0xc2, 0xb6 ; AFA0
	.db 0x02, 0xe2, 0xb6, 0x02, 0x02, 0xb7, 0x02, 0x22, 0xb7, 0x02, 0x42, 0xb7, 0x02, 0x62, 0xb7, 0x02 ; AFB0
	.db 0x82, 0xb7, 0x02, 0x22, 0xb7, 0x02, 0x42, 0xb7, 0x02, 0x62, 0xb7, 0x02, 0x82, 0xb7, 0x02, 0x22 ; AFC0
	.db 0xb7, 0x02, 0x42, 0xb7, 0x02, 0x62, 0xb7, 0x02, 0x82, 0xb7, 0x00, 0xa2, 0xb7, 0x0a, 0xa2, 0xb1 ; AFD0
	.db 0x0a, 0xc2, 0xb1, 0x0a, 0xe2, 0xb1, 0x0a, 0x02, 0xb2, 0x0a, 0x22, 0xb2, 0x0a, 0x42, 0xb2, 0x0a ; AFE0
	.db 0x62, 0xb2, 0x0a, 0x82, 0xb2, 0x0a, 0xa2, 0xb2, 0x0a, 0xc2, 0xb2, 0x0a, 0xe2, 0xb2, 0x0a, 0x02 ; AFF0
	.db 0xb3, 0x0a, 0x22, 0xb3, 0x0a, 0x42, 0xb3, 0x0a, 0x62, 0xb3, 0x0a, 0x82, 0xb3, 0x0a, 0xa2, 0xb3 ; B000
	.db 0x0a, 0xc2, 0xb3, 0x0a, 0xe2, 0xb3, 0x0a, 0x02, 0xb4, 0x0a, 0xe2, 0xb3, 0x0a, 0xc2, 0xb3, 0x0a ; B010
	.db 0xa2, 0xb3, 0x0a, 0x82, 0xb3, 0xff, 0x0a, 0xb0, 0x0f, 0xf9, 0xa9, 0x0f, 0x19, 0xaa, 0x0f, 0x39 ; B020
	.db 0xaa, 0x0f, 0x59, 0xaa, 0x0f, 0x39, 0xaa, 0x0f, 0x19, 0xaa, 0xff, 0x28, 0xb0, 0x05, 0x79, 0xaa ; B030
	.db 0x05, 0x99, 0xaa, 0x05, 0xb9, 0xaa, 0x05, 0xd9, 0xaa, 0x05, 0xf9, 0xaa, 0x05, 0x19, 0xab, 0x05 ; B040
	.db 0x39, 0xab, 0x05, 0x59, 0xab, 0x05, 0x79, 0xab, 0x05, 0x99, 0xab, 0x05, 0xb9, 0xab, 0x05, 0xd9 ; B050
	.db 0xab, 0x05, 0xf9, 0xab, 0x05, 0xf9, 0xab, 0x05, 0xf9, 0xab, 0x05, 0x19, 0xac, 0x05, 0x39, 0xac ; B060
	.db 0x05, 0x59, 0xac, 0x05, 0x79, 0xac, 0x05, 0x99, 0xac, 0x05, 0x79, 0xac, 0x05, 0x59, 0xac, 0x05 ; B070
	.db 0x39, 0xac, 0x05, 0x19, 0xac, 0xff, 0x67, 0xb0, 0x02, 0x02, 0xb8, 0x02, 0x22, 0xb8, 0x02, 0x02 ; B080
	.db 0xb8, 0x02, 0x22, 0xb8, 0x02, 0x02, 0xb8, 0x02, 0x22, 0xb8, 0x02, 0x02, 0xb8, 0x02, 0x22, 0xb8 ; B090
	.db 0x02, 0x02, 0xb8, 0x02, 0x22, 0xb8, 0x02, 0x02, 0xb8, 0x02, 0x22, 0xb8, 0x02, 0x02, 0xb8, 0x02 ; B0A0
	.db 0x22, 0xb8, 0x02, 0x02, 0xb8, 0x02, 0x22, 0xb8, 0x02, 0x02, 0xb8, 0x02, 0x22, 0xb8, 0x02, 0x02 ; B0B0
	.db 0xb8, 0x02, 0x22, 0xb8, 0x02, 0xf9, 0xab, 0x3c, 0xb9, 0xac, 0x01, 0xd9, 0xac, 0x01, 0xf9, 0xac ; B0C0
	.db 0x01, 0x19, 0xad, 0x01, 0x39, 0xad, 0x01, 0x59, 0xad, 0x01, 0x39, 0xad, 0x01, 0x19, 0xad, 0x01 ; B0D0
	.db 0xf9, 0xac, 0x01, 0xd9, 0xac, 0x01, 0xb9, 0xac, 0xff, 0xca, 0xb0, 0x03, 0x99, 0xa4, 0x03, 0xb9 ; B0E0
	.db 0xa4, 0x03, 0xd9, 0xa4, 0x03, 0xf9, 0xa4, 0xff, 0xeb, 0xb0, 0x0a, 0x39, 0xa5, 0x0a, 0xb9, 0xa5 ; B0F0
	.db 0xff, 0xfa, 0xb0, 0x03, 0xd9, 0xa8, 0x03, 0xf9, 0xa8, 0x03, 0x19, 0xa9, 0x03, 0x39, 0xa9, 0x03 ; B100
	.db 0x59, 0xa9, 0x03, 0xf9, 0xa8, 0x03, 0xd9, 0xa8, 0x03, 0x79, 0xa9, 0x03, 0x99, 0xa9, 0x03, 0xb9 ; B110
	.db 0xa9, 0x03, 0x99, 0xa9, 0x03, 0xf9, 0xa8, 0xff, 0x03, 0xb1, 0x05, 0x99, 0xa7, 0x05, 0xb9, 0xa7 ; B120
	.db 0x05, 0xd9, 0xa7, 0x05, 0xf9, 0xa7, 0x05, 0x19, 0xa8, 0x05, 0x39, 0xa8, 0x05, 0x59, 0xa8, 0x05 ; B130
	.db 0x79, 0xa8, 0x05, 0x99, 0xa8, 0x05, 0xb9, 0xa8, 0xff, 0x2a, 0xb1, 0x05, 0x59, 0xa6, 0x05, 0x79 ; B140
	.db 0xa6, 0x05, 0x99, 0xa6, 0x05, 0xb9, 0xa6, 0xff, 0x4b, 0xb1, 0x05, 0xf9, 0xa6, 0x05, 0xf9, 0xa6 ; B150
	.db 0x05, 0x19, 0xa7, 0x05, 0xf9, 0xa6, 0x05, 0xf9, 0xa6, 0x05, 0xf9, 0xa6, 0x05, 0xf9, 0xa6, 0x05 ; B160
	.db 0xf9, 0xa6, 0x05, 0xf9, 0xa6, 0x05, 0xf9, 0xa6, 0x05, 0x19, 0xa7, 0xff, 0x5a, 0xb1, 0x05, 0x39 ; B170
	.db 0xa7, 0x05, 0x39, 0xa7, 0x05, 0x59, 0xa7, 0x05, 0x39, 0xa7, 0x05, 0x39, 0xa7, 0x05, 0x39, 0xa7 ; B180
	.db 0x05, 0x39, 0xa7, 0x05, 0x39, 0xa7, 0x05, 0x39, 0xa7, 0x05, 0x39, 0xa7, 0x05, 0x59, 0xa7, 0xff ; B190
	.db 0x7e, 0xb1, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f ; B1A0
	.db 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f ; B1B0
	.db 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xfe, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xef, 0x0f ; B1C0
	.db 0xff, 0x0f, 0xfe, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f ; B1D0
	.db 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0e, 0xed, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xdf, 0x0f ; B1E0
	.db 0xfe, 0x0f, 0xfd, 0x0e, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f ; B1F0
	.db 0xff, 0x0f, 0xff, 0x0f, 0xef, 0x0d, 0xdc, 0x0e, 0xff, 0x0f, 0xff, 0x0f, 0xef, 0x0f, 0xcf, 0x0e ; B200
	.db 0xfd, 0x0e, 0xfc, 0x0d, 0xff, 0x0e, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f ; B210
	.db 0xfe, 0x0f, 0xff, 0x0f, 0xdf, 0x0c, 0xcb, 0x0d, 0xff, 0x0f, 0xff, 0x0f, 0xdf, 0x0f, 0xbf, 0x0d ; B220
	.db 0xfc, 0x0d, 0xfb, 0x0b, 0xff, 0x0d, 0xef, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f ; B230
	.db 0xfd, 0x0f, 0xff, 0x0f, 0xcf, 0x0b, 0xba, 0x0c, 0xff, 0x0f, 0xff, 0x0f, 0xcf, 0x0e, 0xaf, 0x0b ; B240
	.db 0xfb, 0x0c, 0xea, 0x0a, 0xff, 0x0c, 0xdf, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f ; B250
	.db 0xfc, 0x0f, 0xff, 0x0f, 0xbe, 0x0a, 0xa9, 0x0a, 0xff, 0x0f, 0xef, 0x0f, 0xbf, 0x0d, 0x9f, 0x0a ; B260
	.db 0xfa, 0x0b, 0xd9, 0x09, 0xef, 0x0b, 0xce, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f ; B270
	.db 0xeb, 0x0f, 0xff, 0x0f, 0xad, 0x09, 0x98, 0x09, 0xff, 0x0f, 0xdf, 0x0f, 0xaf, 0x0c, 0x8f, 0x08 ; B280
	.db 0xf9, 0x0a, 0xc8, 0x08, 0xdf, 0x0a, 0xbd, 0x0f, 0xff, 0x0e, 0xff, 0x0e, 0xff, 0x0e, 0xfe, 0x0f ; B290
	.db 0xda, 0x0f, 0xff, 0x0e, 0x9c, 0x07, 0x87, 0x08, 0xff, 0x0f, 0xcf, 0x0f, 0x9f, 0x0b, 0x6f, 0x06 ; B2A0
	.db 0xf8, 0x09, 0xb6, 0x07, 0xce, 0x09, 0xac, 0x0f, 0xff, 0x0e, 0xff, 0x0e, 0xff, 0x0e, 0xed, 0x0e ; B2B0
	.db 0xc9, 0x0d, 0xef, 0x0e, 0x8a, 0x06, 0x76, 0x07, 0xff, 0x0f, 0xbf, 0x0e, 0x8f, 0x0a, 0x5f, 0x05 ; B2C0
	.db 0xe7, 0x08, 0xa5, 0x06, 0xbd, 0x08, 0x98, 0x0f, 0xff, 0x0e, 0xff, 0x0e, 0xff, 0x0e, 0xdc, 0x0d ; B2D0
	.db 0xbb, 0x0c, 0xef, 0x0d, 0x79, 0x05, 0x65, 0x06, 0xff, 0x0f, 0xaf, 0x0d, 0x7f, 0x09, 0x4f, 0x04 ; B2E0
	.db 0xd6, 0x07, 0x94, 0x05, 0xac, 0x07, 0x8f, 0x0f, 0xef, 0x0e, 0xef, 0x0e, 0xef, 0x0e, 0xcb, 0x0c ; B2F0
	.db 0xa7, 0x0b, 0xde, 0x0c, 0x68, 0x04, 0x54, 0x05, 0xff, 0x0e, 0x9f, 0x0c, 0x6f, 0x08, 0x3f, 0x03 ; B300
	.db 0xc5, 0x06, 0x83, 0x04, 0x9b, 0x06, 0x79, 0x0f, 0xef, 0x0e, 0xef, 0x0e, 0xef, 0x0e, 0xba, 0x0b ; B310
	.db 0x96, 0x0a, 0xcd, 0x0b, 0x47, 0x02, 0x43, 0x04, 0xff, 0x0d, 0x8f, 0x0b, 0x5f, 0x07, 0x2f, 0x02 ; B320
	.db 0xb4, 0x05, 0x72, 0x03, 0x8a, 0x05, 0x68, 0x0f, 0xef, 0x0e, 0xef, 0x0e, 0xef, 0x0e, 0xa9, 0x0a ; B330
	.db 0x85, 0x09, 0xbc, 0x0a, 0x36, 0x01, 0x32, 0x03, 0xff, 0x0c, 0x7f, 0x09, 0x3f, 0x05, 0x1e, 0x01 ; B340
	.db 0xa3, 0x04, 0x51, 0x02, 0x79, 0x04, 0x47, 0x0f, 0xef, 0x0e, 0xef, 0x0e, 0xef, 0x0e, 0x98, 0x09 ; B350
	.db 0x74, 0x08, 0xab, 0x09, 0x25, 0x00, 0x21, 0x02, 0xff, 0x0b, 0x5e, 0x08, 0x2e, 0x04, 0x0d, 0x00 ; B360
	.db 0x92, 0x03, 0x40, 0x01, 0x68, 0x03, 0x36, 0x01, 0xef, 0x0d, 0xef, 0x0d, 0xef, 0x0d, 0x87, 0x08 ; B370
	.db 0x63, 0x07, 0xab, 0x09, 0x25, 0x00, 0x21, 0x02, 0xff, 0x0b, 0x5e, 0x08, 0x2e, 0x04, 0x0d, 0x00 ; B380
	.db 0x92, 0x03, 0x40, 0x01, 0x68, 0x03, 0x36, 0x01, 0xef, 0x0d, 0xef, 0x0d, 0xef, 0x0d, 0x87, 0x08 ; B390
	.db 0x63, 0x07, 0xab, 0x09, 0x25, 0x00, 0x21, 0x02, 0xff, 0x0b, 0x5e, 0x08, 0x2e, 0x04, 0x0d, 0x00 ; B3A0
	.db 0x92, 0x03, 0x40, 0x01, 0x68, 0x03, 0x36, 0x01, 0xef, 0x0d, 0xef, 0x0d, 0xde, 0x0c, 0x88, 0x08 ; B3B0
	.db 0x64, 0x07, 0xab, 0x09, 0x25, 0x00, 0x21, 0x02, 0xff, 0x0b, 0x5e, 0x08, 0x2e, 0x04, 0x0d, 0x00 ; B3C0
	.db 0x92, 0x03, 0x40, 0x01, 0x68, 0x03, 0x36, 0x01, 0xef, 0x0d, 0xde, 0x0c, 0xcd, 0x0b, 0x88, 0x09 ; B3D0
	.db 0x64, 0x08, 0xab, 0x09, 0x25, 0x00, 0x21, 0x02, 0xff, 0x0b, 0x5e, 0x08, 0x2e, 0x04, 0x0d, 0x00 ; B3E0
	.db 0x92, 0x03, 0x40, 0x01, 0x68, 0x03, 0x36, 0x01, 0xef, 0x0d, 0xcd, 0x0b, 0xbc, 0x0a, 0x98, 0x09 ; B3F0
	.db 0x74, 0x08, 0xab, 0x09, 0x25, 0x00, 0x21, 0x02, 0xff, 0x0b, 0x5e, 0x08, 0x2e, 0x04, 0x0d, 0x00 ; B400
	.db 0x92, 0x03, 0x40, 0x01, 0x68, 0x03, 0x36, 0x01, 0xef, 0x0d, 0xbc, 0x0a, 0xab, 0x09, 0x99, 0x09 ; B410
	.db 0x75, 0x08, 0xad, 0x08, 0x25, 0x00, 0xff, 0x02, 0xff, 0x0b, 0x03, 0x00, 0x9f, 0x00, 0xff, 0x0c ; B420
	.db 0x14, 0x00, 0x4f, 0x00, 0x9f, 0x00, 0x4f, 0x00, 0xef, 0x0d, 0xef, 0x0d, 0xef, 0x0d, 0x79, 0x08 ; B430
	.db 0x47, 0x06, 0x8c, 0x06, 0xff, 0x0f, 0x9f, 0x00, 0xff, 0x02, 0xff, 0x0f, 0x1f, 0x00, 0x04, 0x00 ; B440
	.db 0xff, 0x0f, 0x0f, 0x00, 0x1f, 0x00, 0x0f, 0x00, 0xef, 0x0b, 0xef, 0x0b, 0xbf, 0x07, 0x78, 0x0a ; B450
	.db 0x57, 0x08, 0x8c, 0x04, 0xff, 0x02, 0x1f, 0x00, 0x9f, 0x00, 0xff, 0x02, 0x16, 0x00, 0xff, 0x0f ; B460
	.db 0xff, 0x02, 0x06, 0x00, 0x18, 0x00, 0x06, 0x00, 0xef, 0x0b, 0xbf, 0x07, 0x9f, 0x05, 0x77, 0x0c ; B470
	.db 0x56, 0x0a, 0x8c, 0x01, 0x9f, 0x00, 0x16, 0x00, 0x0f, 0x00, 0x9f, 0x01, 0xff, 0x0f, 0xff, 0x02 ; B480
	.db 0x9f, 0x00, 0xff, 0x0f, 0xef, 0x0f, 0xff, 0x0f, 0xef, 0x0a, 0x9f, 0x05, 0x8d, 0x03, 0x87, 0x0e ; B490
	.db 0x66, 0x0e, 0xbe, 0x09, 0x37, 0x01, 0xff, 0x04, 0xff, 0x0d, 0x14, 0x01, 0xbf, 0x02, 0xff, 0x0d ; B4A0
	.db 0x25, 0x01, 0x5f, 0x01, 0xbf, 0x02, 0x6f, 0x02, 0xff, 0x0d, 0xff, 0x0d, 0xff, 0x0d, 0x8a, 0x0a ; B4B0
	.db 0x68, 0x08, 0xae, 0x07, 0xff, 0x0f, 0xbf, 0x02, 0xff, 0x04, 0xff, 0x0f, 0x4f, 0x02, 0x36, 0x02 ; B4C0
	.db 0xff, 0x0f, 0x2f, 0x01, 0x3f, 0x01, 0x2f, 0x01, 0xff, 0x0c, 0xff, 0x0c, 0xcf, 0x09, 0x99, 0x0c ; B4D0
	.db 0x68, 0x0a, 0xae, 0x06, 0xff, 0x04, 0x3f, 0x02, 0xcf, 0x03, 0xff, 0x04, 0x39, 0x02, 0xff, 0x0f ; B4E0
	.db 0xff, 0x05, 0x3a, 0x02, 0x38, 0x02, 0x29, 0x01, 0xff, 0x0c, 0xcf, 0x09, 0xbf, 0x07, 0x98, 0x0e ; B4F0
	.db 0x78, 0x0c, 0x9e, 0x03, 0xcf, 0x02, 0x39, 0x02, 0x2f, 0x01, 0xcf, 0x03, 0xff, 0x0f, 0xff, 0x05 ; B500
	.db 0xcf, 0x03, 0xff, 0x0f, 0xef, 0x0f, 0xff, 0x0f, 0xef, 0x0c, 0xbf, 0x07, 0x9e, 0x05, 0xb8, 0x0f ; B510
	.db 0x98, 0x0f, 0xcf, 0x0a, 0x48, 0x02, 0xff, 0x07, 0xff, 0x0e, 0x48, 0x02, 0xef, 0x05, 0xff, 0x0e ; B520
	.db 0x48, 0x02, 0x9f, 0x04, 0xdf, 0x04, 0x9f, 0x04, 0xff, 0x0e, 0xff, 0x0e, 0xff, 0x0e, 0x98, 0x0d ; B530
	.db 0x79, 0x0a, 0xcf, 0x09, 0xff, 0x0f, 0xdf, 0x05, 0xff, 0x08, 0xff, 0x0f, 0x6f, 0x04, 0x59, 0x04 ; B540
	.db 0xff, 0x0f, 0x4f, 0x03, 0x5f, 0x04, 0x6f, 0x04, 0xff, 0x0d, 0xff, 0x0e, 0xdf, 0x0b, 0xba, 0x0e ; B550
	.db 0x89, 0x0c, 0xcf, 0x08, 0xff, 0x08, 0x6f, 0x05, 0xff, 0x05, 0xff, 0x08, 0x5b, 0x04, 0xff, 0x0f ; B560
	.db 0xff, 0x09, 0x6b, 0x05, 0x7b, 0x05, 0x7b, 0x05, 0xff, 0x0d, 0xdf, 0x0a, 0xcf, 0x09, 0xb9, 0x0f ; B570
	.db 0x99, 0x0f, 0x8f, 0x05, 0xef, 0x05, 0x6a, 0x05, 0x5f, 0x03, 0xef, 0x05, 0xff, 0x0f, 0xff, 0x09 ; B580
	.db 0xdf, 0x07, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0d, 0xdf, 0x09 ; B590

;; ---------------------------------------------------------------- $0B59C
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_B59C
sub_b02_B59C:
	cp a                            ; B59C
	ex af,af'                       ; B59D
	ret                             ; B59E
	.db 0x0f                        ; B59F
	.db 0xba, 0x0f, 0xef, 0x0c, 0x7c, 0x04, 0xff, 0x09, 0xff, 0x0e, 0x7c, 0x04, 0xef, 0x09, 0xff, 0x0e ; B5A0
	.db 0x7c, 0x04, 0xdf, 0x07, 0xff, 0x09, 0xef, 0x07, 0xff, 0x0e, 0xff, 0x0e, 0xff, 0x0e, 0xbb, 0x0f ; B5B0
	.db 0x89, 0x0e, 0xef, 0x0b, 0xff, 0x0f, 0xef, 0x09, 0xff, 0x0c, 0xff, 0x0f, 0x9f, 0x07, 0x9d, 0x06 ; B5C0
	.db 0xff, 0x0f, 0x8f, 0x05, 0x8f, 0x05, 0x8f, 0x05, 0xff, 0x0e, 0xff, 0x0e, 0xef, 0x0c, 0xdb, 0x0f ; B5D0
	.db 0xba, 0x0f, 0xef, 0x0b, 0xff, 0x0c, 0x9f, 0x08, 0xff, 0x09, 0xff, 0x0b, 0x8e, 0x07, 0xff, 0x0f ; B5E0
	.db 0xff, 0x0c, 0x9e, 0x08, 0x9e, 0x08, 0x9e, 0x08, 0xff, 0x0f, 0xef, 0x0c, 0xef, 0x0b, 0xda, 0x0f ; B5F0
	.db 0xcb, 0x0f, 0xdf, 0x08, 0xff, 0x08, 0x9e, 0x07, 0x8f, 0x06, 0xff, 0x07, 0xff, 0x0f, 0xff, 0x0b ; B600
	.db 0xef, 0x0a, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0e, 0xef, 0x0b, 0xcf, 0x0a, 0xdb, 0x0f ; B610
	.db 0xdb, 0x0f, 0xff, 0x0f, 0x9f, 0x06, 0xff, 0x0c, 0xff, 0x0e, 0x9f, 0x06, 0xff, 0x0b, 0xff, 0x0e ; B620
	.db 0x9f, 0x06, 0xef, 0x0a, 0xff, 0x0d, 0xff, 0x0a, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xdc, 0x0f ; B630
	.db 0xba, 0x0f, 0xff, 0x0c, 0xff, 0x0f, 0xff, 0x0b, 0xff, 0x0f, 0xff, 0x0f, 0xcf, 0x0a, 0xbf, 0x08 ; B640
	.db 0xff, 0x0f, 0xbf, 0x08, 0xbf, 0x08, 0xbf, 0x08, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0d, 0xed, 0x0f ; B650
	.db 0xdc, 0x0f, 0xff, 0x0d, 0xff, 0x0f, 0xcf, 0x0b, 0xff, 0x0c, 0xff, 0x0e, 0xcf, 0x0a, 0xff, 0x0f ; B660
	.db 0xff, 0x0f, 0xcf, 0x0a, 0xcf, 0x0a, 0xcf, 0x0a, 0xff, 0x0f, 0xff, 0x0d, 0xff, 0x0d, 0xed, 0x0f ; B670
	.db 0xed, 0x0f, 0xff, 0x0b, 0xff, 0x0d, 0xcf, 0x0a, 0xcf, 0x0a, 0xff, 0x0b, 0xff, 0x0f, 0xff, 0x0d ; B680
	.db 0xff, 0x0d, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0d, 0xff, 0x0d, 0xed, 0x0f ; B690
	.db 0xed, 0x0f, 0xff, 0x0f, 0xcf, 0x0b, 0xff, 0x0f, 0xff, 0x0e, 0xcf, 0x0b, 0xff, 0x0e, 0xff, 0x0e ; B6A0
	.db 0xcf, 0x0b, 0xff, 0x0c, 0xff, 0x0f, 0xff, 0x0d, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xfe, 0x0f ; B6B0
	.db 0xfd, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xdf, 0x0c, 0xdf, 0x0c ; B6C0
	.db 0xff, 0x0f, 0xdf, 0x0c, 0xdf, 0x0c, 0xdf, 0x0c, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f ; B6D0
	.db 0xfd, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xef, 0x0d, 0xff, 0x0f, 0xff, 0x0f, 0xef, 0x0d, 0xff, 0x0f ; B6E0
	.db 0xff, 0x0f, 0xef, 0x0d, 0xef, 0x0d, 0xef, 0x0d, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f ; B6F0
	.db 0xfe, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xef, 0x0d, 0xef, 0x0d, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f ; B700
	.db 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f ; B710
	.db 0xff, 0x0f, 0xff, 0x0f, 0xef, 0x0e, 0xff, 0x0f, 0xff, 0x0f, 0xef, 0x0e, 0xef, 0x0e, 0xef, 0x0e ; B720
	.db 0xef, 0x0e, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f ; B730
	.db 0xff, 0x0f, 0xff, 0x0f, 0xef, 0x0e, 0xff, 0x0f, 0xff, 0x0f, 0xef, 0x0e, 0xef, 0x0e, 0xef, 0x0e ; B740
	.db 0xff, 0x0f, 0xef, 0x0e, 0xef, 0x0e, 0xef, 0x0e, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f ; B750
	.db 0xff, 0x0f, 0xff, 0x0f, 0xef, 0x0e, 0xff, 0x0e, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0e, 0xff, 0x0f ; B760
	.db 0xff, 0x0f, 0xef, 0x0e, 0xef, 0x0e, 0xff, 0x0e, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f ; B770
	.db 0xff, 0x0f, 0xff, 0x0f, 0xef, 0x0e, 0xff, 0x0e, 0xff, 0x0e, 0xff, 0x0f, 0xff, 0x0e, 0xff, 0x0f ; B780
	.db 0xff, 0x0f, 0xef, 0x0e, 0xef, 0x0e, 0xff, 0x0e, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f ; B790
	.db 0xff, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; B7A0
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; B7B0
	.db 0x00, 0x00, 0x21, 0x0f, 0xc8, 0x0f, 0x00, 0x01, 0x00, 0x07, 0x32, 0x06, 0x70, 0x01, 0x30, 0x00 ; B7C0
	.db 0x8f, 0x03, 0x1f, 0x00, 0xc1, 0x05, 0x03, 0x00, 0x5f, 0x06, 0x22, 0x03, 0x75, 0x0f, 0x4e, 0x00 ; B7D0
	.db 0x8e, 0x04, 0x21, 0x0f, 0xef, 0x03, 0xff, 0x0b, 0xef, 0x0a, 0x8f, 0x03, 0x7e, 0x01, 0x8d, 0x06 ; B7E0
	.db 0xff, 0x0b, 0xbb, 0x05, 0x03, 0x00, 0x03, 0x00, 0xbf, 0x02, 0x9f, 0x03, 0xff, 0x0a, 0x9f, 0x02 ; B7F0
	.db 0xdf, 0x04, 0x00, 0x00, 0xff, 0x0f, 0xdd, 0x0d, 0x66, 0x06, 0xaa, 0x0a, 0xff, 0x0f, 0xaa, 0x0a ; B800
	.db 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0xff, 0x0f, 0x22, 0x02, 0x66, 0x06, 0x88, 0x08 ; B810
	.db 0xbb, 0x0b, 0xff, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x88, 0x08, 0x22, 0x02, 0x00, 0x00, 0x44, 0x04 ; B820
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x0f, 0x66, 0x06, 0x33, 0x03 ; B830
	.db 0x00, 0x00                  ; B840

;; ---------------------------------------------------------------- $0B842
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B02_B842
sub_b02_B842::
	ld hl,(scene_id)                ; B842
	ld h,#0x00                      ; B845
	add hl,hl                       ; B847
	ld a,(flow_C1B6)                 ; B848
	bit 7,a                         ; B84B
	jr z,loc_b02_B850               ; B84D
	inc hl                          ; B84F
loc_b02_B850:
	ld de,#data_b02_B859            ; B850
	add hl,de                       ; B853
	ld a,(hl)                       ; B854
	ld (player_CF03),a                 ; B855
	ret                             ; B858
data_b02_B859:
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; B859
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfe, 0xfd, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; B860
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0xfd, 0xfc, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; B870
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; B880
	.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; B890
	.db 0x00, 0xfd, 0xfd, 0xff, 0xfe, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfd, 0xfd, 0x00, 0x00, 0xfe ; B8A0
	.db 0xfd, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfe, 0xfd, 0xfd ; B8B0
	.db 0xfc, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff ; B8C0
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
