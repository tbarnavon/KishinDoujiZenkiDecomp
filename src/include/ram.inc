;; ram.inc - carte memoire RAM ($C000-$DFFF), groupee par module proprietaire
;; (= module qui accede le plus a la variable). genere initialement par emit.py, desormais edite a la main.
;; Nom prefixe_XXXX = role non identifie. Voir docs/memory_map.md et docs/ram_by_module.md.

;; ---- (non reference)
game_flags                   = 0xC000   ; drapeaux globaux (bit 6 = jeu fige, bits 2/4 par scripts)
irq_flags                    = 0xC001   ; bit 7 = trame en cours (IRQ)
vdp_requests                 = 0xC002   ; demandes de transferts VDP a l'IRQ (bits 0,4,5,6,7)
vdp_requests2                = 0xC003   ; demandes complementaires (bits 5, 6)
lives_or_c005                = 0xC005   ; initialise a 3 au boot (?)
start_stage                  = 0xC006   ; niveau de depart (menu cache)
start_power                  = 0xC007   ; niveau de pouvoir de depart (menu cache)
start_mode                   = 0xC008   ; mode special de depart (table $093A)
demo_mode                    = 0xC011   ; non nul = demo (entrees effacees)
current_stage                = 0xC012   ; niveau courant
game_mode                    = 0xC013   ; mode de jeu
scene_id                     = 0xC014   ; numero de scene / niveau (indexe toutes les tables de niveau)
joypad_state                 = 0xC016   ; Etat courant des boutons (1 = appuye)
joypad_pressed               = 0xC017   ; Boutons nouvellement appuyes cette trame
scroll_y                     = 0xC09B   ; defilement vertical -> registre VDP 9
scroll_x                     = 0xC0AE   ; defilement horizontal -> registre VDP 8 (via $C1BE)
vdp_reg1_shadow              = 0xC0B4   ; copie du registre VDP 1 (affichage on/off)
pal_anim_bg_ptr              = 0xC0C7   ; liste d'animation de la palette de fond
pal_anim_spr_ptr             = 0xC0C9   ; liste d'animation de la palette des sprites
tmp_d3                       = 0xC0D3   ; parametre temporaire (fondus, coordonnees, pointeurs)
tmp_d5                       = 0xC0D5   ; parametre temporaire
map_bank                     = 0xC0D7   ; banque des donnees de carte en cours de dessin
pal_fx_table                 = 0xC0E4   ; effets par couleur (32 entrees)
tile_anim_ptr                = 0xC186   ; liste d'animation de tuiles (banque 23)
freeze_timer                 = 0xC18F   ; compte a rebours qui fige le jeu
raster_ptr                   = 0xC1C4   ; table raster de l'IRQ de ligne
sprite_buf_y_ptr             = 0xC244   ; pointeur d'ecriture du tampon de sprites (Y)
sprite_buf_xn_ptr            = 0xC246   ; pointeur d'ecriture du tampon de sprites (X, tuile)
spawn_list                   = 0xC7FB   ; liste d'apparition des ennemis du niveau (copie de la banque 4)
scene_script_ptr             = 0xC8FF   ; pointeur du script de scene / base des acteurs de scene
scene_wait                   = 0xC901   ; trames d'attente du script de scene
scene_scroll_dx              = 0xC902   ; defilement automatique x
scene_scroll_dy              = 0xC903   ; defilement automatique y
text_ptr                     = 0xC904   ; pointeur du texte en cours d'affichage
player_state                 = 0xCEEF   ; etat du joueur (debut de la structure joueur)
level_map                    = 0xCF27   ; carte du niveau en RAM (copie de la banque 19/20)
level_attr_ptr               = 0xD4C7   ; attributs des metatuiles du niveau
level_metatile_ptr           = 0xD4C9   ; jeu de metatuiles du niveau
decomp_buffer                = 0xD981   ; tampon de decompression
task_active_mask             = 0xDCA1   ; Bit n = tache n existante
task_ready_mask              = 0xDCA2   ; Bit n = tache n prete
task_current                 = 0xDCA3   ; Numero de la tache courante ($FF = aucune)
task_suspended_mask          = 0xDCA4   ; Bit n = tache n suspendue
task_sp_table                = 0xDCA5   ; SP sauvegarde de chaque tache (8 mots)
task_wait_table              = 0xDCB5   ; Trames d'attente restantes par tache (8 octets)
vdp_status_copy              = 0xDCBD   ; Dernier statut VDP lu par l'IRQ
bank_slot2_shadow            = 0xDCBE   ; Copie de la banque mappee en slot 2 (restauree apres l'IRQ)
snd_queue_0                  = 0xDE04   ; file de commandes du driver son
snd_queue_music              = 0xDE05   ; musique demandee
snd_queue_sfx                = 0xDE06   ; effet sonore demande
sms_pause_flag               = 0xDFF0   ; SMS uniquement : $40 si Pause appuye (NMI), lu par joypad_read

;; ---- audio/sound_api
snd_DE08                     = 0xDE08

;; ---- audio/sound_driver
snd_DE01                     = 0xDE01
snd_DE02                     = 0xDE02
snd_DE03                     = 0xDE03
snd_DE09                     = 0xDE09
snd_DE0A                     = 0xDE0A
snd_DE0B                     = 0xDE0B
snd_DE0F                     = 0xDE0F
snd_DE10                     = 0xDE10
snd_DE11                     = 0xDE11
snd_DE15                     = 0xDE15
snd_DE16                     = 0xDE16
snd_DE23                     = 0xDE23
snd_DE40                     = 0xDE40
snd_DE42                     = 0xDE42
snd_DE44                     = 0xDE44
snd_DE46                     = 0xDE46
snd_DE4A                     = 0xDE4A
snd_DE70                     = 0xDE70
snd_DEA0                     = 0xDEA0
snd_DED0                     = 0xDED0
snd_DF00                     = 0xDF00
snd_DF30                     = 0xDF30
snd_DF60                     = 0xDF60
snd_DF90                     = 0xDF90
snd_E050                     = 0xE050
snd_E051                     = 0xE051

;; ---- core/game_flow
flow_C015                    = 0xC015
flow_C0DB                    = 0xC0DB
flow_C0DD                    = 0xC0DD
flow_C0DF                    = 0xC0DF
flow_C0E0                    = 0xC0E0
flow_C0E2                    = 0xC0E2
flow_C0E3                    = 0xC0E3
flow_C1A0                    = 0xC1A0
flow_C1A1                    = 0xC1A1
flow_C1A2                    = 0xC1A2
flow_C1B0                    = 0xC1B0
flow_C1B1                    = 0xC1B1
flow_C1B6                    = 0xC1B6
flow_C1B7                    = 0xC1B7
flow_C1E1                    = 0xC1E1
flow_C1E2                    = 0xC1E2
flow_C24D                    = 0xC24D
flow_C24F                    = 0xC24F
flow_CF28                    = 0xCF28
flow_CF49                    = 0xCF49
flow_D303                    = 0xD303
flow_FEBC                    = 0xFEBC
flow_FEC0                    = 0xFEC0
flow_FEE0                    = 0xFEE0

;; ---- core/irq
irq_C0BA                     = 0xC0BA
irq_C0BB                     = 0xC0BB
irq_C189                     = 0xC189
irq_C18B                     = 0xC18B
irq_C1B8                     = 0xC1B8
irq_C1BA                     = 0xC1BA
irq_C1BC                     = 0xC1BC
irq_C1BE                     = 0xC1BE
irq_C1C1                     = 0xC1C1
irq_C1C2                     = 0xC1C2
irq_C1C5                     = 0xC1C5
irq_D701                     = 0xD701

;; ---- core/util
util_C0A2                    = 0xC0A2
util_C0AD                    = 0xC0AD
util_C0BE                    = 0xC0BE
util_C0C0                    = 0xC0C0
util_C0D9                    = 0xC0D9
util_C19A                    = 0xC19A
util_C900                    = 0xC900
util_CB08                    = 0xCB08
util_CD38                    = 0xCD38
util_CD87                    = 0xCD87
util_CD88                    = 0xCD88
util_CDB0                    = 0xCDB0
util_D4D1                    = 0xD4D1
util_FF60                    = 0xFF60
util_FFF0                    = 0xFFF0
util_FFF7                    = 0xFFF7

;; ---- game/actor_script
ascript_C09C                 = 0xC09C
ascript_C0DC                 = 0xC0DC
ascript_C8B1                 = 0xC8B1
ascript_C8B4                 = 0xC8B4
ascript_CCE7                 = 0xCCE7
ascript_CF30                 = 0xCF30
ascript_FF11                 = 0xFF11

;; ---- game/actors
actor_C0D1                   = 0xC0D1
actor_C0DA                   = 0xC0DA
actor_C9EF                   = 0xC9EF
actor_C9F0                   = 0xC9F0
actor_C9F1                   = 0xC9F1
actor_CB07                   = 0xCB07
actor_CBA7                   = 0xCBA7
actor_CDD7                   = 0xCDD7
actor_CDE4                   = 0xCDE4
actor_CEF2                   = 0xCEF2
actor_CF07                   = 0xCF07

;; ---- game/banked_b23
banked_b23_F901              = 0xF901

;; ---- game/collision
coll_C0D0                    = 0xC0D0
coll_C0E1                    = 0xC0E1
coll_C18C                    = 0xC18C
coll_C198                    = 0xC198
coll_C199                    = 0xC199
coll_CA67                    = 0xCA67
coll_CA68                    = 0xCA68
coll_CA8F                    = 0xCA8F
coll_CAB7                    = 0xCAB7
coll_CADF                    = 0xCADF
coll_CF02                    = 0xCF02

;; ---- game/level
level_C0C5                   = 0xC0C5
level_C0C6                   = 0xC0C6
level_C188                   = 0xC188
level_C19C                   = 0xC19C
level_C1F3                   = 0xC1F3
level_C91A                   = 0xC91A
level_CF18                   = 0xCF18
level_FF20                   = 0xFF20

;; ---- game/player
player_C0B1                  = 0xC0B1
player_C0B2                  = 0xC0B2
player_C0B6                  = 0xC0B6
player_C0CC                  = 0xC0CC
player_C0CD                  = 0xC0CD
player_C0CE                  = 0xC0CE
player_C194                  = 0xC194
player_C196                  = 0xC196
player_C19F                  = 0xC19F
player_C1B3                  = 0xC1B3
player_C1C0                  = 0xC1C0
player_C1DF                  = 0xC1DF
player_C1E9                  = 0xC1E9
player_C1F0                  = 0xC1F0
player_C1F1                  = 0xC1F1
player_C1F2                  = 0xC1F2
player_C1F4                  = 0xC1F4
player_C425                  = 0xC425
player_C435                  = 0xC435
player_C500                  = 0xC500
player_C8D8                  = 0xC8D8
player_C8E7                  = 0xC8E7
player_CA17                  = 0xCA17
player_CA19                  = 0xCA19
player_CA41                  = 0xCA41
player_CA44                  = 0xCA44
player_CD37                  = 0xCD37
player_CD5F                  = 0xCD5F
player_CDAF                  = 0xCDAF
player_CEF0                  = 0xCEF0
player_CEF1                  = 0xCEF1
player_CEF3                  = 0xCEF3
player_CEF4                  = 0xCEF4
player_CEF6                  = 0xCEF6
player_CEF7                  = 0xCEF7
player_CEF8                  = 0xCEF8
player_CEF9                  = 0xCEF9
player_CEFC                  = 0xCEFC
player_CEFD                  = 0xCEFD
player_CEFE                  = 0xCEFE
player_CEFF                  = 0xCEFF
player_CF00                  = 0xCF00
player_CF01                  = 0xCF01
player_CF03                  = 0xCF03
player_CF04                  = 0xCF04
player_CF05                  = 0xCF05
player_CF06                  = 0xCF06
player_CF08                  = 0xCF08
player_CF09                  = 0xCF09
player_CF11                  = 0xCF11
player_CF13                  = 0xCF13
player_CF17                  = 0xCF17
player_CF20                  = 0xCF20
player_CF21                  = 0xCF21
player_CF25                  = 0xCF25
player_E600                  = 0xE600

;; ---- game/script
scene_C01E                   = 0xC01E
scene_C0E6                   = 0xC0E6
scene_C1BF                   = 0xC1BF
scene_C906                   = 0xC906
scene_C907                   = 0xC907
scene_C908                   = 0xC908
scene_C90B                   = 0xC90B
scene_C90C                   = 0xC90C
scene_C90D                   = 0xC90D
scene_C90E                   = 0xC90E
scene_C90F                   = 0xC90F
scene_C91F                   = 0xC91F
scene_C920                   = 0xC920
scene_CB9F                   = 0xCB9F
scene_CBA3                   = 0xCBA3
scene_CBA4                   = 0xCBA4
scene_CBA5                   = 0xCBA5
scene_CBA6                   = 0xCBA6
scene_CBA8                   = 0xCBA8
scene_CBA9                   = 0xCBA9
scene_CBAB                   = 0xCBAB
scene_CBB5                   = 0xCBB5
scene_CBB7                   = 0xCBB7

;; ---- game/scroll
scroll_C09A                  = 0xC09A
scroll_C0B0                  = 0xC0B0
scroll_C0B7                  = 0xC0B7
scroll_C0B8                  = 0xC0B8
scroll_C0B9                  = 0xC0B9
scroll_C19E                  = 0xC19E
scroll_C1B4                  = 0xC1B4
scroll_C1B5                  = 0xC1B5
scroll_FC00                  = 0xFC00
scroll_FE00                  = 0xFE00

;; ---- game/stage_events
event_C010                   = 0xC010
event_C07A                   = 0xC07A
event_C1A3                   = 0xC1A3
event_C1A4                   = 0xC1A4
event_C1A5                   = 0xC1A5
event_C1A6                   = 0xC1A6
event_C1A7                   = 0xC1A7
event_C1A8                   = 0xC1A8
event_C1A9                   = 0xC1A9
event_C1AA                   = 0xC1AA
event_C1AB                   = 0xC1AB
event_C1AC                   = 0xC1AC
event_C1AD                   = 0xC1AD
event_C1AE                   = 0xC1AE
event_C1AF                   = 0xC1AF
event_C1B2                   = 0xC1B2
event_C2CD                   = 0xC2CD
event_C8B0                   = 0xC8B0
event_C8B3                   = 0xC8B3
event_C8B6                   = 0xC8B6
event_C8BF                   = 0xC8BF
event_C8C1                   = 0xC8C1
event_C8CA                   = 0xC8CA
event_C8D0                   = 0xC8D0
event_C8DB                   = 0xC8DB
event_C8DE                   = 0xC8DE
event_C8E9                   = 0xC8E9
event_C8F2                   = 0xC8F2
event_C8F8                   = 0xC8F8
event_CF0A                   = 0xCF0A
event_CF31                   = 0xCF31
event_CF32                   = 0xCF32
event_CF40                   = 0xCF40
event_CF41                   = 0xCF41
event_CF43                   = 0xCF43
event_CF44                   = 0xCF44
event_CF45                   = 0xCF45
event_CF46                   = 0xCF46
event_CF48                   = 0xCF48
event_CF4A                   = 0xCF4A
event_CF4B                   = 0xCF4B
event_CF4C                   = 0xCF4C
event_CF54                   = 0xCF54
event_CF5B                   = 0xCF5B
event_CF67                   = 0xCF67
event_CF6F                   = 0xCF6F
event_CF79                   = 0xCF79
event_CF7C                   = 0xCF7C
event_CF81                   = 0xCF81
event_CF82                   = 0xCF82
event_CF83                   = 0xCF83
event_CF8D                   = 0xCF8D
event_CF8E                   = 0xCF8E
event_CF90                   = 0xCF90
event_CF94                   = 0xCF94
event_CFA3                   = 0xCFA3
event_CFA8                   = 0xCFA8
event_CFB5                   = 0xCFB5
event_CFB6                   = 0xCFB6
event_CFBC                   = 0xCFBC
event_CFBD                   = 0xCFBD
event_CFBE                   = 0xCFBE
event_CFBF                   = 0xCFBF
event_CFC0                   = 0xCFC0
event_CFC1                   = 0xCFC1

;; ---- game/text
text_CBB1                    = 0xCBB1
text_CBB3                    = 0xCBB3
text_CBB4                    = 0xCBB4
text_FFC0                    = 0xFFC0

;; ---- screens/debug_menu
dbg_C004                     = 0xC004
dbg_C0D4                     = 0xC0D4

;; ---- screens/pause_menu
pause_C0F4                   = 0xC0F4
pause_C8D7                   = 0xC8D7
pause_CA18                   = 0xCA18
pause_CA1E                   = 0xCA1E
pause_CA32                   = 0xCA32
pause_CA38                   = 0xCA38
pause_CA3F                   = 0xCA3F
pause_CA46                   = 0xCA46
pause_CA5A                   = 0xCA5A
pause_CA60                   = 0xCA60
pause_CAE6                   = 0xCAE6

;; ---- video/palette
pal_C01A                     = 0xC01A
pal_C03A                     = 0xC03A
pal_C05A                     = 0xC05A
pal_C0D6                     = 0xC0D6
pal_C0E5                     = 0xC0E5
pal_C0F5                     = 0xC0F5
pal_C104                     = 0xC104
pal_C124                     = 0xC124
pal_C144                     = 0xC144
pal_C145                     = 0xC145
pal_C154                     = 0xC154
pal_C155                     = 0xC155
pal_C184                     = 0xC184

;; ---- video/sprites
sprite_C185                  = 0xC185
sprite_C240                  = 0xC240
sprite_C242                  = 0xC242
sprite_C248                  = 0xC248
sprite_C249                  = 0xC249
sprite_C24A                  = 0xC24A
sprite_C24B                  = 0xC24B
sprite_C24C                  = 0xC24C
sprite_C8AF                  = 0xC8AF
sprite_C8D9                  = 0xC8D9
sprite_C8DC                  = 0xC8DC
sprite_CB7F                  = 0xCB7F
sprite_CD0F                  = 0xCD0F
sprite_CEC7                  = 0xCEC7
sprite_CF22                  = 0xCF22
sprite_CF24                  = 0xCF24
sprite_FFD8                  = 0xFFD8

;; ---- video/vdp
vdp_C0AF                     = 0xC0AF
vdp_C0B5                     = 0xC0B5
vdp_C200                     = 0xC200
vdp_C201                     = 0xC201
vdp_C800                     = 0xC800
vdp_E0E0                     = 0xE0E0
