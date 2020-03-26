.ifndef MUSIC_INC
MUSIC_INC = 1

.include "x16.inc"
.include "ym2151.asm"
.include "globals.asm"

OPM_DELAY_REG   = 2
OPM_DONE_REG    = 4

MUSIC_AVAILABLE = RAM_WIN
MUSIC_START_PTR = RAM_WIN+1

__music_delay:    .byte 0
__music_playing:  .byte 0

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
   jsr init_music
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
   lda music_enabled
   beq @return
   lda music_bank
   sta RAM_BANK
   lda MUSIC_AVAILABLE
   beq @return
   lda #1
   sta __music_playing
@return:
   rts

music_tick:
   lda __music_playing
   bne @check_delay
   jmp @return
@check_delay:
   lda __music_delay
   beq @load
   dec __music_delay
   bra @return
@load:
   lda music_bank
   sta RAM_BANK
@loop:
   ldy #0
   lda (MUSIC_PTR),y
   iny
   cmp #OPM_DELAY_REG
   beq @delay
   cmp #OPM_DONE_REG
   beq @reinit
   bra @write
@delay:
   lda (MUSIC_PTR),y
   sta __music_delay
   INC_MUSIC_PTR
   bra @return
@reinit:
   jsr init_music
   bra @return
@write:
   sta YM_reg
   lda (MUSIC_PTR),y
   sta YM_data
   INC_MUSIC_PTR
   bra @loop
@return:
   rts

.endif
