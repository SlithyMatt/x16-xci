.include "x16.inc"

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

   ; Disable layers
   stz VERA_ctrl
   lda VERA_dc_video
   and #$8F
   sta VERA_dc_video

   ; Setup tiles on layer 1
   lda #$12                      ; 64x32 map of 4bpp tiles
   sta VERA_L1_config
   lda #((VRAM_TILEMAP >> 9) & $FF)
   sta VERA_L1_mapbase
   lda #((((VRAM_TILES >> 11) & $3F) << 2) | $00)  ; 8x8 tiles
   sta VERA_L1_tilebase
   stz VERA_L1_hscroll_l         ; set scroll position to 0,0
   stz VERA_L1_hscroll_h
   stz VERA_L1_vscroll_l
   stz VERA_L1_vscroll_h

   ; Clear tile map
   ldy #0
   jsr tile_clear

   ; set display to 2x scale
   lda #64
   sta VERA_dc_hscale
   sta VERA_dc_vscale

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
   lda #$06       ; 4bpp bitmap
   sta VERA_L0_config
   lda #((((VRAM_BITMAP >> 11) & $3F) << 2) | $00) ; 320x240
   sta VERA_L0_tilebase
   lda #1
   sta BITMAP_PO ; Palette offset = 1

   ; enable sprites and layers
   lda VERA_dc_video
   ora #$70
   sta VERA_dc_video

   ; load configuration
   jsr load_main_cfg

   ; setup interrupts
   jsr init_irq

   ; init global variables
   lda #<XGF_STAGE
   sta XGF_PTR
   lda #>XGF_STAGE
   sta XGF_PTR+1
   lda #<cfg_ts_anim
   sta ANIM_PTR
   lda #>cfg_ts_anim
   sta ANIM_PTR+1
   lda cfg_menu
   clc
   adc #<RAM_CONFIG
   sta MENU_PTR
   lda cfg_menu+1
   adc #>RAM_CONFIG
   sta MENU_PTR+1
   lda cfg_tb
   clc
   adc #<RAM_CONFIG
   sta TB_PTR
   lda cfg_tb+1
   adc #>RAM_CONFIG
   sta TB_PTR+1
   lda cfg_inv
   clc
   adc #<RAM_CONFIG
   sta INV_PTR
   lda cfg_inv+1
   adc #>RAM_CONFIG
   sta INV_PTR+1
   ldy #MENU_CONTROLS
   lda (MENU_PTR),y
   clc
   adc #<RAM_CONFIG
   sta help_controls_ptr
   iny
   lda (MENU_PTR),y
   adc #>RAM_CONFIG
   sta help_controls_ptr+1
   ldy #MENU_ABOUT
   lda (MENU_PTR),y
   clc
   adc #<RAM_CONFIG
   sta help_about_ptr
   iny
   lda (MENU_PTR),y
   adc #>RAM_CONFIG
   sta help_about_ptr+1
   lda #<cfg_zone_levels
   sta ZL_COUNT_PTR
   lda #>cfg_zone_levels
   sta ZL_COUNT_PTR+1
   asl cfg_cursor    ; convert sprite frame number to VRAM address
   rol cfg_cursor+1  ; by just multiplying by 4
   asl cfg_cursor
   rol cfg_cursor+1
   lda cfg_cursor
   sta def_cursor
   lda cfg_cursor+1
   ora #(^VRAM_SPRITES << 3) ; Add bank
   sta def_cursor+1
   jsr init_mouse
   lda cfg_zones
   sta num_zones
   lda cfg_ts_dur
   sta ts_dur
   lda cfg_ts_dur+1
   sta ts_dur+1
   bne @title
   lda ts_dur
   bne @title
   ; Title screen duration = 0, cut straight to menu
   stz ts_playing
   jsr init_menu
   jsr init_toolbar
   bra mainloop

@title:
   ; start title screen
   jsr init_music
   jsr start_music
   jsr anim_reset
   jsr start_anim

mainloop:
   wai
   jsr check_vsync
   lda exit_req
   beq mainloop

   ; Restore IRQ vector
   jsr restore_irq

   ; Reset VERA
   lda #$80
   sta VERA_ctrl

   ; Return to BASIC
   lda #KERNAL_ROM_BANK
   sta ROM_BANK
   jsr SCINIT

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

; ---- Save game file staging

.org XGF_STAGE

; --- directory file structure
xgf_num_files: .byte 0
xgf_filenames:
   .byte 0  ; length
   .byte "            "
   .word 0  ; checksum

   .byte 0
   .byte "            "
   .word 0

   .byte 0
   .byte "            "
   .word 0

   .byte 0
   .byte "            "
   .word 0

   .byte 0
   .byte "            "
   .word 0

   .byte 0
   .byte "            "
   .word 0

   .byte 0
   .byte "            "
   .word 0

   .byte 0
   .byte "            "
   .word 0
