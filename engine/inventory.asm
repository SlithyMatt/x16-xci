.ifndef INVENTORY_INC
INVENTORY_INC = 1

.include "bin2dec.asm"

INV_START_Y          = 0
INV_TILEMAP          = 1
INV_NUM_ITEMS        = 321
INT_ITEM_ROWS        = 322
INV_ITEM_COLS        = 323
INV_ITEM_WIDTH       = 324
INV_ITEM_HEIGHT      = 325
INV_ITEM_START_X     = 326
INV_ITEM_STEP_X      = 327
INV_ITEM_QUANT_X     = 328
INV_ITEM_QUANT_WIDTH = 329
INV_ITEM_CFG         = 330

INV_MAX_ITEM_LABEL   = 16
INV_ITEM_QUANT       = 16
INV_ITEM_MAX         = 18
INV_ITEM_CURSOR      = 20
INV_ITEM_TILES       = 22

__inv_tilemap_addr:     .word 0
__inv_scroll_up_x:      .byte 0
__inv_scroll_up_y:      .byte 0
__inv_scroll_down_x:    .byte 0
__inv_scroll_down_y:    .byte 0
__inv_num_items:        .byte 0
__inv_max_items:        .byte 0
__inv_page_rows:        .byte 0
__inv_page_cols:        .byte 0
__inv_page_size:        .byte 0
__inv_page_start:       .byte 0
__inv_item_width:       .byte 0
__inv_item_height:      .byte 0
__inv_item_start_x:     .byte 0
__inv_item_step_x:      .byte 0
__inv_item_quant_x:     .byte 0
__inv_item_quant_width: .byte 0
__inv_item_cfg_size:    .byte 0

__inv_order:   ; position to index map
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

__inv_cfg_map: ; index to config address map
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

init_inv:
   stz inv_visible
   stz current_item
   stz __inv_num_items
   stz __inv_page_start
   ldy #INV_START_Y
   lda (INV_PTR),y
   sta inv_start_y
   lda INV_PTR
   clc
   adc #INV_TILEMAP
   sta __inv_tilemap_addr
   lda INV_PTR+1
   adc #0
   sta __inv_tilemap_addr+1
   lda INV_PTR
   clc
   adc #<INV_NUM_ITEMS
   sta ZP_PTR_1
   lda INV_PTR+1
   adc #0
   sta ZP_PTR_1+1
   lda (ZP_PTR_1)
   sta __inv_max_items
   ldy #INT_ITEM_ROWS-INV_NUM_ITEMS
   lda (ZP_PTR_1),y
   sta __inv_page_rows
   ldy #INV_ITEM_COLS-INV_NUM_ITEMS
   lda (ZP_PTR_1),y
   sta __inv_page_cols
   tax
   ldy __inv_page_rows
   jsr byte_mult
   sta __inv_page_size
   ldy #INV_ITEM_WIDTH-INV_NUM_ITEMS
   lda (ZP_PTR_1),y
   sta __inv_item_width
   ldy #INV_ITEM_HEIGHT-INV_NUM_ITEMS
   lda (ZP_PTR_1),y
   sta __inv_item_height
   ldy #INV_ITEM_START_X-INV_NUM_ITEMS
   lda (ZP_PTR_1),y
   sta __inv_item_start_x
   ldy #INV_ITEM_STEP_X-INV_NUM_ITEMS
   lda (ZP_PTR_1),y
   sta __inv_item_step_x
   ldy #INV_ITEM_QUANT_X-INV_NUM_ITEMS
   lda (ZP_PTR_1),y
   sta __inv_item_quant_x
   ldy #INV_ITEM_QUANT_WIDTH-INV_NUM_ITEMS
   lda (ZP_PTR_1),y
   sta __inv_item_quant_width
   lda INV_PTR
   clc
   adc #<INV_ITEM_CFG
   tax
   lda INV_PTR+1
   adc #>INV_ITEM_CFG
   tay
   jsr __inv_map_item_cfgs
   ldx __inv_item_width
   ldy __inv_item_height
   jsr byte_mult
   clc
   adc #INV_ITEM_TILES
   sta __inv_item_cfg_size
@loop:
   lda current_item
   cmp __inv_max_items
   beq @return
   jsr inv_get_quant
   cpx #0
   bne @add
   cpy #0
   beq @next
@add:
   lda current_item     ; initial quantity of the current item > 0
   ldx __inv_num_items
   sta __inv_order,x
   inc __inv_num_items
@next:
   inc current_item
   bra @loop
@return:
   stz current_item
   rts

show_inv:
   bra @start
@pos: .byte 0
@x:   .byte 0
@y:   .byte 0
@row: .byte 0
@col: .byte 0
@start:
   stz @pos
   lda inv_start_y
   sta @y
   lda __inv_tilemap_addr
   sta ZP_PTR_1
   lda __inv_tilemap_addr+1
   sta ZP_PTR_1
@loop:
   lda #1
   ldx #0
   ldy @y
   jsr xy2vaddr
   stz VERA_ctrl
   ora #$10
   sta VERA_addr_bank
   stx VERA_addr_low
   sty VERA_addr_high
   ldy #0
@tile_loop:
   lda (ZP_PTR_1),y
   sta VERA_data0
   iny
   cpy #80
   bne @tile_loop
   inc @y
   lda @y
   cmp #30
   beq @fill
   lda ZP_PTR_1
   clc
   adc #80
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   bra @loop
@fill:
   stz @row
   stz @col
@fill_loop:
   lda @pos
   cmp __inv_page_size
   beq @return
   ldx @col
   ldy @row
   jsr __inv_show_item
   inc @col
   lda @col
   cmp __inv_page_cols
   beq @new_row
   bra @fill_loop
@new_row:
   inc @row
   lda @row
   cmp __inv_page_rows
   beq @return
   stz @col
   inc @pos
   bra @fill_loop
@return:
   lda #1
   sta inv_visible
   rts

__inv_show_item:  ; A: item position in __inv_order
                  ; X: page column
                  ; Y: page row
   bra @start
@pos:          .byte 0
@x:            .byte 0
@y:            .byte 0
@end_y:        .byte 0
@tile_offset:  .byte 0
@width:        .byte 0
@quant:        .word 0
@quant_ascii:  .byte 0,0,0,0,0
@start:
   sta @pos
   lda __inv_item_start_x
   clc
@x_loop:
   cpx #0
   beq @set_y
   adc __inv_item_step_x
   dex
   bra @x_loop
@set_y:
   sta @x
   lda inv_start_y
   clc
@y_loop:
   cpy #0
   beq @show
   adc __inv_item_height
   dey
   bra @y_loop
@show:
   sta @y
   clc
   adc __inv_item_height
   sta @end_y
   ldx @pos
   lda __inv_order,x
   sta ZP_PTR_1
   inx
   lda __inv_order,x
   sta ZP_PTR_1+1
   ldy #INV_ITEM_QUANT
   lda (ZP_PTR_1),y
   sta @quant
   iny
   lda (ZP_PTR_1),y
   sta @quant+1
   lda #INV_ITEM_TILES
   sta @tile_offset
   lda __inv_item_width
   asl
   sta @width
@show_loop:
   lda #1
   ldx @x
   ldy @y
   jsr xy2vaddr
   stz VERA_ctrl
   ora #$10
   sta VERA_addr_bank
   stx VERA_addr_low
   sty VERA_addr_high
   ldx #0
@tile_loop:
   ldy @tile_offset
   lda (ZP_PTR_1),y
   sta VERA_data0
   inc @tile_offset
   inx
   cpx @width
   bne @tile_loop
   inc @y
   lda @y
   cmp @end_y
   bne @show_loop
   lda __inv_item_quant_x
   beq @return
   clc
   adc @x
   sta @x
   dec @y
   lda #<@quant
   sta ZP_PTR_1
   lda #>@quant
   sta ZP_PTR_1+1
   lda #<@quant_ascii
   sta ZP_PTR_2
   lda #>@quant_ascii
   sta ZP_PTR_2+1
   jsr word2ascii
   sta @width
   lda __inv_item_quant_width
   sec
   sbc @width



@return:
   rts

inv_hide:
   bra @start
@y: .byte 0
@start:
   lda inv_start_y
   sta @y
@row_loop:
   lda #1
   ldx #0
   ldy @y
   jsr xy2vaddr
   stz VERA_ctrl
   ora #$10
   sta VERA_addr_bank
   stx VERA_addr_low
   sty VERA_addr_high
   ldy #0
@tile_loop:
   stz VERA_data0
   iny
   cpy #80
   bne @tile_loop
   inc @y
   lda @y
   cmp #30
   bne @row_loop
   stz inv_visible
   rts


inv_tick:

   rts

__inv_map_item_cfgs: ; Input: X/Y item config start address
   bra @start
@addr: .word 0
@start:
   stx @addr
   sty @addr+1
   ldx #0
@loop:
   cpx __inv_max_items
   beq @return
   txa
   asl
   tay
   lda @addr
   sta __inv_cfg_map,y
   lda @addr+1
   iny
   sta __inv_cfg_map,y
   lda @addr
   clc
   adc __inv_item_cfg_size
   sta @addr
   lda @addr+1
   adc #0
   sta @addr+1
   inx
   bra @loop
@return:
   rts

inv_get_quant: ; Input: A - item index
               ; Output: X/Y - quantity
   asl
   tax
   lda __inv_cfg_map,x
   sta ZP_PTR_1
   inx
   lda __inv_cfg_map,x
   sta ZP_PTR_1+1
   ldy #INV_ITEM_QUANT
   lda (ZP_PTR_1),y
   tax
   iny
   lda (ZP_PTR_1),y
   tay
   rts

.endif
