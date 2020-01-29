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

.macro INC_ANIM_PTR
   lda ANIM_PTR
   clc
   adc #1
   sta ANIM_PTR
   lda ANIM_PTR+1
   adc #0
   sta ANIM_PTR+1
.endmacro

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
   lda (ANIM_PTR)
   sta __sprite_idx
   INC_ANIM_PTR
   lda (ANIM_PTR)
   sta __pal_offset
   INC_ANIM_PTR
   lda #SPRITE_FRAME_SEQ_BANK
   sta RAM_BANK
   lda __sprite_idx
   jsr __get_sprite_frame_addr
   lda (ANIM_PTR) ; number of frames
   sta (ZP_PTR_1)
   tax ; words to copy = number of frames
   INC_ANIM_PTR
   ldy #1
@loop:
   cpx #0
   beq @set
   dex
   lda (ANIM_PTR)
   sta __sprite_frame
   INC_ANIM_PTR
   lda (ANIM_PTR)
   sta __sprite_frame+1
   and #FRAME_FLIP
   sta __sprite_flip
   INC_ANIM_PTR
   asl __sprite_frame   ; convert frame index to VRAM address
   rol __sprite_frame+1
   asl __sprite_frame
   rol __sprite_frame+1
   lda __sprite_frame
   sta (ZP_PTR_1),y
   iny
   lda __sprite_frame+1
   ora #(^VRAM_SPRITES << 3)
   ora __sprite_flip
   sta (ZP_PTR_1),y
   iny
   jmp @loop
@set:
   lda __sprite_idx
   jsr __sprattr     ; set the current frame to the first one
   ldy #1
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
   lda (ANIM_PTR) ; sprite index
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
   jsr __sprattr  ; clear Z-depth
   lda VERA_data0 ; ignore first 6 bytes
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda __sprite_flip
   sta VERA_data0
   rts

__anim_tiles:
   bra @start
@tilex: .byte 0
@tiley: .byte 0
@width: .byte 0
@start:
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
   rts

__anim_wait:
   lda (ANIM_PTR)
   sta __anim_waiting
   INC_ANIM_PTR
   rts

__anim_new_sprite_move:
   lda #SPRITE_MOVEMENT_BANK
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
   sta (ZP_PTR_1),y
   iny
   sta (ZP_PTR_1),y  ; delay counter
   INC_ANIM_PTR
   iny
   lda (ANIM_PTR)    ; number of frames
   sta (ZP_PTR_1),y
   INC_ANIM_PTR
   iny
   lda #0
   sta (ZP_PTR_1),y  ; frame counter (init = 0)
   iny
   lda (ANIM_PTR)    ; vector x
   sta (ZP_PTR_1),y
   INC_ANIM_PTR
   iny
   lda (ANIM_PTR)    ; vector y
   sta (ZP_PTR_1),y
   INC_ANIM_PTR
   ; two spare bytes for future use
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
   lda #SPRITE_FRAME_SEQ_BANK
   sta RAM_BANK
   lda __sprite_idx
   jsr __get_sprite_frame_addr
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
   rts

.endif
