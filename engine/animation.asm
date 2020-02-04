.ifndef ANIMATION_INC
ANIMATION_INC = 1

.include "x16.inc"
.include "globals.asm"
.include "tilelib.asm"

SPRITE_FRAMES_KEY    = 40
SPRITE_KEY           = 41
TILES_KEY            = 42
WAIT_KEY             = 43
SPRITE_MOVE_KEY      = 44
END_ANIM_KEY         = 56
SPRITE_HIDE_KEY      = 57
TEXT_LINE            = 60
SCROLL_KEY           = 61
LINE_SKIP            = 62
CLEAR_TEXT           = 63
GO_LEVEL             = 64
IF_STATE             = 67
IF_NOT_STATE         = 68
END_IF               = 69
SET_STATE            = 70
CLEAR_STATE          = 71
GET_ITEM             = 72
GIF_START            = 73
GIF_PAUSE            = 74
GIF_FRAME            = 75

NUM_SPRITES          = 128

FRAME_FLIP           = $C0
FRAME_FLIP_MASK      = $3F
SPRITE_Z             = $0C
SPRITE_Z_MASK        = $F3
SPRITE_DIM           = $50

anim_seq_done:    .byte 0
__anim_playing:   .byte 0
__anim_waiting:   .byte 0
__sprite_idx:     .byte 0
__pal_offset:     .byte 0
__sprite_frame:   .word 0
__sprite_flip:    .byte 0
__sprite_x:       .word 0
__sprite_y:       .byte 0
__vec_x:          .byte 0
__vec_y:          .byte 0

TEXT_LINE_0 = VRAM_TILEMAP + 64*2*26 + 2
TEXT_LINE_1 = TEXT_LINE_0 + 64*2
TEXT_LINE_2 = TEXT_LINE_1 + 64*2
TEXT_LINE_3 = TEXT_LINE_2 + 64*2

TEXT_LINE_LENGTH  = 38

VRAM_TILEMAP_BANK = $10 | ^VRAM_TILEMAP
__anim_text_addr:
.word TEXT_LINE_0 & $FFFF
.word TEXT_LINE_1 & $FFFF
.word TEXT_LINE_2 & $FFFF
.word TEXT_LINE_3 & $FFFF
__anim_text_line: .byte 0


.macro INC_ANIM_PTR
   lda ANIM_PTR
   clc
   adc #1
   sta ANIM_PTR
   lda ANIM_PTR+1
   adc #0
   sta ANIM_PTR+1
.endmacro

anim_reset:
   lda #SPRITE_FRAME_SEQ_BANK
   jsr reset_bank
   lda #SPRITE_MOVEMENT_BANK
   jsr reset_bank
   stz anim_seq_done
   stz __anim_waiting
   stz __anim_text_line
   rts

start_anim:
   lda #1
   sta __anim_playing
   rts

stop_anim:
   stz __anim_playing
   rts

anim_tick:
   lda __anim_playing
   bne @check_done
   jmp @return
@check_done:
   lda anim_seq_done
   beq @check_wait
   jmp @move_all_sprites
@check_wait:
   lda __anim_waiting
   beq @play
   dec
   sta __anim_waiting
   beq @play
   jmp @move_all_sprites
@play:
   lda anim_bank
   sta RAM_BANK
   lda (ANIM_PTR)
   pha
   INC_ANIM_PTR
   pla
   cmp #SPRITE_FRAMES_KEY
   beq @sprite_frames
   cmp #SPRITE_KEY
   beq @sprite
   cmp #SPRITE_HIDE_KEY
   beq @sprite_hide
   cmp #TILES_KEY
   beq @tiles
   cmp #WAIT_KEY
   beq @wait
   cmp #SPRITE_MOVE_KEY
   beq @sprite_move
   cmp #TEXT_LINE
   beq @text_line
   cmp #SCROLL_KEY
   beq @scroll
   cmp #LINE_SKIP
   beq @line_skip
   cmp #CLEAR_TEXT
   beq @clear_text
   cmp #GO_LEVEL
   beq @go_level
   cmp #IF_STATE
   beq @if_state
   cmp #IF_NOT_STATE
   beq @if_not_state
   cmp #END_IF
   beq @play
   cmp #SET_STATE
   beq @set_state
   cmp #CLEAR_STATE
   beq @clear_state
   cmp #GET_ITEM
   beq @get_item
   cmp #GIF_START
   beq @gif_start
   cmp #GIF_PAUSE
   beq @gif_pause
   cmp #GIF_FRAME
   beq @gif_frame
   cmp #END_ANIM_KEY
   beq @end_anim
   jmp @stop ; unrecognized key, just stop
@sprite_frames:
   jsr __anim_sprite_frames
   jmp @play
@sprite:
   jsr __anim_sprite
   jmp @play
@sprite_hide:
   jsr __anim_sprite_hide
   jmp @play
@tiles:
   jsr __anim_tiles
   jmp @play
@wait:
   jsr __anim_wait
   jmp @move_all_sprites
@sprite_move:
   jsr __anim_new_sprite_move
   jmp @play
@text_line:
   jsr __anim_text_instruction
   jmp @play
@scroll:
   jsr __anim_scroll_instruction
   jmp @play
@line_skip:
   jsr __anim_line_skip
   jmp @play
@clear_text:
   jsr __anim_clear_text
   jmp @play
@go_level:
   jsr __anim_go_level
   jmp @return
@if_state:
   jsr __anim_if
   jmp @play
@if_not_state:
   jsr __anim_if_not
   jmp @play
@set_state:
   jsr __anim_set_state
   jmp @play
@clear_state:
   jsr __anim_clear_state
   jmp @play
@get_item:
   jsr __anim_get_item
   jmp @play
@gif_start:
   lda #2
   sta GIF_ctrl
   jmp @play
@gif_pause:
   lda #0
   sta GIF_ctrl
   jmp @play
@gif_frame:
   lda #1
   sta GIF_ctrl
   jmp @play
@end_anim:
   lda #1
   sta anim_seq_done
@move_all_sprites:
   jsr __anim_move_sprites
   bra @return
@stop:
   jsr stop_anim
@return:
   rts

__anim_sprite_frames:
   lda anim_bank
   sta RAM_BANK
   lda (ANIM_PTR)
   sta __sprite_idx
   INC_ANIM_PTR
   lda (ANIM_PTR)
   sta __pal_offset
   INC_ANIM_PTR
   lda __sprite_idx
   jsr __get_sprite_frame_addr
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ANIM_PTR) ; number of frames
   cli
   pha
   lda #SPRITE_FRAME_SEQ_BANK
   sei
   sta RAM_BANK
   pla
   sta (ZP_PTR_1)
   cli
   tax ; words to copy = number of frames
   INC_ANIM_PTR
   ldy #1
@loop:
   cpx #0
   beq @set
   dex
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ANIM_PTR)
   sta __sprite_frame
   INC_ANIM_PTR
   lda (ANIM_PTR)
   cli
   sta __sprite_frame+1
   and #FRAME_FLIP
   sta __sprite_flip
   INC_ANIM_PTR
   asl __sprite_frame   ; convert frame index to VRAM address
   rol __sprite_frame+1
   asl __sprite_frame
   rol __sprite_frame+1
   lda #SPRITE_FRAME_SEQ_BANK
   sei
   sta RAM_BANK
   lda __sprite_frame
   sta (ZP_PTR_1),y
   iny
   lda __sprite_frame+1
   ora #(^VRAM_SPRITES << 3)
   ora __sprite_flip
   sta (ZP_PTR_1),y
   cli
   iny
   jmp @loop
@set:
   lda __sprite_idx
   jsr __sprattr     ; set the current frame to the first one
   ldy #1
   lda #SPRITE_FRAME_SEQ_BANK
   sei
   sta RAM_BANK
   lda (ZP_PTR_1),y
   sta VERA_data0
   iny
   lda (ZP_PTR_1),y
   and #FRAME_FLIP_MASK
   sta VERA_data0
   lda VERA_data0 ; leave position alone
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda (ZP_PTR_1),y
   cli
   and #FRAME_FLIP
   asl
   rol
   rol
   ora VERA_data0 ; add flipping to current Z-depth
   sta __sprite_flip
   lda __sprite_idx
   jsr __sprattr  ; write flipping back
   lda VERA_data0 ; ignore first 6 bytes
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda __sprite_flip
   sta VERA_data0
   lda __pal_offset
   ora #SPRITE_DIM
   sta VERA_data0
   rts

__get_sprite_frame_addr:   ; Input: A - sprite index (0-127)
                           ; Output: ZP_PTR_1 - address of frame sequence
   sta ZP_PTR_1
   stz ZP_PTR_1+1
   ; multiply sprite index by 64 (2^6) to get offset
   asl ZP_PTR_1
   rol ZP_PTR_1+1
   asl ZP_PTR_1
   rol ZP_PTR_1+1
   asl ZP_PTR_1
   rol ZP_PTR_1+1
   asl ZP_PTR_1
   rol ZP_PTR_1+1
   asl ZP_PTR_1
   rol ZP_PTR_1+1
   asl ZP_PTR_1
   rol ZP_PTR_1+1
   clc
   lda ZP_PTR_1
   ; add offset to beginning of banked RAM window
   adc #<RAM_WIN
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #>RAM_WIN
   sta ZP_PTR_1+1
   rts

__sprattr:  ; A: sprite index
   stz VERA_ctrl
   pha
   asl
   asl
   asl
   sta VERA_addr_low
   pla
   lsr
   lsr
   lsr
   lsr
   lsr
   ora #>VRAM_sprattr
   sta VERA_addr_high
   lda #(^VRAM_sprattr | $10)
   sta VERA_addr_bank
   rts

__anim_sprite:
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ANIM_PTR) ; sprite index
   jsr __sprattr
   lda VERA_data0 ; use current frame for now
   lda VERA_data0
   INC_ANIM_PTR
   lda (ANIM_PTR) ; x[0]
   sta VERA_data0
   INC_ANIM_PTR
   lda (ANIM_PTR) ; x[1]
   sta VERA_data0
   INC_ANIM_PTR
   lda (ANIM_PTR) ; y[0]
   cli
   sta VERA_data0
   INC_ANIM_PTR
   stz VERA_data0 ; y[1] = 0 since max y = 240
   lda VERA_data0 ; get current flipping
   ora #SPRITE_Z
   sta __sprite_flip
   lda __sprite_idx
   jsr __sprattr  ; now show sprite by including Z-depth
   lda VERA_data0 ; ignore first 6 bytes
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda __sprite_flip
   sta VERA_data0
   rts

__anim_sprite_hide:
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ANIM_PTR) ; sprite index
   cli
   sta __sprite_idx
   jsr __sprattr  ; load current sprite flipping
   lda VERA_data0 ; ignore first 6 bytes
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   and #SPRITE_Z_MASK
   sta __sprite_flip
   lda __sprite_idx
   jsr __sprattr  ; clear Z-depth
   lda VERA_data0 ; ignore first 6 bytes
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda __sprite_flip
   sta VERA_data0
   INC_ANIM_PTR
   lda __sprite_idx              ; stop any current animation
   sta ZP_PTR_1
   stz ZP_PTR_1+1
   asl ZP_PTR_1
   rol ZP_PTR_1+1
   asl ZP_PTR_1
   rol ZP_PTR_1+1
   asl ZP_PTR_1
   rol ZP_PTR_1+1
   lda ZP_PTR_1
   clc
   adc #<RAM_WIN
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #>RAM_WIN
   sta ZP_PTR_1+1
   lda #SPRITE_MOVEMENT_BANK
   sei
   sta RAM_BANK
   lda #0
   sta (ZP_PTR_1)
   cli
   rts

__anim_tiles:
   bra @start
@tilex: .byte 0
@tiley: .byte 0
@width: .byte 0
@start:
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ANIM_PTR)
   sta @tilex
   INC_ANIM_PTR
   lda (ANIM_PTR)
   sta @tiley
   INC_ANIM_PTR
   lda (ANIM_PTR)
   sta @width
   INC_ANIM_PTR
   lda #1
   ldx @tilex
   ldy @tiley
   jsr xy2vaddr
   stz VERA_ctrl
   ora #$10
   sta VERA_addr_bank
   stx VERA_addr_low
   sty VERA_addr_high
   lda @width
   asl
   tax ; copy width x 2 bytes to VRAM
@loop:
   cpx #0
   beq @return
   dex
   lda (ANIM_PTR)
   sta VERA_data0
   INC_ANIM_PTR
   bra @loop
@return:
   cli
   rts

__anim_wait:
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ANIM_PTR)
   cli
   sta __anim_waiting
   INC_ANIM_PTR
   rts

__anim_new_sprite_move:
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ANIM_PTR)
   sta __sprite_idx
   INC_ANIM_PTR
   lda __sprite_idx  ; store to 8 x sprite index offset in window
   sta ZP_PTR_1
   stz ZP_PTR_1+1
   asl ZP_PTR_1
   rol ZP_PTR_1+1
   asl ZP_PTR_1
   rol ZP_PTR_1+1
   asl ZP_PTR_1
   rol ZP_PTR_1+1
   lda ZP_PTR_1
   clc
   adc #<RAM_WIN
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #>RAM_WIN
   sta ZP_PTR_1+1
   ldy #0
   lda (ANIM_PTR)    ; frame delay
   dec
   pha
   lda #SPRITE_MOVEMENT_BANK
   sta RAM_BANK
   pla
   sta (ZP_PTR_1),y
   iny
   sta (ZP_PTR_1),y  ; delay counter
   INC_ANIM_PTR
   iny
   lda anim_bank
   sta RAM_BANK
   lda (ANIM_PTR)    ; number of frames
   pha
   lda #SPRITE_MOVEMENT_BANK
   sta RAM_BANK
   pla
   sta (ZP_PTR_1),y
   INC_ANIM_PTR
   iny
   lda #0
   sta (ZP_PTR_1),y  ; frame counter (init = 0)
   iny
   lda anim_bank
   sta RAM_BANK
   lda (ANIM_PTR)    ; vector x
   pha
   lda #SPRITE_MOVEMENT_BANK
   sta RAM_BANK
   pla
   sta (ZP_PTR_1),y
   INC_ANIM_PTR
   iny
   lda anim_bank
   sta RAM_BANK
   lda (ANIM_PTR)    ; vector y
   pha
   lda #SPRITE_MOVEMENT_BANK
   sta RAM_BANK
   pla
   sta (ZP_PTR_1),y
   INC_ANIM_PTR
   ; two spare bytes for future use
   cli
   rts

__anim_text_instruction:
   bra @start
@byte2: .byte 0
@start:
   lda tb_visible
   ora inv_visible
   bne @return       ; text field blocked
   lda __anim_text_line
   cmp #4
   bmi @print
   lda #1
   jsr __anim_scroll
@print:
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ANIM_PTR)
   clc
   adc #MENU_PO
   asl
   asl
   asl
   asl
   sta @byte2
   stz VERA_ctrl
   lda #VRAM_TILEMAP_BANK
   sta VERA_addr_bank
   lda __anim_text_line
   asl
   tax
   lda __anim_text_addr,x
   sta VERA_addr_low
   inx
   lda __anim_text_addr,x
   inx
   sta VERA_addr_high
   INC_ANIM_PTR
   ldx #TEXT_LINE_LENGTH
@loop:
   lda (ANIM_PTR)
   sta VERA_data0
   lda @byte2
   sta VERA_data0
   INC_ANIM_PTR
   dex
   bne @loop
   cli
   inc __anim_text_line
@return:
   rts

__anim_scroll: ; A: lines to scroll
   bra @start
@lines: .byte 0
@start:
   sta @lines
   cmp #0
   bne @check_clear
   jmp @return
@check_clear:
   cmp __anim_text_line
   bmi @start_scroll
   jmp @clear
@start_scroll:
   ldx #0
   lda __anim_text_line
   sec
   sbc @lines
   sta __anim_text_line
   tay
@scroll_line_loop:
   cpy #0
   beq @clear_lines
   stz VERA_ctrl
   lda #VRAM_TILEMAP_BANK
   sta VERA_addr_bank
   phx
   txa
   asl
   tax
   lda __anim_text_addr,x
   sta VERA_addr_low
   inx
   lda __anim_text_addr,x
   sta VERA_addr_high
   pla
   pha
   clc
   adc @lines
   asl
   tax
   lda #1
   sta VERA_ctrl
   lda #VRAM_TILEMAP_BANK
   sta VERA_addr_bank
   lda __anim_text_addr,x
   sta VERA_addr_low
   inx
   lda __anim_text_addr,x
   sta VERA_addr_high
   ldx #0
@scroll_data_loop:
   lda VERA_data1
   sta VERA_data0
   inx
   cpx #(TEXT_LINE_LENGTH*2)
   bne @scroll_data_loop
   plx
   inx
   dey
   jmp @scroll_line_loop
@clear_lines:
   lda __anim_text_line    ; clear current line and all below
   asl
   tax
@clear_line_loop:
   stz VERA_ctrl
   lda #VRAM_TILEMAP_BANK
   sta VERA_addr_bank
   lda __anim_text_addr,x
   sta VERA_addr_low
   inx
   lda __anim_text_addr,x
   sta VERA_addr_high
   inx
   ldy #(TEXT_LINE_LENGTH*2)
@clear_data_loop:
   stz VERA_data0
   dey
   bne @clear_data_loop
   cpx #8
   bmi @clear_line_loop
   bra @return
@clear:
   jsr __anim_clear_text
@return:
   rts

__anim_scroll_instruction:
   lda tb_visible
   ora inv_visible
   bne @return       ; text field blocked
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ANIM_PTR)
   cli
   jsr __anim_scroll
   INC_ANIM_PTR
@return:
   rts

__anim_line_skip:
   lda tb_visible
   ora inv_visible
   bne @return       ; text field blocked
   inc __anim_text_line
   cmp #4
   bne @return
   lda #1
   jsr __anim_scroll
@return:
   rts

__anim_clear_text:
   stz __anim_text_line
   lda tb_visible
   ora inv_visible
   bne @return       ; text field blocked
   stz VERA_ctrl
   VERA_SET_ADDR TEXT_LINE_0, 1
   ldx #(TEXT_LINE_LENGTH*2)
@loop0:
   stz VERA_data0
   dex
   bne @loop0
   VERA_SET_ADDR TEXT_LINE_1, 1
   ldx #(TEXT_LINE_LENGTH*2)
@loop1:
   stz VERA_data0
   dex
   bne @loop1
   VERA_SET_ADDR TEXT_LINE_2, 1
   ldx #(TEXT_LINE_LENGTH*2)
@loop2:
   stz VERA_data0
   dex
   bne @loop2
   VERA_SET_ADDR TEXT_LINE_3, 1
   ldx #(TEXT_LINE_LENGTH*2)
@loop3:
   stz VERA_data0
   dex
   bne @loop3
@return:
   rts

__anim_go_level:
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ANIM_PTR)
   cmp zone
   beq @level
   sta zone
   jsr load_zone
@level:
   INC_ANIM_PTR
   lda (ANIM_PTR)
   cli
   sta level
   lda #1
   sta req_load_level
   stz __anim_text_line
   INC_ANIM_PTR
   rts

__anim_if:
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ANIM_PTR)
   tax
   INC_ANIM_PTR
   lda (ANIM_PTR)
   cli
   tay
   INC_ANIM_PTR
   jsr get_state
   cmp #0
   bne @return ; state is set, just continue executing after IF
   jsr __anim_seek_endif
@return:
   rts

__anim_if_not:
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ANIM_PTR)
   tax
   INC_ANIM_PTR
   lda (ANIM_PTR)
   cli
   tay
   INC_ANIM_PTR
   jsr get_state
   cmp #0
   beq @return ; state is clear, just continue executing after IF_NOT
   jsr __anim_seek_endif
@return:
   rts

__anim_seek_endif:
   bra @start
@depth: .byte 0
@start:
   stz @depth
   lda anim_bank
   sei
   sta RAM_BANK
@loop:
   lda (ANIM_PTR)
   cmp #END_IF
   beq @check_depth
   cmp #IF_STATE
   beq @level_down
   cmp #IF_NOT_STATE
   beq @level_down
   bra @next
@level_down:
   inc @depth
   bra @next
@check_depth:
   lda @depth
   beq @return
   dec @depth
@next:
   jsr __anim_seek_next_instruction
   bra @loop
@return:
   jsr __anim_seek_next_instruction
   cli
   rts

__anim_seek_next_instruction:
   ; Requires: animation RAM bank selected and interrupts disabled
   lda (ANIM_PTR)
   cmp #SPRITE_FRAMES_KEY
   beq @sprite_frames
   cmp #SPRITE_KEY
   beq @seek5
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
   beq @seek2
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
   lda ANIM_PTR
   clc
   adc #3
   sta ANIM_PTR
   lda ANIM_PTR+1
   adc #0
   sta ANIM_PTR+1
   lda (ANIM_PTR)
   asl
   clc
   adc ANIM_PTR
   sta ANIM_PTR
   lda ANIM_PTR+1
   adc #0
   sta ANIM_PTR+1
   bra @return
@seek40:
   lda ANIM_PTR
   clc
   adc #40
   sta ANIM_PTR
   lda ANIM_PTR+1
   adc #0
   sta ANIM_PTR+1
   bra @return
@seek6:
   INC_ANIM_PTR
@seek5:
   INC_ANIM_PTR
@seek4:
   INC_ANIM_PTR
@seek3:
   INC_ANIM_PTR
@seek2:
   INC_ANIM_PTR
@seek1:
   INC_ANIM_PTR
@return:
   rts

__anim_set_state:
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ANIM_PTR)
   tax
   INC_ANIM_PTR
   lda (ANIM_PTR)
   cli
   tay
   INC_ANIM_PTR
   lda #1
   jsr set_state
   rts

__anim_clear_state:
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ANIM_PTR)
   tax
   INC_ANIM_PTR
   lda (ANIM_PTR)
   cli
   tay
   INC_ANIM_PTR
   lda #0
   jsr set_state
   rts

__anim_get_item:
   lda anim_bank
   sei
   sta RAM_BANK
   lda (ANIM_PTR)
   pha
   INC_ANIM_PTR
   lda (ANIM_PTR)
   tax
   INC_ANIM_PTR
   lda (ANIM_PTR)
   cli
   tay
   pla
   jsr inv_add_item
   INC_ANIM_PTR
   rts

__anim_move_sprites:
   bra @start
@frame_idx: .byte 0
@num_frames: .byte 0
@start:
   stz __sprite_idx
   lda #<RAM_WIN
   sta ZP_PTR_2
   lda #>RAM_WIN
   sta ZP_PTR_2+1
   sei
@loop:
   inc __sprite_idx
   lda __sprite_idx
   cmp #NUM_SPRITES
   bne @check_moving
   jmp @return
@check_moving:
   lda #SPRITE_MOVEMENT_BANK
   sta RAM_BANK
   lda ZP_PTR_2   ; increment ZP_PTR_2 to next sprite movement
   clc
   adc #8
   sta ZP_PTR_2
   lda ZP_PTR_2+1
   adc #0
   sta ZP_PTR_2+1
   lda (ZP_PTR_2)
   bne @check_delay
   jmp @loop
@check_delay:
   ldy #1
   lda (ZP_PTR_2),y
   beq @move
   dec
   sta (ZP_PTR_2),y
   jmp @loop
@move:
   lda (ZP_PTR_2)
   sta (ZP_PTR_2),y  ; reset delay counter to initial value
   iny
   lda (ZP_PTR_2),y  ; number of frames to move
   dec
   sta (ZP_PTR_2),y
   bne @load
   lda #0
   sta (ZP_PTR_2)    ; this will be the last frame
@load:
   iny
   phy
   lda (ZP_PTR_2),y  ; frame index
   asl
   inc
   pha
   iny
   lda (ZP_PTR_2),y
   sta __vec_x
   iny
   lda (ZP_PTR_2),y
   sta __vec_y
   lda __sprite_idx
   jsr __get_sprite_frame_addr
   lda #SPRITE_FRAME_SEQ_BANK
   sta RAM_BANK
   lda (ZP_PTR_1)
   sta @num_frames
   ply
   lda (ZP_PTR_1),y
   sta __sprite_frame
   iny
   lda (ZP_PTR_1),y
   and #FRAME_FLIP_MASK
   sta __sprite_frame+1
   lda (ZP_PTR_1),y
   and #FRAME_FLIP
   asl
   rol
   rol
   ora #SPRITE_Z
   sta __sprite_flip
   lda #SPRITE_MOVEMENT_BANK
   sta RAM_BANK
   ply
   lda (ZP_PTR_2),y ; reload frame index to increment for next time
   inc
   sta (ZP_PTR_2),y
   cmp @num_frames
   bne @read
   lda #0
   sta (ZP_PTR_2),y ; go back to frame index zero next time
@read:
   lda __sprite_idx
   jsr __sprattr
   lda VERA_data0 ; ignore - only position is needed
   lda VERA_data0 ; ignore - only position is needed
   lda VERA_data0
   sta __sprite_x
   lda VERA_data0
   sta __sprite_x+1
   lda VERA_data0
   sta __sprite_y
   ; apply vector
   lda __vec_x
   bmi @neg_x
   clc
   adc __sprite_x
   sta __sprite_x
   lda __sprite_x+1
   adc #0
   sta __sprite_x+1
   bra @check_y
@neg_x:
   lda #0
   sec
   sbc __vec_x
   sta __vec_x
   lda __sprite_x
   sec
   sbc __vec_x
   sta __sprite_x
   lda __sprite_x+1
   sbc #0
   sta __sprite_x+1
@check_y:
   lda __vec_y
   bmi @neg_y
   clc
   adc __sprite_y
   sta __sprite_y
   bra @write
@neg_y:
   lda #0
   sec
   sbc __vec_y
   sta __vec_y
   lda __sprite_y
   sec
   sbc __vec_y
   sta __sprite_y
@write:
   lda __sprite_idx
   jsr __sprattr
   lda __sprite_frame
   sta VERA_data0
   lda __sprite_frame+1
   sta VERA_data0
   lda __sprite_x
   sta VERA_data0
   lda __sprite_x+1
   sta VERA_data0
   lda __sprite_y
   sta VERA_data0
   stz VERA_data0
   lda __sprite_flip
   sta VERA_data0
@return:
   cli
   rts

.endif
