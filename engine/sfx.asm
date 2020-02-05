.ifndef SFX_INC
SFX_INC = 1

enable_sfx:
   lda #1
   sta sfx_enabled
   rts

disable_sfx:
   stz sfx_enabled
   rts

sfx_tick:
   lda sfx_enabled
   beq @return
   ; TODO - play sound effects
@return:
   rts

.endif
