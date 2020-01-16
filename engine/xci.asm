.include "x16.inc"
.include "globals.asm"

.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"
   jmp start

.include "filenames.asm"
.include "loadbank.asm"
.include "loadvram.asm"
.include "irq.asm"
.include "vsync.asm"
.include "globals.asm"
.include "menu.asm"
.include "music.asm"

start:

   ; Setup tiles on layer 1
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_layer1, 1  ; configure VRAM layer 1
   lda #$60                      ; 4bpp tiles
   sta VERA_data0
   lda #$01                      ; 64x32 map of 8x8 tiles
   sta VERA_data0
   lda #((VRAM_TILEMAP >> 2) & $FF)
   sta VERA_data0
   lda #((VRAM_TILEMAP >> 10) & $FF)
   sta VERA_data0
   lda #((VRAM_TILES >> 2) & $FF)
   sta VERA_data0
   lda #((VRAM_TILES >> 10) & $FF)
   sta VERA_data0
   stz VERA_data0                ; set scroll position to 0,0
   stz VERA_data0
   stz VERA_data0
   stz VERA_data0

   VERA_SET_ADDR VRAM_hscale, 1  ; set display to 2x scale
   lda #64
   sta VERA_data0
   sta VERA_data0

   ; load VRAM data from binaries
   lda #>(VRAM_SPRITES>>4)
   ldx #<(VRAM_SPRITES>>4)
   ldy #<sprites_fn
   jsr loadvram

   lda #>(VRAM_TILES>>4)
   ldx #<(VRAM_TILES>>4)
   ldy #<tiles_fn
   jsr loadvram

   lda #>(VRAM_palette>>4)
   ldx #<(VRAM_palette>>4)
   ldy #<palette_fn
   jsr loadvram

   lda #>(VRAM_BITMAP>>4)
   ldx #<(VRAM_BITMAP>>4)
   ldy #<ttl_bm_fn
   jsr loadvram

   ; store title screen music to banked RAM
   jsr loadbank

   ; configure layer 0 for background bitmaps
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_layer0, 1  ; configure VRAM layer 0
   lda #$C1
   sta VERA_data0 ; 4bpp bitmap
   stz VERA_data0 ; 320x240
   stz VERA_data0
   stz VERA_data0
   lda #<(VRAM_BITMAP >> 2)
   sta VERA_data0
   lda #>(VRAM_BITMAP >> 2)
   sta VERA_data0
   stz VERA_data0
   lda #1
   sta VERA_data0 ; Palette offset = 1
   stz VERA_data0
   stz VERA_data0

   stz VERA_ctrl
   VERA_SET_ADDR VRAM_layer1, 0  ; enable VRAM layer 1
   lda #$01
   ora VERA_data0
   sta VERA_data0

   ; setup interrupts
   jsr init_irq

   ; init global variables
   lda #<cfg_ts_anim
   sta ANIM_PTR
   lda #>cfg_ts_anim
   sta ANIM_PTR+1
   lda cfg_menu
   sta MENU_PTR
   lda cfg_menu+1
   sta MENU_PTR+1
   lda cfg_tb
   sta TB_PTR
   lda cfg_tb+1
   sta TB_PTR+1
   lda cfg_inv
   sta INV_PTR
   lda cfg_inv+1
   sta INV_PTR+1
   ldy MENU_CONTROLS
   lda (MENU_PTR),y
   sta HELP_CTRLS_PTR
   iny
   lda (MENU_PTR),y
   sta HELP_CTRLS_PTR+1
   ldy MENU_ABOUT
   lda (MENU_PTR),y
   sta HELP_ABOUT_PTR
   iny
   lda (MENU_PTR),y
   sta HELP_ABOUT_PTR+1
   lda cfg_zone_levels
   sta ZL_COUNT_PTR
   lda cfg_zone_levels+1
   sta ZL_COUNT_PTR+1
   lda cfg_cursor
   sta def_cursor
   lda cfg_cursor+1
   sta def_cursor+1
   lda cfg_zones
   sta num_zones
   lda cfg_ts_dur

   ; start title screen
   jsr init_music
   jsr start_music
   jsr start_anim

mainloop:
   wai
   jsr check_vsync
   bra mainloop


; ----- Configuration

.org RAM_CONFIG

cfg_title:  .dword 0,0,0,0,0,0,0,0
cfg_author: .dword 0,0,0,0,0,0,0,0
cfg_cursor: .word 0
cfg_zones:  .byte 0
cfg_zone_levels:
   .dword 0,0,0,0,0,0,0,0 ; 0-31
   .dword 0,0,0,0,0,0,0,0 ; 32-63
   .dword 0,0,0,0,0,0,0,0 ; 64-95
   .dword 0,0,0,0,0,0,0,0 ; 96-127
   .dword 0,0,0,0,0,0,0,0 ; 128-159
   .dword 0,0,0,0,0,0,0,0 ; 160-191
   .dword 0,0,0,0,0,0,0,0 ; 192-223
   .dword 0,0,0,0,0,0,0,0 ; 224-255
cfg_menu:   .word 0
cfg_tb:     .word 0
cfg_inv:    .word 0
cfg_ts_dur: .word 0
cfg_ts_anim:
   .byte 0
