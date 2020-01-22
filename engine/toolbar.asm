.ifndef TOOLBAR_INC
TOOLBAR_INC = 1

; config offsets
TB_START_X        = 0
TB_START_Y        = 1
TB_WALK_CURSOR    = 2
TB_RUN_CURSOR     = 4
TB_LOOK_CURSOR    = 6
TB_USE_CURSOR     = 8
TB_TALK_CURSOR    = 10
TB_STRIKE_CURSOR  = 12
TB_NUM_TOOLS      = 14
TB_BUTTONS        = 15

TB_POPUP_ZONE_Y   = 29

__tb_enabled: .byte 0

__tb_start_x:  .byte 0
__tb_end_x:    .byte 0

__tb_tiles:
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

; tool IDs
INVENTORY_TOOL = 0
WALK_TOOL      = 1
RUN_TOOL       = 2
LOOK_TOOL      = 3
USE_TOOL       = 4
TALK_TOOL      = 5
STRIKE_TOOL    = 6
PIN_TOOLBAR    = 7

__tb_num_tools: .byte 0

__tb_tools:
; first tool
.byte 0     ; start X
.byte 0     ; tool ID
.word 0     ; cursor
.dword 0,0,0,0,0,0,0

__tb_pin_pos:        .byte 0
__tb_pin_tiles_ptr:  .word 0
__tb_pinned:         .byte 0


init_toolbar:
   bra @start
@start_x: .byte 0
@action: .byte 0
@height: .byte 0
@width: .byte 0
@i: .byte 0
@start:
   ldy #TB_START_X
   lda (TB_PTR),y
   sta __tb_start_x
   ldy #TB_START_Y
   lda (TB_PTR),y
   sta tb_start_y
   ldy #TB_NUM_TOOLS
   lda (TB_PTR),y
   sta __tb_num_tools
   lda TB_PTR
   clc
   adc #TB_BUTTONS
   sta ZP_PTR_1
   lda TB_PTR+1
   adc #0
   sta ZP_PTR_1+1
   stz @width
   ldx #0
   lda __tb_start_x
   sta __tb_end_x
@loop:
   lda __tb_end_x
   asl
   clc
   adc #<__tb_tiles
   sta ZP_PTR_2
   lda #>__tb_tiles
   adc #0
   sta ZP_PTR_2+1
   txa
   asl
   asl
   tay
   iny
   lda (ZP_PTR_1)
   sta __tb_tools,y  ; action
   sta @action
   dey
   phy
   ldy #1
   lda (ZP_PTR_1),y
   ply
   sta __tb_tools,y  ; start_x
   sta @start_x
   ldy #2
   lda (ZP_PTR_1),y
   inc
   sta __tb_end_x
   sec
   sbc @start_x
   asl
   sta @width
   lda #30
   sec
   sbc tb_start_y
   sta @height
   lda ZP_PTR_1
   clc
   adc #3
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
@tile_loop:
   ldy #0
@row_loop:
   lda (ZP_PTR_1),y
   sta (ZP_PTR_2),y
   iny
   cpy @width
   bne @row_loop
   lda ZP_PTR_1
   clc
   adc @width
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   lda ZP_PTR_2
   clc
   adc #80
   sta ZP_PTR_2
   lda ZP_PTR_2+1
   adc #0
   sta ZP_PTR_2+1
   dec @height
   lda @height
   bne @tile_loop
   lda @action
   cmp #PIN_TOOLBAR
   bne @next_button
   stx __tb_pin_pos
   lda ZP_PTR_1
   sta __tb_pin_tiles_ptr
   lda ZP_PTR_1+1
   sta __tb_pin_tiles_ptr+1
   lda #30
   sec
   sbc tb_start_y
   sta @height
@pin_loop:           ; advance ZP_PTR_1 past the second pin button
   lda @height
   beq @next_button
   lda ZP_PTR_1
   clc
   adc @width
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   dec @height
   bra @pin_loop
@next_button:
   lda @action
   jsr __tb_set_cursor
   inx
   cpx __tb_num_tools
   beq @done
   jmp @loop
@done:
   lda #1
   sta __tb_enabled
   rts

__tb_set_cursor:  ; A: tool ID
                  ; X: tool position in __tb_tools (must not change)
   bra @start
@id:           .byte 0
@cursor_table: .byte 0
@cursor_cfg:   .byte 0
@start:
   sta @id
   txa
   asl
   asl
   inc
   inc ; __tb_tools,a -> cursor
   sta @cursor_table
   lda @id
   cmp #WALK_TOOL
   beq @walk
   cmp #RUN_TOOL
   beq @run
   cmp #LOOK_TOOL
   beq @look
   cmp #USE_TOOL
   beq @use
   cmp #TALK_TOOL
   beq @talk
   cmp #STRIKE_TOOL
   beq @strike
   lda def_cursor    ; all other toolbar actions use default cursor
   ldy @cursor_table
   sta __tb_tools,y
   iny
   lda def_cursor+1
   sta __tb_tools,y
   bra @return
@walk:
   lda #TB_WALK_CURSOR
   bra @copy
@run:
   lda #TB_RUN_CURSOR
   bra @copy
@look:
   lda #TB_LOOK_CURSOR
   bra @copy
@use:
   lda #TB_USE_CURSOR
   bra @copy
@talk:
   lda #TB_TALK_CURSOR
   bra @copy
@strike:
   lda #TB_STRIKE_CURSOR
@copy:
   sta @cursor_cfg
   ldy @cursor_cfg
   lda (TB_PTR),y
   ldy @cursor_table
   sta __tb_tools,y
   ldy @cursor_cfg+1
   lda (TB_PTR),y
   ldy @cursor_table+1
   sta __tb_tools,y
@return:
   rts

toolbar_tick:
   lda __tb_enabled
   beq @return
   lda tb_visible
   bne @check_hide
   lda mouse_tile_y
   cmp #TB_POPUP_ZONE_Y
   bmi @return
   jsr __tb_show
   bra @return
@check_hide:
   lda mouse_tile_y
   cmp tb_start_y
   bmi @hide
   cmp #TB_POPUP_ZONE_Y
   bpl @check_click     ; never hide toolbar while in popup zone
   lda mouse_tile_x
   cmp __tb_start_x
   bmi @hide
   cmp __tb_end_x
   bpl @hide
@check_click:
   lda mouse_left_click
   beq @return
   jsr __tb_click
@hide:
   lda __tb_pinned
   bne @return       ; keep toolbar visible while pinned
   lda inv_visible
   bne @return       ; toolbar already hidden to show inventory
   jsr __tb_hide
@return:
   rts

__tb_show:
   bra @start
@y: .byte 0
@start:
   lda tb_start_y
   sta @y
   lda #<__tb_tiles
   sta ZP_PTR_1
   lda #>__tb_tiles
   sta ZP_PTR_1+1
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
   lda (ZP_PTR_1),y
   sta VERA_data0
   iny
   cpy #80
   bne @tile_loop
   lda ZP_PTR_1
   clc
   adc #80
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   inc @y
   lda @y
   cmp #30
   bne @row_loop
   lda #1
   sta tb_visible
   rts

__tb_click:
   bra @start
@index: .byte 0
@start:
   stz @index
@loop:
   lda @index
   asl
   asl
   tax
   lda __tb_tools,x ; start_x
   cmp mouse_tile_x
   bmi @get_action
   inc @index
   lda @index
   cmp __tb_num_tools
   bne @loop
@get_action:
   dec @index
   lda @index
   bmi @clear
   asl
   asl
   inc
   cmp #INVENTORY_TOOL
   beq @inventory
   cmp #WALK_TOOL
   beq @walk

@inventory:

@walk:

@clear:
   stz current_tool
   SET_MOUSE_CURSOR def_cursor
@return:
   rts

__tb_hide:
   bra @start
@y: .byte 0
@start:
   lda tb_start_y
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
   stz tb_visible
   rts

.endif
