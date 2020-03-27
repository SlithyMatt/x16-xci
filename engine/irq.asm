.ifndef IRQ_INC
IRQ_INC = 1

.include "globals.asm"

def_irq: .word $0000

init_irq:
   lda IRQVec
   sta def_irq
   lda IRQVec+1
   sta def_irq+1
   lda #<handle_irq
   sta IRQVec
   lda #>handle_irq
   sta IRQVec+1
   rts



handle_irq:
   ; check for VSYNC
   lda VERA_isr
   and #$01
   beq @done_vsync
   sta vsync_trig
   ; clear vera irq flag
   sta VERA_isr
@done_vsync:

   ; check for AFLOW
   lda VERA_isr
   and #$08
   beq @done_aflow
   sta aflow_trig
@done_aflow:

   ; TODO check other IRQs

   jmp (def_irq)




.endif
