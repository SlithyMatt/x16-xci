.ifndef GLOBALS_INC
GLOBALS_INC = 1

.include "x16.inc"
.include "charmap.inc"

; ------------- Macros --------------

.macro SET_MOUSE_CURSOR frame_addr
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_sprattr, 1
   lda frame_addr
   sta VERA_data0
   lda frame_addr+1
   sta VERA_data0
.endmacro

; ------------ Functions ------------

byte_mult:  ; Input: X,Y - factors
            ; Output: A - product
   bra @start
@x: .byte 0
@start:
   cpy #0
   beq @zero
   cpx #0
   beq @zero
   stx @x
   txa
@loop:
   dey
   cpy #0
   beq @return
   clc
   adc @x
   bra @loop
@zero:
   lda #0
@return:
   rts

reset_bank: ; A: bank to set to all zeros
   bra @start
@bank: .byte 0
@start:
   sta @bank
   lda #<RAM_WIN
   sta ZP_PTR_1
   lda #>RAM_WIN
   sta ZP_PTR_1+1
   ldy #0
@loop:
   lda @bank
   sta RAM_BANK
   lda #0
   sta (ZP_PTR_1),y
   iny
   bne @loop
   inc ZP_PTR_1+1
   lda ZP_PTR_1+1
   cmp #>(RAM_WIN+RAM_WIN_SIZE)
   bne @loop
@return:
   rts

RAM_CONFIG     = $6000

load_main_cfg:
   lda #0
   sta ROM_BANK
   lda #1
   ldx #DISK_DEVICE
   ldy #0
   jsr SETLFS        ; SetFileParams(LogNum=1,DevNum=DISK_DEVICE,SA=0)
   lda #(main_fn_end-main_fn-1)
   ldx #<main_fn
   ldy #>main_fn
   jsr SETNAM        ; SetFileName(main_fn)
   lda #0
   ldx #<RAM_CONFIG
   ldy #>RAM_CONFIG
   jsr LOAD          ; LoadFile(Verify=0,Address=RAM_CONFIG)
   rts

; ---------- Build Options ----------

; ------------ Constants ------------

; dedicated zero page pointers
MUSIC_PTR      = $28
ANIM_PTR       = $2A
MENU_PTR       = $2C
TB_PTR         = $2E
INV_PTR        = $30
HELP_PTR       = $32
ZL_COUNT_PTR   = $34
MOUSE_X        = $36
MOUSE_Y        = $38

VRAM_BITMAP    = $00000 ; 4bpp 320x240
VRAM_TILEMAP   = $09600 ; 64x32 (40x30 visible)
VRAM_TILES     = $0A600 ; 720 4bpp 8x8 tiles
VRAM_SPRITES   = $10000 ; 512 4bpp 16x16 frames

LEVEL_BITMAP_OFFSET        = 8*320/2
VRAM_LEVEL_BITMAP          = VRAM_BITMAP + LEVEL_BITMAP_OFFSET
LEVEL_BITMAP_SIZE          = 200*320/2
VRAM_TEXTFIELD_BITMAP_BG   = VRAM_LEVEL_BITMAP + LEVEL_BITMAP_SIZE
TEXTFIELD_BITMAP_BG_SIZE   = 32*320/2

TILEMAP_SIZE   = VRAM_TILES - VRAM_TILEMAP

.ifndef TTL_MUS_BANK
TTL_MUS_BANK            = 1
.endif

SPRITE_FRAME_SEQ_BANK   = 61
SPRITE_MOVEMENT_BANK    = 62
STATE_BANK = 63

; palette offsets
DEFAULT_PO     = 0
LEVEL0_PO      = 1
MENU_PO        = 11
TEXT1_PO       = 12
TEXT2_PO       = 13
TEXT3_PO       = 14
BLACK_PO       = 15

; sprite indices
MOUSE_idx      = 0

NO_ITEM        = $FF

START_TEXT_Y   = 26

; --------- Global Variables ---------
vsync_trig: .byte 0
frame_num:  .byte 0
def_cursor: .word 0
num_zones:  .byte 0
zone:       .byte 0
level:      .byte 0
ts_playing: .byte 1
ts_dur:     .word 0
music_bank: .byte TTL_MUS_BANK
anim_bank:  .byte 0

help_controls_ptr:   .word 0
help_about_ptr:      .word 0

tb_visible:       .byte 0
tb_start_y:       .byte 0
current_tool:     .byte 0
inv_visible:      .byte 0
inv_start_y:      .byte 0
current_item:     .byte NO_ITEM
help_visible:     .byte 0
music_enabled:    .byte 1
sfx_enabled:      .byte 1
saveas_visible:   .byte 0
load_visible:     .byte 0
req_load_level:   .byte 0
mouse_tile_x:     .byte 0
mouse_tile_y:     .byte 0
mouse_buttons:    .byte 0
mouse_left_click: .byte 0


.endif
