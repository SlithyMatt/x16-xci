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
   stz current_item

   ; disable all sprites except mouse cursor
   VERA_SET_ADDR $F500E, 4 ; sprite 1 byte 6, stride of 8
   ldx #1
@clear_sprite_loop:
   stz VERA_data0
   inx
   cpx #128
   bne @clear_sprite_loop

   ; intialize animation
   stz anim_seq_done
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
   sta ZP_PTR_1
   lda ANIM_PTR+1
   sta ZP_PTR_1
   jsr __level_next_seq
   lda (ZP_PTR_1)
   cmp #FIRST_VISIT
   bne @find_triggers
   ldx level
   ldy zone
   jsr check_visited
   cmp #0
   bne @find_triggers
   lda ZP_PTR_1
   clc
   adc #1
   sta __level_first
   lda ZP_PTR_1+1
   adc #0
   sta __level_first+1
   lda #1
   sta __level_has_first
@find_triggers:
   stz __level_num_triggers
@trigger_loop:
   jsr __level_next_seq
   lda (ZP_PTR_1)
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
   lda (ZP_PTR_1)
   ldy #6
   sta (ZP_PTR_2),y  ; set key
   ldy #1
   lda (ZP_PTR_1),y
   ldy #7
   sta (ZP_PTR_2),y  ; set tool/item
   ldy #2
   sta (ZP_PTR_2),y
   iny
   lda (ZP_PTR_1),y
   sta (ZP_PTR_2),y  ; set x_min
   iny
   lda (ZP_PTR_1),y
   sta (ZP_PTR_2),y  ; set y_min
   iny
   lda (ZP_PTR_1),y
   sta (ZP_PTR_2),y  ; set x_max
   iny
   lda (ZP_PTR_1),y
   sta (ZP_PTR_2),y  ; set y_max
@next_trigger:
   inc __level_num_triggers
   bra @trigger_loop

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
   VERA_SET_ADDR VRAM_BITMAP,1
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
   pha
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
   rts

__level_next_seq: ; Input/Output: ZP_PTR_1 - address of start of sequence
@loop:
   lda (ZP_PTR)
   cmp #END_ANIM
   beq @next
   lda ZP_PTR_1
   clc
   adc #1
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   bra @loop
@next:
   lda ZP_PTR_1
   clc
   adc #1
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
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
   lda __level_playing
   bne @check_done
   jmp @return
@check_done:
   lda anim_seq_done
   bne @next_seq
   jmp @return
@next_seq:
   lda __level_has_first
   beq @check_go_level
   lda __level_first
   sta ANIM_PTR
   lda __level_first+1
   sta ANIM_PTR+1
   stz __level_has_first
   stz anim_seq_done
   jmp @return
@check_go_level:
   lda (ANIM_PTR)
   cmp #GO_LEVEL
   bne @check_trigger
   INC_ANIM_PTR
   lda (ANIM_PTR)
   cmp zone
   beq @get_level
   sta zone
   jsr load_zone
@get_level:
   INC_ANIM_PTR
   lda (ANIM_PTR)
   sta level
   jsr load_level
   jmp @return
@check_trigger:
   stz __level_trigger_offset
   stz __level_trigger_offset+1
   ldx #0
@trigger_loop:
   cpx __level_num_triggers
   beq @return
   phx
   lda __level_triggers
   clc
   adc __level_trigger_offset
   sta ZP_PTR_1
   lda __level_triggers+1
   adc __level_trigger_offset+1
   sta ZP_PTR_1+1
   lda mouse_tile_x
   ldy #2
   cmp (ZP_PTR_1),y
   bmi @next
   ldy #4
   dec
   cmp (ZP_PTR_1),y
   bpl @next
   lda mouse_tile_y
   ldy #3
   cmp (ZP_PTR_1),y
   bmi @next
   ldy #5
   dec
   cmp (ZP_PTR_1),y
   bpl @next
   ldy #6
   lda (ZP_PTR_1),y
   cmp #ITEM_TRIGGER
   bne @check_tool
   lda mouse_left_click
   beq @next
   lda current_item
   ldy #7
   cmp (ZP_PTR_1),y
   beq @exec_trigger
   bra @next
@check_tool:
   

@exec_trigger:


@next:
   plx
   inx
   lda __level_trigger_offset
   clc
   adc #8
   sta __level_trigger_offset
   lda __level_trigger_offset+1
   adc #0
   sta __level_trigger_offset+1
   bra @trigger_loop
@return:
   rts



.endif
