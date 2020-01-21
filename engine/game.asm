.ifndef GAME_INC
GAME_INC = 1

.include "x16.inc"
.include "globals.asm"
.include "music.asm"
.include "menu.asm"
.include "animation.asm"
.include "title_screen.asm"
.include "mouse.asm"

init_game:
   jsr init_music
   rts

game_tick:        ; called after every VSYNC detected (60 Hz)
   inc frame_num
   lda frame_num
   cmp #60
   bne @tick
   lda #0
   sta frame_num
@tick:
   jsr ts_tick
   jsr mouse_tick
   jsr music_tick
   jsr menu_tick
   jsr anim_tick
@return:
   rts


.endif
