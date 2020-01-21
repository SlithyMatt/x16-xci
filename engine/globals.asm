.ifndef GLOBALS_INC
GLOBALS_INC = 1

.charmap $40, $40
.charmap $41, $41
.charmap $42, $42
.charmap $43, $43
.charmap $44, $44
.charmap $45, $45
.charmap $46, $46
.charmap $47, $47
.charmap $48, $48
.charmap $49, $49
.charmap $4a, $4a
.charmap $4b, $4b
.charmap $4c, $4c
.charmap $4d, $4d
.charmap $4e, $4e
.charmap $4f, $4f
.charmap $50, $50
.charmap $51, $51
.charmap $52, $52
.charmap $53, $53
.charmap $54, $54
.charmap $55, $55
.charmap $56, $56
.charmap $57, $57
.charmap $58, $58
.charmap $59, $59
.charmap $5a, $5a
.charmap $5b, $5b
.charmap $5c, $5c
.charmap $5d, $5d
.charmap $5e, $5e
.charmap $5f, $5f
.charmap $61, $61
.charmap $62, $62
.charmap $63, $63
.charmap $64, $64
.charmap $65, $65
.charmap $66, $66
.charmap $67, $67
.charmap $68, $68
.charmap $69, $69
.charmap $6a, $6a
.charmap $6b, $6b
.charmap $6c, $6c
.charmap $6d, $6d
.charmap $6e, $6e
.charmap $6f, $6f
.charmap $70, $70
.charmap $71, $71
.charmap $72, $72
.charmap $73, $73
.charmap $74, $74
.charmap $75, $75
.charmap $76, $76
.charmap $77, $77
.charmap $78, $78
.charmap $79, $79
.charmap $7a, $7a
.charmap $7b, $7b
.charmap $7c, $7c
.charmap $7d, $7d
.charmap $7e, $7e
.charmap $7f, $7f

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
MOUSE_X        = $38
MOUSE_Y        = $3A

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


mouse_tile_x:  .byte 0
mouse_tile_y:  .byte 0
mouse_buttons: .byte 0
mouse_left_click: .byte 0

backup_tilemap:
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


.endif
