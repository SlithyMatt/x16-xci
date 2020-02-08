.ifndef ZONE_INC
ZONE_INC = 1

.include "x16.inc"
.include "globals.asm"
.include "toolbar.asm"
.include "state.asm"
.include "bin2dec.asm"
.include "level.asm"

__zone_filename: .asciiz "Z000.L0.00.BIN"
__zone_bank: .byte 0
ZONE_FN_LENGTH = __zone_bank - __zone_filename - 1

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
   lda #KERNAL_ROM_BANK
   sta ROM_BANK
   lda #1
   ldx #DISK_DEVICE
   ldy #0
   jsr SETLFS                 ; SetFileParams(LogNum=1,DevNum=DISK_DEVICE,SA=0)
   lda #<(__zone_filename+1)  ; overwrite zone number in filename
   sta ZP_PTR_2
   lda #>(__zone_filename+1)
   sta ZP_PTR_2+1
   lda zone
   jsr byte2ascii
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
   sta __zone_filename+6
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
   sta __zone_filename+8
   lda __zone_num_string+2
   sta __zone_filename+9
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
