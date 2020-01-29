.ifndef TILELIB_INC
TILELIB_INC = 1

xy2vaddr:   ; Input:
            ;  A: layer
            ;  X: tile display x position
            ;  Y: tile display y position
            ; Output:
            ;  A: VRAM bank
            ;  X/Y: VRAM addr
   jmp @start
@vars:
@ctrl1:     .byte 0
@map:       .word 0
@xoff:      .word 0
@yoff:      .word 0
@end_vars:
@banks:     .byte 0,1
@start:
   phx
   ldx #(@end_vars-@vars-1)
@init:
   stz @vars,x
   dex
   bpl @init
   plx
   cmp #0
   bne @layer1
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_layer0, 1
   jmp @readlayer
@layer1:
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_layer1, 1
@readlayer:
   lda VERA_data0 ; ignore CTRL0
   lda VERA_data0
   sta @ctrl1
   lda VERA_data0
   sta @map
   lda VERA_data0
   sta @map+1
   lda VERA_data0 ; ignore TILE_BASE
   lda VERA_data0
   lda VERA_data0
   sta @xoff
   lda VERA_data0
   sta @xoff+1
   lda VERA_data0
   sta @yoff
   lda VERA_data0
   sta @yoff+1
   lda @ctrl1
   and #$10
   beq @xoff_div8
   clc               ; tiles are 16 pixels wide, xoff >> 4
   ror @xoff+1
   ror @xoff
@xoff_div8:
   lsr @xoff+1
   ror @xoff
   lsr @xoff+1
   ror @xoff
   lsr @xoff+1
   ror @xoff
   txa
   clc
   adc @xoff
   sta @xoff
   bcc @calc_yoff
   lda #1
   sta @xoff+1
@calc_yoff:
   lda @ctrl1
   and #$20
   beq @yoff_div8
   clc               ; tiles are 16 pixels high, yoff >> 4
   ror @yoff+1
   ror @yoff
@yoff_div8:
   lsr @yoff+1
   ror @yoff
   lsr @yoff+1
   ror @yoff
   lsr @yoff+1
   ror @yoff
   tya
   clc
   adc @yoff
   sta @yoff
   bcc @calcaddr
   lda #1
   sta @yoff+1
@calcaddr:  ; address = map_base+(yoff*MAPW+xoff)*2
   lda @ctrl1
   and #$03
   clc
   adc #5
   tax            ; X = log2(MAPW)
@mult_loop:
   txa
   beq @end_mult_loop
   asl @yoff
   rol @yoff+1
   dex
   jmp @mult_loop
@end_mult_loop:   ; yoff = yoff*MAPW
   clc
   lda @yoff
   adc @xoff
   sta @yoff
   lda @yoff+1
   adc @xoff+1
   sta @yoff+1    ; yoff = yoff + xoff
   asl @yoff
   rol @yoff+1    ; yoff = yoff * 2
   asl @map
   rol @map+1
   asl @map
   rol @map+1
   lda #0
   bcc @push_bank
   lda #1
@push_bank:
   pha
   lda @map
   clc
   adc @yoff
   sta @map
   lda @map+1
   adc @yoff+1
   sta @map+1
   ldx #0
   bcc @pull_bank
   ldx #1
@pull_bank:
   pla
   clc
   adc @banks,x
   ldx @map
   ldy @map+1
   rts


pix2tilexy: ; Input:
            ; A: bit 4: layer; bits 3,2: x (9:8), bits 1,0: y (9:8)
            ; X: display x (7:0)
            ; Y: display y (7:0)
            ; Output:
            ; A: bits 7-4: TILEW/2, bits 3-0: TILEH/2
            ; X: tile x
            ; Y: tile y
   jmp @start
@ctrl1:     .byte 0
@xoff:      .word 0
@yoff:      .word 0
@xshift:    .byte 3
@yshift:    .byte 3
@start:
   pha                     ; push A params
   and #$10
   cmp #0
   bne @layer1
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_layer0, 1
   bra @readlayer
@layer1:
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_layer1, 1
@readlayer:
   lda VERA_data0 ; ignore CTRL0
   lda VERA_data0
   sta @ctrl1
   lda VERA_data0 ; ignore MAP_BASE
   lda VERA_data0
   lda VERA_data0 ; ignore TILE_BASE
   lda VERA_data0
   lda VERA_data0
   sta @xoff
   lda VERA_data0
   lda VERA_data0
   sta @yoff
@gettw:
   lda @ctrl1
   and #$10
   bne @tw16
   lda #3
   sta @xshift
   lda @xoff
   and #$07    ; A = xoff % 8
   jmp @calcx
@tw16:
   lda #4
   sta @xshift
   lda @xoff
   and #$0F    ; A = xoff % 16
@calcx:
   sta @xoff
   txa
   sec
   sbc @xoff
   php
   plx
   sta @xoff
   pla
   pha
   and #$0C
   lsr
   lsr
   phx
   plp
   sbc #0
   bpl @do_xshift
   stz @xoff
   stz @xoff+1
   bra @getth
@do_xshift:
   sta @xoff+1
   ldx @xshift
@xshift_loop:
   beq @getth
   lsr @xoff+1
   ror @xoff
   dex
   bra @xshift_loop
@getth:
   lda @ctrl1
   and #$20
   bne @th16
   lda #3
   sta @yshift
   lda @yoff
   and #$07    ; A = yoff % 8
   jmp @calcy
@th16:
   lda #4
   sta @yshift
   lda @yoff
   and #$0F    ; A = yoff %16
@calcy:
   sta @yoff
   tya
   sec
   sbc @yoff
   php
   plx
   sta @yoff
   pla
   and #$03
   phx
   plp
   sbc #0
   bpl @do_yshift
   stz @yoff
   stz @yoff+1
   bra @end
@do_yshift:
   ldy @yshift
@yshift_loop:
   beq @end
   lsr @yoff+1
   ror @yoff
   dey
   bra @yshift_loop
@end:
   lda @xshift
   asl
   asl
   asl
   asl
   ora @yshift
   asl
   ldx @xoff
   ldy @yoff
   rts


get_tile:   ; Input:
            ; A: layer
            ; X: tile display x position
            ; Y: tile display y position
            ; Output:
            ; A: layer
            ; X: tile entry 0
            ; Y: tile entry 1
   pha
   jsr xy2vaddr
   stz VERA_ctrl
   ora #$10
   sta VERA_addr_bank
   stx VERA_addr_low
   sty VERA_addr_high
   ldx VERA_data0
   ldy VERA_data0
   pla
   rts


tile_backup:
   ldy #1
@row_loop:
   lda #1
   ldx #0
   phy
   jsr xy2vaddr
   stz VERA_ctrl
   ora #$10
   sta VERA_addr_bank
   stx VERA_addr_low
   sty VERA_addr_high
   pla
   pha
   dec
   asl
   tay
   lda __tile_backup_row_table,y
   sta ZP_PTR_1
   iny
   lda __tile_backup_row_table,y
   sta ZP_PTR_1+1
   ldy #0
@tile_loop:
   lda VERA_data0
   sta (ZP_PTR_1),y
   iny
   cpy #80
   bne @tile_loop
   ply
   iny
   cpy #30
   bne @row_loop
   rts

tile_restore:
   ldy #1
@row_loop:
   lda #1
   ldx #0
   phy
   jsr xy2vaddr
   stz VERA_ctrl
   ora #$10
   sta VERA_addr_bank
   stx VERA_addr_low
   sty VERA_addr_high
   pla
   pha
   dec
   asl
   tay
   lda __tile_backup_row_table,y
   sta ZP_PTR_1
   iny
   lda __tile_backup_row_table,y
   sta ZP_PTR_1+1
   ldy #0
@tile_loop:
   lda (ZP_PTR_1),y
   sta VERA_data0
   iny
   cpy #80
   bne @tile_loop
   ply
   iny
   cpy #30
   bne @row_loop
   rts

tile_clear:
   lda #<__tile_backup_map
   sta r0L
   lda #>__tile_backup_map
   sta r0H
   lda #<TILE_BACKUP_MAP_SIZE
   sta r1L
   lda #>TILE_BACKUP_MAP_SIZE
   sta r1H
   lda #KERNAL_ROM_BANK
   sta ROM_BANK
   lda #0
   jsr MEMORY_FILL
   jsr tile_restore
   rts

__tile_backup_map:
__tile_row0:   .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row1:   .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row2:   .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row3:   .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row4:   .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row5:   .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row6:   .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row7:   .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row8:   .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row9:   .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row10:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row11:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row12:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row13:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row14:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row15:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row16:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row17:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row18:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row19:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row20:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row21:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row22:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row23:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row24:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row25:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row26:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row27:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row28:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
__tile_row29:  .dword 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

__tile_backup_row_table:
.word __tile_row0
.word __tile_row1
.word __tile_row2
.word __tile_row3
.word __tile_row4
.word __tile_row5
.word __tile_row6
.word __tile_row7
.word __tile_row8
.word __tile_row9
.word __tile_row10
.word __tile_row11
.word __tile_row12
.word __tile_row13
.word __tile_row14
.word __tile_row15
.word __tile_row16
.word __tile_row17
.word __tile_row18
.word __tile_row19
.word __tile_row20
.word __tile_row21
.word __tile_row22
.word __tile_row23
.word __tile_row24
.word __tile_row25
.word __tile_row26
.word __tile_row27
.word __tile_row28
.word __tile_row29

TILE_BACKUP_MAP_SIZE = __tile_backup_row_table - __tile_backup_map
.endif
