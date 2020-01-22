.ifndef TOOLBAR_INC
TOOLBAR_INC = 1

; config offsets
TB_START_X        = 0
TB_START_Y        = 1
TB_WALK_CURSOR    = 2
TB_RUN_CURSOR     = 4
TB_LOOK_CURSOR    = 6
TB_USE_CURSOR     = 8
TB_TALK_CURSOR    = 10
TB_STRIKE_CURSOR  = 12
TB_NUM_TOOLS      = 14
TB_BUTTONS        = 15

TB_POPUP_ZONE_Y   = 29

__tb_enabled: .byte 0
__tb_visible: .byte 0

__tb_start_x:  .byte 0
__tb_end_x:    .byte 0
__tb_start_y:  .byte 0

__tb_tiles:
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

; tool IDs
INVENTORY_TOOL = 0
WALK_TOOL      = 1
RUN_TOOL       = 2
LOOK_TOOL      = 3
USE_TOOL       = 4
TALK_TOOL      = 5
STRIKE_TOOL    = 6
PIN_TOOLBAR    = 7

__tb_num_tools: .byte 0

__tb_tools:
; first tool
.byte 0     ; start X
.byte 0     ; tool ID
.word 0     ; cursor
.dword 0,0,0,0,0,0,0

__tb_pin_pos:        .byte 0
__tb_pin_tiles_ptr:  .word 0
__tb_pinned:         .byte 0


init_toolbar:
   ldy #TB_START_X
   lda (TB_PTR),y
   sta __tb_start_x
   ldy #TB_START_Y
   lda (TB_PTR),y
   sta __tb_start_y
   ldy #TB_NUM_TOOLS
   lda (TB_PTR),y
   sta __tb_num_tools
   tax
   lda TB_PTR
   clc
   adc #TB_BUTTONS
   sta ZP_PTR_1
   lda TB_PTR+1
   adc #0
   sta ZP_PTR_1
@loop:
   cpx #0
   beq @done
   txa
   asl
   asl
   tay
   iny
   lda (ZP_PTR_1)
   sta __tb_tools,y  ; action
   dey
   phy
   ldy #1
   lda (ZP_PTR_1),y
   ply
   sta __tb_tools,y  ; start_x
   ldy #2
   lda (ZP_PTR_1),y
   sta __tb_end_x
   ; TODO copy tiles


   dex
   bra @loop
@done:
   lda #1
   sta __tb_enabled
   rts

toolbar_tick:
   lda __tb_enabled
   beq @return

@return:
   rts

.endif
