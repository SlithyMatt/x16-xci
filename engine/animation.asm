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

NUM_SPRITES          = 128

__anim_playing:   .byte 0
__anim_waiting:   .byte 0
__anim_start:     .word 0
__anim_loops:     .byte 0
__sprite_idx:     .byte 0
__pal_offset:     .byte 0
__sprite_frame:   .word 0


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
   lda ANIM_PTR
   sta __anim_start
   lda ANIM_PTR+1
   sta __anim_start+1
   lda #1
   sta __anim_playing
   stz __anim_loops
   rts

stop_anim:
   stz __anim_playing
   rts

anim_tick:
   lda __anim_playing
   bne @check_wait
   jmp @return
@check_wait:
   lda __anim_waiting
   beq @play
   dec
   sta __anim_waiting
   beq @play
   jmp @return
@play:
   lda anim_bank
   sta RAM_BANK
   lda (ANIM_PTR)
   INC_ANIM_PTR
   cmp #SPRITE_FRAMES_KEY
   beq @sprite_frames
   cmp #SPRITE_KEY
   beq @sprite
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
   jmp @move_all_sprites
@sprite:
   jsr __anim_sprite
   jmp @move_all_sprites
@tiles:
   jsr __anim_tiles
   jmp @move_all_sprites
@wait:
   jsr __anim_wait
   jmp @return
@sprite_move:
   jsr __anim_new_sprite_move
   jmp @move_all_sprites
@end_anim:
   lda (ANIM_PTR,x)
   cmp __anim_loops
   beq @stop
   inc __anim_loops
   lda __anim_start
   sta ANIM_PTR
   lda __anim_start+1
   sta ANIM_PTR+1
   bra @return
@move_all_sprites:
   jsr __anim_move_sprites
@stop:
   jsr stop_anim
@return:
   rts

__anim_sprite_frames:
   lda (ANIM_PTR)
   sta __sprite_idx
   INC_ANIM_PTR
   lda (ANIM_PTR,x)
   sta __pal_offset
   INC_ANIM_PTR
   lda #SPRITE_FRAME_SEQ_BANK
   sta RAM_BANK
   lda __sprite_idx
   jsr __get_sprite_frame_addr
   lda (ANIM_PTR) ; number of frames
   sta (ZP_PTR_1)
   tax ; words to copy = number of frames
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
   sta VERA_data0
   lda VERA_data0 ; leave position alone
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   ; TODO put in flipping
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
   lda #0
   sta __sprite_idx
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
   sta __sprite_frame+1
   ply
   lda (ZP_PTR_2),y ; reload frame index to increment for next time
   inc
   sta (ZP_PTR_2),y
   cmp @num_frames
   bne @write
   lda #0
   sta (ZP_PTR_2),y ; go back to frame index zero next time
@write:
   lda __sprite_idx
   jsr __sprattr
   lda __sprite_frame
   sta VERA_data0
   lda __sprite_frame+1
   sta VERA_data0




@return:
   rts

.endif
