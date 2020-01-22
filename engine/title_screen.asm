.ifndef TITLE_SCREEN_INC
TITLE_SCREEN_INC = 1

.include "x16.inc"
.include "globals.asm"
.include "menu.asm"
.include "toolbar.asm"

ts_tick:
   lda ts_playing
   bne @check_click
   bra @return
@check_click:
   lda mouse_left_click
   beq @countdown
   bra @stop
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
@stop:
   stz ts_playing ; this is last tick of title screen
   jsr stop_anim
   jsr stop_music
   jsr init_menu
   jsr init_toolbar
@return:
   rts


.endif
