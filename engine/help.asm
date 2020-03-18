.ifndef HELP_INC
HELP_INC = 1

.include "x16.inc"
.include "globals.asm"
.include "level.asm"

__help_start_ptr: .word 0
__help_row:       .byte 0

__help_show:
   lda #1
   sta help_visible
   stz VERA_ctrl
   ; disable sprites
   lda VERA_dc_video
   and #$BF
   sta VERA_dc_video
   lda __help_start_ptr
   tay
   stz HELP_PTR
   lda __help_start_ptr+1
   sta HELP_PTR+1
   lda #1
   sta __help_row
@row_loop:
   phy
   ldy __help_row
   ldx #0
   lda #1
   jsr xy2vaddr
   stz VERA_ctrl
   ora #$10
   sta VERA_addr_bank
   stx VERA_addr_low
   sty VERA_addr_high
   ply
   ldx #0
@tile_loop:
   cpx #80
   beq @next_row
   inx
   lda (HELP_PTR),y
   sta VERA_data0
   iny
   bne @tile_loop
   inc HELP_PTR+1
   bra @tile_loop
@next_row:
   inc __help_row
   lda __help_row
   cmp #START_TEXT_Y
   beq @return
   bra @row_loop
@return:
   rts

help_controls:
   lda help_controls_ptr
   sta __help_start_ptr
   lda help_controls_ptr+1
   sta __help_start_ptr+1
   jsr __help_show
   rts

help_about:
   lda help_about_ptr
   sta __help_start_ptr
   lda help_about_ptr+1
   sta __help_start_ptr+1
   jsr __help_show
   rts

help_tick:
   lda help_visible
   beq @return
   lda mouse_left_click
   beq @return
   stz help_visible
   ldy #1
   jsr tile_restore
   ; enable sprites
   lda VERA_dc_video
   ora #$40
   sta VERA_dc_video
@return:
   rts


.endif
