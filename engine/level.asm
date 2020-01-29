.ifndef LEVEL_INC
LEVEL_INC = 1

.include "x16.inc"
.include "globals.asm"
.include "animation.asm"

INIT_LEVEL     = 58
FIRST_VISIT    = 59
TEXT_LINE      = 60
SCROLL         = 61
LINE_SKIP      = 62
CLEAR_TEXT     = 63
GO_LEVEL       = 64
TOOL_TRIGGER   = 65
ITEM_TRIGGER   = 66
IF_STATE       = 67
IF_NOT_STATE   = 68
END_IF         = 69
SET_STATE      = 70
CLEAR_STATE    = 71
GET_ITEM       = 72

__level_playing:        .byte 0

__level_has_first:      .byte 0
__level_first:          .word 0

__level_num_triggers:   .byte 0

__level_triggers:
.word 0     ; address
.byte 0     ; key
.dword 0    ; rectangle
.byte 0     ; tool
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
   sta __level_first
   lda ZP_PTR_1+1
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
   lda __level_triggers
   clc
   adc __level_trigger_offset
   sta ZP_PTR_2
   lda __level_triggers+1
   adc __level_trigger_offset+1
   sta ZP_PTR_2+1
   lda ZP_PTR_1
   sta (ZP_PTR_2)
   lda ZP_PTR_1+1
   ldy #1
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
   lda (ZP_PTR_1)
   cmp #TOOL_TRIGGER
   beq @tool_trigger
   bra @item_trigger
@tool_trigger:
   ldy #1
   lda (ZP_PTR_1),y
   ldy #7
   sta (ZP_PTR_2),y  ; set tool
   bra @next_trigger
@item_trigger:
   lda #0
   ldy #7
   sta (ZP_PTR_2),y  ; clear tool
@next_trigger:
   inc __level_num_triggers
   bra @trigger_loop

   ; intialize music
@init_music:

   ; load bitmap

   rts

__level_next_seq:

   rts

level_tick:

   rts



.endif
