.ifndef MENU_INC
MENU_INC = 1

.include "x16.inc"
.include "globals.asm"

; MENU_PTR offsets
MENU_DIV       = 80
MENU_SPACE     = 82
MENU_CHECK     = 84
MENU_UNCHECK   = 86
MENU_CONTROLS  = 88
MENU_ABOUT     = 90
MENU_NUM       = 92

init_menu:
   ; blackout bitmap

   ; clear all tiles

   ; init mouse cursor

   ; disable other sprites

   ; render menu bar

   rts

menu_tick:

@return:
   rts


.endif
