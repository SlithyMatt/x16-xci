.ifndef SFX_INC
SFX_INC = 1

__sfx_playing: .byte 0
__sfx_end:     .word 0

SOUND_0_PTR = RAM_WIN+3

enable_sfx:
   lda #1
   sta sfx_enabled
   rts

disable_sfx:
   stz sfx_enabled
   rts

play_sfx:   ; A: sound index
   ; get address of sound start pointer
   asl
   tay
   lda #<SOUND_0_PTR
   sta ZP_PTR_1
   lda #>SOUND_0_PTR
   sta ZP_PTR_1+1
   ; get sound start pointer
   lda music_bank
   sta RAM_BANK
   lda (ZP_PTR_1),y
   clc
   adc #<RAM_WIN
   sta SFX_PTR
   iny
   lda (ZP_PTR_1),y
   adc #>RAM_WIN
   sta SFX_PTR+1
   ; get sound end pointer, immediately following
   iny
   lda (ZP_PTR_1),y
   clc
   adc #<RAM_WIN
   sta __sfx_end
   iny
   lda (ZP_PTR_1),y
   adc #>RAM_WIN
   sta __sfx_end+1
   ; start playing at next tick
   lda #1
   sta __sfx_playing
   rts

sfx_tick:
   lda sfx_enabled
   bne @check_playing
   jmp @return
@check_playing:
   lda __sfx_playing
   bne @play
   jmp @return
@play:
   ; TODO - play sound effects
   nop
@return:
   rts

.endif
