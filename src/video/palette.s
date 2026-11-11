;; video/palette.s
;; Palette : effets par couleur ($C0E4) et fondus ($C0D3).
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $0574C
;; classement : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
	.area _B01_574C
sub_574C::
	ld b,#0x20                      ; 574C
	ld hl,#pal_fx_table             ; 574E
loc_5751:
	ld a,(hl)                       ; 5751
	or a                            ; 5752
	jr z,loc_57A1                   ; 5753
	push bc                         ; 5755
	push hl                         ; 5756
	cp #0x01                        ; 5757
	jr nz,loc_5760                  ; 5759
	call sub_57B5                   ; 575B
	jr loc_579F                     ; 575E
loc_5760:
	cp #0x02                        ; 5760
	jr nz,loc_5769                  ; 5762
	call sub_57BF                   ; 5764
	jr loc_579F                     ; 5767
loc_5769:
	cp #0x03                        ; 5769
	jr nz,loc_577B                  ; 576B
	call sub_57B5                   ; 576D
	pop hl                          ; 5770
	pop bc                          ; 5771
	ld a,(hl)                       ; 5772
	or a                            ; 5773
	jr nz,loc_57A1                  ; 5774
	ld a,#0x04                      ; 5776
	ld (hl),a                       ; 5778
	jr loc_57A1                     ; 5779
loc_577B:
	cp #0x04                        ; 577B
	jr nz,loc_578D                  ; 577D
	call sub_57BF                   ; 577F
	pop hl                          ; 5782
	pop bc                          ; 5783
	ld a,(hl)                       ; 5784
	or a                            ; 5785
	jr nz,loc_57A1                  ; 5786
	ld a,#0x03                      ; 5788
	ld (hl),a                       ; 578A
	jr loc_57A1                     ; 578B
loc_578D:
	cp #0x05                        ; 578D
	jr nz,loc_5796                  ; 578F
	call sub_57CA                   ; 5791
	jr loc_579F                     ; 5794
loc_5796:
	cp #0x06                        ; 5796
	jr nz,loc_579F                  ; 5798
	call sub_57D5                   ; 579A
	jr loc_579F                     ; 579D
loc_579F:
	pop hl                          ; 579F
	pop bc                          ; 57A0
loc_57A1:
	inc hl                          ; 57A1
	djnz loc_5751                   ; 57A2
	ld a,(pal_C184)                 ; 57A4
	or a                            ; 57A7
	jp z,loc_57B4                   ; 57A8
	xor a                           ; 57AB
	ld (pal_C184),a                 ; 57AC
	ld hl,#vdp_requests2            ; 57AF
	set 6,(hl)                      ; 57B2
loc_57B4:
	ret                             ; 57B4

;; ---------------------------------------------------------------- $057B5
;; classement : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
	.area _B01_57B5
sub_57B5:
	xor a                           ; 57B5
	ld (tmp_d5),a                   ; 57B6
	xor a                           ; 57B9
	ld (pal_C0D6),a                 ; 57BA
	jr loc_57E1                     ; 57BD

;; ---------------------------------------------------------------- $057BF
;; classement : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
	.area _B01_57BF
sub_57BF:
	ld a,#0xff                      ; 57BF
	ld (tmp_d5),a                   ; 57C1
	xor a                           ; 57C4
	ld (pal_C0D6),a                 ; 57C5
	jr loc_57E1                     ; 57C8

;; ---------------------------------------------------------------- $057CA
;; classement : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
	.area _B01_57CA
sub_57CA:
	xor a                           ; 57CA
	ld (tmp_d5),a                   ; 57CB
	ld a,#0xff                      ; 57CE
	ld (pal_C0D6),a                 ; 57D0
	jr loc_57E1                     ; 57D3

;; ---------------------------------------------------------------- $057D5
;; classement : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
	.area _B01_57D5
sub_57D5:
	ld a,#0xff                      ; 57D5
	ld (tmp_d5),a                   ; 57D7
	ld a,#0xff                      ; 57DA
	ld (pal_C0D6),a                 ; 57DC
	jr loc_57E1                     ; 57DF
loc_57E1:
	ld a,#0x20                      ; 57E1
	sub b                           ; 57E3
	ld l,a                          ; 57E4
	ld h,#0x00                      ; 57E5
	ld (tmp_d3),hl                  ; 57E7
	ld de,#pal_C104                 ; 57EA
	add hl,de                       ; 57ED
	ld a,(hl)                       ; 57EE
	cp #0x10                        ; 57EF
	jp nc,loc_5889                  ; 57F1
	ld h,a                          ; 57F4
	ld a,(tmp_d5)                   ; 57F5
	or a                            ; 57F8
	ld a,h                          ; 57F9
	jr nz,loc_5800                  ; 57FA
	sub #0x0f                       ; 57FC
	neg                             ; 57FE
loc_5800:
	ld c,a                          ; 5800
	call sub_5805                   ; 5801
	ret                             ; 5804

;; ---------------------------------------------------------------- $05805
;; classement : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
	.area _B01_5805
sub_5805:
	ld hl,(tmp_d3)                  ; 5805
	ld de,#pal_C124                 ; 5808
	add hl,de                       ; 580B
	dec (hl)                        ; 580C
	jp p,loc_585E                   ; 580D
	push hl                         ; 5810
	ld hl,(tmp_d3)                  ; 5811
	ld de,#pal_C144                 ; 5814
	add hl,de                       ; 5817
	ld a,(hl)                       ; 5818
	pop hl                          ; 5819
	ld (hl),a                       ; 581A
	ld hl,(tmp_d3)                  ; 581B
	ld de,#pal_C104                 ; 581E
	add hl,de                       ; 5821
	inc (hl)                        ; 5822
	ld hl,(tmp_d3)                  ; 5823
	add hl,hl                       ; 5826
	push hl                         ; 5827
	ld de,#pal_C05A                 ; 5828
	add hl,de                       ; 582B
	ld a,(hl)                       ; 582C
	inc hl                          ; 582D
	ld b,(hl)                       ; 582E
	pop hl                          ; 582F
	ld de,#0xc01a                   ; 5830
	add hl,de                       ; 5833
	ld (hl),a                       ; 5834
	inc hl                          ; 5835
	ld (hl),b                       ; 5836
	dec hl                          ; 5837
	ld a,(pal_C0D6)                 ; 5838
	or a                            ; 583B
	jr nz,loc_585F                  ; 583C
	rrd                             ; 583E
	and #0x0f                       ; 5840
	sub c                           ; 5842
	jr nc,loc_5846                  ; 5843
	xor a                           ; 5845
loc_5846:
	rrd                             ; 5846
	and #0x0f                       ; 5848
	sub c                           ; 584A
	jr nc,loc_584E                  ; 584B
	xor a                           ; 584D
loc_584E:
	rrd                             ; 584E
	inc hl                          ; 5850
	ld a,(hl)                       ; 5851
	and #0x0f                       ; 5852
	sub c                           ; 5854
	jr nc,loc_5858                  ; 5855
	xor a                           ; 5857
loc_5858:
	ld (hl),a                       ; 5858
	ld a,#0xff                      ; 5859
	ld (pal_C184),a                 ; 585B
loc_585E:
	ret                             ; 585E
loc_585F:
	rrd                             ; 585F
	and #0x0f                       ; 5861
	add a,c                         ; 5863
	cp #0x0f                        ; 5864
	jr c,loc_586A                   ; 5866
	ld a,#0x0f                      ; 5868
loc_586A:
	rrd                             ; 586A
	and #0x0f                       ; 586C
	add a,c                         ; 586E
	cp #0x0f                        ; 586F
	jr c,loc_5875                   ; 5871
	ld a,#0x0f                      ; 5873
loc_5875:
	rrd                             ; 5875
	inc hl                          ; 5877
	ld a,(hl)                       ; 5878
	and #0x0f                       ; 5879
	add a,c                         ; 587B
	cp #0x0f                        ; 587C
	jr c,loc_5882                   ; 587E
	ld a,#0x0f                      ; 5880
loc_5882:
	ld (hl),a                       ; 5882
	ld a,#0xff                      ; 5883
	ld (pal_C184),a                 ; 5885
	ret                             ; 5888
loc_5889:
	ld de,#pal_fx_table             ; 5889
	ld hl,(tmp_d3)                  ; 588C
	add hl,de                       ; 588F
	ld (hl),#0x00                   ; 5890
	ld hl,(tmp_d3)                  ; 5892
	ld de,#pal_C124                 ; 5895
	add hl,de                       ; 5898
	ld (hl),#0x00                   ; 5899
	ld hl,(tmp_d3)                  ; 589B
	ld de,#pal_C104                 ; 589E
	add hl,de                       ; 58A1
	ld (hl),#0x00                   ; 58A2
	ret                             ; 58A4

;; ---------------------------------------------------------------- $058A5
;; classement : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
	.area _B01_58A5
sub_58A5::
	push af                         ; 58A5
	ld a,#0x01                      ; 58A6
	ld (tmp_d3),a                   ; 58A8
	pop af                          ; 58AB
	jr loc_58D0                     ; 58AC

;; ---------------------------------------------------------------- $058AE
;; classement : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
	.area _B01_58AE
sub_58AE::
	push af                         ; 58AE
	ld a,#0x02                      ; 58AF
	ld (tmp_d3),a                   ; 58B1
	pop af                          ; 58B4
	jr loc_58D0                     ; 58B5

;; ---------------------------------------------------------------- $058B7
;; classement : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
	.area _B01_58B7
sub_58B7:
	push af                         ; 58B7
	ld a,#0x03                      ; 58B8
	ld (tmp_d3),a                   ; 58BA
	pop af                          ; 58BD
	jr loc_58D0                     ; 58BE

;; ---------------------------------------------------------------- $058C0
;; classement : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
	.area _B01_58C0
sub_58C0::
	push af                         ; 58C0
	ld a,#0x05                      ; 58C1
	ld (tmp_d3),a                   ; 58C3
	pop af                          ; 58C6
	jr loc_58D0                     ; 58C7

;; ---------------------------------------------------------------- $058C9
;; classement : effets de palette ($C0E4, 32 entrees) et fondus ($C0D3)
	.area _B01_58C9
sub_58C9::
	push af                         ; 58C9
	ld a,#0x06                      ; 58CA
	ld (tmp_d3),a                   ; 58CC
	pop af                          ; 58CF
loc_58D0:
	ld hl,#pal_C144                 ; 58D0
	ld bc,#0x001f                   ; 58D3
	ld de,#pal_C145                 ; 58D6
	ld (hl),a                       ; 58D9
	ldir                            ; 58DA
	ld a,(tmp_d3)                   ; 58DC
	ld hl,#pal_fx_table             ; 58DF
	ld de,#pal_C0E5                 ; 58E2
	ld bc,#0x001f                   ; 58E5
	ld (hl),a                       ; 58E8
	ldir                            ; 58E9
	cp #0x01                        ; 58EB
	jr z,loc_590A                   ; 58ED
	cp #0x05                        ; 58EF
	jr z,loc_5914                   ; 58F1
	cp #0x06                        ; 58F3
	jr nz,loc_58FF                  ; 58F5
	ld hl,#pal_C01A                 ; 58F7
	ld de,#pal_C05A                 ; 58FA
	jr loc_5905                     ; 58FD
loc_58FF:
	ld hl,#pal_C01A                 ; 58FF
	ld de,#pal_C05A                 ; 5902
loc_5905:
	ld bc,#0x0040                   ; 5905
	jr loc_591F                     ; 5908
loc_590A:
	ld hl,#pal_C01A                 ; 590A
	ld (hl),#0x00                   ; 590D
	ld de,#0xc01b                   ; 590F
	jr loc_591C                     ; 5912
loc_5914:
	ld hl,#pal_C01A                 ; 5914
	ld de,#0xc01b                   ; 5917
	ld (hl),#0xff                   ; 591A
loc_591C:
	ld bc,#0x003f                   ; 591C
loc_591F:
	ldir                            ; 591F
	ret                             ; 5921

;; ---------------------------------------------------------------- $05922
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5922
sub_5922:
	ld hl,#pal_C144                 ; 5922
	ld (hl),a                       ; 5925
	ld de,#pal_C145                 ; 5926
	ld bc,#0x000f                   ; 5929
	ldir                            ; 592C
	ld hl,#pal_fx_table             ; 592E
	ld (hl),#0x01                   ; 5931
	ld bc,#0x000f                   ; 5933
	ld de,#pal_C0E5                 ; 5936
	ldir                            ; 5939
	ld hl,#pal_C01A                 ; 593B
	ld (hl),#0x00                   ; 593E
	ld de,#0xc01b                   ; 5940
	ld bc,#0x001f                   ; 5943
	ldir                            ; 5946
	ret                             ; 5948
	.db 0x21                        ; 5949

;; ---------------------------------------------------------------- $0594A
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_594A
sub_594A:
	ld b,h                          ; 594A
	pop bc                          ; 594B
	ld (hl),a                       ; 594C
	ld de,#pal_C145                 ; 594D
	ld bc,#0x000f                   ; 5950
	ldir                            ; 5953
	ld hl,#pal_fx_table             ; 5955
	ld (hl),#0x02                   ; 5958
	ld bc,#0x000f                   ; 595A
	ld de,#pal_C0E5                 ; 595D
	ldir                            ; 5960
	ld hl,#pal_C01A                 ; 5962
	ld de,#pal_C05A                 ; 5965
	ld bc,#0x0020                   ; 5968
	ldir                            ; 596B
	ret                             ; 596D

;; ---------------------------------------------------------------- $0596E
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_596E
sub_596E:
	push af                         ; 596E
	ld a,#0x01                      ; 596F
	ld (tmp_d3),a                   ; 5971
	pop af                          ; 5974
	jr loc_5987                     ; 5975

;; ---------------------------------------------------------------- $05977
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5977
sub_5977:
	push af                         ; 5977
	ld a,#0x02                      ; 5978
	ld (tmp_d3),a                   ; 597A
	pop af                          ; 597D
	jr loc_5987                     ; 597E

;; ---------------------------------------------------------------- $05980
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_5980
sub_5980:
	push af                         ; 5980
	ld a,#0x03                      ; 5981
	ld (tmp_d3),a                   ; 5983
	pop af                          ; 5986
loc_5987:
	ld hl,#pal_C154                 ; 5987
	ld bc,#0x000f                   ; 598A
	ld de,#pal_C155                 ; 598D
	ld (hl),a                       ; 5990
	ldir                            ; 5991
	ld a,(tmp_d3)                   ; 5993
	ld hl,#pause_C0F4                 ; 5996
	ld de,#pal_C0F5                 ; 5999
	ld bc,#0x000f                   ; 599C
	ld (hl),a                       ; 599F
	ldir                            ; 59A0
	cp #0x02                        ; 59A2
	jr nz,loc_59B3                  ; 59A4
	ld hl,#pal_C03A                 ; 59A6
	ld de,#event_C07A                 ; 59A9
	ld bc,#0x0020                   ; 59AC
	ldir                            ; 59AF
	jr loc_59C0                     ; 59B1
loc_59B3:
	ld hl,#pal_C03A                 ; 59B3
	ld (hl),#0x00                   ; 59B6
	ld de,#0xc03b                   ; 59B8
	ld bc,#0x001f                   ; 59BB
	ldir                            ; 59BE
loc_59C0:
	ret                             ; 59C0
