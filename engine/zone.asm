.ifndef ZONE_INC
ZONE_INC = 1

.include "x16.inc"
.include "globals.asm"
.include "toolbar.asm"

new_game:
   stz zone
   stz level
   ; TODO - reset game state
   jsr load_zone
   jsr init_toolbar
   rts

load_zone:

   rts

.endif
