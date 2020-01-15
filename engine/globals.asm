.ifndef GLOBALS_INC
GLOBALS_INC = 1

; ---------- Build Options ----------

; ------------ Constants ------------


VRAM_TILEMAP   = $09600 ; 64x32 (40x30 visible)
VRAM_SPRITES   = $10000 ; 512 4bpp 16x16 frames
VRAM_TILES     = $0A600 ; 720 4bpp 8x8 tiles
VRAM_BITMAP    = $00000 ; 4bpp 320x240

RAM_CONFIG     = $6000

TTL_MUS_BANK   = 1

; sprite indices
MOUSE_idx      = 0


; --------- Global Variables ---------


.endif
