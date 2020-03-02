.ifndef XGF_INC
XGF_INC = 1

.include "x16.inc"
.include "globals.asm"
.include "tilelib.asm"

XGF_STAGE_START         = $BEBE ; bank = STATE_BANK
XGF_STAGE_TITLE_OFFSET  = $00
XGF_STAGE_AUTHOR_OFFSET = $20
XGF_STAGE_ZONE_OFFSET   = $40
XGF_STAGE_LEVEL_OFFSET  = $41
XGF_STAGE_MUSIC_OFFSET  = $42
XGF_STAGE_SFX_OFFSET    = $43
XGF_STAGE_INV_OFFSET    = $44
XGF_NUM_INV_QUANTS      = 127

XGF_PREFIX_MAX = 8

__xgf_fn:         .byte "SAVEGAME.XGF"
__xgf_ext:        .byte ".XGF"
__xgf_fn_length:  .byte 0 ; filename not set if zero
__xgf_quant:      .word 0
__xgf_state_done: .byte 0

__xgf_dir_fn:     .byte "XGFDIR.BIN"
__end_xgf_dir_fn:

__xgf_saveas_dialog:
.byte "                "
.byte " NAME: ________ "
.byte "                "
.byte " [CLEAR] [SAVE] "
.byte "                "

__xgf_load_lengths:  .byte 0,0,0,0,0,0,0,0
__xgf_load_num: .byte 0
__xgf_load_dialog:
.byte "                      "
.byte " Select File to Load: "
.byte " -------------------- "
.byte "           |          "
.byte "           |          "
.byte "           |          "
.byte "           |          "
.byte " -------------------- "
.byte "                      "


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
XGF_LOAD_X        = 9
XGF_LOAD_Y        = 9
XGF_LOAD_WIDTH    = 22
XGF_LOAD_HEIGHT   = 9
XGF_LOAD_L_X_MIN  = XGF_LOAD_X + 2
XGF_LOAD_L_X_MAX  = XGF_LOAD_L_X_MIN + XGF_PREFIX_MAX
XGF_LOAD_R_X_MIN  = XGF_LOAD_X + 13
XGF_LOAD_R_X_MAX  = XGF_LOAD_R_X_MIN + XGF_PREFIX_MAX
XGF_LOAD_Y_MIN    = XGF_LOAD_Y + 3
XGF_LOAD_Y_MAX    = XGF_LOAD_Y_MIN + 4
XGF_MAX_FILES     = 8

XGF_NUM_FILES     = XGF_STAGE
XGF_FN0_LENGTH    = XGF_STAGE+1
XGF_FN0           = XGF_FN0_LENGTH+1
XGF_MAX_FN_LEN    = XGF_PREFIX_MAX+XGF_EXT_LENGTH

__xgf_dir_fns:
   .byte 0, XGF_MAX_FN_LEN+1, XGF_MAX_FN_LEN*2+1, XGF_MAX_FN_LEN*3+1
   .byte XGF_MAX_FN_LEN*4+1, XGF_MAX_FN_LEN*5+1, XGF_MAX_FN_LEN*6+1, XGF_MAX_FN_LEN*7+1

XGF_DIR_FILE_LENGTH  = 1 + (1 + XGF_MAX_FN_LEN) * XGF_MAX_FILES


ASCII_UNDERSCORE  = 95

__xgf_row:        .byte 0
__xgf_cursor_x:   .byte 0

load_game:
   lda #XGF_LOAD_Y
   sta __xgf_row
@row_loop:
   lda #1
   ldx #XGF_LOAD_X
   ldy __xgf_row
   jsr xy2vaddr
   stz VERA_ctrl
   ora #$10
   sta VERA_addr_bank
   stx VERA_addr_low
   sty VERA_addr_high
   lda __xgf_row
   sec
   sbc #XGF_LOAD_Y
   tax
   ldy #XGF_LOAD_WIDTH
   jsr byte_mult
   tax
   ldy #XGF_LOAD_WIDTH
@tile_loop:
   lda __xgf_load_dialog,x
   sta VERA_data0
   lda #(MENU_PO << 4)
   sta VERA_data0
   inx
   dey
   bne @tile_loop
   inc __xgf_row
   lda __xgf_row
   cmp #(XGF_LOAD_Y+XGF_LOAD_HEIGHT)
   bne @row_loop
   lda #1
   sta load_visible
   jsr load_xgf_dir
   lda #XGF_LOAD_Y_MIN
   sta __xgf_row
   ldx XGF_NUM_FILES
@file_loop:
   cpx #0
   beq @return
   phx
   txa
   ldy __xgf_row
   bit #$01
   bne @right_col
   ldx XGF_LOAD_L_X_MIN
   bra @print
@right_col:
   ldx XGF_LOAD_R_X_MIN
   inc __xgf_row
@print:
   lda #1
   jsr xy2vaddr
   stz VERA_ctrl
   ora #$20 ; stride = 2 to only replace tile indices
   sta VERA_addr_bank
   stx VERA_addr_low
   sty VERA_addr_high
   plx
   phx
   ldy __xgf_dir_fns,x
   ldx XGF_FN0_LENGTH,y
@char_loop:
   lda XGF_FN0,y
   sta VERA_data0
   iny
   dex
   bne @char_loop
   plx
   dex
   bra @file_loop
@return:
   rts

load_xgf_dir:
   lda #KERNAL_ROM_BANK
   sta ROM_BANK
   lda #1
   ldx #DISK_DEVICE
   ldy #0
   jsr SETLFS        ; SetFileParams(LogNum=1,DevNum=DISK_DEVICE,SA=0)
   lda #(__end_xgf_dir_fn-__xgf_dir_fn)
   ldx #<__xgf_dir_fn
   ldy #>__xgf_dir_fn
   jsr SETNAM        ; SetFileName(__xgf_fn)
   lda #0
   ldx #<XGF_STAGE
   ldy #>XGF_STAGE
   jsr LOAD
   bcc @return
   stz XGF_NUM_FILES ; assume no files defined
@return:
   rts

save_game:
   lda __xgf_fn_length
   bne @save
   jsr save_game_as
   jmp @return
@save:
   lda #<XGF_STAGE_START
   sta ZP_PTR_3
   lda #>XGF_STAGE_START
   sta ZP_PTR_3+1
   lda #<RAM_CONFIG
   sta ZP_PTR_2
   lda #>RAM_CONFIG
   sta ZP_PTR_2+1
   lda #STATE_BANK
   sta RAM_BANK
   ldy #0
@title_author_loop:
   lda (ZP_PTR_2),y
   sta (ZP_PTR_3),y
   iny
   cpy #XGF_STAGE_ZONE_OFFSET
   bmi @title_author_loop
   lda zone
   sta (ZP_PTR_3),y
   iny
   lda level
   sta (ZP_PTR_3),y
   iny
   lda music_enabled
   sta (ZP_PTR_3),y
   iny
   lda sfx_enabled
   sta (ZP_PTR_3),y
   lda ZP_PTR_3
   clc
   adc #XGF_STAGE_INV_OFFSET
   sta ZP_PTR_3
   lda ZP_PTR_3+1
   adc #0
   sta ZP_PTR_3+1
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
   sta (ZP_PTR_3),y
   iny
   lda __xgf_quant+1
   sta (ZP_PTR_3),y
   inx
   cpx #XGF_NUM_INV_QUANTS
   bmi @inv_loop

   ; Can't save direct from banked RAM, so copying to low RAM for now
   lda #<RAM_WIN
   sta ZP_PTR_2
   lda #>RAM_WIN
   sta ZP_PTR_2+1
   lda #<XGF_STAGE
   sta ZP_PTR_3
   lda #>XGF_STAGE
   sta ZP_PTR_3+1
   ldx #0
   ldy #0
@loop:
   lda (ZP_PTR_2),y
   sta (ZP_PTR_3),y
   iny
   bne @loop
   inc ZP_PTR_2+1
   inc ZP_PTR_3+1
   inx
   cpx #>RAM_WIN_SIZE
   bmi @loop

   lda #KERNAL_ROM_BANK
   sta ROM_BANK
   lda #1
   ldx #DISK_DEVICE
   ldy #0
   jsr SETLFS        ; SetFileParams(LogNum=1,DevNum=DISK_DEVICE,SA=0)
   lda __xgf_fn_length
   ldx #<__xgf_fn
   ldy #>__xgf_fn
   jsr SETNAM        ; SetFileName(__xgf_fn)
   lda #XGF_PTR
   ldx #<(XGF_STAGE+RAM_WIN_SIZE)
   ldy #>(XGF_STAGE+RAM_WIN_SIZE)
   jsr SAVE
@restore:
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
   bra @start
@match: .byte $FF
@match_mask: .byte $FE
@start:
   jsr load_xgf_dir
   lda XGF_NUM_FILES
   cmp #XGF_MAX_FILES
   bpl @check_prefix
   inc XGF_NUM_FILES
   jmp @add_ext
@check_prefix:
   lda #$FF
   sta @match
   ldx #0   ; char index
@char_loop:
   phx
   lda #$FE
   sta @match_mask
   ldy #0   ; slot index
@slot_loop:
   ldx __xgf_dir_fns,y
   lda XGF_FN0,x
   plx
   phx
   cmp __xgf_fn,x
   beq @next_slot
   lda @match
   and @match_mask
   sta @match
@next_slot:
   iny
   cpy #XGF_MAX_FILES
   beq @next_char
   sec
   rol @match_mask
   bra @slot_loop
@next_char:
   plx
   inx
   cpx __xgf_fn_length
   beq @check_match
   bra @char_loop
@check_match:
   lda @match
   beq @reject
   ldy #0
@match_loop:
   lda @match
   bit #$01
   beq @next_match
   lda __xgf_dir_fns,y
   clc
   adc __xgf_fn_length
   tax
   lda XGF_FN0,x
   cmp __xgf_ext     ; check to see that the extension starts where expected
   bne @next_match   ; requested prefix only a substring of one from directory
   bra @add_ext      ; filename matches one from directory, overwrite
@next_match:
   lsr @match
   iny
   cpy #XGF_MAX_FILES
   beq @reject
   bra @match_loop
@reject:
   jsr __xgf_reject_fn
   bra @return
@add_ext:
   ldx __xgf_fn_length
   beq @return
   ldy #0
@add_ext_loop:
   lda __xgf_ext,y
   sta __xgf_fn,x
   inc __xgf_fn_length
   inx
   iny
   cpy #XGF_EXT_LENGTH
   bmi @add_ext_loop
   jsr __xgf_update_dir
   jsr save_game
   stz saveas_visible
@return:
   rts

__xgf_update_dir:
   ; TODO: add __xgf_fn to directory file, if not already there
   rts

__xgf_reject_fn:
   ; TODO: print error message
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
   lda mouse_left_click
   beq @return
   jsr tile_restore
   stz load_visible
@return:
   rts

.endif
