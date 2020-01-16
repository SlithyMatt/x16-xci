.ifndef VSYNC_INC
VSYNC_INC = 1

.include "game.asm"

vsync_trig: .byte 0

check_vsync:
   lda vsync_trig
   beq @done

   ; VSYNC has occurred, handle
   jsr game_tick

   stz vsync_trig
@done:
   rts

.endif
