;; game/stage_events.s
;; Evenements de niveau (tache 4) : declencheurs $C1E1, handlers $0B3D.
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $004F1
;; classement : atteinte uniquement par task4
	.area _B00_04F1
sub_04F1:
	ld a,#0xa2                      ; 04F1
	jp loc_060D                     ; 04F3

;; ---------------------------------------------------------------- $004F6
;; classement : atteinte uniquement par task4
	.area _B00_04F6
sub_04F6:
	ld a,#0xb1                      ; 04F6
	jp loc_060D                     ; 04F8

;; ---------------------------------------------------------------- $00500
;; classement : atteinte uniquement par tbl_0B3D
	.area _B00_0500
sub_0500:
	ld a,#0xb4                      ; 0500
	jp loc_060D                     ; 0502

;; ---------------------------------------------------------------- $00537
;; classement : atteinte uniquement par task4
	.area _B00_0537
sub_0537:
	ld a,#0xb2                      ; 0537
	jp loc_0627                     ; 0539

;; ---------------------------------------------------------------- $00653
;; classement : atteinte uniquement par tbl_0B3D
	.area _B00_0653
sub_0653::
	ld a,#0xa7                      ; 0653
	jr loc_0627                     ; 0655

;; ---------------------------------------------------------------- $00657
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0657
sub_0657:
	ld a,#0x8b                      ; 0657
	jr sub_062D                     ; 0659

;; ---------------------------------------------------------------- $0065B
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_065B
sub_065B:
	ld a,#0x8c                      ; 065B
	jr sub_062D                     ; 065D

;; ---------------------------------------------------------------- $0065F
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_065F
sub_065F:
	ld a,#0x88                      ; 065F
	jr sub_062D                     ; 0661

;; ---------------------------------------------------------------- $00663
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0663
sub_0663:
	ld a,#0x87                      ; 0663
	jr sub_062D                     ; 0665

;; ---------------------------------------------------------------- $00667
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0667
sub_0667:
	ld a,#0x8d                      ; 0667
	jr sub_062D                     ; 0669

;; ---------------------------------------------------------------- $00B20
;; classement : atteinte uniquement par tbl_0B3D
	.area _B00_0B20
sub_0B20:
	ld b,a                          ; 0B20
loc_0B21:
	push bc                         ; 0B21
	call task_yield                 ; 0B22
	call sub_574C                   ; 0B25
	call sub_1573                   ; 0B28
	ld hl,#vdp_requests2            ; 0B2B
	set 7,(hl)                      ; 0B2E
	call sub_1356                   ; 0B30
	call sub_5A52                   ; 0B33
	call sub_59C1                   ; 0B36
	pop bc                          ; 0B39
	djnz loc_0B21                   ; 0B3A
	ret                             ; 0B3C
jt_0B3D:
	.dw loc_0B5F                    ; 0B3D
	.dw loc_0B8E                    ; 0B3F
	.dw loc_0BD7                    ; 0B41
	.dw loc_0C04                    ; 0B43
	.dw loc_0C1B                    ; 0B45
	.dw loc_0C77                    ; 0B47
	.dw loc_0CA4                    ; 0B49
	.dw loc_0D10                    ; 0B4B
	.dw loc_0D3D                    ; 0B4D
	.dw loc_0D6A                    ; 0B4F
	.dw loc_0D81                    ; 0B51
	.dw loc_0DC9                    ; 0B53
	.dw loc_0E05                    ; 0B55
	.dw loc_0E48                    ; 0B57
	.dw loc_0E8A                    ; 0B59
	.dw loc_0BAA                    ; 0B5B
	.dw loc_0CE3                    ; 0B5D
loc_0B5F:
	ld hl,#event_CFB5                 ; 0B5F
	ld a,#0x9a                      ; 0B62
	ld (hl),a                       ; 0B64
	call sub_48DA                   ; 0B65
	call sub_0500                   ; 0B68
	ld a,#0x14                      ; 0B6B
	call sub_0B20                   ; 0B6D
	ld hl,#event_CFB6                 ; 0B70
	ld a,#0x9b                      ; 0B73
	ld (hl),a                       ; 0B75
	call sub_48DA                   ; 0B76
	call sub_0500                   ; 0B79
	ld a,#0x14                      ; 0B7C
	call sub_0B20                   ; 0B7E
	ld hl,#flow_C1A2                 ; 0B81
	set 2,(hl)                      ; 0B84
	ld hl,#flow_C1A1                 ; 0B86
	set 3,(hl)                      ; 0B89
	set 4,(hl)                      ; 0B8B
	ret                             ; 0B8D
loc_0B8E:
	ld hl,#event_CFA3                 ; 0B8E
	ld a,#0x98                      ; 0B91
	ld (hl),a                       ; 0B93
	call sub_48DA                   ; 0B94
	call sub_0500                   ; 0B97
	ld a,#0x14                      ; 0B9A
	call sub_0B20                   ; 0B9C
	ld hl,#flow_C1A2                 ; 0B9F
	set 0,(hl)                      ; 0BA2
	ld hl,#event_C1A3                 ; 0BA4
	set 1,(hl)                      ; 0BA7
	ret                             ; 0BA9
loc_0BAA:
	ld hl,#event_CF8E                 ; 0BAA
	ld a,#0x9f                      ; 0BAD
	ld (hl),a                       ; 0BAF
	call sub_48DA                   ; 0BB0
	call sub_0500                   ; 0BB3
	ld a,#0x14                      ; 0BB6
	call sub_0B20                   ; 0BB8
	ld hl,#event_CF8D                 ; 0BBB
	ld a,#0x9e                      ; 0BBE
	ld (hl),a                       ; 0BC0
	call sub_48DA                   ; 0BC1
	call sub_0500                   ; 0BC4
	ld a,#0x14                      ; 0BC7
	call sub_0B20                   ; 0BC9
	ld hl,#event_C1A3                 ; 0BCC
	set 2,(hl)                      ; 0BCF
	ld hl,#event_C1A4                 ; 0BD1
	set 1,(hl)                      ; 0BD4
	ret                             ; 0BD6
loc_0BD7:
	ld hl,#event_CF90                 ; 0BD7
	ld a,#0xa0                      ; 0BDA
	ld (hl),a                       ; 0BDC
	call sub_48DA                   ; 0BDD
	call sub_0500                   ; 0BE0
	ld a,#0x14                      ; 0BE3
	call sub_0B20                   ; 0BE5
	ld hl,#event_CF7C                 ; 0BE8
	ld a,#0x95                      ; 0BEB
	ld (hl),a                       ; 0BED
	call sub_48DA                   ; 0BEE
	call sub_0500                   ; 0BF1
	ld a,#0x14                      ; 0BF4
	call sub_0B20                   ; 0BF6
	ld hl,#event_C1A3                 ; 0BF9
	set 3,(hl)                      ; 0BFC
	ld hl,#event_C1A5                 ; 0BFE
	set 1,(hl)                      ; 0C01
	ret                             ; 0C03
loc_0C04:
	ld hl,#event_CF79                 ; 0C04
	ld a,#0x8c                      ; 0C07
	ld (hl),a                       ; 0C09
	call sub_48DA                   ; 0C0A
	call sub_0500                   ; 0C0D
	ld a,#0x14                      ; 0C10
	call sub_0B20                   ; 0C12
	ld hl,#event_C1A4                 ; 0C15
	set 4,(hl)                      ; 0C18
	ret                             ; 0C1A
loc_0C1B:
	ld hl,#event_CF67                 ; 0C1B
	ld a,#0x90                      ; 0C1E
	ld (hl),a                       ; 0C20
	inc hl                          ; 0C21
	ld a,#0x91                      ; 0C22
	ld (hl),a                       ; 0C24
	inc hl                          ; 0C25
	ld a,#0x92                      ; 0C26
	ld (hl),a                       ; 0C28
	call sub_48DA                   ; 0C29
	call sub_0653                   ; 0C2C
	ld a,#0x28                      ; 0C2F
	call sub_0B20                   ; 0C31
	ld hl,#event_CF54                 ; 0C34
	ld a,#0x8e                      ; 0C37
	ld (hl),a                       ; 0C39
	call sub_48DA                   ; 0C3A
	call sub_0500                   ; 0C3D
	ld a,#0x14                      ; 0C40
	call sub_0B20                   ; 0C42
	ld hl,#event_CF40                 ; 0C45
	ld a,#0x83                      ; 0C48
	ld (hl),a                       ; 0C4A
	call sub_48DA                   ; 0C4B
	call sub_0500                   ; 0C4E
	ld a,#0x14                      ; 0C51
	call sub_0B20                   ; 0C53
	ld hl,#event_CF41                 ; 0C56
	ld a,#0x84                      ; 0C59
	ld (hl),a                       ; 0C5B
	call sub_48DA                   ; 0C5C
	call sub_0500                   ; 0C5F
	ld a,#0x14                      ; 0C62
	call sub_0B20                   ; 0C64
	ld hl,#event_C1A5                 ; 0C67
	set 0,(hl)                      ; 0C6A
	ld hl,#event_C1A6                 ; 0C6C
	set 2,(hl)                      ; 0C6F
	ld hl,#event_C1A5                 ; 0C71
	set 4,(hl)                      ; 0C74
	ret                             ; 0C76
loc_0C77:
	ld hl,#event_CF43                 ; 0C77
	ld a,#0x85                      ; 0C7A
	ld (hl),a                       ; 0C7C
	call sub_48DA                   ; 0C7D
	call sub_0500                   ; 0C80
	ld a,#0x14                      ; 0C83
	call sub_0B20                   ; 0C85
	ld hl,#event_CF44                 ; 0C88
	ld a,#0xa2                      ; 0C8B
	ld (hl),a                       ; 0C8D
	call sub_48DA                   ; 0C8E
	call sub_0500                   ; 0C91
	ld a,#0x14                      ; 0C94
	call sub_0B20                   ; 0C96
	ld hl,#event_C1A6                 ; 0C99
	set 3,(hl)                      ; 0C9C
	ld hl,#event_C1A7                 ; 0C9E
	set 2,(hl)                      ; 0CA1
	ret                             ; 0CA3
loc_0CA4:
	ld hl,#ascript_CF30                 ; 0CA4
	ld a,#0x80                      ; 0CA7
	ld (hl),a                       ; 0CA9
	ld hl,#event_CF31                 ; 0CAA
	ld a,#0x81                      ; 0CAD
	ld (hl),a                       ; 0CAF
	ld hl,#event_CF32                 ; 0CB0
	ld a,#0x82                      ; 0CB3
	ld (hl),a                       ; 0CB5
	ld hl,#event_CF44                 ; 0CB6
	ld a,#0x86                      ; 0CB9
	ld (hl),a                       ; 0CBB
	ld hl,#event_CF45                 ; 0CBC
	ld a,#0x87                      ; 0CBF
	ld (hl),a                       ; 0CC1
	ld hl,#event_CF46                 ; 0CC2
	ld a,#0x94                      ; 0CC5
	ld (hl),a                       ; 0CC7
	call sub_48DA                   ; 0CC8
	call sub_0653                   ; 0CCB
	ld a,#0x28                      ; 0CCE
	call sub_0B20                   ; 0CD0
	ld hl,#event_C1A7                 ; 0CD3
	set 3,(hl)                      ; 0CD6
	ld hl,#event_C1A8                 ; 0CD8
	set 2,(hl)                      ; 0CDB
	ld hl,#event_C1A7                 ; 0CDD
	set 4,(hl)                      ; 0CE0
	ret                             ; 0CE2
loc_0CE3:
	ld hl,#event_CF48                 ; 0CE3
	ld a,#0x88                      ; 0CE6
	ld (hl),a                       ; 0CE8
	call sub_48DA                   ; 0CE9
	call sub_0500                   ; 0CEC
	ld a,#0x14                      ; 0CEF
	call sub_0B20                   ; 0CF1
	ld hl,#flow_CF49                 ; 0CF4
	ld a,#0x89                      ; 0CF7
	ld (hl),a                       ; 0CF9
	call sub_48DA                   ; 0CFA
	call sub_0500                   ; 0CFD
	ld a,#0x14                      ; 0D00
	call sub_0B20                   ; 0D02
	ld hl,#event_C1A8                 ; 0D05
	set 3,(hl)                      ; 0D08
	ld hl,#event_C1A9                 ; 0D0A
	set 2,(hl)                      ; 0D0D
	ret                             ; 0D0F
loc_0D10:
	ld hl,#event_CF5B                 ; 0D10
	ld a,#0x8f                      ; 0D13
	ld (hl),a                       ; 0D15
	call sub_48DA                   ; 0D16
	call sub_0500                   ; 0D19
	ld a,#0x14                      ; 0D1C
	call sub_0B20                   ; 0D1E
	ld hl,#event_CF6F                 ; 0D21
	ld a,#0x93                      ; 0D24
	ld (hl),a                       ; 0D26
	call sub_48DA                   ; 0D27
	call sub_0500                   ; 0D2A
	ld a,#0x14                      ; 0D2D
	call sub_0B20                   ; 0D2F
	ld hl,#event_C1A8                 ; 0D32
	set 1,(hl)                      ; 0D35
	ld hl,#event_C1AB                 ; 0D37
	set 0,(hl)                      ; 0D3A
	ret                             ; 0D3C
loc_0D3D:
	ld hl,#event_CF4A                 ; 0D3D
	ld a,#0x8a                      ; 0D40
	ld (hl),a                       ; 0D42
	call sub_48DA                   ; 0D43
	call sub_0500                   ; 0D46
	ld a,#0x14                      ; 0D49
	call sub_0B20                   ; 0D4B
	ld hl,#event_CF4B                 ; 0D4E
	ld a,#0x8b                      ; 0D51
	ld (hl),a                       ; 0D53
	call sub_48DA                   ; 0D54
	call sub_0500                   ; 0D57
	ld a,#0x14                      ; 0D5A
	call sub_0B20                   ; 0D5C
	ld hl,#event_C1A9                 ; 0D5F
	set 3,(hl)                      ; 0D62
	ld hl,#event_C1AA                 ; 0D64
	set 2,(hl)                      ; 0D67
	ret                             ; 0D69
loc_0D6A:
	ld hl,#event_CF4C                 ; 0D6A
	ld a,#0x8c                      ; 0D6D
	ld (hl),a                       ; 0D6F
	call sub_48DA                   ; 0D70
	call sub_0500                   ; 0D73
	ld a,#0x28                      ; 0D76
	call sub_0B20                   ; 0D78
	ld hl,#event_C1AA                 ; 0D7B
	set 4,(hl)                      ; 0D7E
	ret                             ; 0D80
loc_0D81:
	ld hl,#event_CF83                 ; 0D81
	ld a,#0x8c                      ; 0D84
	ld (hl),a                       ; 0D86
	call sub_48DA                   ; 0D87
	call sub_0500                   ; 0D8A
	ld a,#0x28                      ; 0D8D
	call sub_0B20                   ; 0D8F
	ld hl,#event_CF82                 ; 0D92
	ld a,#0x97                      ; 0D95
	ld (hl),a                       ; 0D97
	call sub_48DA                   ; 0D98
	call sub_0500                   ; 0D9B
	ld a,#0x14                      ; 0D9E
	call sub_0B20                   ; 0DA0
	ld hl,#event_CF81                 ; 0DA3
	ld a,#0x96                      ; 0DA6
	ld (hl),a                       ; 0DA8
	call sub_48DA                   ; 0DA9
	call sub_0500                   ; 0DAC
	ld a,#0x14                      ; 0DAF
	call sub_0B20                   ; 0DB1
	ld hl,#event_C1AB                 ; 0DB4
	set 2,(hl)                      ; 0DB7
	ld hl,#event_C1AC                 ; 0DB9
	set 3,(hl)                      ; 0DBC
	ld hl,#event_C1AB                 ; 0DBE
	set 4,(hl)                      ; 0DC1
	ld hl,#event_C010                 ; 0DC3
	set 7,(hl)                      ; 0DC6
	ret                             ; 0DC8
loc_0DC9:
	ld hl,#event_CF94                 ; 0DC9
	ld a,#0xa1                      ; 0DCC
	ld (hl),a                       ; 0DCE
	call sub_48DA                   ; 0DCF
	call sub_0500                   ; 0DD2
	ld a,#0x14                      ; 0DD5
	call sub_0B20                   ; 0DD7
	ld hl,#event_CFA8                 ; 0DDA
	ld a,#0x99                      ; 0DDD
	ld (hl),a                       ; 0DDF
	call sub_48DA                   ; 0DE0
	call sub_0500                   ; 0DE3
	ld a,#0x14                      ; 0DE6
	call sub_0B20                   ; 0DE8
	ld hl,#event_C1AC                 ; 0DEB
	set 1,(hl)                      ; 0DEE
	ld hl,#event_C1AD                 ; 0DF0
	set 0,(hl)                      ; 0DF3
	ld hl,#flow_C1B6                 ; 0DF5
	set 7,(hl)                      ; 0DF8
	ld hl,#event_C010                 ; 0DFA
	res 7,(hl)                      ; 0DFD
	ld hl,#event_C1AC                 ; 0DFF
	set 4,(hl)                      ; 0E02
	ret                             ; 0E04
loc_0E05:
	ld hl,#event_CFBC                 ; 0E05
	ld a,#0x8c                      ; 0E08
	ld (hl),a                       ; 0E0A
	call sub_48DA                   ; 0E0B
	call sub_0500                   ; 0E0E
	ld a,#0x28                      ; 0E11
	call sub_0B20                   ; 0E13
	ld hl,#event_CFBD                 ; 0E16
	ld a,#0x8b                      ; 0E19
	ld (hl),a                       ; 0E1B
	call sub_48DA                   ; 0E1C
	call sub_0500                   ; 0E1F
	ld a,#0x14                      ; 0E22
	call sub_0B20                   ; 0E24
	ld hl,#event_CFBE                 ; 0E27
	ld a,#0x8b                      ; 0E2A
	ld (hl),a                       ; 0E2C
	call sub_48DA                   ; 0E2D
	call sub_0500                   ; 0E30
	ld a,#0x14                      ; 0E33
	call sub_0B20                   ; 0E35
	ld hl,#event_C1AD                 ; 0E38
	set 3,(hl)                      ; 0E3B
	ld hl,#event_C1AE                 ; 0E3D
	set 2,(hl)                      ; 0E40
	ld hl,#event_C1AD                 ; 0E42
	set 4,(hl)                      ; 0E45
	ret                             ; 0E47
loc_0E48:
	ld hl,#event_CFBF                 ; 0E48
	ld a,#0x8c                      ; 0E4B
	ld (hl),a                       ; 0E4D
	call sub_48DA                   ; 0E4E
	call sub_0500                   ; 0E51
	ld a,#0x28                      ; 0E54
	call sub_0B20                   ; 0E56
	ld hl,#event_CFC0                 ; 0E59
	ld a,#0x9c                      ; 0E5C
	ld (hl),a                       ; 0E5E
	call sub_48DA                   ; 0E5F
	call sub_0500                   ; 0E62
	ld a,#0x14                      ; 0E65
	call sub_0B20                   ; 0E67
	ld hl,#event_CFC1                 ; 0E6A
	ld a,#0x9d                      ; 0E6D
	ld (hl),a                       ; 0E6F
	call sub_48DA                   ; 0E70
	call sub_0500                   ; 0E73
	ld a,#0x14                      ; 0E76
	call sub_0B20                   ; 0E78
	ld hl,#event_C1AE                 ; 0E7B
	set 3,(hl)                      ; 0E7E
	ld hl,#event_C1AF                 ; 0E80
	set 2,(hl)                      ; 0E83
	ld hl,#event_C1AE                 ; 0E85
	set 4,(hl)                      ; 0E88
loc_0E8A:
	ret                             ; 0E8A
data_0E8B:
	.db 0x03, 0x00, 0x00, 0x00, 0x08 ; 0E8B
data_0E90:
	.db 0x09, 0x00, 0x00, 0x00, 0x08 ; 0E90
data_0E95:
	.db 0xfd, 0xc9, 0x00, 0xf6      ; 0E95
data_0E99:
	.db 0x03, 0x00, 0x00, 0x00, 0xf8 ; 0E99
data_0E9E:
	.db 0x09, 0x00                  ; 0E9E
	.db 0x00, 0x00, 0xf8, 0x00, 0x95, 0x0e ; 0EA0
data_0EA6:
	.db 0xfd, 0x0c, 0x02, 0x00, 0x95, 0x0e ; 0EA6
data_0EAC:
	.db 0xfd, 0x0c, 0x0e, 0x00      ; 0EAC
	.db 0x95, 0x0e                  ; 0EB0
data_0EB2:
	.db 0x06, 0x79, 0xa3, 0x06, 0x99, 0xa3, 0x06, 0xb9, 0xa3, 0x06, 0x79, 0xa3, 0x06, 0x99 ; 0EB2
	.db 0xa3, 0x06, 0xb9, 0xa3, 0x06, 0x79, 0xa3, 0x06, 0x99, 0xa3, 0x06, 0xb9, 0xa3, 0x06, 0x19, 0xa4 ; 0EC0
	.db 0x06, 0xf9, 0xa3, 0x06, 0xd9, 0xa3, 0x06, 0xb9, 0xa3, 0xff, 0xb2, 0x0e ; 0ED0
data_0EDC:
	.db 0x06, 0x59, 0xa4, 0x06      ; 0EDC
	.db 0x39, 0xa4, 0xff, 0xdc, 0x0e ; 0EE0
data_0EE5:
	.db 0x06, 0x79, 0xa4, 0x06, 0x39, 0xa4, 0xff, 0xe5, 0x0e ; 0EE5
data_0EEE:
	.db 0x02, 0x06                  ; 0EEE
	.db 0x07, 0xb1, 0xa6, 0xc0, 0x6f, 0x04, 0x07, 0x07, 0x92, 0xa4, 0x00, 0x64, 0x02, 0x06, 0x07, 0x1a ; 0EF0
	.db 0xa7, 0xc0, 0x6f, 0x04, 0x07, 0x07, 0xa1, 0xa5, 0x00, 0x64, 0x02, 0x06, 0x07, 0x83, 0xa7, 0xc0 ; 0F00
	.db 0x6f, 0xff, 0xee, 0x0e      ; 0F10
data_0F14:
	.db 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07, 0x07 ; 0F14
	.db 0x07, 0x07, 0x07            ; 0F20
data_0F23:
	.db 0x88, 0x50, 0x88, 0x78, 0x68, 0x78, 0x58, 0x58, 0x48, 0x88, 0x28, 0x6c, 0x28 ; 0F23
	.db 0x6c, 0x28, 0x6c, 0x28, 0x81, 0x28, 0xa9, 0x58, 0x93, 0x58, 0x93, 0x88, 0x93, 0x88, 0x6c, 0x88 ; 0F30
	.db 0x89                        ; 0F40
data_0F41:
	.db 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0xff ; 0F41

;; ---------------------------------------------------------------- $00F4C
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0F4C
sub_0F4C:
	rst 0x38                        ; 0F4C
	nop                             ; 0F4D

;; ---------------------------------------------------------------- $00F4E
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0F4E
sub_0F4E:
	nop                             ; 0F4E
	rst 0x38                        ; 0F4F

;; ---------------------------------------------------------------- $00F50
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0F50
sub_0F50:
	rst 0x38                        ; 0F50
	nop                             ; 0F51

;; ---------------------------------------------------------------- $00F52
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0F52
sub_0F52:
	nop                             ; 0F52
	rst 0x38                        ; 0F53

;; ---------------------------------------------------------------- $00F54
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0F54
sub_0F54:
	rst 0x38                        ; 0F54
	nop                             ; 0F55

;; ---------------------------------------------------------------- $00F56
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0F56
sub_0F56:
	nop                             ; 0F56
	jp loc_00FF                     ; 0F57
	.db 0x00, 0x93, 0xff, 0x00, 0x00, 0x73 ; 0F5A
	.db 0xff, 0x00, 0x00, 0x60, 0xff, 0x00, 0x00, 0x60, 0xff, 0x00, 0x00, 0x9a, 0xff, 0x00, 0x00, 0xca ; 0F60
	.db 0xff, 0x00, 0x00, 0xca, 0xff, 0x00, 0x00, 0x73, 0xff, 0x00, 0x00, 0x60, 0xff ; 0F70
data_0F7D:
	.db 0x40, 0x8b, 0xa0            ; 0F7D
	.db 0x5e, 0x07, 0x00, 0xec, 0xa7, 0x80, 0x40, 0x07, 0x00, 0x56, 0xa8, 0x00, 0x41, 0x07, 0x00, 0xbe ; 0F80
	.db 0xa8, 0x80, 0x41, 0x07, 0x00, 0x28, 0xa9, 0x00, 0x42, 0x07, 0x00, 0x92, 0xa9, 0x80, 0x42, 0x07 ; 0F90
	.db 0x00, 0xfc, 0xa9, 0x00, 0x43, 0x07, 0x00, 0xff, 0xff ; 0FA0

;; ---------------------------------------------------------------- $00FA9
;; classement : atteinte uniquement par task4
	.area _B00_0FA9
sub_0FA9::
	xor a                           ; 0FA9
	ld (coll_C0D0),a                 ; 0FAA
	ld (player_C1F2),a                 ; 0FAD
	ld a,#0x03                      ; 0FB0
	ld (player_CEFE),a                 ; 0FB2
	call sub_139B                   ; 0FB5
	call sub_15BB                   ; 0FB8
	ld hl,#0x0000                   ; 0FBB
	ld (raster_ptr),hl              ; 0FBE
	ld hl,#vdp_requests2            ; 0FC1
	set 5,(hl)                      ; 0FC4
	call task_yield                 ; 0FC6
	call sub_0050                   ; 0FC9
	ld a,#0x01                      ; 0FCC
	call sub_58A5                   ; 0FCE
	ld a,#0x32                      ; 0FD1
	ld (freeze_timer),a             ; 0FD3
loc_0FD6:
	call task_yield                 ; 0FD6
	call sub_574C                   ; 0FD9
	call sub_1356                   ; 0FDC
	ld a,(freeze_timer)             ; 0FDF
	or a                            ; 0FE2
	jr nz,loc_105C                  ; 0FE3
	ld a,(joypad_pressed)           ; 0FE5
	call sub_1380                   ; 0FE8
	ld (tmp_d3),a                   ; 0FEB
	ld iy,#player_state             ; 0FEE
	ld hl,#0x0000                   ; 0FF2
	ld (player_CF01),hl                ; 0FF5
	call sub_72B2                   ; 0FF8
	ld hl,(player_CF11)                ; 0FFB
	ld (player_CF01),hl                ; 0FFE
	ld hl,(player_CF01)                ; 1001
	ld a,(player_CF21)                 ; 1004
	push af                         ; 1007
	ld a,l                          ; 1008
	or h                            ; 1009
	jr z,loc_1017                   ; 100A
	bit 7,h                         ; 100C
	ld a,#0x00                      ; 100E
	jr z,loc_1014                   ; 1010
	ld a,#0x01                      ; 1012
loc_1014:
	ld (player_CF21),a                 ; 1014
loc_1017:
	pop bc                          ; 1017
	ld a,(player_CF21)                 ; 1018
	cp b                            ; 101B
	jr z,loc_1022                   ; 101C
	xor a                           ; 101E
	ld (scroll_C19E),a                 ; 101F
loc_1022:
	call sub_2C7B                   ; 1022
	call sub_225F                   ; 1025
	ld hl,(scroll_x)                ; 1028
	push hl                         ; 102B
	ld hl,(scroll_y)                ; 102C
	push hl                         ; 102F
	call sub_5606                   ; 1030
	call sub_55A8                   ; 1033
	pop hl                          ; 1036
	pop de                          ; 1037
	call sub_1BC9                   ; 1038
	call sub_1592                   ; 103B
	ld a,(joypad_pressed)           ; 103E
	bit 5,a                         ; 1041
	jr z,loc_105C                   ; 1043
	ld a,(player_CEF6)                 ; 1045
	cp #0x04                        ; 1048
	jr nz,loc_105C                  ; 104A
	ld hl,(flow_C1A0)                ; 104C
	ld h,#0x00                      ; 104F
	ld de,#flow_C1A1                 ; 1051
	add hl,de                       ; 1054
	bit 4,(hl)                      ; 1055
	jr z,loc_1070                   ; 1057
	call sub_0537                   ; 1059
loc_105C:
	call sub_5A52                   ; 105C
	call sub_59C1                   ; 105F
	call sub_1573                   ; 1062
	call sub_15AA                   ; 1065
	ld hl,#vdp_requests2            ; 1068
	set 7,(hl)                      ; 106B
	jp loc_0FD6                     ; 106D
loc_1070:
	call sub_1294                   ; 1070
	ld a,#0x14                      ; 1073
	ld (freeze_timer),a             ; 1075
loc_1078:
	call sub_1236                   ; 1078
	call sub_5A0F                   ; 107B
	ld a,(joypad_pressed)           ; 107E
	bit 4,a                         ; 1081
	jp z,loc_110C                   ; 1083
	ld hl,#data_0E9E                ; 1086
	ld a,(event_C010)                 ; 1089
	bit 7,a                         ; 108C
	jr z,loc_1093                   ; 108E
	ld hl,#data_0E99                ; 1090
loc_1093:
	ld (event_C8CA),hl                ; 1093
	ld hl,#data_0E90                ; 1096
	ld (event_C8F2),hl                ; 1099
	xor a                           ; 109C
	ld (event_C8D0),a                 ; 109D
	ld (event_C8F8),a                 ; 10A0
	ld a,#0x14                      ; 10A3
	ld (freeze_timer),a             ; 10A5
	call sub_04F1                   ; 10A8
	call sub_1236                   ; 10AB
	ld a,(event_C8B6)                 ; 10AE
	cp #0x15                        ; 10B1
	ld a,#0xff                      ; 10B3
	jr z,loc_10B9                   ; 10B5
	ld a,#0xfe                      ; 10B7
loc_10B9:
	ld (player_state),a             ; 10B9
	ld iy,#player_state             ; 10BC
	ld 9(iy),#0x00                  ; 10C0
	ld 8(iy),#0x00                  ; 10C4
	ld 10(iy),#0x00                 ; 10C8
	ld a,#0x02                      ; 10CC
	ld (bank_slot2_shadow),a        ; 10CE
	ld (MAPPER_SLOT2),a             ; 10D1  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b02_A379            ; 10D4
	ld de,#0xc01a                   ; 10D7
	ld bc,#0x0020                   ; 10DA
	ldir                            ; 10DD
	ld hl,#data_b02_A439            ; 10DF
	ld de,#0xc03a                   ; 10E2
	ld bc,#0x0020                   ; 10E5
	ldir                            ; 10E8
	ld hl,#data_b02_A439            ; 10EA
	ld de,#event_C07A                 ; 10ED
	ld bc,#0x0020                   ; 10F0
	ldir                            ; 10F3
	ld hl,#vdp_requests2            ; 10F5
	set 6,(hl)                      ; 10F8
	ld hl,#0x0000                   ; 10FA
	ld (pal_anim_spr_ptr),hl        ; 10FD
	ld hl,#data_0EB2                ; 1100
	ld (pal_anim_bg_ptr),hl         ; 1103
	call sub_0608                   ; 1106
	jp loc_0FD6                     ; 1109
loc_110C:
	bit 5,a                         ; 110C
	jp z,loc_11A4                   ; 110E
	ld hl,#data_0EA6                ; 1111
	ld a,(event_C010)                 ; 1114
	bit 7,a                         ; 1117
	jr z,loc_111E                   ; 1119
	ld hl,#data_0E95                ; 111B
loc_111E:
	ld (event_C8CA),hl                ; 111E
	ld hl,#data_0E90                ; 1121
	ld (event_C8F2),hl                ; 1124
	ld a,#0x02                      ; 1127
data_1129::
	ld (bank_slot2_shadow),a        ; 1129
	ld (MAPPER_SLOT2),a             ; 112C  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b02_A459            ; 112F
	ld de,#0xc03a                   ; 1132
	ld bc,#0x0020                   ; 1135
	ldir                            ; 1138
	ld a,(event_C8B6)                 ; 113A
	cp #0x15                        ; 113D
	ld hl,#event_C8B6                 ; 113F
	ld a,#0x16                      ; 1142
	jr z,loc_116A                   ; 1144
	ld hl,#data_0E9E                ; 1146
	ld (event_C8CA),hl                ; 1149
	ld hl,#data_0EAC                ; 114C
	ld (event_C8F2),hl                ; 114F
	ld a,#0x02                      ; 1152
	ld (bank_slot2_shadow),a        ; 1154
	ld (MAPPER_SLOT2),a             ; 1157  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b02_A479            ; 115A
	ld de,#0xc03a                   ; 115D
	ld bc,#0x0020                   ; 1160
	ldir                            ; 1163
	ld hl,#event_C8DE                 ; 1165
	ld a,#0x19                      ; 1168
loc_116A:
	ld (hl),a                       ; 116A
	xor a                           ; 116B
	ld (event_C8D0),a                 ; 116C
	ld (event_C8F8),a                 ; 116F
	ld iy,#pause_C8D7                 ; 1172
	ld 9(iy),#0x00                  ; 1176
	ld 8(iy),#0x00                  ; 117A
	ld 10(iy),#0x00                 ; 117E
	ld iy,#sprite_C8AF                 ; 1182
	ld 9(iy),#0x00                  ; 1186
	ld 8(iy),#0x00                  ; 118A
	ld 10(iy),#0x00                 ; 118E
	ld hl,#vdp_requests2            ; 1192
	set 6,(hl)                      ; 1195
	ld a,#0x14                      ; 1197
	ld (freeze_timer),a             ; 1199
	call sub_04F6                   ; 119C
	call sub_1236                   ; 119F
	jr loc_1215                     ; 11A2
loc_11A4:
	and #0x0c                       ; 11A4
	jp z,loc_1078                   ; 11A6
	ld hl,#event_C010                 ; 11A9
	bit 7,(hl)                      ; 11AC
	jr z,loc_11B3                   ; 11AE
	jp loc_1078                     ; 11B0
loc_11B3:
	bit 2,a                         ; 11B3
	jr z,loc_11D0                   ; 11B5
	ld a,(event_C8B6)                 ; 11B7
	cp #0x15                        ; 11BA
	jr nz,loc_11C1                  ; 11BC
	jp loc_1078                     ; 11BE
loc_11C1:
	ld a,#0x1a                      ; 11C1
	ld (event_C8DE),a                 ; 11C3
	ld a,#0x15                      ; 11C6
	ld (event_C8B6),a                 ; 11C8
	ld hl,#data_0EDC                ; 11CB
	jr loc_11E7                     ; 11CE
loc_11D0:
	ld a,(event_C8DE)                 ; 11D0
	cp #0x18                        ; 11D3
	jr nz,loc_11DA                  ; 11D5
	jp loc_1078                     ; 11D7
loc_11DA:
	ld a,#0x18                      ; 11DA
	ld (event_C8DE),a                 ; 11DC
	ld a,#0x17                      ; 11DF
	ld (event_C8B6),a                 ; 11E1
	ld hl,#data_0EE5                ; 11E4
loc_11E7:
	ld (pal_anim_spr_ptr),hl        ; 11E7
	ld a,#0x00                      ; 11EA
	ld (level_C0C6),a                 ; 11EC
	ld iy,#pause_C8D7                 ; 11EF
	ld 9(iy),#0x00                  ; 11F3
	ld 8(iy),#0x00                  ; 11F7
	ld 10(iy),#0x00                 ; 11FB
	ld iy,#sprite_C8AF                 ; 11FF
	ld 9(iy),#0x00                  ; 1203
	ld 8(iy),#0x00                  ; 1207
	ld 10(iy),#0x00                 ; 120B
	call sub_04FB                   ; 120F
	jp loc_1078                     ; 1212
loc_1215:
	ld a,(event_C8B6)                 ; 1215
	cp #0x16                        ; 1218
	ld a,#0xff                      ; 121A
	jr z,loc_1220                   ; 121C
	ld a,#0xfe                      ; 121E
loc_1220:
	ld (event_C1B2),a                 ; 1220
	ld hl,#game_flags               ; 1223
	set 4,(hl)                      ; 1226
	ld hl,#level_map                ; 1228
	ld de,#event_C2CD                 ; 122B
	ld bc,#0x00b4                   ; 122E
	ldir                            ; 1231
	jp loc_1078                     ; 1233

;; ---------------------------------------------------------------- $01236
;; classement : atteinte uniquement par task4
	.area _B00_1236
sub_1236:
	call task_yield                 ; 1236
	ld iy,#sprite_C8AF                 ; 1239
	call sub_72B2                   ; 123D
	ld iy,#pause_C8D7                 ; 1240
	call sub_72B2                   ; 1244
	ld hl,(event_C8B0)                ; 1247
	ld de,(event_C8BF)                ; 124A
	add hl,de                       ; 124E
	ld (event_C8B0),hl                ; 124F
	ld hl,(event_C8B3)                ; 1252
	ld de,(event_C8C1)                ; 1255
	add hl,de                       ; 1259
	ld (event_C8B3),hl                ; 125A
	ld iy,#sprite_C8AF                 ; 125D
	call sub_6D4E                   ; 1261
	ld hl,#event_C010                 ; 1264
	bit 7,(hl)                      ; 1267
	jr nz,loc_1288                  ; 1269
	ld hl,(player_C8D8)                ; 126B
	ld de,(player_C8E7)                ; 126E
	add hl,de                       ; 1272
	ld (player_C8D8),hl                ; 1273
	ld hl,(event_C8DB)                ; 1276
	ld de,(event_C8E9)                ; 1279
	add hl,de                       ; 127D
	ld (event_C8DB),hl                ; 127E
	ld iy,#pause_C8D7                 ; 1281
	call sub_6D4E                   ; 1285
loc_1288:
	ld hl,#vdp_requests2            ; 1288
	set 7,(hl)                      ; 128B
	ld a,(freeze_timer)             ; 128D
	or a                            ; 1290
	jr nz,sub_1236                  ; 1291
	ret                             ; 1293

;; ---------------------------------------------------------------- $01294
;; classement : atteinte uniquement par task4
	.area _B00_1294
sub_1294:
	ld c,#0x04                      ; 1294
	ld hl,#pal_C01A                 ; 1296
	call sub_1315                   ; 1299
	call sub_05F8                   ; 129C
	ld hl,#sprite_C8AF                 ; 129F
	ld de,#event_C8B0                 ; 12A2
	ld bc,#0x004f                   ; 12A5
	ld (hl),#0x00                   ; 12A8
	ldir                            ; 12AA
	ld hl,#data_0E90                ; 12AC
	ld a,(event_C010)                 ; 12AF
	bit 7,a                         ; 12B2
	jr z,loc_12BE                   ; 12B4
	ld hl,#data_0E8B                ; 12B6
	ld a,#0xff                      ; 12B9
	ld (event_C1B2),a                 ; 12BB
loc_12BE:
	ld (event_C8CA),hl                ; 12BE
	ld hl,#data_0E9E                ; 12C1
	ld (event_C8F2),hl                ; 12C4
	ld a,(event_C1B2)                 ; 12C7
	cp #0xff                        ; 12CA
	ld a,#0x15                      ; 12CC
	ld b,#0x1a                      ; 12CE
	jr z,loc_12D6                   ; 12D0
	ld a,#0x17                      ; 12D2
	ld b,#0x18                      ; 12D4
loc_12D6:
	ld (event_C8B6),a                 ; 12D6
	ld a,b                          ; 12D9
	ld (event_C8DE),a                 ; 12DA
	xor a                           ; 12DD
	ld (event_C8D0),a                 ; 12DE
	ld (event_C8F8),a                 ; 12E1
	ld a,#0x60                      ; 12E4
	ld (ascript_C8B1),a                 ; 12E6
	ld (sprite_C8D9),a                 ; 12E9
	ld a,#0x20                      ; 12EC
	ld (ascript_C8B4),a                 ; 12EE
	ld a,#0xe0                      ; 12F1
	ld (sprite_C8DC),a                 ; 12F3
	ld hl,#0x0edc                   ; 12F6
	ld a,(event_C1B2)                 ; 12F9
	cp #0xff                        ; 12FC
	jr z,loc_1303                   ; 12FE
	ld hl,#data_0EE5                ; 1300
loc_1303:
	ld (pal_anim_spr_ptr),hl        ; 1303
	ld a,#0x00                      ; 1306
	ld (level_C0C6),a                 ; 1308
	ld hl,#0x0000                   ; 130B
	ld (pal_anim_bg_ptr),hl         ; 130E
	call sub_04F1                   ; 1311
	ret                             ; 1314

;; ---------------------------------------------------------------- $01315
;; classement : atteinte uniquement par task4
	.area _B00_1315
sub_1315:
	ld b,#0x10                      ; 1315
loc_1317:
	push bc                         ; 1317
	ld e,(hl)                       ; 1318
	inc hl                          ; 1319
	ld d,(hl)                       ; 131A
	dec hl                          ; 131B
	ld b,e                          ; 131C
	ld a,e                          ; 131D
	and #0x0f                       ; 131E
	ld e,a                          ; 1320
	srl b                           ; 1321
	srl b                           ; 1323
	srl b                           ; 1325
	srl b                           ; 1327
	ld a,d                          ; 1329
	and #0x0f                       ; 132A
	ld a,e                          ; 132C
	sub c                           ; 132D
	jr nc,loc_1331                  ; 132E
	xor a                           ; 1330
loc_1331:
	ld e,a                          ; 1331
	ld a,b                          ; 1332
	sub c                           ; 1333
	jr nc,loc_1337                  ; 1334
	xor a                           ; 1336
loc_1337:
	ld b,a                          ; 1337
	ld a,d                          ; 1338
	sub c                           ; 1339
	jr nc,loc_133D                  ; 133A
	xor a                           ; 133C
loc_133D:
	ld d,a                          ; 133D
	sla b                           ; 133E
	sla b                           ; 1340
	sla b                           ; 1342
	sla b                           ; 1344
	ld a,e                          ; 1346
	or b                            ; 1347
	ld e,a                          ; 1348
	ld (hl),e                       ; 1349
	inc hl                          ; 134A
	ld (hl),d                       ; 134B
	inc hl                          ; 134C
	pop bc                          ; 134D
	djnz loc_1317                   ; 134E
	ld hl,#vdp_requests2            ; 1350
	set 6,(hl)                      ; 1353
	ret                             ; 1355

;; ---------------------------------------------------------------- $01356
;; classement : racines du meme module : task4+tbl_0B3D
	.area _B00_1356
sub_1356:
	ld a,(freeze_timer)             ; 1356
	cp #0x01                        ; 1359
	ret nz                          ; 135B
	ld b,#0x00                      ; 135C
	ld hl,#flow_C1E1                 ; 135E
loc_1361:
	bit 7,(hl)                      ; 1361
	jr z,loc_1378                   ; 1363
	bit 6,(hl)                      ; 1365
	jr nz,loc_1378                  ; 1367
	set 6,(hl)                      ; 1369
	ld l,b                          ; 136B
	ld h,#0x00                      ; 136C
	add hl,hl                       ; 136E
	ld de,#jt_0B3D                  ; 136F
	add hl,de                       ; 1372
	ld e,(hl)                       ; 1373
	inc hl                          ; 1374
	ld d,(hl)                       ; 1375
	ex de,hl                        ; 1376
	jp (hl)                         ; 1377
loc_1378:
	inc hl                          ; 1378
	inc b                           ; 1379
	ld a,b                          ; 137A
	cp #0x11                        ; 137B
	jr c,loc_1361                   ; 137D
	ret                             ; 137F

;; ---------------------------------------------------------------- $0139B
;; classement : atteinte uniquement par task4
	.area _B00_139B
sub_139B:
	call sub_170C                   ; 139B
	ld hl,#level_map                ; 139E
	ld de,#flow_CF28                 ; 13A1
	ld (hl),#0x00                   ; 13A4
	ld bc,#0x05aa                   ; 13A6
	ldir                            ; 13A9
	ld hl,#event_C2CD                 ; 13AB
	ld de,#level_map                ; 13AE
	ld bc,#0x00b4                   ; 13B1
	ldir                            ; 13B4
	xor a                           ; 13B6
	ld (scroll_C19E),a                 ; 13B7
	call sub_221E                   ; 13BA
	ld a,(event_C1B2)                 ; 13BD
	ld (player_state),a             ; 13C0
	ld a,#0x04                      ; 13C3
	ld (player_CEF6),a                 ; 13C5
	ld hl,(flow_C1A0)                ; 13C8
	ld h,#0x00                      ; 13CB
	add hl,hl                       ; 13CD
	push hl                         ; 13CE
	ld a,#0x19                      ; 13CF
	ld (bank_slot2_shadow),a        ; 13D1
	ld (MAPPER_SLOT2),a             ; 13D4  mapper : banque du slot 2 ($8000-$BFFF)
	ld de,#actors_B8B8              ; 13D7
	pop hl                          ; 13DA
	add hl,de                       ; 13DB
	ld e,(hl)                       ; 13DC
	inc hl                          ; 13DD
	ld d,(hl)                       ; 13DE
	ld (event_CF0A),de                ; 13DF
	ld a,#0x14                      ; 13E3
	ld (level_CF18),a                 ; 13E5
	ld de,#actors_8000              ; 13E8
	ld (level_metatile_ptr),de      ; 13EB
	ld hl,#data_0F7D                ; 13EF
	call sub_5198                   ; 13F2
	ld a,#0x02                      ; 13F5
	ld (bank_slot2_shadow),a        ; 13F7
	ld (MAPPER_SLOT2),a             ; 13FA  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,#data_b02_A379            ; 13FD
	ld de,#0xc01a                   ; 1400
	ld bc,#0x0020                   ; 1403
	ldir                            ; 1406
	ld hl,#data_b02_A379            ; 1408
	ld de,#pal_C05A                 ; 140B
	ld bc,#0x0020                   ; 140E
	ldir                            ; 1411
	ld hl,#data_b02_A439            ; 1413
	ld de,#0xc03a                   ; 1416
	ld bc,#0x0020                   ; 1419
	ldir                            ; 141C
	ld hl,#data_b02_A439            ; 141E
	ld de,#event_C07A                 ; 1421
	ld bc,#0x0020                   ; 1424
	ldir                            ; 1427
	ld hl,#util_FF60                 ; 1429
	ld (util_C19A),hl                ; 142C
	ld hl,#0x0000                   ; 142F
	ld (level_C19C),hl                ; 1432
	ld hl,(flow_C1A0)                ; 1435
	ld h,#0x00                      ; 1438
	add hl,hl                       ; 143A
	add hl,hl                       ; 143B
	ld de,#data_0F41                ; 143C
	add hl,de                       ; 143F
	ld e,(hl)                       ; 1440
	inc hl                          ; 1441
	ld d,(hl)                       ; 1442
	inc hl                          ; 1443
	ld (scroll_y),de                ; 1444
	ld e,(hl)                       ; 1448
	inc hl                          ; 1449
	ld d,(hl)                       ; 144A
	ld (scroll_x),de                ; 144B
	ld hl,(flow_C1A0)                ; 144F
	ld h,#0x00                      ; 1452
	add hl,hl                       ; 1454
	ld de,#data_0F23                ; 1455
	add hl,de                       ; 1458
	ld a,(hl)                       ; 1459
	ld (player_CEF1),a                 ; 145A
	inc hl                          ; 145D
	ld a,(hl)                       ; 145E
	ld (player_CEF4),a                 ; 145F
	ld hl,(flow_C1A0)                ; 1462
	ld h,#0x00                      ; 1465
	ld de,#data_0F14                ; 1467
	add hl,de                       ; 146A
	ld a,(hl)                       ; 146B
	ld (scroll_C0B0),a                 ; 146C
	ld hl,#data_0EEE                ; 146F
	ld (tile_anim_ptr),hl           ; 1472
	ld hl,#data_0EB2                ; 1475
	ld (pal_anim_bg_ptr),hl         ; 1478
	ld hl,#0x0000                   ; 147B
	ld (pal_anim_spr_ptr),hl        ; 147E
	call sub_48DA                   ; 1481
	ld a,#0x95                      ; 1484
	call sub_062D                   ; 1486
	ret                             ; 1489

;; ---------------------------------------------------------------- $0148A
;; classement : racines du meme module : task4+tbl_0B3D
	.area _B00_148A
sub_148A:
	ld a,(player_state)             ; 148A
	or a                            ; 148D
	ret z                           ; 148E
	cpl                             ; 148F
	and #0x03                       ; 1490
	ld de,#sub_1498                 ; 1492
	jp loc_72E1                     ; 1495

;; ---------------------------------------------------------------- $01498
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_1498
sub_1498:
	xor e                           ; 1498
	inc d                           ; 1499
	sbc a,h                         ; 149A
	inc d                           ; 149B
	ld 10(iy),#0x00                 ; 149C
	ld de,#0xa3d5                   ; 14A0
	ld hl,#0x85c0                   ; 14A3
	ld (tmp_d5),hl                  ; 14A6
	jr loc_14B8                     ; 14A9
	.db 0xfd                        ; 14AB

;; ---------------------------------------------------------------- $014AC
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_14AC
sub_14AC:
	ld (hl),#0x0a                   ; 14AC
	nop                             ; 14AE
	ld de,#0xa310                   ; 14AF
	ld hl,#0x8000                   ; 14B2
	ld (tmp_d5),hl                  ; 14B5
loc_14B8:
	ld a,#0x07                      ; 14B8
	ld (bank_slot2_shadow),a        ; 14BA
	ld (MAPPER_SLOT2),a             ; 14BD  mapper : banque du slot 2 ($8000-$BFFF)
	ld hl,(player_CEF6)                ; 14C0
	ld h,#0x00                      ; 14C3
	add hl,hl                       ; 14C5
	add hl,de                       ; 14C6
	ld e,(hl)                       ; 14C7
	inc hl                          ; 14C8
	ld d,(hl)                       ; 14C9
	ld (sprite_C240),de                ; 14CA
	push de                         ; 14CE
	pop ix                          ; 14CF
	ld a,(player_CEF7)                 ; 14D1
	or a                            ; 14D4
	jr z,loc_14EE                   ; 14D5
	ld a,(game_flags)               ; 14D7
	bit 6,a                         ; 14DA
	jr nz,loc_151A                  ; 14DC
	ld a,(player_CEF7)                 ; 14DE
	inc a                           ; 14E1
	ld (player_CEF7),a                 ; 14E2
	cp 0(ix)                        ; 14E5
	jr c,loc_151A                   ; 14E8
	ld hl,#player_CEF8                 ; 14EA
	inc (hl)                        ; 14ED
loc_14EE:
	ld 8(iy),#0x01                  ; 14EE
	ld hl,#sprite_C185                 ; 14F2
	ld a,(tmp_d3)                   ; 14F5
	or (hl)                         ; 14F8
	ld (hl),a                       ; 14F9
	ld a,(player_CEF8)                 ; 14FA
	ld e,1(ix)                      ; 14FD
	cp e                            ; 1500
	jr c,loc_151A                   ; 1501
	jr z,loc_151A                   ; 1503
	ld 9(iy),#0x00                  ; 1505
	ld a,e                          ; 1509
	or a                            ; 150A
	jr z,loc_1511                   ; 150B
	ld 10(iy),#0x01                 ; 150D
loc_1511:
	ld a,2(ix)                      ; 1511
	or a                            ; 1514
	jr z,loc_151A                   ; 1515
	ld (player_CEF8),a                 ; 1517
loc_151A:
	ld hl,#sprite_C185                 ; 151A
	bit 0,(hl)                      ; 151D
	jp z,loc_1572                   ; 151F
	res 0,(hl)                      ; 1522
	ld hl,(player_CEF8)                ; 1524
	ld h,#0x00                      ; 1527
	add hl,hl                       ; 1529
	push ix                         ; 152A
	pop de                          ; 152C
	add hl,de                       ; 152D
	ld de,#0x0003                   ; 152E
	add hl,de                       ; 1531
	ld e,(hl)                       ; 1532
	inc hl                          ; 1533
	ld d,(hl)                       ; 1534
	ex de,hl                        ; 1535
	ld de,#irq_D701                 ; 1536
	ld b,#0x00                      ; 1539
loc_153B:
	push bc                         ; 153B
	ld c,(hl)                       ; 153C
	inc hl                          ; 153D
	ld b,(hl)                       ; 153E
	inc hl                          ; 153F
	ld a,b                          ; 1540
	cp #0xff                        ; 1541
	jr z,loc_155F                   ; 1543
	push hl                         ; 1545
	ld a,b                          ; 1546
	and #0x01                       ; 1547
	ld h,a                          ; 1549
	ld l,c                          ; 154A
	add hl,hl                       ; 154B
	add hl,hl                       ; 154C
	add hl,hl                       ; 154D
	add hl,hl                       ; 154E
	add hl,hl                       ; 154F
	ld bc,(tmp_d5)                  ; 1550
	add hl,bc                       ; 1554
	ld bc,#0x0020                   ; 1555
	ldir                            ; 1558
	pop hl                          ; 155A
	pop bc                          ; 155B
	inc b                           ; 155C
	jr loc_153B                     ; 155D
loc_155F:
	pop bc                          ; 155F
	ld hl,#vdp_requests2            ; 1560
	ld a,(tmp_d3)                   ; 1563
	or (hl)                         ; 1566
	ld (hl),a                       ; 1567
	ld hl,#data_b07_A35F            ; 1568
	ld (sprite_CF22),hl                ; 156B
	ld a,b                          ; 156E
	ld (sprite_CF24),a                 ; 156F
loc_1572:
	ret                             ; 1572

;; ---------------------------------------------------------------- $01573
;; classement : racines du meme module : task4+tbl_0B3D
	.area _B00_1573
sub_1573:
	ld iy,#player_state             ; 1573
	ld a,#0x01                      ; 1577
	ld (tmp_d3),a                   ; 1579
	di                              ; 157C
	ld hl,#vdp_requests             ; 157D
	ld a,(hl)                       ; 1580
	inc hl                          ; 1581
	or (hl)                         ; 1582
	bit 0,a                         ; 1583
	ei                              ; 1585
	call z,sub_148A                 ; 1586
	ld a,#0x07                      ; 1589
	ld (dbg_C0D4),a                 ; 158B
	call sub_6E72                   ; 158E
	ret                             ; 1591

;; ---------------------------------------------------------------- $01592
;; classement : atteinte uniquement par task4
	.area _B00_1592
sub_1592:
	ld iy,#scene_script_ptr         ; 1592
	ld b,#0x05                      ; 1596
loc_1598:
	ld a,7(iy)                      ; 1598
	or a                            ; 159B
	jr z,loc_15A1                   ; 159C
	call sub_35E2                   ; 159E
loc_15A1:
	ld de,#0x0028                   ; 15A1
	add iy,de                       ; 15A4
	djnz loc_1598                   ; 15A6
	ret                             ; 15A8
	.db 0xc9                        ; 15A9

;; ---------------------------------------------------------------- $015AA
;; classement : atteinte uniquement par task4
	.area _B00_15AA
sub_15AA:
	ld iy,#scene_script_ptr         ; 15AA
	ld b,#0x05                      ; 15AE
loc_15B0:
	call sub_6D4E                   ; 15B0
	ld de,#0x0028                   ; 15B3
	add iy,de                       ; 15B6
	djnz loc_15B0                   ; 15B8
	ret                             ; 15BA

;; ---------------------------------------------------------------- $015BB
;; classement : atteinte uniquement par task4
	.area _B00_15BB
sub_15BB:
	ld a,(event_C010)                 ; 15BB
	bit 7,a                         ; 15BE
	ret z                           ; 15C0
	ld hl,#scene_script_ptr         ; 15C1
	ld de,#util_C900                 ; 15C4
	ld bc,#0x0207                   ; 15C7
	ld (hl),#0x00                   ; 15CA
	ldir                            ; 15CC
	ld b,#0x05                      ; 15CE
	ld ix,#data_15F8                ; 15D0
	ld iy,#scene_script_ptr         ; 15D4
loc_15D8:
	ld a,(event_C010)                 ; 15D8
	and 0(ix)                       ; 15DB
	jr nz,loc_15EB                  ; 15DE
	ld a,5(ix)                      ; 15E0
	ld 7(iy),a                      ; 15E3
	push bc                         ; 15E6
	call sub_3B78                   ; 15E7
	pop bc                          ; 15EA
loc_15EB:
	ld de,#0x0028                   ; 15EB
	add iy,de                       ; 15EE
	ld de,#0x0006                   ; 15F0
	add ix,de                       ; 15F3
	djnz loc_15D8                   ; 15F5
	ret                             ; 15F7
data_15F8:
	.db 0x01, 0xc8, 0x00, 0x18, 0x00, 0x10, 0x02, 0xf0 ; 15F8
	.db 0x00, 0x18, 0x00, 0x11, 0x04, 0x48, 0x00, 0x78, 0x00, 0x12, 0x08, 0x78, 0x00, 0x18, 0x00, 0x13 ; 1600
	.db 0x10                        ; 1610

;; ---------------------------------------------------------------- $01611
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_1611
sub_1611:
	ld c,b                          ; 1611
	nop                             ; 1612
	ld e,b                          ; 1613
	nop                             ; 1614
	inc d                           ; 1615
