.ifndef MOUSE_INC
MOUSE_INC = 1

MOUSE_LEFT_BUTTON = $01

__mouse_last_left_button: .byte 0

init_mouse:
   lda #0
   sta ROM_BANK
   sec
   jsr SCREEN_MODE ; setup X and Y with screen size
   lda #$FF ; custom cursor
   jsr MOUSE_CONFIG
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_sprattr, 1
   lda def_cursor
   sta VERA_data0
   lda def_cursor+1
   sta VERA_data0
   lda VERA_data0 ; leave position alone
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda #$0C       ; make cursor visible, no flipping
   sta VERA_data0
   lda #$50       ; size 16x16, palette offset 0
   sta VERA_data0
   rts

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
   lda MOUSE_Y       ; divide screen Y by 8 to get tile Y
   sta mouse_tile_y
   lda MOUSE_Y+1
   lsr
   ror mouse_tile_y
   lsr
   ror mouse_tile_y
   lsr
   ror mouse_tile_y
   rts

.endif
