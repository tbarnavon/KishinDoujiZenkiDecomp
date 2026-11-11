;; screens/debug_menu.s
;; Menu cache (banque 23, combinaison $B4) : choix du niveau et des options de depart.
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $5D637
;; classement : menu cache (combinaison $B4), appele par la tache 0
	.area _B23_9637
sub_b23_9637:
	ld bc,#0x001e                   ; 9637
	ld hl,#0x9632                   ; 963A
loc_b23_963D:
	call sub_005B                   ; 963D
	ld a,(joypad_pressed)           ; 9640
	or a                            ; 9643
	jr z,loc_b23_9655               ; 9644
	cp (hl)                         ; 9646
	jr nz,loc_b23_965A              ; 9647
	inc hl                          ; 9649
	ld a,(hl)                       ; 964A
	cp #0xff                        ; 964B
	jr nz,loc_b23_9652              ; 964D
	or #0xff                        ; 964F
	ret                             ; 9651
loc_b23_9652:
	ld bc,#0x001e                   ; 9652
loc_b23_9655:
	dec bc                          ; 9655
loc_b23_9656::
	ld a,c                          ; 9656
	or b                            ; 9657
	jr nz,loc_b23_963D              ; 9658
loc_b23_965A:
	xor a                           ; 965A
	ret                             ; 965B
.if VERSION_SMS_EN
data_b23_965C:
	.db 0x50, 0x0f, 0xff, 0x0f      ; 965C
.else ; VERSION_GG_JP
data_b23_965C:
	.db 0x88, 0x08, 0xff, 0x0f      ; 965C
.endif
	.db 0x00, 0x00, 0xcf, 0x00, 0xaf, 0x08, 0x6b, 0x03, 0x08, 0x00, 0x0f, 0x00, 0x7f, 0x0c, 0x05, 0x09 ; 9660
	.db 0x63, 0x0f, 0xb7, 0x0f, 0x90, 0x03, 0x7f, 0x00, 0x0f, 0x05, 0x00, 0x00 ; 9670

;; ---------------------------------------------------------------- $5D67C
;; classement : menu cache (combinaison $B4), appele par la tache 0
	.area _B23_967C
sub_b23_967C::
	call sub_b23_9637               ; 967C
	ret z                           ; 967F
	ld a,#0x01                      ; 9680
	ld (game_mode),a                ; 9682
.if VERSION_SMS_EN
	call sound_init                 ; 9685
.else ; VERSION_GG_JP
	call sub_006E                   ; 9685
.endif
	call sub_004D                   ; 9688
.if VERSION_SMS_EN
	call sub_0A33                   ; 968B
.else ; VERSION_GG_JP
	call sub_006B                   ; 968B
.endif
	ld hl,#data_b23_AAA1            ; 968E
	ld de,#data_780C                ; 9691
	ld bc,#0x1214                   ; 9694
	ld a,#0x11                      ; 9697
	ld (player_C0B1),a                 ; 9699
	call sub_003E                   ; 969C
	ld hl,#data_b23_965C            ; 969F
	ld de,#pal_C05A                 ; 96A2
	ld bc,#0x0020                   ; 96A5
	ldir                            ; 96A8
	ld hl,#data_b23_965C            ; 96AA
	ld de,#event_C07A                 ; 96AD
	ld bc,#0x0020                   ; 96B0
	ldir                            ; 96B3
	call sub_b23_9772               ; 96B5
	call sub_b23_97B4               ; 96B8
	call sub_b23_9852               ; 96BB
	xor a                           ; 96BE
	ld (dbg_C0D4),a                 ; 96BF
	call sub_b23_9905               ; 96C2
	call sub_b23_98B0               ; 96C5
	call sub_b23_98ED               ; 96C8
	call sub_0050                   ; 96CB
	ld a,#0x01                      ; 96CE
	call sub_0031                   ; 96D0
	call sub_005E                   ; 96D3
	call sub_0061                   ; 96D6
	xor a                           ; 96D9
	ld (tmp_d3),a                   ; 96DA
loc_b23_96DD:
	call sub_005B                   ; 96DD
	ld a,(joypad_pressed)           ; 96E0
	bit 7,a                         ; 96E3
	jr nz,loc_b23_96F6              ; 96E5
	and #0x03                       ; 96E7
	call nz,sub_b23_991D            ; 96E9
	ld a,(joypad_pressed)           ; 96EC
	and #0x3c                       ; 96EF
	call nz,sub_b23_9702            ; 96F1
	jr loc_b23_96DD                 ; 96F4
loc_b23_96F6:
	call sub_0071                   ; 96F6
	ld a,#0x01                      ; 96F9
	call sub_0034                   ; 96FB
	call sub_0061                   ; 96FE
	ret                             ; 9701

;; ---------------------------------------------------------------- $5D702
;; classement : menu cache (combinaison $B4), appele par la tache 0
	.area _B23_9702
sub_b23_9702:
	ld hl,(tmp_d3)                  ; 9702
	ld h,#0x00                      ; 9705
	ld de,#jt_b23_970D              ; 9707
.if VERSION_SMS_EN
	jp util_jump_table              ; 970A
jt_b23_970D:
	.dw sub_b23_9752                ; 970D
	.dw sub_b23_9788                ; 970F
	.dw sub_b23_97CC                ; 9711
	.dw loc_b23_9719                ; 9713
	.dw sub_b23_988B                ; 9715
	.dw sub_b23_98C8                ; 9717
.else ; VERSION_GG_JP
	jp loc_0068                     ; 970A
jt_b23_970D:
	.db 0x52, 0x97, 0x88            ; 970D
	.db 0x97, 0xcc                  ; 9710
sub_b23_9712:
	sub a                           ; 9712
	add hl,de                       ; 9713
	sub a                           ; 9714
	adc a,e                         ; 9715
	sbc a,b                         ; 9716
	ret z                           ; 9717
	sbc a,b                         ; 9718
.endif
loc_b23_9719:
	bit 3,a                         ; 9719
	jr z,loc_b23_9728               ; 971B
	ld a,(dbg_C0D4)                 ; 971D
	inc a                           ; 9720
	cp #0x46                        ; 9721
	jr c,loc_b23_973B               ; 9723
	xor a                           ; 9725
	jr loc_b23_973B                 ; 9726
loc_b23_9728:
	bit 2,a                         ; 9728
	jr z,loc_b23_9738               ; 972A
	ld a,(dbg_C0D4)                 ; 972C
	dec a                           ; 972F
	cp #0xff                        ; 9730
	jr nz,loc_b23_973B              ; 9732
	ld a,#0x45                      ; 9734
	jr loc_b23_973B                 ; 9736
loc_b23_9738:
	ld a,(dbg_C0D4)                 ; 9738
loc_b23_973B:
	ld (dbg_C0D4),a                 ; 973B
.if VERSION_SMS_EN
	call sound_init                 ; 973E
.else ; VERSION_GG_JP
	call sub_006E                   ; 973E
.endif
	call sub_b23_9905               ; 9741
	ld hl,(dbg_C0D4)                ; 9744
	ld h,#0x00                      ; 9747
	ld de,#data_b23_A2F7            ; 9749
	add hl,de                       ; 974C
	ld a,(hl)                       ; 974D
	ld (snd_queue_0),a              ; 974E
	ret                             ; 9751
sub_b23_9752:
	and #0x30                       ; 9752
	ret z                           ; 9754
	bit 4,a                         ; 9755
	ld a,(lives_or_c005)            ; 9757
	jr z,loc_b23_9760               ; 975A
	inc a                           ; 975C
	daa                             ; 975D
	jr loc_b23_976B                 ; 975E
loc_b23_9760:
	or a                            ; 9760
	jr z,loc_b23_9767               ; 9761
	dec a                           ; 9763
	daa                             ; 9764
	jr loc_b23_976B                 ; 9765
loc_b23_9767:
	ld a,#0x99                      ; 9767
	jr loc_b23_976B                 ; 9769
loc_b23_976B:
	ld (lives_or_c005),a            ; 976B
	call sub_b23_9772               ; 976E
	ret                             ; 9771

;; ---------------------------------------------------------------- $5D772
;; classement : menu cache (combinaison $B4), appele par la tache 0
	.area _B23_9772
sub_b23_9772:
	ld a,(lives_or_c005)            ; 9772
	ld de,#util_D4D1                 ; 9775
	call sub_b23_AC09               ; 9778
	ld hl,#util_D4D1                 ; 977B
	ld bc,#0x0102                   ; 977E
	ld de,#0x796c                   ; 9781
	call sub_003B                   ; 9784
	ret                             ; 9787
sub_b23_9788:
	and #0x30                       ; 9788
	ret z                           ; 978A
	bit 4,a                         ; 978B
	ld a,(start_stage)              ; 978D
	jr z,loc_b23_979C               ; 9790
	cp #0x0f                        ; 9792
	jr c,loc_b23_9799               ; 9794
	xor a                           ; 9796
	jr loc_b23_97A6                 ; 9797
loc_b23_9799:
	inc a                           ; 9799
	jr loc_b23_97A6                 ; 979A
loc_b23_979C:
	or a                            ; 979C
	jr z,loc_b23_97A2               ; 979D
	dec a                           ; 979F
	jr loc_b23_97A6                 ; 97A0
loc_b23_97A2:
	ld a,#0x0f                      ; 97A2
	jr loc_b23_97A6                 ; 97A4
loc_b23_97A6:
	ld (start_stage),a              ; 97A6
	call sub_b23_97B4               ; 97A9
	xor a                           ; 97AC
	ld (dbg_C004),a                 ; 97AD
	call sub_b23_9852               ; 97B0
	ret                             ; 97B3

;; ---------------------------------------------------------------- $5D7B4
;; classement : menu cache (combinaison $B4), appele par la tache 0
	.area _B23_97B4
sub_b23_97B4:
	ld a,(start_stage)              ; 97B4
	ld de,#data_b23_A941            ; 97B7
	call sub_b23_9951               ; 97BA
	ld de,#data_799C                ; 97BD
	ld bc,#0x020a                   ; 97C0
	ld a,#0x11                      ; 97C3
	ld (player_C0B1),a                 ; 97C5
	call sub_003E                   ; 97C8
	ret                             ; 97CB
sub_b23_97CC:
	and #0x30                       ; 97CC
	ret z                           ; 97CE
	bit 4,a                         ; 97CF
	ld a,(dbg_C004)                 ; 97D1
	jr z,loc_b23_97DB               ; 97D4
	call sub_b23_97E5               ; 97D6
	jr loc_b23_97DE                 ; 97D9
loc_b23_97DB:
	call sub_b23_9814               ; 97DB
loc_b23_97DE:
	ld (dbg_C004),a                 ; 97DE
	call sub_b23_9852               ; 97E1
	ret                             ; 97E4

;; ---------------------------------------------------------------- $5D7E5
;; classement : menu cache (combinaison $B4), appele par la tache 0
	.area _B23_97E5
sub_b23_97E5:
	ld a,(start_stage)              ; 97E5
	cp #0x0f                        ; 97E8
	ld b,#0x00                      ; 97EA
	jr z,loc_b23_980F               ; 97EC
	ld hl,(start_stage)             ; 97EE
	ld h,#0x00                      ; 97F1
	inc hl                          ; 97F3
	add hl,hl                       ; 97F4
	ld de,#data_b23_AC33            ; 97F5
	add hl,de                       ; 97F8
	ld e,(hl)                       ; 97F9
	inc hl                          ; 97FA
	ld d,(hl)                       ; 97FB
	ld a,(dbg_C004)                 ; 97FC
	inc a                           ; 97FF
	ld b,a                          ; 9800
	add a,a                         ; 9801
	ld l,a                          ; 9802
	ld h,#0x00                      ; 9803
	add hl,de                       ; 9805
	ld a,(hl)                       ; 9806
	cp #0xff                        ; 9807
	jr nz,loc_b23_980F              ; 9809
	ld b,#0x00                      ; 980B
	jr loc_b23_980F                 ; 980D
loc_b23_980F:
	ld a,b                          ; 980F
	ld (dbg_C004),a                 ; 9810
	ret                             ; 9813

;; ---------------------------------------------------------------- $5D814
;; classement : menu cache (combinaison $B4), appele par la tache 0
	.area _B23_9814
sub_b23_9814:
	ld a,(start_stage)              ; 9814
	cp #0x0f                        ; 9817
	jr nz,loc_b23_9820              ; 9819
	xor a                           ; 981B
	ld (dbg_C004),a                 ; 981C
	ret                             ; 981F
loc_b23_9820:
	ld a,(dbg_C004)                 ; 9820
	or a                            ; 9823
	jr z,loc_b23_982B               ; 9824
	dec a                           ; 9826
	ld (dbg_C004),a                 ; 9827
	ret                             ; 982A
loc_b23_982B:
	ld hl,(start_stage)             ; 982B
	ld h,#0x00                      ; 982E
	inc hl                          ; 9830
	add hl,hl                       ; 9831
	ld de,#data_b23_AC33            ; 9832
	add hl,de                       ; 9835
	ld e,(hl)                       ; 9836
	inc hl                          ; 9837
	ld d,(hl)                       ; 9838
	ex de,hl                        ; 9839
	ld b,#0xff                      ; 983A
loc_b23_983C:
	ld a,(hl)                       ; 983C
	cp #0xff                        ; 983D
	jr z,loc_b23_9846               ; 983F
	inc b                           ; 9841
	inc hl                          ; 9842
	inc hl                          ; 9843
	jr loc_b23_983C                 ; 9844
loc_b23_9846:
	ld a,b                          ; 9846
	ld (dbg_C004),a                 ; 9847
	cp #0xff                        ; 984A
	ret nz                          ; 984C
	xor a                           ; 984D
	ld (dbg_C004),a                 ; 984E
	ret                             ; 9851

;; ---------------------------------------------------------------- $5D852
;; classement : menu cache (combinaison $B4), appele par la tache 0
	.area _B23_9852
sub_b23_9852:
	ld hl,(start_stage)             ; 9852
	ld h,#0x00                      ; 9855
	inc hl                          ; 9857
	add hl,hl                       ; 9858
	ld de,#data_b23_AC33            ; 9859
	add hl,de                       ; 985C
	ld e,(hl)                       ; 985D
	inc hl                          ; 985E
	ld d,(hl)                       ; 985F
	ld a,(dbg_C004)                 ; 9860
	add a,a                         ; 9863
	ld l,a                          ; 9864
	ld h,#0x00                      ; 9865
	add hl,de                       ; 9867
	ld a,(hl)                       ; 9868
	inc hl                          ; 9869
	push hl                         ; 986A
	dec a                           ; 986B
	add a,a                         ; 986C
	ld l,a                          ; 986D
	ld h,#0x00                      ; 986E
	ld de,#data_b23_9A21            ; 9870
	add hl,de                       ; 9873
	ld e,(hl)                       ; 9874
	inc hl                          ; 9875
	ld d,(hl)                       ; 9876
	pop hl                          ; 9877
	ld a,(hl)                       ; 9878
	call sub_b23_9951               ; 9879
	ld de,#data_7A1C                ; 987C
	ld bc,#0x020a                   ; 987F
	ld a,#0x11                      ; 9882
	ld (player_C0B1),a                 ; 9884
	call sub_003E                   ; 9887
	ret                             ; 988A
sub_b23_988B:
	and #0x30                       ; 988B
	ret z                           ; 988D
	bit 4,a                         ; 988E
	ld a,(start_mode)               ; 9890
	jr z,loc_b23_989F               ; 9893
	cp #0x08                        ; 9895
	jr c,loc_b23_989C               ; 9897
	xor a                           ; 9899
	jr loc_b23_98A9                 ; 989A
loc_b23_989C:
	inc a                           ; 989C
	jr loc_b23_98A9                 ; 989D
loc_b23_989F:
	or a                            ; 989F
	jr z,loc_b23_98A5               ; 98A0
	dec a                           ; 98A2
	jr loc_b23_98A9                 ; 98A3
loc_b23_98A5:
	ld a,#0x08                      ; 98A5
	jr loc_b23_98A9                 ; 98A7
loc_b23_98A9:
	ld (start_mode),a               ; 98A9
	call sub_b23_98B0               ; 98AC
	ret                             ; 98AF

;; ---------------------------------------------------------------- $5D8B0
;; classement : menu cache (combinaison $B4), appele par la tache 0
	.area _B23_98B0
sub_b23_98B0:
	ld a,(start_mode)               ; 98B0
	ld de,#data_b23_995B            ; 98B3
	call sub_b23_9951               ; 98B6
	ld de,#0x7b1c                   ; 98B9
	ld bc,#0x020a                   ; 98BC
	ld a,#0x11                      ; 98BF
	ld (player_C0B1),a                 ; 98C1
	call sub_003E                   ; 98C4
	ret                             ; 98C7
sub_b23_98C8:
	and #0x30                       ; 98C8
	ret z                           ; 98CA
	bit 4,a                         ; 98CB
	ld a,(start_power)              ; 98CD
	jr z,loc_b23_98DC               ; 98D0
	cp #0x06                        ; 98D2
	jr c,loc_b23_98D9               ; 98D4
	xor a                           ; 98D6
	jr loc_b23_98E6                 ; 98D7
loc_b23_98D9:
	inc a                           ; 98D9
	jr loc_b23_98E6                 ; 98DA
loc_b23_98DC:
	or a                            ; 98DC
	jr z,loc_b23_98E2               ; 98DD
	dec a                           ; 98DF
	jr loc_b23_98E6                 ; 98E0
loc_b23_98E2:
	ld a,#0x06                      ; 98E2
	jr loc_b23_98E6                 ; 98E4
loc_b23_98E6:
	ld (start_power),a              ; 98E6
	call sub_b23_98ED               ; 98E9
	ret                             ; 98EC

;; ---------------------------------------------------------------- $5D8ED
;; classement : menu cache (combinaison $B4), appele par la tache 0
	.area _B23_98ED
sub_b23_98ED:
	ld a,(start_power)              ; 98ED
	ld de,#data_b23_A25D            ; 98F0
	call sub_b23_9951               ; 98F3
	ld de,#data_7B9C                ; 98F6
	ld bc,#0x020a                   ; 98F9
	ld a,#0x11                      ; 98FC
	ld (player_C0B1),a                 ; 98FE
	call sub_003E                   ; 9901
	ret                             ; 9904

;; ---------------------------------------------------------------- $5D905
;; classement : menu cache (combinaison $B4), appele par la tache 0
	.area _B23_9905
sub_b23_9905:
	ld a,(dbg_C0D4)                 ; 9905
	ld de,#data_b23_A33D            ; 9908
	call sub_b23_9951               ; 990B
	ld de,#data_7A9C                ; 990E
	ld bc,#0x020a                   ; 9911
	ld a,#0x11                      ; 9914
	ld (player_C0B1),a                 ; 9916
	call sub_003E                   ; 9919
	ret                             ; 991C

;; ---------------------------------------------------------------- $5D91D
;; classement : menu cache (combinaison $B4), appele par la tache 0
	.area _B23_991D
sub_b23_991D:
	bit 0,a                         ; 991D
	ld a,(tmp_d3)                   ; 991F
	jr z,loc_b23_992D               ; 9922
	dec a                           ; 9924
	cp #0xff                        ; 9925
	jr nz,loc_b23_9935              ; 9927
	ld a,#0x05                      ; 9929
	jr loc_b23_9935                 ; 992B
loc_b23_992D:
	inc a                           ; 992D
	cp #0x06                        ; 992E
	jr c,loc_b23_9935               ; 9930
	xor a                           ; 9932
	jr loc_b23_9935                 ; 9933
loc_b23_9935:
	ld (tmp_d3),a                   ; 9935
	call sub_b23_993C               ; 9938
	ret                             ; 993B

;; ---------------------------------------------------------------- $5D93C
;; classement : menu cache (combinaison $B4), appele par la tache 0
	.area _B23_993C
sub_b23_993C:
	ld de,#data_b23_A23B            ; 993C
	call sub_b23_9951               ; 993F
	ld de,#data_794E                ; 9942
	ld bc,#0x0c01                   ; 9945
	ld a,#0x11                      ; 9948
	ld (player_C0B1),a                 ; 994A
	call sub_003E                   ; 994D
	ret                             ; 9950

;; ---------------------------------------------------------------- $5D951
;; classement : menu cache (combinaison $B4), appele par la tache 0
	.area _B23_9951
sub_b23_9951:
	ld l,a                          ; 9951
	ld h,#0x00                      ; 9952
	add hl,hl                       ; 9954
	add hl,de                       ; 9955
	ld e,(hl)                       ; 9956
	inc hl                          ; 9957
	ld d,(hl)                       ; 9958
	ex de,hl                        ; 9959
	ret                             ; 995A
data_b23_995B:
	.db 0x6d, 0x99, 0x81, 0x99, 0x95 ; 995B
	.db 0x99, 0xa9, 0x99, 0xbd, 0x99, 0xd1, 0x99, 0xe5, 0x99, 0x0d, 0x9a, 0xf9, 0x99, 0x1f, 0x1f, 0x1f ; 9960
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xa9, 0x90, 0xaf ; 9970
	.db 0xb9, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9980
	.db 0x3f, 0x32, 0x1f, 0xa1, 0xab, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9990
	.db 0x1f, 0x1f, 0x1f, 0x3f, 0x32, 0x1f, 0xa1, 0x91, 0x97, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f ; 99A0
	.db 0x1f, 0x1f, 0x1f, 0x61, 0x80, 0x5a, 0x1f, 0x9c, 0xae, 0x93, 0xa1, 0x8d, 0x93, 0x1f, 0xbe, 0x1f ; 99B0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x5d, 0x5a, 0x1f, 0xae, 0x93, 0xb3, 0xbd, 0x9d ; 99C0
	.db 0xb0, 0xbe, 0x1f, 0x1f, 0x1f, 0xbf, 0x1f, 0x1f, 0x1f, 0x1f, 0xbf, 0x61, 0x80, 0x5a, 0x1f, 0x6d ; 99D0
	.db 0x7f, 0x2e, 0x54, 0x53, 0x6f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f ; 99E0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xab, 0xa9, 0xac, 0xa0, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 99F0
	.db 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0xab, 0x96, 0xb8, 0xa9, 0xac, 0xa0, 0x1f, 0x1f, 0x1f ; 9A00
	.db 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x96, 0x9e, 0xa9, 0xac ; 9A10
	.db 0xa0                        ; 9A20
data_b23_9A21:
	.db 0x29, 0x9a, 0x2b, 0x9d, 0x2b, 0x9d, 0x2b, 0x9d, 0x6f, 0x9a, 0x83, 0x9a, 0x97, 0x9a, 0xab ; 9A21
	.db 0x9a, 0xbf, 0x9a, 0xd3, 0x9a, 0xe7, 0x9a, 0xfb, 0x9a, 0x0f, 0x9b, 0x23, 0x9b, 0x37, 0x9b, 0x4b ; 9A30
	.db 0x9b, 0x5f, 0x9b, 0x73, 0x9b, 0x87, 0x9b, 0x9b, 0x9b, 0xaf, 0x9b, 0xc3, 0x9b, 0xd7, 0x9b, 0xeb ; 9A40
	.db 0x9b, 0xff, 0x9b, 0x13, 0x9c, 0x27, 0x9c, 0x3b, 0x9c, 0x4f, 0x9c, 0x63, 0x9c, 0x77, 0x9c, 0x8b ; 9A50
	.db 0x9c, 0x9f, 0x9c, 0xb3, 0x9c, 0xc7, 0x9c, 0xdb, 0x9c, 0xef, 0x9c, 0x03, 0x9d, 0x17, 0x9d, 0x1f ; 9A60
	.db 0x1f, 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x45, 0x1f, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54 ; 9A70
	.db 0x7c, 0x1f, 0x20, 0x1f, 0x1f, 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x45, 0x1f, 0x1f, 0x1f ; 9A80
	.db 0x6e, 0x5f, 0x51, 0x54, 0x7c, 0x1f, 0x21, 0x1f, 0x1f, 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f ; 9A90
	.db 0x45, 0x1f, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54, 0x7c, 0x1f, 0x22, 0x1f, 0x1f, 0x1f, 0xbe, 0xbe ; 9AA0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x45, 0x1f, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54, 0x7c, 0x1f, 0x23, 0x1f ; 9AB0
	.db 0x1f, 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x45, 0x1f, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54 ; 9AC0
	.db 0x7c, 0x1f, 0x24, 0x1f, 0x1f, 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x45, 0x1f, 0x1f, 0x1f ; 9AD0
	.db 0x6e, 0x5f, 0x51, 0x54, 0x7c, 0x1f, 0x25, 0x1f, 0x1f, 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f ; 9AE0
	.db 0x45, 0x1f, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54, 0x7c, 0x1f, 0x26, 0x1f, 0x1f, 0x1f, 0xbe, 0xbe ; 9AF0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x45, 0x1f, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54, 0x7c, 0x1f, 0x27, 0x1f ; 9B00
	.db 0x1f, 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x45, 0x1f, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54 ; 9B10
	.db 0x7c, 0x1f, 0x28, 0x1f, 0x1f, 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x45, 0x1f, 0x1f, 0x1f ; 9B20
	.db 0x6e, 0x5f, 0x51, 0x54, 0x7c, 0x1f, 0x29, 0x1f, 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9B30
	.db 0x45, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54, 0x7c, 0x1f, 0x21, 0x20, 0x1f, 0x1f, 0xbe, 0xbe, 0x1f ; 9B40
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x45, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54, 0x7c, 0x1f, 0x21, 0x21, 0x1f ; 9B50
	.db 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x45, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54, 0x7c ; 9B60
	.db 0x1f, 0x21, 0x22, 0x1f, 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x45, 0x1f, 0x1f, 0x6e ; 9B70
	.db 0x5f, 0x51, 0x54, 0x7c, 0x1f, 0x21, 0x23, 0x1f, 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9B80
	.db 0x45, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54, 0x7c, 0x1f, 0x21, 0x24, 0x1f, 0x1f, 0xbe, 0xbe, 0x1f ; 9B90
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x45, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54, 0x7c, 0x1f, 0x21, 0x25, 0x1f ; 9BA0
	.db 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x45, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54, 0x7c ; 9BB0
	.db 0x1f, 0x21, 0x26, 0x1f, 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x45, 0x1f, 0x1f, 0x6e ; 9BC0
	.db 0x5f, 0x51, 0x54, 0x7c, 0x1f, 0x21, 0x27, 0x1f, 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9BD0
	.db 0x45, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54, 0x7c, 0x1f, 0x21, 0x28, 0x1f, 0x1f, 0xbe, 0xbe, 0x1f ; 9BE0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x45, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54, 0x7c, 0x1f, 0x21, 0x29, 0x1f ; 9BF0
	.db 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x45, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54, 0x7c ; 9C00
	.db 0x1f, 0x22, 0x20, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x43, 0x1f, 0x1f, 0xb8 ; 9C10
	.db 0x8d, 0x93, 0xae, 0x98, 0xa9, 0xa0, 0x97, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0xbe ; 9C20
	.db 0x43, 0x1f, 0x1f, 0x1f, 0x1f, 0x9b, 0xbd, 0x96, 0x98, 0xa4, 0x93, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9C30
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x43, 0x1f, 0x1f, 0x1f, 0xac, 0x93, 0x92, 0xbd, 0xa9, 0xb3, 0xb8, 0x1f ; 9C40
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x43, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x96, 0x99 ; 9C50
	.db 0x9a, 0x93, 0xb4, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x43, 0x1f, 0x1f, 0x1f ; 9C60
	.db 0x9a, 0x9c, 0x8e, 0x93, 0xa9, 0xaa, 0x9c, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9C70
	.db 0x43, 0x1f, 0x1f, 0x1f, 0xa1, 0xaf, 0xb9, 0xa9, 0xb4, 0x96, 0xa0, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f ; 9C80
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x43, 0x1f, 0x1f, 0x96, 0x99, 0xbb, 0x93, 0x9b, 0x97, 0x8d, 0x93, 0x1f ; 9C90
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x43, 0x1f, 0x1f, 0x1f, 0x1f, 0x9b, 0xbd, 0xb8 ; 9CA0
	.db 0xbd, 0xa4, 0x93, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x43, 0x1f, 0x1f, 0x1f ; 9CB0
	.db 0xac, 0x93, 0x92, 0xbd, 0xa9, 0x9b, 0xa4, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f ; 9CC0
	.db 0x43, 0x1f, 0x1f, 0x1f, 0x96, 0xa2, 0xb7, 0x97, 0xa1, 0x8e, 0x93, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9CD0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x43, 0x1f, 0x1f, 0x1f, 0x1f, 0x95, 0x95, 0xb0, 0xa8, 0xb4, 0xaf, 0x1f ; 9CE0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x43, 0x1f, 0x1f, 0x1f, 0x1f, 0xb8, 0xbd, 0x96 ; 9CF0
	.db 0xbd, 0xa4, 0x93, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x43, 0x1f, 0x1f, 0x1f ; 9D00
	.db 0x96, 0xa2, 0xb7, 0x97, 0xad, 0x92, 0xb4, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9D10
	.db 0x43, 0x1f, 0x92, 0xa7, 0x96, 0xb0, 0xae, 0xbd, 0x97, 0x8e, 0xa1, 0x9f, 0x9d, 0xb3, 0x9d, 0xc7 ; 9D20
	.db 0x9d, 0xdb, 0x9d, 0xef, 0x9d, 0x03, 0x9e, 0x17, 0x9e, 0x2b, 0x9e, 0x3f, 0x9e, 0x53, 0x9e, 0x67 ; 9D30
	.db 0x9e, 0x7b, 0x9e, 0x8f, 0x9e, 0xa3, 0x9e, 0xb7, 0x9e, 0xcb, 0x9e, 0xdf, 0x9e, 0xf3, 0x9e, 0x07 ; 9D40
	.db 0x9f, 0x1b, 0x9f, 0x2f, 0x9f, 0x43, 0x9f, 0x57, 0x9f, 0x6b, 0x9f, 0x7f, 0x9f, 0x93, 0x9f, 0xa7 ; 9D50
	.db 0x9f, 0xbb, 0x9f, 0xcf, 0x9f, 0xe3, 0x9f, 0xf7, 0x9f, 0x0b, 0xa0, 0x1f, 0xa0, 0x33, 0xa0, 0x47 ; 9D60
	.db 0xa0, 0x5b, 0xa0, 0x6f, 0xa0, 0x83, 0xa0, 0x97, 0xa0, 0xab, 0xa0, 0xbf, 0xa0, 0xd3, 0xa0, 0xe7 ; 9D70
	.db 0xa0, 0xfb, 0xa0, 0x0f, 0xa1, 0x23, 0xa1, 0x37, 0xa1, 0x4b, 0xa1, 0x5f, 0xa1, 0x73, 0xa1, 0x87 ; 9D80
	.db 0xa1, 0x9b, 0xa1, 0xaf, 0xa1, 0xc3, 0xa1, 0xd7, 0xa1, 0xeb, 0xa1, 0xff, 0xa1, 0x13, 0xa2, 0x1f ; 9D90
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f, 0xa0, 0x97, 0xa4, 0x92 ; 9DA0
	.db 0xbc, 0x1f, 0x30, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f ; 9DB0
	.db 0xa0, 0x97, 0xa4, 0x92, 0xbc, 0x1f, 0x31, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9DC0
	.db 0x42, 0x1f, 0x1f, 0x1f, 0xa0, 0x97, 0xa4, 0x92, 0xbc, 0x1f, 0x32, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9DD0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f, 0xa0, 0x97, 0xa4, 0x92, 0xbc, 0x1f, 0x33, 0x1f ; 9DE0
	.db 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0xa1, 0x96, 0xa4, 0x93, 0x98, 0xa2 ; 9DF0
	.db 0x21, 0x1f, 0x30, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0xa1, 0x96 ; 9E00
	.db 0xa4, 0x93, 0x98, 0xa2, 0x21, 0x1f, 0x31, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9E10
	.db 0x42, 0x1f, 0xa1, 0x96, 0xa4, 0x93, 0x98, 0xa2, 0x21, 0x1f, 0x32, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9E20
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x31, 0x1f, 0x1f, 0x1f, 0x9b, 0x92, 0xbb, 0x93, 0x9b, 0x92, 0x9a, 0x1f ; 9E30
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f, 0x98, 0xb3, 0xa4, 0xaa ; 9E40
	.db 0x9c, 0x1f, 0x30, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f ; 9E50
	.db 0x98, 0xb3, 0xa4, 0xaa, 0x9c, 0x1f, 0x31, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9E60
	.db 0x42, 0x1f, 0x1f, 0x1f, 0x98, 0xb3, 0xa4, 0xaa, 0x9c, 0x1f, 0x32, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9E70
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f, 0x98, 0xb3, 0xa4, 0xaa, 0x9c, 0x1f, 0x33, 0x1f ; 9E80
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f, 0x98, 0xb3, 0xa4, 0xaa ; 9E90
	.db 0x9c, 0x1f, 0x34, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f ; 9EA0
	.db 0x1f, 0x1f, 0x9a, 0x93, 0xb4, 0x9b, 0xbd, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9EB0
	.db 0x42, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xab, 0x97, 0x1f, 0x1f, 0x1f, 0x1f ; 9EC0
data_b23_9ECF::
	.db 0x1f                        ; 9ECF
	.db 0x1f, 0xbe, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f, 0x1f, 0x92, 0x9c, 0xa0, 0xbd, 0x1f, 0x30, 0x1f ; 9ED0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f, 0x1f, 0x92, 0x9c, 0xa0 ; 9EE0
	.db 0xbd, 0x1f, 0x31, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f ; 9EF0
	.db 0x1f, 0x92, 0x9c, 0xa0, 0xbd, 0x1f, 0x32, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9F00
	.db 0x42, 0x1f, 0x1f, 0x1f, 0xaa, 0x92, 0x9a, 0x93, 0x21, 0x1f, 0x30, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9F10
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f, 0xaa, 0x92, 0x9a, 0x93, 0x21, 0x1f, 0x31, 0x1f ; 9F20
	.db 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x96, 0x99, 0xbb, 0x93, 0x9b, 0x97, 0x8d ; 9F30
	.db 0x93, 0x1f, 0x30, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x96, 0x99, 0xbb ; 9F40
	.db 0x93, 0x9b, 0x97, 0x8d, 0x93, 0x1f, 0x31, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9F50
	.db 0x42, 0x96, 0x99, 0xbb, 0x93, 0x9b, 0x97, 0x8d, 0x93, 0x1f, 0x32, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f ; 9F60
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x96, 0x99, 0xbb, 0x93, 0x9b, 0x97, 0x8d, 0x93, 0x1f, 0x33, 0x1f ; 9F70
	.db 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x96, 0x99, 0xbb, 0x93, 0x9b, 0x97, 0x8d ; 9F80
	.db 0x93, 0x1f, 0x34, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x96, 0x99, 0xbb ; 9F90
	.db 0x93, 0x9b, 0x97, 0x8d, 0x93, 0x1f, 0x35, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9FA0
	.db 0x42, 0x96, 0x99, 0xbb, 0x93, 0x9b, 0x97, 0x8d, 0x93, 0x1f, 0x36, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; 9FB0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f, 0xaa, 0x92, 0x9a, 0x93, 0x22, 0x1f, 0x30, 0x1f ; 9FC0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f, 0xaa, 0x92, 0x9a, 0x93 ; 9FD0
	.db 0x22, 0x1f, 0x31, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f ; 9FE0
	.db 0xaa, 0x92, 0x9a, 0x93, 0x22, 0x1f, 0x42, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f ; 9FF0
	.db 0x42, 0x1f, 0x1f, 0x9b, 0xbd, 0xb8, 0xbd, 0xa4, 0x93, 0x1f, 0x30, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A000
	.db 0x1f, 0xbe, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x9b, 0xbd, 0xb8, 0xbd, 0xa4, 0x93, 0x1f, 0x31, 0x1f ; A010
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x9b, 0xbd, 0xb8, 0xbd, 0xa4 ; A020
	.db 0x93, 0x1f, 0x32, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0xa1, 0x96 ; A030
	.db 0xa4, 0x93, 0x98, 0xa2, 0x22, 0x1f, 0x30, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A040
	.db 0x42, 0x1f, 0xac, 0x93, 0x92, 0xbd, 0xa9, 0xb3, 0xb8, 0x1f, 0x30, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A050
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0xac, 0x93, 0x92, 0xbd, 0xa9, 0xb3, 0xb8, 0x1f, 0x31, 0x1f ; A060
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x31, 0xac, 0x93, 0x92, 0xbd, 0xa9, 0xb3, 0xb8 ; A070
	.db 0x1f, 0x71, 0x60, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f ; A080
	.db 0xa1, 0xaf, 0xb9, 0xa9, 0xb4, 0x96, 0xa0, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A090
	.db 0x42, 0x1f, 0xac, 0x93, 0x92, 0xbd, 0xa9, 0x9b, 0xa4, 0x1f, 0x30, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A0A0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0xac, 0x93, 0x92, 0xbd, 0xa9, 0x9b, 0xa4, 0x1f, 0x31, 0x1f ; A0B0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x1f, 0xac, 0x93, 0x92, 0xbd, 0xa9, 0x9b ; A0C0
	.db 0xa4, 0x1f, 0x32, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x31, 0xac, 0x93, 0x92 ; A0D0
	.db 0xbd, 0xa9, 0x9b, 0xa4, 0x1f, 0x71, 0x60, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A0E0
	.db 0x42, 0x96, 0xa2, 0xb7, 0x97, 0xa1, 0x8e, 0x93, 0x1f, 0xad, 0xb8, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A0F0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x31, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x97, 0xb3, 0xbd, 0x1f ; A100
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x31, 0x1f, 0x1f, 0x1f, 0x9c, 0x8e, 0x93, 0xa0 ; A110
	.db 0x92, 0xb6, 0x93, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0xb8 ; A120
	.db 0xbd, 0x96, 0xbd, 0xa4, 0x93, 0x1f, 0x30, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f ; A130
	.db 0x42, 0x1f, 0x1f, 0xb8, 0xbd, 0x96, 0xbd, 0xa4, 0x93, 0x1f, 0x31, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A140
	.db 0x1f, 0xbe, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0xb8, 0xbd, 0x96, 0xbd, 0xa4, 0x93, 0x1f, 0x32, 0x1f ; A150
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0xbe, 0x31, 0x1f, 0xb8, 0xbd, 0x96, 0xbd, 0xa4, 0x93 ; A160
	.db 0x1f, 0x71, 0x60, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x42, 0x1f, 0x1f, 0x1f ; A170
	.db 0x96, 0xa2, 0xb7, 0x97, 0xad, 0x92, 0xb4, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f ; A180
	.db 0x31, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xa4, 0x98, 0xbb, 0x9f, 0x93, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A190
	.db 0xbe, 0x1f, 0x1f, 0x1f, 0x31, 0x1f, 0xa1, 0x8e, 0x93, 0x1f, 0xa4, 0x98, 0xbb, 0x9f, 0x93, 0x1f ; A1A0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x31, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x92 ; A1B0
	.db 0xa7, 0x96, 0xb0, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x31, 0x1f, 0x1f, 0xa1 ; A1C0
	.db 0x8e, 0x93, 0x1f, 0x92, 0xa7, 0x96, 0xb0, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe ; A1D0
	.db 0x31, 0x9b, 0x92, 0x9c, 0x8d, 0x93, 0x1f, 0x92, 0xa7, 0x96, 0xb0, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f ; A1E0
	.db 0x1f, 0x1f, 0xbe, 0x1f, 0x31, 0x1f, 0x1f, 0x1f, 0x61, 0x80, 0x5a, 0x98, 0xa0, 0x99, 0xb9, 0xbe ; A1F0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x31, 0xa4, 0x98, 0xbb, 0x1f, 0xab, 0x8e, 0x93 ; A200
	.db 0x92, 0xa9, 0xb0, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x31, 0x1f, 0x1f, 0x1f ; A210
	.db 0xaf, 0xb5, 0x1f, 0xaa, 0x98, 0xaa, 0xa2, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f ; A220
	.db 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x57, 0x80, 0x66, 0x4c, 0x80, 0x5b ; A230
data_b23_A23B:
	.db 0x51, 0xa2, 0x4f, 0xa2, 0x4d ; A23B
	.db 0xa2, 0x4b, 0xa2, 0x49, 0xa2, 0x47, 0xa2, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A240
	.db 0x1f, 0x81, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A250
data_b23_A25D:
	.db 0x6b, 0xa2, 0xcf            ; A25D
	.db 0xa2, 0xbb, 0xa2, 0x7f, 0xa2, 0xa7, 0xa2, 0x93, 0xa2, 0xe3, 0xa2, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A260
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xa0, 0xaf, 0xa5, 0x9c, 0x1f ; A270
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xa1 ; A280
	.db 0xa9, 0xa0, 0xaf, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A290
	.db 0x1f, 0x1f, 0x96, 0x9e, 0xa9, 0xa0, 0xaf, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f ; A2A0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xb0, 0x9d, 0xa9, 0xa0, 0xaf, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A2B0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x9f, 0xb7, 0xa9, 0xa0, 0xaf, 0x1f ; A2C0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xab ; A2D0
	.db 0xa9, 0xa0, 0xaf, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A2E0
	.db 0x1f, 0x9e, 0xbd, 0xac, 0xa9, 0xa0, 0xaf ; A2F0
data_b23_A2F7:
	.db 0xde, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88 ; A2F7
	.db 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f, 0xde, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98 ; A300
	.db 0x99, 0x9a, 0xde, 0xde, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab ; A310
	.db 0xac, 0xad, 0xae, 0xaf, 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xbb ; A320
	.db 0xbc, 0xbd, 0xbe, 0xbf, 0xc0, 0xc1, 0xc2, 0xc3, 0xc4 ; A330

;; ---------------------------------------------------------------- $5E339
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B23_A339
sub_b23_A339:
	push bc                         ; A339
	add a,#0xe0                     ; A33A
	pop hl                          ; A33C
data_b23_A33D:
	ret                             ; A33D
	.db 0xa3, 0xdd                  ; A33E
	.db 0xa3, 0xf1, 0xa3, 0x05, 0xa4, 0x19, 0xa4, 0x2d, 0xa4, 0x41, 0xa4, 0x55, 0xa4, 0x69, 0xa4, 0x7d ; A340
	.db 0xa4, 0x91, 0xa4, 0xa5, 0xa4, 0xb9, 0xa4, 0xcd ; A350

;; ---------------------------------------------------------------- $5E358
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B23_A358
sub_b23_A358:
	and h                           ; A358
	pop hl                          ; A359
	and h                           ; A35A
loc_b23_A35B::
	push af                         ; A35B
	and h                           ; A35C
	add hl,bc                       ; A35D
	and l                           ; A35E
	dec e                           ; A35F
	and l                           ; A360
	ld sp,#0x45a5                   ; A361
	and l                           ; A364
	ld e,c                          ; A365
	and l                           ; A366
	ld l,l                          ; A367
	and l                           ; A368
	add a,c                         ; A369
	and l                           ; A36A
	sub l                           ; A36B
	and l                           ; A36C
	xor c                           ; A36D
	and l                           ; A36E
	cp l                            ; A36F
	and l                           ; A370
	pop de                          ; A371
	and l                           ; A372
	push hl                         ; A373
	and l                           ; A374
	ld sp,hl                        ; A375
	and l                           ; A376
	dec c                           ; A377
	and (hl)                        ; A378
	ld hl,#data_35A6                ; A379
	and (hl)                        ; A37C
	ld c,c                          ; A37D
	and (hl)                        ; A37E
	ld e,l                          ; A37F
	and (hl)                        ; A380
	ld (hl),c                       ; A381
	and (hl)                        ; A382
	add a,l                         ; A383
	and (hl)                        ; A384
	sbc a,c                         ; A385
	and (hl)                        ; A386
	xor l                           ; A387
	and (hl)                        ; A388
	pop bc                          ; A389
	and (hl)                        ; A38A
	push de                         ; A38B
	and (hl)                        ; A38C
	jp (hl)                         ; A38D
	.db 0xa6, 0xfd                  ; A38E
	.db 0xa6, 0x11, 0xa7, 0x25, 0xa7, 0x39, 0xa7, 0x4d, 0xa7, 0x61, 0xa7, 0x75, 0xa7, 0x89, 0xa7, 0x9d ; A390
	.db 0xa7, 0xb1, 0xa7, 0xc5, 0xa7, 0xd9, 0xa7, 0xed ; A3A0

;; ---------------------------------------------------------------- $5E3A8
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B23_A3A8
sub_b23_A3A8:
	and a                           ; A3A8
	ld bc,#0x15a8                   ; A3A9
	xor b                           ; A3AC
	add hl,hl                       ; A3AD
	xor b                           ; A3AE
	dec a                           ; A3AF
	xor b                           ; A3B0
	ld d,c                          ; A3B1
	xor b                           ; A3B2
	ld h,l                          ; A3B3
	xor b                           ; A3B4
	ld a,c                          ; A3B5
	xor b                           ; A3B6
	adc a,l                         ; A3B7
	xor b                           ; A3B8
	and c                           ; A3B9
	xor b                           ; A3BA
	or l                            ; A3BB
	xor b                           ; A3BC
	ret                             ; A3BD
	.db 0xa8, 0xdd                  ; A3BE
	.db 0xa8, 0xf1, 0xa8, 0x05, 0xa9, 0x19, 0xa9, 0x2d, 0xa9, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A3C0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x3e, 0x35, 0x35, 0x1f, 0x1f, 0x1f ; A3D0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x43, 0x30, 0x36, 0x34, 0x20 ; A3E0
	.db 0x21, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x43 ; A3F0
	.db 0x30, 0x36, 0x34, 0x20, 0x22, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A400
	.db 0x1f, 0x1f, 0x42, 0x43, 0x30, 0x36, 0x34, 0x20, 0x23, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A410
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x43, 0x30, 0x36, 0x34, 0x20, 0x24, 0x1f, 0x1f, 0x1f ; A420
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x42, 0x43, 0x30, 0x36, 0x34, 0x20 ; A430
	.db 0x25, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x31 ; A440
	.db 0x3e, 0x42, 0x42, 0x20, 0x21, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A450
	.db 0x1f, 0x1f, 0x1f, 0x31, 0x3e, 0x42, 0x42, 0x20, 0x22, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A460
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x31, 0x3e, 0x42, 0x42, 0x20, 0x23, 0x1f, 0x1f, 0x1f ; A470
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x31, 0x3e, 0x42, 0x42, 0x20 ; A480
	.db 0x24, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x35, 0x38, 0x3d, 0x30, 0x3b ; A490
	.db 0x1f, 0x31, 0x3e, 0x42, 0x42, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A4A0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0xa4, 0x98, 0xbb, 0x9f, 0x93, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A4B0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x31, 0x3e, 0x42, 0x42, 0x20, 0x27, 0x1f, 0x1f, 0x1f ; A4C0
	.db 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54, 0x7c ; A4D0
	.db 0x21, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x6e ; A4E0
	.db 0x5f, 0x51, 0x54, 0x7c, 0x22, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A4F0
	.db 0x1f, 0x1f, 0x1f, 0x6e, 0x5f, 0x51, 0x54, 0x7c, 0x23, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A500
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x91, 0x97, 0x1f, 0x1f, 0x1f ; A510
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x9c, 0xbd, 0xa0, 0xa4 ; A520
	.db 0x97, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x5c, 0x2e ; A530
	.db 0x74, 0x58, 0x2e, 0x6d, 0x2e, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A540
	.db 0x1f, 0x1f, 0x5d, 0x80, 0x66, 0x4c, 0x69, 0x51, 0x2e, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe ; A550
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x60, 0x66, 0x2e, 0x5f, 0x5b, 0x7b, 0x54, 0x1f, 0x1f, 0x1f ; A560
	.db 0xbf, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x72, 0x53, 0x6f, 0x92, 0xa4, 0x93, 0xa1, 0x8d ; A570
	.db 0x93, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0xbf, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x58 ; A580
	.db 0x2e, 0x6f, 0x69, 0x80, 0x5b, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f ; A590
	.db 0x1f, 0x1f, 0xa4, 0x93, 0x98, 0xa2, 0x5f, 0x2e, 0x80, 0x1f, 0x1f, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f ; A5A0
	.db 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x71, 0x60, 0x1f, 0x5b, 0x7b, 0x54, 0x1f, 0x1f, 0x1f ; A5B0
	.db 0x1f, 0xbe, 0x1f, 0x1f, 0xbe, 0x1f, 0x1f, 0x1f, 0x1f, 0x57, 0x80, 0x66, 0x4c, 0x80, 0x5b, 0x1f ; A5C0

;; ---------------------------------------------------------------- $5E5D0
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B23_A5D0
sub_b23_A5D0:
	ld (0x1f1f),hl                  ; A5D0
	rra                             ; A5D3
	cp (hl)                         ; A5D4
	cp (hl)                         ; A5D5
	rra                             ; A5D6
	rra                             ; A5D7
	rra                             ; A5D8
	rra                             ; A5D9
	rra                             ; A5DA
	rra                             ; A5DB
	rra                             ; A5DC
	rra                             ; A5DD
	ld l,(hl)                       ; A5DE
	ld e,a                          ; A5DF
	ld d,c                          ; A5E0
	ld d,h                          ; A5E1
	ld a,h                          ; A5E2
	rra                             ; A5E3
	inc h                           ; A5E4
	rra                             ; A5E5
	rra                             ; A5E6
	rra                             ; A5E7
	rra                             ; A5E8
	rra                             ; A5E9
	rra                             ; A5EA
	rra                             ; A5EB
	rra                             ; A5EC
	cp (hl)                         ; A5ED
	rra                             ; A5EE
	rra                             ; A5EF
	rra                             ; A5F0
	ld b,d                          ; A5F1
	ld a,#0x3d                      ; A5F2
	ld (hl),#0x1f                   ; A5F4
	or (hl)                         ; A5F6
	xor e                           ; A5F7
	ld hl,#data_1F1F                ; A5F8
	rra                             ; A5FB
	rra                             ; A5FC
	rra                             ; A5FD
	rra                             ; A5FE
	rra                             ; A5FF
	rra                             ; A600
	cp (hl)                         ; A601
	rra                             ; A602
	rra                             ; A603
	rra                             ; A604
	ld b,d                          ; A605
	ld a,#0x3d                      ; A606
	ld (hl),#0x1f                   ; A608
	or (hl)                         ; A60A
	xor e                           ; A60B
	ld (data_1F1F),hl               ; A60C
	rra                             ; A60F
	rra                             ; A610
	cp (hl)                         ; A611
	rra                             ; A612
	rra                             ; A613
	cp a                            ; A614
	rra                             ; A615
	rra                             ; A616
	rra                             ; A617
	rra                             ; A618
	rra                             ; A619
	rra                             ; A61A
	ld e,a                          ; A61B
	ld d,b                          ; A61C
	add a,b                         ; A61D
	ld l,a                          ; A61E
	rra                             ; A61F
	dec sp                          ; A620
	rra                             ; A621
	rra                             ; A622
	rra                             ; A623
	rra                             ; A624
	cp (hl)                         ; A625
	rra                             ; A626
	rra                             ; A627
	cp a                            ; A628
	rra                             ; A629
	rra                             ; A62A
	rra                             ; A62B
	rra                             ; A62C
	rra                             ; A62D
	rra                             ; A62E
	ld e,a                          ; A62F
	ld d,b                          ; A630
	add a,b                         ; A631
	ld l,a                          ; A632
	rra                             ; A633
	ld b,d                          ; A634
	rra                             ; A635
	rra                             ; A636
	rra                             ; A637
	rra                             ; A638
	rra                             ; A639
	rra                             ; A63A
	rra                             ; A63B
	cp (hl)                         ; A63C
	rra                             ; A63D
	cp (hl)                         ; A63E
	rra                             ; A63F
	rra                             ; A640
	ld h,a                          ; A641
	ld (hl),d                       ; A642
	ld (hl),c                       ; A643
	ld l,#0x5b                      ; A644
	sub (hl)                        ; A646
	and h                           ; A647
	xor h                           ; A648
	rra                             ; A649
	rra                             ; A64A
	rra                             ; A64B
	rra                             ; A64C
	rra                             ; A64D
	rra                             ; A64E
	rra                             ; A64F
	rra                             ; A650
	rra                             ; A651
	rra                             ; A652
	rra                             ; A653
	rra                             ; A654
	rra                             ; A655
	rra                             ; A656
	rra                             ; A657
	rra                             ; A658
	and c                           ; A659
	adc a,h                         ; A65A
	sbc a,b                         ; A65B
	and c                           ; A65C
	rra                             ; A65D
	rra                             ; A65E
	cp (hl)                         ; A65F
	rra                             ; A660
	rra                             ; A661
	rra                             ; A662
	rra                             ; A663
	rra                             ; A664
	rra                             ; A665
	rra                             ; A666
	rra                             ; A667
	xor e                           ; A668
	sub (hl)                        ; A669
	or e                            ; A66A
	sub h                           ; A66B
	cp c                            ; A66C
	sub l                           ; A66D
	and h                           ; A66E
	rra                             ; A66F
	ld b,d                          ; A670
	rra                             ; A671
	rra                             ; A672
	cp (hl)                         ; A673
	rra                             ; A674
	rra                             ; A675
	rra                             ; A676
	rra                             ; A677
	rra                             ; A678
	rra                             ; A679
	rra                             ; A67A
	rra                             ; A67B
	xor e                           ; A67C
	sub (hl)                        ; A67D
	or e                            ; A67E
	sub h                           ; A67F
	cp c                            ; A680
	sub l                           ; A681
	and h                           ; A682
	rra                             ; A683
	dec sp                          ; A684
	rra                             ; A685
	rra                             ; A686
	rra                             ; A687
	rra                             ; A688
	rra                             ; A689
	rra                             ; A68A
	cp (hl)                         ; A68B
	rra                             ; A68C
	rra                             ; A68D
	rra                             ; A68E
	rra                             ; A68F
	rra                             ; A690
	rra                             ; A691
	rra                             ; A692
	rra                             ; A693
	rra                             ; A694
	xor d                           ; A695
	sbc a,b                         ; A696
	xor d                           ; A697
	and d                           ; A698
	rra                             ; A699
	rra                             ; A69A
	rra                             ; A69B
	rra                             ; A69C
	rra                             ; A69D
	cp (hl)                         ; A69E
	rra                             ; A69F
	rra                             ; A6A0
	rra                             ; A6A1
	rra                             ; A6A2
	rra                             ; A6A3
	rra                             ; A6A4
	rra                             ; A6A5
	sub d                           ; A6A6
	cp h                            ; A6A7
	sub (hl)                        ; A6A8
	sbc a,d                         ; A6A9
	cp h                            ; A6AA
	cp d                            ; A6AB
	cp c                            ; A6AC
	rra                             ; A6AD
	rra                             ; A6AE
	rra                             ; A6AF
	rra                             ; A6B0
	rra                             ; A6B1
	rra                             ; A6B2
	cp (hl)                         ; A6B3
	rra                             ; A6B4
	rra                             ; A6B5
	rra                             ; A6B6
	rra                             ; A6B7
	rra                             ; A6B8
	rra                             ; A6B9
	rra                             ; A6BA
	rra                             ; A6BB
	or b                            ; A6BC
	sbc a,l                         ; A6BD
	xor c                           ; A6BE
	sub l                           ; A6BF
	and h                           ; A6C0
	rra                             ; A6C1
	rra                             ; A6C2
	cp (hl)                         ; A6C3
	rra                             ; A6C4
	rra                             ; A6C5
	rra                             ; A6C6
	cp (hl)                         ; A6C7
	rra                             ; A6C8
	rra                             ; A6C9
	rra                             ; A6CA
	sbc a,d                         ; A6CB
	sub e                           ; A6CC
	sbc a,c                         ; A6CD
	sub a                           ; A6CE
	add a,(hl)                      ; A6CF
	xor d                           ; A6D0
	sbc a,h                         ; A6D1
	sbc a,b                         ; A6D2
	rra                             ; A6D3
	ld b,d                          ; A6D4
	rra                             ; A6D5
	rra                             ; A6D6
	cp (hl)                         ; A6D7
	rra                             ; A6D8
	rra                             ; A6D9
	rra                             ; A6DA
	cp (hl)                         ; A6DB
	rra                             ; A6DC
	rra                             ; A6DD
	rra                             ; A6DE
	sbc a,d                         ; A6DF
	sub e                           ; A6E0
	sbc a,c                         ; A6E1
	sub a                           ; A6E2
	add a,(hl)                      ; A6E3
	xor d                           ; A6E4
	sbc a,h                         ; A6E5
	sbc a,b                         ; A6E6
	rra                             ; A6E7
	dec sp                          ; A6E8
	rra                             ; A6E9
	rra                             ; A6EA
	rra                             ; A6EB
	rra                             ; A6EC
	rra                             ; A6ED
	rra                             ; A6EE
	rra                             ; A6EF
	cp a                            ; A6F0
	rra                             ; A6F1
	rra                             ; A6F2
	rra                             ; A6F3
	rra                             ; A6F4
	rra                             ; A6F5
	rra                             ; A6F6
	rra                             ; A6F7
	rra                             ; A6F8
	rra                             ; A6F9
	ld l,l                          ; A6FA
	add a,b                         ; A6FB

;; ---------------------------------------------------------------- $5E6FC
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B23_A6FC
sub_b23_A6FC:
	ld h,h                          ; A6FC
	rra                             ; A6FD
	rra                             ; A6FE
	rra                             ; A6FF
	rra                             ; A700
	rra                             ; A701
	rra                             ; A702
	cp (hl)                         ; A703
	rra                             ; A704
	rra                             ; A705
	cp (hl)                         ; A706
	rra                             ; A707
	rra                             ; A708
	rra                             ; A709
	ccf                             ; A70A
	ld (data_631F),a                ; A70B
	ld (hl),l                       ; A70E
	ld l,#0x5f                      ; A70F
	rra                             ; A711
	rra                             ; A712
	rra                             ; A713
	rra                             ; A714
	rra                             ; A715
	rra                             ; A716
	rra                             ; A717
	rra                             ; A718
	rra                             ; A719
	rra                             ; A71A
	ld d,h                          ; A71B
	ld d,l                          ; A71C
	ld h,(hl)                       ; A71D
	ld (hl),h                       ; A71E
	sub (hl)                        ; A71F
	sbc a,b                         ; A720
	and h                           ; A721
	sbc a,b                         ; A722
	rra                             ; A723
	ld hl,#data_1F1F                ; A724
	rra                             ; A727
	rra                             ; A728
	rra                             ; A729
	rra                             ; A72A
	rra                             ; A72B

;; ---------------------------------------------------------------- $5E72C
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B23_A72C
sub_b23_A72C:
	rra                             ; A72C
	rra                             ; A72D
	rra                             ; A72E
	ld d,h                          ; A72F
	ld d,l                          ; A730
	ld h,(hl)                       ; A731
	ld (hl),h                       ; A732
	sub (hl)                        ; A733
	sbc a,b                         ; A734
	and h                           ; A735
	sbc a,b                         ; A736
	rra                             ; A737
	ld (data_1F1F),hl               ; A738
	rra                             ; A73B
	rra                             ; A73C
	rra                             ; A73D
	rra                             ; A73E
	rra                             ; A73F
	rra                             ; A740
	rra                             ; A741
	rra                             ; A742
	rra                             ; A743
	rra                             ; A744
	rra                             ; A745
	rra                             ; A746
	rra                             ; A747
	rra                             ; A748
	rra                             ; A749
	ld hl,#0x3f44                   ; A74A
	rra                             ; A74D
	rra                             ; A74E
	rra                             ; A74F
	rra                             ; A750
	rra                             ; A751
	rra                             ; A752
	rra                             ; A753
	rra                             ; A754
	rra                             ; A755
	rra                             ; A756
	rra                             ; A757
	rra                             ; A758
	ld e,c                          ; A759
	ld l,#0x62                      ; A75A
	ld a,h                          ; A75C
	sbc a,(hl)                      ; A75D
	cp l                            ; A75E
	and b                           ; A75F
	sbc a,b                         ; A760
	rra                             ; A761
	rra                             ; A762
	rra                             ; A763
	rra                             ; A764
	rra                             ; A765
	rra                             ; A766
	rra                             ; A767
	rra                             ; A768
	rra                             ; A769
	rra                             ; A76A
	rra                             ; A76B
	rra                             ; A76C
	ld e,c                          ; A76D
	ld l,#0x62                      ; A76E
	ld a,h                          ; A770
	sbc a,c                         ; A771
	adc a,a                         ; A772
	and e                           ; A773
	sub d                           ; A774
	rra                             ; A775
	rra                             ; A776
	rra                             ; A777
	rra                             ; A778
	rra                             ; A779
	rra                             ; A77A
	rra                             ; A77B
	cp (hl)                         ; A77C
	cp (hl)                         ; A77D
	rra                             ; A77E
	rra                             ; A77F
	rra                             ; A780
	rra                             ; A781
	rra                             ; A782
	rra                             ; A783
	rra                             ; A784
	rra                             ; A785
	ld l,a                          ; A786
	ld e,(hl)                       ; A787
	ld l,#0x1f                      ; A788
	rra                             ; A78A
	rra                             ; A78B
	rra                             ; A78C
	rra                             ; A78D
	rra                             ; A78E
	rra                             ; A78F
	rra                             ; A790
	cp (hl)                         ; A791
	rra                             ; A792
	rra                             ; A793
	rra                             ; A794
	rra                             ; A795
	rra                             ; A796
	rra                             ; A797
	rra                             ; A798
	ld a,l                          ; A799
	ld l,#0x5e                      ; A79A
	ld l,#0x1f                      ; A79C
	rra                             ; A79E
	rra                             ; A79F
	rra                             ; A7A0
	rra                             ; A7A1
	rra                             ; A7A2
	rra                             ; A7A3
	cp (hl)                         ; A7A4
	rra                             ; A7A5
	rra                             ; A7A6
	rra                             ; A7A7
	rra                             ; A7A8
	rra                             ; A7A9
	rra                             ; A7AA
	rra                             ; A7AB
	rra                             ; A7AC
	rra                             ; A7AD
	sbc a,h                         ; A7AE
	sbc a,h                         ; A7AF
	cp l                            ; A7B0
	rra                             ; A7B1
	rra                             ; A7B2
	rra                             ; A7B3
	rra                             ; A7B4
	rra                             ; A7B5
	rra                             ; A7B6
	cp (hl)                         ; A7B7
	rra                             ; A7B8
	rra                             ; A7B9
	cp (hl)                         ; A7BA
	rra                             ; A7BB
	rra                             ; A7BC
	rra                             ; A7BD
	and e                           ; A7BE
	sub a                           ; A7BF
	rra                             ; A7C0
	ld h,e                          ; A7C1
	ld (hl),l                       ; A7C2
	ld l,#0x5f                      ; A7C3
	rra                             ; A7C5
	rra                             ; A7C6
	rra                             ; A7C7
	cp (hl)                         ; A7C8
	rra                             ; A7C9
	rra                             ; A7CA
	cp (hl)                         ; A7CB
	rra                             ; A7CC
	rra                             ; A7CD
	cp (hl)                         ; A7CE
	rra                             ; A7CF
	rra                             ; A7D0
	rra                             ; A7D1
	ld (hl),c                       ; A7D2
	ld h,b                          ; A7D3
	rra                             ; A7D4
	ld h,e                          ; A7D5
	ld (hl),l                       ; A7D6
	ld l,#0x5f                      ; A7D7
	rra                             ; A7D9
	rra                             ; A7DA
	rra                             ; A7DB
	rra                             ; A7DC
	rra                             ; A7DD
	rra                             ; A7DE
	cp (hl)                         ; A7DF
	rra                             ; A7E0
	rra                             ; A7E1
	rra                             ; A7E2
	rra                             ; A7E3
	rra                             ; A7E4
	rra                             ; A7E5
	rra                             ; A7E6
	rra                             ; A7E7
	sub (hl)                        ; A7E8
	sbc a,(hl)                      ; A7E9
	xor c                           ; A7EA
	sub l                           ; A7EB
	and h                           ; A7EC
	rra                             ; A7ED
	rra                             ; A7EE
	rra                             ; A7EF
	rra                             ; A7F0
	rra                             ; A7F1
	rra                             ; A7F2
	rra                             ; A7F3
	rra                             ; A7F4
	rra                             ; A7F5
	rra                             ; A7F6
	rra                             ; A7F7
	rra                             ; A7F8
	rra                             ; A7F9
	rra                             ; A7FA
	rra                             ; A7FB
	rra                             ; A7FC
	xor e                           ; A7FD
	xor c                           ; A7FE
	sub l                           ; A7FF
	and h                           ; A800
	rra                             ; A801
	rra                             ; A802
	rra                             ; A803
	rra                             ; A804
	rra                             ; A805
	rra                             ; A806
	rra                             ; A807
	rra                             ; A808
	rra                             ; A809
	rra                             ; A80A
	xor e                           ; A80B
	sub (hl)                        ; A80C
	cp b                            ; A80D
	xor c                           ; A80E
	and b                           ; A80F
	xor a                           ; A810
	xor d                           ; A811
	adc a,a                         ; A812
	sbc a,h                         ; A813
	adc a,h                         ; A814
	rra                             ; A815
	rra                             ; A816
	rra                             ; A817
	rra                             ; A818
	rra                             ; A819
	rra                             ; A81A
	rra                             ; A81B
	rra                             ; A81C
	cp (hl)                         ; A81D
	rra                             ; A81E
	rra                             ; A81F
	ld (hl),e                       ; A820
	ld l,c                          ; A821
	ld e,d                          ; A822
	ld d,b                          ; A823
	ld a,d                          ; A824
	rra                             ; A825
	sub d                           ; A826
	and h                           ; A827
	sub e                           ; A828
	rra                             ; A829
	rra                             ; A82A
	rra                             ; A82B
	rra                             ; A82C
	rra                             ; A82D
	rra                             ; A82E
	rra                             ; A82F
	rra                             ; A830
	rra                             ; A831
	rra                             ; A832
	rra                             ; A833
	rra                             ; A834
	rra                             ; A835
	ld h,b                          ; A836
	ld d,l                          ; A837
	ld d,e                          ; A838
	ld h,h                          ; A839
	xor c                           ; A83A
	sub l                           ; A83B
	and h                           ; A83C
	rra                             ; A83D
	rra                             ; A83E
	rra                             ; A83F
	rra                             ; A840
	rra                             ; A841
	rra                             ; A842
	rra                             ; A843
	rra                             ; A844
	rra                             ; A845
	rra                             ; A846
	ld h,e                          ; A847
	ld d,l                          ; A848
	ld h,a                          ; A849
	ld a,h                          ; A84A
	rra                             ; A84B
	ld l,a                          ; A84C
	ld a,d                          ; A84D
	ld d,e                          ; A84E
	ld e,a                          ; A84F
	ld d,c                          ; A850
	rra                             ; A851
	rra                             ; A852
	rra                             ; A853
	rra                             ; A854
	rra                             ; A855
	rra                             ; A856
	rra                             ; A857
	rra                             ; A858
	rra                             ; A859
	rra                             ; A85A
	rra                             ; A85B
	rra                             ; A85C
	rra                             ; A85D
	rra                             ; A85E
	rra                             ; A85F

;; ---------------------------------------------------------------- $5E860
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B23_A860
sub_b23_A860:
	rra                             ; A860
	or a                            ; A861
	sub d                           ; A862
	or d                            ; A863
	sub d                           ; A864
	rra                             ; A865
	rra                             ; A866
	rra                             ; A867
	rra                             ; A868
	rra                             ; A869
	rra                             ; A86A
	rra                             ; A86B
	rra                             ; A86C
	cp (hl)                         ; A86D
	rra                             ; A86E
	rra                             ; A86F
	rra                             ; A870
	rra                             ; A871
	rra                             ; A872
	rra                             ; A873
	rra                             ; A874
	and l                           ; A875
	sub a                           ; A876
	sbc a,d                         ; A877
	sub h                           ; A878
	rra                             ; A879
	rra                             ; A87A
	rra                             ; A87B
	rra                             ; A87C
	cp (hl)                         ; A87D
	rra                             ; A87E
	cp (hl)                         ; A87F
	rra                             ; A880
	rra                             ; A881
	rra                             ; A882
	rra                             ; A883
	rra                             ; A884
	or e                            ; A885
	xor c                           ; A886
	sub (hl)                        ; A887
	sbc a,b                         ; A888
	and b                           ; A889
	sbc a,c                         ; A88A
	and c                           ; A88B
	cp c                            ; A88C
	rra                             ; A88D
	rra                             ; A88E
	rra                             ; A88F
	rra                             ; A890
	rra                             ; A891
	rra                             ; A892
	rra                             ; A893
	rra                             ; A894
	rra                             ; A895
	rra                             ; A896
	rra                             ; A897
	rra                             ; A898
	rra                             ; A899
	sub a                           ; A89A
	or a                            ; A89B
	cp b                            ; A89C
	and h                           ; A89D
	xor e                           ; A89E
	sub (hl)                        ; A89F
	cp c                            ; A8A0
	rra                             ; A8A1
	rra                             ; A8A2
	rra                             ; A8A3
	rra                             ; A8A4
	rra                             ; A8A5
	cp (hl)                         ; A8A6
	rra                             ; A8A7
	rra                             ; A8A8
	rra                             ; A8A9
	rra                             ; A8AA
	rra                             ; A8AB
	rra                             ; A8AC
	rra                             ; A8AD
	xor (hl)                        ; A8AE
	sub e                           ; A8AF
	and e                           ; A8B0
	cp l                            ; A8B1
	xor c                           ; A8B2
	sub l                           ; A8B3
	and h                           ; A8B4
	rra                             ; A8B5
	rra                             ; A8B6
	rra                             ; A8B7
	rra                             ; A8B8
	cp (hl)                         ; A8B9
	rra                             ; A8BA
	rra                             ; A8BB
	cp (hl)                         ; A8BC
	rra                             ; A8BD
	rra                             ; A8BE
	ld e,c                          ; A8BF
	ld l,#0x62                      ; A8C0
	ld a,h                          ; A8C2
	sub (hl)                        ; A8C3
	and h                           ; A8C4
	cp l                            ; A8C5
	and e                           ; A8C6
	sbc a,b                         ; A8C7
	cp c                            ; A8C8
	rra                             ; A8C9
	rra                             ; A8CA
	rra                             ; A8CB
	rra                             ; A8CC
	cp (hl)                         ; A8CD
	rra                             ; A8CE
	cp (hl)                         ; A8CF
	rra                             ; A8D0
	rra                             ; A8D1
	rra                             ; A8D2
	rra                             ; A8D3
	ld d,a                          ; A8D4
	ld l,e                          ; A8D5
	ld a,h                          ; A8D6
	ld e,d                          ; A8D7
	ld l,#0x96                      ; A8D8
	and b                           ; A8DA
	xor a                           ; A8DB
	cp c                            ; A8DC
	rra                             ; A8DD
	rra                             ; A8DE
	rra                             ; A8DF
	rra                             ; A8E0
	rra                             ; A8E1
	rra                             ; A8E2
	rra                             ; A8E3
	rra                             ; A8E4
	rra                             ; A8E5
	rra                             ; A8E6
	rra                             ; A8E7
	rra                             ; A8E8
	ld (hl),e                       ; A8E9
	ld e,(hl)                       ; A8EA
	ld d,l                          ; A8EB
	ld a,h                          ; A8EC
	xor d                           ; A8ED
	adc a,a                         ; A8EE
	sbc a,h                         ; A8EF
	adc a,h                         ; A8F0
	rra                             ; A8F1
	rra                             ; A8F2
	rra                             ; A8F3
	rra                             ; A8F4
	rra                             ; A8F5
	rra                             ; A8F6
	rra                             ; A8F7
	cp a                            ; A8F8
	rra                             ; A8F9
	rra                             ; A8FA
	rra                             ; A8FB
	rra                             ; A8FC
	rra                             ; A8FD
	rra                             ; A8FE
	ld (hl),b                       ; A8FF
	ld a,e                          ; A900
	ld e,l                          ; A901
	ld l,a                          ; A902
	ld h,e                          ; A903
	ld l,#0x1f                      ; A904
	rra                             ; A906
	rra                             ; A907
	rra                             ; A908
	rra                             ; A909
	rra                             ; A90A
	rra                             ; A90B
	rra                             ; A90C
	cp (hl)                         ; A90D
	rra                             ; A90E
	rra                             ; A90F
	rra                             ; A910
	rra                             ; A911
	rra                             ; A912
	rra                             ; A913
	and c                           ; A914
	adc a,h                         ; A915
	sbc a,b                         ; A916
	and b                           ; A917
	cp l                            ; A918
	rra                             ; A919
	cp (hl)                         ; A91A
	cp (hl)                         ; A91B
	rra                             ; A91C
	rra                             ; A91D
	rra                             ; A91E
	rra                             ; A91F
	rra                             ; A920
	rra                             ; A921
	rra                             ; A922
	rra                             ; A923
	ld l,l                          ; A924
	ld e,a                          ; A925
	ld d,c                          ; A926
	ld a,d                          ; A927
	ld e,b                          ; A928
	add a,b                         ; A929
	ld d,h                          ; A92A
	ld l,#0x5b                      ; A92B
	rra                             ; A92D
	rra                             ; A92E
	rra                             ; A92F
	rra                             ; A930
	cp (hl)                         ; A931
	rra                             ; A932
	rra                             ; A933
	rra                             ; A934
	rra                             ; A935
	rra                             ; A936
	rra                             ; A937
	rra                             ; A938
	rra                             ; A939
	rra                             ; A93A
	sbc a,c                         ; A93B
	cp l                            ; A93C
	cp b                            ; A93D
	cp l                            ; A93E
	sbc a,(hl)                      ; A93F
	or (hl)                         ; A940
data_b23_A941:
	ld h,c                          ; A941
	xor c                           ; A942
	ld (hl),l                       ; A943
	xor c                           ; A944
	adc a,c                         ; A945
	xor c                           ; A946
	sbc a,l                         ; A947
	xor c                           ; A948
	or c                            ; A949
	xor c                           ; A94A
	push bc                         ; A94B
	xor c                           ; A94C
	exx                             ; A94D
	xor c                           ; A94E
	cpd                             ; A94F
	ld bc,#0x15aa                   ; A951
	xor d                           ; A954
	add hl,hl                       ; A955
	xor d                           ; A956
	dec a                           ; A957
	xor d                           ; A958
	ld d,c                          ; A959
	xor d                           ; A95A
	ld h,l                          ; A95B
	xor d                           ; A95C
	ld a,c                          ; A95D
	xor d                           ; A95E
	adc a,l                         ; A95F
	xor d                           ; A960
	rra                             ; A961
	rra                             ; A962
	rra                             ; A963
	cp (hl)                         ; A964
	rra                             ; A965
	rra                             ; A966
	rra                             ; A967
	cp (hl)                         ; A968
	rra                             ; A969
	rra                             ; A96A
	sub h                           ; A96B
	cp l                            ; A96C
	xor c                           ; A96D
	sbc a,h                         ; A96E
	adc a,l                         ; A96F
	xor (hl)                        ; A970
	sub e                           ; A971
	and h                           ; A972
	sub e                           ; A973
	jr nz,loc_b23_A995              ; A974
	rra                             ; A976
	rra                             ; A977
	rra                             ; A978
	rra                             ; A979
	rra                             ; A97A
	rra                             ; A97B
	rra                             ; A97C
	rra                             ; A97D
	rra                             ; A97E
	rra                             ; A97F
	rra                             ; A980
	rra                             ; A981
	and b                           ; A982
	sub a                           ; A983
	and h                           ; A984
	sub d                           ; A985
	cp h                            ; A986
	rra                             ; A987
	ld hl,#data_1F1F                ; A988
	rra                             ; A98B
	rra                             ; A98C
	rra                             ; A98D
	rra                             ; A98E
	rra                             ; A98F
	rra                             ; A990
	cp (hl)                         ; A991
	rra                             ; A992
	rra                             ; A993

;; ---------------------------------------------------------------- $5E994
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B23_A994
sub_b23_A994:
	rra                             ; A994
loc_b23_A995:
	rra                             ; A995
	rra                             ; A996
	rra                             ; A997
	ld h,b                          ; A998
	ld h,(hl)                       ; A999
	ld l,#0x5f                      ; A99A
	ld (data_1F1F),hl               ; A99C
	rra                             ; A99F
	rra                             ; A9A0
	rra                             ; A9A1
	rra                             ; A9A2
	rra                             ; A9A3
	rra                             ; A9A4
	cp (hl)                         ; A9A5
	rra                             ; A9A6
	rra                             ; A9A7
	rra                             ; A9A8
	rra                             ; A9A9
	rra                             ; A9AA
	rra                             ; A9AB
	ld h,b                          ; A9AC
	ld h,(hl)                       ; A9AD
	ld l,#0x5f                      ; A9AE
	inc hl                          ; A9B0
	rra                             ; A9B1
	rra                             ; A9B2
	rra                             ; A9B3
	rra                             ; A9B4
	rra                             ; A9B5
	rra                             ; A9B6
	rra                             ; A9B7
	rra                             ; A9B8
	rra                             ; A9B9
	rra                             ; A9BA
	rra                             ; A9BB
	rra                             ; A9BC
	rra                             ; A9BD
	sbc a,d                         ; A9BE
	sub e                           ; A9BF
	or h                            ; A9C0
	sbc a,e                         ; A9C1
	cp l                            ; A9C2
	rra                             ; A9C3
	inc h                           ; A9C4
	rra                             ; A9C5
	rra                             ; A9C6
	rra                             ; A9C7
	rra                             ; A9C8
	rra                             ; A9C9
	rra                             ; A9CA
	rra                             ; A9CB
	rra                             ; A9CC
	rra                             ; A9CD
	rra                             ; A9CE
	rra                             ; A9CF
	rra                             ; A9D0
	rra                             ; A9D1
	xor d                           ; A9D2
	sbc a,h                         ; A9D3
	and h                           ; A9D4
	sbc a,b                         ; A9D5
	or e                            ; A9D6
	rra                             ; A9D7
	dec h                           ; A9D8
	rra                             ; A9D9
	rra                             ; A9DA
	rra                             ; A9DB
	rra                             ; A9DC
	rra                             ; A9DD
	rra                             ; A9DE
	rra                             ; A9DF
	rra                             ; A9E0
	cp (hl)                         ; A9E1
	rra                             ; A9E2
	rra                             ; A9E3
	rra                             ; A9E4
	rra                             ; A9E5
	rra                             ; A9E6
	rra                             ; A9E7
	ld h,b                          ; A9E8
	ld h,(hl)                       ; A9E9
	ld l,#0x5f                      ; A9EA
	ld h,#0x1f                      ; A9EC
	rra                             ; A9EE
	rra                             ; A9EF
	rra                             ; A9F0
	rra                             ; A9F1
	rra                             ; A9F2
	rra                             ; A9F3
	rra                             ; A9F4
	cp (hl)                         ; A9F5
	rra                             ; A9F6
	rra                             ; A9F7
	rra                             ; A9F8
	rra                             ; A9F9
	rra                             ; A9FA
	rra                             ; A9FB
	ld h,b                          ; A9FC
	ld h,(hl)                       ; A9FD
	ld l,#0x5f                      ; A9FE
	daa                             ; AA00
	rra                             ; AA01
	rra                             ; AA02
	rra                             ; AA03
	rra                             ; AA04
	rra                             ; AA05
	rra                             ; AA06
	rra                             ; AA07
	rra                             ; AA08
	cp (hl)                         ; AA09
	rra                             ; AA0A
	rra                             ; AA0B
	rra                             ; AA0C
	rra                             ; AA0D
	rra                             ; AA0E
	rra                             ; AA0F
	ld h,b                          ; AA10
	ld h,(hl)                       ; AA11
	ld l,#0x5f                      ; AA12
	jr z,loc_b23_AA35               ; AA14
	rra                             ; AA16
	rra                             ; AA17
	rra                             ; AA18
	rra                             ; AA19
	rra                             ; AA1A
	rra                             ; AA1B
	rra                             ; AA1C
	cp (hl)                         ; AA1D
	rra                             ; AA1E
	rra                             ; AA1F
	rra                             ; AA20
	rra                             ; AA21
	rra                             ; AA22
	rra                             ; AA23
	ld h,b                          ; AA24
	ld h,(hl)                       ; AA25
	ld l,#0x5f                      ; AA26
	add hl,hl                       ; AA28
	rra                             ; AA29
	rra                             ; AA2A
	rra                             ; AA2B
	rra                             ; AA2C
	rra                             ; AA2D
	rra                             ; AA2E
	rra                             ; AA2F
	cp (hl)                         ; AA30
	rra                             ; AA31
	rra                             ; AA32
	rra                             ; AA33
	rra                             ; AA34
loc_b23_AA35:
	rra                             ; AA35
	rra                             ; AA36
	ld h,b                          ; AA37
	ld h,(hl)                       ; AA38
	ld l,#0x5f                      ; AA39
	ld hl,#0x1f20                   ; AA3B
	rra                             ; AA3E
	rra                             ; AA3F
	rra                             ; AA40
	rra                             ; AA41
	rra                             ; AA42
	rra                             ; AA43
	cp (hl)                         ; AA44
	rra                             ; AA45
	rra                             ; AA46
	rra                             ; AA47
	rra                             ; AA48
	rra                             ; AA49
	rra                             ; AA4A
	ld h,b                          ; AA4B
	ld h,(hl)                       ; AA4C
	ld l,#0x5f                      ; AA4D
	ld hl,#data_1F21                ; AA4F
	rra                             ; AA52
	rra                             ; AA53
	rra                             ; AA54
	rra                             ; AA55
	rra                             ; AA56
	rra                             ; AA57
	cp (hl)                         ; AA58
	rra                             ; AA59
	rra                             ; AA5A
	rra                             ; AA5B
	rra                             ; AA5C
	rra                             ; AA5D
	rra                             ; AA5E
	ld h,b                          ; AA5F
	ld h,(hl)                       ; AA60
	ld l,#0x5f                      ; AA61
	ld hl,#0x1f22                   ; AA63
	rra                             ; AA66
	rra                             ; AA67
	rra                             ; AA68
	rra                             ; AA69
	rra                             ; AA6A
	rra                             ; AA6B
	cp (hl)                         ; AA6C
	rra                             ; AA6D
	rra                             ; AA6E
	rra                             ; AA6F
	rra                             ; AA70
	rra                             ; AA71
	rra                             ; AA72
	ld h,b                          ; AA73
	ld h,(hl)                       ; AA74
	ld l,#0x5f                      ; AA75
	ld hl,#0x1f23                   ; AA77
	rra                             ; AA7A
	rra                             ; AA7B
	rra                             ; AA7C
	rra                             ; AA7D
	rra                             ; AA7E
	rra                             ; AA7F
	cp (hl)                         ; AA80
	rra                             ; AA81
	rra                             ; AA82
	rra                             ; AA83
	rra                             ; AA84
	rra                             ; AA85
	rra                             ; AA86
	ld h,b                          ; AA87
	ld h,(hl)                       ; AA88
	ld l,#0x5f                      ; AA89
	ld hl,#data_1F24                ; AA8B
	rra                             ; AA8E
	rra                             ; AA8F
	rra                             ; AA90
	rra                             ; AA91
	rra                             ; AA92
	cp (hl)                         ; AA93
	rra                             ; AA94
	rra                             ; AA95
	cp (hl)                         ; AA96
	rra                             ; AA97
	rra                             ; AA98
	rra                             ; AA99
	rra                             ; AA9A
	ld d,a                          ; AA9B
	add a,b                         ; AA9C
	ld h,(hl)                       ; AA9D
	ld c,h                          ; AA9E
	add a,b                         ; AA9F
	ld e,e                          ; AAA0
data_b23_AAA1:
	rra                             ; AAA1
	rra                             ; AAA2
	rra                             ; AAA3
	rra                             ; AAA4
	rra                             ; AAA5
	rra                             ; AAA6
	rra                             ; AAA7
	rra                             ; AAA8
	rra                             ; AAA9
	rra                             ; AAAA
	rra                             ; AAAB
	rra                             ; AAAC
	rra                             ; AAAD
	rra                             ; AAAE
	rra                             ; AAAF
	rra                             ; AAB0
	rra                             ; AAB1
	rra                             ; AAB2
	rra                             ; AAB3
	rra                             ; AAB4
	rra                             ; AAB5
	rra                             ; AAB6
	rra                             ; AAB7
	rra                             ; AAB8
	rra                             ; AAB9
	rra                             ; AABA
	rra                             ; AABB
	rra                             ; AABC
	cp (hl)                         ; AABD
	rra                             ; AABE
	rra                             ; AABF
	rra                             ; AAC0
	rra                             ; AAC1
	rra                             ; AAC2
	rra                             ; AAC3
	rra                             ; AAC4
	rra                             ; AAC5
	rra                             ; AAC6
	rra                             ; AAC7
	rra                             ; AAC8
	rra                             ; AAC9
	rra                             ; AACA
	rra                             ; AACB
	rra                             ; AACC
	sbc a,d                         ; AACD
	cp l                            ; AACE
	xor h                           ; AACF
	adc a,b                         ; AAD0
	sub a                           ; AAD1
	adc a,l                         ; AAD2
	cp d                            ; AAD3
	ld l,#0x9c                      ; AAD4
	adc a,(hl)                      ; AAD6
	cp l                            ; AAD7
	rra                             ; AAD8

;; ---------------------------------------------------------------- $5EAD9
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B23_AAD9
sub_b23_AAD9:
	rra                             ; AAD9
	rra                             ; AADA
	rra                             ; AADB
	rra                             ; AADC
	rra                             ; AADD
	rra                             ; AADE
	rra                             ; AADF
	rra                             ; AAE0
	rra                             ; AAE1
	rra                             ; AAE2
	rra                             ; AAE3
	rra                             ; AAE4
	rra                             ; AAE5
	rra                             ; AAE6
	rra                             ; AAE7
	rra                             ; AAE8
	rra                             ; AAE9
	rra                             ; AAEA
	rra                             ; AAEB
	rra                             ; AAEC
	rra                             ; AAED
	rra                             ; AAEE
	rra                             ; AAEF
	rra                             ; AAF0
	rra                             ; AAF1
	rra                             ; AAF2
	rra                             ; AAF3
	rra                             ; AAF4
	rra                             ; AAF5
	rra                             ; AAF6
	rra                             ; AAF7
	rra                             ; AAF8
	rra                             ; AAF9
	rra                             ; AAFA
	rra                             ; AAFB
	rra                             ; AAFC
	rra                             ; AAFD
	rra                             ; AAFE
	rra                             ; AAFF
	rra                             ; AB00
	rra                             ; AB01
	rra                             ; AB02
	rra                             ; AB03
	rra                             ; AB04
	rra                             ; AB05
	add a,c                         ; AB06
	ccf                             ; AB07
	dec sp                          ; AB08
	jr nc,loc_b23_AB53              ; AB09
	inc (hl)                        ; AB0B
	ld b,c                          ; AB0C
	ld b,d                          ; AB0D
	rra                             ; AB0E
	rra                             ; AB0F
	rra                             ; AB10
	rra                             ; AB11
	rra                             ; AB12
	rra                             ; AB13
	rra                             ; AB14
	rra                             ; AB15
	rra                             ; AB16
	rra                             ; AB17
	rra                             ; AB18
	rra                             ; AB19
	rra                             ; AB1A
	rra                             ; AB1B
	rra                             ; AB1C
	rra                             ; AB1D
	rra                             ; AB1E
	rra                             ; AB1F
	rra                             ; AB20
	rra                             ; AB21
	rra                             ; AB22
	rra                             ; AB23
	rra                             ; AB24
	rra                             ; AB25
	rra                             ; AB26
	rra                             ; AB27
	rra                             ; AB28
	rra                             ; AB29
	rra                             ; AB2A
	rra                             ; AB2B
	rra                             ; AB2C
	rra                             ; AB2D
	rra                             ; AB2E
	ld b,c                          ; AB2F
	ld a,#0x44                      ; AB30
	dec a                           ; AB32
	inc sp                          ; AB33
	rra                             ; AB34
	rra                             ; AB35
	rra                             ; AB36
	rra                             ; AB37
	rra                             ; AB38
	rra                             ; AB39
	rra                             ; AB3A
	rra                             ; AB3B
	rra                             ; AB3C
	rra                             ; AB3D
	rra                             ; AB3E
	rra                             ; AB3F
	rra                             ; AB40
	rra                             ; AB41
	rra                             ; AB42
	rra                             ; AB43
	rra                             ; AB44
	rra                             ; AB45
	rra                             ; AB46
	rra                             ; AB47
	rra                             ; AB48
	rra                             ; AB49
	rra                             ; AB4A
	rra                             ; AB4B
	rra                             ; AB4C
	rra                             ; AB4D
	rra                             ; AB4E
	rra                             ; AB4F
	rra                             ; AB50
	rra                             ; AB51
	rra                             ; AB52
loc_b23_AB53:
	rra                             ; AB53
	rra                             ; AB54
	rra                             ; AB55
	rra                             ; AB56
	ld b,d                          ; AB57
	ld (0x3d34),a                   ; AB58
	inc (hl)                        ; AB5B
	rra                             ; AB5C
	rra                             ; AB5D
	rra                             ; AB5E
	rra                             ; AB5F
	rra                             ; AB60
	rra                             ; AB61
	rra                             ; AB62
	rra                             ; AB63
	rra                             ; AB64
	rra                             ; AB65
	rra                             ; AB66
	rra                             ; AB67
	rra                             ; AB68
	rra                             ; AB69
	rra                             ; AB6A
	rra                             ; AB6B
	rra                             ; AB6C
	rra                             ; AB6D
	rra                             ; AB6E
	rra                             ; AB6F
	rra                             ; AB70
	rra                             ; AB71
	rra                             ; AB72
	rra                             ; AB73
	rra                             ; AB74
	rra                             ; AB75
	rra                             ; AB76
	rra                             ; AB77
	rra                             ; AB78
	rra                             ; AB79
	rra                             ; AB7A
	rra                             ; AB7B
	rra                             ; AB7C
	rra                             ; AB7D
	rra                             ; AB7E
	ld b,d                          ; AB7F
	ld a,#0x44                      ; AB80
	dec a                           ; AB82
	inc sp                          ; AB83
	rra                             ; AB84
	rra                             ; AB85
	rra                             ; AB86
	rra                             ; AB87
	rra                             ; AB88
	rra                             ; AB89
	rra                             ; AB8A
	rra                             ; AB8B
	rra                             ; AB8C
	rra                             ; AB8D
	rra                             ; AB8E
	rra                             ; AB8F
	rra                             ; AB90
	rra                             ; AB91
	rra                             ; AB92
	cp (hl)                         ; AB93
	rra                             ; AB94
	rra                             ; AB95
	rra                             ; AB96
	rra                             ; AB97
	rra                             ; AB98
	rra                             ; AB99
	rra                             ; AB9A
	rra                             ; AB9B
	rra                             ; AB9C
	rra                             ; AB9D
	rra                             ; AB9E
	rra                             ; AB9F
	rra                             ; ABA0
	rra                             ; ABA1
	rra                             ; ABA2
	rra                             ; ABA3
	rra                             ; ABA4
	rra                             ; ABA5
	rra                             ; ABA6
	sbc a,h                         ; ABA7
	adc a,l                         ; ABA8
	and d                           ; ABA9
	rra                             ; ABAA
	rra                             ; ABAB
	rra                             ; ABAC
	rra                             ; ABAD
	rra                             ; ABAE
	rra                             ; ABAF
	rra                             ; ABB0
	rra                             ; ABB1
	rra                             ; ABB2
	rra                             ; ABB3
	rra                             ; ABB4
	rra                             ; ABB5
	rra                             ; ABB6
	rra                             ; ABB7
	rra                             ; ABB8
	rra                             ; ABB9
	rra                             ; ABBA
	rra                             ; ABBB
	rra                             ; ABBC
	rra                             ; ABBD
	rra                             ; ABBE
	rra                             ; ABBF
	rra                             ; ABC0
	rra                             ; ABC1
	rra                             ; ABC2
	rra                             ; ABC3
	rra                             ; ABC4
	rra                             ; ABC5
	rra                             ; ABC6
	rra                             ; ABC7
	rra                             ; ABC8
	rra                             ; ABC9
	rra                             ; ABCA
	rra                             ; ABCB
	rra                             ; ABCC
	rra                             ; ABCD
	rra                             ; ABCE
	and b                           ; ABCF
	xor a                           ; ABD0
	rra                             ; ABD1
	rra                             ; ABD2
	rra                             ; ABD3
	rra                             ; ABD4
	rra                             ; ABD5
	rra                             ; ABD6
	rra                             ; ABD7
	rra                             ; ABD8
	rra                             ; ABD9
	rra                             ; ABDA
	rra                             ; ABDB
	rra                             ; ABDC
	rra                             ; ABDD
	rra                             ; ABDE
	rra                             ; ABDF
	rra                             ; ABE0
	rra                             ; ABE1
	rra                             ; ABE2
	rra                             ; ABE3
	rra                             ; ABE4
	rra                             ; ABE5
	rra                             ; ABE6
	rra                             ; ABE7
	rra                             ; ABE8
	rra                             ; ABE9
	rra                             ; ABEA
	rra                             ; ABEB
	rra                             ; ABEC
	rra                             ; ABED
	rra                             ; ABEE
	rra                             ; ABEF
	rra                             ; ABF0
	rra                             ; ABF1
	rra                             ; ABF2
	rra                             ; ABF3
	rra                             ; ABF4
	rra                             ; ABF5
	rra                             ; ABF6
	rra                             ; ABF7
	rra                             ; ABF8
	rra                             ; ABF9
	rra                             ; ABFA
	rra                             ; ABFB
	rra                             ; ABFC
	rra                             ; ABFD
	rra                             ; ABFE
	rra                             ; ABFF
	rra                             ; AC00
	rra                             ; AC01
	rra                             ; AC02
	rra                             ; AC03
	rra                             ; AC04
	rra                             ; AC05
	rra                             ; AC06
	rra                             ; AC07
	rra                             ; AC08
