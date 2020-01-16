.ifndef LOADBANK_INC
LOADBANK_INC = 1

.include "x16.inc"
.include "filenames.asm"

loadbank:
   lda #0
   sta ROM_BANK
   lda #1
   ldx #8
   ldy #0
   jsr SETLFS        ; SetFileParams(LogNum=1,DevNum=8,SA=0)
   lda #<bankparams
   sta ZP_PTR_1
   lda #>bankparams
   sta ZP_PTR_1+1
   ldx #0
@loop:
   cpx #FILES_TO_LOAD
   beq end_loadbank
   phx
   jsr @load         ; load bank
   plx
   inx
   jmp @loop

@load:               ; load banked RAM using params starting at ZP_PTR_1
   lda (ZP_PTR_1)
   sta RAM_BANK      ; set RAM bank
   jsr @inczp1
   lda (ZP_PTR_1)
   pha               ; push filename length to stack
   jsr @inczp1
   lda (ZP_PTR_1)
   pha               ; push filename address low byte to stack
   jsr @inczp1
   lda (ZP_PTR_1)
   tay               ; Y = filename address high byte
   jsr @inczp1
   pla               ; pull filename address low byte from stack
   tax               ; X = filename address low byte
   pla               ; pull filename length from stack to A
   beq @load_return
   jsr SETNAM        ; SetFileName(filename)
   lda #0
   ldx #<RAM_WIN
   ldy #>RAM_WIN
   jsr LOAD          ; LoadFile(Verify=0,Address=RAM_WIN)
@load_return:
   rts

@inczp1:             ; increment ZP_PTR_1
   pha               ; push A to stack
   lda #1
   clc
   adc ZP_PTR_1
   sta ZP_PTR_1
   lda #0
   adc ZP_PTR_1+1
   sta ZP_PTR_1+1
   pla               ; pull A back from stack
   rts

end_loadbank:
   rts



getramaddr: ; A = Offset into RAM bank >> 5
            ; Output: X/Y = Absolute address
   pha
   and #$07
   asl
   asl
   asl
   asl
   asl
   ora #<RAM_WIN
   tax
   pla
   and #$F8
   lsr
   lsr
   lsr
   ora #>RAM_WIN
   tay
   rts



bank2vram:  ; A = RAM bank,
            ; X = beginning of data offset >> 5,
            ; Y = end of data offset >> 5 (0 = whole bank)
   sta RAM_BANK
   phy               ; push end offset
   txa
   jsr getramaddr    ; get start address
   stx ZP_PTR_1
   sty ZP_PTR_1+1
   pla               ; pull end offset
   beq @wholebank
   jsr getramaddr    ; get end address from offset
   stx ZP_PTR_2
   sty ZP_PTR_2+1
   jmp @loop
@wholebank:
   lda #<(RAM_WIN+RAM_WIN_SIZE)
   sta ZP_PTR_2
   lda #>(RAM_WIN+RAM_WIN_SIZE)
   sta ZP_PTR_2+1
@loop:
   lda (ZP_PTR_1)    ; load from banked RAM
   sta VERA_data0     ; store to next VRAM address
   clc
   lda #1
   adc ZP_PTR_1
   sta ZP_PTR_1
   lda #0
   adc ZP_PTR_1+1
   sta ZP_PTR_1+1
   lda ZP_PTR_1
   cmp ZP_PTR_2
   bne @loop
   lda ZP_PTR_1+1
   cmp ZP_PTR_2+1
   bne @loop
   rts

.endif
