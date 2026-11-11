;; core/irq.s
;; Interruptions : vecteur IRQ ($0038), NMI ($0066), gestionnaire VBlank/HBlank.
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $00038
;; classement : plage symbols.json
	.area _B00_0038
irq_vector:
	jp irq_handler                  ; 0038

;; ---------------------------------------------------------------- $0003B
;; classement : plage symbols.json
	.area _B00_003B
sub_003B::
	jp sub_44E4                     ; 003B

;; ---------------------------------------------------------------- $0003E
;; classement : plage symbols.json
	.area _B00_003E
sub_003E::
	jp sub_454E                     ; 003E
	.db 0xff                        ; 0041

;; ---------------------------------------------------------------- $00042
;; classement : plage symbols.json
	.area _B00_0042
sub_0042::
	ld hl,#vdp_reg1_shadow          ; 0042
	res 6,(hl)                      ; 0045
	ld e,(hl)                       ; 0047
	ld d,#0x81                      ; 0048
	jp rst08_vdp_set_addr_di        ; 004A

;; ---------------------------------------------------------------- $0004D
;; classement : plage symbols.json
	.area _B00_004D
sub_004D::
	jp sub_170C                     ; 004D

;; ---------------------------------------------------------------- $00050
;; classement : plage symbols.json
	.area _B00_0050
sub_0050::
	ld hl,#vdp_reg1_shadow          ; 0050
	set 6,(hl)                      ; 0053
	ld e,(hl)                       ; 0055
	ld d,#0x81                      ; 0056
	jp rst08_vdp_set_addr_di        ; 0058

;; ---------------------------------------------------------------- $0005B
;; classement : plage symbols.json
	.area _B00_005B
sub_005B::
	jp task_yield                   ; 005B

;; ---------------------------------------------------------------- $0005E
;; classement : plage symbols.json
	.area _B00_005E
sub_005E::
	jp sub_574C                     ; 005E

;; ---------------------------------------------------------------- $00061
;; classement : plage symbols.json
	.area _B00_0061
sub_0061::
	jp sub_174B                     ; 0061
	.db 0xff, 0xff                  ; 0064

;; ---------------------------------------------------------------- $00066
;; classement : plage symbols.json
	.area _B00_0066
.if VERSION_SMS_EN
nmi_vector:
	push af                         ; 0066
	ld a,#0x40                      ; 0067
	ld (sms_pause_flag),a           ; 0069
	pop af                          ; 006C
	retn                            ; 006D
	.db 0x00                        ; 006F
	.db 0x00                        ; 0070
.else ; VERSION_GG_JP
nmi_vector:
	retn                            ; 0066
loc_0068::
	jp util_jump_table              ; 0068
sub_006B::
	jp sub_0A33                     ; 006B
sub_006E::
	jp sound_init                   ; 006E
.endif

;; ---------------------------------------------------------------- $00071
;; classement : plage symbols.json
	.area _B00_0071
sub_0071::
	jp sub_059F                     ; 0071

;; ---------------------------------------------------------------- $000B0
;; classement : plage symbols.json
	.area _B00_00B0
irq_handler:
	push af                         ; 00B0
	push bc                         ; 00B1
	push de                         ; 00B2
	push hl                         ; 00B3
	in a,(VDP_STATUS)               ; 00B4  VDP : statut (acquitte l'IRQ)
	ld (vdp_status_copy),a          ; 00B6
	rlca                            ; 00B9
	jr c,loc_0117                   ; 00BA
	ld hl,(raster_ptr)              ; 00BC
	ld a,(game_mode)                ; 00BF
	cp #0x06                        ; 00C2
	jr nz,loc_00EA                  ; 00C4
	in a,(VDP_VCOUNTER)             ; 00C6  VDP : compteur de ligne
	cp #0x78                        ; 00C8
	jr nc,loc_0109                  ; 00CA
	ld a,l                          ; 00CC
	inc a                           ; 00CD
	cp #0x18                        ; 00CE
	jr c,loc_00D3                   ; 00D0
	xor a                           ; 00D2
loc_00D3:
	ld (raster_ptr),a               ; 00D3
	ld e,a                          ; 00D6
	ld d,#0x00                      ; 00D7
	ld hl,#data_04D4                ; 00D9
	add hl,de                       ; 00DC
	ld e,(hl)                       ; 00DD
	jr loc_00E4                     ; 00DE
	.db 0xed                        ; 00E0

;; ---------------------------------------------------------------- $000E1
;; classement : plage symbols.json
	.area _B00_00E1
sub_00E1:
	ld e,e                          ; 00E1
	cp (hl)                         ; 00E2
	pop bc                          ; 00E3
loc_00E4:
	ld d,#0x88                      ; 00E4
	rst 0x10                        ; 00E6  VDP : adresse/commande = de
	jp loc_03FD                     ; 00E7
loc_00EA:
	cp #0x01                        ; 00EA
	jr z,loc_0109                   ; 00EC
	in a,(VDP_VCOUNTER)             ; 00EE  VDP : compteur de ligne
	cp (hl)                         ; 00F0
	jp c,loc_03FD                   ; 00F1
	inc hl                          ; 00F4
	ld a,(hl)                       ; 00F5
	cp #0xff                        ; 00F6
	jr z,loc_0109                   ; 00F8
	inc hl                          ; 00FA
	inc hl                          ; 00FB
	inc hl                          ; 00FC
	ld a,(hl)                       ; 00FD
	ld e,a                          ; 00FE
loc_00FF::
	ld d,#0x88                      ; 00FF
	rst 0x10                        ; 0101  VDP : adresse/commande = de
	inc hl                          ; 0102
	ld (raster_ptr),hl              ; 0103
	jp loc_03FD                     ; 0106
loc_0109:
	ld de,(irq_C1BE)                ; 0109
	ld d,#0x88                      ; 010D
	rst 0x10                        ; 010F  VDP : adresse/commande = de
.if VERSION_SMS_EN
	ld de,#VDP_REG_0|0x26           ; 0110
.else ; VERSION_GG_JP
	ld de,#VDP_REG_0|0x06           ; 0110
.endif
	rst 0x10                        ; 0113  VDP : adresse/commande = de
	jp loc_03FD                     ; 0114
loc_0117:
	push ix                         ; 0117
	push iy                         ; 0119
	ld hl,#irq_flags                ; 011B
	set 7,(hl)                      ; 011E
	ld hl,#vdp_requests             ; 0120
	bit 0,(hl)                      ; 0123
	jr z,loc_0148                   ; 0125
	res 0,(hl)                      ; 0127
	ld hl,#irq_D701                 ; 0129
	ld a,#0x00                      ; 012C
	out (VDP_CTRL),a                ; 012E  VDP : commande (adresse / registre)
	ld a,#0x40                      ; 0130
	out (VDP_CTRL),a                ; 0132  VDP : commande (adresse / registre)
	ld a,(current_stage)            ; 0134
	or a                            ; 0137
	ld c,#0xbe                      ; 0138
	jr nz,loc_0142                  ; 013A
	call sub_43BB                   ; 013C
	jp loc_015E                     ; 013F
loc_0142:
	call sub_407B                   ; 0142
	jp loc_015E                     ; 0145
loc_0148:
	bit 4,(hl)                      ; 0148
	jr z,loc_015E                   ; 014A
	ld de,(irq_C189)                ; 014C
	rst 0x10                        ; 0150  VDP : adresse/commande = de
	ld hl,(irq_C18B)                ; 0151
	call sub_047D                   ; 0154
	ld hl,#vdp_requests             ; 0157
	res 4,(hl)                      ; 015A
	jr loc_015E                     ; 015C
loc_015E:
	ld hl,#vdp_requests             ; 015E
	bit 6,(hl)                      ; 0161
	call nz,sub_404E                ; 0163
	ld hl,#vdp_requests             ; 0166
	bit 7,(hl)                      ; 0169
.if WIDESCREEN
	call nz,wide_sat                ; 016B  vue elargie : SAT copiee a vitesse sure si trop tard
.else
	call nz,sub_405C                ; 016B
.endif
	ld hl,#vdp_requests             ; 016E
	bit 5,(hl)                      ; 0171
	jr z,loc_0189                   ; 0173
	ld de,(scroll_y)                ; 0175
	ld d,#0x89                      ; 0179
	rst 0x10                        ; 017B  VDP : adresse/commande = de
	ld a,(scroll_x)                 ; 017C
	ld (irq_C1BE),a                 ; 017F
	ld de,(scroll_x)                ; 0182
	ld d,#0x88                      ; 0186
	rst 0x10                        ; 0188  VDP : adresse/commande = de
loc_0189:
	ld a,(game_mode)                ; 0189
	cp #0x06                        ; 018C
	jr nz,loc_01B3                  ; 018E
	ld a,(irq_C1C5)                 ; 0190
data_0193::
	inc a                           ; 0193
	ld (irq_C1C5),a                 ; 0194
	cp #0x06                        ; 0197
	ld a,(irq_C1C1)                 ; 0199
	jr c,loc_01AE                   ; 019C
	xor a                           ; 019E
	ld (irq_C1C5),a                 ; 019F
	ld a,(irq_C1C1)                 ; 01A2
	inc a                           ; 01A5
	cp #0x18                        ; 01A6
	jr c,loc_01AB                   ; 01A8
	xor a                           ; 01AA
loc_01AB:
	ld (irq_C1C1),a                 ; 01AB
loc_01AE:
	ld (raster_ptr),a               ; 01AE
	jr loc_01F5                     ; 01B1
loc_01B3:
	cp #0x01                        ; 01B3
	jr z,loc_01F9                   ; 01B5
	ld hl,(raster_ptr)              ; 01B7
	ld a,l                          ; 01BA
	or h                            ; 01BB
	jr z,loc_0226                   ; 01BC
	ld hl,(irq_C1C2)                ; 01BE
	ld (raster_ptr),hl              ; 01C1
	push hl                         ; 01C4
	ld a,(game_flags)               ; 01C5
	bit 6,a                         ; 01C8
	jr nz,loc_01E3                  ; 01CA
	inc hl                          ; 01CC
	ld a,(irq_C1C1)                 ; 01CD
loc_01D0:
	ld e,(hl)                       ; 01D0
	inc hl                          ; 01D1
	ld d,(hl)                       ; 01D2
	inc hl                          ; 01D3
	ld c,(hl)                       ; 01D4
	inc hl                          ; 01D5
	ld b,(hl)                       ; 01D6
	ex de,hl                        ; 01D7
	add hl,bc                       ; 01D8
	ex de,hl                        ; 01D9
	ld (hl),d                       ; 01DA
	dec hl                          ; 01DB
	ld (hl),e                       ; 01DC
	inc hl                          ; 01DD
	inc hl                          ; 01DE
	inc hl                          ; 01DF
	dec a                           ; 01E0
	jr nz,loc_01D0                  ; 01E1
loc_01E3:
	pop hl                          ; 01E3
	ld de,#0x0004                   ; 01E4
	add hl,de                       ; 01E7
	ld e,(hl)                       ; 01E8
	ld d,#0x88                      ; 01E9
	rst 0x10                        ; 01EB  VDP : adresse/commande = de
	ld e,#0x08                      ; 01EC
	ld a,(game_mode)                ; 01EE
	cp #0x05                        ; 01F1
	jr nz,loc_021F                  ; 01F3
loc_01F5:
	ld e,#0x01                      ; 01F5
	jr loc_021F                     ; 01F7
loc_01F9:
	ld a,(scene_C1BF)                 ; 01F9
	or a                            ; 01FC
	jr z,loc_0226                   ; 01FD
	ld a,(scroll_x)                 ; 01FF
	ld (irq_C1BE),a                 ; 0202
	ld hl,(irq_C1BA)                ; 0205
	ld de,(irq_C1B8)                ; 0208
	ld a,(irq_C0BB)                 ; 020C
	cp #0x01                        ; 020F
	jr nz,loc_0214                  ; 0211
	add hl,de                       ; 0213
loc_0214:
	ld (irq_C1BA),hl                ; 0214
	ld e,h                          ; 0217
	ld d,#0x88                      ; 0218
	rst 0x10                        ; 021A  VDP : adresse/commande = de
	ld de,(irq_C1BC)                ; 021B
loc_021F:
	ld d,#0x8a                      ; 021F
	rst 0x10                        ; 0221  VDP : adresse/commande = de
.if VERSION_SMS_EN
	ld de,#VDP_REG_0|0x36           ; 0222
.else ; VERSION_GG_JP
	ld de,#VDP_REG_0|0x16           ; 0222
.endif
	rst 0x10                        ; 0225  VDP : adresse/commande = de
loc_0226:
	ld hl,#irq_C0BA                 ; 0226
	inc (hl)                        ; 0229
	inc hl                          ; 022A
	inc (hl)                        ; 022B
	ld a,(hl)                       ; 022C
	cp #0x01                        ; 022D
	jr nz,loc_0237                  ; 022F
	call joypad_read                ; 0231
	call sub_047C                   ; 0234
loc_0237:
	ld a,#0x1a                      ; 0237
	ld (MAPPER_SLOT1),a             ; 0239  mapper : banque du slot 1 ($4000-$7FFF)
	ld a,#0x1b                      ; 023C
	ld (MAPPER_SLOT2),a             ; 023E  mapper : banque du slot 2 ($8000-$BFFF)
	exx                             ; 0241
	push af                         ; 0242
	push bc                         ; 0243
	push de                         ; 0244
	push hl                         ; 0245
	call sound_update               ; 0246
	pop hl                          ; 0249
	pop de                          ; 024A
	pop bc                          ; 024B
	pop af                          ; 024C
	exx                             ; 024D
	ld a,#0x01                      ; 024E
	ld (MAPPER_SLOT1),a             ; 0250  mapper : banque du slot 1 ($4000-$7FFF)
	ld a,(task_ready_mask)          ; 0253
	or a                            ; 0256
	jp nz,loc_03D8                  ; 0257
	ld hl,#irq_C0BB                 ; 025A
	ld a,(hl)                       ; 025D
	cp #0x02                        ; 025E
	jp c,loc_03D8                   ; 0260
	ld (hl),#0x00                   ; 0263
	ld a,(task_active_mask)         ; 0265
	ld (task_ready_mask),a          ; 0268
	ld a,#0xff                      ; 026B
	ld (task_current),a             ; 026D
	jp task_scheduler               ; 0270
