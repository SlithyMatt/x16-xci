.ifndef MENU_INC
MENU_INC = 1

.include "x16.inc"
.include "globals.asm"

; MENU_PTR offsets
MENU_DIV       = 80
MENU_SPACE     = 82
MENU_CHECK     = 84
MENU_UNCHECK   = 86
MENU_CONTROLS  = 88
MENU_ABOUT     = 90
MENU_NUM       = 92

__menu_visible: .byte 0

init_menu:
   bra @start
@tilemap: .word 0
@start:
   ; blackout bitmap
   stz VERA_ctrl
   lda #LAYER_BM_OFFSET
   sta VERA_addr_low
   lda #>VRAM_layer0
   sta VERA_addr_high
   lda #(^VRAM_layer0 | $10)
   sta VERA_addr_bank
   lda #BLACK_PO
   sta VERA_data0

   ; clear all tiles
   VERA_SET_ADDR VRAM_TILEMAP, 1
   lda #<TILEMAP_SIZE
   sta @tilemap
   lda #>TILEMAP_SIZE
   sta @tilemap+1
@clear_tile_loop:
   stz VERA_data0
   lda @tilemap
   sec
   sbc #1
   sta @tilemap
   lda @tilemap+1
   sbc #0
   sta @tilemap+1
   bne @clear_tile_loop
   lda @tilemap
   bne @clear_tile_loop

   ; init mouse cursor
   lda #0
   sta ROM_BANK
   lda #$FF ; custom cursor
   ldx #2   ; scale x 2
   jsr MOUSE_CONFIG
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

   ; disable other sprites
   VERA_SET_ADDR $F500E, 4 ; sprite 1 byte 6, stride of 8
   ldx #1
@clear_sprite_loop:
   stz VERA_data0
   inx
   cpx #128
   bne @clear_sprite_loop

   ; render menu bar
   VERA_SET_ADDR VRAM_TILEMAP, 1
   ldy #0
@render_loop:
   lda (MENU_PTR),y
   sta VERA_data0
   iny
   cpy #80
   bne @render_loop

   lda #1
   sta __menu_visible

   rts

menu_tick:

@return:
   rts


.endif
