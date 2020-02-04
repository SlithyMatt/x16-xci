.ifndef LOADVRAM_INC
LOADVRAM_INC = 1

.include "x16.inc"
.include "filenames.asm"

loadvram:   ; A = VRAM address (19:12)
            ; X = VRAM address (11:4)
            ; Y = filename address (7:0)
   pha      ; push original A argument
   txa
   sta ZP_PTR_1   ; store original X argument to ZP
   tya
   sta ZP_PTR_1+1 ; store original Y argument to ZP
   lda #0
   sta ROM_BANK
   lda #1
   ldx #DISK_DEVICE
   ldy #0
   jsr SETLFS         ; SetFileParams(DISK_DEVICE to VRAM bank)
   ldx ZP_PTR_1+1     ; X = low byte of filename address
   stx ZP_PTR_2
   ldy #>filenames    ; Y = high byte of filename address
   sty ZP_PTR_2+1
   ldy #0
@loop:
   lda (ZP_PTR_2),y
   beq @foundnull
   iny
   jmp @loop
@foundnull:
   tya                ; A = filename length
   ldy #>filenames    ; Y = high byte of filename address
   jsr SETNAM
   pla                ; pull original A argument
   tax
   and #$F0           ; mask VRAM bank << 4
   lsr
   lsr
   lsr
   lsr
   clc
   adc #2
   pha                ; push VRAM bank + 2
   txa
   asl
   asl
   asl
   asl
   pha                ; push high nibble of VRAM address high byte (15:12)
   lda ZP_PTR_1
   tax                ; X = VRAM Address (11:4)
   lsr
   lsr
   lsr
   lsr
   sta ZP_PTR_1       ; store VRAM Address (11:8) to ZP
   pla                ; pull VRAM address (15:12)
   ora ZP_PTR_1
   tay                ; Y = VRAM Address high byte (15:8)
   txa
   asl
   asl
   asl
   asl
   tax                ; X = VRAM Address low byte (7:0)
   pla                ; A = VRAM bank + 2
   jsr LOAD
   rts

.endif
