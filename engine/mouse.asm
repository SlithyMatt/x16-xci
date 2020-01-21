.ifndef MOUSE_INC
MOUSE_INC = 1

MOUSE_LEFT_BUTTON = $01

mouse_tick:
   lda #0
   sta ROM_BANK
   ldx #MOUSE_X
   jsr MOUSE_GET
   and #MOUSE_LEFT_BUTTON
   sta mouse_button
   lda MOUSE_X       ; divide screen X by 8 to get tile X
   sta mouse_tile_x
   lda MOUSE_X+1
   lsr
   ror mouse_tile_x
   lsr
   ror mouse_tile_x
   lsr
   ror mouse_tile_x
   sta mouse_tile_x+1
   lda MOUSE_Y       ; divide screen Y by 8 to get tile X
   sta mouse_tile_y
   lda MOUSE_Y+1
   lsr
   ror mouse_tile_y
   lsr
   ror mouse_tile_y
   lsr
   ror mouse_tile_y
   sta mouse_tile_y+1
   rts
   
.endif
