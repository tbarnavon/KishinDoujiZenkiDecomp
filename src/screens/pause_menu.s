;; screens/pause_menu.s
;; Menu de pause (bouton Pause SMS / Start GG) : $1616.
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $01616
;; classement : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
	.area _B00_1616
sub_1616::
	ld a,(freeze_timer)             ; 1616
	or a                            ; 1619
	ret nz                          ; 161A
	ld a,(player_CEFC)                 ; 161B
	and #0x84                       ; 161E
	ret nz                          ; 1620
	ld a,(joypad_pressed)           ; 1621
.if VERSION_SMS_EN
	bit 6,a                         ; 1624
.else ; VERSION_GG_JP
	bit 7,a                         ; 1624
.endif
	ret z                           ; 1626
	ld hl,#game_flags               ; 1627
	set 6,(hl)                      ; 162A
	ld a,(player_state)             ; 162C
	cp #0xfd                        ; 162F
	jp z,loc_17A7                   ; 1631
	ld hl,#sprite_C8AF                 ; 1634
	ld de,#event_C8B0                 ; 1637
	ld (hl),#0x00                   ; 163A
	ld bc,#0x004f                   ; 163C
	ldir                            ; 163F
	call sub_05F8                   ; 1641
	call sub_6C26                   ; 1644
	call task_yield                 ; 1647
	ld a,#0x12                      ; 164A
	ld (bank_slot2_shadow),a        ; 164C
	ld (MAPPER_SLOT2),a             ; 164F  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b18_B468            ; 1652
	ld de,#VDP_VRAM_WRITE|0x0000    ; 1655
	call sub_46A1                   ; 1658
	ld iy,#pause_C8D7                 ; 165B
	ld a,#0x19                      ; 165F
	ld (bank_slot2_shadow),a        ; 1661
	ld (MAPPER_SLOT2),a             ; 1664  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#actors_BD21              ; 1667
	ld e,(hl)                       ; 166A
	inc hl                          ; 166B
	ld d,(hl)                       ; 166C
	ld (event_C8F2),de                ; 166D
	inc hl                          ; 1671
	ld a,(hl)                       ; 1672
	ld (sprite_C8D9),a                 ; 1673
	inc hl                          ; 1676
	ld a,(hl)                       ; 1677
	ld (sprite_C8DC),a                 ; 1678
	ld 0(iy),#0x01                  ; 167B
	call sub_05FE                   ; 167F
loc_1682:
	call sub_16DC                   ; 1682
	ld a,(joypad_pressed)           ; 1685
.if VERSION_SMS_EN
	bit 6,a                         ; 1688
.else ; VERSION_GG_JP
	bit 7,a                         ; 1688
.endif
	jr z,loc_1682                   ; 168A
	ld iy,#pause_C8D7                 ; 168C
	ld a,#0x19                      ; 1690
	ld (bank_slot2_shadow),a        ; 1692
	ld (MAPPER_SLOT2),a             ; 1695  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#actors_BD35              ; 1698
	ld e,(hl)                       ; 169B
	inc hl                          ; 169C
	ld d,(hl)                       ; 169D
	ld 27(iy),e                     ; 169E
	ld 28(iy),d                     ; 16A1
	ld 33(iy),#0x00                 ; 16A4
	ld 0(iy),#0x01                  ; 16A8
	call sub_16DC                   ; 16AC
	call sub_05FE                   ; 16AF
	ld a,#0x03                      ; 16B2
	call sub_0332                   ; 16B4
	call sub_0608                   ; 16B7
	ld a,#0x07                      ; 16BA
	ld (bank_slot2_shadow),a        ; 16BC
	ld (MAPPER_SLOT2),a             ; 16BF  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b07_BA1F            ; 16C2
	ld de,#VDP_VRAM_WRITE|0x0220    ; 16C5
	call sub_46A1                   ; 16C8
	ld hl,#game_flags               ; 16CB
	res 6,(hl)                      ; 16CE
	ld hl,#vdp_requests2            ; 16D0
	set 0,(hl)                      ; 16D3
	call sub_6C26                   ; 16D5
	call task_yield                 ; 16D8
	ret                             ; 16DB

;; ---------------------------------------------------------------- $016DC
;; classement : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
	.area _B00_16DC
sub_16DC:
	call task_yield                 ; 16DC
	ld iy,#pause_C8D7                 ; 16DF
	call sub_72B2                   ; 16E3
	ld hl,(player_C8D8)                ; 16E6
	ld de,(player_C8E7)                ; 16E9
	add hl,de                       ; 16ED
	ld (player_C8D8),hl                ; 16EE
	ld a,(pause_C8D7)                 ; 16F1
	or a                            ; 16F4
	jr nz,sub_16DC                  ; 16F5
	ret                             ; 16F7

;; ---------------------------------------------------------------- $016F8
;; classement : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
	.area _B00_16F8
sub_16F8::
	push bc                         ; 16F8
	push af                         ; 16F9
	push de                         ; 16FA
	ld b,#0x00                      ; 16FB
	ldir                            ; 16FD
	pop de                          ; 16FF
	pop af                          ; 1700
	push hl                         ; 1701
	ld l,a                          ; 1702
	ld h,#0x00                      ; 1703
	add hl,de                       ; 1705
	ex de,hl                        ; 1706
	pop hl                          ; 1707
	pop bc                          ; 1708
	djnz sub_16F8                   ; 1709
	ret                             ; 170B

;; ---------------------------------------------------------------- $0170C
;; classement : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
	.area _B00_170C
sub_170C::
	ld hl,#pal_C01A                 ; 170C
	ld de,#0xc01b                   ; 170F
	ld bc,#0x003f                   ; 1712
	ld (hl),#0x00                   ; 1715
	ldir                            ; 1717
	ld hl,#vdp_requests2            ; 1719
	set 6,(hl)                      ; 171C
	call task_yield                 ; 171E
	call sub_4616                   ; 1721
	ret                             ; 1724

;; ---------------------------------------------------------------- $01725
;; classement : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
	.area _B00_1725
sub_1725::
	ld hl,#pal_C01A                 ; 1725
	ld de,#0xc01b                   ; 1728
	ld bc,#0x003f                   ; 172B
	ld (hl),#0xff                   ; 172E
	ldir                            ; 1730
	ld hl,#vdp_requests2            ; 1732
	set 6,(hl)                      ; 1735
	call task_yield                 ; 1737
	call sub_4619                   ; 173A
	ret                             ; 173D

;; ---------------------------------------------------------------- $0173E
;; classement : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
	.area _B00_173E
sub_173E:
	call task_yield                 ; 173E
	call sub_574C                   ; 1741
	ld a,(pause_C0F4)                 ; 1744
	or a                            ; 1747
	jr nz,sub_173E                  ; 1748
	ret                             ; 174A

;; ---------------------------------------------------------------- $0174B
;; classement : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
	.area _B00_174B
sub_174B::
	call task_yield                 ; 174B
	call sub_574C                   ; 174E
	call sub_574C                   ; 1751
	call sub_574C                   ; 1754
	ld a,(pal_fx_table)             ; 1757
	or a                            ; 175A
	jr nz,sub_174B                  ; 175B
	ret                             ; 175D
loc_175E:
	ld a,#0x01                      ; 175E
sub_1760:
	call sub_1781                   ; 1760
	ret nz                          ; 1763
	call sub_574C                   ; 1764

;; ---------------------------------------------------------------- $01767
;; classement : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
	.area _B00_1767
sub_1767:
	ld a,(pal_fx_table)             ; 1767
	or a                            ; 176A
	jr nz,loc_175E                  ; 176B
	ret                             ; 176D

;; ---------------------------------------------------------------- $0176E
;; classement : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
	.area _B00_176E
sub_176E::
	call task_yield                 ; 176E
	call sub_0A64                   ; 1771
	call sub_574C                   ; 1774
	call sub_6C26                   ; 1777
	ld a,(pal_fx_table)             ; 177A
	or a                            ; 177D
	jr nz,sub_176E                  ; 177E
	ret                             ; 1780

;; ---------------------------------------------------------------- $01781
;; classement : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
	.area _B00_1781
sub_1781:
	push af                         ; 1781
	call task_yield                 ; 1782
	pop af                          ; 1785
	ld hl,#joypad_state             ; 1786
	bit 7,(hl)                      ; 1789
	ret nz                          ; 178B
	dec a                           ; 178C
	jr nz,sub_1781                  ; 178D
	ret                             ; 178F

;; ---------------------------------------------------------------- $01790
;; classement : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
	.area _B00_1790
sub_1790:
	push bc                         ; 1790
	call task_yield                 ; 1791
	pop bc                          ; 1794
	dec bc                          ; 1795
	ld a,c                          ; 1796
	or b                            ; 1797
	jr nz,sub_1790                  ; 1798
	ret                             ; 179A
data_179B::
	.db 0x50, 0x68, 0x68, 0x80, 0x50 ; 179B
	.db 0x98, 0x38                  ; 17A0
.if VERSION_SMS_EN
sub_17A2:
	.db 0x80                        ; 17A2
.else ; VERSION_GG_JP
sub_17A2:
	add a,b                         ; 17A2
.endif

;; ---------------------------------------------------------------- $017A3
;; classement : menu de pause : bouton Pause/Start, graphismes $B468 (banque 18), curseur (scripts actors_BD21/BD35)
	.area _B00_17A3
sub_17A3:
	inc bc                          ; 17A3
	ld bc,#0x0200                   ; 17A4
loc_17A7:
	ld hl,#player_CA17                 ; 17A7
	ld de,#pause_CA18                 ; 17AA
	ld (hl),#0x00                   ; 17AD
	ld bc,#0x00ef                   ; 17AF
	ldir                            ; 17B2
	call sub_223B                   ; 17B4
	call sub_05F8                   ; 17B7
	call sub_6C26                   ; 17BA
	call task_yield                 ; 17BD
	ld a,#0x12                      ; 17C0
	ld (bank_slot2_shadow),a        ; 17C2
	ld (MAPPER_SLOT2),a             ; 17C5  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b18_B468            ; 17C8
	ld de,#VDP_VRAM_WRITE|0x0000    ; 17CB
	call sub_46A1                   ; 17CE
	ld iy,#coll_CA67                 ; 17D1
	ld a,#0x19                      ; 17D5
	ld (bank_slot2_shadow),a        ; 17D7
	ld (MAPPER_SLOT2),a             ; 17DA  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#actors_BD21              ; 17DD
	ld hl,#0x0004                   ; 17E0
	add hl,de                       ; 17E3
	push hl                         ; 17E4
	pop ix                          ; 17E5
	ld b,#0x04                      ; 17E7
	call sub_18EE                   ; 17E9
	ld a,(flow_C1B6)                 ; 17EC
	bit 7,a                         ; 17EF
	ld a,#0x1f                      ; 17F1
	jr z,loc_17F7                   ; 17F3
	ld a,#0x1e                      ; 17F5
loc_17F7:
	ld (pause_CAE6),a                 ; 17F7
	ld iy,#pause_C8D7                 ; 17FA
	ld de,#actors_BD21              ; 17FE
	push de                         ; 1801
	pop ix                          ; 1802
	ld b,#0x01                      ; 1804
	call sub_18EE                   ; 1806
	ld de,#data_1A2C                ; 1809
	ld (pause_CA32),de                ; 180C
	ld (pause_CA5A),de                ; 1810
	call sub_0603                   ; 1814
	call sub_1963                   ; 1817
	ld a,#0x01                      ; 181A
	ld (pause_CA3F),a                 ; 181C
	ld de,#data_1A17                ; 181F
	ld (pause_CA5A),de                ; 1822
	ld a,(flow_C1B6)                 ; 1826
	and #0x03                       ; 1829
	call sub_193C                   ; 182B
	ld de,#data_1A0E                ; 182E
	ld (pause_CA32),de                ; 1831
loc_1835:
	call sub_1963                   ; 1835
	ld a,(joypad_pressed)           ; 1838
	and #0xa0                       ; 183B
	jr nz,loc_187E                  ; 183D
	ld a,(joypad_state)             ; 183F
	call sub_1380                   ; 1842
	or a                            ; 1845
	jr z,loc_1835                   ; 1846
	dec a                           ; 1848
	ld l,a                          ; 1849
	ld h,#0x00                      ; 184A
	ld de,#sub_17A3                 ; 184C
	add hl,de                       ; 184F
	ld a,(flow_C1B6)                 ; 1850
	and #0x03                       ; 1853
	cp (hl)                         ; 1855
	jr z,loc_1835                   ; 1856
	ld b,(hl)                       ; 1858
	ld hl,#flow_C1B6                 ; 1859
	ld a,(hl)                       ; 185C
	and #0x80                       ; 185D
	or b                            ; 185F
	ld (hl),a                       ; 1860
	call sub_193C                   ; 1861
	ld de,#data_1A17                ; 1864
	ld (pause_CA5A),de                ; 1867
	ld de,#data_1A0E                ; 186B
	ld (pause_CA32),de                ; 186E
	xor a                           ; 1872
	ld (pause_CA60),a                 ; 1873
	ld (pause_CA38),a                 ; 1876
	call sub_04FB                   ; 1879
	jr loc_1835                     ; 187C
loc_187E:
	call sub_19B7                   ; 187E
	ld a,#0x19                      ; 1881
	ld (bank_slot2_shadow),a        ; 1883
	ld (MAPPER_SLOT2),a             ; 1886  mapper : banque du slot 2 ($8000-$BFFF)
	xor a                           ; 1889
	ld (pause_CA46),a                 ; 188A
	ld (pause_CA1E),a                 ; 188D
	ld (pause_CA3F),a                 ; 1890
	ld (player_CA17),a                 ; 1893
	ld de,#data_1A2C                ; 1896
	ld (pause_CA5A),de                ; 1899
	ld (pause_CA32),de                ; 189D
	ld iy,#coll_CA67                 ; 18A1
	ld de,#actors_BD35              ; 18A5
	inc de                          ; 18A8
	inc de                          ; 18A9
	push de                         ; 18AA
	pop ix                          ; 18AB
	ld b,#0x04                      ; 18AD
	call sub_191B                   ; 18AF
	ld iy,#pause_C8D7                 ; 18B2
	ld de,#actors_BD35              ; 18B6
	push de                         ; 18B9
	pop ix                          ; 18BA
	ld b,#0x01                      ; 18BC
	call sub_191B                   ; 18BE
	call sub_1963                   ; 18C1
	call sub_0603                   ; 18C4
	ld a,#0x03                      ; 18C7
	call sub_0332                   ; 18C9
	call sub_0608                   ; 18CC
	ld a,#0x07                      ; 18CF
	ld (bank_slot2_shadow),a        ; 18D1
	ld (MAPPER_SLOT2),a             ; 18D4  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b07_BA1F            ; 18D7
	ld de,#VDP_VRAM_WRITE|0x0220    ; 18DA
	call sub_46A1                   ; 18DD
	ld hl,#game_flags               ; 18E0
	res 6,(hl)                      ; 18E3
	ld hl,#vdp_requests2            ; 18E5
	set 0,(hl)                      ; 18E8
	call task_yield                 ; 18EA
	ret                             ; 18ED
