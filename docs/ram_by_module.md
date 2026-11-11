# RAM par module (GÉNÉRÉ)

Généré par `tools/disasm/emit.py` (post-traitement). Module propriétaire = celui qui accède le plus à la variable ; « aussi » = autres modules.
Les noms `prefixe_XXXX` désignent des variables dont le rôle n'est pas encore identifié.

## (non reference)

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C000` | `game_flags` | 0 |  |
| `$C001` | `irq_flags` | 0 |  |
| `$C002` | `vdp_requests` | 0 |  |
| `$C003` | `vdp_requests2` | 0 |  |
| `$C005` | `lives_or_c005` | 0 |  |
| `$C006` | `start_stage` | 0 |  |
| `$C007` | `start_power` | 0 |  |
| `$C008` | `start_mode` | 0 |  |
| `$C011` | `demo_mode` | 0 |  |
| `$C012` | `current_stage` | 0 |  |
| `$C013` | `game_mode` | 0 |  |
| `$C014` | `scene_id` | 0 |  |
| `$C016` | `joypad_state` | 0 |  |
| `$C017` | `joypad_pressed` | 0 |  |
| `$C09B` | `scroll_y` | 0 |  |
| `$C0AE` | `scroll_x` | 0 |  |
| `$C0B4` | `vdp_reg1_shadow` | 0 |  |
| `$C0C7` | `pal_anim_bg_ptr` | 0 |  |
| `$C0C9` | `pal_anim_spr_ptr` | 0 |  |
| `$C0D3` | `tmp_d3` | 0 |  |
| `$C0D5` | `tmp_d5` | 0 |  |
| `$C0D7` | `map_bank` | 0 |  |
| `$C0E4` | `pal_fx_table` | 0 |  |
| `$C186` | `tile_anim_ptr` | 0 |  |
| `$C18F` | `freeze_timer` | 0 |  |
| `$C1C4` | `raster_ptr` | 0 |  |
| `$C244` | `sprite_buf_y_ptr` | 0 |  |
| `$C246` | `sprite_buf_xn_ptr` | 0 |  |
| `$C7FB` | `spawn_list` | 0 |  |
| `$C8FF` | `scene_script_ptr` | 0 |  |
| `$C901` | `scene_wait` | 0 |  |
| `$C902` | `scene_scroll_dx` | 0 |  |
| `$C903` | `scene_scroll_dy` | 0 |  |
| `$C904` | `text_ptr` | 0 |  |
| `$CEEF` | `player_state` | 0 |  |
| `$CF27` | `level_map` | 0 |  |
| `$D4C7` | `level_attr_ptr` | 0 |  |
| `$D4C9` | `level_metatile_ptr` | 0 |  |
| `$D981` | `decomp_buffer` | 0 |  |
| `$DCA1` | `task_active_mask` | 0 |  |
| `$DCA2` | `task_ready_mask` | 0 |  |
| `$DCA3` | `task_current` | 0 |  |
| `$DCA4` | `task_suspended_mask` | 0 |  |
| `$DCA5` | `task_sp_table` | 0 |  |
| `$DCB5` | `task_wait_table` | 0 |  |
| `$DCBD` | `vdp_status_copy` | 0 |  |
| `$DCBE` | `bank_slot2_shadow` | 0 |  |
| `$DE04` | `snd_queue_0` | 0 |  |
| `$DE05` | `snd_queue_music` | 0 |  |
| `$DE06` | `snd_queue_sfx` | 0 |  |
| `$DFF0` | `sms_pause_flag` | 0 |  |

## audio/sound_api

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$DE08` | `snd_DE08` | 3 | audio/sound_driver (1) |

## audio/sound_driver

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$DE01` | `snd_DE01` | 5 |  |
| `$DE02` | `snd_DE02` | 5 |  |
| `$DE03` | `snd_DE03` | 5 |  |
| `$DE09` | `snd_DE09` | 8 | audio/sound_api (1) |
| `$DE0A` | `snd_DE0A` | 5 | audio/sound_api (1) |
| `$DE0B` | `snd_DE0B` | 3 | audio/sound_api (1) |
| `$DE0F` | `snd_DE0F` | 3 |  |
| `$DE10` | `snd_DE10` | 3 |  |
| `$DE11` | `snd_DE11` | 2 |  |
| `$DE15` | `snd_DE15` | 1 |  |
| `$DE16` | `snd_DE16` | 1 |  |
| `$DE23` | `snd_DE23` | 3 |  |
| `$DE40` | `snd_DE40` | 7 |  |
| `$DE42` | `snd_DE42` | 2 |  |
| `$DE44` | `snd_DE44` | 2 |  |
| `$DE46` | `snd_DE46` | 1 |  |
| `$DE4A` | `snd_DE4A` | 1 |  |
| `$DE70` | `snd_DE70` | 5 |  |
| `$DEA0` | `snd_DEA0` | 7 |  |
| `$DED0` | `snd_DED0` | 6 |  |
| `$DF00` | `snd_DF00` | 4 |  |
| `$DF30` | `snd_DF30` | 6 |  |
| `$DF60` | `snd_DF60` | 4 |  |
| `$DF90` | `snd_DF90` | 2 |  |
| `$E050` | `snd_E050` | 2 |  |
| `$E051` | `snd_E051` | 2 |  |

## core/game_flow

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C015` | `flow_C015` | 8 | core/util (2), video/sprites (2) |
| `$C0DB` | `flow_C0DB` | 15 | game/actors (2), game/actor_script (2), game/collision (2) |
| `$C0DD` | `flow_C0DD` | 8 | game/collision (2) |
| `$C0DF` | `flow_C0DF` | 6 | game/collision (2) |
| `$C0E0` | `flow_C0E0` | 1 |  |
| `$C0E2` | `flow_C0E2` | 3 |  |
| `$C0E3` | `flow_C0E3` | 4 |  |
| `$C1A0` | `flow_C1A0` | 12 | game/stage_events (5), game/player (1) |
| `$C1A1` | `flow_C1A1` | 4 | game/stage_events (2) |
| `$C1A2` | `flow_C1A2` | 4 | game/stage_events (2) |
| `$C1B0` | `flow_C1B0` | 9 |  |
| `$C1B1` | `flow_C1B1` | 8 | game/player (3) |
| `$C1B6` | `flow_C1B6` | 16 | screens/pause_menu (4), game/player (3), core/util (1) |
| `$C1B7` | `flow_C1B7` | 8 | game/player (3), video/sprites (1) |
| `$C1E1` | `flow_C1E1` | 3 | game/stage_events (1) |
| `$C1E2` | `flow_C1E2` | 2 |  |
| `$C24D` | `flow_C24D` | 2 | video/vdp (1) |
| `$C24F` | `flow_C24F` | 1 |  |
| `$CF28` | `flow_CF28` | 3 | game/level (1), game/stage_events (1) |
| `$CF49` | `flow_CF49` | 3 | game/stage_events (1) |
| `$D303` | `flow_D303` | 1 |  |
| `$FEBC` | `flow_FEBC` | 1 |  |
| `$FEC0` | `flow_FEC0` | 1 |  |
| `$FEE0` | `flow_FEE0` | 1 |  |

## core/irq

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C0BA` | `irq_C0BA` | 1 |  |
| `$C0BB` | `irq_C0BB` | 2 |  |
| `$C189` | `irq_C189` | 2 | game/level (1) |
| `$C18B` | `irq_C18B` | 2 | game/level (1) |
| `$C1B8` | `irq_C1B8` | 2 | game/script (1) |
| `$C1BA` | `irq_C1BA` | 3 | game/script (1) |
| `$C1BC` | `irq_C1BC` | 2 | game/script (1) |
| `$C1BE` | `irq_C1BE` | 3 |  |
| `$C1C1` | `irq_C1C1` | 7 | game/script (2), game/level (1) |
| `$C1C2` | `irq_C1C2` | 2 | game/script (1) |
| `$C1C5` | `irq_C1C5` | 4 | game/script (1) |
| `$D701` | `irq_D701` | 3 | game/stage_events (1), video/sprites (1) |

## core/util

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C0A2` | `util_C0A2` | 2 |  |
| `$C0AD` | `util_C0AD` | 6 | game/scroll (2), game/script (1), video/vdp (1) |
| `$C0BE` | `util_C0BE` | 5 | game/scroll (2), video/vdp (1) |
| `$C0C0` | `util_C0C0` | 5 | game/scroll (2), video/vdp (1) |
| `$C0D9` | `util_C0D9` | 11 | game/actor_script (3), core/game_flow (2), game/actors (2) |
| `$C19A` | `util_C19A` | 4 | game/level (1), game/scroll (1), game/stage_events (1) |
| `$C900` | `util_C900` | 3 | game/level (1), game/stage_events (1) |
| `$CB08` | `util_CB08` | 1 |  |
| `$CD38` | `util_CD38` | 1 |  |
| `$CD87` | `util_CD87` | 2 | video/sprites (1) |
| `$CD88` | `util_CD88` | 1 |  |
| `$CDB0` | `util_CDB0` | 1 |  |
| `$D4D1` | `util_D4D1` | 8 | game/level (2), screens/debug_menu (2), game/collision (1) |
| `$FF60` | `util_FF60` | 2 | game/stage_events (1) |
| `$FFF0` | `util_FFF0` | 3 |  |
| `$FFF7` | `util_FFF7` | 1 |  |

## game/actor_script

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C09C` | `ascript_C09C` | 2 | video/vdp (1) |
| `$C0DC` | `ascript_C0DC` | 1 |  |
| `$C8B1` | `ascript_C8B1` | 5 | game/stage_events (1) |
| `$C8B4` | `ascript_C8B4` | 5 | game/stage_events (1) |
| `$CCE7` | `ascript_CCE7` | 1 |  |
| `$CF30` | `ascript_CF30` | 2 | game/stage_events (1) |
| `$FF11` | `ascript_FF11` | 1 |  |

## game/actors

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C0D1` | `actor_C0D1` | 4 | game/player (1) |
| `$C0DA` | `actor_C0DA` | 3 | game/actor_script (1) |
| `$C9EF` | `actor_C9EF` | 2 |  |
| `$C9F0` | `actor_C9F0` | 1 |  |
| `$C9F1` | `actor_C9F1` | 1 |  |
| `$CB07` | `actor_CB07` | 13 | game/actor_script (3), game/player (3), core/util (1) |
| `$CBA7` | `actor_CBA7` | 17 | game/script (5), game/player (3), core/util (1) |
| `$CDD7` | `actor_CDD7` | 19 | game/actor_script (3), game/collision (2), game/player (2) |
| `$CDE4` | `actor_CDE4` | 1 |  |
| `$CEF2` | `actor_CEF2` | 1 |  |
| `$CF07` | `actor_CF07` | 4 | game/player (1), game/scroll (1) |

## game/banked_b23

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$F901` | `banked_b23_F901` | 1 |  |

## game/collision

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C0D0` | `coll_C0D0` | 3 | game/level (1), game/stage_events (1) |
| `$C0E1` | `coll_C0E1` | 8 | core/game_flow (3) |
| `$C18C` | `coll_C18C` | 5 | game/player (2), game/actor_script (1) |
| `$C198` | `coll_C198` | 3 |  |
| `$C199` | `coll_C199` | 3 |  |
| `$CA67` | `coll_CA67` | 8 | screens/pause_menu (2) |
| `$CA68` | `coll_CA68` | 1 |  |
| `$CA8F` | `coll_CA8F` | 1 |  |
| `$CAB7` | `coll_CAB7` | 1 |  |
| `$CADF` | `coll_CADF` | 2 | video/sprites (1) |
| `$CF02` | `coll_CF02` | 1 |  |

## game/level

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C0C5` | `level_C0C5` | 5 | game/actors (1) |
| `$C0C6` | `level_C0C6` | 8 | game/player (2), game/stage_events (2) |
| `$C188` | `level_C188` | 4 |  |
| `$C19C` | `level_C19C` | 3 | game/scroll (1), game/stage_events (1) |
| `$C1F3` | `level_C1F3` | 7 | game/script (2), audio/sound_api (1), core/game_flow (1) |
| `$C91A` | `level_C91A` | 1 |  |
| `$CF18` | `level_CF18` | 10 | game/collision (2), game/player (1), game/stage_events (1) |
| `$FF20` | `level_FF20` | 1 |  |

## game/player

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C0B1` | `player_C0B1` | 19 | screens/debug_menu (7), game/script (3), video/vdp (1) |
| `$C0B2` | `player_C0B2` | 3 |  |
| `$C0B6` | `player_C0B6` | 7 | game/scroll (2), video/vdp (1) |
| `$C0CC` | `player_C0CC` | 4 | game/collision (1) |
| `$C0CD` | `player_C0CD` | 4 | game/collision (1) |
| `$C0CE` | `player_C0CE` | 4 | core/util (1) |
| `$C194` | `player_C194` | 4 |  |
| `$C196` | `player_C196` | 8 | game/collision (2), game/actor_script (1) |
| `$C19F` | `player_C19F` | 6 |  |
| `$C1B3` | `player_C1B3` | 13 | core/game_flow (3) |
| `$C1C0` | `player_C1C0` | 5 |  |
| `$C1DF` | `player_C1DF` | 12 | game/actors (2), core/util (1), game/actor_script (1) |
| `$C1E9` | `player_C1E9` | 1 |  |
| `$C1F0` | `player_C1F0` | 1 |  |
| `$C1F1` | `player_C1F1` | 1 |  |
| `$C1F2` | `player_C1F2` | 20 | core/game_flow (4), game/collision (3), video/sprites (2) |
| `$C1F4` | `player_C1F4` | 2 |  |
| `$C425` | `player_C425` | 12 |  |
| `$C435` | `player_C435` | 3 |  |
| `$C500` | `player_C500` | 1 |  |
| `$C8D8` | `player_C8D8` | 6 | game/stage_events (2), screens/pause_menu (2) |
| `$C8E7` | `player_C8E7` | 3 | game/stage_events (1), screens/pause_menu (1) |
| `$CA17` | `player_CA17` | 5 | screens/pause_menu (2), video/sprites (1) |
| `$CA19` | `player_CA19` | 2 |  |
| `$CA41` | `player_CA41` | 1 |  |
| `$CA44` | `player_CA44` | 1 |  |
| `$CD37` | `player_CD37` | 8 | core/util (3), video/sprites (1) |
| `$CD5F` | `player_CD5F` | 2 | video/sprites (1) |
| `$CDAF` | `player_CDAF` | 5 | core/util (1), game/actors (1), game/actor_script (1) |
| `$CEF0` | `player_CEF0` | 16 | game/actors (2) |
| `$CEF1` | `player_CEF1` | 15 | game/actor_script (3), game/actors (2), game/collision (2) |
| `$CEF3` | `player_CEF3` | 18 | game/scroll (8), game/actors (1) |
| `$CEF4` | `player_CEF4` | 14 | game/actors (2), game/actor_script (2), game/collision (1) |
| `$CEF6` | `player_CEF6` | 61 | data/stage_data (3), game/stage_events (3), core/util (2) |
| `$CEF7` | `player_CEF7` | 15 | game/stage_events (3), video/sprites (3), data/stage_data (1) |
| `$CEF8` | `player_CEF8` | 17 | game/stage_events (4), video/sprites (4), game/actors (1) |
| `$CEF9` | `player_CEF9` | 14 | game/actors (1) |
| `$CEFC` | `player_CEFC` | 15 | core/util (4), audio/sound_api (1), game/actors (1) |
| `$CEFD` | `player_CEFD` | 6 | video/sprites (2) |
| `$CEFE` | `player_CEFE` | 23 | game/collision (4), core/game_flow (2), game/script (2) |
| `$CEFF` | `player_CEFF` | 56 | game/collision (2), game/scroll (2), core/util (1) |
| `$CF00` | `player_CF00` | 6 | game/collision (2), game/actors (1) |
| `$CF01` | `player_CF01` | 36 | game/scroll (11), game/stage_events (3), core/util (2) |
| `$CF03` | `player_CF03` | 7 | core/game_flow (1) |
| `$CF04` | `player_CF04` | 5 |  |
| `$CF05` | `player_CF05` | 2 |  |
| `$CF06` | `player_CF06` | 18 | game/actors (1), game/scroll (1) |
| `$CF08` | `player_CF08` | 10 |  |
| `$CF09` | `player_CF09` | 5 | video/sprites (2), core/util (1) |
| `$CF11` | `player_CF11` | 121 | game/actor_script (1), game/stage_events (1) |
| `$CF13` | `player_CF13` | 106 | core/util (1) |
| `$CF17` | `player_CF17` | 1 |  |
| `$CF20` | `player_CF20` | 57 | game/scroll (1) |
| `$CF21` | `player_CF21` | 54 | game/stage_events (3), game/scroll (2), data/stage_data (1) |
| `$CF25` | `player_CF25` | 12 | audio/sound_api (1) |
| `$E600` | `player_E600` | 1 |  |

## game/script

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C01E` | `scene_C01E` | 1 |  |
| `$C0E6` | `scene_C0E6` | 1 |  |
| `$C1BF` | `scene_C1BF` | 4 | core/irq (1), video/vdp (1) |
| `$C906` | `scene_C906` | 4 | game/level (1) |
| `$C907` | `scene_C907` | 3 |  |
| `$C908` | `scene_C908` | 5 |  |
| `$C90B` | `scene_C90B` | 4 |  |
| `$C90C` | `scene_C90C` | 2 |  |
| `$C90D` | `scene_C90D` | 2 |  |
| `$C90E` | `scene_C90E` | 2 |  |
| `$C90F` | `scene_C90F` | 1 |  |
| `$C91F` | `scene_C91F` | 3 |  |
| `$C920` | `scene_C920` | 1 |  |
| `$CB9F` | `scene_CB9F` | 2 |  |
| `$CBA3` | `scene_CBA3` | 3 |  |
| `$CBA4` | `scene_CBA4` | 5 |  |
| `$CBA5` | `scene_CBA5` | 3 |  |
| `$CBA6` | `scene_CBA6` | 3 |  |
| `$CBA8` | `scene_CBA8` | 4 | core/util (1) |
| `$CBA9` | `scene_CBA9` | 2 |  |
| `$CBAB` | `scene_CBAB` | 2 |  |
| `$CBB5` | `scene_CBB5` | 5 |  |
| `$CBB7` | `scene_CBB7` | 1 |  |

## game/scroll

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C09A` | `scroll_C09A` | 3 | video/vdp (1) |
| `$C0B0` | `scroll_C0B0` | 24 | core/util (4), game/player (3), game/stage_events (1) |
| `$C0B7` | `scroll_C0B7` | 1 |  |
| `$C0B8` | `scroll_C0B8` | 8 | video/vdp (1) |
| `$C0B9` | `scroll_C0B9` | 1 |  |
| `$C19E` | `scroll_C19E` | 15 | game/player (3), game/stage_events (2), data/stage_data (1) |
| `$C1B4` | `scroll_C1B4` | 3 | game/player (1) |
| `$C1B5` | `scroll_C1B5` | 3 | game/player (1) |
| `$FC00` | `scroll_FC00` | 3 | game/player (1) |
| `$FE00` | `scroll_FE00` | 2 |  |

## game/stage_events

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C010` | `event_C010` | 17 | core/game_flow (7), game/player (1) |
| `$C07A` | `event_C07A` | 6 | game/level (1), game/script (1), screens/debug_menu (1) |
| `$C1A3` | `event_C1A3` | 3 |  |
| `$C1A4` | `event_C1A4` | 2 |  |
| `$C1A5` | `event_C1A5` | 3 |  |
| `$C1A6` | `event_C1A6` | 2 |  |
| `$C1A7` | `event_C1A7` | 3 |  |
| `$C1A8` | `event_C1A8` | 3 |  |
| `$C1A9` | `event_C1A9` | 2 |  |
| `$C1AA` | `event_C1AA` | 2 |  |
| `$C1AB` | `event_C1AB` | 3 |  |
| `$C1AC` | `event_C1AC` | 3 |  |
| `$C1AD` | `event_C1AD` | 3 |  |
| `$C1AE` | `event_C1AE` | 3 |  |
| `$C1AF` | `event_C1AF` | 1 |  |
| `$C1B2` | `event_C1B2` | 10 | core/game_flow (3), game/level (1), game/player (1) |
| `$C2CD` | `event_C2CD` | 3 | core/game_flow (1) |
| `$C8B0` | `event_C8B0` | 7 | video/sprites (3), screens/pause_menu (1) |
| `$C8B3` | `event_C8B3` | 2 |  |
| `$C8B6` | `event_C8B6` | 8 |  |
| `$C8BF` | `event_C8BF` | 1 |  |
| `$C8C1` | `event_C8C1` | 1 |  |
| `$C8CA` | `event_C8CA` | 4 |  |
| `$C8D0` | `event_C8D0` | 3 |  |
| `$C8DB` | `event_C8DB` | 2 |  |
| `$C8DE` | `event_C8DE` | 5 |  |
| `$C8E9` | `event_C8E9` | 1 |  |
| `$C8F2` | `event_C8F2` | 5 | screens/pause_menu (1) |
| `$C8F8` | `event_C8F8` | 3 |  |
| `$CF0A` | `event_CF0A` | 1 |  |
| `$CF31` | `event_CF31` | 1 |  |
| `$CF32` | `event_CF32` | 1 |  |
| `$CF40` | `event_CF40` | 1 |  |
| `$CF41` | `event_CF41` | 1 |  |
| `$CF43` | `event_CF43` | 1 |  |
| `$CF44` | `event_CF44` | 2 |  |
| `$CF45` | `event_CF45` | 1 |  |
| `$CF46` | `event_CF46` | 1 |  |
| `$CF48` | `event_CF48` | 1 |  |
| `$CF4A` | `event_CF4A` | 1 |  |
| `$CF4B` | `event_CF4B` | 1 |  |
| `$CF4C` | `event_CF4C` | 1 |  |
| `$CF54` | `event_CF54` | 1 |  |
| `$CF5B` | `event_CF5B` | 1 |  |
| `$CF67` | `event_CF67` | 1 |  |
| `$CF6F` | `event_CF6F` | 1 |  |
| `$CF79` | `event_CF79` | 1 |  |
| `$CF7C` | `event_CF7C` | 1 |  |
| `$CF81` | `event_CF81` | 1 |  |
| `$CF82` | `event_CF82` | 1 |  |
| `$CF83` | `event_CF83` | 1 |  |
| `$CF8D` | `event_CF8D` | 1 |  |
| `$CF8E` | `event_CF8E` | 1 |  |
| `$CF90` | `event_CF90` | 1 |  |
| `$CF94` | `event_CF94` | 1 |  |
| `$CFA3` | `event_CFA3` | 1 |  |
| `$CFA8` | `event_CFA8` | 1 |  |
| `$CFB5` | `event_CFB5` | 1 |  |
| `$CFB6` | `event_CFB6` | 1 |  |
| `$CFBC` | `event_CFBC` | 1 |  |
| `$CFBD` | `event_CFBD` | 1 |  |
| `$CFBE` | `event_CFBE` | 1 |  |
| `$CFBF` | `event_CFBF` | 1 |  |
| `$CFC0` | `event_CFC0` | 1 |  |
| `$CFC1` | `event_CFC1` | 1 |  |

## game/text

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$CBB1` | `text_CBB1` | 4 | game/script (1) |
| `$CBB3` | `text_CBB3` | 6 | game/script (2) |
| `$CBB4` | `text_CBB4` | 3 | game/script (1) |
| `$FFC0` | `text_FFC0` | 1 |  |

## screens/debug_menu

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C004` | `dbg_C004` | 12 | core/game_flow (1) |
| `$C0D4` | `dbg_C0D4` | 29 | core/util (6), video/sprites (6), game/level (4) |

## screens/pause_menu

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C0F4` | `pause_C0F4` | 2 | video/palette (1) |
| `$C8D7` | `pause_C8D7` | 15 | game/stage_events (4), game/player (2), game/script (2) |
| `$CA18` | `pause_CA18` | 1 |  |
| `$CA1E` | `pause_CA1E` | 1 |  |
| `$CA32` | `pause_CA32` | 4 |  |
| `$CA38` | `pause_CA38` | 1 |  |
| `$CA3F` | `pause_CA3F` | 3 | game/player (1) |
| `$CA46` | `pause_CA46` | 1 |  |
| `$CA5A` | `pause_CA5A` | 4 |  |
| `$CA60` | `pause_CA60` | 1 |  |
| `$CAE6` | `pause_CAE6` | 1 |  |

## video/palette

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C01A` | `pal_C01A` | 10 | screens/pause_menu (2), game/stage_events (1), video/vdp (1) |
| `$C03A` | `pal_C03A` | 2 |  |
| `$C05A` | `pal_C05A` | 8 | game/level (1), game/script (1), game/stage_events (1) |
| `$C0D6` | `pal_C0D6` | 7 | core/util (1), game/actor_script (1) |
| `$C0E5` | `pal_C0E5` | 3 |  |
| `$C0F5` | `pal_C0F5` | 1 |  |
| `$C104` | `pal_C104` | 3 |  |
| `$C124` | `pal_C124` | 2 |  |
| `$C144` | `pal_C144` | 3 |  |
| `$C145` | `pal_C145` | 3 |  |
| `$C154` | `pal_C154` | 1 |  |
| `$C155` | `pal_C155` | 1 |  |
| `$C184` | `pal_C184` | 4 |  |

## video/sprites

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C185` | `sprite_C185` | 9 | game/script (2), game/stage_events (2), game/collision (1) |
| `$C240` | `sprite_C240` | 6 | game/stage_events (1) |
| `$C242` | `sprite_C242` | 3 |  |
| `$C248` | `sprite_C248` | 6 |  |
| `$C249` | `sprite_C249` | 5 |  |
| `$C24A` | `sprite_C24A` | 5 |  |
| `$C24B` | `sprite_C24B` | 5 | video/vdp (1) |
| `$C24C` | `sprite_C24C` | 8 | game/script (1) |
| `$C8AF` | `sprite_C8AF` | 14 | game/stage_events (5), game/actor_script (2), screens/pause_menu (1) |
| `$C8D9` | `sprite_C8D9` | 4 | game/stage_events (1), screens/pause_menu (1) |
| `$C8DC` | `sprite_C8DC` | 4 | game/stage_events (1), screens/pause_menu (1) |
| `$CB7F` | `sprite_CB7F` | 1 |  |
| `$CD0F` | `sprite_CD0F` | 1 |  |
| `$CEC7` | `sprite_CEC7` | 1 |  |
| `$CF22` | `sprite_CF22` | 3 | game/stage_events (1) |
| `$CF24` | `sprite_CF24` | 3 | game/stage_events (1) |
| `$FFD8` | `sprite_FFD8` | 3 |  |

## video/vdp

| Adresse | Nom | Accès | Aussi utilisée par |
|---|---|---|---|
| `$C0AF` | `vdp_C0AF` | 1 |  |
| `$C0B5` | `vdp_C0B5` | 1 |  |
| `$C200` | `vdp_C200` | 4 | core/game_flow (1) |
| `$C201` | `vdp_C201` | 1 |  |
| `$C800` | `vdp_C800` | 1 |  |
| `$E0E0` | `vdp_E0E0` | 1 |  |
