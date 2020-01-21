.ifndef MENU_INC
MENU_INC = 1

.include "x16.inc"
.include "globals.asm"
.include "zone.asm"
.include "xgf.asm"
.include "music.asm"
.include "help.asm"
.include "tilelib.asm"

MENU_ASCII_BYTE2  = MENU_PO << 4

; MENU_PTR offsets
MENU_DIV       = 80
MENU_SPACE     = 82
MENU_CHECK     = 84
MENU_UNCHECK   = 86
MENU_CONTROLS  = 88
MENU_ABOUT     = 90
MENU_NUM       = 92

; Menu Item IDs
MENU_DIV_ITEM  = 0
NEW_GAME       = 1
LOAD_GAME      = 2
SAVE_GAME      = 3
SAVE_GAME_AS   = 4
EXIT_GAME      = 5
TOGGLE_MUSIC   = 6
TOGGLE_SFX     = 7
HELP_CONTROLS  = 8
HELP_ABOUT     = 9

__menu_bar_visible:  .byte 0
__menu_visible:      .byte 0

__str_new:        .byte "New Game      "
__str_load:       .byte "Load Game...  "
__str_save:       .byte "Save Game     "
__str_saveas:     .byte "Save As...    "
__str_exit:       .byte "Exit          "
__str_music:      .byte "Music         "
__str_sfx:        .byte "Sound Effects "
__str_controls:   .byte "Controls      "
__str_about:      .byte "About         "
__end_strings:

__menu_strings:
.word 0 ; placeholder for divider
.word __str_new
.word __str_load
.word __str_save
.word __str_saveas
.word __str_exit
.word __str_music
.word __str_sfx
.word __str_controls
.word __str_about

__menu_y_map:
.byte 0 ; placeholder for menu bar
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0

__menu_idx:       .byte 0
__menu_start_x:   .byte 0
__menu_end_x:     .byte 0  ; always __menu_start_x+15 when menu visible
__menu_end_y:     .byte 0

__menu_0:
.byte 0, 0, 0     ; config: start_x, end_x, num_items
__menu_0_items:   ; each item 32 bytes
.byte 0, 0        ; item ID, spare
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; tiles (last tile always transparent)
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

MENU_ITEMS_OFFSET = __menu_0_items-__menu_0

__menu_1:
.byte 0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

__menu_2:
.byte 0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

__menu_3:
.byte 0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

__menu_4:
.byte 0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


__menu_table:
.word __menu_0
.word __menu_1
.word __menu_2
.word __menu_3
.word __menu_4


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

   ; build the menus
   ldy #MENU_NUM
   lda (MENU_PTR),y
   tax   ; x = number of menus
   stz __menu_idx
   lda MENU_PTR
   clc
   adc #MENU_NUM+1
   sta ZP_PTR_1
   lda MENU_PTR+1
   adc #0
   sta ZP_PTR_1+1
@build_loop:
   phx
   lda __menu_idx
   asl
   tay
   lda __menu_table,y
   sta ZP_PTR_2
   lda __menu_table+1,y
   sta ZP_PTR_2+1       ; ZP_PTR_2 -> menu_x
   ldy #0
   lda (ZP_PTR_1),y     ; start_x
   sta (ZP_PTR_2),y
   iny
   lda (ZP_PTR_1),y     ; end_x
   sta (ZP_PTR_2),y
   iny
   lda (ZP_PTR_1),y     ; num_items
   sta (ZP_PTR_2),y
   iny
   tax   ; x = number of items
   tya
   clc
   adc ZP_PTR_1
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   lda ZP_PTR_2
   clc
   adc #MENU_ITEMS_OFFSET
   sta ZP_PTR_2
   lda ZP_PTR_2+1
   adc #0
   sta ZP_PTR_2+1
@item_loop:
   phx
   lda (ZP_PTR_1) ; item ID
   sta (ZP_PTR_2)
   jsr __menu_build_item_tiles
   lda ZP_PTR_1
   clc
   adc #1
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   lda ZP_PTR_2
   clc
   adc #32
   sta ZP_PTR_2
   lda ZP_PTR_2+1
   adc #0
   sta ZP_PTR_2+1
   plx
   dex
   bne @item_loop
   inc __menu_idx
   plx
   dex
   bne @build_loop

@render:
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
   sta __menu_bar_visible
   rts

__menu_build_item_tiles:   ; A: item ID
                           ; ZP_PTR_2: menu item layout
   bra @start
@div_tile: .word 0
@start:
   pha
   cmp #MENU_DIV_ITEM
   beq @div
   cmp #TOGGLE_MUSIC
   beq @toggle
   cmp #TOGGLE_SFX
   beq @toggle
   ldy #MENU_SPACE
   lda (MENU_PTR),y
   ldy #2
   sta (ZP_PTR_2),y
   ldy #MENU_SPACE+1
   lda (MENU_PTR),y
   ldy #3
   sta (ZP_PTR_2),y
   bra @build
@div:
   pla   ; clear stack
   ldy #MENU_DIV
   lda (MENU_PTR),y
   sta @div_tile
   iny
   lda (MENU_PTR),y
   sta @div_tile+1
   ldy #2
@div_loop:
   lda @div_tile
   sta (ZP_PTR_2),y
   iny
   lda @div_tile+1
   sta (ZP_PTR_2),y
   iny
   cpy #32
   bne @div_loop
   bra @return
@toggle:
   ldy #MENU_CHECK
   lda (MENU_PTR),y
   ldy #2
   sta (ZP_PTR_2),y
   ldy #MENU_CHECK
   lda (MENU_PTR),y
   ldy #3
   sta (ZP_PTR_2),y
@build:
   pla
   asl
   tax
   lda __menu_strings,x
   sta ZP_PTR_3
   inx
   lda __menu_strings,x
   sta ZP_PTR_3+1
   ldx #14
   ldy #0
@build_loop:
   lda (ZP_PTR_3),y
   pha
   tya
   asl
   clc
   adc #4
   tay
   pla
   sta (ZP_PTR_2),y
   lda #MENU_ASCII_BYTE2
   iny
   sta (ZP_PTR_2),y
   tya
   sec
   sbc #5
   lsr
   inc
   tay
   dex
   bne @build_loop
@return:
   rts


menu_tick:
   lda __menu_bar_visible
   beq @return
   lda mouse_button
   beq @return
   lda __menu_visible
   beq @check_bar
   lda mouse_tile_x
   beq @restore
   cmp __menu_start_x
   bmi @restore
   cmp __menu_end_x
   bpl @restore
   lda mouse_tile_y
   cmp __menu_end_y
   bpl @restore
   jsr __menu_command
   lda (ZP_PTR_1)
   cmp #MENU_DIV_ITEM
   beq @return
@restore:
   stz __menu_visible
   jsr tile_restore
   bra @return
@check_bar:
   jsr __menu_bar_click
@return:
   rts

__menu_command:
   bra @start
@offset: .word 0
@start:
   lda __menu_idx
   asl
   tax
   lda __menu_table,x
   sta ZP_PTR_1
   inx
   sta ZP_PTR_1+1
   lda ZP_PTR_1
   clc
   adc #3
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   ldy mouse_tile_y
   lda __menu_y_map,y
   cmp #NEW_GAME
   beq @new
   cmp #LOAD_GAME
   beq @load
   cmp #SAVE_GAME
   beq @save
   cmp #SAVE_GAME_AS
   beq @saveas
   cmp #EXIT_GAME
   beq @exit
   cmp #TOGGLE_MUSIC
   beq @music
   cmp #TOGGLE_SFX
   beq @sfx
   cmp #HELP_CONTROLS
   beq @controls
   cmp #HELP_ABOUT
   beq @about
   bra @return
@new:
   jsr new_game
   bra @return
@load:
   jsr load_game
   bra @return
@save:
   jsr save_game
   bra @return
@saveas:
   jsr save_game_as
   bra @return
@exit:
   jsr __menu_exit
   bra @return
@music:
   jsr __menu_toggle_music
   bra @return
@sfx:
   jsr __menu_toggle_sfx
   bra @return
@controls:
   jsr help_controls
   rts
@about:
   jsr help_about
   rts
@return:
   rts


__menu_bar_click:
   stz __menu_idx
@loop:
   ldx __menu_idx
   lda __menu_table,x
   sta ZP_PTR_1
   inx
   lda __menu_table,x
   sta ZP_PTR_1+1
   lda mouse_tile_x
   cmp (ZP_PTR_1)
   bmi @next
   ldy #1
   cmp (ZP_PTR_1),y
   bpl @next
   bra @show
@next:
   inc __menu_idx
   lda __menu_idx
   ldy #MENU_NUM
   cmp (MENU_PTR),y
   bne @loop
   jmp @return
@show:
   jsr tile_backup
   lda (ZP_PTR_1)
   sta __menu_start_x
   clc
   adc #15
   sta __menu_end_x
   ldy #2
   lda (ZP_PTR_1),y
   inc
   sta __menu_end_y
   lda ZP_PTR_1
   clc
   adc #3
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   ldx #0
@item_loop:
   lda (ZP_PTR_1)
   sta __menu_y_map,x
   phx
   lda #1
   ldx __menu_start_x
   ldy #1
   jsr xy2vaddr
   stz VERA_ctrl
   ora #$10
   sta VERA_addr_bank
   stx VERA_addr_low
   sty VERA_addr_high
   ldx #0
   ldy #1
@tile_loop:
   lda (ZP_PTR_1),y
   sta VERA_data0
   iny
   inx
   cpx #30
   bne @tile_loop
   plx
   inx
   cpx __menu_end_y
   lda #1
   sta __menu_visible
@return:
   rts

__menu_exit:

   rts

__menu_toggle_music:

   rts

__menu_toggle_sfx:

   rts

.endif
