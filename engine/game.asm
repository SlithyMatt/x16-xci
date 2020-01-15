.ifndef GAME_INC
GAME_INC = 1

.include "x16.inc"
.include "player.asm"
.include "timer.asm"
.include "joystick.asm"
.include "superimpose.asm"
.include "debug.asm"
.include "levels.asm"
.include "loadbank.asm"
.include "fruit.asm"
.include "skull.asm"
.include "fireball.asm"
.include "bomb.asm"
.include "winscreen.asm"
.include "music.asm"
.include "soundfx.asm"

init_game:
   lda #0
   jsr MOUSE_CONFIG  ; disable mouse cursor
   jsr regenerate
   jsr init_music
   rts

game_tick:        ; called after every VSYNC detected (60 Hz)
   inc frame_num
   lda frame_num
   cmp #60
   bne @tick
   lda #0
   sta frame_num
@tick:
   jsr timer_tick
   jsr joystick_tick
   jsr sfx_tick
   jsr check_input
   lda start_prompt
   ora paused
   ora continue_prompt
   bne @return
@play:
   jsr player_tick
   jsr enemy_tick
   jsr fruit_tick
   jsr level_tick
   jsr skull_tick
   jsr fireball_tick
   jsr bomb_tick
   jsr winscreen_tick
   jsr music_tick
@return:
   rts

check_input:
.if NUKE_ENABLED
   lda joystick1_a
   beq @check_start
   jsr enemy_clear
   jsr skull_clear
.endif
@check_start:
   lda joystick1_start
   and new_start
   bne @check_start_action
   lda joystick1_start
   bne @start_still_pressed
   lda #1
   sta new_start
@start_still_pressed:
   jmp check_input_return
@check_start_action:
   stz new_start
   lda start_prompt
   bne @start_game
   jmp @check_pause
@start_game:
   ; Setup level map on layer 1
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_layer1, 1  ; configure VRAM layer 1
   lda #$60                      ; 4bpp tiles
   sta VERA_data0
   lda #$3A                      ; 128x128 map of 16x16 tiles
   sta VERA_data0
   lda #((VRAM_TILEMAP >> 2) & $FF)
   sta VERA_data0
   lda #((VRAM_TILEMAP >> 10) & $FF)
   sta VERA_data0
   ; setup game parameters and initialize states
   jsr init_game
   ; load level 1 bitmap from banked RAM into layer 0
   lda #7
   jsr set_bg_palette
   ; raster the bitmap twice to make sure it takes
   jsr raster_bitmap
   jsr raster_bitmap
   lda #15
   jsr set_bg_palette
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_sprreg, 0  ; enable sprites
   lda #$01
   sta VERA_data0
   VERA_SET_ADDR VRAM_layer1, 0  ; enable VRAM layer 1
   lda #$01
   ora VERA_data0
   sta VERA_data0
   jsr level_backup
   stz start_prompt
   bra check_input_return
@check_pause:
   lda paused
   beq @check_continue
   SUPERIMPOSE_RESTORE
   stz paused
   jsr start_music
   bra check_input_return
@check_continue:
   lda continue_prompt
   beq @pause
   jsr continue
   stz continue_prompt
   bra check_input_return
@pause:
   lda player
   bit #$02
   beq check_input_return
   lda #1
   sta paused
   SUPERIMPOSE "paused", 7, 9
   jsr stop_music
check_input_return:
   rts

raster_bitmap:
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_BITMAP, 1
   lda #BITMAP_BANK
   ldx #0
   ldy #0
   jsr bank2vram
   lda #(BITMAP_BANK+1)
   ldx #0
   ldy #0
   jsr bank2vram
   lda #(BITMAP_BANK+2)
   ldx #0
   ldy #0
   jsr bank2vram
   lda #(BITMAP_BANK+3)
   ldx #0
   ldy #0
   jsr bank2vram
   lda #(BITMAP_BANK+4)
   ldx #0
   ldy #$B0
   jsr bank2vram
   rts

.endif
