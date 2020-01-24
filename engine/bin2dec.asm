.ifndef BIN2DEC_INC
BIN2DEC_INC = 1

.include "x16.inc"

word2ascii: ; Input:
            ;  ZP_PTR_1: address of 16-bit binary word
            ;  ZP_PTR_2: address of buffer for ASCII string (up to 5 bytes)
            ; Output:
            ;  A: length of string at ZP_PTR_2
            ;  (ZP_PTR_2): Decimal ASCII numerals in reverse order (1s,10s,...)
   bra @start
@bcd: .byte 0,0,0
@start:
   lda (ZP_PTR_1)
   tax
   ldy #1
   lda (ZP_PTR_1),y
   tay
   lda #<@bcd
   sta ZP_PTR_1
   lda #>@bcd
   sta ZP_PTR_1+1
   jsr word2bcd
   ldx #0
   ldy #0
@ascii_loop:
   lda @bcd,x
   and #$0F
   ora #$30
   sta (ZP_PTR_2),y
   iny
   cpy #5
   beq @get_length
   lda @bcd,x
   inx
   and #$F0
   lsr
   lsr
   lsr
   lsr
   ora #$30
   sta (ZP_PTR_2),y
   iny
   bra @ascii_loop
@get_length:
   ldy #4
@count_loop:
   lda (ZP_PTR_2),y
   cmp #$30
   bne @return
   dey
   bne @count_loop
@return:
   iny
   tya
   rts

word2bcd:   ; Input:
            ;  X/Y: binary word
            ;  ZP_PTR_1: address of buffer for BCD number (up to 3 bytes)
            ; Output:
            ;  (ZP_PTR_1): BCD encoding of input
   bra @start
@bin: .word 0
@start:
   sed
   lda #0
   sta (ZP_PTR_1)
   ldy #1
   sta (ZP_PTR_1),y
   iny
   sta (ZP_PTR_1),y
   ldx #16
@loop:
   asl @bin
   rol @bin+1
   lda (ZP_PTR_1)
   adc (ZP_PTR_1)
   sta (ZP_PTR_1)
   ldy #1
   lda (ZP_PTR_1),y
   adc (ZP_PTR_1),y
   sta (ZP_PTR_1),y
   iny
   lda (ZP_PTR_1),y
   adc (ZP_PTR_1),y
   sta (ZP_PTR_1),y
   dex
   bne @loop
   cld
   rts


.endif
