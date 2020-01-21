.include "x16.inc"

.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"
   jmp start

.include "filenames.asm"
.include "loadvram.asm"
.include "irq.asm"
.include "globals.asm"
.include "mouse.asm"
.include "tilelib.asm"

tilemap: .word 0

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

   ; load VRAM data from binaries (assuming example game)
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

   ; disable layer 0
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_layer0, 1  ; configure VRAM layer 0
   lda #$C0
   sta VERA_data0 ; 4bpp bitmap, disabled

   VERA_SET_ADDR VRAM_layer1, 0  ; enable VRAM layer 1
   lda #$01
   ora VERA_data0
   sta VERA_data0

   VERA_SET_ADDR VRAM_sprreg, 0  ; enable sprites
   lda #$01
   sta VERA_data0



   ; setup interrupts
   jsr init_irq

   ; initialize mouse, tilemap
   stz VERA_ctrl

   ; clear all tiles
   VERA_SET_ADDR VRAM_TILEMAP, 1
   lda #<TILEMAP_SIZE
   sta tilemap
   lda #>TILEMAP_SIZE
   sta tilemap+1
@clear_tile_loop:
   stz VERA_data0
   lda tilemap
   sec
   sbc #1
   sta tilemap
   lda tilemap+1
   sbc #0
   sta tilemap+1
   bne @clear_tile_loop
   lda tilemap
   bne @clear_tile_loop

   ; init mouse cursor
   lda #0
   sta ROM_BANK
   lda #$FF ; custom cursor
   ldx #2   ; scale x 2
   jsr MOUSE_CONFIG
   VERA_SET_ADDR VRAM_sprattr, 1
   stz VERA_data0
   lda #$08
   sta VERA_data0
   lda VERA_data0 ; leave position alone
   lda VERA_data0
   lda VERA_data0
   lda VERA_data0
   lda #$0C       ; make cursor visible, no flipping
   sta VERA_data0
   lda #$50       ; size 16x16, palette offset 0
   sta VERA_data0

mainloop:
   wai
   lda vsync_trig
   beq mainloop
   jsr mouse_tick
   lda mouse_left_click
   beq @clear_trig
   lda #1
   ldx mouse_tile_x
   ldy mouse_tile_y
   jsr xy2vaddr
   stz VERA_ctrl
   sta VERA_addr_bank
   stx VERA_addr_low
   sty VERA_addr_high
   lda VERA_data0
   beq @white
   stz VERA_data0 ; make tile black
   bra @clear_trig
@white:
   lda #1
   sta VERA_data0 ; make tile white
@clear_trig:
   stz vsync_trig
   bra mainloop
