;; audio/sound_driver.s
;; Driver son PSG (banque 26, execute en slot 1).
;; Genere initialement par tools/disasm/emit.py, puis EDITE A LA MAIN (src/ gele le 2026-11-11).

	.include "hardware.inc"
	.include "ram.inc"
	.include "structs.inc"
	.include "data_banks.inc"
	.include "version.inc"

;; Les labels utilises par d'autres modules sont definis avec '::' (globaux).

;; ---------------------------------------------------------------- $68000
;; classement : plage symbols.json
	.area _B26_4000
sound_update::
	ld a,(snd_DE23)                 ; 4000
	or a                            ; 4003
	ret nz                          ; 4004
	call sub_b26_408A               ; 4005
	call sub_b26_40D5               ; 4008
	call sub_b26_413E               ; 400B
	ld hl,#snd_DE08                 ; 400E
	ld a,(hl)                       ; 4011
	or a                            ; 4012
	jp z,loc_b26_4021               ; 4013
	jp m,loc_b26_4050               ; 4016
	ld (hl),#0x80                   ; 4019
	call sub_b26_44C8               ; 401B
	jp loc_b26_4050                 ; 401E
loc_b26_4021:
	call sub_b26_4072               ; 4021
	ld ix,#snd_DE40                 ; 4024
	bit 7,0(ix)                     ; 4028
	call nz,sub_b26_4605            ; 402C
	ld ix,#snd_DE70                 ; 402F
	bit 7,0(ix)                     ; 4033
	call nz,sub_b26_4605            ; 4037
	ld ix,#snd_DEA0                 ; 403A
	bit 7,0(ix)                     ; 403E
	call nz,sub_b26_4605            ; 4042
	ld ix,#snd_DED0                 ; 4045
	bit 7,0(ix)                     ; 4049
	call nz,sub_b26_470D            ; 404D
loc_b26_4050:
	ld ix,#snd_DF00                 ; 4050
	bit 7,0(ix)                     ; 4054
	call nz,sub_b26_4605            ; 4058
	ld ix,#snd_DF30                 ; 405B
	bit 7,0(ix)                     ; 405F
	call nz,sub_b26_4605            ; 4063
	ld ix,#snd_DF60                 ; 4066
	bit 7,0(ix)                     ; 406A
	call nz,sub_b26_4605            ; 406E
	ret                             ; 4071

;; ---------------------------------------------------------------- $68072
;; classement : plage symbols.json
	.area _B26_4072
sub_b26_4072:
	ld hl,#snd_DE01                 ; 4072
	ld a,(hl)                       ; 4075
	or a                            ; 4076
	ld a,(snd_DE02)                 ; 4077
	add a,(hl)                      ; 407A
	ld (hl),a                       ; 407B
	ret nc                          ; 407C
	ld hl,#snd_DE4A                 ; 407D
	ld de,#0x0030                   ; 4080
	ld b,#0x04                      ; 4083
loc_b26_4085:
	inc (hl)                        ; 4085
	add hl,de                       ; 4086
	djnz loc_b26_4085               ; 4087
	ret                             ; 4089

;; ---------------------------------------------------------------- $6808A
;; classement : plage symbols.json
	.area _B26_408A
sub_b26_408A:
	ld hl,#snd_queue_0              ; 408A
	ld a,(hl)                       ; 408D
	or a                            ; 408E
	jr nz,loc_b26_40BF              ; 408F
	inc hl                          ; 4091
	ld a,(hl)                       ; 4092
	or a                            ; 4093
	jp nz,loc_b26_40CC              ; 4094
	inc hl                          ; 4097
	ld a,(hl)                       ; 4098
	or a                            ; 4099
	ret z                           ; 409A
loc_b26_409B:
	ld (hl),#0x00                   ; 409B
	ld hl,#music_priorities         ; 409D
	ld e,a                          ; 40A0
	sub #0x81                       ; 40A1
	ld c,a                          ; 40A3
	ld b,#0x00                      ; 40A4
	add hl,bc                       ; 40A6
	ld a,(hl)                       ; 40A7
	bit 7,a                         ; 40A8
	jp nz,loc_b26_40B8              ; 40AA
	ld hl,#snd_DE0F                 ; 40AD
	cp (hl)                         ; 40B0
	ret m                           ; 40B1
	ld (hl),a                       ; 40B2
loc_b26_40B3:
	ld a,e                          ; 40B3
	ld (snd_DE03),a                 ; 40B4
	ret                             ; 40B7
loc_b26_40B8:
	xor a                           ; 40B8
	ld (snd_DE0F),a                 ; 40B9
	jp loc_b26_40B3                 ; 40BC
loc_b26_40BF:
	inc hl                          ; 40BF
	ld b,(hl)                       ; 40C0
	inc hl                          ; 40C1
	ld c,(hl)                       ; 40C2
	ld (hl),#0x00                   ; 40C3
	dec hl                          ; 40C5
	ld (hl),c                       ; 40C6
	dec hl                          ; 40C7
	ld (hl),b                       ; 40C8
	jp loc_b26_409B                 ; 40C9
loc_b26_40CC:
	inc hl                          ; 40CC
	ld c,(hl)                       ; 40CD
	ld (hl),#0x00                   ; 40CE
	dec hl                          ; 40D0
	ld (hl),c                       ; 40D1
	jp loc_b26_409B                 ; 40D2

;; ---------------------------------------------------------------- $680D5
;; classement : plage symbols.json
	.area _B26_40D5
sub_b26_40D5:
	ld a,(snd_DE09)                 ; 40D5
	or a                            ; 40D8
	ret z                           ; 40D9
	ld hl,#snd_DF00                 ; 40DA
	ld b,#0x03                      ; 40DD
	ld de,#0x0030                   ; 40DF
loc_b26_40E2:
	bit 7,(hl)                      ; 40E2
	jp z,loc_b26_4109               ; 40E4
	push hl                         ; 40E7
	inc hl                          ; 40E8
	ld a,(hl)                       ; 40E9
	cp #0xa0                        ; 40EA
	jp nz,loc_b26_40F7              ; 40EC
	ld hl,#snd_DE70                 ; 40EF
	res 2,(hl)                      ; 40F2
	jp loc_b26_4106                 ; 40F4
loc_b26_40F7:
	cp #0xe0                        ; 40F7
	jp nz,loc_b26_4101              ; 40F9
	ld hl,#snd_DED0                 ; 40FC
	res 2,(hl)                      ; 40FF
loc_b26_4101:
	ld hl,#snd_DEA0                 ; 4101
	res 2,(hl)                      ; 4104
loc_b26_4106:
	pop hl                          ; 4106
	xor a                           ; 4107
	ld (hl),a                       ; 4108
loc_b26_4109:
	add hl,de                       ; 4109
	djnz loc_b26_40E2               ; 410A
	ld a,(snd_DE0A)                 ; 410C
	dec a                           ; 410F
	jr z,loc_b26_4116               ; 4110
	ld (snd_DE0A),a                 ; 4112
	ret                             ; 4115
loc_b26_4116:
	ld a,(snd_DE0B)                 ; 4116
	ld (snd_DE0A),a                 ; 4119
	ld a,(snd_DE09)                 ; 411C
	dec a                           ; 411F
	ld (snd_DE09),a                 ; 4120
	jp z,sub_b26_44A9               ; 4123
	ld hl,#snd_DE46                 ; 4126
	ld de,#0x0030                   ; 4129
	ld b,#0x03                      ; 412C
loc_b26_412E:
	call sub_b26_4137               ; 412E
	add hl,de                       ; 4131
	djnz loc_b26_412E               ; 4132
	ld hl,#snd_DE16                 ; 4134

;; ---------------------------------------------------------------- $68137
;; classement : plage symbols.json
	.area _B26_4137
sub_b26_4137:
	ld a,(hl)                       ; 4137
	inc a                           ; 4138
	cp #0x0c                        ; 4139
	ret nc                          ; 413B
	ld (hl),a                       ; 413C
	ret                             ; 413D

;; ---------------------------------------------------------------- $6813E
;; classement : plage symbols.json
	.area _B26_413E
sub_b26_413E:
	ld a,(snd_DE03)                 ; 413E
	bit 7,a                         ; 4141
	jp z,sub_b26_44A9               ; 4143
	cp #0xa0                        ; 4146
	jp c,loc_b26_41FC               ; 4148
	cp #0xc7                        ; 414B
	jp c,loc_b26_4232               ; 414D
	cp #0xe2                        ; 4150
	jp nc,sub_b26_44A9              ; 4152
	sub #0xdb                       ; 4155
	ld hl,#jt_b26_4164              ; 4157
	ld c,a                          ; 415A
	ld b,#0x00                      ; 415B
	add hl,bc                       ; 415D
	add hl,bc                       ; 415E
	ld c,(hl)                       ; 415F
	inc hl                          ; 4160
	ld h,(hl)                       ; 4161
	ld l,c                          ; 4162
	jp (hl)                         ; 4163
jt_b26_4164:
	.dw loc_b26_41D4                ; 4164
	.dw sub_b26_44A9                ; 4166
	.dw loc_b26_41E4                ; 4168
	.dw loc_b26_4176                ; 416A
	.dw loc_b26_4193                ; 416C
	.dw loc_b26_4172                ; 416E
	.dw loc_b26_4172                ; 4170
loc_b26_4172:
	call sub_b26_4A5A               ; 4172
	ret                             ; 4175
loc_b26_4176:
	ld a,(snd_DE01)                 ; 4176
	ld (snd_E050),a                 ; 4179
	ld a,(snd_DE02)                 ; 417C
	ld (snd_E051),a                 ; 417F
	ld bc,#0x00c0                   ; 4182
	ld hl,#snd_DE40                 ; 4185
	ld de,#snd_DF90                 ; 4188
loc_b26_418B:
	ldi                             ; 418B
	jp pe,loc_b26_418B              ; 418D
	jp loc_b26_422C                 ; 4190
loc_b26_4193:
	ld a,(snd_E050)                 ; 4193
	ld (snd_DE01),a                 ; 4196
	ld a,(snd_E051)                 ; 4199
	ld (snd_DE02),a                 ; 419C
	ld bc,#0x00c0                   ; 419F
	ld de,#snd_DE40                 ; 41A2
	ld hl,#snd_DF90                 ; 41A5
loc_b26_41A8:
	ldi                             ; 41A8
	jp pe,loc_b26_41A8              ; 41AA
	push ix                         ; 41AD
	ld ix,#snd_DE40                 ; 41AF
	call sub_b26_462D               ; 41B3
	ld ix,#snd_DE70                 ; 41B6
	call sub_b26_462D               ; 41BA
	ld ix,#snd_DEA0                 ; 41BD
	call sub_b26_462D               ; 41C1
	ld ix,#snd_DED0                 ; 41C4
	call sub_b26_462D               ; 41C8
	ld a,#0xff                      ; 41CB
	out (PSG_PORT),a                ; 41CD  PSG (son)
	pop ix                          ; 41CF
	jp loc_b26_422C                 ; 41D1
loc_b26_41D4:
	ld a,#0x0c                      ; 41D4
	ld (snd_DE09),a                 ; 41D6
	ld a,#0x06                      ; 41D9
	ld (snd_DE0A),a                 ; 41DB
	ld (snd_DE0B),a                 ; 41DE
	jp loc_b26_422C                 ; 41E1
loc_b26_41E4:
	ld iy,#snd_DF00                 ; 41E4
	ld de,#0x0030                   ; 41E8
	ld b,#0x03                      ; 41EB
	ld hl,#data_b26_41FB            ; 41ED
loc_b26_41F0:
	ld 3(iy),l                      ; 41F0
	ld 4(iy),h                      ; 41F3
	add iy,de                       ; 41F6
	djnz loc_b26_41F0               ; 41F8
	ret                             ; 41FA
data_b26_41FB:
	.db 0xf2                        ; 41FB
loc_b26_41FC:
	sub #0x81                       ; 41FC
	ret m                           ; 41FE
	ex af,af'                       ; 41FF
	call sub_b26_4485               ; 4200
	ex af,af'                       ; 4203
	ld hl,#music_song_table         ; 4204
	ld c,a                          ; 4207
	ld b,#0x00                      ; 4208
	add hl,bc                       ; 420A
	add hl,bc                       ; 420B
	ld c,(hl)                       ; 420C
	inc hl                          ; 420D
	ld h,(hl)                       ; 420E
	ld l,c                          ; 420F
	inc hl                          ; 4210
	inc hl                          ; 4211
	ld b,(hl)                       ; 4212
	inc hl                          ; 4213
	inc hl                          ; 4214
	ld a,(hl)                       ; 4215
	ex af,af'                       ; 4216
	inc hl                          ; 4217
	ld a,(hl)                       ; 4218
	ld (snd_DE01),a                 ; 4219
	ld (snd_DE02),a                 ; 421C
	ld iy,#data_b26_4308            ; 421F
	inc hl                          ; 4223
	ld de,#snd_DE40                 ; 4224
loc_b26_4227:
	call sub_b26_42CA               ; 4227
	djnz loc_b26_4227               ; 422A
loc_b26_422C:
	ld a,#0x80                      ; 422C
	ld (snd_DE03),a                 ; 422E
	ret                             ; 4231
loc_b26_4232:
	sub #0xa0                       ; 4232
	ld hl,#music_sfx_table          ; 4234
	ld c,a                          ; 4237
	ld b,#0x00                      ; 4238
	add hl,bc                       ; 423A
	add hl,bc                       ; 423B
	ld c,(hl)                       ; 423C
	inc hl                          ; 423D
	ld h,(hl)                       ; 423E
	ld l,c                          ; 423F
	inc hl                          ; 4240
	inc hl                          ; 4241
	ld a,(hl)                       ; 4242
	inc hl                          ; 4243
	ex af,af'                       ; 4244
	ld b,(hl)                       ; 4245
	inc hl                          ; 4246
loc_b26_4247:
	inc hl                          ; 4247
	ld a,(hl)                       ; 4248
	dec hl                          ; 4249
	cp #0xa0                        ; 424A
	jr z,loc_b26_4276               ; 424C
	cp #0xc0                        ; 424E
	jr z,loc_b26_425B               ; 4250
	ld de,#snd_DF60                 ; 4252
	ld iy,#snd_DED0                 ; 4255
	jr loc_b26_427D                 ; 4259
loc_b26_425B:
	ld iy,#snd_DF60                 ; 425B
	bit 6,0(iy)                     ; 425F
	jr nz,loc_b26_426D              ; 4263
	set 2,0(iy)                     ; 4265
	ld a,#0xff                      ; 4269
	out (PSG_PORT),a                ; 426B  PSG (son)
loc_b26_426D:
	ld de,#snd_DF30                 ; 426D
	ld iy,#snd_DEA0                 ; 4270
	jr loc_b26_427D                 ; 4274
loc_b26_4276:
	ld de,#snd_DF00                 ; 4276
	ld iy,#snd_DE70                 ; 4279
loc_b26_427D:
	call sub_b26_4284               ; 427D
	djnz loc_b26_4247               ; 4280
	jr loc_b26_422C                 ; 4282

;; ---------------------------------------------------------------- $68284
;; classement : plage symbols.json
	.area _B26_4284
sub_b26_4284:
	set 2,0(iy)                     ; 4284
	ld c,#0x36                      ; 4288
	push de                         ; 428A
	pop ix                          ; 428B
	ldi                             ; 428D
	ldi                             ; 428F
	ex af,af'                       ; 4291
	ld (de),a                       ; 4292
	inc de                          ; 4293
	ex af,af'                       ; 4294
	xor a                           ; 4295
	ldi                             ; 4296
	ldi                             ; 4298
	ldi                             ; 429A
	ldi                             ; 429C
	ld (de),a                       ; 429E
	inc de                          ; 429F
	ld (de),a                       ; 42A0
	inc de                          ; 42A1
	ld a,c                          ; 42A2
	ld (de),a                       ; 42A3
	inc de                          ; 42A4
	ld a,#0xff                      ; 42A5
	push bc                         ; 42A7
	ld c,#0x06                      ; 42A8
.if VERSION_SMS_EN
	nop                             ; 42AA
	nop                             ; 42AB
.else ; VERSION_GG_JP
	out (c),a                       ; 42AA
.endif
	pop bc                          ; 42AC
	xor a                           ; 42AD
	ld 37(ix),a                     ; 42AE
	ld 39(ix),a                     ; 42B1
	ld 40(ix),a                     ; 42B4
	ld 41(ix),a                     ; 42B7
	ld 42(ix),a                     ; 42BA
	ld 43(ix),a                     ; 42BD
	inc a                           ; 42C0
	ld (de),a                       ; 42C1
	push hl                         ; 42C2
	ld hl,#0x0026                   ; 42C3
	add hl,de                       ; 42C6
	ex de,hl                        ; 42C7
	pop hl                          ; 42C8
	ret                             ; 42C9

;; ---------------------------------------------------------------- $682CA
;; classement : plage symbols.json
	.area _B26_42CA
sub_b26_42CA:
	ld c,#0x34                      ; 42CA
	push de                         ; 42CC
	pop ix                          ; 42CD
	ld a,#0x80                      ; 42CF
	ld (de),a                       ; 42D1
	inc de                          ; 42D2
	ld a,0(iy)                      ; 42D3
	ld (de),a                       ; 42D6
	inc de                          ; 42D7
	inc iy                          ; 42D8
	ex af,af'                       ; 42DA
	ld (de),a                       ; 42DB
	inc de                          ; 42DC
	ex af,af'                       ; 42DD
	xor a                           ; 42DE
	ldi                             ; 42DF
	ldi                             ; 42E1
	ldi                             ; 42E3
	ldi                             ; 42E5
	ld (de),a                       ; 42E7
	inc de                          ; 42E8
	ld (de),a                       ; 42E9
	inc de                          ; 42EA
	ld a,c                          ; 42EB
	ld (de),a                       ; 42EC
	inc de                          ; 42ED
	xor a                           ; 42EE
	ld 39(ix),a                     ; 42EF
	ld 40(ix),a                     ; 42F2
	ld 41(ix),a                     ; 42F5
	ld 42(ix),a                     ; 42F8
	ld 43(ix),a                     ; 42FB
	inc a                           ; 42FE
	ld (de),a                       ; 42FF
	push hl                         ; 4300
	ld hl,#0x0026                   ; 4301
	add hl,de                       ; 4304
	ex de,hl                        ; 4305
	pop hl                          ; 4306
	ret                             ; 4307
data_b26_4308:
	.db 0x80, 0xa0, 0xc0, 0xe0      ; 4308

;; ---------------------------------------------------------------- $6830C
;; classement : plage symbols.json
	.area _B26_430C
sub_b26_430C:
	bit 7,7(ix)                     ; 430C
	ret z                           ; 4310
	bit 1,0(ix)                     ; 4311
	ret nz                          ; 4315
	ld e,16(ix)                     ; 4316
	ld d,17(ix)                     ; 4319
	push ix                         ; 431C
	pop hl                          ; 431E
	ld b,#0x00                      ; 431F
	ld c,#0x14                      ; 4321
	add hl,bc                       ; 4323
	ex de,hl                        ; 4324
	ldi                             ; 4325
	ldi                             ; 4327
	ldi                             ; 4329
	ld a,(hl)                       ; 432B
	srl a                           ; 432C
	ld (de),a                       ; 432E
	inc de                          ; 432F
	ld a,20(ix)                     ; 4330
	ld (de),a                       ; 4333
	inc de                          ; 4334
	ld a,21(ix)                     ; 4335
	ld (de),a                       ; 4338
	inc de                          ; 4339
	ld a,22(ix)                     ; 433A
	ld (de),a                       ; 433D
	inc de                          ; 433E
	ld a,23(ix)                     ; 433F
	ld (de),a                       ; 4342
	xor a                           ; 4343
	ld 18(ix),a                     ; 4344
	ld 19(ix),a                     ; 4347
	ret                             ; 434A

;; ---------------------------------------------------------------- $6834B
;; classement : plage symbols.json
	.area _B26_434B
sub_b26_434B:
	ld l,11(ix)                     ; 434B
	ld h,12(ix)                     ; 434E
	ld a,7(ix)                      ; 4351
	or a                            ; 4354
	ret z                           ; 4355
	jp p,loc_b26_43A9               ; 4356
	dec 20(ix)                      ; 4359
	ret nz                          ; 435C
	inc 20(ix)                      ; 435D
	push hl                         ; 4360
	ld l,18(ix)                     ; 4361
	ld h,19(ix)                     ; 4364
	dec 21(ix)                      ; 4367
	jr nz,loc_b26_438F              ; 436A
	ld e,16(ix)                     ; 436C
	ld d,17(ix)                     ; 436F
	push de                         ; 4372
	pop iy                          ; 4373
	ld a,1(iy)                      ; 4375
	ld a,25(ix)                     ; 4378
	ld 21(ix),a                     ; 437B
	ld a,22(ix)                     ; 437E
	ld c,a                          ; 4381
	and #0x80                       ; 4382
	rlca                            ; 4384
	neg                             ; 4385
	ld b,a                          ; 4387
	add hl,bc                       ; 4388
	ld 18(ix),l                     ; 4389
	ld 19(ix),h                     ; 438C
loc_b26_438F:
	pop bc                          ; 438F
	add hl,bc                       ; 4390
	dec 23(ix)                      ; 4391
	ret nz                          ; 4394
	ld a,3(iy)                      ; 4395
	ld a,27(ix)                     ; 4398
	sla a                           ; 439B
	ld 23(ix),a                     ; 439D
	ld a,22(ix)                     ; 43A0
	neg                             ; 43A3
	ld 22(ix),a                     ; 43A5
	ret                             ; 43A8
loc_b26_43A9:
	dec a                           ; 43A9
	ex de,hl                        ; 43AA
	ld hl,#music_table_5692         ; 43AB
	ld c,a                          ; 43AE
	ld b,#0x00                      ; 43AF
	add hl,bc                       ; 43B1
	add hl,bc                       ; 43B2
	ld c,(hl)                       ; 43B3
	inc hl                          ; 43B4
	ld h,(hl)                       ; 43B5
	ld l,c                          ; 43B6
	jr loc_b26_43BC                 ; 43B7
loc_b26_43B9:
	ld 21(ix),a                     ; 43B9
loc_b26_43BC:
	push hl                         ; 43BC
	ld c,21(ix)                     ; 43BD
	ld b,#0x00                      ; 43C0
	add hl,bc                       ; 43C2
	ld a,(hl)                       ; 43C3
	pop hl                          ; 43C4
	bit 7,a                         ; 43C5
	jr z,loc_b26_43E4               ; 43C7
	cp #0x83                        ; 43C9
	jr z,loc_b26_43D9               ; 43CB
	jr nc,loc_b26_43E0              ; 43CD
	cp #0x80                        ; 43CF
	jr z,loc_b26_43DD               ; 43D1
	set 5,0(ix)                     ; 43D3
	pop hl                          ; 43D7
	ret                             ; 43D8
loc_b26_43D9:
	inc de                          ; 43D9
	ld a,(de)                       ; 43DA
	jr loc_b26_43B9                 ; 43DB
loc_b26_43DD:
	xor a                           ; 43DD
	jr loc_b26_43B9                 ; 43DE
loc_b26_43E0:
	ld h,#0xff                      ; 43E0
	jr loc_b26_43E6                 ; 43E2
loc_b26_43E4:
	ld h,#0x00                      ; 43E4
loc_b26_43E6:
	ld l,a                          ; 43E6
	add hl,de                       ; 43E7
	inc 21(ix)                      ; 43E8
	ret                             ; 43EB

;; ---------------------------------------------------------------- $683EC
;; classement : plage symbols.json
	.area _B26_43EC
sub_b26_43EC:
	res 1,0(ix)                     ; 43EC
	res 4,0(ix)                     ; 43F0
	ld e,3(ix)                      ; 43F4
	ld d,4(ix)                      ; 43F7
	ld a,(de)                       ; 43FA
	inc de                          ; 43FB
	cp #0xe1                        ; 43FC
	jp nc,loc_b26_47B9              ; 43FE
	bit 3,0(ix)                     ; 4401
	jp nz,loc_b26_4467              ; 4405
	cp #0x80                        ; 4408
	jr c,loc_b26_442A               ; 440A
	jr z,loc_b26_445E               ; 440C
	res 7,36(ix)                    ; 440E
	call sub_b26_44E2               ; 4412
	ld 11(ix),l                     ; 4415
	ld 12(ix),h                     ; 4418
loc_b26_441B:
	ld a,(de)                       ; 441B
	inc de                          ; 441C
	or a                            ; 441D
	jp p,loc_b26_442A               ; 441E
	ld a,13(ix)                     ; 4421
	ld 10(ix),a                     ; 4424
	dec de                          ; 4427
	jr loc_b26_4433                 ; 4428
loc_b26_442A:
	call sub_b26_44FB               ; 442A
	ld 10(ix),a                     ; 442D
	ld 13(ix),a                     ; 4430
loc_b26_4433:
	ld 3(ix),e                      ; 4433
	ld 4(ix),d                      ; 4436
	bit 1,0(ix)                     ; 4439
	ret nz                          ; 443D
	bit 6,0(ix)                     ; 443E
	jr nz,loc_b26_4448              ; 4442
	res 5,0(ix)                     ; 4444
loc_b26_4448:
	ld a,15(ix)                     ; 4448
	ld 14(ix),a                     ; 444B
	xor a                           ; 444E
	ld 21(ix),a                     ; 444F
	bit 7,36(ix)                    ; 4452
	ret nz                          ; 4456
	ld 31(ix),a                     ; 4457
	ld 35(ix),a                     ; 445A
	ret                             ; 445D
loc_b26_445E:
	set 7,36(ix)                    ; 445E
	call sub_b26_46EB               ; 4462
	jr loc_b26_441B                 ; 4465
loc_b26_4467:
	ld h,a                          ; 4467
	ld a,(de)                       ; 4468
	inc de                          ; 4469
	ld l,a                          ; 446A
	or h                            ; 446B
	jr z,loc_b26_447A               ; 446C
	ld b,#0x00                      ; 446E
	ld a,5(ix)                      ; 4470
	or a                            ; 4473
	ld c,a                          ; 4474
	jp p,loc_b26_4479               ; 4475
	dec b                           ; 4478
loc_b26_4479:
	add hl,bc                       ; 4479
loc_b26_447A:
	ld 11(ix),l                     ; 447A
	ld 12(ix),h                     ; 447D
	ld a,(de)                       ; 4480
	inc de                          ; 4481
	jp loc_b26_442A                 ; 4482

;; ---------------------------------------------------------------- $68485
;; classement : plage symbols.json
	.area _B26_4485
sub_b26_4485:
	push hl                         ; 4485
	push bc                         ; 4486
	push de                         ; 4487
	di                              ; 4488
	ld hl,#0x0000                   ; 4489
	add hl,sp                       ; 448C
	ld sp,#0xdf00                   ; 448D
	ld de,#0x0000                   ; 4490
	ld b,#0x7d                      ; 4493
loc_b26_4495:
	push de                         ; 4495
	djnz loc_b26_4495               ; 4496
	ld sp,hl                        ; 4498
	ei                              ; 4499
	ld a,#0xff                      ; 449A
	ld (snd_DE10),a                 ; 449C
	ld c,#0x06                      ; 449F
.if VERSION_SMS_EN
	nop                             ; 44A1
	nop                             ; 44A2
.else ; VERSION_GG_JP
	out (c),a                       ; 44A1
.endif
	pop de                          ; 44A3
	pop bc                          ; 44A4
	pop hl                          ; 44A5
	jp sub_b26_44C8                 ; 44A6

;; ---------------------------------------------------------------- $684A9
;; classement : plage symbols.json
	.area _B26_44A9
sub_b26_44A9::
	push hl                         ; 44A9
	push bc                         ; 44AA
	push de                         ; 44AB
	ld hl,#0x0000                   ; 44AC
	add hl,sp                       ; 44AF
	ld sp,#0xdf90                   ; 44B0
	ld de,#0x0000                   ; 44B3
	ld b,#0xc7                      ; 44B6
loc_b26_44B8:
	push de                         ; 44B8
	djnz loc_b26_44B8               ; 44B9
	ld sp,hl                        ; 44BB
	ld a,#0xff                      ; 44BC
	ld (snd_DE10),a                 ; 44BE
	ld c,#0x06                      ; 44C1
.if VERSION_SMS_EN
	nop                             ; 44C3
	nop                             ; 44C4
.else ; VERSION_GG_JP
	out (c),a                       ; 44C3
.endif
	pop de                          ; 44C5
	pop bc                          ; 44C6
	pop hl                          ; 44C7

;; ---------------------------------------------------------------- $684C8
;; classement : plage symbols.json
	.area _B26_44C8
sub_b26_44C8:
	push hl                         ; 44C8
	push bc                         ; 44C9
	ld hl,#data_b26_44D8            ; 44CA
	ld b,#0x0a                      ; 44CD
	ld c,#0x7f                      ; 44CF
	otir                            ; 44D1
	pop bc                          ; 44D3
	pop hl                          ; 44D4
	jp loc_b26_422C                 ; 44D5
data_b26_44D8:
	.db 0x80, 0x00, 0xa0, 0x00, 0xc0, 0x00, 0x9f, 0xbf ; 44D8
	.db 0xdf, 0xff                  ; 44E0

;; ---------------------------------------------------------------- $684E2
;; classement : plage symbols.json
	.area _B26_44E2
sub_b26_44E2:
	sub #0x81                       ; 44E2
	add a,5(ix)                     ; 44E4
	and #0x7f                       ; 44E7
	ld hl,#data_b26_4505            ; 44E9
	ld c,a                          ; 44EC
	ld b,#0x00                      ; 44ED
	add hl,bc                       ; 44EF
	add hl,bc                       ; 44F0
	ld c,(hl)                       ; 44F1
	inc hl                          ; 44F2
	ld h,(hl)                       ; 44F3
	ld l,c                          ; 44F4
	ret                             ; 44F5
	.db 0x06, 0x00, 0x09, 0x7e, 0xc9 ; 44F6

;; ---------------------------------------------------------------- $684FB
;; classement : plage symbols.json
	.area _B26_44FB
sub_b26_44FB:
	ld b,2(ix)                      ; 44FB
	dec b                           ; 44FE
	ret z                           ; 44FF
	ld c,a                          ; 4500
loc_b26_4501:
	add a,c                         ; 4501
	djnz loc_b26_4501               ; 4502
	ret                             ; 4504
data_b26_4505:
	.db 0xac, 0x01, 0x94, 0x01, 0x7c, 0x01, 0x68, 0x01, 0x53, 0x01, 0x40 ; 4505
	.db 0x01, 0x2e, 0x01, 0x1d, 0x01, 0x0d, 0x01, 0xfe, 0x00, 0xf0, 0x00, 0xe2, 0x00, 0xd6, 0x00, 0xca ; 4510
	.db 0x00, 0xbe, 0x00, 0xb4, 0x00, 0xaa, 0x00, 0xa0, 0x00, 0x97, 0x00, 0x8f, 0x00, 0x87, 0x00, 0x7f ; 4520
	.db 0x00, 0x78, 0x00, 0x71, 0x00, 0x6b, 0x00, 0x65, 0x00, 0x5f, 0x00, 0x5a, 0x00, 0x55, 0x00, 0x50 ; 4530
	.db 0x00, 0x4c, 0x00, 0x47, 0x00, 0x43, 0x00, 0xf9, 0x03, 0xc0, 0x03, 0x8a, 0x03, 0x57, 0x03, 0x27 ; 4540
	.db 0x03, 0xfa, 0x02, 0xcf, 0x02, 0xa7, 0x02, 0x81, 0x02, 0x5d, 0x02, 0x3b, 0x02, 0x1b, 0x02, 0xfc ; 4550
	.db 0x01, 0xe0, 0x01, 0xc5, 0x01, 0xac, 0x01, 0x94, 0x01, 0x7c, 0x01, 0x68, 0x01, 0x53, 0x01, 0x40 ; 4560
	.db 0x01, 0x2e, 0x01, 0x1d, 0x01, 0x0d, 0x01, 0xfe, 0x00, 0xf0, 0x00, 0xe2, 0x00, 0xd6, 0x00, 0xca ; 4570
	.db 0x00, 0xbe, 0x00, 0xb4, 0x00, 0xaa, 0x00, 0xa0, 0x00, 0x97, 0x00, 0x8f, 0x00, 0x87, 0x00, 0x7f ; 4580
	.db 0x00, 0x78, 0x00, 0x71, 0x00, 0x6b, 0x00, 0x65, 0x00, 0x5f, 0x00, 0x5a, 0x00, 0x55, 0x00, 0x50 ; 4590
	.db 0x00, 0x4c, 0x00, 0x47, 0x00, 0x43, 0x00, 0x40, 0x00, 0x3c, 0x00, 0x39, 0x00, 0x36, 0x00, 0x33 ; 45A0
	.db 0x00, 0x30, 0x00, 0x2d, 0x00, 0x2b, 0x00, 0x28, 0x00, 0x26, 0x00, 0x24, 0x00, 0x22, 0x00, 0x20 ; 45B0
	.db 0x00, 0x1f, 0x00, 0x1d, 0x00, 0x1b, 0x00, 0x1a, 0x00, 0x18, 0x00, 0x17, 0x00, 0x16, 0x00, 0x15 ; 45C0
	.db 0x00, 0x13, 0x00, 0x12, 0x00, 0x11, 0x00, 0x10, 0x00, 0x0f, 0x00, 0x0e, 0x00, 0x0d, 0x00, 0x0c ; 45D0
	.db 0x00, 0x0b, 0x00, 0x0a, 0x00, 0x09, 0x00, 0xf9, 0x03, 0xc0, 0x03, 0x8a, 0x03, 0x57, 0x03, 0x27 ; 45E0
	.db 0x03, 0xfa, 0x02, 0xcf, 0x02, 0xa7, 0x02, 0x81, 0x02, 0x5d, 0x02, 0x3b, 0x02, 0x1b, 0x02, 0xfc ; 45F0
	.db 0x01, 0xe0, 0x01, 0xc5, 0x01 ; 4600

;; ---------------------------------------------------------------- $68605
;; classement : plage symbols.json
	.area _B26_4605
sub_b26_4605:
	dec 10(ix)                      ; 4605
	jr nz,loc_b26_461C              ; 4608
	call sub_b26_43EC               ; 460A
	bit 4,0(ix)                     ; 460D
	ret nz                          ; 4611
	bit 2,0(ix)                     ; 4612
	ret nz                          ; 4616
	call sub_b26_430C               ; 4617
	jr loc_b26_4639                 ; 461A
loc_b26_461C:
	bit 2,0(ix)                     ; 461C
	ret nz                          ; 4620
	ld a,14(ix)                     ; 4621
	or a                            ; 4624
	jr z,sub_b26_462D               ; 4625
	dec 14(ix)                      ; 4627
	call z,sub_b26_46EB             ; 462A

;; ---------------------------------------------------------------- $6862D
;; classement : plage symbols.json
	.area _B26_462D
sub_b26_462D:
	ld a,7(ix)                      ; 462D
	or a                            ; 4630
	jr z,sub_b26_4668               ; 4631
	bit 5,0(ix)                     ; 4633
	jr nz,sub_b26_4668              ; 4637
loc_b26_4639:
	bit 6,0(ix)                     ; 4639
	jr nz,sub_b26_4668              ; 463D
	call sub_b26_434B               ; 463F
	ld d,#0x00                      ; 4642
	ld a,37(ix)                     ; 4644
	or a                            ; 4647
	jp p,loc_b26_464C               ; 4648
	dec d                           ; 464B
loc_b26_464C:
	ld e,a                          ; 464C
	add hl,de                       ; 464D
	ld a,1(ix)                      ; 464E
	cp #0xe0                        ; 4651
	jr nz,loc_b26_4657              ; 4653
	ld a,#0xc0                      ; 4655
loc_b26_4657:
	ld c,a                          ; 4657
	ld a,l                          ; 4658
	and #0x0f                       ; 4659
	or c                            ; 465B
	out (PSG_PORT),a                ; 465C  PSG (son)
	ld a,l                          ; 465E
	and #0xf0                       ; 465F
	or h                            ; 4661
	rrca                            ; 4662
	rrca                            ; 4663
	rrca                            ; 4664
	rrca                            ; 4665
	out (PSG_PORT),a                ; 4666  PSG (son)

;; ---------------------------------------------------------------- $68668
;; classement : plage symbols.json
	.area _B26_4668
sub_b26_4668:
	ld a,8(ix)                      ; 4668
	or a                            ; 466B
	ret z                           ; 466C
	bit 7,36(ix)                    ; 466D
	jp z,loc_b26_467A               ; 4671
	jp loc_b26_46B6                 ; 4674
	.db 0xdd, 0x77, 0x1f            ; 4677
loc_b26_467A:
	push hl                         ; 467A
	ld l,31(ix)                     ; 467B
	ld h,#0x00                      ; 467E
	ld c,46(ix)                     ; 4680
	ld b,47(ix)                     ; 4683
	add hl,bc                       ; 4686
	ld a,(hl)                       ; 4687
	pop hl                          ; 4688
	bit 7,a                         ; 4689
	jp z,loc_b26_4693               ; 468B
	set 4,0(ix)                     ; 468E
	ret                             ; 4692
loc_b26_4693:
	inc 31(ix)                      ; 4693
loc_b26_4696:
	bit 2,0(ix)                     ; 4696
	ret nz                          ; 469A
	bit 4,0(ix)                     ; 469B
	ret nz                          ; 469F
	ld 30(ix),a                     ; 46A0
	add a,6(ix)                     ; 46A3
	bit 4,a                         ; 46A6
	jr z,loc_b26_46AC               ; 46A8
	ld a,#0x0f                      ; 46AA
loc_b26_46AC:
	and #0x0f                       ; 46AC
	or 1(ix)                        ; 46AE
	add a,#0x10                     ; 46B1
	out (PSG_PORT),a                ; 46B3  PSG (son)
	ret                             ; 46B5
loc_b26_46B6:
	ld a,35(ix)                     ; 46B6
	or a                            ; 46B9
	jp z,loc_b26_46C3               ; 46BA
	ld a,30(ix)                     ; 46BD
	jp loc_b26_46E5                 ; 46C0
loc_b26_46C3:
	ld a,34(ix)                     ; 46C3
	ld 35(ix),a                     ; 46C6
	ld b,30(ix)                     ; 46C9
	ld a,#0x0e                      ; 46CC
	cp b                            ; 46CE
	ld a,b                          ; 46CF
	jp nc,loc_b26_46DA              ; 46D0
	res 7,36(ix)                    ; 46D3
	jp loc_b26_46FC                 ; 46D7
loc_b26_46DA:
	ld b,32(ix)                     ; 46DA
	cp b                            ; 46DD
	jp p,loc_b26_46E2               ; 46DE
	ld a,b                          ; 46E1
loc_b26_46E2:
	add a,33(ix)                    ; 46E2
loc_b26_46E5:
	dec 35(ix)                      ; 46E5
	jp loc_b26_4696                 ; 46E8

;; ---------------------------------------------------------------- $686EB
;; classement : plage symbols.json
	.area _B26_46EB
sub_b26_46EB:
	bit 1,0(ix)                     ; 46EB
	ret nz                          ; 46EF
	bit 7,36(ix)                    ; 46F0
	jp z,loc_b26_46FC               ; 46F4
	set 7,36(ix)                    ; 46F7
	ret                             ; 46FB
loc_b26_46FC:
	set 4,0(ix)                     ; 46FC
	bit 2,0(ix)                     ; 4700
	ret nz                          ; 4704
	ld a,#0x1f                      ; 4705
	add a,1(ix)                     ; 4707
	out (PSG_PORT),a                ; 470A  PSG (son)
	ret                             ; 470C

;; ---------------------------------------------------------------- $6870D
;; classement : plage symbols.json
	.area _B26_470D
sub_b26_470D:
	ld a,(snd_DE09)                 ; 470D
	or a                            ; 4710
	jp z,loc_b26_4717               ; 4711
	jp loc_b26_46FC                 ; 4714
loc_b26_4717:
	dec 10(ix)                      ; 4717
	jp nz,sub_b26_4668              ; 471A
	res 4,0(ix)                     ; 471D
	ld e,3(ix)                      ; 4721
	ld d,4(ix)                      ; 4724
	ld a,(de)                       ; 4727
	inc de                          ; 4728
	cp #0xe1                        ; 4729
	jr nc,loc_b26_4743              ; 472B
	cp #0x80                        ; 472D
	jp c,loc_b26_442A               ; 472F
	call sub_b26_474C               ; 4732
	xor #0x00                       ; 4735
	ld 31(ix),a                     ; 4737
	ld 35(ix),a                     ; 473A
	call sub_b26_4668               ; 473D
	jp loc_b26_441B                 ; 4740
loc_b26_4743:
	ld hl,#data_b26_4749            ; 4743
	jp loc_b26_47BC                 ; 4746
data_b26_4749:
	.db 0x13, 0x18, 0xdb            ; 4749

;; ---------------------------------------------------------------- $6874C
;; classement : plage symbols.json
	.area _B26_474C
sub_b26_474C:
	sub #0x80                       ; 474C
	jp z,loc_b26_46FC               ; 474E
	rlca                            ; 4751
	ld bc,#0x479f                   ; 4752
	ld h,#0x00                      ; 4755
	ld l,a                          ; 4757
	add hl,bc                       ; 4758
	ld c,(hl)                       ; 4759
	inc hl                          ; 475A
	ld b,(hl)                       ; 475B
	ld a,8(ix)                      ; 475C
	inc c                           ; 475F
	cp c                            ; 4760
	jr z,loc_b26_478E               ; 4761
	ld 8(ix),c                      ; 4763
	ld a,c                          ; 4766
	dec a                           ; 4767
	push bc                         ; 4768
	ld bc,#music_envelopes          ; 4769
	rlca                            ; 476C
	ld h,#0x00                      ; 476D
	ld l,a                          ; 476F
	add hl,bc                       ; 4770
	ld a,(hl)                       ; 4771
	inc hl                          ; 4772
	ld h,(hl)                       ; 4773
	ld l,a                          ; 4774
	ld a,(hl)                       ; 4775
	ld 32(ix),a                     ; 4776
	inc hl                          ; 4779
	ld a,(hl)                       ; 477A
	ld 34(ix),a                     ; 477B
	ld 35(ix),a                     ; 477E
	inc hl                          ; 4781
	ld a,(hl)                       ; 4782
	ld 33(ix),a                     ; 4783
	inc hl                          ; 4786
	ld 46(ix),l                     ; 4787
	ld 47(ix),h                     ; 478A
	pop bc                          ; 478D
loc_b26_478E:
	bit 2,0(ix)                     ; 478E
	ret nz                          ; 4792
	ld a,(snd_DE15)                 ; 4793
	add a,#0xe0                     ; 4796
	add a,b                         ; 4798
	ld (snd_DE11),a                 ; 4799
	out (PSG_PORT),a                ; 479C  PSG (son)
	ret                             ; 479E
	.db 0x0a                        ; 479F
	.db 0x06, 0x1e, 0x05, 0x0b, 0x06, 0x15, 0x04, 0x14, 0x05, 0x02, 0x04, 0x0c, 0x06, 0x03, 0x04, 0x0c ; 47A0
	.db 0x05, 0x18, 0x04, 0x11, 0x05, 0x11, 0x06, 0x05, 0x04 ; 47B0
loc_b26_47B9:
	ld hl,#data_b26_47CD            ; 47B9
loc_b26_47BC:
	push hl                         ; 47BC
	sub #0xe1                       ; 47BD
	ld hl,#jt_b26_47D1              ; 47BF
	add a,a                         ; 47C2
	ld c,a                          ; 47C3
	ld b,#0x00                      ; 47C4
	add hl,bc                       ; 47C6
	ld c,(hl)                       ; 47C7
	inc hl                          ; 47C8
	ld h,(hl)                       ; 47C9
	ld l,c                          ; 47CA
	ld a,(de)                       ; 47CB
	jp (hl)                         ; 47CC
data_b26_47CD:
	.db 0x13, 0xc3, 0xfa            ; 47CD
	.db 0x43                        ; 47D0
jt_b26_47D1:
	.dw loc_b26_4A4E                ; 47D1
	.dw loc_b26_480F                ; 47D3
	.dw loc_b26_483C                ; 47D5
	.dw loc_b26_4A30                ; 47D7
	.dw loc_b26_484C                ; 47D9
	.dw loc_b26_4A52                ; 47DB
	.dw loc_b26_4A48                ; 47DD
	.dw loc_b26_4A3A                ; 47DF
	.dw loc_b26_486F                ; 47E1
	.dw loc_b26_48BD                ; 47E3
	.dw loc_b26_48E7                ; 47E5
	.dw loc_b26_48F1                ; 47E7
	.dw loc_b26_486B                ; 47E9
	.dw loc_b26_4864                ; 47EB
	.dw loc_b26_48EB                ; 47ED
	.dw loc_b26_4978                ; 47EF
	.dw loc_b26_496B                ; 47F1
	.dw loc_b26_48FF                ; 47F3
	.dw loc_b26_497F                ; 47F5
	.dw loc_b26_4996                ; 47F7
	.dw loc_b26_49A9                ; 47F9
	.dw loc_b26_49BC                ; 47FB
	.dw loc_b26_49CF                ; 47FD
	.dw loc_b26_49E2                ; 47FF
	.dw loc_b26_49F8                ; 4801
	.dw loc_b26_4A06                ; 4803
	.dw loc_b26_4A14                ; 4805
	.dw loc_b26_4A22                ; 4807
	.dw loc_b26_484B                ; 4809
	.dw loc_b26_484B                ; 480B
	.dw loc_b26_484B                ; 480D
loc_b26_480F:
	ld b,38(ix)                     ; 480F
	ld 38(ix),a                     ; 4812
	cpl                             ; 4815
	ld c,a                          ; 4816
	ld a,1(ix)                      ; 4817
loc_b26_481A:
	cp #0x80                        ; 481A
	jr z,loc_b26_4832               ; 481C
	rlc b                           ; 481E
	rlc c                           ; 4820
	cp #0xa0                        ; 4822
	jr z,loc_b26_4832               ; 4824
	rlc b                           ; 4826
	rlc c                           ; 4828
	cp #0xc0                        ; 482A
	jr z,loc_b26_4832               ; 482C
	rlc b                           ; 482E
	rlc c                           ; 4830
loc_b26_4832:
	ld hl,#snd_DE10                 ; 4832
	ld a,(hl)                       ; 4835
	or b                            ; 4836
	and c                           ; 4837
	ld (hl),a                       ; 4838
.if VERSION_SMS_EN
	nop                             ; 4839
	nop                             ; 483A
.else ; VERSION_GG_JP
	out (GG_STEREO),a               ; 4839  GG : stereo PSG
.endif
	ret                             ; 483B
loc_b26_483C:
	ex af,af'                       ; 483C
	ld a,(snd_DE09)                 ; 483D
	or a                            ; 4840
	ret nz                          ; 4841
	ex af,af'                       ; 4842
	add a,6(ix)                     ; 4843
	and #0x0f                       ; 4846
	ld 6(ix),a                      ; 4848
loc_b26_484B:
	ret                             ; 484B
loc_b26_484C:
	ex af,af'                       ; 484C
	ld a,(snd_DE09)                 ; 484D
	or a                            ; 4850
	ret nz                          ; 4851
	ex af,af'                       ; 4852
	and #0x0f                       ; 4853
	ld 6(ix),a                      ; 4855
	ret                             ; 4858
	.db 0x4f, 0x3a, 0x16, 0xde, 0x81, 0xe6, 0x0f ; 4859
	.db 0x32, 0x16, 0xde, 0xc9      ; 4860
loc_b26_4864:
	add a,5(ix)                     ; 4864
	ld 5(ix),a                      ; 4867
	ret                             ; 486A
loc_b26_486B:
	ld 2(ix),a                      ; 486B
	ret                             ; 486E
loc_b26_486F:
	ex af,af'                       ; 486F
	or #0xfc                        ; 4870
	inc a                           ; 4872
	jr nz,loc_b26_488D              ; 4873
	ld hl,#snd_DF30                 ; 4875
	bit 7,(hl)                      ; 4878
	jr z,loc_b26_488D               ; 487A
	ld hl,#snd_DED0                 ; 487C
	res 2,(hl)                      ; 487F
	set 4,(hl)                      ; 4881
	xor a                           ; 4883
	ld 0(ix),a                      ; 4884
	dec a                           ; 4887
	out (PSG_PORT),a                ; 4888  PSG (son)
	pop hl                          ; 488A
	pop hl                          ; 488B
	ret                             ; 488C
loc_b26_488D:
	ld a,(de)                       ; 488D
	out (PSG_PORT),a                ; 488E  PSG (son)
	ld hl,#snd_DEA0                 ; 4890
	ld iy,#snd_DF30                 ; 4893
	or #0xfc                        ; 4897
	inc a                           ; 4899
	jr nz,loc_b26_48AB              ; 489A
	ld a,#0xdf                      ; 489C
	out (PSG_PORT),a                ; 489E  PSG (son)
	res 6,0(ix)                     ; 48A0
	set 2,(hl)                      ; 48A4
	set 2,0(iy)                     ; 48A6
	ret                             ; 48AA
loc_b26_48AB:
	set 6,0(ix)                     ; 48AB
	bit 7,0(iy)                     ; 48AF
	jr nz,loc_b26_48B8              ; 48B3
	res 2,(hl)                      ; 48B5
	ret                             ; 48B7
loc_b26_48B8:
	res 2,0(iy)                     ; 48B8
	ret                             ; 48BC
loc_b26_48BD:
	inc a                           ; 48BD
	ld 8(ix),a                      ; 48BE
	dec a                           ; 48C1
	ld bc,#music_envelopes          ; 48C2
	rlca                            ; 48C5
	ld h,#0x00                      ; 48C6
	ld l,a                          ; 48C8
	add hl,bc                       ; 48C9
	ld a,(hl)                       ; 48CA
	inc hl                          ; 48CB
	ld h,(hl)                       ; 48CC
	ld l,a                          ; 48CD
	ld a,(hl)                       ; 48CE
	ld 32(ix),a                     ; 48CF
	inc hl                          ; 48D2
	ld a,(hl)                       ; 48D3
	ld 34(ix),a                     ; 48D4
	ld 35(ix),a                     ; 48D7
	inc hl                          ; 48DA
	ld a,(hl)                       ; 48DB
	ld 33(ix),a                     ; 48DC
	inc hl                          ; 48DF
	ld 46(ix),l                     ; 48E0
	ld 47(ix),h                     ; 48E3
	ret                             ; 48E6
loc_b26_48E7:
	ld 7(ix),a                      ; 48E7
	ret                             ; 48EA
loc_b26_48EB:
	ex de,hl                        ; 48EB
	ld e,(hl)                       ; 48EC
	inc hl                          ; 48ED
	ld d,(hl)                       ; 48EE
	dec de                          ; 48EF
	ret                             ; 48F0
loc_b26_48F1:
	cp #0x01                        ; 48F1
	jr nz,loc_b26_48FA              ; 48F3
	set 3,0(ix)                     ; 48F5
	ret                             ; 48F9
loc_b26_48FA:
	res 3,0(ix)                     ; 48FA
	ret                             ; 48FE
loc_b26_48FF:
	ld a,1(ix)                      ; 48FF
	cp #0xa0                        ; 4902
	jr z,loc_b26_4946               ; 4904
	cp #0xc0                        ; 4906
	jr z,loc_b26_493A               ; 4908
	bit 6,0(ix)                     ; 490A
	jr nz,loc_b26_492C              ; 490E
	ld hl,#snd_DF30                 ; 4910
	bit 7,(hl)                      ; 4913
	jp nz,loc_b26_492C              ; 4915
	ld hl,#snd_DEA0                 ; 4918
	res 2,(hl)                      ; 491B
	res 6,(hl)                      ; 491D
	set 4,(hl)                      ; 491F
	push af                         ; 4921
	ld a,#0xdf                      ; 4922
	out (PSG_PORT),a                ; 4924  PSG (son)
	pop af                          ; 4926
	ld hl,#snd_DF30                 ; 4927
	ld (hl),#0x00                   ; 492A
loc_b26_492C:
	push af                         ; 492C
	ld a,(snd_DE11)                 ; 492D
	jr z,loc_b26_4934               ; 4930
	out (PSG_PORT),a                ; 4932  PSG (son)
loc_b26_4934:
	pop af                          ; 4934
	ld hl,#snd_DED0                 ; 4935
	jr loc_b26_4949                 ; 4938
loc_b26_493A:
	ld hl,#snd_DF60                 ; 493A
	bit 7,(hl)                      ; 493D
	jr nz,loc_b26_4949              ; 493F
	ld hl,#snd_DEA0                 ; 4941
	jr loc_b26_4949                 ; 4944
loc_b26_4946:
	ld hl,#snd_DE70                 ; 4946
loc_b26_4949:
	res 2,(hl)                      ; 4949
	set 4,(hl)                      ; 494B
	or #0x1f                        ; 494D
	out (PSG_PORT),a                ; 494F  PSG (son)
	xor a                           ; 4951
	ld (snd_DE0F),a                 ; 4952
	ld 0(ix),a                      ; 4955
	pop bc                          ; 4958
	pop bc                          ; 4959
	push hl                         ; 495A
	pop iy                          ; 495B
	ld b,38(ix)                     ; 495D
	ld a,38(iy)                     ; 4960
	cpl                             ; 4963
	ld c,a                          ; 4964
	ld a,1(iy)                      ; 4965
	jp loc_b26_481A                 ; 4968
loc_b26_496B:
	ld l,a                          ; 496B
	inc de                          ; 496C
	ld a,(de)                       ; 496D
	ld h,a                          ; 496E
	ld 44(ix),e                     ; 496F
	ld 45(ix),d                     ; 4972
	ex de,hl                        ; 4975
	dec de                          ; 4976
	ret                             ; 4977
loc_b26_4978:
	ld e,44(ix)                     ; 4978
	ld d,45(ix)                     ; 497B
	ret                             ; 497E
loc_b26_497F:
	inc de                          ; 497F
	add a,#0x27                     ; 4980
	ld c,a                          ; 4982
	ld b,#0x00                      ; 4983
	push ix                         ; 4985
	pop hl                          ; 4987
	add hl,bc                       ; 4988
	ld a,(hl)                       ; 4989
	or a                            ; 498A
	jr nz,loc_b26_498F              ; 498B
	ld a,(de)                       ; 498D
	ld (hl),a                       ; 498E
loc_b26_498F:
	inc de                          ; 498F
	dec (hl)                        ; 4990
	jp nz,loc_b26_48EB              ; 4991
	inc de                          ; 4994
	ret                             ; 4995
loc_b26_4996:
	ld a,40(ix)                     ; 4996
	or a                            ; 4999
	jr nz,loc_b26_49A0              ; 499A
	ld a,(de)                       ; 499C
	ld 40(ix),a                     ; 499D
loc_b26_49A0:
	inc de                          ; 49A0
	dec 40(ix)                      ; 49A1
	jp nz,loc_b26_48EB              ; 49A4
	inc de                          ; 49A7
	ret                             ; 49A8
loc_b26_49A9:
	ld a,41(ix)                     ; 49A9
	or a                            ; 49AC
	jr nz,loc_b26_49B3              ; 49AD
	ld a,(de)                       ; 49AF
	ld 41(ix),a                     ; 49B0
loc_b26_49B3:
	inc de                          ; 49B3
	dec 41(ix)                      ; 49B4
	jp nz,loc_b26_48EB              ; 49B7
	inc de                          ; 49BA
	ret                             ; 49BB
loc_b26_49BC:
	ld a,42(ix)                     ; 49BC
	or a                            ; 49BF
	jr nz,loc_b26_49C6              ; 49C0
	ld a,(de)                       ; 49C2
	ld 42(ix),a                     ; 49C3
loc_b26_49C6:
	inc de                          ; 49C6
	dec 42(ix)                      ; 49C7
	jp nz,loc_b26_48EB              ; 49CA
	inc de                          ; 49CD
	ret                             ; 49CE
loc_b26_49CF:
	ld a,43(ix)                     ; 49CF
	or a                            ; 49D2
	jr nz,loc_b26_49D9              ; 49D3
	ld a,(de)                       ; 49D5
	ld 43(ix),a                     ; 49D6
loc_b26_49D9:
	inc de                          ; 49D9
	dec 43(ix)                      ; 49DA
	jp nz,loc_b26_48EB              ; 49DD
	inc de                          ; 49E0
	ret                             ; 49E1
loc_b26_49E2:
	inc de                          ; 49E2
	add a,#0x27                     ; 49E3
	ld c,a                          ; 49E5
	ld b,#0x00                      ; 49E6
	push ix                         ; 49E8
	pop hl                          ; 49EA
	add hl,bc                       ; 49EB
	ld a,(hl)                       ; 49EC
	cp #0x01                        ; 49ED
	jr nz,loc_b26_49F6              ; 49EF
	ld (hl),#0x00                   ; 49F1
	jp loc_b26_48EB                 ; 49F3
loc_b26_49F6:
	inc de                          ; 49F6
	ret                             ; 49F7
loc_b26_49F8:
	ld a,40(ix)                     ; 49F8
	cp #0x01                        ; 49FB
	jr nz,loc_b26_49F6              ; 49FD
	ld 40(ix),#0x00                 ; 49FF
	jp loc_b26_48EB                 ; 4A03
loc_b26_4A06:
	ld a,41(ix)                     ; 4A06
	cp #0x01                        ; 4A09
	jr nz,loc_b26_49F6              ; 4A0B
	ld 41(ix),#0x00                 ; 4A0D
	jp loc_b26_48EB                 ; 4A11
loc_b26_4A14:
	ld a,42(ix)                     ; 4A14
	cp #0x01                        ; 4A17
	jr nz,loc_b26_49F6              ; 4A19
	ld 42(ix),#0x00                 ; 4A1B
	jp loc_b26_48EB                 ; 4A1F
loc_b26_4A22:
	ld a,43(ix)                     ; 4A22
	cp #0x01                        ; 4A25
	jr nz,loc_b26_49F6              ; 4A27
	ld 43(ix),#0x00                 ; 4A29
	jp loc_b26_48EB                 ; 4A2D
loc_b26_4A30:
	call sub_b26_44FB               ; 4A30
	ld 14(ix),a                     ; 4A33
	ld 15(ix),a                     ; 4A36
	ret                             ; 4A39
loc_b26_4A3A:
	ld 16(ix),e                     ; 4A3A
	ld 17(ix),d                     ; 4A3D
	ld 7(ix),#0x80                  ; 4A40
	inc de                          ; 4A44
	inc de                          ; 4A45
	inc de                          ; 4A46
	ret                             ; 4A47
loc_b26_4A48:
	set 1,0(ix)                     ; 4A48
	dec de                          ; 4A4C
	ret                             ; 4A4D
loc_b26_4A4E:
	ld 37(ix),a                     ; 4A4E
	ret                             ; 4A51
loc_b26_4A52:
	ld (snd_DE02),a                 ; 4A52
	ld (snd_DE01),a                 ; 4A55
	ret                             ; 4A58
	.db 0xc9                        ; 4A59

;; ---------------------------------------------------------------- $68A5A
;; classement : plage symbols.json
	.area _B26_4A5A
sub_b26_4A5A:
	ld a,#0x01                      ; 4A5A
	ld (snd_DE23),a                 ; 4A5C
	push bc                         ; 4A5F
	push de                         ; 4A60
	push hl                         ; 4A61
	ld a,(snd_DE03)                 ; 4A62
	sub #0xe0                       ; 4A65
	ld ix,#data_b26_4B0F            ; 4A67
	sla a                           ; 4A6B
	ld e,a                          ; 4A6D
	ld d,#0x00                      ; 4A6E
	add ix,de                       ; 4A70
	sla a                           ; 4A72
	ld e,a                          ; 4A74
	ld d,#0x00                      ; 4A75
	ld a,0(ix)                      ; 4A77
	ld (snd_DE44),a                 ; 4A7A
	ld a,1(ix)                      ; 4A7D
	ld hl,#MAPPER_SLOT2             ; 4A80
	ld (hl),a                       ; 4A83
	ld ix,#data_b26_4B03            ; 4A84
	add ix,de                       ; 4A88
	ld e,0(ix)                      ; 4A8A
	ld d,1(ix)                      ; 4A8D
	ld l,2(ix)                      ; 4A90
	ld h,3(ix)                      ; 4A93
	ld (snd_DE40),de                ; 4A96
	ccf                             ; 4A9A
	sbc hl,de                       ; 4A9B
	ld (snd_DE42),hl                ; 4A9D
	ld bc,(snd_DE42)                ; 4AA0
	xor a                           ; 4AA4
	ld (snd_DE03),a                 ; 4AA5
	ld a,#0x81                      ; 4AA8
	out (PSG_PORT),a                ; 4AAA  PSG (son)
	ld a,#0x00                      ; 4AAC
	out (PSG_PORT),a                ; 4AAE  PSG (son)
	ld a,#0xa1                      ; 4AB0
	out (PSG_PORT),a                ; 4AB2  PSG (son)
	ld a,#0x00                      ; 4AB4
	out (PSG_PORT),a                ; 4AB6  PSG (son)
	ld a,#0xc1                      ; 4AB8
	out (PSG_PORT),a                ; 4ABA  PSG (son)
	ld a,#0x00                      ; 4ABC
	out (PSG_PORT),a                ; 4ABE  PSG (son)
	ld a,(snd_DE44)                 ; 4AC0
	ld l,a                          ; 4AC3
	ld de,(snd_DE40)                ; 4AC4
loc_b26_4AC8:
	ld a,(de)                       ; 4AC8
	push bc                         ; 4AC9
	cpl                             ; 4ACA
	rrca                            ; 4ACB
	rrca                            ; 4ACC
	rrca                            ; 4ACD
	rrca                            ; 4ACE
	ld b,l                          ; 4ACF
loc_b26_4AD0:
	djnz loc_b26_4AD0               ; 4AD0
	and #0x0f                       ; 4AD2
	or #0x90                        ; 4AD4
	out (PSG_PORT),a                ; 4AD6  PSG (son)
	add a,#0x20                     ; 4AD8
	out (PSG_PORT),a                ; 4ADA  PSG (son)
	add a,#0x20                     ; 4ADC
	out (PSG_PORT),a                ; 4ADE  PSG (son)
	ld b,l                          ; 4AE0
loc_b26_4AE1:
	djnz loc_b26_4AE1               ; 4AE1
	ld a,(de)                       ; 4AE3
	cpl                             ; 4AE4
	and #0x0f                       ; 4AE5
	or #0x90                        ; 4AE7
	out (PSG_PORT),a                ; 4AE9  PSG (son)
	add a,#0x20                     ; 4AEB
	out (PSG_PORT),a                ; 4AED  PSG (son)
	add a,#0x20                     ; 4AEF
	out (PSG_PORT),a                ; 4AF1  PSG (son)
	pop bc                          ; 4AF3
	inc de                          ; 4AF4
	dec bc                          ; 4AF5
	ld a,c                          ; 4AF6
	or b                            ; 4AF7
	jp nz,loc_b26_4AC8              ; 4AF8
	xor a                           ; 4AFB
	ld (snd_DE23),a                 ; 4AFC
	pop hl                          ; 4AFF
	pop de                          ; 4B00
	pop bc                          ; 4B01
	ret                             ; 4B02
data_b26_4B03:
	.db 0x00, 0x80, 0x54, 0xbe, 0x00, 0x80, 0x18, 0xbc, 0x00, 0x80, 0x54, 0xbe ; 4B03
data_b26_4B0F:
	.db 0x05                        ; 4B0F
	.db 0x03, 0x09, 0x15, 0x08, 0x03 ; 4B10
