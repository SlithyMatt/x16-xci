.ifndef LEVEL_INC
LEVEL_INC = 1

.include "x16.inc"
.include "globals.asm"
.include "animation.asm"

INIT_LEVEL     = 58
FIRST_VISIT    = 59
TOOL_TRIGGER   = 65
ITEM_TRIGGER   = 66

__level_playing:        .byte 0

__level_has_first:      .byte 0
__level_first:          .word 0

__level_num_triggers:   .byte 0

__level_triggers:
.word 0     ; address
.dword 0    ; rectangle
.byte 0     ; key
.byte 0     ; tool/item
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

__level_trigger_offset: .word 0

__level_quant: .word 0

load_level:
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

   ; clear level tiles
   jsr tile_clear

   ; reset UI state
   stz tb_visible
   stz current_tool
   stz inv_visible
   lda #NO_ITEM
   sta current_item

   ; disable all sprites except mouse cursor
   VERA_SET_ADDR $F500E, 4 ; sprite 1 byte 6, stride of 8
   ldx #1
@clear_sprite_loop:
   stz VERA_data0
   inx
   cpx #128
   bne @clear_sprite_loop

   ; intialize animation
   jsr anim_reset
   stz __level_has_first
   jsr start_anim
   ldx level
   ldy #6
   jsr byte_mult
   inc
   sta anim_bank
   sta RAM_BANK
   lda #32
   sta ANIM_PTR
   lda #>RAM_WIN
   sta ANIM_PTR+1
   lda (ANIM_PTR)
   cmp #INIT_LEVEL
   beq @init_seq
   cmp #FIRST_VISIT
   bne @find_triggers
   ldx level
   ldy zone
   jsr check_visited
   cmp #0
   beq @cue_first
   lda #1
   sta anim_seq_done
   bra @find_triggers
@cue_first:
   INC_ANIM_PTR
   bra @find_triggers
@init_seq:
   INC_ANIM_PTR
   lda ANIM_PTR
   sta ZP_PTR_3
   lda ANIM_PTR+1
   sta ZP_PTR_3+1
   jsr __level_next_seq
   lda anim_bank
   sta RAM_BANK
   lda (ZP_PTR_3)
   cmp #FIRST_VISIT
   bne @find_triggers
   ldx level
   ldy zone
   jsr check_visited
   cmp #0
   bne @not_first
   lda ZP_PTR_3
   clc
   adc #1
   sta __level_first
   lda ZP_PTR_3+1
   adc #0
   sta __level_first+1
   lda #1
   sta __level_has_first
@not_first:
   jsr __level_next_seq
@find_triggers:
   stz __level_num_triggers
@trigger_loop:
   lda anim_bank
   sta RAM_BANK
   lda (ZP_PTR_3)
   cmp #TOOL_TRIGGER
   beq @trigger
   cmp #ITEM_TRIGGER
   beq @trigger
   bra @init_music
@trigger:
   lda __level_num_triggers
   sta __level_trigger_offset
   lda #0
   sta __level_trigger_offset+1
   asl __level_trigger_offset
   rol __level_trigger_offset+1
   asl __level_trigger_offset
   rol __level_trigger_offset+1
   asl __level_trigger_offset
   rol __level_trigger_offset+1
   lda #<__level_triggers
   clc
   adc __level_trigger_offset
   sta ZP_PTR_2
   lda #>__level_triggers
   adc __level_trigger_offset+1
   sta ZP_PTR_2+1
   lda (ZP_PTR_3)
   cmp #TOOL_TRIGGER
   beq @tool_offset
   lda #10
   bra @set_offset
@tool_offset:
   lda #6
@set_offset:
   clc
   adc ZP_PTR_3
   sta (ZP_PTR_2)    ; set address of sequence start
   lda ZP_PTR_3+1
   adc #0
   ldy #1
   sta (ZP_PTR_2),y
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ZP_PTR_3)
   ldy #6
   sta (ZP_PTR_2),y  ; set key
   ldy #1
   lda (ZP_PTR_3),y
   ldy #7
   sta (ZP_PTR_2),y  ; set tool/item
   ldy #2
   lda (ZP_PTR_3),y
   sta (ZP_PTR_2),y  ; set x_min
   iny
   lda (ZP_PTR_3),y
   sta (ZP_PTR_2),y  ; set y_min
   iny
   lda (ZP_PTR_3),y
   sta (ZP_PTR_2),y  ; set x_max
   iny
   lda (ZP_PTR_3),y
   cli
   sta (ZP_PTR_2),y  ; set y_max
@next_trigger:
   inc __level_num_triggers
   jsr __level_next_seq
   jmp @trigger_loop

   ; intialize music
@init_music:
   lda anim_bank
   clc
   adc #5
   sta music_bank
   jsr init_music
   jsr start_music

   ; load bitmap
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_LEVEL_BITMAP, 1
   lda anim_bank
   inc            ; bitmap in 4 banks following level config
   pha
   ldx #0
   ldy #0
   jsr bank2vram
   pla
   inc
   pha
   ldx #0
   ldy #0
   jsr bank2vram
   pla
   inc
   pha
   ldx #0
   ldy #0
   jsr bank2vram
   pla
   inc
   ldx #0
   ldy #0
   jsr bank2vram
   lda #LAYER_BM_OFFSET       ; set palette offset
   sta VERA_addr_low
   lda #>VRAM_layer0
   sta VERA_addr_high
   lda #(^VRAM_layer0 | $10)
   sta VERA_addr_bank
   lda level
   clc
   adc #LEVEL0_PO
   sta VERA_data0

   jsr level_continue
   ldx level
   ldy zone
   jsr set_visited
   rts

.macro INC_ZP_PTR_3
   lda ZP_PTR_3
   clc
   adc #1
   sta ZP_PTR_3
   lda ZP_PTR_3+1
   adc #0
   sta ZP_PTR_3+1
.endmacro

__level_next_seq: ; Input/Output: ZP_PTR_3 - address of start of sequence
@loop:
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ZP_PTR_3)
   cli
   cmp #END_ANIM_KEY
   beq @next
   jsr __level_next_instruction
   bra @loop
@next:
   INC_ZP_PTR_3
   rts

__level_next_instruction: ; Input/Output: ZP_PTR_3 - address of start of instruction
   lda (ZP_PTR_3)
   cmp #TOOL_TRIGGER
   bne @check_item_trigger
   jmp @seek6
@check_item_trigger:
   cmp #ITEM_TRIGGER
   bne @check_sprite_frames
   jmp @seek10
@check_sprite_frames:
   cmp #SPRITE_FRAMES_KEY
   beq @sprite_frames
   cmp #SPRITE_KEY
   bne @check_tiles
   jmp @seek5
@check_tiles:
   cmp #TILES_KEY
   beq @tiles
   cmp #WAIT_KEY
   bne @check_sprite_move
   jmp @seek2
@check_sprite_move:
   cmp #SPRITE_MOVE_KEY
   beq @seek6
   cmp #SPRITE_HIDE_KEY
   bne @check_text_line
   jmp @seek2
@check_text_line:
   cmp #TEXT_LINE
   beq @seek40
   cmp #SCROLL_KEY
   bne @check_go_level
   jmp @seek2
@check_go_level:
   cmp #GO_LEVEL
   beq @seek3
   cmp #IF_STATE
   beq @seek3
   cmp #IF_NOT_STATE
   beq @seek3
   cmp #SET_STATE
   beq @seek3
   cmp #CLEAR_STATE
   beq @seek3
   cmp #GET_ITEM
   beq @seek4
   jmp @seek1     ; all other keys are single-byte instructions
@sprite_frames:   ; SPRITE_FRAMES same binary format as TILES
@tiles:
   lda ZP_PTR_3
   clc
   adc #3
   sta ZP_PTR_3
   lda ZP_PTR_3+1
   adc #0
   sta ZP_PTR_3+1
   lda (ZP_PTR_3)
   asl
   clc
   adc ZP_PTR_3
   sta ZP_PTR_3
   lda ZP_PTR_3+1
   adc #0
   sta ZP_PTR_3+1
   bra @return
@seek40:
   lda ZP_PTR_3
   clc
   adc #40
   sta ZP_PTR_3
   lda ZP_PTR_3+1
   adc #0
   sta ZP_PTR_3+1
   bra @return
@seek10:
   lda ZP_PTR_3
   clc
   adc #10
   sta ZP_PTR_3
   lda ZP_PTR_3+1
   adc #0
   sta ZP_PTR_3+1
   bra @return
@seek6:
   INC_ZP_PTR_3
@seek5:
   INC_ZP_PTR_3
@seek4:
   INC_ZP_PTR_3
@seek3:
   INC_ZP_PTR_3
@seek2:
   INC_ZP_PTR_3
@seek1:
   INC_ZP_PTR_3
@return:
   rts

level_pause:
   stz __level_playing
   jsr stop_anim
   rts

level_continue:
   lda #1
   sta __level_playing
   jsr start_anim
   rts

level_tick:
   lda req_load_level
   beq @check_playing
   jsr level_pause
   jsr load_level
   stz req_load_level
@check_playing:
   lda __level_playing
   bne @check_done
   jmp @return
@check_done:
   lda anim_seq_done
   bne @next_seq
   jmp @return
@next_seq:
   lda __level_has_first
   beq @check_trigger
   lda __level_first
   sta ANIM_PTR
   lda __level_first+1
   sta ANIM_PTR+1
   stz __level_has_first
   stz anim_seq_done
   jmp @return
@check_trigger:
   stz __level_trigger_offset
   stz __level_trigger_offset+1
   ldx #0
@trigger_loop:
   cpx __level_num_triggers
   bne @check_next_trigger
   lda current_item
   inc
   ora current_tool
   bne @keep_cursor
   SET_MOUSE_CURSOR def_cursor
@keep_cursor:
   jmp @return
@check_next_trigger:
   phx
   lda #<__level_triggers
   clc
   adc __level_trigger_offset
   sta ZP_PTR_3
   lda #>__level_triggers
   adc __level_trigger_offset+1
   sta ZP_PTR_3+1
   lda anim_bank
   sei
   sta RAM_BANK
   lda mouse_tile_x
   ldy #2
   cmp (ZP_PTR_3),y
   bpl @check_x_max
   jmp @next
@check_x_max:
   ldy #4
   dec
   cmp (ZP_PTR_3),y
   bmi @check_y
   jmp @next
@check_y:
   lda mouse_tile_y
   ldy #3
   cmp (ZP_PTR_3),y
   bpl @check_y_max
   jmp @next
@check_y_max:
   ldy #5
   dec
   cmp (ZP_PTR_3),y
   bmi @check_key
   jmp @next
@check_key:
   ldy #6
   lda (ZP_PTR_3),y
   cli
   cmp #ITEM_TRIGGER
   beq @check_item_click
   jmp @check_tool
@check_item_click:
   lda mouse_left_click
   bne @check_item_index
   jmp @next
@check_item_index:
   lda anim_bank
   sei
   sta RAM_BANK
   lda current_item
   ldy #7
   cmp (ZP_PTR_3),y
   cli
   beq @check_item_quant
   jmp @next
@check_item_quant:
   jsr inv_get_quant
   stx __level_quant
   sty __level_quant+1
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ZP_PTR_3)
   sec
   sbc #4
   sta ZP_PTR_2
   ldy #1
   lda (ZP_PTR_3),y
   cli
   sbc #0
   sta ZP_PTR_2+1
   ldy #1
   lda (ZP_PTR_2),y
   cmp __level_quant+1
   bmi @debit
   beq @check_low_quant
   jmp @next
@check_low_quant:
   dey
   lda (ZP_PTR_2),y
   cmp __level_quant
   bmi @debit
   beq @debit
   jmp @next
@debit:
   ldy #2
   lda (ZP_PTR_2),y
   tax
   iny
   lda (ZP_PTR_2),y
   tay
   lda current_item
   jsr inv_lose_item
   lda #NO_ITEM
   sta current_item
   SET_MOUSE_CURSOR def_cursor
   bra @exec_trigger
@check_tool:
   lda current_item
   cmp #NO_ITEM
   bne @next
   lda current_tool
   bne @check_match
   ldy #7
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ZP_PTR_3),y
   cli
   jsr tool_set_cursor
   bra @check_click
@check_match:
   ldy #7
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ZP_PTR_3),y
   cli
   cmp current_tool
   bne @next
@check_click:
   lda mouse_left_click
   beq @clear_stack
   stz current_tool
   SET_MOUSE_CURSOR def_cursor
@exec_trigger:
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ZP_PTR_3)
   sta ANIM_PTR
   ldy #1
   lda (ZP_PTR_3),y
   cli
   sta ANIM_PTR+1
   stz anim_seq_done
   bra @clear_stack
@next:
   cli
   plx
   inx
   lda __level_trigger_offset
   clc
   adc #8
   sta __level_trigger_offset
   lda __level_trigger_offset+1
   adc #0
   sta __level_trigger_offset+1
   jmp @trigger_loop
@clear_stack:
   plx
@return:
   rts


.endif
