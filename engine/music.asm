.ifndef MUSIC_INC
MUSIC_INC = 1

.include "x16.inc"
.include "ym2151.asm"
.include "globals.asm"

OPM_DELAY_REG   = 2
OPM_DONE_REG    = 4

MUSIC_AVAILABLE = RAM_WIN
MUSIC_START_PTR = RAM_WIN+1

__music_delay: .byte 0

__music_playing: .byte 1

__music_looping: .byte 0

__music_loop_start: .word 0

.macro INC_MUSIC_PTR
   clc
   lda MUSIC_PTR
   adc #2
   sta MUSIC_PTR
   lda MUSIC_PTR+1
   adc #0
   sta MUSIC_PTR+1
.endmacro

init_music:
   stz __music_delay
   lda music_bank
   sta RAM_BANK
   lda MUSIC_START_PTR
   clc
   adc #<RAM_WIN
   sta MUSIC_PTR
   lda MUSIC_START_PTR+1
   adc #>RAM_WIN
   sta MUSIC_PTR+1
   stz __music_looping
   rts

__loop_music:
   stz __music_delay
   lda __music_loop_start
   sta MUSIC_PTR
   lda __music_loop_start+1
   sta MUSIC_PTR+1
   lda #1
   sta __music_looping
   rts


stop_music:
   stz __music_playing
   YM_SET_REG YM_KEY_ON, YM_CH_1
   YM_SET_REG YM_KEY_ON, YM_CH_2
   YM_SET_REG YM_KEY_ON, YM_CH_3
   YM_SET_REG YM_KEY_ON, YM_CH_4
   YM_SET_REG YM_KEY_ON, YM_CH_5
   YM_SET_REG YM_KEY_ON, YM_CH_6
   YM_SET_REG YM_KEY_ON, YM_CH_7
   YM_SET_REG YM_KEY_ON, YM_CH_8
   rts

enable_music:
   lda #1
   sta music_enabled
   jsr start_music
   rts

disable_music:
   jsr stop_music
   stz music_enabled
   rts

start_music:
   jsr stop_music
   lda music_enabled
   beq @return
   lda music_bank
   sta RAM_BANK
   lda MUSIC_AVAILABLE
   beq @return
   jsr play_music
@return:
   rts

play_music:
   lda #1
   sta __music_playing
   rts

music_tick:
   lda __music_playing
   bne @check_delay
   jmp @return
@check_delay:
   lda __music_delay
   beq @loop
   dec __music_delay
   jmp @return
@loop:
   lda music_bank
   sta RAM_BANK
   ldy #0
   lda (MUSIC_PTR),y
   iny
   cmp #OPM_DELAY_REG
   beq @delay
   cmp #OPM_DONE_REG
   beq @done
   bra @write
@delay:
   lda (MUSIC_PTR),y
   dec a
   sta __music_delay
   INC_MUSIC_PTR
   bra @return
@done:
   lda __music_looping
   bne @loop_again
   jsr stop_music
   INC_MUSIC_PTR
   lda MUSIC_PTR
   sta __music_loop_start
   lda MUSIC_PTR+1
   sta __music_loop_start+1
   jsr play_music
@loop_again:
   jsr __loop_music
   bra @return
@write:
   bit YM_data
   bmi @write
   sta YM_reg
   lda (MUSIC_PTR),y
   sta YM_data
   INC_MUSIC_PTR
   jmp @loop
@return:
   rts

.endif
