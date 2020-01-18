.ifndef TITLE_SCREEN_INC
TITLE_SCREEN_INC = 1

.include "x16.inc"
.include "globals.asm"
.include "menu.asm"

ts_tick:
   lda ts_playing
   bne @countdown
   jmp @return
@countdown:
   lda ts_dur
   sec
   sbc #1
   sta ts_dur
   lda ts_dur+1
   sbc #0
   sta ts_dur+1
   bne @return
   lda ts_dur
   bne @return
   stz ts_playing ; this is last tick of title screen
   jsr stop_anim
   jsr stop_music
   jsr init_menu
@return:
   rts


.endif
