.ifndef ZONE_INC
ZONE_INC = 1

.include "x16.inc"
.include "globals.asm"
.include "toolbar.asm"
.include "state.asm"
.include "bin2dec.asm"

__zone_filename: .asciiz "Z000.L0.00.BIN"
__zone_fn_length: .byte __zone_fn_length-__zone_filename-1

__zone_num_string: .byte 0,0,0

new_game:
   stz zone
   stz level
   jsr init_state
   jsr load_zone
   jsr init_toolbar
   rts

load_zone:
   lda #<(__zone_filename+1)  ; overwrite zone number in filename
   sta ZP_PTR_2
   lda #>(__zone_filename+1)
   sta ZP_PTR_2+1
   lda zone
   jsr byte2ascii
   ldx #0
@loop:
   lda #<__zone_num_string    ; overwrite level number in filename
   sta ZP_PTR_2
   lda #>__zone_num_string
   sta ZP_PTR_2+1
   txa
   jsr byte2ascii
   lda __zone_num_string+2
   sta __zone_filename+6

   lda level                  ; overwrite bank number in filename
   ldy zone


   inx
   txa
   ldy zone
   cmp (ZL_COUNT_PTR),y
   bne @loop 
@return:
   rts

.endif
