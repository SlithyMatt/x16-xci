.ifndef ANIMATION_INC
ANIMATION_INC = 1

SPRITE_FRAMES_KEY    = 40
SPRITE_KEY           = 41
TILES_KEY            = 42
WAIT_KEY             = 43
SPRITE_MOVE_KEY      = 44
END_ANIM_KEY         = 56

__anim_playing:   .byte 0
__anim_start:     .word 0
__anim_loops:     .byte 0

start_anim:
   lda ANIM_PTR
   sta __anim_start
   lda ANIM_PTR+1
   sta __anim_start+1
   lda #1
   sta __anim_playing
   stz __anim_loops
   rts

stop_anim:
   stz __anim_playing
   rts

anim_tick:
   lda __anim_playing
   bne @play
   jmp @return
@play:
   lda anim_bank
   sta RAM_BANK
   ldx #0
   lda (ANIM_PTR,x)
   inx
   cmp #SPRITE_FRAMES_KEY
   beq @sprite_frames
   cmp #SPRITE_KEY
   beq @sprite
   cmp #TILES_KEY
   beq @tiles
   cmp #WAIT_KEY
   beq @wait
   cmp #SPRITE_MOVE_KEY
   beq @sprite_move
   cmp #END_ANIM_KEY
   beq @end_anim
   jmp @stop ; unrecognized key, just stop
@sprite_frames:
   jsr anim_sprite_frames
   jmp @play
@sprite:
   jsr anim_sprite
   jmp @play
@tiles:
   jsr anim_tiles
   jmp @play
@wait:
   jsr anim_wait
   jmp @return
@sprite_move:
   jsr anim_sprite_move
   jmp @play
@end_anim:
   lda (ANIM_PTR,x)
   cmp __anim_loops
   beq @stop
   inc __anim_loops
   lda __anim_start
   sta ANIM_PTR
   lda __anim_start+1
   sta ANIM_PTR+1
   bra @return
@stop:
   jsr stop_anim
@return:
   rts

anim_sprite_frames:

   rts

anim_sprite:

   rts

anim_tiles:

   rts

anim_wait:

   rts

anim_sprite_move:

   rts


.endif
