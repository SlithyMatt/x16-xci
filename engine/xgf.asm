.ifndef XGF_INC
XGF_INC = 1

.include "x16.inc"
.include "globals.asm"
.include "tilelib.asm"

XGF_STAGE_START         = $BEBE ; bank = STATE_BANK - 1
XGF_STAGE_TITLE_OFFSET  = $00
XGF_STAGE_AUTHOR_OFFSET = $20
XGF_STAGE_ZONE_OFFSET   = $40
XGF_STAGE_LEVEL_OFFSET  = $41
XGF_STAGE_MUSIC_OFFSET  = $42
XGF_STAGE_SFX_OFFSET    = $43
XGF_STAGE_INV_OFFSET    = $44
XGF_NUM_INV_QUANTS      = 127
XFG_DATA_SIZE           = $2142

XGF_PREFIX_MAX = 8

__xgf_fn:         .byte "SAVEGAME.XGF"
__xgf_ext:        .byte ".XGF"
__xgf_fn_length:  .byte 0 ; filename not set if zero
__xgf_quant:      .word 0
__xgf_state_done: .byte 0

__xgf_saveas_dialog:
.byte "                "
.byte " NAME: ________ "
.byte "                "
.byte " [CLEAR] [SAVE] "
.byte "                "

XGF_SAVEAS_X      = 12
XGF_SAVEAS_Y      = 6
XGF_SAVEAS_WIDTH  = 16
XGF_SAVEAS_HEIGHT = 5
XGF_CURSOR_X_MIN  = XGF_SAVEAS_X + 7
XGF_CURSOR_Y      = XGF_SAVEAS_Y + 1
XGF_SAVEAS_BTN_Y  = XGF_SAVEAS_Y + 3
XGF_CLEAR_X_MIN   = XGF_SAVEAS_X + 1
XGF_CLEAR_X_MAX   = XGF_CLEAR_X_MIN + 7
XGF_SAVE_X_MIN    = XGF_SAVEAS_X + 9
XGF_SAVE_X_MAX    = XGF_SAVE_X_MIN + 6
XGF_EXT_LENGTH    = 4

ASCII_UNDERSCORE  = 95

__xgf_row:        .byte 0
__xgf_cursor_x:   .byte 0

load_game:

   rts

save_game:
   lda __xgf_fn_length
   bne @save
   jsr save_game_as
   jmp @return
@save:
   lda #<XGF_STAGE_START
   sta ZP_PTR_1
   lda #>XGF_STAGE_START
   sta ZP_PTR_1+1
   lda #<RAM_CONFIG
   sta ZP_PTR_2
   lda #>RAM_CONFIG
   sta ZP_PTR_2+1
   lda #(STATE_BANK-1)
   sei
   sta RAM_BANK
   ldy #0
@title_author_loop:
   lda (ZP_PTR_2),y
   sta (ZP_PTR_1),y
   iny
   cpy #XGF_STAGE_ZONE_OFFSET
   bmi @title_author_loop
   lda zone
   sta (ZP_PTR_1),y
   iny
   lda level
   sta (ZP_PTR_1),y
   iny
   lda music_enabled
   sta (ZP_PTR_1),y
   iny
   lda sfx_enabled
   sta (ZP_PTR_1),y
   lda ZP_PTR_1
   clc
   adc #XGF_STAGE_INV_OFFSET
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   ldx #0
@inv_loop:
   phx
   txa
   jsr inv_get_quant
   stx __xgf_quant
   sty __xgf_quant+1
   pla
   tax
   asl
   tay
   lda __xgf_quant
   sta (ZP_PTR_1),y
   iny
   lda __xgf_quant+1
   sta (ZP_PTR_1),y
   inx
   cpx #XGF_NUM_INV_QUANTS
   bmi @inv_loop
   cli
   lda #KERNAL_ROM_BANK
   sta ROM_BANK
   lda #3
   ldx #DISK_DEVICE
   ldy #3
   jsr SETLFS        ; SetFileParams(LogNum=3,DevNum=DISK_DEVICE,SA=3)
   lda __xgf_fn_length
   ldx #<__xgf_fn
   ldy #>__xgf_fn
   jsr SETNAM        ; SetFileName(__xgf_fn)
   jsr OPEN
   ldx #3
   jsr CHKOUT        ; SetDefaultOutput(LogNum=3)
   stz ZP_PTR_1
   lda #>XGF_STAGE_START
   sta ZP_PTR_1+1
   lda #ZP_PTR_1
   ldy #<XGF_STAGE_START
   stz __xgf_state_done
@write_loop:
   lda (ZP_PTR_1),y
   phy
   jsr CHROUT
   ply
   iny
   bne @write_loop
   inc ZP_PTR_1+1
   lda ZP_PTR_1+1
   cmp #>(RAM_WIN+RAM_WIN_SIZE)
   bne @write_loop
   lda __xgf_state_done
   bne @close
   lda #STATE_BANK
   sta RAM_BANK
   lda #<RAM_WIN
   sta ZP_PTR_1
   lda #>RAM_WIN
   sta ZP_PTR_1+1
   lda #1
   sta __xgf_state_done
   bra @write_loop
@close:
   lda #3
   jsr CLOSE            ; CloseFile(LogNum=3)
   jsr tile_restore
@return:
   rts

save_game_as:
   lda #XGF_SAVEAS_Y
   sta __xgf_row
@row_loop:
   lda #1
   ldx #XGF_SAVEAS_X
   ldy __xgf_row
   jsr xy2vaddr
   stz VERA_ctrl
   ora #$10
   sta VERA_addr_bank
   stx VERA_addr_low
   sty VERA_addr_high
   lda __xgf_row
   sec
   sbc #XGF_SAVEAS_Y
   tax
   ldy #XGF_SAVEAS_WIDTH
   jsr byte_mult
   tax
   ldy #XGF_SAVEAS_WIDTH
@tile_loop:
   lda __xgf_saveas_dialog,x
   sta VERA_data0
   lda #(MENU_PO << 4)
   sta VERA_data0
   inx
   dey
   bne @tile_loop
   inc __xgf_row
   lda __xgf_row
   cmp #(XGF_SAVEAS_Y+XGF_SAVEAS_HEIGHT)
   bne @row_loop
   lda #XGF_CURSOR_X_MIN
   sta __xgf_cursor_x
   lda #1
   sta saveas_visible
   stz __xgf_fn_length
   rts

xgf_tick:
   lda saveas_visible
   beq @check_load
   jsr __xgf_saveas_tick
   bra @return
@check_load:
   lda load_visible
   beq @return
   jsr __xgf_load_tick
@return:
   rts

__xgf_saveas_tick:
   ldx __xgf_cursor_x
   cpx #(XGF_CURSOR_X_MIN+XGF_PREFIX_MAX)
   bpl @return
   ldy #XGF_CURSOR_Y
   lda #1
   jsr xy2vaddr
   stz VERA_ctrl
   ora #$10
   sta VERA_addr_bank
   stx VERA_addr_low
   sty VERA_addr_high
   jsr GETIN
   cmp #0
   beq @cursor
   sta VERA_data0
   ldx __xgf_fn_length
   sta __xgf_fn,x
   lda #(MENU_PO << 4)
   sta VERA_data0
   inc __xgf_fn_length
   inc __xgf_cursor_x
   lda __xgf_cursor_x
   cmp #(XGF_CURSOR_X_MIN+XGF_PREFIX_MAX)
   beq @check_saveas_click
@cursor:
   lda #ASCII_UNDERSCORE
   sta VERA_data0
   lda frame_num
   cmp #30
   bmi @show_cursor
   lda #(MENU_PO << 4)
   sta VERA_data0
   bra @check_saveas_click
@show_cursor:
   lda #(BLACK_PO << 4)
   sta VERA_data0
@check_saveas_click:
   lda mouse_left_click
   beq @return
   lda mouse_tile_y
   cmp #XGF_SAVEAS_BTN_Y
   bne @return
   lda mouse_tile_x
   cmp #XGF_CLEAR_X_MIN
   bmi @return
   cmp #XGF_CLEAR_X_MAX
   bmi @clear
   cmp #XGF_SAVE_X_MIN
   bmi @return
   cmp #XGF_SAVE_X_MAX
   bpl @return
   jsr __xgf_save_btn_click
   bra @return
@clear:
   jsr __xgf_clear_btn_click
   bra @return
@return:
   rts

__xgf_save_btn_click:
   lda __xgf_fn_length
   beq @return
   tax
   ldy #0
@loop:
   lda __xgf_ext,y
   sta __xgf_fn,x
   inc __xgf_fn_length
   inx
   iny
   cpy #XGF_EXT_LENGTH
   bmi @loop
   jsr save_game
   stz saveas_visible
@return:
   rts

__xgf_clear_btn_click:
   stz __xgf_fn_length
   lda #1
   ldx #XGF_CURSOR_X_MIN
   ldy #XGF_CURSOR_Y
   jsr xy2vaddr
   stz VERA_ctrl
   ora #$10
   sta VERA_addr_bank
   stx VERA_addr_low
   sty VERA_addr_high
   ldx #XGF_PREFIX_MAX
@loop:
   lda #ASCII_UNDERSCORE
   sta VERA_data0
   lda #(MENU_PO << 4)
   sta VERA_data0
   dex
   bne @loop
   lda #XGF_CURSOR_X_MIN
   sta __xgf_cursor_x
   rts

__xgf_load_tick:

   rts

.endif
