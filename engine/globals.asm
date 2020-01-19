.ifndef GLOBALS_INC
GLOBALS_INC = 1

; ---------- Build Options ----------

; ------------ Constants ------------

; dedicated zero page pointers
MUSIC_PTR      = $28
ANIM_PTR       = $2A
MENU_PTR       = $2C
TB_PTR         = $2E
INV_PTR        = $30
HELP_CTRLS_PTR = $32
HELP_ABOUT_PTR = $34
ZL_COUNT_PTR   = $36

VRAM_BITMAP    = $00000 ; 4bpp 320x240
VRAM_TILEMAP   = $09600 ; 64x32 (40x30 visible)
VRAM_TILES     = $0A600 ; 720 4bpp 8x8 tiles
VRAM_SPRITES   = $10000 ; 512 4bpp 16x16 frames

TILEMAP_SIZE   = VRAM_TILES - VRAM_TILEMAP

RAM_CONFIG     = $6000

TTL_MUS_BANK            = 1
SPRITE_FRAME_SEQ_BANK   = 61
SPRITE_MOVEMENT_BANK    = 62

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


; --------- Global Variables ---------
frame_num:  .byte 0
def_cursor: .word 0
num_zones:  .byte 0
zone:       .byte 0
level:      .byte 0
ts_playing: .byte 1
ts_dur:     .word 0
music_bank: .byte TTL_MUS_BANK
anim_bank:  .byte 0

.endif
