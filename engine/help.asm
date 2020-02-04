.ifndef HELP_INC
HELP_INC = 1

__help_start_ptr: .word 0
__help_row:       .byte 0

help_controls:
   lda #1
   sta help_visible
   jsr tile_backup
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_sprreg, 0  ; disable sprites
   stz VERA_data0
   lda HELP_CTRLS_PTR
   sta __help_start_ptr
   tay
   stz HELP_CTRLS_PTR
   lda HELP_CTRLS_PTR+1
   sta __help_start_ptr+1
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
   cpx #40
   beq @next_row
   lda (HELP_CTRLS_PTR),y
   sta VERA_data0
   iny
   bne @tile_loop
   inc HELP_CTRLS_PTR+1
   bra @tile_loop
@next_row:
   inc __help_row
   lda __help_row
   cmp #START_TEXT_Y
   beq @return
   bra @row_loop
@return:
   lda __help_start_ptr
   sta HELP_CTRLS_PTR
   lda __help_start_ptr+1
   sta HELP_CTRLS_PTR+1
   rts


help_about:

   rts

help_tick:
   lda help_visible
   beq @return
   lda mouse_left_click
   beq @return
   stz help_visible
   jsr tile_restore
   VERA_SET_ADDR VRAM_sprreg, 0  ; enable sprites
   lda #$01
   sta VERA_data0
@return:
   rts


.endif
