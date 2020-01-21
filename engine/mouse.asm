.ifndef MOUSE_INC
MOUSE_INC = 1

MOUSE_LEFT_BUTTON = $01

__mouse_last_left_button: .byte 0

mouse_tick:
   lda #0
   sta ROM_BANK
   ldx #MOUSE_X
   jsr MOUSE_GET
   sta mouse_buttons
   and #MOUSE_LEFT_BUTTON
   beq @clear
   cmp __mouse_last_left_button
   beq @clear ; click started in the last frame
   sta mouse_left_click
   bra @get_tiles
@clear:
   stz mouse_left_click
@get_tiles:
   sta __mouse_last_left_button
   lda MOUSE_X       ; divide screen X by 16 to get tile X
   sta mouse_tile_x
   lda MOUSE_X+1
   lsr
   ror mouse_tile_x
   lsr
   ror mouse_tile_x
   lsr
   ror mouse_tile_x
   lsr
   ror mouse_tile_x
   sta mouse_tile_x+1
   lda MOUSE_Y       ; divide screen Y by 16 to get tile X
   sta mouse_tile_y
   lda MOUSE_Y+1
   lsr
   ror mouse_tile_y
   lsr
   ror mouse_tile_y
   lsr
   ror mouse_tile_y
   lsr
   ror mouse_tile_y
   rts

.endif
