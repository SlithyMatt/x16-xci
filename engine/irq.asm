.ifndef IRQ_INC
IRQ_INC = 1

.include "vsync.asm"

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
   lda VERA_irq
   and #$01
   beq @done_vsync
   sta vsync_trig
   ; clear vera irq flag
   sta VERA_irq

@done_vsync:

   ; TODO check other IRQs

   jmp (def_irq)




.endif
