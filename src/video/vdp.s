;; video/vdp.s
;; Acces VDP : adresse/registres, affichage on/off, transferts VRAM/CRAM.
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $0047D
;; classement : plage symbols.json
	.area _B00_047D
sub_047D::
	ld h,#0x00                      ; 047D
	add hl,hl                       ; 047F
	ld de,#jt_048B                  ; 0480
	add hl,de                       ; 0483
	ld e,(hl)                       ; 0484
	inc hl                          ; 0485
	ld d,(hl)                       ; 0486
	ex de,hl                        ; 0487
	ld c,#0xbe                      ; 0488
	jp (hl)                         ; 048A
jt_048B:
	.dw loc_049B                    ; 048B
	.dw loc_04A3                    ; 048D
	.dw loc_04AB                    ; 048F
	.dw loc_04AD                    ; 0491
	.dw loc_04B5                    ; 0493
	.dw loc_04BD                    ; 0495
	.dw loc_04C5                    ; 0497
	.dw loc_04CD                    ; 0499
loc_049B:
	ld hl,#decomp_buffer            ; 049B
	call sub_447B                   ; 049E
	jr loc_04D3                     ; 04A1
loc_04A3:
	ld hl,#decomp_buffer            ; 04A3
	call sub_437B                   ; 04A6
	jr loc_04D3                     ; 04A9
loc_04AB:
	jr loc_04D3                     ; 04AB
loc_04AD:
	ld hl,#decomp_buffer            ; 04AD
	call sub_443B                   ; 04B0
	jr loc_04D3                     ; 04B3
loc_04B5:
	ld hl,#decomp_buffer            ; 04B5
	call sub_43BB                   ; 04B8
	jr loc_04D3                     ; 04BB
loc_04BD:
	ld hl,#decomp_buffer            ; 04BD
	call sub_433B                   ; 04C0
	jr loc_04D3                     ; 04C3
loc_04C5:
	ld hl,#decomp_buffer            ; 04C5
	call sub_43FB                   ; 04C8
	jr loc_04D3                     ; 04CB
loc_04CD:
	ld hl,#decomp_buffer            ; 04CD
	call sub_427B                   ; 04D0
loc_04D3:
	ret                             ; 04D3
data_04D4::
	.db 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x02, 0x02, 0x02, 0x02, 0x01, 0x01 ; 04D4
	.db 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xfe ; 04E0

;; ---------------------------------------------------------------- $004E7
;; classement : plage symbols.json
	.area _B00_04E7
sub_04E7:
	cp #0xfe                        ; 04E7
	cp #0xff                        ; 04E9
	rst 0x38                        ; 04EB

;; ---------------------------------------------------------------- $00A33
;; classement : remise a zero ecran (defilement, raster, tampon sprites)
	.area _B00_0A33
sub_0A33::
	ld hl,#0x0000                   ; 0A33
	ld (scroll_C0B8),hl                ; 0A36
	ld (player_C0B6),hl                ; 0A39
	ld (util_C0AD),hl                ; 0A3C
	ld (util_C0BE),hl                ; 0A3F
	ld (util_C0C0),hl                ; 0A42
	di                              ; 0A45
	ld (raster_ptr),hl              ; 0A46
.if VERSION_SMS_EN
	ld de,#VDP_REG_0|0x26           ; 0A49
.else ; VERSION_GG_JP
	ld de,#VDP_REG_0|0x06           ; 0A49
.endif
	rst 0x10                        ; 0A4C  VDP : adresse/commande = de
	ei                              ; 0A4D
	ld hl,#vdp_C800                 ; 0A4E
	ld (scroll_C09A),hl                ; 0A51
	xor a                           ; 0A54
	ld (vdp_C0AF),a                 ; 0A55
	ld (ascript_C09C),a                 ; 0A58
	ld (scene_C1BF),a                 ; 0A5B
	ld hl,#vdp_requests2            ; 0A5E
	set 5,(hl)                      ; 0A61
	ret                             ; 0A63

;; ---------------------------------------------------------------- $00A64
;; classement : remise a zero ecran (defilement, raster, tampon sprites)
	.area _B00_0A64
sub_0A64::
	ld hl,#irq_flags                ; 0A64
	bit 1,(hl)                      ; 0A67
	jr z,loc_0A83                   ; 0A69

;; ---------------------------------------------------------------- $00A6B
;; classement : remise a zero ecran (defilement, raster, tampon sprites)
	.area _B00_0A6B
sub_0A6B::
	call sub_0A84                   ; 0A6B
	ld hl,#irq_flags                ; 0A6E
	res 1,(hl)                      ; 0A71
	xor a                           ; 0A73
	ld (sprite_C24B),a                 ; 0A74
	ld hl,#vdp_C200                 ; 0A77
	ld (sprite_buf_y_ptr),hl        ; 0A7A
	ld hl,#flow_C24D                 ; 0A7D
	ld (sprite_buf_xn_ptr),hl       ; 0A80
loc_0A83:
	ret                             ; 0A83

;; ---------------------------------------------------------------- $00A84
;; classement : remise a zero ecran (defilement, raster, tampon sprites)
	.area _B00_0A84
sub_0A84:
	ld hl,#vdp_C200                 ; 0A84
	ld de,#vdp_C201                 ; 0A87
	ld bc,#0x003f                   ; 0A8A
	ld (hl),#0xe0                   ; 0A8D
	ldir                            ; 0A8F
	ret                             ; 0A91

;; ---------------------------------------------------------------- $00A92
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0A92
sub_0A92:
	ld a,#0x01                      ; 0A92
	call task_resume                ; 0A94
	ld a,#0x03                      ; 0A97
	call task_resume                ; 0A99
	ld a,#0x02                      ; 0A9C
	call task_resume                ; 0A9E
	ret                             ; 0AA1

;; ---------------------------------------------------------------- $00AA2
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B00_0AA2
sub_0AA2:
	ld a,#0x01                      ; 0AA2
	call task_suspend               ; 0AA4
	ld a,#0x03                      ; 0AA7
	call task_suspend               ; 0AA9
	ld a,#0x02                      ; 0AAC
	call task_suspend               ; 0AAE
	ret                             ; 0AB1

;; ---------------------------------------------------------------- $04000
;; classement : plage symbols.json
	.area _B01_4000
	ld l,e                          ; 4000
loc_4001:
	outi                            ; 4001
	nop                             ; 4003
	nop                             ; 4004
	jr nz,loc_4001                  ; 4005
	dec a                           ; 4007
	jr nz,loc_3FFD                  ; 4008
	ei                              ; 400A
	ret                             ; 400B

;; ---------------------------------------------------------------- $0400C
;; classement : plage symbols.json
	.area _B01_400C
sub_400C::
	in a,(VDP_VCOUNTER)             ; 400C  VDP : compteur de ligne
	cp #0xb0                        ; 400E
	jp nz,sub_400C                  ; 4010
	ld hl,#sub_4028                 ; 4013
	ld bc,#0x16bf                   ; 4016
	otir                            ; 4019
	ld a,(data_402A)                ; 401B
	ld (vdp_reg1_shadow),a          ; 401E
	ld a,(data_402C)                ; 4021
	ld (vdp_C0B5),a                 ; 4024
	ret                             ; 4027

;; ---------------------------------------------------------------- $04028
;; classement : plage symbols.json
	.area _B01_4028
.if VERSION_SMS_EN
sub_4028:
	ld h,#0x80                      ; 4028
.else ; VERSION_GG_JP
sub_4028:
	ld b,#0x80                      ; 4028
.endif
data_402A:
	and b                           ; 402A
	add a,c                         ; 402B
data_402C:
	rst 0x38                        ; 402C

;; ---------------------------------------------------------------- $0402D
;; classement : plage symbols.json
	.area _B01_402D
sub_402D:
	add a,d                         ; 402D
	rst 0x38                        ; 402E

;; ---------------------------------------------------------------- $0402F
;; classement : plage symbols.json
	.area _B01_402F
sub_402F:
	add a,e                         ; 402F
	rst 0x38                        ; 4030

;; ---------------------------------------------------------------- $04031
;; classement : plage symbols.json
	.area _B01_4031
sub_4031:
	add a,h                         ; 4031
	rst 0x38                        ; 4032

;; ---------------------------------------------------------------- $04033
;; classement : plage symbols.json
	.area _B01_4033
sub_4033:
	add a,l                         ; 4033
	ei                              ; 4034
	add a,(hl)                      ; 4035
	nop                             ; 4036
	add a,a                         ; 4037
	nop                             ; 4038
	adc a,b                         ; 4039
	nop                             ; 403A
	adc a,c                         ; 403B
	rst 0x38                        ; 403C
	adc a,d                         ; 403D
	ld hl,#vdp_reg1_shadow          ; 403E
	set 1,(hl)                      ; 4041
	ld hl,#vdp_reg1_shadow          ; 4043
	res 1,(hl)                      ; 4046
	ld e,(hl)                       ; 4048
	ld d,#0x81                      ; 4049
	jp rst08_vdp_set_addr_di        ; 404B

;; ---------------------------------------------------------------- $0404E
;; classement : plage symbols.json
	.area _B01_404E
sub_404E::
	xor a                           ; 404E
	out (VDP_CTRL),a                ; 404F  VDP : commande (adresse / registre)
	ld hl,#pal_C01A                 ; 4051
	ld a,h                          ; 4054
	out (VDP_CTRL),a                ; 4055  VDP : commande (adresse / registre)
	ld c,#0xbe                      ; 4057
.if VERSION_SMS_EN
	jp loc_7FA3                     ; 4059
.else ; VERSION_GG_JP
	jp sub_443B                     ; 4059
.endif

;; ---------------------------------------------------------------- $0405C
;; classement : plage symbols.json
	.area _B01_405C
sub_405C::
	ld hl,#irq_flags                ; 405C
	set 1,(hl)                      ; 405F
	xor a                           ; 4061
	out (VDP_CTRL),a                ; 4062  VDP : commande (adresse / registre)
	ld a,#0x7f                      ; 4064
	out (VDP_CTRL),a                ; 4066  VDP : commande (adresse / registre)
	ld c,#0xbe                      ; 4068
	ld hl,#vdp_C200                 ; 406A
	call sub_443B                   ; 406D
	inc a                           ; 4070
	out (VDP_CTRL),a                ; 4071  VDP : commande (adresse / registre)
	dec a                           ; 4073
	out (VDP_CTRL),a                ; 4074  VDP : commande (adresse / registre)
	ld l,#0x4d                      ; 4076
	jp sub_43BB                     ; 4078

;; ---------------------------------------------------------------- $0407B
;; classement : plage symbols.json
	.area _B01_407B
sub_407B::
	outi                            ; 407B
	outi                            ; 407D
	outi                            ; 407F
	outi                            ; 4081
	outi                            ; 4083
	outi                            ; 4085
	outi                            ; 4087
	outi                            ; 4089
	outi                            ; 408B
	outi                            ; 408D
	outi                            ; 408F
	outi                            ; 4091
	outi                            ; 4093
	outi                            ; 4095
	outi                            ; 4097
	outi                            ; 4099
	outi                            ; 409B
	outi                            ; 409D
	outi                            ; 409F
	outi                            ; 40A1
	outi                            ; 40A3
	outi                            ; 40A5
	outi                            ; 40A7
	outi                            ; 40A9
	outi                            ; 40AB
	outi                            ; 40AD
	outi                            ; 40AF
	outi                            ; 40B1
	outi                            ; 40B3
	outi                            ; 40B5
	outi                            ; 40B7
	outi                            ; 40B9
	outi                            ; 40BB
	outi                            ; 40BD
	outi                            ; 40BF
	outi                            ; 40C1
	outi                            ; 40C3
	outi                            ; 40C5
	outi                            ; 40C7
	outi                            ; 40C9
	outi                            ; 40CB
	outi                            ; 40CD
	outi                            ; 40CF
	outi                            ; 40D1
	outi                            ; 40D3
	outi                            ; 40D5
	outi                            ; 40D7
	outi                            ; 40D9
	outi                            ; 40DB
	outi                            ; 40DD
	outi                            ; 40DF
	outi                            ; 40E1
	outi                            ; 40E3
	outi                            ; 40E5
	outi                            ; 40E7
	outi                            ; 40E9
	outi                            ; 40EB
	outi                            ; 40ED
	outi                            ; 40EF
	outi                            ; 40F1
	outi                            ; 40F3
	outi                            ; 40F5
	outi                            ; 40F7
	outi                            ; 40F9
	outi                            ; 40FB
	outi                            ; 40FD
	outi                            ; 40FF
	outi                            ; 4101
	outi                            ; 4103
	outi                            ; 4105
	outi                            ; 4107
	outi                            ; 4109
	outi                            ; 410B
	outi                            ; 410D
	outi                            ; 410F
	outi                            ; 4111
	outi                            ; 4113
	outi                            ; 4115
	outi                            ; 4117
	outi                            ; 4119
	outi                            ; 411B
	outi                            ; 411D
	outi                            ; 411F
	outi                            ; 4121
	outi                            ; 4123
	outi                            ; 4125
	outi                            ; 4127
	outi                            ; 4129
	outi                            ; 412B
	outi                            ; 412D
	outi                            ; 412F
	outi                            ; 4131
	outi                            ; 4133
	outi                            ; 4135
	outi                            ; 4137
	outi                            ; 4139
	outi                            ; 413B
	outi                            ; 413D
	outi                            ; 413F
	outi                            ; 4141
	outi                            ; 4143
	outi                            ; 4145
	outi                            ; 4147
	outi                            ; 4149
	outi                            ; 414B
	outi                            ; 414D
	outi                            ; 414F
	outi                            ; 4151
	outi                            ; 4153
	outi                            ; 4155
	outi                            ; 4157
	outi                            ; 4159
	outi                            ; 415B
	outi                            ; 415D
	outi                            ; 415F
	outi                            ; 4161
	outi                            ; 4163
	outi                            ; 4165
	outi                            ; 4167
	outi                            ; 4169
	outi                            ; 416B
	outi                            ; 416D
	outi                            ; 416F
	outi                            ; 4171
	outi                            ; 4173
	outi                            ; 4175
	outi                            ; 4177
	outi                            ; 4179
	outi                            ; 417B
	outi                            ; 417D
	outi                            ; 417F
	outi                            ; 4181
	outi                            ; 4183
	outi                            ; 4185
	outi                            ; 4187
	outi                            ; 4189
	outi                            ; 418B
	outi                            ; 418D
	outi                            ; 418F
	outi                            ; 4191
	outi                            ; 4193
	outi                            ; 4195
	outi                            ; 4197
	outi                            ; 4199
	outi                            ; 419B
	outi                            ; 419D
	outi                            ; 419F
	outi                            ; 41A1
	outi                            ; 41A3
	outi                            ; 41A5
	outi                            ; 41A7
	outi                            ; 41A9
	outi                            ; 41AB
	outi                            ; 41AD
	outi                            ; 41AF
	outi                            ; 41B1
	outi                            ; 41B3
	outi                            ; 41B5
	outi                            ; 41B7
	outi                            ; 41B9
	outi                            ; 41BB
	outi                            ; 41BD
	outi                            ; 41BF
	outi                            ; 41C1
	outi                            ; 41C3
	outi                            ; 41C5
	outi                            ; 41C7
	outi                            ; 41C9
	outi                            ; 41CB
	outi                            ; 41CD
	outi                            ; 41CF
	outi                            ; 41D1
	outi                            ; 41D3
	outi                            ; 41D5
	outi                            ; 41D7
	outi                            ; 41D9
	outi                            ; 41DB
	outi                            ; 41DD
	outi                            ; 41DF
	outi                            ; 41E1
	outi                            ; 41E3
	outi                            ; 41E5
	outi                            ; 41E7
	outi                            ; 41E9
	outi                            ; 41EB
	outi                            ; 41ED
	outi                            ; 41EF
	outi                            ; 41F1
	outi                            ; 41F3
	outi                            ; 41F5
	outi                            ; 41F7
	outi                            ; 41F9
	outi                            ; 41FB
	outi                            ; 41FD
	outi                            ; 41FF
	outi                            ; 4201
	outi                            ; 4203
	outi                            ; 4205
	outi                            ; 4207
	outi                            ; 4209
	outi                            ; 420B
	outi                            ; 420D
	outi                            ; 420F
	outi                            ; 4211
	outi                            ; 4213
	outi                            ; 4215
	outi                            ; 4217
	outi                            ; 4219
	outi                            ; 421B
	outi                            ; 421D
	outi                            ; 421F
	outi                            ; 4221
	outi                            ; 4223
	outi                            ; 4225
	outi                            ; 4227
	outi                            ; 4229
	outi                            ; 422B
	outi                            ; 422D
	outi                            ; 422F
	outi                            ; 4231
	outi                            ; 4233
	outi                            ; 4235
	outi                            ; 4237
	outi                            ; 4239
	outi                            ; 423B
	outi                            ; 423D
	outi                            ; 423F
	outi                            ; 4241
	outi                            ; 4243
	outi                            ; 4245
	outi                            ; 4247
	outi                            ; 4249
	outi                            ; 424B
	outi                            ; 424D
	outi                            ; 424F
	outi                            ; 4251
	outi                            ; 4253
	outi                            ; 4255
	outi                            ; 4257
	outi                            ; 4259
	outi                            ; 425B
	outi                            ; 425D
	outi                            ; 425F
	outi                            ; 4261
	outi                            ; 4263
	outi                            ; 4265
	outi                            ; 4267
	outi                            ; 4269
	outi                            ; 426B
	outi                            ; 426D
	outi                            ; 426F
	outi                            ; 4271
	outi                            ; 4273
	outi                            ; 4275
	outi                            ; 4277
	outi                            ; 4279

;; ---------------------------------------------------------------- $0427B
;; classement : plage symbols.json
	.area _B01_427B
sub_427B:
	outi                            ; 427B
	outi                            ; 427D
	outi                            ; 427F
	outi                            ; 4281
	outi                            ; 4283
	outi                            ; 4285
	outi                            ; 4287
	outi                            ; 4289
	outi                            ; 428B
	outi                            ; 428D
	outi                            ; 428F
	outi                            ; 4291
	outi                            ; 4293
	outi                            ; 4295
	outi                            ; 4297
	outi                            ; 4299
	outi                            ; 429B
	outi                            ; 429D
	outi                            ; 429F
	outi                            ; 42A1
	outi                            ; 42A3
	outi                            ; 42A5
	outi                            ; 42A7
	outi                            ; 42A9
	outi                            ; 42AB
	outi                            ; 42AD
	outi                            ; 42AF
	outi                            ; 42B1
	outi                            ; 42B3
	outi                            ; 42B5
	outi                            ; 42B7
	outi                            ; 42B9
	outi                            ; 42BB
	outi                            ; 42BD
	outi                            ; 42BF
	outi                            ; 42C1
	outi                            ; 42C3
	outi                            ; 42C5
	outi                            ; 42C7
	outi                            ; 42C9
	outi                            ; 42CB
	outi                            ; 42CD
	outi                            ; 42CF
	outi                            ; 42D1
	outi                            ; 42D3
	outi                            ; 42D5
	outi                            ; 42D7
	outi                            ; 42D9
	outi                            ; 42DB
	outi                            ; 42DD
	outi                            ; 42DF
	outi                            ; 42E1
	outi                            ; 42E3
	outi                            ; 42E5
	outi                            ; 42E7
	outi                            ; 42E9
	outi                            ; 42EB
	outi                            ; 42ED
	outi                            ; 42EF
	outi                            ; 42F1
	outi                            ; 42F3
	outi                            ; 42F5
	outi                            ; 42F7
	outi                            ; 42F9
	outi                            ; 42FB
	outi                            ; 42FD
	outi                            ; 42FF
	outi                            ; 4301
	outi                            ; 4303
	outi                            ; 4305
	outi                            ; 4307
	outi                            ; 4309
	outi                            ; 430B
	outi                            ; 430D
	outi                            ; 430F
	outi                            ; 4311
	outi                            ; 4313
	outi                            ; 4315
	outi                            ; 4317
	outi                            ; 4319
	outi                            ; 431B
	outi                            ; 431D
	outi                            ; 431F
	outi                            ; 4321
	outi                            ; 4323
	outi                            ; 4325
	outi                            ; 4327
	outi                            ; 4329
	outi                            ; 432B
	outi                            ; 432D
	outi                            ; 432F
	outi                            ; 4331
	outi                            ; 4333
	outi                            ; 4335
	outi                            ; 4337
	outi                            ; 4339

;; ---------------------------------------------------------------- $0433B
;; classement : plage symbols.json
	.area _B01_433B
sub_433B:
	outi                            ; 433B
	outi                            ; 433D
	outi                            ; 433F
	outi                            ; 4341
	outi                            ; 4343
	outi                            ; 4345
	outi                            ; 4347
	outi                            ; 4349
	outi                            ; 434B
	outi                            ; 434D
	outi                            ; 434F
	outi                            ; 4351
	outi                            ; 4353
	outi                            ; 4355
	outi                            ; 4357
	outi                            ; 4359
	outi                            ; 435B
	outi                            ; 435D
	outi                            ; 435F
	outi                            ; 4361
	outi                            ; 4363
	outi                            ; 4365
	outi                            ; 4367
	outi                            ; 4369
	outi                            ; 436B
	outi                            ; 436D
	outi                            ; 436F
	outi                            ; 4371
	outi                            ; 4373
	outi                            ; 4375
	outi                            ; 4377
	outi                            ; 4379

;; ---------------------------------------------------------------- $0437B
;; classement : plage symbols.json
	.area _B01_437B
sub_437B:
	outi                            ; 437B
	outi                            ; 437D
	outi                            ; 437F
	outi                            ; 4381
	outi                            ; 4383
	outi                            ; 4385
	outi                            ; 4387
	outi                            ; 4389
	outi                            ; 438B
	outi                            ; 438D
	outi                            ; 438F
	outi                            ; 4391
	outi                            ; 4393
	outi                            ; 4395
	outi                            ; 4397
	outi                            ; 4399
	outi                            ; 439B
	outi                            ; 439D
	outi                            ; 439F
	outi                            ; 43A1
	outi                            ; 43A3
	outi                            ; 43A5
	outi                            ; 43A7
	outi                            ; 43A9
	outi                            ; 43AB
	outi                            ; 43AD
	outi                            ; 43AF
	outi                            ; 43B1
	outi                            ; 43B3
	outi                            ; 43B5
	outi                            ; 43B7
	outi                            ; 43B9

;; ---------------------------------------------------------------- $043BB
;; classement : plage symbols.json
	.area _B01_43BB
sub_43BB::
	outi                            ; 43BB
	outi                            ; 43BD
	outi                            ; 43BF
	outi                            ; 43C1
	outi                            ; 43C3
	outi                            ; 43C5
	outi                            ; 43C7
	outi                            ; 43C9
	outi                            ; 43CB
	outi                            ; 43CD
	outi                            ; 43CF
	outi                            ; 43D1
	outi                            ; 43D3
	outi                            ; 43D5
	outi                            ; 43D7
	outi                            ; 43D9
	outi                            ; 43DB
	outi                            ; 43DD
	outi                            ; 43DF
	outi                            ; 43E1
	outi                            ; 43E3
	outi                            ; 43E5
	outi                            ; 43E7
	outi                            ; 43E9
	outi                            ; 43EB
	outi                            ; 43ED
	outi                            ; 43EF
	outi                            ; 43F1
	outi                            ; 43F3
	outi                            ; 43F5
	outi                            ; 43F7
	outi                            ; 43F9

;; ---------------------------------------------------------------- $043FB
;; classement : plage symbols.json
	.area _B01_43FB
sub_43FB:
	outi                            ; 43FB
	outi                            ; 43FD
	outi                            ; 43FF
	outi                            ; 4401
	outi                            ; 4403
	outi                            ; 4405
	outi                            ; 4407
	outi                            ; 4409
	outi                            ; 440B
	outi                            ; 440D
	outi                            ; 440F
	outi                            ; 4411
	outi                            ; 4413
	outi                            ; 4415
	outi                            ; 4417
	outi                            ; 4419
	outi                            ; 441B
	outi                            ; 441D
	outi                            ; 441F
	outi                            ; 4421
	outi                            ; 4423
	outi                            ; 4425
	outi                            ; 4427
	outi                            ; 4429
	outi                            ; 442B
	outi                            ; 442D
	outi                            ; 442F
	outi                            ; 4431
	outi                            ; 4433
	outi                            ; 4435
	outi                            ; 4437
	outi                            ; 4439

;; ---------------------------------------------------------------- $0443B
;; classement : plage symbols.json
	.area _B01_443B
sub_443B:
	outi                            ; 443B
	outi                            ; 443D
	outi                            ; 443F
	outi                            ; 4441
	outi                            ; 4443
	outi                            ; 4445
	outi                            ; 4447
	outi                            ; 4449
	outi                            ; 444B
	outi                            ; 444D
	outi                            ; 444F
	outi                            ; 4451
	outi                            ; 4453
	outi                            ; 4455
	outi                            ; 4457
	outi                            ; 4459
	outi                            ; 445B
	outi                            ; 445D
	outi                            ; 445F
	outi                            ; 4461
	outi                            ; 4463
	outi                            ; 4465
	outi                            ; 4467
	outi                            ; 4469
	outi                            ; 446B
	outi                            ; 446D
	outi                            ; 446F
	outi                            ; 4471
	outi                            ; 4473
	outi                            ; 4475
	outi                            ; 4477
	outi                            ; 4479

;; ---------------------------------------------------------------- $0447B
;; classement : plage symbols.json
	.area _B01_447B
sub_447B:
	outi                            ; 447B
	outi                            ; 447D
	outi                            ; 447F
	outi                            ; 4481
	outi                            ; 4483
	outi                            ; 4485
	outi                            ; 4487
	outi                            ; 4489
	outi                            ; 448B
	outi                            ; 448D
	outi                            ; 448F
	outi                            ; 4491
	outi                            ; 4493
	outi                            ; 4495
	outi                            ; 4497
	outi                            ; 4499
	outi                            ; 449B
	outi                            ; 449D
	outi                            ; 449F
	outi                            ; 44A1
	outi                            ; 44A3
	outi                            ; 44A5
	outi                            ; 44A7
	outi                            ; 44A9
	outi                            ; 44AB
	outi                            ; 44AD
	outi                            ; 44AF
	outi                            ; 44B1
	outi                            ; 44B3
	outi                            ; 44B5
	outi                            ; 44B7
	outi                            ; 44B9
	ret                             ; 44BB

;; ---------------------------------------------------------------- $044BC
;; classement : plage symbols.json
	.area _B01_44BC
sub_44BC::
	ld hl,#vdp_E0E0                 ; 44BC
	ld de,#VDP_VRAM_WRITE|0x3f00    ; 44BF
	ld bc,#0x0020                   ; 44C2
	jr sub_44D0                     ; 44C5

;; ---------------------------------------------------------------- $044C7
;; classement : plage symbols.json
	.area _B01_44C7
sub_44C7::
	ld hl,#0x0000                   ; 44C7

;; ---------------------------------------------------------------- $044CA
;; classement : plage symbols.json
	.area _B01_44CA
sub_44CA::
	ld de,#VDP_VRAM_WRITE|0x3800    ; 44CA
	ld bc,#0x0380                   ; 44CD

;; ---------------------------------------------------------------- $044D0
;; classement : plage symbols.json
	.area _B01_44D0
sub_44D0::
	rst 0x10                        ; 44D0  VDP : adresse/commande = de
	ld a,c                          ; 44D1
	or a                            ; 44D2
	jr z,loc_44D6                   ; 44D3
	inc b                           ; 44D5
loc_44D6:
	ld a,l                          ; 44D6
	out (VDP_DATA),a                ; 44D7  VDP : donnee VRAM/CRAM
	push af                         ; 44D9
	pop af                          ; 44DA
	ld a,h                          ; 44DB
	out (VDP_DATA),a                ; 44DC  VDP : donnee VRAM/CRAM
	dec c                           ; 44DE
	jr nz,loc_44D6                  ; 44DF
	djnz loc_44D6                   ; 44E1
	ret                             ; 44E3

;; ---------------------------------------------------------------- $044E4
;; classement : plage symbols.json
	.area _B01_44E4
sub_44E4::
	push bc                         ; 44E4
	ld b,c                          ; 44E5
	ld a,e                          ; 44E6
	and #0xc0                       ; 44E7
	ld c,a                          ; 44E9
	push de                         ; 44EA
loc_44EB:
	di                              ; 44EB
	rst 0x10                        ; 44EC  VDP : adresse/commande = de
	ld a,(hl)                       ; 44ED
	out (VDP_DATA),a                ; 44EE  VDP : donnee VRAM/CRAM
	inc hl                          ; 44F0
	ld a,(hl)                       ; 44F1
	push af                         ; 44F2
	pop af                          ; 44F3
	out (VDP_DATA),a                ; 44F4  VDP : donnee VRAM/CRAM
	ei                              ; 44F6
	inc e                           ; 44F7
	inc e                           ; 44F8
	ld a,#0x3f                      ; 44F9
	and e                           ; 44FB
	or c                            ; 44FC
	ld e,a                          ; 44FD
	inc hl                          ; 44FE
	dec b                           ; 44FF
	jr nz,loc_44EB                  ; 4500
	pop de                          ; 4502
	ex de,hl                        ; 4503
	ld bc,#0x0040                   ; 4504
	add hl,bc                       ; 4507
	ld a,h                          ; 4508
	cp #0x7f                        ; 4509
	jr nz,loc_450F                  ; 450B
	ld h,#0x78                      ; 450D
loc_450F:
	ex de,hl                        ; 450F
	pop bc                          ; 4510
	djnz sub_44E4                   ; 4511
	ret                             ; 4513

;; ---------------------------------------------------------------- $04514
;; classement : plage symbols.json
	.area _B01_4514
sub_4514:
	push bc                         ; 4514
	ld b,c                          ; 4515
	ld a,e                          ; 4516
	and #0xc0                       ; 4517
	ld c,a                          ; 4519
	push de                         ; 451A
loc_451B:
	di                              ; 451B
	rst 0x10                        ; 451C  VDP : adresse/commande = de
	push af                         ; 451D
	pop af                          ; 451E
	push ix                         ; 451F
	pop ix                          ; 4521
	in a,(VDP_DATA)                 ; 4523  VDP : donnee VRAM/CRAM
	ld (hl),a                       ; 4525
	inc hl                          ; 4526
	push af                         ; 4527
	pop af                          ; 4528
	push ix                         ; 4529
	pop ix                          ; 452B
	in a,(VDP_DATA)                 ; 452D  VDP : donnee VRAM/CRAM
	ld (hl),a                       ; 452F
	ei                              ; 4530
	inc e                           ; 4531
	inc e                           ; 4532
	ld a,#0x3f                      ; 4533
	and e                           ; 4535
	or c                            ; 4536
	ld e,a                          ; 4537
	inc hl                          ; 4538
	dec b                           ; 4539
	jr nz,loc_451B                  ; 453A
	pop de                          ; 453C
	ex de,hl                        ; 453D
	ld bc,#0x0040                   ; 453E
	add hl,bc                       ; 4541
	ld a,h                          ; 4542
	cp #0x3f                        ; 4543
	jr nz,loc_4549                  ; 4545
	ld h,#0x38                      ; 4547
loc_4549:
	ex de,hl                        ; 4549
	pop bc                          ; 454A
	djnz sub_4514                   ; 454B
	ret                             ; 454D

;; ---------------------------------------------------------------- $0454E
;; classement : plage symbols.json
	.area _B01_454E
sub_454E::
	push bc                         ; 454E
	ld b,c                          ; 454F
	ld a,e                          ; 4550
	and #0xc0                       ; 4551
	ld c,a                          ; 4553
	push de                         ; 4554
loc_4555:
	di                              ; 4555
	rst 0x10                        ; 4556  VDP : adresse/commande = de
	ld a,(hl)                       ; 4557
	out (VDP_DATA),a                ; 4558  VDP : donnee VRAM/CRAM
	ld a,(player_C0B1)                 ; 455A
	push ix                         ; 455D
	pop ix                          ; 455F
	out (VDP_DATA),a                ; 4561  VDP : donnee VRAM/CRAM
	ei                              ; 4563
	inc e                           ; 4564
	inc e                           ; 4565
	ld a,#0x3f                      ; 4566
	and e                           ; 4568
	or c                            ; 4569
	ld e,a                          ; 456A
	inc hl                          ; 456B
	dec b                           ; 456C
	jr nz,loc_4555                  ; 456D
	pop de                          ; 456F
	ex de,hl                        ; 4570
	ld bc,#0x0040                   ; 4571
	add hl,bc                       ; 4574
	ld a,h                          ; 4575
	cp #0x7f                        ; 4576
	jr nz,loc_457C                  ; 4578
	ld h,#0x78                      ; 457A
loc_457C:
	ex de,hl                        ; 457C
	pop bc                          ; 457D
	djnz sub_454E                   ; 457E
	ret                             ; 4580

;; ---------------------------------------------------------------- $04581
;; classement : plage symbols.json
	.area _B01_4581
sub_4581:
	xor a                           ; 4581
	jr loc_458C                     ; 4582

;; ---------------------------------------------------------------- $04584
;; classement : plage symbols.json
	.area _B01_4584
sub_4584:
	ld c,(hl)                       ; 4584
	ld b,#0x01                      ; 4585
	inc hl                          ; 4587
	jr loc_458C                     ; 4588
	.db 0x7e, 0x23                  ; 458A
loc_458C:
	push af                         ; 458C
	rst 0x10                        ; 458D  VDP : adresse/commande = de
	pop af                          ; 458E
	push bc                         ; 458F
	ld b,c                          ; 4590
	ld c,#0xbe                      ; 4591
loc_4593:
	outi                            ; 4593
	push ix                         ; 4595
	pop ix                          ; 4597
	nop                             ; 4599
	out (VDP_DATA),a                ; 459A  VDP : donnee VRAM/CRAM
	dec b                           ; 459C
	jr nz,loc_4593                  ; 459D
	ex de,hl                        ; 459F
	ld c,#0x40                      ; 45A0
	add hl,bc                       ; 45A2
	ex de,hl                        ; 45A3
	pop bc                          ; 45A4
	djnz loc_458C                   ; 45A5
	ret                             ; 45A7

;; ---------------------------------------------------------------- $045A8
;; classement : plage symbols.json
	.area _B01_45A8
sub_45A8:
	push af                         ; 45A8
	rst 0x10                        ; 45A9  VDP : adresse/commande = de
	pop af                          ; 45AA
	push bc                         ; 45AB
	ld b,c                          ; 45AC
loc_45AD:
	push af                         ; 45AD
	ld a,l                          ; 45AE
	out (VDP_DATA),a                ; 45AF  VDP : donnee VRAM/CRAM
	pop af                          ; 45B1
	push af                         ; 45B2
	out (VDP_DATA),a                ; 45B3  VDP : donnee VRAM/CRAM
	pop af                          ; 45B5
	push af                         ; 45B6
	ld a,h                          ; 45B7
	out (VDP_DATA),a                ; 45B8  VDP : donnee VRAM/CRAM
	pop af                          ; 45BA
	push af                         ; 45BB
	pop af                          ; 45BC
	out (VDP_DATA),a                ; 45BD  VDP : donnee VRAM/CRAM
	djnz loc_45AD                   ; 45BF
	ex de,hl                        ; 45C1
	ld c,#0x40                      ; 45C2
	add hl,bc                       ; 45C4
	ex de,hl                        ; 45C5
	pop bc                          ; 45C6
	djnz sub_45A8                   ; 45C7
	ret                             ; 45C9

;; ---------------------------------------------------------------- $045CA
;; classement : plage symbols.json
	.area _B01_45CA
sub_45CA::
	rst 0x10                        ; 45CA  VDP : adresse/commande = de
	push bc                         ; 45CB
	ld b,c                          ; 45CC
	ld c,#0xbe                      ; 45CD
loc_45CF:
	outi                            ; 45CF
	push af                         ; 45D1
	pop af                          ; 45D2
	jr nz,loc_45CF                  ; 45D3
	ex de,hl                        ; 45D5
	ld c,#0x40                      ; 45D6
	add hl,bc                       ; 45D8
	ex de,hl                        ; 45D9
	pop bc                          ; 45DA
	djnz sub_45CA                   ; 45DB
	ret                             ; 45DD

;; ---------------------------------------------------------------- $045DE
;; classement : plage symbols.json
	.area _B01_45DE
sub_45DE:
	rst 0x10                        ; 45DE  VDP : adresse/commande = de
	ld a,c                          ; 45DF
	or a                            ; 45E0
	jr z,loc_45E4                   ; 45E1
	inc b                           ; 45E3
loc_45E4:
	ld a,b                          ; 45E4
	ld b,c                          ; 45E5
	ld c,#0xbe                      ; 45E6
loc_45E8:
	outi                            ; 45E8
	push ix                         ; 45EA
	pop ix                          ; 45EC
	jr nz,loc_45E8                  ; 45EE
	dec a                           ; 45F0
	jr nz,loc_45E8                  ; 45F1
	ret                             ; 45F3
	.db 0x11, 0x00, 0x40, 0x21, 0x00 ; 45F4

;; ---------------------------------------------------------------- $045F9
;; classement : plage symbols.json
	.area _B01_45F9
sub_45F9:
	nop                             ; 45F9
	call sub_460D                   ; 45FA
	ld de,#0x4020                   ; 45FD
	ld hl,#MAPPER_SLOT2             ; 4600
	call sub_460D                   ; 4603
	ret                             ; 4606

;; ---------------------------------------------------------------- $04607
;; classement : plage symbols.json
	.area _B01_4607
sub_4607::
	ld de,#VDP_VRAM_WRITE|0x2000    ; 4607
	ld hl,#0x0000                   ; 460A

;; ---------------------------------------------------------------- $0460D
;; classement : plage symbols.json
	.area _B01_460D
sub_460D:
	ld bc,#0x0010                   ; 460D
	di                              ; 4610
	call sub_44D0                   ; 4611
	ei                              ; 4614
	ret                             ; 4615

;; ---------------------------------------------------------------- $04616
;; classement : plage symbols.json
	.area _B01_4616
sub_4616::
	call sub_0042                   ; 4616

;; ---------------------------------------------------------------- $04619
;; classement : plage symbols.json
	.area _B01_4619
sub_4619::
	di                              ; 4619
	call sub_44BC                   ; 461A
	ld hl,#0x0100                   ; 461D
	call sub_44CA                   ; 4620
	ei                              ; 4623
	ret                             ; 4624

;; ---------------------------------------------------------------- $04625
;; classement : plage symbols.json
	.area _B01_4625
sub_4625:
	ld a,(hl)                       ; 4625
	inc hl                          ; 4626
	exx                             ; 4627
	ld e,a                          ; 4628
	ld d,#0x00                      ; 4629
	exx                             ; 462B
	ld b,a                          ; 462C
loc_462D:
	push bc                         ; 462D
	push de                         ; 462E
	exx                             ; 462F
	pop hl                          ; 4630
	push hl                         ; 4631
	exx                             ; 4632
	call sub_463C                   ; 4633
	pop de                          ; 4636
	inc de                          ; 4637
	pop bc                          ; 4638
	djnz loc_462D                   ; 4639
	ret                             ; 463B

;; ---------------------------------------------------------------- $0463C
;; classement : plage symbols.json
	.area _B01_463C
sub_463C:
	ld a,(hl)                       ; 463C
	inc hl                          ; 463D
	or a                            ; 463E
	ret z                           ; 463F
	ld b,a                          ; 4640
	and #0x80                       ; 4641
	ld c,a                          ; 4643
	ld a,b                          ; 4644
	and #0x7f                       ; 4645
	ld b,a                          ; 4647
loc_4648:
	ld a,(hl)                       ; 4648
	push af                         ; 4649
	push bc                         ; 464A
	ld b,a                          ; 464B
	call sub_474E                   ; 464C
	ld (de),a                       ; 464F
	pop bc                          ; 4650
	pop af                          ; 4651
	xor a                           ; 4652
	or c                            ; 4653
	jr z,loc_4657                   ; 4654
	inc hl                          ; 4656
loc_4657:
	exx                             ; 4657
	add hl,de                       ; 4658
	push hl                         ; 4659
	exx                             ; 465A
	pop de                          ; 465B
	djnz loc_4648                   ; 465C
	xor a                           ; 465E
	or c                            ; 465F
	jp nz,sub_463C                  ; 4660
	inc hl                          ; 4663
	jp sub_463C                     ; 4664

;; ---------------------------------------------------------------- $04667
;; classement : plage symbols.json
	.area _B01_4667
sub_4667::
	ld a,(hl)                       ; 4667
	inc hl                          ; 4668
	exx                             ; 4669
	ld e,a                          ; 466A
	ld d,#0x00                      ; 466B
	exx                             ; 466D
	ld b,a                          ; 466E
loc_466F:
	push bc                         ; 466F
	push de                         ; 4670
	exx                             ; 4671
	pop hl                          ; 4672
	push hl                         ; 4673
	exx                             ; 4674
	call sub_467E                   ; 4675
	pop de                          ; 4678
	inc de                          ; 4679
	pop bc                          ; 467A
	djnz loc_466F                   ; 467B
	ret                             ; 467D

;; ---------------------------------------------------------------- $0467E
;; classement : plage symbols.json
	.area _B01_467E
sub_467E:
	ld a,(hl)                       ; 467E
	inc hl                          ; 467F
	or a                            ; 4680
	ret z                           ; 4681
	ld b,a                          ; 4682
	and #0x80                       ; 4683
	ld c,a                          ; 4685
	ld a,b                          ; 4686
	and #0x7f                       ; 4687
	ld b,a                          ; 4689
loc_468A:
	ld a,(hl)                       ; 468A
	ld (de),a                       ; 468B
	xor a                           ; 468C
	or c                            ; 468D
	jr z,loc_4691                   ; 468E
	inc hl                          ; 4690
loc_4691:
	exx                             ; 4691
loc_4692::
	add hl,de                       ; 4692
	push hl                         ; 4693
	exx                             ; 4694
	pop de                          ; 4695
	djnz loc_468A                   ; 4696
	xor a                           ; 4698
	or c                            ; 4699
	jp nz,sub_467E                  ; 469A
	inc hl                          ; 469D
	jp sub_467E                     ; 469E

;; ---------------------------------------------------------------- $046A1
;; classement : plage symbols.json
	.area _B01_46A1
sub_46A1::
	ld a,(hl)                       ; 46A1
	inc hl                          ; 46A2
	exx                             ; 46A3
	ld e,a                          ; 46A4
	ld d,#0x00                      ; 46A5
	exx                             ; 46A7
	ld b,a                          ; 46A8
loc_46A9:
	push bc                         ; 46A9
	push de                         ; 46AA
	exx                             ; 46AB
	pop hl                          ; 46AC
	push hl                         ; 46AD
	exx                             ; 46AE
	call sub_46B8                   ; 46AF
	pop de                          ; 46B2
	inc de                          ; 46B3
	pop bc                          ; 46B4
	djnz loc_46A9                   ; 46B5
	ret                             ; 46B7

;; ---------------------------------------------------------------- $046B8
;; classement : plage symbols.json
	.area _B01_46B8
sub_46B8:
	ld a,(hl)                       ; 46B8
	inc hl                          ; 46B9
	or a                            ; 46BA
	ret z                           ; 46BB
	ld b,a                          ; 46BC
	and #0x80                       ; 46BD
	ld c,a                          ; 46BF
	ld a,b                          ; 46C0
	and #0x7f                       ; 46C1
	ld b,a                          ; 46C3
loc_46C4:
	di                              ; 46C4
	rst 0x10                        ; 46C5  VDP : adresse/commande = de
	ex (sp),hl                      ; 46C6
	ex (sp),hl                      ; 46C7
	jr loc_46CA                     ; 46C8
loc_46CA:
	ld a,(hl)                       ; 46CA
	out (VDP_DATA),a                ; 46CB  VDP : donnee VRAM/CRAM
	ei                              ; 46CD
	xor a                           ; 46CE
	or c                            ; 46CF
	jr z,loc_46D3                   ; 46D0
	inc hl                          ; 46D2
loc_46D3:
	exx                             ; 46D3
	add hl,de                       ; 46D4
	push hl                         ; 46D5
	exx                             ; 46D6
	pop de                          ; 46D7
	djnz loc_46C4                   ; 46D8
	xor a                           ; 46DA
	or c                            ; 46DB
	jp nz,sub_46B8                  ; 46DC
	inc hl                          ; 46DF
	jp sub_46B8                     ; 46E0

;; ---------------------------------------------------------------- $046E3
;; classement : plage symbols.json
	.area _B01_46E3
sub_46E3::
	ld a,(hl)                       ; 46E3
	inc hl                          ; 46E4
	exx                             ; 46E5
	ld e,a                          ; 46E6
	ld d,#0x00                      ; 46E7
	exx                             ; 46E9
	ld b,a                          ; 46EA
loc_46EB:
	push bc                         ; 46EB
	push de                         ; 46EC
	exx                             ; 46ED
	pop hl                          ; 46EE
	push hl                         ; 46EF
	exx                             ; 46F0
	call sub_46FA                   ; 46F1
	pop de                          ; 46F4
	inc de                          ; 46F5
	pop bc                          ; 46F6
	djnz loc_46EB                   ; 46F7
	ret                             ; 46F9

;; ---------------------------------------------------------------- $046FA
;; classement : plage symbols.json
	.area _B01_46FA
sub_46FA:
	ld a,(hl)                       ; 46FA
	inc hl                          ; 46FB
	or a                            ; 46FC
	ret z                           ; 46FD
	ld b,a                          ; 46FE
	and #0x80                       ; 46FF
	ld c,a                          ; 4701
	ld a,b                          ; 4702
	and #0x7f                       ; 4703
	ld b,a                          ; 4705
loc_4706:
	di                              ; 4706
	rst 0x10                        ; 4707  VDP : adresse/commande = de
	ld a,(hl)                       ; 4708
	push af                         ; 4709
	push bc                         ; 470A
	ld b,a                          ; 470B
	call sub_474E                   ; 470C
	out (VDP_DATA),a                ; 470F  VDP : donnee VRAM/CRAM
	ei                              ; 4711
	pop bc                          ; 4712
	pop af                          ; 4713
	xor a                           ; 4714
	or c                            ; 4715
	jr z,loc_4719                   ; 4716
	inc hl                          ; 4718
loc_4719:
	exx                             ; 4719
	add hl,de                       ; 471A
	push hl                         ; 471B
	exx                             ; 471C
	pop de                          ; 471D
	djnz loc_4706                   ; 471E
	xor a                           ; 4720
	or c                            ; 4721
	jp nz,sub_46FA                  ; 4722
	inc hl                          ; 4725
	jp sub_46FA                     ; 4726

;; ---------------------------------------------------------------- $04729
;; classement : SUPPOSE : non atteinte, rangee avec la fonction precedente
	.area _B01_4729
sub_4729:
	push bc                         ; 4729
	ld a,(hl)                       ; 472A
	ld b,a                          ; 472B
	rrc b                           ; 472C
	rla                             ; 472E
	rrc b                           ; 472F
	rla                             ; 4731
	rrc b                           ; 4732
	rla                             ; 4734
	rrc b                           ; 4735
	rla                             ; 4737
	rrc b                           ; 4738
	rla                             ; 473A
	rrc b                           ; 473B
	rla                             ; 473D
	rrc b                           ; 473E
	rla                             ; 4740
	rrc b                           ; 4741
	rla                             ; 4743
	ld (de),a                       ; 4744
	pop bc                          ; 4745
	inc hl                          ; 4746
	inc de                          ; 4747
	dec bc                          ; 4748
	ld a,c                          ; 4749
	or b                            ; 474A
	jr nz,sub_4729                  ; 474B
	ret                             ; 474D
