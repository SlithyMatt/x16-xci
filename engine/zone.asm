.ifndef ZONE_INC
ZONE_INC = 1

.include "x16.inc"
.include "globals.asm"
.include "toolbar.asm"
.include "state.asm"
.include "bin2dec.asm"
.include "level.asm"
.include "mouse.asm"

__zone_filename:     .asciiz "000L0B00.BIN"
__zone_tiles_fn:     .asciiz "000TILES.BIN"
__zone_sprites_fn:   .asciiz "000SPRTS.BIN"
__zone_bank: .byte 0
ZONE_FN_LENGTH = __zone_tiles_fn - __zone_filename - 1

__zone_num_string: .byte 0,0,0

new_game:
   jsr load_main_cfg ; reload main config file
   stz zone
   stz level
   jsr init_state

   ; clear background header and footer
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_BITMAP, 1
   ldx #<LEVEL_BITMAP_OFFSET
   ldy #>LEVEL_BITMAP_OFFSET
@header_loop:
   stz VERA_data0
   dex
   bne @header_loop
   dey
   bne @header_loop
   cpx #0
   bne @header_loop
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_TEXTFIELD_BITMAP_BG, 1
   ldx #<TEXTFIELD_BITMAP_BG_SIZE
   ldy #>TEXTFIELD_BITMAP_BG_SIZE
@footer_loop:
   stz VERA_data0
   dex
   bne @footer_loop
   dey
   bne @footer_loop
   cpx #0
   bne @footer_loop

   jsr load_zone
   jsr init_toolbar
   jsr load_level
   rts

load_zone:
   ; blackout bitmap
   lda #BLACK_PO
   sta BITMAP_PO
   ; clear level tiles
   ldy #1
   jsr tile_clear
   ; clear sprites
   VERA_SET_ADDR $1FC0E, 4 ; sprite 1 byte 6, stride of 8
   ldx #1
@clear_sprite_loop:
   stz VERA_data0
   inx
   cpx #128
   bne @clear_sprite_loop
   ; load zone files
   lda #KERNAL_ROM_BANK
   sta ROM_BANK
   lda #1
   ldx #DISK_DEVICE
   ldy #0
   jsr SETLFS                 ; SetFileParams(LogNum=1,DevNum=DISK_DEVICE,SA=0)
   lda #<(__zone_filename)    ; overwrite zone number in filenames
   sta ZP_PTR_2
   lda #>(__zone_filename)
   sta ZP_PTR_2+1
   lda zone
   jsr byte2ascii
   lda #<(__zone_tiles_fn)
   sta ZP_PTR_2
   lda #>(__zone_tiles_fn)
   sta ZP_PTR_2+1
   lda zone
   jsr byte2ascii
   lda #<(__zone_sprites_fn)
   sta ZP_PTR_2
   lda #>(__zone_sprites_fn)
   sta ZP_PTR_2+1
   lda zone
   jsr byte2ascii
   ; load custom tiles
   lda #ZONE_FN_LENGTH
   ldx #<__zone_tiles_fn
   ldy #>__zone_tiles_fn
   jsr SETNAM                 ; SetFileName(__zone_tiles_fn)
   lda __zone_bank
   sta RAM_BANK
   jsr reset_bank
   lda #^VRAM_TILES_UPPER
   clc
   adc #2
   ldx #<VRAM_TILES_UPPER
   ldy #>VRAM_TILES_UPPER
   jsr LOAD                   ; LoadFile(Verify=VRAM_TILES_UPPER.bank+2,Address=VRAM_TILES_UPPER.addr)
   ; load custom sprites
   lda #ZONE_FN_LENGTH
   ldx #<__zone_sprites_fn
   ldy #>__zone_sprites_fn
   jsr SETNAM                 ; SetFileName(__zone_sprites_fn)
   lda __zone_bank
   sta RAM_BANK
   jsr reset_bank
   lda #^VRAM_SPRITES_UPPER
   clc
   adc #2
   ldx #<VRAM_SPRITES_UPPER
   ldy #>VRAM_SPRITES_UPPER
   jsr LOAD                   ; LoadFile(Verify=VRAM_SPRITES_UPPER.bank+2,Address=VRAM_SPRITES_UPPER.addr)
   jsr init_mouse
   ldx #0
@level_loop:
   lda #<__zone_num_string    ; overwrite level number in filename
   sta ZP_PTR_2
   lda #>__zone_num_string
   sta ZP_PTR_2+1
   txa
   phx
   jsr byte2ascii
   plx
   lda __zone_num_string+2
   sta __zone_filename+4
   ldy #6
   phx
   jsr byte_mult
   inc
   sta __zone_bank            ; level config bank = level * 6 + 1
   jsr __zone_load_file
   inc __zone_bank            ; bitmap start bank = config bank + 1
   jsr __zone_load_file
   lda __zone_bank
   clc
   adc #4
   sta __zone_bank            ; music/sfx bank = bitmap bank + 4
   jsr __zone_load_file
   stz VERA_ctrl              ; load level palette offset (level + 1)
   lda #(^VRAM_palette | $10)
   sta VERA_addr_bank
   plx
   txa
   inc
   asl
   asl
   asl
   asl
   asl
   sta VERA_addr_low
   lda #>VRAM_palette
   adc #0
   sta VERA_addr_high
   ldy #0
   lda __zone_bank
   sec
   sbc #5         ; go back to level config bank
   sta RAM_BANK
   lda #<RAM_WIN
   sta ZP_PTR_1
   lda #>RAM_WIN
   sta ZP_PTR_1+1
@pal_loop:
   lda (ZP_PTR_1),y
   sta VERA_data0
   iny
   cpy #32
   bne @pal_loop
   inx
   txa
   ldy zone
   cmp (ZL_COUNT_PTR),y
   bne @level_loop
@return:
   rts

__zone_load_file:
   lda #<__zone_num_string    ; overwrite bank number in filename
   sta ZP_PTR_2
   lda #>__zone_num_string
   sta ZP_PTR_2+1
   lda __zone_bank
   jsr byte2ascii
   lda __zone_num_string+1
   sta __zone_filename+6
   lda __zone_num_string+2
   sta __zone_filename+7
   lda #ZONE_FN_LENGTH
   ldx #<__zone_filename
   ldy #>__zone_filename
   jsr SETNAM                 ; SetFileName(__zone_filename)
   lda __zone_bank
   sta RAM_BANK
   jsr reset_bank
   lda #0
   ldx #<RAM_WIN
   ldy #>RAM_WIN
   jsr LOAD                   ; LoadFile(Verify=0,Address=RAM_WIN)
   rts

.endif
